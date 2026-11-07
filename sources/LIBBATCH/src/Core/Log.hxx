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
 *  Log.hxx :
 *
 *  Created on: 28 jan. 2013
 *  Author : Renaud BARATE - EDF R&D
 */

#ifndef _LOG_H_
#define _LOG_H_

#include <iostream>
#include <fstream>
#include <sstream>

#include "Defines.hxx"

#define LOG(msg) {std::ostringstream sstream; sstream << msg; Log::log(sstream.str());}

namespace Batch {

  class BATCH_EXPORT Log
  {
  public:
    virtual ~Log();

    static void log(const std::string & msg);

  private:

    Log();

    static Log & getInstance();

    // Forbid the use of copy constructor and assignment operator
    Log(const Log &) {}
    void operator=(const Log &) {}

    std::ofstream _stream;

  };

}

#endif
