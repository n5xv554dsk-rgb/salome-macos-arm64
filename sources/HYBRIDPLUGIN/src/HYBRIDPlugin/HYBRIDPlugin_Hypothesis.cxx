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

//=============================================================================
// File      : HYBRIDPlugin_Hypothesis.cxx
// Created   : Wed Apr  2 12:36:29 2008
// Author    : Edward AGAPOV (eap)
//=============================================================================
//
#include <clocale>
#include "HYBRIDPlugin_Hypothesis.hxx"

#include <SMESHDS_Mesh.hxx>

#include <TopExp_Explorer.hxx>

#ifdef WIN32
#include <process.h>
#define getpid _getpid
#endif

namespace
{
  struct GET_DEFAULT // struct used to get default value from GetOptionValue()
  {
    bool isDefault;
    operator bool* () { return &isDefault; }
  };
}

//=======================================================================
//function : HYBRIDPlugin_Hypothesis
//=======================================================================

HYBRIDPlugin_Hypothesis::HYBRIDPlugin_Hypothesis(int hypId, SMESH_Gen * gen)
  : SMESH_Hypothesis(hypId, gen),
    myNbOfBoundaryLayers(DefaultNbOfBoundaryLayers()),
    myHeightFirstLayer(DefaultHeightFirstLayer()),
    myHeightIsRelative(DefaultHeightIsRelative()),
    myBoundaryLayersGrowth(DefaultBoundaryLayersGrowth()),
    myBoundaryLayersMaxElemAngle(DefaultBoundaryLayersMaxElemAngle()),
    myBoundaryLayersProgression(DefaultBoundaryLayersProgression()),
    myElementGeneration(DefaultElementGeneration()),
    myCoreSize(DefaultCoreSize()),
    myLayersOnAllWrap(DefaultLayersOnAllWrap()),
    myCollisionMode(DefaultCollisionMode()),
    myAddMultinormals(DefaultAddMultinormals()),
    mySmoothNormals(DefaultSmoothNormals()),
    myMultinormalsAngle(DefaultMultinormalsAngle()),
    myGradation(DefaultGradation()),
    myWorkingDirectory(DefaultWorkingDirectory()),
    myVerboseLevel(DefaultVerboseLevel()),
    myLogInStandardOutput(DefaultStandardOutputLog()),
    myRemoveLogOnSuccess(DefaultRemoveLogOnSuccess()),
    myKeepFiles(DefaultKeepFiles()),
    myOptimizationLevel(DefaultOptimizationLevel()),
    myToMakeGroupsOfDomains(DefaultToMakeGroupsOfDomains()),
    myToMeshHoles(DefaultMeshHoles()),
    myMaximumMemory(-1),
    myInitialMemory(-1),
    myToCreateNewNodes(DefaultToCreateNewNodes()),
    myToUseBoundaryRecoveryVersion(DefaultToUseBoundaryRecoveryVersion()),
    myToUseFemCorrection(DefaultToUseFEMCorrection()),
    myToRemoveCentralPoint(DefaultToRemoveCentralPoint()),
    myUseLib(DefaultToUseLib())
{
  _name = "HYBRID_Parameters";
  _param_algo_dim = 3;

  const char* boolOptionNames[] = { "add_multinormals", // no
                                    "smooth_normals",   // no
                                    "" // mark of end
  };
  const char* intOptionNames[] = { "max_number_of_threads", // 4
                                   "" // mark of end
  };
  const char* doubleOptionNames[] = { //"global_physical_size",  // 0.0 = not set -- myCoreSize
                                      "gradation",    // 2.0
                                      //"boundary_layer_max_element_angle", // 165.0 -- myBoundaryLayersMaxElemAngle
                                      "multinormal_angle_threshold", // 30.0
                                      "" // mark of end
  };
  const char* charOptionNames[] = { "collision_mode",                   // stop/decrease
                                    "" // mark of end
  };

  int i = 0;
  while (boolOptionNames[i][0])
  {
    _boolOptions.insert( boolOptionNames[i] );
    _option2value[boolOptionNames[i++]].clear();
  }
  i = 0;
  while (intOptionNames[i][0])
    _option2value[intOptionNames[i++]].clear();

  i = 0;
  while (doubleOptionNames[i][0]) {
    _doubleOptions.insert(doubleOptionNames[i]);
    _option2value[doubleOptionNames[i++]].clear();
  }
  i = 0;
  while (charOptionNames[i][0]) {
    _charOptions.insert(charOptionNames[i]);
    _option2value[charOptionNames[i++]].clear();
  }

  // default values to be used while MG meshing

  _defaultOptionValues["add_multinormals"                ] = "no";
  _defaultOptionValues["smooth_normals"                  ] = "no";
  _defaultOptionValues["max_number_of_threads"           ] = "4";
  //_defaultOptionValues["global_physical_size"            ] = "0";
  _defaultOptionValues["gradation"                       ] = "2";
  //_defaultOptionValues["boundary_layer_max_element_angle"] = "165";
  _defaultOptionValues["multinormal_angle_threshold"     ] = "30";
  _defaultOptionValues["collision_mode"                  ] = "stop";

#ifdef _DEBUG_
  // check validity of option names of _defaultOptionValues
  TOptionValues::iterator n2v = _defaultOptionValues.begin();
  for ( ; n2v != _defaultOptionValues.end(); ++n2v )
    ASSERT( _option2value.count( n2v->first ));
  ASSERT( _option2value.size() == _defaultOptionValues.size() );
#endif
}

//=======================================================================
//function : SetHeightIsRelative
//=======================================================================

void HYBRIDPlugin_Hypothesis::SetHeightIsRelative(bool isRelative)
{
  if ( myHeightIsRelative != isRelative ) {
    myHeightIsRelative = isRelative;
    NotifySubMeshesHypothesisModification();
  }
}

//=======================================================================
//function : SetBoundaryLayersMaxElemAngle
//=======================================================================

void HYBRIDPlugin_Hypothesis::SetBoundaryLayersMaxElemAngle( double angle )
{
  if ( myBoundaryLayersMaxElemAngle != angle ) {
    myBoundaryLayersMaxElemAngle = angle;
    NotifySubMeshesHypothesisModification();
  }
}

//=======================================================================
//function : SetToUseLibrary
//=======================================================================

void HYBRIDPlugin_Hypothesis::SetToUseLibrary(bool toUseLib)
{
  if ( myUseLib != toUseLib ) {
    myUseLib = toUseLib;
    NotifySubMeshesHypothesisModification();
  }
}

//=======================================================================
//function : GetToUseLibrary
//=======================================================================

bool HYBRIDPlugin_Hypothesis::GetToUseLibrary() const
{
  return myUseLib;
}

//=======================================================================
//function : GetToUseLibrary
//=======================================================================

bool HYBRIDPlugin_Hypothesis::GetToUseLibrary(const HYBRIDPlugin_Hypothesis* hyp)
{
  bool res;
  if ( hyp )
    res = hyp->GetToUseLibrary();
  else
    res = DefaultToUseLib();
  return res;
}


//=======================================================================
//function : SetLayersOnAllWrap
//=======================================================================

void HYBRIDPlugin_Hypothesis::SetLayersOnAllWrap(bool toMesh)
{
  if ( myLayersOnAllWrap != toMesh ) {
    myLayersOnAllWrap = toMesh;
    NotifySubMeshesHypothesisModification();
  }
}

//=======================================================================
//function : GetLayersOnAllWrap
//=======================================================================

bool HYBRIDPlugin_Hypothesis::GetLayersOnAllWrap(bool /*checkFreeOption*/) const
{
  return myLayersOnAllWrap;
}

//=======================================================================
//function : SetFacesWithLayers
//purpose  : Set IDs of faces to grow the layers on
//=======================================================================

bool HYBRIDPlugin_Hypothesis::SetFacesWithLayers(const std::vector<int>& theVal)
{
  if ( myFacesWithLayers != theVal )
  {
    myFacesWithLayers = theVal;
    NotifySubMeshesHypothesisModification();
    return true;
  }
  return false;
}

//=======================================================================
//function : GetFacesWithLayers
//purpose  : Return IDs of faces to grow the layers on
//=======================================================================

const std::vector<int>& HYBRIDPlugin_Hypothesis::GetFacesWithLayers() const
{
  return myFacesWithLayers;
}

//=======================================================================
//function : SetFacesWithImprinting
//purpose  : Set IDs of faces to grow the layers on
//=======================================================================

bool HYBRIDPlugin_Hypothesis::SetFacesWithImprinting(const std::vector<int>& theVal)
{
  if ( myFacesWithImprinting != theVal )
  {
    myFacesWithImprinting = theVal;
    NotifySubMeshesHypothesisModification();
    return true;
  }
  return false;
}

//=======================================================================
//function : GetFacesWithImprinting
//purpose  : Return IDs of faces to grow the layers on
//=======================================================================

const std::vector<int>& HYBRIDPlugin_Hypothesis::GetFacesWithImprinting() const
{
  return myFacesWithImprinting;
}

//=======================================================================
//function : SetFacesWithSnapping
//purpose  : Set IDs of faces that already have surface layers
//=======================================================================

bool HYBRIDPlugin_Hypothesis::SetFacesWithSnapping(const std::vector<int>& theVal)
{
  if ( myFacesWithSnapping != theVal )
  {
    myFacesWithSnapping = theVal;
    NotifySubMeshesHypothesisModification();
    return true;
  }
  return false;
}

//=======================================================================
//function : GetFacesWithSnapping
//purpose  : Return IDs of faces that already have surface layers
//=======================================================================

const std::vector<int>& HYBRIDPlugin_Hypothesis::GetFacesWithSnapping() const
{
  return myFacesWithSnapping;
}

//=======================================================================
//function : SetToMeshHoles
//=======================================================================

void HYBRIDPlugin_Hypothesis::SetToMeshHoles(bool toMesh)
{
  if ( myToMeshHoles != toMesh ) {
    myToMeshHoles = toMesh;
    NotifySubMeshesHypothesisModification();
  }
}

//=======================================================================
//function : GetToMeshHoles
//=======================================================================

bool HYBRIDPlugin_Hypothesis::GetToMeshHoles(bool /*checkFreeOption*/) const
{
  return myToMeshHoles;
}

//=======================================================================
//function : SetToMakeGroupsOfDomains
//=======================================================================

void HYBRIDPlugin_Hypothesis::SetToMakeGroupsOfDomains(bool toMakeGroups)
{
  if ( myToMakeGroupsOfDomains != toMakeGroups ) {
    myToMakeGroupsOfDomains = toMakeGroups;
    NotifySubMeshesHypothesisModification();
  }
}

//=======================================================================
//function : GetToMakeGroupsOfDomains
//=======================================================================

bool HYBRIDPlugin_Hypothesis::GetToMakeGroupsOfDomains() const
{
  return myToMakeGroupsOfDomains;
}

//=======================================================================
//function : GetToMakeGroupsOfDomains
//=======================================================================

bool HYBRIDPlugin_Hypothesis::GetToMakeGroupsOfDomains(const HYBRIDPlugin_Hypothesis* hyp)
{
  bool res;
  if ( hyp ) res = /*hyp->GetToMeshHoles(true) &&*/ hyp->GetToMakeGroupsOfDomains();
  else       res = /*DefaultMeshHoles()        &&*/ DefaultToMakeGroupsOfDomains();
  return res;
}

//=======================================================================
//function : SetMaximumMemory
//=======================================================================

void HYBRIDPlugin_Hypothesis::SetMaximumMemory(double MB)
{
  if ( myMaximumMemory != MB ) {
    myMaximumMemory = MB;
    NotifySubMeshesHypothesisModification();
  }
}

//=======================================================================
//function : GetMaximumMemory
//           * automatic memory adjustment mode. Default is zero
//=======================================================================

double HYBRIDPlugin_Hypothesis::GetMaximumMemory() const
{
  return myMaximumMemory;
}

//=======================================================================
//function : SetInitialMemory
//=======================================================================

void HYBRIDPlugin_Hypothesis::SetInitialMemory(double MB)
{
  if ( myInitialMemory != MB ) {
    myInitialMemory = MB;
    NotifySubMeshesHypothesisModification();
  }
}

//=======================================================================
//function : GetInitialMemory
//=======================================================================

double HYBRIDPlugin_Hypothesis::GetInitialMemory() const
{
  return myInitialMemory;
}

//=======================================================================
//function : SetOptimizationLevel
//=======================================================================

void HYBRIDPlugin_Hypothesis::SetOptimizationLevel(OptimizationLevel level)
{
  if ( myOptimizationLevel != level ) {
    myOptimizationLevel = level;
    NotifySubMeshesHypothesisModification();
  }
}

//=======================================================================
//function : GetOptimizationLevel
//=======================================================================
HYBRIDPlugin_Hypothesis::OptimizationLevel HYBRIDPlugin_Hypothesis::GetOptimizationLevel() const
{
  return (OptimizationLevel) myOptimizationLevel;
}

//=======================================================================
//function : SetCollisionMode
//=======================================================================
void HYBRIDPlugin_Hypothesis::SetCollisionMode(CollisionMode mode)
{
  SetOptionValue( "collision_mode", mode == Decrease ? "decrease" : "stop" );
  myCollisionMode = mode;
}

//=======================================================================
//function : GetCollisionMode
//=======================================================================
HYBRIDPlugin_Hypothesis::CollisionMode HYBRIDPlugin_Hypothesis::GetCollisionMode() const
{
  return (CollisionMode) myCollisionMode;
}

//=======================================================================
//function : SetBoundaryLayersGrowth
//=======================================================================
void HYBRIDPlugin_Hypothesis::SetBoundaryLayersGrowth(BoundaryLayersGrowth mode)
{
  if ( myBoundaryLayersGrowth != mode ) {
    myBoundaryLayersGrowth = mode;
    NotifySubMeshesHypothesisModification();
  }
}

//=======================================================================
//function : GetBoundaryLayersGrowth
//=======================================================================
HYBRIDPlugin_Hypothesis::BoundaryLayersGrowth HYBRIDPlugin_Hypothesis::GetBoundaryLayersGrowth() const
{
  return (BoundaryLayersGrowth) myBoundaryLayersGrowth;
}

//=======================================================================
//function : SetElementGeneration
//=======================================================================
void HYBRIDPlugin_Hypothesis::SetElementGeneration(ElementGeneration mode)
{
  if ( myElementGeneration != mode ) {
    myElementGeneration = mode;
    NotifySubMeshesHypothesisModification();
  }
}

//=======================================================================
//function : GetElementGeneration
//=======================================================================
HYBRIDPlugin_Hypothesis::ElementGeneration HYBRIDPlugin_Hypothesis::GetElementGeneration() const
{
  return (ElementGeneration) myElementGeneration;
}

//=======================================================================
//function : SetAddMultinormals
//=======================================================================
void HYBRIDPlugin_Hypothesis::SetAddMultinormals(bool toAddMultinormals)
{
  SetOptionValue( "add_multinormals", toAddMultinormals ? "yes" : "no" );
  myAddMultinormals = toAddMultinormals;
}

//=======================================================================
//function : GetAddMultinormals
//=======================================================================

bool HYBRIDPlugin_Hypothesis::GetAddMultinormals() const
{
  return myAddMultinormals;
}

//=======================================================================
//function : SetSmoothNormals
//=======================================================================

void HYBRIDPlugin_Hypothesis::SetSmoothNormals(bool toSmoothNormals)
{
  SetOptionValue( "smooth_normals", toSmoothNormals ? "yes" : "no" );
  mySmoothNormals = toSmoothNormals;
}

//=======================================================================
//function : GetSmoothNormals
//=======================================================================

bool HYBRIDPlugin_Hypothesis::GetSmoothNormals() const
{
  return mySmoothNormals;
}

//=======================================================================
//function : SetHeightFirstLayer
//=======================================================================

void HYBRIDPlugin_Hypothesis::SetHeightFirstLayer(double toHeightFirstLayer)
{
  if ( myHeightFirstLayer != toHeightFirstLayer ) {
    myHeightFirstLayer = toHeightFirstLayer;
    NotifySubMeshesHypothesisModification();
  }
}

//=======================================================================
//function : GetHeightFirstLayer
//=======================================================================

double HYBRIDPlugin_Hypothesis::GetHeightFirstLayer() const
{
  return myHeightFirstLayer;
}

//=======================================================================
//function : SetBoundaryLayersProgression
//=======================================================================

void HYBRIDPlugin_Hypothesis::SetBoundaryLayersProgression(double toBoundaryLayersProgression)
{
  if ( myBoundaryLayersProgression != toBoundaryLayersProgression ) {
    myBoundaryLayersProgression = toBoundaryLayersProgression;
    NotifySubMeshesHypothesisModification();
  }
}

//=======================================================================
//function : GetBoundaryLayersProgression
//=======================================================================

double HYBRIDPlugin_Hypothesis::GetBoundaryLayersProgression() const
{
  return myBoundaryLayersProgression;
}

//=======================================================================
//function : SetCoreSize
//=======================================================================

void HYBRIDPlugin_Hypothesis::SetCoreSize(double toCoreSize)
{
  if ( myCoreSize != toCoreSize ) {
    myCoreSize = toCoreSize;
    NotifySubMeshesHypothesisModification();
  }
}

//=======================================================================
//function : GetCoreSize
//=======================================================================

double HYBRIDPlugin_Hypothesis::GetCoreSize() const
{
  return myCoreSize;
}

//=======================================================================
//function : SetMultinormalsAngle
//=======================================================================

void HYBRIDPlugin_Hypothesis::SetMultinormalsAngle(double toMultinormalsAngle)
{
  SetOptionValue( "multinormal_angle_threshold", SMESH_Comment( toMultinormalsAngle ));
  myMultinormalsAngle = toMultinormalsAngle;
}

//=======================================================================
//function : GetMultinormalsAngle
//=======================================================================

double HYBRIDPlugin_Hypothesis::GetMultinormalsAngle() const
{
  return myMultinormalsAngle;
}

//=======================================================================
//function : SetNbOfBoundaryLayers
//=======================================================================

void HYBRIDPlugin_Hypothesis::SetNbOfBoundaryLayers(short toNbOfBoundaryLayers)
{
  if ( myNbOfBoundaryLayers != toNbOfBoundaryLayers ) {
    myNbOfBoundaryLayers = toNbOfBoundaryLayers;
    NotifySubMeshesHypothesisModification();
  }
}

//=======================================================================
//function : GetCoreSize
//=======================================================================

short HYBRIDPlugin_Hypothesis::GetNbOfBoundaryLayers() const
{
  return myNbOfBoundaryLayers;
}


/////////////////////////////////////////////////////////////////////////


//=======================================================================
//function : SetWorkingDirectory
//=======================================================================

void HYBRIDPlugin_Hypothesis::SetWorkingDirectory(const std::string& path)
{
  if ( myWorkingDirectory != path ) {
    myWorkingDirectory = path;
    NotifySubMeshesHypothesisModification();
  }
}

//=======================================================================
//function : GetWorkingDirectory
//=======================================================================

std::string HYBRIDPlugin_Hypothesis::GetWorkingDirectory() const
{
  return myWorkingDirectory;
}

//=======================================================================
//function : SetKeepFiles
//=======================================================================

void HYBRIDPlugin_Hypothesis::SetKeepFiles(bool toKeep)
{
  if ( myKeepFiles != toKeep ) {
    myKeepFiles = toKeep;
    NotifySubMeshesHypothesisModification();
  }
}

//=======================================================================
//function : GetKeepFiles
//=======================================================================

bool HYBRIDPlugin_Hypothesis::GetKeepFiles() const
{
  return myKeepFiles;
}

//=======================================================================
//function : SetVerboseLevel
//=======================================================================

void HYBRIDPlugin_Hypothesis::SetVerboseLevel(short level)
{
  if ( myVerboseLevel != level ) {
    myVerboseLevel = level;
    NotifySubMeshesHypothesisModification();
  }
}

//=======================================================================
//function : GetVerboseLevel
//=======================================================================

short HYBRIDPlugin_Hypothesis::GetVerboseLevel() const
{
  return myVerboseLevel;
}

//=======================================================================
//function : SetToCreateNewNodes
//=======================================================================

void HYBRIDPlugin_Hypothesis::SetToCreateNewNodes(bool toCreate)
{
  if ( myToCreateNewNodes != toCreate ) {
    myToCreateNewNodes = toCreate;
    NotifySubMeshesHypothesisModification();
  }
}

//=======================================================================
//function : GetToCreateNewNodes
//=======================================================================

bool HYBRIDPlugin_Hypothesis::GetToCreateNewNodes() const
{
  return myToCreateNewNodes;
}

//=======================================================================
//function : SetToUseBoundaryRecoveryVersion
//=======================================================================

void HYBRIDPlugin_Hypothesis::SetToUseBoundaryRecoveryVersion(bool toUse)
{
  if ( myToUseBoundaryRecoveryVersion != toUse ) {
    myToUseBoundaryRecoveryVersion = toUse;
    NotifySubMeshesHypothesisModification();
  }
}

//=======================================================================
//function : GetToUseBoundaryRecoveryVersion
//=======================================================================

bool HYBRIDPlugin_Hypothesis::GetToUseBoundaryRecoveryVersion() const
{
  return myToUseBoundaryRecoveryVersion;
}

//=======================================================================
//function : SetFEMCorrection
//=======================================================================

void HYBRIDPlugin_Hypothesis::SetFEMCorrection(bool toUseFem)
{
  if ( myToUseFemCorrection != toUseFem ) {
    myToUseFemCorrection = toUseFem;
    NotifySubMeshesHypothesisModification();
  }
}

//=======================================================================
//function : GetFEMCorrection
//=======================================================================

bool HYBRIDPlugin_Hypothesis::GetFEMCorrection() const
{
  return myToUseFemCorrection;
}

//=======================================================================
//function : SetToRemoveCentralPoint
//=======================================================================

void HYBRIDPlugin_Hypothesis::SetToRemoveCentralPoint(bool toRemove)
{
  if ( myToRemoveCentralPoint != toRemove ) {
    myToRemoveCentralPoint = toRemove;
    NotifySubMeshesHypothesisModification();
  }
}

//=======================================================================
//function : GetToRemoveCentralPoint
//=======================================================================

bool HYBRIDPlugin_Hypothesis::GetToRemoveCentralPoint() const
{
  return myToRemoveCentralPoint;
}

//=======================================================================
//function : SetAdvancedOption
//=======================================================================

void HYBRIDPlugin_Hypothesis::SetAdvancedOption(const std::string& option)
{
  size_t wsPos = option.find(' ');
  if ( wsPos == std::string::npos )
  {
    SetOptionValue( option, "" );
  }
  else
  {
    std::string opt( option, 0, wsPos );
    std::string val( option, wsPos + 1 );
    SetOptionValue( opt, val );
  }
}

//=======================================================================
//function : GetAdvancedOption
//=======================================================================

std::string HYBRIDPlugin_Hypothesis::GetAdvancedOption() const
{
  SMESH_Comment txt;

  TOptionValues::const_iterator o2v = _option2value.begin();
  for ( ; o2v != _option2value.end(); ++o2v )
    if ( !o2v->second.empty() )
    {
      if ( !txt.empty() )
        txt << " ";
      txt << o2v->first << " " << o2v->second;
    }
  for ( o2v = _customOption2value.begin(); o2v != _customOption2value.end(); ++o2v )
  {
    if ( !txt.empty() )
      txt << " ";
    txt << o2v->first << " " << o2v->second;
  }
  return txt;
}

//=======================================================================
//function : SetGradation
//=======================================================================

void HYBRIDPlugin_Hypothesis::SetGradation(double gradation)
{
  SetOptionValue( "gradation", SMESH_Comment( gradation ));
  myGradation = gradation;
}

//=======================================================================
//function : GetGradation
//=======================================================================

double HYBRIDPlugin_Hypothesis::GetGradation() const
{
  return myGradation;
}

//=======================================================================
//function : SetStandardOutputLog
//=======================================================================

void HYBRIDPlugin_Hypothesis::SetStandardOutputLog(bool logInStandardOutput)
{
  if ( myLogInStandardOutput != logInStandardOutput ) {
    myLogInStandardOutput = logInStandardOutput;
    NotifySubMeshesHypothesisModification();
  }
}

//=======================================================================
//function : GetStandardOutputLog
//=======================================================================

bool HYBRIDPlugin_Hypothesis::GetStandardOutputLog() const
{
  return myLogInStandardOutput;
}

//=======================================================================
//function : SetRemoveLogOnSuccess
//=======================================================================

void HYBRIDPlugin_Hypothesis::SetRemoveLogOnSuccess(bool removeLogOnSuccess)
{
  if ( myRemoveLogOnSuccess != removeLogOnSuccess ) {
    myRemoveLogOnSuccess = removeLogOnSuccess;
    NotifySubMeshesHypothesisModification();
  }
}

//=======================================================================
//function : GetRemoveLogOnSuccess
//=======================================================================

bool HYBRIDPlugin_Hypothesis::GetRemoveLogOnSuccess() const
{
  return myRemoveLogOnSuccess;
}

//=======================================================================
//function : SetEnforcedVertex
//=======================================================================

bool HYBRIDPlugin_Hypothesis::SetEnforcedVertex(std::string theName, std::string theEntry, std::string theGroupName,
                                               double size, double x, double y, double z, bool isCompound)
{
  bool toNotify = false;
  bool toCreate = true;

  THYBRIDEnforcedVertex *oldEnVertex;
  THYBRIDEnforcedVertex *newEnfVertex = new THYBRIDEnforcedVertex();
  newEnfVertex->name = theName;
  newEnfVertex->geomEntry = theEntry;
  newEnfVertex->coords.clear();
  if (!isCompound) {
    newEnfVertex->coords.push_back(x);
    newEnfVertex->coords.push_back(y);
    newEnfVertex->coords.push_back(z);
  }
  newEnfVertex->groupName = theGroupName;
  newEnfVertex->size = size;
  newEnfVertex->isCompound = isCompound;
  
  
  // update _enfVertexList
  THYBRIDEnforcedVertexList::iterator it = _enfVertexList.find(newEnfVertex);
  if (it != _enfVertexList.end()) {
    toCreate = false;
    oldEnVertex = (*it);
    if (oldEnVertex->name != theName) {
      oldEnVertex->name = theName;
      toNotify = true;
    }
    if (oldEnVertex->groupName != theGroupName) {
      oldEnVertex->groupName = theGroupName;
      toNotify = true;
    }
    if (oldEnVertex->size != size) {
      oldEnVertex->size = size;
      toNotify = true;
    }
    if (toNotify) {
      // update map coords / enf vertex if needed
      if (oldEnVertex->coords.size()) {
        _coordsEnfVertexMap[oldEnVertex->coords] = oldEnVertex;
        _enfVertexCoordsSizeList[oldEnVertex->coords] = size;
      }

      // update map geom entry / enf vertex if needed
      if (oldEnVertex->geomEntry != "") {
        _geomEntryEnfVertexMap[oldEnVertex->geomEntry] = oldEnVertex;
        _enfVertexEntrySizeList[oldEnVertex->geomEntry] = size;
      }
    }
  }

//   //////// CREATE ////////////
  if (toCreate) {
    toNotify = true;
    _enfVertexList.insert(newEnfVertex);
    if (theEntry == "") {
      _coordsEnfVertexMap[newEnfVertex->coords] = newEnfVertex;
      _enfVertexCoordsSizeList[newEnfVertex->coords] = size;
    }
    else {
      _geomEntryEnfVertexMap[newEnfVertex->geomEntry] = newEnfVertex;
      _enfVertexEntrySizeList[newEnfVertex->geomEntry] = size;
    }
  }

  if (toNotify)
    NotifySubMeshesHypothesisModification();

  return toNotify;
}


//=======================================================================
//function : SetEnforcedMesh
//=======================================================================
bool HYBRIDPlugin_Hypothesis::SetEnforcedMesh(SMESH_Mesh& theMesh, SMESH::ElementType elementType, std::string name, std::string entry, std::string groupName)
{
  TIDSortedElemSet theElemSet;
  SMDS_ElemIteratorPtr eIt = theMesh.GetMeshDS()->elementsIterator(SMDSAbs_ElementType(elementType));
  while ( eIt->more() )
    theElemSet.insert( eIt->next() );
  bool added = SetEnforcedElements( theElemSet, elementType, groupName);
  if (added) {
    THYBRIDEnforcedMesh* newEnfMesh = new THYBRIDEnforcedMesh();
    newEnfMesh->persistID   = theMesh.GetMeshDS()->GetPersistentId();
    newEnfMesh->name        = name;
    newEnfMesh->entry       = entry;
    newEnfMesh->elementType = elementType;
    newEnfMesh->groupName   = groupName;
    
    THYBRIDEnforcedMeshList::iterator it = _enfMeshList.find(newEnfMesh);
    if (it == _enfMeshList.end()) {
      _entryEnfMeshMap[entry].insert(newEnfMesh);
      _enfMeshList.insert(newEnfMesh);
    }
    else {
      delete newEnfMesh;
    }
  }
  return added;
}

//=======================================================================
//function : SetEnforcedGroup
//=======================================================================
bool HYBRIDPlugin_Hypothesis::SetEnforcedGroup(const SMESHDS_Mesh* theMeshDS, SMESH::smIdType_array_var theIDs, SMESH::ElementType elementType, std::string name, std::string entry, std::string groupName)
{
  TIDSortedElemSet theElemSet;
  if ( theIDs->length() == 0 ){MESSAGE("The source group is empty");}
  for ( CORBA::ULong i = 0; i < theIDs->length(); i++)
  {
    SMESH::smIdType ind = theIDs[i];
    if (elementType == SMESH::NODE)
    {
      const SMDS_MeshNode * node = theMeshDS->FindNode(ind);
      if (node)
        theElemSet.insert( node );
    }
    else
    {
      const SMDS_MeshElement * elem = theMeshDS->FindElement(ind);
      if (elem)
        theElemSet.insert( elem );
    }
  }

  //   SMDS_ElemIteratorPtr it = theGroup->GetGroupDS()->GetElements();
  //   while ( it->more() )
  //     theElemSet.insert( it->next() );

  bool added = SetEnforcedElements( theElemSet, elementType, groupName);
  if (added) {
    THYBRIDEnforcedMesh* newEnfMesh = new THYBRIDEnforcedMesh();
    newEnfMesh->name = name;
    newEnfMesh->entry = entry;
    newEnfMesh->elementType = elementType;
    newEnfMesh->groupName = groupName;

    THYBRIDEnforcedMeshList::iterator it = _enfMeshList.find(newEnfMesh);
    if (it == _enfMeshList.end()) {
      _entryEnfMeshMap[entry].insert(newEnfMesh);
      _enfMeshList.insert(newEnfMesh);
    }
  }
  return added;
}

//=======================================================================
//function : SetEnforcedElements
//=======================================================================
bool HYBRIDPlugin_Hypothesis::SetEnforcedElements(TIDSortedElemSet theElemSet, SMESH::ElementType elementType, std::string groupName)
{
  TIDSortedElemSet::const_iterator it = theElemSet.begin();
  const SMDS_MeshElement* elem;
  const SMDS_MeshNode* node;
  bool added = true;
  std::pair<TIDSortedNodeGroupMap::iterator,bool> nodeRet;
  std::pair<TIDSortedElemGroupMap::iterator,bool> elemRet;

  for (;it != theElemSet.end();++it)
  {
    elem = (*it);
    switch (elementType) {
      case SMESH::NODE:
        node = dynamic_cast<const SMDS_MeshNode*>(elem);
        if (node) {
          nodeRet = _enfNodes.insert(make_pair(node,groupName));
          added = added && nodeRet.second;
          std::string msg = added ? "yes":"no";
        }
        else {
          SMDS_ElemIteratorPtr nodeIt = elem->nodesIterator();
          for (;nodeIt->more();) {
            node = dynamic_cast<const SMDS_MeshNode*>(nodeIt->next());
            nodeRet = _enfNodes.insert(make_pair(node,groupName));
            added = added && nodeRet.second;
          }
//          added = true;s
        }
        break;
      case SMESH::EDGE:
        if (elem->GetType() == SMDSAbs_Edge) {
          elemRet = _enfEdges.insert(make_pair(elem,groupName));
          added = added && elemRet.second;
        }
        break;
      case SMESH::FACE:
        if (elem->GetType() == SMDSAbs_Face)
        {
          if (elem->NbCornerNodes() == 3) {
            elemRet = _enfTriangles.insert(make_pair(elem,groupName));
            added = added && elemRet.second;
          }
        }
        break;
      default:
        break;
    };
  }
  if (added)
    NotifySubMeshesHypothesisModification();
  return added;
}


//=======================================================================
//function : GetEnforcedVertex
//=======================================================================

HYBRIDPlugin_Hypothesis::THYBRIDEnforcedVertex* HYBRIDPlugin_Hypothesis::GetEnforcedVertex(double x, double y, double z)
{
  std::vector<double> coord(3);
  coord[0] = x;
  coord[1] = y;
  coord[2] = z;
  if (_coordsEnfVertexMap.count(coord)>0)
    return _coordsEnfVertexMap[coord];
  std::ostringstream msg ;
  msg << "No enforced vertex at " << x << ", " << y << ", " << z;
  throw std::invalid_argument(msg.str());
}

HYBRIDPlugin_Hypothesis::THYBRIDEnforcedVertex* HYBRIDPlugin_Hypothesis::GetEnforcedVertex(const std::string theEntry)
{
  if (_geomEntryEnfVertexMap.count(theEntry)>0)
    return _geomEntryEnfVertexMap[theEntry];
  
  std::ostringstream msg ;
  msg << "No enforced vertex with entry " << theEntry;
  throw std::invalid_argument(msg.str());
}

//=======================================================================
//function : RemoveEnforcedVertex
//=======================================================================

bool HYBRIDPlugin_Hypothesis::RemoveEnforcedVertex(double x, double y, double z, const std::string theEntry)
{
  bool toNotify = false;
  std::ostringstream msg;
  THYBRIDEnforcedVertex *oldEnfVertex;
  std::vector<double> coords(3);
  coords[0] = x;
  coords[1] = y;
  coords[2] = z;
  
  // check that enf vertex with given enf vertex entry exists
  TGeomEntryHYBRIDEnforcedVertexMap::iterator it_enfVertexEntry = _geomEntryEnfVertexMap.find(theEntry);
  if (it_enfVertexEntry != _geomEntryEnfVertexMap.end()) {
    // Success
    oldEnfVertex = it_enfVertexEntry->second;
    _geomEntryEnfVertexMap.erase(it_enfVertexEntry);
  } else {
    // Fail
    // check that enf vertex with given coords exists
    TCoordsHYBRIDEnforcedVertexMap::iterator it_coords_enf = _coordsEnfVertexMap.find(coords);
    if (it_coords_enf != _coordsEnfVertexMap.end()) {
      // Success
      oldEnfVertex = it_coords_enf->second;
      _coordsEnfVertexMap.erase(it_coords_enf);
      _enfVertexCoordsSizeList.erase(_enfVertexCoordsSizeList.find(coords));
    } else {
      // Fail
      throw std::invalid_argument(msg.str());
    }
  }


  // update _enfVertexList
  THYBRIDEnforcedVertexList::iterator it = _enfVertexList.find(oldEnfVertex);
  if (it != _enfVertexList.end()) {
    if ((*it)->groupName != "")
      _groupsToRemove.insert((*it)->groupName);
    _enfVertexList.erase(it);
    toNotify = true;
  }

  if (toNotify)
    NotifySubMeshesHypothesisModification();

  return toNotify;
}

//=======================================================================
//function : ClearEnforcedVertices
//=======================================================================
void HYBRIDPlugin_Hypothesis::ClearEnforcedVertices()
{
  THYBRIDEnforcedVertexList::const_iterator it = _enfVertexList.begin();
  for(;it != _enfVertexList.end();++it) {
    if ((*it)->groupName != "")
      _groupsToRemove.insert((*it)->groupName);
  }
  _enfVertexList.clear();
  _coordsEnfVertexMap.clear();
  _geomEntryEnfVertexMap.clear();
  _enfVertexCoordsSizeList.clear();
  _enfVertexEntrySizeList.clear();
  NotifySubMeshesHypothesisModification();
}

//=======================================================================
//function : ClearEnforcedMeshes
//=======================================================================
void HYBRIDPlugin_Hypothesis::ClearEnforcedMeshes()
{
  THYBRIDEnforcedMeshList::const_iterator it = _enfMeshList.begin();
  for(;it != _enfMeshList.end();++it) {
    if ((*it)->groupName != "")
      _groupsToRemove.insert((*it)->groupName);
  }
  _enfNodes.clear();
  _enfEdges.clear();
  _enfTriangles.clear();
  _nodeIDToSizeMap.clear();
  _enfMeshList.clear();
  _entryEnfMeshMap.clear();
  NotifySubMeshesHypothesisModification();
}

//================================================================================
/*!
 * \brief At mesh loading, restore enforced elements by just loaded enforced meshes
 */
//================================================================================

void HYBRIDPlugin_Hypothesis::RestoreEnfElemsByMeshes()
{
  THYBRIDEnforcedMeshList::const_iterator it = _enfMeshList.begin();
  for(;it != _enfMeshList.end();++it) {
    THYBRIDEnforcedMesh* enfMesh = *it;
    if ( SMESH_Mesh* mesh = GetMeshByPersistentID( enfMesh->persistID ))
      SetEnforcedMesh( *mesh,
                       enfMesh->elementType,
                       enfMesh->name,
                       enfMesh->entry,
                       enfMesh->groupName );
    enfMesh->persistID = -1; // not to restore again
  }
}

//=======================================================================
//function : SetGroupsToRemove
//=======================================================================

void HYBRIDPlugin_Hypothesis::ClearGroupsToRemove()
{
  _groupsToRemove.clear();
}

//=======================================================================
//function : DefaultToUseLib
//=======================================================================

bool HYBRIDPlugin_Hypothesis::DefaultToUseLib()
{
  // default is false but it can be change by environment variable
  if (getenv("MG_HYBRID_USE_LIB"))
    return true;
  return false;
}

//=======================================================================
//function : DefaultLayersOnAllWrap
//=======================================================================

bool HYBRIDPlugin_Hypothesis::DefaultLayersOnAllWrap()
{
  return true;
}

//=======================================================================
//function : DefaultMeshHoles
//=======================================================================

bool HYBRIDPlugin_Hypothesis::DefaultMeshHoles()
{
  return false; // PAL19680
}

//=======================================================================
//function : DefaultToMakeGroupsOfDomains
//=======================================================================

bool HYBRIDPlugin_Hypothesis::DefaultToMakeGroupsOfDomains()
{
  return false; // issue 0022172
}

//=======================================================================
//function : DefaultMaximumMemory
//=======================================================================

#if defined(WIN32)
#include <windows.h>
#elif !defined(__APPLE__)
#include <sys/sysinfo.h>
#endif

double  HYBRIDPlugin_Hypothesis::DefaultMaximumMemory()
{
#if defined(WIN32)
  // See http://msdn.microsoft.com/en-us/library/aa366589.aspx
  MEMORYSTATUSEX statex;
  statex.dwLength = sizeof (statex);
  int err = GlobalMemoryStatusEx (&statex);
  if (err != 0) {
    int totMB = 
      statex.ullTotalPhys / 1024 / 1024 +
      statex.ullTotalPageFile / 1024 / 1024 +
      statex.ullTotalVirtual / 1024 / 1024;
    return ( 0.7 * totMB );
  }
#elif !defined(__APPLE__)
  struct sysinfo si;
  int err = sysinfo( &si );
  if ( err == 0 ) {
    int ramMB = si.totalram * si.mem_unit / 1024 / 1024;
    return ( 0.7 * ramMB );
  }
#endif
  return 1024;
}

//=======================================================================
//function : DefaultInitialMemory
//=======================================================================

double  HYBRIDPlugin_Hypothesis::DefaultInitialMemory()
{
  return DefaultMaximumMemory();
}

//=======================================================================
//function : DefaultCollisionMode
//=======================================================================
short  HYBRIDPlugin_Hypothesis::DefaultCollisionMode()
{
  return Decrease;
}

//=======================================================================
//function : DefaultBoundaryLayersGrowth
//=======================================================================
short  HYBRIDPlugin_Hypothesis::DefaultBoundaryLayersGrowth()
{
  return Layer_Growth_Inward;
}

//=======================================================================
//function : DefaultElementGeneration
//=======================================================================
short  HYBRIDPlugin_Hypothesis::DefaultElementGeneration()
{
  return Generation_Tetra_Dominant;
}

//=======================================================================
//function : DefaultOptimizationLevel
//=======================================================================
short  HYBRIDPlugin_Hypothesis::DefaultOptimizationLevel()
{
  return Medium;
}

//=======================================================================
//function : DefaultWorkingDirectory
//=======================================================================

std::string HYBRIDPlugin_Hypothesis::DefaultWorkingDirectory()
{
  std::string aTmpDir;

  char *Tmp_dir = getenv("SALOME_TMP_DIR");
  if(Tmp_dir != NULL) {
    aTmpDir = Tmp_dir;
  }
  else {
#ifdef WIN32
    aTmpDir = "C:\\";
#else
    aTmpDir = "/tmp/";
#endif
  }
  return aTmpDir;
}

//=======================================================================
//function : DefaultKeepFiles
//=======================================================================

bool   HYBRIDPlugin_Hypothesis::DefaultKeepFiles()
{
  return false;
}

//=======================================================================
//function : DefaultRemoveLogOnSuccess
//=======================================================================

bool   HYBRIDPlugin_Hypothesis::DefaultRemoveLogOnSuccess()
{
  return false;
}


//=======================================================================
//function : DefaultVerboseLevel
//=======================================================================

short  HYBRIDPlugin_Hypothesis::DefaultVerboseLevel()
{
  return 10;
}

//=======================================================================
//function : DefaultToCreateNewNodes
//=======================================================================

bool HYBRIDPlugin_Hypothesis::DefaultToCreateNewNodes()
{
  return true;
}

//=======================================================================
//function : DefaultToUseBoundaryRecoveryVersion
//=======================================================================

bool HYBRIDPlugin_Hypothesis::DefaultToUseBoundaryRecoveryVersion()
{
  return false;
}

//=======================================================================
//function : DefaultToUseFEMCorrection
//=======================================================================

bool HYBRIDPlugin_Hypothesis::DefaultToUseFEMCorrection()
{
  return false;
}

//=======================================================================
//function : DefaultToRemoveCentralPoint
//=======================================================================

bool HYBRIDPlugin_Hypothesis::DefaultToRemoveCentralPoint()
{
  return false;
}

//=======================================================================
//function : DefaultGradation
//=======================================================================

double HYBRIDPlugin_Hypothesis::DefaultGradation()
{
  return 2;
}

//=======================================================================
//function : DefaultStandardOutputLog
//=======================================================================

bool HYBRIDPlugin_Hypothesis::DefaultStandardOutputLog()
{
  return false;
}

// //=======================================================================
// //function : DefaultID2SizeMap
// //=======================================================================
// 
// HYBRIDPlugin_Hypothesis::TID2SizeMap HYBRIDPlugin_Hypothesis::DefaultID2SizeMap()
// {
//   return HYBRIDPlugin_Hypothesis::TID2SizeMap();
// }

//=======================================================================
//function : DefaultAddMultinormals
//=======================================================================
bool HYBRIDPlugin_Hypothesis::DefaultAddMultinormals()
{
  return false;
}

//=======================================================================
//function : DefaultSmoothNormals
//=======================================================================
bool HYBRIDPlugin_Hypothesis::DefaultSmoothNormals()
{
  return false;
}

//=======================================================================
//function : DefaultHeightFirstLayer
//=======================================================================
double HYBRIDPlugin_Hypothesis::DefaultHeightFirstLayer()
{
  return 0.0; //or epsilon?
}

//=======================================================================
//function : DefaultBoundaryLayersProgression
//=======================================================================
double HYBRIDPlugin_Hypothesis::DefaultBoundaryLayersProgression()
{
  return 1.0;
}

//=======================================================================
//function : DefaultCoreSize
//=======================================================================
double HYBRIDPlugin_Hypothesis::DefaultCoreSize()
{
  return 0.0;
}

//=======================================================================
//function : DefaultMultinormalsAngle
//=======================================================================
double HYBRIDPlugin_Hypothesis::DefaultMultinormalsAngle()
{
  return 30.0;
}

//=======================================================================
//function : DefaultNbOfBoundaryLayers
//=======================================================================
short HYBRIDPlugin_Hypothesis::DefaultNbOfBoundaryLayers()
{
  return 1;
}

//=======================================================================
//function : SaveTo
//=======================================================================

std::ostream & HYBRIDPlugin_Hypothesis::SaveTo(std::ostream & save)
{
  save << (int) myBoundaryLayersGrowth << " ";
  save << (int) myElementGeneration << " ";
  save << (int) myAddMultinormals << " ";
  save << (int) mySmoothNormals << " ";
  save << (int) myLayersOnAllWrap << " ";

  save << myNbOfBoundaryLayers << " ";
  save << myHeightFirstLayer << " ";
  save << myBoundaryLayersProgression << " ";
  save << myMultinormalsAngle << " ";

  save << (int) myKeepFiles << " ";
  save << myWorkingDirectory << " ";
  save << myVerboseLevel << " ";
  save << myCoreSize << " ";

  // if (!myTextOption.empty()) {
  //   save << "__OPTIONS_BEGIN__ ";
  //   save << myTextOption << " ";
  //   save << "__OPTIONS_END__ ";
  // }


  THYBRIDEnforcedVertexList::iterator it  = _enfVertexList.begin();
  if (it != _enfVertexList.end()) {
    save << " " << "__ENFORCED_VERTICES_BEGIN__ ";
    for ( ; it != _enfVertexList.end(); ++it ) {
      THYBRIDEnforcedVertex *enfVertex = (*it);
      save << " " << "__BEGIN_VERTEX__";
      if (!enfVertex->name.empty()) {
        save << " " << "__BEGIN_NAME__";
        save << " " << enfVertex->name;
        save << " " << "__END_NAME__";
      }
      if (!enfVertex->geomEntry.empty()) {
        save << " " << "__BEGIN_ENTRY__";
        save << " " << enfVertex->geomEntry;
        save << " " << enfVertex->isCompound;
        save << " " << "__END_ENTRY__";
      }
      if (!enfVertex->groupName.empty()) {
        save << " " << "__BEGIN_GROUP__";
        save << " " << enfVertex->groupName;
        save << " " << "__END_GROUP__";
      }
      if (enfVertex->coords.size()) {
        save << " " << "__BEGIN_COORDS__";
        for ( size_t i = 0; i < enfVertex->coords.size(); i++ )
          save << " " << enfVertex->coords[i];
        save << " " << "__END_COORDS__";
      }
      save << " " << "__BEGIN_SIZE__";
      save << " " << enfVertex->size;
      save << " " << "__END_SIZE__";
      save << " " << "__END_VERTEX__";
    }
    save << " " << "__ENFORCED_VERTICES_END__ ";
  }

  THYBRIDEnforcedMeshList::iterator it_mesh  = _enfMeshList.begin();
  if (it_mesh != _enfMeshList.end()) {
    save << " " << "__ENFORCED_MESHES_BEGIN__ ";
    for ( ; it_mesh != _enfMeshList.end(); ++it_mesh ) {
      THYBRIDEnforcedMesh *enfMesh = (*it_mesh);
      save << " " << "__BEGIN_ENF_MESH__";

      save << " " << "__BEGIN_NAME__";
      save << " " << enfMesh->name;
      save << " " << "__END_NAME__";

      save << " " << "__BEGIN_ENTRY__";
      save << " " << enfMesh->entry;
      save << " " << "__END_ENTRY__";

      save << " " << "__BEGIN_ELEM_TYPE__";
      save << " " << (int)enfMesh->elementType;
      save << " " << "__END_ELEM_TYPE__";

      if (!enfMesh->groupName.empty()) {
        save << " " << "__BEGIN_GROUP__";
        save << " " << enfMesh->groupName;
        save << " " << "__END_GROUP__";
      }
      save << " " << "__PERSIST_ID__";
      save << " " << enfMesh->persistID;
      save << " " << "__END_ENF_MESH__";
      std::cout << "Saving of enforced mesh " << enfMesh->name.c_str() << " done" << std::endl;
    }
    save << " "  << "__ENFORCED_MESHES_END__ ";
  }

  save << " " << myFacesWithLayers.size();
  for ( size_t i = 0; i < myFacesWithLayers.size(); ++i )
    save << " " << myFacesWithLayers[i];

  save << " " << myFacesWithImprinting.size();
  for ( size_t i = 0; i < myFacesWithImprinting.size(); ++i )
    save << " " << myFacesWithImprinting[i];

  save << " " << myFacesWithSnapping.size();
  for ( size_t i = 0; i < myFacesWithSnapping.size(); ++i )
    save << " " << myFacesWithSnapping[i];

  // New options in 2.9.6 (issue #17784)

  save << " " << myHeightIsRelative;
  save << " " << myBoundaryLayersMaxElemAngle;
  save << " " << myCollisionMode;
  save << " " << myGradation;
  save << " " << myOptimizationLevel;

  save << " " << _option2value.size();
  TOptionValues::iterator o2v = _option2value.begin();
  for ( ; o2v != _option2value.end(); ++o2v )
    save << " -" << o2v->first << " -" << o2v->second;

  save << " " << _customOption2value.size();
  for ( o2v = _customOption2value.begin(); o2v != _customOption2value.end(); ++o2v )
    save << " -" << o2v->first << " -" << o2v->second;

  // New in SALOME 9.13
  save << " " << myUseLib;

  return save;
}

//=======================================================================
//function : LoadFrom
//=======================================================================

std::istream & HYBRIDPlugin_Hypothesis::LoadFrom(std::istream & load)
{
  bool isOK = true;
  int i;
  double d;

  isOK = static_cast<bool>(load >> i);
  if (isOK)
    myBoundaryLayersGrowth = (short) i;
  else
    load.clear(ios::badbit | load.rdstate());

  isOK = static_cast<bool>(load >> i);
  if (isOK)
    myElementGeneration = (short) i;
  else
    load.clear(ios::badbit | load.rdstate());

  isOK = static_cast<bool>(load >> i);
  if (isOK)
    myAddMultinormals = (bool) i;
  else
    load.clear(ios::badbit | load.rdstate());

  isOK = static_cast<bool>(load >> i);
  if (isOK)
    mySmoothNormals = (bool) i;
  else
    load.clear(ios::badbit | load.rdstate());

  isOK = static_cast<bool>(load >> i);
  if (isOK)
    myLayersOnAllWrap = (bool) i;
  else
    load.clear(ios::badbit | load.rdstate());

  isOK = static_cast<bool>(load >> i);
  if (isOK)
    myNbOfBoundaryLayers = (short) i;
  else
    load.clear(ios::badbit | load.rdstate());

  isOK = static_cast<bool>(load >> d);
  if (isOK)
    myHeightFirstLayer = d;
  else
    load.clear(ios::badbit | load.rdstate());

  isOK = static_cast<bool>(load >> d);
  if (isOK)
    myBoundaryLayersProgression = d;
  else
    load.clear(ios::badbit | load.rdstate());

  isOK = static_cast<bool>(load >> d);
  if (isOK)
    myMultinormalsAngle = d;
  else
    load.clear(ios::badbit | load.rdstate());

  isOK = static_cast<bool>(load >> i);
  if (isOK)
    myKeepFiles = (bool) i;
  else
    load.clear(ios::badbit | load.rdstate());

  isOK = static_cast<bool>(load >> myWorkingDirectory);
  if (isOK) {
    if ( myWorkingDirectory == "0") { // myWorkingDirectory was empty
      myKeepFiles = false;
      myWorkingDirectory.clear();
    }
    else if ( myWorkingDirectory == "1" ) {
      myKeepFiles = true;
      myWorkingDirectory.clear();
    }
  }
  else
    load.clear(ios::badbit | load.rdstate());

  isOK = static_cast<bool>(load >> i);
  if (isOK)
    myVerboseLevel = (short) i;
  else
    load.clear(ios::badbit | load.rdstate());

  isOK = static_cast<bool>(load >> d);
  if (isOK)
    myCoreSize = d;
  else
    load.clear(ios::badbit | load.rdstate());

  std::string separator;
  bool hasOptions = false;
  bool hasEnforcedVertices = false;
  bool hasEnforcedMeshes = false;
  isOK = static_cast<bool>(load >> separator);

  if (isOK) {
    if (separator == "__OPTIONS_BEGIN__")
      hasOptions = true;
    else if (separator == "__ENFORCED_VERTICES_BEGIN__")
      hasEnforcedVertices = true;
    else if (separator == "__ENFORCED_MESHES_BEGIN__")
      hasEnforcedMeshes = true;
  }

  if (hasOptions) {
    std::string txt;
    while (isOK) {
      isOK = static_cast<bool>(load >> txt);
      if (isOK) {
        if (txt == "__OPTIONS_END__") {
          isOK = false;
          break;
        }
        // myTextOption += txt;
      }
    }
  }

  if (hasOptions) {
    isOK = static_cast<bool>(load >> separator);
    if (isOK && separator == "__ENFORCED_VERTICES_BEGIN__")
      hasEnforcedVertices = true;
    if (isOK && separator == "__ENFORCED_MESHES_BEGIN__")
      hasEnforcedMeshes = true;
  }

  if (hasEnforcedVertices) {
    std::string txt, name, entry, groupName;
    double size, coords[3];
    bool isCompound;
    bool hasCoords = false;
    isOK = static_cast<bool>(load >> txt);  // __BEGIN_VERTEX__
    while (isOK) {
      if (txt == "__ENFORCED_VERTICES_END__")
        isOK = false;

      THYBRIDEnforcedVertex *enfVertex = new THYBRIDEnforcedVertex();
      while (isOK) {
        isOK = static_cast<bool>(load >> txt);
        if (txt == "__END_VERTEX__") {
          enfVertex->name = name;
          enfVertex->geomEntry = entry;
          enfVertex->isCompound = isCompound;
          enfVertex->groupName = groupName;
          enfVertex->coords.clear();
          if (hasCoords)
            enfVertex->coords.assign(coords,coords+3);

          _enfVertexList.insert(enfVertex);

          if (enfVertex->coords.size())
            _coordsEnfVertexMap[enfVertex->coords] = enfVertex;
          if (!enfVertex->geomEntry.empty())
            _geomEntryEnfVertexMap[enfVertex->geomEntry] = enfVertex;

          name.clear();
          entry.clear();
          groupName.clear();
          hasCoords = false;
          isOK = false;
        }

        if (txt == "__BEGIN_NAME__") {  // __BEGIN_NAME__
          while (isOK && (txt != "__END_NAME__")) {
            isOK = static_cast<bool>(load >> txt);
            if (txt != "__END_NAME__") {
              if (!name.empty())
                name += " ";
              name += txt;
            }
          }
        }

        if (txt == "__BEGIN_ENTRY__") {  // __BEGIN_ENTRY__
          isOK = static_cast<bool>(load >> entry);
          isOK = static_cast<bool>(load >> isCompound);
          isOK = static_cast<bool>(load >> txt); // __END_ENTRY__
          if (txt != "__END_ENTRY__")
            throw std::exception();
        }

        if (txt == "__BEGIN_GROUP__") {  // __BEGIN_GROUP__
          while (isOK && (txt != "__END_GROUP__")) {
            isOK = static_cast<bool>(load >> txt);
            if (txt != "__END_GROUP__") {
              if (!groupName.empty())
                groupName += " ";
              groupName += txt;
            }
          }
        }

        if (txt == "__BEGIN_COORDS__") {  // __BEGIN_COORDS__
          hasCoords = true;
          isOK = static_cast<bool>(load >> coords[0] >> coords[1] >> coords[2]);
          isOK = static_cast<bool>(load >> txt); // __END_COORDS__
          if (txt != "__END_COORDS__")
            throw std::exception();
        }

        if (txt == "__BEGIN_SIZE__") {  // __BEGIN_ENTRY__
          isOK = static_cast<bool>(load >> size);
          isOK = static_cast<bool>(load >> txt); // __END_ENTRY__
          if (txt != "__END_SIZE__") {
            throw std::exception();
          }
        }
      }
      isOK = static_cast<bool>(load >> txt);  // __BEGIN_VERTEX__
    }
  }

  if (hasEnforcedVertices) {
    isOK = static_cast<bool>(load >> separator);
    if (isOK && separator == "__ENFORCED_MESHES_BEGIN__")
      hasEnforcedMeshes = true;
  }

  if (hasEnforcedMeshes) {
    std::string txt, name, entry, groupName;
    int elementType = -1, persistID = -1;
    isOK = static_cast<bool>(load >> txt);  // __BEGIN_ENF_MESH__
    while (isOK) {
      //                if (isOK) {
      if (txt == "__ENFORCED_MESHES_END__")
        isOK = false;

      THYBRIDEnforcedMesh *enfMesh = new THYBRIDEnforcedMesh();
      while (isOK) {
        isOK = static_cast<bool>(load >> txt);
        if (txt == "__END_ENF_MESH__") {
          enfMesh->name = name;
          enfMesh->entry = entry;
          enfMesh->elementType = (SMESH::ElementType)elementType;
          enfMesh->groupName = groupName;
          enfMesh->persistID = persistID;

          _enfMeshList.insert(enfMesh);
          std::cout << "Restoring of enforced mesh " <<name  << " done" << std::endl;

          name.clear();
          entry.clear();
          elementType = -1;
          groupName.clear();
          persistID = -1;
          isOK = false;
        }

        if (txt == "__BEGIN_NAME__") {  // __BEGIN_NAME__
          while (isOK && (txt != "__END_NAME__")) {
            isOK = static_cast<bool>(load >> txt);
            if (txt != "__END_NAME__") {
              if (!name.empty())
                name += " ";
              name += txt;
            }
          }
        }

        if (txt == "__BEGIN_ENTRY__") {  // __BEGIN_ENTRY__
          isOK = static_cast<bool>(load >> entry);
          isOK = static_cast<bool>(load >> txt); // __END_ENTRY__
          if (txt != "__END_ENTRY__")
            throw std::exception();
        }

        if (txt == "__BEGIN_ELEM_TYPE__") {  // __BEGIN_ELEM_TYPE__
          isOK = static_cast<bool>(load >> elementType);
          isOK = static_cast<bool>(load >> txt); // __END_ELEM_TYPE__
          if (txt != "__END_ELEM_TYPE__")
            throw std::exception();
        }

        if (txt == "__BEGIN_GROUP__") {  // __BEGIN_GROUP__
          while (isOK && (txt != "__END_GROUP__")) {
            isOK = static_cast<bool>(load >> txt);
            if (txt != "__END_GROUP__") {
              if (!groupName.empty())
                groupName += " ";
              groupName += txt;
            }
          } // while
        } // if

        if (txt == "__PERSIST_ID__") {
          isOK = static_cast<bool>(load >> persistID);
        }
        std::cout << "isOK: " << isOK << std::endl;
      } // while
      //                } // if
      isOK = static_cast<bool>(load >> txt);  // __BEGIN_ENF_MESH__
    } // while
  } // if

  if ( hasEnforcedMeshes )
    isOK = static_cast<bool>(load >> separator);

  if ( isOK )
  {
    i = atoi( separator.c_str() );
    isOK = ( i >= 0 );
    if ( isOK )
    {
      myFacesWithLayers.reserve( i );
      while (( myFacesWithLayers.size() < myFacesWithLayers.capacity() ) &&
             ( isOK = static_cast<bool>(load >> i)) )
        myFacesWithLayers.push_back( i );
    }
  }

  isOK = static_cast<bool>(load >> separator);
  if ( isOK )
  {
    i = atoi( separator.c_str() );
    isOK = ( i >= 0 );
    if ( isOK )
    {
      myFacesWithImprinting.reserve( i );
      while (( myFacesWithImprinting.size() < myFacesWithImprinting.capacity() ) &&
             ( isOK = static_cast<bool>(load >> i)) )
        myFacesWithImprinting.push_back( i );
    }
  }

  isOK = static_cast<bool>(load >> separator);
  if ( isOK )
  {
    i = atoi( separator.c_str() );
    isOK = ( i >= 0 );
    if ( isOK )
    {
      myFacesWithSnapping.reserve( i );
      while (( myFacesWithSnapping.size() < myFacesWithSnapping.capacity() ) &&
             ( isOK = static_cast<bool>(load >> i)) )
        myFacesWithSnapping.push_back( i );
    }
  }

  // New options in 2.9.6 (issue #17784)

  if ( static_cast<bool>(load >> i))
  {
    myHeightIsRelative = (bool) i;
    load >> myBoundaryLayersMaxElemAngle;
    load >> myCollisionMode;
    load >> myGradation;
    load >> myOptimizationLevel;

    std::string option, value;
    if ( static_cast<bool>( load >> i ) && i >= 0 )
    {
      for ( int nbRead = 0; nbRead < i; ++nbRead )
      {
        load >> option >> value;
        _option2value[ std::string( option, 1 )] = std::string( value, 1 );
      }
    }
    if ( static_cast<bool>( load >> i ) && i >= 0 )
    {
      for ( int nbRead = 0; nbRead < i; ++nbRead )
      {
        load >> option >> value;
        _customOption2value[ std::string( option, 1 )] = std::string( value, 1 );
      }
    }
  }

  // New in SALOME 9.13
  if ( static_cast<bool>(load >> i))
    myUseLib = (bool) i;

  return load;
}

//=======================================================================
//function : SetParametersByMesh
//=======================================================================

bool HYBRIDPlugin_Hypothesis::SetParametersByMesh(const SMESH_Mesh* ,const TopoDS_Shape&)
{
  return false;
}

//================================================================================
/*!
 * \brief Sets myToMakeGroupsOfDomains depending on whether theMesh is on shape or not
 */
//================================================================================

bool HYBRIDPlugin_Hypothesis::SetParametersByDefaults(const TDefaults&  dflts,
                                                     const SMESH_Mesh* /*theMesh*/)
{
  myToMakeGroupsOfDomains = ( !dflts._shape || dflts._shape->IsNull() );
  return true;
}

//================================================================================
/*!
 * \brief Return command to run hybrid mesher excluding file prefix (-f)
 */
//================================================================================

std::string HYBRIDPlugin_Hypothesis::CommandToRun(const HYBRIDPlugin_Hypothesis* hyp)
{
  SMESH_Comment cmd = GetExeName();
  // check if any option is overridden by hyp->_option2value
  bool p_h     = ( hyp && hyp->HasOptionDefined("-h"));
  bool p_v     = ( hyp && hyp->HasOptionDefined("-v"));
  bool p_blsd  = ( hyp && hyp->HasOptionDefined("--normal_direction"));
  bool p_hotfl = ( hyp && hyp->HasOptionDefined("--boundary_layer_global_initial_height"));
  bool p_nobl  = ( hyp && hyp->HasOptionDefined("--number_of_boundary_layers"));
  bool p_blgp  = ( hyp && hyp->HasOptionDefined("--boundary_layer_geometric_progression"));
  bool p_eg    = ( hyp && hyp->HasOptionDefined("--element_generation"));
  bool p_cs    = ( hyp && hyp->HasOptionDefined("--global_physical_size"));

  bool nolayers = false;
  bool layersOnAllWrap = hyp ? hyp->myLayersOnAllWrap : DefaultLayersOnAllWrap();

  //help mode
  if ( p_h ) {
    cmd << " --help ";
#ifdef WIN32
    cmd << " < NUL";
#endif
    std::cout << "!!!!! CommandToRun help only !!!! " << cmd << std::endl;
    return cmd;
  }

  if ( !p_v && hyp )
    cmd << " --verbose " << hyp->myVerboseLevel;

  //no layers?
  if ( !p_nobl && hyp ) {
    if ( hyp->myNbOfBoundaryLayers < 1 ) nolayers = true;
  }
  if ( !p_hotfl && hyp ) {
    if ( hyp->myHeightFirstLayer < 1e-50 ) nolayers = true;
  }

  if ( !p_blsd && hyp ) {
    if ( hyp->myBoundaryLayersGrowth >= 0 && hyp->myBoundaryLayersGrowth <= 1 ) {
      const char* value[] = { "-1" , "1" }; // -1 == inside
      cmd << " --normal_direction " << value[ hyp->myBoundaryLayersGrowth ];
    }
  }

  if ( !p_hotfl && hyp ) {
    cmd << " --boundary_layer_global_initial_height " << hyp->myHeightFirstLayer;
  }
  if ( hyp && hyp->GetHeightIsRelative() )
    cmd << " --boundary_layer_height_relative_to_local_surface_size yes";

  if ( !p_nobl && hyp ) {
    cmd << " --number_of_boundary_layers " << ( nolayers ? 0 :  hyp->myNbOfBoundaryLayers );
  }

  if ( !p_blgp && hyp ) {
    cmd << " --boundary_layer_geometric_progression " << hyp->myBoundaryLayersProgression;
  }

  if ( !nolayers && hyp )
  {
    cmd << " --boundary_layer_size_mode " << ( layersOnAllWrap ? "global" : "local" );

    if ( hyp->GetBoundaryLayersMaxElemAngle() != hyp->DefaultBoundaryLayersMaxElemAngle() )
      cmd << " --boundary_layer_max_element_angle "
          << SMESH_Comment( hyp->GetBoundaryLayersMaxElemAngle() );

    if ( !layersOnAllWrap )
    {
      // faces with layers
      const std::vector<int>& faceLayersIDs = hyp->GetFacesWithLayers();
      if ( !faceLayersIDs.empty() )
        cmd << " --boundary_layer_surface_tags ";
      for ( size_t i = 0; i < faceLayersIDs.size(); ++i )
      {
        cmd << faceLayersIDs[i];
        if (i<faceLayersIDs.size()-1)
          cmd << ",";
      }
      // Don't need to set the height of the layer face by face since:
      // - the same height is already set on all the faces with boundary_layer_global_initial_height
      // - we don't allow the user to set different heights for specific faces for now
      // nor in GUI nor in python (it will require a further improvement if needed)
//       if ( !faceLayersIDs.empty() )
//         cmd << " --boundary_layer_initial_height_on_surface_tags ";
//       for ( size_t i = 0; i < faceLayersIDs.size(); ++i )
//         cmd << hyp->myHeightFirstLayer << ",";

      // faces with imprinting
      const std::vector<int>& faceImprintingIDs = hyp->GetFacesWithImprinting();
      if ( !faceImprintingIDs.empty() )
        cmd << " --boundary_layer_imprinting yes --boundary_layer_imprinting_tags ";
      for ( size_t i = 0; i < faceImprintingIDs.size(); ++i )
      {
        cmd << faceImprintingIDs[i];
        if (i<faceImprintingIDs.size()-1)
          cmd << ",";
      }

      // faces with snapping
      const std::vector<int>& faceSnappingIDs = hyp->GetFacesWithSnapping();
      if ( !faceSnappingIDs.empty() )
        cmd << " --boundary_layer_snapping yes --boundary_layer_snapping_tags ";
      for ( size_t i = 0; i < faceSnappingIDs.size(); ++i )
      {
        cmd << faceSnappingIDs[i];
        if (i<faceSnappingIDs.size()-1)
          cmd << ",";
      }
    }
  }

  if ( !p_eg && hyp ) {
    if ( hyp->myElementGeneration >= 0 && hyp->myElementGeneration <= 3 ) {
      const char* value[] = { "tetra_dominant" , "hexa_dominant", "cartesian_core", "extrusion_only" };
      cmd << " --element_generation " << value[ hyp->myElementGeneration ];
    }
  }

  if ( !p_cs && hyp ) {
    if ( hyp->myCoreSize > 0 ) {
      cmd << " --global_physical_size " << hyp->myCoreSize;
    }
  }

  if ( hyp )
  {
    // options as text
    std::string option, value;
    bool isDefault;
    const TOptionValues* options[] = { & hyp->_option2value, & hyp->_customOption2value };
    for ( int iOp = 0; iOp < 2; ++iOp )
    {
      TOptionValues::const_iterator o2v = options[iOp]->begin();
      for ( ; o2v != options[iOp]->end(); ++o2v )
      {
        option = o2v->first;
        value = hyp->GetOptionValue( option, &isDefault );

        if ( isDefault )
          continue;
        if ( value.empty() )
        {
          if ( hyp->_defaultOptionValues.count( option ))
            continue; // non-custom option with no value
        }
        if ( option[0] != '-' )
          cmd << " --";
        else
          cmd << " ";
        cmd << option << " " << value;
      }
    }
  }

#ifdef WIN32
  cmd << " < NUL";
#endif
  //std::cout << "!!!!!CommandToRun end " << cmd << std::endl;

  return cmd;
}

//================================================================================
/*!
 * \brief Return a unique file name
 */
//================================================================================

std::string HYBRIDPlugin_Hypothesis::GetFileName(const HYBRIDPlugin_Hypothesis* hyp)
{
  std::string aTmpDir = hyp ? hyp->GetWorkingDirectory() : DefaultWorkingDirectory();
  const char lastChar = *aTmpDir.rbegin();
#ifdef WIN32
  if(lastChar != '\\') aTmpDir+='\\';
#else
  if(lastChar != '/') aTmpDir+='/';
#endif

  SMESH_Comment aGenericName = aTmpDir;
  aGenericName << "HYBRID_";
  aGenericName << getpid();
  aGenericName << "_";
  aGenericName << Abs((Standard_Integer)(long) aGenericName.c_str());

  return aGenericName;
}

//================================================================================
/*
 * Return the name of executable
 */
//================================================================================

std::string HYBRIDPlugin_Hypothesis::GetExeName()
{
  return "mg-hybrid.exe";
}

//=============================================================================
void HYBRIDPlugin_Hypothesis::SetOptionValue(const std::string& optionName,
                                             const std::string& optionValue)
{
  TOptionValues::iterator op_val = _option2value.find(optionName);
  if (op_val == _option2value.end())
  {
    op_val = _customOption2value.find( optionName );
    if ( op_val == _customOption2value.end() || op_val->second != optionValue )
      NotifySubMeshesHypothesisModification();
    _customOption2value[ optionName ] = optionValue;
    return;
  }

  if (op_val->second != optionValue)
  {
    const char* ptr = optionValue.c_str();
    // strip white spaces
    while (ptr[0] == ' ')
      ptr++;
    int i = strlen(ptr);
    while (i != 0 && ptr[i - 1] == ' ')
      i--;
    // check value type
    bool typeOk = true;
    std::string typeName;
    if (i == 0) {
      // empty string
    } else if (_charOptions.count(optionName)) {
      // do not check strings
    } else if (_doubleOptions.count(optionName)) {
      // check if value is double
      ToDbl(ptr, &typeOk);
      typeName = "real";
    } else if (_boolOptions.count(optionName)) {
      // check if value is bool
      ToBool(ptr, &typeOk);
      typeName = "bool";
    } else {
      // check if value is int
      ToInt(ptr, &typeOk);
      typeName = "integer";
    }
    if ( typeOk ) // check some specific values ?
    {
    }
    if ( !typeOk )
    {
      std::string msg = "Advanced option '" + optionName + "' = '" + optionValue + "' but must be " + typeName;
      throw std::invalid_argument(msg);
    }
    std::string value( ptr, i );
    if ( _defaultOptionValues[ optionName ] == value )
      value.clear();

    op_val->second = value;

    NotifySubMeshesHypothesisModification();
  }
}

//=============================================================================
//! Return option value. If isDefault provided, it can be a default value,
//  then *isDefault == true. If isDefault is not provided, the value will be
//  empty if it equals a default one.
std::string HYBRIDPlugin_Hypothesis::GetOptionValue(const std::string& optionName,
                                                    bool*              isDefault) const
{
  TOptionValues::const_iterator op_val = _option2value.find(optionName);
  if (op_val == _option2value.end())
  {
    op_val = _customOption2value.find(optionName);
    if (op_val == _customOption2value.end())
    {
      std::string msg = "Unknown MG-Hybrid option: <" + optionName + ">";
      MESSAGE(msg);
      throw std::invalid_argument(msg);
    }
  }
  std::string val = op_val->second;
  if ( isDefault ) *isDefault = ( val.empty() );

  if ( val.empty() && isDefault )
  {
    op_val = _defaultOptionValues.find( optionName );
    if (op_val != _defaultOptionValues.end())
      val = op_val->second;
  }
  MESSAGE("GetOptionValue " << optionName << " = " << val);
  return val;
}


//=============================================================================
bool HYBRIDPlugin_Hypothesis::HasOptionDefined( const std::string& optionName ) const
{
  bool isDefault = false;
  try
  {
    GetOptionValue( optionName, &isDefault );
  }
  catch ( std::invalid_argument& )
  {
    return false;
  }
  return !isDefault;
}

//=============================================================================
void HYBRIDPlugin_Hypothesis::ClearOption(const std::string& optionName)
{
  TOptionValues::iterator op_val = _customOption2value.find(optionName);
  if (op_val != _customOption2value.end())
    _customOption2value.erase(op_val);
  else {
    op_val = _option2value.find(optionName);
    if (op_val != _option2value.end())
      op_val->second.clear();
  }
}

//=============================================================================
HYBRIDPlugin_Hypothesis::TOptionValues HYBRIDPlugin_Hypothesis::GetOptionValues() const
{
  TOptionValues vals;
  TOptionValues::const_iterator op_val = _option2value.begin();
  for ( ; op_val != _option2value.end(); ++op_val )
    vals.insert( make_pair( op_val->first, GetOptionValue( op_val->first, GET_DEFAULT() )));

  return vals;
}

//================================================================================
/*!
 * \brief Converts a string to a bool
 */
//================================================================================

bool HYBRIDPlugin_Hypothesis::ToBool(const std::string& str, bool* isOk )
{
  std::string s = str;
  if ( isOk ) *isOk = true;

  for ( size_t i = 0; i <= s.size(); ++i )
    s[i] = tolower( s[i] );

  if ( s == "1" || s == "true" || s == "active" || s == "yes" )
    return true;

  if ( s == "0" || s == "false" || s == "inactive" || s == "no" )
    return false;

  if ( isOk )
    *isOk = false;
  else {
    std::string msg = "Not a Boolean value:'" + str + "'";
    throw std::invalid_argument(msg);
  }
  return false;
}

//================================================================================
/*!
 * \brief Converts a string to a real value
 */
//================================================================================

double HYBRIDPlugin_Hypothesis::ToDbl(const std::string& str, bool* isOk )
{
  if ( str.empty() ) throw std::invalid_argument("Empty value provided");

  char * endPtr;
  // Save locale setting
  const std::string oldLocale=std::setlocale(LC_NUMERIC, nullptr);
  // Force '.' as the radix point, otherwise it is comma in French and "1.2" will result to 1
  std::setlocale(LC_NUMERIC,"C");
  double val = strtod(&str[0], &endPtr);
  // Restore locale setting
  std::setlocale(LC_NUMERIC, oldLocale.c_str());
  bool ok = (&str[0] != endPtr);

  if ( isOk ) *isOk = ok;

  if ( !ok )
  {
    std::string msg = "Not a real value:'" + str + "'";
    throw std::invalid_argument(msg);
  }
  return val;
}

//================================================================================
/*!
 * \brief Converts a string to a integer value
 */
//================================================================================

int HYBRIDPlugin_Hypothesis::ToInt(const std::string& str, bool* isOk )
{
  if ( str.empty() ) throw std::invalid_argument("Empty value provided");

  char * endPtr;
  int val = (int)strtol( &str[0], &endPtr, 10);
  bool ok = (&str[0] != endPtr);

  if ( isOk ) *isOk = ok;

  if ( !ok )
  {
    std::string msg = "Not an integer value:'" + str + "'";
    throw std::invalid_argument(msg);
  }
  return val;
}


HYBRIDPlugin_Hypothesis::THYBRIDEnforcedVertexList HYBRIDPlugin_Hypothesis::GetEnforcedVertices(const HYBRIDPlugin_Hypothesis* hyp)
{
  return hyp ? hyp->_GetEnforcedVertices():THYBRIDEnforcedVertexList();
}

HYBRIDPlugin_Hypothesis::THYBRIDEnforcedVertexCoordsValues HYBRIDPlugin_Hypothesis::GetEnforcedVerticesCoordsSize (const HYBRIDPlugin_Hypothesis* hyp)
{  
  return hyp ? hyp->_GetEnforcedVerticesCoordsSize(): THYBRIDEnforcedVertexCoordsValues();
}

HYBRIDPlugin_Hypothesis::THYBRIDEnforcedVertexEntryValues HYBRIDPlugin_Hypothesis::GetEnforcedVerticesEntrySize (const HYBRIDPlugin_Hypothesis* hyp)
{  
  return hyp ? hyp->_GetEnforcedVerticesEntrySize():THYBRIDEnforcedVertexEntryValues();
}

HYBRIDPlugin_Hypothesis::TCoordsHYBRIDEnforcedVertexMap HYBRIDPlugin_Hypothesis::GetEnforcedVerticesByCoords (const HYBRIDPlugin_Hypothesis* hyp)
{  
  return hyp ? hyp->_GetEnforcedVerticesByCoords():TCoordsHYBRIDEnforcedVertexMap();
}

HYBRIDPlugin_Hypothesis::TGeomEntryHYBRIDEnforcedVertexMap HYBRIDPlugin_Hypothesis::GetEnforcedVerticesByEntry (const HYBRIDPlugin_Hypothesis* hyp)
{  
  return hyp ? hyp->_GetEnforcedVerticesByEntry():TGeomEntryHYBRIDEnforcedVertexMap();
}

HYBRIDPlugin_Hypothesis::TIDSortedNodeGroupMap HYBRIDPlugin_Hypothesis::GetEnforcedNodes(const HYBRIDPlugin_Hypothesis* hyp)
{
  return hyp ? hyp->_GetEnforcedNodes():TIDSortedNodeGroupMap();
}

HYBRIDPlugin_Hypothesis::TIDSortedElemGroupMap HYBRIDPlugin_Hypothesis::GetEnforcedEdges(const HYBRIDPlugin_Hypothesis* hyp)
{
  return hyp ? hyp->_GetEnforcedEdges():TIDSortedElemGroupMap();
}

HYBRIDPlugin_Hypothesis::TIDSortedElemGroupMap HYBRIDPlugin_Hypothesis::GetEnforcedTriangles(const HYBRIDPlugin_Hypothesis* hyp)
{
  return hyp ? hyp->_GetEnforcedTriangles():TIDSortedElemGroupMap();
}

HYBRIDPlugin_Hypothesis::TID2SizeMap HYBRIDPlugin_Hypothesis::GetNodeIDToSizeMap(const HYBRIDPlugin_Hypothesis* hyp)
{
  return hyp ? hyp->_GetNodeIDToSizeMap():TID2SizeMap();
}

HYBRIDPlugin_Hypothesis::TSetStrings HYBRIDPlugin_Hypothesis::GetGroupsToRemove(const HYBRIDPlugin_Hypothesis* hyp)
{
  return hyp ? hyp->_GetGroupsToRemove():TSetStrings();
}
