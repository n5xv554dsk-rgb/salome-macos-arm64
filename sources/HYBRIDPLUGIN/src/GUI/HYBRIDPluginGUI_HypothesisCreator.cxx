// Copyright (C) 2007-2026  CEA, EDF
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

// ---
// File   : HYBRIDPluginGUI_HypothesisCreator.cxx
// Author : Christian VAN WAMBEKE (CEA)
// ---
//
#include "HYBRIDPluginGUI_HypothesisCreator.h"
#include "HYBRIDPluginGUI_Enums.h"
#include "HYBRIDPluginGUI_Dlg.h"

#include <GeometryGUI.h>

#include <SMESHGUI_HypothesesUtils.h>
#include <SMESHGUI_SpinBox.h>
#include <SMESHGUI_Utils.h>
#include <SMESH_NumberFilter.hxx>
#include <SMESH_TypeFilter.hxx>
#include <StdMeshersGUI_ObjectReferenceParamWdg.h>
#include <StdMeshersGUI_SubShapeSelectorWdg.h>

#include <LightApp_SelectionMgr.h>
#include <SUIT_Session.h>
#include <SUIT_MessageBox.h>
#include <SUIT_ResourceMgr.h>
#include <SUIT_FileDlg.h>
#include <SalomeApp_Tools.h>
#include <SalomeApp_TypeFilter.h>

#include <TopoDS_Iterator.hxx>

#include <QComboBox>
#include <QPalette>
#include <QLabel>
#include <QFrame>
#include <QVBoxLayout>
#include <QGridLayout>
#include <QLineEdit>
#include <QCheckBox>
#include <QTabWidget>
#include <QSpinBox>
#include <QPushButton>
#include <QFileInfo>
#include <QGroupBox>

#include <QTableWidget>
#include <QTableWidgetItem>
#include <QHeaderView>

#include <stdexcept>
#include <utilities.h>

#include <boost/algorithm/string.hpp>

// namespace {

// #ifdef WIN32
// #include <windows.h>
// #else
// #include <sys/sysinfo.h>
// #endif

//   int maxAvailableMemory()
//   {
// #ifdef WIN32
//     // See http://msdn.microsoft.com/en-us/library/aa366589.aspx
//     MEMORYSTATUSEX statex;
//     statex.dwLength = sizeof (statex);
//     int err = GlobalMemoryStatusEx (&statex);
//     if (err != 0) {
//       int totMB = 
//         statex.ullTotalPhys / 1024 / 1024 +
//         statex.ullTotalPageFile / 1024 / 1024 +
//         statex.ullTotalVirtual / 1024 / 1024;
//       return (int) ( 0.7 * totMB );
//     }
// #else
//     struct sysinfo si;
//     int err = sysinfo( &si );
//     if ( err == 0 ) {
//       int totMB =
//         si.totalram * si.mem_unit / 1024 / 1024 +
//         si.totalswap * si.mem_unit / 1024 / 1024 ;
//       return (int) ( 0.7 * totMB );
//     }
// #endif
//     return 0;
//   }
// }

//
// BEGIN EnforcedVertexTableWidgetDelegate
//

EnforcedVertexTableWidgetDelegate::EnforcedVertexTableWidgetDelegate(QObject *parent)
    : QItemDelegate(parent)
{
}

QWidget *EnforcedVertexTableWidgetDelegate::createEditor(QWidget *parent,
                                                  const QStyleOptionViewItem & option ,
                                                  const QModelIndex & index ) const
{
  QModelIndex father = index.parent();
  QString entry = father.child(index.row(), ENF_VER_ENTRY_COLUMN).data().toString();
  
  if (index.column() == ENF_VER_X_COLUMN ||
      index.column() == ENF_VER_Y_COLUMN ||
      index.column() == ENF_VER_Z_COLUMN ||
      index.column() == ENF_VER_SIZE_COLUMN) {
    SMESHGUI_SpinBox *editor = new SMESHGUI_SpinBox(parent);
    if (index.column() == ENF_VER_SIZE_COLUMN)
      editor->RangeStepAndValidator(0, COORD_MAX, 10.0, "length_precision");
    else
      editor->RangeStepAndValidator(COORD_MIN, COORD_MAX, 10.0, "length_precision");
    editor->setReadOnly(!entry.isEmpty());
    editor->setDisabled(!entry.isEmpty());
    return editor;
  }
//   else if (index.column() == ENF_VER_COMPOUND_COLUMN) {
//     QCheckBox *editor = new QCheckBox(parent);
//     editor->setDisabled(!entry.isEmpty());
//     return editor;
//   }
  else if (index.column() == ENF_VER_GROUP_COLUMN ||
           index.column() == ENF_VER_NAME_COLUMN) {
//   else {
    QLineEdit *editor = new QLineEdit(parent);
    if (index.column() != ENF_VER_GROUP_COLUMN) {
      editor->setReadOnly(!entry.isEmpty());
      editor->setDisabled(!entry.isEmpty());
    }
    return editor;
  }
  return QItemDelegate::createEditor(parent, option, index);
}

void EnforcedVertexTableWidgetDelegate::setEditorData(QWidget *editor,
                                               const QModelIndex &index) const
{
  if (index.column() == ENF_VER_X_COLUMN ||
      index.column() == ENF_VER_Y_COLUMN ||
      index.column() == ENF_VER_Z_COLUMN ||
      index.column() == ENF_VER_SIZE_COLUMN)
  {
    SMESHGUI_SpinBox *lineEdit = qobject_cast<SMESHGUI_SpinBox*>(editor);
    lineEdit->SetValue(index.data().toDouble());
  } 
  else if (index.column() == ENF_VER_COMPOUND_COLUMN) {
    QCheckBox *checkBox = qobject_cast<QCheckBox*>(editor);
    checkBox->setChecked(index.data().toBool());
  }
  else {
    QItemDelegate::setEditorData(editor, index);
  }
}

void EnforcedVertexTableWidgetDelegate::setModelData(QWidget *editor, QAbstractItemModel *model,
                                              const QModelIndex &index) const
{
  QModelIndex parent = index.parent();
  
  QString entry = parent.child(index.row(), ENF_VER_ENTRY_COLUMN).data().toString();
  bool isCompound = parent.child(index.row(), ENF_VER_COMPOUND_COLUMN).data(Qt::CheckStateRole).toBool();
  
  if (index.column() == ENF_VER_X_COLUMN || 
      index.column() == ENF_VER_Y_COLUMN || 
      index.column() == ENF_VER_Z_COLUMN) {
    SMESHGUI_SpinBox *lineEdit = qobject_cast<SMESHGUI_SpinBox*>(editor);
    if (!isCompound && !vertexExists(model, index, lineEdit->GetString()))
      model->setData(index, lineEdit->GetValue(), Qt::EditRole);
  } 
  else if (index.column() == ENF_VER_SIZE_COLUMN)
  {
    SMESHGUI_SpinBox *lineEdit = qobject_cast<SMESHGUI_SpinBox*>(editor);
    const double newsize =  lineEdit->GetValue();
    if (newsize > 0)
      model->setData(index, newsize, Qt::EditRole);
  } 
  else if (index.column() == ENF_VER_NAME_COLUMN) {
    QLineEdit *lineEdit = qobject_cast<QLineEdit*>(editor);
    QString value = lineEdit->text();
    if (entry.isEmpty() && !vertexExists(model, index, value))
      model->setData(index, value, Qt::EditRole);
  } 
  else if (index.column() == ENF_VER_ENTRY_COLUMN) {
    QLineEdit *lineEdit = qobject_cast<QLineEdit*>(editor);
    QString value = lineEdit->text();
    if (! vertexExists(model, index, value))
      model->setData(index, value, Qt::EditRole);
  }
  else if (index.column() == ENF_VER_COMPOUND_COLUMN) {
    QCheckBox *checkBox = qobject_cast<QCheckBox*>(editor);
    model->setData(index, checkBox->isChecked(), Qt::CheckStateRole);
  }
  else {
    QItemDelegate::setModelData(editor, model, index);
  }
}

void EnforcedVertexTableWidgetDelegate::updateEditorGeometry(QWidget *editor,
    const QStyleOptionViewItem &option, const QModelIndex &/* index */) const
{
    editor->setGeometry(option.rect);
}

bool EnforcedVertexTableWidgetDelegate::vertexExists(QAbstractItemModel *model,
                                              const QModelIndex &index, 
                                              QString value) const
{
  bool exists = false;
  QModelIndex parent = index.parent();
  int row = index.row();
  int col = index.column();

  if (parent.isValid() && !value.isEmpty()) {
    if (col == ENF_VER_X_COLUMN || col == ENF_VER_Y_COLUMN || col == ENF_VER_Z_COLUMN) {
      double x, y, z;
      if (col == ENF_VER_X_COLUMN) {
        x = value.toDouble();
        y = parent.child(row, ENF_VER_Y_COLUMN).data().toDouble();
        z = parent.child(row, ENF_VER_Z_COLUMN).data().toDouble();
      }
      if (col == ENF_VER_Y_COLUMN) {
        y = value.toDouble();
        x = parent.child(row, ENF_VER_X_COLUMN).data().toDouble();
        z = parent.child(row, ENF_VER_Z_COLUMN).data().toDouble();
      }
      if (col == ENF_VER_Z_COLUMN) {
        z = value.toDouble();
        x = parent.child(row, ENF_VER_X_COLUMN).data().toDouble();
        y = parent.child(row, ENF_VER_Y_COLUMN).data().toDouble();
      }
      int nbChildren = model->rowCount(parent);
      for (int i = 0 ; i < nbChildren ; i++) {
        if (i != row) {
          double childX = parent.child(i, ENF_VER_X_COLUMN).data().toDouble();
          double childY = parent.child(i, ENF_VER_Y_COLUMN).data().toDouble();
          double childZ = parent.child(i, ENF_VER_Z_COLUMN).data().toDouble();
          if ((childX == x) && (childY == y) && (childZ == z)) {
            exists = true;
            break;
          }
        }
      }
    }
    else if (col == ENF_VER_NAME_COLUMN) {
      QString name = parent.child(row, ENF_VER_NAME_COLUMN).data().toString();
      if (name == value)
        exists = true;
    }
  }

  return exists;
}

//
// END EnforcedVertexTableWidgetDelegate
//

//
// BEGIN EnforcedMeshTableWidgetDelegate
//

EnforcedMeshTableWidgetDelegate::EnforcedMeshTableWidgetDelegate(QObject *parent)
    : QItemDelegate(parent)
{
}

QWidget *EnforcedMeshTableWidgetDelegate::createEditor(QWidget *parent,
                                                  const QStyleOptionViewItem & option ,
                                                  const QModelIndex & index ) const
{
  return QItemDelegate::createEditor(parent, option, index);
}

void EnforcedMeshTableWidgetDelegate::setEditorData(QWidget *editor,
                                               const QModelIndex &index) const
{
        QItemDelegate::setEditorData(editor, index);
}

void EnforcedMeshTableWidgetDelegate::setModelData(QWidget *editor, QAbstractItemModel *model,
                                              const QModelIndex &index) const
{  
  QItemDelegate::setModelData(editor, model, index);

}

void EnforcedMeshTableWidgetDelegate::updateEditorGeometry(QWidget *editor,
    const QStyleOptionViewItem &option, const QModelIndex &/* index */) const
{
    editor->setGeometry(option.rect);
}

// bool EnforcedMeshTableWidgetDelegate::enfMeshExists(QAbstractItemModel *model,
//                                               const QModelIndex &index, 
//                                               QString value) const
// {
//   bool exists = false;
//   QModelIndex parent = index.parent();
//   int row = index.row();
//   int col = index.column();
//   return exists;
// }

//
// END EnforcedMeshTableWidgetDelegate
//


HYBRIDPluginGUI_HypothesisCreator::HYBRIDPluginGUI_HypothesisCreator( const QString& theHypType )
: SMESHGUI_GenericHypothesisCreator( theHypType )
{
  GeomToolSelected = NULL;
  GeomToolSelected = getGeomSelectionTool();
  
  iconVertex  = QPixmap(SUIT_Session::session()->resourceMgr()->loadPixmap("GEOM", tr("ICON_OBJBROWSER_VERTEX")));
  iconCompound  = QPixmap(SUIT_Session::session()->resourceMgr()->loadPixmap("GEOM", tr("ICON_OBJBROWSER_COMPOUND")));
//   mySelectionMgr = SMESH::GetSelectionMgr(SMESHGUI::GetSMESHGUI());
  myEnfMeshConstraintLabels << tr( "HYBRID_ENF_MESH_CONSTRAINT_NODE" ) << tr( "HYBRID_ENF_MESH_CONSTRAINT_EDGE" ) << tr("HYBRID_ENF_MESH_CONSTRAINT_FACE");
}

HYBRIDPluginGUI_HypothesisCreator::~HYBRIDPluginGUI_HypothesisCreator()
{
  HYBRIDPluginGUI_HypothesisCreator* that = (HYBRIDPluginGUI_HypothesisCreator*)this;
  that->getGeomSelectionTool()->selectionMgr()->clearFilters();
  myEnfMeshWdg->deactivateSelection();
}

/**
 * \brief {Get or create the geom selection tool for active study}
 * */
GeomSelectionTools* HYBRIDPluginGUI_HypothesisCreator::getGeomSelectionTool()
{
  HYBRIDPluginGUI_HypothesisCreator* that = (HYBRIDPluginGUI_HypothesisCreator*)this;
  if (that->GeomToolSelected == NULL) {
    that->GeomToolSelected = new GeomSelectionTools();
  }
  return that->GeomToolSelected;
}

GEOM::GEOM_Gen_var HYBRIDPluginGUI_HypothesisCreator::getGeomEngine()
{
  return GeometryGUI::GetGeomGen();
}

QFrame* HYBRIDPluginGUI_HypothesisCreator::buildFrame()
{
  QFrame* fr = new QFrame( 0 );
  QVBoxLayout* lay = new QVBoxLayout( fr );
  lay->setMargin( 5 );
  lay->setSpacing( 0 );

  // tab
  QTabWidget* tab = new QTabWidget( fr );
  tab->setTabShape( QTabWidget::Rounded );
  tab->setTabPosition( QTabWidget::North );
  lay->addWidget( tab );

  // basic parameters
  myStdGroup = new QWidget();
  QGridLayout* aStdLayout = new QGridLayout( myStdGroup );
  aStdLayout->setSpacing( 6 );
  aStdLayout->setMargin( 11 );

  int row = 0;
  myName = 0;
  if( isCreation() )
  {
    aStdLayout->addWidget( new QLabel( tr( "SMESH_NAME" ), myStdGroup ), row, 0, 1, 1 );
    myName = new QLineEdit( myStdGroup );
    aStdLayout->addWidget( myName, row++, 1, 1, 1 );
  }

  myStdWidget = new HYBRIDPluginGUI_StdWidget( myStdGroup );
  myStdWidget->verticalLayout->setMargin( 0 );
  aStdLayout->addWidget( myStdWidget, row++, 0, 1, 2 );

  // advanced parameters
  myAdvWidget = new HYBRIDPluginGUI_AdvWidget( tab );

  // Enforced vertices parameters
  myEnfGroup = new QWidget();
  QGridLayout* anEnfLayout = new QGridLayout(myEnfGroup);
  myEnforcedTableWidget = new QTableWidget(myEnfGroup);
  myEnforcedTableWidget ->setMinimumWidth(300);
  myEnforcedTableWidget->setRowCount( 0 );
  myEnforcedTableWidget->setColumnCount( ENF_VER_NB_COLUMNS );
  myEnforcedTableWidget->setSortingEnabled(true);
  QStringList enforcedHeaders;
  enforcedHeaders << tr( "HYBRID_ENF_NAME_COLUMN" )
                  << tr( "HYBRID_ENF_VER_X_COLUMN" )<< tr( "HYBRID_ENF_VER_Y_COLUMN" ) << tr( "HYBRID_ENF_VER_Z_COLUMN" )
                  << tr( "HYBRID_ENF_SIZE_COLUMN" ) << tr("HYBRID_ENF_ENTRY_COLUMN") << tr("HYBRID_ENF_VER_COMPOUND_COLUMN") << tr( "HYBRID_ENF_GROUP_COLUMN" );

  myEnforcedTableWidget->setHorizontalHeaderLabels(enforcedHeaders);
  myEnforcedTableWidget->verticalHeader()->hide();
  myEnforcedTableWidget->horizontalHeader()->setStretchLastSection(true);
  myEnforcedTableWidget->setAlternatingRowColors(true);
  myEnforcedTableWidget->setSelectionMode(QAbstractItemView::ExtendedSelection);
  myEnforcedTableWidget->setSelectionBehavior(QAbstractItemView::SelectItems);
  myEnforcedTableWidget->horizontalHeader()->setSectionResizeMode(QHeaderView::Interactive);

  myEnforcedTableWidget->resizeColumnsToContents();
  myEnforcedTableWidget->hideColumn(ENF_VER_ENTRY_COLUMN);
  myEnforcedTableWidget->hideColumn(ENF_VER_COMPOUND_COLUMN);
  
  myEnforcedTableWidget->setItemDelegate(new EnforcedVertexTableWidgetDelegate());
  
// VERTEX SELECTION
  TColStd_MapOfInteger shapeTypes;
  shapeTypes.Add( TopAbs_VERTEX );
  shapeTypes.Add( TopAbs_COMPOUND );

  SMESH_NumberFilter* vertexFilter = new SMESH_NumberFilter("GEOM", TopAbs_SHAPE, 1, shapeTypes);
  myEnfVertexWdg = new StdMeshersGUI_ObjectReferenceParamWdg( vertexFilter, 0, /*multiSel=*/true);
  myEnfVertexWdg->SetDefaultText(tr("HYBRID_ENF_SELECT_VERTEX"), "QLineEdit { color: grey }");
  
  QLabel* myXCoordLabel = new QLabel( tr( "HYBRID_ENF_VER_X_LABEL" ), myEnfGroup );
  myXCoord = new SMESHGUI_SpinBox(myEnfGroup);
  myXCoord->RangeStepAndValidator(COORD_MIN, COORD_MAX, 10.0, "length_precision");
  QLabel* myYCoordLabel = new QLabel( tr( "HYBRID_ENF_VER_Y_LABEL" ), myEnfGroup );
  myYCoord = new SMESHGUI_SpinBox(myEnfGroup);
  myYCoord->RangeStepAndValidator(COORD_MIN, COORD_MAX, 10.0, "length_precision");
  QLabel* myZCoordLabel = new QLabel( tr( "HYBRID_ENF_VER_Z_LABEL" ), myEnfGroup );
  myZCoord = new SMESHGUI_SpinBox(myEnfGroup);
  myZCoord->RangeStepAndValidator(COORD_MIN, COORD_MAX, 10.0, "length_precision");
  QLabel* mySizeLabel = new QLabel( tr( "HYBRID_ENF_SIZE_LABEL" ), myEnfGroup );
  mySizeValue = new SMESHGUI_SpinBox(myEnfGroup);
  mySizeValue->RangeStepAndValidator(COORD_MIN, COORD_MAX, 10.0, "length_precision");

  QLabel* myGroupNameLabel = new QLabel( tr( "HYBRID_ENF_GROUP_LABEL" ), myEnfGroup );
  myGroupName = new QLineEdit(myEnfGroup);

  addVertexButton = new QPushButton(tr("HYBRID_ENF_ADD"),myEnfGroup);
  addVertexButton->setEnabled(false);
  removeVertexButton = new QPushButton(tr("HYBRID_ENF_REMOVE"),myEnfGroup);
//   myGlobalGroupName = new QCheckBox(tr("HYBRID_ENF_VER_GROUPS"), myEnfGroup);
//   myGlobalGroupName->setChecked(false);
  
  // QGroupBox* GroupBox = new QGroupBox( myEnfGroup );
  // QLabel* info = new QLabel( GroupBox );
  // info->setText( tr( "HYBRID_ENF_VER_INFO" ) );
  // info->setWordWrap( true );
  // QVBoxLayout* GroupBoxVLayout = new QVBoxLayout( GroupBox );
  // GroupBoxVLayout->setSpacing( 6 );
  // GroupBoxVLayout->setMargin( 11 );
  // GroupBoxVLayout->addWidget( info );
  

  //anEnfLayout->addWidget(GroupBox,                  ENF_VER_WARNING, 0, 1, 2 );
  anEnfLayout->addWidget(myEnforcedTableWidget,     ENF_VER_VERTEX, 0, ENF_VER_NB_LINES, 1);
  
  QGridLayout* anEnfLayout2 = new QGridLayout(myEnfGroup);
  anEnfLayout2->addWidget(myEnfVertexWdg,           ENF_VER_VERTEX, 0, 1, 2);
  anEnfLayout2->addWidget(myXCoordLabel,            ENF_VER_X_COORD, 0, 1, 1);
  anEnfLayout2->addWidget(myXCoord,                 ENF_VER_X_COORD, 1, 1, 1);
  anEnfLayout2->addWidget(myYCoordLabel,            ENF_VER_Y_COORD, 0, 1, 1);
  anEnfLayout2->addWidget(myYCoord,                 ENF_VER_Y_COORD, 1, 1, 1);
  anEnfLayout2->addWidget(myZCoordLabel,            ENF_VER_Z_COORD, 0, 1, 1);
  anEnfLayout2->addWidget(myZCoord,                 ENF_VER_Z_COORD, 1, 1, 1);
  anEnfLayout2->addWidget(mySizeLabel,              ENF_VER_SIZE, 0, 1, 1);
  anEnfLayout2->addWidget(mySizeValue,              ENF_VER_SIZE, 1, 1, 1);
  anEnfLayout2->addWidget(myGroupNameLabel,         ENF_VER_GROUP, 0, 1, 1);
  anEnfLayout2->addWidget(myGroupName,              ENF_VER_GROUP, 1, 1, 1);
  anEnfLayout2->addWidget(addVertexButton,          ENF_VER_BTN, 0, 1, 1);
  anEnfLayout2->addWidget(removeVertexButton,       ENF_VER_BTN, 1, 1, 1);
  anEnfLayout2->setRowStretch(ENF_VER_NB_LINES, 1);
  
  anEnfLayout->addLayout(anEnfLayout2,              ENF_VER_VERTEX, 1,ENF_VER_NB_LINES, 1);
  anEnfLayout->setRowStretch(ENF_VER_VERTEX, 10);

  // Enforced meshes parameters
  myEnfMeshGroup = new QWidget();
  QGridLayout* anEnfMeshLayout = new QGridLayout(myEnfMeshGroup);
  
  myEnforcedMeshTableWidget = new QTableWidget(myEnfGroup);
  myEnforcedMeshTableWidget->setRowCount( 0 );
  myEnforcedMeshTableWidget->setColumnCount( ENF_MESH_NB_COLUMNS );
  myEnforcedMeshTableWidget->setSortingEnabled(true);
  myEnforcedMeshTableWidget->verticalHeader()->hide();
  QStringList enforcedMeshHeaders;
  enforcedMeshHeaders << tr( "HYBRID_ENF_NAME_COLUMN" ) 
                      << tr( "HYBRID_ENF_ENTRY_COLUMN" ) 
                      << tr( "HYBRID_ENF_MESH_CONSTRAINT_COLUMN" ) 
                      << tr( "HYBRID_ENF_GROUP_COLUMN" );
  myEnforcedMeshTableWidget->setHorizontalHeaderLabels(enforcedMeshHeaders);
  myEnforcedMeshTableWidget->horizontalHeader()->setStretchLastSection(true);
  myEnforcedMeshTableWidget->horizontalHeader()->setSectionResizeMode(QHeaderView::Interactive);

  myEnforcedMeshTableWidget->setAlternatingRowColors(true);
  myEnforcedMeshTableWidget->setSelectionMode(QAbstractItemView::ExtendedSelection);
  myEnforcedMeshTableWidget->setSelectionBehavior(QAbstractItemView::SelectItems);
  myEnforcedMeshTableWidget->resizeColumnsToContents();
  myEnforcedMeshTableWidget->hideColumn(ENF_MESH_ENTRY_COLUMN);
  
  myEnforcedMeshTableWidget->setItemDelegate(new EnforcedMeshTableWidgetDelegate());
  
//   myEnfMesh = SMESH::SMESH_Mesh::_nil();
//   myEnfMeshArray = new SMESH::mesh_array();

  myEnfMeshWdg = new StdMeshersGUI_ObjectReferenceParamWdg( SMESH::IDSOURCE, myEnfMeshGroup, /*multiSel=*/true);
  myEnfMeshWdg->SetDefaultText(tr("HYBRID_ENF_SELECT_MESH"), "QLineEdit { color: grey }");
  
  myEnfMeshWdg->AvoidSimultaneousSelection(myEnfVertexWdg);
  ////myEnfMeshWdg->hide(); //may be used later
  
  QLabel* myMeshConstraintLabel = new QLabel( tr( "HYBRID_ENF_MESH_CONSTRAINT_LABEL" ), myEnfMeshGroup );
  myEnfMeshConstraint = new QComboBox(myEnfMeshGroup);
  myEnfMeshConstraint->insertItems(0,myEnfMeshConstraintLabels);
  myEnfMeshConstraint->setEditable(false);
  myEnfMeshConstraint->setCurrentIndex(2); //EZ: use mesh group of faces for a layer
  myMeshConstraintLabel->hide(); //may be used later
  myEnfMeshConstraint->hide(); //may be used later

  QLabel* myMeshGroupNameLabel = new QLabel( tr( "HYBRID_ENF_GROUP_LABEL" ), myEnfMeshGroup );
  myMeshGroupName = new QLineEdit(myEnfMeshGroup);
  myMeshGroupNameLabel->hide(); //may be used later
  myMeshGroupName->hide(); //may be used later

  addEnfMeshButton = new QPushButton(tr("HYBRID_ENF_ADD"),myEnfMeshGroup);
  // addEnfMeshButton->setEnabled(false);
  removeEnfMeshButton = new QPushButton(tr("HYBRID_ENF_REMOVE"),myEnfMeshGroup);
    
  // QGroupBox* GroupBox2 = new QGroupBox( myEnfMeshGroup );
  // QLabel* info2 = new QLabel( GroupBox2 );
  // info2->setText( tr( "HYBRID_ENF_MESH_INFO" ) );
  // info2->setWordWrap( true );
  // QVBoxLayout* GroupBox2VLayout = new QVBoxLayout( GroupBox2 );
  // GroupBox2VLayout->setSpacing( 6 );
  // GroupBox2VLayout->setMargin( 11 );
  // GroupBox2VLayout->addWidget( info2 );
  
  // anEnfMeshLayout->addWidget( GroupBox2,                ENF_MESH_WARNING, 0, 1, 2 );
  //anEnfMeshLayout->addWidget(myLayersOnAllWrapCheck, ENF_MESH_MESH, 0, 1 , 1);
  anEnfMeshLayout->addWidget(myEnforcedMeshTableWidget, ENF_MESH_MESH, 0, ENF_MESH_NB_LINES , 1);
  
  QGridLayout* anEnfMeshLayout2 = new QGridLayout(myEnfMeshGroup);
  anEnfMeshLayout2->addWidget(myEnfMeshWdg,             ENF_MESH_MESH, 0, 1, 2);
  //TODO remove or not be lateful to select layers...
  //anEnfMeshLayout2->addWidget(myMeshConstraintLabel,    ENF_MESH_CONSTRAINT, 0, 1, 1);
  //anEnfMeshLayout2->addWidget(myEnfMeshConstraint,      ENF_MESH_CONSTRAINT, 1, 1, 1);
  //anEnfMeshLayout2->addWidget(myMeshGroupNameLabel,     ENF_MESH_GROUP, 0, 1, 1);
  //anEnfMeshLayout2->addWidget(myMeshGroupName,          ENF_MESH_GROUP, 1, 1, 1);
  anEnfMeshLayout2->addWidget(addEnfMeshButton,         ENF_MESH_BTN, 0, 1, 1);
  anEnfMeshLayout2->addWidget(removeEnfMeshButton,      ENF_MESH_BTN, 1, 1, 1);
  anEnfMeshLayout2->setRowStretch(ENF_MESH_NB_LINES, 1);
  
  anEnfMeshLayout->addLayout(anEnfMeshLayout2,          ENF_MESH_MESH, 1, ENF_MESH_NB_LINES, 1);
  anEnfMeshLayout->setRowStretch(ENF_MESH_MESH, 10);


  // selection of faces for layers

  QWidget* faceSelLayersGroup = new QWidget( dlg() );
  //myLayersOnAllWrapCheck = new QCheckBox( tr( "HYBRID_LAYERS_ON_ALL_WRAP" ), faceSelLayersGroup );
  QGridLayout* faceSelLayersLayout = new QGridLayout( faceSelLayersGroup );
  //faceSelLayersLayout->addWidget(myLayersOnAllWrapCheck, 0, 0 );

  myFacesLbl = new QLabel( tr("HYBRID_FACE_IDS"), faceSelLayersGroup );
  faceSelLayersLayout->addWidget( myFacesLbl, 1, 0 );

  myFaceSelectorLayers = new StdMeshersGUI_SubShapeSelectorWdg( faceSelLayersGroup, TopAbs_FACE, true, true );
  QString aMainEntry = SMESHGUI_GenericHypothesisCreator::getMainShapeEntry();
  QString aSubEntry  = SMESHGUI_GenericHypothesisCreator::getShapeEntry();
  myFaceSelectorLayers->SetGeomShapeEntry( aSubEntry, aMainEntry );
  faceSelLayersLayout->addWidget( myFaceSelectorLayers, 2, 0);
  faceSelLayersLayout->setRowStretch( 2, 10);

  // selection of faces for imprinting

  QWidget* faceSelImprintingGroup = new QWidget( dlg() );
  QGridLayout* faceSelImprintingLayout = new QGridLayout( faceSelImprintingGroup );

  QLabel* facesLblImprinting = new QLabel( tr("HYBRID_FACE_IDS"), faceSelImprintingGroup );
  faceSelImprintingLayout->addWidget( facesLblImprinting, 0, 0 );

  myFaceSelectorImprinting = new StdMeshersGUI_SubShapeSelectorWdg( faceSelImprintingGroup, TopAbs_FACE, true, true );
  myFaceSelectorImprinting->SetGeomShapeEntry( aSubEntry, aMainEntry );
  faceSelImprintingLayout->addWidget( myFaceSelectorImprinting, 1, 0, 2, 2 );
  faceSelImprintingLayout->setRowStretch( 1, 10);

  // selection of faces for snapping

  QWidget* faceSelSnappingGroup = new QWidget( dlg() );
  QGridLayout* faceSelSnappingLayout = new QGridLayout( faceSelSnappingGroup );

  QLabel* facesLblSnapping = new QLabel( tr("HYBRID_FACE_IDS"), faceSelSnappingGroup );
  faceSelSnappingLayout->addWidget( facesLblSnapping, 0, 0 );

  myFaceSelectorSnapping = new StdMeshersGUI_SubShapeSelectorWdg( faceSelSnappingGroup, TopAbs_FACE, true, true );
  myFaceSelectorSnapping->SetGeomShapeEntry( aSubEntry, aMainEntry );
  faceSelSnappingLayout->addWidget( myFaceSelectorSnapping, 1, 0, 2, 2 );
  faceSelSnappingLayout->setRowStretch( 1, 10);

  // add tabs
  tab->insertTab( STD_TAB, myStdGroup, tr( "SMESH_ARGUMENTS" ) );
  tab->insertTab( ADV_TAB, myAdvWidget, tr( "HYBRID_ADV_ARGS" ) );
  if ( aMainEntry.isEmpty() && aSubEntry.isEmpty() ) { // mesh not based of geometry
    faceSelLayersGroup->hide();
    faceSelImprintingGroup->hide();
    faceSelSnappingGroup->hide();
  }
  else {
    tab->insertTab( FACE_SEL_LAYERS_TAB, faceSelLayersGroup, tr( "HYBRID_FACES_LAYERS_TAB" ));
    tab->insertTab( FACE_SEL_IMPRINTING_TAB, faceSelImprintingGroup, tr( "HYBRID_FACES_IMPRINTING_TAB" ));
    tab->insertTab( FACE_SEL_SNAPPING_TAB, faceSelSnappingGroup, tr( "HYBRID_FACES_SNAPPING_TAB" ));
  }
  tab->insertTab( ENF_MESH_TAB, myEnfMeshGroup, tr( "HYBRID_ENFORCED_MESHES" ) );
  tab->setCurrentIndex( STD_TAB );

  // connections
  connect( tab,              SIGNAL( currentChanged ( int )),       this,         SLOT( onTabChanged( int ) ) );
  connect( myAdvWidget->addBtn, SIGNAL( clicked() ),           this, SLOT( onAddOption() ) );
  connect( myStdWidget->myBoundaryLayersSizeMode, SIGNAL( currentIndexChanged(int)), SLOT( updateWidgets()));
  connect( myStdWidget->myImprinting, SIGNAL( currentIndexChanged(int)), SLOT( updateWidgets()));
  connect( myStdWidget->mySnapping,   SIGNAL( currentIndexChanged(int)), SLOT( updateWidgets()));
  connect( myAdvWidget->logInFileCheck,             SIGNAL( toggled( bool ) ), this, SLOT( updateWidgets() ) );
  connect( myAdvWidget->keepWorkingFilesCheck,      SIGNAL( toggled( bool ) ), this, SLOT( updateWidgets() ) );
  connect( myAdvWidget->workingDirectoryPushButton, SIGNAL( clicked() ),       this, SLOT( onDirBtnClicked() ) );
  
  connect( myEnforcedTableWidget,   SIGNAL( itemClicked(QTableWidgetItem *)), this, SLOT( synchronizeCoords() ) );
  connect( myEnforcedTableWidget,   SIGNAL( itemChanged(QTableWidgetItem *)), this, SLOT( updateEnforcedVertexValues(QTableWidgetItem *) ) );
  connect( myEnforcedTableWidget,   SIGNAL( itemSelectionChanged() ),         this, SLOT( synchronizeCoords() ) );
  connect( addVertexButton,         SIGNAL( clicked()),                       this, SLOT( onAddEnforcedVertex() ) );
  connect( removeVertexButton,      SIGNAL( clicked()),                       this, SLOT( onRemoveEnforcedVertex() ) );
  connect( myEnfVertexWdg,          SIGNAL( contentModified()),               this, SLOT( onSelectEnforcedVertex() ) );
  connect( myEnfVertexWdg,          SIGNAL( contentModified()),              this,  SLOT( checkVertexIsDefined() ) );
  connect( myXCoord,                SIGNAL( textChanged(const QString&) ),   this,  SLOT( clearEnfVertexSelection() ) );
  connect( myYCoord,                SIGNAL( textChanged(const QString&) ),   this,  SLOT( clearEnfVertexSelection() ) );
  connect( myZCoord,                SIGNAL( textChanged(const QString&) ),   this,  SLOT( clearEnfVertexSelection() ) );
  connect( mySizeValue,             SIGNAL( textChanged(const QString&) ),   this,  SLOT( checkVertexIsDefined() ) );
  connect( myXCoord,                SIGNAL( valueChanged(const QString&) ),   this,  SLOT( clearEnfVertexSelection() ) );
  connect( myYCoord,                SIGNAL( valueChanged(const QString&) ),   this,  SLOT( clearEnfVertexSelection() ) );
  connect( myZCoord,                SIGNAL( valueChanged(const QString&) ),   this,  SLOT( clearEnfVertexSelection() ) );
  connect( mySizeValue,             SIGNAL( valueChanged(const QString&) ),   this,  SLOT( checkVertexIsDefined() ) );
  connect( this,                    SIGNAL( vertexDefined(bool) ), addVertexButton, SLOT( setEnabled(bool) ) );
  
  connect( addEnfMeshButton,        SIGNAL( clicked()),                       this, SLOT( onAddEnforcedMesh() ) );
  connect( removeEnfMeshButton,     SIGNAL( clicked()),                       this, SLOT( onRemoveEnforcedMesh() ) );
//   connect( myEnfMeshWdg,            SIGNAL( contentModified()),              this,  SLOT( checkEnfMeshIsDefined() ) );
//   connect( myEnfMeshConstraint,     SIGNAL( currentIndexChanged(int) ),      this,  SLOT( checkEnfMeshIsDefined() ) );
//   connect( this,                    SIGNAL( enfMeshDefined(bool) ), addEnfMeshButton, SLOT( setEnabled(bool) ) );
  
  return fr;
}

/** 
 * This method checks if an enforced vertex is defined;
**/
void HYBRIDPluginGUI_HypothesisCreator::clearEnfVertexSelection()
{
  if (myEnfVertexWdg->NbObjects() != 0) {
    disconnect( myEnfVertexWdg, SIGNAL( contentModified()), this, SLOT( onSelectEnforcedVertex() ) );
    disconnect( myEnfVertexWdg, SIGNAL( contentModified()), this, SLOT( checkVertexIsDefined() ) );
    myEnfVertexWdg->SetObject(GEOM::GEOM_Object::_nil());
    connect( myEnfVertexWdg, SIGNAL( contentModified()), this, SLOT( onSelectEnforcedVertex() ) );
    connect( myEnfVertexWdg, SIGNAL( contentModified()), this, SLOT( checkVertexIsDefined() ) );
  }
  HYBRIDPluginGUI_HypothesisCreator* that = (HYBRIDPluginGUI_HypothesisCreator*)this;
  that->checkVertexIsDefined();
}

/** 
 * This method checks if an enforced vertex is defined;
**/
void HYBRIDPluginGUI_HypothesisCreator::checkVertexIsDefined()
{
  bool enfVertexIsDefined = false;
  enfVertexIsDefined = (!mySizeValue->GetString().isEmpty() &&
                       (!myEnfVertexWdg->NbObjects() == 0 ||
                       (myEnfVertexWdg->NbObjects() == 0 && !myXCoord->GetString().isEmpty()
                                                         && !myYCoord->GetString().isEmpty()
                                                         && !myZCoord->GetString().isEmpty())));
  emit vertexDefined(enfVertexIsDefined);
}

/** 
 * This method checks if an enforced mesh is defined;
**/
void HYBRIDPluginGUI_HypothesisCreator::checkEnfMeshIsDefined()
{
  emit enfMeshDefined( myEnfVertexWdg->NbObjects() != 0);
}

/** 
 * This method resets the content of the X, Y, Z, size and GroupName widgets;
**/
void HYBRIDPluginGUI_HypothesisCreator::clearEnforcedVertexWidgets()
{
  myXCoord->setCleared(true);
  myYCoord->setCleared(true);
  myZCoord->setCleared(true);
//   mySizeValue->setCleared(true);
  myXCoord->setText("");
  myYCoord->setText("");
  myZCoord->setText("");
//   mySizeValue->setText("");
//   myGroupName->setText("");
  addVertexButton->setEnabled(false);
}

/** HYBRIDPluginGUI_HypothesisCreator::updateEnforcedVertexValues(item)
This method updates the tooltip of a modified item. The QLineEdit widgets content
is synchronized with the coordinates of the enforced vertex clicked in the tree widget.
*/
void HYBRIDPluginGUI_HypothesisCreator::updateEnforcedVertexValues(QTableWidgetItem* item) {
  int row = myEnforcedTableWidget->row(item);
      
  QVariant vertexName = myEnforcedTableWidget->item(row,ENF_VER_NAME_COLUMN)->data(Qt::EditRole);
  QVariant x = myEnforcedTableWidget->item(row,ENF_VER_X_COLUMN)->data( Qt::EditRole);
  QVariant y = myEnforcedTableWidget->item(row,ENF_VER_Y_COLUMN)->data( Qt::EditRole);
  QVariant z = myEnforcedTableWidget->item(row,ENF_VER_Z_COLUMN)->data( Qt::EditRole);
  QVariant size = myEnforcedTableWidget->item(row,ENF_VER_SIZE_COLUMN)->data( Qt::EditRole);
  QVariant entry = myEnforcedTableWidget->item(row,ENF_VER_ENTRY_COLUMN)->data( Qt::EditRole);
  QString groupName = myEnforcedTableWidget->item(row,ENF_VER_GROUP_COLUMN)->data( Qt::EditRole).toString();
  
  clearEnforcedVertexWidgets();
  
  if ( !x.isNull() || !entry.isNull()) {
    QString toolTip = vertexName.toString();
    toolTip += QString("(");
    if (entry.isNull() || (!entry.isNull() && entry.toString() == "")) {
      toolTip += x.toString();
      toolTip += QString(", ") + y.toString();
      toolTip += QString(", ") + z.toString();
    }
    else
      toolTip += entry.toString();
    toolTip += QString(")");
    
    if (!size.isNull())
      toolTip += QString("=") + size.toString();
    
    if (!groupName.isEmpty())
      toolTip += QString(" [") + groupName + QString("]");

    for (int col=0;col<ENF_VER_NB_COLUMNS;col++)
      myEnforcedTableWidget->item(row,col)->setToolTip(toolTip);

    if (!x.isNull()) {
      disconnect( myXCoord, SIGNAL( textChanged(const QString&) ), this, SLOT( clearEnfVertexSelection() ) );
      disconnect( myYCoord, SIGNAL( textChanged(const QString&) ), this, SLOT( clearEnfVertexSelection() ) );
      disconnect( myZCoord, SIGNAL( textChanged(const QString&) ), this, SLOT( clearEnfVertexSelection() ) );
      myXCoord->SetValue(x.toDouble());
      myYCoord->SetValue(y.toDouble());
      myZCoord->SetValue(z.toDouble());
      connect( myXCoord, SIGNAL( textChanged(const QString&) ), this, SLOT( clearEnfVertexSelection() ) );
      connect( myYCoord, SIGNAL( textChanged(const QString&) ), this, SLOT( clearEnfVertexSelection() ) );
      connect( myZCoord, SIGNAL( textChanged(const QString&) ), this, SLOT( clearEnfVertexSelection() ) );
    }
    if (!size.isNull())
      mySizeValue->SetValue(size.toDouble());
    
    if (!groupName.isEmpty())
      myGroupName->setText(groupName);
  }
}

void HYBRIDPluginGUI_HypothesisCreator::onSelectEnforcedVertex() {
  int nbSelEnfVertex = myEnfVertexWdg->NbObjects();
  clearEnforcedVertexWidgets();
  if (nbSelEnfVertex == 1)
  {
    if ( CORBA::is_nil( getGeomEngine() ) && !GeometryGUI::InitGeomGen() )
    return ;

    myEnfVertex = myEnfVertexWdg->GetObject< GEOM::GEOM_Object >(nbSelEnfVertex-1);
    if (myEnfVertex == GEOM::GEOM_Object::_nil())
      return;
    if (myEnfVertex->GetShapeType() == GEOM::VERTEX)
    {
      GEOM::GEOM_IMeasureOperations_var measureOp = getGeomEngine()->GetIMeasureOperations();
      if (CORBA::is_nil(measureOp))
        return;
      
      CORBA::Double x,y,z;
      measureOp->PointCoordinates (myEnfVertex, x, y, z);
      if ( measureOp->IsDone() )
      {
        disconnect( myXCoord, SIGNAL( textChanged(const QString&) ), this, SLOT( clearEnfVertexSelection() ) );
        disconnect( myYCoord, SIGNAL( textChanged(const QString&) ), this, SLOT( clearEnfVertexSelection() ) );
        disconnect( myZCoord, SIGNAL( textChanged(const QString&) ), this, SLOT( clearEnfVertexSelection() ) );
        myXCoord->SetValue(x);
        myYCoord->SetValue(y);
        myZCoord->SetValue(z);
        connect( myXCoord, SIGNAL( textChanged(const QString&) ), this, SLOT( clearEnfVertexSelection() ) );
        connect( myYCoord, SIGNAL( textChanged(const QString&) ), this, SLOT( clearEnfVertexSelection() ) );
        connect( myZCoord, SIGNAL( textChanged(const QString&) ), this, SLOT( clearEnfVertexSelection() ) );
      }
    }
  }
}

/** HYBRIDPluginGUI_HypothesisCreator::synchronizeCoords()
This method synchronizes the QLineEdit/SMESHGUI_SpinBox widgets content with the coordinates
of the enforced vertex clicked in the tree widget.
*/
void HYBRIDPluginGUI_HypothesisCreator::synchronizeCoords() {
  clearEnforcedVertexWidgets();
  QList<QTableWidgetItem *> items = myEnforcedTableWidget->selectedItems();
//   myEnfVertexWdg->disconnect(SIGNAL(contentModified()));
  disconnect( myEnfVertexWdg, SIGNAL( contentModified()), this, SLOT( onSelectEnforcedVertex() ) );
  if (! items.isEmpty()) {
    QTableWidgetItem *item;
    int row;
    QVariant entry;
    if (items.size() == 1) {
      item = items[0];
      row = myEnforcedTableWidget->row(item);
      QVariant x = myEnforcedTableWidget->item(row,ENF_VER_X_COLUMN)->data( Qt::EditRole);
      QVariant y = myEnforcedTableWidget->item(row,ENF_VER_Y_COLUMN)->data( Qt::EditRole);
      QVariant z = myEnforcedTableWidget->item(row,ENF_VER_Z_COLUMN)->data( Qt::EditRole);
      QVariant size = myEnforcedTableWidget->item(row,ENF_VER_SIZE_COLUMN)->data( Qt::EditRole);
      entry = myEnforcedTableWidget->item(row,ENF_VER_ENTRY_COLUMN)->data( Qt::EditRole);
      if (!entry.isNull()) {
        SMESH::string_array_var objIds = new SMESH::string_array;
        objIds->length(1);
        objIds[0] = entry.toString().toStdString().c_str();
        myEnfVertexWdg->SetObjects(objIds);
      }
      else {
        myEnfVertexWdg->SetObject(GEOM::GEOM_Object::_nil());
      }
      QVariant group = myEnforcedTableWidget->item(row,ENF_VER_GROUP_COLUMN)->data( Qt::EditRole);
      if (!x.isNull()/* && entry.isNull()*/) {
//         disconnect( myXCoord, SIGNAL( textChanged(const QString &)), this, SLOT( onSelectEnforcedVertex() ) );
        disconnect( myXCoord, SIGNAL( textChanged(const QString&) ), this, SLOT( clearEnfVertexSelection() ) );
        disconnect( myYCoord, SIGNAL( textChanged(const QString&) ), this, SLOT( clearEnfVertexSelection() ) );
        disconnect( myZCoord, SIGNAL( textChanged(const QString&) ), this, SLOT( clearEnfVertexSelection() ) );
        myXCoord->SetValue(x.toDouble());
        myYCoord->SetValue(y.toDouble());
        myZCoord->SetValue(z.toDouble());
        connect( myXCoord, SIGNAL( textChanged(const QString&) ), this, SLOT( clearEnfVertexSelection() ) );
        connect( myYCoord, SIGNAL( textChanged(const QString&) ), this, SLOT( clearEnfVertexSelection() ) );
        connect( myZCoord, SIGNAL( textChanged(const QString&) ), this, SLOT( clearEnfVertexSelection() ) );
      }
      if (!size.isNull())
        mySizeValue->SetValue(size.toDouble());
      
      if (!group.isNull() && (!x.isNull() || !entry.isNull()))
        myGroupName->setText(group.toString());
    }
    else {
      QList<QString> entryList;
      for (int i = 0; i < items.size(); ++i) {
        item = items[i];
        row = myEnforcedTableWidget->row(item);
        entry = myEnforcedTableWidget->item(row,ENF_VER_ENTRY_COLUMN)->data( Qt::EditRole);
        if (!entry.isNull())
          entryList << entry.toString();
      }
      if (entryList.size() > 0) {
        SMESH::string_array_var objIds = new SMESH::string_array;
        objIds->length(entryList.size());
        for (int i = 0; i < entryList.size() ; i++)
          objIds[i] = entryList.at(i).toStdString().c_str();
        myEnfVertexWdg->SetObjects(objIds);
      }
      else {
        myEnfVertexWdg->SetObject(GEOM::GEOM_Object::_nil());
      }
    }
  }
  else {
    myEnfVertexWdg->SetObject(GEOM::GEOM_Object::_nil());
  }
  connect( myEnfVertexWdg, SIGNAL( contentModified()), this, SLOT( onSelectEnforcedVertex() ) );
  HYBRIDPluginGUI_HypothesisCreator* that = (HYBRIDPluginGUI_HypothesisCreator*)this;
  that->checkVertexIsDefined();
}

/** HYBRIDPluginGUI_HypothesisCreator::addEnforcedMesh( meshName, geomEntry, elemType, size, groupName)
This method adds in the tree widget an enforced mesh from mesh, submesh or group with optionally size and and groupName.
*/
void HYBRIDPluginGUI_HypothesisCreator::addEnforcedMesh(std::string name, std::string entry, int elementType, std::string groupName)
{
  bool okToCreate = true;
  QString itemEntry = "";
  int itemElementType = 0;
  int rowCount = myEnforcedMeshTableWidget->rowCount();
  bool allColumns = true;
  for (int row = 0;row<rowCount;row++) {
    for (int col = 0 ; col < ENF_MESH_NB_COLUMNS ; col++) {
      if (col == ENF_MESH_CONSTRAINT_COLUMN){
        if (qobject_cast<QComboBox*>(myEnforcedMeshTableWidget->cellWidget(row, col)) == 0) {
          allColumns = false;
          break;
        }
      }
      else if (myEnforcedMeshTableWidget->item(row, col) == 0) {
        allColumns = false;
        break;
      }
      if (col == ENF_MESH_CONSTRAINT_COLUMN) {
        QComboBox* itemComboBox = qobject_cast<QComboBox*>(myEnforcedMeshTableWidget->cellWidget(row, col));
        itemElementType = itemComboBox->currentIndex();
      }
      else if (col == ENF_MESH_ENTRY_COLUMN)
        itemEntry = myEnforcedMeshTableWidget->item(row, col)->data(Qt::EditRole).toString();
    }
    
    if (!allColumns)
      break;
  
    if (itemEntry == QString(entry.c_str()) && itemElementType == elementType) { 
//       // update group name
//       if (itemGroupName.toStdString() != groupName) {
//         myEnforcedMeshTableWidget->item(row, ENF_MESH_GROUP_COLUMN)->setData( Qt::EditRole, QVariant(groupName.c_str()));
//       }
      okToCreate = false;
      break;
    } // if
  } // for

    
  if (!okToCreate)
    return;
  

  myEnforcedMeshTableWidget->setRowCount(rowCount+1);
  myEnforcedMeshTableWidget->setSortingEnabled(false);
  
  for (int col=0;col<ENF_MESH_NB_COLUMNS;col++) {
    if (col == ENF_MESH_CONSTRAINT_COLUMN) {
      QComboBox* comboBox = new QComboBox();
      QPalette pal = comboBox->palette();
      pal.setColor(QPalette::Button, Qt::white);
      comboBox->setPalette(pal);
      comboBox->insertItems(0,myEnfMeshConstraintLabels);
      comboBox->setEditable(false);
      comboBox->setCurrentIndex(elementType);
      myEnforcedMeshTableWidget->setCellWidget(rowCount,col,comboBox);
    }
    else {
      QTableWidgetItem* item = new QTableWidgetItem();
      item->setFlags( Qt::ItemIsSelectable | Qt::ItemIsEditable | Qt::ItemIsEnabled);
      switch (col) {
        case ENF_MESH_NAME_COLUMN:
          item->setData( 0, name.c_str() );
          item->setFlags( Qt::ItemIsSelectable | Qt::ItemIsEnabled);
          myEnforcedMeshTableWidget->setItem(rowCount,col,item);
          break;
        case ENF_MESH_ENTRY_COLUMN:
          item->setData( 0, entry.c_str() );
          item->setFlags( Qt::ItemIsSelectable | Qt::ItemIsEnabled);
          myEnforcedMeshTableWidget->setItem(rowCount,col,item);
          break;
        case ENF_MESH_GROUP_COLUMN:
          item->setData( 0, groupName.c_str() );
          myEnforcedMeshTableWidget->setItem(rowCount,col,item);
          break;
        default:
          break;
      }
    }
  }

//   connect( myEnforcedMeshTableWidget,SIGNAL( itemChanged(QTableWidgetItem *)), this,  SLOT( updateEnforcedVertexValues(QTableWidgetItem *) ) );
  
  myEnforcedMeshTableWidget->setSortingEnabled(true);
//   myEnforcedTableWidget->setCurrentItem(myEnforcedTableWidget->item(rowCount,ENF_VER_NAME_COLUMN));
//   updateEnforcedVertexValues(myEnforcedTableWidget->item(rowCount,ENF_VER_NAME_COLUMN));
    
}

/** HYBRIDPluginGUI_HypothesisCreator::addEnforcedVertex( x, y, z, size, vertexName, geomEntry, groupName)
This method adds in the tree widget an enforced vertex with given size and coords (x,y,z) or GEOM vertex or compound and with optionally groupName.
*/
void HYBRIDPluginGUI_HypothesisCreator::addEnforcedVertex(double x, double y, double z, double size, std::string vertexName, std::string geomEntry, std::string groupName, bool isCompound)
{
  myEnforcedTableWidget->disconnect(SIGNAL( itemChanged(QTableWidgetItem *)));
  bool okToCreate = true;
  double itemX=0.,itemY=0.,itemZ=0.,itemSize = 0;
  QString itemEntry, itemGroupName = QString("");
//   bool itemIsCompound;
  int rowCount = myEnforcedTableWidget->rowCount();
  QVariant data;
  bool allColumns;
  for (int row = 0;row<rowCount;row++) {
    allColumns = true;
    for (int col = 0 ; col < ENF_VER_NB_COLUMNS ; col++) {
      if (myEnforcedTableWidget->item(row, col) == 0) {
        allColumns = false;
        break;
      }
      
      data = myEnforcedTableWidget->item(row, col)->data(Qt::EditRole);
      if (!data.isNull()) {
        switch (col) {
          case ENF_VER_GROUP_COLUMN:
            itemGroupName = data.toString();
            break;
          case ENF_VER_ENTRY_COLUMN:
            itemEntry = data.toString();
            break;
//           case ENF_VER_COMPOUND_COLUMN:
//             itemIsCompound = data.toBool();
//             break;
          case ENF_VER_X_COLUMN:
            itemX = data.toDouble();
            break;
          case ENF_VER_Y_COLUMN:
            itemY = data.toDouble();
            break;
          case ENF_VER_Z_COLUMN:
            itemZ = data.toDouble();
            break;
          case ENF_VER_SIZE_COLUMN:
            itemSize = data.toDouble();
            break;
          default:
            break;
        }
      }
    }
    
    if (!allColumns)
      break;


    if (( !isCompound && ((itemX == x) && (itemY == y) && (itemZ == z))) || /*( (itemEntry.toStdString() != "") && */ (itemEntry.toStdString() == geomEntry)/*)*/) {
      // update size
      if (itemSize != size) {
        myEnforcedTableWidget->item(row, ENF_VER_SIZE_COLUMN)->setData( Qt::EditRole, QVariant(size));
      }
      // update group name
      if (itemGroupName.toStdString() != groupName) {
        myEnforcedTableWidget->item(row, ENF_VER_GROUP_COLUMN)->setData( Qt::EditRole, QVariant(groupName.c_str()));
      }
      okToCreate = false;
      break;
    } // if
  } // for
  if (!okToCreate) {
    if (geomEntry.empty()) {
    }
    else {
    }
    return;
  }
    
  if (geomEntry.empty()) {
  }
  else {
  }

  int vertexIndex=0;
  int indexRef = -1;
  QString myVertexName;
  while(indexRef != vertexIndex) {
    indexRef = vertexIndex;
    if (vertexName.empty())
      myVertexName = QString("Vertex #%1").arg(vertexIndex);
    else
      myVertexName = QString(vertexName.c_str());

    for (int row = 0;row<rowCount;row++) {
      QString name = myEnforcedTableWidget->item(row,ENF_VER_NAME_COLUMN)->data(Qt::EditRole).toString();
      if (myVertexName == name) {
        vertexIndex++;
        break;
      }
    }
  }
  
  myEnforcedTableWidget->setRowCount(rowCount+1);
  myEnforcedTableWidget->setSortingEnabled(false);
  for (int col=0;col<ENF_VER_NB_COLUMNS;col++) {
    QTableWidgetItem* item = new QTableWidgetItem();
    item->setFlags( Qt::ItemIsSelectable | Qt::ItemIsEditable | Qt::ItemIsEnabled);
    switch (col) {
      case ENF_VER_NAME_COLUMN:
        item->setData( Qt::EditRole, myVertexName );
        if (!geomEntry.empty()) {
          if (isCompound)
            item->setIcon(QIcon(iconCompound.scaled(iconCompound.size()*0.7,Qt::KeepAspectRatio,Qt::SmoothTransformation)));
          else
            item->setIcon(QIcon(iconVertex.scaled(iconVertex.size()*0.7,Qt::KeepAspectRatio,Qt::SmoothTransformation)));
        }
        break;
      case ENF_VER_X_COLUMN:
        if (!isCompound)
          item->setData( 0, QVariant(x) );
        break;
      case ENF_VER_Y_COLUMN:
        if (!isCompound)
          item->setData( 0, QVariant(y) );
        break;
      case ENF_VER_Z_COLUMN:
        if (!isCompound)
          item->setData( 0, QVariant(z) );
        break;
      case ENF_VER_SIZE_COLUMN:
        item->setData( 0, QVariant(size) );
        break;
      case ENF_VER_ENTRY_COLUMN:
        if (!geomEntry.empty())
          item->setData( 0, QString(geomEntry.c_str()) );
        break;
      case ENF_VER_COMPOUND_COLUMN:
        item->setData( Qt::CheckStateRole, isCompound );
        item->setFlags(Qt::ItemIsSelectable | Qt::ItemIsUserCheckable);
        break;
      case ENF_VER_GROUP_COLUMN:
        if (!groupName.empty())
          item->setData( 0, QString(groupName.c_str()) );
        break;
      default:
        break;
    }
    
    myEnforcedTableWidget->setItem(rowCount,col,item);
  }

  connect( myEnforcedTableWidget,SIGNAL( itemChanged(QTableWidgetItem *)), this,  SLOT( updateEnforcedVertexValues(QTableWidgetItem *) ) );
  
  myEnforcedTableWidget->setSortingEnabled(true);
//   myEnforcedTableWidget->setCurrentItem(myEnforcedTableWidget->item(rowCount,ENF_VER_NAME_COLUMN));
  updateEnforcedVertexValues(myEnforcedTableWidget->item(rowCount,ENF_VER_NAME_COLUMN));
}

/** HYBRIDPluginGUI_HypothesisCreator::onAddEnforcedMesh()
This method is called when a item is added into the enforced meshes tree widget
*/
void HYBRIDPluginGUI_HypothesisCreator::onAddEnforcedMesh()
{

  HYBRIDPluginGUI_HypothesisCreator* that = (HYBRIDPluginGUI_HypothesisCreator*)this;
  
  that->getGeomSelectionTool()->selectionMgr()->clearFilters();
  myEnfMeshWdg->deactivateSelection();

  for (int column = 0; column < myEnforcedMeshTableWidget->columnCount(); ++column)
    myEnforcedMeshTableWidget->resizeColumnToContents(column);

  // Vertex selection
  int selEnfMeshes = myEnfMeshWdg->NbObjects();
  if (selEnfMeshes == 0)
    return;

  std::string groupName = myMeshGroupName->text().toStdString();
//   if (myGlobalGroupName->isChecked())
//     groupName = myGlobalGroupName->text().toStdString();

  if (boost::trim_copy(groupName).empty())
    groupName = "LayersGroup"; //have to be not empty until non used

  int elementType = myEnfMeshConstraint->currentIndex();
  
  
  _PTR(Study) aStudy = SMESH::getStudy();
  _PTR(SObject) aSObj; //SMESH::SMESH_IDSource::_nil;
  QString meshEntry = myEnfMeshWdg->GetValue();
  
  if (selEnfMeshes == 1)
  {
//     myEnfMesh = myEnfMeshWdg->GetObject< SMESH::SMESH_IDSource >();
//     std::string entry = myEnfMeshWdg->GetValue();
    aSObj = aStudy->FindObjectID(meshEntry.toStdString().c_str());
    CORBA::Object_var anObj = SMESH::SObjectToObject(aSObj);
    if (!CORBA::is_nil(anObj)) {
//       SMESH::SMESH_IDSource_var theSource = SMESH::SObjectToInterface<SMESH::SMESH_IDSource>( aSObj );
      addEnforcedMesh( aSObj->GetName(), aSObj->GetID(), elementType, groupName);
    }
  }
  else
  {
    QStringList meshEntries = meshEntry.split(" ", QString::SkipEmptyParts);
    QStringListIterator meshEntriesIt (meshEntries);
    while (meshEntriesIt.hasNext()) {
      aSObj = aStudy->FindObjectID(meshEntriesIt.next().toStdString().c_str());
      CORBA::Object_var anObj = SMESH::SObjectToObject(aSObj);
      if (!CORBA::is_nil(anObj)) {
//         SMESH::SMESH_IDSource_var theSource = SMESH::SObjectToInterface<SMESH::SMESH_IDSource>( aSObj );
        addEnforcedMesh( aSObj->GetName(), aSObj->GetID(), elementType, groupName);
      }
    }
  }

  myEnfVertexWdg->SetObject(SMESH::SMESH_IDSource::_nil());
  
  for (int column = 0; column < myEnforcedMeshTableWidget->columnCount(); ++column)
    myEnforcedMeshTableWidget->resizeColumnToContents(column);  
}


/** HYBRIDPluginGUI_HypothesisCreator::onAddEnforcedVertex()
This method is called when a item is added into the enforced vertices tree widget
*/
void HYBRIDPluginGUI_HypothesisCreator::onAddEnforcedVertex()
{

  HYBRIDPluginGUI_HypothesisCreator* that = (HYBRIDPluginGUI_HypothesisCreator*)this;
  
  that->getGeomSelectionTool()->selectionMgr()->clearFilters();
  myEnfVertexWdg->deactivateSelection();

  for (int column = 0; column < myEnforcedTableWidget->columnCount(); ++column)
    myEnforcedTableWidget->resizeColumnToContents(column);

  // Vertex selection
  int selEnfVertex = myEnfVertexWdg->NbObjects();
  bool coordsEmpty = (myXCoord->text().isEmpty()) || (myYCoord->text().isEmpty()) || (myZCoord->text().isEmpty());
  if ((selEnfVertex == 0) && coordsEmpty)
    return;

  std::string groupName = myGroupName->text().toStdString();
//   if (myGlobalGroupName->isChecked())
//     groupName = myGlobalGroupName->text().toStdString();

  if (boost::trim_copy(groupName).empty())
    groupName = "";

  double size = mySizeValue->GetValue();
  
  if (selEnfVertex <= 1)
  {
    double x = 0, y = 0, z=0;
    if (myXCoord->GetString() != "") {
      x = myXCoord->GetValue();
      y = myYCoord->GetValue();
      z = myZCoord->GetValue();
    }
    if (selEnfVertex == 1) {
      myEnfVertex = myEnfVertexWdg->GetObject< GEOM::GEOM_Object >();
      std::string entry = "";
      if (myEnfVertex != GEOM::GEOM_Object::_nil())
        entry = myEnfVertex->GetStudyEntry();
      addEnforcedVertex(x, y, z, size, myEnfVertex->GetName(),entry, groupName, myEnfVertex->GetShapeType() == GEOM::COMPOUND);
    }
    else {
      addEnforcedVertex(x, y, z, size, "", "", groupName);
    }
  }
  else
  {
    if ( CORBA::is_nil(getGeomEngine()))
      return;

    GEOM::GEOM_IMeasureOperations_var measureOp = getGeomEngine()->GetIMeasureOperations();
    if (CORBA::is_nil(measureOp))
      return;

    CORBA::Double x = 0, y = 0,z = 0;
    for (int j = 0 ; j < selEnfVertex ; j++)
    {
      myEnfVertex = myEnfVertexWdg->GetObject< GEOM::GEOM_Object >(j);
      if (myEnfVertex == GEOM::GEOM_Object::_nil())
        continue;
      if (myEnfVertex->GetShapeType() == GEOM::VERTEX) {
        measureOp->PointCoordinates (myEnfVertex, x, y, z);
        if ( measureOp->IsDone() )
          addEnforcedVertex(x, y, z, size, myEnfVertex->GetName(),myEnfVertex->GetStudyEntry(), groupName);
      } else if (myEnfVertex->GetShapeType() == GEOM::COMPOUND) {
          addEnforcedVertex(0., 0., 0., size, myEnfVertex->GetName(),myEnfVertex->GetStudyEntry(), groupName, true);
      }
    }
  }

  myEnfVertexWdg->SetObject(GEOM::GEOM_Object::_nil());
  
  for (int column = 0; column < myEnforcedTableWidget->columnCount(); ++column)
    myEnforcedTableWidget->resizeColumnToContents(column);  
}

/** HYBRIDPluginGUI_HypothesisCreator::onRemoveEnforcedMesh()
This method is called when a item is removed from the enforced meshes tree widget
*/
void HYBRIDPluginGUI_HypothesisCreator::onRemoveEnforcedMesh()
{
  QList<int> selectedRows;
  QList<QTableWidgetItem *> selectedItems = myEnforcedMeshTableWidget->selectedItems();
  QTableWidgetItem* item;
  int row;
  foreach( item, selectedItems ) {
    row = item->row();
    if (!selectedRows.contains( row ) )
      selectedRows.append(row);
  }
  
  qSort( selectedRows );
  QListIterator<int> it( selectedRows );
  it.toBack();
  while ( it.hasPrevious() ) {
      row = it.previous();
      myEnforcedMeshTableWidget->removeRow(row );
  }

  myEnforcedMeshTableWidget->selectionModel()->clearSelection();
}

/** HYBRIDPluginGUI_HypothesisCreator::onRemoveEnforcedVertex()
This method is called when a item is removed from the enforced vertices tree widget
*/
void HYBRIDPluginGUI_HypothesisCreator::onRemoveEnforcedVertex()
{
  QList<int> selectedRows;
  QList<QTableWidgetItem *> selectedItems = myEnforcedTableWidget->selectedItems();
  QTableWidgetItem* item;
  int row;
  foreach( item, selectedItems ) {
    row = item->row();
    if (!selectedRows.contains( row ) )
      selectedRows.append(row);
  }
  
  qSort( selectedRows );
  QListIterator<int> it( selectedRows );
  it.toBack();
  while ( it.hasPrevious() ) {
      row = it.previous();
      myEnforcedTableWidget->removeRow(row );
  }

  myEnforcedTableWidget->selectionModel()->clearSelection();
}

void HYBRIDPluginGUI_HypothesisCreator::onDirBtnClicked()
{
  QString dir = SUIT_FileDlg::getExistingDirectory( dlg(), myAdvWidget->workingDirectoryLineEdit->text(), QString() );
  if ( !dir.isEmpty() )
    myAdvWidget->workingDirectoryLineEdit->setText( dir );
}

void HYBRIDPluginGUI_HypothesisCreator::onTabChanged( int )
{
  myEnfVertexWdg->deactivateSelection();
  myEnfMeshWdg->deactivateSelection();
  myFaceSelectorLayers->ActivateSelection( false );
  myFaceSelectorLayers->ShowPreview( false );
  myFaceSelectorImprinting->ActivateSelection( false );
  myFaceSelectorImprinting->ShowPreview( false );
  myFaceSelectorSnapping->ActivateSelection( false );
  myFaceSelectorSnapping->ShowPreview( false );
}

void HYBRIDPluginGUI_HypothesisCreator::updateWidgets()
{
  if ( sender() == myAdvWidget->logInFileCheck ||
       sender() == myAdvWidget->keepWorkingFilesCheck )
  {
    bool logFileRemovable = ( myAdvWidget->logInFileCheck->isChecked() &&
                              !myAdvWidget->keepWorkingFilesCheck->isChecked() );
    myAdvWidget->removeLogOnSuccessCheck->setEnabled( logFileRemovable );
  }

  myStdWidget->myCoreSize->setEnabled( myStdWidget->myCoreSizeEnabled->isChecked() );

  if ( QTabWidget* tab = qobject_cast<QTabWidget*>( myStdGroup->parentWidget()->parentWidget() ))
  {
    bool isGlobal     = myStdWidget->GetLayersOnAllWrap();
    bool isImprinting = myStdWidget->myImprinting->currentIndex();
    bool isSnapping   = myStdWidget->mySnapping->currentIndex();
    tab->setTabEnabled( FACE_SEL_LAYERS_TAB,     !isGlobal );
    tab->setTabEnabled( FACE_SEL_IMPRINTING_TAB, isImprinting );
    tab->setTabEnabled( FACE_SEL_SNAPPING_TAB,   isSnapping );
  }
}

bool HYBRIDPluginGUI_HypothesisCreator::checkParams(QString& msg) const
{

  if ( !QFileInfo( myAdvWidget->workingDirectoryLineEdit->text().trimmed() ).isWritable() ) {
    SUIT_MessageBox::warning( dlg(),
                              tr( "SMESH_WRN_WARNING" ),
                              tr( "HYBRID_PERMISSION_DENIED" ) );
    return false;
  }

  HYBRIDPlugin::HYBRIDPlugin_Hypothesis_var h =
    HYBRIDPlugin::HYBRIDPlugin_Hypothesis::_narrow( hypothesis() );

  myAdvWidget->myOptionTable->setFocus();
  QApplication::instance()->processEvents();

  QString name, value;
  bool isDefault, ok = true;
  int iRow = 0, nbRows = myAdvWidget->myOptionTable->topLevelItemCount();
  for ( ; iRow < nbRows; ++iRow )
  {
    QTreeWidgetItem* row = myAdvWidget->myOptionTable->topLevelItem( iRow );
    myAdvWidget->GetOptionAndValue( row, name, value, isDefault );

    if ( name.simplified().isEmpty() )
      continue; // invalid custom option

    if ( isDefault ) // not selected option
      value.clear();

    try {
      h->SetOptionValue( name.toLatin1().constData(), value.toLatin1().constData() );
    }
    catch ( const SALOME_CMOD::SALOME_Exception& ex )
    {
      msg = ex.details.text.in();
      ok = false;
      break;
    }
  }

  if ( !ok )
  {
    h->SetOptionValues( myOptions ); // restore values
  }

  return ok;
}

void HYBRIDPluginGUI_HypothesisCreator::retrieveParams() const
{
  HYBRIDPluginGUI_HypothesisCreator* that = (HYBRIDPluginGUI_HypothesisCreator*)this;
  HYBRIDHypothesisData data;
  readParamsFromHypo( data );

  if ( myName )
    myName->setText( data.myName );
  myStdWidget->SetLayersOnAllWrap( data.myLayersOnAllWrap );

  myStdWidget->myNbOfBoundaryLayers        ->setValue( data.myNbOfBoundaryLayers );
  myStdWidget                              ->SetLayersOnAllWrap( data.myLayersOnAllWrap );
  myStdWidget->myHeightFirstLayer          ->setValue( data.myHeightFirstLayer );
  myStdWidget->myHeightIsRelative          ->setCurrentIndex( data.myHeightIsRelative );
  myStdWidget->myBoundaryLayersGrowth      ->setCurrentIndex( data.myBoundaryLayersGrowth );
  myStdWidget->myBoundaryLayersMaxElemAngle->setValue( data.myBoundaryLayersMaxElemAngle );
  myStdWidget->myBoundaryLayersProgression ->setValue( data.myBoundaryLayersProgression );
  myStdWidget->myImprinting                ->setCurrentIndex( data.myImprinting );
  myStdWidget->mySnapping                  ->setCurrentIndex( data.mySnapping );
  myStdWidget->myElementGeneration         ->setCurrentIndex( data.myElementGeneration );
  if (data.myCoreSize <= 0)
    myStdWidget->myCoreSize->setText("");
  else
    myStdWidget->myCoreSize->setValue( data.myCoreSize );
  myStdWidget->myCoreSizeEnabled->setChecked( data.myCoreSize > 0 );

  myFaceSelectorLayers            ->SetListOfIDs( data.myFaceWLIds );
  myFaceSelectorImprinting        ->SetListOfIDs( data.myFaceWIIds );
  myFaceSelectorSnapping          ->SetListOfIDs( data.myFaceWSIds );

  myAdvWidget->workingDirectoryLineEdit       ->setText   ( data.myWorkingDir );
  myAdvWidget->keepWorkingFilesCheck          ->setChecked( data.myKeepFiles );
  myAdvWidget->verboseLevelSpin               ->setValue  ( data.myVerboseLevel );
  myAdvWidget->logInFileCheck                 ->setChecked( !data.myLogInStandardOutput );
  myAdvWidget->removeLogOnSuccessCheck        ->setChecked( data.myRemoveLogOnSuccess );
  myAdvWidget->useLibraryCheck                ->setChecked( data.myUseLib );

  if ( myOptions.operator->() ) {
    for ( int i = 0, nb = myOptions->length(); i < nb; ++i )
      myAdvWidget->AddOption( that->myOptions[i].in() );
  }
  if ( myCustomOptions.operator->() ) {
    for ( int i = 0, nb = myCustomOptions->length(); i < nb; ++i )
      myAdvWidget->AddOption( that->myCustomOptions[i].in() );
  }
  myAdvWidget->myOptionTable->resizeColumnToContents( OPTION_NAME_COLUMN );

  TEnfVertexList::const_iterator it;
  int rowCount = 0;
  myEnforcedTableWidget->clearContents();
  myEnforcedTableWidget->setSortingEnabled(false);
  myEnforcedTableWidget->disconnect(SIGNAL( itemChanged(QTableWidgetItem *)));
  for(it = data.myEnforcedVertices.begin() ; it != data.myEnforcedVertices.end(); it++ )
  {
    TEnfVertex* enfVertex = (*it);
    myEnforcedTableWidget->setRowCount(rowCount+1);

    for (int col=0;col<ENF_VER_NB_COLUMNS;col++) {
      QTableWidgetItem* item = new QTableWidgetItem();
      item->setFlags( Qt::ItemIsSelectable | Qt::ItemIsEditable | Qt::ItemIsEnabled);
      switch (col) {
        case ENF_VER_NAME_COLUMN:
          item->setData( 0, enfVertex->name.c_str() );
          if (!enfVertex->geomEntry.empty()) {
            if (enfVertex->isCompound)
              item->setIcon(QIcon(iconCompound.scaled(iconCompound.size()*0.7,Qt::KeepAspectRatio,Qt::SmoothTransformation)));
            else
              item->setIcon(QIcon(iconVertex.scaled(iconVertex.size()*0.7,Qt::KeepAspectRatio,Qt::SmoothTransformation)));
            
          }
          break;
        case ENF_VER_X_COLUMN:
          if (!enfVertex->isCompound) {
            item->setData( 0, enfVertex->coords.at(0) );
          }
          break;
        case ENF_VER_Y_COLUMN:
          if (!enfVertex->isCompound) {
            item->setData( 0, enfVertex->coords.at(1) );
          }
          break;
        case ENF_VER_Z_COLUMN:
          if (!enfVertex->isCompound) {
            item->setData( 0, enfVertex->coords.at(2) );
          }
          break;
        case ENF_VER_SIZE_COLUMN:
          item->setData( 0, enfVertex->size );
          break;
        case ENF_VER_ENTRY_COLUMN:
          item->setData( 0, enfVertex->geomEntry.c_str() );
          break;
        case ENF_VER_COMPOUND_COLUMN:
          item->setFlags(Qt::ItemIsSelectable | Qt::ItemIsUserCheckable);
          item->setData( Qt::CheckStateRole, enfVertex->isCompound );
          break;
        case ENF_VER_GROUP_COLUMN:
          item->setData( 0, enfVertex->groupName.c_str() );
          break;
        default:
          break;
      }
      
      myEnforcedTableWidget->setItem(rowCount,col,item);
    }
    that->updateEnforcedVertexValues(myEnforcedTableWidget->item(rowCount,ENF_VER_NAME_COLUMN));
    rowCount++;
  }

  connect( myEnforcedTableWidget,SIGNAL( itemChanged(QTableWidgetItem *)), this,  SLOT( updateEnforcedVertexValues(QTableWidgetItem *) ) );
  myEnforcedTableWidget->setSortingEnabled(true);
  
  for (int column = 0; column < myEnforcedTableWidget->columnCount(); ++column)
    myEnforcedTableWidget->resizeColumnToContents(column);

  // Update Enforced meshes QTableWidget
  TEnfMeshList::const_iterator itMesh;
  rowCount = 0;
  myEnforcedMeshTableWidget->clearContents();
  myEnforcedMeshTableWidget->setSortingEnabled(false);
//   myEnforcedMeshTableWidget->disconnect(SIGNAL( itemChanged(QTableWidgetItem *)));
  for(itMesh = data.myEnforcedMeshes.begin() ; itMesh != data.myEnforcedMeshes.end(); itMesh++ )
  {
    TEnfMesh* enfMesh = (*itMesh);
    myEnforcedMeshTableWidget->setRowCount(rowCount+1);

    for (int col=0;col<ENF_MESH_NB_COLUMNS;col++) {
      if (col == ENF_MESH_CONSTRAINT_COLUMN) {
        QComboBox* comboBox = new QComboBox();
        QPalette pal = comboBox->palette();
        pal.setColor(QPalette::Button, Qt::white);
        comboBox->setPalette(pal);
        comboBox->insertItems(0,myEnfMeshConstraintLabels);
        comboBox->setEditable(false);
        comboBox->setCurrentIndex(enfMesh->elementType);
        myEnforcedMeshTableWidget->setCellWidget(rowCount,col,comboBox);
      }
      else {
        QTableWidgetItem* item = new QTableWidgetItem();
        item->setFlags( Qt::ItemIsSelectable | Qt::ItemIsEditable | Qt::ItemIsEnabled);
        switch (col) {
          case ENF_MESH_NAME_COLUMN:
            item->setData( 0, enfMesh->name.c_str() );
            item->setFlags( Qt::ItemIsSelectable | Qt::ItemIsEnabled);
            myEnforcedMeshTableWidget->setItem(rowCount,col,item);
            break;
          case ENF_MESH_ENTRY_COLUMN:
            item->setData( 0, enfMesh->entry.c_str() );
            item->setFlags( Qt::ItemIsSelectable | Qt::ItemIsEnabled);
            myEnforcedMeshTableWidget->setItem(rowCount,col,item);
            break;
          case ENF_MESH_GROUP_COLUMN:
            item->setData( 0, enfMesh->groupName.c_str() );
            myEnforcedMeshTableWidget->setItem(rowCount,col,item);
            break;
          default:
            break;
        }
      }
      
//       myEnforcedMeshTableWidget->setItem(rowCount,col,item);
    }
//     that->updateEnforcedVertexValues(myEnforcedTableWidget->item(rowCount,ENF_VER_NAME_COLUMN));
    rowCount++;
  }

//   connect( myEnforcedMeshTableWidget,SIGNAL( itemChanged(QTableWidgetItem *)), this,  SLOT( updateEnforcedVertexValues(QTableWidgetItem *) ) );
  myEnforcedMeshTableWidget->setSortingEnabled(true);
  
  for (int col=0;col<ENF_MESH_NB_COLUMNS;col++)
    myEnforcedMeshTableWidget->resizeColumnToContents(col);
  
  that->updateWidgets();
  that->checkVertexIsDefined();
}

QString HYBRIDPluginGUI_HypothesisCreator::storeParams() const
{
  HYBRIDHypothesisData data;
  readParamsFromWidgets( data );
  storeParamsToHypo( data );

  QString valStr = "";
  return valStr;
}

bool HYBRIDPluginGUI_HypothesisCreator::readParamsFromHypo( HYBRIDHypothesisData& h_data ) const
{
  HYBRIDPlugin::HYBRIDPlugin_Hypothesis_var h =
    HYBRIDPlugin::HYBRIDPlugin_Hypothesis::_narrow( initParamsHypothesis() );

  HypothesisData* data = SMESH::GetHypothesisData( hypType() );
  h_data.myName = isCreation() && data ? hypName() : "";

  h_data.myNbOfBoundaryLayers         = h->GetNbOfBoundaryLayers();
  h_data.myLayersOnAllWrap            = h->GetLayersOnAllWrap();
  h_data.myHeightFirstLayer           = h->GetHeightFirstLayer();
  h_data.myHeightIsRelative           = h->GetHeightIsRelative();
  h_data.myBoundaryLayersGrowth       = h->GetBoundaryLayersGrowth();
  h_data.myBoundaryLayersMaxElemAngle = h->GetBoundaryLayersMaxElemAngle();
  h_data.myBoundaryLayersProgression  = h->GetBoundaryLayersProgression();
  h_data.myElementGeneration          = h->GetElementGeneration();
  h_data.myCoreSize                   = h->GetCoreSize();
  
  h_data.myFaceWLIds                  = h->GetFacesWithLayers();
  h_data.myFaceWIIds                  = h->GetFacesWithImprinting();
  h_data.myFaceWSIds                  = h->GetFacesWithSnapping();
  h_data.myImprinting                 = h_data.myFaceWIIds->length();//h->GetImprinting();
  h_data.mySnapping                   = h_data.myFaceWSIds->length();//h->GetSnapping();

  h_data.myCollisionMode              = h->GetCollisionMode();
  h_data.myOptimizationLevel          = h->GetOptimizationLevel();

  h_data.myKeepFiles                  = h->GetKeepFiles();
  h_data.myWorkingDir                 = h->GetWorkingDirectory();
  h_data.myVerboseLevel               = h->GetVerboseLevel();
  h_data.myLogInStandardOutput        = h->GetStandardOutputLog();
  h_data.myRemoveLogOnSuccess         = h->GetRemoveLogOnSuccess();
  h_data.myUseLib                     = h->GetToUseLibrary();

  HYBRIDPluginGUI_HypothesisCreator* that = (HYBRIDPluginGUI_HypothesisCreator*)this;
  that->myOptions       = h->GetOptionValues();
  that->myCustomOptions = h->GetAdvancedOptionValues();


  HYBRIDPlugin::HYBRIDEnforcedVertexList_var vertices = h->GetEnforcedVertices();
  h_data.myEnforcedVertices.clear();
  for (CORBA::ULong i=0 ; i<vertices->length() ; i++) {
    TEnfVertex* myVertex = new TEnfVertex();
    myVertex->name = CORBA::string_dup(vertices[i].name.in());
    myVertex->geomEntry = CORBA::string_dup(vertices[i].geomEntry.in());
    myVertex->groupName = CORBA::string_dup(vertices[i].groupName.in());
    myVertex->size = vertices[i].size;
    myVertex->isCompound = vertices[i].isCompound;
    if (vertices[i].coords.length()) {
      for (CORBA::ULong c = 0; c < vertices[i].coords.length() ; c++)
        myVertex->coords.push_back(vertices[i].coords[c]);
    }
    h_data.myEnforcedVertices.insert(myVertex);
  }
  
  HYBRIDPlugin::HYBRIDEnforcedMeshList_var enfMeshes = h->GetEnforcedMeshes();
  h_data.myEnforcedMeshes.clear();
  for (CORBA::ULong i=0 ; i<enfMeshes->length() ; i++) {
    TEnfMesh* myEnfMesh = new TEnfMesh();
    myEnfMesh->name = CORBA::string_dup(enfMeshes[i].name.in());
    myEnfMesh->entry = CORBA::string_dup(enfMeshes[i].entry.in());
    myEnfMesh->groupName = CORBA::string_dup(enfMeshes[i].groupName.in());
    switch (enfMeshes[i].elementType) {
      case SMESH::NODE:
        myEnfMesh->elementType = 0;
        break;
      case SMESH::EDGE:
        myEnfMesh->elementType = 1;
        break;
      case SMESH::FACE:
        myEnfMesh->elementType = 2;
        break;
      default:
        break;
    }
//     myEnfMesh->elementType = enfMeshes[i].elementType;
    h_data.myEnforcedMeshes.insert(myEnfMesh);
  }
  return true;
}

bool HYBRIDPluginGUI_HypothesisCreator::storeParamsToHypo( const HYBRIDHypothesisData& h_data ) const
{
  HYBRIDPlugin::HYBRIDPlugin_Hypothesis_var h =
    HYBRIDPlugin::HYBRIDPlugin_Hypothesis::_narrow( hypothesis() );

  bool ok = true;
  try
  {
    if( isCreation() )
      SMESH::SetName( SMESH::FindSObject( h ), h_data.myName.toLatin1().constData() );

    if ( h->GetNbOfBoundaryLayers() != h_data.myNbOfBoundaryLayers )
      h->SetNbOfBoundaryLayers       ( h_data.myNbOfBoundaryLayers );
    if ( h->GetLayersOnAllWrap() != h_data.myLayersOnAllWrap ) // avoid duplication of DumpPython commands
      h->SetLayersOnAllWrap ( h_data.myLayersOnAllWrap );
    if ( h->GetHeightFirstLayer() != h_data.myHeightFirstLayer )
      h->SetHeightFirstLayer       ( h_data.myHeightFirstLayer );
    h->SetHeightIsRelative( h_data.myHeightIsRelative );
    if ( h->GetBoundaryLayersGrowth() != h_data.myBoundaryLayersGrowth )
      h->SetBoundaryLayersGrowth(        h_data.myBoundaryLayersGrowth );
    h->SetBoundaryLayersMaxElemAngle( h_data.myBoundaryLayersMaxElemAngle );
    if ( h->GetBoundaryLayersProgression() != h_data.myBoundaryLayersProgression )
      h->SetBoundaryLayersProgression       ( h_data.myBoundaryLayersProgression );
    if ( h->GetElementGeneration() != h_data.myElementGeneration )
      h->SetElementGeneration(        h_data.myElementGeneration );
    if ( h->GetCoreSize() != h_data.myCoreSize )
      h->SetCoreSize       ( h_data.myCoreSize );

    // if ( h->GetOptimizationLevel() != h_data.myOptimizationLevel )
    //   h->SetOptimizationLevel( h_data.myOptimizationLevel );
    // if ( h->GetCollisionMode() != h_data.myCollisionMode )
    //   h->SetCollisionMode(        h_data.myCollisionMode );

    h->SetFacesWithLayers( h_data.myFaceWLIds );
    h->SetFacesWithImprinting( h_data.myFaceWIIds );
    h->SetFacesWithSnapping( h_data.myFaceWSIds );

    if ( h->GetKeepFiles() != h_data.myKeepFiles)
      h->SetKeepFiles       ( h_data.myKeepFiles);
    if ( h->GetWorkingDirectory() != h_data.myWorkingDir )
      h->SetWorkingDirectory       ( h_data.myWorkingDir.toLatin1().constData() );
    if ( h->GetVerboseLevel() != h_data.myVerboseLevel )
      h->SetVerboseLevel       ( h_data.myVerboseLevel );
    if ( h->GetStandardOutputLog() != h_data.myLogInStandardOutput )
      h->SetStandardOutputLog       ( h_data.myLogInStandardOutput );
    if ( h->GetRemoveLogOnSuccess() != h_data.myRemoveLogOnSuccess )
      h->SetRemoveLogOnSuccess        ( h_data.myRemoveLogOnSuccess );
    if ( h->GetToUseLibrary() != h_data.myUseLib )
      h->SetToUseLibrary        ( h_data.myUseLib );
    
    // Enforced vertices
    //int nbVertex = (int) h_data.myEnforcedVertices.size();
    HYBRIDPlugin::HYBRIDEnforcedVertexList_var vertexHyp = h->GetEnforcedVertices();
    int nbVertexHyp = vertexHyp->length();
    
    
    // 1. Clear all enforced vertices in hypothesis
    // 2. Add new enforced vertex according to h_data
    if ( nbVertexHyp > 0)
      h->ClearEnforcedVertices();
    
    TEnfVertexList::const_iterator it;
    double x = 0, y = 0, z = 0;
    for(it = h_data.myEnforcedVertices.begin() ; it != h_data.myEnforcedVertices.end(); it++ ) {
      TEnfVertex* enfVertex = (*it);
      x =y =z = 0;
      if (enfVertex->coords.size()) {
        x = enfVertex->coords.at(0);
        y = enfVertex->coords.at(1);
        z = enfVertex->coords.at(2);
      }
      ok = h->p_SetEnforcedVertex( enfVertex->size, x, y, z, enfVertex->name.c_str(), enfVertex->geomEntry.c_str(), enfVertex->groupName.c_str(), enfVertex->isCompound);
    } // for
    
    // Enforced Meshes
    //int nbEnfMeshes = (int) h_data.myEnforcedMeshes.size();
    HYBRIDPlugin::HYBRIDEnforcedMeshList_var enfMeshListHyp = h->GetEnforcedMeshes();
    int nbEnfMeshListHyp = enfMeshListHyp->length();
    
    
    // 1. Clear all enforced vertices in hypothesis
    // 2. Add new enforced vertex according to h_data
    if ( nbEnfMeshListHyp > 0)
      h->ClearEnforcedMeshes();
    
    TEnfMeshList::const_iterator itEnfMesh;

    _PTR(Study) aStudy = SMESH::getStudy();

    for(itEnfMesh = h_data.myEnforcedMeshes.begin() ; itEnfMesh != h_data.myEnforcedMeshes.end(); itEnfMesh++ ) {
      TEnfMesh* enfMesh = (*itEnfMesh);

      _PTR(SObject) aSObj = aStudy->FindObjectID(enfMesh->entry.c_str());
      SMESH::SMESH_IDSource_var theSource = SMESH::SObjectToInterface<SMESH::SMESH_IDSource>( aSObj );

      SMESH::ElementType elementType = SMESH::NODE;
      switch(enfMesh->elementType) {
        case 0:
          elementType = SMESH::NODE;
          break;
        case 1:
          elementType = SMESH::EDGE;
          break;
        case 2:
          elementType = SMESH::FACE;
          break;
        default:
          break;
      }
    
      ok = h->p_SetEnforcedMesh(theSource, elementType, enfMesh->name.c_str(), enfMesh->groupName.c_str());
    } // for
  } // try
//   catch(const std::exception& ex) {
//     std::cout << "Exception: " << ex.what() << std::endl;
//     throw ex;
//   }
  catch ( const SALOME_CMOD::SALOME_Exception& ex )
  {
    SalomeApp_Tools::QtCatchCorbaException( ex );
    ok = false;
  }
  return ok;
}

bool HYBRIDPluginGUI_HypothesisCreator::readParamsFromWidgets( HYBRIDHypothesisData& h_data ) const
{
  h_data.myName                       = myName ? myName->text() : "";
  h_data.myNbOfBoundaryLayers         = myStdWidget->myNbOfBoundaryLayers -> value();
  h_data.myLayersOnAllWrap            = myStdWidget->GetLayersOnAllWrap();
  h_data.myHeightFirstLayer           = myStdWidget->myHeightFirstLayer -> value();
  h_data.myHeightIsRelative           = myStdWidget->myHeightIsRelative->currentIndex();
  h_data.myBoundaryLayersGrowth       = myStdWidget->myBoundaryLayersGrowth->currentIndex();
  h_data.myBoundaryLayersMaxElemAngle = myStdWidget->myBoundaryLayersMaxElemAngle->value();
  h_data.myBoundaryLayersProgression  = myStdWidget->myBoundaryLayersProgression -> value();
  h_data.myElementGeneration          = myStdWidget->myElementGeneration->currentIndex();
  h_data.myCoreSize                   = myStdWidget->myCoreSizeEnabled->isChecked() ? myStdWidget->myCoreSize -> value() : 0;

  h_data.myFaceWLIds                  = myFaceSelectorLayers->GetListOfIDs();
  h_data.myFaceWIIds                  = myFaceSelectorImprinting->GetListOfIDs();
  h_data.myFaceWSIds                  = myFaceSelectorSnapping->GetListOfIDs();

  h_data.myKeepFiles                  = myAdvWidget->keepWorkingFilesCheck->isChecked();
  h_data.myWorkingDir                 = myAdvWidget->workingDirectoryLineEdit->text().trimmed();
  h_data.myVerboseLevel               = myAdvWidget->verboseLevelSpin->value();
  h_data.myLogInStandardOutput        = !myAdvWidget->logInFileCheck->isChecked();
  h_data.myRemoveLogOnSuccess         = myAdvWidget->removeLogOnSuccessCheck->isChecked();
  h_data.myUseLib                     = myAdvWidget->useLibraryCheck->isChecked();

  // Enforced vertices
  h_data.myEnforcedVertices.clear();
  QVariant valueX, valueY, valueZ;
  for (int row=0 ; row<myEnforcedTableWidget->rowCount() ; row++) {
    
    TEnfVertex *myVertex = new TEnfVertex();
    myVertex->name = myEnforcedTableWidget->item(row,ENF_VER_NAME_COLUMN)->data(Qt::EditRole).toString().toStdString();
    myVertex->geomEntry = myEnforcedTableWidget->item(row,ENF_VER_ENTRY_COLUMN)->data(Qt::EditRole).toString().toStdString();
    if (myVertex->geomEntry.size())
    myVertex->groupName = myEnforcedTableWidget->item(row,ENF_VER_GROUP_COLUMN)->data(Qt::EditRole).toString().toStdString();
    if (myVertex->groupName.size())
    valueX = myEnforcedTableWidget->item(row,ENF_VER_X_COLUMN)->data(Qt::EditRole);
    valueY = myEnforcedTableWidget->item(row,ENF_VER_Y_COLUMN)->data(Qt::EditRole);
    valueZ = myEnforcedTableWidget->item(row,ENF_VER_Z_COLUMN)->data(Qt::EditRole);
    if (!valueX.isNull() && !valueY.isNull() && !valueZ.isNull()) {
      myVertex->coords.push_back(valueX.toDouble());
      myVertex->coords.push_back(valueY.toDouble());
      myVertex->coords.push_back(valueZ.toDouble());
    }
    myVertex->size = myEnforcedTableWidget->item(row,ENF_VER_SIZE_COLUMN)->data(Qt::EditRole).toDouble();
    myVertex->isCompound = myEnforcedTableWidget->item(row,ENF_VER_COMPOUND_COLUMN)->data(Qt::CheckStateRole).toBool();
    h_data.myEnforcedVertices.insert(myVertex);
  }
  
  // Enforced meshes
  h_data.myEnforcedMeshes.clear();

  for (int row=0 ; row<myEnforcedMeshTableWidget->rowCount() ; row++) {
    
    TEnfMesh *myEnfMesh = new TEnfMesh();
    myEnfMesh->name = myEnforcedMeshTableWidget->item(row,ENF_MESH_NAME_COLUMN)->data(Qt::EditRole).toString().toStdString();
    myEnfMesh->entry = myEnforcedMeshTableWidget->item(row,ENF_MESH_ENTRY_COLUMN)->data(Qt::EditRole).toString().toStdString();
    myEnfMesh->groupName = myEnforcedMeshTableWidget->item(row,ENF_MESH_GROUP_COLUMN)->data(Qt::EditRole).toString().toStdString();
    QComboBox* combo = qobject_cast<QComboBox*>(myEnforcedMeshTableWidget->cellWidget(row,ENF_MESH_CONSTRAINT_COLUMN));
    myEnfMesh->elementType = combo->currentIndex();
    h_data.myEnforcedMeshes.insert(myEnfMesh);
  }

  return true;
}

QString HYBRIDPluginGUI_HypothesisCreator::caption() const
{
  return tr( "HYBRID_TITLE" );
}

QPixmap HYBRIDPluginGUI_HypothesisCreator::icon() const
{
  return SUIT_Session::session()->resourceMgr()->loadPixmap( "HYBRIDPlugin", tr( "ICON_DLG_HYBRID_PARAMETERS" ) );
}

QString HYBRIDPluginGUI_HypothesisCreator::type() const
{
  return tr( "HYBRID_HYPOTHESIS" );
}

QString HYBRIDPluginGUI_HypothesisCreator::helpPage() const
{
  return "hybrid_hypo_page.html";
}

void HYBRIDPluginGUI_HypothesisCreator::onAddOption()
{
  myAdvWidget->AddOption( NULL, true );
}
