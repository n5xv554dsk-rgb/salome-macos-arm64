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

#ifndef _JM_EDITSALOMERESOURCE_HXX_
#define _JM_EDITSALOMERESOURCE_HXX_

#include "BL_SALOMEServices.hxx"

#include <QDialog>
#include <string>

class QCheckBox;
class QComboBox;
class QLineEdit;
class QListWidget;
class QPushButton;
class QSpinBox;

namespace JM 
{
  class EditSalomeResource: public QDialog
  {
    Q_OBJECT

    public:
      EditSalomeResource(QWidget *parent,
                         BL::SALOMEServices * salome_services,
                         const std::string & resource_name = "");
      virtual ~EditSalomeResource();

      void get_infos();

    public slots:
      virtual void accept();
      void add_component();
      void remove_components();
      void itemSelectionChanged();

    protected:
      QWidget* _parent;
      BL::SALOMEServices * _salome_services;
      std::string _resource_name;

      // widget
      QLineEdit * _name_line;
      QLineEdit * _hostname_line;
      QLineEdit * _username_line;
      QLineEdit * _applipath_line;
      QListWidget * _componentList;
      QLineEdit * _os_line;

      QComboBox * _protocol_line;
      QComboBox * _iprotocol_line;
      QComboBox * _batch_line;
      QComboBox * _mpiImpl_line;

      QSpinBox * _mem_mb_line;
      QSpinBox * _cpu_clock_line;
      QSpinBox * _nb_node_line;
      QSpinBox * _nb_proc_per_node_line;

      QLineEdit * _working_directory;
      QCheckBox * _can_launch_batch_jobs;
      QCheckBox * _can_run_containers;

      QPushButton * _add_button;
      QPushButton * _remove_button;
  };
}

#endif

