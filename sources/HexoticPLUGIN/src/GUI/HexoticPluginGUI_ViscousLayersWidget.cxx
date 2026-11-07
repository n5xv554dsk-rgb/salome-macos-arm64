// Copyright (C) 2015-2026  CEA, EDF
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
// File    : HexoticPluginGUI_ViscousLayersWidget.cxx
//

#include "HexoticPluginGUI_Dlg.h"

#include <SUIT_Session.h>
#include <SUIT_ResourceMgr.h>

#include <StdMeshersGUI_SubShapeSelectorWdg.h>

//////////////////////////////////////////
// HexoticPluginGUI_ViscousLayersWidget
//////////////////////////////////////////

HexoticPluginGUI_ViscousLayersWidget::HexoticPluginGUI_ViscousLayersWidget( QWidget* parent, Qt::WindowFlags f )
: QWidget( parent, f )
{
  setupUi( this );

  // Obtain precision from preferences
  int precision = SUIT_Session::session()->resourceMgr()->integerValue( "SMESH", "length_precision", -3 );

  myNbLayers->setMinimum(0);
  myNbLayers->setSingleStep( 1 );

  myFirstLayerSize->setMinimum(0);
  myFirstLayerSize->setPrecision(precision);
  myFirstLayerSize->setSingleStep(0.1);

  myGrowth->setMinimum(0);
  myFirstLayerSize->setPrecision(precision);
  myGrowth->setSingleStep( 0.1 );

  myFacesWithLayers = new StdMeshersGUI_SubShapeSelectorWdg(0,TopAbs_FACE);
  QHBoxLayout* layoutFacesWithLayers = new QHBoxLayout(myContainerFacesWithLayers);
  layoutFacesWithLayers->setMargin(0);
  layoutFacesWithLayers->addWidget(myFacesWithLayers);

  myImprintedFaces = new StdMeshersGUI_SubShapeSelectorWdg(0,TopAbs_FACE);
  QHBoxLayout* layoutImprintedFaces = new QHBoxLayout(myContainerImprintedFaces);
  layoutImprintedFaces->setMargin(0);
  layoutImprintedFaces->addWidget(myImprintedFaces);

  connect( myFacesWithLayers, SIGNAL(selectionChanged()), this, SLOT(onSelectionChanged()));
  connect( myImprintedFaces, SIGNAL(selectionChanged()), this, SLOT(onSelectionChanged()));
}

HexoticPluginGUI_ViscousLayersWidget::~HexoticPluginGUI_ViscousLayersWidget()
{
}

void HexoticPluginGUI_ViscousLayersWidget::onSelectionChanged()
{
  StdMeshersGUI_SubShapeSelectorWdg* send = (StdMeshersGUI_SubShapeSelectorWdg*)sender();

  bool isDefault = (send == myFacesWithLayers);
  myFacesWithLayers->ShowPreview(isDefault);
  myImprintedFaces->ShowPreview(!isDefault);
  if (isDefault)
    myImprintedFaces->ClearSelected();
  else
	myFacesWithLayers->ClearSelected();

}
