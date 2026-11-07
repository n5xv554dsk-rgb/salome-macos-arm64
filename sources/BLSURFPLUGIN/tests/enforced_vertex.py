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

dist_coin = 10.1

p1 = geompy.MakeVertex(0., 0., 0.)
p2 = geompy.MakeVertex(100., 100., 100.)
box = geompy.MakeBoxTwoPnt(p1, p2)
geompy.addToStudy(box, "box")

p3 = geompy.MakeVertex(dist_coin, 0, dist_coin)
geompy.addToStudy(p3, "p3")

left = geompy.GetFaceNearPoint(box, p3)
geompy.addToStudyInFather(box, left, "left")

allEnforcedCoords = []
allEnforcedCoords.append(( dist_coin, 0, dist_coin ))
allEnforcedCoords.append(( 20, 0, 15.3 ))
allEnforcedCoords.append(( 25, 1, 25.3 ))
allEnforcedCoords.append(( 35, 1, 45.3 ))
allEnforcedCoords.append(( 35, 1, 55.3 ))

p4 = geompy.MakeVertex( *(allEnforcedCoords[1] ))
p5 = geompy.MakeVertex( *(allEnforcedCoords[2] ))
pp = geompy.MakeCompound( [p4,p5], theName="p4,p5" )
p6 = geompy.MakeVertex( *(allEnforcedCoords[3] ), theName="p6")
p7 = geompy.MakeVertex( *(allEnforcedCoords[4] ), theName="p7")

xyz7 = allEnforcedCoords[4]

# Mesh
# ====

from salome.kernel import SMESH
from salome.smesh import smeshBuilder
smesh = smeshBuilder.New()

Mesh = smesh.Mesh(box, "Mesh")


algo2d = Mesh.Triangle(algo=smeshBuilder.MG_CADSurf)
algo2d.SetGeometricMesh( 1 )
algo2d.SetAngleMesh( 4 )
algo2d.SetPhySize( 8 )

algo2d.SetEnforcedVertex(left, dist_coin, 0, dist_coin)
algo2d.AddEnforcedVertexGeom( pp )
algo2d.AddEnforcedVertexGeom( p6 )
algo2d.AddEnforcedVertex( *xyz7 )

assert Mesh.Compute()
assert not Mesh.FindCoincidentNodes( 1e-7 )

for x,y,z in allEnforcedCoords:

    id_node = Mesh.FindNodeClosestTo( x,y,z )
    xn, yn, zn = Mesh.GetNodeXYZ( id_node )

    # compare X and Z
    assert "%.2f, %.2f"%(x, z) == "%.2f, %.2f"%( xn, zn ), \
        "%.2f, %.2f, %.2f != %.2f, %.2f, %.2f"%( xn, yn, zn, x,y,z )


salome.sg.updateObjBrowser()

