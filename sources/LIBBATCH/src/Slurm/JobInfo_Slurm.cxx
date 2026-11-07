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
 *  JobInfo_Slurm.cxx :
 *
 *  Created on: 12 may 2011
 *  Author : Renaud BARATE - EDF R&D
 */

#include <sstream>

#include <RunTimeException.hxx>
#include <Constants.hxx>

#include "JobInfo_Slurm.hxx"

using namespace std;

// Utility function to test if string str1 starts with str2
bool starts_with(const std::string & str1, const std::string & str2)
{
	if (str1.length() < str2.length()) {
		return false;
	}
	return (str1.substr(0, str2.length()) == str2);
}


namespace Batch {

  JobInfo_Slurm::JobInfo_Slurm(const std::string & id, const std::string & queryOutput)
    : JobInfo()
  {
    _param[ID] = id;

    // We test only the beginning of the string because some extra info can be added by sacct
    // command (e.g. CANCELLED+)
    if (starts_with(queryOutput, "BOOT_FAIL")) {
        _param[STATE] = FAILED;
    } else if (starts_with(queryOutput, "CANCELLED")) {
      _param[STATE] = FAILED;
    } else if (starts_with(queryOutput, "COMPLETED")) {
      _param[STATE] = FINISHED;
    } else if (starts_with(queryOutput, "CONFIGURI")) {
      _param[STATE] = RUNNING;
    } else if (starts_with(queryOutput, "COMPLETIN")) {
      _param[STATE] = RUNNING;
    } else if (starts_with(queryOutput, "DEADLINE")) {
      _param[STATE] = FAILED;
    } else if (starts_with(queryOutput, "FAILED")) {
      _param[STATE] = FAILED;
    } else if (starts_with(queryOutput, "NODE_FAIL")) {
      _param[STATE] = FAILED;
    } else if (starts_with(queryOutput, "OUT_OF_ME")) {
      _param[STATE] = FAILED;
    } else if (starts_with(queryOutput, "PENDING")) {
      _param[STATE] = QUEUED;
    } else if (starts_with(queryOutput, "PREEMPTED")) {
      _param[STATE] = FAILED;
    } else if (starts_with(queryOutput, "RUNNING")) {
      _param[STATE] = RUNNING;
    } else if (starts_with(queryOutput, "RESV_DEL_")) {
      _param[STATE] = PAUSED;
    } else if (starts_with(queryOutput, "REQUEUE")) {
      _param[STATE] = PAUSED;
    } else if (starts_with(queryOutput, "RESIZING")) {
      _param[STATE] = PAUSED;
    } else if (starts_with(queryOutput, "REVOKED")) {
      _param[STATE] = FAILED;
    } else if (starts_with(queryOutput, "SIGNALING")) {
      _param[STATE] = FAILED;
    } else if (starts_with(queryOutput, "SPECIAL_E")) {
      _param[STATE] = FAILED;
    } else if (starts_with(queryOutput, "STAGE_OUT")) {
      _param[STATE] = FAILED;
    } else if (starts_with(queryOutput, "STOPPED")) {
      _param[STATE] = FAILED;
    } else if (starts_with(queryOutput, "SUSPENDED")) {
      _param[STATE] = PAUSED;
    } else if (starts_with(queryOutput, "TIMEOUT")) {
      _param[STATE] = FAILED;
    } else {
      throw RunTimeException("Unknown job state: \"" + queryOutput + "\"");
    }
  }

  JobInfo_Slurm::~JobInfo_Slurm()
  {
  }

}
