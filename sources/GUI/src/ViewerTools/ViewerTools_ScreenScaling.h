// Copyright (C) 2007-2026  CEA, EDF, OPEN CASCADE
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

#ifndef VIEWERTOOLS_SCREENSCALING_H
#define VIEWERTOOLS_SCREENSCALING_H

#include "ViewerTools.h"

class QEvent;

/*!
 * Namespace   : ViewerTools_ScreenScaling
 * Description : Tools for handle UI on screens with different scaling
 */
namespace ViewerTools_ScreenScaling
{
  // Returns pixel ratio for the current screen
  VIEWERTOOLS_EXPORT double getPR();

  // Check if we have pixel ratio != 1.0
  VIEWERTOOLS_EXPORT bool isScaledPixelRatio();

  // Returns a copy of the given event with the local coordinates
  // updated with the current pixel ratio.
  VIEWERTOOLS_EXPORT QEvent* getDpiAwareEvent(QEvent* e, bool toMultiply = true);
}

#endif
