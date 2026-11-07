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
// File   : HexoticPlugin_Hexotic_i.hxx
// Author : Lioka RAZAFINDRAZAKA (CEA)
// ---
//
#ifndef _HexoticPlugin_Hexotic_I_HXX_
#define _HexoticPlugin_Hexotic_I_HXX_

#include <SALOMEconfig.h>
#include CORBA_SERVER_HEADER(HexoticPlugin_Algorithm)
#include CORBA_SERVER_HEADER(SALOME_Exception)

#include "SMESH_3D_Algo_i.hxx"
#include "HexoticPlugin_Hexotic.hxx"

// ======================================================
// MG-Hexa 3d algorithm
// ======================================================
class HEXOTICPLUGIN_EXPORT HexoticPlugin_Hexotic_i:
  public virtual POA_HexoticPLUGIN::HexoticPlugin_Hexotic,
  public virtual SMESH_3D_Algo_i
{
public:
  // Constructor
  HexoticPlugin_Hexotic_i (PortableServer::POA_ptr thePOA,
                           ::SMESH_Gen*            theGenImpl );
  // Destructor
  virtual ~HexoticPlugin_Hexotic_i();

  // Get implementation
  ::HexoticPlugin_Hexotic* GetImpl();
};

#endif
