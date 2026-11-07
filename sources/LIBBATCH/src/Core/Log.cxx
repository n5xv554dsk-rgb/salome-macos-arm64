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
 *  Log.cxx :
 *
 *  Created on: 28 jan. 2013
 *  Author : Renaud BARATE - EDF R&D
 */

#include "Utils.hxx"
#include "Log.hxx"
#include <time.h>

#ifdef WIN32
#include <time.h>
#endif

using namespace std;

namespace Batch {

  Log::Log()
  {
    const size_t BUFSIZE = 32;
    char date[BUFSIZE];
    time_t curtime = time(NULL);
    strftime(date, BUFSIZE, "%Y-%m-%d_%H-%M-%S", localtime(&curtime));
    string prefix = string("log-") + date;
    Utils::createAndOpenTemporaryFile(prefix, _stream);
  }

  Log::~Log()
  {
    _stream.close();
  }

  void Log::log(const string & msg)
  {
    const size_t BUFSIZE = 32;
    char timestamp[BUFSIZE];
    time_t curtime = time(NULL);
    strftime(timestamp, BUFSIZE, "%Y-%m-%d_%H-%M-%S", localtime(&curtime));
    getInstance()._stream << timestamp << ": " << msg << endl;
  }

  Log & Log::getInstance()
  {
    static Log instance;
    return instance;
  }

}
