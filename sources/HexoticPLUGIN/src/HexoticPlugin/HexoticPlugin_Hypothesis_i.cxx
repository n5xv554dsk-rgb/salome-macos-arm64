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
// File   : HexoticPlugin_Hypothesis_i.cxx
// Author : Lioka RAZAFINDRAZAKA (CEA)
// ---
//
#include "HexoticPlugin_Hypothesis_i.hxx"
#include "SMESH_Mesh_i.hxx"
#include "SMESH_Gen.hxx"
#include "SMESH_PythonDump.hxx"

#include "Utils_CorbaException.hxx"
#include "utilities.h"

//=============================================================================
/*!
 *  HexoticPlugin_Hypothesis_i::HexoticPlugin_Hypothesis_i
 *
 *  Constructor
 */
//=============================================================================
HexoticPlugin_Hypothesis_i::
HexoticPlugin_Hypothesis_i (PortableServer::POA_ptr thePOA,
                            ::SMESH_Gen*            theGenImpl)
  : SALOME::GenericObj_i( thePOA ),
    SMESH_Hypothesis_i( thePOA )
{
  myBaseImpl = new ::HexoticPlugin_Hypothesis (theGenImpl->GetANewId(),
                                               theGenImpl);
}

//=============================================================================
/*!
 *  HexoticPlugin_Hypothesis_i::~HexoticPlugin_Hypothesis_i
 *
 *  Destructor
 */
//=============================================================================
HexoticPlugin_Hypothesis_i::~HexoticPlugin_Hypothesis_i()
{
}

//=============================================================================
/*!
 *  HexoticPlugin_Hypothesis_i::SetHexesMinLevel
 *  HexoticPlugin_Hypothesis_i::SetHexesMaxLevel
 *  HexoticPlugin_Hypothesis_i::SetMinSize
 *  HexoticPlugin_Hypothesis_i::SetMaxSize
 *  HexoticPlugin_Hypothesis_i::SetHexoticIgnoreRidges
 *  HexoticPlugin_Hypothesis_i::SetHexoticInvalidElements
 *  HexoticPlugin_Hypothesis_i::SetHexoticSharpAngleThreshold
 *  HexoticPlugin_Hypothesis_i::SetHexoticNbProc
 *  HexoticPlugin_Hypothesis_i::SetHexoticWorkingDirectory
 *  HexoticPlugin_Hypothesis_i::SetHexoticSdMode
 *  HexoticPlugin_Hypothesis_i::SetVerbosity
 *  HexoticPlugin_Hypothesis_i::SetHexoticMaxMemory
 *  HexoticPlugin_Hypothesis_i::SetTextOptions
 *  HexoticPlugin_Hypothesis_i::SetNbLayers
 *  HexoticPlugin_Hypothesis_i::SetFirstLayerSize
 *  HexoticPlugin_Hypothesis_i::SetDirection
 *  HexoticPlugin_Hypothesis_i::SetGrowth
 *  HexoticPlugin_Hypothesis_i::SetFacesWithLayers
 *  HexoticPlugin_Hypothesis_i::SetImprintedFaces
 */
//=============================================================================

void HexoticPlugin_Hypothesis_i::SetHexesMinLevel (CORBA::Long theValue)
{
  ASSERT(myBaseImpl);
  CORBA::Long oldValue = GetHexesMinLevel();
  this->GetImpl()->SetHexesMinLevel(theValue);
  if (theValue != oldValue)
    SMESH::TPythonDump() << _this() << ".SetHexesMinLevel( " << theValue << " )";
}

void HexoticPlugin_Hypothesis_i::SetHexesMaxLevel (CORBA::Long theValue)
{
  ASSERT(myBaseImpl);
  CORBA::Long oldValue = GetHexesMaxLevel();
  this->GetImpl()->SetHexesMaxLevel(theValue);
  if (theValue != oldValue)
    SMESH::TPythonDump() << _this() << ".SetHexesMaxLevel( " << theValue << " )";
}

void HexoticPlugin_Hypothesis_i::SetMinSize (CORBA::Double theValue)
{
  ASSERT(myBaseImpl);
  CORBA::Double oldValue = GetMinSize();
  this->GetImpl()->SetMinSize(theValue);
  if (theValue != oldValue)
    SMESH::TPythonDump() << _this() << ".SetMinSize( " << theValue << " )";
}

void HexoticPlugin_Hypothesis_i::SetMaxSize (CORBA::Double theValue)
{
  ASSERT(myBaseImpl);
  CORBA::Double oldValue = GetMaxSize();
  this->GetImpl()->SetMaxSize(theValue);
  if (theValue != oldValue)
    SMESH::TPythonDump() << _this() << ".SetMaxSize( " << theValue << " )";
}

void HexoticPlugin_Hypothesis_i::SetGeomApproxAngle(CORBA::Double angle)
{
  CORBA::Double oldValue = GetGeomApproxAngle();
  this->GetImpl()->SetGeomApproxAngle( angle );
  if (angle != oldValue)
    SMESH::TPythonDump() << _this() << ".SetGeomApproxAngle( " << angle << " )";
}

CORBA::Double HexoticPlugin_Hypothesis_i::GetGeomApproxAngle()
{
  return this->GetImpl()->GetGeomApproxAngle();
}

void HexoticPlugin_Hypothesis_i::SetHexoticIgnoreRidges (CORBA::Boolean theValue)
{
  ASSERT(myBaseImpl);
  CORBA::Boolean oldValue = GetHexoticIgnoreRidges();
  this->GetImpl()->SetHexoticIgnoreRidges(theValue);
  if (theValue != oldValue)
    SMESH::TPythonDump() << _this() << ".SetHexoticIgnoreRidges( " << theValue << " )";
}

void HexoticPlugin_Hypothesis_i::SetHexoticInvalidElements (CORBA::Boolean theValue)
{
  ASSERT(myBaseImpl);
  CORBA::Boolean oldValue = GetHexoticInvalidElements();
  this->GetImpl()->SetHexoticInvalidElements(theValue);
  if (theValue != oldValue)
    SMESH::TPythonDump() << _this() << ".SetHexoticInvalidElements( " << theValue << " )";
}

void HexoticPlugin_Hypothesis_i::SetHexoticSharpAngleThreshold (CORBA::Double theValue)
{
  ASSERT(myBaseImpl);
  CORBA::Double oldValue = GetHexoticSharpAngleThreshold();
  this->GetImpl()->SetHexoticSharpAngleThreshold(theValue);
  if (theValue != oldValue)
    SMESH::TPythonDump() << _this() << ".SetHexoticSharpAngleThreshold( " << theValue << " )";
}

void HexoticPlugin_Hypothesis_i::SetHexoticNbProc (CORBA::Long theValue)
{
  ASSERT(myBaseImpl);
  CORBA::Long oldValue = GetHexoticNbProc();
  this->GetImpl()->SetHexoticNbProc(theValue);
  if (theValue != oldValue)
    SMESH::TPythonDump() << _this() << ".SetHexoticNbProc( " << theValue << " )";
}

void HexoticPlugin_Hypothesis_i::SetHexoticWorkingDirectory(const char* path)
{
  if (!path )
    THROW_SALOME_CORBA_EXCEPTION( "Null working directory",SALOME_CMOD::BAD_PARAM );

  ASSERT(myBaseImpl);
  std::string file(path);
  std::string oldValue(GetHexoticWorkingDirectory());
  bool doDump = false;
  if (oldValue != file)
    doDump = true;

  const char lastChar = *file.rbegin();
#ifdef WIN32
  if ( lastChar != '\\' ) file += '\\';
#else
  if ( lastChar != '/' ) file += '/';
#endif
  file += "Hexotic_In.mesh";
  SMESH_Mesh_i::PrepareForWriting (file.c_str());

  this->GetImpl()->SetHexoticWorkingDirectory(path);
  if (doDump)
    SMESH::TPythonDump() << _this() << ".SetHexoticWorkingDirectory( '" << path << "' )";
}

void HexoticPlugin_Hypothesis_i::SetKeepFiles(::CORBA::Boolean toKeep)
{
  if ( GetKeepFiles() != toKeep )
  {
    this->GetImpl()->SetKeepFiles(toKeep);
    SMESH::TPythonDump() << _this() << ".SetKeepFiles( " << toKeep << " )";
  }
}

::CORBA::Boolean HexoticPlugin_Hypothesis_i::GetKeepFiles()
{
  return this->GetImpl()->GetKeepFiles();
}

void HexoticPlugin_Hypothesis_i::SetStandardOutputLog(::CORBA::Boolean logInStandardOutput)
{
  if ( GetStandardOutputLog() != logInStandardOutput )
  {
    this->GetImpl()->SetStandardOutputLog(logInStandardOutput);
    SMESH::TPythonDump() << _this() << ".SetStandardOutputLog( " << logInStandardOutput << " )";
  }
}

::CORBA::Boolean HexoticPlugin_Hypothesis_i::GetStandardOutputLog()
{
  return this->GetImpl()->GetStandardOutputLog();
}

void HexoticPlugin_Hypothesis_i::SetRemoveLogOnSuccess(::CORBA::Boolean removeLogOnSuccess)
{
  if ( GetRemoveLogOnSuccess() != removeLogOnSuccess )
  {
    this->GetImpl()->SetRemoveLogOnSuccess(removeLogOnSuccess);
    SMESH::TPythonDump() << _this() << ".SetRemoveLogOnSuccess( " << removeLogOnSuccess << " )";
  }
}

::CORBA::Boolean HexoticPlugin_Hypothesis_i::GetRemoveLogOnSuccess()
{
  return this->GetImpl()->GetRemoveLogOnSuccess();
}

void HexoticPlugin_Hypothesis_i::SetHexoticSdMode (CORBA::Long theValue)
{
  ASSERT(myBaseImpl);
  CORBA::Long oldValue = GetHexoticSdMode();
  this->GetImpl()->SetHexoticSdMode(theValue);
  if (theValue != oldValue)
    SMESH::TPythonDump() << _this() << ".SetHexoticSdMode( " << theValue << " )";
}

void HexoticPlugin_Hypothesis_i::SetHexoticVerbosity (CORBA::Long theValue)
{
  ASSERT(myBaseImpl);
  CORBA::Long oldValue = GetHexoticVerbosity();
  this->GetImpl()->SetHexoticVerbosity(theValue);
  if (theValue != oldValue)
    SMESH::TPythonDump() << _this() << ".SetHexoticVerbosity( " << theValue << " )";
}

void HexoticPlugin_Hypothesis_i::SetHexoticMaxMemory (CORBA::Long theValue)
{
  ASSERT(myBaseImpl);
  CORBA::Long oldValue = GetHexoticMaxMemory();
  this->GetImpl()->SetHexoticMaxMemory(theValue);
  if (theValue != oldValue)
    SMESH::TPythonDump() << _this() << ".SetHexoticMaxMemory( " << theValue << " )";
}

void HexoticPlugin_Hypothesis_i::SetOptionValue(const char* optionName, const char* optionValue)
{
  ASSERT(myBaseImpl);
  try {
    std::string name( optionName );
    if ( !optionValue || !optionValue[0] )
      UnsetOption( optionName );

    // options having corresponding methods

    else if ( name == "max_memory" )
      SetHexoticMaxMemory( GetImpl()->ToInt( optionValue ));

    else if ( name == "min_level" )
      SetHexesMinLevel( GetImpl()->ToInt( optionValue ));

    else if ( name == "max_level" )
      SetHexesMaxLevel( GetImpl()->ToInt( optionValue ));

    else if ( name == "min_size" )
      SetMinSize( GetImpl()->ToDbl( optionValue ));

    else if ( name == "max_size" )
      SetMaxSize( GetImpl()->ToDbl( optionValue ));

    else if ( name == "ridge_angle" )
      SetHexoticSharpAngleThreshold( GetImpl()->ToDbl( optionValue ));

    else if ( name == "compute_ridges" )
      SetHexoticIgnoreRidges( ! GetImpl()->ToBool( optionValue ));

    else if ( name == "allow_invalid_elements" )
      SetHexoticInvalidElements( GetImpl()->ToBool( optionValue ));

    else if ( name == "max_number_of_threads" )
      SetHexoticNbProc( GetImpl()->ToInt( optionValue ));

    else if ( name == "verbose" )
      SetHexoticVerbosity( GetImpl()->ToInt( optionValue ));

    // advanced options (for backward compatibility)
    // else if ( name == "create_tag_on_collision" ||
    //           name == "tiny_edge_respect_geometry" )
    //   AddOption( optionName, optionValue );

    else {
      bool valueChanged = true, isDefault;
      try {
        valueChanged = ( this->GetImpl()->GetOptionValue( name, &isDefault ) != optionValue );
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

char* HexoticPlugin_Hypothesis_i::GetOptionValue(const char* optionName)
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

void HexoticPlugin_Hypothesis_i::UnsetOption(const char* optionName) {
  ASSERT(myBaseImpl);
  if ( !GetImpl()->GetOptionValue( optionName ).empty() )
  {
    this->GetImpl()->ClearOption(optionName);
    SMESH::TPythonDump() << _this() << ".UnsetOption( '" << optionName << "' )";
  }
}

//=============================================================================

HexoticPLUGIN::string_array* HexoticPlugin_Hypothesis_i::GetOptionValues()
{
  HexoticPLUGIN::string_array_var result = new HexoticPLUGIN::string_array();

  const ::HexoticPlugin_Hypothesis::TOptionValues & opts = this->GetImpl()->GetOptionValues();
  result->length(opts.size());
  int i=0;

  bool isDefault;
  ::HexoticPlugin_Hypothesis::TOptionValues::const_iterator opIt = opts.begin();
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

HexoticPLUGIN::string_array* HexoticPlugin_Hypothesis_i::GetAdvancedOptionValues()
{
  HexoticPLUGIN::string_array_var result = new HexoticPLUGIN::string_array();

  const ::HexoticPlugin_Hypothesis::TOptionValues & custom_opts = this->GetImpl()->GetCustomOptionValues();
  result->length(custom_opts.size());
  int i=0;

  ::HexoticPlugin_Hypothesis::TOptionValues::const_iterator opIt = custom_opts.begin();
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

void HexoticPlugin_Hypothesis_i::SetOptionValues(const HexoticPLUGIN::string_array& options)
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

void HexoticPlugin_Hypothesis_i::SetAdvancedOptionValues(const HexoticPLUGIN::string_array& options)
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

void HexoticPlugin_Hypothesis_i::SetAdvancedOption(const char* optionsAndValues)
{
  if ( !optionsAndValues ) return;

  SMESH::TPythonDump dump;

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
  dump << _this() << ".SetAdvancedOption( '" << optionsAndValues << "' )";
}

//=============================================================================

void HexoticPlugin_Hypothesis_i::AddOption(const char* optionName, const char* optionValue)
{
  ASSERT(myBaseImpl);
  bool valueChanged = ( !this->GetImpl()->HasOptionDefined(optionName) ||
                        this->GetImpl()->GetOptionValue(optionName) != optionValue );
  if (valueChanged) {
    this->GetImpl()->SetOptionValue(optionName, optionValue);
    SMESH::TPythonDump() << _this() << ".SetOptionValue( '" << optionName << "', '" << optionValue << "' )";
  }
}

//=============================================================================

char* HexoticPlugin_Hypothesis_i::GetOption(const char* optionName)
{
  ASSERT(myBaseImpl);
  return CORBA::string_dup(this->GetImpl()->GetOptionValue(optionName).c_str());
}

void HexoticPlugin_Hypothesis_i::SetTextOptions(const char* theOptions)
{
  ASSERT(myBaseImpl);
  std::string oldValue(GetAdvancedOption());
  this->GetImpl()->SetAdvancedOption(theOptions);
  if (theOptions != oldValue)
    SMESH::TPythonDump() << _this() << ".SetAdvancedOption( '" << theOptions << "' )";
}

HexoticPLUGIN::HexoticPluginSizeMapsList* HexoticPlugin_Hypothesis_i::GetSizeMaps ()
{
  // Get the std::map < std::string entry, double size >
  HexoticPLUGIN::HexoticPluginSizeMapsList_var result = new HexoticPLUGIN::HexoticPluginSizeMapsList();
  const ::HexoticPlugin_Hypothesis::THexoticSizeMaps sizeMaps = this->GetImpl()->GetSizeMaps();
  result->length( sizeMaps.size() );

  // Write the content into a CORBA sequence of struct{ entry=anEntry; size=aSize; }
  ::HexoticPlugin_Hypothesis::THexoticSizeMaps::const_iterator it = sizeMaps.begin();
  for ( int i = 0; it != sizeMaps.end(); i++, it++ )
  {
    HexoticPLUGIN::HexoticPluginSizeMap_var aSizeMap = new HexoticPLUGIN::HexoticPluginSizeMap();
    aSizeMap->entry = CORBA::string_dup( it->first.c_str() );
    aSizeMap->size = it->second;
    result[i] = aSizeMap;
  }
  return result._retn();
}

void HexoticPlugin_Hypothesis_i::SetSizeMapEntry ( const char* theEntry, CORBA::Double theSize )
{
  bool valueChanged = this->GetImpl()->AddSizeMap(theEntry, theSize);
  if (valueChanged)
    SMESH::TPythonDump() << _this() << ".SetSizeMap( "<< theEntry << ", " << theSize << " )";
}

void HexoticPlugin_Hypothesis_i::UnsetSizeMapEntry ( const char* theEntry )
{
  bool entryRemoved = this->GetImpl()->UnsetSizeMap(theEntry);
  if (entryRemoved)
    SMESH::TPythonDump() << _this() << ".UnsetSizeMap( "<< theEntry << " )";
}

void HexoticPlugin_Hypothesis_i::SetSizeMap (const GEOM::GEOM_Object_ptr theGeomObj, const double theSize)
{
  ASSERT(myBaseImpl);
  std::string entry = theGeomObj->GetStudyEntry();
  SetSizeMapEntry( entry.c_str(), theSize);
}

void HexoticPlugin_Hypothesis_i::UnsetSizeMap (const GEOM::GEOM_Object_ptr theGeomObj)
{
  ASSERT(myBaseImpl);
  std::string entry = theGeomObj->GetStudyEntry();
  UnsetSizeMapEntry( entry.c_str());
}

void HexoticPlugin_Hypothesis_i::SetNbLayers(CORBA::Long theVal)
{
  ASSERT(myBaseImpl);
  CORBA::Long oldValue = GetNbLayers();
  this->GetImpl()->SetNbLayers(theVal);
  if (theVal != oldValue)
    SMESH::TPythonDump() << _this() << ".SetNbLayers( " << theVal << " )";
}

void HexoticPlugin_Hypothesis_i::SetFirstLayerSize(CORBA::Double theVal)
{
  ASSERT(myBaseImpl);
  CORBA::Double oldValue = GetFirstLayerSize();
  this->GetImpl()->SetFirstLayerSize(theVal);
  if (theVal != oldValue)
    SMESH::TPythonDump() << _this() << ".SetFirstLayerSize( " << theVal << " )";
}

void HexoticPlugin_Hypothesis_i::SetDirection(CORBA::Boolean theVal)
{
  ASSERT(myBaseImpl);
  CORBA::Boolean oldValue = GetDirection();
  this->GetImpl()->SetDirection(theVal);
  if (theVal != oldValue)
    SMESH::TPythonDump() << _this() << ".SetDirection( " << theVal << " )";
}

void HexoticPlugin_Hypothesis_i::SetGrowth(CORBA::Double theVal)
{
  ASSERT(myBaseImpl);
  CORBA::Double oldValue = GetGrowth();
  this->GetImpl()->SetGrowth(theVal);
  if (theVal != oldValue)
    SMESH::TPythonDump() << _this() << ".SetGrowth( " << theVal << " )";
}

void HexoticPlugin_Hypothesis_i::SetFacesWithLayers(const ::SMESH::long_array& theVal)
{
  std::vector<int> ids( theVal.length() );
  for ( unsigned i = 0; i < ids.size(); ++i )
   ids[i] = theVal[i];

  bool valueChanged = this->GetImpl()->SetFacesWithLayers(ids);
  if (valueChanged)
    SMESH::TPythonDump() << _this() << ".SetFacesWithLayers( "<< theVal << " )";
}

void HexoticPlugin_Hypothesis_i::SetImprintedFaces(const ::SMESH::long_array& theVal)
{
  std::vector<int> ids( theVal.length() );
  for ( unsigned i = 0; i < ids.size(); ++i )
   ids[i] = theVal[i];

  bool valueChanged = this->GetImpl()->SetImprintedFaces(ids);
  if (valueChanged)
    SMESH::TPythonDump() << _this() << ".SetImprintedFaces( "<< theVal << " )";
}

//=============================================================================
/*!
 *  HexoticPlugin_Hypothesis_i::GetHexesMinLevel
 *  HexoticPlugin_Hypothesis_i::GetHexesMaxLevel
 *  HexoticPlugin_Hypothesis_i::GetMinSize
 *  HexoticPlugin_Hypothesis_i::GetMaxSize
 *  HexoticPlugin_Hypothesis_i::GetHexoticIgnoreRidges
 *  HexoticPlugin_Hypothesis_i::GetHexoticInvalidElements
 *  HexoticPlugin_Hypothesis_i::GetHexoticSharpAngleThreshold
 *  HexoticPlugin_Hypothesis_i::GetHexoticNbProc
 *  HexoticPlugin_Hypothesis_i::GetHexoticWorkingDirectory
 *  HexoticPlugin_Hypothesis_i::GetHexoticSdMode
 *  HexoticPlugin_Hypothesis_i::GetVerbosity
 *  HexoticPlugin_Hypothesis_i::GetHexoticMaxMemory
 *  HexoticPlugin_Hypothesis_i::GetTextOptions
 *  HexoticPlugin_Hypothesis_i::GetNbLayers
 *  HexoticPlugin_Hypothesis_i::GetFirstLayerSize
 *  HexoticPlugin_Hypothesis_i::GetDirection
 *  HexoticPlugin_Hypothesis_i::GetGrowth
 *  HexoticPlugin_Hypothesis_i::GetFacesWithLayers
 *  HexoticPlugin_Hypothesis_i::GetImprintedFaces
 */
//=============================================================================

CORBA::Long HexoticPlugin_Hypothesis_i::GetHexesMinLevel()
{
  ASSERT(myBaseImpl);
  return this->GetImpl()->GetHexesMinLevel();
}

CORBA::Long HexoticPlugin_Hypothesis_i::GetHexesMaxLevel()
{
  ASSERT(myBaseImpl);
  return this->GetImpl()->GetHexesMaxLevel();
}

CORBA::Double HexoticPlugin_Hypothesis_i::GetMinSize()
{
  ASSERT(myBaseImpl);
  return this->GetImpl()->GetMinSize();
}

CORBA::Double HexoticPlugin_Hypothesis_i::GetMaxSize()
{
  ASSERT(myBaseImpl);
  return this->GetImpl()->GetMaxSize();
}

CORBA::Boolean HexoticPlugin_Hypothesis_i::GetHexoticIgnoreRidges()
{
  ASSERT(myBaseImpl);
  return this->GetImpl()->GetHexoticIgnoreRidges();
}

CORBA::Boolean HexoticPlugin_Hypothesis_i::GetHexoticInvalidElements()
{
  ASSERT(myBaseImpl);
  return this->GetImpl()->GetHexoticInvalidElements();
}

CORBA::Double HexoticPlugin_Hypothesis_i::GetHexoticSharpAngleThreshold()
{
  ASSERT(myBaseImpl);
  return this->GetImpl()->GetHexoticSharpAngleThreshold();
}

CORBA::Long HexoticPlugin_Hypothesis_i::GetHexoticNbProc()
{
  ASSERT(myBaseImpl);
  return this->GetImpl()->GetHexoticNbProc();
}

char* HexoticPlugin_Hypothesis_i::GetHexoticWorkingDirectory()
{
  ASSERT(myBaseImpl);
  return CORBA::string_dup( this->GetImpl()->GetHexoticWorkingDirectory().c_str() );
}

CORBA::Long HexoticPlugin_Hypothesis_i::GetHexoticSdMode ()
{
  ASSERT(myBaseImpl);
  return this->GetImpl()->GetHexoticSdMode();
}

CORBA::Long HexoticPlugin_Hypothesis_i::GetHexoticVerbosity()
{
  ASSERT(myBaseImpl);
  return this->GetImpl()->GetHexoticVerbosity();
}

CORBA::Long HexoticPlugin_Hypothesis_i::GetHexoticMaxMemory()
{
  ASSERT(myBaseImpl);
  return this->GetImpl()->GetHexoticMaxMemory();
}

char* HexoticPlugin_Hypothesis_i::GetAdvancedOption()
{
  ASSERT(myBaseImpl);
  return CORBA::string_dup( this->GetImpl()->GetAdvancedOption( /*customOnly=*/true ).c_str() );
}
char* HexoticPlugin_Hypothesis_i::GetTextOptions()
{
  ASSERT(myBaseImpl);
  return CORBA::string_dup( this->GetImpl()->GetAdvancedOption().c_str() );
}

CORBA::Long HexoticPlugin_Hypothesis_i::GetNbLayers()
{
  ASSERT(myBaseImpl);
  return this->GetImpl()->GetNbLayers();
}

CORBA::Double HexoticPlugin_Hypothesis_i::GetFirstLayerSize()
{
  ASSERT(myBaseImpl);
  return this->GetImpl()->GetFirstLayerSize();
}

CORBA::Boolean HexoticPlugin_Hypothesis_i::GetDirection()
{
  ASSERT(myBaseImpl);
  return this->GetImpl()->GetDirection();
}

CORBA::Double HexoticPlugin_Hypothesis_i::GetGrowth()
{
  ASSERT(myBaseImpl);
  return this->GetImpl()->GetGrowth();
}

SMESH::long_array* HexoticPlugin_Hypothesis_i::GetFacesWithLayers()
{
  ASSERT(myBaseImpl);
  std::vector<int> idsVec = this->GetImpl()->GetFacesWithLayers();
  SMESH::long_array_var ids = new SMESH::long_array;
  ids->length( idsVec.size() );
  for ( unsigned i = 0; i < idsVec.size(); ++i )
    ids[i] = idsVec[i];
  return ids._retn();
}

SMESH::long_array* HexoticPlugin_Hypothesis_i::GetImprintedFaces()
{
  ASSERT(myBaseImpl);
  std::vector<int> idsVec = this->GetImpl()->GetImprintedFaces();
  SMESH::long_array_var ids = new SMESH::long_array;
  ids->length( idsVec.size() );
  for ( unsigned i = 0; i < idsVec.size(); ++i )
    ids[i] = idsVec[i];
  return ids._retn();
}
//=============================================================================
/*!
 *  HexoticPlugin_Hypothesis_i::GetImpl
 *
 *  Get implementation
 */
//=============================================================================
::HexoticPlugin_Hypothesis* HexoticPlugin_Hypothesis_i::GetImpl()
{
  return (::HexoticPlugin_Hypothesis*)myBaseImpl;
}

//================================================================================
/*!
 * \brief Verify whether hypothesis supports given entity type
 * \param type - dimension (see SMESH::Dimension enumeration)
 * \retval CORBA::Boolean - TRUE if dimension is supported, FALSE otherwise
 *
 * Verify whether hypothesis supports given entity type (see SMESH::Dimension enumeration)
 */
//================================================================================
CORBA::Boolean HexoticPlugin_Hypothesis_i::IsDimSupported( SMESH::Dimension type )
{
  return type == SMESH::DIM_3D;
}

//================================================================================
/*!
 * \brief Return geometry this hypothesis depends on. Return false if there is no geometry parameter
 */
//================================================================================

bool
HexoticPlugin_Hypothesis_i::getObjectsDependOn( std::vector< std::string > & entryArray,
                                                std::vector< int >         & subIDArray ) const
{
  typedef ::HexoticPlugin_Hypothesis THyp;
  const THyp* h = static_cast< const THyp*> ( myBaseImpl );

  const THyp::THexoticSizeMaps& sizeMaps = h->GetSizeMaps();
  THyp::THexoticSizeMaps::const_iterator entry2size = sizeMaps.cbegin();
  for ( ; entry2size != sizeMaps.cend(); ++entry2size )
    entryArray.push_back( entry2size->first );

  subIDArray = h->GetFacesWithLayers();
  subIDArray.insert( subIDArray.end(),
                     h->GetImprintedFaces().begin(),
                     h->GetImprintedFaces().end());

  return true;
}

//================================================================================
/*!
 * \brief Set new geometry instead of that returned by getObjectsDependOn()
 */
//================================================================================

bool
HexoticPlugin_Hypothesis_i::setObjectsDependOn( std::vector< std::string > & entryArray,
                                                std::vector< int >         & subIDArray )
{
  typedef ::HexoticPlugin_Hypothesis THyp;
  THyp* h = static_cast< THyp*> ( myBaseImpl );

  size_t iEnt = 0;

  THyp::THexoticSizeMaps& sizeMapsNew = const_cast< THyp::THexoticSizeMaps& > ( h->GetSizeMaps() );
  THyp::THexoticSizeMaps sizeMaps;
  sizeMaps.swap( sizeMapsNew );
  THyp::THexoticSizeMaps::const_iterator entry2size = sizeMaps.cbegin();
  for ( ; entry2size != sizeMaps.cend(); ++entry2size )
  {
    const std::string& entry = entryArray[ iEnt++ ];
    if ( entry.empty() == entry2size->first.empty() )
      sizeMapsNew[ entry ] = entry2size->second;
  }

  size_t nbFacesWL = h->GetFacesWithLayers().size();
  std::vector<int> facesWithLayers;
  size_t iID = 0;
  for ( ; iID < nbFacesWL; ++iID )
    if ( subIDArray[ iID ] > 0 )
      facesWithLayers.push_back( subIDArray[ iID ]);
  h->SetFacesWithLayers( facesWithLayers );

  std::vector<int> imprintedFaces;
  for ( ; iID < subIDArray.size(); ++iID )
    if ( subIDArray[ iID ] > 0 )
      imprintedFaces.push_back( subIDArray[ iID ]);
  h->SetImprintedFaces( imprintedFaces );

  return iID == subIDArray.size() && iEnt == entryArray.size();
}
