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
 * ParameterTypeMap.hxx :
 *
 * Auteur : Renaud Barate - EDF R&D
 * Date   : Mars 2011
 *
 */

#ifndef _PARAMETERTYPEMAP_H_
#define _PARAMETERTYPEMAP_H_

#include "Defines.hxx"
#include "Versatile.hxx"

#include <string>
#include <map>

namespace Batch {

  typedef struct {
    DiscriminatorType type;
    int maxelem;
  } ParameterType;


  /*!
   * This class is used to control the type of the values associated with a parameter.
   * It's a singleton that can be get only through the static method getInstance().
   */
  class BATCH_EXPORT ParameterTypeMap
  {
  public:
    static ParameterTypeMap& getInstance();

    bool hasKey(const std::string & key) const;
    void addParameter(const std::string & key, DiscriminatorType type, int maxelem);
    Versatile createVersatile(const std::string & parameterName);

  protected:

    ParameterTypeMap();
    virtual ~ParameterTypeMap();

    std::map<std::string, ParameterType> _map;

  private:

    // Forbid the use of copy constructor and assignment operator
    ParameterTypeMap(const ParameterTypeMap &) {}
    void operator=(const ParameterTypeMap &) {}

  };

}

#endif
