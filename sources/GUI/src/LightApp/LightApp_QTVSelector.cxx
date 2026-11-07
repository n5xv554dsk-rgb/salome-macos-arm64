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

#include "LightApp_QTVSelector.h"

#include "LightApp_DataOwner.h"

#include <QtViewer_Object.h>
#include <QtViewer_ViewPort.h>
#include <QtViewer_Viewer.h>

LightApp_QTVSelector::LightApp_QTVSelector( QtViewer_Viewer* theViewer,
                                          SUIT_SelectionMgr* theSelMgr )
: SUIT_Selector( theSelMgr, theViewer ),
  myViewer( theViewer )
{
  connect( theViewer, SIGNAL( selectionChanged() ),
          this, SLOT( onSelectionChanged() ) );
}

LightApp_QTVSelector::~LightApp_QTVSelector()
{
}

QString LightApp_QTVSelector::type() const
{
  return QtViewer_Viewer::Type();
}

void LightApp_QTVSelector::getSelection( SUIT_DataOwnerPtrList& theList ) const
{
  if ( !myViewer )
    return;

  if( QtViewer_ViewPort* aViewport = myViewer->getActiveViewPort() )
    {
      foreach (QGraphicsItem *item, aViewport->scene()->selectedItems()) 
        {
         if (QtViewer_Object* obj = dynamic_cast<QtViewer_Object*>(item))
           {
             LightApp_DataOwner* owner = dynamic_cast<LightApp_DataOwner*>( obj->owner() );
             if ( owner )
               theList.append( SUIT_DataOwnerPtr( new LightApp_DataOwner( owner->entry() ) ) );
           }
        }
    } 
}

void LightApp_QTVSelector::setSelection( const SUIT_DataOwnerPtrList& theList)
{ 
 if ( !myViewer )
    return;

  QMap<QString, int> aSelected;
  for ( SUIT_DataOwnerPtrList::const_iterator itr = theList.begin(); itr != theList.end(); ++itr )
  {
    const LightApp_DataOwner* owner = dynamic_cast<const LightApp_DataOwner*>( (*itr).operator->() );

    if ( owner )
      aSelected.insert( owner->entry(), 0 );
  }
  
  if( QtViewer_ViewPort* aViewport = myViewer->getActiveViewPort() )
    {
      aViewport->scene()->clearSelection();
      foreach (QGraphicsItem *item, aViewport->items())
        {
          if (QtViewer_Object* obj = dynamic_cast<QtViewer_Object*>(item))
            {
              LightApp_DataOwner* owner = dynamic_cast<LightApp_DataOwner*>( obj->owner() );
              bool sel = owner && aSelected.contains(owner->entry());
              obj->setSelected(sel);
            }
       }
   }
}

void LightApp_QTVSelector::onSelectionChanged()
{
  selectionChanged();
}
