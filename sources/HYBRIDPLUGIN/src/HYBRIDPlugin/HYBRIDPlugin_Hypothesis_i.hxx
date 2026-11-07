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
// File   : HYBRIDPlugin_Hypothesis_i.hxx
// Author : Christian VAN WAMBEKE (CEA)
// ---
//
#ifndef _HYBRIDPlugin_Hypothesis_i_HXX_
#define _HYBRIDPlugin_Hypothesis_i_HXX_

#include "HYBRIDPlugin_Defs.hxx"

#include <SALOMEconfig.h>
#include CORBA_SERVER_HEADER(HYBRIDPlugin_Algorithm)

#include "SMESH_Hypothesis_i.hxx"
#include "SMESH_Mesh_i.hxx"
#include "HYBRIDPlugin_Hypothesis.hxx"

class SMESH_Gen;

// HYBRIDPlugin parameters hypothesis

class HYBRIDPLUGIN_EXPORT HYBRIDPlugin_Hypothesis_i:
  public virtual POA_HYBRIDPlugin::HYBRIDPlugin_Hypothesis,
  public virtual SMESH_Hypothesis_i
{
 public:
  // Constructor
  HYBRIDPlugin_Hypothesis_i (PortableServer::POA_ptr thePOA,
                             ::SMESH_Gen*            theGenImpl);
  // Destructor
  virtual ~HYBRIDPlugin_Hypothesis_i();

  /*!
   * Sizes of boundary layers are relative to the surface size. Default no
   */
  void SetHeightIsRelative( CORBA::Boolean isRelative );
  CORBA::Boolean GetHeightIsRelative();
  /*!
   * Maximum internal angles of boundary elements (in degree)
   */
  void SetBoundaryLayersMaxElemAngle( CORBA::Double angle );
  CORBA::Double GetBoundaryLayersMaxElemAngle();
  /*!
   * To mesh "holes" in a solid or not. Default is to mesh.
   */
  void SetToMeshHoles(CORBA::Boolean toMesh);
  CORBA::Boolean GetToMeshHoles();
  /*!
   * IDs of faces to grow the layers on
   */
  void SetFacesWithLayers(const SMESH::long_array& faceIDs);
  SMESH::long_array* GetFacesWithLayers();
  /*!
   * IDs of faces to imprint the layers on
   */
  void SetFacesWithImprinting(const SMESH::long_array& faceIDs);
  SMESH::long_array* GetFacesWithImprinting();
  /*!
   * IDs of faces to snap the layers on (faces that already have surface layers)
   */
  void SetFacesWithSnapping(const SMESH::long_array& faceIDs);
  SMESH::long_array* GetFacesWithSnapping();
  /*!
   * To call MG-Hybrid by library. Default is no (i.e. by executable)
   */
  void SetToUseLibrary(CORBA::Boolean toUseLib);
  CORBA::Boolean GetToUseLibrary();
  /*!
   * To mesh "layers on all wrap". Default is to mesh.
   */
  void SetLayersOnAllWrap(CORBA::Boolean toMesh);
  CORBA::Boolean GetLayersOnAllWrap();
  /*!
   * To make groups of volumes of different domains when mesh is generated from skin.
   * Default is to make groups.
   * This option works only (1) for the mesh w/o shape and (2) if GetToMeshHoles() == true
   */
  void SetToMakeGroupsOfDomains(CORBA::Boolean toMakeGroups);
  CORBA::Boolean GetToMakeGroupsOfDomains();
  /*!
   * Maximal size of memory to be used by the algorithm (in Megabytes)
   */
  void SetMaximumMemory(CORBA::Double MB);
  CORBA::Double GetMaximumMemory();
  /*!
   * Initial size of memory to be used by the algorithm (in Megabytes) in
   * automatic memory adjustment mode. Default is zero
   */
  void SetInitialMemory(CORBA::Double MB);
  CORBA::Double GetInitialMemory();
  /*!
   * Optimization level: 0-none, 1-light, 2-medium, 3-strong. Default is medium
   */
  void SetOptimizationLevel(CORBA::Short level);
  CORBA::Short GetOptimizationLevel();
  /*!
   * Collision Mode: 0-decrease, 1-stop. Default is decrease
   */
  void SetCollisionMode(CORBA::Short mode);
  CORBA::Short GetCollisionMode();
  /*!
   * Path to working directory
   */
  void SetWorkingDirectory(const char* path);
  char* GetWorkingDirectory();
  /*!
   * To keep working files or remove them. Log file remains in case of errors anyway.
   */
  void SetKeepFiles(CORBA::Boolean toKeep);
  CORBA::Boolean GetKeepFiles();
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
  void SetVerboseLevel(CORBA::Short level);
  CORBA::Short GetVerboseLevel();
  /*!
   * To create new nodes
   */
  void SetToCreateNewNodes(CORBA::Boolean toCreate);
  CORBA::Boolean GetToCreateNewNodes();
  /*!
   * To use boundary recovery version which tries to create mesh on a very poor
   * quality surface mesh
   */
  void SetToUseBoundaryRecoveryVersion(CORBA::Boolean toUse);
  CORBA::Boolean GetToUseBoundaryRecoveryVersion();
  /*!
   * Applies ﬁnite-element correction by replacing overconstrained elements where
   * it is possible. The process is cutting ﬁrst the overconstrained edges and
   * second the overconstrained facets. This insure that no edges have two boundary
   * vertices and that no facets have three boundary vertices.
   */
  void SetFEMCorrection(CORBA::Boolean toUseFem);
  CORBA::Boolean GetFEMCorrection();
  /*!
   * To removes initial central point.
   */
  void SetToRemoveCentralPoint(CORBA::Boolean toRemove);
  CORBA::Boolean GetToRemoveCentralPoint();

  void SetOptionValue(const char* optionName, const char* optionValue);
  char* GetOptionValue(const char* optionName);
  void UnsetOption(const char* optionName);

  HYBRIDPlugin::string_array* GetOptionValues();
  HYBRIDPlugin::string_array* GetAdvancedOptionValues();

  void SetOptionValues(const HYBRIDPlugin::string_array& options);
  void SetAdvancedOptionValues(const HYBRIDPlugin::string_array& options);

  void AddOption(const char* optionName, const char* optionValue);
  char* GetOption(const char* optionName);
  /*!
   * To set hiden/undocumented/advanced options
   */
  void SetAdvancedOption(const char* theOptAndVals );
  char* GetAdvancedOption();
  void SetTextOption(const char* option);
  char* GetTextOption();
  /*!
  * To define the volumic gradation
  */
  void SetGradation(CORBA::Double gradation);
  CORBA::Double GetGradation();
  /*!
  * Print log in standard output
  */
  void SetStandardOutputLog(CORBA::Boolean logInStandardOutput);
  CORBA::Boolean GetStandardOutputLog();
  /*!
  * Remove log file on success
  */
  void SetRemoveLogOnSuccess(CORBA::Boolean removeLogOnSuccess);
  CORBA::Boolean GetRemoveLogOnSuccess();
  
  void SetBoundaryLayersGrowth(CORBA::Short mode);
  CORBA::Short GetBoundaryLayersGrowth();

  void SetElementGeneration(CORBA::Short mode);
  CORBA::Short GetElementGeneration();

  void SetAddMultinormals(CORBA::Boolean toAddMultinormals);
  CORBA::Boolean GetAddMultinormals();

  void SetSmoothNormals(CORBA::Boolean toSmoothNormals);
  CORBA::Boolean GetSmoothNormals();

  void SetHeightFirstLayer(CORBA::Double toHeightFirstLayer);
  CORBA::Double GetHeightFirstLayer();

  void SetBoundaryLayersProgression(CORBA::Double toBoundaryLayersProgression);
  CORBA::Double GetBoundaryLayersProgression();
  
  void SetCoreSize(CORBA::Double toCoreSize);
  CORBA::Double GetCoreSize();

  void SetMultinormalsAngle(CORBA::Double toMultinormalsAngle);
  CORBA::Double GetMultinormalsAngle();
  
  void SetNbOfBoundaryLayers(CORBA::Short toNbOfBoundaryLayers);
  CORBA::Short GetNbOfBoundaryLayers();

  /*!
   * To set an enforced vertex
   */
  bool p_SetEnforcedVertex(CORBA::Double size, CORBA::Double x = 0, CORBA::Double y = 0, CORBA::Double z = 0,
                           const char* theVertexName = "", const char* theVertexEntry = "", const char* theGroupName = "",
                           CORBA::Boolean isCompound = false);
  bool SetEnforcedVertex(CORBA::Double x, CORBA::Double y, CORBA::Double z, CORBA::Double size);
  bool SetEnforcedVertexNamed(CORBA::Double x, CORBA::Double y, CORBA::Double z, CORBA::Double size, const char* theVertexName);
  bool SetEnforcedVertexWithGroup(CORBA::Double x, CORBA::Double y, CORBA::Double z, CORBA::Double size, const char* theGroupName);
  bool SetEnforcedVertexNamedWithGroup(CORBA::Double x, CORBA::Double y, CORBA::Double z, CORBA::Double size, const char* theVertexName, const char* theGroupName);
  bool SetEnforcedVertexGeom(GEOM::GEOM_Object_ptr theVertex, CORBA::Double size);
  bool SetEnforcedVertexGeomWithGroup(GEOM::GEOM_Object_ptr theVertex, CORBA::Double size, const char* theGroupName);
  CORBA::Double GetEnforcedVertex(CORBA::Double x, CORBA::Double y, CORBA::Double z);
  CORBA::Double GetEnforcedVertexGeom(GEOM::GEOM_Object_ptr theVertex);
  bool RemoveEnforcedVertex(CORBA::Double x, CORBA::Double y, CORBA::Double z);
  bool RemoveEnforcedVertexGeom(GEOM::GEOM_Object_ptr theVertex);
  HYBRIDPlugin::HYBRIDEnforcedVertexList* GetEnforcedVertices();
  void ClearEnforcedVertices();
  /*!
   * To set an enforced mesh
   */  
  bool p_SetEnforcedMesh(SMESH::SMESH_IDSource_ptr theSource, SMESH::ElementType elementType, const char* theName="", const char* theGroupName="");
  bool SetEnforcedMesh(SMESH::SMESH_IDSource_ptr theSource, SMESH::ElementType elementType);
  bool SetEnforcedMeshWithGroup(SMESH::SMESH_IDSource_ptr theSource, SMESH::ElementType elementType, const char* theGroupName);

  /* OBSOLETE FUNCTIONS */
  bool SetEnforcedMeshSize(SMESH::SMESH_IDSource_ptr theSource, SMESH::ElementType elementType, double size);
  bool SetEnforcedMeshSizeWithGroup(SMESH::SMESH_IDSource_ptr theSource, SMESH::ElementType elementType, double size, const char* theGroupName);
  /* OBSOLETE FUNCTIONS */

  HYBRIDPlugin::HYBRIDEnforcedMeshList* GetEnforcedMeshes();
  void ClearEnforcedMeshes();

  // Get implementation
  ::HYBRIDPlugin_Hypothesis* GetImpl();

  // Verify whether hypothesis supports given entity type
  CORBA::Boolean IsDimSupported( SMESH::Dimension type );
  
  // Methods for copying mesh definition to other geometry
  virtual bool getObjectsDependOn( std::vector< std::string > & /*entryArray*/,
                                   std::vector< int >         & /*subIDArray*/ ) const { return false; }
  virtual bool setObjectsDependOn( std::vector< std::string > & /*entryArray*/,
                                   std::vector< int >         & /*subIDArray*/ ) { return true; }
};

#endif
