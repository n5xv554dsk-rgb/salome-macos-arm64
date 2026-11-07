import pydefx

myParams = pydefx.Parameters()
myParams.configureResource("localhost")
myParams.createResultDirectory("/tmp")

pyScript = """
def _exec(a, b):
  d = a / b
  return d"""

myScript = pydefx.PyScript()
myScript.loadString(pyScript)

mySample = myScript.CreateEmptySample()
mydata = {"a":[1.1, 2.2, 3.4, 5.5],
          "b":[2.2, 4.4, 6.8, 11]}
mySample.setInputValues(mydata)

myStudy = pydefx.PyStudy()
myStudy.createNewJob(myScript, mySample, myParams)
myStudy.launch()

strdmp= myStudy.dump()
restoredJob = pydefx.PyStudy()
restoredJob.loadFromString(strdmp)

print(myStudy.getJobState())
print(myStudy.getProgress())
