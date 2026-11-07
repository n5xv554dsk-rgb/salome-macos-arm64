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
// File   : HexoticPlugin_Hexotic.cxx
// Author : Lioka RAZAFINDRAZAKA (CEA)
// ---
//
#include "HexoticPlugin_Hexotic.hxx"
#include "HexoticPlugin_Hypothesis.hxx"
#include "MG_Hexotic_API.hxx"

#include "utilities.h"

#ifdef WIN32
#include <process.h>
#endif

#ifdef _DEBUG_
#define DUMP(txt) \
//  std::cout << txt
#else
#define DUMP(txt)
#endif

#include <SMESHDS_GroupBase.hxx>
#include <SMESHDS_Mesh.hxx>
#include <SMESH_ComputeError.hxx>
#include <SMESH_File.hxx>
#include <SMESH_Gen.hxx>
#include <SMESH_HypoFilter.hxx>
#include <SMESH_MesherHelper.hxx>
#include <SMESH_subMesh.hxx>
#include <SMESH_MeshEditor.hxx>
#include <SMESH_ControlPnt.hxx>

#include <list>
#include <cstdlib>

#include <Standard_ProgramError.hxx>

#include <BRepBndLib.hxx>
#include <BRepClass3d_SolidClassifier.hxx>
#include <BRep_Tool.hxx>
#include <Bnd_Box.hxx>
#include <OSD_File.hxx>
#include <Precision.hxx>
#include <TopExp_Explorer.hxx>
#include <TopTools_MapOfShape.hxx>
#include <TopoDS.hxx>
#include <TopoDS_Vertex.hxx>
#include <gp_Pnt.hxx>

#include <Basics_DirUtils.hxx>
#include <Basics_Utils.hxx>
#include <GEOMImpl_Types.hxx>
#include <GEOM_wrap.hxx>

#include <boost/filesystem.hpp>
namespace boofs = boost::filesystem;

#define GMFVERSION GmfDouble
#define GMFDIMENSION 3

using SMESHUtils::ControlPnt;

static void removeFile( const TCollection_AsciiString& fileName )
{
  try {
    OSD_File( fileName ).Remove();
  }
  catch ( Standard_ProgramError& ) {
    MESSAGE("Can't remove file: " << fileName.ToCString() << " ; file does not exist or permission denied");
  }
}

// change results files permissions to user only (using boost to be used without C++17)
static void chmodUserOnly(const char* filename)
{
  if (boofs::exists(filename))
    boofs::permissions(filename, boofs::remove_perms | boofs::group_all | boofs::others_all );
}

//=============================================================================
/*!
 *  
 */
//=============================================================================

HexoticPlugin_Hexotic::HexoticPlugin_Hexotic(int hypId, SMESH_Gen* gen)
  : SMESH_3D_Algo(hypId, gen)
{
  _name = "MG-Hexa";
  _shapeType = (1 << TopAbs_SHELL) | (1 << TopAbs_SOLID);// 1 bit /shape type
  _onlyUnaryInput = false;
  _requireShape = false;
  _iShape=0;
  _nbShape=0;
  _hexoticFilesKept=false;
  _compatibleHypothesis.push_back( HexoticPlugin_Hypothesis::GetHypType() );
#ifdef WITH_BLSURFPLUGIN
  _blsurfHypo = NULL;
#endif
  _computeCanceled = false;
  
}

//=============================================================================
/*!
 *  
 */
//=============================================================================

HexoticPlugin_Hexotic::~HexoticPlugin_Hexotic()
{
}


#ifdef WITH_BLSURFPLUGIN
bool HexoticPlugin_Hexotic::CheckBLSURFHypothesis( SMESH_Mesh&         aMesh,
                                                   const TopoDS_Shape& aShape )
{
  _blsurfHypo = NULL;

  std::list<const SMESHDS_Hypothesis*>::const_iterator itl;
  const SMESHDS_Hypothesis* theHyp;

  // If a BLSURF hypothesis is applied, get it
  SMESH_HypoFilter blsurfFilter;
  blsurfFilter.Init( blsurfFilter.HasName( BLSURFPlugin_Hypothesis::GetHypType(true) ));
  blsurfFilter.Or  ( blsurfFilter.HasName( BLSURFPlugin_Hypothesis::GetHypType(false)));
  std::list<const SMESHDS_Hypothesis *> appliedHyps;
  aMesh.GetHypotheses( aShape, blsurfFilter, appliedHyps, false );

  if ( appliedHyps.size() > 0 ) {
    itl = appliedHyps.begin();
    theHyp = (*itl); // use only the first hypothesis
    std::string hypName = theHyp->GetName();
    if (hypName == BLSURFPlugin_Hypothesis::GetHypType(true) ||
        hypName == BLSURFPlugin_Hypothesis::GetHypType(false) )
    {
      _blsurfHypo = static_cast<const BLSURFPlugin_Hypothesis*> (theHyp);
      ASSERT(_blsurfHypo);
      return true;
    }
  }
  return false;
}
#endif

//=============================================================================
/*!
 *  
 */
//=============================================================================

bool HexoticPlugin_Hexotic::CheckHypothesis( SMESH_Mesh&                          aMesh,
                                             const TopoDS_Shape&                  aShape,
                                             SMESH_Hypothesis::Hypothesis_Status& aStatus )
{
  _hypothesis = NULL;

  std::list<const SMESHDS_Hypothesis*>::const_iterator itl;
  const SMESHDS_Hypothesis* theHyp;

  const std::list<const SMESHDS_Hypothesis*>& hyps = GetUsedHypothesis(aMesh, aShape, false);
  int nbHyp = hyps.size();
  if (!nbHyp) {
    // retrieve BLSURF hypothesis if no hexotic hypothesis has been set
#ifdef WITH_BLSURFPLUGIN
    CheckBLSURFHypothesis(aMesh, aShape);
#endif
    aStatus = SMESH_Hypothesis::HYP_OK;
    return true;  // can work with no hypothesis
  }

  itl = hyps.begin();
  theHyp = (*itl); // use only the first hypothesis

  std::string hypName = theHyp->GetName();
  if (hypName == HexoticPlugin_Hypothesis::GetHypType() ) {
    _hypothesis = static_cast<const HexoticPlugin_Hypothesis*> (theHyp);
    ASSERT(_hypothesis);
    aStatus = SMESH_Hypothesis::HYP_OK;
  }
  else
    aStatus = SMESH_Hypothesis::HYP_INCOMPATIBLE;
  
#ifdef WITH_BLSURFPLUGIN
  CheckBLSURFHypothesis(aMesh, aShape);
#endif
  
  return aStatus == SMESH_Hypothesis::HYP_OK;
}

//=======================================================================
//function : findShape
//purpose  :
//=======================================================================

static TopoDS_Shape findShape(SMDS_MeshNode**     t_Node,
                              TopoDS_Shape        aShape,
                              const TopoDS_Shape* t_Shape,
                              double**            t_Box,
                              const int           nShape)
{
  double pntCoor[3];
  int iShape, nbNode = 8;

  for ( int i=0; i<3; i++ ) {
    pntCoor[i] = 0;
    for ( int j=0; j<nbNode; j++ ) {
      if ( i == 0) pntCoor[i] += t_Node[j]->X();
      if ( i == 1) pntCoor[i] += t_Node[j]->Y();
      if ( i == 2) pntCoor[i] += t_Node[j]->Z();
    }
    pntCoor[i] /= nbNode;
  }
  gp_Pnt aPnt(pntCoor[0], pntCoor[1], pntCoor[2]);

  if ( aShape.IsNull() ) aShape = t_Shape[0];
  BRepClass3d_SolidClassifier SC (aShape, aPnt, Precision::Confusion());
  if ( !(SC.State() == TopAbs_IN) ) {
    aShape.Nullify();
    for (iShape = 0; iShape < nShape && aShape.IsNull(); iShape++) {
      if ( !( pntCoor[0] < t_Box[iShape][0] || t_Box[iShape][1] < pntCoor[0] ||
              pntCoor[1] < t_Box[iShape][2] || t_Box[iShape][3] < pntCoor[1] ||
              pntCoor[2] < t_Box[iShape][4] || t_Box[iShape][5] < pntCoor[2]) ) {
        BRepClass3d_SolidClassifier SC (t_Shape[iShape], aPnt, Precision::Confusion());
        if (SC.State() == TopAbs_IN)
          aShape = t_Shape[iShape];
      }
    }
  }
  return aShape;
}

//=======================================================================
//function : getNbShape
//purpose  :
//=======================================================================

static int getNbShape(MG_Hexotic_API* hexaOutput, int iMesh, GmfKwdCod what, int defaultValue=0)
{
  int number = hexaOutput->GmfStatKwd( iMesh, what );
  if ( number > 0 )
  {
    number = ( number + defaultValue + std::abs(number - defaultValue) ) / 2;
  }
  else
  {
    number = defaultValue;
  }
  return number;
}

//=======================================================================
//function : countShape
//purpose  :
//=======================================================================

static int countShape( SMESH_Mesh* mesh, TopAbs_ShapeEnum shape )
{
  if ( !mesh->HasShapeToMesh() )
    return 0;
  TopExp_Explorer expShape ( mesh->GetShapeToMesh(), shape );
  TopTools_MapOfShape mapShape;
  int nbShape = 0;
  for ( ; expShape.More(); expShape.Next() ) {
    if (mapShape.Add(expShape.Current())) {
      nbShape++;
    }
  }
  return nbShape;
}

//=======================================================================
//function : getShape
//purpose  :
//=======================================================================

template < class Mesh, class Shape, class Tab >
void getShape(Mesh* mesh, Shape shape, Tab *t_Shape)
{
  TopExp_Explorer expShape ( mesh->ShapeToMesh(), shape );
  TopTools_MapOfShape mapShape;
  for ( int i=0; expShape.More(); expShape.Next() ) {
    if (mapShape.Add(expShape.Current())) {
      t_Shape[i] = expShape.Current();
      i++;
    }
  }
  return;
}

//=======================================================================
//function : printWarning
//purpose  :
//=======================================================================

static void printWarning(const int nbExpected, std::string aString, const int nbFound) {
  std::cout << std::endl;
  std::cout << "WARNING : " << nbExpected << " " << aString << " expected, MG-Hexa has found " << nbFound << std::endl;
  std::cout << "=======" << std::endl;
  std::cout << std::endl;
  return;
}

//=======================================================================
//function : removeHexoticFiles
//purpose  :
//=======================================================================

static void removeHexoticFiles(TCollection_AsciiString file_In, TCollection_AsciiString file_Out)
{
  removeFile( file_In );
  removeFile( file_Out );
}

//=======================================================================
//function : splitQuads
//purpose  : splits all quadrangles into triangles
//=======================================================================

static void splitQuads(SMESH_Mesh& aMesh)
{
  SMESH_MeshEditor spliter( &aMesh );

  TIDSortedElemSet elems;
  SMDS_ElemIteratorPtr eIt = aMesh.GetMeshDS()->elementsIterator();
  while( eIt->more() )
    elems.insert( elems.end(), eIt->next() );
  
  spliter.QuadToTri ( elems, /*the13Diag=*/true);
}

//=======================================================================
//function : writeInput
//purpose  : pass a mesh to input of MG-Hexa
//=======================================================================

static void writeInput(MG_Hexotic_API*     theHexaInput,
                       const char*         theFile,
                       const SMESHDS_Mesh* theMeshDS)
{
  int meshID = theHexaInput->GmfOpenMesh( theFile, GmfWrite, GMFVERSION, GMFDIMENSION);
  theHexaInput->SetIsInputMesh( true ); // it's a mesh file

  // nodes
  int iN = 0;
  smIdType nbNodes = theMeshDS->NbNodes();
  theHexaInput->GmfSetKwd( meshID, GmfVertices, nbNodes );
  std::map< const SMDS_MeshNode*, int, TIDCompare > node2IdMap;
  SMDS_NodeIteratorPtr nodeIt = theMeshDS->nodesIterator();
  SMESH_TNodeXYZ n;
  while ( nodeIt->more() )
  {
    n.Set( nodeIt->next() );
    theHexaInput->GmfSetLin( meshID, GmfVertices, n.X(), n.Y(), n.Z(), n._node->getshapeId() );
    node2IdMap.insert( node2IdMap.end(), std::make_pair( n._node, ++iN ));
  }

  // edges
  SMDS_ElemIteratorPtr elemIt = theMeshDS->elementsIterator( SMDSAbs_Edge );
  if ( elemIt->more() )
  {
    smIdType nbEdges = theMeshDS->GetMeshInfo().NbElements( SMDSAbs_Edge );
    theHexaInput->GmfSetKwd(meshID, GmfEdges, nbEdges );
    for ( int gmfID = 1; elemIt->more(); ++gmfID )
    {
      const SMDS_MeshElement* edge = elemIt->next();
      theHexaInput->GmfSetLin(meshID, GmfEdges, 
                              node2IdMap[ edge->GetNode( 0 )],
                              node2IdMap[ edge->GetNode( 1 )],
                              edge->getshapeId() );
    }
  }

  // triangles
  elemIt = theMeshDS->elementGeomIterator( SMDSGeom_TRIANGLE );
  if ( elemIt->more() )
  {
    smIdType nbTria = theMeshDS->GetMeshInfo().NbElements( SMDSGeom_TRIANGLE );
    theHexaInput->GmfSetKwd(meshID, GmfTriangles, nbTria );
    for ( int gmfID = 1; elemIt->more(); ++gmfID )
    {
      const SMDS_MeshElement* tria = elemIt->next();
      theHexaInput->GmfSetLin(meshID, GmfTriangles, 
                              node2IdMap[ tria->GetNode( 0 )],
                              node2IdMap[ tria->GetNode( 1 )],
                              node2IdMap[ tria->GetNode( 2 )],
                              tria->getshapeId() );
    }
  }
  theHexaInput->GmfCloseMesh( meshID );
}

//=======================================================================
//function : readResult
//purpose  : Read GMF file in case of a mesh with geometry
//=======================================================================

static bool readResult(MG_Hexotic_API*       theHexaOutput,
                       const char*           theFile,
                       HexoticPlugin_Hexotic*theAlgo,
                       SMESH_MesherHelper*   theHelper,
                       const int             nbShape = 0,
                       const TopoDS_Shape*   tabShape = 0,
                       double**              tabBox = 0)
{
  SMESH_Mesh*     theMesh = theHelper->GetMesh();
  SMESHDS_Mesh* theMeshDS = theHelper->GetMeshDS();

  // ---------------------------------
  // Read generated elements and nodes
  // ---------------------------------

  TopoDS_Shape aShape;
  TopoDS_Vertex aVertex;
  std::string token;
  int shapeID, hexoticShapeID;
  const int IdShapeRef = 2;
  std::vector< int > tabID;
  double epsilon = Precision::Confusion();
  std::map <std::string,int> mapField;
  std::vector< SMDS_MeshNode*> HexoticNode;
  std::vector< TopoDS_Shape > tabCorner;

  const int nbDomains = countShape( theMesh, TopAbs_SHELL );
  const int holeID = -1;

  if ( nbDomains > 0 )
  {
    tabID.resize( nbDomains, 0 );
    if ( nbDomains == 1 )
      tabID[0] = theMeshDS->ShapeToIndex( tabShape[0] );
  }
  else
  {
    tabID.resize( 1, 1 );
  }

  SMDS_ElemIteratorPtr eIt = theMeshDS->elementsIterator();
  while( eIt->more() )
    theMeshDS->RemoveFreeElement( eIt->next(), /*sm=*/0 );
  SMDS_NodeIteratorPtr nIt = theMeshDS->nodesIterator();
  while ( nIt->more() )
    theMeshDS->RemoveFreeNode( nIt->next(), /*sm=*/0 );

  theHelper->SetElementsOnShape( false );

  int ver, dim;
  int meshID = theHexaOutput->GmfOpenMesh( theFile, GmfRead, &ver, &dim );

  int nbVerticesInShape = countShape( theMesh, TopAbs_VERTEX );
  int nbVertices  = getNbShape(theHexaOutput, meshID, GmfVertices );
  int nbCorners   = getNbShape(theHexaOutput, meshID, GmfCorners, nbVerticesInShape);
  if ( nbVertices == 0 )
    return false;

  tabCorner.resize( nbCorners );
  HexoticNode.resize( nbVertices + 1 );

  // get the shape vertices if the mesh lies on a shape (and this shape has corners)
  if ( nbCorners > 0 && nbVerticesInShape > 0 )
    getShape( theMeshDS, TopAbs_VERTEX, tabCorner.data() );

  int nbNodes = theHexaOutput->GmfStatKwd( meshID, GmfVertices );
  if ( nbNodes > 0 )
  {
    theHexaOutput->GmfGotoKwd( meshID, GmfVertices );
    double x,y,z;
    for ( int aHexoticID = 1; aHexoticID <= nbNodes; ++aHexoticID )
    {
      if ( theAlgo->computeCanceled() )
        return false;
      theHexaOutput->GmfGetLin( meshID, GmfVertices, &x, &y, &z, &shapeID );
      HexoticNode[ aHexoticID ] = theHelper->AddNode( x,y,z );
    }
  }

  int nodeID[8];
  SMDS_MeshNode* node[8];
  SMDS_MeshElement * aHexoticElement;

  nbCorners = theHexaOutput->GmfStatKwd( meshID, GmfCorners );
  if ( nbCorners > 0 && nbDomains > 0 )
  {
    theHexaOutput->GmfGotoKwd( meshID, GmfCorners );
    for ( int iElem = 0; iElem < nbCorners; iElem++ )
    {
      if ( theAlgo->computeCanceled() )
        return false;
      theHexaOutput->GmfGetLin( meshID, GmfCorners, &nodeID[0] );
      node[0] = HexoticNode[ nodeID[0] ];
      gp_Pnt HexoticPnt ( node[0]->X(), node[0]->Y(), node[0]->Z() );
      for ( int i = 0; i < nbCorners; i++ )
      {
        aVertex = TopoDS::Vertex( tabCorner[i] );
        gp_Pnt aPnt = BRep_Tool::Pnt( aVertex );
        if ( aPnt.Distance( HexoticPnt ) < epsilon )
        {
          theMeshDS->SetNodeOnVertex( node[0], aVertex );
          break;
        }
      }
    }
  }

  int nbEdges = theHexaOutput->GmfStatKwd( meshID, GmfEdges );
  if ( nbEdges > 0 )
  {
    theHexaOutput->GmfGotoKwd( meshID, GmfEdges );
    for ( int iElem = 0; iElem < nbEdges; iElem++ )
    {
      if ( theAlgo->computeCanceled() )
        return false;
      theHexaOutput->GmfGetLin( meshID, GmfEdges, &nodeID[0], &nodeID[1], &shapeID );
      for ( int i = 0; i < 2; ++i )
      {
        node[i] = HexoticNode[ nodeID[i]];
        if ( shapeID > 0 && node[i]->getshapeId() < 1 )
          theMeshDS->SetNodeOnEdge( node[i], shapeID );
      }
      aHexoticElement = theHelper->AddEdge( node[0], node[1] );
      if ( shapeID > 0 && aHexoticElement->getshapeId() < 1 )
        theMeshDS->SetMeshElementOnShape( aHexoticElement, shapeID );
    }
  }

  int nbQuad = theHexaOutput->GmfStatKwd( meshID, GmfQuadrilaterals );
  if ( nbQuad > 0 )
  {
    theHexaOutput->GmfGotoKwd( meshID, GmfQuadrilaterals );
    for ( int iElem = 0; iElem < nbQuad; iElem++ )
    {
      if ( theAlgo->computeCanceled() )
        return false;
      theHexaOutput->GmfGetLin( meshID, GmfQuadrilaterals,
                                &nodeID[0], &nodeID[1], &nodeID[2], &nodeID[3], &shapeID );
      for ( int i = 0; i < 4; ++i )
      {
        node[i] = HexoticNode[ nodeID[i]];
        if ( shapeID > 0 && node[i]->getshapeId() < 1 )
          theMeshDS->SetNodeOnFace( node[i], shapeID );
      }
      aHexoticElement = theHelper->AddFace( node[0], node[1], node[2], node[3] );
      if ( shapeID > 0 && aHexoticElement->getshapeId() < 1 )
        theMeshDS->SetMeshElementOnShape( aHexoticElement, shapeID );
    }
  }

  int nbHexa = theHexaOutput->GmfStatKwd( meshID, GmfHexahedra );
  if ( nbHexa > 0 )
  {
    theHexaOutput->GmfGotoKwd( meshID, GmfHexahedra );
    for ( int iElem = 0; iElem < nbHexa; iElem++ )
    {
      if ( theAlgo->computeCanceled() )
        return false;
      theHexaOutput->GmfGetLin( meshID, GmfHexahedra,
                                &nodeID[0], &nodeID[1], &nodeID[2], &nodeID[3],
                                &nodeID[4], &nodeID[5], &nodeID[6], &nodeID[7],
                                &shapeID );
      for ( int i = 0; i < 8; ++i )
      {
        node[i] = HexoticNode[ nodeID[i]];
      }
      if ( nbDomains > 1 ) {
        hexoticShapeID = shapeID - IdShapeRef;
        if ( tabID[ hexoticShapeID ] == 0 ) {
          aShape = findShape(node, aShape, tabShape, tabBox, nbShape);
          shapeID = aShape.IsNull() ? holeID : theMeshDS->ShapeToIndex( aShape );
          tabID[ hexoticShapeID ] = shapeID;
        }
        else {
          shapeID = tabID[ hexoticShapeID ];
        }
        if ( iElem == ( nbHexa - 1) ) {
          int shapeAssociated = 0;
          for ( int i=0; i<nbDomains; i++ ) {
            if (tabID[i] > 0 )
              shapeAssociated += 1;
          }
          if ( shapeAssociated != nbShape )
            printWarning(nbShape, "domains", shapeAssociated);
        }
      }
      else {
        shapeID = tabID[0];
      }

      if ( shapeID != holeID )
      {
        for ( int i = 0; i < 8; ++i )
        {
          if ( node[i]->NbInverseElements( SMDSAbs_Face ) == 0 )
            theMeshDS->SetNodeInVolume( node[i], shapeID );
        }
        aHexoticElement = theHelper->AddVolume( node[0], node[3], node[2], node[1],
                                                node[4], node[7], node[6], node[5]);
        if ( aHexoticElement->getshapeId() < 1 )
          theMeshDS->SetMeshElementOnShape( aHexoticElement, shapeID );
      }
    }
  }
  std::cout << std::endl;

  // remove nodes in holes
  if ( nbDomains > 1 )
  {
    SMESHDS_SubMesh* subMesh = 0;
    for ( int i = 1; i <= nbNodes; ++i )
      if ( HexoticNode[i]->NbInverseElements() == 0 )
      {
        theMeshDS->RemoveFreeNode( HexoticNode[i], subMesh, /*fromGroups=*/false );
      }
  }

  // avoid "Error: No mesh on sub-shape"
  if ( theMesh->NbVolumes() > 0 )
  {
    SMESH_subMesh*         smMain = theMesh->GetSubMesh( theMesh->GetShapeToMesh() );
    SMESH_subMeshIteratorPtr smIt = smMain->getDependsOnIterator( /*includeSelf=*/true );
    while ( smIt->more() )
    {
      SMESH_subMesh* sm = smIt->next();
      if ( !sm->IsMeshComputed() )
        sm->SetIsAlwaysComputed( true );
    }
  }

  return true;
}

//=============================================================================
/*!
 * Pass parameters to MG-Hexa
 */
//=============================================================================

void HexoticPlugin_Hexotic::SetParameters(const HexoticPlugin_Hypothesis* hyp)
{
  if (hyp) {
    _hexesMinLevel = hyp->GetHexesMinLevel();
    _hexesMaxLevel = hyp->GetHexesMaxLevel();
    _hexesMinSize = hyp->GetMinSize();
    _hexesMaxSize = hyp->GetMaxSize();
    _approxAngle = hyp->GetGeomApproxAngle();
    _hexoticIgnoreRidges = hyp->GetHexoticIgnoreRidges();
    _hexoticInvalidElements = hyp->GetHexoticInvalidElements();
    _hexoticSharpAngleThreshold = hyp->GetHexoticSharpAngleThreshold();
    _hexoticNbProc = hyp->GetHexoticNbProc();
    _hexoticWorkingDirectory = hyp->GetHexoticWorkingDirectory();
    _hexoticVerbosity = hyp->GetHexoticVerbosity();
    _hexoticMaxMemory = hyp->GetHexoticMaxMemory();
    _hexoticSdMode = hyp->GetHexoticSdMode();
    _textOptions = hyp->GetAdvancedOption();
    _sizeMaps = hyp->GetSizeMaps();
    _nbLayers = hyp->GetNbLayers();
    _firstLayerSize = hyp->GetFirstLayerSize();
    _direction = hyp->GetDirection();
    _growth = hyp->GetGrowth();
    _facesWithLayers = hyp->GetFacesWithLayers();
    _imprintedFaces = hyp->GetImprintedFaces();
    _keepFiles = hyp->GetKeepFiles();
    _removeLogOnSuccess = hyp->GetRemoveLogOnSuccess();
    _logInStandardOutput = hyp->GetStandardOutputLog();
  }
  else {
    std::cout << std::endl;
    std::cout << "WARNING : The MG-Hexa default parameters are taken into account" << std::endl;
    std::cout << "=======" << std::endl;
    _hexesMinLevel = hyp->GetDefaultHexesMinLevel();
    _hexesMaxLevel = hyp->GetDefaultHexesMaxLevel();
    _hexesMinSize = hyp->GetDefaultMinSize();
    _hexesMaxSize = hyp->GetDefaultMaxSize();
    _approxAngle = hyp->GetDefaultGeomApproxAngle();
    _hexoticIgnoreRidges = hyp->GetDefaultHexoticIgnoreRidges();
    _hexoticInvalidElements = hyp->GetDefaultHexoticInvalidElements();
    _hexoticSharpAngleThreshold = hyp->GetDefaultHexoticSharpAngleThreshold();
    _hexoticNbProc = hyp->GetDefaultHexoticNbProc();
    _hexoticWorkingDirectory = hyp->GetDefaultHexoticWorkingDirectory();
    _hexoticVerbosity = hyp->GetDefaultHexoticVerbosity();
    _hexoticMaxMemory = hyp->GetDefaultHexoticMaxMemory();
    _hexoticSdMode = hyp->GetDefaultHexoticSdMode();
    _textOptions = hyp->GetDefaultTextOptions();
    _sizeMaps = hyp->GetDefaultHexoticSizeMaps();
    _nbLayers = hyp->GetDefaultNbLayers();
    _firstLayerSize = hyp->GetDefaultFirstLayerSize();
    _direction = hyp->GetDefaultDirection();
    _growth = hyp->GetDefaultGrowth();
    _facesWithLayers = hyp->GetDefaultFacesWithLayers();
    _imprintedFaces = hyp->GetDefaultImprintedFaces();
    _keepFiles = hyp->GetDefaultKeepFiles();
    _removeLogOnSuccess = hyp->GetDefaultRemoveLogOnSuccess();
    _logInStandardOutput = hyp->GetDefaultStandardOutputLog();
  }
}

//=======================================================================
//function : getSuffix
//purpose  : Returns a suffix that will be unique for the current process
//=======================================================================

static TCollection_AsciiString getSuffix()
{
  TCollection_AsciiString aSuffix = "";
  aSuffix += "_";
#ifndef WIN32
  const char* user = getenv("USER");
  aSuffix += (user ? user : "unknown");
#else
  const char* username = getenv("USERNAME");
  std::string uname = std::string(username ? username : "unknown");
  replace(uname.begin(), uname.end(), ' ', '_');
  aSuffix += uname.c_str();
#endif
  aSuffix += "_";
  std::string hostname = Kernel_Utils::GetHostname();
  aSuffix += (!hostname.empty() ? hostname.c_str() : "localhost");
  aSuffix += "_";
#ifndef WIN32
  aSuffix += getpid();
#else
  aSuffix += _getpid();
#endif

  return aSuffix;
}

//================================================================================
/*!
 * \brief Returns a command to run MG-Hexa mesher
 */
//================================================================================

std::string
HexoticPlugin_Hexotic::getHexoticCommand(const TCollection_AsciiString& Hexotic_In,
                                         const TCollection_AsciiString& Hexotic_Out,
                                         const TCollection_AsciiString& Hexotic_SizeMap_Prefix,
                                         const bool                     forExecutable) const
{
  std::cout << std::endl;
  std::cout << "MG-Hexa execution..." << std::endl;
  std::cout << _name << " parameters :" << std::endl;
  std::cout << "    " << _name << " Verbosity = " << _hexoticVerbosity << std::endl;
  std::cout << "    " << _name << " Max Memory = " << _hexoticMaxMemory << std::endl;
  std::cout << "    " << _name << " Segments Min Level = " << _hexesMinLevel << std::endl;
  std::cout << "    " << _name << " Segments Max Level = " << _hexesMaxLevel << std::endl;
  std::cout << "    " << _name << " Segments Min Size = " << _hexesMinSize << std::endl;
  std::cout << "    " << _name << " Segments Max Size = " << _hexesMaxSize << std::endl;
  std::cout << "    " << "MG-Hexa can ignore ridges : " << (_hexoticIgnoreRidges ? "yes":"no") << std::endl;
  std::cout << "    " << "MG-Hexa authorize invalide elements : " << ( _hexoticInvalidElements ? "yes":"no") << std::endl;
  std::cout << "    " << _name << " Sharp angle threshold = " << _hexoticSharpAngleThreshold << " degrees" << std::endl;
  std::cout << "    " << _name << " Number of threads = " << _hexoticNbProc << std::endl;
  std::cout << "    " << _name << " Working directory = \"" << _hexoticWorkingDirectory << "\"" << std::endl;
  std::cout << "    " << _name << " Sub. Dom mode = " << _hexoticSdMode << std::endl;
  std::cout << "    " << _name << " Text options = \"" << _textOptions << "\"" << std::endl;
  std::cout << "    " << _name << " Number of layers = " << _nbLayers << std::endl;
  std::cout << "    " << _name << " Size of the first layer  = " << _firstLayerSize << std::endl;
  std::cout << "    " << _name << " Direction of the layers = " << ( _direction ? "Inward" : "Outward" ) << std::endl;
  std::cout << "    " << _name << " Growth = " << _growth << std::endl;
  if (!_facesWithLayers.empty()) {
    std::cout << "    " << _name << " Faces with layers = ";
    for (size_t i = 0; i < _facesWithLayers.size(); i++)
    {
      std::cout << _facesWithLayers.at(i);
      if ((i + 1) != _facesWithLayers.size())
        std::cout << ", ";
    }
    std::cout << std::endl;
  }
  if (!_imprintedFaces.empty()) {
    std::cout << "    " << _name << " Imprinted faces = ";
    for (size_t i = 0; i < _imprintedFaces.size(); i++)
    {
      std::cout << _imprintedFaces.at(i);
      if ((i + 1) != _imprintedFaces.size())
        std::cout << ", ";
    }
    std::cout << std::endl;
  }

  TCollection_AsciiString run_Hexotic("mg-hexa.exe");

  TCollection_AsciiString minl         = " --min_level ", maxl = " --max_level ", angle = " --ridge_angle ";
  TCollection_AsciiString mins         = " --min_size ", maxs = " --max_size ";
  TCollection_AsciiString in           = " --in ",   out  = " --out ";
  TCollection_AsciiString sizeMap      = " --background_sizemap ";
  TCollection_AsciiString sizeMapMesh  = " --background_mesh ";
  TCollection_AsciiString ignoreRidges = " --compute_ridges no ", invalideElements = " --allow_invalid_elements yes ";
  TCollection_AsciiString subdom       = " --components ";
#ifndef WIN32
  TCollection_AsciiString proc         = " --max_number_of_threads ";
#endif
  TCollection_AsciiString verb         = " --verbose ";
  TCollection_AsciiString maxmem       = " --max_memory ";

  TCollection_AsciiString comNbLayers        = " --number_of_boundary_layers ";
  TCollection_AsciiString comFirstLayerSize  = " --height_of_the_first_layer ";
  TCollection_AsciiString comDirection       = " --boundary_layers_subdomain_direction ";
  TCollection_AsciiString comGrowth          = " --boundary_layers_geometric_progression ";
  TCollection_AsciiString comFacesWithLayers = " --boundary_layers_surface_ids ";
  TCollection_AsciiString comImptintedFaces  = " --imprinted_surface_ids ";

  TCollection_AsciiString minLevel, maxLevel, minSize, maxSize, sharpAngle, mode, nbproc, verbosity, maxMemory,
                          textOptions, nbLayers, firstLayerSize, direction, growth, facesWithLayers, imprintedFaces;
  minLevel   = _hexesMinLevel;
  maxLevel   = _hexesMaxLevel;
  minSize    = _hexesMinSize;
  maxSize    = _hexesMaxSize;
  sharpAngle = _hexoticSharpAngleThreshold;
  // Mode translation for mg-tetra 1.1
  switch ( _hexoticSdMode )
  {
    case 1:
      mode = "outside_skin_only";
      break;
    case 2:
      mode = "outside_components";
      break;
    case 3:
      mode = "all";
      break;
    case 4:
      mode = "all --manifold_geometry no";
      break;
  }
  nbproc         = _hexoticNbProc;
  verbosity      = _hexoticVerbosity;
  maxMemory      = _hexoticMaxMemory;
  textOptions    = (" " + _textOptions + " ").c_str();
  nbLayers       = _nbLayers;
  firstLayerSize = _firstLayerSize;
  direction      = _direction ? "1" : "-1";
  growth         = _growth;
  for (size_t i = 0; i < _facesWithLayers.size(); i++)
  {
    facesWithLayers += _facesWithLayers[i];
    if ((i + 1) != _facesWithLayers.size())
      facesWithLayers += ",";
  }
  for (size_t i = 0; i < _imprintedFaces.size(); i++)
  {
    imprintedFaces += _imprintedFaces[i];
    if ((i + 1) != _imprintedFaces.size())
      imprintedFaces += ",";
  }

  if (_hexoticIgnoreRidges)
    run_Hexotic +=  ignoreRidges;

  if (_hexoticInvalidElements)
    run_Hexotic +=  invalideElements;

  if (_hexesMinSize > 0)
    run_Hexotic +=  mins + minSize;

  if (_hexesMaxSize > 0)
    run_Hexotic +=  maxs + maxSize;

  if (_hexesMinLevel > 0)
    run_Hexotic +=  minl + minLevel;

  if (_hexesMaxLevel > 0)
    run_Hexotic +=  maxl + maxLevel;

  if (_hexoticSharpAngleThreshold > 0)
    run_Hexotic +=  angle + sharpAngle;

  if ( !_sizeMaps.empty() && forExecutable )
    run_Hexotic += ( sizeMap     + Hexotic_SizeMap_Prefix + ".sol " +
                     sizeMapMesh + Hexotic_SizeMap_Prefix + ".mesh " );

  if (_nbLayers       > 0 &&
      _firstLayerSize > 0 &&
      _growth         > 0 &&
      !_facesWithLayers.empty())
  {
    run_Hexotic += comNbLayers + nbLayers;
    run_Hexotic += comFirstLayerSize + firstLayerSize;
    run_Hexotic += comDirection + direction;
    run_Hexotic += comGrowth + growth;
    run_Hexotic += comFacesWithLayers + facesWithLayers;
    if (!_imprintedFaces.empty())
      run_Hexotic += comImptintedFaces + imprintedFaces;
  }
  if ( forExecutable )
    run_Hexotic += in + Hexotic_In + out + Hexotic_Out;
  run_Hexotic += subdom + mode;
#ifndef WIN32
  run_Hexotic += proc + nbproc;
#endif
  run_Hexotic += verb + verbosity;
  run_Hexotic += maxmem + maxMemory;

  if (!_textOptions.empty())
    run_Hexotic += textOptions;

  return run_Hexotic.ToCString();
}

// TODO : this is a duplication of some code found in BLSURFPlugin_BLSURF find a proper
// way to share it
TopoDS_Shape HexoticPlugin_Hexotic::entryToShape(std::string entry)
{
  GEOM::GEOM_Object_var aGeomObj;
  TopoDS_Shape S = TopoDS_Shape();
  SALOMEDS::SObject_var aSObj = SMESH_Gen_i::GetSMESHGen()->getStudyServant()->FindObjectID( entry.c_str() );
  if (!aSObj->_is_nil()) {
    CORBA::Object_var obj = aSObj->GetObject();
    aGeomObj = GEOM::GEOM_Object::_narrow(obj);
    aSObj->UnRegister();
  }
  if ( !aGeomObj->_is_nil() )
    S = SMESH_Gen_i::GetSMESHGen()->GeomObjectToShape( aGeomObj.in() );
  return S;
}

//================================================================================
/*!
 * \brief Produces a .mesh file with the size maps informations to give to Hexotic
 */
//================================================================================

std::vector<std::string> HexoticPlugin_Hexotic::writeSizeMapFile( MG_Hexotic_API* mgInput,
                                                                  std::string     sizeMapPrefix )
{
  HexoticPlugin_Hypothesis::THexoticSizeMaps::iterator it;

  std::vector<ControlPnt> points;
  // Iterate on the size maps
  for (it=_sizeMaps.begin(); it!=_sizeMaps.end(); it++)
  {
    // Step 1 : Get the GEOM object entry and the size 
    // from the _sizeMaps infos
    std::string anEntry = it->first;
    double aLocalSize = it->second;
    TopoDS_Shape aShape = entryToShape( anEntry );
    
    // Step 2 : Create the points
    createControlPoints( aShape, aLocalSize, points );
  }

  // Write the .mesh size map file

  std::string myVerticesFile = sizeMapPrefix + ".mesh";
  std::string      mySolFile = sizeMapPrefix + ".sol";
  
  // Open files
  int verticesFileID =
    mgInput->GmfOpenMesh( myVerticesFile.c_str(), GmfWrite, GMFVERSION, GMFDIMENSION );  
  int solFileID =
    mgInput->GmfOpenMesh( mySolFile.c_str(), GmfWrite, GMFVERSION, GMFDIMENSION );

  mgInput->SetIsInputMesh( false ); // they are not mesh files
  
  int pointsNumber = points.size();
  
  // Vertices Keyword
  mgInput->GmfSetKwd( verticesFileID, GmfVertices, pointsNumber );
  // SolAtVertices Keyword
  int TypTab[] = {GmfSca};
  mgInput->GmfSetKwd(solFileID, GmfSolAtVertices, pointsNumber, 1, TypTab);
  
  // Read the control points information from the vector and write it into the files
  double ValTab[1];
  std::vector<ControlPnt>::const_iterator points_it;
  for (points_it = points.begin(); points_it != points.end(); points_it++ )
  {
    mgInput->GmfSetLin( verticesFileID, GmfVertices, points_it->X(), points_it->Y(), points_it->Z(), 0 );
    ValTab[0] = points_it->Size();
    mgInput->GmfSetLin( solFileID, GmfSolAtVertices, ValTab);
  }

  // Close Files
  mgInput->GmfCloseMesh( verticesFileID );
  chmodUserOnly(myVerticesFile.c_str());
  mgInput->GmfCloseMesh( solFileID );
  chmodUserOnly(mySolFile.c_str());

  std::vector<std::string> fileNames(2);
  fileNames[0] = myVerticesFile;
  fileNames[1] = mySolFile;

  return fileNames;
}

//=============================================================================
/*!
 * Here we are going to use the MG-Hexa mesher
 */
//=============================================================================

bool HexoticPlugin_Hexotic::Compute(SMESH_Mesh&          aMesh,
                                    const TopoDS_Shape& /*aShape*/)
{
  _computeCanceled = false;
  bool Ok = true;
  SMESHDS_Mesh* meshDS = aMesh.GetMeshDS();
  TCollection_AsciiString hexahedraMessage;

  _nbShape = countShape( &aMesh, TopAbs_SOLID );  // we count the number of shapes

  {
    // create bounding box for each shape of the compound

    int iShape = 0;
    TopoDS_Shape *tabShape;
    double **tabBox;

    tabShape = new TopoDS_Shape[_nbShape];
    tabBox   = new double*[_nbShape];
    for (int i=0; i<_nbShape; i++)
      tabBox[i] = new double[6];
    double Xmin, Ymin, Zmin, Xmax, Ymax, Zmax;

    TopExp_Explorer expBox (meshDS->ShapeToMesh(), TopAbs_SOLID);
    for (; expBox.More(); expBox.Next()) {
      tabShape[iShape] = expBox.Current();
      Bnd_Box BoundingBox;
      BRepBndLib::Add(expBox.Current(), BoundingBox);
      BoundingBox.Get(Xmin, Ymin, Zmin, Xmax, Ymax, Zmax);
      tabBox[iShape][0] = Xmin; tabBox[iShape][1] = Xmax;
      tabBox[iShape][2] = Ymin; tabBox[iShape][3] = Ymax;
      tabBox[iShape][4] = Zmin; tabBox[iShape][5] = Zmax;
      iShape++;
    }

    SetParameters(_hypothesis);

    TCollection_AsciiString aTmpDir = Kernel_Utils::GetTmpDirByPath(_hexoticWorkingDirectory).c_str();
    TCollection_AsciiString aQuote("");
#ifdef WIN32
    aQuote = "\"";
    if ( aTmpDir.Value(aTmpDir.Length()) != '\\' ) aTmpDir += '\\';
#else
    if ( aTmpDir.Value(aTmpDir.Length()) != '/' ) aTmpDir += '/';
#endif
    TCollection_AsciiString Hexotic_In(""), Hexotic_Out, Hexotic_SizeMap_Prefix;
    TCollection_AsciiString aLogFileName = aTmpDir + "Hexotic"+getSuffix()+".log";    // log

    std::map <int,int> aSmdsToHexoticIdMap;
    std::map <int,const SMDS_MeshNode*> aHexoticIdToNodeMap;

    MG_Hexotic_API mgHexa( _computeCanceled, _progress );

    Hexotic_Out = aTmpDir + "Hexotic"+getSuffix()+"_Out.mesh";
#ifdef WITH_BLSURFPLUGIN
    bool defaultInputFile = true;
    if (_blsurfHypo && _blsurfHypo->GetElementType() == BLSURFPlugin_Hypothesis::Triangles ) {
      Hexotic_In = _blsurfHypo->GetGMFFile().c_str();
      if ( !Hexotic_In.IsEmpty() &&
           SMESH_File( _blsurfHypo->GetGMFFile() ).exists() )
      {
        MESSAGE("Use output file from blsurf as input file from hexotic: " << Hexotic_In);
        mgHexa.SetUseExecutable();
        mgHexa.SetInputFile( _blsurfHypo->GetGMFFile() );
        defaultInputFile = false;
      }
    }
    if (defaultInputFile) {
#endif
      Hexotic_In  = aTmpDir + "Hexotic"+getSuffix()+"_In.mesh";
      removeHexoticFiles(Hexotic_In, Hexotic_Out);
      splitQuads(aMesh); // quadrangles are no longer acceptable as input
      if ( mgHexa.IsExecutable() )
      {
        std::cout << std::endl;
        std::cout << "Creating MG-Hexa input mesh file : " << Hexotic_In << std::endl;
      }
      writeInput( &mgHexa, Hexotic_In.ToCString(), meshDS );
#ifdef WITH_BLSURFPLUGIN
    }
    else {
      removeFile( Hexotic_Out );
    }
#endif
    
    Hexotic_SizeMap_Prefix = aTmpDir + "Hexotic_SizeMap" + getSuffix();
    std::vector<std::string> sizeMapFiles = writeSizeMapFile( &mgHexa, Hexotic_SizeMap_Prefix.ToCString() );
  
    std::string run_Hexotic = getHexoticCommand(aQuote + Hexotic_In + aQuote, aQuote + Hexotic_Out + aQuote, Hexotic_SizeMap_Prefix, mgHexa.IsExecutable() );
    run_Hexotic += std::string(" 1> ") + aQuote.ToCString() + aLogFileName.ToCString() + aQuote.ToCString();  // dump into file
    mgHexa.SetLogFile( aLogFileName.ToCString() );
    std::cout << "Creating MG-Hexa log file : " << aLogFileName << std::endl;

    std::cout << std::endl;
    std::cout << "MG-Hexa command : " << run_Hexotic << std::endl;

    if ( mgHexa.IsExecutable() )
    {
      chmodUserOnly(Hexotic_In.ToCString());
    }
    aSmdsToHexoticIdMap.clear();
    aHexoticIdToNodeMap.clear();

    MESSAGE("HexoticPlugin_Hexotic::Compute");

    
    std::string errStr;
    Ok = mgHexa.Compute( run_Hexotic, errStr ); // run

    chmodUserOnly(aLogFileName.ToCString());

    // --------------
    // read a result
    // --------------

    if ( mgHexa.IsExecutable() )
    {
      chmodUserOnly( Hexotic_Out.ToCString() );
    }
    SMESH_MesherHelper aHelper( aMesh );

    Ok = readResult( &mgHexa, Hexotic_Out.ToCString(),
                     this,
                     &aHelper, _nbShape, tabShape, tabBox );

    std::string log = mgHexa.GetLog();
    hexahedraMessage = "failed";
    if ( Ok )
    {
      hexahedraMessage = "success";
      if ( _removeLogOnSuccess )
        removeFile( aLogFileName );
    }
    else if ( !log.empty() )
    {
      if( _computeCanceled )
        error( "interruption initiated by user" );
      else
      {
        // get problem description from the log file
        char msgLic1[] = "connection to server failed";
        char msgLic2[] = " Dlim ";
        char msgLic3[] = "license is not valid";
        const char* fileBeg = &log[0], *fileEnd = fileBeg + log.size();
        if ( std::search( fileBeg, fileEnd, msgLic1, msgLic1+strlen(msgLic1)) != fileEnd ||
             std::search( fileBeg, fileEnd, msgLic2, msgLic2+strlen(msgLic2)) != fileEnd
            )
          error("Network license problem.");
        else if ( std::search( fileBeg, fileEnd, msgLic3, msgLic3 + strlen(msgLic3)) != fileEnd )
          error("License is not valid.");
      }
    }
    else if ( !errStr.empty() )
    {
      // the log file is empty
      removeFile( aLogFileName );
      INFOS( "MG-Hexa Error, " << errStr);
      error(COMPERR_ALGO_FAILED, errStr);
    }

    if ( !Ok && mgHexa.IsExecutable() )
      std::cout << "Problem with MG-Hexa output file " << Hexotic_Out.ToCString() << std::endl;

    if ( !_keepFiles )
    {
      removeFile(Hexotic_Out);
      removeFile(Hexotic_In);
      for ( size_t i = 0; i < sizeMapFiles.size(); i++ )
        removeFile( sizeMapFiles[i].c_str() );
    }
    std::cout << "Hexahedra meshing " << hexahedraMessage << std::endl;
    std::cout << std::endl;

    delete [] tabShape;
    for (int i=0; i<_nbShape; i++)
      delete [] tabBox[i];
    delete [] tabBox;
    _nbShape = 0;
    _iShape  = 0;
  }

  return Ok;
}

//=============================================================================
/*!
 * \brief Computes mesh without geometry
 *  \param aMesh - the mesh
 *  \param aHelper - helper that must be used for adding elements to \aaMesh
 *  \retval bool - is a success
 *
 * The method is called if ( !aMesh->HasShapeToMesh() )
 */
//=============================================================================

bool HexoticPlugin_Hexotic::Compute(SMESH_Mesh & aMesh, SMESH_MesherHelper* aHelper)
{
  _computeCanceled = false;

  bool Ok = true;
  TCollection_AsciiString hexahedraMessage;
  TCollection_AsciiString aQuote("");
#ifdef WIN32
  aQuote = "\"";
#endif
  SetParameters(_hypothesis);

  TCollection_AsciiString aTmpDir = _hexoticWorkingDirectory.c_str();//getTmpDir();
  TCollection_AsciiString Hexotic_In, Hexotic_Out, Hexotic_SizeMap_Prefix;
  TCollection_AsciiString aLogFileName = aTmpDir + "Hexotic"+getSuffix()+".log";    // log

  std::map <int,int> aSmdsToHexoticIdMap;
  std::map <int,const SMDS_MeshNode*> aHexoticIdToNodeMap;

  Hexotic_In  = aTmpDir + "Hexotic"+getSuffix()+"_In.mesh";
  Hexotic_Out = aTmpDir + "Hexotic"+getSuffix()+"_Out.mesh";
  Hexotic_SizeMap_Prefix = aTmpDir + "Hexotic_SizeMap";

  MG_Hexotic_API mgHexa( _computeCanceled, _progress );

  std::vector<std::string> sizeMapFiles = writeSizeMapFile( &mgHexa, Hexotic_SizeMap_Prefix.ToCString() );

  std::string run_Hexotic = getHexoticCommand(aQuote + Hexotic_In + aQuote, aQuote + Hexotic_Out + aQuote, Hexotic_SizeMap_Prefix, mgHexa.IsExecutable());
  run_Hexotic += std::string(" 1> ") + aQuote.ToCString() + aLogFileName.ToCString() + aQuote.ToCString();  // dump into file
  mgHexa.SetLogFile( aLogFileName.ToCString() );
  std::cout << "Creating MG-Hexa log file : " << aLogFileName << std::endl;

  removeHexoticFiles(Hexotic_In, Hexotic_Out);

  splitQuads(aMesh); // quadrangles are no longer acceptable as input

  std::cout << std::endl;
  std::cout << "Creating MG-Hexa input mesh file : " << Hexotic_In << std::endl;
  writeInput( &mgHexa, Hexotic_In.ToCString(), aHelper->GetMeshDS() );
  if ( mgHexa.IsExecutable() )
  {
    chmodUserOnly( Hexotic_In.ToCString() );
  }
  aSmdsToHexoticIdMap.clear();
  aHexoticIdToNodeMap.clear();

  MESSAGE("HexoticPlugin_Hexotic::Compute");

  std::cout << std::endl;
  std::cout << "MG-Hexa command : " << run_Hexotic << std::endl;

  std::string errStr;
  Ok = mgHexa.Compute( run_Hexotic, errStr ); // run

  chmodUserOnly(aLogFileName.ToCString());

  // --------------
  // read a result
  // --------------

  if ( mgHexa.IsExecutable() )
  {
    chmodUserOnly(Hexotic_Out.ToCString());
  }

  Ok = Ok && readResult( &mgHexa, Hexotic_Out.ToCString(), this, aHelper );

  std::string log = mgHexa.GetLog();
  if ( Ok )
  {
    hexahedraMessage = "success";
  }
  else
  {
    hexahedraMessage = "failed";
    if ( mgHexa.IsExecutable() )
      std::cout << "Problem with MG-Hexa output file " << Hexotic_Out << std::endl;

    if ( log.find( " license " ) != std::string::npos ||
         log.find( " Dlim "    ) != std::string::npos )
      error("License problems.");

    if ( !errStr.empty() )
      error(errStr);
  }
  std::cout << "Hexahedra meshing " << hexahedraMessage << std::endl;
  std::cout << std::endl;

  if (_computeCanceled)
    return error(SMESH_Comment("interruption initiated by user"));
  if ( !_keepFiles )
  {
    removeFile(Hexotic_Out);
    removeFile(Hexotic_In);
    for( size_t i=0; i<sizeMapFiles.size(); i++)
    {
      removeFile( TCollection_AsciiString(sizeMapFiles[i].c_str()) );
    }
  }
  if ( Ok && _removeLogOnSuccess )
    removeFile(aLogFileName);
  return Ok;
}

//=============================================================================
/*!
 *
 */
//=============================================================================

bool HexoticPlugin_Hexotic::Evaluate(SMESH_Mesh&         aMesh,
                                     const TopoDS_Shape& aShape,
                                     MapShapeNbElems&    aResMap)
{
  std::vector<smIdType> aResVec(SMDSEntity_Last);
  for(smIdType i=SMDSEntity_Node; i<SMDSEntity_Last; i++) aResVec[i] = 0;
  SMESH_subMesh * sm = aMesh.GetSubMesh(aShape);
  aResMap.insert(std::make_pair(sm,aResVec));

  SMESH_ComputeErrorPtr& smError = sm->GetComputeError();
  smError.reset( new SMESH_ComputeError(COMPERR_ALGO_FAILED,"Evaluation is not implemented",this));

  return true;
}

void HexoticPlugin_Hexotic::CancelCompute()
{
  _computeCanceled = true;
#ifdef WIN32
#else
  TCollection_AsciiString aTmpDir = _hexoticWorkingDirectory.c_str(); //getTmpDir();
  TCollection_AsciiString Hexotic_In = aTmpDir + "Hexotic_In.mesh";
  TCollection_AsciiString cmd = TCollection_AsciiString("ps ux | grep ") + Hexotic_In;
  cmd += TCollection_AsciiString(" | grep -v grep | awk '{print $2}' | xargs kill -9 > /dev/null 2>&1");
  system( cmd.ToCString() );
#endif
}
