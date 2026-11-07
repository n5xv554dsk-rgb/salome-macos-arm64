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

#ifndef _BL_BUTTONS_HXX_
#define _BL_BUTTONS_HXX_

#include "BL_Traces.hxx"

#include <QWidget>

class QPushButton;

namespace BL 
{
  class Buttons: public QWidget
  {
    Q_OBJECT

    public:
      Buttons(QWidget * parent);
      virtual ~Buttons();

      void setCreateButtonSlot(QObject * receiver, const char * name);
      void setEditCloneButtonSlot(QObject * receiver, const char * name);
      void setStartButtonSlot(QObject * receiver, const char * name);
      void setReStartButtonSlot(QObject * receiver, const char * name);
      void setStopButtonSlot(QObject * receiver, const char * name);
      void setDeleteButtonSlot(QObject * receiver, const char * name);
      void setRefreshButtonSlot(QObject * receiver, const char * name);
      void setGetResultsButtonSlot(QObject * receiver, const char * name);

      void enable_edit_clone_button();
      void disable_edit_clone_button();

      void enable_start_button();
      void disable_start_button();

      void enable_restart_button();
      void disable_restart_button();

      void enable_stop_button();
      void disable_stop_button();

      void enable_delete_button();
      void disable_delete_button();

      void enable_get_results_button();
      void disable_get_results_button();

    protected:  
      QPushButton * _create_button;
      QPushButton * _edit_clone_button;
      QPushButton * _start_button;
      QPushButton * _restart_button;
      QPushButton * _delete_button;
      QPushButton * _get_results_button;
      QPushButton * _refresh_button;
      QPushButton * _stop_button;
  };
}

#endif

