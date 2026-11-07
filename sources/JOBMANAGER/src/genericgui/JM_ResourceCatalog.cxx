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

#include "JM_ResourceCatalog.hxx"
#include "BL_Traces.hxx"
#include "JM_SalomeResource.hxx"
#include "JM_EditSalomeResource.hxx"

#include <QHBoxLayout>
#include <QListWidget>
#include <QPushButton>
#include <QVBoxLayout>

JM::ResourceCatalog::ResourceCatalog(QWidget *parent, BL::SALOMEServices * salome_services, bool batch_only)
: QWidget(parent),
  _batch_only(batch_only)
{
  DEBTRACE("Creating JM::ResourceCatalog");
  BL_ASSERT(parent);
  BL_ASSERT(salome_services);
  _parent = parent;
  _salome_services = salome_services;

  _refresh_button = new QPushButton("Refresh Resource List");
  _refresh_button->show();
  _resource_files_list = new QListWidget(this);
  _resource_files_list->setSelectionMode(QAbstractItemView::SingleSelection);
  std::list<std::string> resource_list = _salome_services->getResourceList(_batch_only);
  std::list<std::string>::iterator it;
  for (it = resource_list.begin(); it != resource_list.end(); it++)
  {
    std::string resource = *it;
    _resource_files_list->addItem(QString(resource.c_str()));
  }

  _show_button = new QPushButton("Show");
  _show_button->setEnabled(false);
  _edit_button = new QPushButton("Edit");
  _edit_button->setEnabled(false);
  _add_button = new QPushButton("Add");
  _remove_button = new QPushButton("Remove");
  _remove_button->setEnabled(false);

  QHBoxLayout * button_layout = new QHBoxLayout(this);
  button_layout->addWidget(_show_button);
  button_layout->addWidget(_edit_button);
  button_layout->addWidget(_add_button);
  button_layout->addWidget(_remove_button);
  QWidget * layout_widget = new QWidget(this);
  layout_widget->setLayout(button_layout);

  QVBoxLayout * mainLayout = new QVBoxLayout(this);
  mainLayout->addWidget(_refresh_button);
  mainLayout->addWidget(_resource_files_list);
  mainLayout->addWidget(layout_widget);
  setLayout(mainLayout);

  // Buttons
  connect(_refresh_button, SIGNAL(clicked()), this, SLOT(refresh_resource_list()));
  connect(_show_button, SIGNAL(clicked()), this, SLOT(show_button()));
  connect(_edit_button, SIGNAL(clicked()), this, SLOT(edit_button()));
  connect(_add_button, SIGNAL(clicked()), this, SLOT(add_button()));
  connect(_remove_button, SIGNAL(clicked()), this, SLOT(remove_button()));
  // Double click on an item
  connect(_resource_files_list, SIGNAL(itemDoubleClicked(QListWidgetItem*)), this, SLOT(item_choosed(QListWidgetItem*)));
  // Selection management
  connect(_resource_files_list, SIGNAL(itemSelectionChanged()), this, SLOT(buttons_management()));
}

JM::ResourceCatalog::~ResourceCatalog()
{
  DEBTRACE("Destroying JM::ResourceCatalog");
}

QListWidget * 
JM::ResourceCatalog::getQListWidget()
{
  return _resource_files_list;
}

void
JM::ResourceCatalog::refresh_resource_list()
{
  _resource_files_list->clear();
  std::list<std::string> resource_list = _salome_services->getResourceList(_batch_only);
  std::list<std::string>::iterator it;
  for (it = resource_list.begin(); it != resource_list.end(); it++)
  {
    std::string resource = *it;
    _resource_files_list->addItem(QString(resource.c_str()));
  }
}

void
JM::ResourceCatalog::item_choosed(QListWidgetItem * item)
{
  DEBTRACE("JM::ResourceCatalog::item_choosed");
  JM::SalomeResource * resource_widget = new JM::SalomeResource(this,
                                                                _salome_services,
                                                                item->text().toUtf8().constData());
  resource_widget->exec();
  delete resource_widget;
}

void
JM::ResourceCatalog::buttons_management()
{
  QList<QListWidgetItem *> item_list = _resource_files_list->selectedItems();
  
  // Test if an item is selected
  if (item_list.size() == 0)
  {
    _show_button->setEnabled(false);
    _edit_button->setEnabled(false);
    _remove_button->setEnabled(false);
  }
  else
  {
    _show_button->setEnabled(true);
    _edit_button->setEnabled(true);
    _remove_button->setEnabled(true);
  }
}

void
JM::ResourceCatalog::show_button()
{
  QList<QListWidgetItem *> item_list = _resource_files_list->selectedItems();
  item_choosed(item_list.at(0));
}

void
JM::ResourceCatalog::add_button()
{
  JM::EditSalomeResource * resource_widget = new JM::EditSalomeResource(this,
                                                                        _salome_services);
  resource_widget->exec();
  delete resource_widget;
  refresh_resource_list();
}

void
JM::ResourceCatalog::remove_button()
{
  QList<QListWidgetItem *> item_list = _resource_files_list->selectedItems();
  QString item_name = item_list.at(0)->text();
  _salome_services->removeResource(item_name.toUtf8().constData());
  refresh_resource_list();
}

void
JM::ResourceCatalog::edit_button()
{
  QList<QListWidgetItem *> item_list = _resource_files_list->selectedItems();
  QString item_name = item_list.at(0)->text();
  JM::EditSalomeResource * resource_widget = new JM::EditSalomeResource(this,
                                                                        _salome_services,
                                                                        item_name.toUtf8().constData());
  resource_widget->exec();
  delete resource_widget;
  refresh_resource_list();
}
