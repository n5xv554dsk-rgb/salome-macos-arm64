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

###
### SMESH component
###

from salome.kernel import SMESH, SALOMEDS
from salome.smesh import smeshBuilder

smesh = smeshBuilder.New()

Mesh_with_imprinting_set_by_groups = smesh.Mesh(piquage)
NETGEN_2D_1 = Mesh_with_imprinting_set_by_groups.Triangle(algo=smeshBuilder.NETGEN_1D2D)
NETGEN_Parameters_2D = NETGEN_2D_1.Parameters()
NETGEN_Parameters_2D.SetMinSize( 0.01 )
NETGEN_Parameters_2D.SetLocalSizeOnShape(corner, 0.01)
NETGEN_Parameters_2D.SetFineness( 5 )
NETGEN_Parameters_2D.SetGrowthRate( 0.1 )
NETGEN_Parameters_2D.SetNbSegPerEdge( 2 )
NETGEN_Parameters_2D.SetNbSegPerRadius( 3 )

wall_faces = geompy.SubShapeAll(Wall, geompy.ShapeType["FACE"])
wall_ids = geompy.GetSubShapesIDs(piquage, wall_faces)
Inlet_x_id, Inlet_z_id, Outlet_id = geompy.GetSubShapesIDs(piquage, [Inlet_x, Inlet_z, Outlet])

HYBRID_3D_2_2 = Mesh_with_imprinting_set_by_groups.Tetrahedron(algo=smeshBuilder.HYBRID)
HYBRID_Parameters_2 = HYBRID_3D_2_2.Parameters()
HYBRID_Parameters_2.SetElementGeneration( 0 )
HYBRID_Parameters_2.SetHeightFirstLayer( 0.01 )
HYBRID_Parameters_2.SetBoundaryLayersProgression( 1.1 )
HYBRID_Parameters_2.SetNbOfBoundaryLayers( 3 )
HYBRID_Parameters_2.SetFacesWithLayers( wall_ids )
HYBRID_Parameters_2.SetFacesWithImprinting( [ Inlet_x_id, Inlet_z_id, Outlet_id ] )
HYBRID_Parameters_2.SetLayersOnAllWrap( 0 )
isDone = Mesh_with_imprinting_set_by_groups.Compute()

if not isDone:
  raise Exception("Problem in mesh generation")

Nb_elems_0 = Mesh_with_imprinting_set_by_groups.NbVolumes()

print("Nb_elems_0: ", Nb_elems_0)

Inlet_x_3 = Mesh_with_imprinting_set_by_groups.GroupOnGeom(Inlet_x,'Inlet_x',SMESH.FACE)
Inlet_z_3 = Mesh_with_imprinting_set_by_groups.GroupOnGeom(Inlet_z,'Inlet_z',SMESH.FACE)
Outlet_3 = Mesh_with_imprinting_set_by_groups.GroupOnGeom(Outlet,'Outlet',SMESH.FACE)
Wall_3 = Mesh_with_imprinting_set_by_groups.GroupOnGeom(Wall,'Wall',SMESH.FACE)

# Add an advanced option as text
HYBRID_Parameters_2.SetAdvancedOption( '--boundary_layer_height_relative_to_local_surface_size yes' )
isDone = Mesh_with_imprinting_set_by_groups.Compute()

if not isDone:
  raise Exception("Problem in mesh generation")

Nb_elems_1 = Mesh_with_imprinting_set_by_groups.NbVolumes()

print("Nb_elems_1: ", Nb_elems_1)

# Check that the number of elements is changed by the option
assert Nb_elems_1> 1.5*Nb_elems_0, "Advanced option as text does not work"

