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

#ifndef PV3DVIEWER_VIEWWINDOW_H
#define PV3DVIEWER_VIEWWINDOW_H

#include "PV3DViewer.h"

#include "SUIT_ViewWindow.h"
#include <QMap>

class SUIT_Desktop;
class PV3DViewer_ViewModel;
class pqTabbedMultiViewWidget;

class PV3DVIEWER_EXPORT PV3DViewer_ViewWindow : public SUIT_ViewWindow
{
  Q_OBJECT

public:
  PV3DViewer_ViewWindow( SUIT_Desktop*, PV3DViewer_ViewModel* );
  virtual ~PV3DViewer_ViewWindow();

  pqTabbedMultiViewWidget* getMultiViewManager() const;

  static void removePVMgr();

private:
  SUIT_Desktop*             myDesktop;
  PV3DViewer_ViewModel*     myModel;
  pqTabbedMultiViewWidget*  myPVMgr;
};

#endif // PV3DVIEWER_VIEWWINDOW_H
