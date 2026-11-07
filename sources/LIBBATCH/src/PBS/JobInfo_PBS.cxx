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
 * JobInfo_PBS.cxx :  emulation of PBS client
 *
 * Auteur : Bernard SECHER - CEA DEN
 * Mail   : mailto:bernard.secher@cea.fr
 * Date   : Thu Apr 24 10:17:22 2008
 * Projet : PAL Salome
 *
 */

#include <cstdio>
#include <iostream>
#include <sstream>

#include <Constants.hxx>
#include "JobInfo_PBS.hxx"
#include "Log.hxx"

using namespace std;

namespace Batch {

  // Constructeurs
  JobInfo_PBS::JobInfo_PBS(int id, string queryOutput) : JobInfo()
  {
    // Fill ID parameter
    ostringstream oss;
    oss << id;
    _param[ID] = oss.str();

    // read query output
    istringstream queryIss(queryOutput);
    string line;
    size_t pos = string::npos;
    while( (pos == string::npos) && getline(queryIss, line) ) {
      pos = line.find("job_state");
    }

    if(pos!=string::npos){
      string status;
      istringstream iss(line);
      iss >> status;
      iss >> status;
      iss >> status;

      if (status == "F") {        // Completed
        _param[STATE] = FINISHED;
      } else if (status == "E") { // Exiting
        _param[STATE] = RUNNING;
      } else if (status == "H") { // Held
        _param[STATE] = PAUSED;
      } else if (status == "Q") { // Queued
        _param[STATE] = QUEUED;
      } else if (status == "R") { // Running
        _param[STATE] = RUNNING;
      } else if (status == "S") { // Suspend
        _param[STATE] = PAUSED;
      } else if (status == "T") { // Transiting
        _param[STATE] = IN_PROCESS;
      } else if (status == "W") { // Waiting
        _param[STATE] = PAUSED;
      } else {
        LOG("Unknown job state code: " << status);
      }
    } else {
      // On some batch managers, the job is deleted as soon as it is finished,
      // so we have to consider that an unknown job is a finished one, even if
      // it is not always true.
      _param[STATE] = FINISHED;
    }
  }

  // Destructeur
  JobInfo_PBS::~JobInfo_PBS()
  {
    // Nothing to do
  }

  // Convertit une date HH:MM:SS en secondes
  long JobInfo_PBS::HMStoLong(const string & s)
  {
    long hour, min, sec;

    sscanf( s.c_str(), "%ld:%ld:%ld", &hour, &min, &sec);
    return ( ( ( hour * 60L ) + min ) * 60L ) + sec;
  }

  // Methode pour l'interfacage avec Python (SWIG) : affichage en Python
  string JobInfo_PBS::__str__() const
  {
    ostringstream sst;
    sst << "<JobInfo_PBS (" << this << ") :" << endl;
    sst << " ID = " <<_param[ID] << endl;
    sst << " STATE = " <<_param[STATE] << endl;

    return sst.str();
  }

}
