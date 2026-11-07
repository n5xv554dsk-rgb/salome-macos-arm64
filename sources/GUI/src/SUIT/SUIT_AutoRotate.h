// Copyright (C) 2007-2026  CEA, EDF, OPEN CASCADE
//
// Copyright (C) 2003-2007  OPEN CASCADE, EADS/CCR, LIP6, CEA/DEN,
// CEDRAT, EDF R&D, LEG, PRINCIPIA R&D, BUREAU VERITAS
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

#ifndef SUIT_AUTOROTATE_H
#define SUIT_AUTOROTATE_H

#include "SUIT.h"
#include <QObject>


class SUIT_ViewWindow;
class QMouseEvent;
class QPoint;


class SUIT_EXPORT SUIT_AutoRotate : public QObject
{
  Q_OBJECT

public:
  SUIT_AutoRotate(SUIT_ViewWindow* theWindow);
  virtual ~SUIT_AutoRotate();

  virtual void  initialize();

  virtual bool  startAnimation() = 0;
  virtual bool  stopAnimation() = 0;

public slots:
  virtual void  onStartRotate(int theMouseX, int theMouseY, qint64 theTime);
  virtual void  onRotate(int theMouseX, int theMouseY, qint64 theTime);
  virtual void  onEndRotate(int theMouseX, int theMouseY, qint64 theTime);
  virtual void  onStopRotate();

protected:
  void  addToLog(const QPoint& thePos, qint64 theTime);

  struct { // tracking mouse movement in a log
    short    mySize;
    short    myHistorySize;
    QPoint*  myPosition;
    qint64*  myTime;
  } myLog;

  SUIT_ViewWindow*  myWindow;
};

#endif
