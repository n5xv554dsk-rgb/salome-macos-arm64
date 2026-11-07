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
// File   : HexoticPlugin_Hypothesis_i.hxx
// Author : Lioka RAZAFINDRAZAKA (CEA)
// ---
//
#ifndef _HexoticPlugin_Hypothesis_i_HXX_
#define _HexoticPlugin_Hypothesis_i_HXX_

#include <SALOMEconfig.h>
#include CORBA_SERVER_HEADER(HexoticPlugin_Algorithm)

#include "SMESH_Hypothesis_i.hxx"
#include "HexoticPlugin_Hypothesis.hxx"

class SMESH_Gen;

// HexoticPlugin parameters hypothesis

class HEXOTICPLUGIN_EXPORT HexoticPlugin_Hypothesis_i:
  public virtual POA_HexoticPLUGIN::HexoticPlugin_Hypothesis,
  public virtual SMESH_Hypothesis_i
{
 public:
  // Constructor
  HexoticPlugin_Hypothesis_i (PortableServer::POA_ptr thePOA,
                              ::SMESH_Gen*            theGenImpl);
  // Destructor
  virtual ~HexoticPlugin_Hypothesis_i();

  // Methods for setting and getting parameters values
  void SetHexesMinLevel(CORBA::Long theVal);
  CORBA::Long GetHexesMinLevel();

  void SetHexesMaxLevel(CORBA::Long theVal);
  CORBA::Long GetHexesMaxLevel();

  void SetMinSize(CORBA::Double theVal);
  CORBA::Double GetMinSize();

  void SetMaxSize(CORBA::Double theVal);
  CORBA::Double GetMaxSize();

  void SetGeomApproxAngle(CORBA::Double angle);
  CORBA::Double GetGeomApproxAngle();

  void SetHexoticIgnoreRidges(CORBA::Boolean theVal);
  CORBA::Boolean GetHexoticIgnoreRidges();

  void SetHexoticInvalidElements(CORBA::Boolean theVal);
  CORBA::Boolean GetHexoticInvalidElements();

  void SetHexoticSharpAngleThreshold(CORBA::Double theVal);
  CORBA::Double GetHexoticSharpAngleThreshold();

  void SetHexoticNbProc(CORBA::Long theVal);
  CORBA::Long GetHexoticNbProc();

  void SetHexoticWorkingDirectory(const char* path);
  char* GetHexoticWorkingDirectory();

  void SetKeepFiles(::CORBA::Boolean toKeep);
  ::CORBA::Boolean GetKeepFiles();

  void SetStandardOutputLog(::CORBA::Boolean logInStandardOutput);
  ::CORBA::Boolean GetStandardOutputLog();

  void SetRemoveLogOnSuccess(::CORBA::Boolean removeLogOnSuccess);
  ::CORBA::Boolean GetRemoveLogOnSuccess();

  void SetHexoticSdMode(CORBA::Long value);
  CORBA::Long GetHexoticSdMode();

  void SetHexoticVerbosity(CORBA::Long theVal);
  CORBA::Long GetHexoticVerbosity();

  void SetHexoticMaxMemory(CORBA::Long theVal);
  CORBA::Long GetHexoticMaxMemory();

  void SetAdvancedOption(const char* theOptions);
  char* GetAdvancedOption();
  void SetTextOptions(const char* theOptions); // obsolete
  char* GetTextOptions();

  void SetOptionValue(const char* optionName, const char* optionValue);
  char* GetOptionValue(const char* optionName);
  void UnsetOption(const char* optionName);

  HexoticPLUGIN::string_array* GetOptionValues();
  HexoticPLUGIN::string_array* GetAdvancedOptionValues();

  void SetOptionValues(const HexoticPLUGIN::string_array& options);
  void SetAdvancedOptionValues(const HexoticPLUGIN::string_array& options);

  void AddOption(const char* optionName, const char* optionValue);
  char* GetOption(const char* optionName);
  void SetSizeMapEntry(const char* theEntry, CORBA::Double theSize);
  void UnsetSizeMapEntry(const char* theEntry);

  void SetSizeMap(GEOM::GEOM_Object_ptr theGeomObj, double theSize);
  void UnsetSizeMap(GEOM::GEOM_Object_ptr theGeomObj);
  HexoticPLUGIN::HexoticPluginSizeMapsList* GetSizeMaps ();

  void SetNbLayers(CORBA::Long theVal);
  CORBA::Long GetNbLayers();

  void SetFirstLayerSize(CORBA::Double theVal);
  CORBA::Double GetFirstLayerSize();

  void SetDirection(CORBA::Boolean theVal);
  CORBA::Boolean GetDirection();

  void SetGrowth(CORBA::Double theVal);
  CORBA::Double GetGrowth();

  void SetFacesWithLayers(const SMESH::long_array& theVal);
  SMESH::long_array* GetFacesWithLayers();

  void SetImprintedFaces(const SMESH::long_array& theVal);
  SMESH::long_array* GetImprintedFaces();

  // Get implementation
  ::HexoticPlugin_Hypothesis* GetImpl();

  // Verify whether hypothesis supports given entity type
  CORBA::Boolean IsDimSupported( SMESH::Dimension type );

  // Methods for copying mesh definition to other geometry

  // Return geometry this hypothesis depends on. Return false if there is no geometry parameter
  virtual bool getObjectsDependOn( std::vector< std::string > & entryArray,
                                   std::vector< int >         & subIDArray ) const;

  // Set new geometry instead of that returned by getObjectsDependOn()
  virtual bool setObjectsDependOn( std::vector< std::string > & entryArray,
                                   std::vector< int >         & subIDArray );
};

#endif
