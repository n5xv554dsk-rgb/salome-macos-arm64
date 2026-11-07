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
 * BatchManager_CCC.cxx : emulation of CCC client for CCRT machines
 *
 * Auteur : Bernard SECHER - CEA DEN
 * Mail   : mailto:bernard.secher@cea.fr
 * Date   : Thu Apr 24 10:17:22 2010
 * Projet : PAL Salome
 *
 */

#include <stdlib.h>
#include <string.h>

#include <iostream>
#include <fstream>
#include <sstream>
#include <string>

#include <stdlib.h>
#include <string.h>

#ifdef WIN32
#include <io.h>
#else
#include <libgen.h>
#endif

#include <Constants.hxx>
#include <NotYetImplementedException.hxx>
#include <Utils.hxx>

#include "BatchManager_CCC.hxx"
#include "JobInfo_CCC.hxx"
#include "Log.hxx"
#include "CommandsOverloader.hxx"

using namespace std;

namespace Batch {

  BatchManager_CCC::BatchManager_CCC(const FactBatchManager * parent, const char * host,
                                       const char * username,
                                       CommunicationProtocolType protocolType, const char * mpiImpl)
  : BatchManager(parent, host, username, protocolType, mpiImpl)
  {
    // Nothing to do
  }

  // Destructeur
  BatchManager_CCC::~BatchManager_CCC()
  {
    // Nothing to do
  }

  // Methode pour le controle des jobs : soumet un job au gestionnaire
  const JobId BatchManager_CCC::runJob(const Job & job)
  {
    Parametre params = job.getParametre();
    const std::string workDir = params[WORKDIR];
    const string fileToExecute = params[EXECUTABLE];
    string::size_type p1 = fileToExecute.find_last_of("/");
    string::size_type p2 = fileToExecute.find_last_of(".");
    std::string fileNameToExecute = fileToExecute.substr(p1+1,p2-p1-1);

    // build batch script for job
    LOG("Construction du script de batch");
    buildBatchScript(job);
    LOG("Script envoye");

    // define command to submit batch
    string subCommand = CommandsOverloader::getInstance().BASH_LOGIN_Command()
                        + " \\\"cd " + workDir + "; ccc_msub " + fileNameToExecute + "_Batch.sh\\\"";
    string command = _protocol.getExecCommand(subCommand, _hostname, _username);
    command += " 2>&1";
    LOG(command);

    // submit job
    string output;
    int status = Utils::getCommandOutput(command, output);
    LOG(output);
    if (status != 0) throw RunTimeException("Can't submit job, error was: " + output);

    // find id of submitted job in output
    istringstream idfile(output);
    string sidj;
    idfile >> sidj;
    idfile >> sidj;
    idfile >> sidj;
    idfile >> sidj;
    if (sidj.size() == 0)
      throw RunTimeException("Error in the submission of the job on the remote host");

    JobId id(this, sidj);
    return id;
  }

  // Methode pour le controle des jobs : retire un job du gestionnaire
  void BatchManager_CCC::deleteJob(const JobId & jobid)
  {
    int status;
    int ref;
    istringstream iss(jobid.getReference());
    iss >> ref;

    // define command to delete batch
    string subCommand = CommandsOverloader::getInstance().BASH_LOGIN_Command()
                        + " \\\"ccc_mdel " + iss.str() + string("\\\"");
    string command = _protocol.getExecCommand(subCommand, _hostname, _username);
    LOG(command);
    status = system(command.c_str());
    if (status)
      throw RunTimeException("Error of connection on remote host");

    LOG("jobId = " << ref << "killed");
  }

  // Methode pour le controle des jobs : renvoie l'etat du job
  JobInfo BatchManager_CCC::queryJob(const JobId & jobid)
  {
    int id;
    istringstream iss(jobid.getReference());
    iss >> id;

    // define command to query batch
    string subCommand = CommandsOverloader::getInstance().BASH_LOGIN_Command()
                        + " \\\"bjobs " + iss.str() + string("\\\"");
    string command = _protocol.getExecCommand(subCommand, _hostname, _username);
    LOG(command);

    string output;
    int status = Utils::getCommandOutput(command, output);
    if (status)
      throw RunTimeException("Error of connection on remote host");

    JobInfo_CCC ji = JobInfo_CCC(id, output);
    return ji;
  }



  // Methode pour le controle des jobs : teste si un job est present en machine
  bool BatchManager_CCC::isRunning(const JobId & /*jobid*/)
  {
    throw NotYetImplementedException("BatchManager_CCC::isRunning");
  }

  void BatchManager_CCC::buildBatchScript(const Job & job)
  {
#ifndef WIN32 //TODO: need for porting on Windows
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
      edt = (long)params[MAXWALLTIME] * 60;
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

    tempOutputFile << "#!/bin/bash" << endl ;
    if (queue != "")
      tempOutputFile << "#MSUB -q " << queue << endl;
    if( edt > 0 )
      tempOutputFile << "#MSUB -T " << edt << endl ;
    if( mem > 0 )
      tempOutputFile << "#MSUB -M " << mem << endl ;
    tempOutputFile << "#MSUB -n " << nbproc << endl ;
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
    tempOutputFile << "#MSUB -o " << baseDir << "/logs/output.log." << rootNameToExecute << endl ;
    tempOutputFile << "#MSUB -e " << baseDir << "/logs/error.log." << rootNameToExecute << endl ;

    if (params.find(EXTRAPARAMS) != params.end())
      tempOutputFile << params[EXTRAPARAMS] << endl;

    tempOutputFile << "cd " << workDir << endl ;

    // generate nodes file
    tempOutputFile << "bool=0" << endl;
    tempOutputFile << "for i in $LSB_MCPU_HOSTS; do" << endl;
    tempOutputFile << "  if test $bool = 0; then" << endl;
    tempOutputFile << "    n=$i" << endl;
    tempOutputFile << "    bool=1" << endl;
    tempOutputFile << "  else" << endl;
    tempOutputFile << "    for ((j=0;j<$i;j++)); do" << endl;
    tempOutputFile << "      echo $n >> nodesFile." << rootNameToExecute << endl;
    tempOutputFile << "    done" << endl;
    tempOutputFile << "    bool=0" << endl;
    tempOutputFile << "  fi" << endl;
    tempOutputFile << "done" << endl;

    // Abstraction of PBS_NODEFILE - TODO
    tempOutputFile << "export LIBBATCH_NODEFILE=nodesFile." << rootNameToExecute << endl;

    // Allow resource sharing in CCRT nodes
    tempOutputFile << "export OMPI_MCA_orte_process_binding=none" << endl;

    // Launch the executable
    tempOutputFile << "./" + fileNameToExecute << endl;
    tempOutputFile.flush();
    tempOutputFile.close();

    Utils::chmod(TmpFileName.c_str(), 0x1ED);
    LOG("Batch script file generated is: " << TmpFileName.c_str());

    Status status = _protocol.copyFile(TmpFileName, "", "",
                                    workDir + "/" + rootNameToExecute + "_Batch.sh",
                                    _hostname, _username);
    if (status.hasErrors())
      throw RunTimeException(status.errorMessage());

#endif

  }

  std::string BatchManager_CCC::getHomeDir(std::string tmpdir)
  {
    std::string home;

    string subCommand = string("echo ");
    subCommand += tmpdir;
    string command = _protocol.getExecCommand(subCommand, _hostname, _username);
    LOG(command);

    string output;
    int status = Utils::getCommandOutput(command, output);

    if (status)
      throw RunTimeException("Error of launching home command on remote host");

    std::istringstream file_home(output);
    std::getline(file_home, home);
    return home;
  }

}
