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
 *  CommunicationProtocolSH.cxx :
 *
 *  Created on: 16 sept. 2009
 *  Author : Renaud BARATE - EDF R&D
 */

#include <libbatch_config.h>

#include "CommunicationProtocolSH.hxx"
#include "CommandsOverloader.hxx"
#include "Utils.hxx"

using namespace std;

namespace Batch {

  CommunicationProtocolSH::CommunicationProtocolSH()
  : CommunicationProtocol(SH)
  {
  }

  vector<string> CommunicationProtocolSH::getExecCommandArgs(const string & subCommand,
                                                             const string & /*host*/,
                                                             const string & /*user*/) const
  {
    vector<string> cmd;

    cmd.push_back(Utils::fixPath(CommandsOverloader::getInstance().SH_Command()));

#ifdef WIN32
    cmd.push_back("/c");
#else
    cmd.push_back("-c");
#endif

    cmd.push_back(Utils::fixPath(subCommand));

    return cmd;
  }

  vector<string> CommunicationProtocolSH::getCopyCommandArgs(const string & sourcePath,
                                                             const string & /*sourceHost*/,
                                                             const string & /*sourceUser*/,
                                                             const string & destinationPath,
                                                             const string & /*destinationHost*/,
                                                             const string & /*destinationUser*/) const
  {
    vector<string> cmd;
    cmd.push_back(CommandsOverloader::getInstance().CP_Command());
#ifndef WIN32
    cmd.push_back("-r");
#endif
    cmd.push_back(Utils::fixPath(sourcePath));
    cmd.push_back(Utils::fixPath(destinationPath));
    return cmd;
  }

  string CommunicationProtocolSH::getRemoveSubCommand(const string & path) const
  {
    return string(CommandsOverloader::getInstance().RM_Command()) + " " + Utils::fixPath(path);
  }

  string CommunicationProtocolSH::getMakeDirectorySubCommand(const string & path) const
  {
    string subCommand = CommandsOverloader::getInstance().MKDIR_Command();
#ifndef WIN32
    subCommand += " -p";
#endif
    subCommand += " " + Utils::fixPath(path);
    return subCommand;
  }

}
