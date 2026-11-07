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

#include "QtViewer_ViewPort.h"
#include "QtViewer_Scene.h"
#include <QGraphicsItem>
#include <QRubberBand>
#include <QMouseEvent>
#include <QCursor>
#include <QScrollBar>
#include <QPainter>
#include <QPrinter>

#include "SUIT_ResourceMgr.h"
#include "SUIT_Session.h"

#include "QtViewer_PainterObject.h"

//=======================================================================
// Name    : QtViewer_ViewPort
// Purpose : Constructor
//=======================================================================
QtViewer_ViewPort::QtViewer_ViewPort( QWidget* theParent )
: QGraphicsView( theParent )
{
  setScene(new QtViewer_Scene(this));

  setHorizontalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
  setVerticalScrollBarPolicy(Qt::ScrollBarAlwaysOff);

  setRenderHints(QPainter::Antialiasing | QPainter::SmoothPixmapTransform);
  
  setMouseTracking( true );
  setFocusPolicy( Qt::StrongFocus );

  myFitAllGap = 0;

  myRectBand = nullptr;
  myRectBandStart = QPoint();
  myRectBandEnd = QPoint();
  fittingArea = false;

  zooming = false;
  previousPos = QPoint();

  panning = false;
  globalPanning = false;
  
  SUIT_ResourceMgr* rmgr = SUIT_Session::session()->resourceMgr();
  zoomCursor = new QCursor( rmgr->loadPixmap( "QtViewer", tr( "ICON_QTV_CURSOR_ZOOM" ) ) );
}

//=======================================================================
// Name    : QtViewer_ViewPort
// Purpose : Destructor
//=======================================================================
QtViewer_ViewPort::~QtViewer_ViewPort()
{
  delete zoomCursor;
  zoomCursor = nullptr;
}

void QtViewer_ViewPort::resetForeground()
{
  for (QSharedPointer<QtViewer_PainterObject> obj : foregroundObjects)
    obj.reset();

  foregroundObjects.clear();
}

void QtViewer_ViewPort::drawForeground(QPainter *painter, const QRectF &rect)
{
  Q_UNUSED(rect);

  for (QSharedPointer<QtViewer_PainterObject> obj : foregroundObjects)
    obj->draw(painter);
}

void QtViewer_ViewPort::addItem( QGraphicsItem* theItem )
{
  scene()->addItem(theItem);
}

void QtViewer_ViewPort::fitAll()
{
  QRectF aRect;
  foreach (QGraphicsItem* item, scene()->items())
    { 
      if (item->isVisible())
        aRect = aRect.united(item->sceneBoundingRect());
    }
 
  fitInView( aRect.adjusted(-myFitAllGap, -myFitAllGap, myFitAllGap, myFitAllGap), Qt::KeepAspectRatio);
}

void QtViewer_ViewPort::fitSelect() 
{
  if (scene()->selectedItems().isEmpty())
      return;

  QRectF selectionRect;
  foreach (QGraphicsItem *item, scene()->selectedItems()) 
    selectionRect = selectionRect.united(item->sceneBoundingRect());

  if(!selectionRect.isNull())
    fitInView(selectionRect.adjusted(-myFitAllGap, -myFitAllGap, myFitAllGap, myFitAllGap), Qt::KeepAspectRatio); 
}

void QtViewer_ViewPort::fitRect(const QRectF& theRect)
{
  fitInView(theRect, Qt::KeepAspectRatio);
}

QRect QtViewer_ViewPort::selectionRect()
{
  if (myRectBand)
    {
      QRect aRect;
      aRect.setLeft(qMin( myRectBandStart.x(), myRectBandEnd.x()));
      aRect.setTop(qMin( myRectBandStart.y(), myRectBandEnd.y()));
      aRect.setRight(qMax( myRectBandStart.x(), myRectBandEnd.x()));
      aRect.setBottom(qMax( myRectBandStart.y(), myRectBandEnd.y()));
      return aRect;
    }
  return QRect();
}

void QtViewer_ViewPort::startDrawingRect( int x, int y )
{
  myRectBandStart = QPoint(x,y);

  if (!myRectBand) 
    {
      myRectBand = new QRubberBand(QRubberBand::Rectangle, this);
      myRectBand->setGeometry(QRect(myRectBandStart, QSize()));
      myRectBand->show();
    }
}

void QtViewer_ViewPort::drawingRect( int x, int y )
{
  myRectBandEnd = QPoint(x,y);
  myRectBand->setGeometry(QRect(myRectBandStart, myRectBandEnd).normalized());
}

void QtViewer_ViewPort::finishDrawingRect()
{
  myRectBand->hide();

  QRectF selectionRect = mapToScene(myRectBand->geometry()).boundingRect();

  if (fittingArea)
    fitInView(selectionRect, Qt::KeepAspectRatio);
  else
    {
      QList<QGraphicsItem *> selectedItems = scene()->items(selectionRect, Qt::IntersectsItemShape);
      for (QGraphicsItem *item : selectedItems) 
        item->setSelected(true);
    }
  
  myRectBandStart = QPoint();
  myRectBandEnd = QPoint();
  delete myRectBand;
  myRectBand = nullptr;
}

void QtViewer_ViewPort::mousePressEvent(QMouseEvent *event)
{ 
  if (!zooming && !panning && !globalPanning && items(event->pos()).count()==0 && (event->buttons() & Qt::LeftButton))
    {
      startDrawingRect(event->pos().x(), event->pos().y());
    }

  if (globalPanning)
    {
      QPoint p0 = viewport()->rect().center();
      QPoint p1 = event->pos();
      double deltaX = p0.x() - p1.x();
      double deltaY = p0.y() - p1.y();

      pan(deltaX, -deltaY);
    }
  QGraphicsView::mousePressEvent(event);
  emit vpMouseEvent(event);
}


void QtViewer_ViewPort::mouseMoveEvent(QMouseEvent *event)
{    
  if ((event->modifiers() & Qt::ShiftModifier) && (event->buttons() & Qt::LeftButton))
    activateZoomAction();

  if (event->buttons() & Qt::MiddleButton)
    activatePanAction();
    
  if (panning && event->buttons() & (Qt::LeftButton | Qt::MiddleButton))
    {
    QPoint currentPos = event->pos();

    if (!previousPos.isNull())
    {
      double deltaX = currentPos.x() - previousPos.x();
      double deltaY = currentPos.y() - previousPos.y();

      pan(deltaX, -deltaY);

    }
    previousPos = currentPos;  
    viewport()->update();
    }
  else if (zooming && (event->buttons() & Qt::LeftButton))
  {
    QPoint currentPos = event->pos();
    if (!previousPos.isNull())
    {
      int deltaX = currentPos.x() - previousPos.x();
      double scaleFactor = deltaX>0 ? 1.1 : 0.9;
      scale(scaleFactor, scaleFactor);
    }
    previousPos = currentPos;
  }
  else if (myRectBand)
    drawingRect(event->pos().x(), event->pos().y());

  QGraphicsView::mouseMoveEvent(event);
  emit vpMouseEvent(event);
}

void QtViewer_ViewPort::mouseReleaseEvent(QMouseEvent *event)
{
  if (myRectBand)
    finishDrawingRect(); 

  clearActions();
  QGraphicsView::mouseReleaseEvent(event);
  emit vpMouseEvent(event);
}

void QtViewer_ViewPort::resizeEvent(QResizeEvent *event)
{
  QSize oldSize = event->oldSize();
  QSize newSize = event->size();

  qreal w = static_cast<qreal>(newSize.width());
  qreal h = static_cast<qreal>(newSize.height());

  qreal w0 = static_cast<qreal>(oldSize.width());
  qreal h0 = static_cast<qreal>(oldSize.height());

  qreal widthRatio = w/w0;
  qreal heightRatio = h/h0;
   
  if (widthRatio>0 && heightRatio>0)
    {
      qreal scaleFactor = w<h ? widthRatio : heightRatio;
      scale(scaleFactor, scaleFactor);
    }

  QGraphicsView::resizeEvent(event);
}

void QtViewer_ViewPort::wheelEvent(QWheelEvent *event)
{
  int delta = event->angleDelta().y();
  double scaleFactor = delta>0 ? 1.1 : 0.9;
  scale(scaleFactor, scaleFactor);
}

void QtViewer_ViewPort::keyPressEvent(QKeyEvent *event)
{
  if (event->key() == Qt::Key_Escape)
    clearActions();

  QGraphicsView::keyPressEvent(event);
}

void QtViewer_ViewPort::clearActions()
{
  setCursor(Qt::ArrowCursor);
  fittingArea = false;
  zooming = false;
  panning  = false;
  globalPanning = false;
  previousPos = QPoint();
}
  
void QtViewer_ViewPort::activateZoomAction() 
{ 
  zooming = true;
  fittingArea = false;
  panning  = false;
  globalPanning = false;
  setCursor(*zoomCursor); 
}

void QtViewer_ViewPort::activateFitAreaAction() 
{ 
  fittingArea = true;
  zooming = false;
  panning  = false;
  globalPanning = false;
  setCursor(Qt::PointingHandCursor);
}

void QtViewer_ViewPort::activatePanAction() 
{
  panning = true; 
  fittingArea = false;
  zooming = false;
  globalPanning = false;
  setCursor(Qt::SizeAllCursor);
  viewport()->update();
}

void QtViewer_ViewPort::activateGlobalPanAction() 
{
  globalPanning = true;
  panning = false; 
  fittingArea = false;
  zooming = false;
  setCursor(Qt::CrossCursor);
}

void QtViewer_ViewPort::pan( double theDX, double theDY )
{
  if( QScrollBar* aHBar = horizontalScrollBar() )
  {
      int aNewValue = aHBar->value() - theDX;
      if( aNewValue < aHBar->minimum() )
        aHBar->setMinimum( aNewValue );
      if( aNewValue > aHBar->maximum() )
        aHBar->setMaximum( aNewValue );
    
      aHBar->setValue( aHBar->value() - theDX );
  }
  if( QScrollBar* aVBar = verticalScrollBar() )
  {
      int aNewValue = aVBar->value() + theDY;
      if( aNewValue < aVBar->minimum() )
        aVBar->setMinimum( aNewValue );
      if( aNewValue > aVBar->maximum() )
        aVBar->setMaximum( aNewValue );
    aVBar->setValue( aVBar->value() + theDY );
  }
}

//================================================================
// Function : dumpView
// Purpose  : 
//================================================================
QImage QtViewer_ViewPort::dumpView( bool theWholeScene,
                                        QSizeF theSize )
{
   QPixmap screenshot = viewport()->grab();
   return screenshot.toImage();
}

bool QtViewer_ViewPort::dumpViewToFormat(const QString& fileName, const QString& format)
{
  if( format!="PS" && format!="EPS" )
    return false;

  QPrinter printer(QPrinter::ScreenResolution);
  printer.setOutputFormat(QPrinter::NativeFormat); 
  printer.setOutputFileName(fileName); 

  QPainter painter;
  if (!painter.begin(&printer))
    return false;

  render(&painter);
  if (!painter.end())
    return false;

  return true;
} 
