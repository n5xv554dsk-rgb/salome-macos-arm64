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
// File   : HYBRIDPluginGUI_HypothesisCreator.h
// Author : Christian VAN WAMBEKE (CEA)
// ---
//
#ifndef HYBRIDPLUGINGUI_HypothesisCreator_HeaderFile
#define HYBRIDPLUGINGUI_HypothesisCreator_HeaderFile

#ifdef WIN32
  #if defined HYBRIDPluginGUI_EXPORTS
    #define HYBRIDPLUGINGUI_EXPORT __declspec( dllexport )
  #else
    #define HYBRIDPLUGINGUI_EXPORT __declspec( dllimport )
  #endif
#else
  #define HYBRIDPLUGINGUI_EXPORT
#endif

#include <SMESHGUI_Hypotheses.h>
#include <GeomSelectionTools.h>
#include <TopAbs_ShapeEnum.hxx>

#include <QItemDelegate>
#include <map>
#include <vector>
#include <set>
#include <GEOM_Client.hxx>
#include CORBA_SERVER_HEADER(HYBRIDPlugin_Algorithm)
#include CORBA_SERVER_HEADER(SMESH_Gen)
#include CORBA_SERVER_HEADER(SMESH_Mesh)

class QCheckBox;
class QComboBox;
class QHeaderView;
class QLineEdit;
class QSpinBox;
class QTableWidget;
class QTableWidgetItem;
class QWidget;

class HYBRIDPluginGUI_StdWidget;
class HYBRIDPluginGUI_AdvWidget;
class LightApp_SelectionMgr;
class SMESHGUI_SpinBox;
class SUIT_SelectionFilter;
class StdMeshersGUI_ObjectReferenceParamWdg;
class StdMeshersGUI_SubShapeSelectorWdg;

class QTEnfVertex
{

public:
  QTEnfVertex(double size, double x=0., double y=0., double z=0., QString name="", QString geomEntry="", QString groupName="", bool isCompound = false);

private:
  bool operator == (const QTEnfVertex* other) const {
    if (other) {
      if (this->coords.size() && other->coords.size())
        return (this->coords == other->coords);
      else
        return (this->geomEntry == other->geomEntry);
    }
  }
  
  QString name;
  QString geomEntry;
  bool isCompound;
  QString groupName;
  double size;
  std::vector<double> coords;
};

typedef QList< QTEnfVertex* > QEnfVertexList;

// Enforced vertex
struct TEnfVertex{
  std::string name;
  std::string geomEntry;
  bool isCompound;
  std::vector<double> coords;
  std::string groupName;
  double size;
};

struct CompareEnfVertices
{
  bool operator () (const TEnfVertex* e1, const TEnfVertex* e2) const {
    if (e1 && e2) {
      if (e1->coords.size() && e2->coords.size())
        return (e1->coords < e2->coords);
      else
        return (e1->geomEntry < e2->geomEntry);
    }
    return false;
  }
};

// List of enforced vertices
typedef std::set< TEnfVertex*, CompareEnfVertices > TEnfVertexList;

// Enforced mesh
struct TEnfMesh{
  std::string name;
  std::string entry;
  int elementType;
  std::string groupName;
};

struct CompareEnfMeshes
{
  bool operator () (const TEnfMesh* e1, const TEnfMesh* e2) const {
    if (e1 && e2) {
      if (e1->entry == e2->entry)
        return (e1->elementType < e2->elementType);
      else
        return (e1->entry < e2->entry);
    }
    else
      return false;
  }
};
// List of enforced meshes
typedef std::set< TEnfMesh*, CompareEnfMeshes > TEnfMeshList;

typedef struct
{
  bool    myHeightIsRelative, myImprinting, mySnapping, myLayersOnAllWrap,
          myKeepFiles, myLogInStandardOutput, myRemoveLogOnSuccess, myUseLib;
  int     myOptimizationLevel, myCollisionMode, myBoundaryLayersGrowth, myElementGeneration;
  QString myName,myWorkingDir;
  double  myGradation;
  short   myVerboseLevel;
  TEnfVertexList myEnforcedVertices;
  TEnfMeshList myEnforcedMeshes;
  double  myHeightFirstLayer,
          myBoundaryLayersProgression,
          myCoreSize,
          myBoundaryLayersMaxElemAngle;
  short   myNbOfBoundaryLayers;
  // IDs of faces with layers
  SMESH::long_array_var myFaceWLIds;
  // IDs of faces with imprinting
  SMESH::long_array_var myFaceWIIds;
  // IDs of faces with snapping
  SMESH::long_array_var myFaceWSIds;

} HYBRIDHypothesisData;

/*!
  \brief Class for creation of HYBRID 3D hypotheses
*/
class HYBRIDPLUGINGUI_EXPORT HYBRIDPluginGUI_HypothesisCreator : public SMESHGUI_GenericHypothesisCreator
{
  Q_OBJECT

public:
  HYBRIDPluginGUI_HypothesisCreator( const QString& );
  virtual ~HYBRIDPluginGUI_HypothesisCreator();

  virtual bool     checkParams(QString& msg) const;
  virtual QString  helpPage() const;

protected:
  virtual QFrame*  buildFrame    ();
  virtual void     retrieveParams() const;
  virtual QString  storeParams   () const;

  virtual QString  caption() const;
  virtual QPixmap  icon() const;
  virtual QString  type() const;

protected slots:
  void                onAddOption();
  void                onDirBtnClicked();
  void                updateWidgets();
  
  void                addEnforcedVertex(double x=0, double y=0, double z=0, double size = 0,
                                        std::string vertexName = "", std::string geomEntry = "", std::string groupName = "",
                                        bool isCompound = false);
  void                onAddEnforcedVertex();
  void                onRemoveEnforcedVertex();
  void                synchronizeCoords();
  void                updateEnforcedVertexValues(QTableWidgetItem* );
  void                onSelectEnforcedVertex();
  void                clearEnforcedVertexWidgets();
  void                checkVertexIsDefined();
  void                clearEnfVertexSelection();
  
  void                addEnforcedMesh(std::string name, std::string entry, int elementType, std::string groupName = "");
  void                onAddEnforcedMesh();
  void                onRemoveEnforcedMesh();
  //void                synchronizeEnforcedMesh();
  void                checkEnfMeshIsDefined();
  void                onTabChanged( int );
  
signals:
  void                vertexDefined(bool);
  void                enfMeshDefined(bool);
  
private:
  bool                readParamsFromHypo( HYBRIDHypothesisData& ) const;
  bool                readParamsFromWidgets( HYBRIDHypothesisData& ) const;
  bool                storeParamsToHypo( const HYBRIDHypothesisData& ) const;
  GeomSelectionTools* getGeomSelectionTool();
  GEOM::GEOM_Gen_var  getGeomEngine();

private:
  QWidget*            myStdGroup;
  QLineEdit*          myName;
  HYBRIDPluginGUI_StdWidget* myStdWidget;
  HYBRIDPluginGUI_AdvWidget* myAdvWidget;

  mutable HYBRIDPlugin::string_array_var myOptions, myCustomOptions;

  QWidget*            myEnfGroup;
  QPixmap             iconVertex, iconCompound;
  StdMeshersGUI_ObjectReferenceParamWdg *myEnfVertexWdg;
  GEOM::GEOM_Object_var myEnfVertex;
  QTableWidget*       myEnforcedTableWidget;
  SMESHGUI_SpinBox*   myXCoord;
  SMESHGUI_SpinBox*   myYCoord;
  SMESHGUI_SpinBox*   myZCoord;
  SMESHGUI_SpinBox*   mySizeValue;
  QLineEdit*          myGroupName;
//   QGroupBox*          makeGroupsCheck;
//   QCheckBox*          myGlobalGroupName;  
  QPushButton*        addVertexButton;
  QPushButton*        removeVertexButton;
  
  QWidget*            myEnfMeshGroup;
  StdMeshersGUI_ObjectReferenceParamWdg *myEnfMeshWdg;
//   SMESH::SMESH_IDSource_var myEnfMesh;
  QComboBox*          myEnfMeshConstraint;
  QStringList         myEnfMeshConstraintLabels;
//   SMESH::mesh_array_var myEnfMeshArray;
  QTableWidget*       myEnforcedMeshTableWidget;
  QLineEdit*          myMeshGroupName;
  QPushButton*        addEnfMeshButton;
  QPushButton*        removeEnfMeshButton;
  
  GeomSelectionTools* GeomToolSelected;
  
  SMESHGUI_SpinBox*   myHeightFirstLayerSpin;
  QSpinBox*           myNbOfBoundaryLayersSpin;
  SMESHGUI_SpinBox*   myBoundaryLayersProgressionSpin;
  SMESHGUI_SpinBox*   myCoreSizeSpin;
  SMESHGUI_SpinBox*   myMultinormalsAngleSpin;
  QCheckBox*          mySmoothNormalsCheck;

  QLabel* myFacesLbl;
  StdMeshersGUI_SubShapeSelectorWdg* myFaceSelectorLayers;
  StdMeshersGUI_SubShapeSelectorWdg* myFaceSelectorImprinting;
  StdMeshersGUI_SubShapeSelectorWdg* myFaceSelectorSnapping;
};

class EnforcedVertexTableWidgetDelegate : public QItemDelegate
{
    Q_OBJECT

public:
  EnforcedVertexTableWidgetDelegate(QObject *parent = 0);

  QWidget *createEditor(QWidget *parent, const QStyleOptionViewItem &option,
                      const QModelIndex &index) const;

  void setEditorData(QWidget *editor, const QModelIndex &index) const;
  void setModelData(QWidget *editor, QAbstractItemModel *model,
                  const QModelIndex &index) const;

  void updateEditorGeometry(QWidget *editor,
      const QStyleOptionViewItem &option, const QModelIndex &index) const;

  bool vertexExists(QAbstractItemModel *model, const QModelIndex &index, QString value) const;
};

class EnforcedMeshTableWidgetDelegate : public QItemDelegate
{
    Q_OBJECT

public:
  EnforcedMeshTableWidgetDelegate(QObject *parent = 0);

  QWidget *createEditor(QWidget *parent, const QStyleOptionViewItem &option,
                      const QModelIndex &index) const;

  void setEditorData(QWidget *editor, const QModelIndex &index) const;
  void setModelData(QWidget *editor, QAbstractItemModel *model,
                  const QModelIndex &index) const;

  void updateEditorGeometry(QWidget *editor,
      const QStyleOptionViewItem &option, const QModelIndex &index) const;
};

#endif
