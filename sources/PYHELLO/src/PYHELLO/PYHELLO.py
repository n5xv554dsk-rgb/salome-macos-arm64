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

# ---
# File   : PYHELLOGUI.py
# Author : Vadim SANDLER, Open CASCADE S.A.S. (vadim.sandler@opencascade.com)
# ---
#
from salome.kernel import PYHELLO_ORB__POA
from salome.kernel import SALOME_ComponentPy
from salome.kernel import SALOME_Embedded_NamingService_ClientPy
from salome.kernel import SALOME_DriverPy
from salome.kernel import SALOMEDS
from PYHELLO_utils import findOrCreateComponent, objectID, moduleName, getStudy

class PYHELLO(PYHELLO_ORB__POA.PYHELLO_Gen,
              SALOME_ComponentPy.SALOME_ComponentPy_i,
              SALOME_DriverPy.SALOME_DriverPy_i):
    """
    Construct an instance of PYHELLO module engine.
    The class PYHELLO implements CORBA interface PYHELLO_Gen (see PYHELLO_Gen.idl).
    It is inherited from the classes SALOME_ComponentPy_i (implementation of
    Engines::EngineComponent CORBA interface - SALOME component) and SALOME_DriverPy_i
    (implementation of SALOMEDS::Driver CORBA interface - SALOME module's engine).
    """
    def __init__ ( self, orb, poa, contID, containerName, instanceName,
                   interfaceName ):
        SALOME_ComponentPy.SALOME_ComponentPy_i.__init__(self, orb, poa,
                    contID, containerName, instanceName, interfaceName, False)
        SALOME_DriverPy.SALOME_DriverPy_i.__init__(self, interfaceName)
        #
        emb_ns = self._contId.get_embedded_NS_if_ssl()
        import CORBA
        if CORBA.is_nil(emb_ns):
            self._naming_service = SALOME_ComponentPy.SALOME_NamingServicePy_i( self._orb )
        else:
            self._naming_service = SALOME_Embedded_NamingService_ClientPy.SALOME_Embedded_NamingService_ClientPy(emb_ns)
        pass

    """
    Get version information.
    """
    def getVersion( self ):
        from salome.kernel import salome_version
        return salome_version.getVersion("PYHELLO", True)

    """
    Generate hello banner.
    """
    def makeBanner( self, name ):
        banner = "Hello %s!" % name
        return banner

    """
    Intentionnally raises an exception for test purposes.
    """
    def raiseAnException( self ):
        from salome.kernel import SALOME_CMOD
        exData = SALOME_CMOD.ExceptionStruct( SALOME_CMOD.BAD_PARAM, "Test exception in raiseAnException()",'',0)
        raise SALOME_CMOD.SALOME_Exception( exData )

    """
    Create object.
    """
    def createObject( self, name ):
        study = getStudy()
        builder = study.NewBuilder()
        father  = findOrCreateComponent()
        obj  = builder.NewObject( father )
        attr    = builder.FindOrCreateAttribute( obj, "AttributeName" )
        attr.SetValue( name )
        attr    = builder.FindOrCreateAttribute( obj, "AttributeLocalID" )
        attr.SetValue( objectID() )
        pass

    """
    Dump module data to the Python script.
    """
    def DumpPython( self, isPublished, isMultiFile ):
        abuffer = []
        names = []
        study = getStudy()
        father = study.FindComponent( moduleName() )
        if father:
            iterator = study.NewChildIterator(father)
            while iterator.More():
                name = iterator.Value().GetName()
                if name: names.append( name )
                iterator.Next()
                pass
            pass
        if names:
            abuffer += [ "from salome.engine import salome" ]
            abuffer += [ "import PYHELLO_ORB" ]
            abuffer += [ "" ]
            abuffer += [ "pyhello = salome.lcc.FindOrLoadComponent( 'FactoryServer', '%s' )" % moduleName() ]
            abuffer += [ "" ]
            abuffer += [ "pyhello.createObject( '%s')" % name for name in names ]
            abuffer += [ "" ]
            pass
        if isMultiFile:
            abuffer = [ "  " + s for s in abuffer ]
            abuffer[0:0] = [ "def RebuildData():" ]
            abuffer += [ "    pass" ]
        abuffer += [ "\0" ]
        res = "\n".join( abuffer )
        return (res.encode(), 1)
