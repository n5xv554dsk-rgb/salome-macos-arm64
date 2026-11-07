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

#include "BatchManager_COORM.hxx"
#include "JobInfo_COORM.hxx"

using namespace std;

namespace Batch
{
      BatchManager_COORM::BatchManager_COORM(const FactBatchManager * parent, const char * host,
                      const char * username,
                      CommunicationProtocolType protocolType, const char * mpiImpl)
              : BatchManager(parent, host, username, protocolType, mpiImpl)
      {
      }

      BatchManager_COORM::~BatchManager_COORM()
      {
      }

      // Soumet un job au gestionnaire
      const JobId BatchManager_COORM::runJob(const Job & job)
      {
              Parametre params = job.getParametre();
              const string workDir = params[WORKDIR];
              const string fileToExecute = params[EXECUTABLE];

              // For CooRM
              const string launcherArgs = params[LAUNCHER_ARGS];
              const string launcherFile  = params[LAUNCHER_FILE];

              const string jobName = params[NAME];

              string::size_type p1 = fileToExecute.find_last_of("/");
              string::size_type p2 = fileToExecute.find_last_of(".");
              std::string fileNameToExecute = fileToExecute.substr(p1+1,p2-p1-1);

              // For CooRM
              p1 = launcherFile.find_last_of("/");
              std::string fileNameToLaunch = launcherFile.substr(p1+1);

              // build batch script for job
              string scriptFile = buildBatchScript(job);

              // Get REMOTE_COORM_PATH environment variable
              const char * remote_coorm_path = getenv("REMOTE_COORM_PATH");
              if (remote_coorm_path == NULL)
              {
                      throw RunTimeException("Unable to get REMOTE_COORM_PATH environment variable");
              }

              // We need omniORB to execute launcher.py
              const string set_env_cmd = "source " + string(remote_coorm_path) + "/coorm_prerequis.sh;";


              // define command to submit batch
              string subCommand = set_env_cmd + "python " + workDir + "/" + fileNameToLaunch + " --name="+ jobName +
                                  " --workdir=" + workDir + " --outputs=" + workDir + "/logs/outputs.log" +
                                  " --errors=" + workDir + "/logs/errors.log" +
                                  " --executable=" + scriptFile + " " + launcherArgs;
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
                id = tokens[1] ;
              }
              else
              {
                throw RunTimeException("Error in the submission of the job on the remote host");
              }

              JobId jobid(this, (string) id);
              return jobid;
              }

              // retire un job du gestionnaire
              void BatchManager_COORM::deleteJob(const JobId & jobid)
              {
              // Get REMOTE_COORM_PATH environment variable
              const char * remote_coorm_path = getenv("REMOTE_COORM_PATH");
              if (remote_coorm_path == NULL)
              {
                throw RunTimeException("Unable to get REMOTE_COORM_PATH environment variable");
              }

              // We need omniORB to execute launcher.py
              const string set_env_cmd = "source " + string(remote_coorm_path) + "/coorm_prerequis.sh;";

              // define command to delete job
              string subCommand = set_env_cmd + "python " + string(remote_coorm_path) + "/coormdel.py --jobID=" + jobid.getReference();
              string command = _protocol.getExecCommand(subCommand, _hostname, _username);
              LOG(command);

              int status = system(command.c_str());
              if (status)
                throw RunTimeException("Can't delete job " + jobid.getReference());

              LOG("job " << jobid.getReference() << " killed");
      }

      // Renvoie l'etat du job
      JobInfo BatchManager_COORM::queryJob(const JobId & jobid)
      {
        // Get REMOTE_COORM_PATH environment variable
        const char * remote_coorm_path = getenv("REMOTE_COORM_PATH");
        if (remote_coorm_path == NULL)
        {
          throw RunTimeException("Unable to get REMOTE_COORM_PATH environment variable");
        }

        // We need omniORB to execute launcher.py
        const string set_env_cmd = "source " + string(remote_coorm_path) + "/coorm_prerequis.sh;";

        // define command to query batch
        string subCommand = set_env_cmd + "python " + string(remote_coorm_path) + "/coormstat.py --jobID=" + jobid.getReference();
        string command = _protocol.getExecCommand(subCommand, _hostname, _username);
        LOG(command);
        string output;
        int status = Utils::getCommandOutput(command, output);
        if(status && status != 153 && status != 256*153)
          throw RunTimeException("Error of connection on remote host");

        JobInfo_COORM jobinfo = JobInfo_COORM(jobid.getReference(), output);
        return jobinfo;
      }

      string BatchManager_COORM::buildBatchScript(const Job & job)
      {
        Parametre params = job.getParametre();

        // Job Parameters
        string workDir       = "";
        string fileToExecute = "";
        string tmpDir = "";
        int nbproc		 = 0;
        int edt		 = 0;
        int mem              = 0;
        string queue         = "";
        LIBBATCH_UNUSED(nbproc);
        LIBBATCH_UNUSED(edt);
        LIBBATCH_UNUSED(mem);

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
        string tmpFileName = Utils::createAndOpenTemporaryFile("COORM-script", tempOutputFile);

        tempOutputFile << "#!/bin/sh -f" << endl;
        tempOutputFile << "export LIBBATCH_NODEFILE=$COORM_NODEFILE" << endl;
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
          throw RunTimeException("Cannot copy batch submission file on host " + _hostname);

        return remoteFileName;
      }

      void BatchManager_COORM::exportInputFiles(const Job & job)
      {
        BatchManager::exportInputFiles(job);

        Parametre params = job.getParametre();

        string launcherFile = params[LAUNCHER_FILE];

        if (launcherFile.size() != 0)
        {
          // Copy launcherFile into batch working directory
          Status status = _protocol.copyFile(launcherFile, "", "",
                                      params[WORKDIR], _hostname, _username);
          if (status.hasErrors()) {
            throw RunTimeException(status.errorMessage());
          }

          string remoteLauncher = launcherFile;
          remoteLauncher = remoteLauncher.substr(remoteLauncher.rfind("/") + 1, remoteLauncher.length());
          remoteLauncher = string(params[WORKDIR]) + "/" + remoteLauncher;

          string subCommand = string("chmod u+x ") + remoteLauncher;
          string command = _protocol.getExecCommand(subCommand, _hostname, _username);
          LOG(command);
          int exe_status = system(command.c_str());
          if (exe_status) {
            std::ostringstream oss;
            oss << "Cannot change permissions of file " << remoteLauncher << " on host " << _hostname;
            oss << ". Return status is " << exe_status;
            throw RunTimeException(oss.str());
          }
        }
      }
}
