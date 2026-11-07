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

#include "SPV3D_ViewManager.h"
#include "SPV3D_ViewModel.h"
#include "SPV3D_ViewWindow.h"

#include <PV3DViewer_ViewManager.h>

#include "PVViewer_InitSingleton.h"
#include "PVViewer_GUIElements.h"
#include "PVServer_ServiceWrapper.h"

#include <SUIT_Desktop.h>

#include <pqObjectBuilder.h>
#include <pqApplicationCore.h>
#include <pqServerManagerModel.h>
#include <pqServerResource.h>
#include <pqView.h>
#include <pqPVApplicationCore.h>
#include <pqParaViewBehaviors.h>

#include <QVBoxLayout>
#include <QApplication>

/*!
  Constructor
*/
SPV3D_ViewManager::SPV3D_ViewManager( SUIT_Study* study, SUIT_Desktop* theDesktop ) 
: SUIT_ViewManager( study, theDesktop, new SPV3D_ViewModel() )
{
  setTitle( SPV3D_ViewManager::tr( "PARAVIEW3D_VIEW_TITLE" ) );
  /*QStringList args = QCoreApplication::arguments();
  int argc = args.length();
  char **argv = new char *[argc+1];
  for(auto i = 0 ; i < argc ; ++i)
    argv[i] = strdup(args[i].toStdString().c_str());
  argv[argc] = nullptr;
  pqPVApplicationCore appPV(argc,argv);
  QApplication::instance()->installEventFilter(&appPV);
  new pqParaViewBehaviors(theDesktop,theDesktop);
  pqObjectBuilder *builder(pqApplicationCore::instance()->getObjectBuilder());
  pqServer *serv(pqApplicationCore::instance()->getServerManagerModel()->findServer(pqServerResource("builtin:")));
  pqView *view=builder->createView(QString("RenderView"),serv);
  static_cast<SPV3D_ViewModel *>(this->getViewModel())->setView(view);*/
  //QVBoxLayout *lay(new QVBoxLayout(theDesktop));
  //lay->addWidget( view->widget() );
  //view->widget()->setParent( theDesktop);
  // Initialize minimal paraview stuff (if not already done)
  //PVViewer_InitSingleton::Init(theDesktop);

  connect( theDesktop, SIGNAL( windowActivated( SUIT_ViewWindow* ) ),
           this, SLOT( onWindowActivated( SUIT_ViewWindow* ) ) );

  SPV3D_ViewModel *vm = dynamic_cast<SPV3D_ViewModel*>(getViewModel());
  if (vm)
    vm->initialize();
}

/*!
  Destructor
*/
SPV3D_ViewManager::~SPV3D_ViewManager()
{
}

/*!
  \return corresponding main window
*/
SUIT_Desktop* SPV3D_ViewManager::getDesktop()
{
  return myDesktop;
}

/*!Enable toolbars if view \a view is ParaView viewer and disable otherwise.
*/
void SPV3D_ViewManager::onWindowActivated(SUIT_ViewWindow* view)
{
  if (view)
  {
    SPV3D_ViewWindow* pvWindow = dynamic_cast<SPV3D_ViewWindow*>(view);
    PVViewer_GUIElements * guiElements = PVViewer_GUIElements::GetInstance( myDesktop );
    guiElements->setToolBarEnabled(pvWindow!=0);
  }
}
