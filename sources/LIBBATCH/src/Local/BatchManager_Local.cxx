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
* BatchManager_Local.cxx :
*
* Auteur : Ivan DUTKA-MALEN - EDF R&D
* Mail   : mailto:ivan.dutka-malen@der.edf.fr
* Date   : Thu Nov  6 10:17:22 2003
* Projet : Salome 2
*
* Refactored by Renaud Barate (EDF R&D) in September 2009 to use
* CommunicationProtocol classes and merge Local_SH, Local_RSH and Local_SSH batch
* managers.
*/

#include <iostream>
#include <fstream>
#include <sstream>
#include <cstdlib>
#include <limits.h>

#include <sys/types.h>
#ifdef WIN32
#include <direct.h>
#else
#include <sys/wait.h>
#include <unistd.h>
#endif
#include <ctime>
#include <pthread.h>
#include <signal.h>
#include <errno.h>
#include <string.h>

#include "Constants.hxx"
#include "IOMutex.hxx"
#include "BatchManager_Local.hxx"
#include "RunTimeException.hxx"
#include "Utils.hxx"
#include "Log.hxx"

using namespace std;

namespace Batch {


  // Constructeur
  BatchManager_Local::BatchManager_Local(const Batch::FactBatchManager * parent, const char * host,
                                         const char * username,
                                         CommunicationProtocolType protocolType, const char * mpiImpl)
    : BatchManager(parent, host, username, protocolType, mpiImpl), _connect(0),
      _idCounter(0)
  {
    pthread_mutex_init(&_threads_mutex, NULL);
    pthread_cond_init(&_threadSyncCondition, NULL);
  }

  // Destructeur
  BatchManager_Local::~BatchManager_Local()
  {
    for (map<Id, Child>::iterator iter = _threads.begin() ; iter != _threads.end() ; iter++) {
      pthread_mutex_lock(&_threads_mutex);
      string state = iter->second.param[STATE];
      if (state != FINISHED && state != FAILED) {
        UNDER_LOCK( LOG("Warning: Job " << iter->first <<
                        " is not finished, it will now be canceled."));
        pthread_cancel(iter->second.thread_id);
        pthread_cond_wait(&_threadSyncCondition, &_threads_mutex);
      }
      pthread_mutex_unlock(&_threads_mutex);
    }
    pthread_mutex_destroy(&_threads_mutex);
    pthread_cond_destroy(&_threadSyncCondition);
  }

  // Methode pour le controle des jobs : soumet un job au gestionnaire
  const JobId BatchManager_Local::runJob(const Job & job)
  {
    Job_Local jobLocal = job;
    Id id = _idCounter++;
    ThreadAdapter * p_ta = new ThreadAdapter(*this, job, id);

    // Les attributs du thread a sa creation
    pthread_attr_t thread_attr;
    pthread_attr_init(&thread_attr);
    pthread_attr_setdetachstate(&thread_attr, PTHREAD_CREATE_DETACHED);

    // Creation du thread qui va executer la commande systeme qu'on lui passe
    pthread_t thread_id;
    pthread_mutex_lock(&_threads_mutex);
    int rc = pthread_create(&thread_id,
      &thread_attr,
      &ThreadAdapter::run,
      static_cast<void *>(p_ta));

    // Liberation des zones memoire maintenant inutiles occupees par les attributs du thread
    pthread_attr_destroy(&thread_attr);

    if (rc != 0) {
      pthread_mutex_unlock(&_threads_mutex);
      throw RunTimeException("Can't create new thread in BatchManager_Local");
    }

    pthread_cond_wait(&_threadSyncCondition, &_threads_mutex);
    pthread_mutex_unlock(&_threads_mutex);

    ostringstream id_sst;
    id_sst << id;
    return JobId(this, id_sst.str());
  }

  // Methode pour le controle des jobs : retire un job du gestionnaire
  void BatchManager_Local::deleteJob(const JobId & jobid)
  {
    Id id;

    istringstream iss(jobid.getReference());
    iss >> id;

    // @@@ --------> SECTION CRITIQUE <-------- @@@
    pthread_mutex_lock(&_threads_mutex);
    bool idFound = (_threads.find(id) != _threads.end());
    if (idFound) {
      string state = _threads[id].param[STATE];
      if (state != FINISHED && state != FAILED) {
        pthread_cancel(_threads[id].thread_id);
        pthread_cond_wait(&_threadSyncCondition, &_threads_mutex);
      } else {
        LOG("Cannot delete job " << jobid.getReference() << ". Job is already finished.");
      }
    }
    pthread_mutex_unlock(&_threads_mutex);
    // @@@ --------> SECTION CRITIQUE <-------- @@@

    if (!idFound)
      throw RunTimeException(string("Job with id ") + jobid.getReference() + " does not exist");
  }

  // Methode pour le controle des jobs : suspend un job en file d'attente
  void BatchManager_Local::holdJob(const JobId & jobid)
  {
    Id id;
    istringstream iss(jobid.getReference());
    iss >> id;

    UNDER_LOCK( LOG("BatchManager is sending HOLD command to the thread " << id) );

    // On introduit une commande dans la queue du thread
    // @@@ --------> SECTION CRITIQUE <-------- @@@
    pthread_mutex_lock(&_threads_mutex);
    if (_threads.find(id) != _threads.end())
      _threads[id].command_queue.push(HOLD);
    pthread_mutex_unlock(&_threads_mutex);
    // @@@ --------> SECTION CRITIQUE <-------- @@@
  }

  // Methode pour le controle des jobs : relache un job suspendu
  void BatchManager_Local::releaseJob(const JobId & jobid)
  {
    Id id;
    istringstream iss(jobid.getReference());
    iss >> id;

    UNDER_LOCK( LOG("BatchManager is sending RELEASE command to the thread " << id) );

    // On introduit une commande dans la queue du thread
    // @@@ --------> SECTION CRITIQUE <-------- @@@
    pthread_mutex_lock(&_threads_mutex);
    if (_threads.find(id) != _threads.end())
      _threads[id].command_queue.push(RELEASE);
    pthread_mutex_unlock(&_threads_mutex);
    // @@@ --------> SECTION CRITIQUE <-------- @@@
  }

  // Methode pour le controle des jobs : renvoie l'etat du job
  JobInfo BatchManager_Local::queryJob(const JobId & jobid)
  {
    Id id;
    istringstream iss(jobid.getReference());
    iss >> id;

    Parametre param;
    Environnement env;

    //UNDER_LOCK( cout << "JobInfo BatchManager_Local::queryJob(const JobId & jobid) : AVANT section critique" << endl );
    // @@@ --------> SECTION CRITIQUE <-------- @@@
    pthread_mutex_lock(&_threads_mutex);
    std::map<Id, Child >::iterator pos = _threads.find(id);
    bool found = (pos != _threads.end());
    if (found) {
      param = pos->second.param;
      env   = pos->second.env;
    }
    pthread_mutex_unlock(&_threads_mutex);
    // @@@ --------> SECTION CRITIQUE <-------- @@@
    //UNDER_LOCK( cout << "JobInfo BatchManager_Local::queryJob(const JobId & jobid) : APRES section critique" << endl );

    if (!found) throw InvalidArgumentException("Invalid JobId argument for queryJob");

    JobInfo_Local ji(param, env);
    return ji;
  }


  // Ce manager ne peut pas reprendre un job
  // On force donc l'état du job à erreur - pour cela on ne donne pas d'Id
  // au JobId
  const Batch::JobId
  BatchManager_Local::addJob(const Batch::Job & /*job*/, const std::string & /*reference*/)
  {
    return JobId(this, "undefined");
  }

  // Methode pour le controle des jobs : teste si un job est present en machine
  bool BatchManager_Local::isRunning(const JobId & jobid)
  {
    Id id;
    istringstream iss(jobid.getReference());
    iss >> id;

    //UNDER_LOCK( cout << "JobInfo BatchManager_Local::queryJob(const JobId & jobid) : AVANT section critique" << endl );
    // @@@ --------> SECTION CRITIQUE <-------- @@@
    pthread_mutex_lock(&_threads_mutex);
    bool running = (_threads[id].param[STATE].str() == RUNNING);
    pthread_mutex_unlock(&_threads_mutex);
    // @@@ --------> SECTION CRITIQUE <-------- @@@
    //UNDER_LOCK( cout << "JobInfo BatchManager_Local::queryJob(const JobId & jobid) : APRES section critique" << endl );

    return running;
  }

  string BatchManager_Local::ThreadAdapter::buildCommandFile(const Job_Local & job)
  {
    Parametre param = job.getParametre();

    // Mandatory parameters
    string workDir = "";
    if (param.find(WORKDIR) != param.end())
      workDir = param[WORKDIR].str();
    else
      throw RunTimeException("param[WORKDIR] is not defined. Please define it, cannot submit this job.");
    string fileToExecute = "";
    if (param.find(EXECUTABLE) != param.end())
      fileToExecute = param[EXECUTABLE].str();
    else
      throw RunTimeException("param[EXECUTABLE] is not defined. Please define it, cannot submit this job.");
#ifdef WIN32
    const char separator = '\\';
#else
    const char separator = '/';
#endif
    string::size_type p1 = fileToExecute.find_last_of(separator);
    string::size_type p2 = fileToExecute.find_last_of(".");
    string rootNameToExecute = fileToExecute.substr(p1+1,p2-p1-1);
    string fileNameToExecute = fileToExecute.substr(p1+1);
    string remotePath = workDir + separator + rootNameToExecute + "_launch_job";

    // Create batch submit file
    ofstream tempOutputFile;
    string tmpFileName = Utils::createAndOpenTemporaryFile("launch-job", tempOutputFile);

#ifdef WIN32
    if (_bm._protocol.getType() == SH) {
      char drive[_MAX_DRIVE];
      _splitpath(workDir.c_str(), drive, NULL, NULL, NULL);
      if (strlen(drive) > 0) tempOutputFile << drive << endl;
      tempOutputFile << "cd " << Utils::fixPath(workDir) << endl;
      // Define environment for the job
      Environnement env = job.getEnvironnement();
      for (Environnement::const_iterator iter = env.begin() ; iter != env.end() ; ++iter) {
        tempOutputFile << "set " << iter->first << "=" << iter->second << endl;
      }
      // Launch the executable
      tempOutputFile << fileNameToExecute;
      if (param.find(ARGUMENTS) != param.end()) {
        Versatile V = param[ARGUMENTS];
        for(Versatile::const_iterator it=V.begin(); it!=V.end(); it++) {
          StringType argt = * static_cast<StringType *>(*it);
          string     arg  = argt;
          tempOutputFile << " " << arg;
        }
      }
      remotePath += ".bat";
    } else {
#endif

    tempOutputFile << "#!/bin/sh -f" << endl;
    tempOutputFile << "cd " << workDir << endl;

    // Optional parameters (system limits on the job process)
    if (param.find(MAXCPUTIME) != param.end()) {
      long maxcputime = (long)param[MAXCPUTIME] * 60;
      tempOutputFile << "ulimit -H -t " << maxcputime << endl;
    }

    if (param.find(MAXDISKSIZE) != param.end()) {
      long maxdisksize = (long)param[MAXDISKSIZE] * 1024;
      tempOutputFile << "ulimit -H -f " << maxdisksize << endl;
    }

    if (param.find(MAXRAMSIZE) != param.end()) {
      long maxramsize = (long)param[MAXRAMSIZE] * 1024;
      tempOutputFile << "ulimit -H -v " << maxramsize << endl;
    }

    // Number of cores to use
    int nbproc = 1;
    if (param.find(NBPROC) != param.end())
      nbproc = param[NBPROC];

    // Define environment for the job
    Environnement env = job.getEnvironnement();
    for (Environnement::const_iterator iter = env.begin() ; iter != env.end() ; ++iter) {
      tempOutputFile << "export " << iter->first << "=" << iter->second << endl;
    }

    // generate nodes file (one line per required proc)
    tempOutputFile << "LIBBATCH_NODEFILE=$(mktemp nodefile-XXXXXXXXXX)" << endl;
    tempOutputFile << "i=" << nbproc << endl;
    tempOutputFile << "hn=$(hostname)" << endl;
    tempOutputFile << "{" << endl;
    tempOutputFile << "while [ $i -gt 0 ]" << endl;
    tempOutputFile << "do" << endl;
    tempOutputFile << "    echo \"$hn\"" << endl;
    tempOutputFile << "    i=$((i-1))" << endl;
    tempOutputFile << "done" << endl;
    tempOutputFile << "} > \"$LIBBATCH_NODEFILE\"" << endl;
    tempOutputFile << "export LIBBATCH_NODEFILE" << endl;

    // Launch the executable
    tempOutputFile << "./" + fileNameToExecute;
    if (param.find(ARGUMENTS) != param.end()) {
      Versatile V = param[ARGUMENTS];
      for(Versatile::const_iterator it=V.begin(); it!=V.end(); it++) {
        StringType argt = * static_cast<StringType *>(*it);
        string     arg  = argt;
        tempOutputFile << " " << arg;
      }
    }

    // Standard input and output
    if (param.find(INFILE) != param.end()) {
      Versatile V = param[INFILE];
      for(Versatile::const_iterator it=V.begin(); it!=V.end(); it++) {
        Couple cpl = * static_cast<CoupleType*>(*it);
        string remote = cpl.getRemote();
        if (remote == "stdin")
          tempOutputFile << " <stdin";
      }
    }

    string stdoutFile = workDir + "/logs/output.log." + rootNameToExecute;
    string stderrFile = workDir + "/logs/error.log." + rootNameToExecute;
    if (param.find(OUTFILE) != param.end()) {
      Versatile V = param[OUTFILE];
      for(Versatile::const_iterator it=V.begin(); it!=V.end(); it++) {
        Couple cpl = * static_cast<CoupleType*>(*it);
        string remote = cpl.getRemote();
        if (remote == "stdout") stdoutFile = "stdout";
        if (remote == "stderr") stderrFile = "stderr";
      }
    }
    tempOutputFile << " 1>" << stdoutFile << " 2>" << stderrFile << endl;

    // Remove the node file
    tempOutputFile << "rm \"$LIBBATCH_NODEFILE\"" << endl;

#ifdef WIN32
    }
#endif

    tempOutputFile.flush();
    tempOutputFile.close();

    LOG("Batch script file generated is: " << tmpFileName);

    Utils::chmod(tmpFileName.c_str(), 0x1ED);
    Status status = _bm._protocol.copyFile(tmpFileName, "", "",
                                        remotePath, _bm._hostname, _bm._username);
    if (status.hasErrors())
      throw RunTimeException(status.errorMessage());

#ifdef WIN32
    if (_bm._protocol.getType() != SH) {
      // On Windows, we make the remote file executable afterward because
      // pscp does not preserve access permissions on files
      string subCommand = string("chmod u+x ") + remotePath;
      string command = _bm._protocol.getExecCommand(subCommand, _bm._hostname, _bm._username);
      LOG(command);
      int status = system(command.c_str());
      if (status) {
        std::ostringstream oss;
        oss << "Cannot change permissions of file " << remotePath << " on host " << _bm._hostname;
        oss << ". Return status is " << status;
        throw RunTimeException(oss.str());
      }
    }
#endif

    return remotePath;
  }



  // Constructeur de la classe ThreadAdapter
  BatchManager_Local::ThreadAdapter::ThreadAdapter(BatchManager_Local & bm, const Job_Local & job, Id id) :
  _bm(bm), _job(job), _id(id)
  {
    // Nothing to do
  }



  // Methode d'execution du thread
  void * BatchManager_Local::ThreadAdapter::run(void * arg)
  {
    ThreadAdapter * p_ta = static_cast<ThreadAdapter *>(arg);

#ifndef WIN32
    // On bloque tous les signaux pour ce thread
    sigset_t setmask;
    sigfillset(&setmask);
    pthread_sigmask(SIG_BLOCK, &setmask, NULL);
#endif

    // On autorise la terminaison differee du thread
    // (ces valeurs sont les valeurs par defaut mais on les force par precaution)
    pthread_setcancelstate(PTHREAD_CANCEL_ENABLE,  NULL);
    pthread_setcanceltype(PTHREAD_CANCEL_DEFERRED, NULL);

    // On enregistre la fonction de suppression du fils en cas d'arret du thread
    // Cette fontion sera automatiquement appelee lorsqu'une demande d'annulation
    // sera prise en compte par pthread_testcancel()
    Process child;
    pthread_cleanup_push(BatchManager_Local::delete_on_exit, arg);
    pthread_cleanup_push(BatchManager_Local::setFailedOnCancel, arg);
    pthread_cleanup_push(BatchManager_Local::kill_child_on_exit, static_cast<void *> (&child));

    // On forke/exec un nouveau process pour pouvoir controler le fils
    // (plus finement qu'avec un appel system)
    // int rc = system(commande.c_str());
    //char *const parmList[] = {"/usr/bin/ssh", "localhost", "-l", "aribes", "sleep 10 && echo end", NULL};
    //execv("/usr/bin/ssh", parmList);
#ifdef WIN32
    child = p_ta->launchWin32ChildProcess();
    p_ta->pere(child);
#else
    // LOCK&UNLOCK needed to avoid potential deadlock if a thread holds the lock
    LOCK_IO
    child = fork();
    UNLOCK_IO
    if (child < 0) { // erreur
      UNDER_LOCK( LOG("Fork impossible (rc=" << child << ")") );

    } else if (child > 0) { // pere
      p_ta->pere(child);

    } else { // fils
      p_ta->fils();
    }
#endif

    pthread_mutex_lock(&p_ta->_bm._threads_mutex);

    // Set the job state to FINISHED or FAILED
    p_ta->_bm._threads[p_ta->_id].param[STATE] = (p_ta->_bm._threads[p_ta->_id].hasFailed) ? FAILED : FINISHED;

    // On retire la fonction de nettoyage de la memoire
    pthread_cleanup_pop(0);

    // On retire la fonction de suppression du fils
    pthread_cleanup_pop(0);

    // remove setFailedOnCancel function from cancel stack
    pthread_cleanup_pop(0);

    pthread_mutex_unlock(&p_ta->_bm._threads_mutex);

    // On invoque la fonction de nettoyage de la memoire
    delete_on_exit(arg);

    UNDER_LOCK( LOG("Father is leaving") );
    pthread_exit(NULL);
    return NULL;
  }




  void BatchManager_Local::ThreadAdapter::pere(Process child)
  {
    time_t child_starttime = time(NULL);

    // On enregistre le fils dans la table des threads
    pthread_t thread_id = pthread_self();

    Parametre param   = _job.getParametre();
    Environnement env = _job.getEnvironnement();

    ostringstream id_sst;
    id_sst << _id;
    param[ID]         = id_sst.str();
    param[STATE]      = Batch::RUNNING;

    _bm._threads[_id].thread_id = thread_id;
#ifndef WIN32
    _bm._threads[_id].pid       = child;
#endif
    _bm._threads[_id].hasFailed = false;
    _bm._threads[_id].param     = param;
    _bm._threads[_id].env       = env;
    _bm._threads[_id].command_queue.push(NOP);

    // Unlock the master thread. From here, all shared variables must be protected
    // from concurrent access
    pthread_cond_signal(&_bm._threadSyncCondition);


    // on boucle en attendant que le fils ait termine
    while (1) {
#ifdef WIN32
      DWORD exitCode;
      GetExitCodeProcess(child, &exitCode);
      if (exitCode != STILL_ACTIVE) {
        UNDER_LOCK( LOG("Father sees his child is DONE: exit code = " << exitCode) );
        break;
      }
#else
      int child_rc = 0;
      pid_t child_wait_rc = waitpid(child, &child_rc, WNOHANG /* | WUNTRACED */);
      if (child_wait_rc > 0) {
	 UNDER_LOCK( LOG("Status is: " << WIFEXITED( child_rc)) );
	 UNDER_LOCK( LOG("Status is: " << WEXITSTATUS( child_rc)) );
	 UNDER_LOCK( LOG("Status is: " << WIFSIGNALED( child_rc)) );
	 UNDER_LOCK( LOG("Status is: " << WTERMSIG( child_rc)) );
	 UNDER_LOCK( LOG("Status is: " << WCOREDUMP( child_rc)) );
	 UNDER_LOCK( LOG("Status is: " << WIFSTOPPED( child_rc)) );
	 UNDER_LOCK( LOG("Status is: " << WSTOPSIG( child_rc)) );
#ifdef WIFCONTINUED
	 UNDER_LOCK( LOG("Status is: " << WIFCONTINUED( child_rc)) ); // not compilable on sarge
#endif
        if (WIFSTOPPED(child_rc)) {
          // NOTA : pour rentrer dans cette section, il faut que le flag WUNTRACED
          // soit positionne dans l'appel a waitpid ci-dessus. Ce flag est couramment
          // desactive car s'il est possible de detecter l'arret d'un process, il est
          // plus difficile de detecter sa reprise.

          // Le fils est simplement stoppe
          // @@@ --------> SECTION CRITIQUE <-------- @@@
          pthread_mutex_lock(&_bm._threads_mutex);
          _bm._threads[_id].param[STATE] = Batch::PAUSED;
          pthread_mutex_unlock(&_bm._threads_mutex);
          // @@@ --------> SECTION CRITIQUE <-------- @@@
          UNDER_LOCK( LOG("Father sees his child is STOPPED : " << child_wait_rc) );

        }
        else {
          // Le fils est termine, on sort de la boucle et du if englobant
          UNDER_LOCK( LOG("Father sees his child is DONE : " << child_wait_rc << " (child_rc=" << (WIFEXITED(child_rc) ? WEXITSTATUS(child_rc) : -1) << ")") );
          break;
        }
      }
      else if (child_wait_rc == -1) {
        // Le fils a disparu ...
        // @@@ --------> SECTION CRITIQUE <-------- @@@
        pthread_mutex_lock(&_bm._threads_mutex);
        _bm._threads[_id].hasFailed = true;
        pthread_mutex_unlock(&_bm._threads_mutex);
        // @@@ --------> SECTION CRITIQUE <-------- @@@
        UNDER_LOCK( LOG("Father sees his child is DEAD : " << child_wait_rc << " (Reason : " << strerror(errno) << ")") );
        break;
      }
#endif

      // On teste si le thread doit etre detruit
      pthread_testcancel();



      // On regarde si le fils n'a pas depasse son temps (wallclock time)
      time_t child_currenttime = time(NULL);
      long child_elapsedtime_minutes = (child_currenttime - child_starttime) / 60L;
      if (param.find(MAXWALLTIME) != param.end()) {
        long maxwalltime = param[MAXWALLTIME];
        // 	  cout << "child_starttime          = " << child_starttime        << endl
        // 	       << "child_currenttime        = " << child_currenttime      << endl
        // 	       << "child_elapsedtime        = " << child_elapsedtime      << endl
        // 	       << "maxwalltime              = " << maxwalltime            << endl
        // 	       << "int(maxwalltime * 1.1)   = " << int(maxwalltime * 1.1) << endl;
        if (child_elapsedtime_minutes > long((float)maxwalltime * 1.1) ) { // On se donne 10% de marge avant le KILL
          UNDER_LOCK( LOG("Father is sending KILL command to the thread " << _id) );
          // On introduit une commande dans la queue du thread
          // @@@ --------> SECTION CRITIQUE <-------- @@@
          pthread_mutex_lock(&_bm._threads_mutex);
          if (_bm._threads.find(_id) != _bm._threads.end())
            _bm._threads[_id].command_queue.push(KILL);
          pthread_mutex_unlock(&_bm._threads_mutex);
          // @@@ --------> SECTION CRITIQUE <-------- @@@


        } else if (child_elapsedtime_minutes > maxwalltime ) {
          UNDER_LOCK( LOG("Father is sending TERM command to the thread " << _id) );
          // On introduit une commande dans la queue du thread
          // @@@ --------> SECTION CRITIQUE <-------- @@@
          pthread_mutex_lock(&_bm._threads_mutex);
          if (_bm._threads.find(_id) != _bm._threads.end())
            _bm._threads[_id].command_queue.push(TERM);
          pthread_mutex_unlock(&_bm._threads_mutex);
          // @@@ --------> SECTION CRITIQUE <-------- @@@
        }
      }



      // On regarde s'il y a quelque chose a faire dans la queue de commande
      // @@@ --------> SECTION CRITIQUE <-------- @@@
      pthread_mutex_lock(&_bm._threads_mutex);
      if (_bm._threads.find(_id) != _bm._threads.end()) {
        while (_bm._threads[_id].command_queue.size() > 0) {
          Commande cmd = _bm._threads[_id].command_queue.front();
          _bm._threads[_id].command_queue.pop();

          switch (cmd) {
    case NOP:
      UNDER_LOCK( LOG("Father does nothing to his child") );
      break;
#ifndef WIN32
    case HOLD:
      UNDER_LOCK( LOG("Father is sending SIGSTOP signal to his child") );
      kill(child, SIGSTOP);
      break;

    case RELEASE:
      UNDER_LOCK( LOG("Father is sending SIGCONT signal to his child") );
      kill(child, SIGCONT);
      break;

    case TERM:
      UNDER_LOCK( LOG("Father is sending SIGTERM signal to his child") );
      kill(child, SIGTERM);
      break;

    case KILL:
      UNDER_LOCK( LOG("Father is sending SIGKILL signal to his child") );
      kill(child, SIGKILL);
      break;
#endif
    case ALTER:
      break;

    default:
      break;
          }
        }

      }
      pthread_mutex_unlock(&_bm._threads_mutex);
      // @@@ --------> SECTION CRITIQUE <-------- @@@

      // On fait une petite pause pour ne pas surcharger inutilement le processeur
#ifdef WIN32
      Sleep(1000);
#else
      sleep(1);
#endif

    }

  }



#ifndef WIN32

  void BatchManager_Local::ThreadAdapter::fils()
  {
    Parametre param = _job.getParametre();
    Parametre::iterator it;

    try {

      // build script file to launch the job and copy it on the server
      string cmdFilePath = buildCommandFile(_job);

      // define command to submit the job
      vector<string> command = _bm._protocol.getExecCommandArgs(cmdFilePath, _bm._hostname, _bm._username);

      // Build the argument array argv from the command
      char ** argv = new char * [command.size() + 1];
      string comstr;
      for (string::size_type i=0 ; i<command.size() ; i++) {
        argv[i] = new char[command[i].size() + 1];
        strncpy(argv[i], command[i].c_str(), command[i].size() + 1);
        comstr += command[i] + " ";
      }
      argv[command.size()] = NULL;
      UNDER_LOCK( LOG("*** debug_command = " << comstr) );

      // On cree une session pour le fils de facon a ce qu'il ne soit pas
      // detruit lorsque le shell se termine (le shell ouvre une session et
      // tue tous les process appartenant a la session en quittant)
      setsid();

      // On ferme les descripteurs de fichiers standards
      //close(STDIN_FILENO);
      //close(STDOUT_FILENO);
      //close(STDERR_FILENO);

      // On execute la commande du fils
      execvp(argv[0], argv);
      UNDER_LOCK( LOG("*** debug_command = " << strerror(errno)) );
      // No need to deallocate since nothing happens after a successful exec

      // Normalement on ne devrait jamais arriver ici
      ofstream file_err("error.log");
      UNDER_LOCK( file_err << "Echec de l'appel a execvp" << endl );

    } catch (GenericException & e) {

      LOG("Caught exception : " << e.type << " : " << e.message);
    }

    exit(99);
  }

#else

  BatchManager_Local::Process BatchManager_Local::ThreadAdapter::launchWin32ChildProcess()
  {
    Parametre param = _job.getParametre();
    Parametre::iterator it;
    PROCESS_INFORMATION pi;
    ZeroMemory( &pi, sizeof(pi) );

    try {

      // build script file to launch the job and copy it on the server
      string cmdFilePath = buildCommandFile(_job);

      // define command to submit the job
      vector<string> command = _bm._protocol.getExecCommandArgs(cmdFilePath, _bm._hostname, _bm._username);

      // Build the command string from the command argument vector
      string comstr;
      for (unsigned int i=0 ; i<command.size() ; i++) {
        if (i>0) comstr += " ";
        comstr += command[i];
      }

      UNDER_LOCK( LOG("*** debug_command = " << comstr) );

      STARTUPINFO si;
      ZeroMemory( &si, sizeof(si) );
      si.cb = sizeof(si);

      // Copy the command to a non-const buffer
      char * buffer = strdup(comstr.c_str());

      // launch the new process
      bool res = CreateProcess(NULL, buffer, NULL, NULL, FALSE,
                               CREATE_NO_WINDOW, NULL, NULL, &si, &pi);

      if (buffer) free(buffer);
      if (!res) throw RunTimeException("Error while creating new process");

      CloseHandle(pi.hThread);

    } catch (GenericException & e) {

      LOG("Caught exception : " << e.type << " : " << e.message);
    }

    return pi.hProcess;
  }

#endif


  void BatchManager_Local::kill_child_on_exit(void * p_pid)
  {
#ifndef WIN32
    //TODO: porting of following functionality
    pid_t child = * static_cast<pid_t *>(p_pid);

    // On tue le fils
    kill(child, SIGTERM);

    // Nota : on pourrait aussi faire a la suite un kill(child, SIGKILL)
    // mais cette option n'est pas implementee pour le moment, car il est
    // preferable de laisser le process fils se terminer normalement et seul.
#endif
  }

  void BatchManager_Local::delete_on_exit(void * arg)
  {
    ThreadAdapter * p_ta = static_cast<ThreadAdapter *>(arg);
    delete p_ta;
  }

  void BatchManager_Local::setFailedOnCancel(void * arg)
  {
    ThreadAdapter * p_ta = static_cast<ThreadAdapter *>(arg);
    pthread_mutex_lock(&p_ta->getBatchManager()._threads_mutex);
    p_ta->getBatchManager()._threads[p_ta->getId()].param[STATE] = FAILED;
    pthread_mutex_unlock(&p_ta->getBatchManager()._threads_mutex);

    // Unlock the master thread. From here, the batch manager instance should not be used.
    pthread_cond_signal(&p_ta->getBatchManager()._threadSyncCondition);
  }

}
