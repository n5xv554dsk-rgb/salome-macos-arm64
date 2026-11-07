# -*- coding: utf-8 -*-
# Copyright (C) 2019-2026 EDF
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
#
# See http://www.salome-platform.org/ or email : webmaster.salome@opencascade.com
#
import inspect
import pathlib
import tempfile
import os
import json
from . import salome_proxy
from . import samplecsvmanager
from . import parameters
from . import configuration
from . import defaultschemabuilder
from .studyexception import StudyUseException, StudyRunException
from .studyresult import StudyResult

def defaultSampleManager():
  return samplecsvmanager.SampleManager()

class PyStudy:
  JOB_DUMP_NAME = "jobDump.xml"
  def __init__(self, sampleManager=None, schemaBuilder=None):
    self.job_id = -1
    self.global_result = StudyResult()
    if sampleManager is None:
      self.sampleManager = defaultSampleManager()
    else:
      self.sampleManager = sampleManager
    if schemaBuilder is None:
      self.schemaBuilder = defaultschemabuilder.DefaultSchemaBuilder()
    else:
      self.schemaBuilder = schemaBuilder

  # Study creation functions
  def createNewJob(self, script, sample, params):
    """
    Create a new job out of those parameters:
    script : script / pyscript type
    sample : sample to be evaluated (Sample class)
    params : job submission parameters (Parameters class)
    The result directory will contain all the files needed for a launch and a
    job is created but not launched.
    """
    self._check(script,sample)
    self.sample = sample
    self.params = params
    self.params.salome_parameters.job_type = self.jobType()
    tmp_workdir = self.params.salome_parameters.result_directory
    schema_path, extra_files = self._prepareDirectoryForLaunch(tmp_workdir,
                                                               script)
    # this list manipulation is needed because in_files is not a python list
    # if we don't use a salome session. In that case swig uses a python tuple
    # in order to map a std::list as a parameter of a structure.
    in_files_as_list = list(self.params.salome_parameters.in_files)
    self.params.salome_parameters.in_files = in_files_as_list + extra_files
    self.params.salome_parameters.job_file = schema_path
    launcher = salome_proxy.getLauncher()
    self.job_id = launcher.createJob(self.params.salome_parameters)
    return self.job_id

  def loadFromDirectory(self, path):
    """
    Recover a study from a result directory where a previous study was launched.
    """
    self.sample = self.sampleManager.restoreSample(path)
    job_string = loadJobString(path)
    launcher = salome_proxy.getLauncher()
    self.job_id = launcher.restoreJob(job_string)
    if self.job_id >= 0:
      salome_params = launcher.getJobParameters(self.job_id)
      self.params = parameters.Parameters(salome_parameters=salome_params)
      self.getResult()
    return self.job_id

  def loadFromString(self, jobstring):
    """
    Recover a study from a string which contains the description of the job.
    This string can be obtained by launcher.dumpJob.
    """
    launcher = salome_proxy.getLauncher()
    self.job_id = launcher.restoreJob(jobstring)
    self.params = None
    self.sample = None
    if self.job_id >= 0:
      salome_params = launcher.getJobParameters(self.job_id)
      self.params = parameters.Parameters(salome_parameters=salome_params)
      #TODO: sampleManager should be loaded from result_directory
      self.sample = self.sampleManager.restoreSample(
                                                 salome_params.result_directory)
      self.getResult()
    else:
      raise StudyRunException("Failed to restore the job.")

  def loadFromId(self, jobid):
    """
    Connect the study to an already created job.
    The result directory of the job must be already prepared for launch.
    """
    if jobid < 0:
      return
    self.job_id = jobid
    launcher = salome_proxy.getLauncher()
    salome_params = launcher.getJobParameters(self.job_id)
    self.params = parameters.Parameters(salome_parameters=salome_params)
    #TODO: sampleManager should be loaded from result_directory
    self.sample=self.sampleManager.restoreSample(salome_params.result_directory)
    self.script = None
    return

  # launch parameters functions
  def jobType(self):
    return "yacs_file"

  # TODO: may be deprecated
  def createDefaultParameters(self, resource="localhost",
                              nb_branches=None,
                              result_base_dir=None):
    """
    Create the Parameters structure and the result directory.
    The result directory created here is needed by the job.
    """
    newParams = parameters.Parameters(resource, nb_branches)
    newParams.salome_parameters.job_type = self.jobType()
    newParams.salome_parameters.job_name = "idefix_job"
    newParams.salome_parameters.result_directory = configuration.newResultDirectory(result_base_dir)
    return newParams

  # Job management functions
  def launch(self):
    """
    The job should have been already created.
    """
    if self.job_id < 0 :
      raise StudyUseException("Nothing to launch! Job is not created!")
    tmp_workdir = self.params.salome_parameters.result_directory
    # run the job
    launcher = salome_proxy.getLauncher()
    launcher.launchJob(self.job_id)
    #save the job
    job_string = launcher.dumpJob(self.job_id)
    jobDumpPath = os.path.join(tmp_workdir, PyStudy.JOB_DUMP_NAME)
    with open(jobDumpPath, "w") as f:
      f.write(job_string)

  def getResult(self):
    """
    Try to get the result file and if it was possible the results are loaded in
    the sample.
    An exception may be thrown if it was not possible to get the file.
    Return a StudyResult object.
    """
    self.global_result = StudyResult()
    if self.job_id < 0 :
      raise StudyUseException("Cannot get the results if the job is not created!")
    launcher = salome_proxy.getLauncher()
    state = launcher.getJobState(self.job_id)
    tmp_workdir = self.params.salome_parameters.result_directory
    searchResults = False
    errorIfNoResults = False
    errorMessage = ""
    if state == "CREATED" :
      raise StudyUseException("Cannot get the results if the job is not launched!")
    elif state ==  "QUEUED" or state == "IN_PROCESS":
      # no results available at this point. Try again later! Not an error.
      searchResults = False
    elif state == "FINISHED" :
      # verify the return code of the execution
      searchResults = True
      if(launcher.getJobWorkFile(self.job_id, "logs/exit_code.log", tmp_workdir)):
        exit_code_file = os.path.join(tmp_workdir, "exit_code.log")
        exit_code = ""
        if os.path.isfile(exit_code_file):
          with open(exit_code_file) as myfile:
            exit_code = myfile.read()
            exit_code = exit_code.strip()
        self.global_result.exit_code = exit_code
        if exit_code == "0" :
          errorIfNoResults = True # we expect to have full results
        else:
          errorMessage = "An error occured during the execution of the job."
      else:
        errorMessage = "Failed to get the exit code of the job."

    elif state == "RUNNING" or state == "PAUSED" or state == "ERROR" :
      # partial results may be available
      searchResults = True
    elif state == "FAILED":
      # We may have some partial results because the job could have been
      # canceled or stoped by timeout.
      searchResults = True
      errorMessage = "Job execution failed!"
    if searchResults :
      if 1 == launcher.getJobWorkFile(self.job_id,
                                      self.sampleManager.getResultFileName(),
                                      tmp_workdir):
        try:
          res = self.sampleManager.loadResult(self.sample, tmp_workdir)
          self.global_result.result = res
        except Exception as err:
          if errorIfNoResults:
            raise err
      elif errorIfNoResults:
        errorMessage = "The job is finished but we cannot get the result file!"
    if len(errorMessage) > 0 :
      warningMessage = """
The results you get may be incomplete or incorrect.
For further details, see {}/logs directory on {}.""".format(
                          self.params.salome_parameters.work_directory,
                          self.params.salome_parameters.resource_required.name)
      errorMessage += warningMessage
      self.global_result.error_message = errorMessage
      raise StudyRunException(errorMessage)
    return self.global_result

  def resultAvailable(self):
    """
    Try to get the result and return True in case of success with no exception.
    In case of success the results are loaded in the sample.
    """
    resultFound = False
    try:
      self.getResult()
      resultFound = True
    except:
      resultFound = False
    return resultFound

  def getJobState(self):
    if self.job_id < 0:
      return "NOT_CREATED"
    launcher = salome_proxy.getLauncher()
    return launcher.getJobState(self.job_id)

  def getProgress(self):
    if self.job_id < 0:
      return 0.0
    state = self.getJobState()
    if state == "CREATED" or state == "QUEUED" :
      return 0.0
    if not self.resultAvailable():
      return 0.0
    return self.sample.progressRate()

  def cancel(self):
    if self.job_id >= 0 :
      launcher = salome_proxy.getLauncher()
      launcher.stopJob(self.job_id)

  def dump(self):
    if self.job_id < 0 :
      raise StudyUseException("Cannot dump the job if it is not created!")
    launcher = salome_proxy.getLauncher()
    return launcher.dumpJob(self.job_id)

  def wait(self, sleep_delay=10):
    """ Wait for the end of the job """
    launcher = salome_proxy.getLauncher()
    job_id = self.job_id
    jobState = launcher.getJobState(job_id)
    import time
    while jobState=="QUEUED" or jobState=="IN_PROCESS" or jobState=="RUNNING" :
      time.sleep(sleep_delay)
      jobState = launcher.getJobState(job_id)

  def _prepareDirectoryForLaunch(self, result_directory, script):
    """
    result_directory : path to a result working directory.
    script : script / pyscript type
    return:
      yacs_schema_path: path to the yacs schema (xml file).
      extra_in_files: list of files to add to salome_parameters.in_files
    """
    if not os.path.exists(result_directory):
      os.makedirs(result_directory)
    # export sample to result_directory
    inputFiles = self.sampleManager.prepareRun(self.sample, result_directory)

    # export nbbranches
    dicconfig = {}
    dicconfig["nbbranches"]  = self.params.nb_branches
    dicconfig["studymodule"] = "idefixstudy"
    dicconfig["sampleIterator"] = self.sampleManager.getModuleName()
    configpath = configuration.exportConfig(dicconfig, result_directory)
    studypath = os.path.join(result_directory, "idefixstudy.py")
    with open(studypath, "w") as f:
      f.write(script.script)
    schema_path, extra_files = self.schemaBuilder.buildSchema(result_directory)

    extra_files.extend([configpath, studypath])
    extra_files.extend(inputFiles)
    return schema_path, extra_files

  def _check(self, script, sample):
    "Raise StudyUseException if the sample does not match with the sample."
    script_params = script.getInputNames()
    sample_inputs = sample.getInputNames()
    if len(script_params) < 1:
      raise StudyUseException("The study function should have at least one parameter. None found.")
    if len(script_params) != len(sample_inputs):
      m="The study function should have the same number of parameters as the input variables in the sample ({} != {})."
      raise StudyUseException(m.format(len(script_params), len(sample_inputs)))
    for nm in script_params:
      if nm not in sample_inputs:
        raise StudyUseException("Parameter {} not found in the sample.".format(nm))

### Deprecated!!!!
def loadJobString(result_directory):
  """
  Return the jobString saved by the dumpJob function into a directory.
  Use dumpJob for saving the string.
  """
  jobDumpPath = os.path.join(result_directory, PyStudy.JOB_DUMP_NAME)
  with open(jobDumpPath, "r") as f:
    job_string = f.read()
  return job_string

