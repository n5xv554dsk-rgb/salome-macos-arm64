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
 *  JobInfo_Vishnu.cxx :
 *
 *  Created on: 24 june 2011
 *  Author : Renaud BARATE - EDF R&D
 */

#include <iostream>
#include <sstream>

#include <RunTimeException.hxx>
#include <Constants.hxx>

#include "JobInfo_Vishnu.hxx"

using namespace std;

namespace Batch {

  JobInfo_Vishnu::JobInfo_Vishnu(const string & id, const string & queryOutput)
    : JobInfo()
  {
    _param[ID] = id;

    // find the status in the query output
    istringstream iss(queryOutput);
    string status;
    bool statusFound = false;
    while (!statusFound && !iss.eof()) {
      string line;
      getline(iss, line);
      size_t pos = line.find(':');
      if (pos != string::npos) {
        string begline = line.substr(0, pos);
        string keyword;
        // Trim leading and trailing spaces of the string before ':'
        size_t startpos = begline.find_first_not_of(" \t");
        size_t endpos = begline.find_last_not_of(" \t");
        if (startpos != string::npos && endpos != string::npos)
          keyword = begline.substr(startpos, endpos-startpos+1);

        if (keyword == "Status") {
          statusFound = true;
          string endline = line.substr(pos + 1);
          startpos = endline.find_first_not_of(" \t");
          endpos = endline.find_last_not_of(" \t");
          if (startpos != string::npos && endpos != string::npos)
            status = endline.substr(startpos, endpos-startpos+1);
        }
      }
    }

    if (status.size() == 0) {
      // On some batch managers, the job is deleted as soon as it is finished,
      // so we have to consider that an unknown job is a finished one, even if
      // it is not always true.
      _param[STATE] = FINISHED;
    } else if (status == "QUEUED") {
      _param[STATE] = QUEUED;
    } else if (status == "WAITING") {
      _param[STATE] = QUEUED;
    } else if (status == "RUNNING") {
      _param[STATE] = RUNNING;
    } else if (status == "TERMINATED") {
      _param[STATE] = FINISHED;
    } else if (status == "CANCELLED") {
      _param[STATE] = FAILED;
    } else {
      throw RunTimeException("Unknown job state code: \"" + status + "\"");
    }
  }

  JobInfo_Vishnu::~JobInfo_Vishnu()
  {
  }

}
