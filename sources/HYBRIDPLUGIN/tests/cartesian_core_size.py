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

O = geompy.MakeVertex(0, 0, 0)
OX = geompy.MakeVectorDXDYDZ(1, 0, 0)
OY = geompy.MakeVectorDXDYDZ(0, 1, 0)
OZ = geompy.MakeVectorDXDYDZ(0, 0, 1)
Cylinder_1 = geompy.MakeCylinderRH(100, 300)
geompy.addToStudy( O, 'O' )
geompy.addToStudy( OX, 'OX' )
geompy.addToStudy( OY, 'OY' )
geompy.addToStudy( OZ, 'OZ' )
geompy.addToStudy( Cylinder_1, 'Cylinder_1' )

###
### SMESH component
###

from salome.kernel import SMESH, SALOMEDS
from salome.smesh import smeshBuilder

from salome.kernel.HYBRIDPlugin import HYBRIDPluginBuilder

smesh = smeshBuilder.New()

# Hybrid mesh with hexa dominant core
# ===================================

Mesh_1 = smesh.Mesh(Cylinder_1)

MG_CADSurf = Mesh_1.Triangle(algo=smeshBuilder.MG_CADSurf)

MG_Hybrid = Mesh_1.Tetrahedron(algo=smeshBuilder.HYBRID)
MG_Hybrid_Parameters_1 = MG_Hybrid.Parameters()
MG_Hybrid_Parameters_1.SetElementGeneration( HYBRIDPluginBuilder.Generation_Hexa_Dominant )
MG_Hybrid_Parameters_1.SetHeightFirstLayer( 1 )
MG_Hybrid_Parameters_1.SetNbOfBoundaryLayers( 3 )

isDone = Mesh_1.Compute()

nb_hexas_1 = Mesh_1.NbHexas()

# check that hexaedra have been genereted
assert nb_hexas_1 > 0

# Hybrid mesh with cartesian core
# ===============================

Mesh_2 = smesh.Mesh(Cylinder_1)

MG_CADSurf_1 = Mesh_2.Triangle(algo=smeshBuilder.MG_CADSurf)

MG_Hybrid_1 = Mesh_2.Tetrahedron(algo=smeshBuilder.HYBRID)
MG_Hybrid_Parameters_2 = MG_Hybrid_1.Parameters()
MG_Hybrid_Parameters_2.SetElementGeneration( HYBRIDPluginBuilder.Generation_Cartesian_Core )
MG_Hybrid_Parameters_2.SetHeightFirstLayer( 1 )
MG_Hybrid_Parameters_2.SetNbOfBoundaryLayers( 3 )

isDone = Mesh_2.Compute()

nb_hexas_2 = Mesh_2.NbHexas()

# check that hexaedra have been genereted
assert nb_hexas_2 > 0


# Hybrid mesh with cartesian core with fine core elements size
# ============================================================

Mesh_3 = smesh.Mesh(Cylinder_1)

MG_CADSurf_1 = Mesh_3.Triangle(algo=smeshBuilder.MG_CADSurf)

MG_Hybrid_1 = Mesh_3.Tetrahedron(algo=smeshBuilder.HYBRID)
MG_Hybrid_Parameters_3 = MG_Hybrid_1.Parameters()
MG_Hybrid_Parameters_3.SetElementGeneration( HYBRIDPluginBuilder.Generation_Cartesian_Core )
MG_Hybrid_Parameters_3.SetHeightFirstLayer( 1 )
MG_Hybrid_Parameters_3.SetNbOfBoundaryLayers( 3 )
MG_Hybrid_Parameters_3.SetCoreSize( 10 )

isDone = Mesh_3.Compute()

nb_hexas_3 = Mesh_3.NbHexas()

# check that more hexaedra have been genereted
assert nb_hexas_3 > nb_hexas_2

