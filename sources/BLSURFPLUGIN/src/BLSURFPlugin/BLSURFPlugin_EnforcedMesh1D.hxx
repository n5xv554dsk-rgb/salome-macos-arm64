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
// File      : BLSURFPlugin_EnforcedMesh1D.hxx
// Author    : Edward AGAPOV (OCC)

#ifndef __BLSURFPlugin_EnforcedMesh1D_HXX__
#define __BLSURFPlugin_EnforcedMesh1D_HXX__

#include "BLSURFPlugin_Hypothesis.hxx"

#include <SMESH_ControlsDef.hxx>
#include <SMESH_MesherHelper.hxx>

#include <Geom2d_Curve.hxx>
#include <NCollection_DataMap.hxx>
#include <NCollection_IndexedMap.hxx>
#include <TopTools_IndexedMapOfShape.hxx>
#include <TopoDS_Edge.hxx>
#include <TopoDS_Face.hxx>
#include <TopoDS_Vertex.hxx>
#include <gp_Pnt.hxx>
#include <gp_Pnt2d.hxx>

#include <vector>
#include <map>

class SMDS_MeshElement;
class SMDS_MeshGroup;
class SMDS_MeshNode;
class SMESH_Mesh;

/*!
 * \brief Implement 1D mesh into the mesh made by MG-CADSurf
 */
class BLSURFPlugin_EnforcedMesh1D
{
public:

  BLSURFPlugin_EnforcedMesh1D( SMESH_MesherHelper&            helper,
                               const BLSURFPlugin_Hypothesis* hyp );

  ~BLSURFPlugin_EnforcedMesh1D();

  // Add a vertex on EDGE
  void AddVertexOnEdge( const double* xyz );

  // Return EDGEs resulted from division of FACE boundary by enforced segments
  bool GetSplitsOfEdge( const TopoDS_Edge&           edge,
                        std::vector< TopoDS_Edge > & splits,
                        TopTools_IndexedMapOfShape & edgeTags );

  // Return true if there are enforced segments on a FACE. Start iteration on segments
  bool HasSegmentsOnFace( const TopoDS_Face& face );

  // Data of an enforced segment to provide MG-CADSurf with
  struct Segmemnt
  {
    int                  _tag;
    Handle(Geom2d_Curve) _pcurve;

    // data of two ends
    double               _u   [2];
    gp_XY                _uv  [2];
    gp_XYZ               _xyz [2];
    int                  _vTag[2];
  };

  // Return next segment on the FACE. Iteration starts upon calling HasSegmentsOnFace() 
  bool NextSegment( Segmemnt & seg, TopTools_IndexedMapOfShape & vertexTags );

  // Return enforced node by tag
  const SMDS_MeshNode* GetNodeByTag( int tag, const TopTools_IndexedMapOfShape & vertexTags );

  // Return true if a tad corresponds to an enforced segment
  bool IsSegmentTag( int tag ) const;

  // Return tag of EDGE by tags of its splits
  int GetTagOfSplitEdge( int splitTag ) const;

  typedef std::map< const SMDS_MeshElement* , std::vector< const SMDS_MeshNode* > > TNodesOnSeg;

private:

  void copyEnforcedMesh( const BLSURFPlugin_Hypothesis::EnforcedMesh& theEnfMesh,
                         const BLSURFPlugin_Hypothesis*               theHyp,
                         const TopoDS_Shape&                          theShape);

  const SMDS_MeshNode* copyEnforcedNode( const SMDS_MeshNode* enfNode );

  void setupPredicates( const TopoDS_Shape& shape );

  void splitSegmentOnSeveralShapes( const SMDS_MeshElement* segment );

  void splitSelfIntersectingSegments( const TopoDS_Shape & face );

  void findIntersectionWithSeamEdge( const TopoDS_Face & face, TNodesOnSeg & segInternalNodes );

  bool intersectSegments( const SMDS_MeshElement* seg1, const SMDS_MeshElement* seg2,
                          const TopoDS_Face& face, gp_Pnt& intPnt, gp_Pnt2d& inUV ) const;

  gp_Pnt getEdgeIntersection( const TopoDS_Shape& faceOrEdge,
                              const gp_XYZ& xyz0, const gp_XYZ& xyz1,
                              TopoDS_Edge & edge, double & paramOnEdge );

  void splitEdgeByNodes( TopoDS_Edge edge, const std::vector< const SMDS_MeshNode* >& nodes);

  SMDS_MeshGroup* getGroup( const std::string& groupName );

  const SMDS_MeshNode* findNodeOnEdge( const gp_Pnt& p, const TopoDS_Edge& edge );
  void addNodeOnEdge( const SMDS_MeshNode*node , const TopoDS_Edge& edge, const double u = 0. );


  SMESH_Mesh*                              _mesh;
  TopoDS_Shape                             _shape;
  SMESH_MesherHelper                       _helper;
  bool                                     _isQuadratic;
  std::map< std::string, SMDS_MeshGroup* > _name2Group;
  double                                   _tol;
  TopTools_IndexedMapOfShape               _faces;

  // segments whose nodes are on different FACEs;
  // such segments will be split into segments lying each on own FACE
  std::vector< const SMDS_MeshElement* >   _segmentsOnSeveralShapes;

  // nodes projected on EDGEs; EDGEs will be divided by them
  typedef NCollection_DataMap< TopoDS_Edge,
                               std::vector< const SMDS_MeshNode* >,
                               TopTools_ShapeMapHasher>              TEdge2Nodes;
  typedef NCollection_DataMap< TopoDS_Edge,
                               std::vector< TopoDS_Edge >,
                               TopTools_ShapeMapHasher>              TEdge2Edges;
  TEdge2Nodes                               _nodesOnEdge;
  TEdge2Edges                               _edgeSplitsOfEdge; // result of EDGE division by nodes
  std::map< int, int >                      _splitTags2EdgeTag;
  std::map< const SMDS_MeshNode* , TopoDS_Vertex > _nOnE2Vertex; // VERTEXes on _nodesOnEdge

  typedef SMESH::Controls::ElementsOnShape    TPredicate;
  typedef SMESH::Controls::ElementsOnShapePtr TPredicatePtr;
  TPredicatePtr                             _onVertexPredicate;
  TPredicatePtr                             _onEdgePredicate;

  // for iteration of segments of FACE

  SMDS_ElemIteratorPtr                      _segIterator;
  TopoDS_Face                               _currentFace;
  int                                       _segTag0;
  int                                       _segTag;

  typedef NCollection_IndexedMap< const SMDS_MeshNode* > TNodeIndMap;
  TNodeIndMap                               _nodeTags;
  int                                       _nodeTag0;

  // nodes not projected to geometry; they are reused during next projection to geometry
  std::vector< const SMDS_MeshNode* >       _freeNodes;

};


#endif
