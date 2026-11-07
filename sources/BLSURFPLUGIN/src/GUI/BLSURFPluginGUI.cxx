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
// File    : BLSURFPluginGUI.cxx
// Authors : Francis KLOSS (OCC) & Patrick LAUG (INRIA)
// ---
//
#ifdef WIN32
// E.A. : On windows with python 2.6, there is a conflict
// E.A. : between pymath.h and Standard_math.h which define
// E.A. : some same symbols : acosh, asinh, ...
#include <Standard_Real.hxx>
  #include <Python.h>
  #include <pymath.h>
#endif

#include "BLSURFPluginGUI_HypothesisCreator.h"

//=============================================================================
/*! GetHypothesisCreator
 *
 */
//=============================================================================
extern "C"
{
  BLSURFPLUGIN_GUI_EXPORT
  SMESHGUI_GenericHypothesisCreator* GetHypothesisCreator( const QString& aHypType )
  {
    SMESHGUI_GenericHypothesisCreator* aCreator = NULL;
    if ( aHypType == "BLSURF_Parameters" ||
         aHypType == "MG-CADSurf Parameters" ||
         aHypType == "MG-CADSurf Parameters_NOGEOM")
      aCreator =  new BLSURFPluginGUI_HypothesisCreator( aHypType );
    return aCreator;
  }
}
