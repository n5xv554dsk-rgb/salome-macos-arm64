// Copyright (C) 2007-2026  CEA, EDF
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

// ---
// File   : HYBRIDPlugin_HYBRID_i.hxx
// Author : Christian VAN WAMBEKE (CEA)
// ---
//
#ifndef _HYBRIDPlugin_HYBRID_I_HXX_
#define _HYBRIDPlugin_HYBRID_I_HXX_

#include "HYBRIDPlugin_Defs.hxx"

#include <SALOMEconfig.h>
#include CORBA_SERVER_HEADER(HYBRIDPlugin_Algorithm)
#include CORBA_SERVER_HEADER(SALOME_Exception)

#include "SMESH_3D_Algo_i.hxx"
#include "HYBRIDPlugin_HYBRID.hxx"

// ======================================================
// HYBRID 3d algorithm
// ======================================================
class HYBRIDPlugin_HYBRID_i:
  public virtual POA_HYBRIDPlugin::HYBRIDPlugin_HYBRID,
  public virtual SMESH_3D_Algo_i
{
public:
  // Constructor
  HYBRIDPlugin_HYBRID_i (PortableServer::POA_ptr thePOA,
                         ::SMESH_Gen*            theGenImpl );
  // Destructor
  virtual ~HYBRIDPlugin_HYBRID_i();

  // Get implementation
  ::HYBRIDPlugin_HYBRID* GetImpl();

  virtual SMESH::SMESH_Mesh_ptr importGMFMesh(const char* theGMFFileName);
};

#endif
