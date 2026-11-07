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
 * BatchManager.hxx : 
 *
 * Auteur : Ivan DUTKA-MALEN - EDF R&D
 * Date   : Septembre 2003
 * Projet : SALOME 2
 *
 */

#ifndef _BATCHMANAGER_H_
#define _BATCHMANAGER_H_

#include "Defines.hxx"

#include <string>
#include <map>
#include "Job.hxx"
#include "JobId.hxx"
#include "JobInfo.hxx"
#include "InvalidArgumentException.hxx"
#include "CommunicationProtocol.hxx"
#include "MpiImpl.hxx"

namespace Batch {

  class Job;
  class JobId;
  class JobInfo;
  class FactBatchManager;

  class BATCH_EXPORT BatchManager
  {
  public:
    // Constructeur et destructeur
    BatchManager(const Batch::FactBatchManager * parent, const char * host = "localhost",
                 const char * username = "",
                 CommunicationProtocolType protocolType = SSH, const char * mpiImpl = "nompi");
    virtual ~BatchManager();
    virtual std::string __repr__() const;

    // Recupere le l'identifiant d'un job deja soumis au BatchManager
    //virtual const JobId getJobIdByReference(const std::string & ref);
    virtual const Batch::JobId getJobIdByReference(const char * ref);

    // Methodes pour le controle des jobs : doivent etre implementees dans les classes filles
    virtual const Batch::JobId submitJob(const Batch::Job & job); // soumet un job au gestionnaire
    virtual void deleteJob(const Batch::JobId & jobid); // retire un job du gestionnaire
    virtual void holdJob(const Batch::JobId & jobid); // suspend un job en file d'attente
    virtual void releaseJob(const Batch::JobId & jobid); // relache un job suspendu
    virtual void alterJob(const Batch::JobId & jobid, const Batch::Parametre & param, const Batch::Environnement & env); // modifie un job en file d'attente
    virtual void alterJob(const Batch::JobId & jobid, const Batch::Parametre & param); // modifie un job en file d'attente
    virtual void alterJob(const Batch::JobId & jobid, const Batch::Environnement & env); // modifie un job en file d'attente
    virtual Batch::JobInfo queryJob(const Batch::JobId & jobid); // renvoie l'etat du job
    virtual const Batch::JobId addJob(const Batch::Job & job, const std::string & reference); // ajoute un nouveau job sans le soumettre
    virtual std::string waitForJobEnd(const Batch::JobId & jobid, long timeout = -1,
                                      long initSleepTime = 1, long maxSleepTime = 600);
    virtual void importOutputFiles( const Job & job, const std::string directory );
    bool importDumpStateFile( const Job & job, const std::string directory );
    // copier le fichier work_file à partir du working_directory vers directory
    virtual bool importWorkFile( const Job & job, const std::string& work_file, const std::string& directory );
    virtual void clearWorkingDir( const Job & job );

    // Get the underlying communication protocol
    const CommunicationProtocol & getProtocol() const;
    virtual void exportInputFiles(const Job & job);

  protected:
    std::string _hostname; // serveur ou tourne le BatchManager
    // std::map< const std::string, const Batch::JobId * > jobid_map; // table des jobs deja soumis
    std::map< std::string, const Batch::JobId * > jobid_map; // table des jobs deja soumis
    const std::string & _type;
    const CommunicationProtocol & _protocol; // protocol to access _hostname
    const std::string _username; // username to access _hostname
    MpiImpl *_mpiImpl; // Mpi implementation to launch executable in batch script

    MpiImpl* FactoryMpiImpl(std::string mpiImpl);
    
    // Preprocessing done on the frontal using "PREPROCESS" parameter as a script.
    // May throw exceptions in case of failure.
    virtual void preprocess(const Batch::Job & job);
    
    // Submit to batch manager, but we suppose input files are already copied
    // and preprocess finished without error
    virtual const Batch::JobId runJob(const Batch::Job & job);

  private:

  };

}

#endif
