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
 * ParameterTypeMap.cxx :
 *
 * Auteur : Renaud Barate - EDF R&D
 * Date   : Mars 2011
 *
 */

#include <string>
#include <map>

#include "Constants.hxx"
#include "InvalidKeyException.hxx"
#include "ParameterTypeMap.hxx"

using namespace std;

namespace Batch {

  /*!
   * The values of this type map contain the type of the parameters and the maximum
   * number of items in the corresponding Versatile object (0 means any number).
   */
  ParameterTypeMap::ParameterTypeMap()
  {
    // Don't use the string constants in this constructor because they might be uninitialized
    addParameter("ARGUMENTS", STRING, 0);
    addParameter("ASSIGNEDHOSTNAMES", STRING, 1);
    addParameter("EXECUTABLE", STRING, 1);
    addParameter("ID", STRING, 1);
    addParameter("INFILE", COUPLE, 0);
    addParameter("MAXCPUTIME", LONG, 1);
    addParameter("MAXDISKSIZE", LONG, 1);
    addParameter("MAXRAMSIZE", LONG, 1);
    addParameter("MAXWALLTIME", LONG, 1);
    addParameter("NAME", STRING, 1);
    addParameter("NBPROC", LONG, 1);
    addParameter("NBPROCPERNODE", LONG, 1);
    addParameter("OUTFILE", COUPLE, 0);
    addParameter("QUEUE", STRING, 1);
    addParameter("STATE", STRING, 1);
    addParameter("WORKDIR", STRING, 1);
    addParameter("EXCLUSIVE", BOOL, 1);
    addParameter("MEMPERCPU", LONG, 1);
    addParameter("WCKEY", STRING, 1);
    addParameter("EXTRAPARAMS", STRING, 1);
    addParameter("PREPROCESS", STRING, 1);
    addParameter("PARTITION", STRING, 1);
    addParameter("NBNODE", LONG, 1);

    // Parameters for COORM
    addParameter("LAUNCHER_FILE", STRING, 1);
    addParameter("LAUNCHER_ARGS", STRING, 1);
  }

  ParameterTypeMap::~ParameterTypeMap()
  {
  }

  /*!
   * Returns the ParameterTypeMap singleton.
   * We use the construct-on-first-use idiom here because otherwise there could be a problem with
   * the initialization order between the factory singletons and this type map. Note that since the
   * destructors do not depend on the other objects, the order is not important for destruction.
   */
  ParameterTypeMap& ParameterTypeMap::getInstance () {
    static ParameterTypeMap instance;
    return instance;
  }

  bool ParameterTypeMap::hasKey(const string & key) const
  {
    return (_map.find(key) != _map.end());
  }

  void ParameterTypeMap::addParameter(const std::string & key, DiscriminatorType type, int maxelem)
  {
    if (hasKey(key)) throw InvalidKeyException(key + " is already present in type map");
    _map[key].type = type;
    _map[key].maxelem = maxelem;
  }

  Versatile ParameterTypeMap::createVersatile(const std::string & parameterName)
  {
    map<string, ParameterType>::const_iterator it = _map.find(parameterName);
    if (it == _map.end()) throw InvalidKeyException(parameterName);
    return Versatile(it->second.type, it->second.maxelem, parameterName);
  }

}
