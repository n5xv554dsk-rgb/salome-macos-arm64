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

#ifdef WIN32
#pragma warning( disable:4251 )
#endif

#include "SPV3D.h"
#include "Qtx.h"
#include "PV3DViewer_ViewWindow.h"
#include "SPV3D_Prs.h"

#include "SALOME_InteractiveObject.hxx"
#include "SALOME_ListIO.hxx"

#include <list>
#include <memory>

class SPV3D_ViewModel;
class SPV3D_CADSelection;

//! Define a container for SALOME PV3D view window
class SPV3D_EXPORT SPV3D_ViewWindow : public PV3DViewer_ViewWindow 
{
  Q_OBJECT

 public:
  //! To construct #SPV3D_ViewWindow instance
  SPV3D_ViewWindow(SUIT_Desktop* theDesktop, SPV3D_ViewModel* theModel);

  SPV3D_Prs *findOrCreatePrs( const char* entry );

  unsigned int isEntryAlreadyExist( const char* entry ) const;

  void ExportToSPV3D(vtkPolyData* ds, const char*);

  void init();

  virtual ~SPV3D_ViewWindow();
  
  bool isVisible(const Handle(SALOME_InteractiveObject)& theIObject);

  /* display */         
  //----------------------------------------------------------------------------
  //! Redirect the request to #SPV3D_View::Display (to support old code)
  virtual void Display(const Handle(SALOME_InteractiveObject)& theIObject,
                       bool theImmediatly = true);

  //! Redirect the request to #SPV3D_View::DisplayOnly (to support old code)
  virtual void DisplayOnly(const Handle(SALOME_InteractiveObject)& theIObject);

  //! Redirect the request to #SPV3D_View::Erase (to support old code)
  virtual void Erase(const Handle(SALOME_InteractiveObject)& theIObject,
                     bool theImmediatly = true);

  //! Redirect the request to #SPV3D_View::DisplayAll (to support old code)
  virtual void DisplayAll();

  //! Redirect the request to #SPV3D_View::EraseAll (to support old code)
  virtual void EraseAll();

  //! To repaint the viewer
  virtual void Repaint(bool theUpdateTrihedron = true);

  //! Enable/disable selection
  virtual void SetSelectionEnabled( bool );

 signals:
  void Show( QShowEvent * );
  void Hide( QHideEvent * );

public slots:
  virtual void showEvent( QShowEvent * );
  virtual void hideEvent( QHideEvent * );
  void showCenterAxes(bool);
  void pickCenterOfRotation(int posx, int posy);
  void goSelect(bool val);

protected slots:
  void onKeyPressed(QKeyEvent* event);
  void onKeyReleased(QKeyEvent* event);
  void onMousePressed(QMouseEvent* event);
  void onMouseDoubleClicked(QMouseEvent* event);
  void onMouseReleased(QMouseEvent* event);
  void onMouseMoving(QMouseEvent* event);

protected:
  SPV3D_CADSelection *mySelection = nullptr;
  int myToolBar = -1;
  SPV3D_ViewModel* myModel;
  //std::list< std::pair<std::string, std::unique_ptr<SPV3D_EXPORTSPV3DData> > > myPrs;
  std::list< std::pair<std::string, SPV3D_Prs* > > Prs;
  std::unique_ptr<SPV3D_EXPORTSPV3DData> myPrs;
};

#ifdef WIN32
#pragma warning( default:4251 )
#endif
