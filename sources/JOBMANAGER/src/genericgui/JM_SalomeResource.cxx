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

#include "JM_SalomeResource.hxx"
#include "BL_Traces.hxx"

#include <QCheckBox>
#include <QGridLayout>
#include <QGroupBox>
#include <QLabel>
#include <QLineEdit>
#include <QListWidget>
#include <QVBoxLayout>

JM::SalomeResource::SalomeResource(QWidget *parent, BL::SALOMEServices * salome_services, 
                                   const std::string & resource_name)
: QDialog(parent, Qt::Window)
{
  DEBTRACE("Creating JM::SalomeResource");
  BL_ASSERT(parent);
  BL_ASSERT(salome_services);
  _parent = parent;
  _salome_services = salome_services;
  _resource_name = resource_name;

  // Widget code
  QGroupBox * main_groupBox = new QGroupBox("Main values");
  QLabel * name_label = new QLabel("Name:");
  _name_line = new QLineEdit(this);
  QLabel * hostname_label = new QLabel("Hostname:");
  _hostname_line = new QLineEdit(this);
  QLabel * protocol_label = new QLabel("Protocol:");
  _protocol_line = new QLineEdit(this);
  QLabel * username_label = new QLabel("Username:");
  _username_line = new QLineEdit(this);
  QLabel * applipath_label = new QLabel("Applipath:");
  _applipath_line = new QLineEdit(this);
  QLabel * componentList_label = new QLabel("Component List:");
  _componentList = new QListWidget(this);
  _componentList->setViewMode(QListView::ListMode);
  QLabel * working_directory_label = new QLabel("Working Directory:");
  _working_directory = new QLineEdit(this);
  _can_launch_batch_jobs = new QCheckBox("This resource can be used to launch batch jobs", this);
  _can_run_containers = new QCheckBox("This resource can be used to run interactive containers", this);
  QGridLayout * m_layout = new QGridLayout;
  m_layout->addWidget(name_label, 0, 0);
  m_layout->addWidget(_name_line, 0, 1);
  m_layout->addWidget(hostname_label, 1, 0);
  m_layout->addWidget(_hostname_line, 1, 1);
  m_layout->addWidget(protocol_label, 2, 0);
  m_layout->addWidget(_protocol_line, 2, 1);
  m_layout->addWidget(username_label, 3, 0);
  m_layout->addWidget(_username_line, 3, 1);
  m_layout->addWidget(applipath_label, 4, 0);
  m_layout->addWidget(_applipath_line, 4, 1);
  m_layout->addWidget(componentList_label, 5, 0);
  m_layout->addWidget(_componentList, 5, 1);
  m_layout->addWidget(working_directory_label, 6, 0);
  m_layout->addWidget(_working_directory, 6, 1);
  m_layout->addWidget(_can_launch_batch_jobs, 7, 1);
  m_layout->addWidget(_can_run_containers, 8, 1);
  main_groupBox->setLayout(m_layout);

  QGroupBox * config_groupBox = new QGroupBox("Configuration values");
  QLabel * os_label = new QLabel("OS:");
  _os_line = new QLineEdit(this);
  QLabel * mem_mb_label = new QLabel("Memory (mb):");
  _mem_mb_line = new QLineEdit(this);
  QLabel * cpu_clock_label = new QLabel("CPU Clock:");
  _cpu_clock_line = new QLineEdit(this);
  QLabel * nb_node_label = new QLabel("Nb node:");
  _nb_node_line = new QLineEdit(this);
  QLabel * nb_proc_per_node_label = new QLabel("Nb proc/node:");
  _nb_proc_per_node_line = new QLineEdit(this);
  QLabel * batch_label = new QLabel("Batch:");
  _batch_line = new QLineEdit(this);
  QLabel * mpiImpl_label = new QLabel("MPI impl:");
  _mpiImpl_line = new QLineEdit(this);
  QLabel * iprotocol_label = new QLabel("Internal proctocol:");
  _iprotocol_line = new QLineEdit(this);
  QGridLayout * c_layout = new QGridLayout;
  c_layout->addWidget(os_label, 0, 0);
  c_layout->addWidget(_os_line, 0, 1);
  c_layout->addWidget(mem_mb_label, 1, 0);
  c_layout->addWidget(_mem_mb_line, 1, 1);
  c_layout->addWidget(cpu_clock_label, 2, 0);
  c_layout->addWidget(_cpu_clock_line, 2, 1);
  c_layout->addWidget(nb_node_label, 3, 0);
  c_layout->addWidget(_nb_node_line, 3, 1);
  c_layout->addWidget(nb_proc_per_node_label, 4, 0);
  c_layout->addWidget(_nb_proc_per_node_line, 4, 1);
  c_layout->addWidget(batch_label, 5, 0);
  c_layout->addWidget(_batch_line, 5, 1);
  c_layout->addWidget(mpiImpl_label, 6, 0);
  c_layout->addWidget(_mpiImpl_line, 6, 1);
  c_layout->addWidget(iprotocol_label, 7, 0);
  c_layout->addWidget(_iprotocol_line, 7, 1);
  config_groupBox->setLayout(c_layout);

  // Main Layout
  QVBoxLayout * mainLayout = new QVBoxLayout(this);
  mainLayout->addWidget(main_groupBox);
  mainLayout->addWidget(config_groupBox);
  setLayout(mainLayout);

  setWindowTitle("Resource");
  get_infos();

  // Line cannot be changed
  _name_line->setCursorPosition(0);
  _hostname_line->setCursorPosition(0);
  _protocol_line->setCursorPosition(0);
  _username_line->setCursorPosition(0);
  _applipath_line->setCursorPosition(0);
  _os_line->setCursorPosition(0);
  _mem_mb_line->setCursorPosition(0);
  _cpu_clock_line->setCursorPosition(0);
  _nb_node_line->setCursorPosition(0);
  _nb_proc_per_node_line->setCursorPosition(0);
  _batch_line->setCursorPosition(0);
  _mpiImpl_line->setCursorPosition(0);
  _iprotocol_line->setCursorPosition(0);
  _working_directory->setCursorPosition(0);

  _name_line->setReadOnly(true);
  _hostname_line->setReadOnly(true);
  _protocol_line->setReadOnly(true);
  _username_line->setReadOnly(true);
  _applipath_line->setReadOnly(true);
  _os_line->setReadOnly(true);
  _mem_mb_line->setReadOnly(true);
  _cpu_clock_line->setReadOnly(true);
  _nb_node_line->setReadOnly(true);
  _nb_proc_per_node_line->setReadOnly(true);
  _batch_line->setReadOnly(true);
  _mpiImpl_line->setReadOnly(true);
  _iprotocol_line->setReadOnly(true);
  _working_directory->setReadOnly(true);
  _can_launch_batch_jobs->setEnabled(false);
  _can_run_containers->setEnabled(false);
}

JM::SalomeResource::~SalomeResource()
{
  DEBTRACE("Destroying JM::SalomeResource");
}

void
JM::SalomeResource::get_infos()
{
  BL::ResourceDescr resource_descr = _salome_services->getResourceDescr(_resource_name);

  _name_line->setText(QString(resource_descr.name.c_str()));
  _hostname_line->setText(QString(resource_descr.hostname.c_str()));
  _protocol_line->setText(QString(resource_descr.protocol.c_str()));
  _username_line->setText(QString(resource_descr.username.c_str()));
  _applipath_line->setText(QString(resource_descr.applipath.c_str()));
  _os_line->setText(QString(resource_descr.OS.c_str()));
  _batch_line->setText(QString(resource_descr.batch.c_str()));
  _mpiImpl_line->setText(QString(resource_descr.mpiImpl.c_str()));
  _iprotocol_line->setText(QString(resource_descr.iprotocol.c_str()));
  _working_directory->setText(QString(resource_descr.working_directory.c_str()));

  if (resource_descr.can_launch_batch_jobs)
    _can_launch_batch_jobs->setCheckState(Qt::Checked);
  else
    _can_launch_batch_jobs->setCheckState(Qt::Unchecked);

  if (resource_descr.can_run_containers)
    _can_run_containers->setCheckState(Qt::Checked);
  else
    _can_run_containers->setCheckState(Qt::Unchecked);

  QString value;
  _mem_mb_line->setText(value.setNum(resource_descr.mem_mb));
  _cpu_clock_line->setText(value.setNum(resource_descr.cpu_clock));
  _nb_node_line->setText(value.setNum(resource_descr.nb_node));
  _nb_proc_per_node_line->setText(value.setNum(resource_descr.nb_proc_per_node));

   std::list<std::string>::iterator it = resource_descr.componentList.begin();
   for(; it != resource_descr.componentList.end(); it++)
     _componentList->addItem(QString((*it).c_str()));
}
