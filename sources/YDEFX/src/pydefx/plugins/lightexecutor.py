import os
import pickle
import time
import traceback
import subprocess

class Context:
  def __init__(self):
    #self.launcher = pydefx.salome_proxy.getLauncher() # getLauncher()
    pass

class JobExecutor:
  def __init__(self, config):
    self.config = config

  def initialize(self):
    """ This is executed before the first evaluation.
    Put here global processing needed by all the evaluations like the copy of
    commun files.
    """
    pass

  def evaluate(self, idx, point):
    """ This is executed for every point to be evaluated.
    """
    context = Context()
    error = None
    out_values = None
    studymodule=self.config["studymodule"]
    import importlib
    try:
      idefixstudy=importlib.import_module(studymodule)
      out_values=idefixstudy._exec(**point)
    except Exception as e:
      error=str(e)
      traceback.print_exc()
    return error, out_values

def createExecutor(config):
  return JobExecutor(config)
