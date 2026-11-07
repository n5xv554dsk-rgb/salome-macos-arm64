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
// File    : BLSURFPlugin_Hypothesis.hxx
// Authors : Francis KLOSS (OCC) & Patrick LAUG (INRIA) & Lioka RAZAFINDRAZAKA (CEA)
//           Size maps developement: Nicolas GEIMER (OCC) & Gilles DAVID (EURIWARE)
// ---
//
#ifndef _BLSURFPlugin_Hypothesis_i_HXX_
#define _BLSURFPlugin_Hypothesis_i_HXX_

#include <SALOMEconfig.h>
#include CORBA_SERVER_HEADER(BLSURFPlugin_Algorithm)

#include "SMESH_Hypothesis_i.hxx"
#include "BLSURFPlugin_Hypothesis.hxx"

class SMESH_Gen;
class GEOM_Object;

// BLSURFPlugin parameters hypothesis

class BLSURFPlugin_Hypothesis_i:
  public virtual POA_BLSURFPlugin::BLSURFPlugin_Hypothesis,
  public virtual SMESH_Hypothesis_i
{
public:
  // Constructor
  BLSURFPlugin_Hypothesis_i(PortableServer::POA_ptr thePOA,
                            ::SMESH_Gen*            theGenImpl,
                            bool                    theHasGEOM);
  // Destructor
  virtual ~BLSURFPlugin_Hypothesis_i();

  char* GetMeshGemsVersion();

  void SetPhysicalMesh(CORBA::Long theValue);
  CORBA::Long GetPhysicalMesh();

  void SetGeometricMesh(CORBA::Long theValue);
  CORBA::Long GetGeometricMesh();

  void SetPhySize(CORBA::Double theValue);
  void SetPhySizeRel(CORBA::Double theValue);
  CORBA::Double GetPhySize();
  CORBA::Boolean IsPhySizeRel();

  void SetMinSize(CORBA::Double theMinSize);
  void SetMinSizeRel(CORBA::Double theMinSize);
  CORBA::Double GetMinSize();
  CORBA::Boolean IsMinSizeRel();

  void SetMaxSize(CORBA::Double theMaxSize);
  void SetMaxSizeRel(CORBA::Double theMaxSize);
  CORBA::Double GetMaxSize();
  CORBA::Boolean IsMaxSizeRel();

  void SetUseGradation(CORBA::Boolean theValue);
  CORBA::Boolean GetUseGradation();
  void SetGradation(CORBA::Double theValue);
  CORBA::Double GetGradation();

  void SetUseVolumeGradation(CORBA::Boolean theValue);
  CORBA::Boolean GetUseVolumeGradation();
  void SetVolumeGradation(CORBA::Double theValue);
  CORBA::Double GetVolumeGradation();

  void SetQuadAllowed(CORBA::Boolean theValue);

  void SetElementType(CORBA::Long theValue);
  CORBA::Long GetElementType();

  void SetAngleMesh(CORBA::Double theValue);
  CORBA::Double GetAngleMesh();

  void SetChordalError(CORBA::Double distance);
  CORBA::Double GetChordalError();

  void SetAnisotropic(CORBA::Boolean anisotropic);
  CORBA::Boolean GetAnisotropic();

  void SetAnisotropicRatio(CORBA::Double ratio);
  CORBA::Double GetAnisotropicRatio();

  void SetRemoveTinyEdges(CORBA::Boolean remove);
  CORBA::Boolean GetRemoveTinyEdges();

  void SetTinyEdgeLength(CORBA::Double length);
  CORBA::Double GetTinyEdgeLength();

  void SetOptimiseTinyEdges(CORBA::Boolean toOptimise);
  CORBA::Boolean GetOptimiseTinyEdges();

  void SetTinyEdgeOptimisationLength(CORBA::Double length);
  CORBA::Double GetTinyEdgeOptimisationLength();

  void SetCorrectSurfaceIntersection(CORBA::Boolean toOptimise);
  CORBA::Boolean GetCorrectSurfaceIntersection();

  void SetCorrectSurfaceIntersectionMaxCost(CORBA::Double maxCost);
  CORBA::Double GetCorrectSurfaceIntersectionMaxCost();

  void SetBadElementRemoval(CORBA::Boolean remove);
  CORBA::Boolean GetBadElementRemoval();

  void SetBadElementAspectRatio(CORBA::Double ratio);
  CORBA::Double GetBadElementAspectRatio();

  void SetOptimizeMesh(CORBA::Boolean optimize);
  CORBA::Boolean GetOptimizeMesh();

  void SetQuadraticMesh(CORBA::Boolean quadratic);
  CORBA::Boolean GetQuadraticMesh();

  void SetTopology(CORBA::Long theValue);
  CORBA::Long GetTopology();


  /*!
   *  Activate/deactivate surface proximity computation
   */
  void SetSurfaceProximity( CORBA::Boolean toUse );
  CORBA::Boolean GetSurfaceProximity();

  /*!
   * Set number of surface element layers to be generated due to surface proximity
   */
  void SetNbSurfaceProximityLayers( CORBA::Short nbLayers );
  CORBA::Short GetNbSurfaceProximityLayers();

  /*!
   * Set coefficient by which size of element refined due to surface proximity is increased
   */
  void SetSurfaceProximityRatio( CORBA::Double ratio );
  CORBA::Double GetSurfaceProximityRatio();

  /*!
   *  Activate/deactivate volume proximity computation
   */
  void SetVolumeProximity( CORBA::Boolean toUse );
  CORBA::Boolean GetVolumeProximity();

  /*!
   * Set number of surface element layers to be generated due to volume proximity
   */
  void SetNbVolumeProximityLayers( CORBA::Short nbLayers );
  CORBA::Short GetNbVolumeProximityLayers();

  /*!
   * Set coefficient by which size of element refined due to volume proximity is increased
   */
  void SetVolumeProximityRatio( CORBA::Double ratio );
  CORBA::Double GetVolumeProximityRatio();


  void SetVerbosity(CORBA::Short theVal);
  CORBA::Short GetVerbosity();

  /*!
   * Set/Get enforced 1D meshes
   */
  void SetEnforcedMeshes( const BLSURFPlugin::EnforcedMeshesList& enforcedMeshes );
  BLSURFPlugin::EnforcedMeshesList* GetEnforcedMeshes();

  void SetEnforceCadEdgesSize( CORBA::Boolean toEnforce );
  CORBA::Boolean GetEnforceCadEdgesSize();

  void SetJacobianRectificationRespectGeometry( CORBA::Boolean allowRectification );
  CORBA::Boolean GetJacobianRectificationRespectGeometry();

  void SetUseDeprecatedPatchMesher( CORBA::Boolean useDeprecatedPatchMesher );
  CORBA::Boolean GetUseDeprecatedPatchMesher();

  void SetJacobianRectification( CORBA::Boolean allowRectification );
  CORBA::Boolean GetJacobianRectification();

  void SetMaxNumberOfPointsPerPatch( CORBA::Long nb );
  CORBA::Long GetMaxNumberOfPointsPerPatch();

  void SetMaxNumberOfThreads( CORBA::Long nb );
  CORBA::Long GetMaxNumberOfThreads();

  void SetRespectGeometry( CORBA::Boolean toRespect );
  CORBA::Boolean GetRespectGeometry();

  void SetTinyEdgesAvoidSurfaceIntersections( CORBA::Boolean toAvoidIntersection );
  CORBA::Boolean GetTinyEdgesAvoidSurfaceIntersections();

  void SetClosedGeometry( CORBA::Boolean isClosed );
  CORBA::Boolean GetClosedGeometry();

  void SetDebug( CORBA::Boolean isDebug );
  bool GetDebug();

  void SetPeriodicTolerance( CORBA::Double tol );
  double GetPeriodicTolerance();

  void SetRequiredEntities( const char* howToTreat );
  char* GetRequiredEntities();

  void SetSewingTolerance( CORBA::Double tol );
  CORBA::Double GetSewingTolerance();

  void SetTags( const char* howToTreat );
  char* GetTags();

  void SetHyperPatches(const BLSURFPlugin::THyperPatchList& hpl);
  BLSURFPlugin::THyperPatchList* GetHyperPatches( GEOM::GEOM_Object_ptr mainShape );
  void SetHyperPatchShapes(const BLSURFPlugin::THyperPatchShapesList& hpsl);
  BLSURFPlugin::THyperPatchEntriesList* GetHyperPatchShapes();
  void SetHyperPatchEntries(const BLSURFPlugin::THyperPatchEntriesList& hpel);

  void SetPreCADMergeEdges(CORBA::Boolean theValue);
  CORBA::Boolean GetPreCADMergeEdges();

  void SetPreCADRemoveDuplicateCADFaces(CORBA::Boolean theValue);
  CORBA::Boolean GetPreCADRemoveDuplicateCADFaces();

  void SetPreCADProcess3DTopology(CORBA::Boolean theValue);
  CORBA::Boolean GetPreCADProcess3DTopology();

  void SetPreCADDiscardInput(CORBA::Boolean theValue);
  CORBA::Boolean GetPreCADDiscardInput();

  void SetOptionValue(const char* optionName, const char* optionValue);
  void SetPreCADOptionValue(const char* optionName, const char* optionValue);
  char* GetOptionValue(const char* optionName);
  char* GetPreCADOptionValue(const char* optionName);

  void UnsetOption(const char* optionName);
  void UnsetPreCADOption(const char* optionName);

  BLSURFPlugin::string_array* GetOptionValues();
  BLSURFPlugin::string_array* GetPreCADOptionValues();
  BLSURFPlugin::string_array* GetAdvancedOptionValues();

  void SetOptionValues(const BLSURFPlugin::string_array& options);
  void SetPreCADOptionValues(const BLSURFPlugin::string_array& options);
  void SetAdvancedOptionValues(const BLSURFPlugin::string_array& options);
  void SetAdvancedOption(const char* optionsAndValues);

  void AddOption(const char* optionName, const char* optionValue);
  void AddPreCADOption(const char* optionName, const char* optionValue);
  char* GetOption(const char* optionName);
  char* GetPreCADOption(const char* optionName);

  void SetSizeMapEntry(const char* entry, const char* sizeMap);

  void SetConstantSizeMapEntry(const char* entry, GEOM::shape_type shapeType, CORBA::Double sizeMap);

  char* GetSizeMapEntry(const char* entry);

  void UnsetEntry(const char* entry);

  BLSURFPlugin::string_array* GetSizeMapEntries();

  void SetSizeMapEntries(const BLSURFPlugin::string_array& sizeMaps);

  void SetSizeMap(GEOM::GEOM_Object_ptr GeomObj, const char* sizeMap);

  void SetConstantSizeMap(GEOM::GEOM_Object_ptr GeomObj, CORBA::Double sizeMap);

  void UnsetSizeMap(GEOM::GEOM_Object_ptr GeomObj);

  void ClearSizeMaps();

  void SetAttractor(GEOM::GEOM_Object_ptr GeomObj, const char* attractor);

  void UnsetAttractor(GEOM::GEOM_Object_ptr GeomObj);

  void SetAttractorEntry(const char* entry, const char* attractor);

  char* GetAttractorEntry(const char* entry);

  BLSURFPlugin::string_array* GetAttractorEntries();
  
  
  /*!
    * Set/get/unset an attractor on a face 
    */
  
  void SetAttractorGeom(GEOM::GEOM_Object_ptr GeomObj, GEOM::GEOM_Object_ptr Attractor, CORBA::Double StartSize, CORBA::Double EndSize, CORBA::Double ActionRadius, CORBA::Double ConstantRadius );

  void UnsetAttractorGeom(GEOM::GEOM_Object_ptr GeomObj,
                          GEOM::GEOM_Object_ptr theAttractor);

  void UnsetAttractorEntry(const char* entry, const char* attractor);
  void SetClassAttractorEntry(const char* entry, const char* att_entry, CORBA::Double StartSize, CORBA::Double EndSize, CORBA::Double ActionRadius, CORBA::Double ConstantRadius);

  BLSURFPlugin::TAttParamsMap* GetAttractorParams();
  

  /*
   void SetCustomSizeMap(GEOM::GEOM_Object_ptr GeomObj, const char* sizeMap);

   void UnsetCustomSizeMap(GEOM::GEOM_Object_ptr GeomObj);

   void SetCustomSizeMapEntry(const char* entry,const char* sizeMap );

   char* GetCustomSizeMapEntry(const char* entry);

   BLSURFPlugin::string_array* GetCustomSizeMapEntries();
   */

  ///////////////////////
  // ENFORCED VERTEXES //
  ///////////////////////

  BLSURFPlugin::TFaceEntryEnfVertexListMap* GetAllEnforcedVerticesByFace();
  BLSURFPlugin::TEnfVertexList* GetAllEnforcedVertices();

  BLSURFPlugin::TFaceEntryCoordsListMap* GetAllCoordsByFace();
  BLSURFPlugin::TCoordsEnfVertexMap* GetAllEnforcedVerticesByCoords();

  BLSURFPlugin::TFaceEntryEnfVertexEntryListMap* GetAllEnfVertexEntriesByFace();
  BLSURFPlugin::TEnfVertexEntryEnfVertexMap* GetAllEnforcedVerticesByEnfVertexEntry();

  void ClearAllEnforcedVertices();

  /*!
   * Set/get/unset an enforced vertex on geom object
   */
  // OBSOLETE
  bool SetEnforcedVertex(GEOM::GEOM_Object_ptr theFace, CORBA::Double x, CORBA::Double y, CORBA::Double z);
  bool SetEnforcedVertexNamed(GEOM::GEOM_Object_ptr theFace, CORBA::Double x, CORBA::Double y, CORBA::Double z, const char* theVertexName);
  bool SetEnforcedVertexGeom(GEOM::GEOM_Object_ptr theFace, GEOM::GEOM_Object_ptr theVertex);
  bool SetEnforcedVertexWithGroup(GEOM::GEOM_Object_ptr theFace, CORBA::Double x, CORBA::Double y, CORBA::Double z, const char* theGroupName);
  bool SetEnforcedVertexNamedWithGroup(GEOM::GEOM_Object_ptr theFace, CORBA::Double x, CORBA::Double y, CORBA::Double z, const char* theVertexName, const char* theGroupName);
  bool SetEnforcedVertexGeomWithGroup(GEOM::GEOM_Object_ptr theFace, GEOM::GEOM_Object_ptr theVertex, const char* theGroupName);

  BLSURFPlugin::TEnfVertexList* GetEnforcedVertices(GEOM::GEOM_Object_ptr theFace);

  bool UnsetEnforcedVertex(GEOM::GEOM_Object_ptr theFace, CORBA::Double x, CORBA::Double y, CORBA::Double z);
  bool UnsetEnforcedVertexGeom(GEOM::GEOM_Object_ptr theFace, GEOM::GEOM_Object_ptr theVertex);
  bool UnsetEnforcedVertices(GEOM::GEOM_Object_ptr theFace);

  // NEW - no face
  bool AddEnforcedVertex(CORBA::Double x, CORBA::Double y, CORBA::Double z);
  bool AddEnforcedVertexNamed(CORBA::Double x, CORBA::Double y, CORBA::Double z, const char* theVertexName);
  bool AddEnforcedVertexGeom(GEOM::GEOM_Object_ptr theVertex);
  bool AddEnforcedVertexWithGroup(CORBA::Double x, CORBA::Double y, CORBA::Double z, const char* theGroupName);
  bool AddEnforcedVertexNamedWithGroup(CORBA::Double x, CORBA::Double y, CORBA::Double z, const char* theVertexName, const char* theGroupName);
  bool AddEnforcedVertexGeomWithGroup(GEOM::GEOM_Object_ptr theVertex, const char* theGroupName);

  bool RemoveEnforcedVertex(CORBA::Double x, CORBA::Double y, CORBA::Double z);
  bool RemoveEnforcedVertexGeom(GEOM::GEOM_Object_ptr theVertex);
  bool RemoveEnforcedVertices();

  /*!
   * Set/get/unset an enforced vertex on geom object given by entry
   */
  bool SetEnforcedVertexEntry(const char* theFaceEntry, CORBA::Double x = 0, CORBA::Double y = 0, CORBA::Double z = 0,
      const char* theVertexName = "", const char* theVertexEntry = "", const char* theGroupName = "");

  BLSURFPlugin::TEnfVertexList* GetEnforcedVerticesEntry(const char* theFaceEntry);

  bool UnsetEnforcedVertexEntry(const char* theFaceEntry, CORBA::Double x, CORBA::Double y, CORBA::Double z,
      const char* theVertexEntry = "");
  bool UnsetEnforcedVerticesEntry(const char* theFaceEntry);

  /*!
   * To add internal vertices as enforced vertices
   */
  void SetInternalEnforcedVertexAllFaces(CORBA::Boolean toEnforceInternalVertices);
  CORBA::Boolean GetInternalEnforcedVertexAllFaces();
  void SetInternalEnforcedVertexAllFacesGroup(const char*  groupName = "");
  char* GetInternalEnforcedVertexAllFacesGroup();

// Enable internal enforced vertices on specific face if requested by user
//  void SetInternalEnforcedVertex(GEOM::GEOM_Object_ptr theFace, CORBA::Boolean toEnforceInternalVertices);
//  void SetInternalEnforcedVertexWithGroup(GEOM::GEOM_Object_ptr theFace, CORBA::Boolean toEnforceInternalVertices, const char* theGroupName = "");
//  void SetInternalEnforcedVertexEntry(const char* theFaceEntry, CORBA::Boolean toEnforceInternalVertices, const char* theGroupName = "");
//  CORBA::Boolean GetInternalEnforcedVertex(GEOM::GEOM_Object_ptr theFace);
//  CORBA::Boolean GetInternalEnforcedVertexEntry(const char* theFaceEntry);
  
  ///////////////////////
  // PERIODICITY       //
  ///////////////////////

  void ClearPreCadPeriodicityVectors();

  BLSURFPlugin::TPeriodicityList* GetPreCadFacesPeriodicityVector();
  BLSURFPlugin::TPeriodicityList* GetPreCadEdgesPeriodicityVector();

  BLSURFPlugin::TPeriodicityList* PreCadVectorToSequence(const ::BLSURFPlugin_Hypothesis::TPreCadPeriodicityVector& preCadPeriodicityVector);

  void AddPreCadFacesPeriodicity(GEOM::GEOM_Object_ptr theFace1, GEOM::GEOM_Object_ptr theFace2);

  void AddPreCadFacesPeriodicityWithVertices(GEOM::GEOM_Object_ptr theFace1, GEOM::GEOM_Object_ptr theFace2,
      const GEOM::ListOfGO& theSourceVertices, const GEOM::ListOfGO& theTargetVertices);

  void AddPreCadFacesPeriodicityEntry(const char* theFace1Entry, const char* theFace2Entry,
      const BLSURFPlugin::TEntryList& theSourceVerticesEntries, const BLSURFPlugin::TEntryList& theTargetVerticesEntries);

  void AddPreCadEdgesPeriodicity(GEOM::GEOM_Object_ptr theEdge1, GEOM::GEOM_Object_ptr theEdge2);

  void AddPreCadEdgesPeriodicityWithVertices(GEOM::GEOM_Object_ptr theEdge1, GEOM::GEOM_Object_ptr theEdge2,
      const GEOM::ListOfGO& theSourceVertices, const GEOM::ListOfGO& theTargetVertices);

  void AddPreCadEdgesPeriodicityEntry(const char* theEdge1Entry, const char* theEdge2Entry,
      const BLSURFPlugin::TEntryList& theSourceVerticesEntries, const BLSURFPlugin::TEntryList& theTargetVerticesEntries);

  ///////////////////////
  
  /*!
    * Sets the file for export resulting mesh in GMF format
    */
//   void SetGMFFile(const char* theFileName, CORBA::Boolean isBinary);
  void SetGMFFile(const char* theFileName);
  char* GetGMFFile();
//   CORBA::Boolean GetGMFFileMode();

  // Get implementation
  ::BLSURFPlugin_Hypothesis* GetImpl();

  // Verify whether hypothesis supports given entity type 
  CORBA::Boolean IsDimSupported(SMESH::Dimension type);



  // Methods for copying mesh definition to other geometry

  // Return geometry this hypothesis depends on. Return false if there is no geometry parameter
  virtual bool getObjectsDependOn( std::vector< std::string > & entryArray,
                                   std::vector< int >         & subIDArray ) const;

  // Set new geometry instead of that returned by getObjectsDependOn()
  virtual bool setObjectsDependOn( std::vector< std::string > & entryArray,
                                   std::vector< int >         & subIDArray );
private:
  ///////////////////////
  // PERIODICITY       //
  ///////////////////////
  std::string ShapeTypeToString(GEOM::shape_type theShapeType);
  void CheckShapeType(GEOM::GEOM_Object_ptr shape, GEOM::shape_type theShapeType);
  void CheckShapeTypes(GEOM::GEOM_Object_ptr shape, std::vector<GEOM::shape_type> theShapeTypes);
  std::string PublishIfNeeded(GEOM::GEOM_Object_ptr shape, GEOM::shape_type theShapeType, std::string prefix);
  std::string FormatVerticesEntries(std::vector<std::string> &theSourceVerticesEntries, std::vector<std::string> &theTargetVerticesEntries);

};

#endif
