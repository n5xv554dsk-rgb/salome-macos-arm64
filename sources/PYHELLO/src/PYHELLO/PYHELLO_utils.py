# Copyright (C) 2007-2026  CEA, EDF, OPEN CASCADE
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
# File   : PYHELLO_utils.py
# Author : Vadim SANDLER, Open CASCADE S.A.S. (vadim.sandler@opencascade.com)
# ---
#
__all__ = [
    "moduleID",
    "objectID",
    "unknownID",
    "moduleName",
    "modulePixmap",
    "verbose",
    "getORB",
    "getLCC",
    "getEngine",
    "getStudy",
    "getEngineIOR",
    "findOrCreateComponent",
    "getObjectID",
    ]


#from omniORB import CORBA
#from salome.kernel.SALOME_NamingServicePy import SALOME_NamingServicePy_i
#from salome.kernel.LifeCycleCORBA import LifeCycleCORBA
#
import salome.kernel.SALOMEDS
#import salome.kernel.SALOMEDS_Attributes_idl
from salome.kernel import PYHELLO_ORB
import os

###
# Get PYHELLO module's ID
###
def moduleID():
    MODULE_ID = 1000
    return MODULE_ID

###
# Get PYHELLO object's ID
###
def objectID():
    OBJECT_ID = 1010
    return OBJECT_ID

###
# Get unknown ID
###
def unknownID():
    FOREIGN_ID = -1
    return FOREIGN_ID

###
# Get PYHELLO module's name
###
def moduleName():
    return "PYHELLO"

###
# Get module's pixmap name
###
def modulePixmap():
    return "PYHELLO_small.png"

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
def getORB():
    from salome.kernel import salome
    salome.salome_init()
    return salome.orb

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
# Get PYHELLO engine
###
__engine__ = None
def getEngine():
    global __engine__
    if __engine__ is None:
        __engine__ = getLCC().FindOrLoadComponent( "FactoryServer", moduleName() )
        pass
    return __engine__

###
# Get PYHELLO engine IOR
###
def getEngineIOR():
    IOR = ""
    if getORB() and getEngine():
        IOR = getORB().object_to_string( getEngine() )
        pass
    return IOR

###
# Find or create PYHELLO component object in a study
###
def findOrCreateComponent():
    study = getStudy()
    father =study.FindComponent( moduleName() )
    if father is None:
        builder = study.NewBuilder()
        father = builder.NewComponent( moduleName() )
        attr = builder.FindOrCreateAttribute( father, "AttributeName" )
        attr.SetValue( moduleName() )
        attr = builder.FindOrCreateAttribute( father, "AttributePixMap" )
        attr.SetPixMap( modulePixmap() )
        attr = builder.FindOrCreateAttribute( father, "AttributeLocalID" )
        attr.SetValue( moduleID() )
        try:
            builder.DefineComponentInstance( father, getEngine() )
            pass
        except:
            pass
        pass
    return father

###
# Get object's ID
###
def getObjectID( entry ):
    ID = unknownID()
    study = getStudy()
    if entry:
        sobj = study.FindObjectID( entry )
        if sobj is not None:
            test, anAttr = sobj.FindAttribute( "AttributeLocalID" )
            if test: ID = anAttr._narrow( salome.kernel.SALOMEDS.AttributeLocalID ).Value()
            pass
        pass
    return ID
    
