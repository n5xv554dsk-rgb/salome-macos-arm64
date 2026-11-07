from SketchAPI import *

from salome.shaper import model

model.begin()
partSet = model.moduleDocument()

### Create Part
Part_1 = model.addPart(partSet)
Part_1_doc = Part_1.document()

### Create Box
Box_1 = model.addBox(Part_1_doc, 200, 200, 200)
Box_2 = model.addBox(Part_1_doc, 200, 200, 200)

### Create Shell
Shell_1 = model.addShell(Part_1_doc, [model.selection("FACE", "Box_1_1/Top"),
                                      model.selection("FACE", "Box_1_1/Front"),
                                      model.selection("FACE", "Box_1_1/Left")])

# Offset of the whole shape, pipe joints (isPipeJoint = True)
Offset_1 = model.addOffset(Part_1_doc, model.selection("SHELL", "Shell_1_1"), 70., True)

# Partial offset. Negative offset value means offset in direction, opposite to normale.
Offset_2 = model.addOffsetPartial(Part_1_doc,
                                  model.selection("SOLID", "Box_2_1"),
                                  -50.,
                                  [model.selection("FACE", "Box_2_1/Top")])

model.end()
