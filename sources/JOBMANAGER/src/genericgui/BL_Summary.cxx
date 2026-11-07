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

#include "BL_Summary.hxx"
#include "BL_Traces.hxx"

#include <QFormLayout>
#include <QLabel>
#include <QStandardItemModel>

BL::Summary::Summary(QWidget *parent, BL::JobsManager_QT * jobs_manager) : QWidget(parent)
{
  DEBTRACE("Creating BL::Summary");
  BL_ASSERT(parent);
  BL_ASSERT(jobs_manager);
  _parent = parent;
  _jobs_manager = jobs_manager;
  _model = NULL;

  
  QLabel * summary_jobs = new QLabel("Jobs Summary:");
  QLabel * total_label = new QLabel("Number of jobs:");
  _total_line = new QLabel;
  _total_line->setText("0");

  QLabel * created_label = new QLabel("Number of created jobs:");
  _created_line = new QLabel;
  _created_line->setText("0");

  QLabel * queued_label = new QLabel("Number of queued jobs:");
  _queued_line = new QLabel;
  _queued_line->setText("0");

  QLabel * running_label = new QLabel("Number of running jobs:");
  _running_line = new QLabel;
  _running_line->setText("0");

  QLabel * finished_label = new QLabel("Number of finished jobs:");
  _finished_line = new QLabel;
  _finished_line->setText("0");

  QFormLayout *mainLayout = new QFormLayout;
  mainLayout->insertRow(0, summary_jobs);
  mainLayout->insertRow(1, total_label, _total_line);
  mainLayout->insertRow(2, created_label, _created_line);
  mainLayout->insertRow(3, queued_label, _queued_line);
  mainLayout->insertRow(4, running_label, _running_line);
  mainLayout->insertRow(5, finished_label, _finished_line);
  setLayout(mainLayout);
}

BL::Summary::~Summary()
{
  DEBTRACE("Destroying BL::Summary");
}

void
BL::Summary::setModel(QStandardItemModel * model)
{
  DEBTRACE("Call setModel BL::Summary");
  BL_ASSERT(model);

  _model = model;
}

void 
BL::Summary::rowsInserted(const QModelIndex & parent, int start, int end)
{
  DEBTRACE("BL::Summary::rowsInserted slot");
  updateJobs();
}

void 
BL::Summary::rowsRemoved(const QModelIndex & parent, int start, int end)
{
  DEBTRACE("BL::Summary::rowsRemoved slot");
  updateJobs();
}

void 
BL::Summary::itemChanged(QStandardItem * item)
{
  updateJobs();
}

void
BL::Summary::updateJobs()
{
  // Total
  QVariant row_number = _model->rowCount();
  _total_line->setText(row_number.toString());

  // New count...
  _created_line->setText("0");
  _queued_line->setText("0");
  _running_line->setText("0");
  _finished_line->setText("0");

  int created_jobs = 0;
  int queued_jobs = 0;
  int running_jobs = 0;
  int finished_jobs = 0;
  std::map<std::string, BL::Job *> jobs = _jobs_manager->getJobs();
  std::map<std::string, BL::Job *>::iterator jobs_it;
  jobs_it = jobs.begin();
  for(; jobs_it != jobs.end(); jobs_it++)
  {
    BL::Job * job = jobs_it->second;
    BL::Job::State job_state = job->getState();
    if (job_state == BL::Job::CREATED)
      created_jobs++;
    if (job_state == BL::Job::QUEUED)
      queued_jobs++;
    if (job_state == BL::Job::RUNNING)
      running_jobs++;
    if (job_state == BL::Job::FINISHED)
      finished_jobs++;
  }

  // End
  _created_line->setText(QVariant(created_jobs).toString());
  _queued_line->setText(QVariant(queued_jobs).toString());
  _running_line->setText(QVariant(running_jobs).toString());
  _finished_line->setText(QVariant(finished_jobs).toString());
}
