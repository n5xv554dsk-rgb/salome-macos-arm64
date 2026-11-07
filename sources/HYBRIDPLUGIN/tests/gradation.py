#!/usr/bin/env python

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
model.addParameter(Part_1_doc, "c", '1')
model.addParameter(Part_1_doc, "r", '2')

### Create Box
Box_1 = model.addBox(Part_1_doc, "c", "c", "c")

### Create Translation
Translation_1 = model.addTranslation(Part_1_doc, [model.selection("SOLID", "Box_1_1")], vector = ["-c/2", "-c/2", "-c/2"], keepSubResults = True)

### Create Sphere
Sphere_1 = model.addSphere(Part_1_doc, model.selection("VERTEX", "PartSet/Origin"), "r")

### Create Cut
Cut_1 = model.addCut(Part_1_doc, [model.selection("SOLID", "Sphere_1_1")], [model.selection("SOLID", "Translation_1_1")], keepSubResults = True)

### Create Group
Group_1_objects = [model.selection("FACE", "Translation_1_1/MF:Translated&Box_1_1/Left"),
                   model.selection("FACE", "Translation_1_1/MF:Translated&Box_1_1/Front"),
                   model.selection("FACE", "Translation_1_1/MF:Translated&Box_1_1/Top"),
                   model.selection("FACE", "Translation_1_1/MF:Translated&Box_1_1/Bottom"),
                   model.selection("FACE", "Translation_1_1/MF:Translated&Box_1_1/Back"),
                   model.selection("FACE", "Translation_1_1/MF:Translated&Box_1_1/Right")]
Group_1 = model.addGroup(Part_1_doc, "Faces", Group_1_objects)
Group_1.setName("box_faces")
Group_1.result().setName("box_faces")

### Create Group
Group_2 = model.addGroup(Part_1_doc, "Faces", [model.selection("FACE", "Sphere_1_1/Face_1")])
Group_2.setName("sphere_face")
Group_2.result().setName("sphere_face")

model.end()

###
### SHAPERSTUDY component
###

model.publishToShaperStudy()
import SHAPERSTUDY
Cut_1_1, box_faces, sphere_face, = SHAPERSTUDY.shape(model.featureStringId(Cut_1))
###
### SMESH component
###

from salome.kernel import SMESH, SALOMEDS
from salome.smesh import smeshBuilder

smesh = smeshBuilder.New()

Mesh_1 = smesh.Mesh(Cut_1_1,'Mesh_1')

MG_CADSurf = Mesh_1.Triangle(algo=smeshBuilder.MG_CADSurf)
Regular_1D = Mesh_1.Segment(geom=box_faces)
Number_of_Segments_1 = Regular_1D.NumberOfSegments(10)
Quadrangle_2D = Mesh_1.Quadrangle(algo=smeshBuilder.QUADRANGLE,geom=box_faces)
MG_Hybrid = Mesh_1.Tetrahedron(algo=smeshBuilder.HYBRID)
MG_Hybrid_Parameters_1 = MG_Hybrid.Parameters()
isDone = Mesh_1.Compute()
Mesh_1.CheckCompute()

box_faces_1 = Mesh_1.GroupOnGeom(box_faces,'box_faces',SMESH.FACE)
sphere_face_1 = Mesh_1.GroupOnGeom(sphere_face,'sphere_face',SMESH.FACE)

nb_vol = Mesh_1.NbVolumes()
print("nb_vol: ", nb_vol)

# in 9.13
#nb_vol:  6533

# change gradation (default is 2)
MG_Hybrid_Parameters_1.SetGradation( 1.05 )
isDone = Mesh_1.Compute()
Mesh_1.CheckCompute()

# should now have more elements
#nb_vol:  17760

new_nb_vol = Mesh_1.NbVolumes()
print("new_nb_vol: ", new_nb_vol)

assert new_nb_vol > 2*nb_vol, "SetGradation has failed"

if salome.sg.hasDesktop():
  salome.sg.updateObjBrowser()
