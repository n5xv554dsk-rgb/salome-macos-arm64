// Copyright (C) 2007-2023  CEA, EDF, OPEN CASCADE
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

// File   : PyEditorPy_binding.h
//

#ifndef SALOME_PYEDITOR__BINDINGS_H
#define SALOME_PYEDITOR__BINDINGS_H

#ifdef _WIN32
  #include <windows.h>
  #define _OMNIORB_HOST_BYTE_ORDER_ 1
#endif // _WIN32
#include <pyside.h>
#include "sbkconverter.h"
#include "sbkmodule.h"
#include "sbkpython.h"
#include "shiboken.h"
#include <QtCore/QByteArray> // Make sure QByteArray is included
#include <QtCore/QCborStreamReader> // Include the header for QCborStreamReader
#include <QtCore/QVector>

#include "PyEditor_Settings.h"
#include "PyEditor_Editor.h"
#include "PyEditor_FindTool.h"
#include "PyEditor_Widget.h"
#include "PyEditor_Window.h"
#endif // SALOME_PYEDITOR__BINDINGS_H
