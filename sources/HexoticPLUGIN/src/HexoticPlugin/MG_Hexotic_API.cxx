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

#include "MG_Hexotic_API.hxx"

#ifdef WIN32
#define NOMINMAX
#endif

#include <DriverGMF_Read.hxx>
#include <SMESH_Comment.hxx>
#include <SMESH_File.hxx>
#include <SMESH_MGLicenseKeyGen.hxx>
#include <Utils_SALOME_Exception.hxx>

#include <cstring>
#include <iostream>
#include <iterator>
#include <vector>

#ifdef USE_MG_LIBS

extern "C"{
#include <meshgems/meshgems.h>
#include <meshgems/hexa.h>
}

struct MG_Hexotic_API::LibData
{
  // MG objects
  context_t *       _context;
  hexa_session_t * _session;
  mesh_t *          _tria_mesh;
  sizemap_t *       _sizemap;
  mesh_t *          _hexa_mesh;

  // data to pass to MG
  std::vector<double> _xyz;
  std::vector<double> _nodeSize; // required nodes
  std::vector<int>    _edgeNodesTags;
  int                 _nbRequiredEdges;
  std::vector<int>    _triaNodesTags;
  int                 _nbRequiredTria;

  std::vector<int>    _corners;

  int                 _count;
  volatile bool&      _cancelled_flag;
  std::string         _errorStr;
  double&             _progress;
  double              _msgCost;

  LibData( volatile bool & cancelled_flag, double& progress )
    : _context(0), _session(0), _tria_mesh(0), _sizemap(0), _hexa_mesh(0),
      _nbRequiredEdges(0), _nbRequiredTria(0),
      _cancelled_flag( cancelled_flag ), _progress( progress ), _msgCost( 0.00015 )
  {
  }
  // methods setting callbacks implemented after callback definitions
  void Init();
  bool Compute();

  ~LibData()
  {
    if ( _hexa_mesh )
      hexa_regain_mesh( _session, _hexa_mesh );
    if ( _tria_mesh )
      mesh_delete( _tria_mesh );
    if ( _sizemap )
      sizemap_delete( _sizemap );
    if ( _session )
      hexa_session_delete( _session );
    if ( _context )
      context_delete( _context );

    _hexa_mesh = 0;
    _session = 0;
    _tria_mesh = 0;
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
    AddError( msg.c_str() );
  }

  bool SetParam( const std::string& param, const std::string& value )
  {
    status_t ret = hexa_set_param( _session, param.c_str(), value.c_str() );
#ifdef _DEBUG_
    //std::cout << param << " = " << value << std::endl;
#endif
    return ( ret == STATUS_OK );
  }

  bool Cancelled()
  {
    return _cancelled_flag;
  }

  int ReadNbSubDomains()
  {
    integer nb = 0;
    status_t ret = mesh_get_subdomain_count( _hexa_mesh, & nb );

    if ( ret != STATUS_OK ) MG_Error("mesh_get_subdomain_count problem");
    return nb;
  }

  int ReadNbNodes()
  {
    _corners.clear();

    integer nb = 0;
    status_t ret = mesh_get_vertex_count( _hexa_mesh, & nb );

    if ( ret != STATUS_OK ) MG_Error("mesh_get_vertex_count problem");
    return nb;
  }

  int ReadNbEdges()
  {
    integer nb = 0;
    status_t ret = mesh_get_edge_count( _hexa_mesh, & nb );

    if ( ret != STATUS_OK ) MG_Error("mesh_get_edge_count problem");
    return nb;
  }

  int ReadNbTria()
  {
    integer nb = 0;
    status_t ret = mesh_get_triangle_count( _hexa_mesh, & nb );

    if ( ret != STATUS_OK ) MG_Error("mesh_get_triangle_count problem");
    return nb;
  }

  int ReadNbQuads()
  {
    integer nb = 0;
    status_t ret = mesh_get_quadrangle_count( _hexa_mesh, & nb );

    if ( ret != STATUS_OK ) MG_Error("mesh_get_quadrangle_count problem");
    return nb;
  }

  int ReadNbTetra()
  {
    integer nb = 0;
    status_t ret = mesh_get_tetrahedron_count( _hexa_mesh, & nb );

    if ( ret != STATUS_OK ) MG_Error("mesh_get_tetrahedron_count problem");
    return nb;
  }

  int ReadNbHexa()
  {
    integer nb = 0;
    status_t ret = mesh_get_hexahedron_count( _hexa_mesh, & nb );

    if ( ret != STATUS_OK ) MG_Error("mesh_get_hexahedron_count problem");
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
    status_t ret = mesh_get_subdomain_description( _hexa_mesh, _count,
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
    status_t ret = mesh_get_vertex_coordinates( _hexa_mesh, _count, coo );
    if ( ret != STATUS_OK ) MG_Error( "unable to get resulting vertices" );

    *x = coo[0];
    *y = coo[1];
    *z = coo[2];

    integer isCorner = 0;
    ret = mesh_get_vertex_corner_property( _hexa_mesh, _count, &isCorner);
    if (ret != STATUS_OK) MG_Error( "unable to get resulting vertex property" );
    if ( isCorner )
      _corners.push_back( _count );

    ++_count;
  }

  void ReadEdgeNodes( int* node1, int* node2, int* domain )
  {
    integer vtx[2], tag;
    status_t ret = mesh_get_edge_vertices( _hexa_mesh, _count, vtx);
    if (ret != STATUS_OK) MG_Error( "unable to get resulting edge" );

    *node1 = vtx[0];
    *node2 = vtx[1];

    ret = mesh_get_edge_tag( _hexa_mesh, _count, &tag );
    if (ret != STATUS_OK) MG_Error( "unable to get resulting edge tag" );

    *domain = tag;

    ++_count;
  }

  void ReadTriaNodes( int* node1, int* node2, int* node3, int* domain )
  {
    integer vtx[3], tag;
    status_t ret = mesh_get_triangle_vertices( _hexa_mesh, _count, vtx);
    if (ret != STATUS_OK) MG_Error( "unable to get resulting triangle" );

    *node1 = vtx[0];
    *node2 = vtx[1];
    *node3 = vtx[2];

    ret = mesh_get_triangle_tag( _hexa_mesh, _count, &tag );
    if (ret != STATUS_OK) MG_Error( "unable to get resulting triangle tag" );

    *domain = tag;

    ++_count;
  }

  void ReadQuadNodes( int* node1, int* node2, int* node3, int* node4, int* domain )
  {
    integer vtx[4], tag;
    status_t ret = mesh_get_quadrangle_vertices( _hexa_mesh, _count, vtx);
    if (ret != STATUS_OK) MG_Error( "unable to get resulting quadrangle" );

    *node1 = vtx[0];
    *node2 = vtx[1];
    *node3 = vtx[2];
    *node4 = vtx[3];

    ret = mesh_get_quadrangle_tag( _hexa_mesh, _count, &tag );
    if (ret != STATUS_OK) MG_Error( "unable to get resulting quadrangle tag" );

    *domain = tag;

    ++_count;
  }

  void ReadTetraNodes( int* node1, int* node2, int* node3, int* node4, int* domain )
  {
    integer vtx[4], tag;
    status_t ret = mesh_get_tetrahedron_vertices( _hexa_mesh, _count, vtx);
    if (ret != STATUS_OK) MG_Error( "unable to get resulting tetrahedron" );

    *node1 = vtx[0];
    *node2 = vtx[1];
    *node3 = vtx[2];
    *node4 = vtx[3];

    ret = mesh_get_tetrahedron_tag( _hexa_mesh, _count, &tag );
    if (ret != STATUS_OK) MG_Error( "unable to get resulting tetrahedron tag" );

    *domain = tag;

    ++_count;
  }

  void ReadHexaNodes( int* node1, int* node2, int* node3, int* node4,
                      int* node5, int* node6, int* node7, int* node8, int* domain )
  {
    integer vtx[8], tag;
    status_t ret = mesh_get_hexahedron_vertices( _hexa_mesh, _count, vtx);
    if (ret != STATUS_OK) MG_Error( "unable to get resulting hexahedron" );

    *node1 = vtx[0];
    *node2 = vtx[1];
    *node3 = vtx[2];
    *node4 = vtx[3];
    *node5 = vtx[4];
    *node6 = vtx[5];
    *node7 = vtx[6];
    *node8 = vtx[7];

    ret = mesh_get_hexahedron_tag( _hexa_mesh, _count, &tag );
    if (ret != STATUS_OK) MG_Error( "unable to get resulting hexahedron tag" );

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
    MG_Hexotic_API::LibData* data = (MG_Hexotic_API::LibData *) user_data;
    *nbvtx = data->NbNodes();

    return STATUS_OK;
  }

  status_t get_vertex_coordinates(integer ivtx, real * xyz, void *user_data)
  {
    MG_Hexotic_API::LibData* data = (MG_Hexotic_API::LibData *) user_data;
    double* coord = data->NodeCoord( ivtx-1 );
    for (int j = 0; j < 3; j++)
      xyz[j] = coord[j];

    return STATUS_OK;
  }
  status_t get_edge_count(integer * nbedge, void *user_data)
  {
    MG_Hexotic_API::LibData* data = (MG_Hexotic_API::LibData *) user_data;
    *nbedge = data->NbEdges();

    return STATUS_OK;
  }

  status_t get_edge_vertices(integer iedge, integer * vedge, void *user_data)
  {
    MG_Hexotic_API::LibData* data = (MG_Hexotic_API::LibData *) user_data;
    int* nodes = data->GetEdgeNodes( iedge-1 );
    vedge[0] = nodes[0];
    vedge[1] = nodes[1];

    return STATUS_OK;
  }

  status_t get_edge_tag(integer iedge, integer * tag, void *user_data)
  {
    MG_Hexotic_API::LibData* data = (MG_Hexotic_API::LibData *) user_data;
    * tag = data->GetEdgeTag( iedge-1 );

    return STATUS_OK;
  }

  status_t get_triangle_count(integer * nbtri, void *user_data)
  {
    MG_Hexotic_API::LibData* data = (MG_Hexotic_API::LibData *) user_data;
    *nbtri = data->NbTriangles();

    return STATUS_OK;
  }

  status_t get_triangle_vertices(integer itri, integer * vtri, void *user_data)
  {
    MG_Hexotic_API::LibData* data = (MG_Hexotic_API::LibData *) user_data;
    int* nodes = data->GetTriaNodes( itri-1 );
    vtri[0] = nodes[0];
    vtri[1] = nodes[1];
    vtri[2] = nodes[2];

    return STATUS_OK;
  }

  status_t get_triangle_tag(integer itri, integer * tag, void *user_data)
  {
    MG_Hexotic_API::LibData* data = (MG_Hexotic_API::LibData *) user_data;
    * tag = data->GetTriaTag( itri-1 );

    return STATUS_OK;
  }

  // status_t get_triangle_extra_vertices(integer itri, integer * typetri,
  //                                      integer * evtri, void *user_data)
  // {
  //   int j;
  //   MG_Hexotic_API::LibData* data = (MG_Hexotic_API::LibData *) user_data;

  //   if (1) {
  //     /* We want to describe a linear "3 nodes" triangle */
  //     *typetri = MESHGEMS_MESH_ELEMENT_TYPE_TRIA3;
  //   } else {
  //     /* We want to describe a quadratic "6 nodes" triangle */
  //     *typetri = MESHGEMS_MESH_ELEMENT_TYPE_TRIA6;
  //     for (j = 0; j < 3; j++)
  //       evtri[j] = 0;             /* the j'th quadratic vertex index of the itri'th triangle */
  //   }

  //   return STATUS_OK;
  // }

  // status_t get_tetrahedron_count(integer * nbtetra, void *user_data)
  // {
  //   MG_Hexotic_API::LibData* data = (MG_Hexotic_API::LibData *) user_data;

  //   *nbtetra = 0;                 /* the number of tetra in your input mesh (0 if you describe a surface mesh) */

  //   return STATUS_OK;
  // }

  // status_t get_tetrahedron_vertices(integer itetra, integer * vtetra,
  //                                   void *user_data)
  // {
  //   int j;
  //   MG_Hexotic_API::LibData* data = (MG_Hexotic_API::LibData *) user_data;

  //   for (j = 0; j < 4; j++)
  //     vtetra[j] = 0;              /* the j'th vertex index of the itetra'th tetrahedron */

  //   return STATUS_OK;
  // }

  status_t get_vertex_required_property(integer ivtx, integer * rvtx, void *user_data)
  {
    MG_Hexotic_API::LibData* data = (MG_Hexotic_API::LibData *) user_data;
    *rvtx = data->IsVertexRequired( ivtx - 1 );

    return STATUS_OK;
  }

  status_t get_vertex_weight(integer ivtx, real * wvtx, void *user_data)
  {
    MG_Hexotic_API::LibData* data = (MG_Hexotic_API::LibData *) user_data;
    *wvtx = data->GetSizeAtVertex( ivtx - 1 );

    return STATUS_OK;
  }

  status_t my_message_cb(message_t * msg, void *user_data)
  {
    char *desc;
    message_get_description(msg, &desc);

    MG_Hexotic_API::LibData* data = (MG_Hexotic_API::LibData *) user_data;
    data->AddError( desc );

#ifdef _DEBUG_
    //std::cout << desc << std::endl;
#endif

    // Compute progress
    // corresponding messages are:
    // " | Analyzing the surface mesh |"         => 1 %
    // " | Building and conforming the octree |" => 8 %
    // " | Subdomains and boundary recovery |"   => 15%
    // " | Mesh bending and smoothing |"         => 45%
    // " | Final mesh statistics |"              => 99%

    double newProgress = std::min( 0.99, data->_progress + data->_msgCost );
    if ( strlen( desc ) > 25 )
    {
      if      ( strncmp( desc+3, "Analyzing the surface mesh", 26 ) == 0 )
        newProgress = 0.01, data->_msgCost = ( 0.08 - 0.01 ) / 10;
      else if ( strncmp( desc+3, "Building and conforming the octree", 34 ) == 0 )
        newProgress = 0.08, data->_msgCost = ( 0.15 - 0.08 ) / 100;
      else if ( strncmp( desc+3, "Subdomains and boundary recovery", 32 ) == 0 )
        newProgress = 0.15, data->_msgCost = ( 0.45 - 0.15 ) / 20;
      else if ( strncmp( desc+3, "Mesh bending and smoothing", 26 ) == 0 )
        newProgress = 0.45, data->_msgCost = ( 0.99 - 0.45 ) / 65;
      else if ( strncmp( desc+3, "Final mesh statistics", 21 ) == 0 )
        newProgress = 0.99;
    }
    data->_progress = std::max( data->_progress, newProgress );

    return STATUS_OK;
  }

  status_t my_interrupt_callback(integer *interrupt_status, void *user_data)
  {
    MG_Hexotic_API::LibData* data = (MG_Hexotic_API::LibData *) user_data;
    *interrupt_status = ( data->Cancelled() ? INTERRUPT_STOP : INTERRUPT_CONTINUE );

    return STATUS_OK;
  }

} // end namespace


void MG_Hexotic_API::LibData::Init()
{
  status_t ret;

  // Create the meshgems working context
  _context = context_new();
  if ( !_context ) MG_Error( "unable to create a new context" );

  // Set the message callback for the _context.
  ret = context_set_message_callback( _context, my_message_cb, this );
  if ( ret != STATUS_OK ) MG_Error("in context_set_message_callback");

  // Create the structure holding the callbacks giving access to triangle mesh
  _tria_mesh = mesh_new( _context );
  if ( !_tria_mesh ) MG_Error("unable to create a new mesh");

  // Set callbacks to provide triangle mesh data
  mesh_set_get_vertex_count( _tria_mesh, get_vertex_count, this );
  mesh_set_get_vertex_coordinates( _tria_mesh, get_vertex_coordinates, this );
  mesh_set_get_vertex_required_property( _tria_mesh, get_vertex_required_property, this );
  mesh_set_get_edge_count( _tria_mesh, get_edge_count, this);
  mesh_set_get_edge_vertices( _tria_mesh, get_edge_vertices, this );
  mesh_set_get_edge_tag( _tria_mesh, get_edge_tag, this );
  mesh_set_get_triangle_count( _tria_mesh, get_triangle_count, this );
  mesh_set_get_triangle_vertices( _tria_mesh, get_triangle_vertices, this );
  mesh_set_get_triangle_tag( _tria_mesh, get_triangle_tag, this );

  // Create a hexa session
  _session = hexa_session_new( _context );
  if ( !_session ) MG_Error( "unable to create a new hexa session");

  ret = hexa_set_interrupt_callback( _session, my_interrupt_callback, this );
  if ( ret != STATUS_OK ) MG_Error("in hexa_set_interrupt_callback");

}

bool MG_Hexotic_API::LibData::Compute()
{
  // MG license
  std::string errorTxt;
  status_t ret;

  if ( !SMESHUtils_MGLicenseKeyGen::SignMesh( _tria_mesh, "hexa", errorTxt ))
  {
    AddError( SMESH_Comment( "Problem with library SalomeMeshGemsKeyGenerator: ") << errorTxt );
    return false;
  }

  // Set surface mesh
  ret = hexa_set_surface_mesh( _session, _tria_mesh );
  if ( ret != STATUS_OK ) MG_Error( "unable to set surface mesh");

  // Set a sizemap
  if ( !_nodeSize.empty() )
  {
    _sizemap = meshgems_sizemap_new( _tria_mesh, meshgems_sizemap_type_iso_mesh_vertex,
                                     (void*) &get_vertex_weight, this );
    if ( !_sizemap ) MG_Error("unable to create a new sizemap");

    ret = hexa_set_sizemap( _session, _sizemap );
    if ( ret != STATUS_OK ) MG_Error( "unable to set sizemap");
  }

  //////////////////////////////////////////////////////////////////////////////////////////
  // const char* file  =  "/tmp/ghs3d_IN.mesh";
  // mesh_write_mesh( _tria_mesh,file);
  // std::cout << std::endl << std::endl << "Write " << file << std::endl << std::endl << std::endl;

  ret = hexa_compute_mesh( _session );
  if ( ret != STATUS_OK ) return false;

  ret = hexa_get_mesh( _session, &_hexa_mesh);
  if (ret != STATUS_OK) MG_Error( "unable to get resulting mesh");

  //////////////////////////////////////////////////////////////////////////////////////////
  // file  =  "/tmp/ghs3d_OUT.mesh";
  // mesh_write_mesh( _hexa_mesh,file);
  // std::cout << std::endl << std::endl << "Write " << file << std::endl << std::endl << std::endl;

  return true;
}

#else // ifdef USE_MG_LIBS

struct MG_Hexotic_API::LibData // to avoid compiler warnings
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

MG_Hexotic_API::MG_Hexotic_API(volatile bool& cancelled_flag, double& progress):
  _isMesh(true), _nbNodes(0), _nbEdges(0), _nbFaces(0), _nbVolumes(0)
{
  _useLib = false;
  _libData = new LibData( cancelled_flag, progress );
#ifdef USE_MG_LIBS
  _useLib = true;
  _libData->Init();
  if ( getenv("MG_HEXA_USE_EXE"))
    _useLib = false;
#endif
}

//================================================================================
/*!
 * \brief Destructor
 */
//================================================================================

MG_Hexotic_API::~MG_Hexotic_API()
{
#ifdef USE_MG_LIBS
  delete _libData;
  _libData = 0;
#endif
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

bool MG_Hexotic_API::IsLibrary()
{
  return _useLib;
}

//================================================================================
/*!
 * \brief Switch to usage of MG-Hexa executable
 */
//================================================================================

void MG_Hexotic_API::SetUseExecutable()
{
  _useLib = false;
}

//================================================================================
/*!
 * \brief Compute the hexa mesh
 *  \param [in] cmdLine - a command to run mg_hexa.exe
 *  \return bool - Ok or not
 */
//================================================================================

bool MG_Hexotic_API::Compute( const std::string& cmdLine, std::string& errStr )
{
  if ( _useLib ) {
#ifdef USE_MG_LIBS

    // split cmdLine
    std::istringstream strm( cmdLine );
    std::istream_iterator<std::string> sIt( strm ), sEnd;
    std::vector< std::string > args( sIt, sEnd );

    // set parameters
    std::string param, value;
    for ( size_t i = 1; i < args.size(); ++i )
    {
      // look for a param name; it starts from "-"
      param = args[i];
      if ( param.size() < 2 || param[0] != '-')
        continue;
      while ( param[0] == '-')
        param = param.substr( 1 );

      value = "";
      while ( i+1 < args.size() && args[i+1][0] != '-' )
      {
        if ( strncmp( "1>", args[i+1].c_str(), 2 ) == 0 )
          break;
        if ( !value.empty() ) value += " ";
        value += args[++i];
      }
      if ( !_libData->SetParam( param, value ))
        std::cout << "Warning: wrong param: '" << param <<"' = '" << value << "'" << std::endl;
    }

    // compute
    bool ok = _libData->Compute();

    GetLog(); // write a log file
    _logFile = ""; // not to write it again

    return ok;
#endif
  }
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
    errStr = SMESH_Comment("system(mg-hexa.exe ...) command failed with error: ")
      << strerror( errno );

  return !err;

}

//================================================================================
/*!
 * \brief Prepare for reading a mesh data
 */
//================================================================================

int  MG_Hexotic_API::GmfOpenMesh(const char* theFile, int rdOrWr, int * ver, int * dim)
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

int MG_Hexotic_API::GmfStatKwd( int iMesh, GmfKwdCod what )
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

void MG_Hexotic_API::GmfGotoKwd( int iMesh, GmfKwdCod what )
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

void MG_Hexotic_API::GmfGetLin( int iMesh, GmfKwdCod what, int* nbNodes, int* faceInd, int* ori, int* domain, int /*dummy*/ )
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

void MG_Hexotic_API::GmfGetLin(int iMesh, GmfKwdCod what,
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

void MG_Hexotic_API::GmfGetLin(int iMesh, GmfKwdCod what,
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

void MG_Hexotic_API::GmfGetLin(int iMesh, GmfKwdCod what, int* node )
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

void MG_Hexotic_API::GmfGetLin(int iMesh, GmfKwdCod what, int* node1, int* node2, int* domain )
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

void MG_Hexotic_API::GmfGetLin(int iMesh, GmfKwdCod what,
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

void MG_Hexotic_API::GmfGetLin(int iMesh, GmfKwdCod what,
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

void MG_Hexotic_API::GmfGetLin(int iMesh, GmfKwdCod what,
                               int* node1, int* node2, int* node3, int* node4,
                               int* node5, int* node6, int* node7, int* node8,
                               int* domain )
{
  if ( _useLib ) {
#ifdef USE_MG_LIBS
    _libData->ReadHexaNodes( node1, node2, node3, node4,
                             node5, node6, node7, node8, domain );
    return;
#endif
  }
  ::GmfGetLin(iMesh, what, node1, node2, node3, node4, node5, node6, node7, node8, domain );
}

//================================================================================
/*!
 * \brief Prepare for passing data to MeshGems
 */
//================================================================================

int  MG_Hexotic_API::GmfOpenMesh(const char* theFile, int rdOrWr, int ver, int dim)
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

void MG_Hexotic_API::GmfSetKwd(int iMesh, GmfKwdCod what, int nb )
{
  if ( iMesh == 1 && _isMesh )
  {
    switch ( what ) {
    case GmfVertices:  _nbNodes += nb; break;
    case GmfEdges:     _nbEdges += nb; break;
    case GmfTriangles: _nbFaces += nb; break;
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
 * \brief Set GMF file made by MG-CADSurf to get nb of mesh entities from it
 */
//================================================================================

void MG_Hexotic_API::SetInputFile( const std::string mesh2DFile )
{
  DriverGMF_Read fileReader;
  fileReader.SetFile( mesh2DFile );

  smIdType nbVertex, nbEdge, nbFace, nbVol;
  if ( fileReader.GetMeshInfo(nbVertex, nbEdge, nbFace, nbVol))
  {
    _nbNodes += nbVertex;
    _nbEdges += nbEdge;
    _nbFaces += nbFace;
  }
}

//================================================================================
/*!
 * \brief Add coordinates of a node
 */
//================================================================================

void MG_Hexotic_API::GmfSetLin(int iMesh, GmfKwdCod what, double x, double y, double z, int domain)
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

void MG_Hexotic_API::GmfSetKwd(int iMesh, GmfKwdCod what, int nbNodes, int dummy, int type[] )
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

void MG_Hexotic_API::GmfSetLin(int iMesh, GmfKwdCod what, double vals[])
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

void MG_Hexotic_API::GmfSetLin(int iMesh, GmfKwdCod what, int node1, int node2, int domain )
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

void MG_Hexotic_API::GmfSetLin(int iMesh, GmfKwdCod what, int id )
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

void MG_Hexotic_API::GmfSetLin(int iMesh, GmfKwdCod what, int node1, int node2, int node3, int domain )
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
 * \brief Close a file
 */
//================================================================================

void MG_Hexotic_API::GmfCloseMesh( int iMesh )
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

bool MG_Hexotic_API::HasLog()
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

std::string MG_Hexotic_API::GetLog()
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
  return file.exists() ? file.getPos() : "";
}
