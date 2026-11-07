# Copyright (C) 2007-2026  CEA, EDF, OPEN CASCADE
#
# Copyright (C) 2003-2007  OPEN CASCADE, EADS/CCR, LIP6, CEA/DEN,
# CEDRAT, EDF R&D, LEG, PRINCIPIA R&D, BUREAU VERITAS
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

#============================================================================
# File   : PYCALCULATOR_TEST.py
# Author : Vadim SANDLER, OPEN CASCADE S.A.S. (vadim.sandler@opencascade.com)
#============================================================================

import os

from salome.kernel import salome
salome.salome_init()

import PYCALCULATOR_ORB

from medcoupling import *
from MEDCouplingCorba import *
from MEDLoader import *
from MEDCouplingClient import *

pc = salome.lcc.FindOrLoadComponent('FactoryServer','PYCALCULATOR')

medFile   = os.path.join(os.getenv("DATA_DIR"), "MedFiles", "pointe.med")
meshName  = "maa1"
fieldName = "fieldcelldoublevector"
print(medFile, meshName, fieldName)

f = ReadFieldCell(medFile, meshName, 0, fieldName, -1, -1)
forig = MEDCouplingFieldDoubleServant._this(f)

fcopy = pc.Clone(forig)
f1    = pc.Add(forig, fcopy)
f2    = pc.Mul(forig, fcopy)
f3    = pc.AddConstant(forig, 3.5)
f4    = pc.MulConstant(forig, 3.5)

clt_forig = MEDCouplingFieldDoubleClient.New(forig)
clt_fcopy = MEDCouplingFieldDoubleClient.New(fcopy)
clt_f1 = MEDCouplingFieldDoubleClient.New(f1)
clt_f2 = MEDCouplingFieldDoubleClient.New(f2)
clt_f3 = MEDCouplingFieldDoubleClient.New(f3)
clt_f4 = MEDCouplingFieldDoubleClient.New(f4)

print("clt_forig:", clt_forig)
print("clt_fcopy:", clt_fcopy)
print("clt_f1:", clt_f1)
print("clt_f2:", clt_f2)
print("clt_f3:", clt_f3)
print("clt_f4:", clt_f4)
