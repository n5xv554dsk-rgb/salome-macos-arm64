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
 *  CommunicationProtocolRsync.cxx :
 *
 *  Author : EDF R&D
 */

#include <libbatch_config.h>
#include "Utils.hxx"

#include "CommunicationProtocolRsync.hxx"
#include "CommandsOverloader.hxx"

using namespace std;

namespace Batch {

  CommunicationProtocolRsync::CommunicationProtocolRsync()
  : CommunicationProtocolSSH()
  {
    _type = RSYNC;
  }

  vector<string> CommunicationProtocolRsync::getCopyCommandArgs(const string & sourcePath,
                                                              const string & sourceHost,
                                                              const string & sourceUser,
                                                              const string & destinationPath,
                                                              const string & destinationHost,
                                                              const string & destinationUser) const
  {
    vector<string> cmd;

    string fullSource;

    if(Utils::isOption(sourcePath))
      fullSource += sourcePath;
    else
    {
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
    }

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
    cmd.push_back(CommandsOverloader::getInstance().RSYNC_Command());
    if(!Utils::isOption(sourcePath))
    {
      cmd.push_back("-p");
      cmd.push_back("-r");
      if(Utils::usesRsyncRelativePath(sourcePath))
        cmd.push_back("-R");
    }
    cmd.push_back(fullSource);
    cmd.push_back(fullDestination);

    return cmd;
  }

}
