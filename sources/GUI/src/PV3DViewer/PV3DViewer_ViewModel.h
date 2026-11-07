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

#ifndef PV3DVIEWER_VIEWMODEL_H
#define PV3DVIEWER_VIEWMODEL_H

#include "PV3DViewer.h"

#include "SUIT_ViewModel.h"

class SUIT_ViewWindow;
class SUIT_Desktop;
class SUIT_Desktop;

class PV3DVIEWER_EXPORT PV3DViewer_ViewModel : public SUIT_ViewModel
{
  Q_OBJECT

public:
  PV3DViewer_ViewModel();
  virtual ~PV3DViewer_ViewModel() {}

  virtual SUIT_ViewWindow*  createView(SUIT_Desktop*);
  virtual QString           getType() const   { return Type(); }
  static QString            Type()            { return "ParaView3D"; }
};

#endif // PV3DVIEWER_VIEWMODEL_H
