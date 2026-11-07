// Copyright (C) 2013-2026  CEA, EDF, OPEN CASCADE
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

#ifndef QTVIEWER_VIEWFRAME_H
#define QTVIEWER_VIEWFRAME_H

#include "QtViewer.h"

#include <SUIT_ViewWindow.h>
#include <QPainterPath>

class QContextMenuEvent;

class QAction;

class SUIT_Desktop;

class QtViewer_Viewer;
class QtViewer_ViewPort;

/*
  Class       : QtViewer_ViewFrame
  Description : View frame of the graphics view
*/
class QTVIEWER_API QtViewer_ViewFrame : public SUIT_ViewWindow
{
  Q_OBJECT

public:
  enum { DumpId, FitAllId, FitRectId, FitSelectId, ZoomId, PanId, GlobalPanId, ResetId };

public:
  QtViewer_ViewFrame( SUIT_Desktop*, QtViewer_Viewer*, QWidget* w = nullptr );
  ~QtViewer_ViewFrame();

  QtViewer_Viewer*    getViewer() const { return myViewer; }
  QtViewer_ViewPort*  getViewPort() const  { return myViewPort; }

  virtual QImage          dumpView();
  
  virtual QString         getVisualParameters();
  virtual void            setVisualParameters( const QString& theParameters );

public slots:
  virtual void showEvent( QShowEvent* );
  virtual void hideEvent( QHideEvent* );

protected slots:
  void                    onViewPan();
  void                    onViewZoom();
  void                    onViewFitAll();
  void                    onViewFitArea();
  void                    onViewFitSelect();
  void                    onViewGlobalPan();
  void                    onViewReset();

private slots:
  void                    keyEvent( QKeyEvent* );
  void                    mouseEvent( QMouseEvent* );
  void                    wheelEvent( QWheelEvent* );
  void                    contextMenuEvent( QContextMenuEvent* );

signals:
  void                    keyPressed( QKeyEvent* );
  void                    keyReleased( QKeyEvent* );
  void                    mousePressed( QMouseEvent* );
  void                    mouseMoving( QMouseEvent* );
  void                    mouseReleased( QMouseEvent* );
  void                    mouseDoubleClicked( QMouseEvent* );
  void                    wheeling( QWheelEvent* );

  void                    sketchingFinished( QPainterPath );

  void Show( QShowEvent* );
  void Hide( QHideEvent* );

protected:
  virtual void            createActions();
  virtual void            createToolBar();
  virtual QString         filter() const;
  virtual bool            dumpViewToFormat( const QImage&, const QString& fileName, const QString& format );

private:
  QtViewer_Viewer*    myViewer;
  QtViewer_ViewPort*  myViewPort;
};

#endif
