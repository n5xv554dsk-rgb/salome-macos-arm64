import pydefx
import os
import pickle
import time
import traceback

pydefx.forceNoSalomeServers()
class Context:
  def __init__(self):
    self.launcher = pydefx.salome_proxy.getLauncher() # getLauncher()
  pass

class JobExecutor:
  def __init__(self, config):
    self.config = config

  def initialize(self):
    """ This is executed before the first evaluation.
    Put here global processing needed by all the evaluations like the copy of
    commun files.
    """
    # Copy the commun files to the root work directory
    params = pydefx.Parameters() # global parameters
    params.loadDict(self.config["params"])
    # use a fake empty command.
    # Using launcher to copy some files on the remote file system,
    # without launching a job.
    command = os.path.join(os.getcwd(), "empty.sh")
    open(command, "w").close()
    params.salome_parameters.job_file = command
    params.salome_parameters.job_type = "command"
    study_module = os.path.join(os.getcwd(), self.config["studymodule"]+".py")
    infiles = list(params.salome_parameters.in_files)
    params.salome_parameters.in_files = infiles + [study_module]
    launcher = pydefx.salome_proxy.getLauncher()
    job_id = launcher.createJob(params.salome_parameters)
    launcher.exportInputFiles(job_id)

  def evaluate(self, idx, point):
    """ This is executed for every point to be evaluated.
    """
    context = Context()
    error = None
    out_values = None
    try:
      self.prepare(idx, point, context)
      if self.noRunFound(idx, point, context):
        self.runjob(idx, point, context)
      error, out_values = self.getResult(context)
    except Exception as e:
      error = str(e)
      traceback.print_exc()
    return error, out_values

  def prepare(self, idx, point, context):
    """
    Define local and remote work directory.
    Define job script.
    """
    context.params = pydefx.Parameters()
    context.params.loadDict(self.config["params"])
    salome_parameters = context.params.salome_parameters
    root_local_dir = salome_parameters.result_directory
    root_remote_dir = salome_parameters.work_directory
    input_files = [] # commun files are already copied to the root directory
    point_name = "job_"+str(idx)
    context.local_dir = os.path.join(root_local_dir, point_name)
    point_remote_dir = os.path.join(root_remote_dir, point_name)
    if not os.path.exists(context.local_dir):
      os.mkdir(context.local_dir)
    # export the point to a file
    data_file_name = "idefixdata.csv"
    data_file_path = os.path.join(context.local_dir, data_file_name)
    with open(data_file_path, "w") as f:
      # explicit dict convertion is needed for compatibility between python versions
      f.write(repr(dict(point)))
    input_files.append(data_file_path)

    #command_path = os.path.join(root_local_dir, "command.py")
    #salome_parameters.job_type = "command_salome"
    #salome_parameters.job_file = command_path

    salome_parameters.in_files = input_files
    salome_parameters.out_files = ["idefixresult.txt", "idefixerror.txt"]
    salome_parameters.work_directory = point_remote_dir
    salome_parameters.result_directory = context.local_dir

  def noRunFound(self, idx, point, context):
    return True

  def runjob(self, idx, point, context):
    """
    Create, launch and wait for the end of the job.
    """
    import random
    sleep_delay = random.randint(5, 15) #10
    #launcher = pydefx.salome_proxy.getLauncher()
    launcher = context.launcher
    context.job_id = launcher.createJob(context.params.salome_parameters)
    launcher.launchJob(context.job_id)
    jobState = launcher.getJobState(context.job_id)
    while jobState=="QUEUED" or jobState=="IN_PROCESS" or jobState=="RUNNING" :
      time.sleep(sleep_delay)
      jobState = launcher.getJobState(context.job_id)

  def getResult(self, context):
    """
    Check the job state, fetch the result file.
    """
    #launcher = pydefx.salome_proxy.getLauncher()
    launcher = context.launcher
    jobState = launcher.getJobState(context.job_id)
    error=""
    result=None
    if jobState != "FINISHED" :
      error = "Job has not finished correctly."
    else:
      launcher.getJobResults(context.job_id, "")
      error_file = os.path.join(context.local_dir, "idefixerror.txt")
      result_file = os.path.join(context.local_dir, "idefixresult.txt")
      with open(error_file, "r") as f:
        error = f.read()
      with open(result_file, "r") as f:
        result_str = f.read()
        result = eval(result_str)

    return error, result

def createExecutor(config):
  return JobExecutor(config)
