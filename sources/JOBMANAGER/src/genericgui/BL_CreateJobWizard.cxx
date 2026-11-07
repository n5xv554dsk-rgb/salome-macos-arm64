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

#include "BL_CreateJobWizard.hxx"
#include "BL_JobsManager_QT.hxx"

#include <QFileDialog>
#include <QMessageBox>
#include <QTreeView>
#include <QDir>

#ifndef WNT
#include <unistd.h>
#include <pwd.h>
#endif
#include <sys/types.h>
#include <stdlib.h>
#include <time.h>

#include <ui_ResourceRequirementsWizardPage.h>
#include <ui_FilesWizardPage.h>
#include <ui_AdvancedParametersWizardPage.h>

#ifdef WNT
#undef ERROR
#endif

using namespace std;
using namespace BL;

BL::CreateJobWizard::CreateJobWizard(BL::JobsManager_QT * jobs_manager, BL::SALOMEServices * salome_services)
{
  DEBTRACE("Creating BL::CreateJobWizard");
  BL_ASSERT(jobs_manager);
  BL_ASSERT(salome_services);
  _jobs_manager = jobs_manager;
  _salome_services = salome_services;

  job_name = "";
  job_type = YACS;
  yacs_file = "";
  command = "";
  python_salome_file = "";
  env_file = "";
  pre_command = "";
  batch_directory = "";

  // For COORM
  coorm_batch_directory = "";

  maximum_duration = "";
  mem_limit = 0;
  mem_req_type = BL::Job::MEM_PER_NODE;
  nb_proc = 1;
  nb_node = 0;

  // Parameters for COORM
  launcher_file = "";
  launcher_args = "";

  result_directory = "";

  resource_choosed = "";
  batch_queue = "";
  batch_partition = "";

  start_job = false;
  dump_yacs_state = -1;
  yacs_driver_options = "";
  ll_jobtype = "";

  setOptions(QWizard::NoBackButtonOnStartPage);

  // Common pages
  _job_name_page = new BL::JobNamePage(this, _jobs_manager);
  _batch_parameters_page = new BL::BatchParametersPage(this, salome_services);

  setPage(Page_JobName, _job_name_page);
  setPage(Page_BatchParameters, _batch_parameters_page);

  // For COORM
  setPage(Page_COORM_BatchParameters, new BL::COORM_BatchParametersPage(this, salome_services));

  setPage(Page_Files, new BL::FilesPage(this, salome_services));
  setPage(Page_Resource, new BL::ResourcePage(this, salome_services));
  setPage(Page_Advanced, new BL::AdvancedParametersPage(this));
  setPage(Page_Conclusion, new BL::ConclusionPage(this));

  // Specific pages
  setPage(Page_YACSSchema, new BL::YACSSchemaPage(this));
  setPage(Page_Command_Main_Definitions, new BL::CommandMainPage(this));
  setPage(Page_PythonSalome_Main_Definitions, new BL::PythonSalomeMainPage(this));

  setWindowTitle("Create Job Wizard");
  connect(this, SIGNAL(finished(int)), this, SLOT(end(int)));
}

BL::CreateJobWizard::~CreateJobWizard()
{
  DEBTRACE("Destroying BL::CreateJobWizard");
}

void
BL::CreateJobWizard::clone(const std::string & name)
{
  if (_jobs_manager->job_already_exist(name) == true)
  {
    BL::Job * job = _jobs_manager->getJob(name);

    // We can only edit a job in CREATED, ERROR, FAILED and NOT_CREATED
    if (job->getState() == BL::Job::CREATED ||
        job->getState() == BL::Job::ERROR   ||
        job->getState() == BL::Job::FAILED  ||
        job->getState() == BL::Job::NOT_CREATED)
    { 
      setField("job_name", QString(name.c_str()));
      _job_name_page->_check_name = false;
    }

    if (job->getType() == BL::Job::YACS_SCHEMA)
    {
      setField("yacs_file", QString(job->getJobFile().c_str()));
      setField("job_type_yacs", true);
      setField("env_yacs_file", QString(job->getEnvFile().c_str()));
      setField("pre_yacs_file", QString(job->getPreCommand().c_str()));
      if (job->getDumpYACSState() != -1)
      {
        QString value;
        value.setNum(job->getDumpYACSState());
        setField("dump_yacs_state", value);
      }
      if (!job->getYacsDriverOptions().empty())
      {
        setField("yacs_driver_options", job->getYacsDriverOptions().c_str());
      }
    }
    else if (job->getType() == BL::Job::COMMAND)
    {
      setField("command", QString(job->getJobFile().c_str()));
      setField("job_type_command", true);
      setField("env_command_file", QString(job->getEnvFile().c_str()));
      setField("pre_command_file", QString(job->getPreCommand().c_str()));
    }
    else if (job->getType() == BL::Job::COMMAND_SALOME)
    {
      setField("command", QString(job->getJobFile().c_str()));
      setField("job_type_command_salome", true);
      setField("env_command_file", QString(job->getEnvFile().c_str()));
      setField("pre_command_file", QString(job->getPreCommand().c_str()));
    }
    else if (job->getType() == BL::Job::PYTHON_SALOME)
    {
      setField("PythonSalome", QString(job->getJobFile().c_str()));
      setField("job_type_python_salome", true);
      setField("env_PythonSalome_file", QString(job->getEnvFile().c_str()));
      setField("pre_PythonSalome_file", QString(job->getPreCommand().c_str()));
    }


    // For COORM
    BL::Job::BatchParam batch_params = job->getBatchParameters();
    BL::ResourceDescr resource_descr = _salome_services->getResourceDescr(job->getResource().c_str());
    std::string batch = resource_descr.batch.c_str();
    if (batch == "coorm")
    {
      setField("coorm_batch_directory", QString(batch_params.batch_directory.c_str()));
      setField("launcher_file", QString(batch_params.launcher_file.c_str()));
      setField("launcher_args", QString(batch_params.launcher_args.c_str()));
    }
    else
    {
      setField("batch_directory", QString(batch_params.batch_directory.c_str()));
    }

    QString proc_value;
    proc_value.setNum(batch_params.nb_proc);
    setField("proc_value", proc_value);

    QString node_value;
    node_value.setNum(batch_params.nb_node);
    setField("node_value", node_value);

    setField("exclusive", batch_params.exclusive);

    if (batch_params.maximum_duration == "")
    {
      setField("default_time", true);
      setField("duration_hour", 0);
      setField("duration_min", 0);
    }
    else
    {
      setField("user_time", true);
      std::size_t pos = batch_params.maximum_duration.find(":");
      std::string hour_str = batch_params.maximum_duration.substr(0, pos);
      int hour; 
      std::istringstream iss_hour(hour_str);
      iss_hour >> hour;
      setField("duration_hour", hour);

      std::string min_str = batch_params.maximum_duration.substr(pos + 1, batch_params.maximum_duration.npos);
      int min; 
      std::istringstream iss_min(min_str);
      iss_min >> min;
      setField("duration_min", min);
    }

    long long mem_mb = batch_params.mem_limit;
    if (mem_mb < 1)
    {
      setField("default_mem", true);
    }
    else
    {
      setField("user_mem", true);
      if (mem_mb % 1024 == 0)
      {
        setField("mem_value", mem_mb / 1024);
        _batch_parameters_page->setMemUnit(BatchParametersPage::GB);
      }
      else
      {
        setField("mem_value", mem_mb);
        _batch_parameters_page->setMemUnit(BatchParametersPage::MB);
      }
      _batch_parameters_page->setMemReqType(batch_params.mem_req_type);
    }

    BL::Job::FilesParam files_params = job->getFilesParameters();

    std::list<std::string>::iterator it = files_params.input_files_list.begin();
    for (; it != files_params.input_files_list.end(); it++)
      _input_files_list->addItem(QString((*it).c_str()));
    it = files_params.output_files_list.begin();
    for (; it != files_params.output_files_list.end(); it++)
      _output_files_list->addItem(QString((*it).c_str()));

    setField("result_directory", QString(files_params.result_directory.c_str()));
    setField("resource_choosed", QString(job->getResource().c_str()));
    setField("batch_queue", QString(job->getBatchQueue().c_str()));
    setField("batch_partition", QString(job->getBatchPartition().c_str()));
    setField("ll_jobtype", QString(job->getLoadLevelerJobType().c_str()));
    setField("wckey", QString(job->getWCKey().c_str()));
    setField("extra_params", QString(job->getExtraParams().c_str()));
  }
}

void
BL::CreateJobWizard::setFilesList(QListWidget * input_files_list, QListWidget * output_files_list)
{
  _input_files_list = input_files_list;
  _output_files_list = output_files_list;
}

void
BL::CreateJobWizard::end(int result)
{
  DEBTRACE("End of BL::CreateJobWizard");
  if (result)
  {
    // Job Name Panel
    QString f_job_name = field("job_name").toString();
    job_name = f_job_name.trimmed().toUtf8().constData();
    if (field("job_type_yacs").toBool())
      job_type = YACS;
    else if (field("job_type_command").toBool())
      job_type = COMMAND;
    else if (field("job_type_command_salome").toBool())
      job_type = COMMAND_SALOME;
    else
      job_type = PYTHON_SALOME;

    // YACS Schema Panel
    QString f_yacs_file = field("yacs_file").toString();
    yacs_file = f_yacs_file.trimmed().toUtf8().constData();
    dump_yacs_state = field("dump_yacs_state").toInt();
    yacs_driver_options = field("yacs_driver_options").toString().trimmed().toUtf8().constData();

    // Command Panel
    QString f_command = field("command").toString();
    command = f_command.trimmed().toUtf8().constData();

    // Command Panel
    QString f_python_salome_file = field("PythonSalome").toString();
    python_salome_file = f_python_salome_file.trimmed().toUtf8().constData();

    QString f_env_file;
    if (job_type == YACS)
      f_env_file = field("env_yacs_file").toString();
    else if (job_type == COMMAND || job_type == COMMAND_SALOME)
      f_env_file = field("env_command_file").toString();
    else if (job_type == PYTHON_SALOME)
      f_env_file = field("env_PythonSalome_file").toString();
    env_file = f_env_file.trimmed().toUtf8().constData();

    QString f_pre_command_file;
    if (job_type == YACS)
      f_pre_command_file = field("pre_yacs_file").toString();
    else if (job_type == COMMAND || job_type == COMMAND_SALOME)
      f_pre_command_file = field("pre_command_file").toString();
    else if (job_type == PYTHON_SALOME)
      f_pre_command_file = field("pre_PythonSalome_file").toString();
    pre_command = f_pre_command_file.trimmed().toUtf8().constData();

    // Batch Panel
    QString f_batch_directory = field("batch_directory").toString();
    batch_directory = f_batch_directory.trimmed().toUtf8().constData();

    // For COORM
    QString f_coorm_batch_directory = field("coorm_batch_directory").toString();
    coorm_batch_directory = f_coorm_batch_directory.toUtf8().constData();

	// For COORM
    QString f_launcher_file = field("launcher_file").toString();
    launcher_file = f_launcher_file.toUtf8().constData();
    QString f_launcher_args = field("launcher_args").toString();
    launcher_args = f_launcher_args.toUtf8().constData();

    QString time_hour;
    QString time_min;
    if (field("default_time").toBool() ||
        (field("duration_hour").toInt() == 0 && field("duration_min").toInt() == 0))
    {
      maximum_duration = "";
    }
    else
    {
      if (field("duration_hour").toInt() < 10)
        time_hour = "0" + field("duration_hour").toString().trimmed();
      else
        time_hour = field("duration_hour").toString().trimmed();
      if (field("duration_min").toInt() < 10)
        time_min = "0" + field("duration_min").toString().trimmed();
      else
        time_min = field("duration_min").toString().trimmed();
      maximum_duration = time_hour.toStdString() + ":" + time_min.toStdString();
    }

    if(field("default_mem").toBool())
    {
      mem_limit = -1;
    }
    else
    {
      unsigned long mem = field("mem_value").toULongLong();
      BatchParametersPage::MemUnit mem_unit = _batch_parameters_page->getMemUnit();
      switch (mem_unit)
      {
      case BatchParametersPage::MB:
        mem_limit = mem;
        break;
      case BatchParametersPage::GB:
        mem_limit = mem * 1024;
        break;
      default:
        throw Exception("Invalid memory unit");
      }
      mem_req_type = _batch_parameters_page->getMemReqType();
    }

    nb_proc = field("proc_value").toInt();
    nb_node = field("node_value").toInt();
    exclusive = field("exclusive").toBool();

    // Files Panel
    QString f_result_directory = field("result_directory").toString();
    result_directory = f_result_directory.trimmed().toUtf8().constData();
    for (int i = 0; i < _input_files_list->count(); ++i)
    {
      QListWidgetItem * item = _input_files_list->item(i);
      QString item_text = item->text();
      input_files_list.push_back(item_text.trimmed().toUtf8().constData());
    }
    for (int i = 0; i < _output_files_list->count(); ++i)
    {
      QListWidgetItem * item = _output_files_list->item(i);
      QString item_text = item->text();
      output_files_list.push_back(item_text.trimmed().toUtf8().constData());
    }

    // Resource list
    QString f_resource_choosed = field("resource_choosed").toString();
    resource_choosed = f_resource_choosed.trimmed().toUtf8().constData();

    // Batch Queue
    QString f_batch_queue = field("batch_queue").toString();
    batch_queue = f_batch_queue.trimmed().toUtf8().constData();

    // Batch Partition
    QString f_batch_partition = field("batch_partition").toString();
    batch_partition = f_batch_partition.trimmed().toUtf8().constData();

    // LoadLeveler JobType
    BL::ResourceDescr resource_descr = _salome_services->getResourceDescr(resource_choosed);
    std::string batch = resource_descr.batch.c_str();
    if (batch == "ll")
    {
      QString f_ll_jobtype = field("ll_jobtype").toString();
      ll_jobtype = f_ll_jobtype.trimmed().toStdString();
    }
    else
    {
      ll_jobtype = "";
    }

    // WC Key
    QString f_wckey = field("wckey").toString();
    wckey = f_wckey.trimmed().toUtf8().constData();

    // Extra params
    QString f_extra_params = field("extra_params").toString();
    extra_params = f_extra_params.trimmed().toUtf8().constData();

    start_job = field("start_job").toBool();
  }
}

// Job Name Page
BL::JobNamePage::JobNamePage(QWidget * parent, BL::JobsManager_QT * jobs_manager)
: QWizardPage(parent)
{
  _jobs_manager = jobs_manager;
  _check_name = true;
  setTitle("Create a new job");

  QLabel *label = new QLabel("Enter Job name, you cannot add two jobs with the same name");
  label->setWordWrap(true);
  QLabel * nameLabel = new QLabel("Job Name:");
  QLineEdit * _nameLineEdit = new QLineEdit(this);
  registerField("job_name", _nameLineEdit);

  QLabel * label_type = new QLabel("Choose type of batch job:");
  QGroupBox *groupBox = new QGroupBox("Type of job");
  QRadioButton * _yacs_schema_button = new QRadioButton(tr("YACS Schema"));
  _yacs_schema_button->setChecked(true);
  QRadioButton * _command_button = new QRadioButton(tr("Command"));
  QRadioButton * _command_salome_button = new QRadioButton(tr("Command in salome shell"));
  QRadioButton * _python_salome_button = new QRadioButton(tr("Python script in SALOME"));
  QVBoxLayout *vbox = new QVBoxLayout;
  vbox->addWidget(_yacs_schema_button);
  vbox->addWidget(_command_button);
  vbox->addWidget(_command_salome_button);
  vbox->addWidget(_python_salome_button);
  vbox->addStretch(1);
  groupBox->setLayout(vbox);
  registerField("job_type_yacs", _yacs_schema_button);
  registerField("job_type_command", _command_button);
  registerField("job_type_command_salome", _command_salome_button);
  registerField("job_type_python_salome", _python_salome_button);

  QGroupBox * explanationBox = new QGroupBox("Explanation");
  QVBoxLayout *explanationvbox = new QVBoxLayout;
  _explanation = new QLabel();
  _explanation->setWordWrap(true);
  explanationvbox->addWidget(_explanation);
  explanationvbox->addStretch(1);
  explanationBox->setLayout(explanationvbox);

  // Layouts
  QVBoxLayout * main_layout = new QVBoxLayout;
  main_layout->addWidget(label);
  QGridLayout *layout = new QGridLayout;
  layout->addWidget(nameLabel, 0, 0);
  layout->addWidget(_nameLineEdit, 0, 1);
  main_layout->insertLayout(-1, layout);
  layout->addWidget(label_type, 2, 0);
  layout->addWidget(groupBox, 3, 0, 1, -1);
  layout->addWidget(explanationBox, 4, 0, 1, -1);
  setLayout(main_layout);

  connect(_yacs_schema_button, SIGNAL(toggled(bool)), this, SLOT(yacs_schema_button(bool)));
  connect(_command_button, SIGNAL(toggled(bool)), this, SLOT(command_button(bool)));
  connect(_command_salome_button, SIGNAL(toggled(bool)), this, SLOT(command_salome_button(bool)));
  connect(_python_salome_button, SIGNAL(toggled(bool)), this, SLOT(python_salome_button(bool)));

  // Default button
  yacs_schema_button(true);
}

BL::JobNamePage::~JobNamePage()
{}

void
BL::JobNamePage::yacs_schema_button(bool checked)
{
  if (checked)
  {
    _explanation->setText("Launch a YACS schema.");
    setField("exclusive", true);
  }
}

void
BL::JobNamePage::command_button(bool checked)
{
  if (checked)
  {
    _explanation->setText("Launch a script on a remote resource without using "
                          "SALOME environment.");
    setField("exclusive", false);
  }
}

void
BL::JobNamePage::command_salome_button(bool checked)
{
  if (checked)
  {
    _explanation->setText("Launch a script on a remote resource within SALOME "
                          "environment but whitout the SALOME application.");
    setField("exclusive", false);
  }
}

void
BL::JobNamePage::python_salome_button(bool checked)
{
  if (checked)
  {
    _explanation->setText("Launch a python script into a SALOME application.");
    setField("exclusive", true);
  }
}

bool
BL::JobNamePage::validatePage()
{
  DEBTRACE("Calling validatePage of BL::JobNamePage");
  bool return_value;
  QString job_name = field("job_name").toString();

  // Check if job name is empty
  if (job_name == "")
  {
    QMessageBox::warning(NULL, "Job Name Error", "Job name entered is empty, enter a job name or cancel the wizard");
    return_value = false;
  }

  // Check if job name already exists
  else {
    if (_jobs_manager->job_already_exist(job_name.toUtf8().constData()) == false || _check_name == false)
    {
      return_value = true;
    }
    else
    {
      QMessageBox::critical(NULL, "Job Name Error", "Job name entered is already used");
      QString value("");
      setField("job_name", value);
      return_value = false;
    }
  }

  return return_value;
}

int
BL::JobNamePage::nextId() const
{
  if (field("job_type_yacs").toBool())
  {
    return BL::CreateJobWizard::Page_YACSSchema;
  } 
  else if (field("job_type_command").toBool() ||
           field("job_type_command_salome").toBool())
  {
    return BL::CreateJobWizard::Page_Command_Main_Definitions;
  }
  else
  {
    return BL::CreateJobWizard::Page_PythonSalome_Main_Definitions;
  }
}

BL::YACSSchemaPage::YACSSchemaPage(QWidget * parent)
: QWizardPage(parent)
{
  setTitle("Configure YACS Execution");

  QLabel *label = new QLabel("In this step you have to configure your YACS execution");
  label->setWordWrap(true);

  QGroupBox * files_param_box = new QGroupBox("YACS job files");
  QPushButton * yacs_file_button = new QPushButton(tr("Choose YACS Schema file"));
  connect(yacs_file_button, SIGNAL(clicked()), this, SLOT(choose_file()));
  _yacs_file_text = new QLineEdit(this);
  _yacs_file_text->setText("");
  registerField("yacs_file", _yacs_file_text);
  _yacs_file_text->setReadOnly(true);
  QPushButton * command_env_file_button = new QPushButton(tr("Choose an environnement file"));
  connect(command_env_file_button, SIGNAL(clicked()), this, SLOT(choose_env_file()));
  _line_env_file = new QLineEdit(this);
  registerField("env_yacs_file", _line_env_file);
  _line_env_file->setReadOnly(true);
  QPushButton * command_pre_command_button = new QPushButton(tr("Choose a pre processing script"));
  connect(command_pre_command_button, SIGNAL(clicked()),
          this, SLOT(choose_pre_command_file()));
  _line_pre_command = new QLineEdit(this);
  registerField("pre_yacs_file", _line_pre_command);
  _line_pre_command->setReadOnly(true);
  QGridLayout * files_layout = new QGridLayout;
  files_layout->addWidget(yacs_file_button, 0, 0);
  files_layout->addWidget(_yacs_file_text, 0, 1);
  files_layout->addWidget(command_env_file_button, 1, 0);
  files_layout->addWidget(_line_env_file, 1, 1);
  files_layout->addWidget(command_pre_command_button, 2, 0);
  files_layout->addWidget(_line_pre_command, 2, 1);
  files_param_box->setLayout(files_layout);

  QGroupBox * spec_param_box = new QGroupBox("YACS specific parameters");
  QLabel * label_dump =  new QLabel("Dump YACS state each secs (0 disable this feature)");
  QLabel * label_driver_options = new QLabel("YACS driver options - see YACS driver documentation.");
  QSpinBox * spin_dump = new QSpinBox(this);
  spin_dump->setMinimum(0);
  spin_dump->setMaximum(1000000);
  registerField("dump_yacs_state", spin_dump);
  QLineEdit* edit_yacs_driver_options = new QLineEdit(this);
  registerField("yacs_driver_options", edit_yacs_driver_options);
  QGridLayout * specific_layout = new QGridLayout;
  specific_layout->addWidget(label_dump, 0, 0);
  specific_layout->addWidget(spin_dump, 0, 1);
  specific_layout->addWidget(label_driver_options, 1, 0);
  specific_layout->addWidget(edit_yacs_driver_options, 1, 1);
  spec_param_box->setLayout(specific_layout);

  QVBoxLayout * main_layout = new QVBoxLayout;
  main_layout->addWidget(label);
  main_layout->addWidget(files_param_box);
  main_layout->addWidget(spec_param_box);

  setLayout(main_layout);
};

BL::YACSSchemaPage::~YACSSchemaPage()
{}

bool
BL::YACSSchemaPage::validatePage()
{
  bool return_value;
  QString yacs_file = field("yacs_file").toString();
  if (yacs_file != "")
  {
    return_value = true;
  }
  else
  {
    QMessageBox::warning(NULL, "YACS File Error", "Please choose a YACS File");
    return_value = false;
  }
  return return_value;
}

void
BL::YACSSchemaPage::choose_file()
{
  QString yacs_file = QFileDialog::getOpenFileName(this,
                                                   tr("Open YACS files"), "",
                                                   tr("XML (*.xml);;All Files (*)"));
  _yacs_file_text->setReadOnly(false);
  _yacs_file_text->setText(yacs_file);
  _yacs_file_text->setReadOnly(true);
}

void
BL::YACSSchemaPage::choose_env_file()
{
  QString env_file = QFileDialog::getOpenFileName(this,
                                                  tr("Open environnement file"), "",
                                                  tr("sh (*.sh);;All Files (*)"));
  _line_env_file->setReadOnly(false);
  _line_env_file->setText(env_file);
  _line_env_file->setReadOnly(true);
}

void
BL::YACSSchemaPage::choose_pre_command_file()
{
  QString pre_command_file = QFileDialog::getOpenFileName(this,
                                                    tr("Open script file"), "",
                                                    tr("All Files (*)"));
  _line_pre_command->setReadOnly(false);
  _line_pre_command->setText(pre_command_file);
  _line_pre_command->setReadOnly(true);
}

int 
BL::YACSSchemaPage::nextId() const
{
  return BL::CreateJobWizard::Page_Resource;
}

BL::CommandMainPage::CommandMainPage(QWidget * parent)
: QWizardPage(parent)
{
  setTitle("Define command job");
  QLabel *label = new QLabel("Enter the command that will be executed into the resource");
  label->setWordWrap(true);

  // command
  QPushButton * command_file_button = new QPushButton(tr("Choose a command file"));
  connect(command_file_button, SIGNAL(clicked()), this, SLOT(choose_command_file()));
  _line_command = new QLineEdit(this);
  registerField("command", _line_command);
  _line_command->setReadOnly(true);

  QPushButton * command_env_file_button = new QPushButton(tr("Choose an environnement file"));
  connect(command_env_file_button, SIGNAL(clicked()), this, SLOT(choose_env_file()));
  _line_env_file = new QLineEdit(this);
  registerField("env_command_file", _line_env_file);
  _line_env_file->setReadOnly(true);

  QPushButton * command_pre_command_button = new QPushButton(tr("Choose a pre processing script"));
  connect(command_pre_command_button, SIGNAL(clicked()),
          this, SLOT(choose_pre_command_file()));
  _line_pre_command = new QLineEdit(this);
  registerField("pre_command_file", _line_pre_command);
  _line_pre_command->setReadOnly(true);

  QGridLayout *layout = new QGridLayout;
  layout->addWidget(command_file_button, 0, 0);
  layout->addWidget(_line_command, 0, 1);
  layout->addWidget(command_env_file_button, 1, 0);
  layout->addWidget(_line_env_file, 1, 1);
  layout->addWidget(command_pre_command_button, 2, 0);
  layout->addWidget(_line_pre_command, 2, 1);

  QVBoxLayout * main_layout = new QVBoxLayout;
  main_layout->addWidget(label);
  main_layout->insertLayout(-1, layout);
  setLayout(main_layout);
};

BL::CommandMainPage::~CommandMainPage()
{}

void
BL::CommandMainPage::choose_command_file()
{
  QString command_file = QFileDialog::getOpenFileName(this,
                                                      tr("Open command file"), "",
                                                      tr("sh (*.sh);;All Files (*)"));
  _line_command->setReadOnly(false);
  _line_command->setText(command_file);
  _line_command->setReadOnly(true);
}

void
BL::CommandMainPage::choose_env_file()
{
  QString env_file = QFileDialog::getOpenFileName(this,
                                                  tr("Open environnement file"), "",
                                                  tr("sh (*.sh);;All Files (*)"));
  _line_env_file->setReadOnly(false);
  _line_env_file->setText(env_file);
  _line_env_file->setReadOnly(true);
}

void
BL::CommandMainPage::choose_pre_command_file()
{
  QString pre_command_file = QFileDialog::getOpenFileName(this,
                                                    tr("Open script file"), "",
                                                    tr("All Files (*)"));
  _line_pre_command->setReadOnly(false);
  _line_pre_command->setText(pre_command_file);
  _line_pre_command->setReadOnly(true);
}

bool
BL::CommandMainPage::validatePage()
{
  QString command = field("command").toString();
  if (command == "")
  {
    QMessageBox::warning(NULL, "Command Error", "Please enter a command");
    return false;
  }

  return true;
}

int 
BL::CommandMainPage::nextId() const
{
  return BL::CreateJobWizard::Page_Resource;
}

BatchParametersPage::BatchParametersPage(QWidget * parent, SALOMEServices * salome_services)
: QWizardPage(parent),
  ui(new Ui::ResourceRequirementsWizardPage),
  _salome_services(salome_services),
  resource_choosed()
{
  ui->setupUi(this);

  registerField("duration_hour", ui->spin_duration_hour);
  registerField("duration_min", ui->spin_duration_min);
  registerField("mem_value", ui->spin_memory);
  registerField("proc_value", ui->spin_proc);
  registerField("node_value", ui->spin_node);
  registerField("exclusive", ui->check_exclusive);
  registerField("default_time", ui->rb_default_time);
  registerField("user_time", ui->rb_user_time);
  registerField("default_mem", ui->rb_default_mem);
  registerField("user_mem", ui->rb_user_mem);

  ui->combo_memory_unit->insertItem(ui->combo_memory_unit->count(), "MB", MB);
  ui->combo_memory_unit->insertItem(ui->combo_memory_unit->count(), "GB", GB);
  setMemUnit(GB);

  ui->combo_memory_req_type->insertItem(ui->combo_memory_req_type->count(),
                                        "per node", Job::MEM_PER_NODE);
  ui->combo_memory_req_type->insertItem(ui->combo_memory_req_type->count(),
                                        "per core", Job::MEM_PER_CPU);

  connect(ui->spin_duration_hour, SIGNAL(valueChanged(int)), this, SLOT(timeChanged()));
  connect(ui->spin_duration_min, SIGNAL(valueChanged(int)), this, SLOT(timeChanged()));
  connect(ui->spin_memory, SIGNAL(valueChanged(int)), this, SLOT(memChanged()));
  connect(ui->combo_memory_unit, SIGNAL(currentIndexChanged(int)), this, SLOT(memChanged()));
  connect(ui->combo_memory_req_type, SIGNAL(currentIndexChanged(int)), this, SLOT(memChanged()));
};

BatchParametersPage::~BatchParametersPage()
{
  delete ui;
}

void
BatchParametersPage::initializePage()
{
  string f_resource_choosed = field("resource_choosed").toString().toUtf8().constData();
  if (f_resource_choosed != resource_choosed)
  {
    resource_choosed = f_resource_choosed;
    // If choosed resource has a SLURM batch manager, activate option "memory per cpu"
    ResourceDescr resource_descr = _salome_services->getResourceDescr(resource_choosed);
    if (resource_descr.batch == "slurm")
    {
      ui->combo_memory_req_type->setEnabled(true);
    }
    else
    {
      ui->combo_memory_req_type->setEnabled(false);
      setMemReqType(Job::MEM_PER_NODE);
    }
  }
}

BatchParametersPage::MemUnit
BatchParametersPage::getMemUnit() const
{
  int idx = ui->combo_memory_unit->currentIndex();
  return (MemUnit)(ui->combo_memory_unit->itemData(idx).toInt());
}

void
BatchParametersPage::setMemUnit(MemUnit mem_unit)
{
  ui->combo_memory_unit->setCurrentIndex(ui->combo_memory_unit->findData(mem_unit));
}

Job::MemReqType
BatchParametersPage::getMemReqType() const
{
  int idx = ui->combo_memory_req_type->currentIndex();
  return (Job::MemReqType)(ui->combo_memory_req_type->itemData(idx).toInt());
}

void
BatchParametersPage::setMemReqType(Job::MemReqType mem_req_type)
{
  ui->combo_memory_req_type->setCurrentIndex(ui->combo_memory_req_type->findData(mem_req_type));
}

void
BatchParametersPage::timeChanged()
{
  if (ui->spin_duration_hour->value() == 0 && ui->spin_duration_min->value() == 0)
    ui->rb_default_time->setChecked(true);
  else
    ui->rb_user_time->setChecked(true);
}

void
BatchParametersPage::memChanged()
{
  ui->rb_user_mem->setChecked(true);
}

void
BatchParametersPage::cleanupPage()
{
}

int 
BatchParametersPage::nextId() const
{
  return CreateJobWizard::Page_Files;
}

BL::COORM_BatchParametersPage::COORM_BatchParametersPage(QWidget * parent, BL::SALOMEServices * salome_services)
: QWizardPage(parent)
{
  setTitle("Enter COORM Parameters");
  resource_choosed = "";

  _salome_services = salome_services;

  QLabel *label = new QLabel("In this step you define the parameters for COORM");
  label->setWordWrap(true);
  QVBoxLayout * main_layout = new QVBoxLayout;
  main_layout->addWidget(label);

  // coorm_batch_directory
  QLabel * label_directory = new QLabel("Remote work directory: ");
  QLineEdit * line_directory = new QLineEdit(this);
  registerField("coorm_batch_directory", line_directory);

  // launcher_file
  QPushButton * launcher_file_button = new QPushButton(tr("Choose a launcher file"));
  connect(launcher_file_button, SIGNAL(clicked()), this, SLOT(choose_launcher_file()));
  _launcher_file_text = new QLineEdit(this);
  _launcher_file_text->setText("");
  registerField("launcher_file", _launcher_file_text);
  _launcher_file_text->setReadOnly(true);

  // launcher_args
  QLabel * launcher_args_label = new QLabel("Launcher args:");
  QLineEdit * launcher_args_text = new QLineEdit(this);
  registerField("launcher_args", launcher_args_text);

  QGridLayout * layout = new QGridLayout;
  layout->addWidget(label_directory, 0, 0);
  layout->addWidget(line_directory, 0, 1);
  layout->addWidget(launcher_file_button, 1, 0);
  layout->addWidget(_launcher_file_text, 1, 1);
  layout->addWidget(launcher_args_label, 2, 0);
  layout->addWidget(launcher_args_text, 2, 1);

  main_layout->insertLayout(-1, layout);

  setLayout(main_layout);
};

BL::COORM_BatchParametersPage::~COORM_BatchParametersPage()
{}

bool
BL::COORM_BatchParametersPage::validatePage()
{
  QString coorm_batch_directory = field("coorm_batch_directory").toString();
  if (coorm_batch_directory == "")
  {
    QMessageBox::warning(NULL, "Batch Directory Error", "Please enter a batch directory");
    return false;
  }

  QString launcher_file = field("launcher_file").toString();
  if (launcher_file == "")
  {
    QMessageBox::warning(NULL, "Launcher File Error", "Please enter a launcher file");
    return false;
  }

  return true;
}

int
BL::COORM_BatchParametersPage::nextId() const
{
  return BL::CreateJobWizard::Page_Files;
}

void
BL::COORM_BatchParametersPage::choose_launcher_file()
{
  QString launcher_file = QFileDialog::getOpenFileName(this,
						   tr("Open launcher files"), "",
						   tr("Py (*.py);;All Files (*)"));
  _launcher_file_text->setReadOnly(false);
  _launcher_file_text->setText(launcher_file);
  _launcher_file_text->setReadOnly(true);
}

void BL::COORM_BatchParametersPage::cleanupPage()
{}

void
BL::COORM_BatchParametersPage::initializePage()
{
  QString f_resource_choosed = field("resource_choosed").toString();
  if (f_resource_choosed != resource_choosed)
  {
    resource_choosed = f_resource_choosed;
    // If choosed resource has a working_directory set
    // Generates a default remote working directory
    BL::ResourceDescr resource_descr = _salome_services->getResourceDescr(resource_choosed.toUtf8().constData());
    QString res_work_dir = resource_descr.working_directory.c_str();
    if (res_work_dir != "")
    {
      time_t rawtime;
      time(&rawtime);
      std::string launch_date = ctime(&rawtime);
      for (int i = 0; i < launch_date.size(); i++)
        if (launch_date[i] == '/' ||
            launch_date[i] == '-' ||
            launch_date[i] == ':' ||
            launch_date[i] == ' ')
          launch_date[i] = '_';
      launch_date.erase(--launch_date.end()); // Last caracter is a \n
      QString date = launch_date.c_str();
      setField("coorm_batch_directory", res_work_dir + "/" + date);
    }
  }
}

FilesPage::FilesPage(CreateJobWizard * parent, SALOMEServices * salome_services)
: QWizardPage(parent),
  ui(new Ui::FilesWizardPage)
{
  ui->setupUi(this);

  resource_choosed = "";
  _salome_services = salome_services;

  connect(ui->add_input_files_button, SIGNAL(clicked()), this, SLOT(choose_input_files()));
  connect(ui->remove_input_files_button, SIGNAL(clicked()), this, SLOT(remove_input_files()));
  connect(ui->input_files_list, SIGNAL(itemSelectionChanged()), this, SLOT(input_itemSelectionChanged()));
  connect(ui->add_output_files_button, SIGNAL(clicked()), this, SLOT(add_output_file()));
  connect(ui->remove_output_files_button, SIGNAL(clicked()), this, SLOT(remove_output_files()));
  connect(ui->output_files_list, SIGNAL(itemSelectionChanged()), this, SLOT(output_itemSelectionChanged()));
  connect(ui->button_choose_result_dir, SIGNAL(clicked()), this, SLOT(choose_local_directory()));

  registerField("batch_directory", ui->line_remote_working_dir);
  registerField("result_directory", ui->line_result_dir);

  // Default result directory is home directory (if we found it)
  ui->line_result_dir->setText(QDir::homePath());

  parent->setFilesList(ui->input_files_list, ui->output_files_list);

  // Check for warning messages
  ui->label_warning_icon->setPixmap(QIcon::fromTheme("dialog-error").pixmap(16, 16));
  connect(ui->line_remote_working_dir, SIGNAL(textChanged(const QString &)), this, SIGNAL(completeChanged()));
  connect(ui->line_result_dir, SIGNAL(textChanged(const QString &)), this, SIGNAL(completeChanged()));
};

FilesPage::~FilesPage()
{
  delete ui;
}

void
FilesPage::initializePage()
{
  QString f_resource_choosed = field("resource_choosed").toString();
  if (f_resource_choosed != resource_choosed)
  {
    resource_choosed = f_resource_choosed;
    // If choosed resource has a working_directory set
    // Generates a default remote working directory
    BL::ResourceDescr resource_descr = _salome_services->getResourceDescr(resource_choosed.toUtf8().constData());
    QString res_work_dir = resource_descr.working_directory.c_str();
    if (res_work_dir != "")
    {
      time_t rawtime;
      time(&rawtime);
      std::string launch_date = ctime(&rawtime);
      for (int i = 0; i < launch_date.size(); i++)
        if (launch_date[i] == '/' ||
            launch_date[i] == '-' ||
            launch_date[i] == ':' ||
            launch_date[i] == ' ')
          launch_date[i] = '_';
      launch_date.erase(--launch_date.end()); // Last caracter is a \n
      QString date = launch_date.c_str();
      setField("batch_directory", res_work_dir + "/" + date);
    }
  }
}

bool
FilesPage::isComplete() const
{
  QString warn_msg;
  if (field("batch_directory").toString().isEmpty())
    warn_msg = "Remote working directory is mandatory.";
  if (field("result_directory").toString().isEmpty() && ui->output_files_list->count() != 0)
  {
    if (!warn_msg.isEmpty()) warn_msg += "\n";
    warn_msg += "Result directory is mandatory if there are output files.";
  }

  ui->label_warning_text->setText(warn_msg);
  if (warn_msg.isEmpty())
  {
    ui->label_warning_icon->hide();
    return true;
  }
  else
  {
    ui->label_warning_icon->show();
    return false;
  }
}

void
FilesPage::choose_input_files()
{
  // We need to be able to select both files and folders.
  // Standard QFileDialog cannot do it.
  QFileDialog w(this, tr("Select input files"),
              "", tr("All files and folders(*)")) ;
  w.setOption(QFileDialog::DontUseNativeDialog,true);
  QListView *l = w.findChild<QListView*>("listView");
  if (l)
  {
    l->setSelectionMode(QAbstractItemView::MultiSelection);
  }
  QTreeView *t = w.findChild<QTreeView*>();
  if (t)
  {
    t->setSelectionMode(QAbstractItemView::MultiSelection);
  }
  if(w.exec())
  {
    QStringList files = w.selectedFiles();
    for (int i = 0; i < files.size(); ++i)
    {
      if (ui->input_files_list->findItems(files.at(i), Qt::MatchFixedString).size() == 0)
        ui->input_files_list->addItem(files.at(i));
    }
  }
}

void
FilesPage::choose_local_directory()
{
  QString dir = QFileDialog::getExistingDirectory(this, tr("Choose local result directory"),
                                                 "",
                                                 QFileDialog::ShowDirsOnly
                                                 | QFileDialog::DontResolveSymlinks);

  if (dir != "")
    ui->line_result_dir->setText(dir);
}

void 
FilesPage::remove_input_files()
{
  QList<QListWidgetItem *> list = ui->input_files_list->selectedItems();
  for (int i = 0; i < list.size(); ++i)
  {
    int row = ui->input_files_list->row( list.at(i) );
    delete ui->input_files_list->takeItem(row);
  }
}

void 
FilesPage::input_itemSelectionChanged()
{
  if (ui->input_files_list->selectedItems().size() > 0)
    ui->remove_input_files_button->setEnabled(true);
  else
    ui->remove_input_files_button->setEnabled(false);
}

void
FilesPage::add_output_file()
{
  QListWidgetItem * new_item = new QListWidgetItem("TO EDIT!");
  new_item->setFlags(Qt::ItemIsSelectable|Qt::ItemIsEditable|Qt::ItemIsUserCheckable|Qt::ItemIsEnabled);
  ui->output_files_list->addItem(new_item);
  emit completeChanged();
}

void 
FilesPage::remove_output_files()
{
  QList<QListWidgetItem *> list = ui->output_files_list->selectedItems();
  for (int i = 0; i < list.size(); ++i)
  {
    int row = ui->output_files_list->row( list.at(i) );
    delete ui->output_files_list->takeItem(row);
  }
  emit completeChanged();
}

void 
FilesPage::output_itemSelectionChanged()
{
  if (ui->output_files_list->selectedItems().size() > 0)
    ui->remove_output_files_button->setEnabled(true);
  else
    ui->remove_output_files_button->setEnabled(false);
}

int 
FilesPage::nextId() const
{
  return BL::CreateJobWizard::Page_Advanced;
}

BL::ConclusionPage::ConclusionPage(QWidget * parent)
: QWizardPage(parent)
{
  setTitle("Job definition is finished");
  QCheckBox * check_box =  new QCheckBox("Start job after creation");
  registerField("start_job", check_box);
  QVBoxLayout * main_layout = new QVBoxLayout;
  main_layout->addWidget(check_box);
  setLayout(main_layout);
};

BL::ConclusionPage::~ConclusionPage()
{}

bool
BL::ConclusionPage::validatePage()
{
  return true;
}

int 
BL::ConclusionPage::nextId() const
{
  return -1;
}

BL::ResourcePage::ResourcePage(BL::CreateJobWizard * parent, BL::SALOMEServices * salome_services)
: QWizardPage(parent)
{
  _salome_services = salome_services;
  setTitle("Select a Resource");

  QLabel * main_label = new QLabel("In this step you select the resource of your job");
  main_label->setWordWrap(true);

  // input_Resource
  QGroupBox * resource_group_box = new QGroupBox("Resource List");
  _resource_list = new JM::ResourceCatalog(this, _salome_services, true);
  connect(_resource_list->getQListWidget(), SIGNAL(itemClicked(QListWidgetItem*)), this, SLOT(itemSelected(QListWidgetItem*)));

  QVBoxLayout * resource_list_layout = new QVBoxLayout();
  resource_list_layout->addWidget(_resource_list);
  resource_group_box->setLayout(resource_list_layout);

  QLabel * resource_label = new QLabel("Resource selected: ");
  _resource_choosed = new QLineEdit();
  _resource_choosed->setText("");
  _resource_choosed->setReadOnly(true);
  registerField("resource_choosed", _resource_choosed);

  QLabel * bqLabel = new QLabel("Batch Queue (could be optional):");
  QLineEdit * _bqLineEdit = new QLineEdit(this);
  registerField("batch_queue", _bqLineEdit);

  QLabel * bpLabel = new QLabel("Batch Partition (could be optional):");
  QLineEdit * _bpLineEdit = new QLineEdit(this);
  registerField("batch_partition", _bpLineEdit);

  _ll_label = new QLabel("LoadLeveler JobType:", this);
  _ll_value = new QLineEdit(this);
  registerField("ll_jobtype", _ll_value);
  _ll_label->hide();
  _ll_value->hide();

  _main_layout = new QGridLayout;
  _main_layout->addWidget(resource_group_box, 0, 0, 1, -1);
  _main_layout->addWidget(resource_label, 1, 0);
  _main_layout->addWidget(_resource_choosed, 1, 1);
  _main_layout->addWidget(bqLabel, 2, 0);
  _main_layout->addWidget(_bqLineEdit, 2, 1);
  _main_layout->addWidget(bpLabel, 3, 0);
  _main_layout->addWidget(_bpLineEdit, 3, 1);
  setLayout(_main_layout);

};

BL::ResourcePage::~ResourcePage()
{}

void
BL::ResourcePage::initializePage()
{
  if (field("ll_jobtype").toString() != "")
  {
    _main_layout->addWidget(_ll_label, 3, 0);
    _main_layout->addWidget(_ll_value, 3, 1);
    _ll_label->show();
    _ll_value->show();
  }

  // Initialize resource_choosed with first resource in resource list
  if (field("resource_choosed").toString() == "")
  {
    std::list<std::string> resource_list = _salome_services->getResourceList(true);
    std::list<std::string>::iterator it = resource_list.begin();
    if (it != resource_list.end())
    {
      QString first_resource((*it).c_str());
      setField("resource_choosed", first_resource);
    }
  }
}

bool
BL::ResourcePage::validatePage()
{
  QString resource_choosed = field("resource_choosed").toString();
  if (resource_choosed == "")
  {
    QMessageBox::warning(NULL, "Resource Error", "Please choose a resource");
    return false;
  }

  BL::ResourceDescr resource_descr = _salome_services->getResourceDescr(resource_choosed.toUtf8().constData());
  std::string batch = resource_descr.batch.c_str();
  if (batch == "ll")
  {
    QString ll_jobtype = field("ll_jobtype").toString();
    if (ll_jobtype == "")
    {
      QMessageBox::warning(NULL, "LoadLeveler Error", "Please define a LoadLeveler JobType");
      return false;
    }
  }
  return true;
}

void 
BL::ResourcePage::itemSelected(QListWidgetItem * item)
{
  _resource_choosed->setReadOnly(false);
  _resource_choosed->setText(item->text());
  _resource_choosed->setReadOnly(true);

  //Specific parameters for LoadLeveler
  BL::ResourceDescr resource_descr = _salome_services->getResourceDescr(item->text().toUtf8().constData());
  std::string batch = resource_descr.batch.c_str();
  if (batch == "ll")
  {
    _main_layout->addWidget(_ll_label, 3, 0);
    _main_layout->addWidget(_ll_value, 3, 1);
    _ll_label->show();
    _ll_value->show();
  }
  else
  {
    _main_layout->removeWidget(_ll_value);
    _main_layout->removeWidget(_ll_label);
    _ll_label->hide();
    _ll_value->hide();
  }
}

int 
BL::ResourcePage::nextId() const
{
  BL::ResourceDescr resource_descr = _salome_services->getResourceDescr(_resource_choosed->text().toUtf8().constData());
  std::string batch = resource_descr.batch.c_str();
  if (batch == "coorm")
  {
	  return BL::CreateJobWizard::Page_COORM_BatchParameters;
  }
  else
  {
	  return BL::CreateJobWizard::Page_BatchParameters;
  }
}

BL::PythonSalomeMainPage::PythonSalomeMainPage(QWidget * parent)
: QWizardPage(parent)
{
  setTitle("Define a Python script in SALOME job");
  QLabel *label = new QLabel("Enter the Python script that will be executed into the resource");
  label->setWordWrap(true);

  // PythonSalome
  QPushButton * PythonSalome_file_button = new QPushButton(tr("Choose a Python file"));
  connect(PythonSalome_file_button, SIGNAL(clicked()), this, SLOT(choose_PythonSalome_file()));
  _line_PythonSalome = new QLineEdit(this);
  registerField("PythonSalome", _line_PythonSalome);
  _line_PythonSalome->setReadOnly(true);

  QPushButton * PythonSalome_env_file_button = new QPushButton(tr("Choose an environnement file"));
  connect(PythonSalome_env_file_button, SIGNAL(clicked()), this, SLOT(choose_env_file()));
  _line_env_file = new QLineEdit(this);
  registerField("env_PythonSalome_file", _line_env_file);
  _line_env_file->setReadOnly(true);

  QPushButton * command_pre_command_button = new QPushButton(tr("Choose a pre processing script"));
  connect(command_pre_command_button, SIGNAL(clicked()),
          this, SLOT(choose_pre_command_file()));
  _line_pre_command = new QLineEdit(this);
  registerField("pre_PythonSalome_file", _line_pre_command);
  _line_pre_command->setReadOnly(true);

  QGridLayout *layout = new QGridLayout;
  layout->addWidget(PythonSalome_file_button, 0, 0);
  layout->addWidget(_line_PythonSalome, 0, 1);
  layout->addWidget(PythonSalome_env_file_button, 1, 0);
  layout->addWidget(_line_env_file, 1, 1);
  layout->addWidget(command_pre_command_button, 2, 0);
  layout->addWidget(_line_pre_command, 2, 1);

  QVBoxLayout * main_layout = new QVBoxLayout;
  main_layout->addWidget(label);
  main_layout->insertLayout(-1, layout);
  setLayout(main_layout);
};

BL::PythonSalomeMainPage::~PythonSalomeMainPage()
{}

void
BL::PythonSalomeMainPage::choose_PythonSalome_file()
{
  QString PythonSalome_file = QFileDialog::getOpenFileName(this,
						      tr("Open Python script file"), "",
						      tr("py (*.py);;All Files (*)"));
  _line_PythonSalome->setReadOnly(false);
  _line_PythonSalome->setText(PythonSalome_file);
  _line_PythonSalome->setReadOnly(true);
}

void
BL::PythonSalomeMainPage::choose_env_file()
{
  QString env_file = QFileDialog::getOpenFileName(this,
						      tr("Open environnement file"), "",
						      tr("sh (*.sh);;All Files (*)"));
  _line_env_file->setReadOnly(false);
  _line_env_file->setText(env_file);
  _line_env_file->setReadOnly(true);
}

void
BL::PythonSalomeMainPage::choose_pre_command_file()
{
  QString pre_command_file = QFileDialog::getOpenFileName(this,
                                                    tr("Open script file"), "",
                                                    tr("All Files (*)"));
  _line_pre_command->setReadOnly(false);
  _line_pre_command->setText(pre_command_file);
  _line_pre_command->setReadOnly(true);
}

bool
BL::PythonSalomeMainPage::validatePage()
{
  QString PythonSalome = field("PythonSalome").toString();
  if (PythonSalome == "")
  {
    QMessageBox::warning(NULL, "Python script in SALOME Error", "Please enter a Python script");
    return false;
  }

  return true;
}

int 
BL::PythonSalomeMainPage::nextId() const
{
  return BL::CreateJobWizard::Page_Resource;
}



AdvancedParametersPage::AdvancedParametersPage(CreateJobWizard * parent)
: QWizardPage(parent),
  ui(new Ui::AdvancedParametersWizardPage)
{
  ui->setupUi(this);
  registerField("wckey", ui->line_wckey);
  registerField("extra_params", ui->text_extra_params, "plainText", "textChanged()");
};

AdvancedParametersPage::~AdvancedParametersPage()
{
  delete ui;
}

int
AdvancedParametersPage::nextId() const
{
  return BL::CreateJobWizard::Page_Conclusion;
}
