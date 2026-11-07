# -*- coding: utf-8 -*-
# Copyright (C) 2018-2026  CEA, EDF
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

# Viscous layers with imprinting
# ==============================

Mesh_1 = smesh.Mesh(piquage, "Mesh_with_imprinting")

NETGEN_2D = Mesh_1.Triangle(algo=smeshBuilder.NETGEN_1D2D)
NETGEN_2D_Parameters = NETGEN_2D.Parameters()

NETGEN_2D_Parameters.SetMinSize( 0.01 )
NETGEN_2D_Parameters.SetLocalSizeOnShape(corner, 0.01)
NETGEN_2D_Parameters.SetFineness( 5 )
NETGEN_2D_Parameters.SetGrowthRate( 0.1 )
NETGEN_2D_Parameters.SetNbSegPerEdge( 2 )
NETGEN_2D_Parameters.SetNbSegPerRadius( 3 )

wall_faces = geompy.SubShapeAll(Wall, geompy.ShapeType["FACE"])
wall_ids = geompy.GetSubShapesIDs(piquage, wall_faces)
Inlet_x_id, Inlet_z_id, Outlet_id = geompy.GetSubShapesIDs(piquage, [Inlet_x, Inlet_z, Outlet])

MG_Hybrid_2 = Mesh_1.Tetrahedron(algo=smeshBuilder.HYBRID)
MG_Hybrid_Parameters_2 = MG_Hybrid_2.Parameters()
MG_Hybrid_Parameters_2.SetLayersOnAllWrap( 0 )
MG_Hybrid_Parameters_2.SetElementGeneration( HYBRIDPluginBuilder.Generation_Tetra_Dominant )
MG_Hybrid_Parameters_2.SetHeightFirstLayer( 0.01 )
MG_Hybrid_Parameters_2.SetBoundaryLayersProgression( 1.1 )
MG_Hybrid_Parameters_2.SetNbOfBoundaryLayers( 3 )
MG_Hybrid_Parameters_2.SetFacesWithLayers( wall_ids )
MG_Hybrid_Parameters_2.SetFacesWithImprinting( [ Inlet_x_id, Inlet_z_id, Outlet_id ] )

isDone = Mesh_1.Compute()

if not isDone:
  raise Exception("Error when computing Mesh_with_imprinting")

assert Mesh_1.NbQuadrangles() > 0

d_groups_1 = {}

for geom_group in geom_groups:
  name = geom_group.GetName()
  gr = Mesh_1.Group(geom_group)
  d_groups_1[name] = gr
  d_geom_groups[name] = geom_group

faces_imprinted = ["Inlet_x", "Inlet_z", "Outlet"]

# Check viscous layers with imprinting
for name in faces_imprinted:
  geom_area = geompy.BasicProperties(d_geom_groups[name])[1]
  gr_1 = d_groups_1[name]
  #assert gr_1.Size() > 0
  assert gr_1.Size() > 0
  # Nb of quadrangles is in 7th index of mesh info
  assert gr_1.GetMeshInfo()[7] > 0

  # Compare mesh group and geom group
  area_error_1 = abs(geom_area-smesh.GetArea(gr_1))/geom_area
  assert area_error_1 < 0.025

# Compare whole mesh volume
shape_volume = geompy.BasicProperties(piquage)[2]
mesh_1_volume = Mesh_1.GetVolume()
volume_error_1 = abs(shape_volume-mesh_1_volume)/shape_volume

assert volume_error_1 < 0.02

# Snapping
# ========

Mesh_snap = smesh.Mesh(piquage, "Mesh_with_snapping")

HYBRID_3D = Mesh_snap.Tetrahedron(algo=smeshBuilder.HYBRID)
HYBRID_Parameters_2 = HYBRID_3D.Parameters()
HYBRID_Parameters_2.SetElementGeneration( 0 )
HYBRID_Parameters_2.SetHeightFirstLayer( 0.01 )
HYBRID_Parameters_2.SetBoundaryLayersProgression( 1.1 )
HYBRID_Parameters_2.SetNbOfBoundaryLayers( 3 )
HYBRID_Parameters_2.SetFacesWithLayers( wall_ids )
HYBRID_Parameters_2.SetFacesWithSnapping([ Inlet_x_id, Inlet_z_id, Outlet_id ])
HYBRID_Parameters_2.SetLayersOnAllWrap( 0 )

Import_1D2D = Mesh_snap.UseExisting2DElements(geom=Inlet_x)
Source_Faces_1 = Import_1D2D.SourceFaces([ d_groups_1["Inlet_x"] ],0,0)

Import_1D2D_1 = Mesh_snap.UseExisting2DElements(geom=Inlet_z)
Source_Faces_2 = Import_1D2D_1.SourceFaces([ d_groups_1["Inlet_z"] ],0,0)

Import_1D2D_2 = Mesh_snap.UseExisting2DElements(geom=Outlet)
Source_Faces_3 = Import_1D2D_2.SourceFaces([ d_groups_1["Outlet"] ],0,0)

Import_1D2D_3 = Mesh_snap.UseExisting2DElements(geom=Wall)
Source_Faces_4 = Import_1D2D_3.SourceFaces([ d_groups_1["Wall"] ],0,0)

isDone = Mesh_snap.Compute()

d_groups_2 = {}

for geom_group in geom_groups:
  name = geom_group.GetName()
  gr = Mesh_snap.Group(geom_group)
  d_groups_2[name] = gr

# Compare whole mesh volume
mesh_2_volume = Mesh_snap.GetVolume()
volume_error_2 = abs(mesh_1_volume-mesh_2_volume)/mesh_1_volume

assert volume_error_2 < 1e-4

# Check viscous layers with snapping
for name in faces_imprinted:
  gr_1 = d_groups_1[name]
  gr_2 = d_groups_2[name]
  assert gr_2.Size() > 0
  # Nb of quadrangles is in 7th index of mesh info
  assert gr_1.GetMeshInfo()[7] == gr_1.GetMeshInfo()[7]

  # Compare mesh group with imprinting set by ids and mesh group with imprinting set by geom group
  area_error_2 = abs(smesh.GetArea(gr_1)-smesh.GetArea(gr_2))/smesh.GetArea(gr_1)
  assert area_error_2 < 1e-10

# Snapping on group
# =================

Mesh_snap_on_group = smesh.Mesh(piquage, "Mesh_with_snapping_on_groups")

HYBRID_3D_on_group = Mesh_snap_on_group.Tetrahedron(algo=smeshBuilder.HYBRID)
HYBRID_Parameters_3 = HYBRID_3D_on_group.Parameters()
HYBRID_Parameters_3.SetElementGeneration( 0 )
HYBRID_Parameters_3.SetHeightFirstLayer( 0.01 )
HYBRID_Parameters_3.SetBoundaryLayersProgression( 1.1 )
HYBRID_Parameters_3.SetNbOfBoundaryLayers( 3 )
HYBRID_Parameters_3.SetFacesWithLayers( wall_ids )
HYBRID_3D_on_group.SetFacesWithSnapping([ Inlet_x, Inlet_z, Outlet ])
HYBRID_Parameters_3.SetLayersOnAllWrap( 0 )

Import_1D2D = Mesh_snap_on_group.UseExisting2DElements(geom=Inlet_x)
Source_Faces_1 = Import_1D2D.SourceFaces([ d_groups_1["Inlet_x"] ],0,0)

Import_1D2D_1 = Mesh_snap_on_group.UseExisting2DElements(geom=Inlet_z)
Source_Faces_2 = Import_1D2D_1.SourceFaces([ d_groups_1["Inlet_z"] ],0,0)

Import_1D2D_2 = Mesh_snap_on_group.UseExisting2DElements(geom=Outlet)
Source_Faces_3 = Import_1D2D_2.SourceFaces([ d_groups_1["Outlet"] ],0,0)

Import_1D2D_3 = Mesh_snap_on_group.UseExisting2DElements(geom=Wall)
Source_Faces_4 = Import_1D2D_3.SourceFaces([ d_groups_1["Wall"] ],0,0)

isDone = Mesh_snap_on_group.Compute()

d_groups_3 = {}

for geom_group in geom_groups:
  name = geom_group.GetName()
  gr = Mesh_snap_on_group.Group(geom_group)
  d_groups_3[name] = gr

# Compare whole mesh volume
mesh_3_volume = Mesh_snap_on_group.GetVolume()
volume_error_3 = abs(mesh_2_volume-mesh_3_volume)/mesh_2_volume

assert volume_error_3 < 1e-10

# Check viscous layers with snapping
for name in faces_imprinted:
  gr_2 = d_groups_2[name]
  gr_3 = d_groups_3[name]
  assert gr_3.Size() > 0
  # Nb of quadrangles is in 7th index of mesh info
  assert gr_2.GetMeshInfo()[7] == gr_3.GetMeshInfo()[7]

  # Compare mesh group with imprinting set by ids and mesh group with imprinting set by geom group
  area_error_3 = abs(smesh.GetArea(gr_2)-smesh.GetArea(gr_3))/smesh.GetArea(gr_2)
  assert area_error_3 < 1e-10
