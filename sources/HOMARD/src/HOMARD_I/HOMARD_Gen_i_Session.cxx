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

#include "HOMARD_Gen_i_Session.hxx"
#include "SALOMEDS_Study_i.hxx"
#include "SALOME_KernelServices.hxx"
#include "Utils_SINGLETON.hxx"

HOMARD_Gen_i_Session::HOMARD_Gen_i_Session( CORBA::ORB_ptr orb, PortableServer::POA_ptr poa, PortableServer::ObjectId* contId, const char* instanceName, const char* interfaceName ):
HOMARD_Gen_i(orb,poa,contId,instanceName,interfaceName,true)
{
    myStudy = SALOMEDS::Study::_duplicate(KERNEL::getStudyServant()); 
    _NS = SINGLETON_<SALOME_NamingService>::Instance();
    ASSERT(SINGLETON_<SALOME_NamingService>::IsAlreadyExisting());
    _NS->init_orb(_orb);
}

SALOME_ModuleCatalog::ModuleCatalog_var HOMARD_Gen_i_Session::getModuleCatalog() const
{
    CORBA::Object_var objVarN = _NS->Resolve("/Kernel/ModulCatalog");
    SALOME_ModuleCatalog::ModuleCatalog_var Catalogue = SALOME_ModuleCatalog::ModuleCatalog::_narrow(objVarN);
    return Catalogue;
}

SMESH::SMESH_Gen_var HOMARD_Gen_i_Session::retrieveSMESHInst() const
{
    SALOME_LifeCycleCORBA* myLCC = new SALOME_LifeCycleCORBA(_NS);
    SMESH::SMESH_Gen_var aSmeshEngine = SMESH::SMESH_Gen::_narrow(myLCC->FindOrLoad_Component("FactoryServer","SMESH"));
    return aSmeshEngine;
}

//=============================================================================
#include "HOMARD_Gen_i_No_Session.hxx"
extern "C"
{
  HOMARDENGINE_EXPORT
  PortableServer::ObjectId* HOMARDEngine_factory(CORBA::ORB_ptr orb,
						  PortableServer::POA_ptr poa,
						  PortableServer::ObjectId* contId,
						  const char* instanceName,
						  const char* interfaceName)
  {
    MESSAGE("PortableServer::ObjectId* HOMARDEngine_factory()");
    CORBA::Object_var o = poa->id_to_reference(*contId);
    Engines::Container_var cont = Engines::Container::_narrow(o);
    if(cont->is_SSL_mode())
    {
      HOMARD_Gen_i_No_Session* myHOMARD_Gen = new HOMARD_Gen_i_No_Session(orb, poa, contId, instanceName, interfaceName);
      return myHOMARD_Gen->getId();
    }
    else
    {
      HOMARD_Gen_i_Session* myHOMARD_Gen = new HOMARD_Gen_i_Session(orb, poa, contId, instanceName, interfaceName);
      return myHOMARD_Gen->getId();
    }
  }
}
