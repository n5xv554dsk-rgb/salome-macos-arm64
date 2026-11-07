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

#include "PV3DViewer_ViewManager.h"
#include "PV3DViewer_ViewWindow.h"
#include "PV3DViewer_ViewModel.h"
// #include "PV3DViewer_Core.h"
#include "PVViewer_InitSingleton.h"
#include "PVViewer_GUIElements.h"
#include "PVServer_ServiceWrapper.h"

#include <utilities.h>

#include "SUIT_Desktop.h"
#include "SUIT_Study.h"
#include "SUIT_Session.h"
#include "SUIT_MessageBox.h"
#include "SUIT_ResourceMgr.h"

#include <pqServer.h>
#include <pqServerConnectReaction.h>
#include <pqActiveObjects.h>

/*!
  Constructor
*/
PV3DViewer_ViewManager::PV3DViewer_ViewManager(SUIT_Study* study, SUIT_Desktop* desktop)
: SUIT_ViewManager( study, desktop, new PV3DViewer_ViewModel() )
{
  setTitle( tr( "PARAVIEW3D_VIEW_TITLE" ) );

  // Initialize minimal paraview stuff (if not already done)
  PVViewer_InitSingleton::Init(desktop);

  connect( desktop, SIGNAL( windowActivated( SUIT_ViewWindow* ) ),
           this, SLOT( onWindowActivated( SUIT_ViewWindow* ) ) );
}

/*!Enable toolbars if view \a view is ParaView viewer and disable otherwise.
*/
void PV3DViewer_ViewManager::onWindowActivated(SUIT_ViewWindow* view)
{
  if (view)
  {
    PV3DViewer_ViewWindow* pvWindow = dynamic_cast<PV3DViewer_ViewWindow*>(view);
    PVViewer_GUIElements * guiElements = PVViewer_GUIElements::GetInstance( myDesktop );
    guiElements->setToolBarEnabled(pvWindow!=0);
  }
}
