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
// File   : HYBRIDPlugin_i.cxx
// Author : Christian VAN WAMBEKE (CEA)
// ---
//
#include "SMESH_Hypothesis_i.hxx"

#include "utilities.h"

#include "HYBRIDPlugin_HYBRID_i.hxx"
#include "HYBRIDPlugin_Hypothesis_i.hxx"

template <class T> class HYBRIDPlugin_Creator_i:public HypothesisCreator_i<T>
{
  // as we have 'module HYBRIDPlugin' in HYBRIDPlugin_Algorithm.idl
  virtual std::string GetModuleName() { return "HYBRIDPlugin"; }
};

//=============================================================================
/*!
 *
 */
//=============================================================================

extern "C"
{
  HYBRIDPLUGIN_EXPORT GenericHypothesisCreator_i* GetHypothesisCreator (const char* aHypName);
  
  HYBRIDPLUGIN_EXPORT
  GenericHypothesisCreator_i* GetHypothesisCreator (const char* aHypName)
  {
    GenericHypothesisCreator_i* aCreator = 0;

    // Hypotheses

    // Algorithm
    if (strcmp(aHypName, "HYBRID_3D") == 0)
      aCreator = new HYBRIDPlugin_Creator_i<HYBRIDPlugin_HYBRID_i>;
    // Hypothesis
    else if (strcmp(aHypName, "HYBRID_Parameters") == 0)
      aCreator = new HYBRIDPlugin_Creator_i<HYBRIDPlugin_Hypothesis_i>;

    return aCreator;
  }
}
