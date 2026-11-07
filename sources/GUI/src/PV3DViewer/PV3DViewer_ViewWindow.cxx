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

#include "PV3DViewer_ViewWindow.h"
//#include "PV3DViewer_Core.h"
//#include "PV3DViewer_GUIElements.h"
#include "PV3DViewer_ViewModel.h"
#include "PV3DViewer_ViewManager.h"

#include "SUIT_ViewManager.h"
#include "SUIT_ResourceMgr.h"
#include "SUIT_Session.h"
#include "SUIT_Desktop.h"
#include "SUIT_Application.h"

#include <pqTabbedMultiViewWidget.h>
#include <pqApplicationCore.h>

/*!
  \brief Constructor.
  \param theDesktop parent desktop window
  \param theModel view model
*/
PV3DViewer_ViewWindow::PV3DViewer_ViewWindow( SUIT_Desktop* theDesktop, PV3DViewer_ViewModel* theModel )
  : SUIT_ViewWindow( theDesktop ), myPVMgr( 0 )
{
  myDesktop = theDesktop;
  myModel = theModel;
  setViewManager(myModel->getViewManager());
}

/*!
  \brief Destructor.
  As pqViewManager persists through the whole session,
  the destructor first removes it from the children of this PV3DViewer_ViewWindow
  to prevent its unexpected deletion.
*/
PV3DViewer_ViewWindow::~PV3DViewer_ViewWindow()
{
  if ( myPVMgr ) {
    myPVMgr->setParent( nullptr );
    myPVMgr->hide();
    myPVMgr = nullptr;
    setCentralWidget( nullptr );
  }
}

void PV3DViewer_ViewWindow::removePVMgr()
{
  pqTabbedMultiViewWidget* aPVMgr = qobject_cast<pqTabbedMultiViewWidget*>(pqApplicationCore::instance()->manager("MULTIVIEW_WIDGET"));
  delete aPVMgr;
}


/*!
  \brief Returns the ParaView multi-view manager previously set with setPVManager()
*/
pqTabbedMultiViewWidget *PV3DViewer_ViewWindow::getMultiViewManager() const
{
  return myPVMgr;
}
