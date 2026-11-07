# Copyright (C) 2019-2026  CEA, EDF
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

# ---
# File   : SHAPERSTUDY_utils.py
# Author : Vadim SANDLER, Open CASCADE S.A.S. (vadim.sandler@opencascade.com)
# ---
#
__all__ = [
    #"moduleID",
    #"objectID",
    #"unknownID",
    "moduleName",
    "modulePixmap",
    "verbose",
    "getORB",
    "getNS",
    "getLCC",
    "getEngine",
    "getStudy",
    "getEngineIOR",
    "findOrCreateComponent",
    "getObjectID",
    ]


from omniORB import CORBA
from salome.kernel.SALOME_NamingServicePy import SALOME_NamingServicePy_i
from salome.kernel.LifeCycleCORBA import LifeCycleCORBA
from salome.kernel import SALOMEDS
from salome.kernel import SALOMEDS_Attributes_idl
from salome.kernel import SHAPERSTUDY_ORB
import os
   
###
# Get SHAPERSTUDY module's name
###
def moduleName():
    return "SHAPERSTUDY"

###
# Get module's pixmap name
###
def modulePixmap():
    return "shaper.png"

###
# Get verbose level
### 
__verbose__ = None
def verbose():
    global __verbose__
    if __verbose__ is None:
        try:
            __verbose__ = int( os.getenv( 'SALOME_VERBOSE', 0 ) )
        except:
            __verbose__ = 0
            pass
        pass
    return __verbose__

###
# Get ORB reference
###
__orb__ = None
def getORB():
    from salome.kernel import salome
    salome.salome_init()
    global __orb__
    if __orb__ is None:
        __orb__ = CORBA.ORB_init( [''], CORBA.ORB_ID )
        pass
    return __orb__

###
# Get POA
###
__poa__ = None
def getPOA():
    global __poa__
    if __poa__ is None:
        from salome.kernel import salome
        salome.salome_init()
        __poa__ = salome.orb.resolve_initial_references("RootPOA")
        pass
    return __poa__

###
# Get naming service instance
###
def getNS():
    from salome.kernel import salome
    salome.salome_init()
    return salome.naming_service

##
# Get life cycle CORBA instance
##
def getLCC():
    from salome.kernel import salome
    salome.salome_init()
    return salome.lcc

##
# Get study
###

def getStudy():
    from salome.kernel import salome
    salome.salome_init()
    return salome.myStudy

###
# Get SHAPERSTUDY engine
###
__engine__ = None
def getEngine():
    global __engine__
    if __engine__ is None:
        from salome.kernel import salome
        salome.salome_init()
        __engine__ = salome.lcc.FindOrLoadComponent( "FactoryServer", moduleName() )
        pass
    return __engine__

###
# Get SHAPERSTUDY engine IOR
###
def getEngineIOR():
    IOR = ""
    if getORB() and getEngine():
        IOR = getORB().object_to_string( getEngine() )
        pass
    return IOR

###
# Find or create SHAPERSTUDY component object in a study
###
def findOrCreateComponent():
    study = getStudy()
    builder = study.NewBuilder()
    father = study.FindComponent( moduleName() )
    if father is None:
        father = builder.NewComponent( moduleName() )
        attr = builder.FindOrCreateAttribute( father, "AttributeName" )
        attr.SetValue( "ShaperResults" )
        attr = builder.FindOrCreateAttribute( father, "AttributePixMap" )
        attr.SetPixMap( modulePixmap() )
        #attr = builder.FindOrCreateAttribute( father, "AttributeLocalID" )
        #attr.SetValue( moduleID() )
        try:
            builder.DefineComponentInstance( father, getEngine() )
            pass
        except:
            pass
        pass
    # load the SHAPER-STUDY file if it is not done yet
    builder.LoadWith(father, getEngine())
    return father

