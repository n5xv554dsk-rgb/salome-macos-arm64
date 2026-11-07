# -*- coding: utf-8 -*-

from salome.kernel import salome
import math

from salome.kernel import GEOM
from salome.geom import geomBuilder
geompy = geomBuilder.New()

simple = False

r = 10
dist = 10

p1 = geompy.MakeVertex(0., 0., 0.)
p2 = geompy.MakeVertex(100., 100., 100.)
box = geompy.MakeBoxTwoPnt(p1, p2)
geompy.addToStudy(box, "box")

p3 = geompy.MakeVertex(25., 5., 25.)
sphere1 = geompy.MakeSpherePntR(p3, 15.)
geompy.addToStudy(sphere1, "sphere1")

sphere1_trans = geompy.MakeTranslation(sphere1, 0, 100, 0)
geompy.addToStudy(sphere1_trans, "sphere1_trans")

sphere1_trans = geompy.MakeTranslation(sphere1, 0, 100, 0)
geompy.addToStudy(sphere1_trans, "sphere1_trans")

p4 = geompy.MakeVertex(5, 50, 90)
sphere2 = geompy.MakeSpherePntR(p4, 20.)

sphere2_trans = geompy.MakeTranslation(sphere2, 100, 0, 0)
geompy.addToStudy(sphere2_trans, "sphere2_trans")

sphere2_trans2 = geompy.MakeTranslation(sphere2, 0, 0, -100)
geompy.addToStudy(sphere2_trans2, "sphere2_trans2")

sphere2_trans3 = geompy.MakeTranslation(sphere2, 100, 0, -100)
geompy.addToStudy(sphere2_trans3, "sphere2_trans3")

if simple:
    part = box
else:
    part = geompy.MakePartition([box], [sphere1, sphere1_trans, sphere2, sphere2_trans, sphere2_trans2, sphere2_trans3])
geompy.addToStudy(part, "part")

Vx = geompy.MakeVectorDXDYDZ(1, 0, 0)
Vy = geompy.MakeVectorDXDYDZ(0, 1, 0)
Vz = geompy.MakeVectorDXDYDZ(0, 0, 1)

left_faces = geompy.GetShapesOnPlane(part, geompy.ShapeType["FACE"], Vy, GEOM.ST_ON)
left = geompy.CreateGroup(part, geompy.ShapeType["FACE"])
geompy.UnionList(left, left_faces)
geompy.addToStudyInFather(part, left, "left")

right_faces = geompy.GetShapesOnPlaneWithLocation(part, geompy.ShapeType["FACE"], Vy, p2, GEOM.ST_ON)
right = geompy.CreateGroup(part, geompy.ShapeType["FACE"])
geompy.UnionList(right, right_faces)
geompy.addToStudyInFather(part, right, "right")

back_faces = geompy.GetShapesOnPlane(part, geompy.ShapeType["FACE"], Vx, GEOM.ST_ON)
back = geompy.CreateGroup(part, geompy.ShapeType["FACE"])
geompy.UnionList(back, back_faces)
geompy.addToStudyInFather(part, back, "back")

front_faces = geompy.GetShapesOnPlaneWithLocation(part, geompy.ShapeType["FACE"], Vx, p2, GEOM.ST_ON)
front = geompy.CreateGroup(part, geompy.ShapeType["FACE"])
geompy.UnionList(front, front_faces)
geompy.addToStudyInFather(part, front, "front")

bottom_faces = geompy.GetShapesOnPlane(part, geompy.ShapeType["FACE"], Vz, GEOM.ST_ON)
bottom = geompy.CreateGroup(part, geompy.ShapeType["FACE"])
geompy.UnionList(bottom, bottom_faces)
geompy.addToStudyInFather(part, bottom, "bottom")

top_faces = geompy.GetShapesOnPlaneWithLocation(part, geompy.ShapeType["FACE"], Vz, p2, GEOM.ST_ON)
top = geompy.CreateGroup(part, geompy.ShapeType["FACE"])
geompy.UnionList(top, top_faces)
geompy.addToStudyInFather(part, top, "top")

sources = geompy.CreateGroup(part, geompy.ShapeType["FACE"])
geompy.UnionList(sources, left_faces)
geompy.UnionList(sources, back_faces)
geompy.UnionList(sources, top_faces)
geompy.addToStudyInFather(part, sources, "sources")

# Mesh
# ====

from salome.kernel import SMESH
from salome.smesh import smeshBuilder
smesh = smeshBuilder.New()

Mesh = smesh.Mesh(part, "Mesh")

algo2d = Mesh.Triangle(algo=smeshBuilder.MG_CADSurf)
algo2d.SetGeometricMesh( 1 )
algo2d.SetAngleMesh( 4 )
algo2d.SetPhySize( 8 )
algo2d.SetVerbosity(1)

# Periodicity
#algo2d.SetPreCADOptionValue("periodic_tolerance", "1e-2")
algo2d.AddPreCadFacesPeriodicity(left, right)
algo2d.AddPreCadFacesPeriodicity(front, back)
algo2d.AddPreCadFacesPeriodicity(bottom, top)

gr_left = Mesh.Group(left)
gr_right = Mesh.Group(right)
gr_front = Mesh.Group(front)
gr_back = Mesh.Group(back)
gr_bottom = Mesh.Group(bottom)
gr_top = Mesh.Group(top)

Mesh.Compute()

left_translated = Mesh.TranslateObjectMakeMesh( gr_left, SMESH.DirStruct( SMESH.PointStruct ( 0, 100, 0 )), 0, 'left_translated' )
front_translated = Mesh.TranslateObjectMakeMesh( gr_front, SMESH.DirStruct( SMESH.PointStruct ( -100, 0, 0 )), 0, 'front_translated' )
bottom_translated = Mesh.TranslateObjectMakeMesh( gr_bottom, SMESH.DirStruct( SMESH.PointStruct ( 0, 0, 100 )), 0, 'bottom_translated' )

def checkProjection(gr, mesh_translated, tol=1e-7):
    name = gr.GetName() + "_" + mesh_translated.GetName().split("_")[0]
    mesh_source = smesh.CopyMesh(gr, gr.GetName())
    mesh_check = smesh.Concatenate([mesh_source.GetMesh(), mesh_translated.GetMesh()], 0, name=name)
    ll_coincident_nodes = mesh_check.FindCoincidentNodes(tol)
    coincident_nodes = [item for sublist in ll_coincident_nodes for item in sublist]
    mesh_check.MakeGroupByIds("coincident_nodes", SMESH.NODE, coincident_nodes)
    mesh_nodes = mesh_check.GetNodesId()
    if len(ll_coincident_nodes) != mesh_translated.NbNodes():
        non_coincident_nodes = list(set(mesh_nodes) - set(coincident_nodes))
        mesh_check.MakeGroupByIds("non_coincident_nodes", SMESH.NODE, non_coincident_nodes)
        raise Exception("Projection failed for %s"%name)
        
checkProjection(gr_right, left_translated)
checkProjection(gr_back, front_translated)
checkProjection(gr_top, bottom_translated)

salome.sg.updateObjBrowser()

