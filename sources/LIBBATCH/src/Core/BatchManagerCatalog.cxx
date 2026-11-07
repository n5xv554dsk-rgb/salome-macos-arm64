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
 * BatchManagerCatalog.cxx :
 *
 * Auteur : Ivan DUTKA-MALEN - EDF R&D
 * Date   : Septembre 2004
 * Projet : SALOME 2
 * Modified by Renaud Barate, April 2009
 *
 */

#include <string>
#include <sstream>
#include <map>
#include "BatchManagerCatalog.hxx"
#include "FactBatchManager.hxx"
using namespace std;

namespace Batch {

  // Constructeur
  BatchManagerCatalog::BatchManagerCatalog()
  {
    pthread_mutex_init(&_mutex, NULL);
  }

  // Destructeur
  BatchManagerCatalog::~BatchManagerCatalog()
  {
    pthread_mutex_destroy(&_mutex);
  }

  /**
   * Returns the catalog singleton.
   * We use the construct-on-first-use idiom here because otherwise there could be a problem with
   * the initialization order between the factory singletons and this catalog. Note that since the
   * destructors do not depend on the other objects, the order is not important for destruction.
   */
  BatchManagerCatalog& BatchManagerCatalog::getInstance () {
    static BatchManagerCatalog instance;
    return instance;
  }

  void BatchManagerCatalog::addFactBatchManager(const char * type, FactBatchManager * pFBM)
  {
    if (pFBM) { // *** section critique ***
      pthread_mutex_lock(&_mutex);
      _catalog[type] = pFBM;
      pthread_mutex_unlock(&_mutex);
    }
  }

  bool BatchManagerCatalog::hasFactBatchManager(const char * type)
  {
    pthread_mutex_lock(&_mutex);
    bool result = (_catalog.find(type) != _catalog.end());
    pthread_mutex_unlock(&_mutex);
    return result;
  }

  // Functor
  FactBatchManager * BatchManagerCatalog::operator() (const char * type)
  {
    FactBatchManager * result = NULL;
    pthread_mutex_lock(&_mutex);
    if (_catalog.find(type) != _catalog.end()) result = _catalog[type];
    pthread_mutex_unlock(&_mutex);
    return result;
  }

  std::map<string, FactBatchManager *> * BatchManagerCatalog::dict()
  {
    return &_catalog;
  }

  string BatchManagerCatalog::__repr__() const
  {
    ostringstream oss;
    oss << "<BatchManagerCatalog contains {";
    string sep;
    for(std::map<string, FactBatchManager *>::const_iterator it = _catalog.begin(); it != _catalog.end(); it++, sep=", ") {
      oss << sep << "'" << (*it).first << "' : '" << (*it).second->__repr__() << "'";
    }
    oss << "}>";
    return oss.str();
  }

}
