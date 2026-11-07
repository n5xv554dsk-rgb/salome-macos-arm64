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
 * BatchManagerCatalog.hxx :
 *
 * Auteur : Ivan DUTKA-MALEN - EDF R&D
 * Date   : Septembre 2004
 * Projet : SALOME 2
 * Modified by Renaud Barate, April 2009
 *
 */

#ifndef _CATALOG_H_
#define _CATALOG_H_

#include "Defines.hxx"

#include <string>
#include <map>
#include <pthread.h>

namespace Batch {

  class FactBatchManager;

  class BATCH_EXPORT BatchManagerCatalog
  {
  public:
    static BatchManagerCatalog& getInstance();

    void addFactBatchManager(const char * type, Batch::FactBatchManager * pFBM);
    bool hasFactBatchManager(const char * type);
    Batch::FactBatchManager * operator() (const char * type);

    virtual std::map<std::string, FactBatchManager *> * dict();
    virtual std::string __repr__() const;

  protected:
    // Constructeur
    BatchManagerCatalog();
    // Destructeur
    virtual ~BatchManagerCatalog();

    std::map<std::string, FactBatchManager *> _catalog;
    pthread_mutex_t _mutex;

  private:

    // Forbid the use of copy constructor and assignment operator
    BatchManagerCatalog(const BatchManagerCatalog &) {}
    void operator=(const BatchManagerCatalog &) {}

  };

}

#endif
