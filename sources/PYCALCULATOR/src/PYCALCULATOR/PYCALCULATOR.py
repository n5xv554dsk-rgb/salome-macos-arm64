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
# File   : PYCALCULATOR.py
# Author : Vadim SANDLER, OPEN CASCADE S.A.S. (vadim.sandler@opencascade.com)
#============================================================================

# Instruct Python to load dynamic libraries using global resolution of symbols
# This is necessary to ensure that different modules will have the same definition
# of dynamic types and C++ RTTI will work between them
#
import os, sys
sys.setdlopenflags(os.RTLD_NOW | os.RTLD_GLOBAL)

from salome.kernel import PYCALCULATOR_ORB__POA
from salome.kernel import SALOME_ComponentPy
from salome.kernel import SALOME_Embedded_NamingService_ClientPy

from salome.kernel import SALOME_MED
from MEDCouplingClient import *
from MEDCouplingCorba import *

from salome.kernel.salome_utils import verbose

class PYCALCULATOR(PYCALCULATOR_ORB__POA.PYCALCULATOR_Gen, SALOME_ComponentPy.SALOME_ComponentPy_i):

    ## Constructor
    def __init__(self, orb, poa, contID, containerName, instanceName,
                 interfaceName):

        if verbose(): print("Begin of PYCALCULATOR::__init__")

        SALOME_ComponentPy.SALOME_ComponentPy_i.__init__(
            self,
            orb,              # ORB instance
            poa,              # POA instance
            contID,           # SALOME container id
            containerName,    # SALOME container name
            instanceName,     # component instance name
            interfaceName,    # component interface name
            False)            # notification flag (for notification server)
        
        emb_ns = self._contId.get_embedded_NS_if_ssl()
        import CORBA
        if CORBA.is_nil(emb_ns):
            self._naming_service = SALOME_ComponentPy.SALOME_NamingServicePy_i( self._orb )
        else:
            self._naming_service = SALOME_Embedded_NamingService_ClientPy.SALOME_Embedded_NamingService_ClientPy(emb_ns)

        if verbose(): print("End of PYCALCULATOR::__init__")

        pass

    ## base interface method: get version of the component
    def getVersion( self ):
        from salome.kernel import salome_version
        return salome_version.getVersion("PYCALCULATOR", True)

    ## interface service: clone field
    def Clone(self, field):
        self.beginService("PYCALCULATOR::Clone")

        if verbose(): 
            print("Begin of PYCALCULATOR::Clone")
            print("            field : ", field)
            pass

        frescorba = None
        
        try:
            # create local field from corba field
            f = MEDCouplingFieldDoubleClient.New(field)

            # create CORBA field
            frescorba = MEDCouplingFieldDoubleServant._this(f)
            
        except Exception as e:
            if verbose(): print(e)
            pass
        
        if verbose(): 
            print("End of PYCALCULATOR::Clone")
            pass
        
        self.endService("PYCALCULATOR::Clone")

        return frescorba

    ## interface service: add two fields
    def Add(self, field1, field2):
        self.beginService("PYCALCULATOR::Add")

        if verbose(): 
            print("Begin of PYCALCULATOR::Add")
            print("            field 1 : ", field1)
            print("            field 2 : ", field2)
            pass

        frescorba = None
        
        try:
            # create local fields from corba fields
            f1 = MEDCouplingFieldDoubleClient.New(field1)
            f2 = MEDCouplingFieldDoubleClient.New(field2)

            # add fields
            f2.changeUnderlyingMesh(f1.getMesh(), 0, 1e-12)
            fres = f1 + f2

            # create CORBA field
            frescorba = MEDCouplingFieldDoubleServant._this(fres)
            
        except Exception as e:
            if verbose(): print(e)
            pass
        
        if verbose(): 
            print("End of PYCALCULATOR::Add")
            pass
        
        self.endService("PYCALCULATOR::Add")

        return frescorba

    ## interface service: multiply two fields
    def Mul(self, field1, field2):
        self.beginService("PYCALCULATOR::Mul")

        if verbose(): 
            print("Begin of PYCALCULATOR::Mul")
            print("            field 1 : ", field1)
            print("            field 2 : ", field2)
            pass

        frescorba = None
        
        try:
            # create local fields from corba fields
            f1 = MEDCouplingFieldDoubleClient.New(field1)
            f2 = MEDCouplingFieldDoubleClient.New(field2)

            # multiply fields
            f2.changeUnderlyingMesh(f1.getMesh(), 0, 1e-12)
            fres = f1 * f2

            # create CORBA field
            frescorba = MEDCouplingFieldDoubleServant._this(fres)
            
        except Exception as e:
            if verbose(): print(e)
            pass
        
        if verbose(): 
            print("End of PYCALCULATOR::Mul")
            pass
        
        self.endService("PYCALCULATOR::Mul")

        return frescorba

    ## interface service: add a constant to a field
    def AddConstant(self, field, val):
        self.beginService("PYCALCULATOR::AddConstant")

        if verbose(): 
            print("Begin of PYCALCULATOR::AddConstant")
            print("            field    : ", field)
            print("            constant : ", val)
            pass

        frescorba = None
        
        try:
            # create local field from corba field
            f = MEDCouplingFieldDoubleClient.New(field)

            # add constant to a field
            fres = f + val

            # create CORBA field
            frescorba = MEDCouplingFieldDoubleServant._this(fres)
            
        except Exception as e:
            if verbose(): print(e)
            pass
        
        if verbose(): 
            print("End of PYCALCULATOR::AddConstant")
            pass
        
        self.endService("PYCALCULATOR::AddConstant")

        return frescorba

    ## interface service: multiply a field to a constant
    def MulConstant(self, field, val):
        self.beginService("PYCALCULATOR::MulConstant")

        if verbose(): 
            print("Begin of PYCALCULATOR::MulConstant")
            print("            field    : ", field)
            print("            constant : ", val)
            pass

        frescorba = None
        
        try:
            # create local field from corba field
            f = MEDCouplingFieldDoubleClient.New(field)

            # multiply field to a constant
            fres = f * val

            # create CORBA field
            frescorba = MEDCouplingFieldDoubleServant._this(fres)
            
        except Exception as e:
            if verbose(): print(e)
            pass
        
        if verbose(): 
            print("End of PYCALCULATOR::MulConstant")
            pass
        
        self.endService("PYCALCULATOR::MulConstant")

        return frescorba

    pass # end of class PYCALCULATOR
