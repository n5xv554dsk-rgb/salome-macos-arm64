# -*- coding: utf-8 -*-
import pydefx
import os

myParams = pydefx.Parameters();
myParams.configureResource("localhost")
myParams.createResultDirectory("/tmp")
myParams.nb_branches = 2

myScript = pydefx.PyScript()
myScript.loadFile("scenario_study.py")

mySample = myScript.CreateEmptySample()
print(mySample.getInputNames())
print(mySample.getOutputNames())

mySample.setInputValues({ "x":[0.1, 0.2, 0.3, 0.4, 0.5],
                          "y":[1.0, 2.0, 3.0, 4.0, 5.0],
                          "z":["a", "b", "c", "d", "e"]})

myStudy = pydefx.PyStudy()
myStudy.createNewJob(myScript, mySample, myParams)
myStudy.launch()
