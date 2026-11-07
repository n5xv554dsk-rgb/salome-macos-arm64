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
 *  CommunicationProtocolRSH.cxx :
 *
 *  Created on: 14 sept. 2009
 *  Author : Renaud BARATE - EDF R&D
 */

#ifdef WIN32
#include <direct.h>
#include <iostream>

#include <RunTimeException.hxx>
#endif

#include <libbatch_config.h>

#include "CommunicationProtocolRSH.hxx"
#include "CommandsOverloader.hxx"
#include "Log.hxx"

using namespace std;

namespace Batch {

  CommunicationProtocolRSH::CommunicationProtocolRSH()
  : CommunicationProtocol(RSH)
  {
  }

  vector<string> CommunicationProtocolRSH::getExecCommandArgs(const string & subCommand,
                                                              const string & host,
                                                              const string & user) const
  {
    vector<string> cmd;

    cmd.push_back(CommandsOverloader::getInstance().RSH_Command());
    cmd.push_back(host);

    if (user.size() > 0) {
      cmd.push_back("-l");
      cmd.push_back(user);
    }

#ifdef WIN32
    cmd.push_back("-n");
#endif

    cmd.push_back(subCommand);

    return cmd;
  }

  vector<string> CommunicationProtocolRSH::getCopyCommandArgs(const string & sourcePath,
                                                              const string & sourceHost,
                                                              const string & sourceUser,
                                                              const string & destinationPath,
                                                              const string & destinationHost,
                                                              const string & destinationUser) const
  {
    vector<string> cmd;

    string fullSource;
    if (sourceHost.size() != 0) {
      if (sourceUser.size() != 0) {
#ifdef WIN32
        fullSource += sourceHost + "." + sourceUser + ":";
#else
        fullSource += sourceUser + "@" + sourceHost + ":";
#endif
      } else {
        fullSource += sourceHost + ":";
      }
    }
    fullSource += sourcePath;

    string fullDestination;
    if (destinationHost.size() != 0) {
      if (destinationUser.size() != 0) {
#ifdef WIN32
        fullDestination += destinationHost + "." + destinationUser + ":";
#else
        fullDestination += destinationUser + "@" + destinationHost + ":";
#endif
      } else {
        fullDestination += destinationHost + ":";
      }
    }
    fullDestination += destinationPath;

    cmd.push_back(CommandsOverloader::getInstance().RCP_Command());
    cmd.push_back("-r");
    cmd.push_back(fullSource);
    cmd.push_back(fullDestination);

    return cmd;
  }

#ifdef WIN32
  Status CommunicationProtocolRSH::copyFile(const std::string & sourcePath,
                                         const std::string & sourceHost,
                                         const std::string & sourceUser,
                                         const std::string & destinationPath,
                                         const std::string & destinationHost,
                                         const std::string & destinationUser) const
  {
    // On Windows, we can't use drive letters in the paths of rcp command because they
    // are confused with host names. So we must first change the working directory and
    // then copy the file using its path without the drive letter.

    // Extract the drive letter from the source path
    string sourcePathWithoutDrive;
    char sourceDriveLetter = getDriveLetter(sourcePath, &sourcePathWithoutDrive);
    // Error if we have a drive letter and it is a remote path
    if (sourceDriveLetter != '\0' && sourceHost.size() != 0)
      throw RunTimeException(string("Invalid path: ") + sourcePath + " for host " + sourceHost);

    // Extract the drive letter from the destination path
    string destinationPathWithoutDrive;
    char destinationDriveLetter = getDriveLetter(destinationPath, &destinationPathWithoutDrive);
    // Error if we have a drive letter and it is a remote path
    if (destinationDriveLetter != '\0' && destinationHost.size() != 0)
      throw RunTimeException(string("Invalid path: ") + destinationPath + " for host " + destinationHost);

    // Error if we have two drive letters and they are different
    if (sourceDriveLetter != '\0' && destinationDriveLetter != '\0' &&
        sourceDriveLetter != destinationDriveLetter)
      throw RunTimeException(string("Can't use RCP to copy files between different drives: ") +
                             sourcePath + (", ") + destinationPath);

    // Now get the drive letter to use if there is one
    char driveLetter = (sourceDriveLetter != '\0') ? sourceDriveLetter : destinationDriveLetter;

    // Get the drive of the current working directory
    char cwd[_MAX_PATH];
    _getcwd(cwd, _MAX_PATH);
    char currentDrive = getDriveLetter(cwd);

    // Change working directory if necessary
    if (driveLetter != '\0' && driveLetter != currentDrive) {
      char newdir[3];
      newdir[0] = driveLetter;
      newdir[1] = ':';
      newdir[2] = '\0';
      LOG("Changing directory: " << newdir);
      _chdir(newdir);
    }

    Status status = CommunicationProtocol::copyFile(sourcePathWithoutDrive, sourceHost, sourceUser,
                                                 destinationPathWithoutDrive, destinationHost, destinationUser);

    // Go back to previous directory if necessary
    if (driveLetter != '\0' && driveLetter != currentDrive) {
      LOG("Changing directory: " << cwd);
      _chdir(cwd);
    }

    return status;
  }

  char CommunicationProtocolRSH::getDriveLetter(const string & path, string * pathWithoutDrive) const
  {
    if (path.find(':') != string::npos) {
      // Error if the colon is not the second character
      if (path.size() < 2 || path[1] != ':')
        throw RunTimeException(string("Invalid path: ") + path);
      else {
        if (pathWithoutDrive != NULL) *pathWithoutDrive = path.substr(2);
        return path[0];
      }
    } else {
      if (pathWithoutDrive != NULL) *pathWithoutDrive = path;
      return '\0';
    }
  }

#endif

}
