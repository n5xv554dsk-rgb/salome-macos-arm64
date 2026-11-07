#! /usr/bin/env python3
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

#  SuperVisionTest FactorialComponent : example of component that calculates factorial
#  File   : FactorialComponent.py
#  Author : 
#  Module : SuperVisionTest
#  $Header$
#
import sys
from omniORB import CORBA, PortableServer
import CosNaming
from salome.kernel import Engines, Engines__POA
import SuperVisionTest, SuperVisionTest__POA
from SALOME_ComponentPy import *

from FactorialComponent_idl import *

class FactorialComponent( SuperVisionTest__POA.FactorialComponent, SALOME_ComponentPy_i):

    def eval(self, val):
        self.beginService( 'FactorialComponent eval' )
        print("eval :",val)
        if (val < 0):
            raise ArgumentError("factorial must be positive, not " + repr(val))
        if (val < 2):
            print("eval return",val)
            self.sendMessage( NOTIF_STEP , "Done" )
            self.endService( 'FactorialComponent eval' )
            return val
        else:
            val1 = self.eval(val-1)
            self.sendMessage( NOTIF_TRACE , "One More Time" )
            print("eval return",val," * ",val1)
            return val * val1
    
    def sigma(self, val):
        self.beginService( 'FactorialComponent sigma' )
        print("sigma :",val)
        if (val < 0):
            raise ArgumentError("sigma must be positive, not " + repr(val))
        i = 0
        while i < 10000 :
            n = 1
            s = 0
            while n <= val :
                s = s + n
                n = n + 1
            i = i + 1
        print("sigma returns",s)
        self.endService( 'FactorialComponent sigma' )
        return s
    
    def getVersion( self ):
        from salome.kernel import salome_version
        return salome_version.getVersion("COMPONENT", True)

    def __init__(self, orb, poa, this, containerName, instanceName, interfaceName):
        SALOME_ComponentPy_i.__init__(self, orb, poa, this, containerName,
                                      instanceName, interfaceName, False)
        print("FactorialComponent::__init__")

