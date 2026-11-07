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

# Thickness mode 1: thicken a shell/face
# isInside = False, so thicken towards outside
Thickness_1 = model.addThickness(Part_1_doc, model.selection("SHELL", "Shell_1_1"), 30, False)

# Thickness mode 2: hollowed solid
# isInside = True, so thicken towards inside
Thickness_2 = model.addHollowedSolid(Part_1_doc,
                                     model.selection("SOLID", "Box_2_1"),
                                     40,
                                     [model.selection("FACE", "Box_2_1/Top"),
                                      model.selection("FACE", "Box_2_1/Left")],
                                     True)

model.end()
