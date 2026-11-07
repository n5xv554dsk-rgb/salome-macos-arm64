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
import numbers
import pickle
import os

class SampleIterator:
  """
  Iterator used to iterate over the input values of a sample, adding an order
  number. The order number is the id you get as the first parameter of the
  function addResult.
  """
  DATAFILE = "idefixdata.csv"
  OUTPUTNAMESFILE = "idefixoutputnames.csv"
  RESULTDIR = "idefixresult" # directory which contains all the result files
  RESULTFILE = "idefixresult.csv" # main result file - values for every point
  GLOBALFILE = "idefixglobal"     # global result - one value for the whole simulation
  ERRORCOLUMN = "idefix_error"
  IDCOLUMN ="idefix_id"
  ESCAPE_CHAR = "@"   # prefix a value that needs particular save/load procedure
  PICK_CHAR = "p"     # @p : csv value saved in another file using pickle

  def __init__(self, directory=None):
    if directory:
      datapath = os.path.join(directory, SampleIterator.DATAFILE)
      outputnamespath = os.path.join(directory, SampleIterator.OUTPUTNAMESFILE)
      self.result_directory = os.path.join(directory, SampleIterator.RESULTDIR)
      self.directory = directory
    else:
      datapath = SampleIterator.DATAFILE
      outputnamespath = SampleIterator.OUTPUTNAMESFILE
      self.result_directory = SampleIterator.RESULTDIR
      self.directory = None
    self.result_file = None
    self.datafile = open(datapath, newline='')
    self.data     = csv.DictReader(self.datafile, quoting=csv.QUOTE_NONNUMERIC)
    self.inputnames = self.data.fieldnames
    self.outputnames = _loadOutputNames(outputnamespath)
    self.iterNb = -1

  def __next__(self):
    self.iterNb += 1
    return self.iterNb, next(self.data)

  def __iter__(self):
    return self

  def writeHeaders(self):
    """
    This function can be called before the first call to addResult in order to
    write the names of the parameters in the result file.
    """
    if self.directory:
      outputnamespath = os.path.join(self.directory,
                                     SampleIterator.OUTPUTNAMESFILE)
    else:
      outputnamespath = SampleIterator.OUTPUTNAMESFILE
    os.makedirs(self.result_directory, exist_ok=True)
    resultpath = os.path.join(self.result_directory, SampleIterator.RESULTFILE)
    result_columns = [SampleIterator.IDCOLUMN]
    result_columns.extend(self.inputnames)
    result_columns.extend(self.outputnames)
    result_columns.append(SampleIterator.ERRORCOLUMN)
    self.result_file = open(resultpath, 'w', newline='')
    self.result_csv = csv.DictWriter( self.result_file,
                                      fieldnames=result_columns,
                                      quoting=csv.QUOTE_NONNUMERIC )
    self.result_csv.writeheader()
    self.result_file.flush()

  def addResult(self, currentId, currentInput, currentOutput, currentError):
    """
    You need to call writeHeaders before the first call of this function.
    currentId : int value
    currentInput : dictionary {"input name":value}
    currentOutput : result returned by _exec.  Can be a tuple, a simple value or
    None in case of error.
    currentError : string or None if no error
    """
    currentRecord = {}
    currentRecord[SampleIterator.IDCOLUMN] = currentId
    for name in self.inputnames:
      currentRecord[name] = currentInput[name]
    if currentError is None:
      if len(self.outputnames) == 1 :
        outputname = self.outputnames[0]
        currentRecord[outputname] = _codeOutput(currentOutput,
                                                currentId,
                                                outputname,
                                                self.directory)
      elif len(self.outputnames) > 1 :
        outputIter = iter(currentOutput)
        for name in self.outputnames:
          currentRecord[name] = _codeOutput(next(outputIter),
                                            currentId,
                                            name,
                                            self.directory)
    else:
      for name in self.outputnames:
        currentRecord[name] = None
    currentRecord[SampleIterator.ERRORCOLUMN] = currentError
    self.result_csv.writerow(currentRecord)
    self.result_file.flush()

  def terminate(self):
    """
    Call this function at the end of the simulation in order to close every
    open files.
    """
    if not self.datafile is None:
      self.datafile.close()
      self.datafile = None
    if not self.result_file is None:
      self.result_file.close()
      self.result_file = None

# Private functions
def _loadOutputNames(filepath):
    outputnames = []
    with open(filepath, "r") as namesfile:
      for line in namesfile:
        line = line.rstrip() # remove whitespaces at the end
        outputnames.append(line)
    return outputnames

# Read and write results (output parameters)
def _codeOutput(value, currentId, name, directory=None):
  """
  Define how a value should be saved.
  value: object to be saved - value of a parameter
  currentId: number of the current line (current point).
  name: name of the parameter (name of the column in the csv file).
  return: string to be saved in the csv file.
  """
  res = None
  if isinstance(value, numbers.Number):
    res = value
  elif isinstance(value, str):
    res = value
    if res[0:1] == SampleIterator.ESCAPE_CHAR :
      res = SampleIterator.ESCAPE_CHAR + res
  else:
    file_name = "idefixresult-{}-{}.pick".format(name, currentId)
    res = SampleIterator.ESCAPE_CHAR + SampleIterator.PICK_CHAR + file_name
    file_path = os.path.join(SampleIterator.RESULTDIR, file_name)
    if directory :
      file_path = os.path.join(directory, file_path)
    with open(file_path, "wb") as f:
      pickle.dump(value, f)
  return res

def _decodeOutput(obj, resultdir):
  """
  Decode a value read from the csv file.
  obj: object to decode (string or number).
  resultdir : directory which contains the result files
  return: decoded object.
  """
  res = None
  if isinstance(obj, numbers.Number):
    res = obj
  elif isinstance(obj, str):
    res = obj
    if res[0:1] == SampleIterator.ESCAPE_CHAR :
      res = res[1:]
      if res[0:1] == SampleIterator.ESCAPE_CHAR :# obj = @@string begins with@
        pass
      elif res[0:1] == SampleIterator.PICK_CHAR:# obj = @pidefixresult-x-1.pick
        file_path = os.path.join(resultdir, res[1:])
        with open(file_path, "rb") as f:
          res = pickle.load(f)
      else:
        raise Exception("Unknown escape value:" + obj)
  return res
