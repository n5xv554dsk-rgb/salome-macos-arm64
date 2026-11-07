# -*- coding: utf-8 -*-
# Copyright (C) 2014-2026  CEA, EDF
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
geompy = geomBuilder.New()


geompy.init_geom()

sphere = geompy.MakeSphereR(10)
geompy.addToStudy( sphere, 'sphere' )

###
### SMESH component
###

from salome.kernel import SMESH
from salome.smesh import smeshBuilder
smesh = smeshBuilder.New()


Mesh_1 = smesh.Mesh(sphere)

BLSURF_1 = Mesh_1.Triangle(algo=smeshBuilder.MG_CADSurf)
BLSURF_Parameters = BLSURF_1.Parameters()
BLSURF_Parameters.SetPhySize( 5 )
BLSURF_Parameters.SetGeometricMesh( 1 )
BLSURF_Parameters.SetAngleMesh( 8 )

ok = Mesh_1.Compute()

if not ok:
    raise Exception("Error when computing surface mesh")

try:
    Mesh_1.Tetrahedron(algo=smeshBuilder.MG_Tetra)

    ok = Mesh_1.Compute()

    if not ok:
        raise Exception("Error when computing volume mesh")
except AttributeError:
    print("Warning: Cannot build volume mesh: MG-Tetra plugin seems to be unavailable")

if salome.sg.hasDesktop():
  salome.sg.updateObjBrowser()
