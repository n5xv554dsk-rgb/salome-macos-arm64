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

#ifndef _BL_SUMMARY_HXX_
#define _BL_SUMMARY_HXX_

#include "BL_JobsManager_QT.hxx"

#include <QWidget>

class QLabel;
class QModelIndex;
class QStandardItem;
class QStandardItemModel;

namespace BL 
{
  class Summary: public QWidget
  {
    Q_OBJECT

    public:
      Summary(QWidget *parent, BL::JobsManager_QT * jobs_manager);
      virtual ~Summary();

      void setModel(QStandardItemModel * model);

      void updateJobs();

    public slots:
      void rowsInserted(const QModelIndex & parent, int start, int end);
      void rowsRemoved(const QModelIndex & parent, int start, int end);
      void itemChanged(QStandardItem * item);

    protected:
      QWidget* _parent;
      QStandardItemModel * _model;

      BL::JobsManager_QT * _jobs_manager;
      QLabel * _total_line;
      QLabel * _created_line;
      QLabel * _queued_line;
      QLabel * _running_line;
      QLabel * _finished_line;
  };
}

#endif

