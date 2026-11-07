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

#ifndef QTVIEWER_SELECTOR_H
#define QTVIEWER_SELECTOR_H

#include "QtViewer.h"

#include <QObject>
#include <QRectF>

class QtViewer_Viewer;

/*
  Class       : QtViewer_Selector
  Description : Selector of the graphics view
*/
class QTVIEWER_API QtViewer_Selector : public QObject
{
  Q_OBJECT

public:
  QtViewer_Selector(QtViewer_Viewer*);
  ~QtViewer_Selector();

public:

  virtual void  select(const QRectF&);    

signals:
  void selSelectionDone();

protected:
  QtViewer_Viewer* myViewer;
};

#endif
