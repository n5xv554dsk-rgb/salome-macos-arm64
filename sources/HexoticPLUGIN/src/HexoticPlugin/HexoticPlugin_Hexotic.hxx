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
// File   : HexoticPlugin_Hexotic.hxx
// Author : Lioka RAZAFINDRAZAKA (CEA)
// ---
//
#ifndef _HexoticPlugin_Hexotic_HXX_
#define _HexoticPlugin_Hexotic_HXX_

#include "HexoticPlugin_Defs.hxx"
#include "HexoticPlugin_Hypothesis.hxx"

#include "SMESH_Algo.hxx"
#include "SMESH_Mesh.hxx"
#include "Utils_SALOME_Exception.hxx"

#ifdef WITH_BLSURFPLUGIN
#include "BLSURFPlugin_Hypothesis.hxx"
#endif

#include <string>

#include "DriverGMF_Read.hxx"
#include "DriverGMF_Write.hxx"

#include <SALOMEconfig.h>
#include CORBA_CLIENT_HEADER(GEOM_Gen)
#include <SMESH_Gen_i.hxx>

class HexoticPlugin_Hypothesis;
class TCollection_AsciiString;
class gp_Pnt;
class MG_Hexotic_API;

class HEXOTICPLUGIN_EXPORT HexoticPlugin_Hexotic: public SMESH_3D_Algo
{
public:
  HexoticPlugin_Hexotic(int hypId, SMESH_Gen* gen);
  virtual ~HexoticPlugin_Hexotic();

#ifdef WITH_BLSURFPLUGIN
  bool CheckBLSURFHypothesis(SMESH_Mesh&         aMesh,
                             const TopoDS_Shape& aShape);
#endif

  virtual bool CheckHypothesis(SMESH_Mesh&                          aMesh,
                               const TopoDS_Shape&                  aShape,
                               SMESH_Hypothesis::Hypothesis_Status& aStatus);

  void SetParameters(const HexoticPlugin_Hypothesis* hyp);

  virtual bool Compute(SMESH_Mesh& aMesh,  const TopoDS_Shape& aShape);

  virtual bool Compute(SMESH_Mesh & aMesh, SMESH_MesherHelper* aHelper);

  virtual void CancelCompute();
  bool computeCanceled() { return _computeCanceled; }

  virtual bool Evaluate(SMESH_Mesh& aMesh, const TopoDS_Shape& aShape,
                        MapShapeNbElems& aResMap);

protected:
  const HexoticPlugin_Hypothesis* _hypothesis;

private:

  std::string getHexoticCommand(const TCollection_AsciiString& Hexotic_In,
                                const TCollection_AsciiString& Hexotic_Out,
                                const TCollection_AsciiString& Hexotic_Sol,
                                const bool                     forExecutable) const;
  
  GEOM::GEOM_Object_var entryToGeomObj(std::string entry);
  TopoDS_Shape     entryToShape(std::string entry);

  std::vector<std::string> writeSizeMapFile(MG_Hexotic_API* mgOutput,
                                            std::string     fileName);
  
  int              _iShape;
  int              _nbShape;
  int              _hexesMinLevel;
  int              _hexesMaxLevel;
  double           _hexesMinSize;
  double           _hexesMaxSize;
  double           _approxAngle;
  bool             _hexoticIgnoreRidges;
  bool             _hexoticInvalidElements;
  bool             _hexoticFilesKept;
  int              _hexoticSharpAngleThreshold;
  int              _hexoticNbProc;
  std::string      _hexoticWorkingDirectory;
  int              _hexoticVerbosity;
  int              _hexoticMaxMemory;
  int              _hexoticSdMode;
  std::string      _textOptions;
  HexoticPlugin_Hypothesis::THexoticSizeMaps _sizeMaps;
  int              _nbLayers;
  double           _firstLayerSize;
  bool             _direction;
  double           _growth;
  std::vector<int> _facesWithLayers;
  std::vector<int> _imprintedFaces;
  SMDS_MeshNode**  _tabNode;
  bool             _keepFiles;
  bool             _removeLogOnSuccess;
  bool             _logInStandardOutput;
  
#ifdef WITH_BLSURFPLUGIN
  const BLSURFPlugin_Hypothesis* _blsurfHypo;
#endif

};

#endif
