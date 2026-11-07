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

#include "HYBRIDPluginGUI_Dlg.h"

#include <SUIT_Session.h>
#include <SUIT_ResourceMgr.h>
#include <SUIT_FileDlg.h>
#include <SalomeApp_Tools.h>

//using namespace std;

//////////////////////////////////////////
// HYBRIDPluginGUI_StdWidget
//////////////////////////////////////////

HYBRIDPluginGUI_StdWidget::HYBRIDPluginGUI_StdWidget( QWidget* parent, Qt::WindowFlags f )
  : QWidget( parent, f )
{
  setupUi( this );

  myHeightFirstLayer->RangeStepAndValidator( 0, 1e+6, 1, "length_precision" );
  myBoundaryLayersMaxElemAngle->RangeStepAndValidator( 90, 360, 5, "angle_precision" );
  myBoundaryLayersProgression->RangeStepAndValidator( -100, 100, 0.1, "length_precision" );
  myCoreSize->RangeStepAndValidator( 0, 1e+6, 1, "length_precision" );

  connect( myCoreSizeEnabled,  SIGNAL( toggled(bool)), myCoreSize, SLOT( setEnabled(bool) ));
}

HYBRIDPluginGUI_StdWidget::~HYBRIDPluginGUI_StdWidget()
{
}
