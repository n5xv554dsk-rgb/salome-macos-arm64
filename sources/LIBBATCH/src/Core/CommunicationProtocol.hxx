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
 *  CommunicationProtocol.hxx :
 *
 *  Created on: 14 sept. 2009
 *  Author : Renaud BARATE - EDF R&D
 */

#ifndef _BATCHCOMMUNICATIONPROTOCOL_H_
#define _BATCHCOMMUNICATIONPROTOCOL_H_

#include <string>
#include <vector>

#include "Defines.hxx"

namespace Batch {

  enum CommunicationProtocolType {SH, SSH, RSH, RSYNC};

  class BATCH_EXPORT Status
  {
  public:
      Status(int status, const std::string & error);
      Status(const Status& copy);
      Status& operator=(const Status& copy);
      bool hasErrors()const;
      const std::string & errorMessage()const;
      int getStatus()const;
  private:
      int _status;
      std::string _error;
  };

  class BATCH_EXPORT CommunicationProtocol
  {
  public:
    virtual ~CommunicationProtocol();

    static const CommunicationProtocol & getInstance(CommunicationProtocolType protocolType);

    virtual std::string getExecCommand(const std::string & subCommand,
                                       const std::string & host,
                                       const std::string & user) const;

    virtual std::vector<std::string> getExecCommandArgs(const std::string & subCommand,
                                                        const std::string & host,
                                                        const std::string & user) const=0;

    virtual Status copyFile(const std::string & sourcePath,
                            const std::string & sourceHost,
                            const std::string & sourceUser,
                            const std::string & destinationPath,
                            const std::string & destinationHost,
                            const std::string & destinationUser) const;

    virtual Status removeFile(const std::string & path,
                              const std::string & host,
                              const std::string & user) const;

    virtual Status removeDirectory(const std::string & path,
                                   const std::string & host,
                                   const std::string & user) const;

    virtual Status makeDirectory(const std::string & path,
                                 const std::string & host,
                                 const std::string & user) const;

    CommunicationProtocolType getType() const;

  protected:

    CommunicationProtocol(CommunicationProtocolType type = SH);

    virtual std::vector<std::string> getCopyCommandArgs(const std::string & sourcePath,
                                                        const std::string & sourceHost,
                                                        const std::string & sourceUser,
                                                        const std::string & destinationPath,
                                                        const std::string & destinationHost,
                                                        const std::string & destinationUser) const=0;

    virtual std::string getRemoveSubCommand(const std::string & path) const;

    virtual std::string getRemoveDirectorySubCommand(const std::string & path) const;

    virtual std::string getMakeDirectorySubCommand(const std::string & path) const;

    std::string commandStringFromArgs(const std::vector<std::string> & args) const;

    CommunicationProtocolType _type;

  };

}

#endif
