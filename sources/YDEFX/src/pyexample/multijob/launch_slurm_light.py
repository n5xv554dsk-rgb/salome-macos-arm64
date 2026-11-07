"""
Cet exemple est adapté pour le cas où la fonction _exec lance une ou plusieures
commandes srun.
La parallélisation est basée sur multiprocessing, mais la distribution est à la
charge de la function _exec par l'utilisation de srun.
Dans cet exemple, on n'utilise ni YACS ni les containers de Salomé.
"""
import pydefx
import os

myParams = pydefx.Parameters()
myParams.configureResource("gaia")
myParams.nb_branches = 4
myParams.salome_parameters.resource_required.nb_proc = 4
myParams.salome_parameters.result_directory=os.path.join(os.getcwd(),"lightsrun")
myParams.salome_parameters.work_directory="/scratch/I35256/workingdir/test_srunjob/"
myParams.salome_parameters.local_directory = os.getcwd()
myParams.salome_parameters.in_files=["template_jdd.txt", "mysolver.py"]

pyScript = os.path.join(os.getcwd(), "mystudy.py")

myScript = pydefx.PyScript()
myScript.loadFile(pyScript)

mySample = myScript.CreateEmptySample()
mydata = {"x":range(10)}
mySample.setInputValues(mydata)

pydefx_path = os.path.dirname(pydefx.__file__)
light_executor_path = os.path.join(pydefx_path, "plugins", "lightexecutor.py")

mybuilder = pydefx.slurmbuilder.SlurmBuilder(executor=light_executor_path)

myStudy = pydefx.SlurmStudy(schemaBuilder=mybuilder)
myStudy.createNewJob(myScript, mySample, myParams)
myStudy.launch()

myStudy.getJobState()
myStudy.wait()
print(myStudy.getResult())
print(myStudy.sample)
