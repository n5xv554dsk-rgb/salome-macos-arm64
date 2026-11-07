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

#ifndef HEXOTICPLUGINGUI_H
#define HEXOTICPLUGINGUI_H

class QPixmap;

enum {
  SD_MODE_1,
  SD_MODE_2,
  SD_MODE_3,
  SD_MODE_4
};

enum {
  OPTION_ID_COLUMN = 0,
  OPTION_TYPE_COLUMN,
  OPTION_NAME_COLUMN = 0,
  OPTION_VALUE_COLUMN,
  NB_COLUMNS,
};

//////////////////////////////////////////
// HexoticPluginGUI_StdWidget
//////////////////////////////////////////

#include "ui_HexoticPluginGUI_StdWidget_QTD.h"
#include "ui_HexoticPluginGUI_AdvWidget_QTD.h"
#include "ui_HexoticPluginGUI_SizeMapsWidget_QTD.h"
#include "ui_HexoticPluginGUI_ViscousLayersWidget_QTD.h"
#include "HexoticPluginGUI.h"

#include <StdMeshersGUI_SubShapeSelectorWdg.h>

class HEXOTICPLUGIN_GUI_EXPORT HexoticPluginGUI_StdWidget : public QWidget,
                                            public Ui::HexoticPluginGUI_StdWidget_QTD
{
  Q_OBJECT

public:
  HexoticPluginGUI_StdWidget( QWidget* = 0, Qt::WindowFlags = 0 );
  ~HexoticPluginGUI_StdWidget();

public slots:
  void onSdModeSelected(int sdMode);
  void onSizeTypeChange(int);

public:
  QPixmap imageSdMode;
};

class HEXOTICPLUGIN_GUI_EXPORT HexoticPluginGUI_AdvWidget : public QWidget,
                                            public Ui::HexoticPluginGUI_AdvWidget_QTD
{
  Q_OBJECT

public:
  HexoticPluginGUI_AdvWidget( QWidget* = 0, Qt::WindowFlags = 0 );
  ~HexoticPluginGUI_AdvWidget();

  void AddOption( const char* name_value_type, bool isCustom = false );
  void GetOptionAndValue( QTreeWidgetItem * tblRow, QString& option, QString& value, bool& dflt );

public slots:

  void onDirBtnClicked();
  void itemChanged(QTreeWidgetItem * tblRow, int column);

};

class HEXOTICPLUGIN_GUI_EXPORT HexoticPluginGUI_SizeMapsWidget : public QWidget,
                                            public Ui::HexoticPluginGUI_SizeMapsWidget_QTD
{
  Q_OBJECT

public:
  HexoticPluginGUI_SizeMapsWidget( QWidget* = 0, Qt::WindowFlags = 0 );
  ~HexoticPluginGUI_SizeMapsWidget();
};

class HEXOTICPLUGIN_GUI_EXPORT HexoticPluginGUI_ViscousLayersWidget : public QWidget,
                                            public Ui::HexoticPluginGUI_ViscousLayersWidget_QTD
{
  Q_OBJECT

public:
  HexoticPluginGUI_ViscousLayersWidget( QWidget* = 0, Qt::WindowFlags = 0 );
  ~HexoticPluginGUI_ViscousLayersWidget();

public slots:
  void onSelectionChanged();

public:
  StdMeshersGUI_SubShapeSelectorWdg* myFacesWithLayers;
  StdMeshersGUI_SubShapeSelectorWdg* myImprintedFaces;
};

#endif
