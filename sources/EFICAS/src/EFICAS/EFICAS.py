# Copyright (C) 2001-2026  EDF R&D
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
# -*- coding: utf-8 -*-

import EFICAS_ORB__POA
import SALOMEDS__POA
from salome.kernel import SALOME_ComponentPy
from salome.kernel import SALOME_Embedded_NamingService_ClientPy

class SALOME_DriverPy_i(SALOMEDS__POA.Driver):
    """
    Python implementation of generic SALOMEDS driver.
    Should be inherited by any Python module's engine
    to provide persistence mechanism.
    """
    def __init__ (self, componentDataType):
        print ("SALOME_DriverPy.__init__: ", componentDataType)
        self._ComponentDataType = componentDataType

    def IORToLocalPersistentID(self, theSObject, IORString, isMultiFile, isASCII):
        return theSObject.GetID()

    def LocalPersistentIDToIOR(self, theSObject, PersistentID, isMultiFile, isASCII):
        return ""

    def ComponentDataType(self):
        return self._ComponentDataType

    def Save(self, theComponent, theURL, isMultiFile):
        return 'Rien'

    def SaveASCII(self, theComponent, theURL, isMultiFile):
        return self.Save(theComponent, theURL, isMultiFile)

    def Load(self, theComponent, theStream, theURL, isMultiFile):
        return 1

    def LoadASCII(self, theComponent, theStream, theURL, isMultiFile):
        return self.Load(theComponent, theStream, theURL, isMultiFile)

    def Close(self, theComponent):
        pass

    def CanPublishInStudy(self, theIOR):
        return 0

    def PublishInStudy(self, theStudy, theSObject, theObject, theName):
        return None

    def CanCopy(self, theObject):
        return 0



class EFICAS(EFICAS_ORB__POA.EFICAS_Gen,
        SALOME_ComponentPy.SALOME_ComponentPy_i,
        SALOME_DriverPy_i ):
    """
        Pour etre un composant SALOME cette classe Python
        doit avoir le nom du composant et heriter de la
        classe EFICAS_Gen issue de la compilation de l'idl
        par omniidl et de la classe SALOME_ComponentPy_i
        qui porte les services generaux d'un composant SALOME
    """
    def __init__ (self, orb, poa, contID, containerName, instanceName, 
                  interfaceName):
        print ("EFICAS.__init__: ", containerName,' ', instanceName)
        SALOME_ComponentPy.SALOME_ComponentPy_i.__init__(self, orb, poa,
                    contID, containerName,instanceName, interfaceName )
        SALOME_DriverPy_i.__init__( self, 'OTHER' )                    
        # On stocke dans l'attribut _naming_service, une reference sur
        # le Naming Service CORBA
        #
        emb_ns = self._contId.get_embedded_NS_if_ssl()
        import CORBA
        if CORBA.is_nil(emb_ns):
            self._naming_service = SALOME_ComponentPy.SALOME_NamingServicePy_i( self._orb )
        else:
            self._naming_service = SALOME_Embedded_NamingService_ClientPy.SALOME_Embedded_NamingService_ClientPy(emb_ns)
        #
