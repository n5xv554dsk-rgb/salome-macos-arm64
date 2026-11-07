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

#include "BL_QModelManager.hxx"
#include "BL_JobsManager_QT.hxx"

#include <QStandardItemModel>

#ifdef WNT
#undef ERROR
#endif

BL::QModelManager::QModelManager(QObject * parent, BL::JobsManager_QT * jobs_manager) : QObject(parent)
{
  DEBTRACE("Creating BL::QModelManager");
  BL_ASSERT(jobs_manager);
  _jobs_manager = jobs_manager;

  _model = new QStandardItemModel(this);
  jobs_manager->set_model_manager(this);
  QStringList headers;
  headers << "Job Name" << "Type" << "State" << "Resource" << "Launcher Id";
  _model->setHorizontalHeaderLabels(headers);
}

BL::QModelManager::~QModelManager()
{
  DEBTRACE("Destroying BL::QModelManager");
}

QStandardItemModel *
BL::QModelManager::getModel()
{
  DEBTRACE("getModel BL::QModelManager called");

  return _model;
}

void
BL::QModelManager::new_job_added(const QString & name)
{
  DEBTRACE("Adding new job in the model manager");
  BL::Job * job = _jobs_manager->getJob(name.toUtf8().constData());
  QStandardItem * new_job_name = new QStandardItem(name);
  
  QStandardItem * new_job_type;
  if (job->getType() == BL::Job::YACS_SCHEMA)
    new_job_type = new QStandardItem("YACS_Schema");
  else if (job->getType() == BL::Job::COMMAND)
    new_job_type = new QStandardItem("Command");
  else if (job->getType() == BL::Job::COMMAND_SALOME)
    new_job_type = new QStandardItem("Command_Salome");
  else if (job->getType() == BL::Job::PYTHON_SALOME)
    new_job_type = new QStandardItem("Python_Salome");

  QStandardItem * new_job_state;
  if (job->getState() == BL::Job::CREATED)
    new_job_state = new QStandardItem("Created");
  else if (job->getState() == BL::Job::QUEUED)
    new_job_state = new QStandardItem("Queued");
  else if (job->getState() == BL::Job::RUNNING)
    new_job_state = new QStandardItem("Running");
  else if (job->getState() == BL::Job::PAUSED)
    new_job_state = new QStandardItem("Paused");
  else if (job->getState() == BL::Job::ERROR)
    new_job_state = new QStandardItem("Error");
  else if (job->getState() == BL::Job::FAILED)
    new_job_state = new QStandardItem("Failed");
  else if (job->getState() == BL::Job::NOT_CREATED)
    new_job_state = new QStandardItem("Not Created");
  else 
    new_job_state = new QStandardItem("Finished");

  QStandardItem * new_job_resource =  new QStandardItem(job->getResource().c_str());
  QString id_str;
  id_str.setNum(job->getSalomeLauncherId());
  QStandardItem * new_job_id =  new QStandardItem(id_str);

  int row = _model->rowCount();
  _model->setItem(row, 0, new_job_name);
  _model->setItem(row, 1, new_job_type);
  _model->setItem(row, 2, new_job_state);
  _model->setItem(row, 3, new_job_resource);
  _model->setItem(row, 4, new_job_id);
}

void
BL::QModelManager::job_state_changed(const QString & name)
{
  DEBTRACE("BL::QModelManager::job_state_changed received");

  BL::Job * job = _jobs_manager->getJob(name.toUtf8().constData());
  QList<QStandardItem *> item_list = _model->findItems(name);
  QStandardItem * job_state_item = _model->item(item_list.at(0)->row(), 2);

  if (job->getState() == BL::Job::CREATED)
    job_state_item->setText("Created");
  else if (job->getState() == BL::Job::QUEUED)
    job_state_item->setText("Queued");
  else if (job->getState() == BL::Job::RUNNING)
    job_state_item->setText("Running");
  else if (job->getState() == BL::Job::PAUSED)
    job_state_item->setText("Paused");
  else if (job->getState() == BL::Job::ERROR)
    job_state_item->setText("Error");
  else if (job->getState() == BL::Job::FAILED)
    job_state_item->setText("Failed");
  else if (job->getState() == BL::Job::NOT_CREATED)
    job_state_item->setText("Not Created");
  else 
    job_state_item->setText("Finished");
}

void
BL::QModelManager::delete_job(const QString & name)
{
  QList<QStandardItem *> list = _model->findItems(name);
  if (list.size() != 1)
  {
    DEBMSG("LIST SIZE IS :" << list.size());
    DEBMSG("FOR NAME :" << name.toUtf8().constData());
  }
  if (list.size() > 0)
    _model->removeRow(list[0]->row());
}
