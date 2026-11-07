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

#include "OCCViewer_AutoRotate.h"
#include "OCCViewer_ViewWindow.h"
#include "OCCViewer_ViewPort3d.h"

#include <SUIT_ViewWindow.h>

#include <gp_Quaternion.hxx>

#include <QtGlobal>
#include <QDateTime>
#include <QMouseEvent>
#include <QPoint>



OCCViewer_AutoRotate::OCCViewer_AutoRotate(SUIT_ViewWindow* theWindow)
  : SUIT_AutoRotate(theWindow)
{
}


OCCViewer_AutoRotate::~OCCViewer_AutoRotate()
{
  OCCViewer_ViewWindow *aWnd = dynamic_cast<OCCViewer_ViewWindow*>(myWindow);
  if (aWnd) {
    OCCViewer_ViewPort3d* aViewPort = aWnd->getViewPort();
    if (aViewPort) {
      aViewPort->stopRotation();
    }
  }
}


bool OCCViewer_AutoRotate::startAnimation()
{
  const int LastIdx = 4;
  const int PrevIdx = 10;
  if (myLog.myHistorySize > PrevIdx) {
    qint64 aStopTime = (QDateTime::currentMSecsSinceEpoch() - myLog.myTime[LastIdx]);
    // Compute the maximum time spent between two distinct mouse move events until we consider the
    // mouse being move at the time, the manual rotation action stops (mouse button released).
    // If the mouse was moving, then we trigger the continuous view animation.
    qint64 maxTime = qint64((myLog.myTime[LastIdx] - myLog.myTime[PrevIdx]) * 1.2);
    if (aStopTime < (qint64)maxTime) {
      OCCViewer_ViewWindow *aWnd = dynamic_cast<OCCViewer_ViewWindow*>(myWindow);
      if (aWnd) {
        OCCViewer_ViewPort3d* aViewPort = aWnd->getViewPort();
        if (aViewPort) {
          Handle(V3d_View) aView = aViewPort->getView();
          if ( !aView.IsNull() ) {
            Standard_Real rx, ry;
            aView->Size(rx, ry);

            Standard_Real dx=0., dy=0., dz=0.;
            dx = (Standard_Real(this->myLog.myPosition[LastIdx].x()) - this->myLog.myPosition[PrevIdx].x()) * M_PI / rx;
            dy = (this->myLog.myPosition[PrevIdx].y() - Standard_Real(this->myLog.myPosition[LastIdx].y())) * M_PI / ry;
            dz = atan2(Standard_Real(this->myLog.myPosition[LastIdx].x())-rx/2., ry/2.-Standard_Real(this->myLog.myPosition[LastIdx].y()))
               - atan2(Standard_Real(this->myLog.myPosition[PrevIdx].x())-rx/2., ry/2.-Standard_Real(this->myLog.myPosition[PrevIdx].y()));

            Handle(Graphic3d_Camera) aCamera = aView->Camera();
            gp_Pnt aRCenter = aView->GravityPoint();
            gp_Dir aZAxis (aCamera->Direction().Reversed());
            gp_Dir aYAxis (aCamera->Up());
            gp_Dir aXAxis (aYAxis.Crossed (aZAxis)); 

            gp_Trsf aRot[3], aTrsf;
            aRot[0].SetRotation (gp_Ax1 (aRCenter, aYAxis), -dx);
            aRot[1].SetRotation (gp_Ax1 (aRCenter, aXAxis), dy);
            aRot[2].SetRotation (gp_Ax1 (aRCenter, aZAxis), dz);
            aTrsf.Multiply (aRot[0]);
            aTrsf.Multiply (aRot[1]);
            aTrsf.Multiply (aRot[2]);

            gp_Quaternion quat = aTrsf.GetRotation();
            gp_Vec aAxis;
            Standard_Real anAngle=0., aScale=1.;
            quat.GetVectorAndAngle(aAxis, anAngle);
            aScale = aView->Scale();
            // std::cout << "Axis=[" << aAxis.X() << " , " << aAxis.Y() << " , " << aAxis.Z()
            //           << "]   Angle=" << anAngle * 180. * 3./aScale / M_PI 
            //           << " deg   z-Angle=" << dz * 180. * 12./aScale / M_PI << " deg   Scale=" << aScale << std::endl;
            if (anAngle != 0.)
              aViewPort->setRotationAxis(aAxis, anAngle*3./aScale, dz*12./aScale);
          }
        }
        return true;
      }
    }
  }

  return false;
}


bool OCCViewer_AutoRotate::stopAnimation()
{
  OCCViewer_ViewWindow *aWnd = dynamic_cast<OCCViewer_ViewWindow*>(myWindow);
  if (aWnd) {
    OCCViewer_ViewPort3d* aViewPort = aWnd->getViewPort();
    if (aViewPort) {
      aViewPort->stopRotation();
      return true;
    }
  }
  return false;
}