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

#  File   : SyrControlComponent.py
#  Author : Jean Rahuel
#  Module : SuperVisionTest
#
import os
import sys
import time
import sys
from omniORB import CORBA, PortableServer
import CosNaming
from salome.kernel import Engines, Engines__POA
import SuperVisionTest, SuperVisionTest__POA
from SALOME_ComponentPy import *

from LifeCycleCORBA import *
from SALOME_NamingServicePy import *

from SyrComponent_idl import *

from SyrControlComponent_idl import *

orb = CORBA.ORB_init([''], CORBA.ORB_ID)

lcc = LifeCycleCORBA(orb)

naming_service = SALOME_NamingServicePy_i(orb)

modulecatalog = naming_service.Resolve("/Kernel/ModulCatalog")

class SyrControlComponent( SuperVisionTest__POA.SyrControlComponent, SALOME_ComponentPy_i):

    def L_OneEven( self , ValOne , ValEven ):
        self.beginService( 'SyrControlComponent L_OneEven' )
        self.sendMessage( NOTIF_STEP , "time.sleep( 1 )" )
        time.sleep( 1 )
        Finished = ValOne
        if Finished == 0 :
            Incr = 1
            Even = ValEven
            if Even == 0 :
                self.sendMessage( NOTIF_TRACE , "OddNumber" )
                Odd = 1
            else :
                self.sendMessage( NOTIF_TRACE , "EvenNumber" )
                Odd = 0
        else :
            self.sendMessage( NOTIF_TRACE , "Syracuse is TRUE : NumberOne" )
            Incr = 0
            Even = 0
            Odd = 0
        Even = ValEven
        self.endService( 'SyrControlComponent L_OneEven' )
        return Finished,Incr,Even,Odd
    
    def C_NotOneIsEven( self ):
        self.beginService( 'SyrControlComponent C_NotOneIsEven' )
        self.sendMessage( NOTIF_TRACE , "EvenNumber" )
        time.sleep( 1 )
        self.endService( 'SyrControlComponent C_NotOneIsEven' )
        return 0,1
    
    def LOOPN( self , InLoop , iN , iK , min , max ):
        self.beginService( 'SyrControlComponent LOOPN' )
        self.sendMessage( NOTIF_TRACE , "LOOPN" )
        time.sleep( 1 )
        OutLoop = 0
        N = 0
        if InLoop != 0 :
            if min > 0 & min <= max :
                N = min
                OutLoop = 1
        else :
            if iN < max :
                N = iN + 1
                OutLoop = 1
        print('SyrControlComponent LOOPN InLoop iN OutLoop N',InLoop,iN,OutLoop,N)
        self.endService( 'SyrControlComponent LOOPN' )
        return OutLoop,N,0

    def WHILENOTONE( self , N ):
        OutLoop = self.Syr.C_ISONE( N )
        if OutLoop == 0 :
            OutLoop = 1
        else :
            OutLoop = 0
        print('SyrControlComponent WHILENOTONE OutLoop N',OutLoop,N)
        return OutLoop

    def IFNOTEVEN( self , N ) :
        Even = self.Syr.C_ISEVEN( N )
        Odd = 0
        if Even == 0 :
            Odd = 1
        print('SyrControlComponent IFNOTEVEN Odd Even N',Odd,Even,N)
        return Odd,Even

    def LOOPi( self , InLoop , ii ):
        OutLoop = 0
        i = 0
        if InLoop != 0 :
            i = 0
            OutLoop = 1
        else :
            if ii+1 < 2 :
                i = ii + 1
                OutLoop = 1
        print('SyrControlComponent LOOPi InLoop ii OutLoop i',InLoop,ii,OutLoop,i)
        return OutLoop,i

    def WHILEEVEN( self , N ) :
        OutLoop = self.Syr.C_ISEVEN( N )
        print('SyrControlComponent WHILEEVEN OutLoop N',OutLoop,N)
        return OutLoop 

    def __init__(self, orb, poa, this, containerName, instanceName, interfaceName):
        SALOME_ComponentPy_i.__init__(self, orb, poa, this, containerName,
                                      instanceName, interfaceName, True)
        self.Syr = lcc.FindOrLoadComponent( 'FactoryServer' , 'SyrComponent' )
        print("SyrControlComponent::__init__",dir(self.Syr))

    def getVersion( self ):
        from salome.kernel import salome_version
        return salome_version.getVersion("COMPONENT", True)

