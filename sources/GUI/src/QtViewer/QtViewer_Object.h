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

#ifndef QTVIEWER_OBJECT_H
#define QTVIEWER_OBJECT_H

#include "QtViewer.h"
#include <QGraphicsItem>

class SUIT_DataOwner;
/*
  Class       : QtViewer_Object
  Description : Base class for all objects displayed at the scene
*/
class QTVIEWER_API QtViewer_Object : public QGraphicsItem
{
public:
  QtViewer_Object( QGraphicsItem* theParent = nullptr );
  ~QtViewer_Object();

  const QString& getName() const { return myName; }
  virtual void setName( const QString& theName ) { myName = theName; }

  SUIT_DataOwner* owner() const { return myOwner; }
  void setOwner( SUIT_DataOwner* owner ) { myOwner = owner; }

protected:
  SUIT_DataOwner* myOwner;
  QString myName;
};

#endif
