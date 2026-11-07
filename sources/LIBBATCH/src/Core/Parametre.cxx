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
 * Parametre.cxx :
 *
 * Auteur : Ivan DUTKA-MALEN - EDF R&D
 * Date   : Septembre 2003
 * Projet : SALOME 2
 *
 */

#include "Versatile.hxx"
#include "InvalidKeyException.hxx"
#include "ParameterTypeMap.hxx"
#include "Parametre.hxx"

using namespace std;

namespace Batch {

  // Constructeur standard
  Parametre::Parametre() : map< string, Versatile >()
  {
  }

  // Operateur de recherche dans la map
  // Cet operateur agit sur les objets NON CONSTANTS, il autorise la modification de
  // la valeur associée à la clef car il retourne une reference non constante
  Versatile & Parametre::operator [] (const string & mk)
  {
    // On controle que la clef est valide
    if (!ParameterTypeMap::getInstance().hasKey(mk)) throw InvalidKeyException(mk);

    Parametre::iterator it = find(mk);
    if (it != end()) {
      return it->second;
    } else {
      Versatile V = ParameterTypeMap::getInstance().createVersatile(mk);
      pair<iterator, bool> result = insert(make_pair(mk, V));
      return result.first->second;
    }
  }

  // Operateur de recherche dans la map
  // Cet operateur agit sur les objets CONSTANTS
  const Versatile & Parametre::operator [] (const string & mk) const
  {
    // On controle que la clef est valide
    if (!ParameterTypeMap::getInstance().hasKey(mk)) throw InvalidKeyException(mk);

    // On recherche la valeur associee
    Parametre::const_iterator it = find(mk);
    if (it == end()) throw InvalidKeyException(mk);
    const Versatile & V = (*it).second;

    return V;
  }

  // Operateur d'affectation
  Parametre & Parametre::operator =(const Parametre & PM)
  {
    // On ne reaffecte pas l'objet a lui-meme, sinon aie, aie, aie
    if (this == &PM) return *this;

    // On efface toute la map
    erase(begin(), end());

    // On recree la structure interne de la map avec les valeurs de celle passee en argument
    Parametre::const_iterator it;
    for(it=PM.begin(); it!=PM.end(); it++)
      insert(make_pair((*it).first, Versatile((*it).second)));

    return *this;
  }

  // Constructeur par recopie
  Parametre::Parametre(const Parametre & PM) : map< string, Versatile >()
  {
    // On cree la structure interne de la map avec les valeurs de celle passee en argument
    Parametre::const_iterator it;
    for(it=PM.begin(); it!=PM.end(); it++)
      insert(make_pair((*it).first, Versatile((*it).second)));
  }

}
