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

#include "BL_MainWindows_SALOME.hxx"

#include <SalomeApp_Application.h>
#include <SalomeApp_Engine_i.h>
#include <SUIT_Desktop.h>
#include <SUIT_ViewManager.h>
#include <SUIT_ViewWindow.h>

#include <QTextEdit>

BL::MainWindows_SALOME::MainWindows_SALOME(const QString & module_name) :
  SalomeApp_Module(module_name)
{
  DEBTRACE("Creating BL::MainWindows_SALOME");
  _actionId = 190;
  _currentViewId = -1;
  _svm = 0;
}

void 
BL::MainWindows_SALOME::initialize(SalomeApp_Application * appli)
{
  DEBTRACE("Initialize BL::MainWindows_SALOME");
  BL_ASSERT(appli);
  _appli = appli;
}


void
BL::MainWindows_SALOME::createView()
{
  DEBTRACE("BL::MainWindows_SALOME CreateView");
  QString vmType = "JobManager View";

  // Get JobManager View Manager
  _svm = _appli->getViewManager( vmType, true );
  if (!_svm) {
    // view manager not found
    QTextEdit* w = new QTextEdit;
    _svm = _appli->createViewManager( vmType, w );
  }

  // Create a view
  _viewWin = _svm->getActiveView();
  _viewWin->setClosable( false );
  _currentViewId = _viewWin->getId();
  DEBTRACE("End of BL::MainWindows_SALOME CreateView");
}

bool
BL::MainWindows_SALOME::restoreViewFocus()
{
  bool result = false;
  SUIT_ViewWindow* resWnd = 0;

  // Search window
  QList<SUIT_ViewWindow*> wndlist = _appli->desktop()->windows();
  SUIT_ViewWindow* wnd;
  for (int i = 0; i < wndlist.size(); ++i) 
   {
    wnd = wndlist.at(i);
    if (_currentViewId == wnd->getId()) {resWnd = wnd;}
    if (resWnd) {break;}
   }

  if (resWnd)
   {
    wnd->setFocus();
    result = true;
   }
  return result;
}

QString  
BL::MainWindows_SALOME::engineIOR() const
{
  DEBTRACE("Entering in BL::SalomeGui::engineIOR");
  QString anEngineIOR = SalomeApp_Engine_i::EngineIORForComponent( "JOBMANAGER", true ).c_str();
  return anEngineIOR;
}

void 
BL::MainWindows_SALOME::viewManagers(QStringList& list) const
{
  DEBTRACE("Entering in BL::SalomeGui::viewManagers");
  if (_svm)
    list.append(_svm->getType());
}


BL::MainWindows_SALOME::~MainWindows_SALOME()
{
  DEBTRACE("Destroying BL::MainWindows_SALOME");
}

QMainWindow * 
BL::MainWindows_SALOME::getDockParent()
{
  return _appli->desktop();
}

QMainWindow * 
BL::MainWindows_SALOME::getTabParent()
{
  return _viewWin;
}

QAction* 
BL::MainWindows_SALOME::createAction(const QString& toolTip,
				     const QIcon& icon,
				     const QString& menu,
				     const QString& status,
				     const int accel,
				     QObject* parent,
				     bool checkable,
				     QObject* receiver,
				     const char* member,
                                     const QString & shortCut)
{
  return SalomeApp_Module::createAction(getActionId(), toolTip, icon, menu, status, accel, parent, checkable, receiver, member, shortCut);
}

int
BL::MainWindows_SALOME::createTopMenu(const QString & menu_name)
{
  return createMenu(menu_name, -1, -1, 30 );
}

void 
BL::MainWindows_SALOME::addActionToMenu(QAction * action, int menu_id)
{
  createMenu(action, menu_id);
}
