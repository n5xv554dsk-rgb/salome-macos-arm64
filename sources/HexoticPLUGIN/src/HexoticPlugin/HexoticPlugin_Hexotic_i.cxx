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
// File   : HexoticPlugin_Hexotic_i.cxx
// Author : Lioka RAZAFINDRAZAKA (CEA)
// ---
//
#include "HexoticPlugin_Hexotic_i.hxx"
#include "SMESH_Gen.hxx"
#include "HexoticPlugin_Hexotic.hxx"

#include "Utils_CorbaException.hxx"
#include "utilities.h"

//=============================================================================
/*!
 *  HexoticPlugin_Hexotic_i::HexoticPlugin_Hexotic_i
 *
 *  Constructor
 */
//=============================================================================

HexoticPlugin_Hexotic_i::HexoticPlugin_Hexotic_i( PortableServer::POA_ptr thePOA,
                                                  ::SMESH_Gen*            theGenImpl )
     : SALOME::GenericObj_i( thePOA ), 
       SMESH_Hypothesis_i( thePOA ), 
       SMESH_Algo_i( thePOA ),
       SMESH_3D_Algo_i( thePOA )
{
  MESSAGE( "HexoticPlugin_Hexotic_i::HexoticPlugin_Hexotic_i" );
  myBaseImpl = new ::HexoticPlugin_Hexotic( theGenImpl->GetANewId(),
                                            theGenImpl );
}

//=============================================================================
/*!
 *  HexoticPlugin_Hexotic_i::~HexoticPlugin_Hexotic_i
 *
 *  Destructor
 */
//=============================================================================

HexoticPlugin_Hexotic_i::~HexoticPlugin_Hexotic_i()
{
  MESSAGE( "HexoticPlugin_Hexotic_i::~HexoticPlugin_Hexotic_i" );
}

//=============================================================================
/*!
 *  HexoticPlugin_Hexotic_i::GetImpl
 *
 *  Get implementation
 */
//=============================================================================

::HexoticPlugin_Hexotic* HexoticPlugin_Hexotic_i::GetImpl()
{
  MESSAGE( "HexoticPlugin_Hexotic_i::GetImpl" );
  return ( ::HexoticPlugin_Hexotic* )myBaseImpl;
}
