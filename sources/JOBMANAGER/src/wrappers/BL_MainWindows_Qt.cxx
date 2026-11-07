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

#include "BL_MainWindows_Qt.hxx"

#include <QAction>
#include <QMainWindow>
#include <QMenu>
#include <QMenuBar>

BL::MainWindows_Qt::MainWindows_Qt(QMainWindow * main_window)
{
  DEBTRACE("Creating BL::MainWindows_Qt");
  BL_ASSERT(main_window);
  _main_window = main_window;
  _menuId = 0;
}

BL::MainWindows_Qt::~MainWindows_Qt()
{
  DEBTRACE("Destroying BL::MainWindows_Qt");
}

QMainWindow * 
BL::MainWindows_Qt::getDockParent()
{
  return _main_window;
}

QMainWindow * 
BL::MainWindows_Qt::getTabParent()
{
  return _main_window;
}

QAction* 
BL::MainWindows_Qt::createAction(const QString& toolTip,
				 const QIcon& icon,
				 const QString& menu,
				 const QString& status,
				 const int accel,
				 QObject* parent,
				 bool checkable,
				 QObject* receiver,
				 const char* member,
                                 const QString& shortCut)
{
  QAction * action = new QAction(icon, menu, parent);
  action->setStatusTip(status);
  action->setToolTip(toolTip);
  if (receiver)
    connect(action, SIGNAL(triggered()), receiver, member);
  return action;
}

int
BL::MainWindows_Qt::createTopMenu(const QString & menu_name)
{
  QMenu * new_menu = _main_window->menuBar()->addMenu(menu_name);
  _menu_map[getMenuId()] = new_menu;
  return 0;
}

void
BL::MainWindows_Qt::addActionToMenu(QAction * action, int menu_id)
{
  _menu_map[menu_id]->addAction(action);
}
