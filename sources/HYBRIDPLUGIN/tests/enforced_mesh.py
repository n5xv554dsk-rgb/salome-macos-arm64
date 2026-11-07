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

p1 = geompy.MakeVertex(0, -0.25, 1)
p2 = geompy.MakeVertex(0, 0.25, 1)
p3 = geompy.MakeVertex(0, 0.25, 3)
p4 = geompy.MakeVertex(0, -0.25, 3)

wire = geompy.MakePolyline([p1, p2, p3, p4, p1])
face = geompy.MakeFace(wire, 1, theName="face")

###
### SMESH component
###

from salome.kernel import SMESH, SALOMEDS
from salome.smesh import smeshBuilder

from salome.kernel.StdMeshers import StdMeshersBuilder

smesh = smeshBuilder.New()

Mesh_faces = smesh.Mesh(face)
Mesh_faces.Triangle(algo=smeshBuilder.MG_CADSurf)
Mesh_faces.Compute()


# Viscous layers with Netgen additional hypothesis
# ================================================

Mesh_1 = smesh.Mesh(piquage)
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

NETGEN_3D = Mesh_1.Tetrahedron()
Viscous_Layers_1 = NETGEN_3D.ViscousLayers(0.05,3,1.1,[],1,StdMeshersBuilder.SURF_OFFSET_SMOOTH)
Viscous_Layers_1.SetTotalThickness( 0.05 )
Viscous_Layers_1.SetNumberLayers( 3 )
Viscous_Layers_1.SetStretchFactor( 1.1 )
Viscous_Layers_1.SetMethod( StdMeshersBuilder.SURF_OFFSET_SMOOTH )
Viscous_Layers_1.SetFaces( wall_ids, 0 )


#isDone = Mesh_1.Compute()
#Mesh_1.SplitVolumesIntoTetra( Mesh_1, 1 )

Outlet_1 = Mesh_1.GroupOnGeom(Outlet,'Outlet',SMESH.FACE)
Wall_1 = Mesh_1.GroupOnGeom(Wall,'Wall',SMESH.FACE)
Inlet_z_1 = Mesh_1.GroupOnGeom(Inlet_z,'Inlet_z',SMESH.FACE)
Inlet_x_1 = Mesh_1.GroupOnGeom(Inlet_x,'Inlet_x',SMESH.FACE)

# Enforced mesh without layer
# ===========================

Mesh_2 = smesh.Mesh(piquage, "Mesh_without_layer")

NETGEN_2D_1_1 = Mesh_2.Triangle(algo=smeshBuilder.NETGEN_1D2D)
status = Mesh_2.AddHypothesis(NETGEN_2D_Parameters)

MG_Hybrid_2 = Mesh_2.Tetrahedron(algo=smeshBuilder.HYBRID)
MG_Hybrid_Parameters_2 = MG_Hybrid_2.Parameters()
MG_Hybrid_Parameters_2.SetLayersOnAllWrap( 0 )
MG_Hybrid_Parameters_2.SetElementGeneration( 0 )
#MG_Hybrid_Parameters_2.SetHeightFirstLayer( 0.01 )
#MG_Hybrid_Parameters_2.SetBoundaryLayersProgression( 1.1 )
#MG_Hybrid_Parameters_2.SetNbOfBoundaryLayers( 3 )
MG_Hybrid_Parameters_2.SetEnforcedMeshWithGroup( Mesh_faces.GetMesh(), SMESH.FACE, "LayersGroup" )
MG_Hybrid_Parameters_2.SetKeepFiles(1)

isDone = Mesh_2.Compute()

if not isDone:
  raise Exception("Error when computing Mesh_without_layer")

# Check that a group has been created with the enforced mesh
assert len(Mesh_2.GetGroups()) == 1
assert Mesh_2.GetGroups()[0].GetName() == 'LayersGroup'
assert Mesh_2.GetGroups()[0].Size() > 0

# Enforced mesh with layers
# =========================

Mesh_3 = smesh.Mesh(piquage, "Mesh_with_layer")

NETGEN_2D_1_1 = Mesh_3.Triangle(algo=smeshBuilder.NETGEN_1D2D)
status = Mesh_3.AddHypothesis(NETGEN_2D_Parameters)

MG_Hybrid_3 = Mesh_3.Tetrahedron(algo=smeshBuilder.HYBRID)
MG_Hybrid_Parameters_3 = MG_Hybrid_3.Parameters()
MG_Hybrid_Parameters_3.SetLayersOnAllWrap( 0 )
MG_Hybrid_Parameters_3.SetElementGeneration( 0 )
MG_Hybrid_Parameters_3.SetHeightFirstLayer( 0.01 )
MG_Hybrid_Parameters_3.SetBoundaryLayersProgression( 1.1 )
MG_Hybrid_Parameters_3.SetNbOfBoundaryLayers( 3 )
MG_Hybrid_Parameters_3.SetEnforcedMeshWithGroup( Mesh_faces.GetMesh(), SMESH.FACE, "LayersGroup" )
MG_Hybrid_Parameters_3.SetKeepFiles(1)
MG_Hybrid_3.SetFacesWithLayers( Wall )


isDone = Mesh_3.Compute()

if not isDone:
  raise Exception("Error when computing Mesh_with_layer")

# Check that a group has been created with the enforced mesh
assert len(Mesh_3.GetGroups()) == 1
assert Mesh_3.GetGroups()[0].GetName() == 'LayersGroup'
assert Mesh_3.GetGroups()[0].Size() > 0

