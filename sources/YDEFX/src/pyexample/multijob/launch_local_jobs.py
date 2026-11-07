import pydefx
import os

myParams = pydefx.Parameters()
myParams.nb_branches = 4
myParams.salome_parameters.work_directory=os.path.join(os.getcwd(),"runbasic")
myParams.salome_parameters.local_directory = os.getcwd()
myParams.salome_parameters.resource_required.nb_proc = 1
myParams.salome_parameters.job_name = "basic_job"
myParams.salome_parameters.job_type = "command"
myParams.salome_parameters.job_file = os.path.join(os.getcwd(), "simple_command.sh")
myParams.salome_parameters.resource_required.name = "eole"
myParams.salome_parameters.wckey = "P11N0:SALOME"

myScript = pydefx.PyScript()

pyScript = os.path.join(os.getcwd(), "jobstudy.py")
myScript.loadFile(pyScript)

mySample = myScript.CreateEmptySample()
mydata = {"n":range(10)}
mySample.setInputValues(mydata)

myStudy = pydefx.LocalStudy(schemaBuilder=pydefx.LocalBuilder("lightexecutor"))
myStudy.createNewJob(myScript, mySample, myParams)
myStudy.launch()

myStudy.getJobState()
myStudy.wait()
print(myStudy.getResult())
print(myStudy.sample)
