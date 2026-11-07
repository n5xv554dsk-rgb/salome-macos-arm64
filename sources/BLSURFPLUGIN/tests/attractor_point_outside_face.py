# -*- coding: utf-8 -*-
# Copyright (C) 2017-2026  CEA, EDF
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

salome.salome_init()

from salome.kernel import SMESH, SALOMEDS

## Compute the minimum area of the faces of the mesh
def getMinArea(mesh):
  faces = mesh.GetElementsByType(SMESH.FACE)
  areas = [mesh.GetArea(face) for face in faces]
  return min(areas)

###
### GEOM component
###

from salome.kernel import GEOM
from salome.geom import geomBuilder
import math
from salome.kernel import SALOMEDS


geompy = geomBuilder.New()

O = geompy.MakeVertex(0, 0, 0)
OX = geompy.MakeVectorDXDYDZ(1, 0, 0)
OY = geompy.MakeVectorDXDYDZ(0, 1, 0)
OZ = geompy.MakeVectorDXDYDZ(0, 0, 1)
radius = 10
height = 100
Cylinder_1 = geompy.MakeCylinderRH(radius, height)

p_half_height = geompy.MakeVertex(0, 0, height/2.)
plane_z = geompy.MakePlane(p_half_height, OZ, 2.5*radius)

Part_1 = geompy.MakePartition([Cylinder_1], [plane_z], Limit=geompy.ShapeType["FACE"])


geompy.addToStudy( O, 'O' )
geompy.addToStudy( OX, 'OX' )
geompy.addToStudy( OY, 'OY' )
geompy.addToStudy( OZ, 'OZ' )
geompy.addToStudy( Part_1, 'Part_1' )


p_edge_vert_opp_1 = geompy.MakeVertex(-radius, 0, 0)
geompy.addToStudy( p_edge_vert_opp_1, 'p_edge_vert_opp_1' )

edge_vert_opp_1 = geompy.MakePrismVecH(p_edge_vert_opp_1, OZ, height/2.)
geompy.addToStudy( edge_vert_opp_1, 'edge_vert_opp_1' )

p_edge_vert_opp_2 = geompy.MakeVertex(-radius, 0, height/4.)
geompy.addToStudy( p_edge_vert_opp_2, 'p_edge_vert_opp_2' )

p_face_cyl_1 = geompy.MakeVertex(0, radius, height/4.)
p_face_cyl_2 = geompy.MakeVertex(0, radius, 3*height/4.)

face_1 = geompy.GetFaceNearPoint(Part_1, p_face_cyl_1)
face_2 = geompy.GetFaceNearPoint(Part_1, p_face_cyl_2)

geompy.addToStudyInFather(Part_1, face_1, "face_1")
geompy.addToStudyInFather(Part_1, face_2, "face_2")

###
### SMESH component
###

from salome.smesh import smeshBuilder

smesh = smeshBuilder.New()
Mesh_1 = smesh.Mesh(Part_1)
MG_CADSurf = Mesh_1.Triangle(algo=smeshBuilder.MG_CADSurf)
MG_CADSurf_Parameters_1 = MG_CADSurf.Parameters()
MG_CADSurf_Parameters_1.SetPhySize( 14.1421 )
MG_CADSurf_Parameters_1.SetMinSize( 0.141421 )
MG_CADSurf_Parameters_1.SetMaxSize( 28.2843 )
MG_CADSurf_Parameters_1.SetChordalError( 7.07107 )
#MG_CADSurf_Parameters_1.SetAttractorGeom( sub_Face_1, Edge_1, 1, 14.1421, 5, 5 )

ok = Mesh_1.Compute()

if not ok:
  raise Exception("Mesh not computed")

min_area_without_attractor = getMinArea(Mesh_1)

print("min_area_without_attractor: ", min_area_without_attractor)

MG_CADSurf_Parameters_1.SetAttractorGeom( face_1, edge_vert_opp_1, 1, 14.1421, 5, 5 )
# the attractor is not on the face. It is done on purpose to test this out of bounds case.
MG_CADSurf_Parameters_1.SetAttractorGeom( face_2, p_edge_vert_opp_2, 1, 14.1421, 5, 5 )

ok = Mesh_1.Compute()

if not ok:
  raise Exception("Mesh with attractors not computed")

min_area_with_attractor = getMinArea(Mesh_1)

print("min_area_with_attractor: ", min_area_with_attractor)

assert min_area_with_attractor < min_area_without_attractor

assert min_area_with_attractor < 1

if salome.sg.hasDesktop():
  salome.sg.updateObjBrowser()
