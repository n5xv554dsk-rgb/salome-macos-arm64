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
 * BatchManager.cxx :
 *
 * Auteur : Ivan DUTKA-MALEN - EDF R&D
 * Date   : Septembre 2003
 * Projet : SALOME 2
 *
 */

#include <iostream>
#include <sstream>
#include <string>

#include "Constants.hxx"
#include "Job.hxx"
#include "JobId.hxx"
#include "JobInfo.hxx"
#include "FactBatchManager.hxx"
#include "BatchManager.hxx"
#include "Utils.hxx"
#include "NotYetImplementedException.hxx"
#include "Log.hxx"

using namespace std;

namespace Batch {

  BatchManager::BatchManager(const Batch::FactBatchManager * parent, const char* host,
                             const char * username,
                             CommunicationProtocolType protocolType, const char* mpiImpl)
    : _hostname(host), jobid_map(), _type(parent->getType()),
      _protocol(CommunicationProtocol::getInstance(protocolType)),
      _username(username), _mpiImpl(FactoryMpiImpl(mpiImpl))
  {
  }


  // Destructeur
  BatchManager::~BatchManager()
  {
    delete _mpiImpl;
  }

  string BatchManager::__repr__() const
  {
    ostringstream oss;
    oss << "<BatchManager of type '" << _type << "' connected to server '" << _hostname << "'>";
    return oss.str();
  }

  // Recupere le l'identifiant d'un job deja soumis au BatchManager
  const JobId BatchManager::getJobIdByReference(const char * ref)
  {
    return JobId(this, ref);
  }

  // Methode pour le controle des jobs : soumet un job au gestionnaire
  const JobId BatchManager::submitJob(const Job & job)
  {
    exportInputFiles(job);
    preprocess(job);
    return runJob(job);
  }

  // Methode pour le controle des jobs : retire un job du gestionnaire
  void BatchManager::deleteJob(const JobId & /*jobid*/)
  {
    throw NotYetImplementedException("Method deleteJob not implemented by Batch Manager \"" + _type + "\"");
  }

  // Methode pour le controle des jobs : suspend un job en file d'attente
  void BatchManager::holdJob(const JobId & /*jobid*/)
  {
    throw NotYetImplementedException("Method holdJob not implemented by Batch Manager \"" + _type + "\"");
  }

  // Methode pour le controle des jobs : relache un job suspendu
  void BatchManager::releaseJob(const JobId & /*jobid*/)
  {
    throw NotYetImplementedException("Method releaseJob not implemented by Batch Manager \"" + _type + "\"");
  }

  // Methode pour le controle des jobs : modifie un job en file d'attente
  void BatchManager::alterJob(const JobId & /*jobid*/, const Parametre & /*param*/, const Environnement & /*env*/)
  {
    throw NotYetImplementedException("Method alterJob not implemented by Batch Manager \"" + _type + "\"");
  }

  // Methode pour le controle des jobs : modifie un job en file d'attente
  void BatchManager::alterJob(const JobId & /*jobid*/, const Parametre & /*param*/)
  {
    throw NotYetImplementedException("Method alterJob not implemented by Batch Manager \"" + _type + "\"");
  }

  // Methode pour le controle des jobs : modifie un job en file d'attente
  void BatchManager::alterJob(const JobId & /*jobid*/, const Environnement & /*env*/)
  {
    throw NotYetImplementedException("Method alterJob not implemented by Batch Manager \"" + _type + "\"");
  }

  // Methode pour le controle des jobs : renvoie l'etat du job
  JobInfo BatchManager::queryJob(const JobId & /*jobid*/)
  {
    throw NotYetImplementedException("Method queryJob not implemented by Batch Manager \"" + _type + "\"");
  }

  const JobId BatchManager::addJob(const Job & /*job*/, const string & reference)
  {
    return JobId(this, reference);
  }

  //! Wait for the end of a job
  /*!
   *  This method is a simple way to wait for a job to end. It will query the job state at
   *  increasing intervals and return when the job is finished (whether successfully or not) or
   *  when the timeout is reached. This method is not intended to be generic. In many cases you
   *  will have to write your own loop to wait for the end of a job.
   *  \param jobid ID of the job to wait for.
   *  \param timeout Maximum time to wait in seconds. If -1 (default), wait indefinitely.
   *  \param initSleepTime Initial time in seconds between two queries for the job state (default is 1).
   *  \param maxSleepTime Maximum time in seconds between two queries for the job state (default is 600).
   *  \return The job state as returned by the last query.
   */
  string BatchManager::waitForJobEnd(const JobId & jobid, long timeout,
                                     long initSleepTime, long maxSleepTime)
  {
    int time = 0;
    int sleeptime = initSleepTime;
    bool testTimeout = (timeout > -1);
    bool timeoutReached = (testTimeout && time >= timeout);
    JobInfo jinfo = jobid.queryJob();
    string state = jinfo.getParametre()[STATE].str();
    while (!timeoutReached && state != FINISHED && state != FAILED) {
      LOG("State is \"" << state << "\"" << ", sleeping " << sleeptime << "s...");
      Utils::sleep(sleeptime);
      time += sleeptime;
      timeoutReached = (testTimeout && time >= timeout);
      sleeptime *= 2;
      if (testTimeout && sleeptime > timeout - time)
        sleeptime = timeout - time;
      if (sleeptime > maxSleepTime)
        sleeptime = maxSleepTime;
      jinfo = jobid.queryJob();
      state = jinfo.getParametre()[STATE].str();
    }
    LOG("State is \"" << state << "\"");
    return state;
  }


  void BatchManager::exportInputFiles(const Job& job)
  {
    Parametre params = job.getParametre();
    const Versatile & V = params[INFILE];
    Versatile::const_iterator Vit;

    // Create remote directories
    string logdir = string(params[WORKDIR]) + "/logs";
    Status status = _protocol.makeDirectory(logdir, _hostname, _username);
    if (status.hasErrors()) {
      throw RunTimeException(status.errorMessage());
    }

    // Copy the file to execute into the remote working directory
    string executeFile = params[EXECUTABLE];
    if (executeFile.size() != 0) {
      status = _protocol.copyFile(executeFile, "", "",
                                  params[WORKDIR], _hostname, _username);
      if (status.hasErrors()) {
        throw RunTimeException(status.errorMessage());
      }

#ifdef WIN32
      if (_protocol.getType() != SH) {
        // On Windows, we make the remote file executable afterward because
        // pscp does not preserve access permissions on files

        string remoteExec = string(params[EXECUTABLE]);
        remoteExec = remoteExec.substr(remoteExec.rfind("/") + 1, remoteExec.length());
        remoteExec = string(params[WORKDIR]) + "/" + remoteExec;

        string subCommand = string("chmod u+x ") + remoteExec;
        string command = _protocol.getExecCommand(subCommand, _hostname, _username);
        LOG(command);
        int status;
        status = system(command.c_str());
        if (status) {
          std::ostringstream oss;
          oss << "Cannot change permissions of file " << remoteExec << " on host " << _hostname;
          oss << ". Return status is " << status;
          throw RunTimeException(oss.str());
        }
      }
#endif
    }

    // Copy input files into the remote working directory
    for (Vit=V.begin() ; Vit!=V.end() ; Vit++) {
      CoupleType cpt = *static_cast< CoupleType * >(*Vit);
      Couple inputFile = cpt;
      string remotePath = inputFile.getRemote();
      if (!Utils::isAbsolutePath(remotePath)) {
        remotePath = params[WORKDIR].str() + "/" + remotePath;
      }
      status = _protocol.copyFile(inputFile.getLocal(), "", "",
                                  remotePath, _hostname, _username);
      if (status.hasErrors()) {
        throw RunTimeException(status.errorMessage());
      }
    }

  }

  void BatchManager::importOutputFiles( const Job & job, const string directory )
  {
    Parametre params = job.getParametre();
    const Versatile & V = params[OUTFILE];
    Versatile::const_iterator Vit;

    // Create local result directory
    Status status = CommunicationProtocol::getInstance(SH).makeDirectory(directory, "", "");
    if (status.hasErrors())
      LOG("Directory creation failed. Error is: " << status.errorMessage());

    for(Vit=V.begin(); Vit!=V.end(); Vit++) {
      CoupleType cpt  = *static_cast< CoupleType * >(*Vit);
      Couple outputFile = cpt;
      string remotePath = outputFile.getRemote();
      if (!Utils::isAbsolutePath(remotePath) && !Utils::isOption(remotePath)) {
        // rsync creates the whole tree after /./ in the destination folder
        remotePath = params[WORKDIR].str() + "/./" + remotePath;
      }
      string localPath = outputFile.getLocal();
      if (!Utils::isAbsolutePath(localPath)) {
        localPath = directory + "/" + localPath;
      }
      status = _protocol.copyFile(remotePath, _hostname, _username,
                                  localPath, "", "");
      if (status.hasErrors())
        LOG("Copy command failed. Error is: " << status.errorMessage());
    }

    // Copy logs
    status = _protocol.copyFile(string(params[WORKDIR]) + string("/logs"), _hostname, _username,
                                directory, "", "");
    if (status.hasErrors())
      LOG("Copy logs directory failed. Error is: " << status.errorMessage());
  }

  bool BatchManager::importDumpStateFile( const Job & job, const string directory )
  {
    Parametre params = job.getParametre();

    // Create local result directory
    Status status = CommunicationProtocol::getInstance(SH).makeDirectory(directory, "", "");
    if (status.hasErrors())
      LOG("Directory creation failed. Error is: " << status.errorMessage());

    bool ret = true;
    status = _protocol.copyFile(string(params[WORKDIR]) + string("/dumpState*.xml"), _hostname, _username,
                                directory, "", "");
    if (status.hasErrors()) {
      LOG("Copy command failed. Error is: " << status.errorMessage());
      ret = false;
    }
    return ret;
  }

  bool BatchManager::importWorkFile( const Job & job,
                                     const std::string& work_file,
                                     const std::string& directory )
  {
    Parametre params = job.getParametre();

    // Create local result directory
    Status status = CommunicationProtocol::getInstance(SH).makeDirectory(directory, "", "");
    if (status.hasErrors())
      LOG("Directory creation failed. Error is: " << status.errorMessage());

    bool ret = true;
    status = _protocol.copyFile(string(params[WORKDIR]) + "/" + work_file,
                                _hostname, _username,
                                directory, "", "");
    if (status.hasErrors()) {
      LOG("Copy command failed. Error is: " << status.errorMessage());
      ret = false;
    }
    return ret;
  }

  void BatchManager::clearWorkingDir( const Job & job)
  {
    Parametre params = job.getParametre();

    string wd = params[WORKDIR];
    if(!wd.empty() && wd != "/")
    {
      Status status = _protocol.removeDirectory(wd, _hostname, _username);
      if (status.hasErrors())
        LOG("removeDirectory command failed. Error is: " << status.errorMessage());
    }
    else
      LOG("removeDirectory command failed. Invalid working directory: " << wd);
  }

  MpiImpl *BatchManager::FactoryMpiImpl(string mpiImpl)
  {
    if(mpiImpl == "lam")
      return new MpiImpl_LAM();
    else if(mpiImpl == "mpich1")
      return new MpiImpl_MPICH1();
    else if(mpiImpl == "mpich2")
      return new MpiImpl_MPICH2();
    else if(mpiImpl == "openmpi")
      return new MpiImpl_OPENMPI();
    else if(mpiImpl == "ompi")
      return new MpiImpl_OMPI();
    else if(mpiImpl == "slurm")
      return new MpiImpl_SLURM();
    else if(mpiImpl == "prun")
      return new MpiImpl_PRUN();
    else if(mpiImpl == "nompi")
      return NULL;
    else{
      ostringstream oss;
      oss << mpiImpl << " : not yet implemented";
      throw RunTimeException(oss.str().c_str());
    }
  }

  const CommunicationProtocol & BatchManager::getProtocol() const
  {
    return _protocol;
  }

  void BatchManager::preprocess(const Batch::Job & job)
  {
    std::string preproCommand;
    std::string workDir;
    Parametre params = job.getParametre();
    if (params.find(PREPROCESS) != params.end())
      preproCommand = params[PREPROCESS].str();
    if (params.find(WORKDIR) != params.end())
      workDir = params[WORKDIR].str();

    if(!preproCommand.empty() && !workDir.empty())
    {
      std::string subCommand = "cd " + workDir + "; " + preproCommand;
      std::string command = _protocol.getExecCommand(subCommand, _hostname, _username);
      command += " 2>&1";
      LOG(command);

      // submit job
      std::string output;
      int status = Utils::getCommandOutput(command, output);
      LOG(output);
      if (status != 0)
        throw RunTimeException("Error when executing: " + command +
                               "\nOutput:" + output);
    }
  }
  
  const Batch::JobId BatchManager::runJob(const Batch::Job & /*job*/)
  {
    throw NotYetImplementedException("Method runJob not implemented by Batch Manager \"" + _type + "\"");
  }
}
