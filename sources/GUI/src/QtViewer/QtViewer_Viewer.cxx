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

#include "QtViewer_Viewer.h"

#include "QtViewer_Selector.h"
#include "QtViewer_Scene.h"
#include "QtViewer_ViewFrame.h"
#include "QtViewer_ViewPort.h"

#include <SUIT_ViewManager.h>

#include <QColorDialog>
#include <QWheelEvent>
#include <QKeyEvent>
#include <QMenu>


//=======================================================================
// Name    : QtViewer_Viewer
// Purpose : Constructor
//=======================================================================
QtViewer_Viewer::QtViewer_Viewer( const QString& /*title*/, QWidget* widget )
: SUIT_ViewModel(),
  mySelector( 0 ),
  myWidget( widget )
{
}

//=======================================================================
// Name    : QtViewer_Viewer
// Purpose : Destructor
//=======================================================================
QtViewer_Viewer::~QtViewer_Viewer()
{
  delete mySelector;
}

QtViewer_ViewFrame* QtViewer_Viewer::createViewFrame( SUIT_Desktop* theDesktop, QWidget* theWidget )
{
  return new QtViewer_ViewFrame( theDesktop, this, theWidget );
}

//================================================================
// Function : createView
// Purpose  : 
//================================================================
SUIT_ViewWindow* QtViewer_Viewer::createView( SUIT_Desktop* theDesktop )
{
  QtViewer_ViewFrame* aViewFrame = createViewFrame( theDesktop, myWidget );

  connect( aViewFrame, SIGNAL( keyPressed( QKeyEvent* ) ),
           this, SLOT( onKeyEvent( QKeyEvent* ) ) );

  connect( aViewFrame, SIGNAL( keyReleased( QKeyEvent* ) ),
           this, SLOT( onKeyEvent( QKeyEvent* ) ) );

  connect( aViewFrame, SIGNAL( mousePressed( QMouseEvent* ) ),
           this, SLOT( onMouseEvent( QMouseEvent* ) ) );

  connect( aViewFrame, SIGNAL( mouseMoving( QMouseEvent* ) ),
           this, SLOT( onMouseEvent( QMouseEvent* ) ) );

  connect( aViewFrame, SIGNAL( mouseReleased( QMouseEvent* ) ),
           this, SLOT( onMouseEvent( QMouseEvent* ) ) );
  return aViewFrame;
}

//================================================================
// Function : contextMenuPopup
// Purpose  : 
//================================================================
void QtViewer_Viewer::contextMenuPopup( QMenu* thePopup )
{
  if( thePopup->actions().count() > 0 )
    thePopup->addSeparator();

  thePopup->addAction(tr("CHANGE_BGCOLOR"), this, SLOT(onChangeBgColor()));
}

//================================================================
// Function : getSelector
// Purpose  : 
//================================================================
QtViewer_Selector* QtViewer_Viewer::getSelector()
{
  if( !mySelector )
  {
    mySelector = new QtViewer_Selector( this );
    if( mySelector )
      connect( mySelector, SIGNAL(selSelectionDone()), this, SLOT( onSelectionDone()));
  }
  return mySelector;
}

//================================================================
// Function : getActiveView
// Purpose  : 
//================================================================
QtViewer_ViewFrame* QtViewer_Viewer::getActiveView() const
{
  if( SUIT_ViewManager* aViewManager = getViewManager() )
    return dynamic_cast<QtViewer_ViewFrame*>( aViewManager->getActiveView() );
  return nullptr;
}

//================================================================
// Function : getActiveViewPort
// Purpose  : 
//================================================================
QtViewer_ViewPort* QtViewer_Viewer::getActiveViewPort() const
{
  if( QtViewer_ViewFrame* aViewFrame = getActiveView() )
    return aViewFrame->getViewPort();
  return nullptr;
}

//================================================================
// Function : getActiveScene
// Purpose  : 
//================================================================
QtViewer_Scene* QtViewer_Viewer::getActiveScene() const
{
  if( QtViewer_ViewPort* aViewPort = getActiveViewPort() )
    return dynamic_cast<QtViewer_Scene*>( aViewPort->scene() );
  return nullptr;
}

//================================================================
// Function : onKeyEvent
// Purpose  : 
//================================================================
void QtViewer_Viewer::onKeyEvent( QKeyEvent* e )
{
  switch( e->type() )
  {
    case QEvent::KeyPress:
      handleKeyPress( e );
      break;
    case QEvent::KeyRelease:
      handleKeyRelease( e );
      break;
    default: break;
  }
}

//================================================================
// Function : onMouseEvent
// Purpose  : 
//================================================================
void QtViewer_Viewer::onMouseEvent(QMouseEvent* e)
{
  switch( e->type() )
  {
    case QEvent::MouseButtonPress:
      handleMousePress(e);
      break;
    case QEvent::MouseMove:
      handleMouseMove(e);
      break;
    case QEvent::MouseButtonRelease:
      handleMouseRelease(e);
      break;
    default: break;
  }
}
//================================================================
// Function : onWheelEvent
// Purpose  : 
//================================================================
void QtViewer_Viewer::onWheelEvent(QWheelEvent* e)
{
  switch(e->type())
  {
    case QEvent::Wheel:
      handleWheel(e);
      break;
    default: break;
  }
}

//================================================================
// Function : handleKeyPress
// Purpose  : 
//================================================================
void QtViewer_Viewer::handleKeyPress( QKeyEvent* e )
{ 
  Q_UNUSED(e);
}

//================================================================
// Function : handleKeyRelease
// Purpose  : 
//================================================================
void QtViewer_Viewer::handleKeyRelease(QKeyEvent* e)
{
  Q_UNUSED(e);
}

//================================================================
// Function : handleMousePress
// Purpose  : 
//================================================================
void QtViewer_Viewer::handleMousePress(QMouseEvent* e)
{
  Q_UNUSED(e);
}

void QtViewer_Viewer::handleWheel(QWheelEvent* e)
{
  Q_UNUSED(e);
}

//================================================================
// Function : handleMouseMove
// Purpose  : 
//================================================================
void QtViewer_Viewer::handleMouseMove(QMouseEvent* e)
{
  Q_UNUSED(e);
}

//================================================================
// Function : handleMouseRelease
// Purpose  : 
//================================================================
void QtViewer_Viewer::handleMouseRelease(QMouseEvent* e)
{
  QtViewer_ViewPort* aViewPort = getActiveViewPort();
  if ( getSelector() )
    getSelector()->select(aViewPort->selectionRect());
}

//================================================================
// Function : onChangeBgColor
// Purpose  : 
//================================================================

void QtViewer_Viewer::onChangeBgColor()
{
  if( QtViewer_ViewPort* aViewPort = getActiveViewPort() )
  {
    QColor aColor = QColorDialog::getColor( aColor, aViewPort );

    if (aColor.isValid())
      aViewPort->setBackgroundBrush(QBrush(aColor));
 }
}

//================================================================
// Function : onSelectionDone
// Purpose  : 
//================================================================
void QtViewer_Viewer::onSelectionDone()
{
  emit selectionChanged();
}

//================================================================
// Function : fitAll 
// Purpose  : 
//================================================================
void QtViewer_Viewer::fitAll()
{
  if (QtViewer_ViewPort* aViewPort = getActiveViewPort())
    aViewPort->fitAll();
}

//================================================================
// Function : fitSelect
// Purpose  : 
//================================================================
void QtViewer_Viewer::fitSelect()
{
  if (QtViewer_ViewPort* aViewPort = getActiveViewPort())
    aViewPort->fitSelect();
}

//================================================================
// Function : fitArea
// Purpose  : 
//================================================================
void QtViewer_Viewer::fitArea()
{
  if (QtViewer_ViewPort* aViewPort = getActiveViewPort())
    aViewPort->activateFitAreaAction();
}

//================================================================
// Function : zoom
// Purpose  : 
//================================================================
void QtViewer_Viewer::zoom()
{
  if (QtViewer_ViewPort* aViewPort = getActiveViewPort())
    aViewPort->activateZoomAction();
}

//================================================================
// Function : pan 
// Purpose  : 
//================================================================
void QtViewer_Viewer::pan()
{
  if (QtViewer_ViewPort* aViewPort = getActiveViewPort())
    aViewPort->activatePanAction();
}

//================================================================
// Function : globalPan 
// Purpose  : 
//================================================================
void QtViewer_Viewer::globalPan()
{
  if (QtViewer_ViewPort* aViewPort = getActiveViewPort())
    {
      aViewPort->fitAll();
      aViewPort->activateGlobalPanAction();
    }
}
