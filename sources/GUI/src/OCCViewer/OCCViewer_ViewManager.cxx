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

#include "OCCViewer_ViewManager.h"
#include "OCCViewer_ViewFrame.h"
#include "OCCViewer_ViewWindow.h"
#include "SUIT_Desktop.h"

/*!
  Constructor
*/
OCCViewer_ViewManager::OCCViewer_ViewManager( SUIT_Study* study, SUIT_Desktop* theDesktop, bool DisplayTrihedron )
: SUIT_ViewManager( study, theDesktop, new OCCViewer_Viewer( DisplayTrihedron ) ),
  myIsChainedOperations( false )
{  
  setTitle( tr( "OCC_VIEW_TITLE" ) );
}

/*!
  Destructor
*/
OCCViewer_ViewManager::~OCCViewer_ViewManager()
{
}

/*!
  Fills popup menu with custom actions
 \param popup - popup menu to be filled with
*/
void OCCViewer_ViewManager::contextMenuPopup( QMenu* popup )
{
  SUIT_ViewManager::contextMenuPopup( popup );
  // if it is necessary invoke method CreatePopup of ViewPort
  // be sure that existing QPopupMenu menu is used for that.
}

bool OCCViewer_ViewManager::isChainedOperations() const
{
  return myIsChainedOperations;
}

void OCCViewer_ViewManager::setChainedOperations( bool isChainedOperations )
{
  myIsChainedOperations = isChainedOperations;
}

bool OCCViewer_ViewManager::isAutoRotation() const
{
  return myIsAutoRotation;
}

void OCCViewer_ViewManager::setAutoRotation( bool isAutoRotation )
{
  myIsAutoRotation = isAutoRotation;

  // Update the auto rotation in all OCC views
  QVector<SUIT_ViewWindow*> views = getViews();
  for ( int i = 0; i < views.count(); i++ )
  {
    if ( views[i] ) {
      OCCViewer_ViewWindow *aView = dynamic_cast<OCCViewer_ViewWindow*>(views[i]);
      if (aView) {
        OCCViewer_ViewWindow* aWnd = aView->getView(OCCViewer_ViewFrame::MAIN_VIEW);
        if (aWnd) {
          aWnd->enableAutoRotation(isAutoRotation);
        }
      }
    }
  }
}
