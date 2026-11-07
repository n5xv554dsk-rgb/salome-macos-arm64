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

#ifndef _BL_CREATEJOBWIZARD_HXX_
#define _BL_CREATEJOBWIZARD_HXX_

#include "BL_Traces.hxx"
#include "BL_SALOMEServices.hxx"
#include "JM_ResourceCatalog.hxx"

#include <QWizard>
#include <QWizardPage>
#include <string>
#include <list>

class QGridLayout;
class QLabel;
class QLineEdit;
class QListWidget;

namespace Ui {
  class ResourceRequirementsWizardPage;
  class FilesWizardPage;
  class AdvancedParametersWizardPage;
}

namespace BL {

  class JobsManager_QT;
  class JobNamePage;
  class BatchParametersPage;
  class CreateJobWizard: public QWizard
  {
    Q_OBJECT

    public:
      CreateJobWizard(BL::JobsManager_QT * jobs_manager, BL::SALOMEServices * salome_services);
      virtual ~CreateJobWizard();

      void setFilesList(QListWidget * input_files_list, QListWidget * output_files_list);

      void clone(const std::string & name);

    public slots:
      void end(int result);

    private:
      BL::JobsManager_QT * _jobs_manager;
      QListWidget * _input_files_list;
      QListWidget * _output_files_list;

      BL::JobNamePage * _job_name_page;
      BL::BatchParametersPage * _batch_parameters_page;
      BL::SALOMEServices * _salome_services;

    public:
      // Results
      std::string job_name;
      enum {YACS, COMMAND, PYTHON_SALOME, COMMAND_SALOME} job_type;

      std::string yacs_file;
      std::string command;
      std::string python_salome_file;

      std::string env_file;
      std::string pre_command;

      std::string batch_directory;

      // For COORM
      std::string coorm_batch_directory;

      std::string maximum_duration;
      long mem_limit;
      BL::Job::MemReqType mem_req_type;
      int nb_proc;
      int nb_node;
      bool exclusive;

      // Parameters for COORM
      std::string launcher_file;
      std::string launcher_args;

      std::string result_directory;
      std::list<std::string> input_files_list;
      std::list<std::string> output_files_list;

      std::string resource_choosed;
      std::string batch_queue;
      std::string batch_partition;
      std::string wckey;
      std::string extra_params;

      bool start_job;
      int dump_yacs_state;
      std::string ll_jobtype;
      std::string yacs_driver_options;

    public:
      enum {Page_JobName,
            Page_YACSSchema,
            Page_Command_Main_Definitions,
            Page_PythonSalome_Main_Definitions,
            Page_BatchParameters,
            Page_COORM_BatchParameters,
            Page_Files,
            Page_Resource,
            Page_Advanced,
            Page_Conclusion};
  };

  class JobNamePage: public QWizardPage
  {
    Q_OBJECT

    public:
      JobNamePage(QWidget * parent, BL::JobsManager_QT * jobs_manager);
      virtual ~JobNamePage();

      virtual bool validatePage();
      virtual int nextId() const ;
      virtual void cleanupPage() {}

    public slots:
      void yacs_schema_button(bool checked);
      void command_button(bool checked);
      void command_salome_button(bool checked);
      void python_salome_button(bool checked);

    private:
      BL::JobsManager_QT * _jobs_manager;
      QLabel * _explanation;

    public:
      bool _check_name;
  };

  class ConclusionPage: public QWizardPage
  {
    public:
      ConclusionPage(QWidget * parent);
      virtual ~ConclusionPage();

      virtual bool validatePage();
      virtual int nextId() const ;
      virtual void cleanupPage() {}
  };

  class BatchParametersPage: public QWizardPage
  {
    Q_OBJECT

    public:
      enum MemUnit {MB, GB};

      BatchParametersPage(QWidget * parent, BL::SALOMEServices * salome_services);
      virtual ~BatchParametersPage();

      virtual void initializePage();
      virtual int nextId() const;
      virtual void cleanupPage();

      MemUnit getMemUnit() const;
      void setMemUnit(MemUnit mem_unit);

      BL::Job::MemReqType getMemReqType() const;
      void setMemReqType(BL::Job::MemReqType mem_req_type);

    public slots:
      void timeChanged();
      void memChanged();

    private:
      Ui::ResourceRequirementsWizardPage * ui;
      BL::SALOMEServices * _salome_services;
      std::string resource_choosed;
  };

  // For COORM
  class COORM_BatchParametersPage: public QWizardPage
  {
    Q_OBJECT

    public:
      COORM_BatchParametersPage(QWidget * parent, BL::SALOMEServices * salome_services);
      virtual ~COORM_BatchParametersPage();

      virtual bool validatePage();
      virtual int nextId() const;
      virtual void cleanupPage();
      virtual void initializePage();

    public slots:
      void choose_launcher_file();

    private:
      BL::SALOMEServices * _salome_services;
      QLineEdit * _launcher_file_text;
      QString resource_choosed;
  };

  class FilesPage: public QWizardPage
  {
    Q_OBJECT

    public:
      FilesPage(BL::CreateJobWizard * parent, BL::SALOMEServices * salome_services);
      virtual ~FilesPage();

      virtual void initializePage();
      virtual int nextId() const;
      virtual bool isComplete() const;
      virtual void cleanupPage() {}

    public slots:
      void choose_input_files();
      void remove_input_files();
      void input_itemSelectionChanged();
      void choose_local_directory();

      void add_output_file();
      void remove_output_files();
      void output_itemSelectionChanged();

    private:
      Ui::FilesWizardPage * ui;
      BL::SALOMEServices * _salome_services;
      QString resource_choosed;
  };

  class ResourcePage: public QWizardPage
  {
    Q_OBJECT

    public:
      ResourcePage(BL::CreateJobWizard * parent, BL::SALOMEServices * salome_services);
      virtual ~ResourcePage();

      virtual int nextId() const;
      virtual bool validatePage();
      virtual void initializePage();
      virtual void cleanupPage() {}

    public slots:
      void itemSelected(QListWidgetItem * item);

    private:
      JM::ResourceCatalog * _resource_list;
      QLineEdit * _resource_choosed;
      BL::SALOMEServices * _salome_services;

      QLabel * _ll_label;
      QLineEdit * _ll_value;
      QGridLayout * _main_layout;
  };

  class YACSSchemaPage: public QWizardPage
  {
    Q_OBJECT

    public:
      YACSSchemaPage(QWidget * parent);
      virtual ~YACSSchemaPage();

      virtual bool validatePage();
      virtual int nextId() const ;
      virtual void cleanupPage() {}

    public slots:
      void choose_file();
      void choose_env_file();
      void choose_pre_command_file();

    private:
      QLineEdit * _yacs_file_text;
      QLineEdit * _line_env_file;
      QLineEdit * _line_pre_command;
  };

  class CommandMainPage: public QWizardPage
  {
    Q_OBJECT

    public:
      CommandMainPage(QWidget * parent);
      virtual ~CommandMainPage();

      virtual bool validatePage();
      virtual int nextId() const ;
      virtual void cleanupPage() {}

    public slots:
      void choose_command_file();
      void choose_env_file();
      void choose_pre_command_file();

    private:
      QLineEdit * _line_command;
      QLineEdit * _line_env_file;
      QLineEdit * _line_pre_command;
  };

  class PythonSalomeMainPage: public QWizardPage
  {
    Q_OBJECT

    public:
      PythonSalomeMainPage(QWidget * parent);
      virtual ~PythonSalomeMainPage();

      virtual bool validatePage();
      virtual int nextId() const ;
      virtual void cleanupPage() {}

    public slots:
      void choose_PythonSalome_file();
      void choose_env_file();
      void choose_pre_command_file();

    private:
      QLineEdit * _line_PythonSalome;
      QLineEdit * _line_env_file;
      QLineEdit * _line_pre_command;
  };

  class AdvancedParametersPage: public QWizardPage
  {
    Q_OBJECT

    public:
      AdvancedParametersPage(BL::CreateJobWizard * parent);
      virtual ~AdvancedParametersPage();

      virtual int nextId() const;
      virtual void cleanupPage() {}

    private:
      Ui::AdvancedParametersWizardPage * ui;

  };

}

#endif

