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


#ifndef _BL_MAINWINDOWS_QT_HXX_
#define _BL_MAINWINDOWS_QT_HXX_

#ifdef WNT
#  if defined BL_Wrappers_Qt_EXPORTS
#    define BL_Wrappers_Qt_EXPORT __declspec( dllexport )
#  else
#    define BL_Wrappers_Qt_EXPORT __declspec( dllimport )
#  endif
#else
#  define BL_Wrappers_Qt_EXPORT
#endif

#include "BL_MainWindows_Wrap.hxx"

#include <QObject>
#include <map>

class QMenu;

namespace BL
{
  class BL_Wrappers_Qt_EXPORT MainWindows_Qt : public MainWindows_Wrap, public QObject
  {
    public:
      MainWindows_Qt(QMainWindow * main_window);
      virtual ~MainWindows_Qt();

      virtual QMainWindow * getDockParent();
      virtual QMainWindow * getTabParent();

      virtual QAction* createAction(const QString& toolTip,
				    const QIcon& icon,
				    const QString& menu,
				    const QString& status,
				    const int accel,
				    QObject* parent =0,
				    bool checkable = false,
				    QObject* receiver =0,
				    const char* member =0,
                                    const QString& shortCut=QString());

      virtual int createTopMenu(const QString & menu_name);
      virtual void addActionToMenu(QAction * action, int menu_id);

    protected:
      QMainWindow * _main_window;
      int _menuId;
      int getMenuId() { return _menuId++; }
      std::map<int, QMenu*> _menu_map;
  };
}

#endif
