// Copyright (C) 2023-2026  CEA, EDF
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

#pragma once

#include "SPV3D.h"
#include "PV3DViewer_ViewModel.h"

#include <SALOME_Prs.h>
#include <SALOME_InteractiveObject.hxx>
#include <SALOME_ListIO.hxx>

#include "SPV3D_Prs.h"


class QMouseEvent;
class pqPipelineSource;
class pqView;

//! Extends two interfaces #SPV3D_ViewModelBase and #SALOME_View 
class SPV3D_EXPORT SPV3D_ViewModel : public PV3DViewer_ViewModel, public SALOME_View 
{
  Q_OBJECT
public:
  void setView(pqView *view) { _view = view; }
  pqView *getView() const;
  void render() const;
public:
  //! Define string representation of the viewer type
  static QString           Type() { return "ParaView3D"; }

  SPV3D_ViewModel();
  virtual ~SPV3D_ViewModel();

  virtual void initialize();
  
  //! See #SUIT_ViewModel::createView
  virtual SUIT_ViewWindow* createView(SUIT_Desktop*);

  //! See #SUIT_ViewModel::createView
  virtual void setViewManager(SUIT_ViewManager* theViewManager);

  //! See #SUIT_ViewModel::contextMenuPopup
  virtual void contextMenuPopup( QMenu* );

  //! See #SUIT_ViewModel::getType
  virtual QString getType() const { return Type(); }

public:
  void enableSelection(bool isEnabled);
  bool isSelectionEnabled() const { return mySelectionEnabled; }
  void updatePVPrsPipeline( const SPV3D_Prs* aPrs);
  /* Reimplemented from SALOME_View */

  //! See #SALOME_View::Display( const SALOME_Prs* )
  void Display( const SALOME_PV3DPrs* ); 

  //! See #SALOME_View::Erase( const SALOME_PV3DPrs*, const bool = false )
  void Erase( const SALOME_PV3DPrs*, const bool = false );

  //! See #SALOME_View::EraseAll( SALOME_Displayer*, const bool = false )
  void EraseAll( SALOME_Displayer*, const bool = false );

  //! See #SALOME_View::getVisible( SALOME_ListIO& )
  virtual void GetVisible( SALOME_ListIO& );

  //! See #SALOME_View::CreatePrs( const char* entry = 0 )
  SALOME_Prs* CreatePrs( const char* entry = 0 );

  //! See #SALOME_View::isVisible( const Handle(SALOME_InteractiveObject)& )
  virtual bool isVisible( const Handle(SALOME_InteractiveObject)& );

  //! See #SALOME_View::Repaint()
  virtual void Repaint();

protected slots:
  void onMousePress(SUIT_ViewWindow*, QMouseEvent*);
  void onMouseMove(SUIT_ViewWindow*, QMouseEvent*);
  void onMouseRelease(SUIT_ViewWindow*, QMouseEvent*);

  void onViewCreated( SUIT_ViewWindow* );

  void onSourceCreated(pqPipelineSource* source);
  void showSelectedMode();

protected:
  pqPipelineSource* GeometrySource = nullptr;
  pqPipelineSource* MeshSource = nullptr;

private:
  bool mySelectionEnabled;
  pqView *_view = nullptr;
};
