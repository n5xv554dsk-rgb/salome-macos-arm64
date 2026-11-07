// Copyright (C) 2021-2026  CEA, EDF
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
//
// See http://www.salome-platform.org/ or email : webmaster.salome@opencascade.com
//

#include "HOMARD_Gen_i_No_Session.hxx"
#include "SALOMEDS_Study_i.hxx"
#include "SALOME_ModuleCatalog_impl.hxx"
#include "SMESH_Gen_No_Session_i.hxx"

HOMARD_Gen_i_No_Session::HOMARD_Gen_i_No_Session( CORBA::ORB_ptr orb, PortableServer::POA_ptr poa, PortableServer::ObjectId* contId, const char* instanceName, const char* interfaceName ):
HOMARD_Gen_i(orb,poa,contId,instanceName,interfaceName,false)
{
    myStudy = KERNEL::getStudyServantSA();
    SMESH_Gen_No_Session_i *servant = new SMESH_Gen_No_Session_i(orb,poa,contId,"SMESH_inst_3","SMESH");
    PortableServer::ObjectId *zeId = servant->getId();
    CORBA::Object_var zeRef = poa->id_to_reference(*zeId);
    _smesh = SMESH::SMESH_Gen::_narrow(zeRef);
}

SALOME_ModuleCatalog::ModuleCatalog_var HOMARD_Gen_i_No_Session::getModuleCatalog() const
{
  SALOME_ModuleCatalog::ModuleCatalog_var aCat = KERNEL::getModuleComponentServantSA();
  return aCat;
}

SMESH::SMESH_Gen_var HOMARD_Gen_i_No_Session::retrieveSMESHInst() const
{
    return _smesh;
}
