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
 * BatchManager_PBS.cxx : emulation of PBS client
 *
 * Auteur : Bernard SECHER - CEA DEN, André RIBES - EDF R&D
 * Mail   : mailto:bernard.secher@cea.fr
 * Date   : Thu Apr 24 10:17:22 2008
 * Projet : PAL Salome
 *
 */

#include <cstdlib>
#include <fstream>
#include <sstream>

#include <Constants.hxx>
#include <Utils.hxx>
#include <NotYetImplementedException.hxx>

#include "BatchManager_PBS.hxx"
#include "JobInfo_PBS.hxx"
#include "Log.hxx"

using namespace std;

namespace Batch {

  BatchManager_PBS::BatchManager_PBS(const FactBatchManager * parent, const char * host,
                                       const char * username,
                                       CommunicationProtocolType protocolType, const char * mpiImpl)
    : BatchManager(parent, host, username, protocolType, mpiImpl)
  {
    // Nothing to do
  }

  // Destructeur
  BatchManager_PBS::~BatchManager_PBS()
  {
    // Nothing to do
  }

  // Methode pour le controle des jobs : soumet un job au gestionnaire
  const JobId BatchManager_PBS::runJob(const Job & job)
  {
    Parametre params = job.getParametre();
    const std::string workDir = params[WORKDIR];

    // build batch script for job
    string scriptFile = buildSubmissionScript(job);

    // define command to submit batch
    string subCommand = string("cd ") + workDir + "; qsub " + scriptFile;
    string command = _protocol.getExecCommand(subCommand, _hostname, _username);
    command += " 2>&1";
    LOG(command);

    // submit job
    string output;
    int status = Utils::getCommandOutput(command, output);
    LOG(output);
    if (status != 0) throw RunTimeException("Can't submit job, error was: " + output);

    // normally output contains only id of submitted job, we just need to remove the final \n
    string jobref = output.substr(0, output.size() - 1);
    JobId id(this, jobref);

    return id;
  }

  // Methode pour le controle des jobs : retire un job du gestionnaire
  void BatchManager_PBS::deleteJob(const JobId & jobid)
  {
    int status;
    int ref;
    istringstream iss(jobid.getReference());
    iss >> ref;

    // define command to delete batch
    string subCommand = string("qdel ") + iss.str();
    string command = _protocol.getExecCommand(subCommand, _hostname, _username);
    LOG(command);
    status = system(command.c_str());
    if (status)
      throw RunTimeException("Error of connection on remote host");

    LOG("jobId = " << ref << "killed");
  }

  // Methode pour le controle des jobs : renvoie l'etat du job
  JobInfo BatchManager_PBS::queryJob(const JobId & jobid)
  {
    int id;
    istringstream iss(jobid.getReference());
    iss >> id;

    // define command to query batch
    string subCommand = string("qstat -f -x ") + iss.str();
    string command = _protocol.getExecCommand(subCommand, _hostname, _username);
    LOG(command);

    string output;
    int status = Utils::getCommandOutput(command, output);
    if(status && status != 153 && status != 256*153)
      throw RunTimeException("Error of connection on remote host");

    JobInfo_PBS ji = JobInfo_PBS(id, output);
    return ji;
  }

  // Methode pour le controle des jobs : teste si un job est present en machine
  bool BatchManager_PBS::isRunning(const JobId & /*jobid*/)
  {
    throw NotYetImplementedException("BatchManager_PBS::isRunning");
  }

  std::string BatchManager_PBS::buildSubmissionScript(const Job & job)
  {
    Parametre params = job.getParametre();
    Environnement env = job.getEnvironnement();

    // Mandatory parameters
    string workDir;
    if (params.find(WORKDIR) != params.end()) 
      workDir = params[WORKDIR].str();
    else 
      throw RunTimeException("params[WORKDIR] is not defined ! Please defined it, cannot submit this job");
    string fileToExecute;
    if (params.find(EXECUTABLE) != params.end()) 
      fileToExecute = params[EXECUTABLE].str();
    else 
      throw RunTimeException("params[EXECUTABLE] is not defined ! Please defined it, cannot submit this job");

    // Optional parameters
    int nbproc = 1;
    if (params.find(NBPROC) != params.end())
      nbproc = params[NBPROC];
    int nbprocpernode = 0;
    if (params.find(NBPROCPERNODE) != params.end())
      nbprocpernode = params[NBPROCPERNODE];
    int nbnode = 0;
    if (params.find(NBNODE) != params.end())
    {
      nbnode = params[NBNODE];
      if(nbnode > 0 && nbprocpernode == 0)
      {
        nbprocpernode = nbproc / nbnode;
        if(nbprocpernode * nbnode < nbproc)
          ++nbprocpernode;
      }
    }
    if(nbprocpernode == 0) // if not defined
      nbprocpernode = 1;
    int edt = 0;
    if (params.find(MAXWALLTIME) != params.end()) 
      edt = params[MAXWALLTIME];
    int mem = 0;
    if (params.find(MAXRAMSIZE) != params.end()) 
      mem = params[MAXRAMSIZE];
    string queue = "";
    if (params.find(QUEUE) != params.end()) 
      queue = params[QUEUE].str();

    string::size_type p1 = fileToExecute.find_last_of("/");
    string::size_type p2 = fileToExecute.find_last_of(".");
    string rootNameToExecute = fileToExecute.substr(p1+1,p2-p1-1);
    string fileNameToExecute = fileToExecute.substr(p1+1);

    // Create batch submit file
    ofstream tempOutputFile;
    std::string TmpFileName = Utils::createAndOpenTemporaryFile("PBS-script", tempOutputFile);

    tempOutputFile << "#! /bin/sh -f" << endl;
    if (params.find(NAME) != params.end()) {
      tempOutputFile << "#PBS -N " << params[NAME] << endl;
    }

    if (nbproc > 0)
    {
      int nb_full_nodes = nbproc / nbprocpernode;
      int nb_proc_on_last_node = nbproc % nbprocpernode;

      // In exclusive mode, we reserve all procs on the nodes
      if (params.find(EXCLUSIVE) != params.end() && params[EXCLUSIVE] && nb_proc_on_last_node > 0) {
        nb_full_nodes += 1;
        nb_proc_on_last_node = 0;
      }

      tempOutputFile << "#PBS -l nodes=";

      // Full nodes
      if (nb_full_nodes > 0) {
        tempOutputFile << nb_full_nodes << ":ppn=" << nbprocpernode;
        if (nb_proc_on_last_node > 0) {
          tempOutputFile << "+";
        }
      }

      // Partly reserved node
      if (nb_proc_on_last_node > 0) {
        tempOutputFile << "1:ppn=" << nb_proc_on_last_node;
      }

      tempOutputFile << endl;
    }
    if (queue != "")
      tempOutputFile << "#PBS -q " << queue << endl;
    if( edt > 0 )
      tempOutputFile << "#PBS -l walltime=" << edt*60 << endl;
    if( mem > 0 )
      tempOutputFile << "#PBS -l mem=" << mem << "MB" << endl;
    tempOutputFile << "#PBS -o " << workDir << "/logs/output.log." << rootNameToExecute << endl;
    tempOutputFile << "#PBS -e " << workDir << "/logs/error.log."  << rootNameToExecute << endl;

    // Define environment for the job
    if (!env.empty()) {
      tempOutputFile << "#PBS -v ";
      Environnement::const_iterator iter;
      for (iter = env.begin() ; iter != env.end() ; ++iter) {
        tempOutputFile << iter->first << "=" << iter->second << ",";
      }
      tempOutputFile << endl;
    }

    // Define NODEFILE
    tempOutputFile << "export LIBBATCH_NODEFILE=$PBS_NODEFILE" << endl;

    // Launch the executable
    tempOutputFile << "cd " << workDir << endl;
    tempOutputFile << "./" + fileNameToExecute << endl;
    tempOutputFile.flush();
    tempOutputFile.close();

    LOG("Batch script file generated is: " << TmpFileName.c_str());

    string remoteFileName = rootNameToExecute + "_Batch.sh";
    Status status = _protocol.copyFile(TmpFileName, "", "",
                                    workDir + "/" + remoteFileName,
                                    _hostname, _username);
    if (status.hasErrors())
      throw RunTimeException(status.errorMessage());
    return remoteFileName;
  }
}
