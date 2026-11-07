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
// File    : BLSURFPluginGUI_StdWidget.cxx
// Authors : Gilles DAVID (OCC)
// ---
//

#include "HexoticPluginGUI_Dlg.h"

#include <SUIT_Session.h>
#include <SUIT_ResourceMgr.h>
#include <SUIT_FileDlg.h>
#include <SalomeApp_Tools.h>

//using namespace std;

//////////////////////////////////////////
// HexoticPluginGUI_StdWidget
//////////////////////////////////////////

HexoticPluginGUI_StdWidget::HexoticPluginGUI_StdWidget( QWidget* parent, Qt::WindowFlags f )
: QWidget( parent, f )
{
  setupUi( this );

  // Obtain precision from preferences
  int precision = SUIT_Session::session()->resourceMgr()->integerValue( "SMESH", "length_precision", -3 );

  myMinSize->setMinimum(0);
  myMinSize->setMaximum(1e15);
  myMinSize->setPrecision(precision);
//  myMinSize->setSpecialValueText(" ");

  myMaxSize->setMinimum(0);
  myMaxSize->setMaximum(1e15);
  myMaxSize->setPrecision(precision);
//  myMaxSize->setSpecialValueText(" ");

  myGeomApproxAngle->RangeStepAndValidator( 0, 180, 1, "angle_precision" );

  myHexoticSdMode->setCurrentIndex(SD_MODE_4);

  imageSdMode = SUIT_Session::session()->resourceMgr()->loadPixmap("HexoticPLUGIN", tr("Hexotic_SD_MODE_4_PIXMAP"));

  connect( myPhySizeType,  SIGNAL( currentIndexChanged(int)), SLOT( onSizeTypeChange(int) ));
  connect( myGeomSizeType, SIGNAL( currentIndexChanged(int)), SLOT( onSizeTypeChange(int) ));
}

HexoticPluginGUI_StdWidget::~HexoticPluginGUI_StdWidget()
{
}
void HexoticPluginGUI_StdWidget::onSdModeSelected(int sdMode) {
  imageSdMode = SUIT_Session::session()->resourceMgr()->loadPixmap("HexoticPLUGIN", tr(QString("Hexotic_SD_MODE_%1_PIXMAP").arg(sdMode+1).toStdString().c_str()));
  sdModeLabel->setPixmap(imageSdMode.scaled(sdModeLabel->size(),
      Qt::KeepAspectRatio,
      Qt::SmoothTransformation));
}

void HexoticPluginGUI_StdWidget::onSizeTypeChange(int index)
{
  if ( sender() == myPhySizeType )
  {
    myMinSize->setEnabled( index );
    myMaxSize->setEnabled( index );
  }
  else
  {
    myGeomApproxAngle->setEnabled( index );
  }
}

