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

#pragma once

#include "HOMARD_Gen_i.hxx"

class HOMARDENGINE_EXPORT HOMARD_Gen_i_Session : public HOMARD_Gen_i
{
public:
  HOMARD_Gen_i_Session( CORBA::ORB_ptr orb,
                        PortableServer::POA_ptr poa,
                        PortableServer::ObjectId* contId,
                        const char* instanceName,
                        const char* interfaceName );
  SALOME_ModuleCatalog::ModuleCatalog_var getModuleCatalog() const override;
  SMESH::SMESH_Gen_var retrieveSMESHInst() const override;
private:
  SALOME_NamingService*         _NS = nullptr;
};
