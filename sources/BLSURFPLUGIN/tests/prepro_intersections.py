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

Face_1 = geompy.MakeFaceHW(10, 10, 1)
Translation_1 = geompy.MakeTranslation(Face_1, 10.0001, 0.0001, 0)
Translation_2 = geompy.MakeTranslation(Face_1, 5, -9.99995, 0)
Partition_1 = geompy.MakePartition([Face_1, Translation_1, Translation_2], [], [], [], geompy.ShapeType["FACE"], 0, [], 0)
geompy.addToStudy( Face_1, 'Face_1' )
geompy.addToStudy( Translation_1, 'Translation_1' )
geompy.addToStudy( Translation_2, 'Translation_2' )
geompy.addToStudy( Partition_1, 'Partition_1' )

p_axe = geompy.MakeVertex(5, -5, 0)
axe = geompy.MakePrismDXDYDZ(p_axe, 0, 0, 1)
vertices = geompy.GetShapesOnCylinder(Partition_1, geompy.ShapeType["VERTEX"], axe, 1e-3, GEOM.ST_IN)
gr_vertices = geompy.CreateGroup(Partition_1, geompy.ShapeType["VERTEX"])
geompy.UnionList(gr_vertices, vertices)
geompy.addToStudyInFather(Partition_1, gr_vertices, "vertices")

###
### SMESH component
###

from salome.kernel import SMESH
from salome.smesh import smeshBuilder
smesh = smeshBuilder.New()


Mesh_1 = smesh.Mesh(Partition_1)

BLSURF_1 = Mesh_1.Triangle(algo=smeshBuilder.MG_CADSurf)
BLSURF_Parameters = BLSURF_1.Parameters()
BLSURF_Parameters.SetPhySize( 5 )
BLSURF_Parameters.SetPreCADMergeEdges( True )
BLSURF_Parameters.SetPreCADProcess3DTopology( True )
BLSURF_Parameters.SetPreCADOptionValue( 'remove_tiny_uv_edges', 'yes' )

ok = Mesh_1.Compute()
if not ok:
  raise Exception("Mesh not computed")

# Check that vertices are merged by preCAD preprocessing
nodes = []
for p in vertices:
    x, y, z = geompy.PointCoordinates(p)
    id_node = Mesh_1.FindNodeClosestTo(x, y, z)
    nodes.append(id_node)

nodes = list(set(nodes))

nodesGroup = Mesh_1.MakeGroupByIds("nodes", SMESH.NODE, nodes)

assert nodesGroup.Size() == 1, nodesGroup.GetIDs()

if salome.sg.hasDesktop():
  salome.sg.updateObjBrowser()
