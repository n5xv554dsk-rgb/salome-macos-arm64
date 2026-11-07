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

#include "BL_Buttons.hxx"

#include <QGridLayout>
#include <QGroupBox>
#include <QHBoxLayout>
#include <QPushButton>

BL::Buttons::Buttons(QWidget * parent) : QWidget(parent)
{
  DEBTRACE("Creating BL::Buttons");

  _create_button      = new QPushButton("Create", this);
  _start_button       = new QPushButton("Start", this);
  _get_results_button = new QPushButton("Get Results", this);


  _stop_button       = new QPushButton("Stop", this);
  _delete_button     = new QPushButton("Delete", this);
  _restart_button    = new QPushButton("Restart", this);
  _edit_clone_button = new QPushButton("Edit/Clone", this);

  _refresh_button    = new QPushButton("Refresh Jobs", this);

  QGroupBox * main_buttons = new QGroupBox(this);
  main_buttons->setTitle("Main");
  QHBoxLayout *mainLayout = new QHBoxLayout;
  mainLayout->addWidget(_create_button);
  mainLayout->addWidget(_start_button);
  mainLayout->addWidget(_get_results_button);
  main_buttons->setLayout(mainLayout);

  QGroupBox * manage_buttons = new QGroupBox(this);
  manage_buttons->setTitle("Management");
  QHBoxLayout *manageLayout = new QHBoxLayout;
  manageLayout->addWidget(_stop_button);
  manageLayout->addWidget(_delete_button);
  manageLayout->addWidget(_restart_button);
  manageLayout->addWidget(_edit_clone_button);
  manage_buttons->setLayout(manageLayout);

  QGroupBox * refresh_buttons = new QGroupBox(this);
  refresh_buttons->setTitle("Refresh");
  QHBoxLayout *refreshLayout = new QHBoxLayout;
  refreshLayout->addWidget(_refresh_button);
  refresh_buttons->setLayout(refreshLayout);

  QGridLayout * gridLayout = new QGridLayout;
  gridLayout->addWidget(main_buttons, 0 ,0);
  gridLayout->addWidget(manage_buttons, 0 ,1);
  gridLayout->addWidget(refresh_buttons, 0 , 2);
  setLayout(gridLayout);
}

BL::Buttons::~Buttons()
{
  DEBTRACE("Destroying BL::Buttons");
}

void
BL::Buttons::setCreateButtonSlot(QObject * receiver, const char * name)
{
  connect(_create_button, SIGNAL(clicked()), receiver, name);
}

void
BL::Buttons::setEditCloneButtonSlot(QObject * receiver, const char * name)
{
  connect(_edit_clone_button, SIGNAL(clicked()), receiver, name);
}

void
BL::Buttons::setStartButtonSlot(QObject * receiver, const char * name)
{
  connect(_start_button, SIGNAL(clicked()), receiver, name);
}

void
BL::Buttons::setReStartButtonSlot(QObject * receiver, const char * name)
{
  connect(_restart_button, SIGNAL(clicked()), receiver, name);
}

void
BL::Buttons::setStopButtonSlot(QObject * receiver, const char * name)
{
  connect(_stop_button, SIGNAL(clicked()), receiver, name);
}

void
BL::Buttons::setDeleteButtonSlot(QObject * receiver, const char * name)
{
  connect(_delete_button, SIGNAL(clicked()), receiver, name);
}

void
BL::Buttons::setRefreshButtonSlot(QObject * receiver, const char * name)
{
  connect(_refresh_button, SIGNAL(clicked()), receiver, name);
}

void 
BL::Buttons::setGetResultsButtonSlot(QObject * receiver, const char * name)
{
  connect(_get_results_button, SIGNAL(clicked()), receiver, name);
}

void 
BL::Buttons::enable_edit_clone_button()
{
  _edit_clone_button->setEnabled(true);
}

void 
BL::Buttons::disable_edit_clone_button()
{
  _edit_clone_button->setEnabled(false);
}

void 
BL::Buttons::enable_start_button()
{
  _start_button->setEnabled(true);
}

void 
BL::Buttons::disable_start_button()
{
  _start_button->setEnabled(false);
}

void 
BL::Buttons::enable_restart_button()
{
  _restart_button->setEnabled(true);
}

void 
BL::Buttons::disable_restart_button()
{
  _restart_button->setEnabled(false);
}

void 
BL::Buttons::enable_stop_button()
{
  _stop_button->setEnabled(true);
}

void 
BL::Buttons::disable_stop_button()
{
  _stop_button->setEnabled(false);
}

void 
BL::Buttons::enable_delete_button()
{
  _delete_button->setEnabled(true);
}

void 
BL::Buttons::disable_delete_button()
{
  _delete_button->setEnabled(false);
}

void 
BL::Buttons::enable_get_results_button()
{
  _get_results_button->setEnabled(true);
}

void 
BL::Buttons::disable_get_results_button()
{
  _get_results_button->setEnabled(false);
}
