// Copyright (C) 2023-2026  CEA, EDF
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

#include <QMenu>
#include <QColorDialog>
#include <QToolBar>
#include <QTimer>
#include <QDebug>

#include <vtkActorCollection.h>

#include "SPV3D_ViewModel.h"
#include "SPV3D_ViewWindow.h"
#include "PVViewer_Core.h"

#include <pqActiveObjects.h>
#include <pqApplicationCore.h>
#include <pqObjectBuilder.h>
#include <pqPipelineSource.h>
#include <pqRenderView.h>

#include <vtkSMPropertyHelper.h>
#include <vtkSMParaViewPipelineControllerWithRendering.h>
#include <vtkSMRenderViewProxy.h>
#include <vtkSMRepresentationProxy.h>
#include <vtkSMSourceProxy.h>
#include <vtkSMPVRepresentationProxy.h>

#include "SUIT_ViewModel.h"
#include "SUIT_ViewManager.h"

#include "SALOME_InteractiveObject.hxx"

#include "QtxActionToolMgr.h"
#include "QtxBackgroundTool.h"

#include <pqObjectBuilder.h>
#include <pqApplicationCore.h>
#include <pqServerManagerModel.h>
#include <pqServerResource.h>
#include <pqView.h>
#include <pqPVApplicationCore.h>
#include <pqParaViewBehaviors.h>

#include <QApplication>

// VSR: Uncomment below line to allow texture background support in PV3D viewer
#define PV3D_ENABLE_TEXTURED_BACKGROUND

/*!
  Constructor
*/
SPV3D_ViewModel::SPV3D_ViewModel()
{
  mySelectionEnabled = true;
}

/*!
  Destructor
*/
SPV3D_ViewModel::~SPV3D_ViewModel() 
{
}


void SPV3D_ViewModel::initialize()
{
}

void SPV3D_ViewModel::render() const
{
  if( _view )
    _view->render();
}

/*!Create new instance of view window on desktop \a theDesktop.
 *\retval SUIT_ViewWindow* - created view window pointer.
 */
SUIT_ViewWindow* SPV3D_ViewModel::createView( SUIT_Desktop* theDesktop )
{
  SPV3D_ViewWindow* aViewWindow = new SPV3D_ViewWindow(theDesktop, this);

  aViewWindow->SetSelectionEnabled( isSelectionEnabled() );
  PVViewer_Core::ParaviewInitApp();
  QApplication::instance()->installEventFilter( PVViewer_Core::GetPVAppCore() );
  new pqParaViewBehaviors(aViewWindow,aViewWindow);
  pqObjectBuilder *builder(pqApplicationCore::instance()->getObjectBuilder());
  QObject::connect(builder, &pqObjectBuilder::sourceCreated, this, &SPV3D_ViewModel::onSourceCreated);
  pqServer *serv(pqApplicationCore::instance()->getServerManagerModel()->findServer(pqServerResource("builtin:")));
  pqView *view=builder->createView(QString("RenderView"),serv);
  setView(view);
  
  aViewWindow->init();
  
  return aViewWindow;
}

/*!
  Sets new view manager
  \param theViewManager - new view manager
*/
void SPV3D_ViewModel::setViewManager(SUIT_ViewManager* theViewManager)
{
  SUIT_ViewModel::setViewManager(theViewManager);

  if ( !theViewManager )
    return;

  connect(theViewManager, SIGNAL(mousePress(SUIT_ViewWindow*, QMouseEvent*)), 
          this, SLOT(onMousePress(SUIT_ViewWindow*, QMouseEvent*)));
  
  connect(theViewManager, SIGNAL(mouseMove(SUIT_ViewWindow*, QMouseEvent*)), 
          this, SLOT(onMouseMove(SUIT_ViewWindow*, QMouseEvent*)));
  
  connect(theViewManager, SIGNAL(mouseRelease(SUIT_ViewWindow*, QMouseEvent*)), 
          this, SLOT(onMouseRelease(SUIT_ViewWindow*, QMouseEvent*)));

  connect(theViewManager, SIGNAL(viewCreated(SUIT_ViewWindow*)), 
	  this, SLOT(onViewCreated(SUIT_ViewWindow*)));
}

/*!
  Builds popup for vtk viewer
*/
void SPV3D_ViewModel::contextMenuPopup( QMenu */*thePopup*/ )
{
  // NYI
}

/*!
  SLOT: called on mouse button press, empty implementation
*/
void SPV3D_ViewModel::onMousePress(SUIT_ViewWindow* /*vw*/, QMouseEvent* /*event*/)
{}

/*!
  SLOT: called on mouse move, empty implementation
*/
void SPV3D_ViewModel::onMouseMove(SUIT_ViewWindow* /*vw*/, QMouseEvent* /*event*/)
{}

/*!
  SLOT: called on mouse button release, empty implementation
*/
void SPV3D_ViewModel::onMouseRelease(SUIT_ViewWindow* /*vw*/, QMouseEvent* /*event*/)
{}

/*!
  Enables/disables selection
  \param isEnabled - new state
*/
void SPV3D_ViewModel::enableSelection(bool isEnabled)
{
  mySelectionEnabled = isEnabled;
  //!! To be done for view windows
  if (SUIT_ViewManager* aViewManager = getViewManager()) {
    QVector<SUIT_ViewWindow*> aViews = aViewManager->getViews();
    for ( int i = 0; i < aViews.count(); i++ )
    {
      if ( SPV3D_ViewWindow* aView = dynamic_cast<SPV3D_ViewWindow*>(aViews.at( i )) )
        aView->SetSelectionEnabled( isEnabled );
    }
  }

  if(!isEnabled) {
    //clear current selection in the viewer
    bool blocked = blockSignals( true );
    /*if ( SUIT_ViewManager* aViewMgr = getViewManager() ) {
      if( SPV3D_ViewWindow* aViewWindow = dynamic_cast<SPV3D_ViewWindow*>( aViewMgr->getActiveView() ) ){
        //NYI
      }
    }*/
    blockSignals( blocked );  
  }

}

pqView *SPV3D_ViewModel::getView() const
{
  return _view;
}

void SPV3D_ViewModel::updatePVPrsPipeline(const SPV3D_Prs* aPrs)
{
  if (aPrs->GetRepresentation())
  {
    aPrs->GetRepresentation()->setVisible(0);
    delete(aPrs->GetRepresentation());
  }
  pqObjectBuilder *builder(pqApplicationCore::instance()->getObjectBuilder());
  pqActiveObjects::instance().setActiveView(getView());
  pqPipelineSource *mySourceProducer = aPrs->GetSourceProducer();
  pqDataRepresentation* myRepr(builder->createDataRepresentation(mySourceProducer->getOutputPort(0),getView(),"CADRepresentation"));//"GeometryRepresentation"
  vtkSMViewProxy::RepresentationVisibilityChanged(myRepr->getViewProxy(), myRepr->getProxy(), true);
  aPrs->SetRepresentation(myRepr);
  myRepr->setVisible(1);
  vtkSMPVRepresentationProxy* proxy(dynamic_cast<vtkSMPVRepresentationProxy*>(myRepr->getProxy()));
  if(proxy)
  {
    vtkSMPropertyHelper inputHelper(proxy, "Input");
    vtkSMSourceProxy* input = vtkSMSourceProxy::SafeDownCast(inputHelper.GetAsProxy());
    input->UpdatePipeline();
  }
}
/*!
  Display presentation
  \param prs - presentation
*/
void SPV3D_ViewModel::Display( const SALOME_PV3DPrs* prs )
{
  if(const SPV3D_Prs* aPrs = dynamic_cast<const SPV3D_Prs*>( prs ))
  {
    updatePVPrsPipeline(aPrs);
    getView()->resetDisplay();
    getView()->render();
  }
  else
  {
    qWarning()<< "SPV3D_ViewModel::Display: Something wrong";
  }
}

/*!
  Erase presentation
  \param prs - presentation
  \param forced - removes object from view
*/
void SPV3D_ViewModel::Erase( const SALOME_PV3DPrs* prs, const bool /*forced*/ )
{
  // NYI - hide a source
  if(const SPV3D_Prs* aPrs = dynamic_cast<const SPV3D_Prs*>( prs )){
    if(aPrs->IsNull())
      return;
    aPrs->hide();
    updatePVPrsPipeline(aPrs);
    getView()->resetDisplay();
    getView()->render();
  }
}

/*!
  Erase all presentations
  \param forced - removes all objects from view
*/
void SPV3D_ViewModel::EraseAll( SALOME_Displayer* d, const bool forced )
{
  SALOME_View::EraseAll( d, forced );
  if(SPV3D_ViewWindow* aViewWindow = dynamic_cast<SPV3D_ViewWindow*>(getViewManager()->getActiveView()))
    aViewWindow->EraseAll();
  Repaint();
}

/*!
  Create presentation corresponding to the entry
  \param entry - entry
*/
SALOME_Prs* SPV3D_ViewModel::CreatePrs( const char* entry )
{
  if(SPV3D_ViewWindow* aViewWindow = dynamic_cast<SPV3D_ViewWindow*>(getViewManager()->getActiveView()))
  {
    return aViewWindow->findOrCreatePrs( entry );
  }
  return nullptr;
}

/*!
  \return true if object is displayed in viewer
  \param obj - object to be checked
*/
bool SPV3D_ViewModel::isVisible( const Handle(SALOME_InteractiveObject)& io )
{
  if(SPV3D_ViewWindow* aViewWindow = dynamic_cast<SPV3D_ViewWindow*>(getViewManager()->getActiveView()))
    return aViewWindow->isVisible( io );
  return false;
}

/*!
  \Collect objects visible in viewer
  \param theList - visible objects collection
*/
void SPV3D_ViewModel::GetVisible( SALOME_ListIO &/*theList*/ )
{
  // NYI
}

/*!
  Updates current viewer
*/
void SPV3D_ViewModel::Repaint()
{
  // NYI
}


void SPV3D_ViewModel::onViewCreated( SUIT_ViewWindow */*view*/) {
#ifdef VGL_WORKAROUND
  if ( SPV3D_ViewWindow* svw = dynamic_cast<SPV3D_ViewWindow*>( view ) )
    QTimer::singleShot(500, [svw] () { svw->Repaint(); } );
#endif
}

//-----------------------------------------------------------------------------
void SPV3D_ViewModel::onSourceCreated(pqPipelineSource* source)
{
  std::string sourceXMLName(source->getSourceProxy()->GetXMLName());
  pqObjectBuilder* builder = pqApplicationCore::instance()->getObjectBuilder();
  if (sourceXMLName == "XMLPolyDataReader" || sourceXMLName == "GeometryGenerator" || sourceXMLName == "ShapeSource" || sourceXMLName == "CubeSource")
  {
    if (this->GeometrySource)
    {
      if (this->GeometrySource == source) {
      }
      else
        builder->destroy(this->GeometrySource);
    }
    this->GeometrySource = source;
  }
  else
  {
    qWarning("Unsupported Source");
    return;
  }
  this->showSelectedMode();
}

//-----------------------------------------------------------------------------
void SPV3D_ViewModel::showSelectedMode()
{
  vtkNew<vtkSMParaViewPipelineControllerWithRendering> controller;
  pqView* activeView = pqActiveObjects::instance().activeView();
  if (activeView)
  {
    if (this->GeometrySource)
    {
#if PARAVIEW_VERSION_MINOR <= 10
      this->GeometrySource->updatePipeline();
      this->GeometrySource->setModifiedState(pqProxy::UNMODIFIED);
#endif

      vtkSMSourceProxy *sourceProxy = this->GeometrySource->getSourceProxy();
      vtkSMViewProxy *viewProxy = activeView->getViewProxy();
      //const char *representationType = "CADRepresentation";
      controller->Show(sourceProxy, 0, viewProxy);//, representationType);

    }
  }
  activeView->render();
  activeView->resetDisplay();
}
