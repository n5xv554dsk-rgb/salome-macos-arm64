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
// See https://www.salome-platform.org/ or email : webmaster.salome@opencascade.com
//

// File:      LightApp_ExtInfoDlg.h
// Author:    Konstantin Leontev
//
#ifndef LIGHTAPP_EXTINFODLG_H
#define LIGHTAPP_EXTINFODLG_H

#include "LightApp.h"

#include <QtxDialog.h>

class QTableWidget;
class GraphWrapper;
class QByteArray;

/*!
  \class LightApp_ExtInfoDlg
  LightApp dialog with info about loaded extensions
*/
class LIGHTAPP_EXPORT LightApp_ExtInfoDlg : public QtxDialog
{
  Q_OBJECT

public:
  LightApp_ExtInfoDlg(QWidget* = 0);
  virtual ~LightApp_ExtInfoDlg();

private:
  QWidget* getExtListWidget(QWidget* parent) const;
  QWidget* getExtTreeWidget(QWidget* parent) const;

  bool fillExtListWidget(QTableWidget* extListWidget) const;
  bool fillExtTreeGraph(const GraphWrapper& graph) const;
  QByteArray renderExtTreeGraph(const GraphWrapper& graph) const;
};

#endif
