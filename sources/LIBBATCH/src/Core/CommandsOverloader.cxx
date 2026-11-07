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
 * CommandsOverloader.cxx :
 *
 * Author : Margarita KARPUNINA - OCC
 * Date   : October 2022
 *
 */

#include <fstream>
#include <set>
#include <sstream>
#include <iostream>

#include <libbatch_config.h>

#include "CommandsOverloader.hxx"

#include "RunTimeException.hxx"

using namespace std;


namespace Batch
{

  static set<string> supportedCmds({"RM", "SH", "CP", "MKDIR", "RSH", "RCP", "SSH", "SCP", "RSYNC", "BASH_LOGIN"});
  const std::string CommandsOverloader::BASH_LOGIN = "bash -l -c";

  /*!
   * Constructor.
   */
  CommandsOverloader::CommandsOverloader()
  {
    if (!isCmdFileDefined() && isCheckCmdsDefined())
    {
      cout << "================================================================" << endl;
      cout << "Commands found on the system at compile time are used." << endl;
      cout << "================================================================" << endl;
    }
  }

  /*!
   * Destructor.
   */
  CommandsOverloader::~CommandsOverloader()
  {
  }

  /*!
   * Return the CommandsOverloader singleton.
   */
  CommandsOverloader& CommandsOverloader::getInstance ()
  {
    static CommandsOverloader instance;
    return instance;
  }

  /*!
   * Return an overridden definition of RM command.
   */
  string CommandsOverloader::RM_Command()
  {
    string cmd = CMD_Command("RM");
    if (!cmd.empty())
    {
      return cmd;
    }

#ifdef RM_COMMAND
    return RM_COMMAND;
#else
    throw RunTimeException("Can't use SH protocol (RM command was "
                           "not found neither in the file pointed by "
                           "LIBBATCH_OVERRIDE_CMDS environment variable "
                           "nor on the system at compile time).");
#endif
  }

  /*!
   * Return an overridden definition of SH command.
   */
  string CommandsOverloader::SH_Command()
  {
    string cmd = CMD_Command("SH");
    if (!cmd.empty())
    {
      return cmd;
    }

#ifdef SH_COMMAND
    return SH_COMMAND;
#else
    throw RunTimeException("Can't use SH protocol (SH command was "
                           "not found neither in the file pointed by "
                           "LIBBATCH_OVERRIDE_CMDS environment variable "
                           "nor on the system at compile time).");
#endif
  }

  /*!
   * Return an overridden definition of CP command.
   */
  string CommandsOverloader::CP_Command()
  {
    string cmd = CMD_Command("CP");
    if (!cmd.empty())
    {
      return cmd;
    }

#ifdef CP_COMMAND
    return CP_COMMAND;
#else
    throw RunTimeException("Can't use SH protocol (CP command was "
                           "not found neither in the file pointed by "
                           "LIBBATCH_OVERRIDE_CMDS environment variable "
                           "nor on the system at compile time).");
#endif
  }

  /*!
   * Return an overridden definition of MKDIR command.
   */
  string CommandsOverloader::MKDIR_Command()
  {
    string cmd = CMD_Command("MKDIR");
    if (!cmd.empty())
    {
      return cmd;
    }

#ifdef MKDIR_COMMAND
    return MKDIR_COMMAND;
#else
    throw RunTimeException("Can't use SH protocol (MKDIR command was "
                           "not found neither in the file pointed by "
                           "LIBBATCH_OVERRIDE_CMDS environment variable "
                           "nor on the system at compile time).");
#endif
  }

  /*!
   * Return an overridden definition of RSH command.
   */
  string CommandsOverloader::RSH_Command()
  {
    string cmd = CMD_Command("RSH");
    if (!cmd.empty())
    {
      return cmd;
    }

#ifdef RSH_COMMAND
    return RSH_COMMAND;
#else
    throw RunTimeException("Can't use RSH protocol (RSH command was "
                           "not found neither in the file pointed by "
                           "LIBBATCH_OVERRIDE_CMDS environment variable "
                           "nor on the system at compile time).");
#endif
  }

  /*!
   * Return an overridden definition of RCP command.
   */
  string CommandsOverloader::RCP_Command()
  {
    string cmd = CMD_Command("RCP");
    if (!cmd.empty())
    {
      return cmd;
    }

#ifdef RCP_COMMAND
    return RCP_COMMAND;
#else
    throw RunTimeException("Can't use RSH protocol (RCP command was "
                           "not found neither in the file pointed by "
                           "LIBBATCH_OVERRIDE_CMDS environment variable "
                           "nor on the system at compile time).");
#endif
  }

  /*!
   * Return an overridden definition of SSH command.
   */
  string CommandsOverloader::SSH_Command()
  {
    string cmd = CMD_Command("SSH");
    if (!cmd.empty())
    {
      return cmd;
    }

#ifdef SSH_COMMAND
    return SSH_COMMAND;
#else
    throw RunTimeException("Can't use SSH protocol (SSH command was "
                           "not found neither in the file pointed by "
                           "LIBBATCH_OVERRIDE_CMDS environment variable "
                           "nor on the system at compile time).");
#endif
  }

  /*!
   * Return an overridden definition of SCP command.
   */
  string CommandsOverloader::SCP_Command()
  {
    string cmd = CMD_Command("SCP");
    if (!cmd.empty())
    {
      return cmd;
    }

#ifdef SCP_COMMAND
    return SCP_COMMAND;
#else
    throw RunTimeException("Can't use SSH protocol (SCP command was "
                           "not found neither in the file pointed by "
                           "LIBBATCH_OVERRIDE_CMDS environment variable "
                           "nor on the system at compile time).");
#endif
  }

  /*!
   * Return an overridden definition of RSYNC command.
   */
  string CommandsOverloader::RSYNC_Command()
  {
    string cmd = CMD_Command("RSYNC");
    if (!cmd.empty())
    {
      return cmd;
    }

#ifdef RSYNC_COMMAND
    return RSYNC_COMMAND;
#else
    throw RunTimeException("Can't use RSYNC protocol (RSYNC command was "
                           "not found neither in the file pointed by "
                           "LIBBATCH_OVERRIDE_CMDS environment variable "
                           "nor on the system at compile time).");
#endif
  }

  /*!
   * Return an overridden definition of bash -l -c command.
   */
  string CommandsOverloader::BASH_LOGIN_Command()
  {
    string cmd = CMD_Command("BASH_LOGIN");
    if (!cmd.empty())
    {
      return cmd;
    }

    return BASH_LOGIN;
  }
  
  /*!
   * Parse text file with the given file name and fill in the map of 
   * <CMD> - <associated command desired by the user at runtime>.
   * \param theFilename the name of text file to be parsed
   */
  void CommandsOverloader::parse(const std::string & theFilename)
  {
    ifstream fileStream(theFilename.c_str());
    if (!fileStream)
    {
      stringstream errMsg;
      errMsg << "Can't open file with overridden commands definitions " << theFilename;
      throw RunTimeException(errMsg.str());
    }
    string line;
    bool empty = true;
    int lineNumber = 1;
    while (getline(fileStream, line))
    {
      string str = line;
      if (!str.empty())
      {
        empty = false;
        // Find ' ' symbol and split the line
        size_t pos = str.find_first_of(' ');
        if (pos == string::npos)
        {
          stringstream errMsg;
          errMsg << "Wrong format of " << theFilename << " file on line " << lineNumber
                 << ": Syntax error (missing ' ' character between key and value): " << line;
          throw RunTimeException(errMsg.str());
        } else
        {
          string key = str.substr(0, pos);
          string value = str.substr(pos+1);

          // Check non-completeness of the file.
          string trimmedKey = trim(key);
          string trimmedValue = trim(value);
          if (trimmedKey.empty() || trimmedValue.empty())
          {
            stringstream errMsg;
            errMsg << "Wrong format of " << theFilename << " file on line " << lineNumber
                   << ": The non-completeness of the file: " << line;
            throw RunTimeException(errMsg.str());
          }

          // Check the presence of an unsupported command.
          if (supportedCmds.find(trimmedKey) == supportedCmds.end())
          {
            stringstream errMsg;
            errMsg << "Wrong format of " << theFilename << " file on line " << lineNumber
                   << ": The presence of an unsupported command: " << trimmedKey;
            throw RunTimeException(errMsg.str());
          }

          if (!hasKey(trimmedKey))
          {
            _cmdmap[trimmedKey] = trimmedValue;
          }
          else
          {
            // Redifinition of already overloaded command is found.
            stringstream errMsg;
            errMsg << "Wrong format of " << theFilename << " file on line " << lineNumber
                   <<": A repetition of the " << trimmedKey << " key in several lines.";
            throw RunTimeException(errMsg.str());
          }
        }
      }
      ++lineNumber;
    }
    if (empty)
    {
      stringstream errMsg;
      errMsg << "Wrong format of " << theFilename << " file: Empty file.";
      throw RunTimeException(errMsg.str());
    }
    fileStream.close();
  }

  /*!
   * Strip leading and trailing spaces in the given string.
   * \param theStr string to be stripped
   * \return stripped string
   */
  string CommandsOverloader::trim(const std::string & theStr) const noexcept
  {
    size_t beg = theStr.find_first_not_of(" \t");
    if (beg == string::npos) beg = 0;
    size_t end = theStr.find_last_not_of(" \t");
    return theStr.substr(beg, end-beg+1);
  }

  /*!
   * Return name of file with overloaded commands defined by
   * LIBBATCH_OVERRIDE_CMDS environment variable.
   * \return the name of file with overloaded commands
   */
  string CommandsOverloader::getCmdFileName() const
  {
    auto parseCmdFileName = []() -> std::string
    {
      const char* cmdFileName = getenv("LIBBATCH_OVERRIDE_CMDS");
      if (cmdFileName != NULL && !string(cmdFileName).empty())
      {
        return cmdFileName;
      }
      return {};
    };
    
    static const string cmdFileName = parseCmdFileName();
    return cmdFileName;
  }
  
  /*!
   * Check, if file with overloaded commands is defined by
   * LIBBATCH_OVERRIDE_CMDS environment variable.
   * \return true, if file is defined; false - otherwise
   */
  bool CommandsOverloader::isCmdFileDefined() const
  {
    static const bool isFileDefined = !getCmdFileName().empty();
    return isFileDefined;
  }

  /*!
   * Check, if it is needed to show information about overloaded or not
   * commands are used. It can be switched ON via the environment
   * variable LIBBATCH_CHECK_CMDS=1.
   * \return true, if it is needed to show information; false - otherwise
   */
  bool CommandsOverloader::isCheckCmdsDefined() const
  {
    char * check_cmds_env = getenv("LIBBATCH_CHECK_CMDS");
    if (check_cmds_env && atoi(check_cmds_env) == 1)
      return true;
    return false;
  }

  /*!
   * Return an overridden definition of the given command.
   * \param theKey command name
   * \return overridden definition of the given command
   */
  string CommandsOverloader::CMD_Command(const std::string & theKey)
  {
    if (_cmdmap.empty())
    {
      if (isCmdFileDefined())
      {
        // Environment variable LIBBATCH_OVERRIDE_CMDS is defined.
        // Parse text file pointed by LIBBATCH_OVERRIDE_CMDS environment variable.
        parse(getCmdFileName());
        // Note: If environment variable LIBBATCH_OVERRIDE_CMDS is not defined,
        // use command configuration established at compile time.
        
        // Showing information about overloaded or not commands are used is disabled by default.
        // It can be switched ON via the environment variable: LIBBATCH_CHECK_CMDS=1
        if (isCheckCmdsDefined())
        {
          cout << "================================================================" << endl;
          if (_cmdmap.empty())
          {
            cout << "Commands found on the system at compile time are used." << endl;
          } else if (_cmdmap.size() == supportedCmds.size())
          {
            cout << "Overloaded commands are used." << endl;
          } else
          {
            cout << "Command(s)" << endl;
            map<string,string>::const_iterator iter;
            for (iter = _cmdmap.begin() ; iter != _cmdmap.end() ; ++iter)
            {
              cout << "\t" << iter->first << endl;
            }
            cout << "is(are) overloaded." << endl;
            cout << "The rest command(s) is(are) found on the system at compile time." << endl;
          }
          cout << "================================================================" << endl;
        }
      }
    }

    return hasKey(theKey) ? _cmdmap[theKey] : string();
  }

  /*!
   * Check, if commands map contains the given command key.
   * \param theKey command name
   * \return true, if command key exists in the map
   */
  bool CommandsOverloader::hasKey(const string & theKey) const
  {
    return (_cmdmap.find(theKey) != _cmdmap.end());
  }

}
