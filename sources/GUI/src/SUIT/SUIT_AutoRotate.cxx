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

#include "SUIT_AutoRotate.h"
#include "SUIT_ViewWindow.h"

#include <QtGlobal>
#include <QDateTime>
#include <QMouseEvent>
#include <QPoint>



SUIT_AutoRotate::SUIT_AutoRotate(SUIT_ViewWindow* theWindow)
  : QObject()
  , myWindow(theWindow)
{
  initialize();

  if (myWindow) {
    // Let's intercept all view rotation relevant signals inside this class
    connect( myWindow, SIGNAL( vpStartRotate(int, int, qint64) ), this, SLOT( onStartRotate(int, int, qint64) ) );
    connect( myWindow, SIGNAL( vpRotate(int, int, qint64) ),      this, SLOT( onRotate(int, int, qint64) ) );
    connect( myWindow, SIGNAL( vpEndRotate(int, int, qint64) ),   this, SLOT( onEndRotate(int, int, qint64) ) );
    connect( myWindow, SIGNAL( mousePressed(SUIT_ViewWindow*, QMouseEvent*) ), this, SLOT( onStopRotate() ) );
  }
}


SUIT_AutoRotate::~SUIT_AutoRotate()
{
  delete [] myLog.myPosition;
  delete [] myLog.myTime;
}


void SUIT_AutoRotate::initialize()
{
  myLog.mySize = 16;
  myLog.myPosition = new QPoint [16];
  myLog.myTime = new qint64 [16];
  myLog.myHistorySize = 0;
}


void SUIT_AutoRotate::onStartRotate(int theMouseX, int theMouseY, qint64 theTime)
{
  myLog.myHistorySize = 0;
  addToLog(QPoint(theMouseX, theMouseY), theTime);
}


void SUIT_AutoRotate::onRotate(int theMouseX, int theMouseY, qint64 theTime)
{
  addToLog(QPoint(theMouseX, theMouseY), theTime);
}


void SUIT_AutoRotate::onEndRotate(int theMouseX, int theMouseY, qint64 theTime)
{
  startAnimation();
}


void SUIT_AutoRotate::onStopRotate()
{
  stopAnimation();
}


void SUIT_AutoRotate::addToLog(const QPoint& thePos, qint64 theTime)
{
  if (myLog.myHistorySize > 0 && thePos == myLog.myPosition[0]) {
    return;
  }

  int aLastIdx = myLog.myHistorySize;
  // If we have filled up the log, throw away the last item
  if (aLastIdx == myLog.mySize) { aLastIdx--; }

  for (int i = aLastIdx; i > 0; i--) {
    myLog.myPosition[i] = myLog.myPosition[i-1];
    myLog.myTime[i] = myLog.myTime[i-1];
  }

  myLog.myPosition[0] = thePos;
  myLog.myTime[0] = theTime;
  if (myLog.myHistorySize < myLog.mySize)
    myLog.myHistorySize++;
}
