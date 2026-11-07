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
 *  CommunicationProtocol.cxx :
 *
 *  Created on: 14 sept. 2009
 *  Author : Renaud BARATE - EDF R&D
 */

#include <stdlib.h>

#include <libbatch_config.h>

#include "CommunicationProtocol.hxx"
#include "CommunicationProtocolRSH.hxx"
#include "CommunicationProtocolSH.hxx"
#include "CommunicationProtocolSSH.hxx"
#include "CommunicationProtocolRsync.hxx"
#include "APIInternalFailureException.hxx"
#include "RunTimeException.hxx"
#include "Log.hxx"
#include "Utils.hxx"

using namespace std;

namespace Batch {

  Status::Status(int status, const std::string & error)
  : _status(status),
  _error(error)
  {
  }

  Status::Status(const Status& copy)
  : _status(copy._status),
  _error(copy._error)
  {
  }

  Status& Status::operator=(const Status& copy)
  {
      _status = copy._status;
      _error = copy._error;
      return *this;
  }

  bool Status::hasErrors()const
  {
      return _status != 0;
  }

  const std::string & Status::errorMessage()const
  {
      return _error;
  }

  int Status::getStatus()const
  {
      return _status;
  }

  CommunicationProtocol::CommunicationProtocol(CommunicationProtocolType type)
  : _type(type)
  {
  }

  CommunicationProtocol::~CommunicationProtocol()
  {
  }

  const CommunicationProtocol & CommunicationProtocol::getInstance(CommunicationProtocolType protocolType)
  {
    if (protocolType == SH) {
      static CommunicationProtocolSH instanceSH;
      return instanceSH;
    } else if (protocolType == RSH) {
      static CommunicationProtocolRSH instanceRSH;
      return instanceRSH;
    } else if (protocolType == SSH) {
      static CommunicationProtocolSSH instanceSSH;
      return instanceSSH;
    } else if (protocolType == RSYNC) {
      static CommunicationProtocolRsync instanceRsync;
      return instanceRsync;
    } else
      throw APIInternalFailureException("Unknown communication protocol.");
  }

  string CommunicationProtocol::getExecCommand(const string & subCommand,
                                               const string & host,
                                               const string & user) const
  {
    return commandStringFromArgs(getExecCommandArgs(subCommand, host, user));
  }

  Status CommunicationProtocol::copyFile(const std::string & sourcePath,
                                      const std::string & sourceHost,
                                      const std::string & sourceUser,
                                      const std::string & destinationPath,
                                      const std::string & destinationHost,
                                      const std::string & destinationUser) const
  {
    string command = commandStringFromArgs(getCopyCommandArgs(sourcePath, sourceHost, sourceUser,
                                                              destinationPath, destinationHost,
                                                              destinationUser));
    LOG(command);
    string output;
    int status = Utils::getCommandOutput(command + " 2>&1", output);
    std::ostringstream oss;
    if (status != 0)
    {
        oss << "Cannot copy file " << sourcePath << " from host " << sourceHost
            << " to " << destinationPath << " on " << destinationHost << std::endl;
        oss << "  Command : " << command << std::endl;
        oss << "  Output : " << output << std::endl;;
    }
    return Status(status, oss.str());
  }

  string CommunicationProtocol::getRemoveSubCommand(const string & path) const
  {
#ifdef WIN32
    return string("del /s ") + path;
#else
    return string("rm ") + path;
#endif
  }

  string CommunicationProtocol::getRemoveDirectorySubCommand(const string & path) const
  {
#ifdef WIN32
    return string("rd /s /q ") + path;
#else
    return string("rm -fR ") + path;
#endif
  }

  string CommunicationProtocol::getMakeDirectorySubCommand(const string & path) const
  {
#ifdef WIN32
    return string("md ") + path;
#else
    return string("mkdir -p ") + path;
#endif
  }

  Status CommunicationProtocol::removeFile(const std::string & path,
                                        const std::string & host,
                                        const std::string & user) const
  {
    string command = getExecCommand(getRemoveSubCommand(path), host, user);
    LOG(command);
    string output;
    int status = Utils::getCommandOutput(command + " 2>&1", output);
    std::ostringstream oss;
    if (status != 0)
    {
        oss << "Cannot remove file " << path << " on host " << host << std::endl;
        oss << "  Command : " << command << std::endl;
        oss << "  Output : " << output << std::endl;;
    }
    return Status(status, oss.str());
  }

  Status CommunicationProtocol::removeDirectory(const std::string & path,
                                                const std::string & host,
                                                const std::string & user) const
  {
    string command = getExecCommand(getRemoveDirectorySubCommand(path), host, user);
    LOG(command);
    string output;
    int status = Utils::getCommandOutput(command + " 2>&1", output);
    std::ostringstream oss;
    if (status != 0)
    {
        oss << "Cannot remove directory " << path << " on host " << host << std::endl;
        oss << "  Command : " << command << std::endl;
        oss << "  Output : " << output << std::endl;;
    }
    return Status(status, oss.str());
  }

  Status CommunicationProtocol::makeDirectory(const std::string & path,
                                           const std::string & host,
                                           const std::string & user) const
  {
    string command = getExecCommand(getMakeDirectorySubCommand(path), host, user);
    LOG(command);
    string output;
    int status = Utils::getCommandOutput(command + " 2>&1", output);
    std::ostringstream oss;
    if (status != 0)
    {
        oss << "Cannot create directory " << path << " on host " << host << std::endl;
        oss << "  Command : " << command << std::endl;
        oss << "  Output : " << output << std::endl;;
    }
    return Status(status, oss.str());
  }

  string CommunicationProtocol::commandStringFromArgs(const vector<string> & commandArgs) const
  {
    string commandStr;

    // On Windows we surround the whole command with quotes to avoid problems when
    // we have several quoted arguments.
#ifdef WIN32
    commandStr += "\"";
#endif

    for (unsigned int i=0 ; i<commandArgs.size() ; i++) {
      if (i != 0) commandStr += " ";

      // if the argument contains spaces, we surround it with simple quotes (Linux)
      // or double quotes (Windows)
      if (commandArgs[i].find(' ') != string::npos &&
          !Utils::isOption(commandArgs[i])){
        commandStr += string("\"") + commandArgs[i] + "\"";
      } else {
        commandStr += commandArgs[i];
      }
    }

#ifdef WIN32
    commandStr += "\"";
#endif

    return commandStr;
  }

  CommunicationProtocolType CommunicationProtocol::getType() const
  {
    return _type;
  }

}
