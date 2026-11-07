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

#include "QtViewer_ViewFrame.h"

#include "QtViewer_Viewer.h"
#include "QtViewer_ViewPort.h"

#include <QtxAction.h>
#include <QtxActionToolMgr.h>
#include <QtxMultiAction.h>
#include <QtxToolBar.h>

#include <SUIT_Desktop.h>
#include <SUIT_MessageBox.h>
#include <SUIT_Session.h>
#include <SUIT_ResourceMgr.h>

#include <QColor>
#include <QFrame>
#include <QFileDialog>

#include <QWheelEvent>
#include <QHBoxLayout>
#include <QImage>
#include <QMouseEvent>
#include <QString>
#include <QWheelEvent>

//=======================================================================
// Name    : QtViewer_ViewFrame
// Purpose : Constructor
//=======================================================================
QtViewer_ViewFrame::QtViewer_ViewFrame( SUIT_Desktop* d, QtViewer_Viewer* vw, QWidget* w )
: SUIT_ViewWindow( d ),
  myViewer( vw )
{
  QFrame* aFrame = new QFrame( this );
  setCentralWidget( aFrame );

  QBoxLayout* aLayout = new QHBoxLayout( aFrame );
  aLayout->setMargin( 0 );
  aLayout->setSpacing( 0 );

  if( w )
    myViewPort = dynamic_cast<QtViewer_ViewPort*>(w);
  else
    myViewPort = new QtViewer_ViewPort( aFrame );

  aLayout->addWidget( myViewPort );
  createActions();
  createToolBar();

  connect( myViewPort, SIGNAL( vpKeyEvent( QKeyEvent* ) ),
           this, SLOT( keyEvent( QKeyEvent* ) ) );
  connect( myViewPort, SIGNAL( vpMouseEvent( QMouseEvent* ) ),
           this, SLOT( mouseEvent( QMouseEvent* ) ) );
  connect( myViewPort, SIGNAL( vpWheelEvent( QWheelEvent* ) ),
           this, SLOT( wheelEvent( QWheelEvent* ) ) );
  connect( myViewPort, SIGNAL( vpContextMenuEvent( QContextMenuEvent* ) ),
           this, SLOT( contextMenuEvent( QContextMenuEvent* ) ) );
}

//=======================================================================
// Name    : QtViewer_ViewFrame
// Purpose : Destructor
//=======================================================================
QtViewer_ViewFrame::~QtViewer_ViewFrame()
{
}

//================================================================
// Function : createActions
// Purpose  : 
//================================================================
void QtViewer_ViewFrame::createActions()
{
  SUIT_ResourceMgr* aResMgr = SUIT_Session::session()->resourceMgr();
  QtxAction* anAction;

  // Dump view
  anAction = new QtxAction( tr( "MNU_DUMP_VIEW" ),
                           aResMgr->loadPixmap( "QtViewer", tr( "ICON_QTV_DUMP" ) ),
                           tr( "MNU_DUMP_VIEW" ), 0, this );
  anAction->setStatusTip( tr( "DSC_DUMP_VIEW" ) );
  connect( anAction, SIGNAL( triggered( bool ) ), this, SLOT( onDumpView() ) );
  toolMgr()->registerAction( anAction, DumpId );

  // FitAll
  anAction = new QtxAction( tr( "MNU_FITALL" ),
                           aResMgr->loadPixmap( "QtViewer", tr( "ICON_QTV_FITALL" ) ),
                           tr( "MNU_FITALL" ), 0, this );
  anAction->setStatusTip( tr( "DSC_FITALL" ) );
  connect( anAction, SIGNAL( triggered( bool ) ), this, SLOT( onViewFitAll() ) );
  toolMgr()->registerAction( anAction, FitAllId );

  // FitRect
  anAction = new QtxAction( tr( "MNU_FITRECT" ),
                           aResMgr->loadPixmap( "QtViewer", tr( "ICON_QTV_FITAREA" ) ),
                           tr( "MNU_FITRECT" ), 0, this );
  anAction->setStatusTip( tr( "DSC_FITRECT" ) );
  connect( anAction, SIGNAL( triggered( bool ) ), this, SLOT( onViewFitArea() ) );
  toolMgr()->registerAction( anAction, FitRectId );

  // FitSelect
  anAction = new QtxAction( tr( "MNU_FITSELECT" ),
                           aResMgr->loadPixmap( "QtViewer", tr( "ICON_QTV_FITSELECT" ) ),
                           tr( "MNU_FITSELECT" ), 0, this );
  anAction->setStatusTip( tr( "DSC_FITSELECT" ) );
  connect( anAction, SIGNAL( triggered( bool ) ), this, SLOT( onViewFitSelect() ) );
  toolMgr()->registerAction( anAction, FitSelectId );

  // Zoom
  anAction = new QtxAction( tr( "MNU_ZOOM_VIEW" ),
                           aResMgr->loadPixmap( "QtViewer", tr( "ICON_QTV_ZOOM" ) ),
                           tr( "MNU_ZOOM_VIEW" ), 0, this );
  anAction->setStatusTip( tr( "DSC_ZOOM_VIEW" ) );
  connect( anAction, SIGNAL( triggered( bool ) ), this, SLOT( onViewZoom() ) );
  toolMgr()->registerAction( anAction, ZoomId );

  // Panning
  anAction = new QtxAction( tr( "MNU_PAN_VIEW" ),
                           aResMgr->loadPixmap( "QtViewer", tr( "ICON_QTV_PAN" ) ),
                           tr( "MNU_PAN_VIEW" ), 0, this );
  anAction->setStatusTip( tr( "DSC_PAN_VIEW" ) );
  connect( anAction, SIGNAL( triggered( bool ) ), this, SLOT( onViewPan() ) );
  toolMgr()->registerAction( anAction, PanId );

  // Global Panning
  anAction = new QtxAction( tr( "MNU_GLOBALPAN_VIEW" ),
                           aResMgr->loadPixmap( "QtViewer", tr( "ICON_QTV_GLOBALPAN" ) ),
                           tr( "MNU_GLOBALPAN_VIEW" ), 0, this );
  anAction->setStatusTip( tr( "DSC_GLOBALPAN_VIEW" ) );
  connect( anAction, SIGNAL( triggered( bool ) ), this, SLOT( onViewGlobalPan() ) );
  toolMgr()->registerAction( anAction, GlobalPanId );
}

//================================================================
// Function : createToolBar
// Purpose  : 
//================================================================
void QtViewer_ViewFrame::createToolBar()
{
  int tid = toolMgr()->createToolBar( tr("LBL_TOOLBAR_LABEL"),                 // title (language-dependant)
				      QString( "QtViewerViewOperations" ), // name (language-independant)
				      false );                                 // disable floatable toolbar
  toolMgr()->append( DumpId, tid );

  QtxMultiAction* aScaleAction = new QtxMultiAction( this );
  aScaleAction->insertAction( toolMgr()->action( FitAllId ) );
  aScaleAction->insertAction( toolMgr()->action( FitRectId ) );
  aScaleAction->insertAction( toolMgr()->action( FitSelectId ) );
  aScaleAction->insertAction( toolMgr()->action( ZoomId ) );
  toolMgr()->append( aScaleAction, tid );

  QtxMultiAction* aPanAction = new QtxMultiAction( this );
  aPanAction->insertAction( toolMgr()->action( PanId ) );
  aPanAction->insertAction( toolMgr()->action( GlobalPanId ) );
  toolMgr()->append( aPanAction, tid );

  toolMgr()->append( toolMgr()->action( ResetId ), tid );
}

//================================================================
// Function : dumpView
// Purpose  : 
//================================================================
QImage QtViewer_ViewFrame::dumpView()
{
  return myViewPort->dumpView();
}

//================================================================
// Function : dumpViewToFormat
// Purpose  : 
//================================================================
bool QtViewer_ViewFrame::dumpViewToFormat( const QImage& image, const QString& fileName, const QString& format )
{
  bool isOK = myViewPort->dumpViewToFormat(fileName, format);
  if( !isOK )
    isOK = SUIT_ViewWindow::dumpViewToFormat( image, fileName, format );
  return isOK;
}

//================================================================
// Function : getVisualParameters
// Purpose  : 
//================================================================
QString QtViewer_ViewFrame::getVisualParameters()
{
  QTransform aTransform = myViewPort->transform();

  QString aString;
  aString.asprintf( "%.3f*%.3f*%.3f*%.3f*%.3f*%.3f*%.3f*%.3f*%.3f",
    aTransform.m11(), aTransform.m12(), aTransform.m13(),
    aTransform.m21(), aTransform.m22(), aTransform.m23(),
    aTransform.m31(), aTransform.m32(), aTransform.m33() );
  return aString;
}

//================================================================
// Function : setVisualParameters
// Purpose  : 
//================================================================
void QtViewer_ViewFrame::setVisualParameters( const QString& theParameters )
{
  QStringList aList = theParameters.split( '*' );
  if( aList.size() < 9 )
    return;

  bool anIsOk[9];
  QTransform aTransform( aList[0].toDouble( &anIsOk[0] ),
                         aList[1].toDouble( &anIsOk[1] ),
                         aList[2].toDouble( &anIsOk[2] ),
                         aList[3].toDouble( &anIsOk[3] ),
                         aList[4].toDouble( &anIsOk[4] ),
                         aList[5].toDouble( &anIsOk[5] ),
                         aList[6].toDouble( &anIsOk[6] ),
                         aList[7].toDouble( &anIsOk[7] ),
                         aList[8].toDouble( &anIsOk[8] ) );
  for( int i = 0; i < 9; i++ )
    if( !anIsOk[ i ] )
      return;

  myViewPort->setTransform(aTransform);
}

//================================================================
// Function : onViewPan
// Purpose  : 
//================================================================
void QtViewer_ViewFrame::onViewPan()
{
  myViewer->pan();
}

//================================================================
// Function : onViewZoom
// Purpose  : 
//================================================================
void QtViewer_ViewFrame::onViewZoom()
{
  myViewer->zoom();
}

//================================================================
// Function : onViewFitAll
// Purpose  : 
//================================================================
void QtViewer_ViewFrame::onViewFitAll()
{
    myViewer->fitAll();
}

//================================================================
// Function : onViewFitArea
// Purpose  : 
//================================================================
void QtViewer_ViewFrame::onViewFitArea()
{
    myViewer->fitArea();
}

//================================================================
// Function : onViewFitSelect
// Purpose  : 
//================================================================
void QtViewer_ViewFrame::onViewFitSelect()
{
    myViewer->fitSelect();
}

//================================================================
// Function : onViewGlobalPan
// Purpose  : 
//================================================================
void QtViewer_ViewFrame::onViewGlobalPan()
{
  myViewer->globalPan();
}

//================================================================
// Function : onViewReset
// Purpose  : 
//================================================================
void QtViewer_ViewFrame::onViewReset()
{
}

//================================================================
// Function : keyEvent
// Purpose  : 
//================================================================
void QtViewer_ViewFrame::keyEvent( QKeyEvent* e )
{
  switch ( e->type() )
  {
    case QEvent::KeyPress:
      emit keyPressed( e );
      break;
    case QEvent::KeyRelease:
      emit keyReleased( e );
      break;
    default:
      break;
  }
}

//================================================================
// Function : mouseEvent
// Purpose  : 
//================================================================
void QtViewer_ViewFrame::mouseEvent( QMouseEvent* e )
{
  switch ( e->type() )
  {
    case QEvent::MouseButtonPress:
      emit mousePressed( e );
      break;
    case QEvent::MouseMove:
      emit mouseMoving( e );
      break;
    case QEvent::MouseButtonRelease:
      emit mouseReleased( e );
      break;
    case QEvent::MouseButtonDblClick:
      emit mouseDoubleClicked( e );
      break;
    default:
      break;
  }
}
//================================================================
// Function : wheelEvent
// Purpose  : 
//================================================================
void QtViewer_ViewFrame::wheelEvent( QWheelEvent* e )
{
  switch ( e->type() )
  {
    case QEvent::Wheel:
      emit wheeling( e );
      break;
    default:
      break;
  }
}

//================================================================
// Function : contextMenuEvent
// Purpose  : 
//================================================================
void QtViewer_ViewFrame::contextMenuEvent( QContextMenuEvent* e )
{
  emit contextMenuRequested(e);
}

/*!
  \brief Handle show event.

  Emits Show() signal.

  \param theEvent show event
*/
void QtViewer_ViewFrame::showEvent( QShowEvent* theEvent )
{
  emit Show( theEvent );
}

/*!
  \brief Handle hide event.

  Emits Hide() signal.

  \param theEvent hide event
*/
void QtViewer_ViewFrame::hideEvent( QHideEvent* theEvent )
{
  emit Hide( theEvent );
}

/*!
  \return filters for image files
*/
QString QtViewer_ViewFrame::filter() const
{
  QStringList filters = SUIT_ViewWindow::filter().split( ";;", QString::SkipEmptyParts );
  filters << tr("POSTSCRIPT_FILES");
  return filters.join( ";;" );
}
