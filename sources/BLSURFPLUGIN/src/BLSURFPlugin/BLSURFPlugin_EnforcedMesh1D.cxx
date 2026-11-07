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
// File      : BLSURFPlugin_EnforcedMesh1D.cxx
// Author    : Edward AGAPOV (OCC)

#include "BLSURFPlugin_EnforcedMesh1D.hxx"

#include "BLSURFPlugin_BLSURF.hxx"

#include <SMDS_IteratorOnIterators.hxx>
#include <SMDS_MeshEdge.hxx>
#include <SMDS_MeshGroup.hxx>
#include <SMESHDS_Group.hxx>
#include <SMESHDS_Mesh.hxx>
#include <SMESH_Group.hxx>
#include <SMESH_Mesh.hxx>
#include <SMESH_MeshAlgos.hxx>
#include <SMESH_MeshEditor.hxx>
#include <SMESH_MesherHelper.hxx>
#include <SMESH_TypeDefs.hxx>

#include <BRepAdaptor_Curve.hxx>
#include <BRepBuilderAPI_MakeVertex.hxx>
#include <BRep_Tool.hxx>
#include <Extrema_ExtCC.hxx>
#include <Extrema_ExtElC.hxx>
#include <Geom_Line.hxx>
#include <ShapeAnalysis_Curve.hxx>
#include <Geom2d_Line.hxx>

// allow range iteration on NCollection_IndexedMap
template < class IMAP >
typename IMAP::const_iterator begin( const IMAP &  m ) { return m.cbegin(); }
template < class IMAP >
typename IMAP::const_iterator end( const IMAP &  m ) { return m.cend(); }


namespace
{
  //================================================================================
  /*!
   * \brief Look for a node coincident with a given nodes among end nodes of a segment
   *        and among its internal nodes
   *  \param [in] p - the epoint
   *  \param [in] tol - 3D tolarace
   *  \param [in] segment - the segment
   *  \param [in] segInternalNodes - map of segment internal nodes
   *  \param [out] index - return index of found internal node; -1 if an end node is found
   *  \return const SMDS_MeshNode* - found node
   */
  //================================================================================

  const SMDS_MeshNode* findNode( const gp_Pnt&                              p,
                                 const double                               tol,
                                 const SMDS_MeshElement*                    segment,
                                 BLSURFPlugin_EnforcedMesh1D::TNodesOnSeg & segInternalNodes,
                                 int &                                      index )
  {

    SMESH_NodeXYZ node0 = segment->GetNode(0);
    if ( p.IsEqual( node0, tol ))
      return index = -1, node0.Node();
    SMESH_NodeXYZ node1 = segment->GetNode(1);
    if ( p.IsEqual( node1, tol ))
      return index = -1, node1.Node();

    auto seg2nodes = segInternalNodes.find( segment );
    if ( seg2nodes != segInternalNodes.end() )
    {
      const std::vector< const SMDS_MeshNode* >& nodes = seg2nodes->second;
      for ( size_t i = 0; i < nodes.size(); ++i )
        if ( p.IsEqual( SMESH_NodeXYZ( nodes[i] ), tol ))
        {
          index = (int) i;
          return nodes[i];
        }
    }
    return nullptr;
  }

  //================================================================================
  /*!
   * \brief Orient segments to correspond to order of nodes in a branch
   *  \param [in] braSegs - segments of the branch
   *  \param [in] braNodes - nodes of the branch
   *  \param [in] nodeIndex - index of a node of the branch
   *  \param [inout] mesh - mesh holding the nodes and segments
   */
  //================================================================================

  void orientSegments( const std::vector< const SMDS_MeshElement* > & braSegs,
                       const std::vector< const SMDS_MeshNode* > &    braNodes,
                       const size_t                                   nodeIndex,
                       SMESH_Mesh*                                    mesh )
  {
    const SMDS_MeshElement* toReverse[2] = { nullptr, nullptr };

    if ( nodeIndex > 0 &&
         braSegs[ nodeIndex - 1 ]->GetNode(1) != braNodes[ nodeIndex ])
      toReverse[ 0 ] = braSegs[ nodeIndex - 1 ];
    
    if ( nodeIndex < braSegs.size() &&
         braSegs[ nodeIndex ]->GetNode(0) != braNodes[ nodeIndex ])
      toReverse[ bool( toReverse[0]) ] = braSegs[ nodeIndex ];

    if ( !toReverse[0] )
      return;

    SMESH_MeshEditor editor( mesh );
    for ( int i = 0; i < 2; ++i )
      if ( toReverse[ i ])
        editor.Reorient( toReverse[ i ]);
  }

} // namespace

//================================================================================
/*!
 * \brief Create enforced mesh segments in a mesh
 *  \param [in] helper - contains the mesh and the shape to compute
 *  \param [in] hyp - hypothesis containing data of enforced meshes
 */
//================================================================================

BLSURFPlugin_EnforcedMesh1D::BLSURFPlugin_EnforcedMesh1D( SMESH_MesherHelper&            helper,
                                                          const BLSURFPlugin_Hypothesis* hyp )
  : _mesh ( helper.GetMesh() ),
    _shape( helper.GetSubShape() ),
    _helper( *_mesh ),
    _isQuadratic( helper.GetIsQuadratic() ),
    _nodeTag0( 0 )
{
  if ( !hyp || !_mesh || hyp->GetEnforcedMeshes().empty() )
    return;

  _tol      = 2 * BRep_Tool::MaxTolerance( _shape, TopAbs_VERTEX );
  _segTag   = 1000 + helper.Count( _shape, TopAbs_EDGE, /*ignoreSame=*/false );
  _segTag0  = _segTag;
  _nodeTag0 = 1000 + helper.Count( _shape, TopAbs_VERTEX, /*ignoreSame=*/false );

  for ( const BLSURFPlugin_Hypothesis::EnforcedMesh& enfMesh : hyp->GetEnforcedMeshes() )
  {
    copyEnforcedMesh( enfMesh, hyp, _shape );
  }

  for ( const SMDS_MeshElement* segment : _segmentsOnSeveralShapes )
  {
    splitSegmentOnSeveralShapes( segment );
  }

  for ( const TopoDS_Shape & face : _faces )
  {
    splitSelfIntersectingSegments( face );
  }

  // for ( TEdge2Nodes::Iterator e2nn( _nodesOnEdge ); e2nn.More(); e2nn.Next() )
  // {
  //   splitEdgeByNodes( e2nn.Key(), e2nn.Value() );
  // }
}

//================================================================================
/*!
 * \brief Convert enforced segments to quadratic
 */
//================================================================================

BLSURFPlugin_EnforcedMesh1D::~BLSURFPlugin_EnforcedMesh1D()
{
  if ( !_isQuadratic )
    return;

  _helper.SetIsQuadratic( true );

  SMESHDS_Mesh* meshDS = _mesh->GetMeshDS();
  std::vector<const SMDS_MeshNode *>    nodes(2);
  std::vector<const SMDS_MeshElement *> trias;

  SMDS_MeshGroup* group = nullptr;
  if ( !_name2Group.empty() )
    group = _name2Group.begin()->second;

  for ( const TopoDS_Shape& f : _faces )
    if ( HasSegmentsOnFace( TopoDS::Face( f )))
      while ( _segIterator->more() )
      {
        const SMDS_MeshElement* segment = _segIterator->next();
        if ( segment->GetType() != SMDSAbs_Edge )
          break;

        nodes[0] = segment->GetNode(0);
        nodes[1] = segment->GetNode(1);
        if ( meshDS->GetElementsByNodes( nodes, trias, SMDSAbs_Face ))
        {
          if ( !group || !group->Contains( segment ))
          {
            SMDS_MeshGroup* otherGroup = nullptr;
            if ( _name2Group.size() > bool( group ))
              for ( auto & n2g : _name2Group )
                if ( n2g.second != group && n2g.second->Contains( segment ))
                {
                  otherGroup = n2g.second;
                  break;
                }
            group = otherGroup;
          }

          _helper.AddTLinks( static_cast< const SMDS_MeshFace* >( trias[0] ));

          meshDS->RemoveFreeElement( segment, meshDS->MeshElements( f ), /*fromGroup=*/false );

          SMDS_MeshElement* quadSegment = _helper.AddEdge( nodes[0], nodes[1],
                                                           /*id=*/0, /*force3d=*/false );
          if ( group && segment != quadSegment )
          {
            group->Remove( segment );
            group->Add( quadSegment );
          }
        }
      }
  return;
}

//================================================================================
/*!
 * \brief Add a vertex on EDGE
 */
//================================================================================

void BLSURFPlugin_EnforcedMesh1D::AddVertexOnEdge( const double* theXYZ )
{
  // setup predicates to find the supporting EDGE
  setupPredicates( _shape );

  SMESHDS_Mesh*         meshDS = _mesh->GetMeshDS();
  const SMDS_MeshNode* nodeOnE = meshDS->AddNode( theXYZ[0], theXYZ[1], theXYZ[2] );

  // check if enfNode is on VERTEX
  bool toRemove = true;
  TopoDS_Vertex vertex;
  TopoDS_Edge   edge;
  if ( _onVertexPredicate->IsSatisfy( nodeOnE, &vertex ))
  {
    toRemove = SMESH_Algo::VertexNode( vertex, meshDS );
    if ( !toRemove )
      meshDS->SetNodeOnVertex( nodeOnE, vertex );
  }
  // find the EDGE supporting theXYZ
  else if ( _onEdgePredicate->IsSatisfy( nodeOnE, &edge ))
  {
    gp_Pnt pnt( theXYZ[0], theXYZ[1], theXYZ[2] );
    toRemove = findNodeOnEdge( pnt, edge );
    if ( !toRemove )
      addNodeOnEdge( nodeOnE, edge );
  }

  if ( toRemove )
    meshDS->RemoveFreeNode( nodeOnE, /*submesh=*/nullptr, /*fromGroup=*/false );
}

//================================================================================
/*!
 * \brief Return EDGEs resulted from division of FACE boundary by enforced segments
 *        and enforced vertices
 *  \param [in] edge - possibly divided EDGE
 *  \param [out] splits - split EDGEs
 *  \return bool - true if the EDGE is split
 */
//================================================================================

bool BLSURFPlugin_EnforcedMesh1D::GetSplitsOfEdge( const TopoDS_Edge&           edge,
                                                   std::vector< TopoDS_Edge > & splits,
                                                   TopTools_IndexedMapOfShape & edgeTags )
{
  if ( _nodesOnEdge.IsBound( edge )) // divide the EDGE
  {
    splitEdgeByNodes( edge, _nodesOnEdge( edge ));

    _nodesOnEdge.UnBind( edge );
  }

  // return splits

  std::vector< TopoDS_Edge > * splitsInMap = _edgeSplitsOfEdge.ChangeSeek( edge );
  if ( !splitsInMap )
    return false;

  splits.insert( splits.end(), splitsInMap->begin(), splitsInMap->end() );

  int eTag = edgeTags.Add( edge );

  size_t index = splits.size() - 1;
  for ( size_t i = 0; i < splitsInMap->size(); ++i, --index )
  {
    int splitTag = edgeTags.Add( splits[ index ]);
    _splitTags2EdgeTag[ splitTag ] = eTag;

    if ( edge.Orientation() == TopAbs_REVERSED )
      splits[ index ].Reverse();
  }

  return true;
}


//================================================================================
/*!
 * \brief Add 1D elements to the mesh
 */
//================================================================================

void BLSURFPlugin_EnforcedMesh1D::

copyEnforcedMesh( const BLSURFPlugin_Hypothesis::EnforcedMesh& theEnfMesh,
                  const BLSURFPlugin_Hypothesis*               theHyp,
                  const TopoDS_Shape&                          theShape)
{
  SMESH_Mesh* mesh1D;
  SMDS_ElemIteratorPtr segIt = theHyp->GetEnforcedSegments( theEnfMesh, mesh1D );
  if ( !segIt->more() )
    throw SALOME_Exception("No edges in an enforced mesh");

  // setup predicates to detect nodes on FACE boundary
  setupPredicates( theShape );

  SMDS_MeshGroup* group = getGroup( theEnfMesh._groupName );
  SMESHDS_Mesh*  meshDS = _helper.GetMeshDS();

  // get ordered nodes and segments of theEnfMesh
  SMESH_MeshAlgos::TElemGroupVector edgeBranches;
  SMESH_MeshAlgos::TNodeGroupVector nodeBranches;
  SMESH_MeshAlgos::Get1DBranches( segIt, edgeBranches, nodeBranches );


  // Copy nodes and segments from an enforced mesh to my mesh

  TopoDS_Shape vertex, edge;

  // first treat ends of branches that can be shared by branches
  for ( size_t iB = 0; iB < nodeBranches.size(); ++iB )
  {
    std::vector< const SMDS_MeshNode* > &   braNodes = nodeBranches[ iB ];
    std::vector< const SMDS_MeshElement* > & braSegs = edgeBranches[ iB ];

    for ( int isLast = 0; isLast < 2; ++isLast )
    {
      const SMDS_MeshNode* enfNode = isLast ? braNodes.back() : braNodes[0];
      if ( meshDS->Contains( enfNode ))
        continue; // already in my mesh

      const SMDS_MeshNode* newNode = copyEnforcedNode( enfNode );
      if ( !newNode )
        orientSegments( braSegs, braNodes, isLast ? 0 : braNodes.size() - 1, mesh1D );

      // replace enfNode at branch ends by newNode
      SMESH_NodeXYZ enfPnt( newNode ? newNode : enfNode );
      for ( std::vector< const SMDS_MeshNode* > & braNodes : nodeBranches )
      {
        for ( int isLast = 0; isLast < 2; ++isLast )
        {
          const SMDS_MeshNode* & endNode = isLast ? braNodes.back() : braNodes[0];
          if ( endNode == enfNode || enfPnt.SquareDistance( endNode ) < _tol*_tol )
            endNode = newNode;
        }
      }
      continue;
    }  // loop on branch ends
  } // loop on nodeBranches

  // copy nodes and segments

  for ( size_t iB = 0; iB < nodeBranches.size(); ++iB )
  {
    std::vector< const SMDS_MeshNode* > &   braNodes = nodeBranches[ iB ];
    std::vector< const SMDS_MeshElement* > & braSegs = edgeBranches[ iB ];

    // copy nodes of the branch
    for ( size_t i = 0; i < braNodes.size(); ++i )
    {
      const SMDS_MeshNode* & enfNode = braNodes[ i ];
      const SMDS_MeshNode*   newNode = copyEnforcedNode( enfNode );

      if ( !newNode ) // orient segments to be able to get enforced not projected node
        orientSegments( braSegs, braNodes, i, mesh1D );

      enfNode = newNode;
    }

    // copy segments of the branch
    for ( size_t i = 0; i < braSegs.size(); ++i )
    {
      //braSegs[ i ] = nullptr;

      const SMDS_MeshNode* node0 = braNodes[ i     ];
      const SMDS_MeshNode* node1 = braNodes[ i + 1 ];
      if ( !node0 && !node1 )
        continue;

      TopoDS_Shape shape0 = _helper.GetSubShapeByNode( node0, meshDS );
      TopoDS_Shape shape1 = _helper.GetSubShapeByNode( node1, meshDS );
      if ( shape0.IsNull() && shape1.IsNull() )
        continue;

      if ( !node0 && shape1.ShapeType() != TopAbs_FACE )
        continue;
      if ( !node1 && shape0.ShapeType() != TopAbs_FACE )
        continue;

      if ( !node0 || !node1 ) // create missing node at location of enforced node projected nowhere
      {
        SMESH_NodeXYZ  pn = braSegs[i]->GetNode( !node1 );
        ( node0 ? node1 : node0 ) = _helper.AddNode( pn->X(), pn->Y(), pn->Z() );
      }

      SMDS_MeshEdge* newSeg = _helper.AddEdge( node0, node1 );
      if ( group )
        group->Add( newSeg );
      braSegs[ i ] = newSeg;

      // check if the both nodes are on the same FACE
      TopoDS_Shape face = shape0;
      if ( !shape0.IsSame( shape1 ) && !shape0.IsNull() && !shape1.IsNull() )
      {
        if ( shape0.ShapeType() == TopAbs_FACE &&
             _helper.IsSubShape( shape1, shape0 ))
        {
          face = shape0;
        }
        else if ( shape1.ShapeType() == TopAbs_FACE &&
                  _helper.IsSubShape( shape0, shape1 ))
        {
          face = shape1;
        }
        else // try to find a FACE by projecting a segment middle point
        {
          face.Nullify();
          gp_Pnt middlePnt = 0.5 * ( SMESH_NodeXYZ( node0 ) + SMESH_NodeXYZ( node1 ));
          //BLSURFPlugin_BLSURF::projectionPoint projPnt =
          BLSURFPlugin_BLSURF::getProjectionPoint( TopoDS::Face( face ), middlePnt );

          if ( !face.IsNull() &&
               ( !_helper.IsSubShape( shape0, face ) ||
                 !_helper.IsSubShape( shape1, face ) ))
            face.Nullify();
        }
      }
      if ( !face.IsNull() && face.ShapeType() == TopAbs_FACE )
      {
        meshDS->SetMeshElementOnShape( newSeg, face );
        _faces.Add( face );
      }

      if ( face.IsNull() || shape0.IsNull() || shape1.IsNull() )
      {
        _segmentsOnSeveralShapes.push_back( newSeg );
      }

    } // loop on branch segments
    continue;
  } // loop on branches

  return;
}

//================================================================================
/*!
 * \brief Create a copy of a node of enforced mesh in my mesh
 *  \param [in] enfNode - enforced node
 *  \return const SMDS_MeshNode* - a node in my mesh
 */
//================================================================================

const SMDS_MeshNode* BLSURFPlugin_EnforcedMesh1D::copyEnforcedNode( const SMDS_MeshNode* enfNode )
{
  SMESHDS_Mesh * meshDS = _helper.GetMeshDS();

  if ( !enfNode || meshDS->Contains( enfNode ))
    return enfNode; // already in my mesh

  SMESH_NodeXYZ enfPnt = enfNode;

  const SMDS_MeshNode* newNode = nullptr;

  // check if enfNode is on VERTEX
  TopoDS_Vertex vertex;
  if ( _onVertexPredicate->IsSatisfy( enfNode, &vertex ))
  {
    _mesh->GetSubMesh( vertex )->ComputeStateEngine( SMESH_subMesh::COMPUTE );
    newNode = SMESH_Algo::VertexNode( vertex, meshDS );
  }

  // check if enfNode is on EDGE
  bool setNodeOnEdge = false;
  TopoDS_Edge edge;
  if ( !newNode )
  {
    setNodeOnEdge = _onEdgePredicate->IsSatisfy( enfNode, &edge );
    if ( setNodeOnEdge )
    {
      newNode = findNodeOnEdge( enfPnt, edge );
      setNodeOnEdge = !newNode;
    }
  }

  // create a new node and set it on FACE
  if ( !newNode )
  {
    TopoDS_Face face;
    BLSURFPlugin_BLSURF::projectionPoint projPnt =
      BLSURFPlugin_BLSURF::getProjectionPoint( face, enfPnt, /*allowStateON=*/true );
    if ( face.IsNull() ) return newNode;

    if ( projPnt.state == TopAbs_ON )
    {
      SMDS_MeshNode* projNode = const_cast< SMDS_MeshNode* >( enfNode );
      projNode->setXYZ( projPnt.xyz.X(), projPnt.xyz.Y(), projPnt.xyz.Z() );
      vertex.Nullify();
      edge.Nullify();
      if ( _onVertexPredicate->IsSatisfy( projNode, &vertex ))
      {
        _mesh->GetSubMesh( vertex )->ComputeStateEngine( SMESH_subMesh::COMPUTE );
        newNode = SMESH_Algo::VertexNode( vertex, meshDS );
      }
      else if (( setNodeOnEdge = _onEdgePredicate->IsSatisfy( projNode, &edge )))
      {
        newNode = findNodeOnEdge( projPnt.xyz, edge );
        setNodeOnEdge = !newNode;
      }
      projNode->setXYZ( enfPnt.X(), enfPnt.Y(), enfPnt.Z() );
    }

    if ( !newNode )
      newNode = meshDS->AddNode( projPnt.xyz.X(), projPnt.xyz.Y(), projPnt.xyz.Z() );

    if ( vertex.IsNull() && edge.IsNull() )
      meshDS->SetNodeOnFace( newNode, face, projPnt.uv.X(), projPnt.uv.Y() );
  }

  // set the new node on EDGE
  if ( newNode && setNodeOnEdge )
  {
    addNodeOnEdge( newNode, edge );
  }

  return newNode;
}

//================================================================================
/*!
 * \brief Split a segment whose nodes are on different FACEs into smaller parts
 *        lying each on one FACE
 */
//================================================================================

void BLSURFPlugin_EnforcedMesh1D::splitSegmentOnSeveralShapes( const SMDS_MeshElement* segment )
{
  const SMDS_MeshNode* node0 = segment->GetNode(0);
  const SMDS_MeshNode* node1 = segment->GetNode(1);
  SMESHDS_Mesh * meshDS = _helper.GetMeshDS();

  TopoDS_Shape shape0 = _helper.GetSubShapeByNode( node0, meshDS );
  TopoDS_Shape shape1 = _helper.GetSubShapeByNode( node1, meshDS );

  if ( shape0.IsNull() )
  {
    std::swap( node0, node1 );
    shape0 = shape1;
    shape1.Nullify();
  }

  gp_XYZ   xyz0 = SMESH_NodeXYZ( node0 );
  gp_XYZ   xyz1 = SMESH_NodeXYZ( node1 );
  gp_XYZ segDir = ( xyz1 - xyz0 ).Normalized();

  //std::map< double, const SMDS_MeshNode* > mediumNodes; // nodes splitting the segment

  while ( !shape0.IsSame( shape1 )) // move along the segment till shape1
  {
    if ( shape0.ShapeType() == TopAbs_FACE ) // make a node on an EDGE of the FACE
    {                                        // ----------------------------------
      TopoDS_Edge edge;
      double paramOnE;
      gp_Pnt edgeIntPnt = getEdgeIntersection( shape0, xyz0, xyz1, edge, paramOnE );
      if ( edge.IsNull() )
        break;

      // check if edgeIntPnt in on VERTEX
      TopoDS_Vertex vertex;
      for ( int iV = 0; iV < 2 &&  vertex.IsNull(); ++iV )
      {
        TopoDS_Vertex v = _helper.IthVertex( iV, edge );
        if ( edgeIntPnt.SquareDistance( BRep_Tool::Pnt( v )) < _tol *_tol )
          vertex = v;
      }

      // make a node on the EDGE
      const SMDS_MeshNode* nodeOnEdge = nullptr;
      if ( vertex.IsNull() )
      {
        nodeOnEdge = findNodeOnEdge( edgeIntPnt, edge );
        if ( !nodeOnEdge )
        {
          if ( shape1.IsNull() && node1 )
          {
            nodeOnEdge = node1;
            node1      = nullptr;
            meshDS->MoveNode( nodeOnEdge, edgeIntPnt.X(), edgeIntPnt.Y(), edgeIntPnt.Z() );
          }
          else
          {
            nodeOnEdge = _helper.AddNode( edgeIntPnt.X(), edgeIntPnt.Y(), edgeIntPnt.Z() );
          }
          addNodeOnEdge( nodeOnEdge, edge, paramOnE );
        }
      }
      else
      {
        _mesh->GetSubMesh( vertex )->ComputeStateEngine( SMESH_subMesh::COMPUTE );
        nodeOnEdge = SMESH_Algo::VertexNode( vertex, meshDS );
      }

      // create a sub-segment
      SMDS_MeshElement* newSeg = _helper.AddEdge( node0, nodeOnEdge );
      meshDS->SetMeshElementOnShape( newSeg, shape0 );

      SMESH_MeshEditor::AddToSameGroups( newSeg, segment, meshDS );

      node0 = nodeOnEdge;
      xyz0  = SMESH_NodeXYZ( node0 );
      if ( vertex.IsNull() )
        shape0 = edge;
      else
        shape0 = vertex;
    }

    else // shape0 is EDGE or VERTEX; look for the next FACE
    {    // ------------------------------------------------

      if ( !shape1.IsNull() &&
           shape1.ShapeType() == TopAbs_FACE &&
           _helper.IsSubShape( shape0, shape1 )) // shape0 belongs to FACE shape1
      {
        SMDS_MeshElement* newSeg = _helper.AddEdge( node0, node1 );
        SMESH_MeshEditor::AddToSameGroups( newSeg, segment, meshDS );
        meshDS->SetMeshElementOnShape( newSeg, shape1 );
        break;
      }
      // FACE search
      TopoDS_Face face;
      double shift = 10 * _tol;
      for ( int nbAttemp = 0; face.IsNull() && nbAttemp < 10; ++nbAttemp )
      {
        xyz0  += segDir * shift;
        shift *= 2;
        BLSURFPlugin_BLSURF::getProjectionPoint( face, xyz0 );
      }
      if ( !face.IsNull() )
      {
        if ( _helper.IsSubShape( shape0, face ))
          _faces.Add( face );
        else
          break;
        shape0 = face;
      }
      else
      {
        break;
      }
    }
    continue;
  } //while ( !shape0.IsSame( shape1 ))

  meshDS->RemoveFreeElement( segment, /*submesh=*/nullptr );
}

//================================================================================
/*!
 * \brief Find intersection of FACE EDGEs and a segment
 *  \param [in] theFace - the FACE
 *  \param [in] thePnt0 - first end of the segment
 *  \param [in] thePnt1 - last end of the segment
 *  \param [out] theFounfEdge - return the intersected EDGE
 *  \param [out] theParamOnEdge - return parameter of intersection point on EDGE
 *  \return gp_XYZ - point on an EDGE closest to the segment
 */
//================================================================================

gp_Pnt BLSURFPlugin_EnforcedMesh1D::getEdgeIntersection( const TopoDS_Shape& theFaceOrEdge,
                                                         const gp_XYZ&       thePnt0,
                                                         const gp_XYZ&       thePnt1,
                                                         TopoDS_Edge &       theFounfEdge,
                                                         double &            theParamOnEdge)
{
  const double segLen = ( thePnt1 - thePnt0 ).Modulus();
  const double maxSegDist2 = segLen * segLen * 0.5 * 0.5;

  Handle(Geom_Line) segLine = new Geom_Line( thePnt0, thePnt1 - thePnt0 );
  GeomAdaptor_Curve segLineAdpt( segLine, 0, segLen );
  
  TopTools_MapOfShape edges;
  double minParamOnSeg = segLen;
  gp_Pnt foundPnt;
  for ( TopExp_Explorer edgeExp( theFaceOrEdge, TopAbs_EDGE ); edgeExp.More(); edgeExp.Next() )
  {
    const TopoDS_Edge& edge = TopoDS::Edge( edgeExp.Current() );
    if ( !edges.Add( edge ))
      continue;

    Extrema_ExtCC extrema( segLineAdpt, BRepAdaptor_Curve( edge ), _tol, _tol );

    if ( extrema.IsDone() && !extrema.IsParallel() )
      for ( int i = 1, nb = extrema.NbExt(); i <= nb; ++i )
        if ( extrema.SquareDistance( i ) < maxSegDist2 )
        {
          Extrema_POnCurv pOnSeg, pOnEdge;
          extrema.Points( i, pOnSeg, pOnEdge );
          double paramOnSeg = pOnSeg.Parameter();
          if ( 0 < paramOnSeg && paramOnSeg < minParamOnSeg )
          {
            minParamOnSeg = paramOnSeg;
            foundPnt = pOnEdge.Value();
            theFounfEdge = edge;
            theParamOnEdge = pOnEdge.Parameter();
          }
        }
  }
  return foundPnt;
}

//================================================================================
/*!
 * \brief Split self-intersecting segments on a given FACE
 */
//================================================================================

void BLSURFPlugin_EnforcedMesh1D::splitSelfIntersectingSegments( const TopoDS_Shape & theFace )
{
  const TopoDS_Face& face = TopoDS::Face( theFace );

  SMESHDS_Mesh* meshDS = _helper.GetMeshDS();
  SMESHDS_SubMesh*  sm = meshDS->MeshElements( face );
  if ( !sm || sm->NbElements() <= 1 )
    return;

  // get ordered nodes and segments on the face
  SMESH_MeshAlgos::TElemGroupVector edgeBranches;
  SMESH_MeshAlgos::TNodeGroupVector nodeBranches;
  SMESH_MeshAlgos::Get1DBranches( sm->GetElements(), edgeBranches, nodeBranches );

  // create element searcher
  SMESH_ElementSearcher*                       elemSearcher;
  SMESHUtils::Deleter< SMESH_ElementSearcher > elSearchdeleter;
  std::vector< const SMDS_MeshElement* >       foundElems;
  {
    std::vector< SMDS_ElemIteratorPtr > elemItVec;
    for ( std::vector< const SMDS_MeshElement* > & braSegs : edgeBranches )
    {
      SMDS_ElemIteratorPtr segIt =
        boost::make_shared< SMDS_ElementVectorIterator >( braSegs.begin(), braSegs.end() );
      elemItVec.push_back( segIt );
    }
    typedef SMDS_IteratorOnIterators< const SMDS_MeshElement*,
                                      std::vector< SMDS_ElemIteratorPtr > > TVecIterator;
    SMDS_ElemIteratorPtr segIt = boost::make_shared< TVecIterator >( elemItVec );

    elemSearcher = SMESH_MeshAlgos::GetElementSearcher( *meshDS, segIt, _tol );
    elSearchdeleter._obj = elemSearcher;

    // force usage of iterators before they die
    elemSearcher->FindElementsByPoint( gp_Pnt( 0,0,1e+20), SMDSAbs_Edge, foundElems );
  }


  // Find intersecting segments

  std::map< const SMDS_MeshElement* , std::vector< const SMDS_MeshNode* > > segInternalNodes;
  SMESH_MeshEditor::TListOfListOfNodes nodeGroupsToMerge;

  for ( std::vector< const SMDS_MeshElement* > & braSegs : edgeBranches )
  {
    braSegs.push_back( braSegs.back() );
    const SMDS_MeshElement* prevSeg = nullptr;

    for ( size_t i = 0, nb = braSegs.size() - 1;  i < nb;  ++i )
    {
      const SMDS_MeshElement*     seg = braSegs[ i ];
      const SMDS_MeshElement* nextSeg = braSegs[ i + 1 ];
      const SMDS_MeshNode*      node0 = seg->GetNode(0);
      const SMDS_MeshNode*      node1 = seg->GetNode(1);

      gp_XYZ      xyz0 = SMESH_NodeXYZ( node0 );
      gp_XYZ      xyz1 = SMESH_NodeXYZ( node1 );
      gp_XYZ middlePnt = 0.5 * ( SMESH_NodeXYZ( node0 ) + SMESH_NodeXYZ( node1 ));
      double    segLen = ( xyz0 - xyz1 ).Modulus();

      foundElems.clear();
      elemSearcher->GetElementsInSphere( middlePnt, 0.5 * segLen + _tol, SMDSAbs_Edge, foundElems );

      for ( const SMDS_MeshElement* closeSeg : foundElems )
      {
        if ( closeSeg == prevSeg ||
             closeSeg >= seg     ||
             closeSeg == nextSeg )
          continue;

        gp_Pnt   intPnt;
        gp_Pnt2d uv;
        if ( intersectSegments( seg, closeSeg, face, intPnt, uv ))
        {
          int i0, i1;
          const SMDS_MeshNode* intNode0 = findNode( intPnt, _tol, seg,      segInternalNodes, i0 );
          const SMDS_MeshNode* intNode1 = findNode( intPnt, _tol, closeSeg, segInternalNodes, i1 );
          if      ( !intNode0 && intNode1 )
          {
            segInternalNodes[ seg ].push_back( intNode1 );
          }
          else if ( !intNode1 && intNode0 )
          {
            segInternalNodes[ closeSeg ].push_back( intNode0 );
          }
          else if ( intNode1 && intNode0 )
          {
            if ( intNode1 == intNode0 )
              continue;
            if ( i0 < 0 && i1 < 0 )
            {
              nodeGroupsToMerge.push_back  // merge end nodes
                ( std::list< const SMDS_MeshNode* >({ intNode0, intNode1 }));
            }
            else if ( i0 < 0 )
            {
              segInternalNodes[ closeSeg ][ i1 ] = intNode0;
            }
            else if ( i1 < 0 )
            {
              segInternalNodes[ seg ][ i0 ] = intNode1;
            }
            else // two internal nodes coincide
            {
              segInternalNodes[ seg ][ i0 ] = intNode1;
              nodeGroupsToMerge.push_back
                ( std::list< const SMDS_MeshNode* >({ intNode1, intNode0 }));
            }
          }
          else // ( !intNode1 && !intNode0 )
          {
            intNode0 = _helper.AddNode( intPnt.X(), intPnt.Y(), intPnt.Z() );
            meshDS->SetNodeOnFace( intNode0, face, uv.X(), uv.Y() );
            segInternalNodes[ seg      ].push_back( intNode0 );
            segInternalNodes[ closeSeg ].push_back( intNode0 );
          }
        }
      }

      prevSeg = seg;

    } // loop on segments of a branch
  } // loop on branches


  findIntersectionWithSeamEdge( face, segInternalNodes ); // on periodic FACE


  // Split segments

  for ( auto& seg2nodes : segInternalNodes )
  {
    const SMDS_MeshElement*                 seg = seg2nodes.first;
    std::vector< const SMDS_MeshNode* > & nodes = seg2nodes.second;
    if ( nodes.empty() ) continue;

    const SMDS_MeshNode* n0 = seg->GetNode( 0 );
    const SMDS_MeshNode* n1 = seg->GetNode( 1 );
    nodes.push_back( n1 );

    // sort nodes on the segment
    gp_Pnt p0 = SMESH_NodeXYZ( n0 );
    std::map< double, const SMDS_MeshNode* > sortedNodes;
    for ( SMESH_NodeXYZ pn : nodes )
      sortedNodes.insert({ p0.SquareDistance( pn ), pn.Node() });

    // make new segments
    for ( auto & d2n : sortedNodes )
    {
      n1 = d2n.second;
      SMDS_MeshElement* newSeg = _helper.AddEdge( n0, n1 );
      n0 = n1;
      meshDS->SetMeshElementOnShape( newSeg, face );
      SMESH_MeshEditor::AddToSameGroups( newSeg, seg, meshDS );
    }
    meshDS->RemoveFreeElement( seg, /*submesh=*/nullptr );
  }


  // merge equal nodes
  SMESH_MeshEditor( _mesh ).MergeNodes( nodeGroupsToMerge );
}

//================================================================================
/*!
 * \brief Find intersections of segments with a seam EDGE on a periodic FACE
 */
//================================================================================

void BLSURFPlugin_EnforcedMesh1D::findIntersectionWithSeamEdge( const TopoDS_Face & face,
                                                                TNodesOnSeg & segInternalNodes )
{
  _helper.SetSubShape( face );
  if ( !_helper.HasSeam() )
    return;

  SMESHDS_Mesh* meshDS = _helper.GetMeshDS();
  SMESHDS_SubMesh*  sm = meshDS->MeshElements( face );
  if ( !sm || sm->NbElements() == 0 )
    return;

  TopTools_MapOfShape treatedEdges;
  for ( TopExp_Explorer edgeExp( face, TopAbs_EDGE ); edgeExp.More(); edgeExp.Next() )
  {
    const TopoDS_Edge& edge = TopoDS::Edge( edgeExp.Current() );
    if ( !_helper.IsSeamShape( edge ) || !treatedEdges.Add( edge ))
      continue;

    for ( SMDS_ElemIteratorPtr setIt = sm->GetElements(); setIt->more(); )
    {
      const SMDS_MeshElement* segment = setIt->next();
      const SMESH_NodeXYZ         pn0 = segment->GetNode( 0 );
      const SMESH_NodeXYZ         pn1 = segment->GetNode( 1 );

      gp_XY uv0 = _helper.GetNodeUV( face, pn0.Node() );
      gp_XY uv1 = _helper.GetNodeUV( face, pn1.Node() );

      for ( int iCoo = 1; iCoo <= 2; ++iCoo )
        if ( iCoo & _helper.GetPeriodicIndex() )
        {
          double distParam = Abs( uv0.Coord( iCoo ) - uv1.Coord( iCoo ));
          if ( distParam > 0.5 * _helper.GetPeriod( iCoo ))
          {
            double paramOnE; TopoDS_Edge edge2;
            gp_Pnt edgeIntPnt = getEdgeIntersection( edge, pn0, pn1, edge2, paramOnE );
            if ( edge2.IsNull() )
              continue;

            const SMDS_MeshNode* nodeOnSeam = findNodeOnEdge( edgeIntPnt, edge );
            bool isOnEdge = nodeOnSeam;

            int indexOnSegment = 3;
            if ( !nodeOnSeam )
              nodeOnSeam = findNode( edgeIntPnt, _tol, segment, segInternalNodes, indexOnSegment );

            if ( !nodeOnSeam )
            {
              nodeOnSeam = _helper.AddNode( edgeIntPnt.X(), edgeIntPnt.Y(), edgeIntPnt.Z() );
            }

            if ( !isOnEdge )
            {
              addNodeOnEdge( nodeOnSeam, edge, paramOnE );
            }
            if ( indexOnSegment == 3 )
              segInternalNodes[ segment ].push_back( nodeOnSeam );
          }
        }
    }
  }
}

//================================================================================
/*!
 * \brief Intersect two segments
 *  \param [in] seg1 - segment 1
 *  \param [in] seg2 - segment 2
 *  \param [in] face - the FACE on which segments lie
 *  \param [out] intPnt - intersection point
 *  \param [out] intUV - UV of intersection point on the FACE
 *  \return bool - true if intersection found
 */
//================================================================================

bool BLSURFPlugin_EnforcedMesh1D::intersectSegments( const SMDS_MeshElement* seg1,
                                                     const SMDS_MeshElement* seg2,
                                                     const TopoDS_Face&      face,
                                                     gp_Pnt &                intPnt,
                                                     gp_Pnt2d &              intUV ) const
{
  SMESH_NodeXYZ n10 = seg1->GetNode(0);
  SMESH_NodeXYZ n11 = seg1->GetNode(1);
  SMESH_NodeXYZ n20 = seg2->GetNode(0);
  SMESH_NodeXYZ n21 = seg2->GetNode(1);
  if ( n10 == n20 || n10 == n21 || n11 == n20 || n10 == n21 )
    return false;

  gp_Lin lin1( n10, n11 - n10 );
  gp_Lin lin2( n20, n21 - n20 );

  Extrema_ExtElC extrema( lin1, lin2, Precision::Angular() );

  if ( !extrema.IsDone() || extrema.IsParallel() )
    return false;

  Extrema_POnCurv poc1, poc2;
  extrema.Points( 1, poc1, poc2 );

  double len1 = lin1.Direction().XYZ() * ( n11 - n10 );
  double len2 = lin2.Direction().XYZ() * ( n21 - n20 );
  double   u1 = poc1.Parameter();
  double   u2 = poc2.Parameter();

  if ( u1 < -_tol || u1 > len1 + _tol )
    return false;
  if ( u2 < -_tol || u2 > len2 + _tol )
    return false;

  intPnt = 0.5 * ( poc1.Value().XYZ() + poc2.Value().XYZ() );

  // compute approximate UV

  u1 /= len1;
  u2 /= len2;

  gp_XY uv10 = _helper.GetNodeUV( face, n10.Node(), n11.Node() );
  gp_XY uv11 = _helper.GetNodeUV( face, n11.Node(), n10.Node() );
  gp_XY uv1  = uv10 * ( 1 - u1 ) + uv11 * u1;

  gp_XY uv20 = _helper.GetNodeUV( face, n20.Node(), n21.Node() );
  gp_XY uv21 = _helper.GetNodeUV( face, n21.Node(), n20.Node() );
  gp_XY uv2  = uv20 * ( 1 - u2 ) + uv21 * u2;

  intUV = 0.5 * ( uv1 + uv2 );

  // compute precise UV and XYZ by projecting intPnt to the FACE

  Handle(ShapeAnalysis_Surface) surface = _helper.GetSurface( face );
  intUV = surface->NextValueOfUV( intUV, intPnt, _tol );
  if ( surface->Gap() > Min( len1, len2 ))
    intUV = surface->ValueOfUV( intPnt, _tol );

  intPnt = surface->Value( intUV );

  return true;
}

//================================================================================
/*!
 * \brief Setup predicates to detect nodes on FACE boundary
 *  \param [in] shape - shape containing FACEs to mesh
 */
//================================================================================

void BLSURFPlugin_EnforcedMesh1D::setupPredicates( const TopoDS_Shape& theShape )
{
  if ( _onVertexPredicate )
    return;

  _onVertexPredicate.reset( new TPredicate() );
  _onVertexPredicate->SetTolerance( _tol );
  _onVertexPredicate->SetMesh( _helper.GetMeshDS() );
  {
    TopTools_IndexedMapOfShape vertices;
    TopExp::MapShapes( theShape, TopAbs_VERTEX, vertices );
    TopoDS_Compound vCompound;
    BRep_Builder    builder;
    builder.MakeCompound( vCompound );
    for ( const TopoDS_Shape& v : vertices )
      builder.Add( vCompound, v );

    _onVertexPredicate->SetShape( vCompound, SMDSAbs_Node );
  }


  _onEdgePredicate.reset( new TPredicate() );
  _onEdgePredicate->SetTolerance( _tol );
  _onEdgePredicate->SetMesh( _helper.GetMeshDS() );
  {
    TopTools_IndexedMapOfShape edges;
    TopExp::MapShapes( theShape, TopAbs_EDGE, edges );
    TopoDS_Compound eCompound;
    BRep_Builder    builder;
    builder.MakeCompound( eCompound );
    for ( const TopoDS_Shape& e : edges )
      builder.Add( eCompound, e );

    _onEdgePredicate->SetShape( eCompound, SMDSAbs_Node );
  }
  return;
}

//================================================================================
/*!
 * \brief Find or create a group of edges with given name
 */
//================================================================================

SMDS_MeshGroup* BLSURFPlugin_EnforcedMesh1D::getGroup( const std::string& groupName )
{
  SMDS_MeshGroup* group = nullptr;
  if ( !groupName.empty() )
  {
    if ( _name2Group.count( groupName ))
      return _name2Group[ groupName ];

    // find existing group
    for ( SMESH_Mesh::GroupIteratorPtr grIt = _mesh->GetGroups(); grIt->more(); )
    {
      SMESH_Group*     grp = grIt->next();
      SMESHDS_Group* grpDS = dynamic_cast< SMESHDS_Group* >( grp->GetGroupDS() );
      if ( grpDS &&
           grpDS->GetType() == SMDSAbs_Edge &&
           groupName == grp->GetName() )
      {
        _name2Group[ groupName ] = & grpDS->SMDSGroup();
        return & grpDS->SMDSGroup();
      }
    }

    // create a new group
    SMESH_Group*     grp = _mesh->AddGroup( SMDSAbs_Edge, groupName.c_str() );
    SMESHDS_Group* grpDS = static_cast< SMESHDS_Group* >( grp->GetGroupDS() );

    group = & grpDS->SMDSGroup();
    _name2Group[ groupName ] = group;
  }
  return group;
}

//================================================================================
/*!
 * \brief Look for a node dividing a given EDGE
 */
//================================================================================

const SMDS_MeshNode* BLSURFPlugin_EnforcedMesh1D::findNodeOnEdge( const gp_Pnt&      p,
                                                                  const TopoDS_Edge& edge )
{
  // look for an equal node on the EDGE
  if ( std::vector< const SMDS_MeshNode* >* nodesOnE = _nodesOnEdge.ChangeSeek( edge ))
    for ( const SMDS_MeshNode* n : *nodesOnE )
      if ( p.SquareDistance( SMESH_NodeXYZ( n )) < _tol * _tol )
      {
        return n;
      }

  return nullptr;
}

//================================================================================
/*!
 * \brief Add a node to an EDGE
 */
//================================================================================

void BLSURFPlugin_EnforcedMesh1D::addNodeOnEdge( const SMDS_MeshNode* node,
                                                 const TopoDS_Edge&   edge,
                                                 const double         u)
{
  _mesh->GetMeshDS()->SetNodeOnEdge( node, edge, u );

  std::vector< const SMDS_MeshNode* > * nodesOnE = _nodesOnEdge.ChangeSeek( edge );
  if ( !nodesOnE )
    nodesOnE = _nodesOnEdge.Bound( edge, std::vector< const SMDS_MeshNode* >() );

  nodesOnE->push_back( node );
}

//================================================================================
/*!
 * \brief Create EDGEs by dividing a given EDGE by nodes on it
 *  \param [in] edge - the EDGE to divide
 *  \param [in] nodes - the nodes to divide by
 */
//================================================================================

void BLSURFPlugin_EnforcedMesh1D::

splitEdgeByNodes( TopoDS_Edge edge, const std::vector< const SMDS_MeshNode* >& nodes )
{
  if ( nodes.empty() )
    return;

  edge.Orientation( TopAbs_FORWARD );

  TopoDS_Vertex v0 = _helper.IthVertex( 0, edge );
  TopoDS_Vertex v1 = _helper.IthVertex( 1, edge );

  // create VERTEXes and sort them along the EDGE

  std::map< double, TopoDS_Vertex > sortedVertices;

  BRepAdaptor_Curve curve( edge );
  for ( SMESH_NodeXYZ pn : nodes )
  {
    gp_Pnt projPnt;
    double u;
    ShapeAnalysis_Curve().Project( curve, pn, _tol, projPnt, u, false );
    projPnt = curve.Value( u );

    TopoDS_Vertex v = BRepBuilderAPI_MakeVertex( projPnt );

    sortedVertices.insert({ u, v });

    _nOnE2Vertex[ pn.Node() ] = v;
  }
  sortedVertices.insert({ BRep_Tool::Parameter( v1, edge ), v1 });


  // create EDGEs

  BRep_Builder builder;
  std::vector< TopoDS_Edge >& newEdges = *_edgeSplitsOfEdge.Bound( edge, TEdge2Edges::value_type());

  double u0 = BRep_Tool::Parameter( v0, edge );
  for ( auto& u2v : sortedVertices )
  {
    double u1 = u2v.first;
    v1        = u2v.second;

    TopoDS_Shape newShape = edge.EmptyCopied();
    TopoDS_Edge  newEdge  = TopoDS::Edge( newShape );
    builder.Add( newEdge, v0 );
    builder.Add( newEdge, v1 );
    builder.Range( newEdge, u0, u1 );
    newEdges.push_back( newEdge );

    v0 = v1;
    u0 = u1;
  }

  return;
}

//================================================================================
/*!
 * \brief  Return true if there are enforced segments on a FACE. Start iteration on segments
 */
//================================================================================

bool BLSURFPlugin_EnforcedMesh1D::HasSegmentsOnFace( const TopoDS_Face& face )
{
  _segIterator.reset();

  if ( _faces.Contains( face ))
  {
    _currentFace = face;
    _segIterator = _helper.GetMeshDS()->MeshElements( face )->GetElements();

    _helper.SetSubShape( face );

    return _segIterator->more();
  }
  return false;
}


//================================================================================
/*!
 * \brief Return next segment on the FACE
 */
//================================================================================

bool BLSURFPlugin_EnforcedMesh1D::NextSegment( Segmemnt &                   seg,
                                               TopTools_IndexedMapOfShape & vertexTags )
{
  if ( _segIterator && _segIterator->more() )
  {
    const SMDS_MeshElement* segment = _segIterator->next();

    while ( segment->GetType() != SMDSAbs_Edge && _segIterator->more() )
      segment = _segIterator->next();
    if ( segment->GetType() != SMDSAbs_Edge )
      return false;

    const SMDS_MeshNode * node[2] = { segment->GetNode(0),
                                      segment->GetNode(1) };

    seg._tag = _segTag++;

    seg._xyz[0] = SMESH_NodeXYZ( node[0]);
    seg._xyz[1] = SMESH_NodeXYZ( node[1]);

    seg._uv[0] = _helper.GetNodeUV( _currentFace, node[0], node[1] );
    seg._uv[1] = _helper.GetNodeUV( _currentFace, node[1], node[0] );

    seg._pcurve = new Geom2d_Line( seg._uv[0], ( seg._uv[1] - seg._uv[0] ));

    seg._u[0] = 0.0;
    seg._u[1] = ( seg._uv[1] - seg._uv[0] ).Modulus();

    for ( int i = 0; i < 2; ++i )
    {
      auto n2v = _nOnE2Vertex.find( node[i] ); // find VERTEX by node

      if ( n2v != _nOnE2Vertex.end() )
        seg._vTag[i] = vertexTags.Add( n2v->second );
      else
        seg._vTag[i] = _nodeTag0 + _nodeTags.Add( node[i] );
    }

    if ( !_isQuadratic )
      _mesh->GetMeshDS()->UnSetMeshElementOnShape( segment, _currentFace );

    return true;
  }
  return false;
}

//================================================================================
/*!
 * \brief Return enforced node by the tag that was returned by Segmemnt::_vTag[i]
 */
//================================================================================

const SMDS_MeshNode*
BLSURFPlugin_EnforcedMesh1D::GetNodeByTag( int                                tag,
                                           const TopTools_IndexedMapOfShape & vertexTags )
{
  const SMDS_MeshNode* node = nullptr;

  if ( tag <= vertexTags.Size() && !_nOnE2Vertex.empty() )
  {
    const TopoDS_Shape& vertex = vertexTags( tag );

    for ( auto n2v = _nOnE2Vertex.begin(); n2v != _nOnE2Vertex.end(); ++n2v )
      if ( vertex.IsSame( n2v->second ))
      {
        node = n2v->first;
        _nOnE2Vertex.erase( n2v );
        return node;
      }
  }

  tag -= _nodeTag0;

  bool isValid = ( 0 < tag && tag <= _nodeTags.Size() );
  if ( isValid )
    node = _nodeTags( tag );

  return node;
}

//================================================================================
/*!
 * \brief Return true if a tag corresponds to the tag of enforced segment
 *  that was returned by Segment::_tag
 */
//================================================================================

bool BLSURFPlugin_EnforcedMesh1D::IsSegmentTag( int tag ) const
{
  return ( _segTag0 <= tag && tag <= _segTag );
}

//================================================================================
/*!
 * \brief Return tag of EDGE by tags of its splits
 */
//================================================================================

int BLSURFPlugin_EnforcedMesh1D::GetTagOfSplitEdge( int splitTag ) const
{
  auto sTag2eTag = _splitTags2EdgeTag.find( splitTag );
  return ( sTag2eTag == _splitTags2EdgeTag.end() ) ? splitTag : sTag2eTag->second;
}
