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

#include "BL_JobsTable.hxx"
#include "BL_Traces.hxx"
#include "BL_GenericGui.hxx"

#include <QHeaderView>
#include <QMainWindow>

BL::JobsTable::JobsTable(QWidget *parent) : QTableView(parent)
{
  DEBTRACE("Creating BL::JobsTable");
  BL_ASSERT(parent);
  _parent = parent;
  _main_gui = NULL;

  // Init
  setShowGrid(false);
  setCornerButtonEnabled(false);
  setEditTriggers(QAbstractItemView::NoEditTriggers);
  setAlternatingRowColors(true);
  setSortingEnabled(true);

  setSelectionBehavior(QAbstractItemView::SelectRows);
  setSelectionMode(QAbstractItemView::ExtendedSelection);

  QHeaderView * header_view = verticalHeader();
  header_view->setSectionsClickable(false);
}

BL::JobsTable::~JobsTable()
{
  DEBTRACE("Destroying BL::JobsTable");
}

bool
BL::JobsTable::selectCurrent()
{
  QModelIndex idx = currentIndex();
  if (idx.row() > -1)
    if (!isMultipleSelected())
    {
      DEBTRACE("SELECT CURRENT ACTIVATION !!!");
      setCurrentIndex(idx);
      activated(idx);
      return true;
    }
  return false;
}

void
BL::JobsTable::set_main_gui(BL::GenericGui * main_gui)
{
  _main_gui = main_gui;
}

void 
BL::JobsTable::selectionChanged ( const QItemSelection & selected, const QItemSelection & deselected )
{
  QTableView::selectionChanged(selected, deselected);
  DEBTRACE("selection changed");
  QModelIndexList selected_rows = selectionModel()->selectedRows();
  if (selected_rows.length() == 0)
  {
    if (_main_gui)
    {
      _main_gui->reset_job_selection();
    }
  }
  else if (selected_rows.length() == 1)
  {
    DEBTRACE("SELECTED CHANGED ACTIVATION !!!");
    DEBTRACE("ROW NUMBER: " << selected_rows[0].row());
    QModelIndex current = selected_rows[0];
    if (!selectionModel()->isSelected(current))
    {
      setCurrentIndex(current);
    }
    activated(current);
  }
  DEBTRACE("Number of selected rows selection: " << selected_rows.length());
}

void
BL::JobsTable::currentChanged(const QModelIndex & current, const QModelIndex & previous)
{
  QTableView::currentChanged(current, previous);
  DEBTRACE("current changed");
  DEBTRACE("current row: " << current.row());
  if (current.row() > -1)
    if (!isMultipleSelected())
    {
      DEBTRACE("CURRENT CHANGED ACTIVATION !!!");
      //setCurrentIndex(current);
      //activated(current);
    }
}

bool
BL::JobsTable::isMultipleSelected()
{
  QModelIndexList selected_rows = selectionModel()->selectedRows();
  DEBTRACE("Number of selected rows: " << selected_rows.length());
  if (selected_rows.length() > 1)
    return true;
  else
    return false;
}

QModelIndexList
BL::JobsTable::getSelectedIndexes()
{
  return selectedIndexes();
}
