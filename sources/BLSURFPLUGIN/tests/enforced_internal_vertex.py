# -*- coding: utf-8 -*-
# Copyright (C) 2013-2026  CEA, EDF
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

from salome.kernel import salome
import math

from salome.kernel import GEOM
from salome.geom import geomBuilder
geompy = geomBuilder.New()

r = 10
dist = 10
dist_coin = 10.1

p1 = geompy.MakeVertex(0., 0., 0.)
p2 = geompy.MakeVertex(100., 100., 100.)
box = geompy.MakeBoxTwoPnt(p1, p2)
geompy.addToStudy(box, "box")

p3 = geompy.MakeVertex(dist_coin, 0, dist_coin)
geompy.addToStudy(p3, "p3")

part = geompy.MakePartition([box], [p3])
geompy.addToStudy(part, "part")

left = geompy.GetFaceNearPoint(box, p3)
geompy.addToStudyInFather(box, left, "left")


# Mesh
# ====

from salome.kernel import SMESH
from salome.smesh import smeshBuilder
smesh = smeshBuilder.New()

Mesh = smesh.Mesh(part, "Mesh")

algo2d = Mesh.Triangle(algo=smeshBuilder.MG_CADSurf)
algo2d.SetGeometricMesh( 1 )
algo2d.SetAngleMesh( 4 )
algo2d.SetPhySize( 8 )

algo2d.SetInternalEnforcedVertexAllFaces(True)

ok = Mesh.Compute()

if not ok:
  raise Exception("Mesh not computed")

id_node = Mesh.FindNodeClosestTo(dist_coin, 0, dist_coin)

x, y, z = Mesh.GetNodeXYZ(id_node)

assert("%.2f, %.2f, %.2f"%(x, y, z) == "%.2f, %.2f, %.2f"%(dist_coin, 0, dist_coin))

salome.sg.updateObjBrowser()

