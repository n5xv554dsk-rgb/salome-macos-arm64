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
// File   : HexoticPluginGUI_HypothesisCreator.h
// Author : Lioka RAZAFINDRAZAKA (CEA)
// ---
//
#ifndef HexoticPLUGINGUI_HypothesisCreator_H
#define HexoticPLUGINGUI_HypothesisCreator_H

#include "HexoticPluginGUI.h"
#include "HexoticPlugin_Hypothesis.hxx"

#include <SMESHGUI_Hypotheses.h>
#include <StdMeshersGUI_ObjectReferenceParamWdg.h>
#include <QItemDelegate>

#include CORBA_SERVER_HEADER(HexoticPlugin_Algorithm)

class QtxIntSpinBox;
class QCheckBox;
class QLineEdit;
class QTableWidgetItem;

class HexoticPluginGUI_StdWidget;
class HexoticPluginGUI_AdvWidget;
class HexoticPluginGUI_SizeMapsWidget;
class HexoticPluginGUI_ViscousLayersWidget;
class SMESH_AdvOptionsWdg;

typedef struct
{
  QString  myName;
  int      myHexesMinLevel, myHexesMaxLevel;
  double   myMinSize, myMaxSize, myApproxAngle;
  bool     myHexoticInvalidElements;
  bool     myHexoticIgnoreRidges;
  double   myHexoticSharpAngleThreshold;
  int      myHexoticNbProc;
  QString  myHexoticWorkingDir;
  int      myHexoticVerbosity;
  int      myHexoticMaxMemory;
  int      myHexoticSdMode;
  QString  myTextOptions;
  bool     myKeepFiles,myLogInStandardOutput, myRemoveLogOnSuccess;
  HexoticPlugin_Hypothesis::THexoticSizeMaps mySizeMaps;
  int      myNbLayers;
  double   myFirstLayerSize;
  bool     myDirection;
  double   myGrowth;
  std::vector<int> myFacesWithLayers;
  std::vector<int> myImprintedFaces;
} HexoticHypothesisData;

/*!
 * \brief Class for creation of MG-Hexa hypotheses
*/
class HEXOTICPLUGIN_GUI_EXPORT HexoticPluginGUI_HypothesisCreator : public SMESHGUI_GenericHypothesisCreator
{
  Q_OBJECT

public:
  HexoticPluginGUI_HypothesisCreator( const QString& );
  virtual ~HexoticPluginGUI_HypothesisCreator();

  virtual bool checkParams(QString&) const;
  virtual QString  helpPage() const;

protected:
  virtual QFrame*  buildFrame    ();
  virtual void     retrieveParams() const;
  virtual QString  storeParams   () const;

  virtual QString  caption() const;
  virtual QPixmap  icon() const;
  virtual QString  type() const;

private:
  bool readParamsFromHypo( HexoticHypothesisData& ) const;
  bool readParamsFromWidgets( HexoticHypothesisData& ) const;
  bool readSizeMapsFromWidgets( HexoticHypothesisData& ) const;
  void insertLocalSizeInWidget( std::string entry, std::string shapeName, double size, int row ) const;
  bool storeParamsToHypo( const HexoticHypothesisData& ) const;
  void resizeEvent(QResizeEvent *event);
  void printData(HexoticHypothesisData&) const;

  GEOM::GEOM_Object_var entryToObject( std::string entry) const;

private:

//  QWidget*            myStdGroup;
  QLineEdit*                              myName;
  HexoticPluginGUI_StdWidget*             myStdWidget;
  HexoticPluginGUI_AdvWidget*             myAdvWidget;
  mutable HexoticPLUGIN::string_array_var myOptions, myCustomOptions;
  HexoticPluginGUI_SizeMapsWidget*        mySmpWidget;
  HexoticPluginGUI_ViscousLayersWidget*   myVLWidget;
  StdMeshersGUI_ObjectReferenceParamWdg*  myGeomSelWdg;

  bool                           myIs3D;
  std::vector< std::string >     mySizeMapsToRemove;
  QVariant                       myNotModifiedSize;

protected slots:
  void             onAddLocalSize();
  void             onRemoveLocalSize();
  void             onTabChanged(int);
  void             onAddOption();
  void             onDirBtnClicked();
};

class SizeMapsTableWidgetDelegate : public QItemDelegate
{
    Q_OBJECT

public:
  SizeMapsTableWidgetDelegate(QObject *parent = 0);

  QWidget *createEditor(QWidget *parent,
                        const QStyleOptionViewItem &option,
                        const QModelIndex &index) const;

  void setEditorData(QWidget *editor,
                     const QModelIndex &index) const;

  void setModelData(QWidget *editor,
                    QAbstractItemModel *model,
                    const QModelIndex &index) const;

  void updateEditorGeometry(QWidget *editor,
                            const QStyleOptionViewItem &option,
                            const QModelIndex &index) const;
};

#endif
