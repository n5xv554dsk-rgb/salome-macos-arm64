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

# This test is a known failure for MeshGems <= 2.4-5 (but must not crash Salome)

import sys
from salome.kernel import salome

salome.salome_init()

###
### GEOM component
###

from salome.kernel import GEOM
from salome.geom import geomBuilder
import math
from salome.kernel import SALOMEDS


geompy = geomBuilder.New()

# first cylinder
r1 = 0.5
h1 = 5

# second cylinder
r2 = 0.3
h2 = 3

length_piquage = 1.5

O = geompy.MakeVertex(0, 0, 0)
OX = geompy.MakeVectorDXDYDZ(1, 0, 0)
OY = geompy.MakeVectorDXDYDZ(0, 1, 0)
OZ = geompy.MakeVectorDXDYDZ(0, 0, 1)
geompy.addToStudy( O, 'O' )
geompy.addToStudy( OX, 'OX' )
geompy.addToStudy( OY, 'OY' )
geompy.addToStudy( OZ, 'OZ' )

Cylinder_1 = geompy.MakeCylinderRH(r1, h1)
Cylinder_2 = geompy.MakeCylinderRH(r2, h2)
Rotation_1 = geompy.MakeRotation(Cylinder_2, OY, -90*math.pi/180.0)
Translation_1 = geompy.MakeTranslation(Rotation_1, 0, 0, length_piquage)

piquage = geompy.MakeFuseList([Cylinder_1, Translation_1], True, True)
geompy.addToStudy( piquage, 'piquage' )

Inlet_z = geompy.GetFaceNearPoint(piquage, O)
geompy.addToStudyInFather( piquage, Inlet_z, 'Inlet_z' )

p_inlet_x = geompy.MakeVertex(-h2, 0, length_piquage)
Inlet_x = geompy.GetFaceNearPoint(piquage, p_inlet_x)
geompy.addToStudyInFather( piquage, Inlet_x, 'Inlet_x' )

p_outlet = geompy.MakeVertex(0, 0, h1)
Outlet = geompy.GetFaceNearPoint(piquage, p_outlet)
geompy.addToStudyInFather( piquage, Outlet, 'Outlet' )

Wall = geompy.CreateGroup(piquage, geompy.ShapeType["FACE"])
faces = geompy.SubShapeAll(piquage, geompy.ShapeType["FACE"])
geompy.UnionList(Wall, faces)
geompy.DifferenceList(Wall, [Inlet_x, Inlet_z, Outlet])
geompy.addToStudyInFather( piquage, Wall, 'Wall' )

p_corner = geompy.MakeVertex(-r2, 0, length_piquage+r2)
corner = geompy.GetVertexNearPoint(piquage, p_corner)
geompy.addToStudyInFather( piquage, corner, 'corner' )

geom_groups = [Inlet_x, Inlet_z, Outlet, Wall]
d_geom_groups = {}

###
### SMESH component
###

from salome.kernel import SMESH, SALOMEDS
from salome.smesh import smeshBuilder

from salome.kernel.StdMeshers import StdMeshersBuilder
from salome.kernel.HYBRIDPlugin import HYBRIDPluginBuilder

smesh = smeshBuilder.New()

# Viscous layers with imprinting (hexa core)
# ==========================================

Mesh_4 = smesh.Mesh(piquage, "Mesh_with_imprinting_hexa_core")

NETGEN_2D_1_1 = Mesh_4.Triangle(algo=smeshBuilder.NETGEN_1D2D)
NETGEN_2D_Parameters = NETGEN_2D_1_1.Parameters()

NETGEN_2D_Parameters.SetMinSize( 0.01 )
NETGEN_2D_Parameters.SetLocalSizeOnShape(corner, 0.01)
NETGEN_2D_Parameters.SetFineness( 5 )
NETGEN_2D_Parameters.SetGrowthRate( 0.1 )
NETGEN_2D_Parameters.SetNbSegPerEdge( 2 )
NETGEN_2D_Parameters.SetNbSegPerRadius( 3 )

wall_faces = geompy.SubShapeAll(Wall, geompy.ShapeType["FACE"])
wall_ids = geompy.GetSubShapesIDs(piquage, wall_faces)
Inlet_x_id, Inlet_z_id, Outlet_id = geompy.GetSubShapesIDs(piquage, [Inlet_x, Inlet_z, Outlet])

MG_Hybrid_4 = Mesh_4.Tetrahedron(algo=smeshBuilder.HYBRID)
MG_Hybrid_Parameters_4 = MG_Hybrid_4.Parameters()
MG_Hybrid_Parameters_4.SetLayersOnAllWrap( 0 )
MG_Hybrid_Parameters_4.SetElementGeneration( HYBRIDPluginBuilder.Generation_Hexa_Dominant )
MG_Hybrid_Parameters_4.SetHeightFirstLayer( 0.01 )
MG_Hybrid_Parameters_4.SetBoundaryLayersProgression( 1.1 )
MG_Hybrid_Parameters_4.SetNbOfBoundaryLayers( 3 )
MG_Hybrid_Parameters_4.SetFacesWithLayers( wall_ids )
MG_Hybrid_Parameters_4.SetFacesWithImprinting( [ Inlet_x_id, Inlet_z_id, Outlet_id ] )

isDone = Mesh_4.Compute()

if not isDone:
  raise Exception("Error when computing Mesh_with_imprinting_hexa_core")

assert Mesh_4.NbQuadrangles() > 0

d_groups_4 = {}
d_geom_groups = {}

for geom_group in geom_groups:
  name = geom_group.GetName()
  gr = Mesh_4.Group(geom_group)
  d_groups_4[name] = gr
  d_geom_groups[name] = geom_group

# Compare whole mesh volume
mesh_4_volume = Mesh_4.GetVolume()
shape_volume = geompy.BasicProperties(piquage)[2]
volume_error_4 = abs(shape_volume-mesh_4_volume)/shape_volume

assert volume_error_4 < 0.02

# Check viscous layers with imprinting
faces_imprinted = ["Inlet_x", "Inlet_z", "Outlet"]

for name in faces_imprinted:
  gr_4 = d_groups_4[name]
  #assert gr_1.Size() > 0
  assert gr_4.Size() > 0
  # Nb of quadrangles is in 7th index of mesh info
  assert gr_4.GetMeshInfo()[7] > 0

  # Compare mesh group and geom group
  geom_area = geompy.BasicProperties(d_geom_groups[name])[1]
  area_error_1 = abs(geom_area-smesh.GetArea(gr_4))/geom_area
  assert area_error_1 < 0.025

