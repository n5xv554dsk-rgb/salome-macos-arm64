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

box_side = 200

O = geompy.MakeVertex(0, 0, 0)
OX = geompy.MakeVectorDXDYDZ(1, 0, 0)
OY = geompy.MakeVectorDXDYDZ(0, 1, 0)
OZ = geompy.MakeVectorDXDYDZ(0, 0, 1)
Box_1 = geompy.MakeBoxDXDYDZ(box_side, box_side, box_side)
geompy.addToStudy( O, 'O' )
geompy.addToStudy( OX, 'OX' )
geompy.addToStudy( OY, 'OY' )
geompy.addToStudy( OZ, 'OZ' )
geompy.addToStudy( Box_1, 'Box_1' )

###
### SMESH component
###

from salome.kernel import SMESH, SALOMEDS
from salome.smesh import smeshBuilder

smesh = smeshBuilder.New()
Mesh_1 = smesh.Mesh(Box_1)
MG_CADSurf = Mesh_1.Triangle(algo=smeshBuilder.MG_CADSurf)
MG_CADSurf_Parameters_1 = MG_CADSurf.Parameters()
MG_CADSurf_Parameters_1.SetPhySize( 10 )
MG_CADSurf_Parameters_1.SetMinSize( 0.34641 )
MG_CADSurf_Parameters_1.SetMaxSize( 69.282 )

isDone = Mesh_1.Compute()

# Copy the skin mesh
Mesh_2 = smesh.CopyMesh( Mesh_1, 'Mesh_2', 0, 0)

# Add hybrid
HYBRID_3D = Mesh_1.Tetrahedron(algo=smeshBuilder.HYBRID)
MG_Hybrid_Parameters_1 = HYBRID_3D.Parameters()
MG_Hybrid_Parameters_1.SetElementGeneration( 1 )
MG_Hybrid_Parameters_1.SetHeightFirstLayer( 1 )
MG_Hybrid_Parameters_1.SetNbOfBoundaryLayers( 3 )

# Compute mesh on CAD
# ===================
isDone = Mesh_1.Compute()

# Check volume
vol_mesh_1 = smesh.GetVolume(Mesh_1)
vol_box = box_side**3
assert abs(vol_mesh_1-vol_box)/vol_box < 1e-4

# Check number of pyramids
assert Mesh_1.NbPyramids() > 1000

# Add hybrid to skin mesh
HYBRID_3D_1 = Mesh_2.Tetrahedron(algo=smeshBuilder.HYBRID,geom=None)
status = Mesh_2.AddHypothesis(MG_Hybrid_Parameters_1,None)

# Compute mesh without CAD
# ========================
isDone = Mesh_2.Compute()

# Check volume
vol_mesh_2 = smesh.GetVolume(Mesh_2)
vol_box = box_side**3
assert abs(vol_mesh_2-vol_box)/vol_box < 1e-4

# Check number of pyramids
assert Mesh_2.NbPyramids() > 1000

