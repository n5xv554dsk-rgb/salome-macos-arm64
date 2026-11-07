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

#ifndef PV3DVIEWER_VIEWMANAGER_H
#define PV3DVIEWER_VIEWMANAGER_H

#include "PV3DViewer.h"

#include "SUIT_ViewManager.h"

class SUIT_Desktop;
class SUIT_Study;
class SUIT_ViewWindow;
class PVServer_ServiceWrapper;
class QMainWindow;

class PV3DVIEWER_EXPORT PV3DViewer_ViewManager : public SUIT_ViewManager
{
  Q_OBJECT

public:
  PV3DViewer_ViewManager(SUIT_Study*, SUIT_Desktop*);
  ~PV3DViewer_ViewManager() {}

protected slots:
  void onWindowActivated(SUIT_ViewWindow*);
};

#endif // PV3DVIEWER_VIEWMANAGER_H
