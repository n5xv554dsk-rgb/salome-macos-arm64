import unittest
import os
import time

class TestYdefx(unittest.TestCase):
  def test_errors(self):
    """
    Test errors in study script.
    """
    import pydefx

    myScript = pydefx.PyScript()
    myScript.loadString("a=5")
    self.assertIn("not accepted statement", myScript.getErrors())
    
    myScript.loadString("n'importe quoi!")
    self.assertIn("SyntaxError", myScript.getErrors())

    myScript.loadString("")
    self.assertIn("Function _exec not found", myScript.getErrors())
    
    with self.assertRaises(pydefx.pyscript.PyScriptException):
      mySample = myScript.CreateEmptySample()

  def test_availableResources(self):
    import pydefx
    lr = pydefx.configuration.availableResources()
    self.assertIn('localhost', lr)

  def test_invalid_study(self):
    import pydefx
    myParams = pydefx.Parameters()
    myParams.configureResource("localhost")
    myScript = pydefx.PyScript()
    myStudy = pydefx.PyStudy()

    myScript.loadString("wrong 'script")
    mySample = pydefx.Sample([],[])
    try:
      myStudy.createNewJob(myScript, mySample, myParams)
      self.fail("Excpected pydefx.pyscript.PyScriptException!")
    except pydefx.pyscript.PyScriptException:
      pass
    except pydefx.studyexception.StudyException:
      pass

    script="""
def _exec():
  x=5
  return x
"""
    myScript.loadString(script)
    try:
      myStudy.createNewJob(myScript, mySample, myParams)
      self.fail("Excpected pydefx.studyexception.StudyUseException!")
    except pydefx.studyexception.StudyException:
      pass

    script="""
def _exec(a):
  x=5
  return x
"""
    myScript.loadString(script)
    try:
      myStudy.createNewJob(myScript, mySample, myParams)
      self.fail("Excpected pydefx.studyexception.StudyUseException!")
    except pydefx.studyexception.StudyException:
      pass

    mySample = pydefx.Sample(["b"],[])
    try:
      myStudy.createNewJob(myScript, mySample, myParams)
      self.fail("Excpected pydefx.studyexception.StudyUseException!")
    except pydefx.studyexception.StudyException:
      pass

if __name__ == '__main__':
    unittest.main()
