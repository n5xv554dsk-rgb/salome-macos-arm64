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
import csv
import inspect
import os
import pathlib
from . import sample
from . import samplecsviterator
SampleIterator = samplecsviterator.SampleIterator

class SampleManager:
  """
  The SampleManager is used by the study for reading and writing a sample from
  and to the file system. This SampleManager uses the csv format.
  The following services are needed by the study:
  - write the sample on the local file system (prepareRun).
  - know what files were written in order to copy them on the remote file system
  (return value of prepareRun).
  - know what files contain the result in order to bring them back from the
  remote file system to the local one (getResultFileName).
  - load the results from the local file system to a sample (loadResult).
  - restore a sample from a local directory when you want to recover a job
  launched in a previous session.
  - the name of the module which contains the class SampleIterator in order to
  iterate over the input values of the sample (getModuleName).
  This name is written by the study in a configuration file and it is used by
  the optimizer loop plugin.
  """
  def __init__(self):
    pass

  # Functions used by the study
  def prepareRun(self, sample, directory):
    """
    Create a dump of the sample in the given directory.
    sample: Sample object.
    directory: path to a local working directory where all the working files are
               copied. This directory should be already created.
    Return a list of files to add to the input files list of the job.
    """
    datapath = os.path.join(directory, SampleIterator.DATAFILE)
    with open(datapath, 'w', newline='') as csvfile:
      writer = csv.DictWriter(csvfile,
                              fieldnames=sample.getInputNames(),
                              quoting=csv.QUOTE_NONNUMERIC )
      writer.writeheader()
      writer.writerows(sample.inputIterator())

    outnamespath = os.path.join(directory, SampleIterator.OUTPUTNAMESFILE)
    with open(outnamespath, 'w') as outputfile:
      for v in sample.getOutputNames():
        outputfile.write(v+'\n')
    filename = inspect.getframeinfo(inspect.currentframe()).filename
    install_directory = pathlib.Path(filename).resolve().parent
    iteratorFile = os.path.join(install_directory, "samplecsviterator.py")
    return [datapath,
            outnamespath,
            iteratorFile
            ]

  def loadResult(self, sample, directory):
    """
    The directory should contain a RESULTDIR directory with the result files.
    The results are loaded into the sample.
    Return the global result of the study which can be used by an insitu
    computation.
    """
    resultdir = os.path.join(directory, SampleIterator.RESULTDIR)
    datapath = os.path.join(resultdir, SampleIterator.RESULTFILE)
    with open(datapath, newline='') as datafile:
      data = csv.DictReader(datafile, quoting=csv.QUOTE_NONNUMERIC)
      for elt in data:
        index = int(elt[SampleIterator.IDCOLUMN]) # float to int
        input_vals = {}
        for name in sample.getInputNames():
          input_vals[name] = elt[name]
        output_vals = {}
        for name in sample.getOutputNames():
          output_vals[name] = samplecsviterator._decodeOutput(elt[name],
                                                              resultdir)
        try:
          sample.checkId(index, input_vals)
        except Exception as err:
          extraInfo = "Error on processing file {} index number {}:".format(
                                                datapath, str(index))
          raise Exception(extraInfo + str(err))
        sample.addResult(index, output_vals, elt[SampleIterator.ERRORCOLUMN])
    return sample

  def restoreSample(self, directory):
    """ The directory should contain the files created by prepareRun. A new
    sample object is created and returned from those files.
    This function is used to recover a previous run.
    """
    sampleIt = SampleIterator(directory)
    inputvalues = {}
    for name in sampleIt.inputnames:
      inputvalues[name] = []
    for newid, values in sampleIt:
      for name in sampleIt.inputnames:
        inputvalues[name].append(values[name])
    
    result = sample.Sample(sampleIt.inputnames, sampleIt.outputnames)
    result.setInputValues(inputvalues)
    sampleIt.terminate()
    return result

  def getModuleName(self):
    """
    Return the module name which contains the class SampleIterator.
    """
    return "samplecsviterator"
  
  def getResultFileName(self):
    """
    Name of the file or directory which contains the result and needs to be
    copied from the remote computer.
    """
    return SampleIterator.RESULTDIR

