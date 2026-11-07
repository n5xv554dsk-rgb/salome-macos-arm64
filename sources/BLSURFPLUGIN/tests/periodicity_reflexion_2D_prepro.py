# -*- coding: iso-8859-1 -*-
# Copyright (C) 2013-2026  CEA, EDF
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
#
# See http://www.salome-platform.org/ or email : webmaster.salome@opencascade.com
#

import sys
from salome.kernel import salome

###
### GEOM component
###

import math

from salome.kernel import GEOM
from salome.geom import geomBuilder
geompy = geomBuilder.New()

O = geompy.MakeVertex(0, 0, 0)
OX = geompy.MakeVectorDXDYDZ(1, 0, 0)
OY = geompy.MakeVectorDXDYDZ(0, 1, 0)
OZ = geompy.MakeVectorDXDYDZ(0, 0, 1)
Face_1 = geompy.MakeFaceHW(10, 10, 1)
geomObj_1 = geompy.MakeMarker(0, 0, 0, 1, 0, 0, 0, 1, 0)
Sketch_1 = geompy.MakeSketcherOnPlane("Sketcher:F -2.5209155082703 -1.4416453838348:TT -1.1105282306671 -2.9872753620148:TT 0.76354801654816 -2.3303825855255:TT 1.9614112377167 -3.0838770866394:TT 3.8354876041412 -1.2677619457245:TT 4.2218952178955 0.644955098629:TT 3.2751967906952 2.5576722621918:TT 0.58966463804245 3.5430111885071:TT -3.7380990982056 3.2338852882385:TT -4.433632850647 0.85747921466827:WW", Face_1 )
vertices = geompy.ExtractShapes(Sketch_1, geompy.ShapeType["VERTEX"], True)
Curve_1 = geompy.MakeInterpol(vertices, True, True)

part = geompy.MakePartition([Face_1], [Curve_1], Limit=geompy.ShapeType["FACE"])
geompy.addToStudy(part, "part")

Vx = geompy.MakeVectorDXDYDZ(1, 0, 0)
Vy = geompy.MakeVectorDXDYDZ(0, 1, 0)
Vz = geompy.MakeVectorDXDYDZ(0, 0, 1)

p1 = geompy.MakeVertex(-5, -5, 0)
p2 = geompy.MakeVertex(5, 5, 0)
left_edges = geompy.GetShapesOnPlaneWithLocation(part, geompy.ShapeType["EDGE"], Vx, p1, GEOM.ST_ON)
left = geompy.CreateGroup(part, geompy.ShapeType["EDGE"])
geompy.UnionList(left, left_edges)
geompy.addToStudyInFather(part, left, "left")

right_edges = geompy.GetShapesOnPlaneWithLocation(part, geompy.ShapeType["EDGE"], Vx, p2, GEOM.ST_ON)
right = geompy.CreateGroup(part, geompy.ShapeType["EDGE"])
geompy.UnionList(right, right_edges)
geompy.addToStudyInFather(part, right, "right")

bottom_edges = geompy.GetShapesOnPlaneWithLocation(part, geompy.ShapeType["EDGE"], Vy, p1, GEOM.ST_ON)
bottom = geompy.CreateGroup(part, geompy.ShapeType["EDGE"])
geompy.UnionList(bottom, bottom_edges)
geompy.addToStudyInFather(part, bottom, "bottom")

top_edges = geompy.GetShapesOnPlaneWithLocation(part, geompy.ShapeType["EDGE"], Vy, p2, GEOM.ST_ON)
top = geompy.CreateGroup(part, geompy.ShapeType["EDGE"])
geompy.UnionList(top, top_edges)
geompy.addToStudyInFather(part, top, "top")

source_face = geompy.GetFaceNearPoint(part, p1)
geompy.addToStudyInFather(part, source_face, "source_face")

# To define a rotation, we have to set at least 3 source vertices not aligned.
p_bas_gauche = geompy.MakeVertex(-5, -5, 0)
geompy.addToStudy(p_bas_gauche, "p_bas_gauche")
p_bas_mil = geompy.MakeVertex(0, -4, 0)
geompy.addToStudy(p_bas_mil, "p_bas_mil")
p_bas_droite = geompy.MakeVertex(5, -5, 0)
geompy.addToStudy(p_bas_droite, "p_bas_droite")

# Target vertices
p_mil_droite = geompy.MakeVertex(4, 0, 0)
geompy.addToStudy(p_mil_droite, "p_mil_droite")
p_haut_droite = geompy.MakeVertex(5, 5, 0)
geompy.addToStudy(p_haut_droite, "p_haut_droite")

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
#algo2d.SetGradation(1.05)

#algo2d.SetOptionValue( 'debug', '1' )
#algo2d.SetPreCADOptionValue( 'debug', '1' )

# Periodicity
#algo2d.SetVerbosity(10)
algo2d.SetPreCADOptionValue("periodic_tolerance", "1e-2")
algo2d.AddPreCadEdgesPeriodicity(bottom, right, [p_bas_droite, p_bas_mil, p_bas_gauche], [p_bas_droite, p_mil_droite, p_haut_droite])


ok = Mesh.Compute()
if not ok:
  raise Exception("Mesh not computed")

gr_left = Mesh.Group(left)
gr_right = Mesh.Group(right)
gr_bottom = Mesh.Group(bottom)
gr_top = Mesh.Group(top)

axe = geompy.MakePrismVecH(p_bas_droite, Vz, 1)
bottom_rotated = Mesh.RotateObjectMakeMesh( gr_bottom, axe, -math.pi/2, NewMeshName='bottom_rotated' )

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
        #print("Projection failed for %s"%name)
        raise Exception("Projection failed for %s"%name)
        
checkProjection(gr_right, bottom_rotated)

#salome.myStudy.SaveAs("test.hdf", 0, 0)

if salome.sg.hasDesktop():
  salome.sg.updateObjBrowser()
  
