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
 * BatchManager_LSF.cxx : emulation of LSF client
 *
 * Auteur : Bernard SECHER - CEA DEN
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
#include "BatchManager_LSF.hxx"
#include "JobInfo_LSF.hxx"
#include "Log.hxx"

using namespace std;

namespace Batch {

  BatchManager_LSF::BatchManager_LSF(const FactBatchManager * parent, const char * host,
                                       const char * username,
                                       CommunicationProtocolType protocolType, const char * mpiImpl)
  : BatchManager(parent, host, username, protocolType, mpiImpl)
  {
    // Nothing to do
  }

  // Destructeur
  BatchManager_LSF::~BatchManager_LSF()
  {
    // Nothing to do
  }

  // Methode pour le controle des jobs : soumet un job au gestionnaire
  const JobId BatchManager_LSF::runJob(const Job & job)
  {
    Parametre params = job.getParametre();
    const std::string workDir = params[WORKDIR];

    // build batch script for job
    LOG("Construction du script de batch");
    string scriptFile = buildSubmissionScript(job);
    LOG("Script envoye");

    // define command to submit batch
    string subCommand = string("cd ") + workDir + "; bsub < " + scriptFile;
    string command = _protocol.getExecCommand(subCommand, _hostname, _username);
    command += " 2>&1";
    LOG(command);

    string output;
    int status = Utils::getCommandOutput(command, output);
    LOG(output);
    if (status != 0) throw RunTimeException("Can't submit job, error was: " + output);

    // read id of submitted job in output
    int p10 = output.find("<");
    int p20 = output.find(">");
    string strjob = output.substr(p10+1,p20-p10-1);

    JobId id(this, strjob);
    return id;
  }

  // Methode pour le controle des jobs : retire un job du gestionnaire
  void BatchManager_LSF::deleteJob(const JobId & jobid)
  {
    int status;
    int ref;
    istringstream iss(jobid.getReference());
    iss >> ref;

    // define command to delete batch
    string subCommand = string("bkill ") + iss.str();
    string command = _protocol.getExecCommand(subCommand, _hostname, _username);
    LOG(command);
    status = system(command.c_str());
    if (status)
      throw RunTimeException("Error of connection on remote host");

    LOG("jobId = " << ref << "killed");
  }

  // Methode pour le controle des jobs : renvoie l'etat du job
  JobInfo BatchManager_LSF::queryJob(const JobId & jobid)
  {
    int id;
    istringstream iss(jobid.getReference());
    iss >> id;

    // define command to query batch
    string subCommand = string("bjobs ") + iss.str();
    string command = _protocol.getExecCommand(subCommand, _hostname, _username);
    LOG(command);

    string output;
    int status = Utils::getCommandOutput(command, output);
    if (status) throw RunTimeException("Error of connection on remote host");

    JobInfo_LSF ji = JobInfo_LSF(id, output);
    return ji;
  }



  // Methode pour le controle des jobs : teste si un job est present en machine
  bool BatchManager_LSF::isRunning(const JobId & /*jobid*/)
  {
    throw NotYetImplementedException("BatchManager_LSF::isRunning");
  }

  std::string BatchManager_LSF::buildSubmissionScript(const Job & job)
  {
    Parametre params = job.getParametre();

    // Job Parameters
    string workDir       = "";
    string fileToExecute = "";
    int nbproc		 = 0;
    int edt		 = 0;
    int mem              = 0;
    string queue         = "";

    // Mandatory parameters
    if (params.find(WORKDIR) != params.end()) 
      workDir = params[WORKDIR].str();
    else 
      throw RunTimeException("params[WORKDIR] is not defined ! Please defined it, cannot submit this job");
    if (params.find(EXECUTABLE) != params.end()) 
      fileToExecute = params[EXECUTABLE].str();
    else 
      throw RunTimeException("params[EXECUTABLE] is not defined ! Please defined it, cannot submit this job");

    // Optional parameters
    if (params.find(NBPROC) != params.end()) 
      nbproc = params[NBPROC];
    if (params.find(MAXWALLTIME) != params.end()) 
      edt = params[MAXWALLTIME];
    if (params.find(MAXRAMSIZE) != params.end()) 
      mem = params[MAXRAMSIZE];
    if (params.find(QUEUE) != params.end()) 
      queue = params[QUEUE].str();

    string::size_type p1 = fileToExecute.find_last_of("/");
    string::size_type p2 = fileToExecute.find_last_of(".");
    string rootNameToExecute = fileToExecute.substr(p1+1,p2-p1-1);
    string fileNameToExecute = fileToExecute.substr(p1+1);
 
    // Create batch submit file
    ofstream tempOutputFile;
    std::string TmpFileName = Utils::createAndOpenTemporaryFile("LSF-script", tempOutputFile);

    tempOutputFile << "#! /bin/sh -f" << endl ;
    if (params.find(NAME) != params.end())
      tempOutputFile << "#BSUB -J " << params[NAME] << endl;
    if (queue != "")
      tempOutputFile << "#BSUB -q " << queue << endl;
    if( edt > 0 )
      tempOutputFile << "#BSUB -W " << getWallTime(edt) << endl ;
    if( mem > 0 )
      tempOutputFile << "#BSUB -M " << mem*1024 << endl ;
    tempOutputFile << "#BSUB -n " << nbproc << endl ;

    if (params.find(EXCLUSIVE) != params.end() && params[EXCLUSIVE]) {
      tempOutputFile << "#BSUB -x" << endl ;
    }

    size_t pos = workDir.find("$HOME");
    string baseDir;
    if( pos != string::npos )
      baseDir = getHomeDir(workDir) + workDir.substr(pos+5,workDir.length()-5);
    else{
      pos = workDir.find("~");
      if( pos != string::npos )
	baseDir = getHomeDir(workDir) + workDir.substr(pos+1,workDir.length()-1);
      else
	baseDir = workDir;
    }
    tempOutputFile << "#BSUB -o " << baseDir << "/logs/output.log." << rootNameToExecute << endl ;
    tempOutputFile << "#BSUB -e " << baseDir << "/logs/error.log." << rootNameToExecute << endl ;

    // Define environment for the job
    Environnement env = job.getEnvironnement();
    for (Environnement::const_iterator iter = env.begin() ; iter != env.end() ; ++iter) {
      tempOutputFile << "export " << iter->first << "=" << iter->second << endl;
    }

    tempOutputFile << "cd " << workDir << endl ;

    // generate nodes file
    tempOutputFile << "LIBBATCH_NODEFILE=$(mktemp nodefile-XXXXXXXXXX) || exit 1" << endl;
    tempOutputFile << "bool=0" << endl;
    tempOutputFile << "for i in $LSB_MCPU_HOSTS; do" << endl;
    tempOutputFile << "  if test $bool = 0; then" << endl;
    tempOutputFile << "    n=$i" << endl;
    tempOutputFile << "    bool=1" << endl;
    tempOutputFile << "  else" << endl;
    tempOutputFile << "    for ((j=0;j<$i;j++)); do" << endl;
    tempOutputFile << "      echo $n >> $LIBBATCH_NODEFILE" << endl;
    tempOutputFile << "    done" << endl;
    tempOutputFile << "    bool=0" << endl;
    tempOutputFile << "  fi" << endl;
    tempOutputFile << "done" << endl;
    tempOutputFile << "export LIBBATCH_NODEFILE" << endl;

    // Launch the executable
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
    tempOutputFile << "rm $LIBBATCH_NODEFILE" << endl;

    tempOutputFile.flush();
    tempOutputFile.close();

    LOG("Batch script file generated is: " << TmpFileName.c_str());

    string remoteFileName = rootNameToExecute + "_Batch.sh";
    Status status = _protocol.copyFile(TmpFileName, "", "",
                                    workDir + "/" + remoteFileName,
                                    _hostname, _username);
    if (status.hasErrors())
      throw RunTimeException("Error of connection on remote host");
    return remoteFileName;
  }

  std::string BatchManager_LSF::getWallTime(const long edt)
  {
    long h, m;
    h = edt / 60;
    m = edt - h*60;
    ostringstream oss;
    if( m >= 10 )
      oss << h << ":" << m;
    else
      oss << h << ":0" << m;
    return oss.str();
  }

  std::string BatchManager_LSF::getHomeDir(std::string tmpdir)
  {
    std::string home;
    int idx = tmpdir.find("Batch/");
    std::string filelogtemp = tmpdir.substr(idx+6, tmpdir.length());
    filelogtemp = "/tmp/logs" + filelogtemp + "_home";

    string subCommand = string("echo $HOME");
    string command = _protocol.getExecCommand(subCommand, _hostname, _username) + " > " + filelogtemp;
    LOG(command);
    int status = system(command.c_str());
    if (status)
      throw RunTimeException("Error of launching home command on remote host");

    std::ifstream file_home(filelogtemp.c_str());
    std::getline(file_home, home);
    file_home.close();
    return home;
  }

}
