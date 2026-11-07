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

#include <cstdlib>
#include <fstream>

#include <Constants.hxx>
#include <Utils.hxx>
#include <Log.hxx>

#include "BatchManager_OAR.hxx"
#include "JobInfo_OAR.hxx"

using namespace std;

namespace Batch
{
  BatchManager_OAR::BatchManager_OAR(const FactBatchManager * parent, const char * host,
                  const char * username,
                  CommunicationProtocolType protocolType, const char * mpiImpl)
          : BatchManager(parent, host, username, protocolType, mpiImpl)
  {
  }

  BatchManager_OAR::~BatchManager_OAR()
  {
  }

  // Soumet un job au gestionnaire
  const JobId BatchManager_OAR::runJob(const Job & job)
  {
    Parametre params = job.getParametre();
    const string workDir = params[WORKDIR];
    const string fileToExecute = params[EXECUTABLE];
    string::size_type p1 = fileToExecute.find_last_of("/");
    string::size_type p2 = fileToExecute.find_last_of(".");
    std::string fileNameToExecute = fileToExecute.substr(p1+1,p2-p1-1);

    // build batch script for job
    string scriptFile = buildBatchScript(job);

    // define command to submit batch
    string subCommand = string("oarsub -t allow_classic_ssh -d ") + workDir + " -S " + workDir + "/" + scriptFile;
    string command = _protocol.getExecCommand(subCommand, _hostname, _username);
    command += " 2>&1";
    LOG(command);

    // submit job
    string output;
    int status = Utils::getCommandOutput(command, output);
    LOG(output);
    if (status != 0) throw RunTimeException("Can't submit job, error was: " + output);

    // read id of submitted job in output
    istringstream logfile(output);
    string sline, idline, id;

    if (logfile)
    {
      while (getline(logfile, sline) && sline != "")
      {
        idline = sline;
      }

      vector<string> tokens;
      JobInfo::Tokenize(idline, tokens, "=");
      id = tokens[1];
    }
    else
    {
      throw RunTimeException("Error in the submission of the job on the remote host");
    }

    JobId jobid(this, id);
    return jobid;
  }

  // retire un job du gestionnaire
  void BatchManager_OAR::deleteJob(const JobId & jobid)
  {
    // define command to delete job
    string subCommand = "oardel " + jobid.getReference();
    string command = _protocol.getExecCommand(subCommand, _hostname, _username);
    LOG(command);

    int status = system(command.c_str());
    if (status)
      throw RunTimeException("Can't delete job " + jobid.getReference());

    LOG("job " << jobid.getReference() << " killed");
  }

  // Renvoie l'etat du job
  JobInfo BatchManager_OAR::queryJob(const JobId & jobid)
  {
    // define command to query batch
    string subCommand = "oarstat -fj " + jobid.getReference();
    string command = _protocol.getExecCommand(subCommand, _hostname, _username);
    LOG(command);
    string output;
    int status = Utils::getCommandOutput(command, output);
    if(status && status != 153 && status != 256*153)
      throw RunTimeException("Error of connection on remote host");

    JobInfo_OAR jobinfo = JobInfo_OAR(jobid.getReference(), output);
    return jobinfo;
  }

  string BatchManager_OAR::buildBatchScript(const Job & job)
  {
    Parametre params = job.getParametre();

    // Job Parameters
    string workDir       = "";
    string fileToExecute = "";
    string tmpDir = "";
    int nbproc		 = 0;
    int mem              = 0;
    string queue         = "";

    // Mandatory parameters
    if (params.find(WORKDIR) != params.end())
      workDir = params[WORKDIR].str();
    else
      throw RunTimeException("params[WORKDIR] is not defined. Please define it, cannot submit this job.");
    if (params.find(EXECUTABLE) != params.end())
      fileToExecute = params[EXECUTABLE].str();
    else
      throw RunTimeException("params[EXECUTABLE] is not defined. Please define it, cannot submit this job.");

    // Optional parameters
    if (params.find(NBPROC) != params.end())
            nbproc = params[NBPROC];
    int nbprocpernode = 1;
    if (params.find(NBPROCPERNODE) != params.end())
      nbprocpernode = params[NBPROCPERNODE];
    long walltimeSecs = 0;
    if (params.find(MAXWALLTIME) != params.end())
      walltimeSecs = (long)params[MAXWALLTIME] * 60;
    if (params.find(MAXRAMSIZE) != params.end())
            mem = params[MAXRAMSIZE];
    if (params.find(QUEUE) != params.end())
            queue = params[QUEUE].str();
    LIBBATCH_UNUSED(mem);

    string::size_type p1 = fileToExecute.find_last_of("/");
    string::size_type p2 = fileToExecute.find_last_of(".");
    string rootNameToExecute = fileToExecute.substr(p1+1,p2-p1-1);
    string fileNameToExecute = fileToExecute.substr(p1+1);

    // Create batch submit file
    ofstream tempOutputFile;
    string tmpFileName = Utils::createAndOpenTemporaryFile("OAR-script", tempOutputFile);

    tempOutputFile << "#!/bin/sh -f" << endl;

    int nb_full_nodes(0);
    int nb_proc_on_last_node(0);

    if (nbproc > 0)
    {
      nb_full_nodes = nbproc / nbprocpernode;
      nb_proc_on_last_node = nbproc % nbprocpernode;

      // In exclusive mode, we reserve all procs on the nodes
      if (params.find(EXCLUSIVE) != params.end() && params[EXCLUSIVE] && nb_proc_on_last_node > 0)
      {
        nb_full_nodes += 1;
        nb_proc_on_last_node = 0;
      }
    }

    if (nb_full_nodes > 0)
    {
      tempOutputFile << "#OAR -l nodes=" << nb_full_nodes;
      if (walltimeSecs > 0)
      {
        tempOutputFile << ",walltime=" << convertSecTo_H_M_S(walltimeSecs) << endl;
      }
      else
      {
        tempOutputFile << endl;
      }
    }
    else
    {
      if (walltimeSecs > 0)
      {
        tempOutputFile << "#OAR -l walltime=" << convertSecTo_H_M_S(walltimeSecs) << endl;
      }
    }

    if (queue != "")
    {
      tempOutputFile << "#OAR -q " << queue << endl;
    }

    tempOutputFile << "#OAR -O " << tmpDir << "/logs/output.log." << rootNameToExecute << endl;
    tempOutputFile << "#OAR -E " << tmpDir << "/logs/error.log."  << rootNameToExecute << endl;

    tempOutputFile << "export LIBBATCH_NODEFILE=$OAR_NODEFILE" << endl;

    // Launch the executable
    tempOutputFile << "cd " << tmpDir << endl;
    tempOutputFile << "./" + fileNameToExecute << endl;
    tempOutputFile.flush();
    tempOutputFile.close();

    Utils::chmod(tmpFileName.c_str(), 0x1ED);
    LOG("Batch script file generated is: " << tmpFileName);

    string remoteFileName = rootNameToExecute + "_Batch.sh";
    Status status = _protocol.copyFile(tmpFileName, "", "",
                                    workDir + "/" + remoteFileName,
                                    _hostname, _username);
    if (status.hasErrors())
      throw RunTimeException(status.errorMessage());

    return remoteFileName;
  }

  string BatchManager_OAR::convertSecTo_H_M_S(long seconds) const
  {
    int h(seconds / 3600);
    int m((seconds % 3600) / 60);
    int s((seconds % 3600) % 60);

    stringstream ss;
    ss << h << ":" << m << ":" << s;

    return ss.str();
  }
}
