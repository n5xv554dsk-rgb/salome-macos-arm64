// Copyright (C) 2009-2026  CEA, EDF
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

#ifndef _BL_SALOMEGUI_HXX_
#define _BL_SALOMEGUI_HXX_

#ifdef WNT
#  if defined JOBMANAGER_EXPORTS
#    define JOBMANAGER_EXPORT __declspec( dllexport )
#  else
#    define JOBMANAGER_EXPORT __declspec( dllimport )
#  endif
#else
#  define JOBMANAGER_EXPORT
#endif

#include <SALOMEconfig.h>

#include <SalomeApp_Module.h>
#include <SalomeApp_Application.h>

#include "BL_MainWindows_SALOME.hxx"
#include "BL_GenericGui.hxx"
#include "BL_Traces.hxx"

namespace BL
{
  class SalomeGui: public MainWindows_SALOME
  {
    Q_OBJECT
    
    public:
      SalomeGui();
      virtual ~SalomeGui();

      void initialize( CAM_Application* app); // --- Call only once, at GUI module creation
      void windows( QMap<int, int>& theMap) const; // --- Default windows, called each time the module is activated

    public slots:
      bool deactivateModule( SUIT_Study* theStudy);
      bool activateModule( SUIT_Study* theStudy);
      void studyClosed();

    protected slots:
      void onWindowActivated( SUIT_ViewWindow* svw);

    protected:
      BL::GenericGui * _gengui;
  };

}

#endif
