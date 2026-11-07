# -*- coding: utf-8 -*-
import pydefx
import os

# load data
import csv

mydata = {}
with open("input.csv", newline='') as datafile:
  csvdata = csv.DictReader(datafile, quoting=csv.QUOTE_NONNUMERIC)
  for field in csvdata.fieldnames:
    mydata[field] = []
  for line in csvdata:
    for field in csvdata.fieldnames:
      mydata[field].append(line[field])

myScript = pydefx.PyScript()
myScript.loadFile("tempostudy.py")

mySample = myScript.CreateEmptySample()
print(mySample.getInputNames())
print(mySample.getOutputNames())

mySample.setInputValues(mydata)

myStudy = pydefx.PyStudy()
myParams = myStudy.createDefaultParameters(resource="localhost");

wd = os.path.join(myParams.salome_parameters.work_directory, "minifixtest")
myParams.salome_parameters.work_directory = wd

myStudy.createNewJob(myScript, mySample, myParams)
myStudy.launch()

print(myStudy.getJobState())
print(myStudy.getResult())
print(myStudy.sample)
print(myStudy.global_result)
print(myStudy.getProgress())
