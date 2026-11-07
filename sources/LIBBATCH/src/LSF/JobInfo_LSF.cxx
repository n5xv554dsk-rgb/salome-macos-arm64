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
 * JobInfo_LSF.cxx :  emulation of LSF client
 *
 * Auteur : Bernard SECHER - CEA DEN
 * Mail   : mailto:bernard.secher@cea.fr
 * Date   : Thu Apr 24 10:17:22 2008
 * Projet : PAL Salome 
 *
 */

#include <cstdio>
#include <sstream>

#include <Constants.hxx>
#include "JobInfo_LSF.hxx"
#include "Log.hxx"

using namespace std;

namespace Batch {

  // Constructeurs
  JobInfo_LSF::JobInfo_LSF(int id, const std::string & queryOutput) : JobInfo()
  {
    // Fill ID parameter
    ostringstream oss;
    oss << id;
    _param[ID] = oss.str();

    // read query output
    string line;
    istringstream fp(queryOutput);
    getline(fp, line);

    // On some batch managers, the job is deleted soon after it is finished,
    // so we have to consider that an unknown job (empty file) is a finished
    // one, even if it is not always true.
    if (fp.eof()) {
      _param[STATE] = FINISHED;
    } else {
      string sjobid, username, status;
      fp >> sjobid;
      fp >> username;
      fp >> status;

      if (status == "PEND") {         // Pending
        _param[STATE] = QUEUED;
      } else if (status == "PSUSP") { // Suspended while pending
        _param[STATE] = PAUSED;
      } else if (status == "RUN") {   // Running
        _param[STATE] = RUNNING;
      } else if (status == "USUSP") { // Suspended while running
        _param[STATE] = PAUSED;
      } else if (status == "SSUSP") { // Suspended by LSF
        _param[STATE] = PAUSED;
      } else if (status == "DONE") {  // Finished successfully
        _param[STATE] = FINISHED;
      } else if (status == "EXIT") {  // Finished in error
        _param[STATE] = FAILED;
      } else if (status == "UNKWN") { // Lost contact
        _param[STATE] = FAILED;
      } else if (status == "ZOMBI") { // Zombie
        _param[STATE] = FAILED;
      } else {
        LOG("Unknown job state code: " << status);
      }

      if( status.find("RUN") != string::npos)
        _running = true;
    }
  }

  // Teste si un job est present en machine
  bool JobInfo_LSF::isRunning() const
  {
    return _running;
  }


  // Destructeur
  JobInfo_LSF::~JobInfo_LSF()
  {
    // Nothing to do
  }

  // Convertit une date HH:MM:SS en secondes
  long JobInfo_LSF::HMStoLong(const string & s)
  {
    long hour, min, sec;

    sscanf( s.c_str(), "%ld:%ld:%ld", &hour, &min, &sec);
    return ( ( ( hour * 60L ) + min ) * 60L ) + sec;
  }

  // Methode pour l'interfacage avec Python (SWIG) : affichage en Python
  string JobInfo_LSF::__str__() const
  {
    ostringstream sst;
    sst << "<JobInfo_LSF (" << this << ") :" << endl;
    sst << " ID = " <<_param[ID] << endl;
    sst << " STATE = " <<_param[STATE] << endl;

    return sst.str();
  }


}
