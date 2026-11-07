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
 * FactBatchManager_Local.hxx : 
 *
 * Auteur : Ivan DUTKA-MALEN - EDF R&D
 * Date   : Septembre 2004
 * Projet : SALOME 2
 *
 * Refactored by Renaud Barate (EDF R&D) in September 2009 to use
 * CommunicationProtocol classes and merge Local_SH, Local_RSH and Local_SSH batch
 * managers.
 *
 */

#ifndef _FACTBATCHMANAGER_LOCAL_H_
#define _FACTBATCHMANAGER_LOCAL_H_

#include "FactBatchManager.hxx"
#include "CommunicationProtocol.hxx"

namespace Batch {
  
  class FactBatchManager_Local : public FactBatchManager
  {
  public:

    FactBatchManager_Local();
    virtual ~FactBatchManager_Local();

    virtual BatchManager * operator() (const char * hostname,
                                       const char * username = "",
                                       CommunicationProtocolType protocolType = SSH,
                                       const char * mpi = "nompi") const;

  };

}

#endif
