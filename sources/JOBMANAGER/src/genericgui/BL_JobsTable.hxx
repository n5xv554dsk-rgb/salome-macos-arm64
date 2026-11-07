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

#ifndef _BL_JOBSTABLE_HXX_
#define _BL_JOBSTABLE_HXX_

#include <QTableView>

class QItemSelection;
class QModelIndex;

namespace BL
{
  class GenericGui;
  class JobsTable: public QTableView
  {
    Q_OBJECT

    public:
      JobsTable(QWidget *parent);
      virtual ~JobsTable();

      bool selectCurrent();
      bool isMultipleSelected();
      QModelIndexList getSelectedIndexes();
      void set_main_gui(BL::GenericGui * main_gui);

    protected:
      QWidget* _parent;

    protected slots:
      void selectionChanged ( const QItemSelection & selected, const QItemSelection & deselected );
      void currentChanged(const QModelIndex & current, const QModelIndex & previous);

    private:
      BL::GenericGui * _main_gui;
  };
}

#endif

