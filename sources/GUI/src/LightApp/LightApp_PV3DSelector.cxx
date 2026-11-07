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

#include "LightApp_PV3DSelector.h"
#include "LightApp_DataOwner.h"

#include "SUIT_Desktop.h"

#ifndef DISABLE_PV3DVIEWER
  #include "SPV3D_ViewModel.h"
  #include "SPV3D_ViewManager.h"
  #include "SPV3D_ViewWindow.h"
  #include <vtkRenderer.h>
#endif

#ifndef DISABLE_SALOMEOBJECT
  // #include "SALOME_Actor.h"
  // #include "SALOME_ListIO.hxx"
#endif

#include <utilities.h>

#ifndef DISABLE_PV3DVIEWER
/*!
  Constructor.
*/
LightApp_PV3DSelector::LightApp_PV3DSelector( SPV3D_ViewModel* viewer, SUIT_SelectionMgr* mgr )
: SUIT_Selector( mgr, viewer ),
  myViewer( viewer )
{
  if ( myViewer )
    connect( myViewer, SIGNAL( selectionChanged() ), this, SLOT( onSelectionChanged() ) );
}

/*!
  Gets viewer.
*/
SPV3D_ViewModel* LightApp_PV3DSelector::viewer() const
{
  return myViewer;
}

/*!
  Gets type of salome PV3D viewer.
*/
QString LightApp_PV3DSelector::type() const
{ 
  return myViewer->getType(); 
}

#endif

/*!
  On selection changed.
*/
void LightApp_PV3DSelector::onSelectionChanged()
{
  selectionChanged();
}

#ifndef DISABLE_PV3DVIEWER

/*!
  Gets list of selected data owners.(output \a aList).
*/
void LightApp_PV3DSelector::getSelection( SUIT_DataOwnerPtrList& /*aList*/ ) const
{
  if ( !myViewer )
    return;

  if ( !myViewer->isSelectionEnabled() )
    return;

  // if(SUIT_ViewManager* aViewManager = myViewer->getViewManager()){
  //   if(PV3DViewer_ViewManager* aViewMgr = dynamic_cast<PV3DViewer_ViewManager*>(aViewManager)){
  //     if(PV3DViewer_ViewWindow* aView = dynamic_cast<PV3DViewer_ViewWindow*>(aViewMgr->getActiveView())){
  //       if(SPV3D_Selector* aSelector = aView->GetSelector()){
  //         const SALOME_ListIO& aListIO = aSelector->StoredIObjects();
  //         SALOME_ListIteratorOfListIO anIter(aListIO);
  //         for(; anIter.More(); anIter.Next()){
  //           Handle(SALOME_InteractiveObject) anIO = anIter.Value();
  //           if(anIO->hasEntry())
  //             aList.append(new LightApp_SPV3DDataOwner(anIO,aViewMgr->getDesktop()));
  //         }
  //       }
  //     }
  //   }
  // }
}

/*!
  Sets selection to selector from data owner list \a theList.
*/
void LightApp_PV3DSelector::setSelection( const SUIT_DataOwnerPtrList& theList )
{
  if ( myViewer && ( theList.isEmpty() || myViewer->isSelectionEnabled() )) {
    //if(SUIT_ViewManager* aViewMgr = myViewer->getViewManager())
    {
    //  if(SPV3D_ViewWindow* aView = dynamic_cast<SPV3D_ViewWindow*>(aViewMgr->getActiveView()))
      {
        // if(PV3DViewer_Selector* aSelector = aView->GetSelector()){
        //   SALOME_ListIO anAppendList;
        //   const SALOME_ListIO& aStoredList = aSelector->StoredIObjects();
        //   SUIT_DataOwnerPtrList::const_iterator anIter = theList.begin();
        //   for(; anIter != theList.end(); ++anIter) {
        //     const SUIT_DataOwner* aDataOwner = (*anIter).get();
        //     if(const LightApp_SPV3DDataOwner* anOwner = dynamic_cast<const LightApp_SPV3DDataOwner*>(aDataOwner))
        //     {
        //       MESSAGE("aSelector->SetSelectionMode("<<anOwner->GetMode()<<");");
        //       aSelector->SetSelectionMode(anOwner->GetMode());
        //       Handle(SALOME_InteractiveObject) anIO = anOwner->IO();

        //       aSelector->AddIObject(anIO);

        //       anAppendList.Append(anIO);
        //       aSelector->AddOrRemoveIndex(anIO,anOwner->GetIds(),false);
        //     }
        //     else if(const LightApp_DataOwner* anOwner = dynamic_cast<const LightApp_DataOwner*>(aDataOwner))
        //     {
        //       Handle(SALOME_InteractiveObject) anIO =
        //         new SALOME_InteractiveObject(anOwner->entry().toUtf8(),"");
        //       aSelector->AddIObject(anIO);
        //       anAppendList.Append(anIO);
        //     }
        //   }
        //   // To remove IOs, which is not selected.
        //   QMap< QString, Handle( SALOME_InteractiveObject )> toRemove;
        //   SALOME_ListIteratorOfListIO anIt( aStoredList );
        //   for( ; anIt.More(); anIt.Next() )
        //     if( !anIt.Value().IsNull() )
        //       toRemove[ anIt.Value()->getEntry() ] = anIt.Value();

        //   anIt = SALOME_ListIteratorOfListIO(anAppendList);
        //   for( ; anIt.More(); anIt.Next() )
        //     toRemove.remove( anIt.Value()->getEntry() );

        //   QMap< QString, Handle( SALOME_InteractiveObject )>::const_iterator RIt = toRemove.begin(),
        //     REnd = toRemove.end();
        //   for( ; RIt!=REnd; RIt++ )
        //     aSelector->RemoveIObject( RIt.value() );

        //   aView->onSelectionChanged();
        // }
      }
    }
  }
}

#endif
