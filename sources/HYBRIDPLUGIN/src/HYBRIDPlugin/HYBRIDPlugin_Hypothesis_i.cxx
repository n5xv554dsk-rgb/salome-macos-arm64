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
// File   : HYBRIDPlugin_Hypothesis_i.cxx
// Author : Christian VAN WAMBEKE (CEA)
// ---
//
#include "HYBRIDPlugin_Hypothesis_i.hxx"

#include "SMESH_Gen.hxx"
#include "SMESH_PythonDump.hxx"
//#include "SMESH_Mesh.hxx"
//#include "SMESH_ProxyMesh.hxx"
//#include <StdMeshers_QuadToTriaAdaptor.hxx>

#include "Utils_CorbaException.hxx"
#include "utilities.h"
#include "SMESH_Mesh_i.hxx"
#include "SMESH_Group_i.hxx"
#include "SMESH_Gen_i.hxx"
#include "SMESH_TypeDefs.hxx"
#include "SMESHDS_GroupBase.hxx"

// SALOME KERNEL includes
#include "SALOMEDSClient.hxx"
#include <SALOMEDSClient_definitions.hxx>
// // IDL headers
// #include <SALOMEconfig.h>
// #include CORBA_SERVER_HEADER(SALOMEDS)

//=======================================================================
//function : HYBRIDPlugin_Hypothesis_i
//=======================================================================
HYBRIDPlugin_Hypothesis_i::HYBRIDPlugin_Hypothesis_i (PortableServer::POA_ptr thePOA,
                                                      ::SMESH_Gen*            theGenImpl)
  : SALOME::GenericObj_i( thePOA ), 
    SMESH_Hypothesis_i( thePOA )
{
  myBaseImpl = new ::HYBRIDPlugin_Hypothesis (theGenImpl->GetANewId(),
                                              theGenImpl);
}

//=======================================================================
//function : ~HYBRIDPlugin_Hypothesis_i
//=======================================================================
HYBRIDPlugin_Hypothesis_i::~HYBRIDPlugin_Hypothesis_i()
{
}

//=======================================================================
/*!
 * Sizes of boundary layers are relative to the surface size. Default no
 */
//=======================================================================

void HYBRIDPlugin_Hypothesis_i::SetHeightIsRelative( CORBA::Boolean isRelative )
{
  ASSERT(myBaseImpl);
  if ( GetImpl()->GetHeightIsRelative() != isRelative )
  {
    this->GetImpl()->SetHeightIsRelative( isRelative );
    SMESH::TPythonDump() << _this() << ".SetHeightIsRelative( " << isRelative << " )";
  }
}

CORBA::Boolean HYBRIDPlugin_Hypothesis_i::GetHeightIsRelative()
{
  return this->GetImpl()->GetHeightIsRelative();
}

//=======================================================================
/*!
 * Maximum internal angles of boundary elements (in degree)
 */
//=======================================================================

void HYBRIDPlugin_Hypothesis_i::SetBoundaryLayersMaxElemAngle( CORBA::Double angle )
{
  if ( GetImpl()->GetBoundaryLayersMaxElemAngle() != angle )
  {
    this->GetImpl()->SetBoundaryLayersMaxElemAngle( angle );
    SMESH::TPythonDump() << _this() << ".SetBoundaryLayersMaxElemAngle( " << angle << " )";
  }
}

CORBA::Double HYBRIDPlugin_Hypothesis_i::GetBoundaryLayersMaxElemAngle()
{
  return this->GetImpl()->GetBoundaryLayersMaxElemAngle();
}

//=======================================================================
//function : SetToUseLibrary
//=======================================================================

void HYBRIDPlugin_Hypothesis_i::SetToUseLibrary(CORBA::Boolean toUseLib)
{
  ASSERT(myBaseImpl);
  this->GetImpl()->SetToUseLibrary(toUseLib);
  SMESH::TPythonDump() << _this() << ".SetToUseLibrary( " << toUseLib << " )";
}

//=======================================================================
//function : GetToUseLibrary
//=======================================================================

CORBA::Boolean HYBRIDPlugin_Hypothesis_i::GetToUseLibrary()
{
  ASSERT(myBaseImpl);
  return this->GetImpl()->GetToUseLibrary();
}

//=======================================================================
//function : SetLayersOnAllWrap
//=======================================================================

void HYBRIDPlugin_Hypothesis_i::SetLayersOnAllWrap(CORBA::Boolean toMesh)
{
  ASSERT(myBaseImpl);
  this->GetImpl()->SetLayersOnAllWrap(toMesh);
  SMESH::TPythonDump() << _this() << ".SetLayersOnAllWrap( " << toMesh << " )";
}

//=======================================================================
//function : GetLayersOnAllWrap
//=======================================================================

CORBA::Boolean HYBRIDPlugin_Hypothesis_i::GetLayersOnAllWrap()
{
  ASSERT(myBaseImpl);
  return this->GetImpl()->GetLayersOnAllWrap();
}

//=======================================================================
//function : SetFacesWithLayers
//=======================================================================

void HYBRIDPlugin_Hypothesis_i::SetFacesWithLayers(const ::SMESH::long_array& theVal)
{
  std::vector<int> ids( theVal.length() );
  for ( size_t i = 0; i < ids.size(); ++i )
   ids[i] = theVal[i];

  bool valueChanged = this->GetImpl()->SetFacesWithLayers(ids);
  if (valueChanged)
    SMESH::TPythonDump() << _this() << ".SetFacesWithLayers( "<< theVal << " )";
}

//=======================================================================
//function : GetFacesWithLayers
//=======================================================================

SMESH::long_array* HYBRIDPlugin_Hypothesis_i::GetFacesWithLayers()
{
  const std::vector<int>& idsVec = this->GetImpl()->GetFacesWithLayers();
  SMESH::long_array_var ids = new SMESH::long_array;
  ids->length( idsVec.size() );
  for ( size_t i = 0; i < idsVec.size(); ++i )
    ids[i] = idsVec[i];
  return ids._retn();
}

//=======================================================================
//function : SetFacesWithImprinting
//=======================================================================

void HYBRIDPlugin_Hypothesis_i::SetFacesWithImprinting(const ::SMESH::long_array& theVal)
{
  std::vector<int> ids( theVal.length() );
  for ( size_t i = 0; i < ids.size(); ++i )
   ids[i] = theVal[i];

  bool valueChanged = this->GetImpl()->SetFacesWithImprinting(ids);
  if (valueChanged)
    SMESH::TPythonDump() << _this() << ".SetFacesWithImprinting( "<< theVal << " )";
}

//=======================================================================
//function : GetFacesWithImprinting
//=======================================================================

SMESH::long_array* HYBRIDPlugin_Hypothesis_i::GetFacesWithImprinting()
{
  const std::vector<int>& idsVec = this->GetImpl()->GetFacesWithImprinting();
  SMESH::long_array_var ids = new SMESH::long_array;
  ids->length( idsVec.size() );
  for ( size_t i = 0; i < idsVec.size(); ++i )
    ids[i] = idsVec[i];
  return ids._retn();
}

//=======================================================================
//function : SetFacesWithSnapping
//=======================================================================

void HYBRIDPlugin_Hypothesis_i::SetFacesWithSnapping(const ::SMESH::long_array& theVal)
{
  std::vector<int> ids( theVal.length() );
  for ( size_t i = 0; i < ids.size(); ++i )
   ids[i] = theVal[i];

  bool valueChanged = this->GetImpl()->SetFacesWithSnapping(ids);
  if (valueChanged)
    SMESH::TPythonDump() << _this() << ".SetFacesWithSnapping( "<< theVal << " )";
}

//=======================================================================
//function : GetFacesWithSnapping
//=======================================================================

SMESH::long_array* HYBRIDPlugin_Hypothesis_i::GetFacesWithSnapping()
{
  const std::vector<int>& idsVec = this->GetImpl()->GetFacesWithSnapping();
  SMESH::long_array_var ids = new SMESH::long_array;
  ids->length( idsVec.size() );
  for ( size_t i = 0; i < idsVec.size(); ++i )
    ids[i] = idsVec[i];
  return ids._retn();
}

//=======================================================================
//function : SetToMeshHoles
//=======================================================================

void HYBRIDPlugin_Hypothesis_i::SetToMeshHoles(CORBA::Boolean toMesh)
{
  ASSERT(myBaseImpl);
  this->GetImpl()->SetToMeshHoles(toMesh);
  SMESH::TPythonDump() << _this() << ".SetToMeshHoles( " << toMesh << " )";
}

//=======================================================================
//function : GetToMeshHoles
//=======================================================================

CORBA::Boolean HYBRIDPlugin_Hypothesis_i::GetToMeshHoles()
{
  ASSERT(myBaseImpl);
  return this->GetImpl()->GetToMeshHoles();
}

//=======================================================================
//function : SetToMakeGroupsOfDomains
//=======================================================================

void HYBRIDPlugin_Hypothesis_i::SetToMakeGroupsOfDomains(CORBA::Boolean toMakeGroups)
{
  ASSERT(myBaseImpl);
  this->GetImpl()->SetToMakeGroupsOfDomains(toMakeGroups);
  SMESH::TPythonDump() << _this() << ".SetToMakeGroupsOfDomains( " << toMakeGroups << " )";
}

//=======================================================================
//function : GetToMakeGroupsOfDomains
//=======================================================================

CORBA::Boolean HYBRIDPlugin_Hypothesis_i::GetToMakeGroupsOfDomains()
{
  ASSERT(myBaseImpl);
  return this->GetImpl()->GetToMakeGroupsOfDomains();
}

//=======================================================================
//function : SetMaximumMemory
//=======================================================================

void HYBRIDPlugin_Hypothesis_i::SetMaximumMemory(CORBA::Double MB)
{
  if ( MB == 0 )
    THROW_SALOME_CORBA_EXCEPTION( "Invalid memory size",SALOME_CMOD::BAD_PARAM );
  ASSERT(myBaseImpl);
  this->GetImpl()->SetMaximumMemory(MB);
  SMESH::TPythonDump() << _this() << ".SetMaximumMemory( " << MB << " )";
}

//=======================================================================
//function : GetMaximumMemory
//=======================================================================

CORBA::Double HYBRIDPlugin_Hypothesis_i::GetMaximumMemory()
{
  ASSERT(myBaseImpl);
  return this->GetImpl()->GetMaximumMemory();
}

//=======================================================================
//function : SetInitialMemory
//=======================================================================

void HYBRIDPlugin_Hypothesis_i::SetInitialMemory(CORBA::Double MB)
{
  if ( MB == 0 )
    THROW_SALOME_CORBA_EXCEPTION( "Invalid memory size",SALOME_CMOD::BAD_PARAM );
  ASSERT(myBaseImpl);
  this->GetImpl()->SetInitialMemory(MB);
  SMESH::TPythonDump() << _this() << ".SetInitialMemory( " << MB << " )";
}

//=======================================================================
//function : GetInitialMemory
//=======================================================================

CORBA::Double HYBRIDPlugin_Hypothesis_i::GetInitialMemory()
{
  ASSERT(myBaseImpl);
  return this->GetImpl()->GetInitialMemory();
}

//=======================================================================
//function : SetOptimizationLevel
//=======================================================================

void HYBRIDPlugin_Hypothesis_i::SetOptimizationLevel(CORBA::Short level)
{
  ::HYBRIDPlugin_Hypothesis::OptimizationLevel l =
      (::HYBRIDPlugin_Hypothesis::OptimizationLevel) level;
  if ( l < ::HYBRIDPlugin_Hypothesis::None ||
       l > ::HYBRIDPlugin_Hypothesis::Strong )
    THROW_SALOME_CORBA_EXCEPTION( "Invalid optimization level",SALOME_CMOD::BAD_PARAM );
    
  ASSERT(myBaseImpl);
  this->GetImpl()->SetOptimizationLevel(l);
  SMESH::TPythonDump() << _this() << ".SetOptimizationLevel( " << level << " )";
}

//=======================================================================
//function : GetOptimizationLevel
//=======================================================================

CORBA::Short HYBRIDPlugin_Hypothesis_i::GetOptimizationLevel()
{
  ASSERT(myBaseImpl);
  return this->GetImpl()->GetOptimizationLevel();
}


//=======================================================================
//function : SetCollisionMode
//=======================================================================
void HYBRIDPlugin_Hypothesis_i::SetCollisionMode(CORBA::Short level)
{
  ::HYBRIDPlugin_Hypothesis::CollisionMode l =
      (::HYBRIDPlugin_Hypothesis::CollisionMode) level;
  if ( l < ::HYBRIDPlugin_Hypothesis::Decrease ||
       l > ::HYBRIDPlugin_Hypothesis::Stop )
    THROW_SALOME_CORBA_EXCEPTION( "Invalid collision mode",SALOME_CMOD::BAD_PARAM );
    
  ASSERT(myBaseImpl);
  this->GetImpl()->SetCollisionMode(l);
  SMESH::TPythonDump() << _this() << ".SetCollisionMode( " << level << " )";
}

//=======================================================================
//function : GetCollisionMode
//=======================================================================
CORBA::Short HYBRIDPlugin_Hypothesis_i::GetCollisionMode()
{
  ASSERT(myBaseImpl);
  return this->GetImpl()->GetCollisionMode();
}

//=======================================================================
//function : SetWorkingDirectory
//=======================================================================
void HYBRIDPlugin_Hypothesis_i::SetWorkingDirectory(const char* path)
{
  if (!path )
    THROW_SALOME_CORBA_EXCEPTION( "Null working directory",SALOME_CMOD::BAD_PARAM );

  std::string file(path);
  const char lastChar = *file.rbegin();
#ifdef WIN32
  if ( lastChar != '\\' ) file += '\\';
#else
  if ( lastChar != '/' ) file += '/';
#endif
  file += "HYBRID.log";
  SMESH_Mesh_i::PrepareForWriting (file.c_str());

  ASSERT(myBaseImpl);
  this->GetImpl()->SetWorkingDirectory(path);
  SMESH::TPythonDump() << _this() << ".SetWorkingDirectory( '" << path << "' )";
}

//=======================================================================
//function : GetWorkingDirectory
//=======================================================================
char* HYBRIDPlugin_Hypothesis_i::GetWorkingDirectory()
{
  ASSERT(myBaseImpl);
  return CORBA::string_dup( this->GetImpl()->GetWorkingDirectory().c_str() );
}

//=======================================================================
//function : SetKeepFiles
//=======================================================================
void HYBRIDPlugin_Hypothesis_i::SetKeepFiles(CORBA::Boolean toKeep)
{
  ASSERT(myBaseImpl);
  this->GetImpl()->SetKeepFiles(toKeep);
  SMESH::TPythonDump() << _this() << ".SetKeepFiles( " << toKeep << " )";
}

//=======================================================================
//function : GetKeepFiles
//=======================================================================
CORBA::Boolean HYBRIDPlugin_Hypothesis_i::GetKeepFiles()
{
  ASSERT(myBaseImpl);
  return this->GetImpl()->GetKeepFiles();
}

//=======================================================================
//function : SetVerboseLevel
//=======================================================================
void HYBRIDPlugin_Hypothesis_i::SetVerboseLevel(CORBA::Short level)
{
  if (level < 0 || level > 10 )
    THROW_SALOME_CORBA_EXCEPTION( "Invalid verbose level, valid range is [0-10]",
                                  SALOME_CMOD::BAD_PARAM );
  ASSERT(myBaseImpl);
  this->GetImpl()->SetVerboseLevel(level);
  SMESH::TPythonDump() << _this() << ".SetVerboseLevel( " << level << " )";
}

//=======================================================================
//function : GetVerboseLevel
//=======================================================================
CORBA::Short HYBRIDPlugin_Hypothesis_i::GetVerboseLevel()
{
  ASSERT(myBaseImpl);
  return this->GetImpl()->GetVerboseLevel();
}

//=======================================================================
//function : SetToCreateNewNodes
//=======================================================================

void HYBRIDPlugin_Hypothesis_i::SetToCreateNewNodes(CORBA::Boolean toCreate)
{
  ASSERT(myBaseImpl);
  this->GetImpl()->SetToCreateNewNodes(toCreate);
  SMESH::TPythonDump() << _this() << ".SetToCreateNewNodes( " << toCreate << " )";
}

//=======================================================================
//function : GetToCreateNewNodes
//=======================================================================

CORBA::Boolean HYBRIDPlugin_Hypothesis_i::GetToCreateNewNodes()
{
  ASSERT(myBaseImpl);
  return this->GetImpl()->GetToCreateNewNodes();
}

//=======================================================================
//function : SetToUseBoundaryRecoveryVersion
//=======================================================================

void HYBRIDPlugin_Hypothesis_i::SetToUseBoundaryRecoveryVersion(CORBA::Boolean toUse)
{
  ASSERT(myBaseImpl);
  this->GetImpl()->SetToUseBoundaryRecoveryVersion(toUse);
  SMESH::TPythonDump() << _this() << ".SetToUseBoundaryRecoveryVersion( " << toUse << " )";
}

//=======================================================================
//function : GetToUseBoundaryRecoveryVersion
//=======================================================================

CORBA::Boolean HYBRIDPlugin_Hypothesis_i::GetToUseBoundaryRecoveryVersion()
{
  ASSERT(myBaseImpl);
  return this->GetImpl()->GetToUseBoundaryRecoveryVersion();
}

//=======================================================================
//function : SetFEMCorrection
//=======================================================================

void HYBRIDPlugin_Hypothesis_i::SetFEMCorrection(CORBA::Boolean toUseFem)
{
  ASSERT(myBaseImpl);
  this->GetImpl()->SetFEMCorrection(toUseFem);
  SMESH::TPythonDump() << _this() << ".SetFEMCorrection( " << toUseFem << " )";
}

//=======================================================================
//function : GetFEMCorrection
//=======================================================================

CORBA::Boolean HYBRIDPlugin_Hypothesis_i::GetFEMCorrection()
{
  ASSERT(myBaseImpl);
  return this->GetImpl()->GetFEMCorrection();
}

//=======================================================================
//function : SetToRemoveCentralPoint
//=======================================================================

void HYBRIDPlugin_Hypothesis_i::SetToRemoveCentralPoint(CORBA::Boolean toRemove)
{
  ASSERT(myBaseImpl);
  this->GetImpl()->SetToRemoveCentralPoint(toRemove);
  SMESH::TPythonDump() << _this() << ".SetToRemoveCentralPoint( " << toRemove << " )";
}

//=======================================================================
//function : GetToRemoveCentralPoint
//=======================================================================

CORBA::Boolean HYBRIDPlugin_Hypothesis_i::GetToRemoveCentralPoint()
{
  ASSERT(myBaseImpl);
  return this->GetImpl()->GetToRemoveCentralPoint();
}

//=============================================================================

void HYBRIDPlugin_Hypothesis_i::SetOptionValue(const char* optionName, const char* optionValue)
{
  ASSERT(myBaseImpl);
  try {
    std::string name( optionName );
    while ( !name.empty() && name[0] == '-' )
      name = name.substr(1);

    if ( !optionValue || !optionValue[0] )
      UnsetOption( optionName );

    // basic options (visible in Advanced table)

    else if ( name == "number_of_boundary_layers" )
      SetNbOfBoundaryLayers( GetImpl()->ToInt( optionValue ));

    else if ( name == "boundary_layer_global_initial_height" )
      SetHeightFirstLayer( GetImpl()->ToDbl( optionValue ));

    else if ( name == "boundary_layer_geometric_progression" )
      SetBoundaryLayersProgression( GetImpl()->ToDbl( optionValue ));

    else if ( name == "boundary_layer_max_element_angle" )
      SetBoundaryLayersMaxElemAngle( GetImpl()->ToDbl( optionValue ));

    else if ( name == "boundary_layer_height_relative_to_local_surface_size" )
      SetHeightIsRelative( GetImpl()->ToBool( optionValue ));

    else if ( name == "gradation" )
      SetGradation( GetImpl()->ToDbl( optionValue ));

    else if ( name == "element_generation" )
      switch ( optionValue[0] ) {
      case 't': SetElementGeneration( 0 ); break;
      case 'h': SetElementGeneration( 1 ); break;
      case 'c': SetElementGeneration( 2 ); break;
      case 'e': SetElementGeneration( 3 ); break;
      default:;
      }
    else if ( name == "collision_mode" ) // decrease|stop
      SetCollisionMode( optionValue[0] != 'd' );

    else if ( name == "add_multinormals" )
      SetAddMultinormals( GetImpl()->ToBool( optionValue ));

    else if ( name == "multinormal_angle_threshold" )
      SetMultinormalsAngle( GetImpl()->ToDbl( optionValue ));

    else if ( name == "verbose" )
      SetVerboseLevel( GetImpl()->ToInt( optionValue ));

    else if ( name == "max_memory" )
      SetMaximumMemory( GetImpl()->ToInt( optionValue ));

    else if ( name == "automatic_memory" )
      SetInitialMemory( GetImpl()->ToInt( optionValue ));

    else if ( name == "smooth_normals" )
        SetSmoothNormals( GetImpl()->ToBool( optionValue ));

    else if ( name == "optimisation" )
      switch ( optionValue[0] ) {
      case 'n': SetOptimizationLevel( 0 ); break;
      case 'y': SetOptimizationLevel( 1 ); break;
      case 'o': SetOptimizationLevel( 2 ); break;
      default:;
      }

    // advanced options (for backward compatibility)
    // else if ( name == "create_tag_on_collision" ||
    //           name == "tiny_edge_respect_geometry" )
    //   AddOption( optionName, optionValue );

    else {
      bool valueChanged = true;
      try {
        valueChanged = ( this->GetImpl()->GetOptionValue( name ) != optionValue );
      }
      catch ( std::invalid_argument& ) {
      }
      if ( valueChanged )
      {
        this->GetImpl()->SetOptionValue(optionName, optionValue);
        SMESH::TPythonDump() << _this() << ".SetOptionValue( '" << optionName << "', '" << optionValue << "' )";
      }
    }
  } catch (const std::invalid_argument& ex) {
    THROW_SALOME_CORBA_EXCEPTION( ex.what() ,SALOME_CMOD::BAD_PARAM );
  } catch (SALOME_Exception& ex) {
    THROW_SALOME_CORBA_EXCEPTION( ex.what() ,SALOME_CMOD::BAD_PARAM );
  }
}

//=============================================================================

char* HYBRIDPlugin_Hypothesis_i::GetOptionValue(const char* optionName)
{
  ASSERT(myBaseImpl);
  try {
    bool isDefault;
    return CORBA::string_dup(this->GetImpl()->GetOptionValue(optionName,&isDefault).c_str());
  } catch (const std::invalid_argument& ex) {
    THROW_SALOME_CORBA_EXCEPTION( ex.what() ,SALOME_CMOD::BAD_PARAM );
  } catch (SALOME_Exception& ex) {
    THROW_SALOME_CORBA_EXCEPTION( ex.what() ,SALOME_CMOD::BAD_PARAM );
  }
  return 0;
}

//=============================================================================

void HYBRIDPlugin_Hypothesis_i::UnsetOption(const char* optionName) {
  ASSERT(myBaseImpl);
  if ( !GetImpl()->GetOptionValue( optionName ).empty() )
  {
    this->GetImpl()->ClearOption(optionName);
    SMESH::TPythonDump() << _this() << ".UnsetOption( '" << optionName << "' )";
  }
}

//=============================================================================

HYBRIDPlugin::string_array* HYBRIDPlugin_Hypothesis_i::GetOptionValues()
{
  HYBRIDPlugin::string_array_var result = new HYBRIDPlugin::string_array();

  const ::HYBRIDPlugin_Hypothesis::TOptionValues & opts = this->GetImpl()->GetOptionValues();
  result->length(opts.size());
  int i=0;

  bool isDefault;
  ::HYBRIDPlugin_Hypothesis::TOptionValues::const_iterator opIt = opts.begin();
  for (; opIt != opts.end(); ++opIt, ++i)
  {
    std::string name_value_type = opIt->first;
    //if (!opIt->second.empty())
    {
      name_value_type += ":";
      name_value_type += GetImpl()->GetOptionValue( opIt->first, &isDefault );
      name_value_type += isDefault ? ":0" : ":1";
    }
    result[i] = CORBA::string_dup(name_value_type.c_str());
  }

  return result._retn();
}

//=============================================================================

HYBRIDPlugin::string_array* HYBRIDPlugin_Hypothesis_i::GetAdvancedOptionValues()
{
  HYBRIDPlugin::string_array_var result = new HYBRIDPlugin::string_array();

  const ::HYBRIDPlugin_Hypothesis::TOptionValues & custom_opts = this->GetImpl()->GetCustomOptionValues();
  result->length(custom_opts.size());
  int i=0;

  ::HYBRIDPlugin_Hypothesis::TOptionValues::const_iterator opIt = custom_opts.begin();
  for (; opIt != custom_opts.end(); ++opIt, ++i) {
    std::string name_value_type = opIt->first;
    if (!opIt->second.empty()) {
      name_value_type += ":";
      name_value_type += opIt->second;
      name_value_type += ":1"; // user defined
    }
    result[i] = CORBA::string_dup(name_value_type.c_str());
  }
  return result._retn();
}

//=============================================================================

void HYBRIDPlugin_Hypothesis_i::SetOptionValues(const HYBRIDPlugin::string_array& options)
{
  for (CORBA::ULong i = 0; i < options.length(); ++i)
  {
    std::string name_value_type = options[i].in();
    if(name_value_type.empty())
      continue;
    size_t colonPos = name_value_type.find(':');
    std::string name, value;
    if (colonPos == std::string::npos) // ':' not found
      name = name_value_type;
    else {
      name = name_value_type.substr(0, colonPos);
      if (colonPos < name_value_type.size() - 1 && name_value_type[colonPos] != ' ') {
        std::string value_type = name_value_type.substr(colonPos + 1);
        colonPos = value_type.find(':');
        value = value_type.substr(0, colonPos);
        if (colonPos < value_type.size() - 1 && value_type[colonPos] != ' ')
          if ( value_type.substr(colonPos + 1) == "0" ) // is default
            value.clear();
      }
    }
    SetOptionValue(name.c_str(), value.c_str());
  }
}

//=============================================================================

void HYBRIDPlugin_Hypothesis_i::SetAdvancedOptionValues(const HYBRIDPlugin::string_array& options)
{
  SMESH::TPythonDump dump;

  std::string optionsAndValues;
  for ( CORBA::ULong i = 0; i < options.length(); ++i) {
    std::string name_value_type = options[i].in();
    if(name_value_type.empty())
      continue;
    size_t colonPos = name_value_type.find(':');
    std::string name, value;
    if (colonPos == std::string::npos) // ':' not found
      name = name_value_type;
    else {
      name = name_value_type.substr(0, colonPos);
      if (colonPos < name_value_type.size() - 1 && name_value_type[colonPos] != ' ') {
        std::string value_type = name_value_type.substr(colonPos + 1);
        colonPos = value_type.find(':');
        value = value_type.substr(0, colonPos);
      }
    }
    AddOption(name.c_str(), value.c_str());

    optionsAndValues += name + " " + value + " ";
  }

  if ( !optionsAndValues.empty() )
    dump << _this() << ".SetAdvancedOptions( '" << optionsAndValues.c_str() << "' )";
}

//=============================================================================

void HYBRIDPlugin_Hypothesis_i::SetAdvancedOption(const char* optionsAndValues)
{
  if ( !optionsAndValues ) return;

  //SMESH::TPythonDump dump;

  std::istringstream strm( optionsAndValues );
  std::istream_iterator<std::string> sIt( strm ), sEnd;
  for ( int nbPairs = 0; sIt != sEnd; ++nbPairs )
  {
    std::string option = *sIt;
    if ( ++sIt != sEnd )
    {
      std::string value = *sIt;
      ++sIt;
      AddOption( option.c_str(), value.c_str() );
    }
    else
    {
      if ( nbPairs > 0 )
        THROW_SALOME_CORBA_EXCEPTION( "Uneven number of options and values" ,SALOME_CMOD::BAD_PARAM );
      AddOption( option.c_str(), "" );
    }
  }
  //dump << _this() << ".SetAdvancedOption( '" << optionsAndValues << "' )";
}

//=============================================================================

void HYBRIDPlugin_Hypothesis_i::AddOption(const char* optionName, const char* optionValue)
{
  if ( strncmp( "--", optionName, 2 ) == 0 )
    optionName += 2;

  bool valueChanged = ( !this->GetImpl()->HasOptionDefined(optionName) ||
                        this->GetImpl()->GetOptionValue(optionName) != optionValue );
  if ( valueChanged )
  {
    SetOptionValue(optionName, optionValue);

    SMESH_Comment optVal("--");
    optVal << optionName << " " << optionValue;
    std::string cmd = ::HYBRIDPlugin_Hypothesis::CommandToRun( GetImpl() );
    if ( cmd.find( optVal ) == std::string::npos )
    {
      this->GetImpl()->SetOptionValue(optionName, optionValue);
      SMESH::TPythonDump() << _this() << ".AddOption( '" << optionName << "', '" << optionValue << "' )";
    }
  }
}

//=============================================================================

char* HYBRIDPlugin_Hypothesis_i::GetOption(const char* optionName)
{
  ASSERT(myBaseImpl);
  return CORBA::string_dup(this->GetImpl()->GetOptionValue(optionName).c_str());
}

//=======================================================================
//function : SetTextOption
//=======================================================================
void HYBRIDPlugin_Hypothesis_i::SetTextOption(const char* option)
{
  ASSERT(myBaseImpl);
  this->GetImpl()->SetAdvancedOption(option);
  SMESH::TPythonDump() << _this() << ".SetAdvancedOption( '" << option << "' )";
}

//=======================================================================
//function : GetTextOption
//=======================================================================
char* HYBRIDPlugin_Hypothesis_i::GetTextOption()
{
  ASSERT(myBaseImpl);
  return CORBA::string_dup( this->GetImpl()->GetAdvancedOption().c_str() );
}

//=======================================================================
//function : GetAdvancedOption
//=======================================================================
char* HYBRIDPlugin_Hypothesis_i::GetAdvancedOption()
{
  return CORBA::string_dup( GetImpl()->GetAdvancedOption().c_str() );
}

//=======================================================================
//function : SetGradation
//=======================================================================

void HYBRIDPlugin_Hypothesis_i::SetGradation(CORBA::Double gradation)
{
  if (gradation <= 1)
    THROW_SALOME_CORBA_EXCEPTION( "The volumic gradation must be > 1",SALOME_CMOD::BAD_PARAM );
  ASSERT(myBaseImpl);
  this->GetImpl()->SetGradation(gradation);
  if (gradation != this->GetImpl()->DefaultGradation()) {
    SMESH::TPythonDump() << _this() << ".SetGradation( " << gradation << " )";
  }
}

//=======================================================================
//function : GetGradation
//=======================================================================

CORBA::Double HYBRIDPlugin_Hypothesis_i::GetGradation()
{
  ASSERT(myBaseImpl);
  return this->GetImpl()->GetGradation();
}

//=======================================================================
//function : SetStandardOutputLog
//=======================================================================
void HYBRIDPlugin_Hypothesis_i::SetStandardOutputLog(CORBA::Boolean logInStandardOutput)
{
  ASSERT(myBaseImpl);
  this->GetImpl()->SetStandardOutputLog(logInStandardOutput);
  SMESH::TPythonDump() << _this() << ".SetPrintLogInFile( " << !logInStandardOutput << " )";
}

//=======================================================================
//function : GetStandardOutputLog
//=======================================================================
CORBA::Boolean HYBRIDPlugin_Hypothesis_i::GetStandardOutputLog()
{
  ASSERT(myBaseImpl);
  return this->GetImpl()->GetStandardOutputLog();
}

//=======================================================================
//function : SetRemoveLogOnSuccess
//=======================================================================
void HYBRIDPlugin_Hypothesis_i::SetRemoveLogOnSuccess(CORBA::Boolean removeLogOnSuccess)
{
  ASSERT(myBaseImpl);
  this->GetImpl()->SetRemoveLogOnSuccess(removeLogOnSuccess);
  SMESH::TPythonDump() << _this() << ".SetRemoveLogOnSuccess( " << removeLogOnSuccess << " )";
}

//=======================================================================
//function : GetRemoveLogOnSuccess
//=======================================================================
CORBA::Boolean HYBRIDPlugin_Hypothesis_i::GetRemoveLogOnSuccess()
{
  ASSERT(myBaseImpl);
  return this->GetImpl()->GetRemoveLogOnSuccess();
}

//=======================================================================
//function : SetBoundaryLayersGrowth
//=======================================================================
void HYBRIDPlugin_Hypothesis_i::SetBoundaryLayersGrowth(CORBA::Short level)
{
  ::HYBRIDPlugin_Hypothesis::BoundaryLayersGrowth l =
      (::HYBRIDPlugin_Hypothesis::BoundaryLayersGrowth) level;
  if ( l < ::HYBRIDPlugin_Hypothesis::Layer_Growth_Inward ||
       l > ::HYBRIDPlugin_Hypothesis::Layer_Growth_Outward )
    THROW_SALOME_CORBA_EXCEPTION( "Invalid BoundaryLayersGrowth mode",SALOME_CMOD::BAD_PARAM );
    
  ASSERT(myBaseImpl);
  this->GetImpl()->SetBoundaryLayersGrowth(l);
  SMESH::TPythonDump() << _this() << ".SetBoundaryLayersGrowth( " << level << " )";
}

//=======================================================================
//function : GetBoundaryLayersGrowth
//=======================================================================
CORBA::Short HYBRIDPlugin_Hypothesis_i::GetBoundaryLayersGrowth()
{
  ASSERT(myBaseImpl);
  return this->GetImpl()->GetBoundaryLayersGrowth();
}

//=======================================================================
//function : SetElementGeneration
//=======================================================================
void HYBRIDPlugin_Hypothesis_i::SetElementGeneration(CORBA::Short level)
{
  ::HYBRIDPlugin_Hypothesis::ElementGeneration l =
      (::HYBRIDPlugin_Hypothesis::ElementGeneration) level;
  if ( l < ::HYBRIDPlugin_Hypothesis::Generation_Tetra_Dominant ||
       l > ::HYBRIDPlugin_Hypothesis::Generation_Extrusion_Only )
    THROW_SALOME_CORBA_EXCEPTION( "Invalid ElementGeneration mode",SALOME_CMOD::BAD_PARAM );
    
  ASSERT(myBaseImpl);
  this->GetImpl()->SetElementGeneration(l);
  SMESH::TPythonDump() << _this() << ".SetElementGeneration( " << level << " )";
}

//=======================================================================
//function : GetElementGeneration
//=======================================================================
CORBA::Short HYBRIDPlugin_Hypothesis_i::GetElementGeneration()
{
  ASSERT(myBaseImpl);
  return this->GetImpl()->GetElementGeneration();
}

//=======================================================================
//function : SetAddMultinormals
//=======================================================================
void HYBRIDPlugin_Hypothesis_i::SetAddMultinormals(CORBA::Boolean toAddMultinormals)
{
  ASSERT(myBaseImpl);
  this->GetImpl()->SetAddMultinormals(toAddMultinormals);
  SMESH::TPythonDump() << _this() << ".SetAddMultinormals( " << toAddMultinormals << " )";
}

//=======================================================================
//function : GetAddMultinormals
//=======================================================================
CORBA::Boolean HYBRIDPlugin_Hypothesis_i::GetAddMultinormals()
{
  ASSERT(myBaseImpl);
  return this->GetImpl()->GetAddMultinormals();
}

//=======================================================================
//function : SetSmoothNormals
//=======================================================================
void HYBRIDPlugin_Hypothesis_i::SetSmoothNormals(CORBA::Boolean toSmoothNormals)
{
  ASSERT(myBaseImpl);
  this->GetImpl()->SetSmoothNormals(toSmoothNormals);
  SMESH::TPythonDump() << _this() << ".SetSmoothNormals( " << toSmoothNormals << " )";
}

//=======================================================================
//function : GetSmoothNormals
//=======================================================================
CORBA::Boolean HYBRIDPlugin_Hypothesis_i::GetSmoothNormals()
{
  ASSERT(myBaseImpl);
  return this->GetImpl()->GetSmoothNormals();
}

//=======================================================================
//function : SetHeightFirstLayer
//=======================================================================
void HYBRIDPlugin_Hypothesis_i::SetHeightFirstLayer(CORBA::Double toHeightFirstLayer)
{
  ASSERT(myBaseImpl);
  this->GetImpl()->SetHeightFirstLayer(toHeightFirstLayer);
  SMESH::TPythonDump() << _this() << ".SetHeightFirstLayer( " << toHeightFirstLayer << " )";
}

//=======================================================================
//function : GetHeightFirstLayer
//=======================================================================
CORBA::Double HYBRIDPlugin_Hypothesis_i::GetHeightFirstLayer()
{
  ASSERT(myBaseImpl);
  return this->GetImpl()->GetHeightFirstLayer();
}

//=======================================================================
//function : SetBoundaryLayersProgression
//=======================================================================
void HYBRIDPlugin_Hypothesis_i::SetBoundaryLayersProgression(CORBA::Double toBoundaryLayersProgression)
{
  ASSERT(myBaseImpl);
  this->GetImpl()->SetBoundaryLayersProgression(toBoundaryLayersProgression);
  SMESH::TPythonDump() << _this() << ".SetBoundaryLayersProgression( " << toBoundaryLayersProgression << " )";
}

//=======================================================================
//function : GetBoundaryLayersProgression
//=======================================================================
CORBA::Double HYBRIDPlugin_Hypothesis_i::GetBoundaryLayersProgression()
{
  ASSERT(myBaseImpl);
  return this->GetImpl()->GetBoundaryLayersProgression();
}

//=======================================================================
//function : SetCoreSize
//=======================================================================
void HYBRIDPlugin_Hypothesis_i::SetCoreSize(CORBA::Double toCoreSize)
{
  ASSERT(myBaseImpl);
  this->GetImpl()->SetCoreSize(toCoreSize);
  SMESH::TPythonDump() << _this() << ".SetCoreSize( " << toCoreSize << " )";
}

//=======================================================================
//function : GetCoreSize
//=======================================================================
CORBA::Double HYBRIDPlugin_Hypothesis_i::GetCoreSize()
{
  ASSERT(myBaseImpl);
  return this->GetImpl()->GetCoreSize();
}

//=======================================================================
//function : SetMultinormalsAngle
//=======================================================================
void HYBRIDPlugin_Hypothesis_i::SetMultinormalsAngle(CORBA::Double toMultinormalsAngle)
{
  ASSERT(myBaseImpl);
  this->GetImpl()->SetMultinormalsAngle(toMultinormalsAngle);
  SMESH::TPythonDump() << _this() << ".SetMultinormalsAngle( " << toMultinormalsAngle << " )";
}

//=======================================================================
//function : GetMultinormalsAngle
//=======================================================================
CORBA::Double HYBRIDPlugin_Hypothesis_i::GetMultinormalsAngle()
{
  ASSERT(myBaseImpl);
  return this->GetImpl()->GetMultinormalsAngle();
}

//=======================================================================
//function : SetNbOfBoundaryLayers
//=======================================================================
void HYBRIDPlugin_Hypothesis_i::SetNbOfBoundaryLayers(CORBA::Short toNbOfBoundaryLayers)
{
  ASSERT(myBaseImpl);
  this->GetImpl()->SetNbOfBoundaryLayers(toNbOfBoundaryLayers);
  SMESH::TPythonDump() << _this() << ".SetNbOfBoundaryLayers( " << toNbOfBoundaryLayers << " )";
}

//=======================================================================
//function : GetNbOfBoundaryLayers
//=======================================================================
CORBA::Short HYBRIDPlugin_Hypothesis_i::GetNbOfBoundaryLayers()
{
  ASSERT(myBaseImpl);
  return this->GetImpl()->GetNbOfBoundaryLayers();
}

//=======================================================================
//function : SetEnforcedVertex
//=======================================================================

bool HYBRIDPlugin_Hypothesis_i::SetEnforcedVertex(CORBA::Double x, CORBA::Double y, CORBA::Double z, CORBA::Double size)
{
  ASSERT(myBaseImpl);
  return p_SetEnforcedVertex(size, x, y, z);
}

bool HYBRIDPlugin_Hypothesis_i::SetEnforcedVertexNamed(CORBA::Double x, CORBA::Double y, CORBA::Double z, CORBA::Double size, const char* theVertexName)
{
  ASSERT(myBaseImpl);
  return p_SetEnforcedVertex(size, x, y, z, theVertexName, "", "");
}

bool HYBRIDPlugin_Hypothesis_i::SetEnforcedVertexWithGroup(CORBA::Double x, CORBA::Double y, CORBA::Double z, CORBA::Double size, const char* theGroupName)
{
  ASSERT(myBaseImpl);
  return p_SetEnforcedVertex(size, x, y, z, "", "", theGroupName);
}

bool HYBRIDPlugin_Hypothesis_i::SetEnforcedVertexNamedWithGroup(CORBA::Double x, CORBA::Double y, CORBA::Double z, CORBA::Double size, const char* theVertexName, const char* theGroupName)
{
  ASSERT(myBaseImpl);
  return p_SetEnforcedVertex(size, x, y, z, theVertexName, "", theGroupName);
}

bool HYBRIDPlugin_Hypothesis_i::SetEnforcedVertexGeom(GEOM::GEOM_Object_ptr theVertex, CORBA::Double size)
{
  ASSERT(myBaseImpl);
  
  if ((theVertex->GetShapeType() != GEOM::VERTEX) && (theVertex->GetShapeType() != GEOM::COMPOUND)) {
    THROW_SALOME_CORBA_EXCEPTION("theVertex shape type is not VERTEX or COMPOUND", SALOME_CMOD::BAD_PARAM);
  }
  
  std::string theVertexEntry = theVertex->GetStudyEntry();
  CORBA::Double x = 0, y = 0, z = 0;
  CORBA::Boolean isCompound = false;
  GEOM::GEOM_Gen_ptr geomGen = SMESH_Gen_i::GetGeomEngine( theVertex );
  if (theVertexEntry.empty()) {
    std::string aName;
    if (theVertex->GetShapeType() == GEOM::VERTEX) {
      aName = "Vertex_";
    }
    if (theVertex->GetShapeType() == GEOM::COMPOUND) {
      aName = "Compound_";
      isCompound = true;
    }
    aName += theVertex->GetEntry();
    SALOMEDS::SObject_ptr theSVertex = geomGen->PublishInStudy(NULL, theVertex, aName.c_str());
    if (!theSVertex->_is_nil())
      theVertexEntry = theSVertex->GetID();
  }
  if (theVertexEntry.empty())
    THROW_SALOME_CORBA_EXCEPTION( "Geom object is not published in study" ,SALOME_CMOD::BAD_PARAM );

  if (theVertex->GetShapeType() == GEOM::VERTEX) {
    GEOM::GEOM_IMeasureOperations_var measureOp = geomGen->GetIMeasureOperations();
    if (CORBA::is_nil(measureOp))
      return false;
    
    measureOp->PointCoordinates (theVertex, x, y, z);
  }

  std::string theVertexName = theVertex->GetName();
  
  return p_SetEnforcedVertex(size, x, y, z, theVertexName.c_str(), theVertexEntry.c_str(), "", isCompound);
}

bool HYBRIDPlugin_Hypothesis_i::SetEnforcedVertexGeomWithGroup(GEOM::GEOM_Object_ptr theVertex, CORBA::Double size, const char* theGroupName)
{
  ASSERT(myBaseImpl);
  
  if ((theVertex->GetShapeType() != GEOM::VERTEX) && (theVertex->GetShapeType() != GEOM::COMPOUND)) {
    MESSAGE("theVertex shape type is not VERTEX or COMPOUND");
    THROW_SALOME_CORBA_EXCEPTION("theVertex shape type is not VERTEX or COMPOUND", SALOME_CMOD::BAD_PARAM);
  }
  
  std::string theVertexEntry = theVertex->GetStudyEntry();
  CORBA::Double x = 0, y = 0, z = 0;
  CORBA::Boolean isCompound = false;
  GEOM::GEOM_Gen_ptr geomGen = SMESH_Gen_i::GetGeomEngine( theVertex );
  if (theVertexEntry.empty()) {
    std::string aName;
    if (theVertex->GetShapeType() == GEOM::VERTEX) {
      aName = "Vertex_";
    }
    if (theVertex->GetShapeType() == GEOM::COMPOUND) {
      aName = "Compound_";
      isCompound = true;
    }
    aName += theVertex->GetEntry();
    SALOMEDS::SObject_ptr theSVertex = geomGen->PublishInStudy(NULL, theVertex, aName.c_str());
    if (!theSVertex->_is_nil())
      theVertexEntry = theSVertex->GetID();
  }
  if (theVertexEntry.empty())
    THROW_SALOME_CORBA_EXCEPTION( "Geom object is not published in study" ,SALOME_CMOD::BAD_PARAM );

  if (theVertex->GetShapeType() == GEOM::VERTEX) {
    GEOM::GEOM_IMeasureOperations_var measureOp = geomGen->GetIMeasureOperations();
    if (CORBA::is_nil(measureOp))
      return false;
    
    measureOp->PointCoordinates (theVertex, x, y, z);
  }
    
  std::string theVertexName = theVertex->GetName();
  
  return p_SetEnforcedVertex(size, x, y, z, theVertexName.c_str(), theVertexEntry.c_str(), theGroupName, isCompound);
}

bool HYBRIDPlugin_Hypothesis_i:: p_SetEnforcedVertex(CORBA::Double size, CORBA::Double x, CORBA::Double y, CORBA::Double z,
                                                   const char* theVertexName, const char* theVertexEntry, const char* theGroupName,
                                                   CORBA::Boolean isCompound)
{
  ASSERT(myBaseImpl);
  bool newValue = false;

  ::HYBRIDPlugin_Hypothesis::TCoordsHYBRIDEnforcedVertexMap coordsList;
  ::HYBRIDPlugin_Hypothesis::TGeomEntryHYBRIDEnforcedVertexMap enfVertexEntryList;
  if (std::string(theVertexEntry).empty()) {
    coordsList = this->GetImpl()->_GetEnforcedVerticesByCoords();
    std::vector<double> coords;
    coords.push_back(x);
    coords.push_back(y);
    coords.push_back(z);
    if (coordsList.find(coords) == coordsList.end()) {
      newValue = true;
    }
    else {
      ::HYBRIDPlugin_Hypothesis::THYBRIDEnforcedVertex *enfVertex = this->GetImpl()->GetEnforcedVertex(x, y, z);
      if ((enfVertex->name != theVertexName) || (enfVertex->groupName != theGroupName) || (enfVertex->size != size)) {
//          this->GetImpl()->ClearEnforcedVertex(theFaceEntry, x, y, z);
        newValue = true;
      }
      else {
      }
    }

    if (newValue) {
      if (std::string(theVertexName).empty()) {
        if (std::string(theGroupName).empty())
          SMESH::TPythonDump() << "isDone = " << _this() << ".SetEnforcedVertex(" << x << ", " << y << ", " << z << ", " << size << ")";
        else
          SMESH::TPythonDump() << "isDone = " << _this() << ".SetEnforcedVertexWithGroup(" << x << ", " << y << ", " << z << ", " << size << ", \"" << theGroupName << "\")";
      }
      else {
        if (std::string(theGroupName).empty())
          SMESH::TPythonDump() << "isDone = " << _this() << ".SetEnforcedVertexNamed(" << x << ", " << y << ", " << z << ", " << size  << ", \"" << theVertexName << "\")";
        else
          SMESH::TPythonDump() << "isDone = " << _this() << ".SetEnforcedVertexNamedWithGroup(" << x << ", " << y << ", " << z << ", " << size  << ", \"" << theVertexName << "\", \"" << theGroupName << "\")";
      }
    }
  } 
  else {
//   if (isCompound || (!isCompound && !std::string(theVertexEntry).empty())) {
    enfVertexEntryList = this->GetImpl()->_GetEnforcedVerticesByEntry();
//     ::BLSURFPlugin_Hypothesis::TGeomEntryHYBRIDEnforcedVertexMap::const_iterator it = enfVertexEntryList.find(theVertexEntry);
    if ( enfVertexEntryList.find(theVertexEntry) == enfVertexEntryList.end()) {
      newValue = true;
    }
    else {
      ::HYBRIDPlugin_Hypothesis::THYBRIDEnforcedVertex *enfVertex = this->GetImpl()->GetEnforcedVertex(theVertexEntry);
      if ((enfVertex->name != theVertexName) || (enfVertex->groupName != theGroupName) || (enfVertex->size != size)) {
//          this->GetImpl()->ClearEnforcedVertex(theFaceEntry, x, y, z);
        newValue = true;
      }
      else {
      }
    }

    if (newValue) {
      if (std::string(theGroupName).empty())
        SMESH::TPythonDump() << "isDone = " << _this() << ".SetEnforcedVertexGeom(" << theVertexEntry << ", " << size << ")";
      else
        SMESH::TPythonDump() << "isDone = " << _this() << ".SetEnforcedVertexGeomWithGroup(" << theVertexEntry << ", " << size << ", \"" << theGroupName << "\")";
    }
  }

  if (newValue)
    this->GetImpl()->SetEnforcedVertex(theVertexName, theVertexEntry, theGroupName, size, x, y, z, isCompound);

  return newValue;
}

//=======================================================================
//function : GetEnforcedVertex
//=======================================================================

CORBA::Double HYBRIDPlugin_Hypothesis_i::GetEnforcedVertex(CORBA::Double x, CORBA::Double y, CORBA::Double z)
{
  ASSERT(myBaseImpl);
  try {
    bool isDone = this->GetImpl()->GetEnforcedVertex(x,y,z)->size;
    SMESH::TPythonDump() << "aSize = " << _this() << ".GetEnforcedVertex(" << x << ", " << y << ", " << z << ")";
    return isDone;
  }
  catch (const std::invalid_argument& ex) {
    SALOME_CMOD::ExceptionStruct ExDescription;
    ExDescription.text = ex.what();
    ExDescription.type = SALOME_CMOD::BAD_PARAM;
    ExDescription.sourceFile = "HYBRIDPlugin_Hypothesis_i.cxx";
    ExDescription.lineNumber = 513;
    throw SALOME_CMOD::SALOME_Exception(ExDescription);
  }
  catch (SALOME_Exception& ex) {
    THROW_SALOME_CORBA_EXCEPTION( ex.what() ,SALOME_CMOD::BAD_PARAM );
  }
}

//=======================================================================
//function : GetEnforcedVertex
//=======================================================================

CORBA::Double HYBRIDPlugin_Hypothesis_i::GetEnforcedVertexGeom(GEOM::GEOM_Object_ptr theVertex)
{
  ASSERT(myBaseImpl);
  
  if ((theVertex->GetShapeType() != GEOM::VERTEX) && (theVertex->GetShapeType() != GEOM::COMPOUND)) {
    MESSAGE("theVertex shape type is not VERTEX or COMPOUND");
    THROW_SALOME_CORBA_EXCEPTION("theVertex shape type is not VERTEX or COMPOUND", SALOME_CMOD::BAD_PARAM);
  }
  
  std::string theVertexEntry = theVertex->GetStudyEntry();
  if (theVertexEntry.empty()) {
    GEOM::GEOM_Gen_ptr geomGen = SMESH_Gen_i::GetGeomEngine( theVertex );
    std::string aName;
    if (theVertex->GetShapeType() == GEOM::VERTEX)
      aName = "Vertex_";
    if (theVertex->GetShapeType() == GEOM::COMPOUND)
      aName = "Compound_";
    aName += theVertex->GetEntry();
    SALOMEDS::SObject_ptr theSVertex = geomGen->PublishInStudy(NULL, theVertex, aName.c_str());
    if (!theSVertex->_is_nil())
      theVertexEntry = theSVertex->GetID();
  }
  if (theVertexEntry.empty())
    THROW_SALOME_CORBA_EXCEPTION( "Geom object is not published in study" ,SALOME_CMOD::BAD_PARAM );

  std::string theVertexName = theVertex->GetName();
  
  try {
    bool isDone = this->GetImpl()->GetEnforcedVertex(theVertexName)->size;
    SMESH::TPythonDump() << "aSize = " << _this() << ".GetEnforcedVertexGeom(" << theVertex << ")";
    return isDone;
  }
  catch (const std::invalid_argument& ex) {
    SALOME_CMOD::ExceptionStruct ExDescription;
    ExDescription.text = ex.what();
    ExDescription.type = SALOME_CMOD::BAD_PARAM;
    ExDescription.sourceFile = "HYBRIDPlugin_Hypothesis_i.cxx";
    ExDescription.lineNumber = 538;
    throw SALOME_CMOD::SALOME_Exception(ExDescription);
  }
  catch (SALOME_Exception& ex) {
    THROW_SALOME_CORBA_EXCEPTION( ex.what() ,SALOME_CMOD::BAD_PARAM );
  }
}

//=======================================================================
//function : GetEnforcedVertices
//=======================================================================

HYBRIDPlugin::HYBRIDEnforcedVertexList* HYBRIDPlugin_Hypothesis_i::GetEnforcedVertices()
{
  ASSERT(myBaseImpl);
  HYBRIDPlugin::HYBRIDEnforcedVertexList_var result = new HYBRIDPlugin::HYBRIDEnforcedVertexList();

  const ::HYBRIDPlugin_Hypothesis::THYBRIDEnforcedVertexList enfVertexList = this->GetImpl()->_GetEnforcedVertices();
  result->length( enfVertexList.size() );

  ::HYBRIDPlugin_Hypothesis::THYBRIDEnforcedVertexList::const_iterator it = enfVertexList.begin();

  for (int i = 0 ; it != enfVertexList.end(); ++it, ++i ) {
    ::HYBRIDPlugin_Hypothesis::THYBRIDEnforcedVertex* currentVertex = (*it);
    HYBRIDPlugin::HYBRIDEnforcedVertex_var enfVertex = new HYBRIDPlugin::HYBRIDEnforcedVertex();
    // Name
    enfVertex->name = CORBA::string_dup(currentVertex->name.c_str());
    // Geom Vertex Entry
    enfVertex->geomEntry = CORBA::string_dup(currentVertex->geomEntry.c_str());
    // Coords
    HYBRIDPlugin::TCoords_var coords = new HYBRIDPlugin::TCoords();
    coords->length(currentVertex->coords.size());
    for (size_t ind = 0; ind < currentVertex->coords.size(); ind++)
      coords[ind] = currentVertex->coords[ind];
    enfVertex->coords = coords;
    // Group Name
    enfVertex->groupName = CORBA::string_dup(currentVertex->groupName.c_str());
    // Size
    enfVertex->size = currentVertex->size;
    // isCompound
    enfVertex->isCompound = currentVertex->isCompound;
    
    result[i]=enfVertex;
    }
  
//   SMESH::TPythonDump() << "allEnforcedVertices = " << _this() << ".GetEnforcedVertices()";

  return result._retn();
}

//=======================================================================
//function : RemoveEnforcedVertex
//=======================================================================

bool HYBRIDPlugin_Hypothesis_i::RemoveEnforcedVertex(CORBA::Double x, CORBA::Double y, CORBA::Double z)
{
  ASSERT(myBaseImpl);
  try {
    bool res = this->GetImpl()->RemoveEnforcedVertex(x,y,z);
    SMESH::TPythonDump() << " isDone = " << _this() << ".RemoveEnforcedVertex( " << x << ", " << y << ", " << z << " )";
    return res;
  }
  catch (const std::invalid_argument& ex) {
    SALOME_CMOD::ExceptionStruct ExDescription;
    ExDescription.text = ex.what();
    ExDescription.type = SALOME_CMOD::BAD_PARAM;
    ExDescription.sourceFile = "HYBRIDPlugin_Hypothesis_i.cxx";
    ExDescription.lineNumber = 625;
    throw SALOME_CMOD::SALOME_Exception(ExDescription);
  }
  catch (SALOME_Exception& ex) {
    THROW_SALOME_CORBA_EXCEPTION( ex.what() ,SALOME_CMOD::BAD_PARAM );
  }
}

bool HYBRIDPlugin_Hypothesis_i::RemoveEnforcedVertexGeom(GEOM::GEOM_Object_ptr theVertex)
{
  ASSERT(myBaseImpl);
  
  if ((theVertex->GetShapeType() != GEOM::VERTEX) && (theVertex->GetShapeType() != GEOM::COMPOUND)) {
    MESSAGE("theVertex shape type is not VERTEX or COMPOUND");
    THROW_SALOME_CORBA_EXCEPTION("theVertex shape type is not VERTEX or COMPOUND", SALOME_CMOD::BAD_PARAM);
  }
  
  std::string theVertexEntry = theVertex->GetStudyEntry();
  if (theVertexEntry.empty()) {
    GEOM::GEOM_Gen_ptr geomGen = SMESH_Gen_i::GetGeomEngine( theVertex );
    std::string aName;
    if (theVertex->GetShapeType() == GEOM::VERTEX)
      aName = "Vertex_";
    if (theVertex->GetShapeType() == GEOM::COMPOUND)
      aName = "Compound_";
    aName += theVertex->GetEntry();
    SALOMEDS::SObject_ptr theSVertex = geomGen->PublishInStudy(NULL, theVertex, aName.c_str());
    if (!theSVertex->_is_nil())
      theVertexEntry = theSVertex->GetID();
  }
  if (theVertexEntry.empty())
    THROW_SALOME_CORBA_EXCEPTION( "Geom object is not published in study" ,SALOME_CMOD::BAD_PARAM );
  
  try {
    bool res = this->GetImpl()->RemoveEnforcedVertex(0,0,0, theVertexEntry.c_str());
    SMESH::TPythonDump() << "isDone = " << _this() << ".RemoveEnforcedVertexGeom( " << theVertexEntry.c_str() << " )";
    return res;
  }
  catch (const std::invalid_argument& ex) {
    SALOME_CMOD::ExceptionStruct ExDescription;
    ExDescription.text = ex.what();
    ExDescription.type = SALOME_CMOD::BAD_PARAM;
    ExDescription.sourceFile = "HYBRIDPlugin_Hypothesis_i.cxx";
    ExDescription.lineNumber = 648;
    throw SALOME_CMOD::SALOME_Exception(ExDescription);
  }
  catch (SALOME_Exception& ex) {
    THROW_SALOME_CORBA_EXCEPTION( ex.what() ,SALOME_CMOD::BAD_PARAM );
  }
}

//=======================================================================
//function : ClearEnforcedVertices
//=======================================================================

void HYBRIDPlugin_Hypothesis_i::ClearEnforcedVertices()
{
  ASSERT(myBaseImpl);
  this->GetImpl()->ClearEnforcedVertices();
  SMESH::TPythonDump () << _this() << ".ClearEnforcedVertices() ";
}

//=======================================================================
//function : ClearEnforcedMeshes
//=======================================================================

void HYBRIDPlugin_Hypothesis_i::ClearEnforcedMeshes()
{
  ASSERT(myBaseImpl);
  this->GetImpl()->ClearEnforcedMeshes();
  SMESH::TPythonDump () << _this() << ".ClearEnforcedMeshes() ";
}

//=======================================================================
//function : GetEnforcedMeshes
//=======================================================================

HYBRIDPlugin::HYBRIDEnforcedMeshList* HYBRIDPlugin_Hypothesis_i::GetEnforcedMeshes()
{
  ASSERT(myBaseImpl);
  HYBRIDPlugin::HYBRIDEnforcedMeshList_var result = new HYBRIDPlugin::HYBRIDEnforcedMeshList();

  const ::HYBRIDPlugin_Hypothesis::THYBRIDEnforcedMeshList enfMeshList = this->GetImpl()->_GetEnforcedMeshes();
  result->length( enfMeshList.size() );

  ::HYBRIDPlugin_Hypothesis::THYBRIDEnforcedMeshList::const_iterator it = enfMeshList.begin();

  for (int i = 0 ; it != enfMeshList.end(); ++it, ++i ) {
    ::HYBRIDPlugin_Hypothesis::THYBRIDEnforcedMesh* currentMesh = (*it);
    HYBRIDPlugin::HYBRIDEnforcedMesh_var enfMesh = new HYBRIDPlugin::HYBRIDEnforcedMesh();
    // Name
    enfMesh->name = CORBA::string_dup(currentMesh->name.c_str());
    // Mesh Entry
    enfMesh->entry = CORBA::string_dup(currentMesh->entry.c_str());
    // isCompound
    enfMesh->elementType = currentMesh->elementType;
    // Group Name
    enfMesh->groupName = CORBA::string_dup(currentMesh->groupName.c_str());
    
    result[i]=enfMesh;
    }
  
//   SMESH::TPythonDump() << "allEnforcedVertices = " << _this() << ".GetEnforcedVertices()";

  return result._retn();
}

/*!
 * \brief Adds enforced elements of type elementType using another mesh/sub-mesh/mesh group theSource. The elements will be grouped in theGroupName.
 */
bool HYBRIDPlugin_Hypothesis_i::SetEnforcedMeshWithGroup(SMESH::SMESH_IDSource_ptr theSource, SMESH::ElementType theType, const char* theGroupName)
{
// #if HYBRID_VERSION >= 42
  return p_SetEnforcedMesh(theSource, theType, "", theGroupName);
// #else
//   SALOME_CMOD::ExceptionStruct ExDescription;
//   ExDescription.text = "Bad version of HYBRID. It must >= 4.2.";
//   ExDescription.type = SALOME_CMOD::BAD_PARAM;
//   ExDescription.sourceFile = "HYBRIDPlugin_Hypothesis_i.cxx";
//   ExDescription.lineNumber = 719;
//   throw SALOME_CMOD::SALOME_Exception(ExDescription);
// #endif
}

/*!
 * \brief Adds enforced elements of type elementType using another mesh/sub-mesh/mesh group theSource.
 */
bool HYBRIDPlugin_Hypothesis_i::SetEnforcedMesh(SMESH::SMESH_IDSource_ptr theSource, SMESH::ElementType theType)
{
// #if HYBRID_VERSION >= 42
  return p_SetEnforcedMesh(theSource, theType);
// #else
//   SALOME_CMOD::ExceptionStruct ExDescription;
//   ExDescription.text = "Bad version of HYBRID. It must >= 4.2.";
//   ExDescription.type = SALOME_CMOD::BAD_PARAM;
//   ExDescription.sourceFile = "HYBRIDPlugin_Hypothesis_i.cxx";
//   ExDescription.lineNumber = 750;
//   throw SALOME_CMOD::SALOME_Exception(ExDescription);
// #endif
}

/*!
 * \brief OBSOLETE FUNCTION - Adds enforced elements of type elementType using another mesh/sub-mesh/mesh group theSource and a size. The elements will be grouped in theGroupName.
 */
bool HYBRIDPlugin_Hypothesis_i::SetEnforcedMeshSizeWithGroup(SMESH::SMESH_IDSource_ptr theSource, SMESH::ElementType theType, double /*theSize*/, const char* theGroupName)
{
// #if HYBRID_VERSION >= 42
  return p_SetEnforcedMesh(theSource, theType, "", theGroupName);
// #else
//   SALOME_CMOD::ExceptionStruct ExDescription;
//   ExDescription.text = "Bad version of HYBRID. It must >= 4.2.";
//   ExDescription.type = SALOME_CMOD::BAD_PARAM;
//   ExDescription.sourceFile = "HYBRIDPlugin_Hypothesis_i.cxx";
//   ExDescription.lineNumber = 750;
//   throw SALOME_CMOD::SALOME_Exception(ExDescription);
// #endif
}

/*!
 * \brief OBSOLETE FUNCTION - Adds enforced elements of type elementType using another mesh/sub-mesh/mesh group theSource and a size.
 */
bool HYBRIDPlugin_Hypothesis_i::SetEnforcedMeshSize(SMESH::SMESH_IDSource_ptr theSource, SMESH::ElementType theType, double /*theSize*/)
{
// #if HYBRID_VERSION >= 42
  return p_SetEnforcedMesh(theSource, theType);
// #else
//   SALOME_CMOD::ExceptionStruct ExDescription;
//   ExDescription.text = "Bad version of HYBRID. It must >= 4.2.";
//   ExDescription.type = SALOME_CMOD::BAD_PARAM;
//   ExDescription.sourceFile = "HYBRIDPlugin_Hypothesis_i.cxx";
//   ExDescription.lineNumber = 750;
//   throw SALOME_CMOD::SALOME_Exception(ExDescription);
// #endif
}

bool HYBRIDPlugin_Hypothesis_i::p_SetEnforcedMesh(SMESH::SMESH_IDSource_ptr theSource, SMESH::ElementType theType, const char* theName, const char* theGroupName)
{
  ASSERT(myBaseImpl);
  
  if (CORBA::is_nil( theSource ))
  {
    SALOME_CMOD::ExceptionStruct ExDescription;
    ExDescription.text = "The source mesh CORBA object is NULL";
    ExDescription.type = SALOME_CMOD::BAD_PARAM;
    ExDescription.sourceFile = "HYBRIDPlugin_Hypothesis_i.cxx";
    ExDescription.lineNumber = 840;
    throw SALOME_CMOD::SALOME_Exception(ExDescription);
  }
  
  switch (theType) {
    case SMESH::NODE:
      break;
    case SMESH::EDGE:
      break;
    case SMESH::FACE:
      break;
    default:
      return false;
  }
  SMESH::array_of_ElementType_var types = theSource->GetTypes();
  if ( types->length() >= 1 && types[types->length()-1] <  theType)
  {
    return false;
//     SALOME_CMOD::ExceptionStruct ExDescription;
//     ExDescription.text = "The source mesh has bad type";
//     ExDescription.type = SALOME_CMOD::BAD_PARAM;
//     ExDescription.sourceFile = "HYBRIDPlugin_Hypothesis_i.cxx";
//     ExDescription.lineNumber = 840;
//     throw SALOME_CMOD::SALOME_Exception(ExDescription);
  }


  SMESH_Gen_i *smeshGen = SMESH_Gen_i::GetSMESHGen();
  SALOMEDS::SObject_ptr SObj = smeshGen->ObjectToSObject(theSource);

  SMESH_Mesh_i* theMesh_i = SMESH::DownCast<SMESH_Mesh_i*>( theSource);
  SMESH_Group_i* theGroup_i = SMESH::DownCast<SMESH_Group_i*>( theSource);
  SMESH_GroupOnGeom_i* theGroupOnGeom_i = SMESH::DownCast<SMESH_GroupOnGeom_i*>( theSource);

  std::string enfMeshName = theName;
  if (enfMeshName.empty())
    enfMeshName = SObj->GetName();

  if (theMesh_i)
  {
    try {
      bool res = this->GetImpl()->SetEnforcedMesh(theMesh_i->GetImpl(), theType, enfMeshName , SObj->GetID(), theGroupName);
      if (theGroupName && theGroupName[0]) {
        SMESH::TPythonDump () << "isDone = " << _this() << ".SetEnforcedMeshWithGroup( "
                              << theSource << ".GetMesh(), " << theType << ", \"" << theGroupName << "\" )";
      }
      else {
        SMESH::TPythonDump () << "isDone = " << _this() << ".SetEnforcedMesh( "
                              << theSource << ".GetMesh(), " << theType << " )";
      }

      return res;
    }
    catch (const std::invalid_argument& ex) {
      SALOME_CMOD::ExceptionStruct ExDescription;
      ExDescription.text = ex.what();
      ExDescription.type = SALOME_CMOD::BAD_PARAM;
      ExDescription.sourceFile = "HYBRIDPlugin_Hypothesis_i.cxx";
      ExDescription.lineNumber = 840;
      throw SALOME_CMOD::SALOME_Exception(ExDescription);
    }
    catch (SALOME_Exception& ex) {
      THROW_SALOME_CORBA_EXCEPTION( ex.what() ,SALOME_CMOD::BAD_PARAM );
    }
  }
  else if (theGroup_i)// && types->length() == 1 && types[0] == theType)
  {
    try {
        bool res = this->GetImpl()->SetEnforcedGroup(theGroup_i->GetGroupDS()->GetMesh(), theGroup_i->GetListOfID(), theType, enfMeshName , SObj->GetID(), theGroupName);
        if (theGroupName && theGroupName[0]) {
          SMESH::TPythonDump () << "isDone = " << _this() << ".SetEnforcedMeshWithGroup( " 
                                << theSource << ", " << theType << ", \"" << theGroupName << "\" )";
        }
        else {
          SMESH::TPythonDump () << "isDone = " << _this() << ".SetEnforcedMesh( " 
                                << theSource << ", " << theType << " )";
        }
      return res;
    }
    catch (const std::invalid_argument& ex) {
      SALOME_CMOD::ExceptionStruct ExDescription;
      ExDescription.text = ex.what();
      ExDescription.type = SALOME_CMOD::BAD_PARAM;
      ExDescription.sourceFile = "HYBRIDPlugin_Hypothesis_i.cxx";
      ExDescription.lineNumber = 840;
      throw SALOME_CMOD::SALOME_Exception(ExDescription);
    }
    catch (SALOME_Exception& ex) {
      THROW_SALOME_CORBA_EXCEPTION( ex.what() ,SALOME_CMOD::BAD_PARAM );
    }
  }
  else if (theGroupOnGeom_i)// && types->length() == 1 && types[0] == theType)
  {
      try {
        bool res = this->GetImpl()->SetEnforcedGroup(theGroupOnGeom_i->GetGroupDS()->GetMesh(),theGroupOnGeom_i->GetListOfID(), theType, enfMeshName , SObj->GetID(), theGroupName);
        if (theGroupName && theGroupName[0]) {
          SMESH::TPythonDump () << "isDone = " << _this() << ".SetEnforcedMeshWithGroup( "
                                << theSource << ", " << theType << ", \"" << theGroupName << "\" )";
        }
        else {
          SMESH::TPythonDump () << "isDone = " << _this() << ".SetEnforcedMesh( "
                                << theSource << ", " << theType << " )";
        }
        return res;
      }
      catch (const std::invalid_argument& ex) {
        SALOME_CMOD::ExceptionStruct ExDescription;
      ExDescription.text = ex.what();
      ExDescription.type = SALOME_CMOD::BAD_PARAM;
      ExDescription.sourceFile = "HYBRIDPlugin_Hypothesis_i.cxx";
      ExDescription.lineNumber = 840;
      throw SALOME_CMOD::SALOME_Exception(ExDescription);
    }
    catch (SALOME_Exception& ex) {
      THROW_SALOME_CORBA_EXCEPTION( ex.what() ,SALOME_CMOD::BAD_PARAM );
    }
  }
  return false;
}
//=============================================================================
/*!
 *  Get implementation
 */
//=============================================================================

::HYBRIDPlugin_Hypothesis* HYBRIDPlugin_Hypothesis_i::GetImpl()
{
  return (::HYBRIDPlugin_Hypothesis*)myBaseImpl;
}

//================================================================================
/*!
 * \brief Verify whether hypothesis supports given entity type 
 */
//================================================================================  

CORBA::Boolean HYBRIDPlugin_Hypothesis_i::IsDimSupported( SMESH::Dimension type )
{
  return type == SMESH::DIM_3D;
}

