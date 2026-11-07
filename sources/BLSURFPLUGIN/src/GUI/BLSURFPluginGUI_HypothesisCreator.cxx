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
// File    : BLSURFPluginGUI_HypothesisCreator.cxx
// Authors : Francis KLOSS (OCC) & Patrick LAUG (INRIA) & Lioka RAZAFINDRAZAKA (CEA)
//           & Aurelien ALLEAUME (DISTENE)
//           Size maps developement: Nicolas GEIMER (OCC) & Gilles DAVID (EURIWARE)
// ---
//
#include "BLSURFPluginGUI_HypothesisCreator.h"
#include "BLSURFPluginGUI_Dlg.h"
#include "BLSURFPlugin_Hypothesis.hxx"

#include <GeometryGUI.h>

#include <SMESHGUI_Dialog.h>
#include <SMESHGUI_HypothesesUtils.h>
#include <SMESHGUI_IdValidator.h>
#include <SMESHGUI_SpinBox.h>
#include <SMESHGUI_Utils.h>
#include <SMESH_Gen_i.hxx>
#include <SMESH_NumberFilter.hxx>
#include <StdMeshersGUI_SubShapeSelectorWdg.h>

#include <LightApp_SelectionMgr.h>
#include <SALOME_ListIO.hxx>
#include <SUIT_MessageBox.h>
#include <SUIT_ResourceMgr.h>
#include <SUIT_Session.h>
#include <SalomeApp_Application.h>
#include <SalomeApp_Tools.h>

#include <QApplication>
#include <QCheckBox>
#include <QComboBox>
#include <QFrame>
#include <QGridLayout>
#include <QGroupBox>
#include <QHBoxLayout>
#include <QHeaderView>
#include <QLabel>
#include <QLineEdit>
#include <QMenu>
#include <QModelIndexList>
#include <QObject>
#include <QPushButton>
#include <QRadioButton>
#include <QSpinBox>
#include <QSplitter>
#include <QStandardItem>
#include <QStandardItemModel>
#include <QTabWidget>
#include <QTableWidget>
#include <QTreeWidget>
#include <QTreeWidgetItem>
#include <QVBoxLayout>

#include <TopoDS_Shape.hxx>
#include <TopoDS_Iterator.hxx>

#include <structmember.h> // Python

using namespace std;

enum {
  STD_TAB = 0,
  ADV_TAB,
  SMP_TAB,
  ENF_V_TAB,
  ENF_M_TAB,
  PERIODICITY_TAB,
  HYPERPATCH_TAB,
  SMP_NAME_COLUMN =0,
  SMP_SIZEMAP_COLUMN,
  SMP_ENTRY_COLUMN,
//  SMP_DIST_COLUMN,
  SMP_NB_COLUMNS,

  // Adv tables
  TBL_MESHING = 0, TBL_PRECAD, TBL_CUSTOM,

  // Enforced vertices array columns
  ENF_VER_NAME_COLUMN = 0,
  ENF_VER_FACE_ENTRY_COLUMN,
  ENF_VER_X_COLUMN,
  ENF_VER_Y_COLUMN,
  ENF_VER_Z_COLUMN,
  ENF_VER_ENTRY_COLUMN,
  ENF_VER_GROUP_COLUMN,
  ENF_VER_NB_COLUMNS,

  // Enforced 1D meshes
  ENF_MESH_NB_COLUMNS = 2,

  // Periodicity
  PERIODICITY_OBJ_SOURCE_COLUMN = 0,
  PERIODICITY_OBJ_TARGET_COLUMN,
  PERIODICITY_P1_SOURCE_COLUMN,
  PERIODICITY_P2_SOURCE_COLUMN,
  PERIODICITY_P3_SOURCE_COLUMN,
  PERIODICITY_P1_TARGET_COLUMN,
  PERIODICITY_P2_TARGET_COLUMN,
  PERIODICITY_P3_TARGET_COLUMN,
  PERIODICITY_SHAPE_TYPE,

//  PERIODICITY_OBJ_SOURCE_COLUMN = 0,
//  PERIODICITY_ENTRY_SOURCE_COLUMN,
//  PERIODICITY_OBJ_TARGET_COLUMN,
//  PERIODICITY_ENTRY_TARGET_COLUMN,
//  PERIODICITY_P1_SOURCE_COLUMN,
//  PERIODICITY_P1_ENTRY_SOURCE_COLUMN,
//  PERIODICITY_P2_SOURCE_COLUMN,
//  PERIODICITY_P2_ENTRY_SOURCE_COLUMN,
//  PERIODICITY_P3_SOURCE_COLUMN,
//  PERIODICITY_P3_ENTRY_SOURCE_COLUMN,
//  PERIODICITY_P1_TARGET_COLUMN,
//  PERIODICITY_P1_ENTRY_TARGET_COLUMN,
//  PERIODICITY_P2_TARGET_COLUMN,
//  PERIODICITY_P2_ENTRY_TARGET_COLUMN,
//  PERIODICITY_P3_TARGET_COLUMN,
//  PERIODICITY_P3_ENTRY_TARGET_COLUMN,

  PERIODICITY_NB_COLUMN
};

enum {
  SMP_TAB_WDG,
  SMP_ADD_BTN,
  SMP_NB_LINES,
  SMP_STD_TAB = 0,
  ATT_TAB,
  SMP_GEOM_BTN_2 = 0,
  ATT_CHECK,
  CONST_SIZE_CHECK,
  SMP_SPACE,
//   SMP_PARAMS,
  SMP_ATT_SHAPE, 
  SMP_ATT_SIZE,
  SMP_ATT_DIST,
  SMP_ATT_RAD
};
  
enum {
  SMP_GEOM_BTN_1,
  SMP_SIZE,
  SMP_SPACE2,
};

// Enforced vertices inputs
enum {
  ENF_VER_FACE = 0,
  ENF_VER_VERTEX = 0,
  ENF_VER_X_COORD,
  ENF_VER_Y_COORD,
  ENF_VER_Z_COORD,
  ENF_VER_GROUP,
//   ENF_VER_GROUP_CHECK,
//   ENF_VER_SPACE,
  ENF_VER_BTN,
  ENF_VER_SEPARATOR,
  ENF_VER_INTERNAL_ALL_FACES,
  ENF_VER_INTERNAL_ALL_FACES_GROUP,
//   ENF_VER_VERTEX_BTN,
//   ENF_VER_REMOVE_BTN,
//   ENF_VER_SEPARATOR,
  ENF_VER_NB_LINES
};


/**************************************************
 Begin initialization Python structures and objects
***************************************************/

namespace {
  typedef struct {
    PyObject_HEAD
    int softspace;
    std::string *out;
    } PyStdOut;

  static void
  PyStdOut_dealloc(PyStdOut *self)
  {
    PyObject_Del(self);
  }

  static PyObject *
  PyStdOut_write(PyStdOut *self, PyObject *args)
  {
    char *c;
    int l;
    if (!PyArg_ParseTuple(args, "t#:write",&c, &l))
      return NULL;

    *(self->out)=*(self->out)+c;

    Py_INCREF(Py_None);
    return Py_None;
  }

  static PyMethodDef PyStdOut_methods[] = {
    {"write",  (PyCFunction)PyStdOut_write,  METH_VARARGS,
    PyDoc_STR("write(string) -> None")},
    {0, 0, 0, 0}   /* sentinel */
  };

  static PyMemberDef PyStdOut_memberlist[] = {
    {(char*)"softspace", T_INT,  offsetof(PyStdOut, softspace), 0,
     (char*)"flag indicating that a space needs to be printed; used by print"},
    {0, 0, 0, 0, 0} /* Sentinel */
  };

  static PyTypeObject PyStdOut_Type = {
    /* The ob_type field must be initialized in the module init function
     * to be portable to Windows without using C++. */
    PyVarObject_HEAD_INIT(NULL, 0)
    "PyOut",                      /*tp_name*/
    sizeof(PyStdOut),             /*tp_basicsize*/
    0,                            /*tp_itemsize*/
    /* methods */
    (destructor)PyStdOut_dealloc, /*tp_dealloc*/
    0,                            /*tp_print*/
    0,                            /*tp_getattr*/
    0,                            /*tp_setattr*/
    0,                            /*tp_compare*/
    0,                            /*tp_repr*/
    0,                            /*tp_as_number*/
    0,                            /*tp_as_sequence*/
    0,                            /*tp_as_mapping*/
    0,                            /*tp_hash*/
    0,                            /*tp_call*/
    0,                            /*tp_str*/
    PyObject_GenericGetAttr,      /*tp_getattro*/
    /* softspace is writable:  we must supply tp_setattro */
    PyObject_GenericSetAttr,      /* tp_setattro */
    0,                            /*tp_as_buffer*/
    Py_TPFLAGS_DEFAULT,           /*tp_flags*/
    0,                            /*tp_doc*/
    0,                            /*tp_traverse*/
    0,                            /*tp_clear*/
    0,                            /*tp_richcompare*/
    0,                            /*tp_weaklistoffset*/
    0,                            /*tp_iter*/
    0,                            /*tp_iternext*/
    PyStdOut_methods,             /*tp_methods*/
    PyStdOut_memberlist,          /*tp_members*/
    0,                            /*tp_getset*/
    0,                            /*tp_base*/
    0,                            /*tp_dict*/
    0,                            /*tp_descr_get*/
    0,                            /*tp_descr_set*/
    0,                            /*tp_dictoffset*/
    0,                            /*tp_init*/
    0,                            /*tp_alloc*/
    0,                            /*tp_new*/
    0,                            /*tp_free*/
    0,                            /*tp_is_gc*/
    0,                            /*tp_bases*/
    0,                            /*tp_mro*/
    0,                            /*tp_cache*/
    0,                            /*tp_subclasses*/
    0,                            /*tp_weaklist*/
    0,                            /*tp_del*/
    0,                            /*tp_version_tag*/
    0,                            /*tp_finalize*/
  };

  PyObject * newPyStdOut( std::string& out )
  {
    PyStdOut* self = PyObject_New(PyStdOut, &PyStdOut_Type);
    if (self) {
      self->softspace = 0;
      self->out=&out;
    }
    return (PyObject*)self;
  }
}

/*************************************************
End initialization Python structures and objects
**************************************************/


//
// BEGIN EnforcedTreeWidgetDelegate
//

EnforcedTreeWidgetDelegate::EnforcedTreeWidgetDelegate(QObject *parent)
  : QItemDelegate(parent)
{
}

QWidget *EnforcedTreeWidgetDelegate::createEditor(QWidget *parent,
                                              const QStyleOptionViewItem & /*option*/ ,
                                              const QModelIndex & index ) const
{
  QModelIndex father = index.parent();
  QString entry = father.child(index.row(), ENF_VER_ENTRY_COLUMN).data(Qt::EditRole).toString();
  
  if (index.column() == ENF_VER_X_COLUMN || \
      index.column() == ENF_VER_Y_COLUMN || \
      index.column() == ENF_VER_Z_COLUMN)
  {
    SMESHGUI_SpinBox *editor = new SMESHGUI_SpinBox(parent);
    editor->RangeStepAndValidator(COORD_MIN, COORD_MAX, 10.0, "length_precision");
    editor->setReadOnly(!entry.isEmpty());
    editor->setDisabled(!entry.isEmpty());
    return editor;
  }
  else
  {
    QLineEdit *editor = new QLineEdit(parent);
    if (index.column() != ENF_VER_GROUP_COLUMN) {
      editor->setReadOnly(!entry.isEmpty());
      editor->setDisabled(!entry.isEmpty());
    }
    return editor;
  }
}

void EnforcedTreeWidgetDelegate::setEditorData(QWidget *editor,
                                           const QModelIndex &index) const
{
  QString value = index.model()->data(index, Qt::EditRole).toString();

  if (index.column() == ENF_VER_X_COLUMN ||
      index.column() == ENF_VER_Y_COLUMN ||
      index.column() == ENF_VER_Z_COLUMN)
  {
    SMESHGUI_SpinBox *lineEdit = static_cast<SMESHGUI_SpinBox*>(editor);
    lineEdit->setText(value);
  }
  else {
    QLineEdit *lineEdit = static_cast<QLineEdit*>(editor);
    lineEdit->setText(value);
  }
}

void EnforcedTreeWidgetDelegate::setModelData(QWidget *editor, QAbstractItemModel *model,
                                          const QModelIndex &index) const
{
  QModelIndex parent = index.parent();
  QString entry = parent.child(index.row(), ENF_VER_ENTRY_COLUMN).data(Qt::EditRole).toString();
  if (index.column() == ENF_VER_X_COLUMN || index.column() == ENF_VER_Y_COLUMN || index.column() == ENF_VER_Z_COLUMN) {
    SMESHGUI_SpinBox *lineEdit = static_cast<SMESHGUI_SpinBox*>(editor);
    if (entry.isEmpty() && !vertexExists(model, index, lineEdit->GetString()))
      model->setData(index, lineEdit->GetValue(), Qt::EditRole);
  } else if (index.column() == ENF_VER_NAME_COLUMN) {
    QLineEdit *lineEdit = static_cast<QLineEdit*>(editor);
    QString value = lineEdit->text();
    if (entry.isEmpty() && !vertexExists(model, index, value))
      model->setData(index, value, Qt::EditRole);
  } else if (index.column() == ENF_VER_ENTRY_COLUMN) {
    QLineEdit *lineEdit = static_cast<QLineEdit*>(editor);
    QString value = lineEdit->text();
    if (!vertexExists(model, index, value))
      model->setData(index, value, Qt::EditRole);
  } else if (index.column() == ENF_VER_GROUP_COLUMN) {
    QLineEdit *lineEdit = static_cast<QLineEdit*>(editor);
    model->setData(index, lineEdit->text(), Qt::EditRole);
  }
}

void EnforcedTreeWidgetDelegate::updateEditorGeometry(QWidget *editor,
    const QStyleOptionViewItem &option, const QModelIndex &/* index */) const
{
  editor->setGeometry(option.rect);
}

bool EnforcedTreeWidgetDelegate::vertexExists(QAbstractItemModel *model,
    const QModelIndex &index, QString value) const
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
        y = parent.child(row, ENF_VER_Y_COLUMN).data(Qt::EditRole).toDouble();
        z = parent.child(row, ENF_VER_Z_COLUMN).data(Qt::EditRole).toDouble();
      }
      if (col == ENF_VER_Y_COLUMN) {
        y = value.toDouble();
        x = parent.child(row, ENF_VER_X_COLUMN).data(Qt::EditRole).toDouble();
        z = parent.child(row, ENF_VER_Z_COLUMN).data(Qt::EditRole).toDouble();
      }
      if (col == ENF_VER_Z_COLUMN) {
        z = value.toDouble();
        x = parent.child(row, ENF_VER_X_COLUMN).data(Qt::EditRole).toDouble();
        y = parent.child(row, ENF_VER_Y_COLUMN).data(Qt::EditRole).toDouble();
      }
      int nbChildren = model->rowCount(parent);
      for (int i = 0 ; i < nbChildren ; i++) {
        if (i != row) {
          double childX = parent.child(i, ENF_VER_X_COLUMN).data(Qt::EditRole).toDouble();
          double childY = parent.child(i, ENF_VER_Y_COLUMN).data(Qt::EditRole).toDouble();
          double childZ = parent.child(i, ENF_VER_Z_COLUMN).data(Qt::EditRole).toDouble();
          if ((childX == x) && (childY == y) && (childZ == z)) {
            exists = true;
            break;
          }
        }
      }
    }
    else if (col == ENF_VER_NAME_COLUMN) {
      int nbChildren = model->rowCount(parent);
      for (int i = 0 ; i < nbChildren ; i++) {
        if (i != row) {
          QString childName = parent.child(i, ENF_VER_NAME_COLUMN).data(Qt::EditRole).toString();
          if (childName == value) {
            exists = true;
            break;
          }
        }
      }
    }
  }

  return exists;
}

//
// END EnforcedTreeWidgetDelegate
//


/**
 * \brief {BLSURFPluginGUI_HypothesisCreator constructor}
 * @param theHypType Name of the hypothesis type (here BLSURF_Parameters)
 *
 * */
BLSURFPluginGUI_HypothesisCreator::BLSURFPluginGUI_HypothesisCreator( const QString& theHypType )
  : SMESHGUI_GenericHypothesisCreator( theHypType )
{
  this->mySMPMap.clear();

  GeomToolSelected = NULL;
  GeomToolSelected = getGeomSelectionTool();

  aSel = GeomToolSelected->selectionMgr();

  /* Initialize the Python interpreter */
  if (! Py_IsInitialized())
    throw ("Error: Python interpreter is not initialized");
  PyGILState_STATE gstate;
  gstate = PyGILState_Ensure();

  main_mod = NULL;
  main_mod = PyImport_AddModule("__main__");

  main_dict = NULL;
  main_dict = PyModule_GetDict(main_mod);

  PyRun_SimpleString("from math import *");
  PyGILState_Release(gstate);

}

BLSURFPluginGUI_HypothesisCreator::~BLSURFPluginGUI_HypothesisCreator()
{
}

/**
 * \brief {Get or create the geom selection tool for active study}
 * */
GeomSelectionTools* BLSURFPluginGUI_HypothesisCreator::getGeomSelectionTool() const
{
  BLSURFPluginGUI_HypothesisCreator* that = (BLSURFPluginGUI_HypothesisCreator*)this;
  if (that->GeomToolSelected == NULL) {
    that->GeomToolSelected = new GeomSelectionTools();
  }
  return that->GeomToolSelected;
}

GEOM::GEOM_Gen_var BLSURFPluginGUI_HypothesisCreator::getGeomEngine()
{
  return GeometryGUI::GetGeomGen();
}

void BLSURFPluginGUI_HypothesisCreator::avoidSimultaneousSelection(ListOfWidgets &selectionWidgets) const
{
  StdMeshersGUI_ObjectReferenceParamWdg* widgetToActivate = 0;
  ListOfWidgets::const_iterator anIt = selectionWidgets.begin();
  for ( ; anIt != selectionWidgets.end(); anIt++)
    {
      if ( *anIt && (*anIt)->inherits("StdMeshersGUI_ObjectReferenceParamWdg"))
        {
          StdMeshersGUI_ObjectReferenceParamWdg * w1 =
              ( StdMeshersGUI_ObjectReferenceParamWdg* ) ( *anIt );
          ListOfWidgets::const_iterator anIt2 = anIt;
          for ( ++anIt2; anIt2 != selectionWidgets.end(); anIt2++)
            if ( *anIt2 && (*anIt2)->inherits("StdMeshersGUI_ObjectReferenceParamWdg"))
              {
                StdMeshersGUI_ObjectReferenceParamWdg * w2 =
                    ( StdMeshersGUI_ObjectReferenceParamWdg* ) ( *anIt2 );
                w1->AvoidSimultaneousSelection( w2 );
              }
          if ( !widgetToActivate )
            widgetToActivate = w1;
        }
    }
  if ( widgetToActivate )
    widgetToActivate->activateSelection();
}

bool BLSURFPluginGUI_HypothesisCreator::checkParams(QString& msg) const
{
  bool ok = true;

  BLSURFPlugin::BLSURFPlugin_Hypothesis_var h =
    BLSURFPlugin::BLSURFPlugin_Hypothesis::_narrow( hypothesis() );

  if ( ok )
  {
    myAdvWidget->myOptionTable->setFocus();
    QApplication::instance()->processEvents();

    QString name, value;
    bool isDefault;
    int iTbl = 0, nbTbl = myAdvWidget->myOptionTable->topLevelItemCount();
    for ( ; iTbl < nbTbl; ++iTbl )
    {
      QTreeWidgetItem* table = myAdvWidget->myOptionTable->topLevelItem( iTbl );
      int nbRows = table->childCount();
      for ( int iRow = 0; iRow < nbRows; ++iRow )
      {
        QTreeWidgetItem* row = table->child( iRow );
        myAdvWidget->GetOptionAndValue( row, name, value, isDefault );

        if ( name.simplified().isEmpty() )
          continue; // invalid custom option

        if ( isDefault ) // not selected option
          value.clear();

        try {
          switch ( iTbl )
          {
          case TBL_MESHING:
            h->SetOptionValue( name.toLatin1().constData(), value.toLatin1().constData() );
            break;
          case TBL_PRECAD:
            h->SetPreCADOptionValue( name.toLatin1().constData(), value.toLatin1().constData() );
            break;
          case TBL_CUSTOM:
            h->AddOption( name.toLatin1().constData(), value.toLatin1().constData() );
            break;
          }
        }
        catch ( const SALOME_CMOD::SALOME_Exception& ex )
        {
          msg = ex.details.text.in();
          ok = false;
          break;
        }
      }
    }
  }

  // SizeMap and attractors
  if ( ok )
  {
    mySizeMapTable->setFocus();
    QApplication::instance()->processEvents();

    BLSURFPluginGUI_HypothesisCreator* that = (BLSURFPluginGUI_HypothesisCreator*)this;
    int row = 0, nbRows = mySizeMapTable->topLevelItemCount();
    std::string e, s;
    for ( ; row < nbRows; ++row )
    {
      QString entry   = mySizeMapTable->topLevelItem( row )->data(SMP_ENTRY_COLUMN, Qt::EditRole).toString();
      QString sizeMap = mySizeMapTable->topLevelItem( row )->data(SMP_SIZEMAP_COLUMN, Qt::EditRole).toString();
      if ( !sizeMap.isEmpty() ) {
        if (that->sizeMapValidationFromRow(row))
        {
          try {
            e = entry.toStdString();
            s = that->mySMPMap[entry].toStdString();
            //h->SetSizeMapEntry( e.c_str(), s.c_str() );
          }
          catch ( const SALOME_CMOD::SALOME_Exception& ex )
          {
            msg = ex.details.text.in();
            ok = false;
          }
        }
        else {
          ok = false;
        }
      }
    }
  }

  // 22207: BLSURFPLUGIN: The user is allowed to enter 0 as a global or local size.
  if ( ok )
  {
    // In case if not STD_TAB is current tab, then text() of empty spinboxes returns "0" value.
    // So STD_TAB must be current tab to get correct value of it's spinbox.
    myTabWidget->setCurrentIndex( STD_TAB );
  }
  if ( ok )
  {
    if ( !( ok = ( myStdWidget->myPhySize->text().isEmpty() ||
                   myStdWidget->myPhySize->text().toDouble() > 0.0 )))
      msg = tr("ZERO_VALUE_OF").arg( tr("BLSURF_HPHYDEF"));
  }
  if ( ok )
  {
    if ( !( ok = ( myStdWidget->myMaxSize->text().isEmpty() ||
                   myStdWidget->myMaxSize->text().toDouble() > 0.0 )))
      msg = tr("ZERO_VALUE_OF").arg( tr("BLSURF_MAXSIZE"));
  }
  if ( ok )
  {
    if ( !( ok = ( myStdWidget->myAngleMesh->text().isEmpty() ||
                   myStdWidget->myAngleMesh->text().toDouble() > 0.0 )))
      msg = tr("ZERO_VALUE_OF").arg( tr("BLSURF_ANGLE_MESH"));
  }
  if ( ok )
  {
    if ( !( ok = ( myStdWidget->myChordalError->text().isEmpty() ||
                   myStdWidget->myChordalError->text().toDouble() > 0.0 )))
      msg = tr("ZERO_VALUE_OF").arg( tr("BLSURF_CHORDAL_ERROR"));
  }

  // #16954 EDF 19466 - localsize
  // Warn the user if local size is less than Min Size
  if ( ok &&
       !myStdWidget->myMinSizeRel->isChecked() &&
       !myStdWidget->myMinSize->text().isEmpty() )
  {
    const double minSize = myStdWidget->myMinSize->GetValue();
    bool isValue;
    for ( QMapIterator<QString,QString> i( mySMPMap ); i.hasNext() &&  ok ; )
    {
      i.next();
      double size = i.value().toDouble( &isValue );
      ok = ( !isValue || size >= minSize );
    }
    for ( QMapIterator<QString, TAttractorVec > i( myATTMap ); i.hasNext() &&  ok ; )
    {
      i.next();
      const TAttractorVec& attVec = i.value();
      for ( size_t i = 0; i < attVec.size(); ++i )
        ok = ( attVec[i].IsToDelete()  || attVec[i].startSize >= minSize );
    }
    if ( !ok )
      msg = tr( "TOO_SMALL_LOCAL_SIZE" );
  }
  // Warn the user if local size is more than User Size
  if ( ok &&
       !myStdWidget->myPhySizeRel->isChecked() &&
       !myStdWidget->myPhySize->text().isEmpty() )
  {
    const double userSize = myStdWidget->myPhySize->GetValue();
    bool isValue;
    for ( QMapIterator<QString,QString> i( mySMPMap ); i.hasNext() &&  ok ; )
    {
      i.next();
      double size = i.value().toDouble( &isValue );
      ok = ( !isValue || size <= userSize );
    }
    for ( QMapIterator<QString, TAttractorVec > i( myATTMap ); i.hasNext() &&  ok ; )
    {
      i.next();
      const TAttractorVec& attVec = i.value();
      for ( size_t i = 0; i < attVec.size(); ++i )
        ok = ( attVec[i].IsToDelete()  || attVec[i].startSize <= userSize );
    }
    if ( !ok )
      msg = tr( "TOO_LARGE_LOCAL_SIZE" );
  }

  // Enforced vertices
  // TODO

  if ( !ok )
  {
    h->SetOptionValues( myOptions ); // restore values
    h->SetPreCADOptionValues( myPreCADOptions ); // restore values
  }

  return ok;
}

QFrame* BLSURFPluginGUI_HypothesisCreator::buildFrame()
{
  QFrame* fr = new QFrame( 0 );
  QVBoxLayout* lay = new QVBoxLayout( fr );
  lay->setMargin( 5 );
  lay->setSpacing( 0 );

  // main TabWidget of the dialog
  myTabWidget = new QTabWidget( fr );
  myTabWidget->setTabShape( QTabWidget::Rounded );
  myTabWidget->setTabPosition( QTabWidget::North );
  lay->addWidget( myTabWidget );

  myName = 0;

  // basic parameters
  myStdGroup = new QWidget();
  QGridLayout* aStdLayout = new QGridLayout( myStdGroup );
  aStdLayout->setSpacing( 6 );
  aStdLayout->setMargin( 11 );

  if( isCreation() )
    myName = new QLineEdit( myStdGroup );
  myStdWidget = new BLSURFPluginGUI_StdWidget(myStdGroup);
  if ( !hasGeom() ) {
    myStdWidget->myPhysicalMesh->removeItem( PhysicalLocalSize );
  }

  int row = 0;
  if( isCreation() ) {
    aStdLayout->addWidget( new QLabel( tr( "SMESH_NAME" ), myStdGroup ),    0, 0, 1, 1 );
    aStdLayout->addWidget( myName,                                      row++, 1, 1, 3 );
  }
  aStdLayout->addWidget( myStdWidget,                                   row++, 0, 1, 4 );

  row = 0;
  if( isCreation() )
    row = 1;
  aStdLayout->setRowStretch(row,1);
  aStdLayout->setColumnStretch(1,1);


  // advanced parameters
  myAdvGroup = new QWidget();
  QGridLayout* anAdvLayout = new QGridLayout( myAdvGroup );
  anAdvLayout->setSpacing( 6 );
  anAdvLayout->setMargin( 11 );
  myAdvWidget = new BLSURFPluginGUI_AdvWidget(myAdvGroup);
  anAdvLayout->addWidget( myAdvWidget );


  // Size Maps parameters

  mySmpGroup = new QWidget( dlg() );

  //Layout
  QGridLayout* anSmpLayout = new QGridLayout(mySmpGroup);

  // Table
  mySizeMapTable = new QTreeWidget( mySmpGroup );
  mySizeMapTable ->setMinimumWidth(200);
  QStringList sizeMapHeaders;
  sizeMapHeaders << tr( "SMP_NAME_COLUMN" )<< tr( "SMP_SIZEMAP_COLUMN" )<< tr( "SMP_ENTRY_COLUMN" );// << tr( "SMP_DIST_COLUMN" );
  mySizeMapTable->setHeaderLabels(sizeMapHeaders);
  mySizeMapTable->resizeColumnToContents(SMP_NAME_COLUMN);
  mySizeMapTable->resizeColumnToContents(SMP_SIZEMAP_COLUMN);
  mySizeMapTable->hideColumn(SMP_ENTRY_COLUMN);
  mySizeMapTable->setAlternatingRowColors(true);
  
  // tab widget
  smpTab = new QTabWidget( mySmpGroup );
  smpTab->setTabShape( QTabWidget::Rounded );
  smpTab->setTabPosition( QTabWidget::South );
  lay->addWidget( smpTab );
  
  // Filters of selection
  TColStd_MapOfInteger SM_ShapeTypes, ATT_ShapeTypes;
  
  SM_ShapeTypes.Add( TopAbs_VERTEX );
  SM_ShapeTypes.Add( TopAbs_EDGE );
  SM_ShapeTypes.Add( TopAbs_FACE );
  SM_ShapeTypes.Add( TopAbs_COMPOUND );
  
  ATT_ShapeTypes.Add( TopAbs_VERTEX );
  ATT_ShapeTypes.Add( TopAbs_EDGE );
  ATT_ShapeTypes.Add( TopAbs_WIRE );
  ATT_ShapeTypes.Add( TopAbs_COMPOUND );
  
  SMESH_NumberFilter* myFilter1 = new SMESH_NumberFilter("GEOM", TopAbs_SHAPE, 0, SM_ShapeTypes);
  SMESH_NumberFilter* myFilter2 = new SMESH_NumberFilter("GEOM", TopAbs_SHAPE, 0, ATT_ShapeTypes);
  SMESH_NumberFilter* myFilter3 = new SMESH_NumberFilter("GEOM", TopAbs_SHAPE, 0, TopAbs_FACE);
  
  // Standard size map tab
  mySmpStdGroup = new QWidget();
  QGridLayout* anSmpStdLayout = new QGridLayout(mySmpStdGroup);
  myGeomSelWdg1 = new StdMeshersGUI_ObjectReferenceParamWdg( myFilter1, 0, /*multiSel=*/false);
  myGeomSelWdg1->SetDefaultText(tr("BLS_SEL_SHAPE"), "QLineEdit { color: grey }");
  mySmpSizeSpin = new SMESHGUI_SpinBox(mySmpStdGroup);
  mySmpSizeSpin->RangeStepAndValidator(0., COORD_MAX, 1.0, "length_precision");
  QLabel* mySmpSizeLabel = new QLabel(tr("BLSURF_SM_SIZE"),mySmpStdGroup);
  
  // Attractor tab
  myAttractorGroup = new QWidget();
  QGridLayout* anAttLayout = new QGridLayout(myAttractorGroup);
  myGeomSelWdg2 = new StdMeshersGUI_ObjectReferenceParamWdg( myFilter3, 0, /*multiSel=*/false);
  myGeomSelWdg2->SetDefaultText(tr("BLS_SEL_FACE"), "QLineEdit { color: grey }");
  myGeomSelWdg2->AvoidSimultaneousSelection(myGeomSelWdg1);
  myAttractorCheck = new QCheckBox(tr("BLSURF_ATTRACTOR"),myAttractorGroup);
  myConstSizeCheck = new QCheckBox(tr("BLSURF_CONST_SIZE"),myAttractorGroup);
  QFrame* attLine  = new QFrame(myAttractorGroup);
  attLine->setFrameShape(QFrame::HLine);
  attLine->setFrameShadow(QFrame::Sunken);
  myAttSelWdg = new StdMeshersGUI_ObjectReferenceParamWdg( myFilter2, myAttractorGroup, /*multiSel=*/false);
  myAttSelWdg->SetDefaultText(tr("BLS_SEL_ATTRACTOR"), "QLineEdit { color: grey }"); 
  myAttSizeSpin = new SMESHGUI_SpinBox(myAttractorGroup);
  myAttSizeSpin->RangeStepAndValidator(0., COORD_MAX, 1.0, "length_precision");
  myAttSizeLabel = new QLabel(tr("BLSURF_SM_SIZE"),myAttractorGroup);
  myAttDistSpin = new SMESHGUI_SpinBox(myAttractorGroup);
  myAttDistSpin->RangeStepAndValidator(0., COORD_MAX, 10.0, "length_precision");
  myAttDistLabel = new QLabel(tr("BLSURF_ATT_DIST"),myAttractorGroup);
  myAttDistSpin2 = new SMESHGUI_SpinBox(myAttractorGroup);
  myAttDistSpin2->RangeStepAndValidator(0., COORD_MAX, 1.0, "length_precision");
  myAttDistLabel2 = new QLabel(tr("BLSURF_ATT_RADIUS"),myAttractorGroup);
  
  myAttSelWdg->AvoidSimultaneousSelection(myGeomSelWdg1);
  myAttSelWdg->AvoidSimultaneousSelection(myGeomSelWdg2);
  
  // Push buttons
  
  addMapButton = new QPushButton(tr("BLSURF_SM_ADD"),mySmpGroup);
  removeMapButton = new QPushButton(tr("BLSURF_SM_REMOVE"),mySmpGroup);
  modifyMapButton = new QPushButton(tr("BLSURF_SM_MODIFY"),mySmpGroup);
  modifyMapButton->setEnabled(false);
  
  // Init SpinBoxes
  myAttSelWdg->setEnabled(false);
  myAttSizeSpin->setEnabled(false);
  myAttSizeLabel->setEnabled(false);
  myAttDistSpin->setEnabled(false);
  myAttDistLabel->setEnabled(false);
  myAttDistSpin2->setEnabled(false);
  myAttDistLabel2->setEnabled(false);
  myAttDistSpin->setValue(0.);
  myAttDistSpin2->setValue(0.);
  myAttSizeSpin->setValue(0.);
  mySmpSizeSpin->setValue(0.);

  
  // ADD WIDGETS (SIZEMAP TAB)
  anSmpLayout->addWidget(mySizeMapTable,     0,  0, SMP_NB_LINES, 1);
  anSmpLayout->setColumnStretch(0, 1);
//  anSmpLayout->addWidget(line2,              SMP_SEPARATOR2, 1, 2, 2);
  anSmpLayout->addWidget(smpTab,             SMP_TAB_WDG,     1, 1, 3);
  anSmpLayout->setRowStretch(SMP_TAB_WDG, 1);
  anSmpLayout->addWidget(addMapButton,       SMP_ADD_BTN,     1, 1, 1);
  anSmpLayout->addWidget(removeMapButton,    SMP_ADD_BTN,     2, 1, 1);
  anSmpLayout->addWidget(modifyMapButton,    SMP_ADD_BTN,     3, 1, 1);
  
  // STANDARD TAB
  anSmpStdLayout->addWidget(myGeomSelWdg1,   SMP_GEOM_BTN_1,  1, 1, 2);
  anSmpStdLayout->addWidget(mySmpSizeLabel,  SMP_SIZE,        1, 1, 1);
  anSmpStdLayout->addWidget(mySmpSizeSpin,   SMP_SIZE,        2, 1, 1);
  anSmpStdLayout->setRowStretch(SMP_SPACE2, 1);
  
  // ADVANCED TAB
  anAttLayout->addWidget(myGeomSelWdg2,      SMP_GEOM_BTN_2,  1, 1, 2);
  anAttLayout->addWidget(myAttractorCheck,   ATT_CHECK,       1, 1, 2);
  anAttLayout->addWidget(myConstSizeCheck,   CONST_SIZE_CHECK,1, 1, 2);
  anAttLayout->addWidget(attLine,            SMP_SPACE,       1, 1, 2);
  anAttLayout->addWidget(myAttSelWdg,        SMP_ATT_SHAPE,   1, 1, 2);
  anAttLayout->addWidget(myAttSizeLabel,     SMP_ATT_SIZE,    1, 1, 1);
  anAttLayout->addWidget(myAttSizeSpin,      SMP_ATT_SIZE,    2, 1, 1);
  anAttLayout->addWidget(myAttDistLabel,     SMP_ATT_DIST,    1, 1, 1);
  anAttLayout->addWidget(myAttDistSpin,      SMP_ATT_DIST,    2, 1, 1);
  anAttLayout->addWidget(myAttDistLabel2,    SMP_ATT_RAD,     1, 1, 1);
  anAttLayout->addWidget(myAttDistSpin2,     SMP_ATT_RAD,     2, 1, 1);
  anAttLayout->setRowStretch(SMP_ATT_RAD+1, 1);
  
  smpTab->insertTab( SMP_STD_TAB, mySmpStdGroup, tr( "BLSURF_SM_STD_TAB" ) );
  smpTab->insertTab( ATT_TAB, myAttractorGroup, tr( "BLSURF_SM_ATT_TAB" ) );

  smpTab->setCurrentIndex( SMP_STD_TAB ); 

  // Enforced vertices parameters
  myEnfGroup = new QWidget( dlg() );
  QGridLayout* anEnfLayout = new QGridLayout(myEnfGroup);

  myEnforcedTreeWidget = new QTreeWidget(myEnfGroup);
  myEnforcedTreeWidget->setColumnCount( ENF_VER_NB_COLUMNS );
  myEnforcedTreeWidget->setSortingEnabled(true);
  QStringList enforcedHeaders;
  enforcedHeaders << tr("BLSURF_ENF_VER_NAME_COLUMN") << tr("BLSURF_ENF_VER_FACE_ENTRY_COLUMN")
                  << tr("BLSURF_ENF_VER_X_COLUMN")<< tr("BLSURF_ENF_VER_Y_COLUMN") << tr("BLSURF_ENF_VER_Z_COLUMN")
                  << tr("BLSURF_ENF_VER_ENTRY_COLUMN") << tr( "BLSURF_ENF_VER_GROUP_COLUMN" );

  myEnforcedTreeWidget->setHeaderLabels(enforcedHeaders);
  myEnforcedTreeWidget->header()->setStretchLastSection(true);
  myEnforcedTreeWidget->setAlternatingRowColors(true);
  myEnforcedTreeWidget->setUniformRowHeights(true);
  myEnforcedTreeWidget->setAnimated(true);
  myEnforcedTreeWidget->setSelectionMode(QAbstractItemView::ExtendedSelection);
  myEnforcedTreeWidget->setSelectionBehavior(QAbstractItemView::SelectItems);
  for (int column = 0; column < ENF_VER_NB_COLUMNS; ++column) {
    myEnforcedTreeWidget->header()->setSectionResizeMode(column,QHeaderView::Interactive);
    myEnforcedTreeWidget->resizeColumnToContents(column);
  }
  myEnforcedTreeWidget->hideColumn(ENF_VER_FACE_ENTRY_COLUMN);
  myEnforcedTreeWidget->hideColumn(ENF_VER_ENTRY_COLUMN);
  myEnforcedTreeWidget->setItemDelegate(new EnforcedTreeWidgetDelegate());
  
  // FACE AND VERTEX SELECTION
  TColStd_MapOfInteger shapeTypes1, shapeTypes2;
  shapeTypes1.Add( TopAbs_FACE );
  shapeTypes1.Add( TopAbs_COMPOUND );
  shapeTypes2.Add( TopAbs_VERTEX );
  shapeTypes2.Add( TopAbs_COMPOUND );

  // SMESH_NumberFilter* faceFilter = new SMESH_NumberFilter("GEOM", TopAbs_FACE, 0, shapeTypes1);
  // myEnfFaceWdg = new StdMeshersGUI_ObjectReferenceParamWdg( faceFilter, 0, /*multiSel=*/true);
  // myEnfFaceWdg->SetDefaultText(tr("BLS_SEL_FACES"), "QLineEdit { color: grey }");

  SMESH_NumberFilter* vertexFilter = new SMESH_NumberFilter("GEOM", TopAbs_SHAPE, 1, shapeTypes2);
  myEnfVertexWdg = new StdMeshersGUI_ObjectReferenceParamWdg( vertexFilter, 0, /*multiSel=*/true);
  myEnfVertexWdg->SetDefaultText(tr("BLS_SEL_VERTICES"), "QLineEdit { color: grey }");

  //myEnfVertexWdg->AvoidSimultaneousSelection(myEnfFaceWdg);

  QLabel* myXCoordLabel = new QLabel( tr( "BLSURF_ENF_VER_X_LABEL" ), myEnfGroup );
  myXCoord = new SMESHGUI_SpinBox(myEnfGroup);
  myXCoord->RangeStepAndValidator(COORD_MIN, COORD_MAX, 10.0, "length_precision");

  QLabel* myYCoordLabel = new QLabel( tr( "BLSURF_ENF_VER_Y_LABEL" ), myEnfGroup );
  myYCoord = new SMESHGUI_SpinBox(myEnfGroup);
  myYCoord->RangeStepAndValidator(COORD_MIN, COORD_MAX, 10.0, "length_precision");

  QLabel* myZCoordLabel = new QLabel( tr( "BLSURF_ENF_VER_Z_LABEL" ), myEnfGroup );
  myZCoord = new SMESHGUI_SpinBox(myEnfGroup);
  myZCoord->RangeStepAndValidator(COORD_MIN, COORD_MAX, 10.0, "length_precision");

  QLabel* myGroupNameLabel = new QLabel( tr( "BLSURF_ENF_VER_GROUP_LABEL" ), myEnfGroup );
  myGroupName = new QLineEdit(myEnfGroup);

  addVertexButton = new QPushButton(tr("BLSURF_ENF_VER_VERTEX"),myEnfGroup);
  removeVertexButton = new QPushButton(tr("BLSURF_ENF_VER_REMOVE"),myEnfGroup);

  myInternalEnforcedVerticesAllFaces = new QCheckBox(tr("BLSURF_ENF_VER_INTERNAL_VERTICES"),myEnfGroup);

  QLabel* myInternalEnforcedVerticesAllFacesGroupLabel = new QLabel( tr( "BLSURF_ENF_VER_GROUP_LABEL" ), myEnfGroup );
  myInternalEnforcedVerticesAllFacesGroup = new QLineEdit(myEnfGroup);

  anEnfLayout->addWidget(myEnforcedTreeWidget,     0, 0, ENF_VER_NB_LINES, 1);
  QGridLayout* anEnfLayout2 = new QGridLayout(myEnfGroup);
  //  FACE AND VERTEX SELECTION
  //anEnfLayout2->addWidget(myEnfFaceWdg,             ENF_VER_FACE, 0, 1, 2);
  anEnfLayout2->addWidget(myEnfVertexWdg,           ENF_VER_VERTEX, 0, 1, 2);
  anEnfLayout2->addWidget(myXCoordLabel,            ENF_VER_X_COORD, 0, 1, 1);
  anEnfLayout2->addWidget(myXCoord,                 ENF_VER_X_COORD, 1, 1, 1);
  anEnfLayout2->addWidget(myYCoordLabel,            ENF_VER_Y_COORD, 0, 1, 1);
  anEnfLayout2->addWidget(myYCoord,                 ENF_VER_Y_COORD, 1, 1, 1);
  anEnfLayout2->addWidget(myZCoordLabel,            ENF_VER_Z_COORD, 0, 1, 1);
  anEnfLayout2->addWidget(myZCoord,                 ENF_VER_Z_COORD, 1, 1, 1);
  anEnfLayout2->addWidget(myGroupNameLabel,         ENF_VER_GROUP, 0, 1, 1);
  anEnfLayout2->addWidget(myGroupName,              ENF_VER_GROUP, 1, 1, 1);
  anEnfLayout2->addWidget(addVertexButton,          ENF_VER_BTN, 0, 1, 1);
  anEnfLayout2->addWidget(removeVertexButton,       ENF_VER_BTN, 1, 1, 1);
  anEnfLayout2->addWidget(myInternalEnforcedVerticesAllFaces, ENF_VER_INTERNAL_ALL_FACES, 0, 1, 2);
  anEnfLayout2->addWidget(myInternalEnforcedVerticesAllFacesGroupLabel, ENF_VER_INTERNAL_ALL_FACES_GROUP, 0, 1, 1);
  anEnfLayout2->addWidget(myInternalEnforcedVerticesAllFacesGroup, ENF_VER_INTERNAL_ALL_FACES_GROUP, 1, 1, 1);
  anEnfLayout2->setRowStretch(ENF_VER_NB_LINES+1, 1);
  anEnfLayout->addLayout(anEnfLayout2, 0,1,ENF_VER_NB_LINES+1,2);

  // ---------------------------
  // Enforced meshes parameters
  // ---------------------------

  myEnfMeshGroup = new QWidget();
  QGridLayout* anEnfMeshLayout = new QGridLayout(myEnfMeshGroup);

  myEnfMeshTableWdg = new QTableWidget(myEnfGroup);
  //myEnfMeshTableWdg->setRowCount( 0 );
  myEnfMeshTableWdg->setColumnCount( ENF_MESH_NB_COLUMNS );
  myEnfMeshTableWdg->setSortingEnabled(true);
  myEnfMeshTableWdg->verticalHeader()->hide();
  myEnfMeshTableWdg->setHorizontalHeaderLabels( QStringList()
                                                << tr( "ENF_NAME_COLUMN" )
                                                << tr( "ENF_GROUP_COLUMN" ));
  myEnfMeshTableWdg->horizontalHeader()->setStretchLastSection(true);
  myEnfMeshTableWdg->horizontalHeader()->setSectionResizeMode(QHeaderView::Interactive);
  myEnfMeshTableWdg->setAlternatingRowColors(true);
  myEnfMeshTableWdg->setSelectionMode(QAbstractItemView::ExtendedSelection);
  myEnfMeshTableWdg->setSelectionBehavior(QAbstractItemView::SelectItems);
  myEnfMeshTableWdg->resizeColumnsToContents();
  //myEnfMeshTableWdg->setItemDelegate(new EnforcedMeshTableWidgetDelegate());

  myEnfMeshWdg = new StdMeshersGUI_ObjectReferenceParamWdg( SMESH::IDSOURCE_EDGE, myEnfMeshGroup, /*multiSel=*/false);
  myEnfMeshWdg->SetDefaultText(tr("ENF_SELECT_MESH"), "QLineEdit { color: grey }");

  myEnfMeshWdg->AvoidSimultaneousSelection(myEnfVertexWdg);
  myEnfMeshWdg->AvoidSimultaneousSelection(myGeomSelWdg1);
  myEnfMeshWdg->AvoidSimultaneousSelection(myGeomSelWdg2);
  myEnfMeshWdg->AvoidSimultaneousSelection(myAttSelWdg);

  QLabel* enforcedGroupNameLabel = new QLabel( tr( "ENF_GROUP_LABEL" ), myEnfMeshGroup );
  myEnforcedGroupName = new QLineEdit(myEnfMeshGroup);

  myAddEnfMeshButton    = new QPushButton(tr("ENF_ADD"),myEnfMeshGroup);
  myRemoveEnfMeshButton = new QPushButton(tr("ENF_REMOVE"),myEnfMeshGroup);

  QGridLayout* anEnfMeshLayout2 = new QGridLayout(myEnfMeshGroup);
  anEnfMeshLayout2->addWidget(myEnfMeshWdg,             0, 0, 1, 2);
  anEnfMeshLayout2->addWidget(enforcedGroupNameLabel,   1, 0, 1, 1);
  anEnfMeshLayout2->addWidget(myEnforcedGroupName,      1, 1, 1, 1);
  anEnfMeshLayout2->addWidget(myAddEnfMeshButton,       2, 0, 1, 2);
  anEnfMeshLayout2->addWidget(myRemoveEnfMeshButton,    3, 0, 1, 2);
  anEnfMeshLayout2->setRowStretch( 4, 1 );

  anEnfMeshLayout->addWidget(myEnfMeshTableWdg, 0, 0, 5, 1);
  anEnfMeshLayout->addLayout(anEnfMeshLayout2,  0, 1, 1, 1);
  anEnfMeshLayout->setRowStretch( 2, 1 );


  // ---
  // Periodicity parameters
  myPeriodicityGroup = new QWidget( dlg() );
  aPeriodicityLayout1 = new QGridLayout(myPeriodicityGroup);

  myPeriodicitySplitter = new QSplitter(myPeriodicityGroup);
  myPeriodicitySplitter->setOrientation(Qt::Horizontal);
  aPeriodicityLayout1->addWidget(myPeriodicitySplitter, 0, 0, 1, 1);

  myPeriodicityTreeWidget = new QTreeWidget(myPeriodicitySplitter);

  QStringList myPeriodicityTreeHeaders;
  myPeriodicityTreeHeaders << tr("BLSURF_PERIODICITY_OBJ_SOURCE_COLUMN")
                           << tr("BLSURF_PERIODICITY_OBJ_TARGET_COLUMN")
                           << tr("BLSURF_PERIODICITY_P1_SOURCE_COLUMN")
                           << tr("BLSURF_PERIODICITY_P2_SOURCE_COLUMN")
                           << tr("BLSURF_PERIODICITY_P3_SOURCE_COLUMN")
                           << tr("BLSURF_PERIODICITY_P1_TARGET_COLUMN")
                           << tr("BLSURF_PERIODICITY_P2_TARGET_COLUMN")
                           << tr("BLSURF_PERIODICITY_P3_TARGET_COLUMN")
                           << tr("BLSURF_PERIODICITY_SHAPE_TYPE");
  myPeriodicityTreeWidget->setHeaderLabels(myPeriodicityTreeHeaders);

  // Hide the vertex name to make the widget more readable
  myPeriodicityTreeWidget->hideColumn(PERIODICITY_P1_SOURCE_COLUMN);
  myPeriodicityTreeWidget->hideColumn(PERIODICITY_P2_SOURCE_COLUMN);
  myPeriodicityTreeWidget->hideColumn(PERIODICITY_P3_SOURCE_COLUMN);
  myPeriodicityTreeWidget->hideColumn(PERIODICITY_P1_TARGET_COLUMN);
  myPeriodicityTreeWidget->hideColumn(PERIODICITY_P2_TARGET_COLUMN);
  myPeriodicityTreeWidget->hideColumn(PERIODICITY_P3_TARGET_COLUMN);
  myPeriodicityTreeWidget->hideColumn(PERIODICITY_SHAPE_TYPE);


  myPeriodicityTreeWidget->setColumnCount(PERIODICITY_NB_COLUMN);
  myPeriodicityTreeWidget->setSortingEnabled(true);

  myPeriodicityTreeWidget->setAlternatingRowColors(true);
  myPeriodicityTreeWidget->setSelectionMode(QAbstractItemView::ExtendedSelection);
  myPeriodicityTreeWidget->setSelectionBehavior(QAbstractItemView::SelectRows);
  
  int periodicityVisibleColumns = 2;
  for (int column = 0; column < periodicityVisibleColumns; ++column) {
      myPeriodicityTreeWidget->header()->setSectionResizeMode(column,QHeaderView::Interactive);
      myPeriodicityTreeWidget->resizeColumnToContents(column);
  }
  myPeriodicityTreeWidget->header()->setStretchLastSection(true);

  myPeriodicitySplitter->addWidget(myPeriodicityTreeWidget);

  myPeriodicityRightWidget = new QWidget(myPeriodicitySplitter);

  myPeriodicityRightGridLayout = new QGridLayout(myPeriodicityRightWidget);
  myPeriodicityGroupBox1 = new QGroupBox(tr("BLSURF_PRECAD_PERIODICITY"), myPeriodicityRightWidget);
  myPeriodicityGroupBox1Layout = new QGridLayout(myPeriodicityGroupBox1);

  myPeriodicityRightGridLayout->addWidget(myPeriodicityGroupBox1, 0, 0, 1, 2);

  myPeriodicityOnFaceRadioButton = new QRadioButton(tr("BLSURF_PERIODICITY_ON_FACE"), myPeriodicityGroupBox1);
  myPeriodicityGroupBox1Layout->addWidget(myPeriodicityOnFaceRadioButton, 0, 0, 1, 2);

  myPeriodicityOnFaceRadioButton->setChecked(true);

  myPeriodicityOnEdgeRadioButton = new QRadioButton(tr("BLSURF_PERIODICITY_ON_EDGE"), myPeriodicityGroupBox1);
  myPeriodicityGroupBox1Layout->addWidget(myPeriodicityOnEdgeRadioButton, 0, 2, 1, 2);


  // FACE, EDGE AND VERTEX SELECTION
  TColStd_MapOfInteger shapeTypesFace, shapeTypesEdge;
  shapeTypesFace.Add( TopAbs_FACE );
  shapeTypesFace.Add( TopAbs_EDGE );
  shapeTypesFace.Add( TopAbs_COMPOUND );
  shapeTypesEdge.Add( TopAbs_EDGE );
  shapeTypesEdge.Add( TopAbs_COMPOUND );

//  myPeriodicityEdgeFilter = new SMESH_NumberFilter("GEOM", TopAbs_EDGE, 0, shapeTypesEdge);

  myPeriodicityMainSourceLabel = new QLabel(tr("BLSURF_PERIODICITY_MAIN_SOURCE"), myPeriodicityGroupBox1);
  myPeriodicityGroupBox1Layout->addWidget(myPeriodicityMainSourceLabel, 1, 0, 1, 1);

  SMESH_NumberFilter* myPeriodicitySourceFaceFilter = new SMESH_NumberFilter("GEOM", TopAbs_SHAPE, 0, shapeTypesFace);
  myPeriodicitySourceFaceWdg = new StdMeshersGUI_ObjectReferenceParamWdg( myPeriodicitySourceFaceFilter, 0, /*multiSel=*/false);
//  myPeriodicitySourceFaceWdg->SetDefaultText(tr("BLSURF_PERIODICITY_SELECT_FACE"), "QLineEdit { color: grey }");
  myPeriodicityGroupBox1Layout->addWidget(myPeriodicitySourceFaceWdg, 1, 1, 1, 1);

//  myPeriodicitySourceEdgeWdg = new StdMeshersGUI_ObjectReferenceParamWdg( myPeriodicityEdgeFilter, 0, /*multiSel=*/false);
//  myPeriodicitySourceEdgeWdg->SetDefaultText(tr("BLSURF_PERIODICITY_SELECT_EDGE"), "QLineEdit { color: grey }");
//  myPeriodicitySourceEdgeWdg->hide();
//  myPeriodicityGroupBox1Layout->addWidget(myPeriodicitySourceEdgeWdg, 1, 1, 1, 1);

  myPeriodicityMainTargetLabel = new QLabel(tr("BLSURF_PERIODICITY_MAIN_TARGET"), myPeriodicityGroupBox1);
  myPeriodicityGroupBox1Layout->addWidget(myPeriodicityMainTargetLabel, 1, 2, 1, 1);

  SMESH_NumberFilter* myPeriodicityTargetFaceFilter = new SMESH_NumberFilter("GEOM", TopAbs_SHAPE, 0, shapeTypesFace);
  myPeriodicityTargetFaceWdg = new StdMeshersGUI_ObjectReferenceParamWdg( myPeriodicityTargetFaceFilter, 0, /*multiSel=*/false);
//  myPeriodicityTargetFaceWdg->SetDefaultText(tr("BLSURF_PERIODICITY_SELECT_FACE"), "QLineEdit { color: grey }");
  myPeriodicityGroupBox1Layout->addWidget(myPeriodicityTargetFaceWdg, 1, 3, 1, 1);

//  myPeriodicityTargetEdgeWdg = new StdMeshersGUI_ObjectReferenceParamWdg( myPeriodicityEdgeFilter, 0, /*multiSel=*/false);
//  myPeriodicityTargetEdgeWdg->SetDefaultText(tr("BLSURF_PERIODICITY_SELECT_EDGE"), "QLineEdit { color: grey }");
//  myPeriodicityTargetEdgeWdg->hide();
//  myPeriodicityGroupBox1Layout->addWidget(myPeriodicityTargetEdgeWdg, 1, 3, 1, 1);

  myPeriodicityGroupBox2 = new QGroupBox(tr("BLSURF_PERIODICITY_WITH_VERTICES"), myPeriodicityRightWidget);
  myPeriodicityGroupBox2Layout = new QGridLayout(myPeriodicityGroupBox2);
  myPeriodicityRightGridLayout->addWidget(myPeriodicityGroupBox2, 1, 0, 1, 2);

  myPeriodicityGroupBox2->setCheckable(true);
  myPeriodicityGroupBox2->setChecked(false);

  myPeriodicitySourceLabel = new QLabel(tr("BLSURF_PERIODICITY_SOURCE"), myPeriodicityGroupBox2);
  myPeriodicityGroupBox2Layout->addWidget(myPeriodicitySourceLabel, 0, 0, 1, 2);

  myPeriodicityTargetLabel = new QLabel(tr("BLSURF_PERIODICITY_TARGET"), myPeriodicityGroupBox2);
  myPeriodicityGroupBox2Layout->addWidget(myPeriodicityTargetLabel, 0, 2, 1, 2);

  // P1
  myPeriodicityP1SourceLabel = new QLabel(tr("BLSURF_PERIODICITY_P1_SOURCE"), myPeriodicityGroupBox2);
  myPeriodicityGroupBox2Layout->addWidget(myPeriodicityP1SourceLabel, 1, 0, 1, 1);


  SMESH_NumberFilter* myPeriodicityP1SourceFilter = new SMESH_NumberFilter("GEOM", TopAbs_SHAPE, 1, TopAbs_VERTEX);
  myPeriodicityP1SourceWdg = new StdMeshersGUI_ObjectReferenceParamWdg( myPeriodicityP1SourceFilter, 0, /*multiSel=*/false);
  myPeriodicityGroupBox2Layout->addWidget(myPeriodicityP1SourceWdg, 1, 1, 1, 1);

  // P2
  myPeriodicityP2SourceLabel = new QLabel(tr("BLSURF_PERIODICITY_P2_SOURCE"), myPeriodicityGroupBox2);
  myPeriodicityGroupBox2Layout->addWidget(myPeriodicityP2SourceLabel, 2, 0, 1, 1);

  SMESH_NumberFilter* myPeriodicityP2SourceFilter = new SMESH_NumberFilter("GEOM", TopAbs_SHAPE, 1, TopAbs_VERTEX);
  myPeriodicityP2SourceWdg = new StdMeshersGUI_ObjectReferenceParamWdg( myPeriodicityP2SourceFilter, 0, /*multiSel=*/false);
  myPeriodicityGroupBox2Layout->addWidget(myPeriodicityP2SourceWdg, 2, 1, 1, 1);

  // P3
  myPeriodicityP3SourceLabel = new QLabel(tr("BLSURF_PERIODICITY_P3_SOURCE"), myPeriodicityGroupBox2);
  myPeriodicityGroupBox2Layout->addWidget(myPeriodicityP3SourceLabel, 3, 0, 1, 1);

  SMESH_NumberFilter* myPeriodicityP3SourceFilter = new SMESH_NumberFilter("GEOM", TopAbs_SHAPE, 1, TopAbs_VERTEX);
  myPeriodicityP3SourceWdg = new StdMeshersGUI_ObjectReferenceParamWdg( myPeriodicityP3SourceFilter, 0, /*multiSel=*/false);
  myPeriodicityGroupBox2Layout->addWidget(myPeriodicityP3SourceWdg, 3, 1, 1, 1);

  // P1
  myPeriodicityP1TargetLabel = new QLabel(tr("BLSURF_PERIODICITY_P1_TARGET"), myPeriodicityGroupBox2);
  myPeriodicityGroupBox2Layout->addWidget(myPeriodicityP1TargetLabel, 1, 2, 1, 1);

  SMESH_NumberFilter* myPeriodicityP1TargetFilter = new SMESH_NumberFilter("GEOM", TopAbs_SHAPE, 1, TopAbs_VERTEX);
  myPeriodicityP1TargetWdg = new StdMeshersGUI_ObjectReferenceParamWdg( myPeriodicityP1TargetFilter, 0, /*multiSel=*/false);
  myPeriodicityGroupBox2Layout->addWidget(myPeriodicityP1TargetWdg, 1, 3, 1, 1);

  // P2
  myPeriodicityP2TargetLabel = new QLabel(tr("BLSURF_PERIODICITY_P2_TARGET"), myPeriodicityGroupBox2);
  myPeriodicityGroupBox2Layout->addWidget(myPeriodicityP2TargetLabel, 2, 2, 1, 1);

  SMESH_NumberFilter* myPeriodicityP2TargetFilter = new SMESH_NumberFilter("GEOM", TopAbs_SHAPE, 1, TopAbs_VERTEX);
  myPeriodicityP2TargetWdg = new StdMeshersGUI_ObjectReferenceParamWdg( myPeriodicityP2TargetFilter, 0, /*multiSel=*/false);
  myPeriodicityGroupBox2Layout->addWidget(myPeriodicityP2TargetWdg, 2, 3, 1, 1);

  // P3
  myPeriodicityP3TargetLabel = new QLabel(tr("BLSURF_PERIODICITY_P3_TARGET"), myPeriodicityGroupBox2);
  myPeriodicityGroupBox2Layout->addWidget(myPeriodicityP3TargetLabel, 3, 2, 1, 1);

  SMESH_NumberFilter* myPeriodicityP3TargetFilter = new SMESH_NumberFilter("GEOM", TopAbs_SHAPE, 1, TopAbs_VERTEX);
  myPeriodicityP3TargetWdg = new StdMeshersGUI_ObjectReferenceParamWdg( myPeriodicityP3TargetFilter, 0, /*multiSel=*/false);
  myPeriodicityGroupBox2Layout->addWidget(myPeriodicityP3TargetWdg, 3, 3, 1, 1);

  myPeriodicityVerticalSpacer = new QSpacerItem(20, 40, QSizePolicy::Minimum, QSizePolicy::Expanding);
  myPeriodicityGroupBox2Layout->addItem(myPeriodicityVerticalSpacer, 7, 1, 1, 1);


  myPeriodicityAddButton = new QPushButton(tr("BLSURF_PERIODICITY_ADD"),myPeriodicityRightWidget);
  myPeriodicityRightGridLayout->addWidget(myPeriodicityAddButton, 2, 0, 1, 1);

  myPeriodicityRemoveButton = new QPushButton(tr("BLSURF_PERIODICITY_REMOVE"),myPeriodicityRightWidget);
  myPeriodicityRightGridLayout->addWidget(myPeriodicityRemoveButton, 2, 1, 1, 1);

  myPeriodicitySplitter->addWidget(myPeriodicityRightWidget);

  myPeriodicitySelectionWidgets.clear();
  myPeriodicitySelectionWidgets.append(myPeriodicitySourceFaceWdg);
  myPeriodicitySelectionWidgets.append(myPeriodicityTargetFaceWdg);
  myPeriodicitySelectionWidgets.append(myPeriodicityP1SourceWdg);
  myPeriodicitySelectionWidgets.append(myPeriodicityP2SourceWdg);
  myPeriodicitySelectionWidgets.append(myPeriodicityP3SourceWdg);
  myPeriodicitySelectionWidgets.append(myPeriodicityP1TargetWdg);
  myPeriodicitySelectionWidgets.append(myPeriodicityP2TargetWdg);
  myPeriodicitySelectionWidgets.append(myPeriodicityP3TargetWdg);
  avoidSimultaneousSelection(myPeriodicitySelectionWidgets);

  // HyperPatch parameters

  QWidget*      hpGroup = new QWidget();
  QGridLayout* hpLayout = new QGridLayout(hpGroup);

  myHyPatchTable = new QTableWidget( hpGroup );
  myHyPatchTable->setColumnCount(1);
  myHyPatchTable->setHorizontalHeaderLabels( QStringList() << tr("BLSURF_HYPATCH_TBL_HEADER") );
  myHyPatchTable->setAlternatingRowColors(true);
  myHyPatchTable->horizontalHeader()->setSectionResizeMode( 0, QHeaderView::Stretch );


  QPixmap iconSelect (SUIT_Session::session()->resourceMgr()->loadPixmap("SMESH", tr("ICON_SELECT")));
  myHyPatchFaceSelBtn  = new QPushButton( iconSelect, tr("BLSURF_HYPATCH_SEL_FACE"), hpGroup );
  myHyPatchGroupSelBtn = new QPushButton( iconSelect, tr("BLSURF_HYPATCH_SEL_GROUP"), hpGroup );
  myHyPatchFaceSelBtn->setCheckable( true );
  myHyPatchGroupSelBtn->setCheckable( true );

  myHyPatchFaceSelector = new StdMeshersGUI_SubShapeSelectorWdg( hpGroup, TopAbs_FACE, /*toShowList=*/false );

  QLabel* hpTagsLbl = new QLabel( tr("BLSURF_TAGS"), hpGroup );
  myHyPatchTagsLE   = new QLineEdit( hpGroup );
  myHyPatchTagsLE->setValidator( new SMESHGUI_IdValidator( hpGroup ));

  QPushButton* hpAddBtn = new QPushButton( tr("BLSURF_SM_ADD"), hpGroup );
  QPushButton* hpRemBtn = new QPushButton( tr("BLSURF_SM_REMOVE"), hpGroup );

  hpLayout->addWidget( myHyPatchTable,        0, 0, 5, 1 );
  hpLayout->addWidget( myHyPatchFaceSelBtn,   0, 1, 1, 2 );
  hpLayout->addWidget( myHyPatchGroupSelBtn,  0, 3, 1, 2 );
  hpLayout->addWidget( hpTagsLbl,             1, 1, 1, 1 );
  hpLayout->addWidget( myHyPatchTagsLE,       1, 2, 1, 3 );
  hpLayout->addWidget( hpAddBtn,              2, 1, 1, 2 );
  hpLayout->addWidget( hpRemBtn,              2, 3, 1, 2 );
  hpLayout->addWidget( myHyPatchFaceSelector, 3, 1, 1, 4 );



  // ---
  myTabWidget->insertTab( STD_TAB, myStdGroup, tr( "SMESH_ARGUMENTS" ) );
  myTabWidget->insertTab( ADV_TAB, myAdvGroup, tr( "BLSURF_ADV_ARGS" ) );
  if ( hasGeom() ) {
    myTabWidget->insertTab( SMP_TAB, mySmpGroup, tr( "LOCAL_SIZE" ) );
    myTabWidget->insertTab( ENF_V_TAB, myEnfGroup, tr( "BLSURF_ENF_VER" ) );
    myTabWidget->insertTab( ENF_M_TAB, myEnfMeshGroup, tr( "ENF_MESH" ) );
    myTabWidget->insertTab( PERIODICITY_TAB, myPeriodicityGroup, tr( "BLSURF_PERIODICITY" ) );
    myTabWidget->insertTab( HYPERPATCH_TAB, hpGroup, tr( "BLSURF_HYPERPATCH_TAB" ));
  }
  else
  {
    mySmpGroup->hide();
    myEnfGroup->hide();
    myEnfMeshGroup->hide();
    myPeriodicityGroup->hide();
    hpGroup->hide();
  }
  myTabWidget->setCurrentIndex( STD_TAB );

  connect( myAdvWidget->addBtn, SIGNAL( clicked() ),                           SLOT( onAddOption() ) );

  // Size Maps
  connect( addMapButton,        SIGNAL( clicked()),                            SLOT( onAddMap() ) );
  connect( removeMapButton,     SIGNAL( clicked()),                            SLOT( onRemoveMap() ) );
  connect( modifyMapButton,     SIGNAL( clicked()),                            SLOT( onModifyMap() ) );
  connect( mySizeMapTable,      SIGNAL( itemClicked (QTreeWidgetItem *, int)), SLOT( onSmpItemClicked(QTreeWidgetItem *, int) ) );
  connect( myGeomSelWdg2,       SIGNAL( contentModified() ),                   SLOT( onMapGeomContentModified() ) );
  connect( myGeomSelWdg1,       SIGNAL( contentModified() ),                   SLOT( onMapGeomContentModified() ) );
  connect( myAttSelWdg,         SIGNAL( contentModified() ),                   SLOT( onMapGeomContentModified() ) );
  connect( mySizeMapTable,      SIGNAL( itemChanged (QTreeWidgetItem *, int)), SLOT( onSetSizeMap(QTreeWidgetItem *, int) ) );
  connect( myAttractorCheck,    SIGNAL( stateChanged ( int )),                 SLOT( onAttractorClicked( int ) ) );
  connect( myConstSizeCheck,    SIGNAL( stateChanged ( int )),                 SLOT( onConstSizeClicked( int ) ) );
  connect( smpTab,              SIGNAL( currentChanged ( int )),               SLOT( onTabChanged( int ) ) );
  connect( myTabWidget,         SIGNAL( currentChanged ( int )),               SLOT( onTabChanged( int ) ) );

  // Enforced vertices
  connect( myEnforcedTreeWidget,SIGNAL( itemClicked(QTreeWidgetItem *, int)),  SLOT( synchronizeCoords() ) );
  connect( myEnforcedTreeWidget,SIGNAL( itemChanged(QTreeWidgetItem *, int)),  SLOT( updateEnforcedVertexValues(QTreeWidgetItem *, int) ) );
  connect( myEnforcedTreeWidget,SIGNAL( itemSelectionChanged() ),              SLOT( synchronizeCoords() ) );
  connect( addVertexButton,     SIGNAL( clicked()),                            SLOT( onAddEnforcedVertices() ) );
  connect( removeVertexButton,  SIGNAL( clicked()),                            SLOT( onRemoveEnforcedVertex() ) );
  connect( myEnfVertexWdg,      SIGNAL( contentModified()),                    SLOT( onSelectEnforcedVertex() ) );
  connect( myInternalEnforcedVerticesAllFaces, SIGNAL( stateChanged ( int )),  SLOT( onInternalVerticesClicked( int ) ) );

  // Enforced mesh
  connect( myAddEnfMeshButton,    SIGNAL( clicked()),              SLOT( onAddEnforcedMesh()));
  connect( myRemoveEnfMeshButton, SIGNAL( clicked()),              SLOT( onRemoveEnforcedMesh()));
  connect( myEnfMeshWdg,          SIGNAL( contentModified()),      SLOT( onEnforcedMeshSelected()));
  connect( myEnfMeshTableWdg,     SIGNAL( itemSelectionChanged()), SLOT( onEnfMeshTableSelected()));


  // Periodicity
  connect( myPeriodicityAddButton,     SIGNAL( clicked()),                     SLOT( onAddPeriodicity() ) );
  connect( myPeriodicityRemoveButton,  SIGNAL( clicked()),                     SLOT( onRemovePeriodicity() ) );
  connect( myPeriodicityTreeWidget,    SIGNAL( itemClicked(QTreeWidgetItem*, int)), SLOT( onPeriodicityTreeClicked(QTreeWidgetItem *, int) ) );
  connect( myPeriodicityGroupBox2,     SIGNAL(toggled(bool)),                  SLOT(onPeriodicityByVerticesChecked(bool)));

  ListOfWidgets::const_iterator anIt = myPeriodicitySelectionWidgets.begin();
  for (; anIt != myPeriodicitySelectionWidgets.end(); anIt++)
  {
    StdMeshersGUI_ObjectReferenceParamWdg * w1 = ( StdMeshersGUI_ObjectReferenceParamWdg* ) ( *anIt );
    connect( w1, SIGNAL( contentModified ()), SLOT( onPeriodicityContentModified() ));

  }

  // HyperPatch
  connect( myHyPatchFaceSelBtn,   SIGNAL( toggled(bool) ),   SLOT( onHyPatchFaceSelection(bool) ));
  connect( myHyPatchGroupSelBtn,  SIGNAL( toggled(bool) ),   SLOT( onHyPatchGroupSelection(bool) ));
  connect( myHyPatchFaceSelector, SIGNAL( shapeSelected() ), SLOT( onHyPatchSelectionChanged()));
  connect( hpAddBtn,              SIGNAL( clicked() ),       SLOT( onHyPatchAdd()));
  connect( hpRemBtn,              SIGNAL( clicked() ),       SLOT( onHyPatchRemove()));

  return fr;
}

/** BLSURFPluginGUI_HypothesisCreator::deactivateSelection(QWidget*, QWidget*)
    This method stop the selection of the widgets StdMeshersGUI_ObjectReferenceParamWdg
*/
// void BLSURFPluginGUI_HypothesisCreator::deactivateSelection(QWidget* old, QWidget* now)
// {
//   if ((now == myXCoord) || (now == myYCoord) || (now == myZCoord)
//       || (now = myGroupName) || (now = myGlobalGroupName) || (now = myEnforcedTreeWidget)) {
//     BLSURFPluginGUI_HypothesisCreator* that = (BLSURFPluginGUI_HypothesisCreator*)this;
//     that->getGeomSelectionTool()->selectionMgr()->clearFilters();
//     myEnfFaceWdg->deactivateSelection();
//     myEnfVertexWdg->deactivateSelection();
//   }
// }

void BLSURFPluginGUI_HypothesisCreator::onStateChange()
{
  myStdWidget->onPhysicalMeshChanged();
}

/**
 * This method resets the content of the X, Y, Z widgets;
 **/
void BLSURFPluginGUI_HypothesisCreator::clearEnforcedVertexWidgets()
{
  myXCoord->setCleared(true);
  myYCoord->setCleared(true);
  myZCoord->setCleared(true);
  myXCoord->setText("");
  myYCoord->setText("");
  myZCoord->setText("");
  //   myGroupName->setText("");
}

/** BLSURFPluginGUI_HypothesisCreator::updateEnforcedVertexValues(item, column)
    This method updates the tooltip of a modified item. The QLineEdit widgets content
    is synchronized with the coordinates of the enforced vertex clicked in the tree widget.
*/
void BLSURFPluginGUI_HypothesisCreator::updateEnforcedVertexValues(QTreeWidgetItem* item, int /*column*/)
{
  QVariant vertexName = item->data(ENF_VER_NAME_COLUMN, Qt::EditRole);
  QVariant x = item->data(ENF_VER_X_COLUMN, Qt::EditRole);
  QVariant y = item->data(ENF_VER_Y_COLUMN, Qt::EditRole);
  QVariant z = item->data(ENF_VER_Z_COLUMN, Qt::EditRole);
  QVariant entry = item->data(ENF_VER_ENTRY_COLUMN, Qt::EditRole);
  QString groupName = item->data(ENF_VER_GROUP_COLUMN, Qt::EditRole).toString();
  QTreeWidgetItem* parent = item->parent();
  
  clearEnforcedVertexWidgets();
  
  if (parent && (!x.isNull() || !entry.isNull())) {
      QString shapeName = parent->data(ENF_VER_NAME_COLUMN, Qt::EditRole).toString();
      QString toolTip = shapeName + QString(": ") + vertexName.toString();
      if (entry.isNull()) {
        toolTip += QString("(") + x.toString();
        toolTip += QString(", ") + y.toString();
        toolTip += QString(", ") + z.toString();
        toolTip += QString(")");
      }
      
      if (!groupName.isEmpty())
        toolTip += QString(" [") + groupName + QString("]");

      item->setToolTip(ENF_VER_NAME_COLUMN,toolTip);

    if (!x.isNull()) {
      myXCoord->SetValue(x.toDouble());
      myYCoord->SetValue(y.toDouble());
      myZCoord->SetValue(z.toDouble());
    }
    
    if (!groupName.isEmpty())
      myGroupName->setText(groupName);
  }
}

void BLSURFPluginGUI_HypothesisCreator::onSelectEnforcedVertex()
{
  size_t nbSelEnfVertex = myEnfVertexWdg->NbObjects();
  clearEnforcedVertexWidgets();
  if (nbSelEnfVertex == 1)
  {
    if ( CORBA::is_nil( getGeomEngine() ) && !GeometryGUI::InitGeomGen() )
    return ;

    myEnfVertex = myEnfVertexWdg->GetObject< GEOM::GEOM_Object >(nbSelEnfVertex-1);
    if (myEnfVertex->GetShapeType() == GEOM::VERTEX) {
      GEOM::GEOM_IMeasureOperations_var measureOp = getGeomEngine()->GetIMeasureOperations();
      if (CORBA::is_nil(measureOp))
        return;
      
      CORBA::Double x,y,z;
      measureOp->PointCoordinates (myEnfVertex, x, y, z);
      if ( measureOp->IsDone() )
      {
        myXCoord->SetValue(x);
        myYCoord->SetValue(y);
        myZCoord->SetValue(z);
      }
    }
  }
}

/** BLSURFPluginGUI_HypothesisCreator::synchronizeCoords()
This method synchronizes the QLineEdit/SMESHGUI_SpinBox widgets content with the coordinates
of the enforced vertex clicked in the tree widget.
*/
void BLSURFPluginGUI_HypothesisCreator::synchronizeCoords()
{
  clearEnforcedVertexWidgets();
  QList<QTreeWidgetItem *> items = myEnforcedTreeWidget->selectedItems();
  if (! items.isEmpty() && items.size() == 1) {
    QTreeWidgetItem *item = items[0];
//     for (int i=0 ; i < items.size() ; i++) {
//       item = items[i];
      QVariant x = item->data(ENF_VER_X_COLUMN, Qt::EditRole);
      QVariant y = item->data(ENF_VER_Y_COLUMN, Qt::EditRole);
      QVariant z = item->data(ENF_VER_Z_COLUMN, Qt::EditRole);
      QVariant entry = item->data(ENF_VER_ENTRY_COLUMN, Qt::EditRole);
      QVariant group = item->data(ENF_VER_GROUP_COLUMN, Qt::EditRole);
      if (!x.isNull()/* && entry.isNull()*/) {
        myXCoord->SetValue(x.toDouble());
        myYCoord->SetValue(y.toDouble());
        myZCoord->SetValue(z.toDouble());
//         break;
      }
      if (!group.isNull() && (!x.isNull() || !entry.isNull()))
        myGroupName->setText(group.toString());
//     }
  }
}

/** BLSURFPluginGUI_HypothesisCreator::addEnforcedFace(entry, shapeName, useInternalVertices)
This method adds a face containing enforced vertices in the tree widget.
*/
QTreeWidgetItem* BLSURFPluginGUI_HypothesisCreator::addEnforcedFace(std::string theFaceEntry, std::string theFaceName)
{
  // Find theFaceEntry item
  QList<QTreeWidgetItem* > theItemList = myEnforcedTreeWidget->findItems(QString(theFaceEntry.c_str()),Qt::MatchExactly,ENF_VER_FACE_ENTRY_COLUMN);
  QTreeWidgetItem* theItem;
  if (theItemList.empty()) {
    theItem = new QTreeWidgetItem();
    theItem->setData(ENF_VER_FACE_ENTRY_COLUMN, Qt::EditRole, QVariant(theFaceEntry.c_str()));
    theItem->setData(ENF_VER_NAME_COLUMN, Qt::EditRole, QVariant(theFaceName.c_str()));
    theItem->setToolTip(ENF_VER_NAME_COLUMN,QString(theFaceEntry.c_str()));
    myEnforcedTreeWidget->addTopLevelItem(theItem);
  }
  else {
    theItem = theItemList[0];
  }
  return theItem;
}

/** BLSURFPluginGUI_HypothesisCreator::addEnforcedVertex(entry, shapeName, x, y, z)
    This method adds an enforced vertex (x,y,z) to shapeName in the tree widget.
*/
void BLSURFPluginGUI_HypothesisCreator::addEnforcedVertex(double x, double y, double z,
                                                          std::string vertexName,
                                                          std::string geomEntry,
                                                          std::string groupName)
{
  bool okToCreate = true;

  const int nbVert = myEnforcedTreeWidget->topLevelItemCount();
  for (int row = 0; row < nbVert; row++ )
  {
    QTreeWidgetItem* child = myEnforcedTreeWidget->topLevelItem( row );
    QString childGroupName = child->data(ENF_VER_GROUP_COLUMN,Qt::EditRole).toString();
    QString childEntry     = child->data(ENF_VER_ENTRY_COLUMN,Qt::EditRole).toString();
    double childX          = child->data(ENF_VER_X_COLUMN,Qt::EditRole).toDouble();
    double childY          = child->data(ENF_VER_Y_COLUMN,Qt::EditRole).toDouble();
    double childZ          = child->data(ENF_VER_Z_COLUMN,Qt::EditRole).toDouble();
    if (((childEntry.isEmpty()) && (childX == x) && (childY == y) && (childZ == z)) ||
        ( !childEntry.isEmpty() && childEntry == geomEntry.c_str() ))
    {
      // update group name
      if ( childGroupName != groupName.c_str() ) {
        child->setData(ENF_VER_GROUP_COLUMN, Qt::EditRole, QVariant(groupName.c_str()));
      }
      okToCreate = false;
      break;
    } // if
  } // for
  if (!okToCreate) {
    return;
  }

  QTreeWidgetItem *vertexItem = new QTreeWidgetItem( myEnforcedTreeWidget );
  vertexItem->setFlags( Qt::ItemIsSelectable | Qt::ItemIsEditable | Qt::ItemIsEnabled);
  QPixmap iconSelect (SUIT_Session::session()->resourceMgr()->loadPixmap("SMESH", tr("ICON_SELECT")));
  QSize iconSize = iconSelect.size()*0.7;

  int vertexIndex=nbVert;
  QString myVertexName;
  int indexRef = -1;
  while(indexRef != vertexIndex) {
    indexRef = vertexIndex;
    if (vertexName.empty())
      myVertexName = QString("Vertex #%1").arg(vertexIndex);
    else
      myVertexName = QString(vertexName.c_str());

    for (int row = 0;row<nbVert;row++) {
      QString name = myEnforcedTreeWidget->topLevelItem(row)->data(ENF_VER_NAME_COLUMN,Qt::EditRole).toString();
      if (myVertexName == name) {
        vertexIndex++;
        break;
      }
    }
  }
  vertexItem->setData( ENF_VER_NAME_COLUMN, Qt::EditRole, myVertexName );
  if (geomEntry.empty()) {
    vertexItem->setData( ENF_VER_X_COLUMN, Qt::EditRole, QVariant(x) );
    vertexItem->setData( ENF_VER_Y_COLUMN, Qt::EditRole, QVariant(y) );
    vertexItem->setData( ENF_VER_Z_COLUMN, Qt::EditRole, QVariant(z) );
  }
  else {
    vertexItem->setIcon(ENF_VER_NAME_COLUMN, QIcon(iconSelect.scaled(iconSize,Qt::KeepAspectRatio,Qt::SmoothTransformation)));
    vertexItem->setData( ENF_VER_ENTRY_COLUMN, Qt::EditRole, QString(geomEntry.c_str()) );
  }
  if (groupName != "")
    vertexItem->setData( ENF_VER_GROUP_COLUMN, Qt::EditRole, QVariant(groupName.c_str()));

  QString toolTip = myVertexName;
  if (geomEntry.empty()) {
    toolTip += QString(" (%1, %2, %3").arg(x).arg(y).arg(z);
  }
  if (groupName != "")
    toolTip += QString(" [%1]").arg(groupName.c_str());
  
  vertexItem->setToolTip(ENF_VER_NAME_COLUMN,toolTip);
  myEnforcedTreeWidget->setCurrentItem(vertexItem,ENF_VER_NAME_COLUMN);
}

/** BLSURFPluginGUI_HypothesisCreator::onAddEnforcedVertices()
This method is called when a item is added into the enforced vertices tree widget
*/
void BLSURFPluginGUI_HypothesisCreator::onAddEnforcedVertices()
{
  getGeomSelectionTool()->selectionMgr()->clearFilters();
  myEnfVertexWdg->deactivateSelection();

  for (int column = 0; column < myEnforcedTreeWidget->columnCount(); ++column)
    myEnforcedTreeWidget->resizeColumnToContents(column);

  // Vertex selection
  size_t selEnfVertex = myEnfVertexWdg->NbObjects();
  bool coordsEmpty = (myXCoord->text().isEmpty()) || (myYCoord->text().isEmpty()) || (myZCoord->text().isEmpty());

  if ((selEnfVertex == 0) && coordsEmpty)
    return;

  string entry, shapeName;
  {
    std::string groupName = myGroupName->text().simplified().toStdString();

    if (selEnfVertex <= 1)
    {
      double x,y,z;
      x = myXCoord->GetValue();
      y = myYCoord->GetValue();
      z = myZCoord->GetValue();
      if (selEnfVertex == 1) {
        myEnfVertex = myEnfVertexWdg->GetObject< GEOM::GEOM_Object >();
        addEnforcedVertex(x, y, z, myEnfVertex->GetName(),myEnfVertex->GetStudyEntry(), groupName);
      }
      else
        addEnforcedVertex(x, y, z, "", "", groupName);
    }
    else
    {
      if ( CORBA::is_nil(getGeomEngine()))
        return;

      GEOM::GEOM_IMeasureOperations_var measureOp = getGeomEngine()->GetIMeasureOperations();
      if (CORBA::is_nil(measureOp))
        return;

      CORBA::Double x,y,z;
      x = y = z = 0.;
      for (size_t j = 0 ; j < selEnfVertex ; j++)
      {
        myEnfVertex = myEnfVertexWdg->GetObject< GEOM::GEOM_Object >(j);
        if (myEnfVertex->GetShapeType() == GEOM::VERTEX) {
          measureOp->PointCoordinates (myEnfVertex, x, y, z);
          if ( measureOp->IsDone() )
            addEnforcedVertex(x, y, z, myEnfVertex->GetName(),myEnfVertex->GetStudyEntry(), groupName);
        } else if (myEnfVertex->GetShapeType() == GEOM::COMPOUND) {
            addEnforcedVertex(0, 0, 0, myEnfVertex->GetName(),myEnfVertex->GetStudyEntry(), groupName);
        }
      }
    }
  }

  myEnfVertexWdg->SetObject(GEOM::GEOM_Object::_nil());
  
  for (int column = 0; column < myEnforcedTreeWidget->columnCount(); ++column)
    myEnforcedTreeWidget->resizeColumnToContents(column);

  if ( myStdWidget->myPhysicalMesh->currentIndex() != PhysicalLocalSize ) {
    myStdWidget->myPhysicalMesh->setCurrentIndex( PhysicalLocalSize );
    myStdWidget->onPhysicalMeshChanged();
  }
}

/** BLSURFPluginGUI_HypothesisCreator::onRemoveEnforcedVertex()
This method is called when a item is removed from the enforced vertices tree widget
*/
void BLSURFPluginGUI_HypothesisCreator::onRemoveEnforcedVertex()
{
  QList<QTreeWidgetItem *> selectedItems = myEnforcedTreeWidget->selectedItems();
  QList<QTreeWidgetItem *> selectedVertices;
  QSet<QTreeWidgetItem *> selectedEntries;
  QTreeWidgetItem* item;

  foreach( item, selectedItems ) {
    QVariant value = item->data(ENF_VER_X_COLUMN, Qt::EditRole);
    if (! value.isNull())
      selectedVertices.append(item);
    else {
      value = item->data(ENF_VER_ENTRY_COLUMN, Qt::EditRole);
      if (! value.isNull())
        selectedVertices.append(item);
      else
        selectedEntries.insert(item);
    }
  }

  foreach(item,selectedVertices) {
    QTreeWidgetItem* parent = item->parent();
    if ( parent )
      parent->removeChild(item);
    delete item;
    if ( parent && parent->childCount() == 0) {
      if (selectedEntries.contains(parent))
        selectedEntries.remove(parent);
      delete parent;
    }
  }

  foreach(item,selectedEntries) {
    delete item;
  }

  myEnforcedTreeWidget->selectionModel()->clearSelection();
}


void BLSURFPluginGUI_HypothesisCreator::onInternalVerticesClicked(int state)
{
  myInternalEnforcedVerticesAllFacesGroup->setEnabled(state == Qt::Checked);
}

/** BLSURFPluginGUI_HypothesisCreator::onAddPeriodicity()
This method is called when a item is added into the periodicity table widget
*/
void BLSURFPluginGUI_HypothesisCreator::onAddPeriodicity()
{
  BLSURFPluginGUI_HypothesisCreator* that = (BLSURFPluginGUI_HypothesisCreator*)this;

  that->getGeomSelectionTool()->selectionMgr()->clearFilters();
  ListOfWidgets::const_iterator anIt = myPeriodicitySelectionWidgets.begin();
  for ( ; anIt != myPeriodicitySelectionWidgets.end(); anIt++)
    {
          StdMeshersGUI_ObjectReferenceParamWdg * w1 = ( StdMeshersGUI_ObjectReferenceParamWdg* ) ( *anIt );
          w1->deactivateSelection();
    }


  // Source-Target selection
  size_t selSource = myPeriodicitySourceFaceWdg->NbObjects();
  size_t selTarget = myPeriodicityTargetFaceWdg->NbObjects();

  if (selSource == 0 || selTarget == 0)
    return;

  // Vertices selection
  if (myPeriodicityGroupBox2->isChecked())
    {
      size_t P1Ssel = myPeriodicityP1SourceWdg->NbObjects();
      size_t P2Ssel = myPeriodicityP2SourceWdg->NbObjects();
      size_t P3Ssel = myPeriodicityP3SourceWdg->NbObjects();
      size_t P1Tsel = myPeriodicityP1TargetWdg->NbObjects();
      //size_t P2Tsel = myPeriodicityP2TargetWdg->NbObjects();
      size_t P3Tsel = myPeriodicityP3TargetWdg->NbObjects();

      if (P1Ssel!=1 || P2Ssel!=1 || P3Ssel!=1 || P1Tsel!=1 || P3Tsel!=1 || P3Tsel!=1)
        {
          QString msg = tr("BLSURF_PERIODICITY_WRONG_NUMBER_OF_VERTICES");
          SUIT_MessageBox::critical( dlg(),"Error" , msg );
          return;
        }
    }

  // Add Source-Target in table
  string shapeEntry, sourceEntry, targetEntry;
  string shapeName, sourceName, targetName;
  GEOM::GEOM_Object_var shape;

  QTreeWidgetItem* item = new QTreeWidgetItem();
  myPeriodicityTreeWidget->addTopLevelItem(item);

  item->setFlags( Qt::ItemIsSelectable   |Qt::ItemIsEnabled );


  int k=0;
  for (anIt = myPeriodicitySelectionWidgets.begin(); anIt != myPeriodicitySelectionWidgets.end(); anIt++, k++)
    {
      StdMeshersGUI_ObjectReferenceParamWdg * w1 = ( StdMeshersGUI_ObjectReferenceParamWdg* ) ( *anIt );
      shape = w1->GetObject< GEOM::GEOM_Object >(0);
      shapeName = shape->GetName();
      shapeEntry = shape->GetStudyEntry();
      item->setData(k, Qt::EditRole, shapeName.c_str() );
      item->setData(k, Qt::UserRole, shapeEntry.c_str() );
      if (! myPeriodicityGroupBox2->isChecked() && k==1)
        break;
    }

  // Add shape type in tree
  string onFace = (myPeriodicityOnFaceRadioButton->isChecked()) ? "1" : "0";
  item->setData(PERIODICITY_SHAPE_TYPE, Qt::UserRole, onFace.c_str());

  // Blank input fields
  for (anIt = myPeriodicitySelectionWidgets.begin(); anIt != myPeriodicitySelectionWidgets.end(); anIt++)
    {
      StdMeshersGUI_ObjectReferenceParamWdg * w1 = ( StdMeshersGUI_ObjectReferenceParamWdg* ) ( *anIt );
      w1->SetObject(GEOM::GEOM_Object::_nil());
    }

//  for (int column = 0; column < myPeriodicityTreeWidget->columnCount(); ++column)
//    myPeriodicityTreeWidget->resizeColumnToContents(column);

}

/** BLSURFPluginGUI_HypothesisCreator::onRemovePeriodicity()
This method is called when a item is removed from the periodicity tree widget
*/
void BLSURFPluginGUI_HypothesisCreator::onRemovePeriodicity()
{
  QList<QTreeWidgetItem *> selectedItems = myPeriodicityTreeWidget->selectedItems();
  QTreeWidgetItem* item;

  foreach(item,selectedItems) {
    delete item;
  }

  myEnforcedTreeWidget->selectionModel()->clearSelection();
}

/** BLSURFPluginGUI_HypothesisCreator::onPeriodicityByVerticesChecked()
This method enable clears the field for periodicity by vertices
*/
void BLSURFPluginGUI_HypothesisCreator::onPeriodicityByVerticesChecked(bool checked)
{
  if (! checked)
    {
      for (int k=2; k<myPeriodicitySelectionWidgets.size(); k++)
        {
          StdMeshersGUI_ObjectReferenceParamWdg * w1 = ( StdMeshersGUI_ObjectReferenceParamWdg* ) ( myPeriodicitySelectionWidgets[k] );
          w1->deactivateSelection();
          w1->SetObject(CORBA::Object::_nil());
        }
    }
}

/** BLSURFPluginGUI_HypothesisCreator::onPeriodicityRadioButtonChanged()
This method enable the proper shape selection widget to Face or Edge shapes
*/
//void BLSURFPluginGUI_HypothesisCreator::onPeriodicityRadioButtonChanged()
//{
//  if (myPeriodicityOnFaceRadioButton->isChecked())
//    {
//      myPeriodicitySourceEdgeWdg->hide();
//      myPeriodicityTargetEdgeWdg->hide();
//      myPeriodicitySourceFaceWdg->show();
//      myPeriodicityTargetFaceWdg->show();
//    }
//  else
//    {
//      myPeriodicitySourceFaceWdg->hide();
//      myPeriodicityTargetFaceWdg->hide();
//      myPeriodicitySourceEdgeWdg->show();
//      myPeriodicityTargetEdgeWdg->show();
//    }
//}

void BLSURFPluginGUI_HypothesisCreator::onPeriodicityTreeClicked(QTreeWidgetItem* item, int /*row*/)
{
  QString shapeName, shapeEntry;
  CORBA::Object_var shape;
  int k=0;
  ListOfWidgets::const_iterator anIt = myPeriodicitySelectionWidgets.begin();
  for (; anIt != myPeriodicitySelectionWidgets.end(); anIt++, k++)
    {
      StdMeshersGUI_ObjectReferenceParamWdg * w1 = ( StdMeshersGUI_ObjectReferenceParamWdg* ) ( *anIt );

      shapeName = item->data(k, Qt::EditRole).toString();
      shapeEntry = item->data(k, Qt::UserRole).toString();
      if (! shapeEntry.isEmpty())
        {
          shape = entryToObject(shapeEntry);
          w1->SetObject(shape);
          w1->deactivateSelection();
          if (k==2)
            myPeriodicityGroupBox2->setChecked(1);
        }
      else if(k==2)
        myPeriodicityGroupBox2->setChecked(0);
    }

  if (item->data(PERIODICITY_SHAPE_TYPE, Qt::UserRole) == "1")
    myPeriodicityOnFaceRadioButton->setChecked(true);
  else
    myPeriodicityOnEdgeRadioButton->setChecked(true);


}

/** BLSURFPluginGUI_HypothesisCreator::onPeriodicityContentModified()
This method gives the focus to the next selection widget when a content is modified in a selection widget.
*/
void BLSURFPluginGUI_HypothesisCreator::onPeriodicityContentModified()
{
  BLSURFPluginGUI_HypothesisCreator* that = (BLSURFPluginGUI_HypothesisCreator*)this;

  ListOfWidgets::const_iterator anIt = myPeriodicitySelectionWidgets.begin();
  int k=0;
  // find wich selection widget is activated
  for (; anIt != myPeriodicitySelectionWidgets.end(); anIt++, k++)
    {
      StdMeshersGUI_ObjectReferenceParamWdg * w1 = ( StdMeshersGUI_ObjectReferenceParamWdg* ) ( *anIt );
      if (w1->IsSelectionActivated() && k<(myPeriodicitySelectionWidgets.size()-1))
        {
          // don't activate vertex selection if the group box is not checked
          if (k==1 && !myPeriodicityGroupBox2->isChecked())
            break;
          // clear the selection, to avoid to put the same object in the other widget
          that->getGeomSelectionTool()->selectionMgr()->clearSelected();
          // activate the next widget
          StdMeshersGUI_ObjectReferenceParamWdg * w2 = ( StdMeshersGUI_ObjectReferenceParamWdg* ) ( myPeriodicitySelectionWidgets[k+1] );
          w2->activateSelection();
          break;
        }
    }
}


/** BLSURFPluginGUI_HypothesisCreator::retrieveParams()
    This method updates the GUI widgets with the hypothesis data
*/
void BLSURFPluginGUI_HypothesisCreator::retrieveParams() const
{
  BLSURFPluginGUI_HypothesisCreator* that = (BLSURFPluginGUI_HypothesisCreator*)this;

  BlsurfHypothesisData data;
  that->readParamsFromHypo( data );

  if ( myName ) {
    myName->setText( data.myName );
    QFontMetrics metrics( myName->font() );
    myName->setMinimumWidth( metrics.width( data.myName )+5 );
  }
  myStdWidget->myPhysicalMesh->setCurrentIndex( data.myPhysicalMesh );
  myStdWidget->myGeometricMesh->setCurrentIndex( data.myGeometricMesh );
  if (data.myPhySize <= 0)
    myStdWidget->myPhySize->setText("");
  else
    myStdWidget->myPhySize->SetValue( data.myPhySize );
  myStdWidget->myPhySizeRel->setChecked( data.myPhySizeRel );
  if (data.myMinSize < 0)
    myStdWidget->myMinSize->setText("");
  else
    myStdWidget->myMinSize->SetValue( data.myMinSize );
  myStdWidget->myMinSizeRel->setChecked( data.myMinSizeRel );
  if (data.myMaxSize < 0)
    myStdWidget->myMaxSize->setText("");
  else
    myStdWidget->myMaxSize->SetValue( data.myMaxSize );
  myStdWidget->myMaxSizeRel->setChecked( data.myMaxSizeRel );
  myStdWidget->myUseGradation->setChecked( data.myUseGradation );
  if (data.myGradation <= 0 || !data.myUseGradation )
    myStdWidget->myGradation->setText("");
  else
    myStdWidget->myGradation->SetValue( data.myGradation );
  myStdWidget->myUseVolumeGradation->setChecked( data.myUseVolumeGradation );
  if (data.myVolumeGradation <= 0 || !data.myUseVolumeGradation )
    myStdWidget->myVolumeGradation->setText("");
  else
    myStdWidget->myVolumeGradation->SetValue( data.myVolumeGradation );

  foreach (QAbstractButton* button, myStdWidget->myButtonGroupElementType->buttons()) {
    if (myStdWidget->myButtonGroupElementType->id(button) == data.myElementType) {
      button->setChecked(true);
      break;
    }
  }

  myStdWidget->myUseSurfaceProximity->setChecked( data.myUseSurfaceProximity );
  myStdWidget->myNbSurfaceProximityLayers->setValue( data.myNbSurfaceProximityLayers );
  myStdWidget->mySurfaceProximityRatio->SetValue( data.mySurfaceProximityRatio );
  myStdWidget->myUseVolumeProximity->setChecked( data.myUseVolumeProximity );
  myStdWidget->myNbVolumeProximityLayers->setValue( data.myNbVolumeProximityLayers );
  myStdWidget->myVolumeProximityRatio->SetValue( data.myVolumeProximityRatio );
  if ( !data.myUseSurfaceProximity )
  {
    //myStdWidget->myNbSurfaceProximityLayers->setText("");
    myStdWidget->mySurfaceProximityRatio->setText("");
  }
  if ( !data.myUseVolumeProximity )
  {
    //myStdWidget->myNbVolumeProximityLayers->setText("");
    myStdWidget->myVolumeProximityRatio->setText("");
  }

  if (data.myAngleMesh < 0)
    myStdWidget->myAngleMesh->setText("");
  else
    myStdWidget->myAngleMesh->SetValue( data.myAngleMesh );
  if (data.myChordalError <= 0)
    myStdWidget->myChordalError->setText("");
  else
    myStdWidget->myChordalError->SetValue( data.myChordalError );
  myStdWidget->myAnisotropic->setChecked( data.myAnisotropic );
  if (data.myAnisotropicRatio <= 0)
    myStdWidget->myAnisotropicRatio->setText("");
  else
    myStdWidget->myAnisotropicRatio->SetValue( data.myAnisotropicRatio );
  myStdWidget->myRemoveTinyEdges->setChecked( data.myRemoveTinyEdges );
  if (data.myTinyEdgeLength <= 0)
    myStdWidget->myTinyEdgeLength->setText("");
  else
    myStdWidget->myTinyEdgeLength->SetValue( data.myTinyEdgeLength );
  myStdWidget->myOptimiseTinyEdges->setChecked( data.myOptimiseTinyEdges );
  if (data.myTinyEdgeOptimisLength <= 0)
    myStdWidget->myTinyEdgeOptimisLength->setText("");
  else
    myStdWidget->myTinyEdgeOptimisLength->SetValue( data.myTinyEdgeOptimisLength );
  myStdWidget->myCorrectSurfaceIntersection->setChecked( data.myCorrectSurfaceIntersection );
  if (data.myCorrectSurfaceIntersectionMaxCost <= 0)
    myStdWidget->myCorrectSurfaceIntersectionMaxCost->setText("");
  else
    myStdWidget->myCorrectSurfaceIntersectionMaxCost->SetValue( data.myCorrectSurfaceIntersectionMaxCost );
  myStdWidget->myForceBadElementRemoval->setChecked( data.myForceBadElementRemoval );
  if (data.myBadElementAspectRatio <= 0)
    myStdWidget->myBadElementAspectRatio->setText("");
  else
    myStdWidget->myBadElementAspectRatio->SetValue( data.myBadElementAspectRatio );
  myStdWidget->myOptimizeMesh->setChecked( data.myOptimizeMesh );
  myStdWidget->myQuadraticMesh->setChecked( data.myQuadraticMesh );
  
  myStdWidget->resizeWidgets();  
  
  myAdvWidget->myVerbosity->setValue( data.myVerbosity );

  if ( myOptions.operator->() ) {
    for ( int i = 0, nb = myOptions->length(); i < nb; ++i )
      myAdvWidget->AddOption( TBL_MESHING, that->myOptions[i].in() );
  }
  if ( myPreCADOptions.operator->() ) {
    for ( int i = 0, nb = myPreCADOptions->length(); i < nb; ++i )
      myAdvWidget->AddOption( TBL_PRECAD, that->myPreCADOptions[i].in() );
  }
  if ( myCustomOptions.operator->() ) {
    for ( int i = 0, nb = myCustomOptions->length(); i < nb; ++i )
      myAdvWidget->AddOption( TBL_CUSTOM, that->myCustomOptions[i].in() );
  }
  myAdvWidget->myOptionTable->resizeColumnToContents( OPTION_NAME_COLUMN );
  myAdvWidget->myGMFFileName->setText(QString(data.myGMFFileName.c_str()));
//   myGMFFileMode->setChecked(data.myGMFFileMode);
  
  // Sizemaps
  QMapIterator<QString, QString> i(that->mySMPMap);
  GeomSelectionTools* myGeomToolSelected = that->getGeomSelectionTool();
  while (i.hasNext()) {
    i.next();
    const QString entry = i.key();
    const QString sizeMap = i.value();
    string shapeName = myGeomToolSelected->getNameFromEntry(entry.toStdString());
    //int row = mySizeMapTable->topLevelItemCount();
    QTreeWidgetItem* item = new QTreeWidgetItem();
    mySizeMapTable->addTopLevelItem( item );
    item->setFlags(Qt::ItemIsSelectable | Qt::ItemIsEditable | Qt::ItemIsEnabled );
    item->setData(SMP_ENTRY_COLUMN,Qt::DisplayRole, QVariant(entry) );
    item->setData(SMP_NAME_COLUMN, Qt::DisplayRole, QVariant( QString::fromStdString(shapeName) ) );
    if (that->myATTMap.contains(entry)) {
      TAttractorVec & attVec = that->myATTMap[entry];
      for ( size_t i = 0; i < attVec.size(); ++i )
      {
        std::string attName = myGeomToolSelected->getNameFromEntry( attVec[i].attEntry );
        QTreeWidgetItem* child = new QTreeWidgetItem();
        item->addChild( child );
        item->setExpanded(true);
        child->setData(SMP_SIZEMAP_COLUMN, Qt::EditRole, QVariant( attVec[i].startSize  ));
        child->setData(SMP_ENTRY_COLUMN, Qt::DisplayRole, QVariant( attVec[i].attEntry.c_str() ));
        child->setData(SMP_NAME_COLUMN, Qt::DisplayRole, QVariant( attName.c_str() ));

        if ( attVec[i].infDist >  std::numeric_limits<double>::epsilon()){
          item->setData(SMP_SIZEMAP_COLUMN, Qt::DisplayRole, QVariant( "Attractor" ));
        }
        else{
          item->setData(SMP_SIZEMAP_COLUMN, Qt::DisplayRole, QVariant( "Constant Size" ));
        }
      }
    }
    else
    {
      item->setData(SMP_SIZEMAP_COLUMN, Qt::EditRole, QVariant( sizeMap ) );
    }
  }
  mySizeMapTable->resizeColumnToContents( SMP_ENTRY_COLUMN );
  mySizeMapTable->resizeColumnToContents( SMP_NAME_COLUMN );
  mySizeMapTable->resizeColumnToContents(SMP_SIZEMAP_COLUMN);

  // Enforced vertices
  TFaceEntryEnfVertexListMap::const_iterator evmIt = data.faceEntryEnfVertexListMap.begin();

  for ( ; evmIt != data.faceEntryEnfVertexListMap.end() ; ++evmIt) {
    TEntry entry = (*evmIt).first;
    std::string shapeName = myGeomToolSelected->getNameFromEntry(entry);

    //QTreeWidgetItem* faceItem = that->addEnforcedFace(entry, shapeName);

    TEnfVertexList evs = (*evmIt).second;

    TEnfVertexList::const_iterator evsIt = evs.begin();
    TEnfVertex *enfVertex;
    for ( ; evsIt != evs.end() ; ++evsIt) {
      enfVertex = (*evsIt);
      double x = 0, y = 0, z = 0;
      if (enfVertex->coords.size()) {
        x = enfVertex->coords[0];
        y = enfVertex->coords[1];
        z = enfVertex->coords[2];
      }
      that->addEnforcedVertex(x, y, z, enfVertex->name, enfVertex->geomEntry, enfVertex->grpName);
    }
  }

  for (int column = 0; column < myEnforcedTreeWidget->columnCount(); ++column)
    myEnforcedTreeWidget->resizeColumnToContents(column);

  myInternalEnforcedVerticesAllFaces->setChecked(data.myInternalEnforcedVerticesAllFaces);
  myInternalEnforcedVerticesAllFacesGroup->setText(QString(data.myInternalEnforcedVerticesAllFacesGroup.c_str()));
  myInternalEnforcedVerticesAllFacesGroup->setEnabled(data.myInternalEnforcedVerticesAllFaces);

  // Periodicity

  // Add an item in the tree widget for each association
  for (size_t i=0 ; i<data.preCadPeriodicityVector.size() ; i++)
  {
    QTreeWidgetItem* item = new QTreeWidgetItem();
    myPeriodicityTreeWidget->addTopLevelItem(item);
    item->setFlags( Qt::ItemIsSelectable   |Qt::ItemIsEnabled );
    TPreCadPeriodicity periodicity_i = data.preCadPeriodicityVector[i];
    for (size_t k=0; k<periodicity_i.size(); k++)
    {
      string shapeEntry = periodicity_i[k];
      string shapeName = myGeomToolSelected->getNameFromEntry(shapeEntry);
      item->setData((int) k, Qt::EditRole, shapeName.c_str() );
      item->setData((int) k, Qt::UserRole, shapeEntry.c_str() );
    }
  }

  // Hyper patches

  QString patchEntries;
  for ( int i = 0; i < data.hyperpatches.size(); ++i )
  {
    if ( i < data.hyperEntries.size() )
      patchEntries = data.hyperEntries[i];
    that->addHyPatchToTable( data.hyperpatches[i], patchEntries );
  }
  // update widgets
  that->myStdWidget->onPhysicalMeshChanged();
  that->myStdWidget->onGeometricMeshChanged();
  that->onStateChange();

  // Enforced mesh

  BLSURFPlugin::BLSURFPlugin_Hypothesis_var h =
    BLSURFPlugin::BLSURFPlugin_Hypothesis::_narrow( initParamsHypothesis() );

  BLSURFPlugin::EnforcedMeshesList_var enfMeshes = h->GetEnforcedMeshes();
  for ( CORBA::ULong i = 0; i < enfMeshes->length(); ++i )
  {
    BLSURFPlugin::MG_EnforcedMesh1D & enfMesh = enfMeshes[i];
    that->addEnforcedMesh( enfMesh.mesh.in(), enfMesh.groupName.in() );
  }
}

/** BLSURFPluginGUI_HypothesisCreator::storeParams()
This method updates the hypothesis data with the GUI widgets content.
*/
QString BLSURFPluginGUI_HypothesisCreator::storeParams() const
{
  BLSURFPluginGUI_HypothesisCreator* that = (BLSURFPluginGUI_HypothesisCreator*)this;

  BlsurfHypothesisData data;
  QString guiHyp = that->readParamsFromWidgets( data );
  that->storeParamsToHypo( data );

  return guiHyp;
}

/** BLSURFPluginGUI_HypothesisCreator::readParamsFromHypo(h_data)
Updates the hypothesis data from hypothesis values.
*/
bool BLSURFPluginGUI_HypothesisCreator::readParamsFromHypo( BlsurfHypothesisData& h_data ) const
{
  BLSURFPlugin::BLSURFPlugin_Hypothesis_var h =
    BLSURFPlugin::BLSURFPlugin_Hypothesis::_narrow( initParamsHypothesis() );

  HypothesisData* data = SMESH::GetHypothesisData( hypType() );
  h_data.myName = isCreation() && data ? hypName() : "";

  h_data.myPhysicalMesh           = (int) h->GetPhysicalMesh();
  h_data.myGeometricMesh          = (int) h->GetGeometricMesh();
  h_data.myPhySize                = h->GetPhySize();
  h_data.myPhySizeRel             = h->IsPhySizeRel();
  double minSize                  = h->GetMinSize();
  double maxSize                  = h->GetMaxSize();
  h_data.myMinSize                = minSize > 0 ? minSize : -1.0;
  h_data.myMinSizeRel             = h->IsMinSizeRel();
  h_data.myMaxSize                = maxSize > 0 ? maxSize : -1.0;
  h_data.myMaxSizeRel             = h->IsMaxSizeRel();
  h_data.myUseGradation           = h->GetUseGradation();
  h_data.myGradation              = h->GetGradation();
  h_data.myUseVolumeGradation     = h->GetUseVolumeGradation();
  h_data.myVolumeGradation        = h->GetVolumeGradation();
  h_data.myElementType            = h->GetElementType();
  double angle                    = h->GetAngleMesh();
  h_data.myAngleMesh              = angle > 0 ? angle : -1.0;
  double chordalError             = h->GetChordalError();
  h_data.myChordalError           = chordalError > 0 ? chordalError : -1.0;
  h_data.myAnisotropic            = h->GetAnisotropic();
  double myAnisotropicRatio       = h->GetAnisotropicRatio();
  h_data.myAnisotropicRatio       = myAnisotropicRatio > 0 ? myAnisotropicRatio : -1.0;
  h_data.myRemoveTinyEdges        = h->GetRemoveTinyEdges();
  double myTinyEdgeLength         = h->GetTinyEdgeLength();
  h_data.myTinyEdgeLength         = myTinyEdgeLength > 0 ? myTinyEdgeLength : -1.0;
  h_data.myOptimiseTinyEdges      = h->GetOptimiseTinyEdges();
  double myTinyEdgeOptimisLength  = h->GetTinyEdgeOptimisationLength();
  h_data.myTinyEdgeOptimisLength  = myTinyEdgeOptimisLength > 0 ? myTinyEdgeOptimisLength : -1.0;
  h_data.myCorrectSurfaceIntersection = h->GetCorrectSurfaceIntersection();
  double corrSurfaceIntersMaxCost = h->GetCorrectSurfaceIntersectionMaxCost();
  h_data.myCorrectSurfaceIntersectionMaxCost = corrSurfaceIntersMaxCost > 0 ? corrSurfaceIntersMaxCost : -1.0;
  h_data.myForceBadElementRemoval = h->GetBadElementRemoval();
  double myBadElementAspectRatio  = h->GetBadElementAspectRatio();
  h_data.myBadElementAspectRatio  = myBadElementAspectRatio > 0 ? myBadElementAspectRatio : -1.0;
  h_data.myOptimizeMesh           = h->GetOptimizeMesh();
  h_data.myQuadraticMesh          = h->GetQuadraticMesh();
  h_data.myVerbosity              = h->GetVerbosity();
  //h_data.myTopology               = (int) h->GetTopology();
  //h_data.myPreCADMergeEdges       = h->GetPreCADMergeEdges();
  // h_data.myPreCADProcess3DTopology  = h->GetPreCADProcess3DTopology();
  // h_data.myPreCADDiscardInput     = h->GetPreCADDiscardInput();
  h_data.myUseSurfaceProximity      = h->GetSurfaceProximity        ();
  h_data.myNbSurfaceProximityLayers = h->GetNbSurfaceProximityLayers();
  h_data.mySurfaceProximityRatio    = h->GetSurfaceProximityRatio   ();
  h_data.myUseVolumeProximity       = h->GetVolumeProximity         ();
  h_data.myNbVolumeProximityLayers  = h->GetNbVolumeProximityLayers ();
  h_data.myVolumeProximityRatio     = h->GetVolumeProximityRatio    ();

  BLSURFPluginGUI_HypothesisCreator* that = (BLSURFPluginGUI_HypothesisCreator*)this;
  that->myOptions       = h->GetOptionValues();
  that->myPreCADOptions = h->GetPreCADOptionValues();
  that->myCustomOptions = h->GetAdvancedOptionValues();

  h_data.myGMFFileName = h->GetGMFFile();
//   h_data.myGMFFileMode = h->GetGMFFileMode();

  that->mySMPMap.clear();
  that->myATTMap.clear();
  // that->myAttDistMap.clear();
  // that->myDistMap.clear();

  // classic size maps
  BLSURFPlugin::string_array_var mySizeMaps = h->GetSizeMapEntries();
  QString fullSizeMaps;
  QStringList fullSizeMapList;
  GeomSelectionTools* myGeomToolSelected = that->getGeomSelectionTool();
  for ( CORBA::ULong i = 0;i<mySizeMaps->length(); ++i ) {
    fullSizeMaps =  mySizeMaps[i].in();
    fullSizeMapList = fullSizeMaps.split( "|", QString::KeepEmptyParts );
    if ( fullSizeMapList.count() > 1 ) {
      string fullSizeMap = fullSizeMapList[1].toStdString();
      size_t pos = fullSizeMap.find("return")+7;
      QString sizeMap;
      try {
        sizeMap = QString::fromStdString(fullSizeMap.substr(pos, fullSizeMap.size()-pos));
      }
      catch (...) {
        continue;
      }
      that->mySMPMap[fullSizeMapList[0]] = sizeMap;
      that->mySMPShapeTypeMap[fullSizeMapList[0]] = myGeomToolSelected->entryToShapeType(fullSizeMapList[0].toStdString());
    }
  }

  // custom size maps
/*
  BLSURFPlugin::string_array_var myCustomSizeMaps = h->GetCustomSizeMapEntries();

  for ( int i = 0;i<myCustomSizeMaps->length(); ++i ) {
    QString fullCustomSizeMaps =  myCustomSizeMaps[i].in();
    QStringList fullCustomSizeMapList = fullCustomSizeMaps.split( "|", QString::KeepEmptyParts );
    if ( fullCustomSizeMapList.count() > 1 ) {
      that->mySMPMap[fullCustomSizeMapList[0]] = fullCustomSizeMapList[1];
      that->mySMPShapeTypeMap[fullCustomSizeMapList[0]] = GeomToolSelected->entryToShapeType(fullCustomSizeMapList[0].toStdString());
    }
  }
*/
  // attractor
  BLSURFPlugin::string_array_var allMyAttractors = h->GetAttractorEntries();

  for ( CORBA::ULong i = 0;i<allMyAttractors->length(); ++i ) {
    QString myAttractors =  allMyAttractors[i].in();
    QStringList myAttractorList = myAttractors.split( "|", QString::KeepEmptyParts );
    if ( myAttractorList.count() > 1 ) {
      that->mySMPMap[myAttractorList[0]] = myAttractorList[1];
      that->mySMPShapeTypeMap[myAttractorList[0]] = myGeomToolSelected->entryToShapeType(myAttractorList[0].toStdString());
    }
  }
  
  // attractor new version
  BLSURFPlugin::TAttParamsMap_var allMyAttractorParams = h->GetAttractorParams();
  for ( CORBA::ULong i = 0;i<allMyAttractorParams->length(); ++i ) {
    BLSURFPlugin::TAttractorParams myAttractorParams =  allMyAttractorParams[i];
    QString faceEntry = myAttractorParams.faceEntry.in();
    QString attEntry  = myAttractorParams.attEntry.in();
    that->mySMPMap[faceEntry] = QString::number( myAttractorParams.startSize, 'g',  6 ); // TODO utiliser les préférences ici (cf. sketcher)
    that->mySMPShapeTypeMap[faceEntry] = myGeomToolSelected->entryToShapeType(faceEntry.toStdString());
    that->myATTMap[faceEntry].push_back( TAttractor( myAttractorParams.attEntry.in(),
                                                     myAttractorParams.startSize,
                                                     myAttractorParams.infDist,
                                                     myAttractorParams.constDist ));
  }
  
  // Enforced vertices
  h_data.enfVertexList.clear();
  h_data.faceEntryEnfVertexListMap.clear();
  /* TODO GROUPS
  h_data.groupNameEnfVertexListMap.clear();
  */

  BLSURFPlugin::TFaceEntryEnfVertexListMap_var faceEntryEnfVertexListMap = h->GetAllEnforcedVerticesByFace();

  for ( CORBA::ULong i = 0;i<faceEntryEnfVertexListMap->length(); ++i )
  {
    std::string entry = faceEntryEnfVertexListMap[i].faceEntry.in();
    BLSURFPlugin::TEnfVertexList vertexList = faceEntryEnfVertexListMap[i].enfVertexList;

    for (CORBA::ULong j=0 ; j<vertexList.length(); ++j)
    {
      TEnfVertex *enfVertex = new TEnfVertex();
      enfVertex->name      = vertexList[j].name.in();
      enfVertex->geomEntry = vertexList[j].geomEntry.in();
      enfVertex->grpName   = vertexList[j].grpName.in();
      for (CORBA::ULong k=0 ; k< vertexList[j].coords.length();k++)
        enfVertex->coords.push_back(vertexList[j].coords[k]);

      h_data.faceEntryEnfVertexListMap[entry].insert(enfVertex);

      /* TODO GROUPS
      if (groupName != "") {
        h_data.groupNameEnfVertexListMap[groupName].insert(ev);
      }
      */
    }
//     h_data.enfVertMap[entry] = evs;
//     h_data.entryCoordsListMap[entry] = coordsList;

    if (h_data.faceEntryEnfVertexListMap[entry].size() == 0) {
      h_data.faceEntryEnfVertexListMap.erase(entry);
    }
  }
  h_data.myInternalEnforcedVerticesAllFaces = h->GetInternalEnforcedVertexAllFaces();
  h_data.myInternalEnforcedVerticesAllFacesGroup = h->GetInternalEnforcedVertexAllFacesGroup();

  // Periodicity

  h_data.preCadPeriodicityVector.clear();

  BLSURFPlugin::TPeriodicityList_var preCadFacePeriodicityVector = h->GetPreCadFacesPeriodicityVector();
  AddPreCadSequenceToVector(h_data, preCadFacePeriodicityVector, true);

  BLSURFPlugin::TPeriodicityList_var preCadEdgePeriodicityVector = h->GetPreCadEdgesPeriodicityVector();
  AddPreCadSequenceToVector(h_data, preCadEdgePeriodicityVector, false);

  // Hyper Patches

  GEOM::GEOM_Object_var geom = myHyPatchFaceSelector->GetGeomObjectByEntry( getMainShapeEntry() );
  if ( geom->_is_nil() )
    geom = myHyPatchFaceSelector->GetGeomObjectByEntry( getShapeEntry() );

  h_data.hyperpatches.clear();
  h_data.hyperEntries.clear();
  BLSURFPlugin::THyperPatchList_var               patchList = h->GetHyperPatches( geom );
  BLSURFPlugin::THyperPatchEntriesList_var patchEntriesList = h->GetHyperPatchShapes();
  for ( CORBA::ULong i = 0; i < patchList->length(); ++i )
  {
    QString tags;
    BLSURFPlugin::THyperPatch& patch = patchList[i];
    for ( CORBA::ULong j = 0; j < patch.length(); ++j )
      tags += QString::number( patch[j] ) + " ";
    if ( !tags.isEmpty() )
      h_data.hyperpatches.append( tags );

    if ( patchEntriesList->length() == patchList->length() )
    {
      QString entries;
      BLSURFPlugin::THyperPatchEntries& patchEntries = patchEntriesList[i];
      for ( CORBA::ULong j = 0; j < patchEntries.length(); ++j )
        entries += patchEntries[j].in() + QString(" ");
      if ( !entries.isEmpty() )
        h_data.hyperEntries.append( entries );
    }
  }
  if ( h_data.hyperpatches.size() != h_data.hyperEntries.size() )
    h_data.hyperEntries.clear();

  return true;
}

void BLSURFPluginGUI_HypothesisCreator::AddPreCadSequenceToVector(BlsurfHypothesisData& h_data,
    BLSURFPlugin::TPeriodicityList_var preCadFacePeriodicityVector, bool onFace) const
{

  for (CORBA::ULong i=0; i<preCadFacePeriodicityVector->length(); i++ )
    {
      TPreCadPeriodicity periodicity_i(PERIODICITY_NB_COLUMN);
      periodicity_i[PERIODICITY_OBJ_SOURCE_COLUMN] = preCadFacePeriodicityVector[i].shape1Entry.in();
      periodicity_i[PERIODICITY_OBJ_TARGET_COLUMN] = preCadFacePeriodicityVector[i].shape2Entry.in();

      BLSURFPlugin::TEntryList sourceVertices = preCadFacePeriodicityVector[i].theSourceVerticesEntries;
      BLSURFPlugin::TEntryList targetVertices = preCadFacePeriodicityVector[i].theTargetVerticesEntries;

      if (sourceVertices.length()!=0)
        {
          periodicity_i[PERIODICITY_P1_SOURCE_COLUMN] = sourceVertices[0].in();
          periodicity_i[PERIODICITY_P2_SOURCE_COLUMN] = sourceVertices[1].in();
          if ( onFace )
            periodicity_i[PERIODICITY_P3_SOURCE_COLUMN] = sourceVertices[2].in();
        }

      if (targetVertices.length()!=0)
        {
          periodicity_i[PERIODICITY_P1_TARGET_COLUMN] = targetVertices[0].in();
          periodicity_i[PERIODICITY_P2_TARGET_COLUMN] = targetVertices[1].in();
          if ( onFace )
            periodicity_i[PERIODICITY_P3_TARGET_COLUMN] = targetVertices[2].in();
        }

      if (onFace)
        periodicity_i[PERIODICITY_SHAPE_TYPE] = "1";
      else
        periodicity_i[PERIODICITY_SHAPE_TYPE] = "0";

      h_data.preCadPeriodicityVector.push_back(periodicity_i);
    }
}

/** BLSURFPluginGUI_HypothesisCreator::storeParamsToHypo(h_data)
Saves the hypothesis data to hypothesis values.
*/
bool BLSURFPluginGUI_HypothesisCreator::storeParamsToHypo( const BlsurfHypothesisData& h_data ) const
{
  BLSURFPlugin::BLSURFPlugin_Hypothesis_var h =
    BLSURFPlugin::BLSURFPlugin_Hypothesis::_narrow( hypothesis() );

  bool ok = true;
  try
  {
    if ( isCreation() )
      SMESH::SetName( SMESH::FindSObject( h ), h_data.myName.toLatin1().constData() );

    if ( h->GetPhysicalMesh() != h_data.myPhysicalMesh ) // avoid duplication of DumpPython commands
      h->SetPhysicalMesh( (int) h_data.myPhysicalMesh );
    if ( h->GetGeometricMesh() != (int) h_data.myGeometricMesh )
      h->SetGeometricMesh( (int) h_data.myGeometricMesh );

    if ( ((int) h_data.myPhysicalMesh == PhysicalGlobalSize)||((int) h_data.myPhysicalMesh == PhysicalLocalSize) ) {
      if ( h->GetPhySize()   != h_data.myPhySize ||
           h->IsPhySizeRel() != h_data.myPhySizeRel ) {
        if ( h_data.myPhySizeRel )
          h->SetPhySizeRel( h_data.myPhySize );
        else
          h->SetPhySize( h_data.myPhySize );
      }
    }
    if (h->GetMinSize()   != h_data.myMinSize ||
        h->IsMinSizeRel() != h_data.myMinSizeRel ) {
      if ( h_data.myMinSizeRel )
        h->SetMinSizeRel( h_data.myMinSize <= 0 ? -1 : h_data.myMinSize );
      else
        h->SetMinSize( h_data.myMinSize <= 0 ? -1 : h_data.myMinSize );
    }
    if (h->GetMaxSize()   != h_data.myMaxSize ||
        h->IsMaxSizeRel() != h_data.myMaxSizeRel ) {
      if ( h_data.myMaxSizeRel )
        h->SetMaxSizeRel( h_data.myMaxSize <= 0 ? -1 : h_data.myMaxSize );
      else
        h->SetMaxSize( h_data.myMaxSize <= 0 ? -1 : h_data.myMaxSize );
    }
    if ( h->GetUseGradation() !=  h_data.myUseGradation )
      h->SetUseGradation( h_data.myUseGradation );
    if ( h->GetGradation() !=  h_data.myGradation )
      h->SetGradation( h_data.myGradation <= 0 ? -1 : h_data.myGradation );
    if ( h->GetUseVolumeGradation() !=  h_data.myUseVolumeGradation )
      h->SetUseVolumeGradation( h_data.myUseVolumeGradation );
    if ( h->GetVolumeGradation() !=  h_data.myVolumeGradation )
      h->SetVolumeGradation( h_data.myVolumeGradation <= 0 ? -1 : h_data.myVolumeGradation );

    h->SetSurfaceProximity        ((CORBA::Short) h_data.myUseSurfaceProximity      );
    h->SetNbSurfaceProximityLayers((CORBA::Short) h_data.myNbSurfaceProximityLayers );
    h->SetSurfaceProximityRatio   ( h_data.mySurfaceProximityRatio    );
    h->SetVolumeProximity         ((CORBA::Short) h_data.myUseVolumeProximity       );
    h->SetNbVolumeProximityLayers ((CORBA::Short) h_data.myNbVolumeProximityLayers  );
    h->SetVolumeProximityRatio    ( h_data.myVolumeProximityRatio     );

    if ( h->GetElementType() != h_data.myElementType )
      h->SetElementType( h_data.myElementType );

    if ( (int) h_data.myGeometricMesh != DefaultGeom ) {
      if ( h->GetAngleMesh() != h_data.myAngleMesh )
        h->SetAngleMesh( h_data.myAngleMesh <= 0 ? -1 :h_data.myAngleMesh );
      if ( h->GetChordalError() != h_data.myChordalError )
        h->SetChordalError( h_data.myChordalError <= 0 ? -1 :h_data.myChordalError );
    }

    if ( h->GetAnisotropic() != h_data.myAnisotropic )
      h->SetAnisotropic( h_data.myAnisotropic );
    if ( h_data.myAnisotropic && ( h->GetAnisotropicRatio() != h_data.myAnisotropicRatio ) )
      h->SetAnisotropicRatio( h_data.myAnisotropicRatio <= 0 ? -1 :h_data.myAnisotropicRatio );

    if ( h->GetRemoveTinyEdges() != h_data.myRemoveTinyEdges )
      h->SetRemoveTinyEdges( h_data.myRemoveTinyEdges );
    if ( h_data.myRemoveTinyEdges && ( h->GetTinyEdgeLength() != h_data.myTinyEdgeLength ) )
      h->SetTinyEdgeLength( h_data.myTinyEdgeLength <= 0 ? -1 :h_data.myTinyEdgeLength );

    if ( h->GetOptimiseTinyEdges() != h_data.myOptimiseTinyEdges )
      h->SetOptimiseTinyEdges( h_data.myOptimiseTinyEdges );
    if ( h_data.myOptimiseTinyEdges && ( h->GetTinyEdgeOptimisationLength() != h_data.myTinyEdgeOptimisLength ) )
      h->SetTinyEdgeOptimisationLength( h_data.myTinyEdgeOptimisLength <= 0 ? -1 :h_data.myTinyEdgeOptimisLength );
    if ( h->GetCorrectSurfaceIntersection() != h_data.myCorrectSurfaceIntersection )
      h->SetCorrectSurfaceIntersection( h_data.myCorrectSurfaceIntersection );
    if ( h_data.myCorrectSurfaceIntersection && ( h->GetCorrectSurfaceIntersectionMaxCost() != h_data.myCorrectSurfaceIntersectionMaxCost ) )
      h->SetCorrectSurfaceIntersectionMaxCost( h_data.myCorrectSurfaceIntersectionMaxCost <= 0 ? -1 :h_data.myCorrectSurfaceIntersectionMaxCost );
    
    if ( h->GetBadElementRemoval() != h_data.myForceBadElementRemoval )
      h->SetBadElementRemoval( h_data.myForceBadElementRemoval );
    if ( h_data.myForceBadElementRemoval && ( h->GetBadElementAspectRatio() != h_data.myBadElementAspectRatio ) )
      h->SetBadElementAspectRatio( h_data.myBadElementAspectRatio <= 0 ? -1 :h_data.myBadElementAspectRatio );
    
    if ( h->GetOptimizeMesh() != h_data.myOptimizeMesh )
      h->SetOptimizeMesh( h_data.myOptimizeMesh );    
    
    if ( h->GetQuadraticMesh() != h_data.myQuadraticMesh )
      h->SetQuadraticMesh( h_data.myQuadraticMesh );

    if ( h->GetVerbosity() != h_data.myVerbosity )
      h->SetVerbosity((CORBA::Short) h_data.myVerbosity );
    // if ( h->GetTopology() != h_data.myTopology )
    //   h->SetTopology( (int) h_data.myTopology );
    // if ( h->GetPreCADMergeEdges() != h_data.myPreCADMergeEdges )
    //   h->SetPreCADMergeEdges( h_data.myPreCADMergeEdges );
    // if ( h->GetPreCADProcess3DTopology() != h_data.myPreCADProcess3DTopology )
    //   h->SetPreCADProcess3DTopology( h_data.myPreCADProcess3DTopology );
    // if ( h->GetPreCADDiscardInput() != h_data.myPreCADDiscardInput )
    //   h->SetPreCADDiscardInput( h_data.myPreCADDiscardInput );

    // options are set in checkParams()
    //h->SetOptionValues( myOptions ); // is set in readParamsFromWidgets()
    //h->SetPreCADOptionValues( myPreCADOptions ); // is set in readParamsFromWidgets()

    if ( h->GetGMFFile() != h_data.myGMFFileName )
      //       || ( h->GetGMFFileMode() != h_data.myGMFFileMode ) )
      //       h->SetGMFFile( h_data.myGMFFileName.c_str(), h_data.myGMFFileMode );
      h->SetGMFFile( h_data.myGMFFileName.c_str());

    BLSURFPluginGUI_HypothesisCreator* that = (BLSURFPluginGUI_HypothesisCreator*)this;
    QMapIterator<QString,QString> i(that->mySMPMap);
    while (i.hasNext()) {
      i.next();
      const QString entry = i.key();
      const QString sizeMap = i.value();

      if (sizeMap == "__TO_DELETE__") {
        h->UnsetEntry(entry.toLatin1().constData());
      }
      else if (sizeMap.startsWith("ATTRACTOR")) {
        h->SetAttractorEntry( entry.toLatin1().constData(), sizeMap.toLatin1().constData());
      }
      else if (sizeMap.startsWith("def")) {
        //        h->SetCustomSizeMapEntry( entry.toLatin1().constData(), sizeMap.toLatin1().constData() );
      }
      else {
        if (!myATTMap[entry].empty()){
          const TAttractorVec& attVec = myATTMap[entry];
          for ( size_t i = 0; i < attVec.size(); ++i )
          {
            if ( attVec[i].IsToDelete() )
              h->UnsetAttractorEntry( entry.toLatin1().constData(),
                                      attVec[i].attEntry.c_str() );
            else
              h->SetClassAttractorEntry( entry.toLatin1().constData(),
                                         attVec[i].attEntry.c_str(),
                                         attVec[i].startSize,
                                         h->GetPhySize(),
                                         attVec[i].infDist,
                                         attVec[i].constDist );
          }
        }
        else {
          QString fullSizeMap;
          fullSizeMap = QString("");
          if (that->mySMPShapeTypeMap[entry]  == TopAbs_FACE)
            fullSizeMap = QString("def f(u,v): return ") + sizeMap;
          else if (that->mySMPShapeTypeMap[entry]  == TopAbs_EDGE)
            fullSizeMap = QString("def f(t): return ") + sizeMap;
          else if (that->mySMPShapeTypeMap[entry] == TopAbs_VERTEX)
            fullSizeMap = QString("def f(): return ") + sizeMap;
          h->SetSizeMapEntry( entry.toLatin1().constData(), fullSizeMap.toLatin1().constData() );
        }
      }
    }

    // Enforced vertices
    //bool ret;
    double x, y, z = 0;
    std::string enfName;
    /* TODO GROUPS
       std::string groupName = "";
    */

    TFaceEntryEnfVertexListMap::const_iterator evmIt = h_data.faceEntryEnfVertexListMap.begin();
    // 1. Clear all enforced vertices in hypothesis
    // 2. Add new enforced vertex according to h_data

    if ( h->GetAllEnforcedVertices()->length() > 0 )
      h->ClearAllEnforcedVertices();
    TEnfName faceEntry;
    TEnfVertexList evs;
    TEnfVertexList::const_iterator evsIt;
    for ( ; evmIt != h_data.faceEntryEnfVertexListMap.end() ; ++evmIt)
    {
      faceEntry = evmIt->first;
      evs = evmIt->second;
      evsIt = evs.begin();
      for ( ; evsIt != evs.end() ; ++evsIt)
      {
        x =y =z = 0;
        if ((*evsIt)->coords.size()) {
          x = (*evsIt)->coords[0];
          y = (*evsIt)->coords[1];
          z = (*evsIt)->coords[2];
        }
        //ret =
        h->SetEnforcedVertexEntry( faceEntry.c_str(), x, y, z, (*evsIt)->name.c_str(), (*evsIt)->geomEntry.c_str(), (*evsIt)->grpName.c_str());
      } // for
    } // for

    if ( h->GetInternalEnforcedVertexAllFaces() != h_data.myInternalEnforcedVerticesAllFaces )
      h->SetInternalEnforcedVertexAllFaces( h_data.myInternalEnforcedVerticesAllFaces );
    if ( h->GetInternalEnforcedVertexAllFacesGroup() != h_data.myInternalEnforcedVerticesAllFacesGroup )
      h->SetInternalEnforcedVertexAllFacesGroup( h_data.myInternalEnforcedVerticesAllFacesGroup.c_str() );

    // Periodicity
    if ( h->GetPreCadFacesPeriodicityVector()->length() > 0 || h->GetPreCadEdgesPeriodicityVector()->length() > 0 )
      h->ClearPreCadPeriodicityVectors();

    TPreCadPeriodicityVector::const_iterator pIt = h_data.preCadPeriodicityVector.begin();
    for ( ; pIt != h_data.preCadPeriodicityVector.end() ; ++pIt)
    {
      TPreCadPeriodicity periodicity_i = *pIt;
      TEntry source = periodicity_i[PERIODICITY_OBJ_SOURCE_COLUMN];
      TEntry target = periodicity_i[PERIODICITY_OBJ_TARGET_COLUMN];
      TEntry p1Source = periodicity_i[PERIODICITY_P1_SOURCE_COLUMN];
      TEntry p2Source = periodicity_i[PERIODICITY_P2_SOURCE_COLUMN];
      TEntry p3Source = periodicity_i[PERIODICITY_P3_SOURCE_COLUMN];
      TEntry p1Target = periodicity_i[PERIODICITY_P1_TARGET_COLUMN];
      TEntry p2Target = periodicity_i[PERIODICITY_P2_TARGET_COLUMN];
      TEntry p3Target = periodicity_i[PERIODICITY_P3_TARGET_COLUMN];
      bool onFace = (periodicity_i[PERIODICITY_SHAPE_TYPE]=="1") ? true : false;

      BLSURFPlugin::TEntryList_var sourceVertices = new BLSURFPlugin::TEntryList();
      if (! p1Source.empty())
      {
        sourceVertices->length(3);
        sourceVertices[0]=CORBA::string_dup(p1Source.c_str());
        sourceVertices[1]=CORBA::string_dup(p2Source.c_str());
        sourceVertices[2]=CORBA::string_dup(p3Source.c_str());
      }


      BLSURFPlugin::TEntryList_var targetVertices = new BLSURFPlugin::TEntryList();
      if (! p1Target.empty())
      {
        targetVertices->length(3);
        targetVertices[0]=CORBA::string_dup(p1Target.c_str());
        targetVertices[1]=CORBA::string_dup(p2Target.c_str());
        targetVertices[2]=CORBA::string_dup(p3Target.c_str());
      }

      if (onFace)
        h->AddPreCadFacesPeriodicityEntry(source.c_str(), target.c_str(), sourceVertices, targetVertices);
      else
        h->AddPreCadEdgesPeriodicityEntry(source.c_str(), target.c_str(), sourceVertices, targetVertices);
    }

    // Hyper-patches
    BLSURFPlugin::THyperPatchList_var         hpl = new BLSURFPlugin::THyperPatchList();
    BLSURFPlugin::THyperPatchEntriesList_var hpel = new BLSURFPlugin::THyperPatchEntriesList();
    hpl ->length( h_data.hyperpatches.size() );
    hpel->length( h_data.hyperEntries.size() );

    for ( int i = 0; i < h_data.hyperpatches.size(); ++i )
    {
      QStringList tags = h_data.hyperpatches[i].split(" ",  QString::SkipEmptyParts);
      BLSURFPlugin::THyperPatch& patch = hpl[ i ];
      patch.length( tags.size() );

      for ( int j = 0; j < tags.size(); ++j )
        patch[ j ] = tags[ j ].toInt();

      if ( i < h_data.hyperEntries.size() )
      {
        QStringList entries = h_data.hyperEntries[i].split(" ",  QString::SkipEmptyParts);
        BLSURFPlugin::THyperPatchEntries& pe = hpel[ i ];
        pe.length( entries.size() );

        for ( int j = 0; j < entries.size(); ++j )
          pe[ j ] = CORBA::string_dup( entries[ j ].toStdString().c_str() );
      }
    }
    if ( h_data.hyperEntries.size() == h_data.hyperpatches.size() )
      h->SetHyperPatchEntries( hpel );
    else
      h->SetHyperPatches( hpl );


    // Enforced meshes
    BLSURFPlugin::EnforcedMeshesList_var enfMeshesList = new BLSURFPlugin::EnforcedMeshesList();
    enfMeshesList->length( myEnfMeshTableWdg->rowCount() );

    int nbMeshes = 0;
    for ( int row = 0, nbRow = myEnfMeshTableWdg->rowCount(); row < nbRow; ++row )
    {
      QTableWidgetItem *  meshCell = myEnfMeshTableWdg->item( row, 0 );
      QString                entry = meshCell->data( Qt::UserRole ).toString();
      QTableWidgetItem * groupCell = myEnfMeshTableWdg->item( row, 1 );
      QString            groupName = groupCell->text();

      SMESH::SMESH_IDSource_var mesh = SMESH::EntryToInterface< SMESH::SMESH_IDSource >( entry );
      if ( !mesh->_is_nil() )
      {
        enfMeshesList[ nbMeshes ].mesh = SMESH::SMESH_IDSource::_duplicate( mesh );
        enfMeshesList[ nbMeshes ].groupName = CORBA::string_dup( groupName.toStdString().c_str() );
        ++nbMeshes;
      }
    }
    enfMeshesList->length( nbMeshes );

    h->SetEnforcedMeshes( enfMeshesList );


  } // try
  catch(...) {
    ok = false;
  }

  return ok;
}

/** BLSURFPluginGUI_HypothesisCreator::readParamsFromWidgets(h_data)
    Stores the widgets content to the hypothesis data.
*/
QString BLSURFPluginGUI_HypothesisCreator::readParamsFromWidgets( BlsurfHypothesisData& h_data ) const
{
  h_data.myName                  = myName ? myName->text() : "";
  h_data.myPhysicalMesh          = myStdWidget->myPhysicalMesh->currentIndex();
  h_data.myGeometricMesh         = myStdWidget->myGeometricMesh->currentIndex();
  h_data.myPhySize               = myStdWidget->myPhySize->text().isEmpty() ? -1.0 : myStdWidget->myPhySize->GetValue();
  h_data.myPhySizeRel            = myStdWidget->myPhySizeRel->isChecked();
  h_data.myMinSize               = myStdWidget->myMinSize->text().isEmpty() ? -1.0 : myStdWidget->myMinSize->GetValue();
  h_data.myMinSizeRel            = myStdWidget->myMinSizeRel->isChecked();
  h_data.myMaxSize               = myStdWidget->myMaxSize->text().isEmpty() ? -1.0 : myStdWidget->myMaxSize->GetValue();
  h_data.myMaxSizeRel            = myStdWidget->myMaxSizeRel->isChecked();
  h_data.myUseGradation          = myStdWidget->myUseGradation->isChecked() && !myStdWidget->myGradation->text().isEmpty();
  h_data.myGradation             = h_data.myUseGradation ? myStdWidget->myGradation->GetValue() : -1.0;
  h_data.myUseVolumeGradation    = myStdWidget->myUseVolumeGradation->isChecked() && !myStdWidget->myVolumeGradation->text().isEmpty();
  h_data.myVolumeGradation       = h_data.myUseVolumeGradation ? myStdWidget->myVolumeGradation->GetValue() : -1. ;
  h_data.myElementType           = myStdWidget->myButtonGroupElementType->checkedId();
  h_data.myAngleMesh             = myStdWidget->myAngleMesh->text().isEmpty() ? -1.0 : myStdWidget->myAngleMesh->GetValue();
  h_data.myChordalError          = myStdWidget->myChordalError->text().isEmpty() ? -1.0 : myStdWidget->myChordalError->GetValue();
  h_data.myAnisotropic           = myStdWidget->myAnisotropic->isChecked();
  h_data.myAnisotropicRatio      = myStdWidget->myAnisotropicRatio->text().isEmpty() ? -1.0 : myStdWidget->myAnisotropicRatio->GetValue();
  h_data.myRemoveTinyEdges       = myStdWidget->myRemoveTinyEdges->isChecked();
  h_data.myTinyEdgeLength        = myStdWidget->myTinyEdgeLength->text().isEmpty() ? -1.0 : myStdWidget->myTinyEdgeLength->GetValue();
  h_data.myOptimiseTinyEdges     = myStdWidget->myOptimiseTinyEdges->isChecked();
  h_data.myTinyEdgeOptimisLength = myStdWidget->myTinyEdgeOptimisLength->text().isEmpty() ? -1.0 : myStdWidget->myTinyEdgeOptimisLength->GetValue();
  h_data.myCorrectSurfaceIntersection = myStdWidget->myCorrectSurfaceIntersection->isChecked();
  h_data.myCorrectSurfaceIntersectionMaxCost = myStdWidget->myCorrectSurfaceIntersectionMaxCost->text().isEmpty() ? -1.0 : myStdWidget->myCorrectSurfaceIntersectionMaxCost->GetValue();
  h_data.myForceBadElementRemoval= myStdWidget->myForceBadElementRemoval->isChecked();
  h_data.myBadElementAspectRatio = myStdWidget->myBadElementAspectRatio->text().isEmpty() ? -1.0 : myStdWidget->myBadElementAspectRatio->GetValue();
  h_data.myOptimizeMesh          = myStdWidget->myOptimizeMesh->isChecked();
  h_data.myQuadraticMesh         = myStdWidget->myQuadraticMesh->isChecked();
  h_data.myVerbosity             = myAdvWidget->myVerbosity->value();
  //h_data.myTopology              = myAdvWidget->myPreCADGroupBox->isChecked() ? PreCAD : FromCAD;
  //h_data.myPreCADMergeEdges      = myAdvWidget->myPreCADMergeEdges->isChecked();
  //h_data.myPreCADProcess3DTopology = myAdvWidget->myPreCADProcess3DTopology->isChecked();
  //h_data.myPreCADDiscardInput    = myAdvWidget->myPreCADDiscardInput->isChecked();
  h_data.myUseSurfaceProximity      = myStdWidget->myUseSurfaceProximity     ->isChecked();
  h_data.myNbSurfaceProximityLayers = myStdWidget->myNbSurfaceProximityLayers->value();
  h_data.mySurfaceProximityRatio    = myStdWidget->mySurfaceProximityRatio   ->value();
  h_data.myUseVolumeProximity       = myStdWidget->myUseVolumeProximity      ->isChecked();
  h_data.myNbVolumeProximityLayers  = myStdWidget->myNbVolumeProximityLayers ->value();
  h_data.myVolumeProximityRatio     = myStdWidget->myVolumeProximityRatio    ->value();

  QString guiHyp;
  guiHyp += tr("BLSURF_PHY_MESH") + " = " + QString::number( h_data.myPhysicalMesh ) + "; ";
  guiHyp += tr("BLSURF_GEOM_MESH") + " = " + QString::number( h_data.myGeometricMesh ) + "; ";
  guiHyp += tr("BLSURF_HPHYDEF") + " = " + QString::number( h_data.myPhySize ) + "; ";
  guiHyp += tr("BLSURF_HPHYDEF") + " " + tr("BLSURF_SIZE_REL") +" = " + QString(h_data.myPhySizeRel ? "yes" : "no") + "; ";
  guiHyp += tr("BLSURF_MINSIZE") + " = "+ QString::number( h_data.myMinSize ) + "; ";
  guiHyp += tr("BLSURF_MINSIZE") + " " + tr("BLSURF_SIZE_REL") + " = " + QString(h_data.myMinSizeRel ? "yes" : "no") + "; ";
  guiHyp += tr("BLSURF_MAXSIZE") + " = "+ QString::number( h_data.myMaxSize ) + "; ";
  guiHyp += tr("BLSURF_MAXSIZE") + " " + tr("BLSURF_SIZE_REL") + " = " + QString(h_data.myMaxSizeRel ? "yes" : "no") + "; ";
  guiHyp += tr("BLSURF_GRADATION") + " = " + QString::number( h_data.myGradation ) + "; ";
  guiHyp += tr("BLSURF_ELEMENT_TYPE") + " = " + QString::number(h_data.myElementType) + "; ";
  guiHyp += tr("BLSURF_ANGLE_MESH") + " = " + QString::number( h_data.myAngleMesh ) + "; ";
  guiHyp += tr("BLSURF_CHORDAL_ERROR") + " = " + QString::number( h_data.myChordalError ) + "; ";
  guiHyp += tr("BLSURF_ANISOTROPIC") + " = " + QString(h_data.myAnisotropic ? "yes" : "no") + "; ";
  guiHyp += tr("BLSURF_ANISOTROPIC_RATIO") + " = " + QString::number( h_data.myAnisotropicRatio ) + "; ";
  
  
  guiHyp += tr("BLSURF_REMOVE_TINY_EDGES") + " = " + QString(h_data.myRemoveTinyEdges ? "yes" : "no") + "; ";
  guiHyp += tr("BLSURF_TINY_EDGES_LENGTH") + " = " + QString::number( h_data.myTinyEdgeLength ) + "; ";
  guiHyp += tr("BLSURF_REMOVE_SLIVERS") + " = " + QString(h_data.myForceBadElementRemoval ? "yes" : "no") + "; ";
  guiHyp += tr("BLSURF_BAD_SURFACE_ELEMENT_ASPECT_RATIO") + " = " + QString::number( h_data.myBadElementAspectRatio ) + "; ";
  guiHyp += tr("BLSURF_OPTIMISATION") + " = " + QString(h_data.myOptimizeMesh ? "yes" : "no") + "; ";
  guiHyp += tr("BLSURF_ELEMENT_ORDER") + " = " + QString(h_data.myQuadraticMesh ? "yes" : "no") + "; ";
  
  
  // guiHyp += tr("BLSURF_TOPOLOGY") + " = " + QString::number( h_data.myTopology ) + "; ";
  // guiHyp += tr("BLSURF_PRECAD_MERGE_EDGES") + " = " + QString(h_data.myPreCADMergeEdges ? "yes" : "no") + "; ";
  // guiHyp += tr("BLSURF_PRECAD_REMOVE_NANO_EDGES") + " = " + QString(h_data.myPreCADProcess3DTopology ? "yes" : "no") + "; ";
  // guiHyp += tr("BLSURF_PRECAD_DISCARD_INPUT") + " = " + QString(h_data.myPreCADDiscardInput ? "yes" : "no") + "; ";
 
  h_data.myGMFFileName = myAdvWidget->myGMFFileName->text().toStdString();
//   h_data.myGMFFileMode = myGMFFileMode->isChecked();

  // SizeMap
  BLSURFPluginGUI_HypothesisCreator* that = (BLSURFPluginGUI_HypothesisCreator*)this;
  int row = 0, nbRows = mySizeMapTable->topLevelItemCount();
  for ( ; row < nbRows; ++row )
  {
    QString entry   = mySizeMapTable->topLevelItem(row)->data(SMP_ENTRY_COLUMN ,Qt::EditRole).toString();
    if ( that->mySMPMap.contains(entry) )
      guiHyp += "SetSizeMapEntry(" + entry + ", " + that->mySMPMap[entry] + "); ";
  }

  // Enforced vertices
  h_data.enfVertexList.clear();
  h_data.faceEntryEnfVertexListMap.clear();

  int nbEnforcedShapes = myEnforcedTreeWidget->topLevelItemCount();
  std::string groupName = "", faceEntry = "";
  for (int i=0 ; i<nbEnforcedShapes ; i++)
  {
    double childValueX,childValueY,childValueZ;
    std::string childName, vertexEntry;
    QTreeWidgetItem* child;

    child = myEnforcedTreeWidget->topLevelItem(i);
    childName   = child->data(ENF_VER_NAME_COLUMN,Qt::EditRole).toString().toStdString();
    childValueX = child->data(ENF_VER_X_COLUMN,Qt::EditRole).toDouble();
    childValueY = child->data(ENF_VER_Y_COLUMN,Qt::EditRole).toDouble();
    childValueZ = child->data(ENF_VER_Z_COLUMN,Qt::EditRole).toDouble();
    vertexEntry = child->data(ENF_VER_ENTRY_COLUMN,Qt::EditRole).toString().toStdString();
    //           if (myGlobalGroupName->isChecked())
    //             groupName = myGlobalGroupName->text().toStdString();
    //           else
    groupName = child->data(ENF_VER_GROUP_COLUMN,Qt::EditRole).toString().toStdString();

    TEnfVertex *enfVertex = new TEnfVertex();
    enfVertex->name = childName;
    if (vertexEntry.empty()) {
      enfVertex->coords.push_back(childValueX);
      enfVertex->coords.push_back(childValueY);
      enfVertex->coords.push_back(childValueZ);
    }
    else
      enfVertex->geomEntry = vertexEntry;
    enfVertex->grpName = groupName;
    //           TEnfVertexList::iterator it = h_data.enfVertexList.find(enfVertex);
    //           if (it == h_data.enfVertexList.end())
    h_data.enfVertexList.insert(enfVertex);
    /* TODO GROUPS
       if (groupName != "")
       h_data.groupNameEnfVertexListMap[groupName].insert(vertex);
    */
    h_data.faceEntryEnfVertexListMap[faceEntry].insert( enfVertex );
  }

  h_data.myInternalEnforcedVerticesAllFaces      = myInternalEnforcedVerticesAllFaces->isChecked();
  h_data.myInternalEnforcedVerticesAllFacesGroup = myInternalEnforcedVerticesAllFacesGroup->text().toStdString();

  // Periodicity
  h_data.preCadPeriodicityVector.clear();
  // For each tree item, store each value. Shapes are stored as entries.
  int nbPeriodicityDescriptions = myPeriodicityTreeWidget->topLevelItemCount();
  for (int i=0 ; i<nbPeriodicityDescriptions ; i++) {
    QTreeWidgetItem* item = myPeriodicityTreeWidget->topLevelItem(i);
    TPreCadPeriodicity periodicity_i;
    if (item) {
        for (int k=0; k<myPeriodicityTreeWidget->columnCount(); ++k)
          {
            std::string entry = item->data(k, Qt::UserRole).toString().toStdString();
            periodicity_i.push_back(entry);
          }
        h_data.preCadPeriodicityVector.push_back(periodicity_i);
    }
    guiHyp += "PERIODICITY = yes; ";
  }

  // Hyper-patches
  h_data.hyperpatches.clear();
  h_data.hyperEntries.clear();
  for ( int row = 0; row < myHyPatchTable->rowCount(); ++row )
  {
    QTableWidgetItem* cell = myHyPatchTable->item( row, 0 );
    h_data.hyperpatches.append( cell->text() );
    if ( cell->data( Qt::UserRole ).isValid() )
      h_data.hyperEntries.append( cell->data( Qt::UserRole ).toString() );
  }
  if ( h_data.hyperpatches.size() != h_data.hyperEntries.size() )
    h_data.hyperEntries.clear();

  return guiHyp;
}

void BLSURFPluginGUI_HypothesisCreator::onAddOption()
{
  myAdvWidget->AddOption( TBL_CUSTOM, NULL );
}

void BLSURFPluginGUI_HypothesisCreator::onChangeOptionName( int /*row*/, int /*column*/ )
{
  // if ( column != OPTION_NAME_COLUMN )
  //   return;
  // myAdvWidget->myOptionTable->resizeColumnToContents( OPTION_NAME_COLUMN );
}

// **********************
// *** BEGIN SIZE MAP ***
// **********************

void BLSURFPluginGUI_HypothesisCreator::onMapGeomContentModified()
{
  if ( myGeomSelWdg2->IsObjectSelected() ){
    mySMapObject = myGeomSelWdg2->GetObject< GEOM::GEOM_Object >(0);
  }
  else if ( myGeomSelWdg1->IsObjectSelected() ){
    mySMapObject = myGeomSelWdg1->GetObject< GEOM::GEOM_Object >(0);
  }
  else {
    mySMapObject = GEOM::GEOM_Object::_nil();
  }
  bool dataAvailable = !mySMapObject->_is_nil();
  QString qEntry;
  if ( dataAvailable )
    qEntry = SMESH::toQStr( mySMapObject->GetStudyEntry() );

  bool mapExists = ( mySMPMap.contains(qEntry) && mySMPMap[qEntry] != "__TO_DELETE__" );
  if (( mapExists && myGeomSelWdg2->IsObjectSelected() )  &&
      ( dataAvailable = myAttSelWdg->isEnabled() )        &&
      ( dataAvailable = myAttSelWdg->IsObjectSelected() ) &&
      ( myATTMap.contains( qEntry )))
  {
    mapExists = false;
    QString attEntry = myAttSelWdg->GetValue();
    const TAttractorVec& attVec = myATTMap[ qEntry ];
    for ( size_t i = 0; i < attVec.size() && !mapExists; ++i )
      mapExists = ( attEntry == attVec[i].attEntry.c_str() );
  }

  addMapButton->setEnabled( !mapExists && dataAvailable );
  modifyMapButton->setEnabled( mapExists && dataAvailable );
}

void BLSURFPluginGUI_HypothesisCreator::onSmpItemClicked(QTreeWidgetItem * item, int col)
{
  BLSURFPluginGUI_HypothesisCreator* that = (BLSURFPluginGUI_HypothesisCreator*)this;
  if (col == SMP_SIZEMAP_COLUMN) {
    QString entry   = item->data( SMP_ENTRY_COLUMN, Qt::EditRole ).toString();
    QString childEntry;
    if (!mySMPMap.contains(entry))
    {
      if ( QTreeWidgetItem* parent = item->parent() )
      {
        childEntry = entry;
        item = parent;
        entry = item->data( SMP_ENTRY_COLUMN, Qt::EditRole ).toString();
      }
      if (!mySMPMap.contains(entry))
        return;
    }
    QString sizeMap = item->data( SMP_SIZEMAP_COLUMN, Qt::EditRole ).toString();
    CORBA::Object_var obj = entryToObject(entry);
    if (sizeMap.startsWith("Attractor") || sizeMap.startsWith("Constant")) {  // ADVANCED MAPS
      smpTab->setCurrentIndex(ATT_TAB);         // Change Tab
      // Retrieve values of the selected item in the current tab widgets
      const TAttractorVec& attVec = myATTMap[entry];
      if ( !attVec.empty() )
      {
        size_t iAtt = 0;
        if ( !childEntry.isEmpty() )
          for ( size_t i = 0; i < attVec.size(); ++i )
            if ( childEntry == attVec[i].attEntry.c_str() )
            {
              iAtt = i;
              break;
            }
        double phySize   = attVec[iAtt].startSize;
        double infDist   = attVec[iAtt].infDist;
        double constDist = attVec[iAtt].constDist;
        QString attEntry = attVec[iAtt].attEntry.c_str();
        CORBA::Object_var attObj = entryToObject(attEntry);
        myAttSizeSpin->setValue(phySize);
        if ( infDist > std::numeric_limits<double>::epsilon() /*sizeMap.startsWith("Attractor")*/){
          myAttDistSpin->setValue(infDist);
          myAttractorCheck->setChecked(true);
        }
        else {
          myAttractorCheck->setChecked(false);
        }
        if (/*sizeMap.startsWith("Constant") || */constDist > std::numeric_limits<double>::epsilon()){
          myAttDistSpin2->setValue(constDist);
          myConstSizeCheck->setChecked(true);
        }
        else{
          myConstSizeCheck->setChecked(false);
        }
        myGeomSelWdg2->SetObject(obj);
        myAttSelWdg->SetObject(attObj);
      }
    }
    else {                                                                   // CLASSIC MAPS
      smpTab->setCurrentIndex(SMP_STD_TAB);  // Change Tab
      myGeomSelWdg1->SetObject(obj);         // Retrieve values of the selected item in the current tab widgets
      if (!sizeMap.startsWith("def")){
        mySmpSizeSpin->setValue(that->mySMPMap[entry].toDouble());
      }
    }
  }
}

void BLSURFPluginGUI_HypothesisCreator::onTabChanged(int tab)
{
  getGeomSelectionTool()->selectionMgr()->clearFilters();
  if ( sender() == myTabWidget )
  {
    myGeomSelWdg1             ->deactivateSelection();
    myGeomSelWdg2             ->deactivateSelection();
    myAttSelWdg               ->deactivateSelection();
    myEnfVertexWdg            ->deactivateSelection();
    myPeriodicitySourceFaceWdg->deactivateSelection();
    myPeriodicityTargetFaceWdg->deactivateSelection();
    myPeriodicityP1SourceWdg  ->deactivateSelection();
    myPeriodicityP2SourceWdg  ->deactivateSelection();
    myPeriodicityP3SourceWdg  ->deactivateSelection();
    myPeriodicityP1TargetWdg  ->deactivateSelection();
    myPeriodicityP2TargetWdg  ->deactivateSelection();
    myPeriodicityP3TargetWdg  ->deactivateSelection();
    myEnfMeshWdg              ->deactivateSelection();
    if ( myHyPatchFaceSelBtn->isChecked() )
      myHyPatchFaceSelBtn->toggle();
    if ( myHyPatchGroupSelBtn->isChecked() )
      myHyPatchGroupSelBtn->toggle();
  }
  else if ( sender() == smpTab )
  {
    myAttDistSpin->setValue(0.);           // Reinitialize widgets
    myAttSizeSpin->setValue(0.);
    myAttDistSpin2->setValue(0.);
    mySmpSizeSpin->setValue(0.);
    myGeomSelWdg1->deactivateSelection();
    myGeomSelWdg2->deactivateSelection();
    myAttSelWdg->deactivateSelection();
    myGeomSelWdg1->SetObject(CORBA::Object::_nil());
    myGeomSelWdg2->SetObject(CORBA::Object::_nil());
    myAttSelWdg->SetObject(CORBA::Object::_nil());
    myAttractorCheck->setChecked(false);
    myConstSizeCheck->setChecked(false);
  }

  if ( tab == SMP_TAB ) // [#16954] limit local size by Min and User Size
  {
    double minSize = 0, maxSize = COORD_MAX;

    if ( !myStdWidget->myMinSizeRel->isChecked() &&
         !myStdWidget->myMinSize->text().isEmpty() )
      minSize = myStdWidget->myMinSize->GetValue();

    if ( !myStdWidget->myPhySizeRel->isChecked() &&
         !myStdWidget->myPhySize->text().isEmpty() )
      maxSize = myStdWidget->myPhySize->GetValue();

    mySmpSizeSpin->RangeStepAndValidator(minSize, maxSize, 1.0, "length_precision");
    myAttSizeSpin->RangeStepAndValidator(minSize, maxSize, 1.0, "length_precision");
  }

  if ( tab == ENF_M_TAB )
  {
    myEnfMeshWdg->activateSelection();
    onEnforcedMeshSelected(); // update buttons
    onEnfMeshTableSelected();
    if ( myEnforcedGroupName->text().isEmpty() )
      myEnforcedGroupName->setText("Group 1D");
  }
}

void BLSURFPluginGUI_HypothesisCreator::onAttractorClicked(int state)
{
  if (state == Qt::Checked){
    myAttSelWdg->setEnabled(true);
    myAttSizeSpin->setEnabled(true);
    myAttSizeLabel->setEnabled(true);
    myAttDistSpin->setEnabled(true);
    myAttDistLabel->setEnabled(true);
    if (!myAttSelWdg->IsObjectSelected()){
      myAttSelWdg->SetDefaultText(tr("BLS_SEL_ATTRACTOR"), "QLineEdit { color: grey }");
    }
  }
  if (state == Qt::Unchecked){
    myAttDistSpin->setEnabled(false);
    myAttDistLabel->setEnabled(false);
    myAttDistSpin->setValue(0.);
    if(myConstSizeCheck->checkState() == Qt::Unchecked){  // No predefined map selected
      myAttSelWdg->setEnabled(false);
      myAttSizeSpin->setEnabled(false);
      myAttSizeLabel->setEnabled(false);
      myAttDistSpin2->setEnabled(false);
      myAttDistLabel2->setEnabled(false);
    }
    else if (!myAttSelWdg->IsObjectSelected()){           // Only constant size selected
      myAttSelWdg->SetDefaultText(tr("BLS_SEL_SHAPE"), "QLineEdit { color: grey }");
    }
  }
  onMapGeomContentModified();
}

void BLSURFPluginGUI_HypothesisCreator::onConstSizeClicked(int state)
{ 
  if (state == Qt::Checked){
    myAttSelWdg->setEnabled(true);
    myAttSizeSpin->setEnabled(true);
    myAttSizeLabel->setEnabled(true);
    myAttDistSpin2->setEnabled(true);
    myAttDistLabel2->setEnabled(true);
    if (myAttractorCheck->checkState() == Qt::Unchecked &&
        !myAttSelWdg->IsObjectSelected()){
      myAttSelWdg->SetDefaultText(tr("BLS_SEL_SHAPE"), "QLineEdit { color: grey }");
    }
  }
  if (state == Qt::Unchecked){
    myAttDistSpin2->setEnabled(false);
    myAttDistLabel2->setEnabled(false);
    myAttDistSpin2->setValue(0.);
    if(myAttractorCheck->checkState() == Qt::Unchecked){  // No predefined map selected
        myAttSelWdg->setEnabled(false);
        myAttSizeSpin->setEnabled(false);
        myAttSizeLabel->setEnabled(false);
        myAttDistSpin->setEnabled(false);
        myAttDistLabel->setEnabled(false);
    }
    else if (!myAttSelWdg->IsObjectSelected()){           // Only constant size selected
    myAttSelWdg->SetDefaultText(tr("BLS_SEL_ATTRACTOR"), "QLineEdit { color: grey }");
    }
  }   
  onMapGeomContentModified();
}

void BLSURFPluginGUI_HypothesisCreator::onRemoveMap()
{
  QList<int> selectedRows;
  QList<QTreeWidgetItem*> selected = mySizeMapTable->selectedItems();
  QTreeWidgetItem* item;
  BLSURFPluginGUI_HypothesisCreator* that = (BLSURFPluginGUI_HypothesisCreator*)this;

  qSort( selectedRows );
  QListIterator<QTreeWidgetItem*> it( selected );
  it.toBack();
  while ( it.hasPrevious() ) {
      item = it.previous();
      QString entry = item->data(SMP_ENTRY_COLUMN, Qt::EditRole).toString();
      QString parentEntry;
      if ( QTreeWidgetItem* parent = item->parent() )
        parentEntry = parent->data(SMP_ENTRY_COLUMN, Qt::EditRole).toString();
      if (that->mySMPMap.contains(entry))
      {
        that->mySMPMap[entry] = "__TO_DELETE__";
        if ( myATTMap.contains( entry ))
        {
          TAttractorVec& attVec = myATTMap[entry];
          for ( size_t i = 0; i < attVec.size(); ++i )
            attVec[i].SetToDelete();
        }          
      }
      else if ( mySMPMap.contains( parentEntry ) && myATTMap.contains( parentEntry ))
      {
        TAttractorVec& attVec = myATTMap[parentEntry];
        for ( size_t i = 0; i < attVec.size(); ++i )
        {
          if ( entry == attVec[i].attEntry.c_str() )
            attVec[i].SetToDelete();
        }
      }
      if (that->mySMPShapeTypeMap.contains(entry))
        that->mySMPShapeTypeMap.remove(entry);
      // if (that->myDistMap.contains(entry))
      //   that->myDistMap.remove(entry);
      // if (that->myAttDistMap.contains(entry))
      //   that->myAttDistMap.remove(entry);
      delete item;
  }
  mySizeMapTable->resizeColumnToContents(SMP_NAME_COLUMN);
  mySizeMapTable->resizeColumnToContents(SMP_SIZEMAP_COLUMN);
}

void BLSURFPluginGUI_HypothesisCreator::onSetSizeMap(QTreeWidgetItem* item, int col)
{
  if (col == SMP_SIZEMAP_COLUMN) {
    BLSURFPluginGUI_HypothesisCreator* that = (BLSURFPluginGUI_HypothesisCreator*)this;
    QString entry   = item->data(SMP_ENTRY_COLUMN, Qt::EditRole).toString();
    QString sizeMap = item->data(SMP_SIZEMAP_COLUMN, Qt::EditRole).toString();
    if (! that->mySMPShapeTypeMap.contains(entry))
      return;
    if (that->mySMPMap.contains(entry))
      if (that->mySMPMap[entry] == sizeMap 
        || sizeMap.startsWith("Attractor") 
        || sizeMap.startsWith("Constant") ){
        return;
      } 
    if (! sizeMap.isEmpty()) {
      that->mySMPMap[entry] = sizeMap;
      sizeMapValidationFromEntry(entry); 
    }
    else {
      item->setData(SMP_SIZEMAP_COLUMN, Qt::EditRole, QVariant(that->mySMPMap[entry]) );
    }
    mySizeMapTable->resizeColumnToContents(SMP_SIZEMAP_COLUMN);
  }
}

void BLSURFPluginGUI_HypothesisCreator::onAddMap()
{
  bool res = false;
  if ( smpTab->currentIndex() == ATT_TAB ){
    if ( myGeomSelWdg2->IsObjectSelected() && myAttSelWdg->IsObjectSelected() ){
      mySMapObject = myGeomSelWdg2->GetObject< GEOM::GEOM_Object >(0);
      myAttObject = myAttSelWdg->GetObject< GEOM::GEOM_Object >(0);
      res = insertAttractor(mySMapObject, myAttObject);
    }
  }
  if (smpTab->currentIndex() == SMP_STD_TAB  ){
    if ( myGeomSelWdg1->IsObjectSelected() ){
      mySMapObject = myGeomSelWdg1->GetObject< GEOM::GEOM_Object >(0);
      res = insertElement(mySMapObject);
    }
  }
  if ( !res ) {
    // Local size should be more than 0
    QString msg = tr("ZERO_VALUE_OF").arg( tr("BLSURF_SM_SIZE"));
    SUIT_MessageBox::critical( dlg(),"Error" , msg );
    return;
  }
  getGeomSelectionTool()->selectionMgr()->clearFilters();
  myAttDistSpin->setValue(0.);
  myAttSizeSpin->setValue(0.);
  myAttDistSpin2->setValue(0.);
  mySmpSizeSpin->setValue(0.);
  myConstSizeCheck->setChecked(false);
  myAttractorCheck->setChecked(false);
  myGeomSelWdg1->deactivateSelection();
  myGeomSelWdg2->deactivateSelection();
  myAttSelWdg->deactivateSelection();
  myGeomSelWdg1->SetObject(CORBA::Object::_nil());
  myGeomSelWdg2->SetObject(CORBA::Object::_nil());
  myAttSelWdg->SetObject(CORBA::Object::_nil());
}

void BLSURFPluginGUI_HypothesisCreator::onModifyMap()
{
  bool res = false;
  if ( smpTab->currentIndex() == ATT_TAB ){    
    if ( myGeomSelWdg2->IsObjectSelected() && myAttSelWdg->IsObjectSelected() ){ 
      mySMapObject = myGeomSelWdg2->GetObject< GEOM::GEOM_Object >(0);
      myAttObject = myAttSelWdg->GetObject< GEOM::GEOM_Object >(0);
      res = insertAttractor(mySMapObject, myAttObject, /*modify = */true);
    }
  }
  if (smpTab->currentIndex() == SMP_STD_TAB  ){
    if ( myGeomSelWdg1->IsObjectSelected() ){
      mySMapObject = myGeomSelWdg1->GetObject< GEOM::GEOM_Object >(0);
      res = insertElement(mySMapObject, /*modify = */true);  
    }  
  }
  if ( !res ) {
    // Local size should be more than 0
    QString msg = tr("ZERO_VALUE_OF").arg( tr("BLSURF_SM_SIZE"));
    SUIT_MessageBox::critical( dlg(),"Error" , msg );
    return;
  }
  getGeomSelectionTool()->selectionMgr()->clearFilters();
  myAttDistSpin->setValue(0.);
  myAttSizeSpin->setValue(0.);
  myAttDistSpin2->setValue(0.);
  mySmpSizeSpin->setValue(0.);
  myConstSizeCheck->setChecked(false);
  myAttractorCheck->setChecked(false);
  myGeomSelWdg1->deactivateSelection();
  myGeomSelWdg2->deactivateSelection();
  myAttSelWdg->deactivateSelection();
  myGeomSelWdg1->SetObject(CORBA::Object::_nil());
  myGeomSelWdg2->SetObject(CORBA::Object::_nil());
  myAttSelWdg->SetObject(CORBA::Object::_nil());
}

bool BLSURFPluginGUI_HypothesisCreator::insertElement(GEOM::GEOM_Object_var anObject, bool modify)
{
  // BLSURFPlugin::BLSURFPlugin_Hypothesis_var h =
  //   BLSURFPlugin::BLSURFPlugin_Hypothesis::_narrow( initParamsHypothesis());

  BLSURFPluginGUI_HypothesisCreator* that = (BLSURFPluginGUI_HypothesisCreator*)this;

  TopAbs_ShapeEnum shapeType;
  string entry, shapeName;
  entry = (string) anObject->GetStudyEntry();
  shapeName = anObject->GetName();
  shapeType = SMESH_Gen_i::GetSMESHGen()->GeomObjectToShape( anObject ).ShapeType();
  // Group management : the type of entities in the group is stored in the SMPShapeTypeMap
  // in order to write the size map with the right syntax in StoreParamsToHypo 
  // (f(t) for edges, f(u,v) for faces ...)
  if (shapeType == TopAbs_COMPOUND){
    TopoDS_Shape theShape = SMESH_Gen_i::GetSMESHGen()->GeomObjectToShape( anObject );
    TopoDS_Shape childShape;
    TopoDS_Iterator anIt(theShape);
    for(;anIt.More();anIt.Next()){
      childShape = anIt.Value();
      shapeType = childShape.ShapeType();
      if(!childShape.IsNull()){
        break;
      }
    }
  }
  mySizeMapTable->setFocus();
  QString shapeEntry;
  shapeEntry = QString::fromStdString(entry);
  double phySize = mySmpSizeSpin->value();

  if ( phySize == 0 )
    return false; // Local size should be more than 0

  std::ostringstream oss;
  oss << phySize;
  QString sizeMap;
  sizeMap  = QString::fromStdString(oss.str());
  QTreeWidgetItem* item = new QTreeWidgetItem();
  if (modify){
    int rowToChange = findRowFromEntry(shapeEntry);
    item = mySizeMapTable->topLevelItem( rowToChange );
  }
  else{
    if (that->mySMPMap.contains(shapeEntry)) {  
      if (that->mySMPMap[shapeEntry] != "__TO_DELETE__") {
        return false;
      }
    }
    mySizeMapTable->addTopLevelItem(item);
  }
  that->mySMPMap[shapeEntry] = sizeMap;
  //that->myDistMap[shapeEntry] = 0. ;
  that->mySMPShapeTypeMap[shapeEntry] = shapeType;
  item->setFlags( Qt::ItemIsSelectable |Qt::ItemIsEditable   |Qt::ItemIsEnabled );
  item->setData(SMP_ENTRY_COLUMN, Qt::EditRole, QVariant(shapeEntry) );
  item->setData(SMP_NAME_COLUMN, Qt::EditRole, QVariant(QString::fromStdString(shapeName)) );
  item->setData(SMP_SIZEMAP_COLUMN, Qt::EditRole, QVariant(sizeMap) );
  mySizeMapTable->resizeColumnToContents( SMP_SIZEMAP_COLUMN );
  mySizeMapTable->resizeColumnToContents( SMP_NAME_COLUMN );
  mySizeMapTable->resizeColumnToContents( SMP_ENTRY_COLUMN );
  mySizeMapTable->clearSelection();

  if ( myStdWidget->myPhysicalMesh->currentIndex() != PhysicalLocalSize ) {
    myStdWidget->myPhysicalMesh->setCurrentIndex( PhysicalLocalSize );
    myStdWidget->onPhysicalMeshChanged();
  }
  return true;
}

bool BLSURFPluginGUI_HypothesisCreator::insertAttractor(GEOM::GEOM_Object_var aFace, GEOM::GEOM_Object_var anAttractor, bool modify)
{
  BLSURFPlugin::BLSURFPlugin_Hypothesis_var h =
    BLSURFPlugin::BLSURFPlugin_Hypothesis::_narrow( initParamsHypothesis());

  TopAbs_ShapeEnum shapeType;
  string entry, attEntry, faceName, attName;
  entry = (string) aFace->GetStudyEntry();
  attEntry = (string) anAttractor->GetStudyEntry();
  faceName = aFace->GetName();
  attName = anAttractor->GetName();
  shapeType = SMESH_Gen_i::GetSMESHGen()->GeomObjectToShape( aFace ).ShapeType();
  mySizeMapTable->setFocus();
  QString shapeEntry = QString::fromStdString(entry);
  QString qAttEntry = QString::fromStdString(attEntry);
  
  double phySize = h->GetPhySize();
  double infDist = 0. ;
  double constDist = 0. ;
  phySize = myAttSizeSpin->value();

  if ( phySize == 0 )
    return false; // Local size should be more than 0

  if (myAttractorCheck->isChecked()){
    infDist = myAttDistSpin->value();
  }
  if (myConstSizeCheck->isChecked()){
    constDist = myAttDistSpin2->value();
  } 
  std::ostringstream oss;
  std::ostringstream oss2;
  std::ostringstream oss3;
  oss << phySize;
  oss2 << infDist;
  oss3 << constDist;
  QString sizeMap  = QString::fromStdString(oss.str());
  QString infDistString = QString::fromStdString(oss2.str());
  QString constDistString = QString::fromStdString(oss3.str());
  
  QTreeWidgetItem* item; 
  QTreeWidgetItem* child = 0;
  TAttractor attParams( attEntry.c_str(), phySize, infDist, constDist );
  if (modify) {
    int rowToChange = findRowFromEntry(shapeEntry);
    item = mySizeMapTable->topLevelItem( rowToChange );
    
    for ( int i = 0, nb = item->childCount(); i < nb; ++i )
      if (( child = item->child( i )))
        if ( qAttEntry == child->data( SMP_ENTRY_COLUMN, Qt::EditRole ).toString() )
          break;
    TAttractorVec & attVec = myATTMap[shapeEntry];
    for ( size_t i = 0; i < attVec.size(); ++i )
      if ( attVec[i].attEntry == attEntry )
      {
        attVec[i] = attParams;
        break;
      }
  }
  else{
    // if (that->mySMPMap.contains(shapeEntry)) {  
    //   if (that->mySMPMap[shapeEntry] != "__TO_DELETE__") {
    //     return false;
    //   }
    // }
    int rowToChange = findRowFromEntry(shapeEntry);
    if ( rowToChange < mySizeMapTable->topLevelItemCount() )
    {
      item = mySizeMapTable->topLevelItem( rowToChange );
    }
    else {
      item = new QTreeWidgetItem();
      mySizeMapTable->addTopLevelItem(item);
    }
    child = new QTreeWidgetItem();
    item->addChild(child);
    bool exists = false;
    TAttractorVec & attVec = myATTMap[shapeEntry];
    for ( size_t i = 0; i < attVec.size(); ++i )
      if ( attVec[i].attEntry == attEntry )
      {
        attVec[i] = attParams;
        exists = true;
        break;
      }
    if ( !exists )
      myATTMap[shapeEntry].push_back( attParams );
  }
  mySMPMap.insert(shapeEntry,sizeMap);
  mySMPShapeTypeMap.insert(shapeEntry,shapeType);
  item->setExpanded(true); 
  item->setData(SMP_ENTRY_COLUMN, Qt::EditRole, QVariant(shapeEntry) );
  item->setData(SMP_NAME_COLUMN, Qt::EditRole, QVariant(QString::fromStdString(faceName)) );
  if (infDist > std::numeric_limits<double>::epsilon()){
    item->setData(SMP_SIZEMAP_COLUMN, Qt::EditRole, QVariant(QString::fromStdString("Attractor")) );
  }
  else if (constDist > std::numeric_limits<double>::epsilon()){
    item->setData(SMP_SIZEMAP_COLUMN, Qt::EditRole, QVariant(QString::fromStdString("Constant Size")) );
  }
  item->setFlags( Qt::ItemIsSelectable |Qt::ItemIsEditable   |Qt::ItemIsEnabled );    
  
  child->setData(SMP_ENTRY_COLUMN, Qt::EditRole, QVariant(qAttEntry) );
  child->setData(SMP_NAME_COLUMN, Qt::EditRole, QVariant(QString::fromStdString(attName)) );
  child->setData(SMP_SIZEMAP_COLUMN, Qt::EditRole, QVariant(sizeMap) );
  
  mySizeMapTable->resizeColumnToContents( SMP_ENTRY_COLUMN );
  mySizeMapTable->resizeColumnToContents( SMP_NAME_COLUMN );
  mySizeMapTable->resizeColumnToContents( SMP_SIZEMAP_COLUMN );

  if ( myStdWidget->myPhysicalMesh->currentIndex() != PhysicalLocalSize ) {
    myStdWidget->myPhysicalMesh->setCurrentIndex( PhysicalLocalSize );
    myStdWidget->onPhysicalMeshChanged();
  }
  return true;
}

bool BLSURFPluginGUI_HypothesisCreator::sizeMapsValidation()
{
  int row = 0, nbRows = mySizeMapTable->topLevelItemCount();
  for ( ; row < nbRows; ++row )
    if (! sizeMapValidationFromRow(row))
      return false;
  return true;
}

bool BLSURFPluginGUI_HypothesisCreator::sizeMapValidationFromRow(int myRow, bool displayError)
{
  QString myEntry   = mySizeMapTable->topLevelItem( myRow )->data( SMP_ENTRY_COLUMN, Qt::EditRole ).toString();
  bool res = sizeMapValidationFromEntry(myEntry,displayError);
  mySizeMapTable->setFocus();
  return res;
}

bool BLSURFPluginGUI_HypothesisCreator::sizeMapValidationFromEntry(QString myEntry, bool displayError)
{

  BLSURFPluginGUI_HypothesisCreator* that = (BLSURFPluginGUI_HypothesisCreator*)this;

  if (! that->mySMPMap.contains(myEntry)) {
    return false;
  }
  if (! that->mySMPShapeTypeMap.contains(myEntry)) {
    return false;
  }

  string expr;

  if (that->mySMPMap[myEntry].startsWith("def")) {
    expr = that->mySMPMap[myEntry].toStdString();
  }
  else if (that->mySMPMap[myEntry].startsWith("ATTRACTOR")) {
    if ((that->mySMPMap[myEntry].count(QRegExp("^ATTRACTOR\\((?:(-?0(\\.\\d*)*|-?[1-9]+\\d*(\\.\\d*)*|-?\\.(\\d)+);){5}(True|False)(?:;(-?0(\\.\\d*)*|-?[1-9]+\\d*(\\.\\d*)*|-?\\.(\\d)+))?\\)$")) != 1)) {

      if (displayError)
        SUIT_MessageBox::warning( dlg(),"Definition of attractor : Error" ,"An attractor is defined with the following pattern: ATTRACTOR(xa;ya;za;a;b;True|False[;d])" );
      return false;
    }
    return true;
  }
  else {
    // case size map is empty
    if (that->mySMPMap[myEntry].isEmpty()) {
      if (displayError)
        SUIT_MessageBox::warning( dlg(),"Definition of size map : Error" , "Size map can't be empty");
      return false;
    }
    else {
      if ( that->mySMPShapeTypeMap[myEntry] == TopAbs_FACE)
        expr = "def f(u,v) : return " + that->mySMPMap[myEntry].toStdString();
      else if ( that->mySMPShapeTypeMap[myEntry] == TopAbs_EDGE)
        expr = "def f(t) : return " + that->mySMPMap[myEntry].toStdString();
      else if ( that->mySMPShapeTypeMap[myEntry] == TopAbs_VERTEX)
        expr = "def f() : return " + that->mySMPMap[myEntry].toStdString();
    }
  }
  //assert(Py_IsInitialized());
  if (! Py_IsInitialized())
    throw ("Erreur: Python interpreter is not initialized");
  PyGILState_STATE gstate;
  gstate = PyGILState_Ensure();

  string  err_description="";
  PyObject* obj= PyRun_String(expr.c_str(), Py_file_input, main_dict, NULL);
  if (obj == NULL){
    fflush(stderr);
    err_description="";
    PyObject* new_stderr = newPyStdOut(err_description);
    PyObject* old_stderr = PySys_GetObject((char*)"stderr");
    Py_INCREF(old_stderr);
    PySys_SetObject((char*)"stderr", new_stderr);
    PyErr_Print();
    PySys_SetObject((char*)"stderr", old_stderr);
    Py_DECREF(new_stderr);
    if (displayError)
      SUIT_MessageBox::warning( dlg(),"Definition of Python Function : Error" ,err_description.c_str() );
    PyGILState_Release(gstate);
    return false;
  }
  Py_DECREF(obj);

  PyObject* func = PyObject_GetAttrString(main_mod, "f");
  if ( func == NULL){
    fflush(stderr);
    err_description="";
    PyObject* new_stderr = newPyStdOut(err_description);
    PyObject* old_stderr = PySys_GetObject((char*)"stderr");
    Py_INCREF(old_stderr);
    PySys_SetObject((char*)"stderr", new_stderr);
    PyErr_Print();
    PySys_SetObject((char*)"stderr", old_stderr);
    Py_DECREF(new_stderr);
    if (displayError)
      SUIT_MessageBox::warning( dlg(),"Python Error" ,err_description.c_str() );
    PyGILState_Release(gstate);
    return false;
  }

  PyGILState_Release(gstate);


  return true;
}

//================================================================================
/*!
 * \brief SLOT: Activate selection of faces in the Viewer
 */
//================================================================================

void BLSURFPluginGUI_HypothesisCreator::onHyPatchFaceSelection(bool on)
{
  if ( on && myHyPatchFaceSelector->GetMainShape().IsNull() )
  {
    QString aMainEntry = SMESHGUI_GenericHypothesisCreator::getMainShapeEntry();
    QString aSubEntry  = SMESHGUI_GenericHypothesisCreator::getShapeEntry();
    myHyPatchFaceSelector->SetGeomShapeEntry( aSubEntry, aMainEntry );
  }
  myHyPatchFaceSelector->setVisible( on );  // show its buttons
  myHyPatchFaceSelector->ShowPreview( on ); // show faces in the Viewer
  // treat selection or not
  myHyPatchFaceSelector->ActivateSelection( on || myHyPatchGroupSelBtn->isChecked() );

  if ( on )
    myHyPatchGroupSelBtn->setChecked( false );
}

//================================================================================
/*!
 * \brief SLOT: Deactivate selection of faces in the Viewer
 */
//================================================================================

void BLSURFPluginGUI_HypothesisCreator::onHyPatchGroupSelection(bool on)
{
  if ( on && myHyPatchFaceSelector->GetMainShape().IsNull() )
  {
    QString aMainEntry = SMESHGUI_GenericHypothesisCreator::getMainShapeEntry();
    QString aSubEntry  = SMESHGUI_GenericHypothesisCreator::getShapeEntry();
    myHyPatchFaceSelector->SetGeomShapeEntry( aSubEntry, aMainEntry );
  }
  if ( !myHyPatchFaceSelBtn->isChecked() )
  {
    myHyPatchFaceSelector->setVisible( false ); // show its buttons
    myHyPatchFaceSelector->ShowPreview( false ); // show faces in the Viewer
  }
  // treat selection or not
  myHyPatchFaceSelector->ActivateSelection( on || myHyPatchFaceSelBtn->isChecked() );

  if ( on )
    myHyPatchFaceSelBtn->setChecked( false );
}

//================================================================================
/*!
 * \brief SLOT: show IDs of selected faces in Tags LineEdit
 */
//================================================================================

void BLSURFPluginGUI_HypothesisCreator::onHyPatchSelectionChanged()
{
  QString tagString;
  const QList<int>& tags = myHyPatchFaceSelector->GetSelectedIDs();
  for ( int i = 0; i < tags.size(); ++i )
    tagString += QString::number( tags[i] ) + " ";

  myHyPatchTagsLE->setText( tagString );
}

//================================================================================
/*!
 * \brief SLOT: Add the Tags to the HyperPatch table
 */
//================================================================================

void BLSURFPluginGUI_HypothesisCreator::onHyPatchAdd()
{
  QStringList tagList = myHyPatchTagsLE->text().split(" ",  QString::SkipEmptyParts);
  if ( tagList.size() > 1 )
  {
    LightApp_SelectionMgr* selMrg = SMESHGUI::GetSMESHGUI()->selectionMgr();
    SALOME_ListIO aList;
    selMrg->selectedObjects( aList );
    QString entries;
    for ( SALOME_ListIteratorOfListIO anIt( aList ); anIt.More(); anIt.Next() )
    {
      Handle(SALOME_InteractiveObject) io = anIt.Value();
      GEOM::GEOM_Object_var go = myHyPatchFaceSelector->GetGeomObjectByEntry( io->getEntry() );
      if ( !CORBA::is_nil( go ))
        entries += io->getEntry() + QString(" ");
      else
      {
        entries.clear();
        break;
      }
    }
    addHyPatchToTable( myHyPatchTagsLE->text(), entries );
    myHyPatchTagsLE->setText("");
  }
}

//================================================================================
/*!
 * \brief Add a row to myHyPatchTable
 */
//================================================================================

void BLSURFPluginGUI_HypothesisCreator::addHyPatchToTable(const QString& tags,
                                                          const QString& entries)
{
  if ( tags.isEmpty() ) return;

  QTableWidgetItem* cell = new QTableWidgetItem( tags );
  cell->setFlags( Qt::ItemIsSelectable | Qt::ItemIsEnabled );
  if ( entries.isEmpty() )
    cell->setData( Qt::UserRole, QVariant() );
  else
    cell->setData( Qt::UserRole, entries );

  int row = myHyPatchTable->rowCount();
  myHyPatchTable->insertRow( row );
  myHyPatchTable->setItem( row, 0, cell );
}

//================================================================================
/*!
 * \brief SLOT: remove selected rows from the HyperPatch table
 */
//================================================================================

void BLSURFPluginGUI_HypothesisCreator::onHyPatchRemove()
{
  QList<QTableWidgetItem *> items = myHyPatchTable->selectedItems();
  while ( !items.isEmpty() )
  {
    myHyPatchTable->removeRow( items[0]->row() );
    items = myHyPatchTable->selectedItems();
  }
}

//================================================================================
/*!
 * \brief Add a new row in Enforced mesh table
 */
//================================================================================

void BLSURFPluginGUI_HypothesisCreator::addEnforcedMesh( SMESH::SMESH_IDSource_ptr mesh,
                                                         const QString&            groupName  )
{
  _PTR(SObject) sobj = SMESH::FindSObject( mesh );
  if ( !sobj )
    return;

  QString meshEntry = sobj->GetID().c_str();
  QString meshName  = sobj->GetName().c_str();

  QTableWidgetItem* meshCell = new QTableWidgetItem( meshName );
  meshCell->setData( Qt::UserRole, meshEntry );
  meshCell->setFlags( Qt::ItemIsSelectable | Qt::ItemIsEnabled );

  QTableWidgetItem* groupCell = new QTableWidgetItem( groupName );
  groupCell->setFlags( Qt::ItemIsSelectable | Qt::ItemIsEnabled | Qt::ItemIsEditable );

  int row = myEnfMeshTableWdg->rowCount();
  myEnfMeshTableWdg->insertRow( row );
  myEnfMeshTableWdg->setItem( row, 0, meshCell );
  myEnfMeshTableWdg->setItem( row, 1, groupCell );

  myEnfMeshTableWdg->resizeColumnToContents( 0 );
  myEnfMeshTableWdg->resizeColumnToContents( 1 );
}

//================================================================================
/*!
 * \brief SLOT called when [Add] is clicked in Enforced mesh tab.
 *        Add an item to the enforced meshes table
 */
//================================================================================

void BLSURFPluginGUI_HypothesisCreator::onAddEnforcedMesh()
{
  if ( myEnfMeshWdg->NbObjects() != 1 )
    return;

  SMESH::SMESH_IDSource_var mesh = myEnfMeshWdg->GetObject< SMESH::SMESH_IDSource >();
  QString              groupName = myEnforcedGroupName->text().simplified();

  addEnforcedMesh( mesh, groupName );

  selectionMgr()->clearSelected();
  myEnfMeshWdg->SetObject( SMESH::SMESH_IDSource::_nil() );
}

//================================================================================
/*!
 * \brief SLOT called when [Remove] is clicked in Enforced mesh tab.
 *        Remove a selected mesh from the enforced meshes table
 */
//================================================================================

void BLSURFPluginGUI_HypothesisCreator::onRemoveEnforcedMesh()
{
  QList<int> selectedRows;
  QList<QTableWidgetItem *> selectedItems = myEnfMeshTableWdg->selectedItems();
  QTableWidgetItem* item;
  int row;
  foreach( item, selectedItems )
  {
    row = item->row();
    if (!selectedRows.contains( row ) )
      selectedRows.append(row);
  }

  qSort( selectedRows );
  QListIterator<int> it( selectedRows );
  it.toBack();
  while ( it.hasPrevious() ) {
    row = it.previous();
    myEnfMeshTableWdg->removeRow(row );
  }

  myEnfMeshTableWdg->selectionModel()->clearSelection();

  onEnforcedMeshSelected(); // to activate [Add] if possible
}

//================================================================================
/*!
 * \brief SLOT called when mesh selection changes. Enable/disable [Add] button
 */
//================================================================================

void BLSURFPluginGUI_HypothesisCreator::onEnforcedMeshSelected()
{
  bool enable = ( myEnfMeshWdg->NbObjects() == 1 );
  if ( enable )
  {
    // check if a selected mesh contains segments
    SMESH::SMESH_IDSource_var mesh = myEnfMeshWdg->GetObject< SMESH::SMESH_IDSource >();
    if (( enable = !mesh->_is_nil() ))
    {
      SMESH::array_of_ElementType_var types = mesh->GetTypes();
      if (( enable = ( types->length() > 0 )))
      {
        enable = false;
        for ( CORBA::ULong i = 0; i < types->length() &&  !enable; ++i )
          enable = ( types[ i ] = SMESH::EDGE );
      }
    }

    // check if this mesh is already in the table
    if ( enable )
    {
      _PTR(SObject) sobj = SMESH::FindSObject( mesh );
      if (( enable = bool( sobj )))
      {
        QString meshEntry = sobj->GetID().c_str();
        for ( int row = 0, nbRow = myEnfMeshTableWdg->rowCount(); row < nbRow &&  enable; ++row )
        {
          QTableWidgetItem * cell = myEnfMeshTableWdg->item( row, 0 );
          enable = ( meshEntry != cell->data( Qt::UserRole ).toString() );
        }
      }
    }
  }
  myAddEnfMeshButton->setEnabled( enable );
}

//================================================================================
/*!
 * \brief SLOT called when selection changes in the table. Enable/disable [Remove] button
 */
//================================================================================

void BLSURFPluginGUI_HypothesisCreator::onEnfMeshTableSelected()
{
  bool enable = !myEnfMeshTableWdg->selectedItems().empty();

  myRemoveEnfMeshButton->setEnabled( enable );
}

//================================================================================
/*!
 * \brief Return false if algorithm is a re-mesher
 */
//================================================================================

bool BLSURFPluginGUI_HypothesisCreator::hasGeom() const
{
  return hypType() == BLSURFPlugin_Hypothesis::GetHypType(true);
}

QString BLSURFPluginGUI_HypothesisCreator::caption() const
{
  return tr( "BLSURF_TITLE" );
}

QPixmap BLSURFPluginGUI_HypothesisCreator::icon() const
{
  return SUIT_Session::session()->resourceMgr()->loadPixmap( "BLSURFPlugin", tr( "ICON_DLG_BLSURF_PARAMETERS") );
}

QString BLSURFPluginGUI_HypothesisCreator::type() const
{
  return tr( "BLSURF_HYPOTHESIS" );
}

QString BLSURFPluginGUI_HypothesisCreator::helpPage() const
{
  return "blsurf_hypo_page.html";
}

LightApp_SelectionMgr* BLSURFPluginGUI_HypothesisCreator::selectionMgr()
{

  SalomeApp_Application* anApp = dynamic_cast<SalomeApp_Application*>( SUIT_Session::session()->activeApplication() );
  if( anApp )
    return dynamic_cast<LightApp_SelectionMgr*>( anApp->selectionMgr() );
  else
    return 0;
}

CORBA::Object_var BLSURFPluginGUI_HypothesisCreator::entryToObject(QString entry)
{
  CORBA::Object_var obj;
  SALOMEDS::SObject_var aSObj = SMESH_Gen_i::GetSMESHGen()->getStudyServant()->FindObjectID( entry.toStdString().c_str() );
  if (!aSObj->_is_nil()) {
    obj = aSObj->GetObject();
    aSObj->UnRegister();
  }
  return obj;
}

int BLSURFPluginGUI_HypothesisCreator::findRowFromEntry(QString entry){
  int endRow = mySizeMapTable->topLevelItemCount()-1;
  int row = 0;
  for ( ; row <= endRow; ++row )
  {
    QString entryForChecking = mySizeMapTable->topLevelItem( row )->data( SMP_ENTRY_COLUMN, Qt::EditRole ).toString();
    if (entry == entryForChecking )
      break;
  }
  return row;
}


