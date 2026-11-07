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

#include "BL_JobsManager_QT.hxx"
#include "BL_GenericGui.hxx"

#include <QApplication>
#include <QFileDialog>
#include <QGroupBox>
#include <QHBoxLayout>
#include <QMenu>
#include <QPushButton>
#include <QScrollArea>
#include <QStandardItemModel>
#include <QTextEdit>
#include <QTimer>
#include <QVBoxLayout>
#include <vector>

using namespace std;

// To tokenize a string
static void Tokenize(const std::string& str, std::vector<std::string>& tokens, const std::string& delimiters = " ");

BL::JobManagerEvent::JobManagerEvent(const std::string & action_i, 
				     const std::string & event_name_i, 
				     const std::string & job_name_i, 
				     const std::string & data_i) : QEvent(QEvent::User)
{
  action = action_i;
  event_name = event_name_i;
  job_name = job_name_i;
  data = data_i;
}

BL::JobManagerEvent::~JobManagerEvent() {}  

BL::JobsManager_QT::JobsManager_QT(QWidget * parent, BL::GenericGui * main_gui, BL::SALOMEServices * salome_services) : 
  QDockWidget(parent), BL::JobsManager(salome_services)
{
  DEBTRACE("Creating BL::JobsManager_QT");
  _main_gui = main_gui;
  setObserver(this);
  _model_manager = NULL;

  // Widget Part

  QWidget * main_widget = new QWidget(this);

  _load_jobs = new QPushButton("Load Jobs");
  _save_jobs = new QPushButton("Save Jobs");
  connect(_load_jobs, SIGNAL(clicked()), this, SLOT(load_jobs_button()));
  connect(_save_jobs, SIGNAL(clicked()), this, SLOT(save_jobs_button()));

  _auto_refresh_jobs = new QPushButton("Auto Refresh: 30s");
  _timer = new QTimer(this);
  _timer->stop();
  _timer->start(30 * 1000);
  connect(_timer, SIGNAL(timeout()), this, SLOT(RefreshJobs()));

  // Menu for auto refresh
  QMenu * refresh_menu = new QMenu(this);
  refresh_menu->addAction("No", this, SLOT(no_auto_refresh()));
  refresh_menu->addAction("10 seconds", this, SLOT(ten_seconds_refresh()));
  refresh_menu->addAction("30 seconds", this, SLOT(thirty_seconds_refresh()));
  refresh_menu->addAction("1 minute", this, SLOT(one_minute_refresh()));
  refresh_menu->addAction("5 minutes", this, SLOT(five_minutes_refresh()));
  refresh_menu->addAction("30 minutes", this, SLOT(thirty_minutes_refresh()));
  refresh_menu->addAction("1 hour", this, SLOT(one_hour_refresh()));
  _auto_refresh_jobs->setMenu(refresh_menu);

  QHBoxLayout * button_layout = new QHBoxLayout();
  button_layout->addWidget(_load_jobs);
  button_layout->addWidget(_save_jobs);
  button_layout->addWidget(_auto_refresh_jobs);

  QGroupBox * message_box = new QGroupBox("Messages");
  _log = new QTextEdit(this);
  _log->setReadOnly(true);
  QVBoxLayout * message_box_layout = new QVBoxLayout(message_box);
  message_box_layout->addWidget(_log);
  message_box->setLayout(message_box_layout);

  QVBoxLayout * mainLayout = new QVBoxLayout();
  mainLayout->addLayout(button_layout);
  mainLayout->addWidget(message_box);
  main_widget->setLayout(mainLayout);

  QScrollArea * scroll_widget = new QScrollArea(this);
  scroll_widget->setWidget(main_widget);
  scroll_widget->setWidgetResizable(true);
  setWidget(scroll_widget);
  setWindowTitle("Job Manager");
  setObjectName("jmJobManagerDock");
}

BL::JobsManager_QT::~JobsManager_QT()
{
  DEBTRACE("Destroying BL::JobsManager_QT");
}

void
BL::JobsManager_QT::set_model_manager(BL::QModelManager * model_manager)
{
  _model_manager = model_manager;
}

void
BL::JobsManager_QT::load_jobs_button()
{
  DEBTRACE("load_jobs");
  QString jobs_file = QFileDialog::getOpenFileName(this,
                                                   tr("Choose an xml jobs file"), "",
                                                   tr("xml (*.xml);;All Files (*)"));
  if (jobs_file == "")
  {
    write_normal_text("Load jobs action cancelled\n");
  }
  else
    load_jobs(jobs_file.toUtf8().constData());
}

void
BL::JobsManager_QT::save_jobs_button()
{
  DEBTRACE("save_jobs");
  QFileDialog dialog(this, "Save jobs file");
  QStringList filters;
  filters << "XML files (*.xml)"
          << "Any files (*)";
  dialog.setFileMode(QFileDialog::AnyFile);
  dialog.setNameFilters(filters);
  dialog.selectNameFilter("(*.xml)");
  dialog.setDefaultSuffix("xml");
  dialog.setConfirmOverwrite(true);
  dialog.setAcceptMode(QFileDialog::AcceptSave);
  QString jobs_file("");
  QStringList fileNames;
  fileNames.clear();
  if (bool ret = dialog.exec())
  {
    DEBTRACE(ret << " " << dialog.confirmOverwrite());
    fileNames = dialog.selectedFiles();
    if (!fileNames.isEmpty())
      jobs_file= fileNames.first();
  }
  if (jobs_file == "")
  {
    write_normal_text("Save jobs action cancelled\n");
  }
  else
    save_jobs(jobs_file.toUtf8().constData());
}

void
BL::JobsManager_QT::RefreshJobs()
{
  refresh_jobs(); 
}

void
BL::JobsManager_QT::no_auto_refresh()
{
  _auto_refresh_jobs->setText("Auto Refresh: no");
  _timer->stop();
}

void
BL::JobsManager_QT::ten_seconds_refresh()
{
  _auto_refresh_jobs->setText("Auto Refresh: 10s");
  _timer->stop();
  _timer->start(10 * 1000);
}

void 
BL::JobsManager_QT::thirty_seconds_refresh()
{
  _auto_refresh_jobs->setText("Auto Refresh: 30s");
  _timer->stop();
  _timer->start(30 * 1000);
}

void 
BL::JobsManager_QT::one_minute_refresh()
{
  _auto_refresh_jobs->setText("Auto Refresh: 1min");
  _timer->stop();
  _timer->start(1 * 60 * 1000);
}

void 
BL::JobsManager_QT::five_minutes_refresh()
{
  _auto_refresh_jobs->setText("Auto Refresh: 5min");
  _timer->stop();
  _timer->start(5 * 60 * 1000);
}

void 
BL::JobsManager_QT::thirty_minutes_refresh()
{
  _auto_refresh_jobs->setText("Auto Refresh: 30min");
  _timer->stop();
  _timer->start(30 * 60 * 1000);
}

void 
BL::JobsManager_QT::one_hour_refresh()
{
  _auto_refresh_jobs->setText("Auto Refresh: 1hour");
  _timer->stop();
  _timer->start(1 * 60 * 60 * 1000);
}

void 
BL::JobsManager_QT::restart_job(const std::string & name)
{
  DEBTRACE("Restart job with name: " << name);
  BL::CreateJobWizard wizard(this, _salome_services);
  wizard.clone(name);
  wizard.end(1);
  wizard.job_name = name;
  wizard.start_job = true;
  _main_gui->delete_job_internal();
  create_job_with_wizard(wizard);
}

void 
BL::JobsManager_QT::edit_clone_job(const std::string & name)
{
  BL::CreateJobWizard wizard(this, _salome_services);
  wizard.clone(name);
  wizard.exec();

  // Check if the job has the same name
  if (name == wizard.job_name)
  {
    DEBTRACE("Job " << name << " has been edited");
    _main_gui->delete_job_internal();
  }

  if (wizard.job_name != "")
  {
    create_job_with_wizard(wizard);
  }
  else
  {
    DEBTRACE("User cancel Create Job Wizard");
  }
}

void
BL::JobsManager_QT::create_job()
{
    BL::CreateJobWizard wizard(this, _salome_services);
    wizard.exec();
    if (wizard.job_name != "")
    {
      create_job_with_wizard(wizard);
    }
    else
    {
       DEBTRACE("User cancel Create Job Wizard");
    }
}

void 
BL::JobsManager_QT::create_job_with_wizard(BL::CreateJobWizard & wizard)
{
  BL::Job * new_job = createJob(wizard.job_name);
  switch (wizard.job_type)
  {
  case BL::CreateJobWizard::YACS:
    // YACS schema job
    new_job->setType(BL::Job::YACS_SCHEMA);
    new_job->setJobFile(wizard.yacs_file);
    new_job->setDumpYACSState(wizard.dump_yacs_state);
    new_job->setYacsDriverOptions(wizard.yacs_driver_options);
    break;
  case BL::CreateJobWizard::COMMAND:
    // Command Job
    new_job->setType(BL::Job::COMMAND);
    new_job->setJobFile(wizard.command);
    break;
  case BL::CreateJobWizard::COMMAND_SALOME:
    // Command Job
    new_job->setType(BL::Job::COMMAND_SALOME);
    new_job->setJobFile(wizard.command);
    break;
  case BL::CreateJobWizard::PYTHON_SALOME:
    // Python Salome Job
    new_job->setType(BL::Job::PYTHON_SALOME);
    new_job->setJobFile(wizard.python_salome_file);
    break;
  default:
    throw BL::Exception("Unknown job type");
  }

  // For all jobs
  new_job->setEnvFile(wizard.env_file);
  new_job->setPreCommand(wizard.pre_command);
  BL::Job::BatchParam param;

  // For COORM
  if (wizard.coorm_batch_directory != "")
  {
	param.batch_directory = wizard.coorm_batch_directory;
  }
  else if (wizard.batch_directory != "")
  {
	param.batch_directory = wizard.batch_directory;
  }

  param.maximum_duration = wizard.maximum_duration;
  param.mem_limit = wizard.mem_limit;
  param.mem_req_type = wizard.mem_req_type;
  param.nb_proc = wizard.nb_proc;
  param.nb_node = wizard.nb_node;
  param.exclusive = wizard.exclusive;

  // Parameters for COORM
  param.launcher_file = wizard.launcher_file;
  param.launcher_args = wizard.launcher_args;

  new_job->setBatchParameters(param);
  BL::Job::FilesParam files_params;
  files_params.result_directory = wizard.result_directory;
  files_params.input_files_list = wizard.input_files_list;
  files_params.output_files_list = wizard.output_files_list;
  new_job->setFilesParameters(files_params);
  new_job->setResource(wizard.resource_choosed);
  new_job->setBatchQueue(wizard.batch_queue);
  new_job->setBatchPartition(wizard.batch_partition);
  new_job->setLoadLevelerJobType(wizard.ll_jobtype);
  new_job->setWCKey(wizard.wckey);
  new_job->setExtraParams(wizard.extra_params);

  // End
  addJobToLauncher(wizard.job_name);
  emit new_job_added(QString::fromUtf8(wizard.job_name.c_str()));
  QStandardItemModel * model = _model_manager->getModel();
  QList<QStandardItem *> item_list = model->findItems(QString::fromUtf8(wizard.job_name.c_str()));
  QStandardItem * job_state_item = model->item(item_list.at(0)->row(), 2);
  _main_gui->_jobs_table->selectRow(item_list.at(0)->row());
  if (wizard.start_job)
    start_job(wizard.job_name);
}

void
BL::JobsManager_QT::delete_job(QString job_name)
{
  BL::JobsManager::removeJob(job_name.toUtf8().constData());
  _model_manager->delete_job(job_name);
  _main_gui->_job_tab->reset(job_name);
}

void 
BL::JobsManager_QT::sendEvent(const std::string & action, 
			      const std::string & event_name, 
			      const std::string & job_name, 
			      const std::string & data)
{
  DEBTRACE("sendEvent BL::JobsManager_QT");

  // Sending a QEvent to go back to main thread
  BL::JobManagerEvent * event = new JobManagerEvent(action, event_name, job_name, data);
  QApplication::postEvent(this, event);
}

bool 
BL::JobsManager_QT::event(QEvent * e)
{
  QDockWidget::event(e);
  JobManagerEvent * event = dynamic_cast<JobManagerEvent*>(e);
  if (!event) return false;

  DEBTRACE("BL::JobsManager_QT Receiving event : " 
	   << event->action << " " 
	   << event->event_name << " "
	   << event->job_name << " "
	   << event->data);

  QString job_name = QString::fromUtf8(event->job_name.c_str());
  if (event->action == "create_job")
  {
    if (event->event_name == "Ok")
    {
      write_normal_text("Job " + job_name + " created\n");
    }
    else
    {
      write_error_text("Error in creating job: " + job_name + "\n");
      write_error_text("*** ");
      write_error_text((event->data).c_str());
      write_error_text(" ***\n");
    }
  }
  else if (event->action == "start_job")
  {
    if (event->event_name == "Ok")
    {
      write_normal_text("Job " + job_name + " queued\n");
    }
    else
    {
      write_error_text("Error in starting job: " + job_name + "\n");
      write_error_text("*** ");
      write_error_text((event->data).c_str());
      write_error_text(" ***\n");
    }
    emit job_state_changed(job_name);
  }
  else if (event->action == "refresh_job")
  {
    if (event->event_name == "Ok")
    {
      QString state((event->data).c_str());
      state = state.toLower();
      write_normal_text("Job " + job_name + " new state is " + state + "\n");
      emit job_state_changed(job_name);
    }
    else
    {
      write_error_text("Error in refreshing job: " + job_name + "\n");
      write_error_text("*** ");
      write_error_text((event->data).c_str());
      write_error_text(" ***\n");
    }
  }
  else if (event->action == "delete_job")
  {
    if (event->event_name == "Ok")
    {
      write_normal_text("Job " + job_name + " deleted\n");
    }
    else
    {
      write_error_text("Warning delete job: " + job_name + " maybe not complete, exception catch in SALOME Launcher service\n");
      write_error_text("*** ");
      write_error_text((event->data).c_str());
      write_error_text(" ***\n");
    }
  }
  else if (event->action == "get_results_job")
  {
    if (event->event_name == "Ok")
    {
      write_normal_text("Results of Job " + job_name + " have been got.\n");
    }
    else
    {
      write_error_text("Warning for results of job: " + job_name + " maybe not complete, exception catch in SALOME Launcher service\n");
      write_error_text("*** ");
      write_error_text((event->data).c_str());
      write_error_text(" ***\n");
    }
  }
  else if (event->action == "stop_job")
  {
    if (event->event_name == "Ok")
    {
      write_normal_text("Job " + job_name + " is stopped\n");
    }
    else
    {
      write_error_text("Error when trying to stop job: " + job_name + "\n");
      write_error_text("*** ");
      write_error_text((event->data).c_str());
      write_error_text(" ***\n");
    }
  }
  else if (event->action == "get_assigned_hostnames")
  {
    if (event->event_name == "Ok")
    {
	  vector<string> hostnames;

	  Tokenize(event->data, hostnames, "+");

	  vector<string>::iterator it;

      write_normal_text("Job " + job_name + " assigned hostnames are :\n");

	  for (it = hostnames.begin(); it < hostnames.end(); it++)
	  {
		  vector<string> hostname;
		  Tokenize(*it, hostname, ".");
		  QString assigned_hostname(hostname[0].c_str());
		  write_normal_text("+ " + assigned_hostname + "\n");
	  }
    }
    else
    {
		// Do nothing in case the batch manager does not support this
    }
  }
  else if (event->action == "save_jobs")
  {
    if (event->event_name == "Error")
    {
      write_error_text("Error in saving jobs: \n");
      write_error_text("*** ");
      write_error_text((event->data).c_str());
      write_error_text(" ***\n");
    }
    else
    {
      QString str((event->data).c_str());
      write_normal_text("Jobs saved in file " + str + "\n");
    }
  }
  else if (event->action == "load_jobs")
  {
    if (event->event_name == "Error")
    {
      write_error_text("Error in loading jobs: \n");
      write_error_text("*** ");
      write_error_text((event->data).c_str());
      write_error_text(" ***\n");
    }
    else
    {
      QString str((event->data).c_str());
      write_normal_text("Jobs loaded from file " + str + "\n");
    }
  }
  else if (event->action == "add_job")
  {
    if (event->event_name == "Ok")
    {
      write_normal_text("New job added " + job_name + "\n");
      emit new_job_added(job_name);
    }
  }
  else if (event->action == "to_remove_job")
  {
    if (event->event_name == "Ok")
      _main_gui->delete_job_external(job_name);
  }
  else
  {
    QString str((event->action).c_str());
    write_error_text("Unknown type of event received:" + str + "\n");
  }
  return true;
}

void 
BL::JobsManager_QT::write_normal_text(const QString & text)
{
  _log->setReadOnly(false);
  QTextCursor cursor = _log->textCursor();
  QTextCharFormat text_format;
  text_format.setForeground(Qt::darkBlue);
  cursor.insertText(text, text_format);
  _log->setTextCursor(cursor);
  _log->setReadOnly(true);
}

void 
BL::JobsManager_QT::write_error_text(const QString & text)
{
  _log->setReadOnly(false);
  QTextCursor cursor = _log->textCursor();
  QTextCharFormat text_format;
  text_format.setForeground(Qt::red);
  cursor.insertText(text, text_format);
  _log->setTextCursor(cursor);
  _log->setReadOnly(true);
}

// To tokenize a string
void Tokenize(const std::string& str, std::vector<std::string>& tokens, const std::string& delimiters)
{
	// Skip delimiters at beginning.
	string::size_type lastPos = str.find_first_not_of(delimiters, 0);
	// Find first "non-delimiter".
	string::size_type pos     = str.find_first_of(delimiters, lastPos);

	while (string::npos != pos || string::npos != lastPos)
	{
		// Found a token, add it to the vector.
		tokens.push_back(str.substr(lastPos, pos - lastPos));
		// Skip delimiters.  Note the "not_of"
		lastPos = str.find_first_not_of(delimiters, pos);
		// Find next "non-delimiter"
		pos = str.find_first_of(delimiters, lastPos);
	}
}
