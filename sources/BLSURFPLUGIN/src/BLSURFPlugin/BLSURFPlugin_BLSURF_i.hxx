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
// File    : BLSURFPlugin_BLSURF_i.hxx
// Authors : Francis KLOSS (OCC) & Patrick LAUG (INRIA)
// ---
//
#ifndef _BLSURFPlugin_BLSURF_I_HXX_
#define _BLSURFPlugin_BLSURF_I_HXX_

#include <SALOMEconfig.h>
#include CORBA_SERVER_HEADER(BLSURFPlugin_Algorithm)

#include "SMESH_2D_Algo_i.hxx"
#include "BLSURFPlugin_BLSURF.hxx"

// ======================================================
// BLSUF 2d algorithm
// ======================================================
class BLSURFPlugin_BLSURF_i:
  public virtual POA_BLSURFPlugin::BLSURFPlugin_BLSURF,
  public virtual SMESH_2D_Algo_i
{
public:
  // Constructor
  BLSURFPlugin_BLSURF_i( PortableServer::POA_ptr thePOA,
                         ::SMESH_Gen*            theGenImpl,
                         bool                    theHasGEOM);
  // Destructor
  virtual ~BLSURFPlugin_BLSURF_i();
 
  // Get implementation
  ::BLSURFPlugin_BLSURF* GetImpl();
};

#endif
