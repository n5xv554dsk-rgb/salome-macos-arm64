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
 * JobInfo_CCC.cxx :  emulation of CCC client for CCRT machines
 *
 * Auteur : Bernard SECHER - CEA DEN
 * Mail   : mailto:bernard.secher@cea.fr
 * Date   : Thu Apr 24 10:17:22 2010
 * Projet : PAL Salome 
 *
 */

#include <cstdio>
#include <iostream>
#include <sstream>

#include "Constants.hxx"
#include "Parametre.hxx"
#include "Environnement.hxx"
#include "JobInfo_CCC.hxx"
#include "Log.hxx"

using namespace std;

namespace Batch {



  // Constructeurs
  JobInfo_CCC::JobInfo_CCC(int id, string output) : JobInfo()
  {
    // On remplit les membres _param et _nv
    ostringstream oss;
    oss << id;
    _param[ID] = oss.str();

    // read status of job in log file
    char line[128];
    istringstream fp(output);
    fp.getline(line,80,'\n');
    
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
    } else if (status == "SSUSP") { // Suspended by CCC
      _param[STATE] = PAUSED;
    } else if (status == "DONE") {  // Finished successfully
      _param[STATE] = FINISHED;
    } else if (status == "EXIT") {  // Finished successfully
      _param[STATE] = FINISHED;
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

  // Teste si un job est present en machine
  bool JobInfo_CCC::isRunning() const
  {
    return _running;
  }


  // Destructeur
  JobInfo_CCC::~JobInfo_CCC()
  {
    // Nothing to do
  }

  // Convertit une date HH:MM:SS en secondes
  long JobInfo_CCC::HMStoLong(const string & s)
  {
    long hour, min, sec;

    sscanf( s.c_str(), "%ld:%ld:%ld", &hour, &min, &sec);
    return ( ( ( hour * 60L ) + min ) * 60L ) + sec;
  }

  // Methode pour l'interfacage avec Python (SWIG) : affichage en Python
  string JobInfo_CCC::__str__() const
  {
    ostringstream sst;
    sst << "<JobInfo_CCC (" << this << ") :" << endl;
    sst << " ID = " <<_param[ID] << endl;
    sst << " STATE = " <<_param[STATE] << endl;

    return sst.str();
  }


}
