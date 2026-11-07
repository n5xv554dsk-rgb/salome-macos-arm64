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
 * BatchManager_Local.hxx :
 *
 * Auteur : Ivan DUTKA-MALEN - EDF R&D
 * Mail   : mailto:ivan.dutka-malen@der.edf.fr
 * Date   : Thu Nov  6 10:17:22 2003
 * Projet : Salome 2
 *
 * Refactored by Renaud Barate (EDF R&D) in September 2009 to use
 * CommunicationProtocol classes and merge Local_SH, Local_RSH and Local_SSH batch
 * managers.
 *
 */

#ifndef _BATCHMANAGER_LOCAL_H_
#define _BATCHMANAGER_LOCAL_H_

#include "Defines.hxx"
#include "CommunicationProtocol.hxx"

#ifdef WIN32
#include <Windows.h>
#endif

#include <list>
#include <map>
#include <queue>
#include <pthread.h>
#include "Job.hxx"
#include "JobId.hxx"
#include "JobInfo.hxx"
#include "JobInfo_Local.hxx"
#include "Job_Local.hxx"
#include "BatchManager.hxx"

namespace Batch {

  class FactBatchManager;

  /*!
   *  This class defines a local pseudo batch manager that can launch jobs locally or on a remote
   *  machine with SSH or RSH. This class is NOT thread-safe.
   */
  class BATCH_EXPORT BatchManager_Local : virtual public BatchManager
  {
  private:
    typedef int Id;
#ifdef WIN32
    typedef HANDLE Process;
#else
    typedef pid_t Process;
#endif
    friend class ThreadAdapter;
    class ThreadAdapter{
    public:
      ThreadAdapter(BatchManager_Local & bm, const Job_Local & job, Id id);
      static void * run(void * arg);
      BatchManager_Local & getBatchManager() const { return _bm; };
      Id getId() const { return _id; };

    protected:
      BatchManager_Local & _bm;
      const Job_Local _job;
      Id _id;

    private:
      void pere(Process child);
#ifndef WIN32
      void fils();
#else
      Process launchWin32ChildProcess();
#endif

      /**
       * Create script to launch the remote command and copy it on the server.
       * Return the path of the remote script.
       */
      std::string buildCommandFile(const Job_Local & job);

    };

    enum Commande {
      NOP = 0,
      HOLD,
      RELEASE,
      TERM,
      KILL,
      ALTER
    };

    struct Child {
      pthread_t thread_id;
      std::queue<Commande, std::deque<Commande> > command_queue;
      pid_t pid;
      int exit_code;
      bool hasFailed;
      Parametre param;
      Environnement env;
    };



  public:

    BatchManager_Local(const Batch::FactBatchManager * parent, const char * host = "localhost",
                       const char * username = "",
                       CommunicationProtocolType protocolType = SSH, const char * mpiImpl = "nompi");
    virtual ~BatchManager_Local();

    // Recupere le nom du serveur par defaut
    // static string BatchManager_Local::getDefaultServer();

    // Methodes pour le controle des jobs
    virtual const JobId runJob(const Job & job); // soumet un job au gestionnaire
    virtual void deleteJob(const JobId & jobid); // retire un job du gestionnaire
    virtual void holdJob(const JobId & jobid); // suspend un job en file d'attente
    virtual void releaseJob(const JobId & jobid); // relache un job suspendu
    virtual JobInfo queryJob(const JobId & jobid); // renvoie l'etat du job
    virtual bool isRunning(const JobId & jobid); // teste si un job est present en machine

    virtual void setParametre(const JobId & jobid, const Parametre & param) { return alterJob(jobid, param); } // modifie un job en file d'attente
    virtual void setEnvironnement(const JobId & jobid, const Environnement & env) { return alterJob(jobid, env); } // modifie un job en file d'attente

    virtual const Batch::JobId addJob(const Batch::Job & job, const std::string & reference); // ajoute un nouveau job sans le soumettre

  protected:
    int _connect; // Local connect id
    pthread_mutex_t _threads_mutex;
    std::map<Id, Child > _threads;

  private:
    static  void kill_child_on_exit(void * p_pid);
    static  void delete_on_exit(void * arg);
    static void setFailedOnCancel(void * arg);
    pthread_cond_t _threadSyncCondition;
    Id _idCounter;

#ifdef SWIG
  public:
    // Recupere le l'identifiant d'un job deja soumis au BatchManager
    //virtual const JobId getJobIdByReference(const string & ref) { return BatchManager::getJobIdByReference(ref); }
    virtual const JobId getJobIdByReference(const char * ref) { return BatchManager::getJobIdByReference(ref); }
#endif

  };

}

#endif
