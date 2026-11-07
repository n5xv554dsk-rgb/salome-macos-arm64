import unittest
import insitu.insitumanager
import os
import time


class TestYdefx(unittest.TestCase):
  def test_insitu(self):
    """
    This test shows how to use insitu processing.
    """
    import pydefx

    myParams = pydefx.Parameters()
    myParams.configureResource("localhost")
    mywd = os.path.join(myParams.salome_parameters.work_directory,
                        "insitu_test" +
                        time.strftime("%Y-%m-%d-%H-%M-%S", time.localtime()))
    myParams.salome_parameters.work_directory = mywd
    myParams.createResultDirectory("/tmp")

    pyScript = """
def _exec(x):
  with open("mydata.txt") as f:
    mydata = f.read()
  intdata = int(mydata)
  y = x + intdata
  return y"""

    myScript = pydefx.PyScript()
    myScript.loadString(pyScript)

    mySample = myScript.CreateEmptySample()
    mydata = {"x":list(range(10))}
    mySample.setInputValues(mydata)

    # pre-processing script called before the first evaluation
    myPrescript = """
with open("mydata.txt", "w") as f:
  f.write("1")
"""
    mySchemaBuilder = pydefx.DefaultSchemaBuilder(myPrescript)

    mySampleManager = insitu.insitumanager.InsituManager()

    myStudy = pydefx.PyStudy(sampleManager=mySampleManager,
                             schemaBuilder=mySchemaBuilder)
    myStudy.createNewJob(myScript, mySample, myParams)

    myStudy.launch()
    myStudy.wait()
    myStudy.getResult()
    expected = """Exit code : 0
Error message : None
Result:
55.0"""
    self.assertEqual(str(myStudy.global_result),expected)

if __name__ == '__main__':
    unittest.main()
