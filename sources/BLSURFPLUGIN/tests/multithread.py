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

import os
import sys
from salome.kernel import salome
import time
import multiprocessing

salome.salome_init()

cpu_count = multiprocessing.cpu_count()

if cpu_count > 1:
    print ("Running test on workstation with %d available cores" % cpu_count)

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
    flight_solid_brep_1 = geompy.ImportBREP(os.path.join(os.getenv("BLSURFPLUGIN_ROOT_DIR"),"share/salome/resources/blsurfplugin/flight_solid.brep"))
    geompy.addToStudy( O, 'O' )
    geompy.addToStudy( OX, 'OX' )
    geompy.addToStudy( OY, 'OY' )
    geompy.addToStudy( OZ, 'OZ' )
    geompy.addToStudy( flight_solid_brep_1, 'flight_solid.brep_1' )

    ###
    ### SMESH component
    ###

    from salome.kernel import SMESH, SALOMEDS
    from salome.smesh import smeshBuilder

    smesh = smeshBuilder.New()

    Mesh_1 = smesh.Mesh(flight_solid_brep_1)
    MG_CADSurf = Mesh_1.Triangle(algo=smeshBuilder.MG_CADSurf)
    MG_CADSurf_Parameters_1 = MG_CADSurf.Parameters()
    MG_CADSurf_Parameters_1.SetPhySize( 1 )
    MG_CADSurf_Parameters_1.SetMaxSize( 1 )
    MG_CADSurf_Parameters_1.SetGradation( 1.05 )
    MG_CADSurf_Parameters_1.SetAngleMesh( 1 )
    MG_CADSurf_Parameters_1.SetChordalError( 2.40018 )
    # 4 procs are used by default
    # => No need to set an option

    time0 = time.time()
    isDone = Mesh_1.Compute()
    time1 = time.time()

    time_multithread = time1-time0

    print ("Time in multi thread (%d procs): %.3f s"%(cpu_count, time_multithread))

    Mesh_2 = smesh.Mesh(flight_solid_brep_1)
    MG_CADSurf = Mesh_2.Triangle(algo=smeshBuilder.MG_CADSurf)
    MG_CADSurf_Parameters_2 = MG_CADSurf.Parameters()
    MG_CADSurf_Parameters_2.SetPhySize( 1 )
    MG_CADSurf_Parameters_2.SetMaxSize( 1 )
    MG_CADSurf_Parameters_2.SetGradation( 1.05 )
    MG_CADSurf_Parameters_2.SetAngleMesh( 1 )
    MG_CADSurf_Parameters_2.SetChordalError( 2.40018 )
    # Use only one thread
    MG_CADSurf_Parameters_2.SetMaxNumberOfThreads( 1 )

    time2 = time.time()
    isDone = Mesh_2.Compute()
    time3 = time.time()

    time_singlethread = time3-time2
    print ("Time in single thread (1 proc): %.3f s"%(time_singlethread))

    assert time_multithread < time_singlethread

    if salome.sg.hasDesktop():
      salome.sg.updateObjBrowser()
else:
    print ("Warning: multithread test is disabled for %d cpu core(s)" % cpu_count)
