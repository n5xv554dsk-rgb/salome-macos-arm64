// Copyright (C) 2012-2021  INRIA
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

#ifndef _BATCHMANAGER_OAR_H_
#define _BATCHMANAGER_OAR_H_

#include "Defines.hxx"
#include "JobId.hxx"
#include "JobInfo.hxx"
#include "FactBatchManager.hxx"
#include "BatchManager.hxx"

namespace Batch
{
  class BATCH_EXPORT BatchManager_OAR : public BatchManager
  {
    public:
      // Constructeur
      BatchManager_OAR(const FactBatchManager * parent, const char * host="localhost",
                      const char * username="",
                      CommunicationProtocolType protocolType = SSH, const char * mpiImpl="nompi");

      // Destructeur
      virtual ~BatchManager_OAR();

      // Soumet un job
      virtual const JobId runJob(const Job & job);

      // Supprime un job
      virtual void deleteJob(const JobId & jobid);

      // Donne l'etat du job
      virtual JobInfo queryJob(const JobId & jobid);

      // Modifie un job en file d'attente
      virtual void setParametre(const JobId & jobid, const Parametre & param) { return alterJob(jobid, param); }

      // Modifie un job en file d'attente
      virtual void setEnvironnement(const JobId & jobid, const Environnement & env) { return alterJob(jobid, env); }

    protected:
      std::string buildBatchScript(const Job & job);
      std::string convertSecTo_H_M_S(long seconds) const;

#ifdef SWIG
    public:
      // Recupere l'identifiant d'un job deja soumis au BatchManager
      virtual const JobId getJobIdByReference(const char * ref) { return BatchManager::getJobIdByReference(ref); }
#endif
  };
}

#endif
