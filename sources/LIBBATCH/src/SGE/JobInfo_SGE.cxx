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
 * JobInfo_SGE.cxx :  emulation of SGE client
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

#include "Constants.hxx"
#include "Parametre.hxx"
#include "Environnement.hxx"
#include "RunTimeException.hxx"
#include "APIInternalFailureException.hxx"
#include "JobInfo_SGE.hxx"
#include "Log.hxx"

using namespace std;

namespace Batch {



  // Constructeurs
  JobInfo_SGE::JobInfo_SGE(int id, const std::string & output) : JobInfo()
  {
    // On remplit les membres _param et _nv
    ostringstream oss;
    oss << id;
    _param[ID] = oss.str();

    // read of log file
    char line[128];
    istringstream fp(output);
      
    string status;
    string sline;
    fp.getline(line,80,'\n');
    sline = string(line);

    if( sline.length() > 0 ){
      istringstream iss(sline);
      iss >> status >> status >> status >> status >> status;

      if (status == "d") {         // Deletion
        _param[STATE] = FAILED;
      } else if (status == "t") {  // Transferring
        _param[STATE] = IN_PROCESS;
      } else if (status == "r") {  // Running
        _param[STATE] = RUNNING;
        _running = true;
      } else if (status == "R") {  // Restarted
        _param[STATE] = RUNNING;
        _running = true;
      } else if (status == "s") {  // Suspended
        _param[STATE] = PAUSED;
      } else if (status == "S") {  // Suspended
        _param[STATE] = PAUSED;
      } else if (status == "T") {  // Threshold
        _param[STATE] = PAUSED;
      } else if (status == "qw") { // Queued and waiting
        _param[STATE] = QUEUED;
      } else if (status == "h") {  // Hold
        _param[STATE] = PAUSED;
      } else {
        LOG("Unknown job state code: " << status);
      }
    } else {
      // TODO: Check this. I suppose that unknown jobs are finished ones.
      _param[STATE] = FINISHED;
    }
  }

  // Teste si un job est present en machine
  bool JobInfo_SGE::isRunning() const
  {
    return _running;
  }


  // Destructeur
  JobInfo_SGE::~JobInfo_SGE()
  {
    // Nothing to do
  }

  // Convertit une date HH:MM:SS en secondes
  long JobInfo_SGE::HMStoLong(const string & s)
  {
    long hour, min, sec;

    sscanf( s.c_str(), "%ld:%ld:%ld", &hour, &min, &sec);
    return ( ( ( hour * 60L ) + min ) * 60L ) + sec;
  }

  // Methode pour l'interfacage avec Python (SWIG) : affichage en Python
  string JobInfo_SGE::__str__() const
  {
    ostringstream sst;
    sst << "<JobInfo_SGE (" << this << ") :" << endl;
    sst << " ID = " <<_param[ID] << endl;
    sst << " STATE = " <<_param[STATE] << endl;

    return sst.str();
  }


}
