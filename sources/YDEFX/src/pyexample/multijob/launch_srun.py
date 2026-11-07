import pydefx
import os

myParams = pydefx.Parameters()
myParams.configureResource("eole")
#myParams.createResultDirectory("/tmp")
myParams.nb_branches = 4
myParams.salome_parameters.resource_required.nb_proc = 4
myParams.salome_parameters.result_directory=os.path.join(os.getcwd(),"runsrun")
myParams.salome_parameters.work_directory="/scratch/I35256/workingdir/test_srunjob/"
myParams.salome_parameters.local_directory = os.getcwd()
myParams.salome_parameters.in_files=["template_jdd.txt", "mysolver.py"]

pyScript = os.path.join(os.getcwd(), "mystudy.py")

myScript = pydefx.PyScript()
myScript.loadFile(pyScript)

mySample = myScript.CreateEmptySample()
mydata = {"x":range(10)}
mySample.setInputValues(mydata)

myStudy = pydefx.SlurmStudy()
myStudy.createNewJob(myScript, mySample, myParams)
myStudy.launch()

myStudy.getJobState()
myStudy.wait()
print(myStudy.getResult())
print(myStudy.sample)
#print(myStudy.global_result)
