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
// File   : HYBRIDPlugin_HYBRID.hxx
// Author : Christian VAN WAMBEKE (CEA) (from GHS3D plugin V730)
// ---
//
#ifndef _HYBRIDPlugin_HYBRID_HXX_
#define _HYBRIDPlugin_HYBRID_HXX_

#include "SMESH_Algo.hxx"
#include "SMESH_Gen.hxx"
#include "SMESH_Gen_i.hxx"

#include <map>
#include <vector>

class HYBRIDPlugin_Hypothesis;
class SMDS_MeshNode;
class SMESH_Mesh;
class StdMeshers_ViscousLayers;
class TCollection_AsciiString;
class _Ghs2smdsConvertor;
class TopoDS_Shape;

class HYBRIDPlugin_HYBRID: public SMESH_3D_Algo
{
public:
  HYBRIDPlugin_HYBRID(int hypId, SMESH_Gen* gen);
  virtual ~HYBRIDPlugin_HYBRID();

  virtual bool CheckHypothesis(SMESH_Mesh&         aMesh,
                               const TopoDS_Shape& aShape,
                               Hypothesis_Status&  aStatus);

  virtual bool Compute(SMESH_Mesh&         aMesh,
                       const TopoDS_Shape& aShape);

  virtual void CancelCompute();
  bool         computeCanceled() { return _computeCanceled; }

  virtual bool Evaluate(SMESH_Mesh& aMesh, const TopoDS_Shape& aShape,
                        MapShapeNbElems& aResMap);

  virtual bool Compute(SMESH_Mesh&         theMesh,
                       SMESH_MesherHelper* aHelper);

  virtual void SubmeshRestored(SMESH_subMesh* subMesh);

  virtual void SetEventListener(SMESH_subMesh* subMesh);

  bool         importGMFMesh(const char* aGMFFileName, SMESH_Mesh& aMesh);

  static const char* Name() { return "HYBRID_3D"; }

  const HYBRIDPlugin_Hypothesis* getHyp() {return _hyp ;}

protected:
  const HYBRIDPlugin_Hypothesis*   _hyp;
  //const StdMeshers_ViscousLayers* _viscousLayersHyp;
  std::string                     _genericName;
   
private:

  bool         storeErrorDescription(const char*                logFile,
                                     const std::string&         log,
                                     const _Ghs2smdsConvertor & toSmdsConvertor );
  TopoDS_Shape entryToShape(std::string entry);
  
  int  _iShape;
  int  _nbShape;
  bool _keepFiles;
  bool _removeLogOnSuccess;
  bool _logInStandardOutput;
};

/*!
 * \brief Convertor of HYBRID elements to SMDS ones
 */
class _Ghs2smdsConvertor
{
  const std::map <int,const SMDS_MeshNode*> * _ghs2NodeMap;
  const std::vector <const SMDS_MeshNode*> *  _nodeByGhsId;

public:
  _Ghs2smdsConvertor( const std::map <int,const SMDS_MeshNode*> & ghs2NodeMap);

  _Ghs2smdsConvertor( const std::vector <const SMDS_MeshNode*> &  nodeByGhsId);

  const SMDS_MeshElement* getElement(const std::vector<int>& ghsNodes) const;
};

#endif
