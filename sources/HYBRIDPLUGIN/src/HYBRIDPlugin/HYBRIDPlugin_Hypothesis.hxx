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
// File   : HYBRIDPlugin_Hypothesis.hxx
// Author : Christian VAN WAMBEKE (CEA)
// ---
//
#ifndef HYBRIDPlugin_Hypothesis_HeaderFile
#define HYBRIDPlugin_Hypothesis_HeaderFile

#include "HYBRIDPlugin_Defs.hxx"

#include <SMDS_MeshNode.hxx>

#include "SMESH_Hypothesis.hxx"
#include "SMESH_Mesh_i.hxx"
#include "SMESH_Gen_i.hxx"
#include "SMESH_TypeDefs.hxx"
#include "utilities.h"

#include <stdexcept>
#include <map>
#include <vector>
#include <cstdio>

class HYBRIDPLUGIN_EXPORT HYBRIDPlugin_Hypothesis: public SMESH_Hypothesis
{
public:

  HYBRIDPlugin_Hypothesis(int hypId, SMESH_Gen * gen);

  typedef std::map<std::vector<double>,double> THYBRIDEnforcedVertexCoordsValues;
  typedef std::map<std::string,double> THYBRIDEnforcedVertexEntryValues;
  
  struct THYBRIDEnforcedVertex {
    std::string name;
    std::string geomEntry;
    bool isCompound;
    std::vector<double> coords;
    std::string groupName;
    double size;
  };
  
  struct CompareHYBRIDEnforcedVertex {
    bool operator () (const THYBRIDEnforcedVertex* e1, const THYBRIDEnforcedVertex* e2) const {
      if (e1 && e2) {
        if (e1->coords.size() && e2->coords.size())
          return (e1->coords < e2->coords);
        else
          return (e1->geomEntry < e2->geomEntry);
      }
      return false;
    }
  };
  typedef std::set< THYBRIDEnforcedVertex*, CompareHYBRIDEnforcedVertex > THYBRIDEnforcedVertexList;
  // Map Coords / Enforced node
  typedef std::map< std::vector<double>, THYBRIDEnforcedVertex* > TCoordsHYBRIDEnforcedVertexMap;
  // Map geom entry / Enforced node
  typedef std::map< std::string, THYBRIDEnforcedVertex* > TGeomEntryHYBRIDEnforcedVertexMap;
  // Map groupName / Enforced node
  typedef std::map< std::string, THYBRIDEnforcedVertexList > TGroupNameHYBRIDEnforcedVertexMap;
  
  ////////////////////
  // Enforced meshes
  ////////////////////
  
  struct THYBRIDEnforcedMesh {
    int         persistID;
    std::string name;
    std::string entry;
    std::string groupName;
    SMESH::ElementType elementType;
  };
  
  struct CompareHYBRIDEnforcedMesh {
    bool operator () (const THYBRIDEnforcedMesh* e1, const THYBRIDEnforcedMesh* e2) const {
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
  typedef std::set< THYBRIDEnforcedMesh*, CompareHYBRIDEnforcedMesh > THYBRIDEnforcedMeshList;
  // Map mesh entry / Enforced mesh list
  // ex: 0:1:2:1 -> [ ("Mesh_1", "0:1:2:1", TopAbs_NODE, ""),
  //                  ("Mesh_1", "0:1:2:1", TopAbs_EDGE, "edge group")]
  typedef std::map< std::string, THYBRIDEnforcedMeshList > TEntryHYBRIDEnforcedMeshListMap;
  
  typedef std::map<int,double> TID2SizeMap;

  struct TIDMeshIDCompare {
    bool operator () (const SMDS_MeshElement* e1, const SMDS_MeshElement* e2) const
    { return e1->GetMesh() == e2->GetMesh() ? e1->GetID() < e2->GetID() : e1->GetMesh() < e2->GetMesh(); }
  };
  
  typedef std::map<const SMDS_MeshElement*, std::string, TIDMeshIDCompare > TIDSortedElemGroupMap;
  typedef std::map<const SMDS_MeshNode*, std::string, TIDMeshIDCompare > TIDSortedNodeGroupMap;
  typedef std::set<std::string> TSetStrings;

  static const char* GetHypType() { return "HYBRID_Parameters"; }


  /*!
   * Sizes of boundary layers are relative to the surface size. Default no
   */
  void SetHeightIsRelative( bool isRelative );
  bool GetHeightIsRelative() const { return myHeightIsRelative; }
  /*!
   * Maximum internal angles of boundary elements (in degree)
   */
  void SetBoundaryLayersMaxElemAngle( double angle );
  double GetBoundaryLayersMaxElemAngle() const { return myBoundaryLayersMaxElemAngle; }
  /*!
   * To call MG-Hybrid by library. Default is no (i.e. by executable)
   */
  void SetToUseLibrary(bool toUseLib);
  bool GetToUseLibrary() const;
  /*!
   * To mesh layers on all wrap. Default is yes.
   */
  void SetLayersOnAllWrap(bool toMesh);
  bool GetLayersOnAllWrap(bool checkFreeOption = false) const;
  /*!
   * IDs of faces to grow the layers on
   */
  bool SetFacesWithLayers(const std::vector<int>& theVal);
  const std::vector<int>& GetFacesWithLayers() const;
  /*!
   * IDs of faces to imprint the layers on
   */
  bool SetFacesWithImprinting(const std::vector<int>& theVal);
  const std::vector<int>& GetFacesWithImprinting() const;
  /*!
   * IDs of faces with snapping (faces that already have surface layers)
   */
  bool SetFacesWithSnapping(const std::vector<int>& theVal);
  const std::vector<int>& GetFacesWithSnapping() const;
  /*!
   * To make groups of volumes of different domains when mesh is generated from skin.
   * Default is to make groups.
   * This option works only (1) for the mesh w/o shape and (2) if GetToMeshHoles() == true
   */
  void SetToMakeGroupsOfDomains(bool toMakeGroups);
  bool GetToMakeGroupsOfDomains() const;
  /*!
   * Maximal size of memory to be used by the algorithm (in Megabytes)
   */
  void SetMaximumMemory(double MB);
  double GetMaximumMemory() const;
  /*!
   * Initial size of memory to be used by the algorithm (in Megabytes) in
   * automatic memory adjustment mode. Default is zero
   */
  void SetInitialMemory(double MB);
  double GetInitialMemory() const;
  /*!
   * Optimization level: 0-none, 1-light, 2-medium, 3-standard+, 4-strong. Default is medium
   */
  enum OptimizationLevel { None = 0, Light, Medium, StandardPlus, Strong };
  void SetOptimizationLevel(OptimizationLevel level);
  OptimizationLevel GetOptimizationLevel() const;

  /*!
   * Collision Mode: 0-decrease, 1-stop. Default is decrease
   */
  enum CollisionMode { Decrease = 0, Stop };
  void SetCollisionMode(CollisionMode mode);
  CollisionMode GetCollisionMode() const;
  /*!
   * BoundaryLayersGrowth: 0-Layer_Growth_Inward, 1-Layer_Growth_Outward. Default is Layer_Growth_Inward
   */
  enum BoundaryLayersGrowth { Layer_Growth_Inward = 0, Layer_Growth_Outward };
  void SetBoundaryLayersGrowth(BoundaryLayersGrowth level);
  BoundaryLayersGrowth GetBoundaryLayersGrowth() const;
  /*!
   * ElementGeneration: 0-Generation_Tetra_Dominant, 1-Generation_Hexa_Dominant, 2-Generation_Cartesian_Core. Default is Generation_Tetra_Dominant
   */
  enum ElementGeneration { Generation_Tetra_Dominant = 0, Generation_Hexa_Dominant, Generation_Cartesian_Core, Generation_Extrusion_Only };
  void SetElementGeneration(ElementGeneration level);
  ElementGeneration GetElementGeneration() const;
    /*!
     * To mesh adding extra normals at opening ridges and corners.
     * Default is no.
     */
    void SetAddMultinormals(bool toAddMultinormals);
    bool GetAddMultinormals() const;
    /*!
     * To mesh smoothing normals at closed ridges and corners.
     * Default is no.
     */
    void SetSmoothNormals(bool toSmoothNormals);
    bool GetSmoothNormals() const;
    /*!
     * To set height of the first layer.
     */
    void SetHeightFirstLayer(double HFL);
    double GetHeightFirstLayer() const;
    /*!
     * To set boundary layers coefficient of geometric progression.
     * Default is 1.0
     */
    void SetBoundaryLayersProgression(double BLP);
    double GetBoundaryLayersProgression() const;
    /*!
     * Set core elements size.
     * Default is 0.0
     */
    void SetCoreSize(double CS);
    double GetCoreSize() const;
    /*!
     * To set multinormals angle threshold at opening ridges.
     * Default is 30.0
     */
    void SetMultinormalsAngle(double MNA);
    double GetMultinormalsAngle() const;
    /*!
     * To set number of boundary layers.
     * Default is 1
     */
    void SetNbOfBoundaryLayers(short NBL);
    short GetNbOfBoundaryLayers() const;


  /*!
   * Path to working directory
   */
  void SetWorkingDirectory(const std::string& path);
  std::string GetWorkingDirectory() const;
  /*!
   * To keep working files or remove them. Log file remains in case of errors anyway.
   */
  void SetKeepFiles(bool toKeep);
  bool GetKeepFiles() const;
  /*!
   * Verbose level [0-10]
   *  0 - no standard output,
   *  2 - prints the data, quality statistics of the skin and final meshes and
   *     indicates when the final mesh is being saved. In addition the software
   *     gives indication regarding the CPU time.
   * 10 - same as 2 plus the main steps in the computation, quality statistics
   *     histogram of the skin mesh, quality statistics histogram together with
   *     the characteristics of the final mesh.
   */
  void SetVerboseLevel(short level);
  short GetVerboseLevel() const;
  /*!
   * To create new nodes
   */
  void SetToCreateNewNodes(bool toCreate);
  bool GetToCreateNewNodes() const;
  /*!
   * To use boundary recovery version which tries to create mesh on a very poor
   * quality surface mesh
   */
  void SetToUseBoundaryRecoveryVersion(bool toUse);
  bool GetToUseBoundaryRecoveryVersion() const;
  /*!
   * Applies ﬁnite-element correction by replacing overconstrained elements where
   * it is possible. The process is cutting ﬁrst the overconstrained edges and
   * second the overconstrained facets. This insure that no edges have two boundary
   * vertices and that no facets have three boundary vertices.
   */
  void SetFEMCorrection(bool toUseFem);
  bool GetFEMCorrection() const;
  /*!
   * To removes initial central point.
   */
  void SetToRemoveCentralPoint(bool toRemove);
  bool GetToRemoveCentralPoint() const;
  /*!
   * To set hiden/undocumented/advanced options
   */
  void SetAdvancedOption(const std::string& option);
  std::string GetAdvancedOption() const;
  /*!
   * To define the volumic gradation
   */
  void SetGradation(double gradation);
  double GetGradation() const ;
  /*!
   * Print log in standard output
   */
  void SetStandardOutputLog(bool logInStandardOutput);
  bool GetStandardOutputLog() const ;
  /*!
   * Remove log file on success
   */
  void SetRemoveLogOnSuccess(bool removeLogOnSuccess);
  bool GetRemoveLogOnSuccess() const ;


  typedef std::map< std::string, std::string > TOptionValues;
  typedef std::set< std::string >              TOptionNames;

  void SetOptionValue(const std::string& optionName,
                      const std::string& optionValue);
  std::string GetOptionValue(const std::string& optionName,
                             bool*              isDefault=0) const;
  bool HasOptionDefined( const std::string& optionName ) const;
  void ClearOption(const std::string& optionName);
  TOptionValues        GetOptionValues()       const;
  const TOptionValues& GetCustomOptionValues() const { return _customOption2value; }

  static bool  ToBool(const std::string& str, bool* isOk=0);
  static double ToDbl(const std::string& str, bool* isOk=0);
  static int    ToInt(const std::string& str, bool* isOk=0);


  /*!
   * \brief Return command to run hybrid mesher excluding file prefix (-f)
   */
  static std::string CommandToRun(const HYBRIDPlugin_Hypothesis* hyp);
  /*!
   * \brief Return a unique file name
   */
  static std::string GetFileName(const HYBRIDPlugin_Hypothesis* hyp);
  /*!
   * \brief Return the name of executable
   */
  static std::string GetExeName();
  /*!
   * \brief Return a tag of enforced triangles
   */
  static int EnforcedTag() { return -5; }

  /*!
   * To set an enforced vertex
   */
  bool SetEnforcedVertex(std::string aName, std::string anEntry, std::string aGroupName,
                         double size, double x=0.0, double y=0.0, double z=0.0, bool isCompound = false);
  THYBRIDEnforcedVertex* GetEnforcedVertex(double x, double y, double z);
  THYBRIDEnforcedVertex* GetEnforcedVertex(const std::string anEntry);
  bool RemoveEnforcedVertex(double x=0.0, double y=0.0, double z=0.0, const std::string anEntry="" );
  const THYBRIDEnforcedVertexCoordsValues _GetEnforcedVerticesCoordsSize() const {return _enfVertexCoordsSizeList; }
  const THYBRIDEnforcedVertexEntryValues  _GetEnforcedVerticesEntrySize() const {return _enfVertexEntrySizeList; }
  const THYBRIDEnforcedVertexList         _GetEnforcedVertices() const { return _enfVertexList; }
  const TCoordsHYBRIDEnforcedVertexMap    _GetEnforcedVerticesByCoords() const { return _coordsEnfVertexMap; }
  const TGeomEntryHYBRIDEnforcedVertexMap _GetEnforcedVerticesByEntry() const { return _geomEntryEnfVertexMap; }
  void ClearEnforcedVertices();

  /*!
   * To set enforced elements
   */
  bool SetEnforcedMesh(SMESH_Mesh& theMesh, SMESH::ElementType elementType, std::string name, std::string entry, std::string groupName = "");
  bool SetEnforcedGroup(const SMESHDS_Mesh* theMeshDS, SMESH::smIdType_array_var theIDs, SMESH::ElementType elementType, std::string name, std::string entry, std::string groupName = "");
  bool SetEnforcedElements(TIDSortedElemSet theElemSet, SMESH::ElementType elementType, std::string groupName = "");
  const THYBRIDEnforcedMeshList _GetEnforcedMeshes() const { return _enfMeshList; }
  const TEntryHYBRIDEnforcedMeshListMap _GetEnforcedMeshesByEntry() const { return _entryEnfMeshMap; }
  void ClearEnforcedMeshes();
  const TIDSortedNodeGroupMap _GetEnforcedNodes() const { return _enfNodes; }
  const TIDSortedElemGroupMap _GetEnforcedEdges() const { return _enfEdges; }
  const TIDSortedElemGroupMap _GetEnforcedTriangles() const { return _enfTriangles; }
  const TID2SizeMap _GetNodeIDToSizeMap() const {return _nodeIDToSizeMap; }
  const TSetStrings _GetGroupsToRemove() const {return _groupsToRemove; }
  void RestoreEnfElemsByMeshes(); // persistence
  /*!
   * \brief Return the enforced vertices
   */
  static THYBRIDEnforcedVertexList GetEnforcedVertices(const HYBRIDPlugin_Hypothesis* hyp);
  static THYBRIDEnforcedVertexCoordsValues GetEnforcedVerticesCoordsSize(const HYBRIDPlugin_Hypothesis* hyp);
  static THYBRIDEnforcedVertexEntryValues  GetEnforcedVerticesEntrySize(const HYBRIDPlugin_Hypothesis* hyp);
  static TCoordsHYBRIDEnforcedVertexMap GetEnforcedVerticesByCoords(const HYBRIDPlugin_Hypothesis* hyp);
  static TGeomEntryHYBRIDEnforcedVertexMap GetEnforcedVerticesByEntry(const HYBRIDPlugin_Hypothesis* hyp);
  
  static THYBRIDEnforcedMeshList GetEnforcedMeshes(const HYBRIDPlugin_Hypothesis* hyp);
  static TEntryHYBRIDEnforcedMeshListMap GetEnforcedMeshesByEntry(const HYBRIDPlugin_Hypothesis* hyp);
  static TIDSortedNodeGroupMap GetEnforcedNodes(const HYBRIDPlugin_Hypothesis* hyp);
  static TIDSortedElemGroupMap GetEnforcedEdges(const HYBRIDPlugin_Hypothesis* hyp);
  static TIDSortedElemGroupMap GetEnforcedTriangles(const HYBRIDPlugin_Hypothesis* hyp);
  static TID2SizeMap GetNodeIDToSizeMap(const HYBRIDPlugin_Hypothesis* hyp);
  static TSetStrings GetGroupsToRemove(const HYBRIDPlugin_Hypothesis* hyp);
  static bool GetToMakeGroupsOfDomains(const HYBRIDPlugin_Hypothesis* hyp);
  static bool GetToUseLibrary(const HYBRIDPlugin_Hypothesis* hyp);
  void ClearGroupsToRemove();
  
  static bool   DefaultHeightIsRelative() { return false; }
  static double DefaultBoundaryLayersMaxElemAngle() { return 165.0; }
  static bool   DefaultMeshHoles();
  static bool   DefaultToUseLib();
  static bool   DefaultLayersOnAllWrap();
  static bool   DefaultToMakeGroupsOfDomains();
  static double DefaultMaximumMemory();
  static double DefaultInitialMemory();
  static short  DefaultOptimizationLevel();
  static short  DefaultCollisionMode();
  static short  DefaultBoundaryLayersGrowth();
  static short  DefaultElementGeneration();
  static std::string DefaultWorkingDirectory();
  static bool   DefaultKeepFiles();
  static short  DefaultVerboseLevel();
  static bool   DefaultToCreateNewNodes();
  static bool   DefaultToUseBoundaryRecoveryVersion();
  static bool   DefaultToUseFEMCorrection();
  static bool   DefaultToRemoveCentralPoint();
  static bool   DefaultStandardOutputLog();
  static bool   DefaultRemoveLogOnSuccess();
  static double DefaultGradation();
  static bool   DefaultAddMultinormals();
  static bool   DefaultSmoothNormals();
  static short  DefaultNbOfBoundaryLayers();
  static double DefaultHeightFirstLayer();
  static double DefaultBoundaryLayersProgression();
  static double DefaultCoreSize();
  static double DefaultMultinormalsAngle();

  /*!
   * To mesh "holes" in a solid or not. Default is to mesh.
   */
  void SetToMeshHoles(bool toMesh);
  bool GetToMeshHoles(bool checkFreeOption = false) const;

  // Persistence
  virtual std::ostream & SaveTo(std::ostream & save);
  virtual std::istream & LoadFrom(std::istream & load);

  /*!
   * \brief Does nothing
   */
  virtual bool SetParametersByMesh(const SMESH_Mesh* theMesh, const TopoDS_Shape& theShape);

  /*!
   * \brief Sets myToMakeGroupsOfDomains depending on whether theMesh is on shape or not
   */
  virtual bool SetParametersByDefaults(const TDefaults& dflts, const SMESH_Mesh* theMesh=0);

private:

  short            myNbOfBoundaryLayers;
  double           myHeightFirstLayer;
  bool             myHeightIsRelative;
  short            myBoundaryLayersGrowth;
  double           myBoundaryLayersMaxElemAngle;
  double           myBoundaryLayersProgression;

  short            myElementGeneration;
  double           myCoreSize;

  bool             myLayersOnAllWrap;
  std::vector<int> myFacesWithImprinting;
  std::vector<int> myFacesWithSnapping;
  std::vector<int> myFacesWithLayers;

  // advanced (main params before redesign for 9.6.2)
  short            myCollisionMode;
  bool             myAddMultinormals;
  bool             mySmoothNormals;
  double           myMultinormalsAngle;
  double           myGradation;

  std::string      myWorkingDirectory;
  short            myVerboseLevel;
  bool             myLogInStandardOutput;
  bool             myRemoveLogOnSuccess;
  bool             myKeepFiles;

  TOptionValues _option2value, _customOption2value;         // user defined values
  TOptionValues _defaultOptionValues;                       // default values
  TOptionNames  _doubleOptions, _charOptions, _boolOptions; // to find a type of option

  short            myOptimizationLevel;            // missing from plugin
  bool             myToMakeGroupsOfDomains;        // missing from plugin

  bool             myToMeshHoles;                  // missing from hybrid
  double           myMaximumMemory;                // missing from hybrid
  double           myInitialMemory;                // missing from hybrid
  bool             myToCreateNewNodes;             // missing from hybrid
  bool             myToUseBoundaryRecoveryVersion; // missing from hybrid
  bool             myToUseFemCorrection;           // missing from hybrid
  bool             myToRemoveCentralPoint;         // missing from hybrid
  bool             myUseLib;


  THYBRIDEnforcedVertexList _enfVertexList;
  THYBRIDEnforcedVertexCoordsValues _enfVertexCoordsSizeList;
  THYBRIDEnforcedVertexEntryValues _enfVertexEntrySizeList;
  // map to get "manual" enf vertex (through the coordinates)
  TCoordsHYBRIDEnforcedVertexMap _coordsEnfVertexMap;
  // map to get "geom" enf vertex (through the geom entries)
  TGeomEntryHYBRIDEnforcedVertexMap _geomEntryEnfVertexMap;
  
  
  THYBRIDEnforcedMeshList _enfMeshList;
  // map to get enf meshes through the entries
  TEntryHYBRIDEnforcedMeshListMap _entryEnfMeshMap;
  TIDSortedNodeGroupMap _enfNodes;
  TIDSortedElemGroupMap _enfEdges;
  TIDSortedElemGroupMap _enfTriangles;
  TID2SizeMap _nodeIDToSizeMap;
  std::map<std::string, TIDSortedElemSet > _entryToElemsMap;
  
  TSetStrings _groupsToRemove;
};


#endif
