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
// File   : HYBRIDPlugin_HYBRID.cxx
// Author : Christian VAN WAMBEKE (CEA) (from GHS3D plugin V730)
// ---
//
#include "HYBRIDPlugin_HYBRID.hxx"
#include "HYBRIDPlugin_Hypothesis.hxx"
#include "MG_HYBRID_API.hxx"

#include <SMDS_FaceOfNodes.hxx>
#include <SMDS_LinearEdge.hxx>
#include <SMDS_VolumeOfNodes.hxx>
#include <SMESHDS_Group.hxx>
#include <SMESHDS_Mesh.hxx>
#include <SMESH_Comment.hxx>
#include <SMESH_File.hxx>
#include <SMESH_Group.hxx>
#include <SMESH_HypoFilter.hxx>
#include <SMESH_Mesh.hxx>
#include <SMESH_MeshAlgos.hxx>
#include <SMESH_MeshEditor.hxx>
#include <SMESH_MesherHelper.hxx>
#include <SMESH_ProxyMesh.hxx>
#include <SMESH_subMeshEventListener.hxx>

#include <BRepAdaptor_Surface.hxx>
#include <BRepBndLib.hxx>
#include <BRepBuilderAPI_MakeVertex.hxx>
#include <BRepClass3d.hxx>
#include <BRepClass3d_SolidClassifier.hxx>
#include <BRepExtrema_DistShapeShape.hxx>
#include <BRepGProp.hxx>
#include <BRepTools.hxx>
#include <BRep_Tool.hxx>
#include <Bnd_Box.hxx>
#include <GProp_GProps.hxx>
#include <GeomAPI_ProjectPointOnSurf.hxx>
#include <Precision.hxx>
#include <Standard_ErrorHandler.hxx>
#include <Standard_Failure.hxx>
#include <Standard_ProgramError.hxx>
#include <TopExp.hxx>
#include <TopExp_Explorer.hxx>
#include <TopTools_IndexedMapOfShape.hxx>
#include <TopTools_ListIteratorOfListOfShape.hxx>
#include <TopTools_MapOfShape.hxx>
#include <TopoDS.hxx>
#include <TopoDS_Shell.hxx>
#include <TopoDS_Solid.hxx>

#include <Basics_Utils.hxx>
#include <utilities.h>

#include <boost/filesystem.hpp>
namespace boofs = boost::filesystem;

#include <fstream>
#include <algorithm>

#define castToNode(n) static_cast<const SMDS_MeshNode *>( n );

#ifndef GMFVERSION
#define GMFVERSION GmfDouble
#endif
#define GMFDIMENSION 3

#define HOLE_ID -1

typedef const std::list<const SMDS_MeshFace*> TTriaList;

static const char theDomainGroupNamePrefix[] = "Domain_";

static void removeFile( const std::string& fileName )
{
  try {
    SMESH_File( fileName ).remove();
  }
  catch ( ... ) {
    MESSAGE("Can't remove file: " << fileName << " ; file does not exist or permission denied");
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

HYBRIDPlugin_HYBRID::HYBRIDPlugin_HYBRID(int hypId, SMESH_Gen* gen)
  : SMESH_3D_Algo(hypId, gen)
{
  _name = Name();
  _shapeType = (1 << TopAbs_SHELL) | (1 << TopAbs_SOLID);// 1 bit /shape type
  _onlyUnaryInput = true; // Compute() will be called on each solid
  _iShape=0;
  _nbShape=0;
  _compatibleHypothesis.push_back( HYBRIDPlugin_Hypothesis::GetHypType());
  _requireShape = false; // can work without shape
  _computeCanceled = false;
}

//=============================================================================
/*!
 *  
 */
//=============================================================================

HYBRIDPlugin_HYBRID::~HYBRIDPlugin_HYBRID()
{
}

//=============================================================================
/*!
 *  
 */
//=============================================================================

bool HYBRIDPlugin_HYBRID::CheckHypothesis ( SMESH_Mesh&         aMesh,
                                          const TopoDS_Shape& aShape,
                                          Hypothesis_Status&  aStatus )
{
  aStatus = SMESH_Hypothesis::HYP_OK;

  _hyp = 0;
  _keepFiles = false;
  _removeLogOnSuccess = true;
  _logInStandardOutput = false;

  const std::list <const SMESHDS_Hypothesis * >& hyps =
    GetUsedHypothesis(aMesh, aShape, /*ignoreAuxiliary=*/false);
  std::list <const SMESHDS_Hypothesis* >::const_iterator h = hyps.begin();
  for ( ; h != hyps.end(); ++h )
  {
    if ( !_hyp )
      _hyp = dynamic_cast< const HYBRIDPlugin_Hypothesis*> ( *h );
  }
  if ( _hyp )
  {
    _keepFiles = _hyp->GetKeepFiles();
    _removeLogOnSuccess = _hyp->GetRemoveLogOnSuccess();
    _logInStandardOutput = _hyp->GetStandardOutputLog();
  }

  return true;
}


//=======================================================================
//function : entryToShape
//purpose  : 
//=======================================================================

TopoDS_Shape HYBRIDPlugin_HYBRID::entryToShape(std::string entry)
{
  if ( SMESH_Gen_i::GetSMESHGen()->getStudyServant()->_is_nil() )
    throw SALOME_Exception("MG-HYBRID plugin can't work w/o publishing in the study");
  GEOM::GEOM_Object_var aGeomObj;
  TopoDS_Shape S = TopoDS_Shape();
  SALOMEDS::SObject_var aSObj = SMESH_Gen_i::GetSMESHGen()->getStudyServant()->FindObjectID( entry.c_str() );
  if (!aSObj->_is_nil() ) {
    CORBA::Object_var obj = aSObj->GetObject();
    aGeomObj = GEOM::GEOM_Object::_narrow(obj);
    aSObj->UnRegister();
  }
  if ( !aGeomObj->_is_nil() )
    S = SMESH_Gen_i::GetSMESHGen()->GeomObjectToShape( aGeomObj.in() );
  return S;
}

//=======================================================================
//function : addElemInMeshGroup
//purpose  : Update or create groups in mesh
//=======================================================================

static void addElemInMeshGroup(SMESH_Mesh*             theMesh,
                               const SMDS_MeshElement* anElem,
                               std::string&            groupName,
                               std::set<std::string>&  /*groupsToRemove*/)
{
  if ( !anElem ) return; // issue 0021776

  bool groupDone = false;
  SMESH_Mesh::GroupIteratorPtr grIt = theMesh->GetGroups();
  while (grIt->more()) {
    SMESH_Group * group = grIt->next();
    if ( !group ) continue;
    SMESHDS_GroupBase* groupDS = group->GetGroupDS();
    if ( !groupDS ) continue;
    if ( groupDS->GetType()==anElem->GetType() &&groupName.compare(group->GetName())==0) {
      SMESHDS_Group* aGroupDS = static_cast<SMESHDS_Group*>( groupDS );
      aGroupDS->SMDSGroup().Add(anElem);
      groupDone = true;
      break;
    }
  }
  
  if (!groupDone)
  {
    SMESH_Group* aGroup = theMesh->AddGroup(anElem->GetType(), groupName.c_str());
    aGroup->SetName( groupName.c_str() );
    SMESHDS_Group* aGroupDS = static_cast<SMESHDS_Group*>( aGroup->GetGroupDS() );
    aGroupDS->SMDSGroup().Add(anElem);
    groupDone = true;
  }
  if (!groupDone)
    throw SALOME_Exception(LOCALIZED("A given element was not added to a group"));
}


//=======================================================================
//function : updateMeshGroups
//purpose  : Update or create groups in mesh
//=======================================================================

static void updateMeshGroups(SMESH_Mesh* theMesh, std::set<std::string> groupsToRemove)
{
  SMESH_Mesh::GroupIteratorPtr grIt = theMesh->GetGroups();
  while (grIt->more()) {
    SMESH_Group * group = grIt->next();
    if ( !group ) continue;
    SMESHDS_GroupBase* groupDS = group->GetGroupDS();
    if ( !groupDS ) continue;
    std::string currentGroupName = (std::string)group->GetName();
    if (groupDS->IsEmpty() && groupsToRemove.find(currentGroupName) != groupsToRemove.end()) {
      // Previous group created by enforced elements
      theMesh->RemoveGroup(groupDS->GetID());
    }
  }
}

//=======================================================================
//function : removeEmptyGroupsOfDomains
//purpose  : remove empty groups named "Domain_nb" created due to
//           "To make groups of domains" option.
//=======================================================================

static void removeEmptyGroupsOfDomains(SMESH_Mesh* mesh,
                                       bool        notEmptyAsWell = false)
{
  const char* refName = theDomainGroupNamePrefix;
  const size_t refLen = strlen( theDomainGroupNamePrefix );

  std::list<int> groupIDs = mesh->GetGroupIds();
  std::list<int>::const_iterator id = groupIDs.begin();
  for ( ; id != groupIDs.end(); ++id )
  {
    SMESH_Group* group = mesh->GetGroup( *id );
    if ( !group || ( !group->GetGroupDS()->IsEmpty() && !notEmptyAsWell ))
      continue;
    const char* name = group->GetName();
    char* end;
    // check the name
    if ( strncmp( name, refName, refLen ) == 0 && // starts from refName;
         isdigit( *( name + refLen )) &&          // refName is followed by a digit;
         strtol( name + refLen, &end, 10) >= 0 && // there are only digits ...
         *end == '\0')                            // ... till a string end.
    {
      mesh->RemoveGroup( *id );
    }
  }
}

//================================================================================
/*!
 * \brief Create the groups corresponding to domains
 */
//================================================================================

static void makeDomainGroups( std::vector< std::vector< const SMDS_MeshElement* > >& elemsOfDomain,
                              SMESH_MesherHelper*                                    theHelper)
{
  for ( size_t iDomain = 0; iDomain < elemsOfDomain.size(); ++iDomain )
  {
    std::vector< const SMDS_MeshElement* > & elems = elemsOfDomain[ iDomain ];
    if ( elems.empty() ) continue;

    // find existing groups
    std::vector< SMESH_Group* > groupOfType( SMDSAbs_NbElementTypes, (SMESH_Group*)NULL );
    const std::string domainName = ( SMESH_Comment( theDomainGroupNamePrefix ) << iDomain );
    SMESH_Mesh::GroupIteratorPtr groupIt = theHelper->GetMesh()->GetGroups();
    while ( groupIt->more() )
    {
      SMESH_Group* group = groupIt->next();
      if ( domainName == group->GetName() &&
           dynamic_cast< SMESHDS_Group* >( group->GetGroupDS()) )
        groupOfType[ group->GetGroupDS()->GetType() ] = group;
    }
    // create and fill the groups
    size_t iElem = 0;
    do
    {
      SMESH_Group* group = groupOfType[ elems[ iElem ]->GetType() ];
      if ( !group )
        group = theHelper->GetMesh()->AddGroup( elems[ iElem ]->GetType(),
                                                domainName.c_str() );
      SMDS_MeshGroup& groupDS =
        static_cast< SMESHDS_Group* >( group->GetGroupDS() )->SMDSGroup();

      while ( iElem < elems.size() && groupDS.Add( elems[iElem] ))
        ++iElem;

    } while ( iElem < elems.size() );
  }
}

//=======================================================================
//function : readGMFFile
//purpose  : read GMF file w/o geometry associated to mesh
//=======================================================================

static bool readGMFFile(MG_HYBRID_API*                          MGOutput,
                        const char*                             theFile,
                        HYBRIDPlugin_HYBRID*                    theAlgo,
                        SMESH_MesherHelper*                     theHelper,
                        std::vector <const SMDS_MeshNode*> &    theNodeByHybridId,
                        std::vector <const SMDS_MeshElement*> & theFaceByHybridId,
                        std::map<const SMDS_MeshNode*,int> &    /*theNodeToHybridIdMap*/,
                        std::vector<std::string> &              aNodeGroupByHybridId,
                        std::vector<std::string> &              anEdgeGroupByHybridId,
                        std::vector<std::string> &              aFaceGroupByHybridId,
                        std::set<std::string> &                 groupsToRemove,
                        bool                                    toMakeGroupsOfDomains=false,
                        bool                                    /*toMeshHoles*/=true)
{
  std::string tmpStr;
  SMESHDS_Mesh* theMeshDS = theHelper->GetMeshDS();
  const bool hasGeom = ( theHelper->GetMesh()->HasShapeToMesh() );

  // if imprinting, the original mesh faces are modified
  // => we clear all the faces to retrieve them from Hybrid output mesh.
  std::vector<int> facesWithImprinting;
  if (theAlgo->getHyp())
    facesWithImprinting = theAlgo->getHyp()->GetFacesWithImprinting();

  if ( ! facesWithImprinting.empty() ) {
#ifdef _DEBUG_
    std::cout << "Imprinting => Clear original mesh" << std::endl;
#endif
    SMESH_subMesh* smOfSolid =
      theHelper->GetMesh()->GetSubMesh( theHelper->GetSubShape() );
    SMESH_subMeshIteratorPtr smIt =
      smOfSolid->getDependsOnIterator(/*includeSelf=*/false, /*complexShapeFirst=*/true);
    while ( smIt->more() )
    {
      SMESH_subMesh* sm = smIt->next();
      if ( SMESHDS_SubMesh * smDS = sm->GetSubMeshDS() )
      {
        SMDS_ElemIteratorPtr eIt = smDS->GetElements();
        while( eIt->more() )
        {
          theMeshDS->RemoveFreeElement( eIt->next(), smDS );
        }
        SMDS_NodeIteratorPtr nIt = smDS->GetNodes();
        while ( nIt->more() )
        {
          const SMDS_MeshNode* n = nIt->next();
          if ( n->NbInverseElements() == 0 )
            theMeshDS->RemoveFreeNode( n, smDS );
        }
      }
    }
    theNodeByHybridId.clear();
    theFaceByHybridId.clear();
  }

  int nbInitialNodes = theNodeByHybridId.size();

#ifdef _DEBUG_
  int nbMeshNodes = theMeshDS->NbNodes();
  const bool isQuadMesh =
    theHelper->GetMesh()->NbEdges( ORDER_QUADRATIC ) ||
    theHelper->GetMesh()->NbFaces( ORDER_QUADRATIC ) ||
    theHelper->GetMesh()->NbVolumes( ORDER_QUADRATIC );

  std::cout << "theNodeByHybridId.size(): " << nbInitialNodes << std::endl;
  std::cout << "theHelper->GetMesh()->NbNodes(): " << nbMeshNodes << std::endl;
  std::cout << "isQuadMesh: " << isQuadMesh << std::endl;
#endif

  // ---------------------------------
  // Read generated elements and nodes
  // ---------------------------------

  int nbElem = 0, nbRef = 0;
  int aGMFNodeID = 0;
  std::vector< const SMDS_MeshNode* > GMFNode;
#ifdef _DEBUG_
  std::map<int, std::set<int> > subdomainId2tetraId;
#endif
  std::map <GmfKwdCod,int> tabRef;
  const bool force3d = !hasGeom;
  const int  noID    = 0;

  tabRef[GmfVertices]       = 3; // for new nodes and enforced nodes
  tabRef[GmfCorners]        = 1;
  tabRef[GmfEdges]          = 2; // for enforced edges
  tabRef[GmfRidges]         = 1;
  tabRef[GmfTriangles]      = 3; // for enforced faces
  tabRef[GmfQuadrilaterals] = 4;
  tabRef[GmfTetrahedra]     = 4; // for new tetras
  tabRef[GmfPyramids]       = 5; // for new pyramids
  tabRef[GmfPrisms]         = 6; // for new prisms
  tabRef[GmfHexahedra]      = 8;

  int ver, dim;
  int InpMsh = MGOutput->GmfOpenMesh(theFile, GmfRead, &ver, &dim);
  if (!InpMsh)
    return false;

  // Hybrid is not multi-domain => We can't (and don't need to) read ids of domains in ouput file like in GHS3DPlugin
  // We just need to get the id of the one and only solid
  int solidID = 1;
  if ( hasGeom )
  {
    if ( theHelper->GetSubShape().ShapeType() == TopAbs_SOLID )
      solidID = theHelper->GetSubShapeID();
    else
      solidID = theMeshDS->ShapeToIndex
        ( TopExp_Explorer( theHelper->GetSubShape(), TopAbs_SOLID ).Current() );
  }

  // Issue 0020682. Avoid creating nodes and tetras at place where
  // volumic elements already exist
  SMESH_ElementSearcher* elemSearcher = 0;
  std::vector< const SMDS_MeshElement* > foundVolumes;
  if ( !hasGeom && theHelper->GetMesh()->NbVolumes() > 0 )
    elemSearcher = SMESH_MeshAlgos::GetElementSearcher( *theMeshDS );
  SMESHUtils::Deleter< SMESH_ElementSearcher > elemSearcherDeleter( elemSearcher );

  // IMP 0022172: [CEA 790] create the groups corresponding to domains
  std::vector< std::vector< const SMDS_MeshElement* > > elemsOfDomain;

  int nbVertices = MGOutput->GmfStatKwd(InpMsh, GmfVertices) - nbInitialNodes;
  if ( nbVertices < 0 )
    return false;
  GMFNode.resize( nbVertices + 1 );

  std::map <GmfKwdCod,int>::const_iterator it = tabRef.begin();
  for ( ; it != tabRef.end() ; ++it)
  {
    if(theAlgo->computeCanceled()) {
      MGOutput->GmfCloseMesh(InpMsh);
      return false;
    }
    int dummy;
    GmfKwdCod token = it->first;
    nbRef           = it->second;

    nbElem = MGOutput->GmfStatKwd(InpMsh, token);
    if (nbElem > 0) {
      MGOutput->GmfGotoKwd(InpMsh, token);
      std::cout << "Read " << nbElem;
    }
    else
      continue;

    std::vector<int> id (nbElem*tabRef[token]); // node ids
    std::vector<int> domainID( nbElem ); // domain

    if (token == GmfVertices) {
      (nbElem <= 1) ? tmpStr = " vertex" : tmpStr = " vertices";
      
      int aGMFID;
      float VerTab_f[3];
      double x, y, z;
      const SMDS_MeshNode * aGMFNode;

      for ( int iElem = 0; iElem < nbElem; iElem++ ) {
        if(theAlgo->computeCanceled()) {
          MGOutput->GmfCloseMesh(InpMsh);
          return false;
        }
        if (ver == GmfFloat) {
          MGOutput->GmfGetLin(InpMsh, token, &VerTab_f[0], &VerTab_f[1], &VerTab_f[2], &dummy);
          x = VerTab_f[0];
          y = VerTab_f[1];
          z = VerTab_f[2];
        }
        else {
          MGOutput->GmfGetLin(InpMsh, token, &x, &y, &z, &dummy);
        }
        if (iElem >= nbInitialNodes) {
          if ( elemSearcher &&
                elemSearcher->FindElementsByPoint( gp_Pnt(x,y,z), SMDSAbs_Volume, foundVolumes))
            aGMFNode = 0;
          else
            aGMFNode = theHelper->AddNode(x, y, z);
          
          aGMFID = iElem -nbInitialNodes +1;
          GMFNode[ aGMFID ] = aGMFNode;
          if (aGMFID-1 < (int)aNodeGroupByHybridId.size() && !aNodeGroupByHybridId.at(aGMFID-1).empty())
            addElemInMeshGroup(theHelper->GetMesh(), aGMFNode, aNodeGroupByHybridId.at(aGMFID-1), groupsToRemove);
        }
      }
    }
    else if (token == GmfCorners && nbElem > 0) {
      (nbElem <= 1) ? tmpStr = " corner" : tmpStr = " corners";
      for ( int iElem = 0; iElem < nbElem; iElem++ )
        MGOutput->GmfGetLin(InpMsh, token, &id[iElem*tabRef[token]]);
    }
    else if (token == GmfRidges && nbElem > 0) {
      (nbElem <= 1) ? tmpStr = " ridge" : tmpStr = " ridges";
      for ( int iElem = 0; iElem < nbElem; iElem++ )
        MGOutput->GmfGetLin(InpMsh, token, &id[iElem*tabRef[token]]);
    }
    else if (token == GmfEdges && nbElem > 0) {
      (nbElem <= 1) ? tmpStr = " edge" : tmpStr = " edges";
      for ( int iElem = 0; iElem < nbElem; iElem++ )
        MGOutput->GmfGetLin(InpMsh, token, &id[iElem*tabRef[token]], &id[iElem*tabRef[token]+1], &domainID[iElem]);
    }
    else if (token == GmfTriangles && nbElem > 0) {
      (nbElem <= 1) ? tmpStr = " triangle" : tmpStr = " triangles";
      for ( int iElem = 0; iElem < nbElem; iElem++ )
        MGOutput->GmfGetLin(InpMsh, token, &id[iElem*tabRef[token]], &id[iElem*tabRef[token]+1], &id[iElem*tabRef[token]+2], &domainID[iElem]);
    }
    else if (token == GmfQuadrilaterals && nbElem > 0) {
      (nbElem <= 1) ? tmpStr = " Quadrilateral" : tmpStr = " Quadrilaterals";
      for ( int iElem = 0; iElem < nbElem; iElem++ )
        MGOutput->GmfGetLin(InpMsh, token, &id[iElem*tabRef[token]], &id[iElem*tabRef[token]+1], &id[iElem*tabRef[token]+2], &id[iElem*tabRef[token]+3], &domainID[iElem]);
    }
    else if (token == GmfTetrahedra && nbElem > 0) {
      (nbElem <= 1) ? tmpStr = " Tetrahedron" : tmpStr = " Tetrahedra";
      for ( int iElem = 0; iElem < nbElem; iElem++ ) {
        MGOutput->GmfGetLin(InpMsh, token, &id[iElem*tabRef[token]], &id[iElem*tabRef[token]+1], &id[iElem*tabRef[token]+2], &id[iElem*tabRef[token]+3], &domainID[iElem]);
#ifdef _DEBUG_
        subdomainId2tetraId[dummy].insert(iElem+1);
#endif
      }
    }
    else if (token == GmfPyramids && nbElem > 0) {
      (nbElem <= 1) ? tmpStr = " Pyramid" : tmpStr = " Pyramids";
      for ( int iElem = 0; iElem < nbElem; iElem++ )
        MGOutput->GmfGetLin(InpMsh, token, &id[iElem*tabRef[token]], &id[iElem*tabRef[token]+1], &id[iElem*tabRef[token]+2], &id[iElem*tabRef[token]+3],
                  &id[iElem*tabRef[token]+4], &domainID[iElem]);
    }
    else if (token == GmfPrisms && nbElem > 0) {
      (nbElem <= 1) ? tmpStr = " Prism" : tmpStr = " Prisms";
      for ( int iElem = 0; iElem < nbElem; iElem++ )
        MGOutput->GmfGetLin(InpMsh, token, &id[iElem*tabRef[token]], &id[iElem*tabRef[token]+1], &id[iElem*tabRef[token]+2], &id[iElem*tabRef[token]+3],
                  &id[iElem*tabRef[token]+4], &id[iElem*tabRef[token]+5], &domainID[iElem]);
    }
    else if (token == GmfHexahedra && nbElem > 0) {
      (nbElem <= 1) ? tmpStr = " Hexahedron" : tmpStr = " Hexahedra";
      for ( int iElem = 0; iElem < nbElem; iElem++ )
        MGOutput->GmfGetLin(InpMsh, token, &id[iElem*tabRef[token]], &id[iElem*tabRef[token]+1], &id[iElem*tabRef[token]+2], &id[iElem*tabRef[token]+3],
                  &id[iElem*tabRef[token]+4], &id[iElem*tabRef[token]+5], &id[iElem*tabRef[token]+6], &id[iElem*tabRef[token]+7], &domainID[iElem]);
    }
    std::cout << tmpStr << std::endl;
    //std::cout << std::endl;

    switch (token) {
    case GmfCorners:
    case GmfRidges:
    case GmfEdges:
    case GmfTriangles:
    case GmfQuadrilaterals:
    case GmfTetrahedra:
    case GmfPyramids:
    case GmfPrisms:
    case GmfHexahedra:
    {
      std::vector< const SMDS_MeshNode* > node( nbRef );
      std::vector< int >          nodeID( nbRef );
      std::vector< SMDS_MeshNode* > enfNode( nbRef );
      const SMDS_MeshElement* aCreatedElem;

      for ( int iElem = 0; iElem < nbElem; iElem++ )
      {
        if(theAlgo->computeCanceled()) {
          MGOutput->GmfCloseMesh(InpMsh);
          return false;
        }
        // Check if elem is already in input mesh. If yes => skip
        bool fullyCreatedElement = false; // if at least one of the nodes was created
        for ( int iRef = 0; iRef < nbRef; iRef++ )
        {
          aGMFNodeID = id[iElem*tabRef[token]+iRef]; // read nbRef aGMFNodeID
          if (aGMFNodeID <= nbInitialNodes) // input nodes
          {
            aGMFNodeID--;
            node[ iRef ] = theNodeByHybridId[aGMFNodeID];
          }
          else
          {
            fullyCreatedElement = true;
            aGMFNodeID -= nbInitialNodes;
            nodeID[ iRef ] = aGMFNodeID ;
            node  [ iRef ] = GMFNode[ aGMFNodeID ];
          }
        }
        aCreatedElem = 0;
        switch (token)
        {
        case GmfEdges:
          if (fullyCreatedElement) {
            aCreatedElem = theHelper->AddEdge( node[0], node[1], noID, force3d );
            if ( !anEdgeGroupByHybridId.empty() && !anEdgeGroupByHybridId[iElem].empty())
              addElemInMeshGroup(theHelper->GetMesh(), aCreatedElem, anEdgeGroupByHybridId[iElem], groupsToRemove);
          }
          break;
        case GmfTriangles:
          if (fullyCreatedElement) {
            aCreatedElem = theHelper->AddFace( node[0], node[1], node[2], noID, force3d );
            // add iElem < aFaceGroupByHybridId.size() to avoid crash if imprinting with hexa core with MeshGems <= 2.4-5
            if ( iElem < (int)aFaceGroupByHybridId.size() && !aFaceGroupByHybridId[iElem].empty() ) {
              addElemInMeshGroup(theHelper->GetMesh(), aCreatedElem, aFaceGroupByHybridId[iElem], groupsToRemove);
            }
            // add element in shape for groups on geom to work
            if ( domainID[iElem] > 0 )
            {
              theMeshDS->SetMeshElementOnShape( aCreatedElem, domainID[iElem] );
              for ( int iN = 0; iN < 3; ++iN )
                if ( node[iN]->getshapeId() < 1 )
                  theMeshDS->SetNodeOnFace( node[iN], domainID[iElem] );
            }
          }
          break;
        case GmfQuadrilaterals:
          if (fullyCreatedElement) {
            aCreatedElem = theHelper->AddFace( node[0], node[1], node[2], node[3], noID, force3d );
            // add element in shape for groups on geom to work
            if ( domainID[iElem] > 0 )
            {
              theMeshDS->SetMeshElementOnShape( aCreatedElem, domainID[iElem] );
              for ( int iN = 0; iN < 3; ++iN )
                if ( node[iN]->getshapeId() < 1 )
                  theMeshDS->SetNodeOnFace( node[iN], domainID[iElem] );
            }
          }
          break;
        case GmfTetrahedra:
          if ( hasGeom )
          {
            if ( solidID != HOLE_ID )
            {
              aCreatedElem = theHelper->AddVolume( node[1], node[0], node[2], node[3],
                                                   noID, force3d );
              theMeshDS->SetMeshElementOnShape( aCreatedElem, solidID );
              for ( int iN = 0; iN < 4; ++iN )
                if ( node[iN]->getshapeId() < 1 )
                  theMeshDS->SetNodeInVolume( node[iN], solidID );
            }
          }
          else
          {
            if ( elemSearcher ) {
              // Issue 0020682. Avoid creating nodes and tetras at place where
              // volumic elements already exist
              if ( !node[1] || !node[0] || !node[2] || !node[3] )
                continue;
              if ( elemSearcher->FindElementsByPoint((SMESH_TNodeXYZ(node[0]) +
                                                      SMESH_TNodeXYZ(node[1]) +
                                                      SMESH_TNodeXYZ(node[2]) +
                                                      SMESH_TNodeXYZ(node[3]) ) / 4.,
                                                     SMDSAbs_Volume, foundVolumes ))
                break;
            }
            aCreatedElem = theHelper->AddVolume( node[1], node[0], node[2], node[3],
                                                 noID, force3d );
          }
          break;
        case GmfPyramids:
          if ( hasGeom )
          {
            if ( solidID != HOLE_ID )
            {
              aCreatedElem = theHelper->AddVolume( node[3], node[2], node[1],
                                                   node[0], node[4],
                                                   noID, force3d );
              theMeshDS->SetMeshElementOnShape( aCreatedElem, solidID );
              for ( int iN = 0; iN < 5; ++iN )
                if ( node[iN]->getshapeId() < 1 )
                  theMeshDS->SetNodeInVolume( node[iN], solidID );
            }
          }
          else
          {
            if ( elemSearcher ) {
              // Issue 0020682. Avoid creating nodes and tetras at place where
              // volumic elements already exist
              if ( !node[1] || !node[0] || !node[2] || !node[3] || !node[4] || !node[5] )
                continue;
              if ( elemSearcher->FindElementsByPoint((SMESH_TNodeXYZ(node[0]) +
                                                      SMESH_TNodeXYZ(node[1]) +
                                                      SMESH_TNodeXYZ(node[2]) +
                                                      SMESH_TNodeXYZ(node[3]) +
                                                      SMESH_TNodeXYZ(node[4])) / 5.,
                                                     SMDSAbs_Volume, foundVolumes ))
                break;
            }
            aCreatedElem = theHelper->AddVolume( node[3], node[2], node[1],
                                                   node[0], node[4],
                                                   noID, force3d );
          }
          break;
        case GmfPrisms:
          if ( hasGeom )
          {
            if ( solidID != HOLE_ID )
            {
              aCreatedElem = theHelper->AddVolume( node[0], node[2], node[1],
                                                   node[3], node[5], node[4],
                                                   noID, force3d );
              theMeshDS->SetMeshElementOnShape( aCreatedElem, solidID );
              for ( int iN = 0; iN < 6; ++iN )
                if ( node[iN]->getshapeId() < 1 )
                  theMeshDS->SetNodeInVolume( node[iN], solidID );
            }
          }
          else
          {
            if ( elemSearcher ) {
              // Issue 0020682. Avoid creating nodes and tetras at place where
              // volumic elements already exist
              if ( !node[1] || !node[0] || !node[2] || !node[3] || !node[4] || !node[5] )
                continue;
              if ( elemSearcher->FindElementsByPoint((SMESH_TNodeXYZ(node[0]) +
                                                      SMESH_TNodeXYZ(node[1]) +
                                                      SMESH_TNodeXYZ(node[2]) +
                                                      SMESH_TNodeXYZ(node[3]) +
                                                      SMESH_TNodeXYZ(node[4]) +
                                                      SMESH_TNodeXYZ(node[5])) / 6.,
                                                     SMDSAbs_Volume, foundVolumes ))
                break;
            }
            aCreatedElem = theHelper->AddVolume( node[0], node[2], node[1],
                                                 node[3], node[5], node[4],
                                                 noID, force3d );
          }
          break;
        case GmfHexahedra:
          if ( hasGeom )
          {
            if ( solidID != HOLE_ID )
            {
              aCreatedElem = theHelper->AddVolume( node[0], node[3], node[2], node[1],
                                                   node[4], node[7], node[6], node[5],
                                                   noID, force3d );
              theMeshDS->SetMeshElementOnShape( aCreatedElem, solidID );
              for ( int iN = 0; iN < 8; ++iN )
                if ( node[iN]->getshapeId() < 1 )
                  theMeshDS->SetNodeInVolume( node[iN], solidID );
            }
          }
          else
          {
            if ( elemSearcher ) {
              // Issue 0020682. Avoid creating nodes and tetras at place where
              // volumic elements already exist
              if ( !node[1] || !node[0] || !node[2] || !node[3] || !node[4] || !node[5] || !node[6] || !node[7])
                continue;
              if ( elemSearcher->FindElementsByPoint((SMESH_TNodeXYZ(node[0]) +
                                                      SMESH_TNodeXYZ(node[1]) +
                                                      SMESH_TNodeXYZ(node[2]) +
                                                      SMESH_TNodeXYZ(node[3]) +
                                                      SMESH_TNodeXYZ(node[4]) +
                                                      SMESH_TNodeXYZ(node[5]) +
                                                      SMESH_TNodeXYZ(node[6]) +
                                                      SMESH_TNodeXYZ(node[7])) / 8.,
                                                     SMDSAbs_Volume, foundVolumes ))
                break;
            }
            aCreatedElem = theHelper->AddVolume( node[0], node[3], node[2], node[1],
                                                 node[4], node[7], node[6], node[5],
                                                 noID, force3d );
          }
          break;
        default: continue;
        } // switch (token)

        if ( aCreatedElem && toMakeGroupsOfDomains )
        {
          if ( domainID[iElem] >= (int) elemsOfDomain.size() )
            elemsOfDomain.resize( domainID[iElem] + 1 );
          elemsOfDomain[ domainID[iElem] ].push_back( aCreatedElem );
        }
      } // loop on elements of one type
      break;
    } // case ...

    default:;
    } // switch (token)
  } // loop on tabRef

  // remove nodes in holes
  if ( hasGeom )
  {
    for ( int i = 1; i <= nbVertices; ++i )
      if ( GMFNode[i]->NbInverseElements() == 0 )
        theMeshDS->RemoveFreeNode( GMFNode[i], /*sm=*/0, /*fromGroups=*/false );
  }

  MGOutput->GmfCloseMesh(InpMsh);

  // 0022172: [CEA 790] create the groups corresponding to domains
  if ( toMakeGroupsOfDomains )
    makeDomainGroups( elemsOfDomain, theHelper );

#ifdef _DEBUG_
  std::map<int, std::set<int> >::const_iterator subdomainIt = subdomainId2tetraId.begin();
  std::string aSubdomainFileName = theFile;
  aSubdomainFileName = aSubdomainFileName + ".subdomain";
  std::ofstream aSubdomainFile  ( aSubdomainFileName  , ios::out);

  aSubdomainFile << "Nb subdomains " << subdomainId2tetraId.size() << std::endl;
  for(;subdomainIt != subdomainId2tetraId.end() ; ++subdomainIt) {
    int subdomainId = subdomainIt->first;
    std::set<int> tetraIds = subdomainIt->second;
    std::set<int>::const_iterator tetraIdsIt = tetraIds.begin();
    aSubdomainFile << subdomainId << std::endl;
    for(;tetraIdsIt != tetraIds.end() ; ++tetraIdsIt) {
      aSubdomainFile << (*tetraIdsIt) << " ";
    }
    aSubdomainFile << std::endl;
  }
  aSubdomainFile.close();
#endif  
  
  return true;
}


static bool writeGMFFile(MG_HYBRID_API*                                  MGInput,
                         const char*                                     theMeshFileName,
                         const char*                                     theRequiredFileName,
                         const char*                                     theSolFileName,
                         const SMESH_ProxyMesh&                          theProxyMesh,
                         SMESH_MesherHelper&                             theHelper,
                         std::vector <const SMDS_MeshNode*> &            theNodeByHybridId,
                         std::vector <const SMDS_MeshElement*> &         theFaceByHybridId,
                         std::map<const SMDS_MeshNode*,int> &            aNodeToHybridIdMap,
                         std::vector<std::string> &                      aNodeGroupByHybridId,
                         std::vector<std::string> &                      anEdgeGroupByHybridId,
                         std::vector<std::string> &                      aFaceGroupByHybridId,
                         HYBRIDPlugin_Hypothesis::TIDSortedNodeGroupMap & theEnforcedNodes,
                         HYBRIDPlugin_Hypothesis::TIDSortedElemGroupMap & theEnforcedEdges,
                         HYBRIDPlugin_Hypothesis::TIDSortedElemGroupMap & theEnforcedTriangles,
                         std::map<std::vector<double>, std::string> &    enfVerticesWithGroup,
                         HYBRIDPlugin_Hypothesis::THYBRIDEnforcedVertexCoordsValues & theEnforcedVertices)
{
  std::string tmpStr;
  int idx, idxRequired = 0, idxSol = 0;
  //tabg each dummyint
  //const int dummyint = 0;
  const int dummyint1 = 1;
  const int dummyint2 = 2;
  const int dummyint3 = 3;
  const int dummyint4 = 4;
  const int enforcedTag = HYBRIDPlugin_Hypothesis::EnforcedTag();
  //const int dummyint6 = 6; //are interesting for layers
  HYBRIDPlugin_Hypothesis::THYBRIDEnforcedVertexCoordsValues::const_iterator vertexIt;
  std::vector<double> enfVertexSizes;
  const SMDS_MeshElement* elem;
  TIDSortedElemSet anElemSetTri, anElemSetQuad, theKeptEnforcedEdges, theKeptEnforcedTriangles;
  SMDS_ElemIteratorPtr nodeIt;
  std::vector <const SMDS_MeshNode*> theEnforcedNodeByHybridId;
  std::map<const SMDS_MeshNode*,int> anEnforcedNodeToHybridIdMap, anExistingEnforcedNodeToHybridIdMap;
  std::vector< const SMDS_MeshElement* > foundElems;
  std::map<const SMDS_MeshNode*,TopAbs_State> aNodeToTopAbs_StateMap;
  int nbFoundElems;
  HYBRIDPlugin_Hypothesis::TIDSortedElemGroupMap::iterator elemIt;
  TIDSortedElemSet::iterator elemSetIt;
  bool isOK;
  SMESH_Mesh* theMesh = theHelper.GetMesh();
  const bool hasGeom = theMesh->HasShapeToMesh();
  SMESHUtils::Deleter< SMESH_ElementSearcher > pntCls
    ( SMESH_MeshAlgos::GetElementSearcher(*theMesh->GetMeshDS()));
  
  int nbEnforcedVertices = theEnforcedVertices.size();
  
  // count faces
  int nbFaces = theProxyMesh.NbFaces();
  int nbNodes;
  theFaceByHybridId.reserve( nbFaces );
  
  // groups management
  int usedEnforcedNodes = 0;
  std::string gn = "";

  if ( nbFaces == 0 )
    return false;
  
  idx = MGInput->GmfOpenMesh(theMeshFileName, GmfWrite, GMFVERSION, GMFDIMENSION);
  if (!idx)
    return false;
  
  // ========================== FACES ==========================
  // TRIANGLES ==========================
  SMDS_ElemIteratorPtr eIt =
    hasGeom ? theProxyMesh.GetFaces( theHelper.GetSubShape()) : theProxyMesh.GetFaces();
  while ( eIt->more() )
  {
    elem = eIt->next();
    nodeIt = elem->nodesIterator();
    nbNodes = elem->NbCornerNodes();
    if (nbNodes == 3)
      anElemSetTri.insert(elem);
    else if (nbNodes == 4)
      anElemSetQuad.insert(elem);
    else
    {
      std::cout << "Unexpected number of nodes: " << nbNodes << std::endl;
      throw ("Unexpected number of nodes" );
    }
    while ( nodeIt->more() && nbNodes--)
    {
      // find HYBRID ID
      const SMDS_MeshNode* node = castToNode( nodeIt->next() );
      int newId = aNodeToHybridIdMap.size() + 1; // hybrid ids count from 1
      aNodeToHybridIdMap.insert( std::make_pair( node, newId ));
    }
  }
  
  //EDGES ==========================
  
  // Iterate over the enforced edges
  for(elemIt = theEnforcedEdges.begin() ; elemIt != theEnforcedEdges.end() ; ++elemIt) {
    elem = elemIt->first;
    isOK = true;
    nodeIt = elem->nodesIterator();
    nbNodes = 2;
    while ( nodeIt->more() && nbNodes-- ) {
      // find HYBRID ID
      const SMDS_MeshNode* node = castToNode( nodeIt->next() );
      // Test if point is inside shape to mesh
      gp_Pnt myPoint(node->X(),node->Y(),node->Z());
      TopAbs_State result = pntCls->GetPointState( myPoint );
      if ( result == TopAbs_OUT ) {
        isOK = false;
        break;
      }
      aNodeToTopAbs_StateMap.insert( std::make_pair( node, result ));
    }
    if (isOK) {
      nodeIt = elem->nodesIterator();
      nbNodes = 2;
      int newId = -1;
      while ( nodeIt->more() && nbNodes-- ) {
        // find HYBRID ID
        const SMDS_MeshNode* node = castToNode( nodeIt->next() );
        gp_Pnt myPoint(node->X(),node->Y(),node->Z());
        nbFoundElems = pntCls->FindElementsByPoint(myPoint, SMDSAbs_Node, foundElems);
#ifdef _DEBUG_
        std::cout << "Node at "<<node->X()<<", "<<node->Y()<<", "<<node->Z()<<std::endl;
        std::cout << "Nb nodes found : "<<nbFoundElems<<std::endl;
#endif
        if (nbFoundElems ==0) {
          if ((*aNodeToTopAbs_StateMap.find(node)).second == TopAbs_IN) {
            newId = aNodeToHybridIdMap.size() + anEnforcedNodeToHybridIdMap.size() + 1; // hybrid ids count from 1
            anEnforcedNodeToHybridIdMap.insert( std::make_pair( node, newId ));
          }
        }
        else if (nbFoundElems ==1) {
          const SMDS_MeshNode* existingNode = (SMDS_MeshNode*) foundElems.at(0);
          newId = (*aNodeToHybridIdMap.find(existingNode)).second;
          anExistingEnforcedNodeToHybridIdMap.insert( std::make_pair( node, newId ));
        }
        else
          isOK = false;
#ifdef _DEBUG_
        std::cout << "HYBRID node ID: "<<newId<<std::endl;
#endif
      }
      if (isOK)
        theKeptEnforcedEdges.insert(elem);
    }
  }
  
  //ENFORCED TRIANGLES ==========================
  
  // Iterate over the enforced triangles
  for(elemIt = theEnforcedTriangles.begin() ; elemIt != theEnforcedTriangles.end() ; ++elemIt) {
    elem = elemIt->first;
    isOK = true;
    nodeIt = elem->nodesIterator();
    nbNodes = 3;
    while ( nodeIt->more() && nbNodes--) {
      // find HYBRID ID
      const SMDS_MeshNode* node = castToNode( nodeIt->next() );
      // Test if point is inside shape to mesh
      gp_Pnt myPoint(node->X(),node->Y(),node->Z());
      TopAbs_State result = pntCls->GetPointState( myPoint );
      if ( result == TopAbs_OUT ) {
        isOK = false;
        break;
      }
      aNodeToTopAbs_StateMap.insert( std::make_pair( node, result ));
    }
    if (isOK) {
      nodeIt = elem->nodesIterator();
      nbNodes = 3;
      int newId = -1;
      while ( nodeIt->more() && nbNodes--) {
        // find HYBRID ID
        const SMDS_MeshNode* node = castToNode( nodeIt->next() );
        gp_Pnt myPoint(node->X(),node->Y(),node->Z());
        nbFoundElems = pntCls->FindElementsByPoint(myPoint, SMDSAbs_Node, foundElems);
#ifdef _DEBUG_
        std::cout << "Nb nodes found : "<<nbFoundElems<<std::endl;
#endif
        if (nbFoundElems ==0) {
          if ((*aNodeToTopAbs_StateMap.find(node)).second == TopAbs_IN) {
            newId = aNodeToHybridIdMap.size() + anEnforcedNodeToHybridIdMap.size() + 1; // hybrid ids count from 1
            anEnforcedNodeToHybridIdMap.insert( std::make_pair( node, newId ));
          }
        }
        else if (nbFoundElems ==1) {
          const SMDS_MeshNode* existingNode = (SMDS_MeshNode*) foundElems.at(0);
          newId = (*aNodeToHybridIdMap.find(existingNode)).second;
          anExistingEnforcedNodeToHybridIdMap.insert( std::make_pair( node, newId ));
        }
        else
          isOK = false;
#ifdef _DEBUG_
        std::cout << "HYBRID node ID: "<<newId<<std::endl;
#endif
      }
      if (isOK)
        theKeptEnforcedTriangles.insert(elem);
    }
  }
  
  // put nodes to theNodeByHybridId vector
#ifdef _DEBUG_
  std::cout << "aNodeToHybridIdMap.size(): "<<aNodeToHybridIdMap.size()<<std::endl;
#endif
  theNodeByHybridId.resize( aNodeToHybridIdMap.size() );
  std::map<const SMDS_MeshNode*,int>::const_iterator n2id = aNodeToHybridIdMap.begin();
  for ( ; n2id != aNodeToHybridIdMap.end(); ++ n2id)
  {
//     std::cout << "n2id->first: "<<n2id->first<<std::endl;
    theNodeByHybridId[ n2id->second - 1 ] = n2id->first; // hybrid ids count from 1
  }

  // put nodes to anEnforcedNodeToHybridIdMap vector
#ifdef _DEBUG_
  std::cout << "anEnforcedNodeToHybridIdMap.size(): "<<anEnforcedNodeToHybridIdMap.size()<<std::endl;
#endif
  theEnforcedNodeByHybridId.resize( anEnforcedNodeToHybridIdMap.size());
  n2id = anEnforcedNodeToHybridIdMap.begin();
  for ( ; n2id != anEnforcedNodeToHybridIdMap.end(); ++ n2id)
  {
    if (n2id->second > (int)aNodeToHybridIdMap.size()) {
      theEnforcedNodeByHybridId[ n2id->second - aNodeToHybridIdMap.size() - 1 ] = n2id->first; // hybrid ids count from 1
    }
  }
  
  
  //========================== NODES ==========================
  std::vector<const SMDS_MeshNode*> theOrderedNodes, theRequiredNodes;
  std::set< std::vector<double> > nodesCoords;
  std::vector<const SMDS_MeshNode*>::const_iterator hybridNodeIt = theNodeByHybridId.begin();
  std::vector<const SMDS_MeshNode*>::const_iterator after  = theNodeByHybridId.end();
  
  (theNodeByHybridId.size() <= 1) ? tmpStr = " node" : " nodes";
  std::cout << theNodeByHybridId.size() << tmpStr << " from mesh ..." << std::endl;
  for ( ; hybridNodeIt != after; ++hybridNodeIt )
  {
    const SMDS_MeshNode* node = *hybridNodeIt;
    std::vector<double> coords;
    coords.push_back(node->X());
    coords.push_back(node->Y());
    coords.push_back(node->Z());
    nodesCoords.insert(coords);
    theOrderedNodes.push_back(node);
  }
  
  // Iterate over the enforced nodes given by enforced elements
  hybridNodeIt = theEnforcedNodeByHybridId.begin();
  after  = theEnforcedNodeByHybridId.end();
  (theEnforcedNodeByHybridId.size() <= 1) ? tmpStr = " node" : " nodes";
  std::cout << theEnforcedNodeByHybridId.size() << tmpStr << " from enforced elements ..." << std::endl;
  for ( ; hybridNodeIt != after; ++hybridNodeIt )
  {
    const SMDS_MeshNode* node = *hybridNodeIt;
    std::vector<double> coords;
    coords.push_back(node->X());
    coords.push_back(node->Y());
    coords.push_back(node->Z());
#ifdef _DEBUG_
    std::cout << "Node at " << node->X()<<", " <<node->Y()<<", " <<node->Z();
#endif
    
    if (nodesCoords.find(coords) != nodesCoords.end()) {
      // node already exists in original mesh
#ifdef _DEBUG_
      std::cout << " found" << std::endl;
#endif
      continue;
    }
    
    if (theEnforcedVertices.find(coords) != theEnforcedVertices.end()) {
      // node already exists in enforced vertices
#ifdef _DEBUG_
      std::cout << " found" << std::endl;
#endif
      continue;
    }
    
#ifdef _DEBUG_
    std::cout << " not found" << std::endl;
#endif
    
    nodesCoords.insert(coords);
    theOrderedNodes.push_back(node);
//     theRequiredNodes.push_back(node);
  }
  
  
  // Iterate over the enforced nodes
  HYBRIDPlugin_Hypothesis::TIDSortedNodeGroupMap::const_iterator enfNodeIt;
  (theEnforcedNodes.size() <= 1) ? tmpStr = " node" : " nodes";
  std::cout << theEnforcedNodes.size() << tmpStr << " from enforced nodes ..." << std::endl;
  for(enfNodeIt = theEnforcedNodes.begin() ; enfNodeIt != theEnforcedNodes.end() ; ++enfNodeIt)
  {
    const SMDS_MeshNode* node = enfNodeIt->first;
    std::vector<double> coords;
    coords.push_back(node->X());
    coords.push_back(node->Y());
    coords.push_back(node->Z());
#ifdef _DEBUG_
    std::cout << "Node at " << node->X()<<", " <<node->Y()<<", " <<node->Z();
#endif
    
    // Test if point is inside shape to mesh
    gp_Pnt myPoint(node->X(),node->Y(),node->Z());
    TopAbs_State result = pntCls->GetPointState( myPoint );
    if ( result == TopAbs_OUT ) {
#ifdef _DEBUG_
      std::cout << " out of volume" << std::endl;
#endif
      continue;
    }
    
    if (nodesCoords.find(coords) != nodesCoords.end()) {
#ifdef _DEBUG_
      std::cout << " found in nodesCoords" << std::endl;
#endif
//       theRequiredNodes.push_back(node);
      continue;
    }

    if (theEnforcedVertices.find(coords) != theEnforcedVertices.end()) {
#ifdef _DEBUG_
      std::cout << " found in theEnforcedVertices" << std::endl;
#endif
      continue;
    }
    
#ifdef _DEBUG_
    std::cout << " not found" << std::endl;
#endif
    nodesCoords.insert(coords);
//     theOrderedNodes.push_back(node);
    theRequiredNodes.push_back(node);
  }
  int requiredNodes = theRequiredNodes.size();
  
  int solSize = 0;
  std::vector<std::vector<double> > ReqVerTab;
  if (nbEnforcedVertices) {
    (nbEnforcedVertices <= 1) ? tmpStr = " node" : " nodes";
    std::cout << nbEnforcedVertices << tmpStr << " from enforced vertices ..." << std::endl;
    // Iterate over the enforced vertices
    for(vertexIt = theEnforcedVertices.begin() ; vertexIt != theEnforcedVertices.end() ; ++vertexIt) {
      double x = vertexIt->first[0];
      double y = vertexIt->first[1];
      double z = vertexIt->first[2];
      // Test if point is inside shape to mesh
      gp_Pnt myPoint(x,y,z);
      TopAbs_State result = pntCls->GetPointState( myPoint );
      if ( result == TopAbs_OUT )
        continue;
      std::vector<double> coords;
      coords.push_back(x);
      coords.push_back(y);
      coords.push_back(z);
      ReqVerTab.push_back(coords);
      enfVertexSizes.push_back(vertexIt->second);
      solSize++;
    }
  }
  
  
  // GmfVertices
  std::cout << "Begin writing required nodes in GmfVertices" << std::endl;
  std::cout << "Nb vertices: " << theOrderedNodes.size() << std::endl;
  MGInput->GmfSetKwd(idx, GmfVertices, theOrderedNodes.size());
  for (hybridNodeIt = theOrderedNodes.begin();hybridNodeIt != theOrderedNodes.end();++hybridNodeIt) {
    MGInput->GmfSetLin(idx, GmfVertices, (*hybridNodeIt)->X(), (*hybridNodeIt)->Y(), (*hybridNodeIt)->Z(), dummyint1);
  }

  std::cout << "End writing required nodes in GmfVertices" << std::endl;

  if (requiredNodes + solSize) {
    std::cout << "Begin writing in req and sol file" << std::endl;
    aNodeGroupByHybridId.resize( requiredNodes + solSize );
    idxRequired = MGInput->GmfOpenMesh(theRequiredFileName, GmfWrite, GMFVERSION, GMFDIMENSION);
    if (!idxRequired) {
      MGInput->GmfCloseMesh(idx);
      return false;
    }
    idxSol = MGInput->GmfOpenMesh(theSolFileName, GmfWrite, GMFVERSION, GMFDIMENSION);
    if (!idxSol) {
      MGInput->GmfCloseMesh(idx);
      if (idxRequired)
        MGInput->GmfCloseMesh(idxRequired);
      return false;
    }
    int TypTab[] = {GmfSca};
    double ValTab[] = {0.0};
    MGInput->GmfSetKwd(idxRequired, GmfVertices, requiredNodes + solSize);
    MGInput->GmfSetKwd(idxSol, GmfSolAtVertices, requiredNodes + solSize, 1, TypTab);
    for (hybridNodeIt = theRequiredNodes.begin();hybridNodeIt != theRequiredNodes.end();++hybridNodeIt) {
      MGInput->GmfSetLin(idxRequired, GmfVertices, (*hybridNodeIt)->X(), (*hybridNodeIt)->Y(), (*hybridNodeIt)->Z(), dummyint2);
      MGInput->GmfSetLin(idxSol, GmfSolAtVertices, ValTab);
      if (theEnforcedNodes.find((*hybridNodeIt)) != theEnforcedNodes.end())
        gn = theEnforcedNodes.find((*hybridNodeIt))->second;
      aNodeGroupByHybridId[usedEnforcedNodes] = gn;
      usedEnforcedNodes++;
    }

    for (int i=0;i<solSize;i++) {
      std::cout << ReqVerTab[i][0] <<" "<< ReqVerTab[i][1] << " "<< ReqVerTab[i][2] << std::endl;
#ifdef _DEBUG_
      std::cout << "enfVertexSizes.at("<<i<<"): " << enfVertexSizes.at(i) << std::endl;
#endif
      double solTab[] = {enfVertexSizes.at(i)};
      MGInput->GmfSetLin(idxRequired, GmfVertices, ReqVerTab[i][0], ReqVerTab[i][1], ReqVerTab[i][2], dummyint3);
      MGInput->GmfSetLin(idxSol, GmfSolAtVertices, solTab);
      aNodeGroupByHybridId[usedEnforcedNodes] = enfVerticesWithGroup.find(ReqVerTab[i])->second;
#ifdef _DEBUG_
      std::cout << "aNodeGroupByHybridId["<<usedEnforcedNodes<<"] = \""<<aNodeGroupByHybridId[usedEnforcedNodes]<<"\""<<std::endl;
#endif
      usedEnforcedNodes++;
    }
    std::cout << "End writing in req and sol file" << std::endl;
  }

  int nedge[2], ntri[3], nquad[4];
    
  // GmfEdges
  int usedEnforcedEdges = 0;
  if (theKeptEnforcedEdges.size()) {
    anEdgeGroupByHybridId.resize( theKeptEnforcedEdges.size() );
    MGInput->GmfSetKwd(idx, GmfEdges, theKeptEnforcedEdges.size());
    for(elemSetIt = theKeptEnforcedEdges.begin() ; elemSetIt != theKeptEnforcedEdges.end() ; ++elemSetIt) {
      elem = (*elemSetIt);
      nodeIt = elem->nodesIterator();
      int index=0;
      while ( nodeIt->more() ) {
        // find HYBRID ID
        const SMDS_MeshNode* node = castToNode( nodeIt->next() );
        std::map< const SMDS_MeshNode*,int >::iterator it = anEnforcedNodeToHybridIdMap.find(node);
        if (it == anEnforcedNodeToHybridIdMap.end()) {
          it = anExistingEnforcedNodeToHybridIdMap.find(node);
          if (it == anEnforcedNodeToHybridIdMap.end())
            throw "Node not found";
        }
        nedge[index] = it->second;
        index++;
      }
      MGInput->GmfSetLin(idx, GmfEdges, nedge[0], nedge[1], dummyint4);
      anEdgeGroupByHybridId[usedEnforcedEdges] = theEnforcedEdges.find(elem)->second;
      usedEnforcedEdges++;
    }
  }


  if (usedEnforcedEdges) {
    MGInput->GmfSetKwd(idx, GmfRequiredEdges, usedEnforcedEdges);
    for (int enfID=1;enfID<=usedEnforcedEdges;enfID++) {
      MGInput->GmfSetLin(idx, GmfRequiredEdges, enfID);
    }
  }

  // GmfTriangles
  int usedEnforcedTriangles = 0;
  if (anElemSetTri.size()+theKeptEnforcedTriangles.size())
  {
    aFaceGroupByHybridId.resize( anElemSetTri.size()+theKeptEnforcedTriangles.size() );
    MGInput->GmfSetKwd(idx, GmfTriangles, anElemSetTri.size()+theKeptEnforcedTriangles.size());
    int k=0;
    for(elemSetIt = anElemSetTri.begin() ; elemSetIt != anElemSetTri.end() ; ++elemSetIt,++k)
    {
      elem = (*elemSetIt);
      theFaceByHybridId.push_back( elem );
      nodeIt = elem->nodesIterator();
      int index=0;
      for ( int j = 0; j < 3; ++j )
      {
        // find HYBRID ID
        const SMDS_MeshNode* node = castToNode( nodeIt->next() );
        std::map< const SMDS_MeshNode*,int >::iterator it = aNodeToHybridIdMap.find(node);
        if (it == aNodeToHybridIdMap.end())
          throw "Node not found";
        ntri[index] = it->second;
        index++;
      }
      MGInput->GmfSetLin(idx, GmfTriangles, ntri[0], ntri[1], ntri[2], /*tag=*/elem->getshapeId() );
      aFaceGroupByHybridId[k] = "";
    }
    
    if ( !theHelper.GetMesh()->HasShapeToMesh() ) SMESHUtils::FreeVector( theFaceByHybridId ); 
    std::cout << "Enforced triangles size " << theKeptEnforcedTriangles.size() << std::endl;
    if (theKeptEnforcedTriangles.size())
    {
      for(elemSetIt = theKeptEnforcedTriangles.begin() ; elemSetIt != theKeptEnforcedTriangles.end() ; ++elemSetIt,++k)
      {
        elem = (*elemSetIt);
        nodeIt = elem->nodesIterator();
        int index=0;
        for ( int j = 0; j < 3; ++j )
        {
          // find HYBRID ID
          const SMDS_MeshNode* node = castToNode( nodeIt->next() );
          std::map< const SMDS_MeshNode*,int >::iterator it = anEnforcedNodeToHybridIdMap.find(node);
          if (it == anEnforcedNodeToHybridIdMap.end())
          {
            it = anExistingEnforcedNodeToHybridIdMap.find(node);
            if (it == anEnforcedNodeToHybridIdMap.end())
              throw "Node not found";
          }
          ntri[index] = it->second;
          index++;
        }
        MGInput->GmfSetLin(idx, GmfTriangles, ntri[0], ntri[1], ntri[2], enforcedTag);
        aFaceGroupByHybridId[k] = theEnforcedTriangles.find(elem)->second;
        usedEnforcedTriangles++;
      }
    }
  }

  
  if (usedEnforcedTriangles)
  {
    MGInput->GmfSetKwd(idx, GmfRequiredTriangles, usedEnforcedTriangles);
    for (int enfID=1;enfID<=usedEnforcedTriangles;enfID++)
      MGInput->GmfSetLin(idx, GmfRequiredTriangles, anElemSetTri.size()+enfID);
  }
  
  if (anElemSetQuad.size())
  {
    MGInput->GmfSetKwd(idx, GmfQuadrilaterals, anElemSetQuad.size());
    int k=0;
    for(elemSetIt = anElemSetQuad.begin() ; elemSetIt != anElemSetQuad.end() ; ++elemSetIt,++k)
    {
      elem = (*elemSetIt);
      theFaceByHybridId.push_back( elem );
      nodeIt = elem->nodesIterator();
      int index=0;
      for ( int j = 0; j < 4; ++j )
      {
        // find HYBRID ID
        const SMDS_MeshNode* node = castToNode( nodeIt->next() );
        std::map< const SMDS_MeshNode*,int >::iterator it = aNodeToHybridIdMap.find(node);
        if (it == aNodeToHybridIdMap.end())
          throw "Node not found";
        nquad[index] = it->second;
        index++;
      }
      MGInput->GmfSetLin(idx, GmfQuadrilaterals, nquad[0], nquad[1], nquad[2], nquad[3],
                         /*tag=*/elem->getshapeId() );
      // _CEA_cbo what is it for???
      //aFaceGroupByHybridId[k] = "";
    }
  }

  MGInput->GmfCloseMesh(idx);
  chmodUserOnly(theMeshFileName);
  if (idxRequired)
    {
      MGInput->GmfCloseMesh(idxRequired);
      chmodUserOnly(theRequiredFileName);
    }
  if (idxSol)
    {
      MGInput->GmfCloseMesh(idxSol);
      chmodUserOnly(theSolFileName);
    }
  return true;
  
}

//=============================================================================
/*!
 *Here we are going to use the HYBRID mesher with geometry
 */
//=============================================================================

bool HYBRIDPlugin_HYBRID::Compute(SMESH_Mesh&         theMesh,
                                  const TopoDS_Shape& theShape)
{
  bool Ok = false;

  // a unique working file name
  // to avoid access to the same files by eg different users
  _genericName = HYBRIDPlugin_Hypothesis::GetFileName(_hyp);
  std::string aGenericName         = _genericName;
  std::string aGenericNameRequired = aGenericName + "_required";

  std::string aLogFileName    = aGenericName + ".log";    // log
  std::string aResultFileName;

  std::string aGMFFileName, aRequiredVerticesFileName, aSolFileName, aResSolFileName;
  aGMFFileName              = aGenericName + ".mesh"; // GMF mesh file
  aResultFileName           = aGenericName + "Vol.mesh"; // GMF mesh file
  aResSolFileName           = aGenericName + "Vol.sol"; // GMF mesh file
  aRequiredVerticesFileName = aGenericNameRequired + ".mesh"; // GMF required vertices mesh file
  aSolFileName              = aGenericNameRequired + ".sol"; // GMF solution file
  
  std::map <int,int> aNodeId2NodeIndexMap, aSmdsToHybridIdMap, anEnforcedNodeIdToHybridIdMap;
  std::map <int, int> nodeID2nodeIndexMap;
  std::map<std::vector<double>, std::string> enfVerticesWithGroup;
  HYBRIDPlugin_Hypothesis::THYBRIDEnforcedVertexCoordsValues coordsSizeMap = HYBRIDPlugin_Hypothesis::GetEnforcedVerticesCoordsSize(_hyp);
  HYBRIDPlugin_Hypothesis::TIDSortedNodeGroupMap enforcedNodes = HYBRIDPlugin_Hypothesis::GetEnforcedNodes(_hyp);
  HYBRIDPlugin_Hypothesis::TIDSortedElemGroupMap enforcedEdges = HYBRIDPlugin_Hypothesis::GetEnforcedEdges(_hyp);
  HYBRIDPlugin_Hypothesis::TIDSortedElemGroupMap enforcedTriangles = HYBRIDPlugin_Hypothesis::GetEnforcedTriangles(_hyp);
  HYBRIDPlugin_Hypothesis::TID2SizeMap nodeIDToSizeMap = HYBRIDPlugin_Hypothesis::GetNodeIDToSizeMap(_hyp);

  HYBRIDPlugin_Hypothesis::THYBRIDEnforcedVertexList enfVertices = HYBRIDPlugin_Hypothesis::GetEnforcedVertices(_hyp);
  HYBRIDPlugin_Hypothesis::THYBRIDEnforcedVertexList::const_iterator enfVerIt = enfVertices.begin();
  std::vector<double> coords;

  for ( ; enfVerIt != enfVertices.end() ; ++enfVerIt)
  {
    HYBRIDPlugin_Hypothesis::THYBRIDEnforcedVertex* enfVertex = (*enfVerIt);
    if (enfVertex->coords.size()) {
      coordsSizeMap.insert(std::make_pair(enfVertex->coords,enfVertex->size));
      enfVerticesWithGroup.insert(std::make_pair(enfVertex->coords,enfVertex->groupName));
    }
    else {
      TopoDS_Shape GeomShape = entryToShape(enfVertex->geomEntry);
      for (TopoDS_Iterator it (GeomShape); it.More(); it.Next()){
        coords.clear();
        if (it.Value().ShapeType() == TopAbs_VERTEX){
          gp_Pnt aPnt = BRep_Tool::Pnt(TopoDS::Vertex(it.Value()));
          coords.push_back(aPnt.X());
          coords.push_back(aPnt.Y());
          coords.push_back(aPnt.Z());
          if (coordsSizeMap.find(coords) == coordsSizeMap.end()) {
            coordsSizeMap.insert(std::make_pair(coords,enfVertex->size));
            enfVerticesWithGroup.insert(std::make_pair(coords,enfVertex->groupName));
          }
        }
      }
    }
  }
  int nbEnforcedVertices = coordsSizeMap.size();
  int nbEnforcedNodes = enforcedNodes.size();

  std::string tmpStr;
  (nbEnforcedNodes <= 1) ? tmpStr = "node" : "nodes";
  std::cout << nbEnforcedNodes << " enforced " << tmpStr << " from hypo" << std::endl;
  (nbEnforcedVertices <= 1) ? tmpStr = "vertex" : "vertices";
  std::cout << nbEnforcedVertices << " enforced " << tmpStr << " from hypo" << std::endl;

  SMESH_MesherHelper helper( theMesh );
  helper.SetSubShape( theShape );

  std::vector <const SMDS_MeshNode*> aNodeByHybridId, anEnforcedNodeByHybridId;
  std::vector <const SMDS_MeshElement*> aFaceByHybridId;
  std::map<const SMDS_MeshNode*,int> aNodeToHybridIdMap;
  std::vector<std::string> aNodeGroupByHybridId, anEdgeGroupByHybridId, aFaceGroupByHybridId;

  SMESH_ProxyMesh::Ptr proxyMesh( new SMESH_ProxyMesh( theMesh ));

  MG_HYBRID_API mgHybrid( _computeCanceled, _progress );

  bool useLibrary = HYBRIDPlugin_Hypothesis::GetToUseLibrary(_hyp);
  if (useLibrary)
    mgHybrid.SetUseLibrary();
  else
    mgHybrid.SetUseExecutable();

  Ok = writeGMFFile(&mgHybrid,
                    aGMFFileName.c_str(),
                    aRequiredVerticesFileName.c_str(),
                    aSolFileName.c_str(),
                    *proxyMesh, helper,
                    aNodeByHybridId, aFaceByHybridId, aNodeToHybridIdMap,
                    aNodeGroupByHybridId, anEdgeGroupByHybridId, aFaceGroupByHybridId,
                    enforcedNodes, enforcedEdges, enforcedTriangles, /*enforcedQuadrangles,*/
                    enfVerticesWithGroup, coordsSizeMap);

  // Write aSmdsToHybridIdMap to temp file
  std::string aSmdsToHybridIdMapFileName;
  aSmdsToHybridIdMapFileName = aGenericName + ".ids";  // ids relation
  std::ofstream aIdsFile  ( aSmdsToHybridIdMapFileName  , ios::out);
  Ok = aIdsFile.rdbuf()->is_open();
  if (!Ok) {
    INFOS( "Can't write into " << aSmdsToHybridIdMapFileName);
    return error(SMESH_Comment("Can't write into ") << aSmdsToHybridIdMapFileName);
  }
  INFOS( "Writing ids relation into " << aSmdsToHybridIdMapFileName);
  aIdsFile << "Smds Hybrid" << std::endl;
  std::map <int,int>::const_iterator myit;
  for (myit=aSmdsToHybridIdMap.begin() ; myit != aSmdsToHybridIdMap.end() ; ++myit) {
    aIdsFile << myit->first << " " << myit->second << std::endl;
  }

  aIdsFile.close();
  chmodUserOnly(aSmdsToHybridIdMapFileName.c_str());

  if ( ! Ok ) {
    if ( !_keepFiles ) {
      removeFile( aGMFFileName );
      removeFile( aRequiredVerticesFileName );
      removeFile( aSolFileName );
      removeFile( aSmdsToHybridIdMapFileName );
    }
    return error(COMPERR_BAD_INPUT_MESH);
  }
  removeFile( aResultFileName ); // needed for boundary recovery module usage

  // -----------------
  // run hybrid mesher
  // -----------------

  std::string cmd = HYBRIDPlugin_Hypothesis::CommandToRun( _hyp );

  if ( mgHybrid.IsExecutable() )
  {
    cmd += " --in "  + aGMFFileName;
    cmd += " --out " + aResultFileName;
  }
  std::cout << std::endl;
  std::cout << "Hybrid execution with geometry..." << std::endl;
  std::cout << cmd;
  if ( !_logInStandardOutput )
  {
    mgHybrid.SetLogFile( aLogFileName );
    if ( mgHybrid.IsExecutable() )
      cmd += " 1>" + aLogFileName;  // dump into file
    std::cout << " 1> " << aLogFileName;
  }
  std::cout << std::endl;

  _computeCanceled = false;

  std::string errStr;
  Ok = mgHybrid.Compute( cmd, errStr ); // run

  if ( _logInStandardOutput && mgHybrid.IsLibrary() )
    std::cout << std::endl << mgHybrid.GetLog() << std::endl;
  else
    chmodUserOnly(aLogFileName.c_str());
  if ( Ok )
    std::cout << "End of Hybrid execution !" << std::endl;

  if ( mgHybrid.IsExecutable() )
    {
      chmodUserOnly(aResultFileName.c_str());
      chmodUserOnly(aResSolFileName.c_str());
    }

  // --------------
  // read a result
  // --------------

  // Mapping the result file

  HYBRIDPlugin_Hypothesis::TSetStrings groupsToRemove = HYBRIDPlugin_Hypothesis::GetGroupsToRemove(_hyp);
  bool toMeshHoles =
    _hyp ? _hyp->GetToMeshHoles(true) : HYBRIDPlugin_Hypothesis::DefaultMeshHoles();
  const bool toMakeGroupsOfDomains = HYBRIDPlugin_Hypothesis::GetToMakeGroupsOfDomains( _hyp );

  helper.IsQuadraticSubMesh( theShape );
  helper.SetElementsOnShape( false );

  Ok = readGMFFile(&mgHybrid, aResultFileName.c_str(),
                   this,
                   &helper, aNodeByHybridId, aFaceByHybridId, aNodeToHybridIdMap,
                   aNodeGroupByHybridId, anEdgeGroupByHybridId, aFaceGroupByHybridId,
                   groupsToRemove, toMakeGroupsOfDomains, toMeshHoles);

  removeEmptyGroupsOfDomains( helper.GetMesh(), !toMakeGroupsOfDomains );



  // ---------------------
  // remove working files
  // ---------------------

  if ( Ok )
  {
    if ( _removeLogOnSuccess )
      removeFile( aLogFileName );
  }
  else if ( mgHybrid.HasLog() )
  {
    // get problem description from the log file
    _Ghs2smdsConvertor conv( aNodeByHybridId );
    storeErrorDescription( _logInStandardOutput ? 0 : aLogFileName.c_str(),
                           mgHybrid.GetLog(), conv );
  }
  else if ( !errStr.empty() )
  {
    // the log file is empty
    removeFile( aLogFileName );
    INFOS( "HYBRID Error, " << errStr );
    error(COMPERR_ALGO_FAILED, errStr );
  }

  if ( !_keepFiles ) {
    if (! Ok && _computeCanceled)
      removeFile( aLogFileName );
    removeFile( aGMFFileName );
    removeFile( aRequiredVerticesFileName );
    removeFile( aSolFileName );
    removeFile( aResSolFileName );
    removeFile( aResultFileName );
    removeFile( aSmdsToHybridIdMapFileName );
  }
  if ( mgHybrid.IsExecutable() )
  {
    std::cout << "<" << aResultFileName << "> HYBRID output file ";
    if ( !Ok )
      std::cout << "not ";
    std::cout << "treated !" << std::endl;
    std::cout << std::endl;
  }
  else
  {
    std::cout << "MG-HYBRID " << ( Ok ? "succeeded" : "failed") << std::endl;
  }

  return Ok;
}

//=============================================================================
/*!
 *Here we are going to use the HYBRID mesher w/o geometry
 */
//=============================================================================
bool HYBRIDPlugin_HYBRID::Compute(SMESH_Mesh&         theMesh,
                                  SMESH_MesherHelper* theHelper)
{
  theHelper->IsQuadraticSubMesh( theHelper->GetSubShape() );

  // a unique working file name
  // to avoid access to the same files by eg different users
  _genericName = HYBRIDPlugin_Hypothesis::GetFileName(_hyp);
  std::string aGenericName((char*) _genericName.c_str() );
  std::string aGenericNameRequired = aGenericName + "_required";

  std::string aLogFileName    = aGenericName + ".log";    // log
  std::string aResultFileName;
  bool Ok;

  std::string aGMFFileName, aRequiredVerticesFileName, aSolFileName, aResSolFileName;
  aGMFFileName              = aGenericName + ".mesh"; // GMF mesh file
  aResultFileName           = aGenericName + "Vol.mesh"; // GMF mesh file
  aResSolFileName           = aGenericName + "Vol.sol"; // GMF mesh file
  aRequiredVerticesFileName = aGenericNameRequired + ".mesh"; // GMF required vertices mesh file
  aSolFileName              = aGenericNameRequired + ".sol"; // GMF solution file

  std::map <int, int> nodeID2nodeIndexMap;
  std::map<std::vector<double>, std::string> enfVerticesWithGroup;
  HYBRIDPlugin_Hypothesis::THYBRIDEnforcedVertexCoordsValues coordsSizeMap;
  TopoDS_Shape GeomShape;
  std::vector<double> coords;
  gp_Pnt aPnt;
  HYBRIDPlugin_Hypothesis::THYBRIDEnforcedVertex* enfVertex;

  HYBRIDPlugin_Hypothesis::THYBRIDEnforcedVertexList enfVertices = HYBRIDPlugin_Hypothesis::GetEnforcedVertices(_hyp);
  HYBRIDPlugin_Hypothesis::THYBRIDEnforcedVertexList::const_iterator enfVerIt = enfVertices.begin();

  for ( ; enfVerIt != enfVertices.end() ; ++enfVerIt)
  {
    enfVertex = (*enfVerIt);
    if (enfVertex->coords.size()) {
      coordsSizeMap.insert(std::make_pair(enfVertex->coords,enfVertex->size));
      enfVerticesWithGroup.insert(std::make_pair(enfVertex->coords,enfVertex->groupName));
    }
    else {
      GeomShape = entryToShape(enfVertex->geomEntry);
      for (TopoDS_Iterator it (GeomShape); it.More(); it.Next()){
        coords.clear();
        if (it.Value().ShapeType() == TopAbs_VERTEX){
          aPnt = BRep_Tool::Pnt(TopoDS::Vertex(it.Value()));
          coords.push_back(aPnt.X());
          coords.push_back(aPnt.Y());
          coords.push_back(aPnt.Z());
          if (coordsSizeMap.find(coords) == coordsSizeMap.end()) {
            coordsSizeMap.insert(std::make_pair(coords,enfVertex->size));
            enfVerticesWithGroup.insert(std::make_pair(coords,enfVertex->groupName));
          }
        }
      }
    }
  }

  HYBRIDPlugin_Hypothesis::TIDSortedNodeGroupMap enforcedNodes = HYBRIDPlugin_Hypothesis::GetEnforcedNodes(_hyp);
  HYBRIDPlugin_Hypothesis::TIDSortedElemGroupMap enforcedEdges = HYBRIDPlugin_Hypothesis::GetEnforcedEdges(_hyp);
  HYBRIDPlugin_Hypothesis::TIDSortedElemGroupMap enforcedTriangles = HYBRIDPlugin_Hypothesis::GetEnforcedTriangles(_hyp);
  HYBRIDPlugin_Hypothesis::TID2SizeMap nodeIDToSizeMap = HYBRIDPlugin_Hypothesis::GetNodeIDToSizeMap(_hyp);

  std::string tmpStr;

  int nbEnforcedVertices = coordsSizeMap.size();
  int nbEnforcedNodes = enforcedNodes.size();
  (nbEnforcedNodes <= 1) ? tmpStr = "node" : tmpStr = "nodes";
  std::cout << nbEnforcedNodes << " enforced " << tmpStr << " from hypo" << std::endl;
  (nbEnforcedVertices <= 1) ? tmpStr = "vertex" : tmpStr = "vertices";
  std::cout << nbEnforcedVertices << " enforced " << tmpStr << " from hypo" << std::endl;

  std::vector <const SMDS_MeshNode*> aNodeByHybridId, anEnforcedNodeByHybridId;
  std::vector <const SMDS_MeshElement*> aFaceByHybridId;
  std::map<const SMDS_MeshNode*,int> aNodeToHybridIdMap;
  std::vector<std::string> aNodeGroupByHybridId, anEdgeGroupByHybridId, aFaceGroupByHybridId;

  SMESH_ProxyMesh::Ptr proxyMesh( new SMESH_ProxyMesh( theMesh ));

  MG_HYBRID_API mgHybrid( _computeCanceled, _progress );

  Ok = writeGMFFile(&mgHybrid,
                    aGMFFileName.c_str(),
                    aRequiredVerticesFileName.c_str(), aSolFileName.c_str(),
                    *proxyMesh, *theHelper,
                    aNodeByHybridId, aFaceByHybridId, aNodeToHybridIdMap,
                    aNodeGroupByHybridId, anEdgeGroupByHybridId, aFaceGroupByHybridId,
                    enforcedNodes, enforcedEdges, enforcedTriangles,
                    enfVerticesWithGroup, coordsSizeMap);

  // -----------------
  // run hybrid mesher
  // -----------------

  std::string cmd = HYBRIDPlugin_Hypothesis::CommandToRun( _hyp );

  if ( mgHybrid.IsExecutable() )
  {
    cmd += " --in "  + aGMFFileName;
    cmd += " --out " + aResultFileName;
  }
  if ( !_logInStandardOutput )
  {
    cmd += " 1> " + aLogFileName;  // dump into file
    mgHybrid.SetLogFile( aLogFileName );
  }
  std::cout << std::endl;
  std::cout << "Hybrid execution w/o geometry..." << std::endl;
  std::cout << cmd << std::endl;

  _computeCanceled = false;

  std::string errStr;
  Ok = mgHybrid.Compute( cmd, errStr ); // run

  if ( _logInStandardOutput && mgHybrid.IsLibrary() )
    std::cout << std::endl << mgHybrid.GetLog() << std::endl;
  else
    chmodUserOnly(aLogFileName.c_str());
  if ( Ok )
    std::cout << "End of Hybrid execution !" << std::endl;

  if (mgHybrid.IsExecutable())
    {
      chmodUserOnly(aResultFileName.c_str());
      chmodUserOnly(aResSolFileName.c_str());
    }

  // --------------
  // read a result
  // --------------
  HYBRIDPlugin_Hypothesis::TSetStrings groupsToRemove = HYBRIDPlugin_Hypothesis::GetGroupsToRemove(_hyp);
  const bool toMakeGroupsOfDomains = HYBRIDPlugin_Hypothesis::GetToMakeGroupsOfDomains( _hyp );

  Ok = Ok && readGMFFile(&mgHybrid,
                         aResultFileName.c_str(),
                         this,
                         theHelper, aNodeByHybridId, aFaceByHybridId, aNodeToHybridIdMap,
                         aNodeGroupByHybridId, anEdgeGroupByHybridId, aFaceGroupByHybridId,
                         groupsToRemove, toMakeGroupsOfDomains);

  updateMeshGroups(theHelper->GetMesh(), groupsToRemove);
  removeEmptyGroupsOfDomains( theHelper->GetMesh(), !toMakeGroupsOfDomains );

  if ( Ok ) {
    HYBRIDPlugin_Hypothesis* that = (HYBRIDPlugin_Hypothesis*)this->_hyp;
    if (that)
      that->ClearGroupsToRemove();
  }
  // ---------------------
  // remove working files
  // ---------------------

  if ( Ok )
  {
    if ( _removeLogOnSuccess )
      removeFile( aLogFileName );
  }
  else if ( mgHybrid.HasLog() )
  {
    // get problem description from the log file
    _Ghs2smdsConvertor conv( aNodeByHybridId );
    storeErrorDescription( _logInStandardOutput ? 0 : aLogFileName.c_str(),
                           mgHybrid.GetLog(), conv );
  }
  else {
    // the log file is empty
    removeFile( aLogFileName );
    INFOS( "HYBRID Error, command '" << cmd << "' failed" );
    error(COMPERR_ALGO_FAILED, "hybrid: command not found" );
  }

  if ( !_keepFiles )
  {
    if (! Ok && _computeCanceled)
      removeFile( aLogFileName );
    removeFile( aGMFFileName );
    removeFile( aResultFileName );
    removeFile( aRequiredVerticesFileName );
    removeFile( aSolFileName );
    removeFile( aResSolFileName );
  }
  return Ok;
}

void HYBRIDPlugin_HYBRID::CancelCompute()
{
  _computeCanceled = true;
#if !defined(WIN32) && !defined(__APPLE__)
  std::string cmd = "ps xo pid,args | grep " + _genericName;
  //cmd += " | grep -e \"^ *[0-9]\\+ \\+" + HYBRIDPlugin_Hypothesis::GetExeName() + "\"";
  cmd += " | awk '{print $1}' | xargs kill -9 > /dev/null 2>&1";
  system( cmd.c_str() );
#endif
}

//================================================================================
/*!
 * \brief Provide human readable text by error code reported by hybrid
 */
//================================================================================

static const char* translateError(const int errNum)
{
  switch ( errNum ) {
  case 0:
    return "error distene 0";
  case 1:
    return "error distene 1";
  }
  return "unknown distene error";
}

//================================================================================
/*!
 * \brief Retrieve from a string given number of integers
 */
//================================================================================

static char* getIds( char* ptr, int nbIds, std::vector<int>& ids )
{
  ids.clear();
  ids.reserve( nbIds );
  while ( nbIds )
  {
    while ( !isdigit( *ptr )) ++ptr;
    if ( ptr[-1] == '-' ) --ptr;
    ids.push_back( strtol( ptr, &ptr, 10 ));
    --nbIds;
  }
  return ptr;
}

//================================================================================
/*!
 * \brief Retrieve problem description form a log file
 *  \retval bool - always false
 */
//================================================================================

bool HYBRIDPlugin_HYBRID::storeErrorDescription(const char*                logFile,
                                                const std::string&         log,
                                                const _Ghs2smdsConvertor & toSmdsConvertor )
{
  if(_computeCanceled)
    return error(SMESH_Comment("interruption initiated by user"));

  char* ptr = const_cast<char*>( log.c_str() );
  char* buf = ptr, * bufEnd = ptr + log.size();

  SMESH_Comment errDescription;

  enum { NODE = 1, EDGE, TRIA, VOL, SKIP_ID = 1 };

  // look for MeshGems version
  // Since "MG-TETRA -- MeshGems 1.1-3 (January, 2013)" error codes change.
  // To discriminate old codes from new ones we add 1000000 to the new codes.
  // This way value of the new codes is same as absolute value of codes printed
  // in the log after "MGMESSAGE" string.
  int versionAddition = 0;
  {
    char* verPtr = ptr;
    while ( ++verPtr < bufEnd )
    {
      if ( strncmp( verPtr, "MG-TETRA -- MeshGems ", 21 ) != 0 )
        continue;
      if ( strcmp( verPtr, "MG-TETRA -- MeshGems 1.1-3 " ) >= 0 )
        versionAddition = 1000000;
      ptr = verPtr;
      break;
    }
  }

  // look for errors "ERR #"

  std::set<std::string> foundErrorStr; // to avoid reporting same error several times
  std::set<int>         elemErrorNums; // not to report different types of errors with bad elements
  while ( ++ptr < bufEnd )
  {
    if ( strncmp( ptr, "ERR ", 4 ) != 0 )
      continue;

    std::list<const SMDS_MeshElement*> badElems;
    std::vector<int> nodeIds;

    ptr += 4;
    char* errBeg = ptr;
    int   errNum = strtol(ptr, &ptr, 10) + versionAddition;
    // we treat errors enumerated in [SALOME platform 0019316] issue
    // and all errors from a new (Release 1.1) MeshGems User Manual
    switch ( errNum ) {
    case 0015: // The face number (numfac) with vertices (f 1, f 2, f 3) has a null vertex.
    case 1005620 : // a too bad quality face is detected. This face is considered degenerated.
      ptr = getIds(ptr, SKIP_ID, nodeIds);
      ptr = getIds(ptr, TRIA, nodeIds);
      badElems.push_back( toSmdsConvertor.getElement(nodeIds));
      break;
    case 1005621 : // a too bad quality face is detected. This face is degenerated.
      // hence the is degenerated it is invisible, add its edges in addition
      ptr = getIds(ptr, SKIP_ID, nodeIds);
      ptr = getIds(ptr, TRIA, nodeIds);
      badElems.push_back( toSmdsConvertor.getElement(nodeIds));
      {
        std::vector<int> edgeNodes( nodeIds.begin(), --nodeIds.end() ); // 01
        badElems.push_back( toSmdsConvertor.getElement(edgeNodes));
        edgeNodes[1] = nodeIds[2]; // 02
        badElems.push_back( toSmdsConvertor.getElement(edgeNodes));
        edgeNodes[0] = nodeIds[1]; // 12
      }      
      break;
    case 1000: // Face (f 1, f 2, f 3) appears more than once in the input surface mesh.
      // ERR  1000 :  1 3 2
    case 1002: // Face (f 1, f 2, f 3) has a vertex negative or null
    case 3019: // Constrained face (f 1, f 2, f 3) cannot be enforced
    case 1002211: // a face has a vertex negative or null.
    case 1005200 : // a surface mesh appears more than once in the input surface mesh.
    case 1008423 : // a constrained face cannot be enforced (regeneration phase failed).
      ptr = getIds(ptr, TRIA, nodeIds);
      badElems.push_back( toSmdsConvertor.getElement(nodeIds));
      break;
    case 1001: // Edge (e1, e2) appears more than once in the input surface mesh
    case 3009: // Constrained edge (e1, e2) cannot be enforced (warning).
      // ERR  3109 :  EDGE  5 6 UNIQUE
    case 3109: // Edge (e1, e2) is unique (i.e., bounds a hole in the surface)
    case 1005210 : // an edge appears more than once in the input surface mesh.
    case 1005820 : // an edge is unique (i.e., bounds a hole in the surface).
    case 1008441 : // a constrained edge cannot be enforced.
      ptr = getIds(ptr, EDGE, nodeIds);
      badElems.push_back( toSmdsConvertor.getElement(nodeIds));
      break;
    case 2004: // Vertex v1 and vertex v2 are too close to one another or coincident (warning).
    case 2014: // at least two points whose distance is dist, i.e., considered as coincident
    case 2103: // Vertex v1 and vertex v2 are too close to one another or coincident (warning).
      // ERR  2103 :  16 WITH  3
    case 1005105 : // two vertices are too close to one another or coincident.
    case 1005107: // Two vertices are too close to one another or coincident.
      ptr = getIds(ptr, NODE, nodeIds);
      badElems.push_back( toSmdsConvertor.getElement(nodeIds));
      ptr = getIds(ptr, NODE, nodeIds);
      badElems.push_back( toSmdsConvertor.getElement(nodeIds));
      break;
    case 2012: // Vertex v1 cannot be inserted (warning).
    case 1005106 : // a vertex cannot be inserted.
      ptr = getIds(ptr, NODE, nodeIds);
      badElems.push_back( toSmdsConvertor.getElement(nodeIds));
      break;
    case 3103: // The surface edge (e1, e2) intersects another surface edge (e3, e4)
    case 1005110 : // two surface edges are intersecting.
      // ERR  3103 :  1 2 WITH  7 3
      ptr = getIds(ptr, EDGE, nodeIds);
      badElems.push_back( toSmdsConvertor.getElement(nodeIds));
      ptr = getIds(ptr, EDGE, nodeIds);
      badElems.push_back( toSmdsConvertor.getElement(nodeIds));
      break;
    case 3104: // The surface edge (e1, e2) intersects the surface face (f 1, f 2, f 3)
      // ERR  3104 :  9 10 WITH  1 2 3
    case 3106: // One surface edge (say e1, e2) intersects a surface face (f 1, f 2, f 3)
    case 1005120 : // a surface edge intersects a surface face.
      ptr = getIds(ptr, EDGE, nodeIds);
      badElems.push_back( toSmdsConvertor.getElement(nodeIds));
      ptr = getIds(ptr, TRIA, nodeIds);
      badElems.push_back( toSmdsConvertor.getElement(nodeIds));
      break;
    case 3105: // One boundary point (say p1) lies within a surface face (f 1, f 2, f 3)
      // ERR  3105 :  8 IN  2 3 5
    case 1005150 : // a boundary point lies within a surface face.
      ptr = getIds(ptr, NODE, nodeIds);
      badElems.push_back( toSmdsConvertor.getElement(nodeIds));
      ptr = getIds(ptr, TRIA, nodeIds);
      badElems.push_back( toSmdsConvertor.getElement(nodeIds));
      break;
    case 3107: // One boundary point (say p1) lies within a surface edge (e1, e2) (stop).
      // ERR  3107 :  2 IN  4 1
    case 1005160 : // a boundary point lies within a surface edge.
      ptr = getIds(ptr, NODE, nodeIds);
      badElems.push_back( toSmdsConvertor.getElement(nodeIds));
      ptr = getIds(ptr, EDGE, nodeIds);
      badElems.push_back( toSmdsConvertor.getElement(nodeIds));
      break;
    case 9000: // ERR  9000
      //  ELEMENT  261 WITH VERTICES :  7 396 -8 242
      //  VOLUME   : -1.11325045E+11 W.R.T. EPSILON   0.
      // A too small volume element is detected. Are reported the index of the element,
      // its four vertex indices, its volume and the tolerance threshold value
      ptr = getIds(ptr, SKIP_ID, nodeIds);
      ptr = getIds(ptr, VOL, nodeIds);
      badElems.push_back( toSmdsConvertor.getElement(nodeIds));
      // even if all nodes found, volume it most probably invisible,
      // add its faces to demonstrate it anyhow
      {
        std::vector<int> faceNodes( nodeIds.begin(), --nodeIds.end() ); // 012
        badElems.push_back( toSmdsConvertor.getElement(faceNodes));
        faceNodes[2] = nodeIds[3]; // 013
        badElems.push_back( toSmdsConvertor.getElement(faceNodes));
        faceNodes[1] = nodeIds[2]; // 023
        badElems.push_back( toSmdsConvertor.getElement(faceNodes));
        faceNodes[0] = nodeIds[1]; // 123
        badElems.push_back( toSmdsConvertor.getElement(faceNodes));
      }
      break;
    case 9001: // ERR  9001
      //  %% NUMBER OF NEGATIVE VOLUME TETS  :  1
      //  %% THE LARGEST NEGATIVE TET        :   1.75376581E+11
      //  %%  NUMBER OF NULL VOLUME TETS     :  0
      // There exists at least a null or negative volume element
      break;
    case 9002:
      // There exist n null or negative volume elements
      break;
    case 9003:
      // A too small volume element is detected
      break;
    case 9102:
      // A too bad quality face is detected. This face is considered degenerated,
      // its index, its three vertex indices together with its quality value are reported
      break; // same as next
    case 9112: // ERR  9112
      //  FACE   2 WITH VERTICES :  4 2 5
      //  SMALL INRADIUS :   0.
      // A too bad quality face is detected. This face is degenerated,
      // its index, its three vertex indices together with its inradius are reported
      ptr = getIds(ptr, SKIP_ID, nodeIds);
      ptr = getIds(ptr, TRIA, nodeIds);
      badElems.push_back( toSmdsConvertor.getElement(nodeIds));
      // add triangle edges as it most probably has zero area and hence invisible
      {
        std::vector<int> edgeNodes(2);
        edgeNodes[0] = nodeIds[0]; edgeNodes[1] = nodeIds[1]; // 0-1
        badElems.push_back( toSmdsConvertor.getElement(edgeNodes));
        edgeNodes[1] = nodeIds[2]; // 0-2
        badElems.push_back( toSmdsConvertor.getElement(edgeNodes));
        edgeNodes[0] = nodeIds[1]; // 1-2
        badElems.push_back( toSmdsConvertor.getElement(edgeNodes));
      }
      break;
    case 1005103 : // the vertices of an element are too close to one another or coincident.
      ptr = getIds(ptr, TRIA, nodeIds);
      if ( nodeIds.back() == 0 ) // index of the third vertex of the element (0 for an edge)
        nodeIds.resize( EDGE );
      badElems.push_back( toSmdsConvertor.getElement(nodeIds));
      break;
    }

    bool isNewError = foundErrorStr.insert( std::string( errBeg, ptr )).second;
    if ( !isNewError )
      continue; // not to report same error several times

//     const SMDS_MeshElement* nullElem = 0;
//     bool allElemsOk = ( find( badElems.begin(), badElems.end(), nullElem) == badElems.end());

//     if ( allElemsOk && !badElems.empty() && !elemErrorNums.empty() ) {
//       bool oneMoreErrorType = elemErrorNums.insert( errNum ).second;
//       if ( oneMoreErrorType )
//         continue; // not to report different types of errors with bad elements
//     }

    // store bad elements
    //if ( allElemsOk ) {
      std::list<const SMDS_MeshElement*>::iterator elem = badElems.begin();
      for ( ; elem != badElems.end(); ++elem )
        addBadInputElement( *elem );
      //}

    // make error text
    std::string text = translateError( errNum );
    if ( errDescription.find( text ) == text.npos ) {
      if ( !errDescription.empty() )
        errDescription << "\n";
      errDescription << text;
    }

  } // end while

  if ( errDescription.empty() ) { // no errors found
    char msgLic1[] = "connection to server failed";
    char msgLic2[] = " Dlim ";
    char msgLic3[] = "license is not valid";
    if ( std::search( &buf[0], bufEnd, msgLic1, msgLic1 + strlen(msgLic1)) != bufEnd ||
         std::search( &buf[0], bufEnd, msgLic2, msgLic2 + strlen(msgLic2)) != bufEnd )
      errDescription << "Network license problem.";
    else if ( std::search( &buf[0], bufEnd, msgLic3, msgLic3 + strlen(msgLic3)) != bufEnd )
      errDescription << "License is not valid.";
    else
    {
      char msg2[] = "SEGMENTATION FAULT";
      if ( std::search( &buf[0], bufEnd, msg2, msg2 + strlen(msg2)) != bufEnd )
        errDescription << "hybrid: SEGMENTATION FAULT. ";
    }
  }

  if ( logFile && logFile[0] )
  {
    if ( errDescription.empty() )
      errDescription << "See " << logFile << " for problem description";
    else
      errDescription << "\nSee " << logFile << " for more information";
  }
  return error( errDescription );
}

//================================================================================
/*!
 * \brief Creates _Ghs2smdsConvertor
 */
//================================================================================

_Ghs2smdsConvertor::_Ghs2smdsConvertor( const std::map <int,const SMDS_MeshNode*> & ghs2NodeMap)
  :_ghs2NodeMap( & ghs2NodeMap ), _nodeByGhsId( 0 )
{
}

//================================================================================
/*!
 * \brief Creates _Ghs2smdsConvertor
 */
//================================================================================

_Ghs2smdsConvertor::_Ghs2smdsConvertor( const std::vector <const SMDS_MeshNode*> &  nodeByGhsId)
  : _ghs2NodeMap( 0 ), _nodeByGhsId( &nodeByGhsId )
{
}

//================================================================================
/*!
 * \brief Return SMDS element by ids of HYBRID nodes
 */
//================================================================================

const SMDS_MeshElement* _Ghs2smdsConvertor::getElement(const std::vector<int>& ghsNodes) const
{
  size_t nbNodes = ghsNodes.size();
  std::vector<const SMDS_MeshNode*> nodes( nbNodes, 0 );
  for ( size_t i = 0; i < nbNodes; ++i ) {
    int ghsNode = ghsNodes[ i ];
    if ( _ghs2NodeMap ) {
      std::map <int,const SMDS_MeshNode*>::const_iterator in = _ghs2NodeMap->find( ghsNode);
      if ( in == _ghs2NodeMap->end() )
        return 0;
      nodes[ i ] = in->second;
    }
    else {
      if ( ghsNode < 1 || ghsNode > (int)_nodeByGhsId->size() )
        return 0;
      nodes[ i ] = (*_nodeByGhsId)[ ghsNode-1 ];
    }
  }
  if ( nbNodes == 1 )
    return nodes[0];

  if ( nbNodes == 2 ) {
    const SMDS_MeshElement* edge= SMDS_Mesh::FindEdge( nodes[0], nodes[1] );
    if ( !edge )
      edge = new SMDS_LinearEdge( nodes[0], nodes[1] );
    return edge;
  }
  if ( nbNodes == 3 ) {
    const SMDS_MeshElement* face = SMDS_Mesh::FindFace( nodes );
    if ( !face )
      face = new SMDS_FaceOfNodes( nodes[0], nodes[1], nodes[2] );
    return face;
  }
  if ( nbNodes == 4 )
    return new SMDS_VolumeOfNodes( nodes[0], nodes[1], nodes[2], nodes[3] );

  return 0;
}


//=============================================================================
/*!
 *
 */
//=============================================================================
bool HYBRIDPlugin_HYBRID::Evaluate(SMESH_Mesh& aMesh,
                                 const TopoDS_Shape& aShape,
                                 MapShapeNbElems& aResMap)
{
  int nbtri = 0, nbqua = 0;
  double fullArea = 0.0;
  for (TopExp_Explorer exp(aShape, TopAbs_FACE); exp.More(); exp.Next()) {
    TopoDS_Face F = TopoDS::Face( exp.Current() );
    SMESH_subMesh *sm = aMesh.GetSubMesh(F);
    MapShapeNbElemsItr anIt = aResMap.find(sm);
    if( anIt==aResMap.end() ) {
      SMESH_ComputeErrorPtr& smError = sm->GetComputeError();
      smError.reset( new SMESH_ComputeError(COMPERR_ALGO_FAILED,
                                            "Submesh can not be evaluated",this));
      return false;
    }
    std::vector<smIdType> aVec = (*anIt).second;
    nbtri += std::max(aVec[SMDSEntity_Triangle],aVec[SMDSEntity_Quad_Triangle]);
    nbqua += std::max(aVec[SMDSEntity_Quadrangle],aVec[SMDSEntity_Quad_Quadrangle]);
    GProp_GProps G;
    BRepGProp::SurfaceProperties(F,G);
    double anArea = G.Mass();
    fullArea += anArea;
  }

  // collect info from edges
  int nb0d_e = 0, nb1d_e = 0;
  bool IsQuadratic = false;
  bool IsFirst = true;
  TopTools_MapOfShape tmpMap;
  for (TopExp_Explorer exp(aShape, TopAbs_EDGE); exp.More(); exp.Next()) {
    TopoDS_Edge E = TopoDS::Edge(exp.Current());
    if( tmpMap.Contains(E) )
      continue;
    tmpMap.Add(E);
    SMESH_subMesh *aSubMesh = aMesh.GetSubMesh(exp.Current());
    MapShapeNbElemsItr anIt = aResMap.find(aSubMesh);
    std::vector<smIdType> aVec = (*anIt).second;
    nb0d_e += aVec[SMDSEntity_Node];
    nb1d_e += std::max(aVec[SMDSEntity_Edge],aVec[SMDSEntity_Quad_Edge]);
    if(IsFirst) {
      IsQuadratic = (aVec[SMDSEntity_Quad_Edge] > aVec[SMDSEntity_Edge]);
      IsFirst = false;
    }
  }
  tmpMap.Clear();

  double ELen = sqrt(2.* ( fullArea/(nbtri+nbqua*2) ) / sqrt(3.0) );

  GProp_GProps G;
  BRepGProp::VolumeProperties(aShape,G);
  double aVolume = G.Mass();
  double tetrVol = 0.1179*ELen*ELen*ELen;
  double CoeffQuality = 0.9;
  int nbVols = int(aVolume/tetrVol/CoeffQuality);
  int nb1d_f = (nbtri*3 + nbqua*4 - nb1d_e) / 2;
  int nb1d_in = (int) ( nbVols*6 - nb1d_e - nb1d_f ) / 5;
  std::vector<smIdType> aVec(SMDSEntity_Last);
  for(int i=SMDSEntity_Node; i<SMDSEntity_Last; i++) aVec[i]=0;
  if( IsQuadratic ) {
    aVec[SMDSEntity_Node] = nb1d_in/6 + 1 + nb1d_in;
    aVec[SMDSEntity_Quad_Tetra] = nbVols - nbqua*2;
    aVec[SMDSEntity_Quad_Pyramid] = nbqua;
  }
  else {
    aVec[SMDSEntity_Node] = nb1d_in/6 + 1;
    aVec[SMDSEntity_Tetra] = nbVols - nbqua*2;
    aVec[SMDSEntity_Pyramid] = nbqua;
  }
  SMESH_subMesh *sm = aMesh.GetSubMesh(aShape);
  aResMap.insert(std::make_pair(sm,aVec));

  return true;
}

bool HYBRIDPlugin_HYBRID::importGMFMesh(const char* theGMFFileName, SMESH_Mesh& theMesh)
{
  SMESH_ComputeErrorPtr err = theMesh.GMFToMesh( theGMFFileName, /*makeRequiredGroups =*/ true );

  theMesh.GetMeshDS()->Modified();

  return ( !err || err->IsOK());
}

namespace
{
  //================================================================================
  /*!
   * \brief Sub-mesh event listener setting enforced elements as soon as an enforced
   *        mesh is loaded
   */
  struct _EnforcedMeshRestorer : public SMESH_subMeshEventListener
  {
    _EnforcedMeshRestorer():
      SMESH_subMeshEventListener( /*isDeletable = */true, Name() )
    {}

    //================================================================================
    /*!
     * \brief Returns an ID of listener
     */
    static const char* Name() { return "HYBRIDPlugin_HYBRID::_EnforcedMeshRestorer"; }

    //================================================================================
    /*!
     * \brief Treat events of the subMesh
     */
    void ProcessEvent(const int                       event,
                      const int                       eventType,
                      SMESH_subMesh*                  /*subMesh*/,
                      SMESH_subMeshEventListenerData* data,
                      const SMESH_Hypothesis*         /*hyp*/)
    {
      if ( SMESH_subMesh::SUBMESH_LOADED == event &&
           SMESH_subMesh::COMPUTE_EVENT  == eventType &&
           data &&
           !data->mySubMeshes.empty() )
      {
        // An enforced mesh (subMesh->_father) has been loaded from hdf file
        if ( HYBRIDPlugin_Hypothesis* hyp = GetGHSHypothesis( data->mySubMeshes.front() ))
          hyp->RestoreEnfElemsByMeshes();
      }
    }
    //================================================================================
    /*!
     * \brief Returns HYBRIDPlugin_Hypothesis used to compute a subMesh
     */
    static HYBRIDPlugin_Hypothesis* GetGHSHypothesis( SMESH_subMesh* subMesh )
    {
      SMESH_HypoFilter ghsHypFilter( SMESH_HypoFilter::HasName( "HYBRID_Parameters" ));
      return (HYBRIDPlugin_Hypothesis* )
        subMesh->GetFather()->GetHypothesis( subMesh->GetSubShape(),
                                             ghsHypFilter,
                                             /*visitAncestors=*/true);
    }
  };

  //================================================================================
  /*!
   * \brief Sub-mesh event listener removing empty groups created due to "To make
   *        groups of domains".
   */
  struct _GroupsOfDomainsRemover : public SMESH_subMeshEventListener
  {
    _GroupsOfDomainsRemover():
      SMESH_subMeshEventListener( /*isDeletable = */true,
                                  "HYBRIDPlugin_HYBRID::_GroupsOfDomainsRemover" ) {}
    /*!
     * \brief Treat events of the subMesh
     */
    void ProcessEvent(const int                       /*event*/,
                      const int                       eventType,
                      SMESH_subMesh*                  subMesh,
                      SMESH_subMeshEventListenerData* /*data*/,
                      const SMESH_Hypothesis*         /*hyp*/)
    {
      if (SMESH_subMesh::ALGO_EVENT == eventType &&
          !subMesh->GetAlgo() )
      {
        removeEmptyGroupsOfDomains( subMesh->GetFather(), /*notEmptyAsWell=*/true );
      }
    }
  };
}

//================================================================================
/*!
 * \brief Set an event listener to set enforced elements as soon as an enforced
 *        mesh is loaded
 */
//================================================================================

void HYBRIDPlugin_HYBRID::SubmeshRestored(SMESH_subMesh* subMesh)
{
  if ( HYBRIDPlugin_Hypothesis* hyp = _EnforcedMeshRestorer::GetGHSHypothesis( subMesh ))
  {
    HYBRIDPlugin_Hypothesis::THYBRIDEnforcedMeshList enfMeshes = hyp->_GetEnforcedMeshes();
    HYBRIDPlugin_Hypothesis::THYBRIDEnforcedMeshList::iterator it = enfMeshes.begin();
    for(;it != enfMeshes.end();++it) {
      HYBRIDPlugin_Hypothesis::THYBRIDEnforcedMesh* enfMesh = *it;
      if ( SMESH_Mesh* mesh = GetMeshByPersistentID( enfMesh->persistID ))
      {
        SMESH_subMesh* smToListen = mesh->GetSubMesh( mesh->GetShapeToMesh() );
        // a listener set to smToListen will care of hypothesis stored in SMESH_EventListenerData
        subMesh->SetEventListener( new _EnforcedMeshRestorer(),
                                   SMESH_subMeshEventListenerData::MakeData( subMesh ),
                                   smToListen);
      }
    }
  }
}

//================================================================================
/*!
 * \brief Sets an event listener removing empty groups created due to "To make
 *        groups of domains".
 * \param subMesh - submesh where algo is set
 *
 * This method is called when a submesh gets HYP_OK algo_state.
 * After being set, event listener is notified on each event of a submesh.
 */
//================================================================================

void HYBRIDPlugin_HYBRID::SetEventListener(SMESH_subMesh* subMesh)
{
  subMesh->SetEventListener( new _GroupsOfDomainsRemover(), 0, subMesh );
}
