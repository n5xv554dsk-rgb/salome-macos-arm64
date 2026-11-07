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

#include "BL_JobTab.hxx"
#include "BL_Traces.hxx"

#include <QFormLayout>
#include <QGroupBox>
#include <QHBoxLayout>
#include <QLabel>
#include <QListWidget>
#include <QStandardItemModel>
#include <QVBoxLayout>

#ifdef WNT
#undef ERROR
#endif

using namespace std;

BL::JobTab::JobTab(QWidget *parent, BL::JobsManager_QT * jobs_manager) : QTabWidget(parent)
{
  DEBTRACE("Creating BL::JobTab");
  BL_ASSERT(parent);
  BL_ASSERT(jobs_manager);
  _parent = parent;
  _jobs_manager = jobs_manager;
  _model = NULL;

  createJobSummaryTab();
  createJobFilesTab();
}

BL::JobTab::~JobTab()
{
  DEBTRACE("Destroying BL::JobTab");
}

void
BL::JobTab::setModel(QStandardItemModel * model)
{
  DEBTRACE("Call setModel BL::JobTab");
  BL_ASSERT(model);

  _model = model;
}

void
BL::JobTab::createJobSummaryTab()
{
  _summary_tab = new QWidget(this);

  QLabel * job_name_label = new QLabel("Name:");
  _job_name_label_value = new QLabel("");
  QLabel * job_type_label = new QLabel("Type:");
  _job_type_label_value = new QLabel("");
  QLabel * job_state_label = new QLabel("State:");
  _job_state_label_value = new QLabel("");
  QLabel * job_launcher_label = new QLabel("Launcher Id:");
  _job_launcher_label_value = new QLabel("");
  QLabel * job_resource_label = new QLabel("Resource:");
  _job_resource_label_value = new QLabel("");
  QLabel * job_jobfile_label = new QLabel("Job File:");
  _job_jobfile_label_value = new QLabel("");
  QLabel * job_envfile_label = new QLabel("Env File:");
  _job_envfile_label_value = new QLabel("");
  QLabel * job_prefile_label = new QLabel("Preprocessing File:");
  _job_prefile_label_value = new QLabel("");


  // Specific values
  _yacs_dump_state_label = new QLabel("YACS dump state:");
  _yacs_dump_state_value = new QLabel("");

  QGroupBox * main_values_box = new QGroupBox("Main values");
  _main_values_form = new QFormLayout;
  _main_values_form->insertRow(0, job_name_label, _job_name_label_value);
  _main_values_form->insertRow(1, job_type_label, _job_type_label_value);
  _main_values_form->insertRow(2, job_state_label, _job_state_label_value);
  _main_values_form->insertRow(3, job_launcher_label, _job_launcher_label_value);
  _main_values_form->insertRow(4, job_resource_label, _job_resource_label_value);
  _main_values_form->insertRow(5, job_jobfile_label, _job_jobfile_label_value);
  _main_values_form->insertRow(6, job_envfile_label, _job_envfile_label_value);
  _main_values_form->insertRow(7, job_prefile_label, _job_prefile_label_value);
  main_values_box->setLayout(_main_values_form);

  QLabel * job_nif_label = new QLabel("Number of Input Files:");
  _job_nif_label_value = new QLabel("");
  QLabel * job_nof_label = new QLabel("Number of Output Files:");
  _job_nof_label_value = new QLabel("");
  QLabel * job_bd_label = new QLabel("Execution directory:");
  _job_bd_label_value = new QLabel("");
  QLabel * job_rd_label = new QLabel("Result directory:");
  _job_rd_label_value = new QLabel("");

  QLabel * job_mdt_label = new QLabel("Maximum duration:");
  _job_mdt_label_value = new QLabel("");
  QLabel * job_req_mem_label = new QLabel("Required memory:");
  _job_req_mem_label_value = new QLabel("");
  QLabel * job_nop_label = new QLabel("Number of processors:");
  _job_nop_label_value = new QLabel("");
  QLabel * job_nono_label = new QLabel("Number of nodes:");
  _job_nono_label_value = new QLabel("");
  QLabel * job_excl_label = new QLabel("Exclusive:");
  _job_excl_label_value = new QLabel("");

  // Parameters for COORM
  QLabel * job_lf_label = new QLabel("Launcher file:");
  _job_lf_label_value = new QLabel("");
  QLabel * job_la_label = new QLabel("Launcher args:");
  _job_la_label_value = new QLabel("");

  // Specific values
  _batch_queue_label = new QLabel("Batch queue:");
  _batch_queue_value = new QLabel("");
  _batch_partition_label = new QLabel("Batch partition:");
  _batch_partition_value = new QLabel("");
  _ll_jobtype_label = new QLabel("LoadLeveler JobType:");
  _ll_jobtype_value = new QLabel("");

  QGroupBox * run_values_box = new QGroupBox("Run values");
  _run_values_form = new QFormLayout;
  _run_values_form->insertRow(0, job_nif_label, _job_nif_label_value);
  _run_values_form->insertRow(1, job_nof_label, _job_nof_label_value);
  _run_values_form->insertRow(2, job_bd_label, _job_bd_label_value);
  _run_values_form->insertRow(3, job_rd_label, _job_rd_label_value);

  // Parameters for COORM
  _run_values_form->insertRow(4, job_lf_label, _job_lf_label_value);

  _other_run_values_form = new QFormLayout;
  _other_run_values_form->insertRow(0, job_mdt_label, _job_mdt_label_value);
  _other_run_values_form->insertRow(1, job_req_mem_label, _job_req_mem_label_value);
  _other_run_values_form->insertRow(2, job_nop_label, _job_nop_label_value);
  _other_run_values_form->insertRow(3, job_nono_label, _job_nono_label_value);
  _other_run_values_form->insertRow(4, job_excl_label, _job_excl_label_value);

  // Parameters for COORM
  _other_run_values_form->insertRow(5, job_la_label, _job_la_label_value);

  QHBoxLayout * box_layout = new QHBoxLayout();
  box_layout->addLayout(_run_values_form);
  box_layout->addLayout(_other_run_values_form);
  run_values_box->setLayout(box_layout);

  QVBoxLayout * mainLayout = new QVBoxLayout();
  mainLayout->addWidget(main_values_box);
  mainLayout->addWidget(run_values_box);
  _summary_tab->setLayout(mainLayout);

  removeTab(0);
  insertTab(0, _summary_tab, "Job Summary");
  setCurrentIndex(0);
}

void
BL::JobTab::createJobFilesTab()
{
  _files_tab = new QWidget(this);

  _input_files_list = new QListWidget(this);
  _input_files_list->setSelectionMode(QAbstractItemView::NoSelection);
  QGroupBox * input_files_box = new QGroupBox("Input Files");
  QVBoxLayout * input_layout = new QVBoxLayout();
  input_layout->addWidget(_input_files_list);
  input_files_box->setLayout(input_layout);

  _output_files_list = new QListWidget(this);
  _output_files_list->setSelectionMode(QAbstractItemView::NoSelection);
  QGroupBox * output_files_box = new QGroupBox("Output Files");
  QVBoxLayout * output_layout = new QVBoxLayout();
  output_layout->addWidget(_output_files_list);
  output_files_box->setLayout(output_layout);

  QVBoxLayout * mainLayout = new QVBoxLayout();
  mainLayout->addWidget(input_files_box);
  mainLayout->addWidget(output_files_box);
  _files_tab->setLayout(mainLayout);

  insertTab(1, _files_tab, "Job Files");
}

void
BL::JobTab::job_selected(const QModelIndex & index)
{
  DEBTRACE("BL::JobTab::job_selected slot");
  QStandardItem * item = _model->itemFromIndex(index);
  QStandardItem * item_name = _model->item(item->row());
  if (item)
  {
    BL::Job * job = _jobs_manager->getJob(item_name->text().toUtf8().constData());

    reset("");

    _job_name_label_value->setText(QString::fromUtf8(job->getName().c_str()));

    if (job->getState() == BL::Job::CREATED)
      _job_state_label_value->setText("Created");
    else if (job->getState() == BL::Job::IN_PROCESS)
      _job_state_label_value->setText("In Process");
    else if (job->getState() == BL::Job::QUEUED)
      _job_state_label_value->setText("Queued");
    else if (job->getState() == BL::Job::RUNNING)
      _job_state_label_value->setText("Running");
    else if (job->getState() == BL::Job::PAUSED)
      _job_state_label_value->setText("Paused");
    else if (job->getState() == BL::Job::ERROR)
      _job_state_label_value->setText("Error");
    else if (job->getState() == BL::Job::FAILED)
      _job_state_label_value->setText("Failed");
    else if (job->getState() == BL::Job::NOT_CREATED)
      _job_state_label_value->setText("Not Created");
    else 
      _job_state_label_value->setText("Finished");

    _job_launcher_label_value->setText(QVariant(job->getSalomeLauncherId()).toString());
    _job_jobfile_label_value->setText(QString::fromUtf8(job->getJobFile().c_str()));
    _job_envfile_label_value->setText(QString::fromUtf8(job->getEnvFile().c_str()));
    _job_prefile_label_value->setText(QString::fromUtf8(job->getPreCommand().c_str()));
    if (job->getType() == BL::Job::YACS_SCHEMA)
      _job_type_label_value->setText("YACS_Schema");
    else if (job->getType() == BL::Job::COMMAND)
      _job_type_label_value->setText("Command");
    else if (job->getType() == BL::Job::COMMAND_SALOME)
      _job_type_label_value->setText("Command_Salome");
    else if (job->getType() == BL::Job::PYTHON_SALOME)
      _job_type_label_value->setText("Python_Salome");

    _job_resource_label_value->setText(QString::fromUtf8(job->getResource().c_str()));

    BL::Job::BatchParam batch_params = job->getBatchParameters();

    BL::Job::FilesParam files_params = job->getFilesParameters();
    int nif = files_params.input_files_list.size();
    _job_nif_label_value->setText(QVariant(nif).toString());
    int nof = files_params.output_files_list.size();
    _job_nof_label_value->setText(QVariant(nof).toString());
    _job_bd_label_value->setText(QString::fromUtf8(batch_params.batch_directory.c_str()));
    _job_rd_label_value->setText(QString::fromUtf8(files_params.result_directory.c_str()));

    QString time = (batch_params.maximum_duration == "")? "Default" :
                                                          batch_params.maximum_duration.c_str();
    _job_mdt_label_value->setText(time);
    _job_nop_label_value->setText(QVariant(batch_params.nb_proc).toString());
    _job_nono_label_value->setText(QVariant(batch_params.nb_node).toString());
    QString exclText = (batch_params.exclusive)? "yes" : "no";
    _job_excl_label_value->setText(exclText);

    // Memory requirement
    long mem_mb = batch_params.mem_limit;
    ostringstream mem_ss;
    if (mem_mb < 1)
      mem_ss << "Default";
    else
    {
      if (mem_mb % 1024 == 0)
        mem_ss << mem_mb / 1024 << "GB";
      else
        mem_ss << mem_mb << "MB";
      switch (batch_params.mem_req_type)
      {
      case BL::Job::MEM_PER_NODE:
        mem_ss << " per node";
        break;
      case BL::Job::MEM_PER_CPU:
        mem_ss << " per core";
        break;
      default:
        throw Exception("Unknown memory requirement, unable to show selected job");
      }
    }
    _job_req_mem_label_value->setText(QString(mem_ss.str().c_str()));

    // Parameters for COORM
    _job_lf_label_value->setText(QString::fromUtf8(batch_params.launcher_file.c_str()));
    _job_la_label_value->setText(QString::fromUtf8(batch_params.launcher_args.c_str()));

    _input_files_list->clear();
    _output_files_list->clear();
    std::list<std::string>::iterator it;
    for (it = files_params.input_files_list.begin(); it != files_params.input_files_list.end(); it++)
    {
      std::string file = *it;
      _input_files_list->addItem(QString::fromUtf8(file.c_str()));
    }
    for (it = files_params.output_files_list.begin(); it != files_params.output_files_list.end(); it++)
    {
      std::string file = *it;
      _output_files_list->addItem(QString::fromUtf8(file.c_str()));
    }

    // Specific parameters management
    if (job->getDumpYACSState() > 0)
    {
      // Add widget in the layout
      _yacs_dump_state_value->setText(QVariant(job->getDumpYACSState()).toString());
      _main_values_form->insertRow(7, _yacs_dump_state_label, _yacs_dump_state_value);
    }
    if (job->getBatchQueue() != "")
    {
      _batch_queue_value->setText(QVariant(job->getBatchQueue().c_str()).toString());
      _other_run_values_form->insertRow(_other_run_values_form->rowCount(), _batch_queue_label, _batch_queue_value);
    }
    if (job->getBatchPartition() != "")
    {
      _batch_partition_value->setText(QVariant(job->getBatchPartition().c_str()).toString());
      _other_run_values_form->insertRow(_other_run_values_form->rowCount(), _batch_partition_label, _batch_partition_value);
    }
    if (job->getLoadLevelerJobType() != "")
    {
      _ll_jobtype_value->setText(QVariant(job->getLoadLevelerJobType().c_str()).toString());
      _other_run_values_form->insertRow(_other_run_values_form->rowCount(), _ll_jobtype_label, _ll_jobtype_value);
    }
  }
  else
    DEBTRACE ("itemFromIndex returns 0 !");
}

void 
BL::JobTab::itemChanged(QStandardItem * item)
{
  DEBTRACE("BL::JobTab::itemChanged slot");

  QStandardItem * item_name = _model->item(item->row());
  BL::Job * job = _jobs_manager->getJob(item_name->text().toUtf8().constData());

  if (_job_name_label_value->text() == QString::fromUtf8(job->getName().c_str()))
  {
    if (job->getState() == BL::Job::CREATED)
      _job_state_label_value->setText("Created");
    else if (job->getState() == BL::Job::IN_PROCESS)
      _job_state_label_value->setText("In Process");
    else if (job->getState() == BL::Job::QUEUED)
      _job_state_label_value->setText("Queued");
    else if (job->getState() == BL::Job::RUNNING)
      _job_state_label_value->setText("Running");
    else if (job->getState() == BL::Job::PAUSED)
      _job_state_label_value->setText("Paused");
    else if (job->getState() == BL::Job::ERROR)
      _job_state_label_value->setText("Error");
    else if (job->getState() == BL::Job::FAILED)
      _job_state_label_value->setText("Failed");
    else if (job->getState() == BL::Job::NOT_CREATED)
      _job_state_label_value->setText("Not Created");
    else 
      _job_state_label_value->setText("Finished");
  }
}

void
BL::JobTab::reset(QString job_name)
{
  if (job_name == _job_name_label_value->text() || job_name == "")
  {
    _job_name_label_value->setText("");
    _job_type_label_value->setText("");
    _job_state_label_value->setText("");
    _job_launcher_label_value->setText("");
    _job_resource_label_value->setText("");
    _job_nif_label_value->setText("");
    _job_nof_label_value->setText("");
    _job_bd_label_value->setText("");
    _job_rd_label_value->setText("");
    _job_mdt_label_value->setText("");
    _job_req_mem_label_value->setText("");
    _job_nop_label_value->setText("");
    _job_nono_label_value->setText("");
    _job_excl_label_value->setText("");
    _job_jobfile_label_value->setText("");
    _job_envfile_label_value->setText("");

    _input_files_list->clear();
    _output_files_list->clear();

    _yacs_dump_state_value->setText("");
    _batch_queue_value->setText("");
    _batch_partition_value->setText("");
    _ll_jobtype_value->setText("");

	// Parameters for COORM
    _job_lf_label_value->setText("");
    _job_la_label_value->setText("");
  }
}
