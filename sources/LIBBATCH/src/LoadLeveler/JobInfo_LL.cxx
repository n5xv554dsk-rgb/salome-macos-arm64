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
 *  JobInfo_LL.cxx :
 *
 *  Created on: 30 nov. 2010
 *  Author : Renaud BARATE - EDF R&D
 */

#include <iostream>
#include <sstream>

#include <RunTimeException.hxx>
#include <Constants.hxx>

#include "JobInfo_LL.hxx"

using namespace std;

namespace Batch {

  JobInfo_LL::JobInfo_LL(const std::string & id, const std::string & output)
    : JobInfo()
  {
    _param[ID] = id;

    // read log file
    istringstream log(output);
    string line;

    // status should be on the third line
    for (int i=0 ; i<3 ; i++)
      getline(log, line);
    string status;
    istringstream iss(line);
    iss >> status;

    if (status.size() == 0) {
      // On some batch managers, the job is deleted as soon as it is finished,
      // so we have to consider that an unknown job is a finished one, even if
      // it is not always true.
      _param[STATE] = FINISHED;
    } else if (status == "C") { // Completed
      _param[STATE] = FINISHED;
    } else if (status == "R") { // Running
      _param[STATE] = RUNNING;
    } else if (status == "I") { // Idle
      _param[STATE] = QUEUED;
    } else if (status == "CA") { // Canceled
      _param[STATE] = FAILED;
    } else if (status == "CK") { // Checkpointing
      _param[STATE] = RUNNING;
    } else if (status == "CP") { // Complete Pending
      _param[STATE] = RUNNING;
    } else if (status == "D") { // Deferred
      _param[STATE] = QUEUED;
    } else if (status == "NQ") { // Not Queued
      _param[STATE] = QUEUED;
    } else if (status == "NR") { // Not Run
      _param[STATE] = FAILED;
    } else if (status == "P") { // Pending
      _param[STATE] = RUNNING;
    } else if (status == "E") { // Preempted
      _param[STATE] = RUNNING;
    } else if (status == "EP") { // Preempt Pending
      _param[STATE] = RUNNING;
    } else if (status == "X") { // Rejected
      _param[STATE] = FAILED;
    } else if (status == "XP") { // Reject Pending
      _param[STATE] = QUEUED;
    } else if (status == "RM") { // Removed
      _param[STATE] = FAILED;
    } else if (status == "RP") { // Remove Pending
      _param[STATE] = FAILED;
    } else if (status == "MP") { // Resume Pending
      _param[STATE] = RUNNING;
    } else if (status == "ST") { // Starting
      _param[STATE] = RUNNING;
    } else if (status == "S") { // System Hold
      _param[STATE] = PAUSED;
    } else if (status == "TX") { // Terminated
      _param[STATE] = FAILED;
    } else if (status == "HS") { // User & System Hold
      _param[STATE] = PAUSED;
    } else if (status == "H") { // User Hold
      _param[STATE] = PAUSED;
    } else if (status == "V") { // Vacated
      _param[STATE] = FAILED;
    } else if (status == "VP") { // Vacate Pending
      _param[STATE] = FAILED;
    } else {
      throw RunTimeException("Unknown job state code: \"" + status + "\"");
    }
  }

  JobInfo_LL::~JobInfo_LL()
  {
    // Nothing to do
  }

}
