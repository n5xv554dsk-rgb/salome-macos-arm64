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
// File    : BLSURFPluginGUI_HypothesisCreator.h
// Authors : Francis KLOSS (OCC) & Patrick LAUG (INRIA) & Lioka RAZAFINDRAZAKA (CEA)
//           & Aurelien ALLEAUME (DISTENE)
//           Size maps developement: Nicolas GEIMER (OCC) & Gilles DAVID (EURIWARE)
// ---
//
#ifndef BLSURFPLUGINGUI_HypothesisCreator_H
#define BLSURFPLUGINGUI_HypothesisCreator_H

// akl: avoid compilation warning on Linux : "_POSIX_C_SOURCE" and "_XOPEN_SOURCE" are redefined
#ifdef _POSIX_C_SOURCE
#undef _POSIX_C_SOURCE
#endif

#ifdef _XOPEN_SOURCE
#undef _XOPEN_SOURCE
#endif

#ifdef WIN32
  #if defined BLSURFPLUGIN_GUI_EXPORTS || defined BLSURFPluginGUI_EXPORTS
    #define BLSURFPLUGIN_GUI_EXPORT __declspec( dllexport )
  #else
    #define BLSURFPLUGIN_GUI_EXPORT __declspec( dllimport )
  #endif
#else
  #define BLSURFPLUGIN_GUI_EXPORT
#endif

#include <Python.h>
#ifdef WIN32
// E.A. : On windows with python 2.6, there is a conflict
// E.A. : between pymath.h and Standard_math.h which define
// E.A. : some same symbols : acosh, asinh, ...
#include <Standard_Real.hxx>
#include <pymath.h>
#endif

#include <QItemDelegate>

#include <SMESHGUI_Hypotheses.h>
#include "StdMeshersGUI_ObjectReferenceParamWdg.h"
#include <SALOMEconfig.h>
#include <cstring>
#include <map>
#include <set>
#include <vector>
#include <TopAbs_ShapeEnum.hxx>
#include <GeomSelectionTools.h>
#include <GEOM_Client.hxx>
#include CORBA_SERVER_HEADER(BLSURFPlugin_Algorithm)

class QGroupBox;
class QComboBox;
class QCheckBox;
class QLineEdit;
class QRadioButton;
class QTableWidget;
class QTreeWidget;
class QModelIndex;
class QSpinBox;
class QDoubleSpinBox;
class QMenu;
class QAction;
class QTreeWidgetItem;
class QTableWidgetItem;
class QObject;
class QSplitter;
class QGridLayout;
class QVBoxLayout;
class QSpacerItem;

class SMESHGUI_SpinBox;
class SMESH_NumberFilter;
class LightApp_SelectionMgr;
class BLSURFPluginGUI_StdWidget;
class BLSURFPluginGUI_AdvWidget;
class StdMeshersGUI_SubShapeSelectorWdg;
// class DlgBlSurfHyp_Enforced;

// Name
typedef std::string TEnfName;
// Entry
typedef std::string TEntry;
// List of entries
typedef std::set<TEntry> TEntryList;
// Enforced vertex = 3 coordinates
typedef std::vector<double> TEnfVertexCoords;
// List of enforced vertices
typedef std::set< TEnfVertexCoords > TEnfVertexCoordsList;
// Enforced vertex
struct TEnfVertex{
  TEnfName name;
  TEntry geomEntry;
  TEnfVertexCoords coords;
  TEnfName grpName;
};
// Attractor
struct TAttractor{
  std::string attEntry;
  double      startSize;
  double      infDist;
  double      constDist;
  TAttractor( const char* theAttEntry, double theStartSize, double theInfDist, double theConstDist)
    : attEntry( theAttEntry ),
      startSize( theStartSize ),
      infDist( theInfDist ),
      constDist( theConstDist )
  {}
  void SetToDelete() { startSize = -1; }
  bool IsToDelete() const { return startSize < 0; }
};
typedef std::vector< TAttractor > TAttractorVec;

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

// Map Face Entry / List of enforced vertices
typedef std::map< TEntry, TEnfVertexList > TFaceEntryEnfVertexListMap;

// Map Face Entry / InternalEnforcedVertices
typedef std::map< TEntry, bool > TFaceEntryInternalVerticesMap;

// PreCad Face and Edge periodicity
typedef std::vector<std::string> TPreCadPeriodicity;
typedef std::vector< TPreCadPeriodicity > TPreCadPeriodicityVector;

typedef struct
{
  int     myTopology, myVerbosity;
  int     myPhysicalMesh, myGeometricMesh;
  double  myPhySize, myMinSize, myMaxSize;
  bool    myPhySizeRel, myMinSizeRel, myMaxSizeRel;
  bool    myUseMinSize, myUseMaxSize, myUseGradation, myUseVolumeGradation;
  double  myGradation, myVolumeGradation, myAngleMesh, myChordalError;
  bool    myAnisotropic, myOptimiseTinyEdges, myRemoveTinyEdges, myForceBadElementRemoval, myCorrectSurfaceIntersection;
  double  myAnisotropicRatio, myTinyEdgeLength, myTinyEdgeOptimisLength, myBadElementAspectRatio, myCorrectSurfaceIntersectionMaxCost;
  bool    myOptimizeMesh, myQuadraticMesh;
  bool    mySmpsurface,mySmpedge,mySmppoint,myEnforcedVertex,myInternalEnforcedVerticesAllFaces;
  int     myElementType;
  bool    myUseSurfaceProximity;
  int     myNbSurfaceProximityLayers;
  double  mySurfaceProximityRatio;
  bool    myUseVolumeProximity;
  int     myNbVolumeProximityLayers;
  double  myVolumeProximityRatio;
  // bool    myPreCADMergeEdges, myPreCADProcess3DTopology, myPreCADDiscardInput;
//   bool    myGMFFileMode;
  std::string myGMFFileName, myInternalEnforcedVerticesAllFacesGroup;
  TEnfVertexList enfVertexList;
  TFaceEntryEnfVertexListMap faceEntryEnfVertexListMap;
  /* TODO GROUPS
  TGroupNameEnfVertexListMap groupNameEnfVertexListMap;
  */
  TPreCadPeriodicityVector preCadPeriodicityVector;
  QStringList hyperpatches, hyperEntries;
  QString myName;
} BlsurfHypothesisData;


/*!
 * \brief Class for creation of MG-CADSurf hypotheses
*/
class BLSURFPLUGIN_GUI_EXPORT BLSURFPluginGUI_HypothesisCreator : public SMESHGUI_GenericHypothesisCreator
{
  Q_OBJECT

public:
  BLSURFPluginGUI_HypothesisCreator( const QString& );
  virtual ~BLSURFPluginGUI_HypothesisCreator();

  virtual bool        checkParams(QString& msg) const;
  virtual QString     helpPage() const;

protected:
  virtual QFrame*     buildFrame    ();
  virtual void        retrieveParams() const;
  virtual QString     storeParams   () const;

  virtual QString     caption() const;
  virtual QPixmap     icon() const;
  virtual QString     type() const;

protected slots:
  void                onStateChange();
  // Advanced tab
  void                onAddOption();
  void                onChangeOptionName( int, int );
  // Sizemap tab
  void                onMapGeomContentModified();
  void                onSmpItemClicked( QTreeWidgetItem *, int );
  void                onTabChanged(int);
  void                onAttractorClicked(int);
  void                onConstSizeClicked(int);
  void                onAddMap();
  void                onRemoveMap();
  void                onModifyMap();
  void                onSetSizeMap(QTreeWidgetItem *, int);
  // Enforced vertices tab
  QTreeWidgetItem*    addEnforcedFace(std::string theFaceEntry, std::string theFaceName);
  void                addEnforcedVertex(double x=0, double y=0, double z=0, 
                                        std::string vertexName = "",
                                        std::string geomEntry = "",
                                        std::string groupName = "");
  void                onAddEnforcedVertices();
  void                onRemoveEnforcedVertex();
  void                synchronizeCoords();
  void                updateEnforcedVertexValues(QTreeWidgetItem* , int );
  void                onSelectEnforcedVertex();
  void                clearEnforcedVertexWidgets();
  void                onInternalVerticesClicked(int);
  // Enforced mesh tab
  void                onAddEnforcedMesh();
  void                onRemoveEnforcedMesh();
  void                onEnforcedMeshSelected();
  void                onEnfMeshTableSelected();
  // Periodicity tab
  void                onPeriodicityByVerticesChecked(bool);
  void                onAddPeriodicity();
  void                onRemovePeriodicity();
  void                onPeriodicityTreeClicked(QTreeWidgetItem*, int);
  void                onPeriodicityContentModified();
  // HyperPatch tab
  void                onHyPatchFaceSelection(bool);
  void                onHyPatchGroupSelection(bool);
  void                onHyPatchSelectionChanged();
  void                onHyPatchAdd();
  void                onHyPatchRemove();

private:
  bool                readParamsFromHypo( BlsurfHypothesisData& ) const;
  QString             readParamsFromWidgets( BlsurfHypothesisData& ) const;
  bool                storeParamsToHypo( const BlsurfHypothesisData& ) const;
  bool                sizeMapsValidation();
  bool                sizeMapValidationFromRow(int,bool displayError = true);
  bool                sizeMapValidationFromEntry(QString,bool displayError = true);
  GeomSelectionTools* getGeomSelectionTool() const;
  GEOM::GEOM_Gen_var  getGeomEngine();
  bool                insertElement( GEOM::GEOM_Object_var, bool modify = false );
  bool                insertAttractor(GEOM::GEOM_Object_var, GEOM::GEOM_Object_var, bool modify = false);
  int                 findRowFromEntry(QString entry);
  CORBA::Object_var   entryToObject(QString entry);
  static LightApp_SelectionMgr* selectionMgr();
  void                avoidSimultaneousSelection(ListOfWidgets &myCustomWidgets) const;
  void                AddPreCadSequenceToVector(BlsurfHypothesisData& h_data, BLSURFPlugin::TPeriodicityList_var preCadFacePeriodicityVector, bool onFace) const;
  void                addHyPatchToTable(const QString& tags, const QString& entries);
  bool                hasGeom() const;

  void                addEnforcedMesh( SMESH::SMESH_IDSource_ptr mesh, const QString& groupName );

private:
  
  QTabWidget*             myTabWidget;
  QWidget*                myStdGroup;
  BLSURFPluginGUI_StdWidget* myStdWidget;
  QLineEdit*              myName;

  QWidget*                myAdvGroup;
  BLSURFPluginGUI_AdvWidget* myAdvWidget;

  // Sizemap widgets
  QWidget                 *mySmpGroup;
  QTreeWidget             *mySizeMapTable;
  QPushButton             *addMapButton;
  QPushButton             *removeMapButton;
  QPushButton             *modifyMapButton;
  QTabWidget              *smpTab; 
  QWidget                 *myAttractorGroup;
  QWidget                 *mySmpStdGroup;
  QCheckBox               *myAttractorCheck;
  QCheckBox               *myConstSizeCheck;
  QGroupBox               *myDistanceGroup;
//   QGroupBox               *myParamsGroup;
//   QWidget                 *myParamsGroup;
  SMESHGUI_SpinBox        *myAttSizeSpin;
  SMESHGUI_SpinBox        *myAttDistSpin;
  SMESHGUI_SpinBox        *myAttDistSpin2;
  SMESHGUI_SpinBox        *mySmpSizeSpin;
  QLabel                  *myAttDistLabel;
  QLabel                  *myAttDistLabel2;
  QLabel                  *myAttSizeLabel;
  // Selection widgets for size maps
  StdMeshersGUI_ObjectReferenceParamWdg *myGeomSelWdg1;
  StdMeshersGUI_ObjectReferenceParamWdg *myGeomSelWdg2;
  StdMeshersGUI_ObjectReferenceParamWdg *myAttSelWdg;
  StdMeshersGUI_ObjectReferenceParamWdg *myDistSelWdg;
  GEOM::GEOM_Object_var                  mySMapObject;
  GEOM::GEOM_Object_var                  myAttObject;
  GEOM::GEOM_Object_var                  myDistObject;
  
  
  
  
  QWidget*            myEnfGroup;
  StdMeshersGUI_ObjectReferenceParamWdg *myEnfFaceWdg;
  GEOM::GEOM_Object_var myEnfFace;
  StdMeshersGUI_ObjectReferenceParamWdg *myEnfVertexWdg;
  GEOM::GEOM_Object_var myEnfVertex;

  QTreeWidget*        myEnforcedTreeWidget;
  SMESHGUI_SpinBox*   myXCoord;
  SMESHGUI_SpinBox*   myYCoord;
  SMESHGUI_SpinBox*   myZCoord;

  QLineEdit*          myGroupName;

  QPushButton*        addVertexButton;
  QPushButton*        removeVertexButton;

  QCheckBox           *myInternalEnforcedVerticesAllFaces;
  QLineEdit           *myInternalEnforcedVerticesAllFacesGroup;


  // Enforced meshes
  QWidget*             myEnfMeshGroup;
  StdMeshersGUI_ObjectReferenceParamWdg *myEnfMeshWdg;
  QTableWidget*        myEnfMeshTableWdg;
  QLineEdit*           myEnforcedGroupName;
  QPushButton*         myAddEnfMeshButton;
  QPushButton*         myRemoveEnfMeshButton;



  // map =  entry , size map
  QMap<QString, QString>          mySMPMap;           // Map <face entry, size>
  QMap<QString, TAttractorVec >   myATTMap;           // Map <face entry, att. entry, etc>
  QMap<QString, TopAbs_ShapeEnum> mySMPShapeTypeMap;
  GeomSelectionTools*             GeomToolSelected;
  LightApp_SelectionMgr*          aSel;

  // Periodicity
  QWidget*      myPeriodicityGroup;
  QSplitter*    myPeriodicitySplitter;
  QTreeWidget*  myPeriodicityTreeWidget;
  QWidget*      myPeriodicityRightWidget;
  QGridLayout*  myPeriodicityRightGridLayout;
  QGroupBox*    myPeriodicityGroupBox1;
  QGroupBox*    myPeriodicityGroupBox2;
  QGridLayout* aPeriodicityLayout1;
  QGridLayout*  myPeriodicityGroupBox1Layout;
  QGridLayout*  myPeriodicityGroupBox2Layout;
  QRadioButton* myPeriodicityOnFaceRadioButton;
  QRadioButton* myPeriodicityOnEdgeRadioButton;
  QLabel*       myPeriodicityMainSourceLabel;
  QLabel*       myPeriodicityMainTargetLabel;
  QLabel*       myPeriodicitySourceLabel;
  QLabel*       myPeriodicityTargetLabel;
  StdMeshersGUI_ObjectReferenceParamWdg* myPeriodicitySourceFaceWdg;
  GEOM::GEOM_Object_var myPeriodicityFace;
  StdMeshersGUI_ObjectReferenceParamWdg* myPeriodicityTargetFaceWdg;
  GEOM::GEOM_Object_var myPeriodicityEdge;
  QLabel*       myPeriodicityP1SourceLabel;
  QLabel*       myPeriodicityP2SourceLabel;
  QLabel*       myPeriodicityP3SourceLabel;
  QLabel*       myPeriodicityP1TargetLabel;
  QLabel*       myPeriodicityP2TargetLabel;
  QLabel*       myPeriodicityP3TargetLabel;
  StdMeshersGUI_ObjectReferenceParamWdg* myPeriodicityP1SourceWdg;
  StdMeshersGUI_ObjectReferenceParamWdg* myPeriodicityP2SourceWdg;
  StdMeshersGUI_ObjectReferenceParamWdg* myPeriodicityP3SourceWdg;
  StdMeshersGUI_ObjectReferenceParamWdg* myPeriodicityP1TargetWdg;
  StdMeshersGUI_ObjectReferenceParamWdg* myPeriodicityP2TargetWdg;
  StdMeshersGUI_ObjectReferenceParamWdg* myPeriodicityP3TargetWdg;
  ListOfWidgets myPeriodicitySelectionWidgets;
  QPushButton*  myPeriodicityAddButton;
  QPushButton*  myPeriodicityRemoveButton;
  QSpacerItem*  myPeriodicityVerticalSpacer;

  QTableWidget*                      myHyPatchTable;
  StdMeshersGUI_SubShapeSelectorWdg* myHyPatchFaceSelector;
  QLineEdit*                         myHyPatchTagsLE;
  QPushButton*                       myHyPatchFaceSelBtn;
  QPushButton*                       myHyPatchGroupSelBtn;

  BLSURFPlugin::string_array_var myOptions, myPreCADOptions, myCustomOptions;

  PyObject *          main_mod;
  PyObject *          main_dict;
};


class EnforcedTreeWidgetDelegate : public QItemDelegate
{
  Q_OBJECT

public:
  EnforcedTreeWidgetDelegate(QObject *parent = 0);

  QWidget *createEditor(QWidget *parent, const QStyleOptionViewItem & option,
                        const QModelIndex &index) const;

  void setEditorData(QWidget *editor, const QModelIndex &index) const;
  void setModelData(QWidget *editor, QAbstractItemModel *model,
                    const QModelIndex &index) const;

  void updateEditorGeometry(QWidget *editor, const QStyleOptionViewItem &option,
                            const QModelIndex &index) const;

  bool vertexExists(QAbstractItemModel *model, const QModelIndex &index, QString value) const;
};

#endif // BLSURFPLUGINGUI_HypothesisCreator_H
