// Copyright (C) 2007-2021  CEA/DEN, EDF R&D, OPEN CASCADE
//
// Copyright (C) 2003-2007  OPEN CASCADE, EADS/CCR, LIP6, CEA/DEN,
// CEDRAT, EDF R&D, LEG, PRINCIPIA R&D, BUREAU VERITAS
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
/*
 *  FactBatchManager_LL.cxx :
 *
 *  Created on: 25 nov. 2010
 *  Author : Renaud BARATE - EDF R&D
 */

#include "ParameterTypeMap.hxx"
#include "BatchManager_LL.hxx"
#include "FactBatchManager_LL.hxx"

namespace Batch {

  def_Constant(LL_JOBTYPE);

  static FactBatchManager_LL sFBM_LL;

  FactBatchManager_LL::FactBatchManager_LL() : FactBatchManager("LL")
  {
    // Add specific parameters
    ParameterTypeMap::getInstance().addParameter(LL_JOBTYPE, STRING, 1);
  }

  FactBatchManager_LL::~FactBatchManager_LL()
  {
    // Nothing to do
  }

  BatchManager * FactBatchManager_LL::operator() (const char * hostname,
                                                   const char * username,
                                                   CommunicationProtocolType protocolType,
                                                   const char * mpiImpl) const
  {
    // MESSAGE("Building new BatchManager_LL on host '" << hostname << "'");
    return new BatchManager_LL(this, hostname, username, protocolType, mpiImpl);
  }

}
