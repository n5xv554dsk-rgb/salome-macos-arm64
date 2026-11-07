#! /usr/bin/env python3
import traceback
import os

data_file_name = "idefixdata.csv"
study_module = "idefixstudy.py"
error_result = "idefixerror.txt"
value_result = "idefixresult.txt"
traceback_result = "idefixtraceback.txt"

with open(data_file_name, "r") as f:
  values = f.read()
inputvals = eval(values)

error=""
result=None
old_dir = os.getcwd()

try:
  os.chdir("..") # go to commun root directory
  with open(study_module, "r") as study_file:
    study_string = study_file.read()
  exec(study_string)
  result = _exec(**inputvals)
except Exception as e:
  error=str(e)
  if not error :
    error = "Exception " + repr(e)
  os.chdir(old_dir) # back to the current case job directory
  with open(traceback_result, "w") as f:
    traceback.print_exc(file=f)

os.chdir(old_dir) # back to the current case job directory

with open(error_result, "w") as f:
  f.write(error)

with open(value_result, "w") as f:
  f.write(repr(result))
