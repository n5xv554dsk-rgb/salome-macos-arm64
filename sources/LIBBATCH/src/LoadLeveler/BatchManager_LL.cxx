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
 *  BatchManager_LL.cxx :
 *
 *  Created on: 25 nov. 2010
 *  Author : Renaud BARATE - EDF R&D
 */

#include <cstdlib>
#include <iostream>
#include <fstream>
#include <sstream>

#include <Constants.hxx>
#include <Utils.hxx>

#include "FactBatchManager_LL.hxx"
#include "BatchManager_LL.hxx"
#include "JobInfo_LL.hxx"
#include "Log.hxx"

using namespace std;

namespace Batch {

  BatchManager_LL::BatchManager_LL(const FactBatchManager * parent, const char * host,
                                     const char * username,
                                     CommunicationProtocolType protocolType, const char * mpiImpl)
    : BatchManager(parent, host, username, protocolType, mpiImpl)
  {
    // Nothing to do
  }

  BatchManager_LL::~BatchManager_LL()
  {
    // Nothing to do
  }

  // Method to submit a job to the batch manager
  const JobId BatchManager_LL::runJob(const Job & job)
  {
    Parametre params = job.getParametre();
    const string workDir = params[WORKDIR];

    // build command file to submit the job and copy it on the server
    string cmdFile = buildCommandFile(job);

    // define command to submit batch
    string subCommand = string("cd ") + workDir + "; llsubmit " + cmdFile;
    string command = _protocol.getExecCommand(subCommand, _hostname, _username);
    LOG(command);

    // submit job
    string output;
    int status = Utils::getCommandOutput(command, output);
    LOG(output);
    if (status != 0) throw RunTimeException("Can't submit job, error was: " + output);

    // find id of submitted job in output
    string jobref;
    istringstream idfile(output);
    string line;
    while (idfile && line.compare(0, 9, "llsubmit:") != 0)
      getline(idfile, line);
    if (line.compare(0, 9, "llsubmit:") == 0)
    {
      string::size_type p1 = line.find_first_of("\"");
      string::size_type p2 = line.find_last_of("\"");
      if (p1 != p2)
        jobref = line.substr(p1 + 1, p2 - p1 - 1);
    }
    if (jobref.size() == 0)
      throw RunTimeException("Error in the submission of the job on the remote host");

    JobId id(this, jobref);
    return id;
  }

  /**
   * Create LoadLeveler command file and copy it on the server.
   * Return the name of the remote file.
   */
  string BatchManager_LL::buildCommandFile(const Job & job)
  {
    Parametre params = job.getParametre();

    // Job Parameters
    string workDir = "";
    string fileToExecute = "";
    string queue = "";

    // Mandatory parameters
    if (params.find(WORKDIR) != params.end()) 
      workDir = params[WORKDIR].str();
    else 
      throw RunTimeException("params[WORKDIR] is not defined. Please define it, cannot submit this job.");
    if (params.find(EXECUTABLE) != params.end()) 
      fileToExecute = params[EXECUTABLE].str();
    else 
      throw RunTimeException("params[EXECUTABLE] is not defined. Please define it, cannot submit this job.");

    string::size_type p1 = fileToExecute.find_last_of("/");
    string::size_type p2 = fileToExecute.find_last_of(".");
    string rootNameToExecute = fileToExecute.substr(p1+1,p2-p1-1);
    string fileNameToExecute = fileToExecute.substr(p1+1);

    // Create batch submit file
    ofstream tempOutputFile;
    string tmpFileName = Utils::createAndOpenTemporaryFile("LL-script", tempOutputFile);

    tempOutputFile << "#!/bin/bash" << endl;
    tempOutputFile << "# @ output = " << workDir << "/logs/output.log." << rootNameToExecute << endl;
    tempOutputFile << "# @ error = " << workDir << "/logs/error.log." << rootNameToExecute << endl;

    if (params.find(NAME) != params.end())
      tempOutputFile << "# @ job_name = " << params[NAME] << endl;

    // Optional parameters
    int nbproc = 1;
    if (params.find(NBPROC) != params.end())
      nbproc = params[NBPROC];
    int nbprocpernode = 1;
    if (params.find(NBPROCPERNODE) != params.end())
      nbprocpernode = params[NBPROCPERNODE];

    if (params.find(EXCLUSIVE) != params.end()) {
      if (params[EXCLUSIVE])
        tempOutputFile << "# @ node_usage = not_shared" << endl;
      else
        tempOutputFile << "# @ node_usage = shared" << endl;
    }

    // If job type is not specified, try to guess it from number of procs
    string job_type;
    if (params.find(LL_JOBTYPE) != params.end())
      job_type = params[LL_JOBTYPE].str();
    else if (nbproc == 1)
      job_type = "serial";
    else
      job_type = "mpich";

    tempOutputFile << "# @ job_type = " << job_type << endl;

    if (job_type == "mpich") {
      int nodes_requested = (nbproc + nbprocpernode -1) / nbprocpernode;
      tempOutputFile << "# @ node = " << nodes_requested << endl;
      tempOutputFile << "# @ total_tasks = " << nbproc << endl;
    }

    if (params.find(MAXWALLTIME) != params.end())
      tempOutputFile << "# @ wall_clock_limit = " << params[MAXWALLTIME] << ":00" << endl;
    if (params.find(MAXRAMSIZE) != params.end())
      tempOutputFile << "# @ as_limit = " << params[MAXRAMSIZE] << "mb" << endl;
    if (params.find(QUEUE) != params.end())
      tempOutputFile << "# @ class = " << params[QUEUE] << endl;

    // Define environment for the job
    Environnement env = job.getEnvironnement();
    if (!env.empty()) {
      tempOutputFile << "# @ environment = ";
      Environnement::const_iterator iter;
      for (iter = env.begin() ; iter != env.end() ; ++iter) {
        tempOutputFile << iter->first << "=" << iter->second << "; ";
      }
      tempOutputFile << endl;
    }

    tempOutputFile << "# @ queue" << endl;

    // generate nodes file
    tempOutputFile << "export LIBBATCH_NODEFILE=$LOADL_HOSTFILE" << endl;

    // Launch the executable
    tempOutputFile << "cd " << workDir << endl;
    tempOutputFile << "./" + fileNameToExecute << endl;

    tempOutputFile.flush();
    tempOutputFile.close();

    LOG("Batch script file generated is: " << tmpFileName);

    string remoteFileName = rootNameToExecute + "_LL.cmd";
    Status status = _protocol.copyFile(tmpFileName, "", "",
                                    workDir + "/" + remoteFileName,
                                    _hostname, _username);
    if (status.hasErrors())
      throw RunTimeException(status.errorMessage());

    return remoteFileName;
  }

  void BatchManager_LL::deleteJob(const JobId & jobid)
  {
    // define command to delete job
    string subCommand = "llcancel " + jobid.getReference();
    string command = _protocol.getExecCommand(subCommand, _hostname, _username);
    LOG(command);

    int status = system(command.c_str());
    if (status)
      throw RunTimeException("Can't delete job " + jobid.getReference());

    LOG("job " << jobid.getReference() << " killed");
  }

  JobInfo BatchManager_LL::queryJob(const JobId & jobid)
  {
    // define command to query batch
    string subCommand = "llq -f %st " + jobid.getReference();
    string command = _protocol.getExecCommand(subCommand, _hostname, _username);
    LOG(command);
    string output;
    int status = Utils::getCommandOutput(command, output);
    if (status != 0)
      throw RunTimeException("Can't query job " + jobid.getReference());

    JobInfo_LL jobinfo = JobInfo_LL(jobid.getReference(), output);
    return jobinfo;
  }

}
