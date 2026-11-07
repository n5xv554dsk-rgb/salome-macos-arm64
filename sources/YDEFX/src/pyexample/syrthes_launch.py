#! /usr/bin/env python3
# -*- coding: utf-8 -*-
import pydefix
import os

# load data
import csv

STUDY_DIR = "/home/I35256/openturns/work/py/cassyrthes"

mydata = {}
with open("syrthes.csv", newline='') as datafile:
  csvdata = csv.DictReader(datafile, quoting=csv.QUOTE_NONNUMERIC)
  for field in csvdata.fieldnames:
    mydata[field] = []
  for line in csvdata:
    for field in csvdata.fieldnames:
      mydata[field].append(line[field])

myParams = pydefix.Parameters(resource="eole",nb_branches=26);
wd = os.path.join(myParams.salome_parameters.work_directory, "test_syrthes")
myParams.salome_parameters.work_directory = wd
myParams.salome_parameters.local_directory = STUDY_DIR
myParams.salome_parameters.in_files = ["brique_ech.syd", "Makefile", "Mesh",
                                       "run.sh", "syrthes.py", "user_cond.c"]
#myParams.salome_parameters.resource_required.nb_node = 2
myScript = pydefix.PyScript()
myScript.loadFile(os.path.join(STUDY_DIR, "etude.py"))

mySample = myScript.CreateEmptySample()
print(mySample.getInputNames())
print(mySample.getOutputNames())

mySample.setInputValues(mydata)

myStudy = pydefix.PyStudy(myScript, mySample, myParams)
myStudy.run()

print(myStudy.getJobState())
print(myStudy.getResult())
print(myStudy.getProgress())
