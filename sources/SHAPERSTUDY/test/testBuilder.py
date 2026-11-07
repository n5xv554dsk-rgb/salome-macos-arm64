#!/usr/bin/env python

###
### This file is generated automatically by SALOME v9.4.0 with dump python functionality
###

import sys
from salome.kernel import salome
salome.salome_init()

###
### SHAPER component
###

from salome.shaper import model

model.begin()
partSet = model.moduleDocument()
Part_1 = model.addPart(partSet)
Part_1_doc = Part_1.document()
Box_1 = model.addBox(Part_1_doc, 10, 10, 10)
Face_1 = model.addFace(Part_1_doc, [model.selection("FACE", "Box_1_1/Top")])

model.end()

###
### SHAPERSTUDY component
###

import SHAPERSTUDY
from salome.kernel import GEOM

model.begin()
anExportFeature = Part_1_doc.addFeature("PublishToStudy")
model.end()


face = salome.myStudy.FindObjectByPath("/ShaperResults/Face_1_1").GetObject()

shaper = face.GetGen()
print(shaper.ComponentDataType())

import shaperBuilder
shaper = shaperBuilder.New()

from salome.smesh import smeshBuilder
smesh = smeshBuilder.New(instanceGeom=shaper)

vv = shaper.ExtractShapes( face, shaper.ShapeType["VERTEX"])
assert len(vv) == 4
assert vv[0].GetShapeType() == GEOM.VERTEX
ee = shaper.ExtractShapes( face, shaper.ShapeType["EDGE"])
assert len(ee) == 4
assert ee[0].GetShapeType() == GEOM.EDGE

eGroup = shaper.CreateGroup( face, shaper.ShapeType["EDGE"])
eGroup.SetEntry("eGroup") # enable adding to study
shaper.addToStudyInFather( face, eGroup, "eGroup" )
shaper.UnionList( eGroup, ee )

meshOnFace = smesh.Mesh( face )
meshOnEdge = smesh.Mesh( ee[0] )

ind = shaper.GetSubShapeID( face, vv[0] )
assert ind == 4

d = shaper.MinDistance( vv[0], vv[1] )
assert d == 10

# SubShapeAll()
# PointCoordinates()
axis = smesh.GetAxisStruct( face )
print(axis)

# GetSubShape()
s = shaper.GetSubShape( face, [2] )
print (s.GetShapeType())
assert s.GetShapeType() == GEOM.WIRE
name = meshOnFace.GetSubShapeName( 2 )
print( name )

#NumberOfEdges()
#NumberOfFaces()
dim = meshOnFace.MeshDimension()
assert dim == 2
dim = meshOnEdge.MeshDimension()
assert dim == 1

#SubShapeName()
smeshBuilder.AssureGeomPublished( meshOnFace, ee[0] )

#Tolerance()
#GetVertexByIndex()
algo = meshOnFace.Segment()
l = algo.ReversedEdgeIndices([(ee[0],vv[0])])


### unnecessary methods that can be accidentally called from any module
from salome.kernel import SALOMEDS
face.GetTopologyType()
face.GetMinShapeType()
face.GetMaxShapeType()
face.GetSubShapeName(1)
face.SetColor(SALOMEDS.Color( 0,0,0 ))
face.GetColor()
face.SetAutoColor(0)
face.GetAutoColor()
face.SetMarkerStd(GEOM.MT_NONE, GEOM.MS_NONE)
face.SetMarkerTexture(0)
face.GetMarkerType()
face.GetMarkerSize()
face.GetMarkerTexture()


if salome.sg.hasDesktop():
  salome.sg.updateObjBrowser()
