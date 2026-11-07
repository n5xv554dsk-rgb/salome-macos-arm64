# -*- coding: utf-8 -*-
# Copyright (C) 2015-2026  CEA, EDF
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

# TA 24-04-2018 : quadrangle_gradation replaces 
# new_1331_test_quadrangles_gradation.py as the starting geometrical part should
# be 3D and not 2D. A 2D part does not constitute a representative case.
import sys
from salome.kernel import salome

salome.salome_init()
theStudy = salome.myStudy

###
### GEOM component
###

from salome.kernel import GEOM
from salome.geom import geomBuilder
import math
from salome.kernel import SALOMEDS


geompy = geomBuilder.New()

h = 5

O = geompy.MakeVertex(0, 0, 0)
OX = geompy.MakeVectorDXDYDZ(1, 0, 0)
OY = geompy.MakeVectorDXDYDZ(0, 1, 0)
OZ = geompy.MakeVectorDXDYDZ(0, 0, 1)
Cylinder_1 = geompy.MakeCylinderRH(1, h)
Sphere_1 = geompy.MakeSphereR(1.5)
Translation_1 = geompy.MakeTranslation(Sphere_1, 0, 0, h)
Fuse_1 = geompy.MakeFuseList([Cylinder_1, Sphere_1, Translation_1], False, True)
geompy.addToStudy( O, 'O' )
geompy.addToStudy( OX, 'OX' )
geompy.addToStudy( OY, 'OY' )
geompy.addToStudy( OZ, 'OZ' )
geompy.addToStudy( Cylinder_1, 'Cylinder_1' )
geompy.addToStudy( Sphere_1, 'Sphere_1' )
geompy.addToStudy( Translation_1, 'Translation_1' )
geompy.addToStudy( Fuse_1, 'Fuse_1' )

###
### SMESH component
###

from salome.kernel import SMESH, SALOMEDS
from salome.smesh import smeshBuilder

from salome.kernel.BLSURFPlugin import BLSURFPluginBuilder

smesh = smeshBuilder.New()

# First mesh with quadrangle-dominant gradation
Mesh_1 = smesh.Mesh(Fuse_1, "Mesh_1")
MG_CADSurf = Mesh_1.Triangle(algo=smeshBuilder.MG_CADSurf)
MG_CADSurf_Parameters_1 = MG_CADSurf.Parameters()
MG_CADSurf_Parameters_1.SetElementType( BLSURFPluginBuilder.QuadrangleDominant )
MG_CADSurf_Parameters_1.SetPhySize( 1 )
MG_CADSurf_Parameters_1.SetMaxSize( 1 )
MG_CADSurf_Parameters_1.SetGradation( 1.05 )
MG_CADSurf_Parameters_1.SetAngleMesh( 4 )
isDone = Mesh_1.Compute()
if not isDone:
  raise Exception("Mesh not computed")

min_1, max_1 = Mesh_1.GetMinMax(SMESH.FT_Area)

# Check that min and max areas are not too far
assert max_1/min_1 < 7

# Second mesh with anisotropy (which disable gradation)
Mesh_2 = smesh.Mesh(Fuse_1, "Mesh_2")
MG_CADSurf = Mesh_2.Triangle(algo=smeshBuilder.MG_CADSurf)
MG_CADSurf_Parameters_2 = MG_CADSurf.Parameters()
MG_CADSurf_Parameters_2.SetElementType( BLSURFPluginBuilder.QuadrangleDominant )
MG_CADSurf_Parameters_2.SetPhySize( 1 )
MG_CADSurf_Parameters_2.SetMaxSize( 1 )
MG_CADSurf_Parameters_2.SetGradation( 1.05 )
MG_CADSurf_Parameters_2.SetAngleMesh( 4 )
MG_CADSurf_Parameters_2.SetAnisotropic( True )
isDone = Mesh_2.Compute()
if not isDone:
  raise Exception("Mesh not computed")


errorMsg = ''

# retrieve the 2D lengths
length_1 = Mesh_1.GetMinMax(SMESH.FT_Length)[1]
length_2 = Mesh_2.GetMinMax(SMESH.FT_Length)[1]

# TEST: expecting the max length to be larger for Mesh_2
if length_1 > length_2:
  errorMsg += '\n' + ' -> Inconsistent max lengths comparison: Mesh_1 = {} Mesh_2 = {}'.format(length_1,length_2)

# retrieve the max aspect ratio for the meshes
aspectRatio_1 = Mesh_1.GetMinMax(SMESH.FT_AspectRatio)[1]
aspectRatio_2 = Mesh_2.GetMinMax(SMESH.FT_AspectRatio)[1]

# TEST: expecting the max value for the aspect ratio to be larger for Mesh_2 
if aspectRatio_1 > aspectRatio_2:
  errorMsg += '\n' + ' -> Inconsistent Aspect ratios comparison: Mesh_1 = {} Mesh_2 = {}'.format(aspectRatio_1,aspectRatio_2)

if errorMsg != '':
  raise RuntimeError("Aspect ratio check the isotropic option with MG-CADSURF algo. The test is KO." + errorMsg )

if salome.sg.hasDesktop():
  salome.sg.updateObjBrowser()
