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

#ifndef _BL_GENERICGUI_HXX_
#define _BL_GENERICGUI_HXX_

#include "BL_GenericGuiDefines.hxx"

#include "BL_Traces.hxx"

#include "BL_SALOMEServices.hxx"

#include "BL_MainWindows_Wrap.hxx"

#include "BL_QModelManager.hxx"
#include "BL_JobsManager_QT.hxx"
#include "BL_JobsTable.hxx"
#include "BL_JobTab.hxx"
#include "BL_Buttons.hxx"
#include "BL_Summary.hxx"
#include "JM_ResourceCatalog.hxx"

#include <QObject>

class QAction;
class QDockWidget;
class QMainWindow;
class QModelIndex;

namespace BL 
{
  class BL_GenericGui_EXPORT GenericGui: public QObject
  {
    Q_OBJECT

    public:
      GenericGui(BL::MainWindows_Wrap * wrapper);
      virtual ~GenericGui();

      void createDockWidgets();
      void createCentralWidget();

      void showDockWidgets(bool isVisible);
      void createActions();
      void createMenus();

      void delete_job_internal();

      void deleteDockWidget();
      void delete_job_external(const QString & name);

      void reset_job_selection();

      void saveIfNeeded();

    public slots:
      void create_job();
      void edit_clone_job();
      void start_job();
      void restart_job();
      void delete_job();
      void refresh_job();
      void stop_job();
      void get_results_job();
      void job_selected(const QModelIndex & index);
      void job_activated(const QModelIndex & index);
      void job_state_changed(const QString & name);
      void updateButtonsStates();
      void updateButtonsStatesSingleSelection();

    public:
      BL::JobTab * _job_tab;
      BL::JobsTable * _jobs_table;

    protected:
      BL::MainWindows_Wrap * _wrapper;

      BL::SALOMEServices * _salome_services;

      QMainWindow * _dock_parent;
      QMainWindow * _tab_parent;
      QDockWidget * _dw_summary;
      QDockWidget * _dw_resource_catalog;

      BL::Buttons * _buttons;
      BL::Summary * _summary;

      QAction * _create_job_action;
      QAction * _edit_clone_job_action;
      QAction * _start_job_action;
      QAction * _restart_job_action;
      QAction * _delete_job_action;
      QAction * _stop_job_action;
      QAction * _get_results_job_action;
      QAction * _refresh_job_action;

      BL::JobsManager_QT * _jobs_manager;
      BL::QModelManager * _model_manager;
      QStandardItemModel * _model;
      JM::ResourceCatalog * _resource_catalog;

      QString _job_name_selected;
  };
}

#endif
