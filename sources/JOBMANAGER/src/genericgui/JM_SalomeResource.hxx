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

#ifndef _JM_SALOMERESOURCE_HXX_
#define _JM_SALOMERESOURCE_HXX_

#include "BL_SALOMEServices.hxx"

#include <QDialog>
#include <string>

class QCheckBox;
class QLineEdit;
class QListWidget;

namespace JM 
{
  class SalomeResource: public QDialog
  {
    Q_OBJECT

    public:
      SalomeResource(QWidget *parent, BL::SALOMEServices * salome_services, 
		     const std::string & resource_name);
      virtual ~SalomeResource();

      void get_infos();

    protected:
      QWidget* _parent;
      BL::SALOMEServices * _salome_services;
      std::string _resource_name;

      // widget
      QLineEdit * _name_line;
      QLineEdit * _hostname_line;
      QLineEdit * _protocol_line;
      QLineEdit * _username_line;
      QLineEdit * _applipath_line;
      QListWidget * _componentList;
      QCheckBox * _can_launch_batch_jobs;
      QCheckBox * _can_run_containers;
      QLineEdit * _working_directory;
      QLineEdit * _os_line;
      QLineEdit * _mem_mb_line;
      QLineEdit * _cpu_clock_line;
      QLineEdit * _nb_node_line;
      QLineEdit * _nb_proc_per_node_line;
      QLineEdit * _batch_line;
      QLineEdit * _mpiImpl_line;
      QLineEdit * _iprotocol_line;
  };
}

#endif

