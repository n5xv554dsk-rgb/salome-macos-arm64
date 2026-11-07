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
Face_1 = geompy.MakeFaceHW(100, 100, 1)
Disk_1 = geompy.MakeDiskR(20, 1)
Partition_1 = geompy.MakePartition([Face_1, Disk_1], Limit=geompy.ShapeType["FACE"])
geompy.addToStudy( O, 'O' )
geompy.addToStudy( OX, 'OX' )
geompy.addToStudy( OY, 'OY' )
geompy.addToStudy( OZ, 'OZ' )
geompy.addToStudy( Face_1, 'Face_1' )
geompy.addToStudy( Disk_1, 'Disk_1' )
geompy.addToStudy( Partition_1, 'Partition_1' )

###
### SMESH component
###

from salome.kernel import SMESH, SALOMEDS
from salome.smesh import smeshBuilder

from salome.kernel.BLSURFPlugin import BLSURFPluginBuilder

smesh = smeshBuilder.New()
Mesh_1 = smesh.Mesh(Partition_1)
MG_CADSurf = Mesh_1.Triangle(algo=smeshBuilder.MG_CADSurf)
MG_CADSurf_Parameters_1 = MG_CADSurf.Parameters()
MG_CADSurf_Parameters_1.SetPhySize( 10 )
MG_CADSurf_Parameters_1.SetMaxSize( 10 )
MG_CADSurf_Parameters_1.SetChordalError( -1 )


# Test quadrangle dominant
MG_CADSurf_Parameters_1.SetElementType( BLSURFPluginBuilder.QuadrangleDominant )
isDone = Mesh_1.Compute()
if not isDone:
  raise Exception("Mesh not computed")

assert Mesh_1.NbQuadrangles() > 0
assert Mesh_1.NbTriangles() > 0
assert Mesh_1.NbQuadrangles() > Mesh_1.NbTriangles()


# Test quadrangles only
MG_CADSurf_Parameters_1.SetElementType( BLSURFPluginBuilder.Quadrangles )
isDone = Mesh_1.Compute()
if not isDone:
  raise Exception("Mesh not computed")

assert Mesh_1.NbQuadrangles() > 0
assert Mesh_1.NbTriangles() == 0


# Test triangles only
MG_CADSurf_Parameters_1.SetElementType( BLSURFPluginBuilder.Triangles )
isDone = Mesh_1.Compute()
if not isDone:
  raise Exception("Mesh not computed")

assert Mesh_1.NbQuadrangles() == 0
assert Mesh_1.NbTriangles() > 0

# Test quadrangle dominant compatibility (to be deprecated in Salome 9)
MG_CADSurf_Parameters_1.SetQuadAllowed( True )
isDone = Mesh_1.Compute()
if not isDone:
  raise Exception("Mesh not computed")

assert Mesh_1.NbQuadrangles() > 0
assert Mesh_1.NbTriangles() > 0
assert Mesh_1.NbQuadrangles() > Mesh_1.NbTriangles()

if salome.sg.hasDesktop():
  salome.sg.updateObjBrowser()
