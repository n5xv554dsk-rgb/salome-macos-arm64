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

#include "BL_GenericGui.hxx"
#include "BL_MainWindows_Qt.hxx"

#include <QApplication>
#include <QMainWindow>

int main(int argc, char *argv[])
{
  QApplication app(argc, argv);

  QMainWindow main_window;
  BL::MainWindows_Qt wrapper(&main_window);
  BL::GenericGui * main_widget = new BL::GenericGui(&wrapper);
  main_widget->createDockWidgets();
  main_widget->createCentralWidget();
  main_widget->createActions();
  main_widget->createMenus();
  main_widget->updateButtonsStates();

  main_window.setWindowTitle("Standalone JobManager Gui");
  main_window.show();

  return app.exec();
}

