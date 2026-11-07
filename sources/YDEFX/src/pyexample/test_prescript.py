import unittest
import os
import time

class TestYdefx(unittest.TestCase):
  def test_prescript(self):
    """
    This test shows how to use an initialization script which is called one time
    before any evaluation of the study function.
    """
    import pydefx

    myParams = pydefx.Parameters()
    myParams.configureResource("localhost")
    mywd = os.path.join(myParams.salome_parameters.work_directory,
                        "prescript_test" +
                        time.strftime("%Y-%m-%d-%H-%M-%S", time.localtime()))
    myParams.salome_parameters.work_directory = mywd
    myParams.createResultDirectory("/tmp")

    pyScript = """
def _exec(name):
  with open("mydata.txt") as f:
    mydata = f.read()
  message = mydata + name
  return message"""

    myScript = pydefx.PyScript()
    myScript.loadString(pyScript)

    mySample = myScript.CreateEmptySample()
    mydata = {"name":["Jean", "Toto", "Titi", "Zizi"]}
    mySample.setInputValues(mydata)

    myPrescript = """
with open("mydata.txt", "w") as f:
  f.write("Hello ")
"""

    mySchemaBuilder = pydefx.DefaultSchemaBuilder(myPrescript)

    myStudy = pydefx.PyStudy(schemaBuilder=mySchemaBuilder)
    myStudy.createNewJob(myScript, mySample, myParams)

    myStudy.launch()
    myStudy.wait()
    myStudy.getResult()
    expected = "name,message,messages\n'Jean','Hello Jean',\n'Toto','Hello Toto',\n'Titi','Hello Titi',\n'Zizi','Hello Zizi',\n"
    self.assertEqual(str(myStudy.sample),expected)

if __name__ == '__main__':
    unittest.main()
