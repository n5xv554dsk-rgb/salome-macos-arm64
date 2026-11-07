#! /usr/bin/env python3
import json
import importlib
from multiprocessing import Pool
import traceback

class StartJob:
  def __init__(self, executor):
    self.executor = executor

  def __call__(self, idx, in_values):
    error=None
    out_values=None
    try:
      error, out_values = self.executor.evaluate(idx, in_values)
    except Exception as e:
      error=str(e)
      traceback.print_exc()
    return idx, in_values, out_values, error

class TerminateJob:
  def __init__(self, manager):
    self.manager = manager

  def __call__(self, result):
    # without try statement we may experience deadlock in case of error.
    try:
      idx, in_values, out_values, error = result
      if not error:
        error = None
      self.manager.addResult(idx, in_values, out_values, error)
    except Exception as e:
      traceback.print_exc()

if __name__ == '__main__':
  with open("idefixconfig.json", "r") as f:
    config = json.load(f)
  plugin_module = importlib.import_module(config["plugin"])
  executor = plugin_module.createExecutor(config)
  # global initialization - commun work for every evaluation.
  executor.initialize()

  itModuleName = config["sampleIterator"]
  itModule = importlib.import_module(itModuleName)
  sampleManager = itModule.SampleIterator()
  sampleManager.writeHeaders()

  nbbranches=config["nbbranches"]
  pool = Pool(nbbranches)
  runPoint = StartJob(executor)
  endOk = TerminateJob(sampleManager)
  for point in sampleManager:
    pool.apply_async(runPoint, point, callback=endOk)
  pool.close()
  pool.join()
  sampleManager.terminate()
