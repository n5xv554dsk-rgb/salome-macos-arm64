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

#ifndef _BL_JOBSMANAGER_QT_HXX_
#define _BL_JOBSMANAGER_QT_HXX_

#include "BL_Traces.hxx"
#include "BL_JobsManager.hxx"
#include "BL_CreateJobWizard.hxx"
#include "BL_JobsManager.hxx"
#include "BL_QModelManager.hxx"

#include <QDockWidget>
#include <QEvent>
#include <string>

class QPushButton;
class QTextEdit;
class QTimer;

namespace BL
{

  class JobManagerEvent : public QEvent
  {
    public:
      JobManagerEvent(const std::string & action_i, 
                      const std::string & event_name_i, 
                      const std::string & job_name_i, 
                      const std::string & data_i);
      virtual ~JobManagerEvent();

    public:
      std::string action;
      std::string event_name;
      std::string job_name;
      std::string data;
  };

  class GenericGui;
  class JobsManager_QT: public QDockWidget,
                        public BL::JobsManager,
                        public BL::Observer
  {
    Q_OBJECT

    public:
      JobsManager_QT(QWidget * parent, BL::GenericGui * main_gui, BL::SALOMEServices * salome_services);
      virtual ~JobsManager_QT();

      void delete_job(QString job_name);

      void create_job();
      void edit_clone_job(const std::string & name);
      void restart_job(const std::string & name);

      virtual void sendEvent(const std::string & action, 
                             const std::string & event_name, 
                             const std::string & job_name, 
                             const std::string & data);
      bool event(QEvent * e);

      void write_normal_text(const QString & text);
      void write_error_text(const QString & text);

      void set_model_manager(BL::QModelManager * model_manager);

    protected:
      void create_job_with_wizard(BL::CreateJobWizard & wizard);

    public slots:
      void RefreshJobs();
      void no_auto_refresh();
      void ten_seconds_refresh();
      void thirty_seconds_refresh();
      void one_minute_refresh();
      void five_minutes_refresh();
      void thirty_minutes_refresh();
      void one_hour_refresh();
      void load_jobs_button();
      void save_jobs_button();

    signals:
      void new_job_added(const QString & name);
      void job_state_changed(const QString & name);

    private:
      QPushButton * _load_jobs;
      QPushButton * _save_jobs;
      QPushButton * _auto_refresh_jobs;
      QTimer * _timer;
      QTextEdit * _log;
      BL::GenericGui * _main_gui;
      BL::QModelManager * _model_manager;
  };

}

#endif


