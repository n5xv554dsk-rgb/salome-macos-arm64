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
 * BatchManager_SGE.cxx : emulation of SGE client
 *
 * Auteur : Bernard SECHER - CEA DEN
 * Mail   : mailto:bernard.secher@cea.fr
 * Date   : Thu Apr 24 10:17:22 2008
 * Projet : PAL Salome
 *
 */

#include <stdlib.h>
#include <string.h>

#include <iostream>
#include <fstream>
#include <sstream>

#include <stdlib.h>
#include <string.h>

#ifdef WIN32
#include <io.h>
#else
#include <libgen.h>
#endif

#include <Constants.hxx>
#include <Utils.hxx>
#include <NotYetImplementedException.hxx>

#include "BatchManager_SGE.hxx"
#include "JobInfo_SGE.hxx"
#include "Log.hxx"
#include "CommandsOverloader.hxx"

using namespace std;

namespace Batch {

  BatchManager_SGE::BatchManager_SGE(const FactBatchManager * parent, const char * host,
                                       const char * username,
                                       CommunicationProtocolType protocolType, const char * mpiImpl)
  : BatchManager(parent, host, username, protocolType, mpiImpl)
  {
    // Nothing to do
  }

  // Destructeur
  BatchManager_SGE::~BatchManager_SGE()
  {
    // Nothing to do
  }

  // Methode pour le controle des jobs : soumet un job au gestionnaire
  const JobId BatchManager_SGE::runJob(const Job & job)
  {
    Parametre params = job.getParametre();
    const std::string workDir = params[WORKDIR];
    const string fileToExecute = params[EXECUTABLE];
    string::size_type p1 = fileToExecute.find_last_of("/");
    string::size_type p2 = fileToExecute.find_last_of(".");
    std::string fileNameToExecute = fileToExecute.substr(p1+1,p2-p1-1);

    // build batch script for job
    buildBatchScript(job);

    // define command to submit batch
    string subCommand = CommandsOverloader::getInstance().BASH_LOGIN_Command()
                        + " \\\"cd " + workDir + "; qsub " + fileNameToExecute + "_Batch.sh\\\"";
    string command = _protocol.getExecCommand(subCommand, _hostname, _username);
    command += " 2>&1";
    LOG(command);

    // submit job
    string output;
    int status = Utils::getCommandOutput(command, output);
    LOG(output);
    if (status != 0) throw RunTimeException("Can't submit job, error was: " + output);

    // find id of submitted job in output
    string strjob;
    istringstream iss(output);
    iss >> strjob >> strjob >> strjob;

    JobId id(this, strjob);
    return id;
  }


  // Methode pour le controle des jobs : retire un job du gestionnaire
  void BatchManager_SGE::deleteJob(const JobId & jobid)
  {
    int status;
    int ref;
    istringstream iss(jobid.getReference());
    iss >> ref;

    // define command to delete batch
    string subCommand = CommandsOverloader::getInstance().BASH_LOGIN_Command()
                        + " \\\"qdel " + iss.str() + string("\\\"");
    string command = _protocol.getExecCommand(subCommand, _hostname, _username);
    LOG(command);
    status = system(command.c_str());
    if(status)
      throw RunTimeException("Error of connection on remote host");

    LOG("jobId = " << ref << "killed");
  }

  // Methode pour le controle des jobs : renvoie l'etat du job
  JobInfo BatchManager_SGE::queryJob(const JobId & jobid)
  {
    int id;
    istringstream iss(jobid.getReference());
    iss >> id;

    // define command to query batch
    string subCommand = CommandsOverloader::getInstance().BASH_LOGIN_Command()
                        + " \\\"qstat | grep " + iss.str() + string("\\\"");
    string command = _protocol.getExecCommand(subCommand, _hostname, _username);
    LOG(command);

    string output;
    int status = Utils::getCommandOutput(command, output);
    if (status && status != 256)
      throw RunTimeException("Error of connection on remote host");

    JobInfo_SGE ji = JobInfo_SGE(id, output);
    return ji;
  }

  // Methode pour le controle des jobs : teste si un job est present en machine
  bool BatchManager_SGE::isRunning(const JobId & /*jobid*/)
  {
    throw NotYetImplementedException("BatchManager_SGE::isRunning");
  }

  void BatchManager_SGE::buildBatchScript(const Job & job)
  {
#ifndef WIN32
    //TODO porting on Win32 platform
    LOG("BuildBatchScript");
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
    std::string TmpFileName = Utils::createAndOpenTemporaryFile("SGE-script", tempOutputFile);

    tempOutputFile << "#! /bin/sh -f" << endl;
    if (queue != "")
      tempOutputFile << "#$ -q " << queue << endl;
    tempOutputFile << "#$ -pe " << _mpiImpl->name() << " " << nbproc << endl;
    if( edt > 0 )
      tempOutputFile << "#$ -l h_rt=" << getWallTime(edt) << endl ;
    if( mem > 0 )
      tempOutputFile << "#$ -l h_vmem=" << mem << "M" << endl ;
    tempOutputFile << "#$ -o " << workDir << "/logs/output.log." << rootNameToExecute << endl ;
    tempOutputFile << "#$ -e " << workDir << "/logs/error.log." << rootNameToExecute << endl ;

    // Abstraction of PBS_NODEFILE - TODO
    tempOutputFile << "export LIBBATCH_NODEFILE=$TMPDIR/machines" << endl;

    // Launch the executable
    tempOutputFile << "cd " << workDir << endl ;
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

#endif //WIN32
  }

  std::string BatchManager_SGE::getWallTime(const long edt)
  {
    long h, m;
    h = edt / 60;
    m = edt - h*60;
    ostringstream oss;
    if( m >= 10 )
      oss << h << ":" << m;
    else
      oss << h << ":0" << m;
    oss << ":00"; // the seconds

    return oss.str();
  }

}
