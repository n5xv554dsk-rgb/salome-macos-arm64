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
 * BatchManager_PBS.hxx : emulation of PBS client
 *
 * Auteur : Bernard SECHER - CEA DEN
 * Mail   : mailto:bernard.secher@cea.fr
 * Date   : Thu Apr 24 10:17:22 2008
 * Projet : PAL Salome
 *
 */

#ifndef _BATCHMANAGER_EPBS_H_
#define _BATCHMANAGER_EPBS_H_

#include "Defines.hxx"
#include "JobId.hxx"
#include "JobInfo.hxx"
#include "FactBatchManager.hxx"
#include "BatchManager.hxx"

namespace Batch {

  class BATCH_EXPORT BatchManager_PBS : public BatchManager
  {
  public:
    // Constructeur et destructeur
    BatchManager_PBS(const FactBatchManager * parent, const char * host="localhost",
                      const char * username="",
                      CommunicationProtocolType protocolType = SSH, const char * mpiImpl="nompi");
    virtual ~BatchManager_PBS();

    // Recupere le nom du serveur par defaut
    // static string BatchManager_LSF::getDefaultServer();

    // Methodes pour le controle des jobs
    virtual const JobId runJob(const Job & job); // soumet un job au gestionnaire
    virtual void deleteJob(const JobId & jobid); // retire un job du gestionnaire
    virtual JobInfo queryJob(const JobId & jobid); // renvoie l'etat du job
    virtual bool isRunning(const JobId & jobid); // teste si un job est present en machine

    virtual void setParametre(const JobId & jobid, const Parametre & param) { return alterJob(jobid, param); } // modifie un job en file d'attente
    virtual void setEnvironnement(const JobId & jobid, const Environnement & env) { return alterJob(jobid, env); } // modifie un job en file d'attente

  protected:
    std::string buildSubmissionScript(const Job & job);

#ifdef SWIG
  public:
    // Recupere le l'identifiant d'un job deja soumis au BatchManager
    //virtual const JobId getJobIdByReference(const string & ref) { return BatchManager::getJobIdByReference(ref); }
    virtual const JobId getJobIdByReference(const char * ref) { return BatchManager::getJobIdByReference(ref); }
#endif

  };

}

#endif
