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

#ifndef QTVIEWER_VIEWPORT_H
#define QTVIEWER_VIEWPORT_H

#include "QtViewer.h"
#include <QGraphicsView>

class QtViewer_PainterObject;
class QRubberBand;

/*
  Class       : QtViewer_ViewPort
  Description : View port of the graphics view
*/
class QTVIEWER_API QtViewer_ViewPort : public QGraphicsView
{
  Q_OBJECT

public:
  QtViewer_ViewPort(QWidget* theParent);
  ~QtViewer_ViewPort();

  void addItem(QGraphicsItem* theItem);

  void fitAll();
  void fitSelect();
  void fitRect(const QRectF& theRect);
  void pan(double theDX, double theDY);

  // rectangle selection
  void startDrawingRect(int x, int y);
  void drawingRect(int x, int y);
  void finishDrawingRect();
  QRect selectionRect();

  void activateZoomAction();
  void activateFitAreaAction(); 
  void activatePanAction(); 
  void activateGlobalPanAction();

  QImage dumpView(bool theWholeScene = false, QSizeF theSize = QSizeF());
  bool dumpViewToFormat(const QString& fileName, const QString& format);

  void addForegroundObject( QSharedPointer<QtViewer_PainterObject> obj) { foregroundObjects.append(obj); }
  void resetForeground();

signals:
  void vpMouseEvent(QMouseEvent*);

protected:

  virtual void mousePressEvent(QMouseEvent *event);
  virtual void mouseMoveEvent(QMouseEvent *event);
  virtual void mouseReleaseEvent(QMouseEvent *event);
  virtual void resizeEvent(QResizeEvent *event);
  virtual void wheelEvent(QWheelEvent *event);
  virtual void keyPressEvent(QKeyEvent *event);

  virtual void drawForeground(QPainter *painter, const QRectF &rect);

  void clearActions();
 
private:

  double myFitAllGap;
  QRubberBand* myRectBand;
  QPoint myRectBandStart;
  QPoint myRectBandEnd;

  bool fittingArea;
  bool zooming;
  bool panning;
  bool globalPanning;
  QPoint previousPos;
  QCursor* zoomCursor;

  QList<QSharedPointer<QtViewer_PainterObject> > foregroundObjects;
};

#endif
