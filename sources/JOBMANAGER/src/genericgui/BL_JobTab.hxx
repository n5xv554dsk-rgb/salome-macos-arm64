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

#ifndef _BL_JOBTAB_HXX_
#define _BL_JOBTAB_HXX_

#include "BL_JobsManager_QT.hxx"

#include <QTabWidget>

class QFormLayout;
class QLabel;
class QListWidget;
class QModelIndex;
class QStandardItem;
class QStandardItemModel;

namespace BL
{
  class JobTab: public QTabWidget
  {
    Q_OBJECT

    public:
      JobTab(QWidget *parent, BL::JobsManager_QT * jobs_manager);
      virtual ~JobTab();

      void setModel(QStandardItemModel * model);

      void createJobSummaryTab();
      void createJobFilesTab();
      void job_selected(const QModelIndex & index);

    public slots:
      void itemChanged(QStandardItem * item);
      void reset(QString job_name);

    protected:
      QWidget* _parent;
      QStandardItemModel * _model;
      BL::JobsManager_QT * _jobs_manager;

      QWidget * _summary_tab;
      QWidget * _files_tab;

      // Main Values
      QFormLayout * _main_values_form;
      QLabel * _job_name_label_value;
      QLabel * _job_type_label_value;
      QLabel * _job_state_label_value;
      QLabel * _job_launcher_label_value;
      QLabel * _job_resource_label_value;
      QLabel * _job_jobfile_label_value;
      QLabel * _job_envfile_label_value;
      QLabel * _job_prefile_label_value;

      // Run Values
      QFormLayout * _run_values_form;
      QFormLayout * _other_run_values_form;
      QLabel * _job_nif_label_value;
      QLabel * _job_nof_label_value;
      QLabel * _job_bd_label_value;
      QLabel * _job_rd_label_value;
      QLabel * _job_mdt_label_value;
      QLabel * _job_req_mem_label_value;
      QLabel * _job_nop_label_value;
      QLabel * _job_nono_label_value;
      QLabel * _job_excl_label_value;

      // Specific Values
      QLabel * _yacs_dump_state_label;
      QLabel * _yacs_dump_state_value;
      QLabel * _batch_queue_label;
      QLabel * _batch_queue_value;
      QLabel * _batch_partition_label;
      QLabel * _batch_partition_value;
      QLabel * _ll_jobtype_label;
      QLabel * _ll_jobtype_value;

      QListWidget * _input_files_list;
      QListWidget * _output_files_list;

	  // Parameters for COORM
      QLabel * _job_lf_label_value;
      QLabel * _job_la_label_value;
  };
}

#endif

