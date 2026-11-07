#!/usr/bin/env python

from salome.kernel import salome
salome.salome_init()

from salome.shaper import model

model.begin()
partSet = model.moduleDocument()

### Create Part
Part_1 = model.addPart(partSet)
Part_1_doc = Part_1.document()

### Create Point
Point_2 = model.addPoint(Part_1_doc, 0, 0, 10)

### Create Sphere
Sphere_1 = model.addSphere(Part_1_doc, model.selection("VERTEX", "Point_1"), 10)

### Create Box
Box_1 = model.addBox(Part_1_doc, 0, 0, -5, 20, 20, 20)

### Create Cut
Cut_1 = model.addCut(Part_1_doc, [model.selection("SOLID", "Sphere_1_1")], [model.selection("SOLID", "Box_1_1")], keepSubResults = True)

### Create RemoveExtraEdges
RemoveExtraEdges_1 = model.addRemoveExtraEdges(Part_1_doc, model.selection("SOLID", "Cut_1_1"), True)

model.end()
