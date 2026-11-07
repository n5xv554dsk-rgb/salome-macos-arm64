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
 *  CommunicationProtocolSSH.cxx :
 *
 *  Created on: 14 sept. 2009
 *  Author : Renaud BARATE - EDF R&D
 */

#include <libbatch_config.h>

#include "CommunicationProtocolSSH.hxx"
#include "CommandsOverloader.hxx"

using namespace std;

namespace Batch {

  CommunicationProtocolSSH::CommunicationProtocolSSH()
  : CommunicationProtocol(SSH)
  {
  }

  vector<string> CommunicationProtocolSSH::getExecCommandArgs(const string & subCommand,
                                                              const string & host,
                                                              const string & user) const
  {
    vector<string> cmd;

    cmd.push_back(CommandsOverloader::getInstance().SSH_Command());
    cmd.push_back(host);

    if (user.size() != 0) {
      cmd.push_back("-l");
      cmd.push_back(user);
    }

    cmd.push_back(subCommand);

    return cmd;
  }

  vector<string> CommunicationProtocolSSH::getCopyCommandArgs(const string & sourcePath,
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
        fullSource += sourceUser + "@";
      }
      fullSource += sourceHost + ":";
    }
#ifndef WIN32
    fullSource += "'";
#endif
    fullSource += sourcePath;
#ifndef WIN32
    fullSource += "'";
#endif

    string fullDestination;
    if (destinationHost.size() != 0) {
      if (destinationUser.size() != 0) {
        fullDestination += destinationUser + "@";
      }
      fullDestination += destinationHost + ":";
    }
#ifndef WIN32
    fullDestination += "'";
#endif
    fullDestination += destinationPath;
#ifndef WIN32
    fullDestination += "'";
#endif

    // Option -p is used to keep the same permissions for the destination file
    // (particularly useful to keep scripts executable when copying them)
    cmd.push_back(CommandsOverloader::getInstance().SCP_Command());
    cmd.push_back("-p");
    cmd.push_back("-r");
    cmd.push_back(fullSource);
    cmd.push_back(fullDestination);

    return cmd;
  }

}
