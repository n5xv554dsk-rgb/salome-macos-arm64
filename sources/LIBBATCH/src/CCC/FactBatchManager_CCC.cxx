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
 * FactBatchManager_CCC.cxx : 
 *
 * Auteur : Bernard SECHER - CEA DEN
 * Date   : Avril 2010
 * Projet : PAL Salome
 *
 */

#include "BatchManager_CCC.hxx"
#include "FactBatchManager_CCC.hxx"

namespace Batch {

  static FactBatchManager_CCC sFBM_CCC;

  // Constructeur
  FactBatchManager_CCC::FactBatchManager_CCC() : FactBatchManager("CCC")
  {
    // Nothing to do
  }

  // Destructeur
  FactBatchManager_CCC::~FactBatchManager_CCC()
  {
    // Nothing to do
  }

  BatchManager * FactBatchManager_CCC::operator() (const char * hostname,
                                                    const char * username,
                                                    CommunicationProtocolType protocolType,
                                                    const char * mpiImpl) const
  {
    // MESSAGE("Building new BatchManager_CCC on host '" << hostname << "'");
    return new BatchManager_CCC(this, hostname, username, protocolType, mpiImpl);
  }

}
