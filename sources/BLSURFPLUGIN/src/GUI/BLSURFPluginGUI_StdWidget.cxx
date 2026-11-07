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

#include "BLSURFPluginGUI_Dlg.h"

#include "SMESHGUI_SpinBox.h"

#include <algorithm>
#include <iostream>

using namespace std;

//////////////////////////////////////////
// BLSURFPluginGUI_StdWidget
//////////////////////////////////////////

BLSURFPluginGUI_StdWidget::BLSURFPluginGUI_StdWidget( QWidget* parent, Qt::WindowFlags f )
: QWidget( parent, f )
{
  setupUi( this );
  myPhySize->RangeStepAndValidator(0, COORD_MAX, 10.0, "length_precision");
  myMinSize->RangeStepAndValidator(0, COORD_MAX, 10.0, "length_precision");
  myMaxSize->RangeStepAndValidator(0, COORD_MAX, 10.0, "length_precision");
  myGradation->RangeStepAndValidator(1.0, COORD_MAX, 0.1, "length_precision");
  myVolumeGradation->RangeStepAndValidator(1.0, COORD_MAX, 0.1, "length_precision");
  myAngleMesh->RangeStepAndValidator(0, 90, 0.5, "angular_precision");
  myChordalError->RangeStepAndValidator(0, COORD_MAX, 0.1, "length_precision");
  myAnisotropicRatio->RangeStepAndValidator(0, COORD_MAX, 0.1, "length_precision");
  myTinyEdgeLength->RangeStepAndValidator(0, COORD_MAX, 0.1, "length_precision");
  myTinyEdgeOptimisLength->RangeStepAndValidator(0, COORD_MAX, 0.1, "length_precision");
  myCorrectSurfaceIntersectionMaxCost->RangeStepAndValidator(0, COORD_MAX, 1);
  myBadElementAspectRatio->RangeStepAndValidator(0, COORD_MAX, 1000, "length_precision");
  mySurfaceProximityRatio->RangeStepAndValidator(1, COORD_MAX, 1, "length_precision");
  myVolumeProximityRatio->RangeStepAndValidator(1, COORD_MAX, 1, "length_precision");
  myMinSize->setText("");
  myMaxSize->setText("");
  myAngleMesh->setText("");
  myChordalError->setText("");
  myAnisotropicRatio->setText("");
  myTinyEdgeLength->setText("");
  myTinyEdgeOptimisLength->setText("");
  myCorrectSurfaceIntersectionMaxCost->setText("");
  myBadElementAspectRatio->setText("");
  myButtonGroupElementType->setId(myRadioButtonTriangles, Triangles);
  myButtonGroupElementType->setId(myRadioButtonQuadrangleDominant, QuadrangleDominant);
  myButtonGroupElementType->setId(myRadioButtonQuadrangles, Quadrangles);
}

BLSURFPluginGUI_StdWidget::~BLSURFPluginGUI_StdWidget()
{
}

void BLSURFPluginGUI_StdWidget::onPhysicalMeshChanged() {
  bool isPhysicalGlobalSize = (myPhysicalMesh->currentIndex() == PhysicalGlobalSize);
  bool isPhysicalLocalSize  = (myPhysicalMesh->currentIndex() == PhysicalLocalSize);
  bool isCustom             = (isPhysicalGlobalSize || isPhysicalLocalSize) ;

  myPhySize->setEnabled(isCustom);
  myPhySizeRel->setEnabled(isCustom);
}

void BLSURFPluginGUI_StdWidget::onGeometricMeshChanged() {
  bool isCustom            = (myGeometricMesh->currentIndex() != DefaultGeom);

  myAngleMesh->setEnabled( isCustom );
  myChordalError->setEnabled( isCustom );

}

void BLSURFPluginGUI_StdWidget::resizeWidgets() {
  // Set minimum width of spin boxes
  // Main parameters
  QFontMetrics metrics1( myPhySize->font() );
  QFontMetrics metrics2( myMinSize->font() );
  QFontMetrics metrics3( myMaxSize->font() );
  int width1 = metrics1.width(myPhySize->GetString());
  int width2 = metrics2.width(myMinSize->GetString());
  int width3 = metrics3.width(myMaxSize->GetString());
  int max_width = max(width1,width2);
  max_width = max(max_width, width3);
  myPhySize->setMinimumWidth( max_width+50 );
  myMinSize->setMinimumWidth( max_width+50 );
  myMaxSize->setMinimumWidth( max_width+50 );
   // Geometrical parameters
  metrics1 = QFontMetrics(myAngleMesh->font());
  metrics2 = QFontMetrics(myChordalError->font());
  width1 = metrics1.width(myAngleMesh->GetString());
  width2 = metrics2.width(myChordalError->GetString());
  max_width = max(width1,width2); 
  myAngleMesh->setMinimumWidth( max_width+50 );
  myChordalError->setMinimumWidth( max_width+50 );
  // Other parameters
  metrics1 = QFontMetrics(myAnisotropicRatio->font());
  metrics2 = QFontMetrics(myTinyEdgeLength->font());
  metrics3 = QFontMetrics(myBadElementAspectRatio->font());
  width1 = metrics1.width(myAnisotropicRatio->GetString());
  width2 = metrics2.width(myTinyEdgeLength->GetString());
  width3 = metrics3.width(myBadElementAspectRatio->GetString());
  max_width = max(width1,width2); 
  max_width = max(max_width, width3);
  myAnisotropicRatio->setMinimumWidth( max_width+50 );
  myTinyEdgeLength->setMinimumWidth( max_width+50 );
  myBadElementAspectRatio->setMinimumWidth( max_width+50 );
}

void BLSURFPluginGUI_StdWidget::onEditingFinished() {
  SMESHGUI_SpinBox* spinBox = (SMESHGUI_SpinBox*)sender();
  bool isEmpty = spinBox->editor()->text().isEmpty();
  if ( isEmpty ) {
    spinBox->SetValue(-1);
    spinBox->setText("");
  }
}
