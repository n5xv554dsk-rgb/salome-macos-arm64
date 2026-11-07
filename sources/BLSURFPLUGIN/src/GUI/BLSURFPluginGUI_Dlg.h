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

// File   : DlgRef.h
// Author : Vadim SANDLER, Open CASCADE S.A.S. (vadim.sandler@opencascade.com)

#ifndef BLSURFPLUGINGUI_H
#define BLSURFPLUGINGUI_H

enum PhysicalMesh
  {
    DefaultSize = 0,
    PhysicalGlobalSize,
    PhysicalLocalSize
  };

enum GeometricMesh
  {
    DefaultGeom = 0,
    GeometricalGlobalSize,
    GeometricalLocalSize
  };

enum ElementType {
  Triangles,
  QuadrangleDominant,
  Quadrangles
};

enum Topology {
    FromCAD = 0,
    Process,
    Process2,
    PreCAD
  } ;
  
enum {
  OPTION_ID_COLUMN = 0,
  OPTION_TYPE_COLUMN,
  OPTION_NAME_COLUMN,
  OPTION_VALUE_COLUMN,
  NB_COLUMNS,
};

//////////////////////////////////////////
// BLSURFPluginGUI_StdWidget
//////////////////////////////////////////

// WARNING: include order is important, do not swap !
#include "BLSURFPluginGUI_HypothesisCreator.h"
#include "ui_BLSURFPluginGUI_StdWidget_QTD.h"

class BLSURFPLUGIN_GUI_EXPORT BLSURFPluginGUI_StdWidget : public QWidget, 
                                            public Ui::BLSURFPluginGUI_StdWidget_QTD
{
  Q_OBJECT

public:
  BLSURFPluginGUI_StdWidget( QWidget* = 0, Qt::WindowFlags = 0 );
  ~BLSURFPluginGUI_StdWidget();

public slots:
  void onPhysicalMeshChanged();
  void onGeometricMeshChanged();
  void onEditingFinished();
  void resizeWidgets();
};

//////////////////////////////////////////
// BLSURFPluginGUI_AdvWidget
//////////////////////////////////////////

#include "ui_BLSURFPluginGUI_AdvWidget_QTD.h"

class BLSURFPLUGIN_GUI_EXPORT BLSURFPluginGUI_AdvWidget : public QWidget, 
                                            public Ui::BLSURFPluginGUI_AdvWidget_QTD
{
  Q_OBJECT

public:
  BLSURFPluginGUI_AdvWidget( QWidget* = 0, Qt::WindowFlags = 0 );
  ~BLSURFPluginGUI_AdvWidget();

  void AddOption( int iTable, const char* name_value_type );
  void GetOptionAndValue( QTreeWidgetItem * tblRow, QString& option, QString& value, bool& dflt );

public slots:

  void onChooseGMFFile();
  void itemChanged(QTreeWidgetItem * tblRow, int column);

};

#endif
