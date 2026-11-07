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

#ifndef _JM_RESOURCECATALOG_HXX_
#define _JM_RESOURCECATALOG_HXX_

#include "BL_SALOMEServices.hxx"

#include <QWidget>
#include <string>
#include <list>

class QListWidget;
class QListWidgetItem;
class QPushButton;

namespace JM 
{
  class ResourceCatalog: public QWidget
  {
    Q_OBJECT

    public:
      ResourceCatalog(QWidget *parent, BL::SALOMEServices * salome_services, bool batch_only);
      virtual ~ResourceCatalog();

      void get_infos();

      QListWidget * getQListWidget();

    public slots:
      void refresh_resource_list();
      void item_choosed(QListWidgetItem * item);
      void buttons_management();
      void show_button();
      void edit_button();
      void add_button();
      void remove_button();

    protected:
      QWidget* _parent;
      BL::SALOMEServices * _salome_services;

      QPushButton * _refresh_button;
      QPushButton * _show_button;
      QPushButton * _edit_button;
      QPushButton * _add_button;
      QPushButton * _remove_button;
      QListWidget * _resource_files_list;
      bool _batch_only;
  };
}

#endif


