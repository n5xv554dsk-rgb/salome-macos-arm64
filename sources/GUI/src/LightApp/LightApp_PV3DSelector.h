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

#ifndef LIGHTAPP_PV3DSELECTOR_H
#define LIGHTAPP_PV3DSELECTOR_H

#include "LightApp.h"

#include <SUIT_Selector.h>
#include <SUIT_DataOwner.h>

#include <QObject>


#ifndef DISABLE_PV3DVIEWER
#ifndef DISABLE_SALOMEOBJECT
  #include "SALOME_InteractiveObject.hxx"
#endif
  class SPV3D_ViewModel;
#endif


/*!
  \class LightApp_PV3DSelector
  Custom selector to get/set selection from PV3D viewer
*/
class LIGHTAPP_EXPORT LightApp_PV3DSelector : public QObject, public SUIT_Selector
{
  Q_OBJECT

public:
  virtual ~LightApp_PV3DSelector() {};
#ifndef DISABLE_PV3DVIEWER
  LightApp_PV3DSelector( SPV3D_ViewModel*, SUIT_SelectionMgr* );

  SPV3D_ViewModel* viewer() const;

  virtual QString type() const;
#else
  LightApp_PV3DSelector( SUIT_SelectionMgr* );
#endif

private slots:
  void              onSelectionChanged();

#ifndef DISABLE_PV3DVIEWER
protected:
  virtual void      getSelection( SUIT_DataOwnerPtrList& ) const;
  virtual void      setSelection( const SUIT_DataOwnerPtrList& );

private:
  SPV3D_ViewModel* myViewer;

#endif
};

#endif
