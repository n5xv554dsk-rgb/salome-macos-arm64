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
 *  BatchManager_Slurm.cxx :
 *
 *  Created on: 12 may 2011
 *  Author : Renaud BARATE - EDF R&D
 */

#include <cstdlib>
#include <fstream>

#include <NotYetImplementedException.hxx>
#include <Constants.hxx>
#include <Utils.hxx>
#include <Log.hxx>

#include "BatchManager_Slurm.hxx"
#include "JobInfo_Slurm.hxx"
#include "CommandsOverloader.hxx"

using namespace std;

namespace Batch {

  BatchManager_Slurm::BatchManager_Slurm(const FactBatchManager * parent,
                                           const char * host,
                                           const char * username,
                                           CommunicationProtocolType protocolType,
                                           const char * mpiImpl)
    : BatchManager(parent, host, username, protocolType, mpiImpl)
  {
  }

  BatchManager_Slurm::~BatchManager_Slurm()
  {
  }

  // Method to submit a job to the batch manager
  const JobId BatchManager_Slurm::runJob(const Job & job)
  {
    Parametre params = job.getParametre();
    const string workDir = params[WORKDIR];

    // build command file to submit the job and copy it on the server
    string cmdFile = buildCommandFile(job);

    // define command to submit batch
    string subCommand = CommandsOverloader::getInstance().BASH_LOGIN_Command()
                        + " \\\"cd " + workDir + "; sbatch " + cmdFile + "\\\"";
    string command = _protocol.getExecCommand(subCommand, _hostname, _username);
    command += " 2>&1";
    LOG(command);

    // submit job
    string output;
    int status = Utils::getCommandOutput(command, output);
    LOG(output);
    if (status != 0) throw RunTimeException("Can't submit job, error was: " + output);

    // find id of submitted job in output
    string search = "Submitted batch job ";
    string::size_type pos = output.find(search);
    if (pos == string::npos)
      throw RunTimeException("Error in the submission of the job on the remote host");
    pos += search.size();
    string::size_type endl_pos = output.find('\n', pos);
    string::size_type count = (endl_pos == string::npos)? string::npos : endl_pos - pos;
    string jobref = output.substr(pos, count);

    JobId id(this, jobref);
    return id;
  }

  /**
   * Create Slurm command file and copy it on the server.
   * Return the name of the remote file.
   */
  string BatchManager_Slurm::buildCommandFile(const Job & job)
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
    string tmpFileName = Utils::createAndOpenTemporaryFile("slurm-script", tempOutputFile);

    tempOutputFile << "#!/bin/bash -l" << endl;
    tempOutputFile << "#SBATCH --output=" << workDir << "/logs/output.log." << rootNameToExecute << endl;
    tempOutputFile << "#SBATCH --error=" << workDir << "/logs/error.log." << rootNameToExecute << endl;

    if (params.find(NAME) != params.end())
      tempOutputFile << "#SBATCH --job-name=\"" << params[NAME] << "\"" << endl;

    // Optional parameters
    int nbproc = 1;
    if (params.find(NBPROC) != params.end())
      nbproc = params[NBPROC];
    tempOutputFile << "#SBATCH --ntasks=" << nbproc << endl;

    if (params.find(EXCLUSIVE) != params.end()) {
      if (params[EXCLUSIVE])
        tempOutputFile << "#SBATCH --exclusive" << endl;
      else
        tempOutputFile << "#SBATCH --share" << endl;
    }

    if (params.find(MAXWALLTIME) != params.end())
      tempOutputFile << "#SBATCH --time=" << params[MAXWALLTIME] << endl;
    if (params.find(MAXRAMSIZE) != params.end())
      tempOutputFile << "#SBATCH --mem=" << params[MAXRAMSIZE] << endl;
    else if (params.find(MEMPERCPU) != params.end())
      tempOutputFile << "#SBATCH --mem-per-cpu=" << params[MEMPERCPU] << endl;
    if (params.find(QUEUE) != params.end())
      tempOutputFile << "#SBATCH --qos=" << params[QUEUE] << endl;
    if (params.find(PARTITION) != params.end())
      tempOutputFile << "#SBATCH --partition=" << params[PARTITION] << endl;
    if (params.find(WCKEY) != params.end())
      tempOutputFile << "#SBATCH --wckey=" << params[WCKEY] << endl;
    if (params.find(NBNODE) != params.end())
      tempOutputFile << "#SBATCH --nodes=" << params[NBNODE] << endl;
    if (params.find(EXTRAPARAMS) != params.end())
      tempOutputFile << params[EXTRAPARAMS] << endl;

    // Define environment for the job
    Environnement env = job.getEnvironnement();
    for (Environnement::const_iterator iter = env.begin() ; iter != env.end() ; ++iter) {
      tempOutputFile << "export " << iter->first << "=" << iter->second << endl;
    }

    // generate nodes file
    tempOutputFile << "LIBBATCH_NODEFILE=$(mktemp nodefile-XXXXXXXXXX)" << endl;
    tempOutputFile << "srun hostname > \"$LIBBATCH_NODEFILE\"" << endl;
    tempOutputFile << "export LIBBATCH_NODEFILE" << endl;

    // Launch the executable
    tempOutputFile << "cd " << workDir << endl;
    tempOutputFile << "./" + fileNameToExecute;
    if (params.find(ARGUMENTS) != params.end()) {
      Versatile V = params[ARGUMENTS];
      for(Versatile::const_iterator it=V.begin(); it!=V.end(); it++) {
        StringType argt = * static_cast<StringType *>(*it);
        string     arg  = argt;
        tempOutputFile << " " << arg;
      }
    }
    tempOutputFile << endl;

    // Remove the node file
    tempOutputFile << "rm \"$LIBBATCH_NODEFILE\"" << endl;

    tempOutputFile.flush();
    tempOutputFile.close();

    LOG("Batch script file generated is: " << tmpFileName);

    string remoteFileName = rootNameToExecute + "_slurm.cmd";
    Status status = _protocol.copyFile(tmpFileName, "", "",
                                    workDir + "/" + remoteFileName,
                                    _hostname, _username);
    if (status.hasErrors())
      throw RunTimeException(status.errorMessage());

    return remoteFileName;
  }

  void BatchManager_Slurm::deleteJob(const JobId & jobid)
  {
    // define command to delete job
    string subCommand = CommandsOverloader::getInstance().BASH_LOGIN_Command()
                        + " \\\"scancel " + jobid.getReference() + "\\\"";
    string command = _protocol.getExecCommand(subCommand, _hostname, _username);
    LOG(command);

    int status = system(command.c_str());
    if (status)
      throw RunTimeException("Can't delete job " + jobid.getReference());

    LOG("job " << jobid.getReference() << " killed");
  }

  JobInfo BatchManager_Slurm::queryJob(const JobId & jobid)
  {
    // First try to query the job with "squeue" command
    string subCommand = CommandsOverloader::getInstance().BASH_LOGIN_Command()
                        + " \\\"squeue -h -o %T -j " + jobid.getReference() + " 2>/dev/null" + "\\\"";
    string command = _protocol.getExecCommand(subCommand, _hostname, _username);
    LOG(command);
    string output;
    int status = Utils::getCommandOutput(command, output);
    LOG("status: " << status << ", output: " << output);
    bool found = false;
    JobInfo jobinfo;
    if (status == 0) {
        try {
            jobinfo = JobInfo_Slurm(jobid.getReference(), output);
            found = true;
        } catch (const RunTimeException & exc) {
            LOG(exc);
        }
    }

    // If "squeue" failed, the job may be finished. In this case, try to query the job with
    // "sacct".
    if (! found) {
        string subCommand = CommandsOverloader::getInstance().BASH_LOGIN_Command()
                            + " \\\"sacct -X -o State%-10 -n -j " + jobid.getReference() + "\\\"";
        string command = _protocol.getExecCommand(subCommand, _hostname, _username);
        LOG(command);
        string output;
        int status = Utils::getCommandOutput(command, output);
        LOG("status: " << status << ", output: " << output);
        if (status == 0) {
            try {
                jobinfo = JobInfo_Slurm(jobid.getReference(), output);
            } catch (const RunTimeException & exc) {
                LOG(exc);
                throw(exc);
            }
        } else {
            throw RunTimeException("sacct command failed with return code: " + to_string(status));
        }
    }
    return jobinfo;
  }

}
