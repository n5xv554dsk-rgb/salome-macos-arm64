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

#include "BL_SalomeGui.hxx"
#include "JOBMANAGER_version.h"

#include <SUIT_Desktop.h>
#include <SUIT_ViewWindow.h>

BL::SalomeGui::SalomeGui() : MainWindows_SALOME("JobManager")
{
  DEBTRACE("Creating BL::SalomeGui");
  _gengui = NULL;
}

BL::SalomeGui::~SalomeGui()
{
  DEBTRACE("Destroying BL::SalomeGui");
  if (getApp())
    disconnect(getApp(), SIGNAL(studyClosed()), this, SLOT(studyClosed()));
  if (_gengui)
    delete _gengui;
}

void 
BL::SalomeGui::initialize(CAM_Application* app)
{
   DEBTRACE("Entering in initialize");
   SalomeApp_Module::initialize(app); // MANDATORY -> Otherwise SISEGV...
   connect( getApp(), SIGNAL(studyClosed()), this, SLOT(studyClosed()));
   if ( app && app->desktop() )
     connect( app->desktop(), SIGNAL( windowActivated( SUIT_ViewWindow* ) ),
              this, SLOT(onWindowActivated( SUIT_ViewWindow* )) );
}

void
BL::SalomeGui::studyClosed()
{
  if (_gengui)
  {
    _gengui->saveIfNeeded();
    _gengui->deleteDockWidget();
    delete _gengui;
    _gengui = NULL;
    _viewWin = NULL;
  }
}

bool 
BL::SalomeGui::activateModule(SUIT_Study* theStudy)
{
  DEBTRACE("Entering in BL::SalomeGui::activateModule");

  if (!_gengui)
  {
   BL::MainWindows_SALOME::initialize(getApp());
   BL::MainWindows_SALOME::createView();
   _gengui = new BL::GenericGui(this);

   _gengui->createDockWidgets();
   _gengui->createCentralWidget();
   _gengui->createActions();
   _gengui->createMenus();
   _gengui->updateButtonsStates();
  }
  else
   {
    // Test main view
    if (!BL::MainWindows_SALOME::restoreViewFocus())
     {
      // We need to recreate QT objects and the view
      BL::MainWindows_SALOME::createView();
      _gengui->createCentralWidget();
     }
   }

  setMenuShown(true);
  _gengui->showDockWidgets(true);
  bool bOk = SalomeApp_Module::activateModule(theStudy);
  return bOk;
}

void 
BL::SalomeGui::windows(QMap<int, int>& theMap) const
{
  DEBTRACE("Entering in BL::SalomeGui::windows");
  theMap.clear();
  theMap.insert(SalomeApp_Application::WT_ObjectBrowser, Qt::LeftDockWidgetArea);
}

bool 
BL::SalomeGui::deactivateModule(SUIT_Study* theStudy)
{
  DEBTRACE("Entering in BL::SalomeGui::deactivateModule");
  setMenuShown(false);
  if (_gengui)
    _gengui->showDockWidgets(false);
  bool bOk = SalomeApp_Module::deactivateModule(theStudy);
  return bOk;
}

void 
BL::SalomeGui::onWindowActivated( SUIT_ViewWindow* svw)
{
  DEBTRACE("BL::SalomeGui::onWindowActivated");
  DEBTRACE("activeModule()->moduleName() " << (getApp()->activeModule() ? getApp()->activeModule()->moduleName().toStdString() : "") );
  
  if (_viewWin) // Be sure to have a _viewWindow
    if (svw->getId() == _viewWin->getId()) // Same Id ?
      if (!getApp()->activeModule() || getApp()->activeModule()->moduleName() != "JobManager") // JobManager already activated ?
        if ( !getApp()->activateModule("JobManager") ) return;
}

// --- Export the module
extern "C"
{
  JOBMANAGER_EXPORT CAM_Module* createModule()
  {
    return new BL::SalomeGui();
  }

  char* getModuleVersion()
  {
      return (char*)JOBMANAGER_VERSION_STR;
  }
}
