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

#ifndef QTVIEWER_VIEWER_H
#define QTVIEWER_VIEWER_H

#include "QtViewer.h"
#include <SUIT_ViewModel.h>

class QKeyEvent;
class QMouseEvent;
class QWheelEvent;

class SUIT_ViewWindow;

class QtViewer_Selector;
class QtViewer_Scene;
class QtViewer_ViewFrame;
class QtViewer_ViewPort;

/*
  Class       : QtViewer_Viewer
  Description : View model of the graphics view
*/
class QTVIEWER_API QtViewer_Viewer: public SUIT_ViewModel
{
  Q_OBJECT

public:
  QtViewer_Viewer(const QString& title, QWidget* widget = nullptr);
  ~QtViewer_Viewer();

public:
  virtual SUIT_ViewWindow*      createView(SUIT_Desktop*);

  virtual QString getType() const { return Type(); }
  static QString Type() { return "QtViewer"; }

  virtual void contextMenuPopup(QMenu*);

public:
  QtViewer_Selector* getSelector();

  QtViewer_ViewFrame* getActiveView() const;
  QtViewer_ViewPort* getActiveViewPort() const;
  QtViewer_Scene* getActiveScene() const;

  void fitAll();
  void fitSelect();
  void fitArea();
  void zoom();
  void pan();
  void globalPan();

signals:
  void selectionChanged();

protected:

  virtual QtViewer_ViewFrame* createViewFrame(SUIT_Desktop* theDesktop, QWidget* theWidget);

protected slots:
  virtual void onKeyEvent(QKeyEvent*);
  virtual void onMouseEvent(QMouseEvent*);
  virtual void onWheelEvent(QWheelEvent*);

  virtual void onSelectionDone();
  virtual void onChangeBgColor();

protected:
  virtual void handleKeyPress(QKeyEvent*);
  virtual void handleKeyRelease(QKeyEvent*);
  virtual void handleMouseMove(QMouseEvent*);
  virtual void handleMousePress(QMouseEvent*);
  virtual void handleMouseRelease(QMouseEvent*);
  virtual void handleWheel(QWheelEvent*);

protected:
  QtViewer_Selector*        mySelector;
  QWidget*                      myWidget;
};

#endif
