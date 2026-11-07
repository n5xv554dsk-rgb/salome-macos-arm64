import sys
from salome.kernel import salome

salome.salome_init()

###
### SHAPER component
###

from salome.shaper import model

model.begin()
partSet = model.moduleDocument()

### Create Part
Part_1 = model.addPart(partSet)
Part_1_doc = Part_1.document()

### Create Cylinder
Cylinder_1 = model.addCylinder(Part_1_doc, model.selection("VERTEX", "PartSet/Origin"), model.selection("EDGE", "PartSet/OZ"), 5, 10)

### Create Cylinder
Cylinder_2 = model.addCylinder(Part_1_doc, model.selection("VERTEX", "PartSet/Origin"), model.selection("EDGE", "PartSet/OZ"), 4, 10)

### Create Cut
Cut_1 = model.addCut(Part_1_doc, [model.selection("SOLID", "Cylinder_1_1")], [model.selection("SOLID", "Cylinder_2_1")], keepSubResults = True)
Cut_1.result().setName("ROD")

### Create Group
Group_1 = model.addGroup(Part_1_doc, "Solids", [model.selection("SOLID", "ROD")])
Group_1.setName("ROD")
Group_1.result().setName("ROD")

### Create Group
Group_2 = model.addGroup(Part_1_doc, "Faces", [model.selection("FACE", "ROD/Modified_Face&Cylinder_1_1/Face_2")])
Group_2.setName("TOP")
Group_2.result().setName("TOP")
model.end()

from ModelAPI import *
aFactory = ModelAPI_Session.get().validators()
assert(aFactory.validate(Group_2.feature()))
