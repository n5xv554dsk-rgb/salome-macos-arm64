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
 *  FactBatchManager_Slurm.hxx :
 *
 *  Created on: 12 may 2011
 *  Author : Renaud BARATE - EDF R&D
 */

#ifndef _FACTBATCHMANAGER_ESLURM_H_
#define _FACTBATCHMANAGER_ESLURM_H_

#include <Defines.hxx>
#include <BatchManager.hxx>
#include <FactBatchManager.hxx>

namespace Batch {

  class BATCH_EXPORT FactBatchManager_Slurm : public FactBatchManager
  {
  public:

    FactBatchManager_Slurm();
    virtual ~FactBatchManager_Slurm();

    virtual BatchManager * operator() (const char * hostname,
                                       const char * username,
                                       CommunicationProtocolType protocolType,
                                       const char * mpiImpl) const;

  };

}

#endif
