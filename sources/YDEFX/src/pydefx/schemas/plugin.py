from salome.yacs import SALOMERuntime
import pickle
import json
import importlib

class myalgosync(SALOMERuntime.OptimizerAlgSync):
  def __init__(self):
    SALOMERuntime.OptimizerAlgSync.__init__(self, None)
    self.started = False

  def setPool(self,pool):
    """Must be implemented to set the pool"""
    self.pool=pool

  def getTCForIn(self):
    """return typecode of type expected as Input of the internal node """
    return SALOMERuntime.getSALOMERuntime().getTypeCode("string")

  def getTCForOut(self):
    """return typecode of type expected as Output of the internal node"""
    return SALOMERuntime.getSALOMERuntime().getTypeCode("string")

  def getTCForAlgoInit(self):
    """return typecode of type expected as input for initialize """
    return SALOMERuntime.getSALOMERuntime().getTypeCode("string")

  def getTCForAlgoResult(self):
    """return typecode of type expected as output of the algorithm """
    return SALOMERuntime.getSALOMERuntime().getTypeCode("int")

  def initialize(self,input):
    """Optional method called on initialization.
       The type of "input" is returned by "getTCForAlgoInit"
    """
    with open("idefixconfig.json", "r") as f:
      self.config = json.load(f)

  def start(self):
    """Start to fill the pool with samples to evaluate."""
    itModuleName = self.config["sampleIterator"]
    itModule = importlib.import_module(itModuleName)
    self.started = True
    self.manager = itModule.SampleIterator()
    self.manager.writeHeaders()
    values=None
    for i in range(0, self.getNbOfBranches()):
      try:
        newid, values = next(self.manager)
        self.pool.pushInSample(newid, pickle.dumps(values, protocol=0).decode())
      except StopIteration:
        pass

  def takeDecision(self):
    """ This method is called each time a sample has been evaluated. It can
        either add new samples to evaluate in the pool, do nothing (wait for
        more samples), or empty the pool to finish the evaluation.
    """
    currentId=self.pool.getCurrentId()
    samplebyte=self.pool.getCurrentInSample().getStringValue().encode()
    sample = pickle.loads(samplebyte)
    resultbyte=self.pool.getCurrentOutSample().getStringValue().encode()
    error,result = pickle.loads(resultbyte)
    self.manager.addResult(currentId, sample, result, error)
    try:
      newid, values = next(self.manager)
      self.pool.pushInSample(newid, pickle.dumps(values, protocol=0).decode())
    except StopIteration:
      pass

  def finish(self):
    """Optional method called when the algorithm has finished, successfully
       or not, to perform any necessary clean up."""
    if self.started :
      self.manager.terminate()
      self.pool.destroyAll()

  def getAlgoResult(self):
    """return the result of the algorithm.
       The object returned is of type indicated by getTCForAlgoResult.
    """
    return 0
