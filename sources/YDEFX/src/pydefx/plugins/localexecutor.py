import os
import pickle
import time
import traceback
import subprocess

class Context:
  def __init__(self):
    pass

class JobExecutor:
  def __init__(self, config):
    self.config = config

  def initialize(self):
    """ This is executed before the first evaluation.
    Put here global processing needed by all the evaluations like the copy of
    commun files.
    """
    pointeval = os.path.join(os.getcwd(), "pointeval.py")
    os.chmod(pointeval, 0o755)

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
    root_dir = os.getcwd()
    point_name = "job_"+str(idx)
    context.local_dir = os.path.join(root_dir, point_name)
    if not os.path.exists(context.local_dir):
      os.mkdir(context.local_dir)
    # export the point to a file
    data_file_name = "idefixdata.csv"
    data_file_path = os.path.join(context.local_dir, data_file_name)
    with open(data_file_path, "w") as f:
      # explicit dict convertion is needed for compatibility between python versions
      f.write(repr(dict(point)))

  def noRunFound(self, idx, point, context):
    return True

  def runjob(self, idx, point, context):
    """
    Create, launch and wait for the end of the job.
    """
    pointeval = os.path.join(os.getcwd(), "pointeval.py")
    return_code = subprocess.check_call(pointeval, shell=True, cwd=context.local_dir)

  def getResult(self, context):
    """
    Check the job state, fetch the result file.
    """
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
