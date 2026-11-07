// Copyright (C) 2007-2026  CEA, EDF
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

// ---
// File   : HexoticPlugin_i.cxx
// Author : Lioka RAZAFINDRAZAKA (CEA)
// ---
//
#include "SMESH_Hypothesis_i.hxx"

#include "utilities.h"

#include "HexoticPlugin_Hexotic_i.hxx"
#include "HexoticPlugin_Hypothesis_i.hxx"

template <class T> class HexoticPlugin_Creator_i:public HypothesisCreator_i<T>
{
  // as we have 'module HexoticPlugin' in HexoticPlugin_Algorithm.idl
  virtual std::string GetModuleName() { return "HexoticPLUGIN"; }
};

//=============================================================================
/*!
 *
 */
//=============================================================================

extern "C"
{
  HEXOTICPLUGIN_EXPORT
  GenericHypothesisCreator_i* GetHypothesisCreator (const char* aHypName)
  {
    MESSAGE("GetHypothesisCreator " << aHypName);

    GenericHypothesisCreator_i* aCreator = 0;

    // Algorithms
    if (strcmp(aHypName, "Hexotic_3D") == 0 ||
        strcmp(aHypName, "MG-Hexa") == 0)
      aCreator = new HexoticPlugin_Creator_i<HexoticPlugin_Hexotic_i>;
    // Hypotheses
    else if (strcmp(aHypName, "Hexotic_Parameters") == 0 ||
             strcmp(aHypName, "MG-Hexa Parameters") == 0)
      aCreator = new HexoticPlugin_Creator_i<HexoticPlugin_Hypothesis_i>;

    return aCreator;
  }
}
