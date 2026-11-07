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
for geom_group in geom_groups:
  name = geom_group.GetName()
  d_geom_groups[name] = geom_group

shape_volume = geompy.BasicProperties(piquage)[2]

###
### SMESH component
###

from salome.kernel import SMESH, SALOMEDS
from salome.smesh import smeshBuilder

from salome.kernel.StdMeshers import StdMeshersBuilder
from salome.kernel.HYBRIDPlugin import HYBRIDPluginBuilder

smesh = smeshBuilder.New()


# Viscous layers without imprinting
# =================================

Mesh_1 = smesh.Mesh(piquage, "Mesh_without_imprinting")
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

MG_Hybrid = Mesh_1.Tetrahedron(algo=smeshBuilder.HYBRID)
MG_Hybrid_Parameters_1 = MG_Hybrid.Parameters()
MG_Hybrid_Parameters_1.SetLayersOnAllWrap( 0 )
MG_Hybrid_Parameters_1.SetElementGeneration( HYBRIDPluginBuilder.Generation_Tetra_Dominant )
MG_Hybrid_Parameters_1.SetHeightFirstLayer( 0.01 )
MG_Hybrid_Parameters_1.SetBoundaryLayersProgression( 1.1 )
MG_Hybrid_Parameters_1.SetNbOfBoundaryLayers( 3 )
MG_Hybrid_Parameters_1.SetFacesWithLayers( wall_ids )

Mesh_1.Compute()

def checkMesh_1(Mesh_1):
  Mesh_1.CheckCompute()

  d_groups_1 = {}

  for geom_group in geom_groups:
    name = geom_group.GetName()
    gr = Mesh_1.Group(geom_group)
    d_groups_1[name] = gr
    d_geom_groups[name] = geom_group

  assert Mesh_1.NbQuadrangles() == 0

  # Compare whole mesh volume
  volume_error_1 = abs(shape_volume-Mesh_1.GetVolume())/shape_volume

  assert volume_error_1 < 0.02

  return d_groups_1

d_groups_1 = checkMesh_1(Mesh_1)

# Compute same mesh with library
MG_Hybrid_Parameters_1.SetToUseLibrary(True)
Mesh_1.Clear()
Mesh_1.Compute()
d_groups_1 = checkMesh_1(Mesh_1)

# Viscous layers with imprinting
# ==============================

Mesh_2 = smesh.Mesh(piquage, "Mesh_with_imprinting")

NETGEN_2D_1_1 = Mesh_2.Triangle(algo=smeshBuilder.NETGEN_1D2D)
status = Mesh_2.AddHypothesis(NETGEN_2D_Parameters)

Inlet_x_id, Inlet_z_id, Outlet_id = geompy.GetSubShapesIDs(piquage, [Inlet_x, Inlet_z, Outlet])

MG_Hybrid_2 = Mesh_2.Tetrahedron(algo=smeshBuilder.HYBRID)
MG_Hybrid_Parameters_2 = MG_Hybrid_2.Parameters()
MG_Hybrid_Parameters_2.SetLayersOnAllWrap( 0 )
MG_Hybrid_Parameters_2.SetElementGeneration( HYBRIDPluginBuilder.Generation_Tetra_Dominant )
MG_Hybrid_Parameters_2.SetHeightFirstLayer( 0.01 )
MG_Hybrid_Parameters_2.SetBoundaryLayersProgression( 1.1 )
MG_Hybrid_Parameters_2.SetNbOfBoundaryLayers( 3 )
MG_Hybrid_Parameters_2.SetFacesWithLayers( wall_ids )
MG_Hybrid_Parameters_2.SetFacesWithImprinting( [ Inlet_x_id, Inlet_z_id, Outlet_id ] )

isDone = Mesh_2.Compute()

mesh_2_volume = Mesh_2.GetVolume()
faces_imprinted = ["Inlet_x", "Inlet_z", "Outlet"]

def checkMesh_2(Mesh_2, d_groups_1):
  Mesh_2.CheckCompute()
  assert Mesh_2.NbQuadrangles() > 0

  d_groups_2 = {}

  for geom_group in geom_groups:
    name = geom_group.GetName()
    gr = Mesh_2.Group(geom_group)
    d_groups_2[name] = gr

  # Check viscous layers with imprinting
  for name in faces_imprinted:
    geom_area = geompy.BasicProperties(d_geom_groups[name])[1]
    gr_1 = d_groups_1[name]
    gr_2 = d_groups_2[name]
    #assert gr_1.Size() > 0
    assert gr_2.Size() > 0
    # Nb of quadrangles is in 7th index of mesh info
    assert gr_2.GetMeshInfo()[7] > 0

    # Compare mesh group and geom group
    area_error_1 = abs(geom_area-smesh.GetArea(gr_2))/geom_area
    assert area_error_1 < 0.025
    # Compare mesh group with imprinting and mesh group without imprinting
    area_error_2 = abs(smesh.GetArea(gr_1)-smesh.GetArea(gr_2))/smesh.GetArea(gr_1)
    assert area_error_2 < 1e-08

  # Compare whole mesh volume
  volume_error_2 = abs(shape_volume-mesh_2_volume)/shape_volume

  assert volume_error_2 < 0.02

  return d_groups_2

d_groups_2 = checkMesh_2(Mesh_2, d_groups_1)

# Compute same mesh with library
MG_Hybrid_Parameters_2.SetToUseLibrary(True)
Mesh_2.Clear()
Mesh_2.Compute()
d_groups_2 = checkMesh_2(Mesh_2, d_groups_1)

# Viscous layers with imprinting set by groups
# ============================================

Mesh_3 = smesh.Mesh(piquage, "Mesh_with_imprinting_set_by_groups")

NETGEN_2D_1_1 = Mesh_3.Triangle(algo=smeshBuilder.NETGEN_1D2D)
status = Mesh_3.AddHypothesis(NETGEN_2D_Parameters)

MG_Hybrid_3 = Mesh_3.Tetrahedron(algo=smeshBuilder.HYBRID)
MG_Hybrid_Parameters_3 = MG_Hybrid_3.Parameters()
MG_Hybrid_Parameters_3.SetLayersOnAllWrap( 0 )
MG_Hybrid_Parameters_3.SetElementGeneration( HYBRIDPluginBuilder.Generation_Tetra_Dominant )
MG_Hybrid_Parameters_3.SetHeightFirstLayer( 0.01 )
MG_Hybrid_Parameters_3.SetBoundaryLayersProgression( 1.1 )
MG_Hybrid_Parameters_3.SetNbOfBoundaryLayers( 3 )
MG_Hybrid_3.SetFacesWithLayers( Wall )
MG_Hybrid_3.SetFacesWithImprinting( [ Inlet_x, Inlet_z, Outlet ] )

isDone = Mesh_3.Compute()

def checkMesh_3(Mesh_3, d_groups_2):
  Mesh_3.CheckCompute()

  d_groups_3 = {}

  for geom_group in geom_groups:
    name = geom_group.GetName()
    gr = Mesh_3.Group(geom_group)
    d_groups_3[name] = gr

  # Compare whole mesh volume
  mesh_3_volume = Mesh_3.GetVolume()
  volume_error_3 = abs(mesh_2_volume-mesh_3_volume)/mesh_2_volume

  assert math.isclose(mesh_3_volume,mesh_2_volume,rel_tol=1e-7)

  # Check viscous layers with imprinting
  for name in faces_imprinted:
    gr_2 = d_groups_2[name]
    gr_3 = d_groups_3[name]
    assert gr_3.Size() > 0
    # Nb of quadrangles is in 7th index of mesh info
    assert gr_2.GetMeshInfo()[7] == gr_3.GetMeshInfo()[7]

    # Compare mesh group with imprinting set by ids and mesh group with imprinting set by geom group
    assert math.isclose( smesh.GetArea(gr_2), smesh.GetArea(gr_3))

checkMesh_3(Mesh_3, d_groups_2)

# Compute same mesh with library
MG_Hybrid_Parameters_3.SetToUseLibrary(True)
Mesh_3.Clear()
Mesh_3.Compute()
checkMesh_3(Mesh_3, d_groups_2)

