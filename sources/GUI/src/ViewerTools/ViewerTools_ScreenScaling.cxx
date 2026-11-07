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

#include "ViewerTools_ScreenScaling.h"

#include <QApplication>
#include <QDesktopWidget>
#include <QEvent>
#include <QMouseEvent>
#include <QWheelEvent>

#include "utilities.h"

/*!
 * Namespace   : ViewerTools_ScreenScaling
 * Description : Tools for handle UI on screens with different scaling
 */
namespace ViewerTools_ScreenScaling
{
  // Returns pixel ratio for the current screen
  double getPR()
  {
    auto getPixelRatio = []() -> double
    {
      // Returns the device pixel ratio for the device as a floating point number.
      // Common values are 1 for normal-dpi displays and 2 for high-dpi "retina" displays.
      // Returns QT_SCALE_FACTOR if QT_SCALE_FACTOR was set.
      // Returns 2 on HDPI if QApplication::setAttribute(Qt::AA_EnableHighDpiScaling) was set.
      // Returns 2 * QT_SCALE_FACTOR if both of the features above were set.
      // NOTE. QT_SCALE_FACTOR breaks UI in a set (-1.0, 0.0) and (0.0, 1.0).
      // Negative values don't scale or break UI down, but end up with 1.0 pixel ratio.
      const double pixelRatio = QApplication::desktop()->devicePixelRatioF();
      MESSAGE("pixelRatio: " << pixelRatio);

      // Keep commented block here for a test case where we use QT_SCALE_FACTOR value instead.
      // QByteArray scaleFactorArr = qgetenv("QT_SCALE_FACTOR");
      // const QString scaleFactorStr = QString::fromLocal8Bit(scaleFactorArr);

      // bool isScale = false;
      // const double scaleFactor = scaleFactorStr.toDouble(&isScale);
      // if (isScale)
      // {
      //   MESSAGE("scaleFactor: " << scaleFactor);
      //   return scaleFactor;
      // }

      return pixelRatio;
    };

    // TODO: check if we need to get it out of static to handle moving to another screen
    static const double pixelRatio = getPixelRatio();
    return pixelRatio;
  }

  // Check if we have pixel ratio != 1.0
  bool isScaledPixelRatio()
  {
    auto isScaledPR = []() -> bool
    {
      // This an arbitrary value that seems to be meaningful for UI scaling.
      // It's not clear if we need smaller values.
      const double epsilon = 0.01;
      const double pixelRatio = ViewerTools_ScreenScaling::getPR();

      const bool isScaled = std::abs(pixelRatio - 1.0) > epsilon;
      MESSAGE("isScaled: " << isScaled);

      return isScaled;
    };

    static const bool isScaled = isScaledPR();
    return isScaled;
  }


  // Returns a copy of the given event with the local coordinates
  // updated with the current pixel ratio.
  QEvent* getDpiAwareEvent(QEvent* e, bool toMultiply/*  = true */)
  {
    // Calculate a new position
    auto getNewPos = [toMultiply](const QPointF& pos) -> QPointF
    {
      double pixelRatio = ViewerTools_ScreenScaling::getPR();
      if (!toMultiply)
      {
        pixelRatio = 1.0 / pixelRatio;
      }

      const double x = pos.x() * pixelRatio;
      const double y = pos.y() * pixelRatio;

      // Commented because of bloated output for casual debug
      // MESSAGE("New pos: " << x << ", " << y);

      return QPointF(x, y);
    };

    // Scales mouse event
    auto makeMouseEvent = [&getNewPos](QMouseEvent* e) -> QEvent*
    {
      const QPointF pos = e->localPos();
      const QPointF newPos = getNewPos(pos);

      const QPointF globalPos = e->globalPos();
      const QPointF globalNewPos = getNewPos(globalPos);

      // Commented because of bloated output for casual debug
      // MESSAGE("type: " << e->type() << "; old: " << pos.x() << ", " << pos.y() << "; new: " << newPos.x() << ", " << newPos.y());

      return new QMouseEvent(e->type(), newPos, globalNewPos, e->button(), e->buttons(), e->modifiers());
    };

    // Scales wheel event
    auto makeWheelEvent = [&getNewPos](QWheelEvent* e) -> QEvent*
    {
      const QPointF pos = e->posF();

      // Commented because of bloated output for casual debug
      // MESSAGE("Old pos: " << pos.x() << ", " << pos.y());

      return new QWheelEvent(
        getNewPos(pos), e->globalPosF(), e->pixelDelta(), e->angleDelta(), e->buttons(), e->modifiers(), e->phase(), e->inverted(), e->source());
    };

    // Return on start if we don't have any scaling
    if (!isScaledPixelRatio())
      return e;

    // Make a copy of the event with the new position
    const int aType = e->type();
    switch(aType)
    {
      case QEvent::MouseButtonPress:
      case QEvent::MouseButtonRelease:
      case QEvent::MouseMove:
      case QEvent::MouseButtonDblClick:
        return makeMouseEvent((QMouseEvent*)e);

      case QEvent::Wheel:
        return makeWheelEvent((QWheelEvent*)e);

      default:
        break;
    }

    return e;
  }
};
