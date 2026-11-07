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

#ifndef SPV3D_VIEWMANAGER_H
#define SPV3D_VIEWMANAGER_H

#include "SUIT_ViewManager.h"
#include "SPV3D.h"

class SUIT_Desktop;
class SUIT_Study;
class SUIT_ViewWindow;

//! Extend SUIT_ViewManager to deal with SPV3D_ViewModel
class SPV3D_EXPORT SPV3D_ViewManager : public SUIT_ViewManager
{
  Q_OBJECT

public:
  //! Construct the view manager
  SPV3D_ViewManager( SUIT_Study* study, SUIT_Desktop* );

  //! Destroy the view manager
  virtual ~SPV3D_ViewManager();

  SUIT_Desktop* getDesktop();

protected slots:
  void onWindowActivated(SUIT_ViewWindow*);
};

#endif
