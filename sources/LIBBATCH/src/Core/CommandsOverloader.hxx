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
 * CommandsOverloader.hxx :
 *
 * Author : Margarita KARPUNINA - OCC
 * Date   : October 2022
 *
 */

#ifndef _COMMANDSOVERLOADER_H_
#define _COMMANDSOVERLOADER_H_

#include "Defines.hxx"

#include <map>
#include <string>

namespace Batch
{

  /*!
   * This class is used to parametrize commands in LIBBATCH.
   * It's a singleton that can be get only through the static method getInstance().
   */
  class BATCH_EXPORT CommandsOverloader
  {
  public:
    static CommandsOverloader& getInstance();
    static const std::string BASH_LOGIN;

    std::string RM_Command();
    std::string SH_Command();
    std::string CP_Command();
    std::string MKDIR_Command();
    std::string RSH_Command();
    std::string RCP_Command();
    std::string SSH_Command();
    std::string SCP_Command();
    std::string RSYNC_Command();
    std::string BASH_LOGIN_Command();

  protected:
    CommandsOverloader();
    virtual ~CommandsOverloader();

    void parse(const std::string & theFilename);
    std::string trim(const std::string & theStr) const noexcept;

    std::string getCmdFileName() const;
    bool isCmdFileDefined() const;
    bool isCheckCmdsDefined() const;

    std::string CMD_Command(const std::string & theKey);

    bool hasKey(const std::string & theKey) const;

    std::map<std::string, std::string> _cmdmap;

  private:
    // Forbid the use of copy constructor and assignment operator
    CommandsOverloader(const CommandsOverloader &) = delete;
    CommandsOverloader(const CommandsOverloader &&) = delete;
    void operator=(const CommandsOverloader &) = delete;
    void operator=(const CommandsOverloader &&) = delete;
  };

}

#endif
