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
// File   : HexoticPlugin_Hypothesis.cxx
// Author : Lioka RAZAFINDRAZAKA (CEA)
// ---
//
#include "HexoticPlugin_Hypothesis.hxx"
#include <utilities.h>

#include <TCollection_AsciiString.hxx>
#include <SMESH_Comment.hxx>

namespace
{
  struct GET_DEFAULT // struct used to get default value from GetOptionValue()
  {
    bool isDefault;
    operator bool* () { return &isDefault; }
  };
}

//=============================================================================
/*!
 *
 */
//=============================================================================
HexoticPlugin_Hypothesis::HexoticPlugin_Hypothesis (int hypId, SMESH_Gen* gen)
  : SMESH_Hypothesis(hypId, gen),
    _hexesMinLevel( GetDefaultHexesMinLevel() ),
    _hexesMaxLevel( GetDefaultHexesMaxLevel() ),
    _minSize( GetDefaultMinSize() ),
    _maxSize( GetDefaultMaxSize() ),
    _approxAngle( GetDefaultGeomApproxAngle() ),
    _hexoticIgnoreRidges( GetDefaultHexoticIgnoreRidges() ),
    _hexoticInvalidElements( GetDefaultHexoticInvalidElements() ),
    _hexoticSharpAngleThreshold( GetDefaultHexoticSharpAngleThreshold() ),
    _hexoticNbProc( GetDefaultHexoticNbProc() ),
    _hexoticSdMode(GetDefaultHexoticSdMode()),
    _hexoticVerbosity(GetDefaultHexoticVerbosity()),
    _hexoticMaxMemory(GetDefaultHexoticMaxMemory()),
    _hexoticWorkingDirectory( GetDefaultHexoticWorkingDirectory() ),
    _logInStandardOutput( GetDefaultStandardOutputLog() ),
    _removeLogOnSuccess( GetDefaultRemoveLogOnSuccess() ),
    _keepFiles( GetDefaultKeepFiles() ),
    _nbLayers(GetDefaultNbLayers()),
    _firstLayerSize(GetDefaultFirstLayerSize()),
    _direction(GetDefaultDirection()),
    _growth(GetDefaultGrowth()),
    _facesWithLayers(GetDefaultFacesWithLayers()),
    _imprintedFaces(GetDefaultImprintedFaces())
{
  MESSAGE("HexoticPlugin_Hypothesis::HexoticPlugin_Hypothesis");
  _name = GetHypType();
  _param_algo_dim = 3;

  const char* boolOptionNames[] = { "allow_invalid_elements",
                                    "enforce_constant_layer_size",
                                    "compute_ridges",
                                    "flatten_hexa_sides",
                                    "recover_sharp_angles",
                                    "" // mark of end
  };
  const char* intOptionNames[] = { "max_memory",            // 2048
                                   "max_number_of_threads", // 4
                                   "min_level",             // 6
                                   "max_level",             // 10
                                   "sizemap_level",         // 10
                                   "" // mark of end
  };
  const char* doubleOptionNames[] = { "ridge_angle",  // 60
                                      "" // mark of end
  };
  const char* charOptionNames[] = { "element_order",   // linear
                                    "tags",            // respect
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

  _defaultOptionValues["allow_invalid_elements"     ] = "no";
  _defaultOptionValues["enforce_constant_layer_size"] = "no";
  _defaultOptionValues["compute_ridges"             ] = "yes";
  _defaultOptionValues["flatten_hexa_sides"         ] = "no";
  _defaultOptionValues["recover_sharp_angles"       ] = "yes";
  _defaultOptionValues["max_memory"                 ] = "2048";
  _defaultOptionValues["max_number_of_threads"      ] = "4";
  _defaultOptionValues["min_level"                  ] = "6";
  _defaultOptionValues["max_level"                  ] = "10";
  _defaultOptionValues["sizemap_level"              ] = "10";
  _defaultOptionValues["ridge_angle"                ] = "60";
  _defaultOptionValues["element_order"              ] = "linear";
  _defaultOptionValues["tags"                       ] = "respect";

#ifdef _DEBUG_
  // check validity of option names of _defaultOptionValues
  TOptionValues::iterator n2v = _defaultOptionValues.begin();
  for ( ; n2v != _defaultOptionValues.end(); ++n2v )
    ASSERT( _option2value.count( n2v->first ));
  ASSERT( _option2value.size() == _defaultOptionValues.size() );
#endif
}

//=============================================================================
/*!
 *
 */
//=============================================================================

void HexoticPlugin_Hypothesis::SetHexesMinLevel(int theVal)
{
  SetOptionValue( "min_level", SMESH_Comment( theVal ));
  _hexesMinLevel = theVal;
}

void HexoticPlugin_Hypothesis::SetHexesMaxLevel(int theVal)
{
  SetOptionValue( "max_level", SMESH_Comment( theVal ));
  _hexesMaxLevel = theVal;
}

void HexoticPlugin_Hypothesis::SetMinSize(double theVal) {
  if (theVal != _minSize) {
    _minSize = theVal;
    NotifySubMeshesHypothesisModification();
  }
}

void HexoticPlugin_Hypothesis::SetMaxSize(double theVal) {
  if (theVal != _maxSize) {
    _maxSize = theVal;
    NotifySubMeshesHypothesisModification();
  }
}

void HexoticPlugin_Hypothesis::SetGeomApproxAngle(double theVal) {
  if (theVal != _approxAngle) {
    _approxAngle = theVal;
    NotifySubMeshesHypothesisModification();
  }
}

void HexoticPlugin_Hypothesis::SetHexoticIgnoreRidges(bool theVal) {
  SetOptionValue( "compute_ridges", theVal ? "no" : "yes" );
  _hexoticIgnoreRidges = theVal;
}

void HexoticPlugin_Hypothesis::SetHexoticInvalidElements(bool theVal)
{
  SetOptionValue( "allow_invalid_elements", theVal ? "yes" : "no" );
  _hexoticInvalidElements = theVal;
}

void HexoticPlugin_Hypothesis::SetHexoticSharpAngleThreshold(double theVal)
{
  SetOptionValue( "ridge_angle", SMESH_Comment( theVal ));
  _hexoticSharpAngleThreshold = theVal;
}

void HexoticPlugin_Hypothesis::SetHexoticNbProc(int theVal)
{
  SetOptionValue( "max_number_of_threads", SMESH_Comment( theVal ));
  _hexoticNbProc = theVal;
}

void HexoticPlugin_Hypothesis::SetHexoticWorkingDirectory(const std::string& path)
{
  if ( _hexoticWorkingDirectory != path ) {
    _hexoticWorkingDirectory = path;
    if ( !path.empty() )
    {
#ifdef WIN32
      if( path[ path.size()-1 ] != '\\')
        _hexoticWorkingDirectory += '\\';
#else
      if( path[ path.size()-1 ] != '/')
        _hexoticWorkingDirectory += '/';
#endif
    }
    NotifySubMeshesHypothesisModification();
  }
}

void HexoticPlugin_Hypothesis::SetHexoticSdMode(int theVal) {
  if (theVal != _hexoticSdMode) {
    _hexoticSdMode = theVal;
    NotifySubMeshesHypothesisModification();
  }
}

void HexoticPlugin_Hypothesis::SetHexoticVerbosity(int theVal) {
  if (theVal != _hexoticVerbosity) {
    _hexoticVerbosity = theVal;
    NotifySubMeshesHypothesisModification();
  }
}

void HexoticPlugin_Hypothesis::SetHexoticMaxMemory(int theVal)
{
  SetOptionValue( "max_memory", SMESH_Comment( theVal ));
  _hexoticMaxMemory = theVal;
}

void HexoticPlugin_Hypothesis::SetKeepFiles(bool toKeep)
{
  if ( _keepFiles != toKeep ) {
    _keepFiles = toKeep;
    NotifySubMeshesHypothesisModification();
  }
}

void HexoticPlugin_Hypothesis::SetStandardOutputLog(bool logInStandardOutput)
{
  if ( _logInStandardOutput != logInStandardOutput ) {
    _logInStandardOutput = logInStandardOutput;
    NotifySubMeshesHypothesisModification();
  }
}

void HexoticPlugin_Hypothesis::SetRemoveLogOnSuccess(bool removeLogOnSuccess)
{
  if ( _removeLogOnSuccess != removeLogOnSuccess ) {
    _removeLogOnSuccess = removeLogOnSuccess;
    NotifySubMeshesHypothesisModification();
  }
}

void HexoticPlugin_Hypothesis::SetOptionValue(const std::string& optionName,
                                              const std::string& optionValue)
{
  TOptionValues::iterator op_val = _option2value.find(optionName);
  if (op_val == _option2value.end())
  {
    op_val = _customOption2value.find( optionName );
    if ( op_val != _customOption2value.end() && op_val->second != optionValue )
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
std::string HexoticPlugin_Hypothesis::GetOptionValue(const std::string& optionName,
                                                     bool*              isDefault) const
{
  TOptionValues::const_iterator op_val = _option2value.find(optionName);
  if (op_val == _option2value.end())
  {
    op_val = _customOption2value.find(optionName);
    if (op_val == _customOption2value.end())
    {
      std::string msg = "Unknown MG-Tetra option: <" + optionName + ">";
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
  return val;
}


//=============================================================================
bool HexoticPlugin_Hypothesis::HasOptionDefined( const std::string& optionName ) const
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
void HexoticPlugin_Hypothesis::ClearOption(const std::string& optionName)
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
HexoticPlugin_Hypothesis::TOptionValues HexoticPlugin_Hypothesis::GetOptionValues() const
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

bool HexoticPlugin_Hypothesis::ToBool(const std::string& str, bool* isOk )
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

double HexoticPlugin_Hypothesis::ToDbl(const std::string& str, bool* isOk )
{
  if ( str.empty() ) throw std::invalid_argument("Empty value provided");

  char * endPtr;
  double val = strtod(&str[0], &endPtr);
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

int HexoticPlugin_Hypothesis::ToInt(const std::string& str, bool* isOk )
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

void HexoticPlugin_Hypothesis::SetAdvancedOption(const std::string& option)
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
//purpose  : Return only options having NO corresponding member fields
//=======================================================================

std::string HexoticPlugin_Hypothesis::GetAdvancedOption( bool customOnly ) const
{
  // options having corresponding member fields
  static std::set< std::string > toSkip = {
    "min_level",
    "max_level",
    "compute_ridges",
    "allow_invalid_elements",
    "ridge_angle",
    "max_number_of_threads",
    "max_memory"
  };

  // Return only options having NO corresponding member fields

  SMESH_Comment txt;

  TOptionValues::const_iterator o2v = _option2value.begin();
  if ( !customOnly )
  {
    for ( ; o2v != _option2value.end(); ++o2v )
      if ( !o2v->second.empty() && !toSkip.count( o2v->first ))
      {
        if ( !txt.empty() )
          txt << " ";
        txt << "--" << o2v->first << " " << o2v->second;
      }
  }
  for ( o2v = _customOption2value.begin(); o2v != _customOption2value.end(); ++o2v )
  {
    if ( !txt.empty() )
      txt << " ";
    // if ( o2v->first[0] != '-' )
    //   txt << "--";
    txt << o2v->first << " " << o2v->second;
  }
  return txt;
}

bool HexoticPlugin_Hypothesis::AddSizeMap(std::string theEntry, double theSize)
{
  THexoticSizeMaps::iterator it;
  it=_sizeMaps.find(theEntry);

  if(theSize <= 0)
    return false;

  if( it == _sizeMaps.end() ) // If no size map is defined on the given object
  {
    _sizeMaps[theEntry] = theSize;
    MESSAGE("NEW size map, entry :"<<theEntry<<", size : "<<theSize);
    NotifySubMeshesHypothesisModification();
    return true;
  }
  else if( it->second != theSize ) // If a size map exists with a different size value
  {
    it->second = theSize;
    MESSAGE("MODIFIED size map, entry :"<<theEntry<<"with size : "<<theSize);
    NotifySubMeshesHypothesisModification();
    return true;
  }
  else
  {
    MESSAGE("NO size map added");
    return false; // No size map added
  }
}

bool HexoticPlugin_Hypothesis::UnsetSizeMap(std::string theEntry) {
  THexoticSizeMaps::iterator it;
  it=_sizeMaps.find(theEntry);
  if( it != _sizeMaps.end() )
  {
    _sizeMaps.erase(it);  
    return true;
  }
  else
    return false;
}

void HexoticPlugin_Hypothesis::SetNbLayers(int theVal) {
  if (theVal != _nbLayers) {
    _nbLayers = theVal;
    NotifySubMeshesHypothesisModification();
  }
}

void HexoticPlugin_Hypothesis::SetFirstLayerSize(double theVal) {
  if (theVal != _firstLayerSize) {
    _firstLayerSize = theVal;
    NotifySubMeshesHypothesisModification();
  }
}

void HexoticPlugin_Hypothesis::SetDirection(bool theVal) {
  if (theVal != _direction) {
    _direction = theVal;
    NotifySubMeshesHypothesisModification();
  }
}

void HexoticPlugin_Hypothesis::SetGrowth(double theVal) {
  if (theVal != _growth) {
    _growth = theVal;
    NotifySubMeshesHypothesisModification();
  }
}

bool HexoticPlugin_Hypothesis::SetFacesWithLayers(const std::vector<int>& theVal) {
  if ( _facesWithLayers != theVal ) {
          _facesWithLayers = theVal;
    NotifySubMeshesHypothesisModification();
    return true;
  }
  return false;
}

bool HexoticPlugin_Hypothesis::SetImprintedFaces(const std::vector<int>& theVal) {
  if ( _imprintedFaces != theVal ) {
          _imprintedFaces = theVal;
    NotifySubMeshesHypothesisModification();
    return true;
  }
  return false;
}

//=============================================================================
/*!
 *  
 */
//=============================================================================
std::ostream& HexoticPlugin_Hypothesis::SaveTo(std::ostream& save)
{
  //explicit outputs for future code compatibility of saved .hdf
  //save without any whitespaces!
  //int dummy = -1;
  save<<"hexesMinLevel="<<_hexesMinLevel<<";";
  save<<"hexesMaxLevel="<<_hexesMaxLevel<<";";
  save<<"hexoticIgnoreRidges="<<(int)_hexoticIgnoreRidges<<";";
  save<<"hexoticInvalidElements="<<(int)_hexoticInvalidElements<<";";
  save<<"hexoticSharpAngleThreshold="<<_hexoticSharpAngleThreshold<<";";
  save<<"hexoticNbProc="<<_hexoticNbProc<<";";
  save<<"hexoticWorkingDirectory="<<_hexoticWorkingDirectory<<";";
  save<<"minSize="<<_minSize<<";";
  save<<"maxSize="<<_maxSize<<";";
  save<<"hexoticSdMode="<<_hexoticSdMode<<";";
  save<<"hexoticVerbosity="<<_hexoticVerbosity<<";";
  save<<"hexoticMaxMemory="<<_hexoticMaxMemory<<";";
  std::string textOptions;// = _textOptions;
  replace(textOptions.begin(), textOptions.end(), ' ', '*');
  save<<"textOptions="<<textOptions<<";";
  THexoticSizeMaps::iterator it = _sizeMaps.begin();
  if ( it != _sizeMaps.end() )
  {
    save<<"sizeMaps=";
    for ( ; it!=_sizeMaps.end() ; it++ )
    {
      save<< it->first << "/" << it->second << "#" ;
    }
    save<<";";
  }
  save<<"nbLayers="<<_nbLayers<<";";
  save<<"firstLayerSize="<<_firstLayerSize<<";";
  save<<"direction="<<_direction<<";";
  save<<"growth="<<_growth<<";";
  if ( !_facesWithLayers.empty() )
  {
    save<<"facesWithLayers=";
    for ( size_t i = 0; i < _facesWithLayers.size(); i++ )
    {
      save<< _facesWithLayers.at(i) << "#" ;
    }
    save<<";";
  }
  if ( !_imprintedFaces.empty() )
  {
    save<<"imprintedFaces=";
    for ( size_t i = 0; i < _imprintedFaces.size(); i++ )
    {
      save<< _imprintedFaces.at(i) << "#" ;
    }
    save<<";";
  }

  // New options in 2.9.6 (issue #17784)

  save << " " << _approxAngle;
  save << " " << _logInStandardOutput;
  save << " " << _removeLogOnSuccess;
  save << " " << _keepFiles;

  save << " " << _option2value.size();
  TOptionValues::iterator o2v = _option2value.begin();
  for ( ; o2v != _option2value.end(); ++o2v )
    save << " -" << o2v->first << " -" << o2v->second;

  save << " " << _customOption2value.size();
  for ( o2v = _customOption2value.begin(); o2v != _customOption2value.end(); ++o2v )
    save << " -" << o2v->first << " -" << o2v->second;

  return save;
}

//=============================================================================
/*!
 *
 */
//=============================================================================
std::istream& HexoticPlugin_Hypothesis::LoadFrom(std::istream& load)
{
   //explicit inputs for future code compatibility of saved .hdf
   bool isOK = true;
   std::string str1,str2,str3,str4;

   //save without any whitespaces!
   isOK = static_cast<bool>(load >> str1);
   if (!(isOK)) {
     //defaults values assumed
     load.clear(std::ios::badbit | load.rdstate());
     return load;
   }
   int pos = 0;
   int len = str1.length();
   while (pos < len) {
      int found = str1.find(';',pos);
      str2 = str1.substr(pos,found-pos);
      int eqpos = str2.find('=',0);
      str3 = str2.substr(0,eqpos);
      str4 = str2.substr(eqpos+1);
      pos = found + 1;

      if (str3=="hexesMinLevel")              _hexesMinLevel              = atoi(str4.c_str());
      if (str3=="hexesMaxLevel")              _hexesMaxLevel              = atoi(str4.c_str());
      if (str3=="hexoticQuadrangles") {}
      if (str3=="hexoticIgnoreRidges")        _hexoticIgnoreRidges    = (bool) atoi(str4.c_str());
      if (str3=="hexoticInvalidElements")     _hexoticInvalidElements = (bool) atoi(str4.c_str());
      if (str3=="hexoticSharpAngleThreshold") _hexoticSharpAngleThreshold = atof(str4.c_str());
      if (str3=="hexoticNbProc")              _hexoticNbProc              = atoi(str4.c_str());
      if (str3=="hexoticWorkingDirectory")    _hexoticWorkingDirectory    = str4;
      if (str3=="minSize")                    _minSize                    = atof(str4.c_str());
      if (str3=="maxSize")                    _maxSize                    = atof(str4.c_str());
      if (str3=="hexoticSdMode")              _hexoticSdMode              = atoi(str4.c_str());
      if (str3=="hexoticVerbosity")           _hexoticVerbosity           = atoi(str4.c_str());
      if (str3=="hexoticMaxMemory")           _hexoticMaxMemory           = atoi(str4.c_str());
      if (str3=="textOptions")
      {
        replace(str4.begin(), str4.end(), '*', ' ');
        //_textOptions = str4;
      }
      if (str3=="sizeMaps")
      {
        std::string sm_substr, sm_substr1, sm_substr2;
        int sm_pos = 0;
        int sm_len = str4.length();
        while ( sm_pos < sm_len )
        {
          int sm_found = str4.find('#',sm_pos);
          sm_substr = str4.substr(sm_pos,sm_found-sm_pos);
          int sm_slashpos = sm_substr.find('/',0);
          sm_substr1 = sm_substr.substr(0,sm_slashpos);
          sm_substr2 = sm_substr.substr(sm_slashpos+1);
          _sizeMaps[sm_substr1] = atof(sm_substr2.c_str());
          sm_pos = sm_found + 1;
        }
      }
      if (str3 == "nbLayers")       _nbLayers       = atoi(str4.c_str());
      if (str3 == "firstLayerSize") _firstLayerSize = atof(str4.c_str());
      if (str3 == "direction")      _direction      = atoi(str4.c_str());
      if (str3 == "growth")         _growth         = atof(str4.c_str());
      if (str3 == "facesWithLayers")
      {
        std::string id;
        size_t pos = 0;
        while ( pos < str4.length() )
        {
          int found = str4.find('#',pos);
          id = str4.substr(pos, found-pos);
          _facesWithLayers.push_back(atoi(id.c_str()));
          pos = found + 1;
        }
      }
      if (str3 == "imprintedFaces")
      {
        std::string id;
        size_t pos = 0;
        while ( pos < str4.length() )
        {
          int found = str4.find('#',pos);
          id = str4.substr(pos, found-pos);
          _imprintedFaces.push_back(atoi(id.c_str()));
          pos = found + 1;
        }
      }
   }

   // New options in 2.9.6 (issue #17784)

   if ( static_cast<bool>( load >> _approxAngle ))
   {
     int i;
     load >> i; _logInStandardOutput = (bool)i;
     load >> i; _removeLogOnSuccess = (bool)i;
     load >> i; _keepFiles = (bool)i;

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
   else // pass old basic parameters to new advanced ones
   {
     SetHexesMinLevel             ( _hexesMinLevel );
     SetHexesMaxLevel             ( _hexesMaxLevel );
     SetHexoticIgnoreRidges       ( _hexoticIgnoreRidges );
     SetHexoticInvalidElements    ( _hexoticInvalidElements );
     SetHexoticSharpAngleThreshold( _hexoticSharpAngleThreshold );
     SetHexoticNbProc             ( _hexoticNbProc );
     SetHexoticMaxMemory          ( _hexoticMaxMemory );
   }

   return load;
}

//=============================================================================
/*!
 *  
 */
//=============================================================================
std::ostream& operator <<(std::ostream& save, HexoticPlugin_Hypothesis& hyp)
{
  return hyp.SaveTo( save );
}

//=============================================================================
/*!
 *  
 */
//=============================================================================
std::istream& operator >>(std::istream& load, HexoticPlugin_Hypothesis& hyp)
{
  return hyp.LoadFrom( load );
}


//================================================================================
/*!
 * \brief Does nothing
 * \param theMesh - the built mesh
 * \param theShape - the geometry of interest
 * \retval bool - always false
 */
//================================================================================
bool HexoticPlugin_Hypothesis::SetParametersByMesh(const SMESH_Mesh*   /*theMesh*/,
                                                   const TopoDS_Shape& /*theShape*/)
{
  return false;
}
//================================================================================
/*!
 * \brief Initialize my parameter values by default parameters.
 *  \retval bool - true if parameter values have been successfully defined
 */
//================================================================================

bool HexoticPlugin_Hypothesis::SetParametersByDefaults(const TDefaults&  /*dflts*/,
                                                       const SMESH_Mesh* /*theMesh*/)
{
  return false;
}

//=============================================================================
int HexoticPlugin_Hypothesis::GetDefaultHexesMinLevel()
{
  return 6;
}

int HexoticPlugin_Hypothesis::GetDefaultHexesMaxLevel()
{
  return 10;
}

double HexoticPlugin_Hypothesis::GetDefaultMinSize()
{
  return 0.0;
}

double HexoticPlugin_Hypothesis::GetDefaultMaxSize()
{
  return 0.0;
}

bool HexoticPlugin_Hypothesis::GetDefaultHexoticIgnoreRidges()
{
  return false;
}

bool HexoticPlugin_Hypothesis::GetDefaultHexoticInvalidElements()
{
  return false;
}

double HexoticPlugin_Hypothesis::GetDefaultHexoticSharpAngleThreshold()
{
  return 60.0;
}

int HexoticPlugin_Hypothesis::GetDefaultHexoticNbProc()
{
  return 4;
}

std::string HexoticPlugin_Hypothesis::GetDefaultHexoticWorkingDirectory()
{
  std::string aTmpDir;

  char *Tmp_dir = getenv("SALOME_TMP_DIR");
#ifdef WIN32
  if(Tmp_dir == NULL) {
    Tmp_dir = getenv("TEMP");
    if( Tmp_dir== NULL )
      Tmp_dir = getenv("TMP");
  }
#endif
  if( Tmp_dir != NULL ) {
    aTmpDir = std::string(Tmp_dir);
#ifdef WIN32
    if(aTmpDir[aTmpDir.size()-1] != '\\') aTmpDir+='\\';
#else
    if(aTmpDir[aTmpDir.size()-1] != '/') aTmpDir+='/';
#endif
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

int HexoticPlugin_Hypothesis::GetDefaultHexoticSdMode()
{
  return 4;
}

int HexoticPlugin_Hypothesis::GetDefaultHexoticVerbosity()
{
  return 1;
}

int HexoticPlugin_Hypothesis::GetDefaultHexoticMaxMemory()
{
  return 2048;
}

std::string HexoticPlugin_Hypothesis::GetDefaultTextOptions()
{
  return "";
}

HexoticPlugin_Hypothesis::THexoticSizeMaps HexoticPlugin_Hypothesis::GetDefaultHexoticSizeMaps()
{
  return THexoticSizeMaps();
}

int HexoticPlugin_Hypothesis::GetDefaultNbLayers()
{
  return 0;
}

double HexoticPlugin_Hypothesis::GetDefaultFirstLayerSize()
{
  return 0.0;
}

bool HexoticPlugin_Hypothesis::GetDefaultDirection()
{
  return true;
}

double HexoticPlugin_Hypothesis::GetDefaultGrowth()
{
  return 0.0;
}

std::vector<int> HexoticPlugin_Hypothesis::GetDefaultFacesWithLayers()
{
  return std::vector<int>();
}

std::vector<int> HexoticPlugin_Hypothesis::GetDefaultImprintedFaces()
{
  return std::vector<int>();
}
