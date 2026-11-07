// Copyright (C) 2004-2026  CEA, EDF
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

#include "MG_HYBRID_API.hxx"

#include <SMESH_Comment.hxx>
#include <SMESH_File.hxx>
#include <SMESH_MGLicenseKeyGen.hxx>
#include <Utils_SALOME_Exception.hxx>
#include "utilities.h"

#include <cstring>
#include <iostream>
#include <iterator>
#include <vector>
#include <sstream>

#ifdef USE_MG_LIBS

extern "C"{
#include <meshgems/meshgems.h>
#include <meshgems/hybrid.h>
}

struct MG_HYBRID_API::LibData
{
  // MG objects
  context_t *       _context;
  hybrid_session_t *_session;
  mesh_t *          _surf_mesh;
  sizemap_t *       _sizemap;
  mesh_t *          _hybrid_mesh;

  // data to pass to MG
  std::vector<double> _xyz;
  std::vector<double> _nodeSize; // required nodes
  std::vector<int>    _edgeNodesTags;
  int                 _nbRequiredEdges;
  std::vector<int>    _triaNodesTags;
  int                 _nbRequiredTria;
  std::vector<int>    _quadNodes;
  std::vector<int>    _corners;

  int                 _count;
  volatile bool&      _cancelled_flag;
  std::string         _errorStr;

  double&             _progress;
  double              _msgCost;

  LibData( volatile bool & cancelled_flag, double& progress )
    : _context(0), _session(0), _surf_mesh(0), _sizemap(0), _hybrid_mesh(0),
      _nbRequiredEdges(0), _nbRequiredTria(0),
      _cancelled_flag( cancelled_flag ), _progress( progress ), _msgCost( 0.00015 )
  {
  }
  // methods setting callbacks implemented after callback definitions
  void Init();
  bool Compute();

  ~LibData()
  {
    if ( _hybrid_mesh )
      hybrid_regain_mesh( _session, _hybrid_mesh );
    if ( _session )
      hybrid_session_delete( _session );
    if ( _surf_mesh )
      mesh_delete( _surf_mesh );
    if ( _sizemap )
      sizemap_delete( _sizemap );
    if ( _context )
      context_delete( _context );

    _hybrid_mesh = 0;
    _session = 0;
    _surf_mesh = 0;
    _sizemap = 0;
    _context = 0;
  }

  void AddError( const char *txt )
  {
    if ( txt )
    {
      _errorStr += txt;
    }
  }

  const std::string& GetErrors()
  {
    return _errorStr;
  }

  void MG_Error(const char* txt="")
  {
    SMESH_Comment msg("\nMeshGems error. ");
    msg << txt << "\n";
    std::cout << msg;
    AddError( msg.c_str() );
  }

  //================================================================================
  /*!
   * \brief SetParam to define a parameter by its value
   *  \param [in] param - the parameter to set
   *  \param [in] valus - its value
   *  \return bool - Ok or not
   */
  //================================================================================
  bool SetParam( const std::string& param, const std::string& value )
  {
    status_t ret = hybrid_set_param( _session, param.c_str(), value.c_str() );
    MESSAGE(param << " = " << value);
    return ( ret == STATUS_OK );
  }


  //================================================================================
  /*!
   * \brief SetTags to define boundary layers
   *  \param [in] param - the parameter to set
   *  \param [in] values - a list of ids separated by a comma
   *  \param [in] size - the size of the boundary layer
   *  \return bool - Ok or not
   */
  //================================================================================
  bool SetTags( const std::string& param, const std::string& values, const std::string& size )
  {
    // constructing stream from the string
    std::stringstream ss(values);
    std::string s;
    // for each string value separated by ',' call hybrid API to set the tag
    while (getline(ss, s, ','))
    {
      status_t ret;
      int tag = stoi(s);
      if ( param=="boundary_layer_imprinting_tags" )
      {
        ret = hybrid_set_boundary_layer_imprinting_tag(_session, tag);
        MESSAGE("imprinting " << tag);
      }
      else if ( param=="boundary_layer_snapping_tags" )
      {
        ret = hybrid_set_boundary_layer_snapping_tag(_session, tag);
        MESSAGE("snapping " << tag);
      }
      else if ( param=="boundary_layer_surface_tags" )
      {
        ret = hybrid_set_initial_height_on_surface_tag(_session, tag, stod(size));
        MESSAGE("height " << tag << " = " << stod(size));
      }
      if ( ret != STATUS_OK )
      {
        MESSAGE("PBBBBBBBBBBBBBBBBBBBBBB STATUS not OK ");
        return false;
      }
    }
    return true;
  }

  bool Cancelled()
  {
    return _cancelled_flag;
  }

  int ReadNbSubDomains()
  {
    integer nb = 0;
    status_t ret = mesh_get_subdomain_count( _hybrid_mesh, & nb );

    if ( ret != STATUS_OK ) MG_Error("mesh_get_subdomain_count problem");
    return nb;
  }

  int ReadNbNodes()
  {
    _corners.clear();

    integer nb = 0;
    status_t ret = mesh_get_vertex_count( _hybrid_mesh, & nb );

    if ( ret != STATUS_OK ) MG_Error("mesh_get_vertex_count problem");
    return nb;
  }

  int ReadNbEdges()
  {
    integer nb = 0;
    status_t ret = mesh_get_edge_count( _hybrid_mesh, & nb );

    if ( ret != STATUS_OK ) MG_Error("mesh_get_edge_count problem");
    return nb;
  }

  int ReadNbTria()
  {
    integer nb = 0;
    status_t ret = mesh_get_triangle_count( _hybrid_mesh, & nb );

    if ( ret != STATUS_OK ) MG_Error("mesh_get_triangle_count problem");
    return nb;
  }

  int ReadNbQuads()
  {
    integer nb = 0;
    status_t ret = mesh_get_quadrangle_count( _hybrid_mesh, & nb );

    if ( ret != STATUS_OK ) MG_Error("mesh_get_quadrangle_count problem");
    return nb;
  }

  int ReadNbTetra()
  {
    integer nb = 0;
    status_t ret = mesh_get_tetrahedron_count( _hybrid_mesh, & nb );

    if ( ret != STATUS_OK ) MG_Error("mesh_get_tetrahedron_count problem");
    return nb;
  }

  int ReadNbHexa()
  {
    integer nb = 0;
    status_t ret = mesh_get_hexahedron_count( _hybrid_mesh, & nb );

    if ( ret != STATUS_OK ) MG_Error("mesh_get_hexahedron_count problem");
    return nb;
  }

  int ReadNbPrisms()
  {
    integer nb = 0;
    status_t ret = mesh_get_prism_count( _hybrid_mesh, & nb );

    if ( ret != STATUS_OK ) MG_Error("mesh_get_prism_count problem");
    return nb;
  }

  int ReadNbPyramids()
  {
    integer nb = 0;
    status_t ret = mesh_get_pyramid_count( _hybrid_mesh, & nb );

    if ( ret != STATUS_OK ) MG_Error("mesh_get_pyramid_count problem");
    return nb;
  }

  int ReadNbCorners()
  {
    return _corners.size();
  }

  void ResetCounter()
  {
    _count = 1;
  }

  void ReadSubDomain( int* nbNodes, int* faceInd, int* ori, int* domain )
  {
    integer tag, seed_type, seed_idx, seed_orientation;
    status_t ret = mesh_get_subdomain_description( _hybrid_mesh, _count,
                                                   &tag, &seed_type, &seed_idx, &seed_orientation);

    if ( ret != STATUS_OK ) MG_Error( "unable to get a sub-domain description");

    *nbNodes = 3;
    *faceInd = seed_idx;
    *domain  = tag;
    *ori     = seed_orientation;

    ++_count;
  }
  void ReadNodeXYZ( double* x, double* y, double *z, int* /*domain*/  )
  {
    real coo[3];
    status_t ret = mesh_get_vertex_coordinates( _hybrid_mesh, _count, coo );
    if ( ret != STATUS_OK ) MG_Error( "unable to get resulting vertices" );

    *x = coo[0];
    *y = coo[1];
    *z = coo[2];

    integer isCorner = 0;
    ret = mesh_get_vertex_corner_property( _hybrid_mesh, _count, &isCorner);
    if (ret != STATUS_OK) MG_Error( "unable to get resulting vertex property" );
    if ( isCorner )
      _corners.push_back( _count );

    ++_count;
  }

  void ReadEdgeNodes( int* node1, int* node2, int* domain )
  {
    integer vtx[2], tag;
    status_t ret = mesh_get_edge_vertices( _hybrid_mesh, _count, vtx);
    if (ret != STATUS_OK) MG_Error( "unable to get resulting edge" );

    *node1 = vtx[0];
    *node2 = vtx[1];

    ret = mesh_get_edge_tag( _hybrid_mesh, _count, &tag );
    if (ret != STATUS_OK) MG_Error( "unable to get resulting edge tag" );

    *domain = tag;

    ++_count;
  }

  void ReadTriaNodes( int* node1, int* node2, int* node3, int* domain )
  {
    integer vtx[3], tag;
    status_t ret = mesh_get_triangle_vertices( _hybrid_mesh, _count, vtx);
    if (ret != STATUS_OK) MG_Error( "unable to get resulting triangle" );

    *node1 = vtx[0];
    *node2 = vtx[1];
    *node3 = vtx[2];

    ret = mesh_get_triangle_tag( _hybrid_mesh, _count, &tag );
    if (ret != STATUS_OK) MG_Error( "unable to get resulting triangle tag" );

    *domain = tag;

    ++_count;
  }

  void ReadQuadNodes( int* node1, int* node2, int* node3, int* node4, int* domain )
  {
    integer vtx[4], tag;
    status_t ret = mesh_get_quadrangle_vertices( _hybrid_mesh, _count, vtx);
    if (ret != STATUS_OK) MG_Error( "unable to get resulting quadrangle" );

    *node1 = vtx[0];
    *node2 = vtx[1];
    *node3 = vtx[2];
    *node4 = vtx[3];

    ret = mesh_get_quadrangle_tag( _hybrid_mesh, _count, &tag );
    if (ret != STATUS_OK) MG_Error( "unable to get resulting quadrangle tag" );

    *domain = tag;

    ++_count;
  }

  void ReadTetraNodes( int* node1, int* node2, int* node3, int* node4, int* domain )
  {
    integer vtx[4], tag;
    status_t ret = mesh_get_tetrahedron_vertices( _hybrid_mesh, _count, vtx);
    if (ret != STATUS_OK) MG_Error( "unable to get resulting tetrahedron" );

    *node1 = vtx[0];
    *node2 = vtx[1];
    *node3 = vtx[2];
    *node4 = vtx[3];

    ret = mesh_get_tetrahedron_tag( _hybrid_mesh, _count, &tag );
    if (ret != STATUS_OK) MG_Error( "unable to get resulting tetrahedron tag" );

    *domain = tag;

    ++_count;
  }

  void ReadHexaNodes( int* node1, int* node2, int* node3, int* node4,
                      int* node5, int* node6, int* node7, int* node8, int* domain )
  {
    integer vtx[8], tag;
    status_t ret = mesh_get_hexahedron_vertices( _hybrid_mesh, _count, vtx);
    if (ret != STATUS_OK) MG_Error( "unable to get resulting hexahedron" );

    *node1 = vtx[0];
    *node2 = vtx[1];
    *node3 = vtx[2];
    *node4 = vtx[3];
    *node5 = vtx[4];
    *node6 = vtx[5];
    *node7 = vtx[6];
    *node8 = vtx[7];

    ret = mesh_get_hexahedron_tag( _hybrid_mesh, _count, &tag );
    if (ret != STATUS_OK) MG_Error( "unable to get resulting hexahedron tag" );

    *domain = tag;

    ++_count;
  }

  void ReadPrismNodes( int* node1, int* node2, int* node3, int* node4,
                       int* node5, int* node6, int* /*domain*/ )
  {
    integer vtx[6];
    status_t ret = mesh_get_prism_vertices( _hybrid_mesh, _count, vtx);
    if (ret != STATUS_OK) MG_Error( "unable to get resulting prism" );

    *node1 = vtx[0];
    *node2 = vtx[1];
    *node3 = vtx[2];
    *node4 = vtx[3];
    *node5 = vtx[4];
    *node6 = vtx[5];

    // integer tag;
    // ret = mesh_get_hexahedron_tag( _hybrid_mesh, _count, &tag );
    // if (ret != STATUS_OK) MG_Error( "unable to get resulting hexahedron tag" );

    // *domain = tag;

    ++_count;
  }

  void ReadPyramidNodes( int* node1, int* node2, int* node3, int* node4, int* node5, int* domain )
  {
    integer vtx[6];
    status_t ret = mesh_get_pyramid_vertices( _hybrid_mesh, _count, vtx);
    if (ret != STATUS_OK) MG_Error( "unable to get resulting pyramid" );

    *node1 = vtx[0];
    *node2 = vtx[1];
    *node3 = vtx[2];
    *node4 = vtx[3];
    *node5 = vtx[4];

    integer tag;
    ret = mesh_get_pyramid_tag( _hybrid_mesh, _count, &tag );
    if (ret != STATUS_OK) MG_Error( "unable to get resulting pyramid tag" );

    *domain = tag;

    ++_count;
  }

  void ReadCorner( int* node )
  {
    if ( _count <= ReadNbCorners() )
      *node = _corners[ _count - 1 ];
    else
      *node = 0;

    ++_count;
  }

  void SetNbVertices( int nb )
  {
    _xyz.reserve( _xyz.capacity() + nb );
  }

  void SetNbEdges( int nb )
  {
    _edgeNodesTags.reserve( nb * 3 );
  }

  void SetNbTria( int nb )
  {
    _triaNodesTags.reserve( nb * 4 );
  }

  void SetNbQuads( int nb )
  {
    _quadNodes.reserve( nb * 4 );
  }

  void SetNbReqVertices( int nb )
  {
    _nodeSize.reserve( nb );
  }

  void SetNbReqEdges( int nb )
  {
    _nbRequiredEdges = nb;
  }

  void SetNbReqTria( int nb )
  {
    _nbRequiredTria = nb;
  }

  void AddNode( double x, double y, double z, int /*domain*/ )
  {
    _xyz.push_back( x );
    _xyz.push_back( y );
    _xyz.push_back( z );
  }

  void AddSizeAtNode( double size )
  {
    _nodeSize.push_back( size );
  }
  
  void AddEdgeNodes( int node1, int node2, int domain )
  {
    _edgeNodesTags.push_back( node1 );
    _edgeNodesTags.push_back( node2 );
    _edgeNodesTags.push_back( domain );
  }
  
  void AddTriaNodes( int node1, int node2, int node3, int domain )
  {
    _triaNodesTags.push_back( node1 );
    _triaNodesTags.push_back( node2 );
    _triaNodesTags.push_back( node3 );
    _triaNodesTags.push_back( domain );
  }

  void AddQuadNodes( int node1, int node2, int node3, int node4 )
  {
    _quadNodes.push_back( node1 );
    _quadNodes.push_back( node2 );
    _quadNodes.push_back( node3 );
    _quadNodes.push_back( node4 );
  }

  int NbNodes()
  {
    return _xyz.size() / 3;
  }

  double* NodeCoord( int iNode )
  {
    return & _xyz[ iNode * 3 ];
  }

  int NbEdges()
  {
    return _edgeNodesTags.size() / 3;
  }

  int* GetEdgeNodes( int iEdge )
  {
    return & _edgeNodesTags[ iEdge * 3 ];
  }

  int GetEdgeTag( int iEdge )
  {
    return _edgeNodesTags[ iEdge * 3 + 2 ];
  }

  int NbTriangles()
  {
    return _triaNodesTags.size() / 4;
  }

  int * GetTriaNodes( int iTria )
  {
    return & _triaNodesTags[ iTria * 4 ];
  }

  int GetTriaTag( int iTria )
  {
    return _triaNodesTags[ iTria * 4 + 3 ];
  }

  int NbQuads()
  {
    return _quadNodes.size() / 4;
  }

  int * GetQuadNodes( int iQ )
  {
    return & _quadNodes[ iQ * 4 ];
  }

  int IsVertexRequired( int iNode )
  {
    return ! ( iNode < int( NbNodes() - _nodeSize.size() ));
  }

  double GetSizeAtVertex( int iNode )
  {
    return IsVertexRequired( iNode ) ? _nodeSize[ iNode - NbNodes() + _nodeSize.size() ] : 0.;
  }
};

namespace // functions called by MG library to exchange with the application
{
  status_t get_vertex_count(integer * nbvtx, void *user_data)
  {
    MG_HYBRID_API::LibData* data = (MG_HYBRID_API::LibData *) user_data;
    *nbvtx = data->NbNodes();

    return STATUS_OK;
  }

  status_t get_vertex_coordinates(integer ivtx, real * xyz, void *user_data)
  {
    MG_HYBRID_API::LibData* data = (MG_HYBRID_API::LibData *) user_data;
    double* coord = data->NodeCoord( ivtx-1 );
    for (int j = 0; j < 3; j++)
      xyz[j] = coord[j];

    return STATUS_OK;
  }
  status_t get_edge_count(integer * nbedge, void *user_data)
  {
    MG_HYBRID_API::LibData* data = (MG_HYBRID_API::LibData *) user_data;
    *nbedge = data->NbEdges();

    return STATUS_OK;
  }

  status_t get_edge_vertices(integer iedge, integer * vedge, void *user_data)
  {
    MG_HYBRID_API::LibData* data = (MG_HYBRID_API::LibData *) user_data;
    int* nodes = data->GetEdgeNodes( iedge-1 );
    vedge[0] = nodes[0];
    vedge[1] = nodes[1];

    return STATUS_OK;
  }

  status_t get_edge_tag(integer iedge, integer * tag, void *user_data)
  {
    MG_HYBRID_API::LibData* data = (MG_HYBRID_API::LibData *) user_data;
    * tag = data->GetEdgeTag( iedge-1 );

    return STATUS_OK;
  }

  status_t get_triangle_count(integer * nbtri, void *user_data)
  {
    MG_HYBRID_API::LibData* data = (MG_HYBRID_API::LibData *) user_data;
    *nbtri = data->NbTriangles();

    return STATUS_OK;
  }

  status_t get_triangle_vertices(integer itri, integer * vtri, void *user_data)
  {
    MG_HYBRID_API::LibData* data = (MG_HYBRID_API::LibData *) user_data;
    int* nodes = data->GetTriaNodes( itri-1 );
    vtri[0] = nodes[0];
    vtri[1] = nodes[1];
    vtri[2] = nodes[2];

    return STATUS_OK;
  }

  status_t get_triangle_tag(integer itri, integer * tag, void *user_data)
  {
    MG_HYBRID_API::LibData* data = (MG_HYBRID_API::LibData *) user_data;
    * tag = data->GetTriaTag( itri-1 );

    return STATUS_OK;
  }

  status_t get_quadrangle_count(integer * nbq, void *user_data)
  {
    MG_HYBRID_API::LibData* data = (MG_HYBRID_API::LibData *) user_data;
    *nbq = data->NbQuads();

    return STATUS_OK;
  }

  status_t get_quadrangle_vertices(integer iq, integer * vq, void *user_data)
  {
    MG_HYBRID_API::LibData* data = (MG_HYBRID_API::LibData *) user_data;
    int* nodes = data->GetQuadNodes( iq-1 );
    vq[0] = nodes[0];
    vq[1] = nodes[1];
    vq[2] = nodes[2];
    vq[3] = nodes[3];

    return STATUS_OK;
  }

  status_t get_vertex_required_property(integer ivtx, integer * rvtx, void *user_data)
  {
    MG_HYBRID_API::LibData* data = (MG_HYBRID_API::LibData *) user_data;
    *rvtx = data->IsVertexRequired( ivtx - 1 );

    return STATUS_OK;
  }

  status_t get_vertex_weight(integer ivtx, real * wvtx, void *user_data)
  {
    MG_HYBRID_API::LibData* data = (MG_HYBRID_API::LibData *) user_data;
    *wvtx = data->GetSizeAtVertex( ivtx - 1 );

    return STATUS_OK;
  }

  status_t my_message_cb(message_t * msg, void *user_data)
  {
    char *desc;
    integer e, n, m;
    integer i, i_data[10];
    real r_data[10];
    n = m = 0;
    message_get_description(msg, &desc);
    message_get_number(msg, &e);

    if (e < 0) {
      printf("mg-hybrid ERROR %i : %s", MESHGEMS_ABS_CODE(e), desc);
      message_get_integer_data_count(msg, &n);
      message_get_real_data_count(msg, &m);
      printf("MGMESSAGE %i ", e);
      printf(" %i", n);
      if (n > 0) {
        message_get_integer_data(msg, 1, n, i_data);
        for (i = 0; i < n; i++)
          printf(" %i", i_data[i]);
      }
      printf(" %i", m);
      if (m > 0) {
        message_get_real_data(msg, 1, m, r_data);
        for (i = 0; i < m; i++)
          printf(" %f", r_data[i]);
      }
      printf(" \n");

    }
    if (e >= 0) {
      if (e == 0)
        printf("\rmg-hybrid info : %s", desc);
      else
        printf("mg-hybrid info %i : %s", MESHGEMS_CODE(e), desc);
    }
    message_get_description(msg, &desc);

    MG_HYBRID_API::LibData* data = (MG_HYBRID_API::LibData *) user_data;
    data->AddError( desc );

    return STATUS_OK;
  }

  status_t my_interrupt_callback(integer *interrupt_status, void *user_data)
  {
    MG_HYBRID_API::LibData* data = (MG_HYBRID_API::LibData *) user_data;
    *interrupt_status = ( data->Cancelled() ? INTERRUPT_STOP : INTERRUPT_CONTINUE );

    return STATUS_OK;
  }

} // end namespace


void MG_HYBRID_API::LibData::Init()
{
  status_t ret;

  // Create the meshgems working context
  _context = context_new();
  if ( !_context ) MG_Error( "unable to create a new context" );

  // Set the message callback for the _context.
  ret = context_set_message_callback( _context, my_message_cb, this );
  if ( ret != STATUS_OK ) MG_Error("in context_set_message_callback");

  // Create the structure holding the callbacks giving access to triangle mesh
  _surf_mesh = mesh_new( _context );
  if ( !_surf_mesh ) MG_Error("unable to create a new mesh");

  // Set callbacks to provide triangle mesh data
  mesh_set_get_vertex_count( _surf_mesh, get_vertex_count, this );
  mesh_set_get_vertex_coordinates( _surf_mesh, get_vertex_coordinates, this );
  mesh_set_get_vertex_required_property( _surf_mesh, get_vertex_required_property, this );
  mesh_set_get_edge_count( _surf_mesh, get_edge_count, this);
  mesh_set_get_edge_vertices( _surf_mesh, get_edge_vertices, this );
  mesh_set_get_edge_tag( _surf_mesh, get_edge_tag, this );
  mesh_set_get_triangle_count( _surf_mesh, get_triangle_count, this );
  mesh_set_get_triangle_vertices( _surf_mesh, get_triangle_vertices, this );
  mesh_set_get_triangle_tag( _surf_mesh, get_triangle_tag, this );
  mesh_set_get_quadrangle_count( _surf_mesh, get_quadrangle_count, this );
  mesh_set_get_quadrangle_vertices( _surf_mesh, get_quadrangle_vertices, this );

  // Create a hybrid session
  _session = hybrid_session_new( _context );
  if ( !_session ) MG_Error( "unable to create a new hybrid session");

  ret = hybrid_set_interrupt_callback( _session, my_interrupt_callback, this );
  if ( ret != STATUS_OK ) MG_Error("in hybrid_set_interrupt_callback");

}

bool MG_HYBRID_API::LibData::Compute()
{
  // MG license
  std::string errorTxt;
  status_t ret;

  if ( !SMESHUtils_MGLicenseKeyGen::SignMesh( _surf_mesh, "hybrid", errorTxt ))
  {
    AddError( SMESH_Comment( "Problem with library SalomeMeshGemsKeyGenerator: ") << errorTxt );
    return false;
  }

  // Set surface mesh
  ret = hybrid_set_surface_mesh( _session, _surf_mesh );
  if ( ret != STATUS_OK ) MG_Error( "unable to set surface mesh");

#ifndef WIN32
  // Set a sizemap
  if ( !_nodeSize.empty() )
  {
    _sizemap = meshgems_sizemap_new( _surf_mesh, meshgems_sizemap_type_iso_mesh_vertex,
                                     (void*) &get_vertex_weight, this );
    if ( !_sizemap ) MG_Error("unable to create a new sizemap");

    ret = hybrid_set_sizemap( _session, _sizemap );
    if ( ret != STATUS_OK ) MG_Error( "unable to set sizemap");
  }
#endif

  //////////////////////////////////////////////////////////////////////////////////////////
  // const char* file  =  "/tmp/ghs3d_IN.mesh";
  // mesh_write_mesh( _surf_mesh,file);
  // std::cout << std::endl << std::endl << "Write " << file << std::endl << std::endl << std::endl;

  ret = hybrid_compute_mesh( _session );
  if ( ret != STATUS_OK ) return false;

  ret = hybrid_get_mesh( _session, &_hybrid_mesh);
  if (ret != STATUS_OK) MG_Error( "unable to get resulting mesh");

  //////////////////////////////////////////////////////////////////////////////////////////
  // file  =  "/tmp/ghs3d_OUT.mesh";
  // mesh_write_mesh( _hybrid_mesh,file);
  // std::cout << std::endl << std::endl << "Write " << file << std::endl << std::endl << std::endl;

  return true;
}

#else // ifdef USE_MG_LIBS

struct MG_HYBRID_API::LibData // to avoid compiler warnings
{
  volatile bool& _cancelled_flag;
  double& _progress;
  LibData(volatile bool& cancelled_flag, double& progress): _cancelled_flag{cancelled_flag}, _progress{progress} {}
};

#endif // ifdef USE_MG_LIBS


//================================================================================
/*!
 * \brief Constructor
 */
//================================================================================

MG_HYBRID_API::MG_HYBRID_API(volatile bool& cancelled_flag, double& progress)
  :_nbNodes(0), _nbEdges(0), _nbFaces(0), _nbVolumes(0)
{
  _useLib = false;
  _libData = new LibData( cancelled_flag, progress );
}

//================================================================================
/*!
 * \brief Destructor
 */
//================================================================================

MG_HYBRID_API::~MG_HYBRID_API()
{
  delete _libData;
  _libData = 0;
  std::set<int>::iterator id = _openFiles.begin();
  for ( ; id != _openFiles.end(); ++id )
    ::GmfCloseMesh( *id );
  _openFiles.clear();
}

//================================================================================
/*!
 * \brief Return the way of MG usage
 */
//================================================================================

bool MG_HYBRID_API::IsLibrary()
{
  return _useLib;
}

//================================================================================
/*!
 * \brief Switch to usage of MG-HYBRID library
 */
//================================================================================

void MG_HYBRID_API::SetUseLibrary()
{
  _useLib = true;
#ifdef USE_MG_LIBS
  _libData->Init();
#endif
}

//================================================================================
/*!
 * \brief Switch to usage of MG-HYBRID executable
 */
//================================================================================

void MG_HYBRID_API::SetUseExecutable()
{
  _useLib = false;
}

//================================================================================
/*!
 * \brief Compute the hybrid mesh
 *  \param [in] cmdLine - a command to run mg_hybrid.exe
 *  \return bool - Ok or not
 */
//================================================================================

bool MG_HYBRID_API::Compute( const std::string& cmdLine, std::string& errStr )
{
  if ( _useLib ) {
#ifdef USE_MG_LIBS
    // split cmdLine
    std::istringstream strm( cmdLine );
    std::istream_iterator<std::string> sIt( strm ), sEnd;
    std::vector< std::string > args( sIt, sEnd );

    // set parameters
    std::string param, value;
    std::string boundary_layer_size;

    for ( size_t i = 1; i < args.size(); i=i+2 )
    {
      param = args[i];
      value = args[i+1];
      MESSAGE("param: " <<  param);
      MESSAGE("value: " <<  value);

      // skipping output redirection, it is not a param to set
      if (param=="1>")
        continue;

      // removing -- from param
      while ( param[0] == '-')
        param = param.substr( 1 );

      // store this value for boundary layer definition (needed by setTags after)
      if (param == "boundary_layer_global_initial_height")
        boundary_layer_size = value;

      // set parameters with list of tags (string of ids separated by a comma)
      if (param=="boundary_layer_imprinting_tags" || param=="boundary_layer_snapping_tags" || param=="boundary_layer_surface_tags")
      {
        if (!_libData->SetTags(param, value, boundary_layer_size))
          std::cout << "Warning: error in SetTags(" << param << ", " << value << ", " << boundary_layer_size << ")" << std::endl;
      }
      // set other parameters
      else if ( !_libData->SetParam( param, value ))
        std::cout << "Warning: wrong param: '" << param <<"' = '" << value << "'" << std::endl;
    }

    // compute
    bool ok =  _libData->Compute();

    GetLog(); // write a log file
    _logFile = ""; // not to write it again

    return ok;
#endif
  }

  // not library => call executable

  // add MG license key
  {
    std::string errorTxt, meshIn;
    std::string key = SMESHUtils_MGLicenseKeyGen::GetKey( meshIn,
                                                          _nbNodes, _nbEdges, _nbFaces, _nbVolumes,
                                                          errorTxt );
    if ( key.empty() )
    {
      errStr = "Problem with library SalomeMeshGemsKeyGenerator: " + errorTxt;
      return false;
    }
    if ( key != "0")
      const_cast< std::string& >( cmdLine ) += " --key " + key;
  }

  int err = system( cmdLine.c_str() ); // run

  if ( err )
    errStr = SMESH_Comment("system(mg-hybrid.exe ...) command failed with error: ")
      << strerror( errno );

  return !err;

}

//================================================================================
/*!
 * \brief Prepare for reading a mesh data
 */
//================================================================================

int  MG_HYBRID_API::GmfOpenMesh(const char* theFile, int rdOrWr, int * ver, int * dim)
{
  if ( _useLib ) {
#ifdef USE_MG_LIBS
    return 1;
#endif
  }
  int id = ::GmfOpenMesh(theFile, rdOrWr, ver, dim );
  _openFiles.insert( id );
  return id;
}

//================================================================================
/*!
 * \brief Return nb of entities
 */
//================================================================================

int MG_HYBRID_API::GmfStatKwd( int iMesh, GmfKwdCod what )
{
  if ( _useLib ) {
#ifdef USE_MG_LIBS
    switch ( what )
    {
    case GmfSubDomainFromGeom: return _libData->ReadNbSubDomains();
    case GmfVertices:          return _libData->ReadNbNodes();
    case GmfEdges:             return _libData->ReadNbEdges();
    case GmfTriangles:         return _libData->ReadNbTria();
    case GmfQuadrilaterals:    return _libData->ReadNbQuads();
    case GmfTetrahedra:        return _libData->ReadNbTetra();
    case GmfPrisms:            return _libData->ReadNbPrisms();
    case GmfPyramids:          return _libData->ReadNbPyramids();
    case GmfHexahedra:         return _libData->ReadNbHexa();
    case GmfCorners:           return _libData->ReadNbCorners();
    default:                   return 0;
    }
    return 0;
#endif
  }
  return ::GmfStatKwd( iMesh, what );
}

//================================================================================
/*!
 * \brief Prepare for reading some data
 */
//================================================================================

void MG_HYBRID_API::GmfGotoKwd( int iMesh, GmfKwdCod what )
{
  if ( _useLib ) {
#ifdef USE_MG_LIBS
    _libData->ResetCounter();
    return;
#endif
  }
  ::GmfGotoKwd( iMesh, what );
}

//================================================================================
/*!
 * \brief Return index of a domain identified by a triangle normal
 *  \param [in] iMesh - mesh file index
 *  \param [in] what - must be GmfSubDomainFromGeom
 *  \param [out] nbNodes - nb nodes in a face
 *  \param [out] faceInd - face index
 *  \param [out] ori - face orientation
 *  \param [out] domain - domain index
 *  \param [in] dummy - an artificial param used to discriminate from GmfGetLin() reading
 *              a triangle
 */
//================================================================================

void MG_HYBRID_API::GmfGetLin( int iMesh, GmfKwdCod what, int* nbNodes, int* faceInd, int* ori, int* domain, int /*dummy*/ )
{
  if ( _useLib ) {
#ifdef USE_MG_LIBS
    _libData->ReadSubDomain( nbNodes, faceInd, ori, domain );
    return;
#endif
  }
  ::GmfGetLin( iMesh, what, nbNodes, faceInd, ori, domain );
}

//================================================================================
/*!
 * \brief Return coordinates of a next node
 */
//================================================================================

void MG_HYBRID_API::GmfGetLin(int iMesh, GmfKwdCod what,
                             double* x, double* y, double *z, int* domain )
{
  if ( _useLib ) {
#ifdef USE_MG_LIBS
    _libData->ReadNodeXYZ( x, y, z, domain );
    return;
#endif
  }
  ::GmfGetLin(iMesh, what, x, y, z, domain );
}

//================================================================================
/*!
 * \brief Return coordinates of a next node
 */
//================================================================================

void MG_HYBRID_API::GmfGetLin(int iMesh, GmfKwdCod what,
                             float* x, float* y, float *z, int* domain )
{
  if ( _useLib ) {
#ifdef USE_MG_LIBS
    double X,Y,Z;
    _libData->ReadNodeXYZ( &X, &Y, &Z, domain );
    *x = X;
    *y = Y;
    *z = Z;
    return;
#endif
  }
  ::GmfGetLin(iMesh, what, x, y, z, domain );
}

//================================================================================
/*!
 * \brief Return node index of a next corner
 */
//================================================================================

void MG_HYBRID_API::GmfGetLin(int iMesh, GmfKwdCod what, int* node )
{
  if ( _useLib ) {
#ifdef USE_MG_LIBS
    _libData->ReadCorner( node );
    return;
#endif
  }
  ::GmfGetLin(iMesh, what, node );
}

//================================================================================
/*!
 * \brief Return node indices of a next edge
 */
//================================================================================

void MG_HYBRID_API::GmfGetLin(int iMesh, GmfKwdCod what, int* node1, int* node2, int* domain )
{
  if ( _useLib ) {
#ifdef USE_MG_LIBS
    _libData->ReadEdgeNodes( node1, node2, domain );
    return;
#endif
  }
  ::GmfGetLin( iMesh, what, node1, node2, domain );
}

//================================================================================
/*!
 * \brief Return node indices of a next triangle
 */
//================================================================================

void MG_HYBRID_API::GmfGetLin(int iMesh, GmfKwdCod what,
                             int* node1, int* node2, int* node3, int* domain )
{
  if ( _useLib ) {
#ifdef USE_MG_LIBS
    _libData->ReadTriaNodes( node1, node2, node3, domain );
    return;
#endif
  }
  ::GmfGetLin(iMesh, what, node1, node2, node3, domain );
}

//================================================================================
/*!
 * \brief Return node indices of a next tetrahedron or quadrangle
 */
//================================================================================

void MG_HYBRID_API::GmfGetLin(int iMesh, GmfKwdCod what,
                             int* node1, int* node2, int* node3, int* node4, int* domain )
{
  if ( _useLib ) {
#ifdef USE_MG_LIBS
    if ( what == GmfQuadrilaterals )
      _libData->ReadQuadNodes( node1, node2, node3, node4, domain );
    else
      _libData->ReadTetraNodes( node1, node2, node3, node4, domain );
    return;
#endif
  }
  ::GmfGetLin(iMesh, what, node1, node2, node3, node4, domain );
}

//================================================================================
/*!
 * \brief Return node indices of a next hexahedron
 */
//================================================================================

void MG_HYBRID_API::GmfGetLin(int iMesh, GmfKwdCod what,
                             int* node1, int* node2, int* node3, int* node4,
                             int* node5, int* node6, int* node7, int* node8,
                             int* domain )
{
  if ( _useLib ) {
#ifdef USE_MG_LIBS
    _libData->ReadHexaNodes( node1, node2, node3, node4, node5, node6, node7, node8, domain );
    return;
#endif
  }
  ::GmfGetLin(iMesh, what, node1, node2, node3, node4, node5, node6, node7, node8, domain );
}

//================================================================================
/*!
 * \brief Return node indices of a next pyramid
 */
//================================================================================

void MG_HYBRID_API::GmfGetLin(int iMesh, GmfKwdCod what,
                              int* node1, int* node2, int* node3, int* node4,
                              int* node5, int* domain )
{
  if ( _useLib ) {
#ifdef USE_MG_LIBS
    _libData->ReadPyramidNodes( node1, node2, node3, node4, node5, domain );
    return;
#endif
  }
  ::GmfGetLin(iMesh, what, node1, node2, node3, node4, node5, domain );
}

//================================================================================
/*!
 * \brief Return node indices of a next prism
 */
//================================================================================

void MG_HYBRID_API::GmfGetLin(int iMesh, GmfKwdCod what,
                              int* node1, int* node2, int* node3, int* node4,
                              int* node5, int* node6, int* domain )
{
  if ( _useLib ) {
#ifdef USE_MG_LIBS
    _libData->ReadPrismNodes( node1, node2, node3, node4, node5, node6, domain );
    return;
#endif
  }
  ::GmfGetLin(iMesh, what, node1, node2, node3, node4, node5, node6, domain );
}

//================================================================================
/*!
 * \brief Prepare for passing data to MeshGems
 */
//================================================================================

int  MG_HYBRID_API::GmfOpenMesh(const char* theFile, int rdOrWr, int ver, int dim)
{
  if ( _useLib ) {
#ifdef USE_MG_LIBS
    return 1;
#endif
  }
  int id = ::GmfOpenMesh(theFile, rdOrWr, ver, dim);
  _openFiles.insert( id );
  return id;
}

//================================================================================
/*!
 * \brief Set number of entities
 */
//================================================================================

void MG_HYBRID_API::GmfSetKwd(int iMesh, GmfKwdCod what, int nb )
{
  if ( iMesh == 1 )
  {
    switch ( what ) {
    case GmfVertices:       _nbNodes = nb; break;
    case GmfEdges:          _nbEdges = nb; break;
    case GmfTriangles:      _nbFaces += nb; break;
    case GmfQuadrilaterals: _nbFaces += nb; break;
    default:;
    }
  }
  if ( _useLib ) {
#ifdef USE_MG_LIBS
    switch ( what ) {
    case GmfVertices:          _libData->SetNbVertices( nb ); break;
    case GmfEdges:             _libData->SetNbEdges   ( nb ); break;
    case GmfRequiredEdges:     _libData->SetNbReqEdges( nb ); break;
    case GmfTriangles:         _libData->SetNbTria    ( nb ); break;
    case GmfRequiredTriangles: _libData->SetNbReqTria ( nb ); break;
    default:;
    }
    return;
#endif
  }
  ::GmfSetKwd(iMesh, what, nb );
}

//================================================================================
/*!
 * \brief Add coordinates of a node
 */
//================================================================================

void MG_HYBRID_API::GmfSetLin(int iMesh, GmfKwdCod what, double x, double y, double z, int domain)
{
  if ( _useLib ) {
#ifdef USE_MG_LIBS
    _libData->AddNode( x, y, z, domain );
    return;
#endif
  }
  ::GmfSetLin(iMesh, what, x, y, z, domain);
}

//================================================================================
/*!
 * \brief Set number of field entities
 *  \param [in] iMesh - solution file index
 *  \param [in] what - solution type
 *  \param [in] nbNodes - nb of entities
 *  \param [in] nbTypes - nb of data entries in each entity
 *  \param [in] type - types of the data entries
 *
 * Used to prepare to storing size at nodes
 */
//================================================================================

void MG_HYBRID_API::GmfSetKwd(int iMesh, GmfKwdCod what, int nbNodes, int dummy, int type[] )
{
  if ( _useLib ) {
#ifdef USE_MG_LIBS
    if ( what == GmfSolAtVertices ) _libData->SetNbReqVertices( nbNodes );
    return;
#endif
  }
  ::GmfSetKwd(iMesh, what, nbNodes, dummy, type );
}

//================================================================================
/*!
 * \brief Add solution data
 */
//================================================================================

void MG_HYBRID_API::GmfSetLin(int iMesh, GmfKwdCod what, double vals[])
{
  if ( _useLib ) {
#ifdef USE_MG_LIBS
    _libData->AddSizeAtNode( vals[0] );
    return;
#endif
  }
  ::GmfSetLin(iMesh, what, vals);
}

//================================================================================
/*!
 * \brief Add edge nodes
 */
//================================================================================

void MG_HYBRID_API::GmfSetLin(int iMesh, GmfKwdCod what, int node1, int node2, int domain )
{
  if ( _useLib ) {
#ifdef USE_MG_LIBS
    _libData->AddEdgeNodes( node1, node2, domain );
    return;
#endif
  }
  ::GmfSetLin(iMesh, what, node1, node2, domain );
}

//================================================================================
/*!
 * \brief Add a 'required' flag
 */
//================================================================================

void MG_HYBRID_API::GmfSetLin(int iMesh, GmfKwdCod what, int id )
{
  if ( _useLib ) {
#ifdef USE_MG_LIBS
    return;
#endif
  }
  ::GmfSetLin(iMesh, what, id );
}

//================================================================================
/*!
 * \brief Add triangle nodes
 */
//================================================================================

void MG_HYBRID_API::GmfSetLin(int iMesh, GmfKwdCod what, int node1, int node2, int node3, int domain )
{
  if ( _useLib ) {
#ifdef USE_MG_LIBS
    _libData->AddTriaNodes( node1, node2, node3, domain );
    return;
#endif
  }
  ::GmfSetLin(iMesh, what, node1, node2, node3, domain );
}

//================================================================================
/*!
 * \brief Add quadrangle nodes
 */
//================================================================================

void MG_HYBRID_API::GmfSetLin(int iMesh, GmfKwdCod what, int node1, int node2, int node3, int node4, int domain )
{
  if ( _useLib ) {
#ifdef USE_MG_LIBS
    _libData->AddQuadNodes( node1, node2, node3, node4 );
    return;
#endif
  }
  ::GmfSetLin(iMesh, what, node1, node2, node3, node4, domain );
}

//================================================================================
/*!
 * \brief Close a file
 */
//================================================================================

void MG_HYBRID_API::GmfCloseMesh( int iMesh )
{
  if ( _useLib ) {
#ifdef USE_MG_LIBS
    return;
#endif
  }
  ::GmfCloseMesh( iMesh );
  _openFiles.erase( iMesh );
}

//================================================================================
/*!
 * \brief Return true if the log is not empty
 */
//================================================================================

bool MG_HYBRID_API::HasLog()
{
  if ( _useLib ) {
#ifdef USE_MG_LIBS
    return !_libData->GetErrors().empty();
#endif
  }
  SMESH_File file( _logFile );
  return file.size() > 0;
}

//================================================================================
/*!
 * \brief Return log contents
 */
//================================================================================

std::string MG_HYBRID_API::GetLog()
{
  if ( _useLib ) {
#ifdef USE_MG_LIBS
    const std::string& err = _libData->GetErrors();
    if ( !_logFile.empty() && !err.empty() )
    {
      SMESH_File file( _logFile, /*openForReading=*/false );
      file.openForWriting();
      file.write( err.c_str(), err.size() );
    }
    return err;
#endif
  }
  SMESH_File file( _logFile );
  return file.getPos();
}
