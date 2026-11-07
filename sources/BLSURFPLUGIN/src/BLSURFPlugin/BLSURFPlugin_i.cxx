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
// File    : BLSURFPlugin_i.cxx
// Authors : Francis KLOSS (OCC) & Patrick LAUG (INRIA)
// ---
//
#include "utilities.h"

#ifdef WIN32
  #if defined BLSURFPLUGIN_EXPORTS || defined BLSURFEngine_EXPORTS
    #define BLSURFPLUGIN_EXPORT __declspec( dllexport )
  #else
    #define BLSURFPLUGIN_EXPORT __declspec( dllimport )
  #endif
#else
  #define BLSURFPLUGIN_EXPORT
#endif

#include "BLSURFPlugin_BLSURF_i.hxx"
#include "BLSURFPlugin_Hypothesis_i.hxx"

template <class T, bool NOGEOM>
class BLSURFPlugin_Creator_i : public GenericHypothesisCreator_i
{
  // Create a hypothesis
  virtual SMESH_Hypothesis_i* Create(PortableServer::POA_ptr thePOA,
                                     ::SMESH_Gen*            theGenImpl)
  {
    return new T (thePOA, theGenImpl, !NOGEOM);
  }

  // as we have 'module BLSURFPlugin' in BLSURFPlugin_Algorithm.idl
  virtual std::string GetModuleName() { return "BLSURFPlugin"; }
};

//=============================================================================
/*!
 *
 */
//=============================================================================

extern "C"
{
  BLSURFPLUGIN_EXPORT
  GenericHypothesisCreator_i* GetHypothesisCreator (const char* aHypName)
  {
    GenericHypothesisCreator_i* aCreator = 0;

    // Algorithms
    if (strcmp(aHypName, "BLSURF") == 0 ||
        strcmp(aHypName, "MG-CADSurf") == 0 )
      aCreator = new BLSURFPlugin_Creator_i<BLSURFPlugin_BLSURF_i,false>;
    else if (strcmp(aHypName, "MG-CADSurf_NOGEOM") == 0 )
      aCreator = new BLSURFPlugin_Creator_i<BLSURFPlugin_BLSURF_i,true>;
    // Hypotheses
    else if (strcmp(aHypName, "BLSURF_Parameters") == 0 ||
             strcmp(aHypName, "MG-CADSurf Parameters") == 0 )
      aCreator = new BLSURFPlugin_Creator_i<BLSURFPlugin_Hypothesis_i,false>;
    else if (strcmp(aHypName, "MG-CADSurf Parameters_NOGEOM") == 0 )
      aCreator = new BLSURFPlugin_Creator_i<BLSURFPlugin_Hypothesis_i,true>;

    return aCreator;
  }
}
