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
// File    : BLSURFPlugin_Hypothesis.cxx
// Authors : Francis KLOSS (OCC) & Patrick LAUG (INRIA) & Lioka RAZAFINDRAZAKA (CEA)
//           Size maps developement: Nicolas GEIMER (OCC) & Gilles DAVID (EURIWARE)
// ---
//
#include "BLSURFPlugin_Hypothesis_i.hxx"
#include "BLSURFPlugin_BLSURF.hxx"

#include <SMESH_Gen.hxx>
#include <SMESH_Gen_i.hxx>
#include <SMESH_Group_i.hxx>
#include <SMESH_PythonDump.hxx>

#include <SALOMEDS_wrap.hxx>
#include <Utils_CorbaException.hxx>
#include <utilities.h>

#include <stdexcept>
#include <cstring>
#include <boost/regex.hpp>

using namespace std;

namespace
{
  //================================================================================
  /*!
   * \brief Return persistent ID of a mesh
   *  \param [in] mesh - the mesh
   *  \return int - -1 in case of failure
   */
  //================================================================================

  int GetMeshPersistentId( SMESH::SMESH_Mesh_ptr mesh )
  {
    int id = -1;
    if ( SMESH_Mesh_i* mesh_i = SMESH::DownCast<SMESH_Mesh_i*>( mesh ))
      id = mesh_i->GetImpl().GetMeshDS()->GetPersistentId();
    return id;
  }

  //================================================================================
  /*!
   * \brief Return persistent ID of a group or sub-mesh
   *  \param [in] meshPart - the mesh part
   *  \param [out] isGroup - return true if meshPart is a group
   *  \return int - -1 in case if meshPart is neither a group nor a sub-mesh
   */
  //================================================================================

  int GetMeshPartPersistentId( SMESH::SMESH_IDSource_ptr meshPart, bool & isGroup )
  {
    int id = -1;
    isGroup = false;
    SMESH_GroupBase_i* group_i = SMESH::DownCast<SMESH_GroupBase_i*>( meshPart );
    if ( group_i )
    {
      id = group_i->GetLocalID();
      isGroup = true;
    }
    else
    {
      SMESH::SMESH_subMesh_var subMesh = SMESH::SMESH_subMesh::_narrow( meshPart );
      if ( !subMesh->_is_nil() )
        id = subMesh->GetId();
    }
    return id;
  }

  //================================================================================
  /*!
   * \brief Find a mesh in the study by mesh persistent ID
   */
  //================================================================================

  SMESH::SMESH_Mesh_ptr FindMeshByID( int theMeshID )
  {
    SMESH::SMESH_Mesh_var mesh;

    SMESH_Gen_i*                gen = SMESH_Gen_i::GetSMESHGen();
    CORBA::String_var  compDataType = gen->ComponentDataType();
    SALOMEDS::Study_var      aStudy = gen->getStudyServant();
    SALOMEDS::SComponent_wrap genSO = aStudy->FindComponent( compDataType.in() );
    if ( !genSO->_is_nil() )
    {
      SALOMEDS::ChildIterator_wrap anIter = aStudy->NewChildIterator( genSO );
      for ( ; anIter->More(); anIter->Next() )
      {
        SALOMEDS::SObject_wrap so = anIter->Value();
        CORBA::Object_var      obj = gen->SObjectToObject( so );
        mesh = SMESH::SMESH_Mesh::_narrow( obj );
        if ( !mesh->_is_nil() && GetMeshPersistentId( mesh ) == theMeshID )
          break;
        mesh = SMESH::SMESH_Mesh::_nil();
      }
    }
    return mesh._retn();
  }

  //================================================================================
  /*!
   * \brief Return a group by its ID
   */
  //================================================================================

  SMESH::SMESH_GroupBase_ptr GetGroupByID( SMESH::SMESH_Mesh_ptr mesh, int ID )
  {
    SMESH::SMESH_GroupBase_var group;
    if ( !CORBA::is_nil( mesh ))
    {
      SMESH::ListOfGroups_var groups = mesh->GetGroups();
      for ( CORBA::ULong i = 0; i < groups->length(); ++i )
        if ( SMESH_GroupBase_i* group_i = SMESH::DownCast<SMESH_GroupBase_i*>( groups[i] ))
          if ( group_i->GetLocalID() == ID )
          {
            group = SMESH::SMESH_GroupBase::_narrow( groups[i] );
            break;
          }
    }
    return group._retn();
  }

  //================================================================================
  /*!
   * \brief Return a sub-mesh by sub-shape ID
   */
  //================================================================================

  SMESH::SMESH_subMesh_ptr GetSubMeshByID( SMESH::SMESH_Mesh_ptr mesh,
                                           const int             shapeID,
                                           CORBA::Long           subMeshTag )
  {
    SMESH::SMESH_subMesh_var subMesh;
    if ( !CORBA::is_nil( mesh ))
    {
      SMESH_Gen_i*              gen = SMESH_Gen_i::GetSMESHGen();
      SALOMEDS::SObject_wrap meshSO = gen->ObjectToSObject( mesh );
      SALOMEDS::Study_var    aStudy = gen->getStudyServant();
      SALOMEDS::SObject_wrap subMeshRootSO;
      if ( !meshSO->_is_nil() && meshSO->FindSubObject( subMeshTag, subMeshRootSO.inout() ))
      {
        SALOMEDS::ChildIterator_wrap anIter = aStudy->NewChildIterator( subMeshRootSO );
        for ( ; anIter->More(); anIter->Next() )
        {
          SALOMEDS::SObject_wrap so = anIter->Value();
          CORBA::Object_var      obj = gen->SObjectToObject( so );
          subMesh = SMESH::SMESH_subMesh::_narrow( obj );
          if ( !subMesh->_is_nil() && subMesh->GetId() == shapeID )
            break;
          subMesh = SMESH::SMESH_subMesh::_nil();
        }
      }
      return subMesh._retn();
    }
    return subMesh._retn();
  }

} // namespace

//=============================================================================
/*!
 *  BLSURFPlugin_Hypothesis_i::BLSURFPlugin_Hypothesis_i
 *
 *  Constructor
 */
//=============================================================================
BLSURFPlugin_Hypothesis_i::BLSURFPlugin_Hypothesis_i(PortableServer::POA_ptr thePOA,
                                                     ::SMESH_Gen*            theGenImpl,
                                                     bool                    theHasGEOM) :
  SALOME::GenericObj_i(thePOA), SMESH_Hypothesis_i(thePOA)
{
  myBaseImpl = new ::BLSURFPlugin_Hypothesis(theGenImpl->GetANewId(),
                                             
                                             theGenImpl,
                                             theHasGEOM);
}

//=============================================================================
/*!
 *  BLSURFPlugin_Hypothesis_i::~BLSURFPlugin_Hypothesis_i
 *
 *  Destructor
 */
//=============================================================================
BLSURFPlugin_Hypothesis_i::~BLSURFPlugin_Hypothesis_i()
{
}

//=============================================================================
/*!
 *  BLSURFPlugin_Hypothesis_i::GetMeshGemsVersion
 *
 *  Get version of MeshGems suite.
 */
//=============================================================================
char* BLSURFPlugin_Hypothesis_i::GetMeshGemsVersion()
{
  return CORBA::string_dup( this->GetImpl()->GetMeshGemsVersion().c_str() );
}

//=============================================================================
/*!
 *  BLSURFPlugin_Hypothesis_i::SetPhysicalMesh
 *
 *  Set PhysicalMesh
 */
//=============================================================================
void BLSURFPlugin_Hypothesis_i::SetPhysicalMesh(CORBA::Long theValue)
{
  ASSERT(myBaseImpl);
  this->GetImpl()->SetPhysicalMesh((::BLSURFPlugin_Hypothesis::PhysicalMesh) theValue);
  SMESH::TPythonDump() << _this() << ".SetPhysicalMesh( " << theValue << " )";
}

//=============================================================================
/*!
 *  BLSURFPlugin_Hypothesis_i::GetPhysicalMesh
 *
 *  Get PhysicalMesh
 */
//=============================================================================
CORBA::Long BLSURFPlugin_Hypothesis_i::GetPhysicalMesh()
{
  ASSERT(myBaseImpl);
  return this->GetImpl()->GetPhysicalMesh();
}

//=============================================================================
/*!
 *  BLSURFPlugin_Hypothesis_i::SetGeometricMesh
 *
 *  Set GeometricMesh
 */

//=============================================================================
void BLSURFPlugin_Hypothesis_i::SetGeometricMesh(CORBA::Long theValue)
{
  ASSERT(myBaseImpl);
  this->GetImpl()->SetGeometricMesh((::BLSURFPlugin_Hypothesis::GeometricMesh) theValue);
  SMESH::TPythonDump() << _this() << ".SetGeometricMesh( " << theValue << " )";
}

//=============================================================================
/*!
 *  BLSURFPlugin_Hypothesis_i::GetGeometricMesh
 *
 *  Get GeometricMesh
 */
//=============================================================================
CORBA::Long BLSURFPlugin_Hypothesis_i::GetGeometricMesh()
{
  ASSERT(myBaseImpl);
  return this->GetImpl()->GetGeometricMesh();
}

//=============================================================================
/*!
 *  BLSURFPlugin_Hypothesis_i::SetPhySize
 *
 *  Set PhySize
 */
//=============================================================================
void BLSURFPlugin_Hypothesis_i::SetPhySize(CORBA::Double theValue)
{
  ASSERT(myBaseImpl);
  this->GetImpl()->SetPhySize(theValue, false);
  SMESH::TPythonDump() << _this() << ".SetPhySize( " << theValue << " )";
}

//=============================================================================
/*!
 *  BLSURFPlugin_Hypothesis_i::SetPhySizeRel
 *
 *  Set Relative PhySize
 */
//=============================================================================
void BLSURFPlugin_Hypothesis_i::SetPhySizeRel(CORBA::Double theValue)
{
  ASSERT(myBaseImpl);
  this->GetImpl()->SetPhySize(theValue, true);
  SMESH::TPythonDump() << _this() << ".SetPhySizeRel( " << theValue << " )";
}

//=============================================================================
/*!
 *  BLSURFPlugin_Hypothesis_i::GetPhySize
 *
 *  Get PhySize
 */
//=============================================================================
CORBA::Double BLSURFPlugin_Hypothesis_i::GetPhySize()
{
  ASSERT(myBaseImpl);
  return this->GetImpl()->GetPhySize();
}

//=============================================================================
/*!
 *  BLSURFPlugin_Hypothesis_i::IsPhySizeRel
 *
 *  Returns True if PhySize is relative
 */
//=============================================================================
CORBA::Boolean BLSURFPlugin_Hypothesis_i::IsPhySizeRel()
{
  ASSERT(myBaseImpl);
  return this->GetImpl()->IsPhySizeRel();
}

//=============================================================================
void BLSURFPlugin_Hypothesis_i::SetMinSize(CORBA::Double theMinSize)
{
  if (IsMinSizeRel() || GetMinSize() != theMinSize ) {
    this->GetImpl()->SetMinSize(theMinSize, false);
    SMESH::TPythonDump() << _this() << ".SetMinSize( " << theMinSize << " )";
  }
}

//=============================================================================
void BLSURFPlugin_Hypothesis_i::SetMinSizeRel(CORBA::Double theMinSize)
{
  if ( !IsMinSizeRel() || (GetMinSize() != theMinSize) ) {
    this->GetImpl()->SetMinSize(theMinSize, true);
    SMESH::TPythonDump() << _this() << ".SetMinSizeRel( " << theMinSize << " )";
  }
}

//=============================================================================
CORBA::Double BLSURFPlugin_Hypothesis_i::GetMinSize()
{
  return this->GetImpl()->GetMinSize();
}

//=============================================================================
CORBA::Boolean BLSURFPlugin_Hypothesis_i::IsMinSizeRel()
{
  return this->GetImpl()->IsMinSizeRel();
}

//=============================================================================
void BLSURFPlugin_Hypothesis_i::SetMaxSize(CORBA::Double theMaxSize)
{
  if (IsMaxSizeRel() || GetMaxSize() != theMaxSize) {
    this->GetImpl()->SetMaxSize(theMaxSize, false);
    SMESH::TPythonDump() << _this() << ".SetMaxSize( " << theMaxSize << " )";
  }
}

//=============================================================================
void BLSURFPlugin_Hypothesis_i::SetMaxSizeRel(CORBA::Double theMaxSize)
{
  if ( !IsMaxSizeRel() || (GetMaxSize() != theMaxSize) ) {
    this->GetImpl()->SetMaxSize(theMaxSize, true);
    SMESH::TPythonDump() << _this() << ".SetMaxSizeRel( " << theMaxSize << " )";
  }
}

//=============================================================================
CORBA::Double BLSURFPlugin_Hypothesis_i::GetMaxSize()
{
  return this->GetImpl()->GetMaxSize();
}

//=============================================================================
CORBA::Boolean BLSURFPlugin_Hypothesis_i::IsMaxSizeRel()
{
  return this->GetImpl()->IsMaxSizeRel();
}


//=============================================================================
/*!
 *  BLSURFPlugin_Hypothesis_i::SetUseGradation
 *
 *  Set true or false
 */
//=============================================================================
void BLSURFPlugin_Hypothesis_i::SetUseGradation(CORBA::Boolean theValue)
{
  if ( GetImpl()->GetUseGradation() != bool( theValue ))
  {
    this->GetImpl()->SetUseGradation(theValue);
    std::string theValueStr = theValue ? "True" : "False";
    SMESH::TPythonDump() << _this() << ".SetUseGradation( " << theValueStr.c_str() << " )";
  }
}

//=============================================================================
/*!
 *  BLSURFPlugin_Hypothesis_i::GetUseGradation
 *
 *  Get true or false
 */
//=============================================================================
CORBA::Boolean BLSURFPlugin_Hypothesis_i::GetUseGradation()
{
  return this->GetImpl()->GetUseGradation();
}

//=============================================================================
/*!
 *  BLSURFPlugin_Hypothesis_i::SetGradation
 *
 *  Set Gradation
 */
//=============================================================================
void BLSURFPlugin_Hypothesis_i::SetGradation(CORBA::Double theValue)
{
  this->GetImpl()->SetGradation(theValue);

  if ( theValue < 0 )
    SetUseGradation( false );
  else
    SMESH::TPythonDump() << _this() << ".SetGradation( " << theValue << " )";
}

//=============================================================================
/*!
 *  BLSURFPlugin_Hypothesis_i::GetGradation
 *
 *  Get Gradation
 */
//=============================================================================
CORBA::Double BLSURFPlugin_Hypothesis_i::GetGradation()
{
  return this->GetImpl()->GetGradation();
}

//=============================================================================
/*!
 *  BLSURFPlugin_Hypothesis_i::SetUseVolumeGradation
 *
 *  Set true or false
 */
//=============================================================================
void BLSURFPlugin_Hypothesis_i::SetUseVolumeGradation(CORBA::Boolean theValue)
{
  if ( GetImpl()->GetUseVolumeGradation() != bool( theValue ))
  {
    this->GetImpl()->SetUseVolumeGradation(theValue);
    std::string theValueStr = theValue ? "True" : "False";
    SMESH::TPythonDump() << _this() << ".SetUseVolumeGradation( " << theValueStr.c_str() << " )";
  }
}

//=============================================================================
/*!
 *  BLSURFPlugin_Hypothesis_i::GetUseVolumeGradation
 *
 *  Get true or false
 */
//=============================================================================
CORBA::Boolean BLSURFPlugin_Hypothesis_i::GetUseVolumeGradation()
{
  return this->GetImpl()->GetUseVolumeGradation();
}

//=============================================================================
/*!
 *  BLSURFPlugin_Hypothesis_i::SetVolumeGradation
 *
 *  Set VolumeGradation
 */
//=============================================================================
void BLSURFPlugin_Hypothesis_i::SetVolumeGradation(CORBA::Double theValue)
{
  this->GetImpl()->SetVolumeGradation(theValue);
  if ( theValue < 0 )
    SetUseVolumeGradation( false );
  else
    SMESH::TPythonDump() << _this() << ".SetVolumeGradation( " << theValue << " )";
}

//=============================================================================
/*!
 *  BLSURFPlugin_Hypothesis_i::GetVolumeGradation
 *
 *  Get VolumeGradation
 */
//=============================================================================
CORBA::Double BLSURFPlugin_Hypothesis_i::GetVolumeGradation()
{
  return this->GetImpl()->GetVolumeGradation();
}

//=============================================================================
/*!
 *  BLSURFPlugin_Hypothesis_i::SetQuadAllowed
 *
 *  Set true or false
 *
 *  DEPRACATED, kept for python script compatibility
 *
 *  TO be removed in Salome 9
 */
//=============================================================================
void BLSURFPlugin_Hypothesis_i::SetQuadAllowed(CORBA::Boolean theValue)
{
  ::BLSURFPlugin_Hypothesis::ElementType theElementType = theValue ?
                  ::BLSURFPlugin_Hypothesis::QuadrangleDominant : ::BLSURFPlugin_Hypothesis::Triangles;
  this->GetImpl()->SetElementType(theElementType);
  SMESH::TPythonDump() << _this() << ".SetElementType( " << theElementType << " )";
}

//=============================================================================
/*!
 *  BLSURFPlugin_Hypothesis_i::SetElementType
 *
 *  Set ElementType
 */
//=============================================================================
void BLSURFPlugin_Hypothesis_i::SetElementType(CORBA::Long theValue)
{
  this->GetImpl()->SetElementType((::BLSURFPlugin_Hypothesis::ElementType) theValue);
  SMESH::TPythonDump() << _this() << ".SetElementType( " << theValue << " )";
}
//=============================================================================
/*!
 *  BLSURFPlugin_Hypothesis_i::GetElementType
 *
 *  Get ElementType
 */
//=============================================================================
CORBA::Long BLSURFPlugin_Hypothesis_i::GetElementType()
{
  return this->GetImpl()->GetElementType();
}

//=============================================================================
/*!
 *  BLSURFPlugin_Hypothesis_i::SetAngleMesh
 *
 *  Set AngleMesh
 */
//=============================================================================
void BLSURFPlugin_Hypothesis_i::SetAngleMesh(CORBA::Double theValue)
{
  this->GetImpl()->SetAngleMesh(theValue);
  SMESH::TPythonDump() << _this() << ".SetAngleMesh( " << theValue << " )";
}

//=============================================================================
/*!
 *  BLSURFPlugin_Hypothesis_i::GetAngleMesh
 *
 *  Get AngleMesh
 */
//=============================================================================
CORBA::Double BLSURFPlugin_Hypothesis_i::GetAngleMesh()
{
  return this->GetImpl()->GetAngleMesh();
}

//=============================================================================
/*!
 *  BLSURFPlugin_Hypothesis_i::SetChordalError
 *
 *  Set Chordal Error
 */
//=============================================================================
void BLSURFPlugin_Hypothesis_i::SetChordalError(CORBA::Double theValue)
{
  this->GetImpl()->SetChordalError(theValue);
  SMESH::TPythonDump() << _this() << ".SetChordalError( " << theValue << " )";
}

//=============================================================================
/*!
 *  BLSURFPlugin_Hypothesis_i::GetChordalError
 *
 *  Get Chordal Error
 */
//=============================================================================
CORBA::Double BLSURFPlugin_Hypothesis_i::GetChordalError()
{
  return this->GetImpl()->GetChordalError();
}

//=============================================================================
/*!
 *  BLSURFPlugin_Hypothesis_i::SetAnisotropic
 *
 *  Set true or false
 */
//=============================================================================
void BLSURFPlugin_Hypothesis_i::SetAnisotropic(CORBA::Boolean theValue)
{
  this->GetImpl()->SetAnisotropic(theValue);
  std::string theValueStr = theValue ? "True" : "False";
  SMESH::TPythonDump() << _this() << ".SetAnisotropic( " << theValueStr.c_str() << " )";
}

//=============================================================================
/*!
 *  BLSURFPlugin_Hypothesis_i::GetAnisotropic
 *
 *  Get true or false
 */
//=============================================================================
CORBA::Boolean BLSURFPlugin_Hypothesis_i::GetAnisotropic()
{
  return this->GetImpl()->GetAnisotropic();
}

//=============================================================================
/*!
 *  BLSURFPlugin_Hypothesis_i::SetAnisotropicRatio
 *
 *  Set Anisotropic Ratio
 */
//=============================================================================
void BLSURFPlugin_Hypothesis_i::SetAnisotropicRatio(CORBA::Double theValue)
{
  this->GetImpl()->SetAnisotropicRatio(theValue);
  SMESH::TPythonDump() << _this() << ".SetAnisotropicRatio( " << theValue << " )";
}

//=============================================================================
/*!
 *  BLSURFPlugin_Hypothesis_i::GetAnisotropicRatio
 *
 *  Get Anisotropic Ratio
 */
//=============================================================================
CORBA::Double BLSURFPlugin_Hypothesis_i::GetAnisotropicRatio()
{
  return this->GetImpl()->GetAnisotropicRatio();
}


//=============================================================================
/*!
 *  BLSURFPlugin_Hypothesis_i::SetRemoveTinyEdges
 *
 *  Set true or false
 */
//=============================================================================
void BLSURFPlugin_Hypothesis_i::SetRemoveTinyEdges(CORBA::Boolean theValue) {
  ASSERT(myBaseImpl);
  this->GetImpl()->SetRemoveTinyEdges(theValue);
  std::string theValueStr = theValue ? "True" : "False";
  SMESH::TPythonDump() << _this() << ".SetRemoveTinyEdges( " << theValueStr.c_str() << " )";
}

//=============================================================================
/*!
 *  BLSURFPlugin_Hypothesis_i::GetRemoveTinyEdges
 *
 *  Get true or false
 */
//=============================================================================
CORBA::Boolean BLSURFPlugin_Hypothesis_i::GetRemoveTinyEdges() {
  ASSERT(myBaseImpl);
  return this->GetImpl()->GetRemoveTinyEdges();
}

//=============================================================================
/*!
 *  BLSURFPlugin_Hypothesis_i::SetTinyEdgeLength
 *
 *  Set Tiny Edge Length
 */
//=============================================================================
void BLSURFPlugin_Hypothesis_i::SetTinyEdgeLength(CORBA::Double theValue) {
  ASSERT(myBaseImpl);
  this->GetImpl()->SetTinyEdgeLength(theValue);
  SMESH::TPythonDump() << _this() << ".SetTinyEdgeLength( " << theValue << " )";
}

//=============================================================================
/*!
 *  BLSURFPlugin_Hypothesis_i::GetTinyEdgeLength
 *
 *  Get Tiny Edge Length
 */
//=============================================================================
CORBA::Double BLSURFPlugin_Hypothesis_i::GetTinyEdgeLength() {
  ASSERT(myBaseImpl);
  return this->GetImpl()->GetTinyEdgeLength();
}

//=============================================================================
/*!
 *  BLSURFPlugin_Hypothesis_i::SetOptimiseTinyEdges
 *
 *  Set true or false
 */
//=============================================================================
void BLSURFPlugin_Hypothesis_i::SetOptimiseTinyEdges(CORBA::Boolean theValue) {
  ASSERT(myBaseImpl);
  this->GetImpl()->SetOptimiseTinyEdges(theValue);
  std::string theValueStr = theValue ? "True" : "False";
  SMESH::TPythonDump() << _this() << ".SetOptimiseTinyEdges( " << theValueStr.c_str() << " )";
}

//=============================================================================
/*!
 *  BLSURFPlugin_Hypothesis_i::GetOptimiseTinyEdges
 *
 *  Get true or false
 */
//=============================================================================
CORBA::Boolean BLSURFPlugin_Hypothesis_i::GetOptimiseTinyEdges() {
  ASSERT(myBaseImpl);
  return this->GetImpl()->GetOptimiseTinyEdges();
}

//=============================================================================
/*!
 *  BLSURFPlugin_Hypothesis_i::SetTinyEdgeOptimisationLength
 *
 *  Set Tiny Edge OptimisationLength
 */
//=============================================================================
void BLSURFPlugin_Hypothesis_i::SetTinyEdgeOptimisationLength(CORBA::Double theValue) {
  ASSERT(myBaseImpl);
  this->GetImpl()->SetTinyEdgeOptimisationLength(theValue);
  SMESH::TPythonDump() << _this() << ".SetTinyEdgeOptimisationLength( " << theValue << " )";
}

//=============================================================================
/*!
 *  BLSURFPlugin_Hypothesis_i::GetTinyEdgeOptimisationLength
 *
 *  Get Tiny Edge OptimisationLength
 */
//=============================================================================
CORBA::Double BLSURFPlugin_Hypothesis_i::GetTinyEdgeOptimisationLength() {
  ASSERT(myBaseImpl);
  return this->GetImpl()->GetTinyEdgeOptimisationLength();
}

//=============================================================================
/*!
 *  BLSURFPlugin_Hypothesis_i::SetCorrectSurfaceIntersection
 *
 *  Set true or false
 */
//=============================================================================
void BLSURFPlugin_Hypothesis_i::SetCorrectSurfaceIntersection(CORBA::Boolean theValue) {
  ASSERT(myBaseImpl);
  this->GetImpl()->SetCorrectSurfaceIntersection(theValue);
  std::string theValueStr = theValue ? "True" : "False";
  SMESH::TPythonDump() << _this() << ".SetCorrectSurfaceIntersection( " << theValueStr.c_str() << " )";
}

//=============================================================================
/*!
 *  BLSURFPlugin_Hypothesis_i::GetCorrectSurfaceIntersection
 *
 *  Get true or false
 */
//=============================================================================
CORBA::Boolean BLSURFPlugin_Hypothesis_i::GetCorrectSurfaceIntersection() {
  ASSERT(myBaseImpl);
  return this->GetImpl()->GetCorrectSurfaceIntersection();
}

//=============================================================================
/*!
 *  BLSURFPlugin_Hypothesis_i::SetCorrectSurfaceIntersectionMaxCost
 *
 *  Set Tiny Edge OptimisationLength
 */
//=============================================================================
void BLSURFPlugin_Hypothesis_i::SetCorrectSurfaceIntersectionMaxCost(CORBA::Double theValue) {
  ASSERT(myBaseImpl);
  this->GetImpl()->SetCorrectSurfaceIntersectionMaxCost(theValue);
  SMESH::TPythonDump() << _this() << ".SetCorrectSurfaceIntersectionMaxCost( " << theValue << " )";
}

//=============================================================================
/*!
 *  BLSURFPlugin_Hypothesis_i::GetCorrectSurfaceIntersectionMaxCost
 *
 *  Get Tiny Edge OptimisationLength
 */
//=============================================================================
CORBA::Double BLSURFPlugin_Hypothesis_i::GetCorrectSurfaceIntersectionMaxCost() {
  ASSERT(myBaseImpl);
  return this->GetImpl()->GetCorrectSurfaceIntersectionMaxCost();
}

//=============================================================================
/*!
 *  BLSURFPlugin_Hypothesis_i::SetBadElementRemoval
 *
 *  Set true or false
 */
//=============================================================================
void BLSURFPlugin_Hypothesis_i::SetBadElementRemoval(CORBA::Boolean theValue) {
  ASSERT(myBaseImpl);
  this->GetImpl()->SetBadElementRemoval(theValue);
  std::string theValueStr = theValue ? "True" : "False";
  SMESH::TPythonDump() << _this() << ".SetBadElementRemoval( " << theValueStr.c_str() << " )";
}

//=============================================================================
/*!
 *  BLSURFPlugin_Hypothesis_i::GetBadElementRemoval
 *
 *  Get true or false
 */
//=============================================================================
CORBA::Boolean BLSURFPlugin_Hypothesis_i::GetBadElementRemoval() {
  ASSERT(myBaseImpl);
  return this->GetImpl()->GetBadElementRemoval();
}

//=============================================================================
/*!
 *  BLSURFPlugin_Hypothesis_i::SetBadElementAspectRatio
 *
 *  Set Bad Surface Element Aspect Ratio
 */
//=============================================================================
void BLSURFPlugin_Hypothesis_i::SetBadElementAspectRatio(CORBA::Double theValue) {
  ASSERT(myBaseImpl);
  this->GetImpl()->SetBadElementAspectRatio(theValue);
  SMESH::TPythonDump() << _this() << ".SetBadElementAspectRatio( " << theValue << " )";
}

//=============================================================================
/*!
 *  BLSURFPlugin_Hypothesis_i::GetBadElementAspectRatio
 *
 *  Get Bad Surface Element Aspect Ratio
 */
//=============================================================================
CORBA::Double BLSURFPlugin_Hypothesis_i::GetBadElementAspectRatio() {
  ASSERT(myBaseImpl);
  return this->GetImpl()->GetBadElementAspectRatio();
}

//=============================================================================
/*!
 *  BLSURFPlugin_Hypothesis_i::SetOptimizeMesh
 *
 *  Set true or false
 */
//=============================================================================
void BLSURFPlugin_Hypothesis_i::SetOptimizeMesh(CORBA::Boolean theValue) {
  ASSERT(myBaseImpl);
  this->GetImpl()->SetOptimizeMesh(theValue);
  std::string theValueStr = theValue ? "True" : "False";
  SMESH::TPythonDump() << _this() << ".SetOptimizeMesh( " << theValueStr.c_str() << " )";
}

//=============================================================================
/*!
 *  BLSURFPlugin_Hypothesis_i::GetOptimizeMesh
 *
 *  Get true or false
 */
//=============================================================================
CORBA::Boolean BLSURFPlugin_Hypothesis_i::GetOptimizeMesh() {
  ASSERT(myBaseImpl);
  return this->GetImpl()->GetOptimizeMesh();
}

//=============================================================================
/*!
 *  BLSURFPlugin_Hypothesis_i::SetQuadraticMesh
 *
 *  Set true or false
 */
//=============================================================================
void BLSURFPlugin_Hypothesis_i::SetQuadraticMesh(CORBA::Boolean theValue) {
  ASSERT(myBaseImpl);
  this->GetImpl()->SetQuadraticMesh(theValue);
  std::string theValueStr = theValue ? "True" : "False";
  SMESH::TPythonDump() << _this() << ".SetQuadraticMesh( " << theValueStr.c_str() << " )";
}

//=============================================================================
/*!
 *  BLSURFPlugin_Hypothesis_i::GetQuadraticMesh
 *
 *  Get true or false
 */
//=============================================================================
CORBA::Boolean BLSURFPlugin_Hypothesis_i::GetQuadraticMesh() {
  ASSERT(myBaseImpl);
  return this->GetImpl()->GetQuadraticMesh();
}





/*!
 *  BLSURFPlugin_Hypothesis_i::SetTopology
 *
 *  Set topology
 */

//=============================================================================
void BLSURFPlugin_Hypothesis_i::SetTopology(CORBA::Long theValue) {
  ASSERT(myBaseImpl);
  this->GetImpl()->SetTopology((::BLSURFPlugin_Hypothesis::Topology) theValue);
  SMESH::TPythonDump() << _this() << ".SetTopology( " << theValue << " )";
}

//=============================================================================
/*!
 *  BLSURFPlugin_Hypothesis_i::GetTopology
 *
 *  Get Topology
 */
//=============================================================================
CORBA::Long BLSURFPlugin_Hypothesis_i::GetTopology() {
  ASSERT(myBaseImpl);
  return this->GetImpl()->GetTopology();
}

//=============================================================================
/*!
 *  Activate/deactivate surface proximity computation
 */
void BLSURFPlugin_Hypothesis_i::SetSurfaceProximity( CORBA::Boolean toUse )
{
  if ( GetSurfaceProximity() != toUse )
  {
    this->GetImpl()->SetUseSurfaceProximity( toUse );
    SMESH::TPythonDump() << _this() << ".SetSurfaceProximity( " << toUse << " )";
  }
}

CORBA::Boolean BLSURFPlugin_Hypothesis_i::GetSurfaceProximity()
{
  return this->GetImpl()->GetUseSurfaceProximity();
}

//=============================================================================
/*!
 * Set number of surface element layers to be generated due to surface proximity
 */
void BLSURFPlugin_Hypothesis_i::SetNbSurfaceProximityLayers( CORBA::Short nbLayers )
{
  if ( GetNbSurfaceProximityLayers() != nbLayers )
  {
    this->GetImpl()->SetNbSurfaceProximityLayers( nbLayers );
    SMESH::TPythonDump() << _this() << ".SetNbSurfaceProximityLayers( " << nbLayers << " )";
  }
}

CORBA::Short BLSURFPlugin_Hypothesis_i::GetNbSurfaceProximityLayers()
{
  return (CORBA::Short) this->GetImpl()->GetNbSurfaceProximityLayers();
}

//=============================================================================
/*!
 * Set coefficient by which size of element refined due to surface proximity is increased
 */
void BLSURFPlugin_Hypothesis_i::SetSurfaceProximityRatio( CORBA::Double ratio )
{
  if ( GetSurfaceProximityRatio() != ratio )
  {
    this->GetImpl()->SetSurfaceProximityRatio( ratio );
    SMESH::TPythonDump() << _this() << ".SetSurfaceProximityRatio( " << ratio << " )";
  }
}

CORBA::Double BLSURFPlugin_Hypothesis_i::GetSurfaceProximityRatio()
{
  return this->GetImpl()->GetSurfaceProximityRatio();
}

//=============================================================================
/*!
 *  Activate/deactivate volume proximity computation
 */
void BLSURFPlugin_Hypothesis_i::SetVolumeProximity( CORBA::Boolean toUse )
{
  if ( GetVolumeProximity() != toUse )
  {
    this->GetImpl()->SetUseVolumeProximity( toUse );
    SMESH::TPythonDump() << _this() << ".SetVolumeProximity( " << toUse << " )";
  }
}

CORBA::Boolean BLSURFPlugin_Hypothesis_i::GetVolumeProximity()
{
  return this->GetImpl()->GetUseVolumeProximity();
}


//=============================================================================
/*!
 * Set number of surface element layers to be generated due to volume proximity
 */
void BLSURFPlugin_Hypothesis_i::SetNbVolumeProximityLayers( CORBA::Short nbLayers )
{
  if ( GetNbVolumeProximityLayers() != nbLayers )
  {
    this->GetImpl()->SetNbVolumeProximityLayers( nbLayers );
    SMESH::TPythonDump() << _this() << ".SetNbVolumeProximityLayers( " << nbLayers << " )";
  }
}

CORBA::Short BLSURFPlugin_Hypothesis_i::GetNbVolumeProximityLayers()
{
  return (CORBA::Short) this->GetImpl()->GetNbVolumeProximityLayers();
}

//=============================================================================
  /*!
   * Set coefficient by which size of element refined due to volume proximity is increased
   */
void BLSURFPlugin_Hypothesis_i::SetVolumeProximityRatio( CORBA::Double ratio )
{
  if ( GetVolumeProximityRatio() != ratio )
  {
    this->GetImpl()->SetVolumeProximityRatio( ratio );
    SMESH::TPythonDump() << _this() << ".SetVolumeProximityRatio( " << ratio << " )";
  }
}

CORBA::Double BLSURFPlugin_Hypothesis_i::GetVolumeProximityRatio()
{
  return this->GetImpl()->GetVolumeProximityRatio();
}

//=============================================================================
void BLSURFPlugin_Hypothesis_i::SetVerbosity(CORBA::Short theVal) {
  ASSERT(myBaseImpl);
  if (theVal < 0 || theVal > 10)
    THROW_SALOME_CORBA_EXCEPTION( "Invalid verbosity level",SALOME_CMOD::BAD_PARAM );
  this->GetImpl()->SetVerbosity(theVal);
  SMESH::TPythonDump() << _this() << ".SetVerbosity( " << theVal << " )";
}

//=============================================================================

CORBA::Short BLSURFPlugin_Hypothesis_i::GetVerbosity() {
  ASSERT(myBaseImpl);
  return (CORBA::Short) this->GetImpl()->GetVerbosity();
}


//=============================================================================
void BLSURFPlugin_Hypothesis_i::SetEnforcedMeshes(const BLSURFPlugin::EnforcedMeshesList& theMeshes )
{
  std::vector< ::BLSURFPlugin_Hypothesis::EnforcedMesh > enforcedMeshes;
  for ( CORBA::ULong i = 0; i < theMeshes.length(); ++i )
  {
    const BLSURFPlugin::MG_EnforcedMesh1D & inEM = theMeshes[ i ];
    if ( CORBA::is_nil( inEM.mesh ))
      THROW_SALOME_CORBA_EXCEPTION( "NULL enforced mesh",SALOME_CMOD::BAD_PARAM );

    SMESH::SMESH_Mesh_var mesh = inEM.mesh->GetMesh();
    if ( CORBA::is_nil( mesh ))
      THROW_SALOME_CORBA_EXCEPTION( "BAD enforced mesh",SALOME_CMOD::BAD_PARAM );

    int meshID = GetMeshPersistentId( mesh );
    if ( meshID < 0 )
      THROW_SALOME_CORBA_EXCEPTION( "BAD enforced mesh",SALOME_CMOD::BAD_PARAM );

    bool isGroup = false;
    int   partID = GetMeshPartPersistentId( inEM.mesh, isGroup );
    ::EnforcedMeshType partType = ENFORCED_MESH;
    if ( partID > -1 )
      partType = isGroup ? ENFORCED_GROUP : ENFORCED_SUBMESH;

    enforcedMeshes.push_back({ meshID, partID, partType, inEM.groupName.in() });
  }

  if ( GetImpl()->GetEnforcedMeshes() == enforcedMeshes )
    return;

  this->GetImpl()->SetEnforcedMeshes( enforcedMeshes );

  // dump

  SMESH::TPythonDump pyDump;
  pyDump << BLSURFPlugin::BLSURFPlugin_Hypothesis_var( _this() )
         << ".SetEnforcedMeshes([ ";

  for ( CORBA::ULong i = 0; i < theMeshes.length(); ++i )
  {
    const BLSURFPlugin::MG_EnforcedMesh1D & inEM = theMeshes[ i ];
    pyDump << "BLSURFPlugin.MG_EnforcedMesh1D( " << inEM.mesh.in() << ", ";
    if ( inEM.groupName.in() && inEM.groupName.in()[0] )
      pyDump << "'" << inEM.groupName.in() << "'";
    else
      pyDump << "''";
    pyDump << ")" << ( i + 1 < theMeshes.length() ? ", " : "");
  }
  pyDump << "])";
}

//=============================================================================

BLSURFPlugin::EnforcedMeshesList* BLSURFPlugin_Hypothesis_i::GetEnforcedMeshes()
{
  const std::vector< ::BLSURFPlugin_Hypothesis::EnforcedMesh > & hypEnfMeshes =
    this->GetImpl()->GetEnforcedMeshes();

  BLSURFPlugin::EnforcedMeshesList_var outEnfMeshes = new BLSURFPlugin::EnforcedMeshesList();
  outEnfMeshes->length( hypEnfMeshes.size() );

  int nbMeshes = 0;
  for ( size_t i = 0; i < hypEnfMeshes.size(); ++i )
  {
    const ::BLSURFPlugin_Hypothesis::EnforcedMesh& enfMeshData = hypEnfMeshes[ i ];
    BLSURFPlugin::MG_EnforcedMesh1D &               outEnfMesh = outEnfMeshes[ nbMeshes ];

    SMESH::SMESH_Mesh_var mesh = FindMeshByID( enfMeshData._meshID );
    switch ( enfMeshData._type ) {
    case ENFORCED_MESH   :
    {
      outEnfMesh.mesh = SMESH::SMESH_IDSource::_narrow( mesh );
      break;
    }
    case ENFORCED_GROUP  :
    {
      SMESH::SMESH_GroupBase_var group = GetGroupByID( mesh, enfMeshData._subID );
      outEnfMesh.mesh = SMESH::SMESH_IDSource::_narrow( group );
      break;
    }
    case ENFORCED_SUBMESH:
    {
      SMESH::SMESH_subMesh_var subMesh;
      subMesh   = GetSubMeshByID( mesh, enfMeshData._subID, SMESH::Tag_SubMeshOnEdge );
      if ( CORBA::is_nil( subMesh ))
        subMesh = GetSubMeshByID( mesh, enfMeshData._subID, SMESH::Tag_SubMeshOnCompound );

      outEnfMesh.mesh = SMESH::SMESH_IDSource::_narrow( subMesh );
      break;
    }
    default: continue;
    }
    outEnfMesh.groupName = enfMeshData._groupName.c_str();

    nbMeshes += ( !CORBA::is_nil( outEnfMesh.mesh ));
  }
  outEnfMeshes->length( nbMeshes );

  return outEnfMeshes._retn();
}

//=============================================================================
void BLSURFPlugin_Hypothesis_i::SetEnforceCadEdgesSize( CORBA::Boolean toEnforce )
{
  if ( GetEnforceCadEdgesSize() != toEnforce )
  {
    this->GetImpl()->SetEnforceCadEdgesSize(toEnforce);
    SMESH::TPythonDump() << _this() << ".SetEnforceCadEdgesSize( " << toEnforce << " )";
  }
}
//=============================================================================
CORBA::Boolean BLSURFPlugin_Hypothesis_i::GetEnforceCadEdgesSize()
{
  return this->GetImpl()->GetEnforceCadEdgesSize();
}
//=============================================================================

void BLSURFPlugin_Hypothesis_i::SetJacobianRectificationRespectGeometry( CORBA::Boolean allowRectification )
{
  if ( GetJacobianRectificationRespectGeometry() != allowRectification )
  {
    this->GetImpl()->SetJacobianRectificationRespectGeometry(allowRectification);
    SMESH::TPythonDump() << _this() << ".SetJacobianRectificationRespectGeometry( " << allowRectification << " )";
  }
}
//=============================================================================
CORBA::Boolean BLSURFPlugin_Hypothesis_i::GetJacobianRectificationRespectGeometry()
{
  return this->GetImpl()->GetJacobianRectificationRespectGeometry();
}
//=============================================================================

void BLSURFPlugin_Hypothesis_i::SetJacobianRectification( CORBA::Boolean allowRectification )
{
  if ( GetJacobianRectification() != allowRectification )
  {
    this->GetImpl()->SetJacobianRectification(allowRectification);
    SMESH::TPythonDump() << _this() << ".SetJacobianRectification( " << allowRectification << " )";
  }
}
//=============================================================================
CORBA::Boolean BLSURFPlugin_Hypothesis_i::GetJacobianRectification()
{
  return this->GetImpl()->GetJacobianRectification();
}
//=============================================================================

void BLSURFPlugin_Hypothesis_i::SetUseDeprecatedPatchMesher( CORBA::Boolean useDeprecatedPatchMesher )
{
  if ( GetUseDeprecatedPatchMesher() != useDeprecatedPatchMesher )
  {
    this->GetImpl()->SetUseDeprecatedPatchMesher(useDeprecatedPatchMesher);
    SMESH::TPythonDump() << _this() << ".SetUseDeprecatedPatchMesher( " << useDeprecatedPatchMesher << " )";
  }
}
//=============================================================================
CORBA::Boolean BLSURFPlugin_Hypothesis_i::GetUseDeprecatedPatchMesher()
{
  return this->GetImpl()->GetUseDeprecatedPatchMesher();
}
//=============================================================================

void BLSURFPlugin_Hypothesis_i::SetMaxNumberOfPointsPerPatch( CORBA::Long nb )
{
  if ( GetMaxNumberOfPointsPerPatch() != nb )
  {
    try {
      this->GetImpl()->SetMaxNumberOfPointsPerPatch(nb);

    } catch (const std::invalid_argument& ex) {
      THROW_SALOME_CORBA_EXCEPTION( ex.what() ,SALOME_CMOD::BAD_PARAM );
    } catch (SALOME_Exception& ex) {
      THROW_SALOME_CORBA_EXCEPTION( ex.what() ,SALOME_CMOD::BAD_PARAM );
    }
    SMESH::TPythonDump() << _this() << ".SetMaxNumberOfPointsPerPatch( " << nb << " )";
  }
}
//=============================================================================
CORBA::Long BLSURFPlugin_Hypothesis_i::GetMaxNumberOfPointsPerPatch()
{
  return this->GetImpl()->GetMaxNumberOfPointsPerPatch();
}
//=============================================================================

void BLSURFPlugin_Hypothesis_i::SetMaxNumberOfThreads( CORBA::Long nb )
{
  if ( GetMaxNumberOfThreads() != nb )
  {
    try {
      this->GetImpl()->SetMaxNumberOfThreads(nb);

    } catch (const std::invalid_argument& ex) {
      THROW_SALOME_CORBA_EXCEPTION( ex.what() ,SALOME_CMOD::BAD_PARAM );
    } catch (SALOME_Exception& ex) {
      THROW_SALOME_CORBA_EXCEPTION( ex.what() ,SALOME_CMOD::BAD_PARAM );
    }
    SMESH::TPythonDump() << _this() << ".SetMaxNumberOfThreads( " << nb << " )";
  }
}
//=============================================================================
CORBA::Long BLSURFPlugin_Hypothesis_i::GetMaxNumberOfThreads()
{
  return this->GetImpl()->GetMaxNumberOfThreads();
}
//=============================================================================

void BLSURFPlugin_Hypothesis_i::SetRespectGeometry( CORBA::Boolean toRespect )
{
  if ( GetRespectGeometry() != toRespect )
  {
    this->GetImpl()->SetRespectGeometry(toRespect);
    SMESH::TPythonDump() << _this() << ".SetRespectGeometry( " << toRespect << " )";
  }
}
//=============================================================================
CORBA::Boolean BLSURFPlugin_Hypothesis_i::GetRespectGeometry()
{
  return this->GetImpl()->GetRespectGeometry();
}
//=============================================================================

void BLSURFPlugin_Hypothesis_i::SetTinyEdgesAvoidSurfaceIntersections( CORBA::Boolean toAvoidIntersection )
{
  if ( GetTinyEdgesAvoidSurfaceIntersections() != toAvoidIntersection )
  {
    this->GetImpl()->SetTinyEdgesAvoidSurfaceIntersections(toAvoidIntersection);
    SMESH::TPythonDump() << _this() << ".SetTinyEdgesAvoidSurfaceIntersections( " << toAvoidIntersection << " )";
  }
}
//=============================================================================
CORBA::Boolean BLSURFPlugin_Hypothesis_i::GetTinyEdgesAvoidSurfaceIntersections()
{
  return this->GetImpl()->GetTinyEdgesAvoidSurfaceIntersections();
}
//=============================================================================

void BLSURFPlugin_Hypothesis_i::SetClosedGeometry( CORBA::Boolean isClosed )
{
  if ( GetClosedGeometry() != isClosed )
  {
    this->GetImpl()->SetClosedGeometry(isClosed);
    SMESH::TPythonDump() << _this() << ".SetClosedGeometry( " << isClosed << " )";
  }
}
//=============================================================================
CORBA::Boolean BLSURFPlugin_Hypothesis_i::GetClosedGeometry()
{
  return this->GetImpl()->GetClosedGeometry();
}
//=============================================================================

void BLSURFPlugin_Hypothesis_i::SetDebug( CORBA::Boolean isDebug )
{
  if ( GetDebug() != isDebug )
  {
    this->GetImpl()->SetDebug(isDebug);
    SMESH::TPythonDump() << _this() << ".SetDebug( " << isDebug << " )";
  }
}
//=============================================================================
bool BLSURFPlugin_Hypothesis_i::GetDebug()
{
  return this->GetImpl()->GetDebug();
}
//=============================================================================

void BLSURFPlugin_Hypothesis_i::SetPeriodicTolerance( CORBA::Double tol )
{
  bool isDefault;
  if ( GetImpl()->GetPreCADOptionValue("periodic_tolerance",&isDefault) != SMESH_Comment( tol ))
  {
    try
    {
      this->GetImpl()->SetPeriodicTolerance(tol);

    } catch (const std::invalid_argument& ex) {
      THROW_SALOME_CORBA_EXCEPTION( ex.what() ,SALOME_CMOD::BAD_PARAM );
    } catch (SALOME_Exception& ex) {
      THROW_SALOME_CORBA_EXCEPTION( ex.what() ,SALOME_CMOD::BAD_PARAM );
    }
    SMESH::TPythonDump() << _this() << ".SetPeriodicTolerance( " << tol << " )";
  }
}
//=============================================================================
double BLSURFPlugin_Hypothesis_i::GetPeriodicTolerance()
{
  try{
    return this->GetImpl()->GetPeriodicTolerance();

  } catch (const std::invalid_argument& ex) {
    THROW_SALOME_CORBA_EXCEPTION( ex.what() ,SALOME_CMOD::BAD_PARAM );
  } catch (SALOME_Exception& ex) {
    THROW_SALOME_CORBA_EXCEPTION( ex.what() ,SALOME_CMOD::BAD_PARAM );
  }
  return -1;
}
//=============================================================================

void BLSURFPlugin_Hypothesis_i::SetRequiredEntities( const char* howToTreat )
{
  if ( GetImpl()->GetRequiredEntities() != howToTreat )
  {
    try {
      this->GetImpl()->SetRequiredEntities(howToTreat);

    } catch (const std::invalid_argument& ex) {
      THROW_SALOME_CORBA_EXCEPTION( ex.what() ,SALOME_CMOD::BAD_PARAM );
    } catch (SALOME_Exception& ex) {
      THROW_SALOME_CORBA_EXCEPTION( ex.what() ,SALOME_CMOD::BAD_PARAM );
    }
    SMESH::TPythonDump() << _this() << ".SetRequiredEntities( '" << howToTreat << "' )";
  }
}
//=============================================================================
char* BLSURFPlugin_Hypothesis_i::GetRequiredEntities()
{
  return CORBA::string_dup( this->GetImpl()->GetRequiredEntities().c_str() );
}
//=============================================================================

void BLSURFPlugin_Hypothesis_i::SetSewingTolerance( CORBA::Double tol )
{
  bool isDefault;
  if ( GetImpl()->GetPreCADOptionValue("sewing_tolerance",&isDefault) != SMESH_Comment( tol ))
  {
    try
    {
      this->GetImpl()->SetSewingTolerance(tol);
      SMESH::TPythonDump() << _this() << ".SetSewingTolerance( " << tol << " )";

    } catch (const std::invalid_argument& ex) {
      THROW_SALOME_CORBA_EXCEPTION( ex.what() ,SALOME_CMOD::BAD_PARAM );
    } catch (SALOME_Exception& ex) {
      THROW_SALOME_CORBA_EXCEPTION( ex.what() ,SALOME_CMOD::BAD_PARAM );
    }
  }
}
//=============================================================================
CORBA::Double BLSURFPlugin_Hypothesis_i::GetSewingTolerance()
{
  try
  {
    return this->GetImpl()->GetSewingTolerance();

  } catch (const std::invalid_argument& ex) {
    THROW_SALOME_CORBA_EXCEPTION( ex.what() ,SALOME_CMOD::BAD_PARAM );
  } catch (SALOME_Exception& ex) {
    THROW_SALOME_CORBA_EXCEPTION( ex.what() ,SALOME_CMOD::BAD_PARAM );
  }
  return -1;
}
//=============================================================================

void BLSURFPlugin_Hypothesis_i::SetTags( const char* howToTreat )
{
  if ( GetImpl()->GetTags() != howToTreat )
  {
    try {
      this->GetImpl()->SetTags(howToTreat);
    }
    catch (const std::invalid_argument& ex) {
      THROW_SALOME_CORBA_EXCEPTION( ex.what() ,SALOME_CMOD::BAD_PARAM );
    } catch (SALOME_Exception& ex) {
      THROW_SALOME_CORBA_EXCEPTION( ex.what() ,SALOME_CMOD::BAD_PARAM );
    }
  }
  SMESH::TPythonDump() << _this() << ".SetTags( '" << howToTreat << "' )";
}
//=============================================================================
char* BLSURFPlugin_Hypothesis_i::GetTags()
{
  return CORBA::string_dup( this->GetImpl()->GetTags().c_str() );
}

//=============================================================================
void BLSURFPlugin_Hypothesis_i::SetHyperPatches(const BLSURFPlugin::THyperPatchList& hpl)
{
  ::BLSURFPlugin_Hypothesis::THyperPatchList patchList( hpl.length() );
  SMESH_Comment hplDump;
  hplDump << "[";
  for ( CORBA::ULong i = 0; i < patchList.size(); ++i )
  {
    hplDump << "[ ";
    BLSURFPlugin::THyperPatch tags = hpl[ i ];
    for ( CORBA::ULong j = 0; j < tags.length(); ++j )
    {
      patchList[ i ].insert( tags[ j ]);
      hplDump << tags[ j ] << ( j+1 < tags.length() ? ", " : " ]" );
    }
    hplDump << ( i+1 < patchList.size() ? "," : "]");
  }
  if ( GetImpl()->GetHyperPatches() != patchList )
  {
    GetImpl()->SetHyperPatches( ::BLSURFPlugin_Hypothesis::THyperPatchEntriesList() ); // erase entries
    GetImpl()->SetHyperPatches( patchList );
    SMESH::TPythonDump() << _this() << ".SetHyperPatches( " << hplDump << " )";
  }
}

//=============================================================================
void BLSURFPlugin_Hypothesis_i::SetHyperPatchEntries(const BLSURFPlugin::THyperPatchEntriesList& hpe)
{
  ::BLSURFPlugin_Hypothesis::THyperPatchEntriesList patchList( hpe.length() );
  SMESH_Comment hpeDump;
  hpeDump << "[";
  for ( CORBA::ULong i = 0; i < patchList.size(); ++i )
  {
    hpeDump << "[ ";
    const BLSURFPlugin::THyperPatchEntries& entryList = hpe[ i ];
    for ( CORBA::ULong j = 0; j < entryList.length(); ++j )
    {
      patchList[ i ].insert( entryList[ j ].in() );
      hpeDump << entryList[ j ].in() << ( j+1 < entryList.length() ? ", " : " ]" );
    }
    hpeDump << ( i+1 < patchList.size() ? "," : "]");
  }
  if ( GetImpl()->GetHyperPatchEntries() != patchList )
  {
    GetImpl()->SetHyperPatches( ::BLSURFPlugin_Hypothesis::THyperPatchList(), /*notify=*/false );
    GetImpl()->SetHyperPatches( patchList );
    // TPythonDump converts entries to objects
    SMESH::TPythonDump() << _this() << ".SetHyperPatchShapes( " << hpeDump << " )";
  }
}

//=============================================================================
void BLSURFPlugin_Hypothesis_i::SetHyperPatchShapes(const BLSURFPlugin::THyperPatchShapesList& hpsl)
{
  BLSURFPlugin::THyperPatchEntriesList patchList;
  patchList.length( hpsl.length() );
  for ( CORBA::ULong i = 0; i < hpsl.length(); ++i )
  {
    const GEOM::ListOfGO&             shapeList = hpsl[ i ];
    BLSURFPlugin::THyperPatchEntries& entryList = patchList[ i ];
    entryList.length( shapeList.length() );
    for ( CORBA::ULong j = 0; j < shapeList.length(); ++j )
    {
      CORBA::String_var entry = shapeList[ j ]->GetStudyEntry();
      if ( !entry.in() || !entry.in()[0] )
        THROW_SALOME_CORBA_EXCEPTION( "BLSURFPlugin_Hypothesis::SetHyperPatchShapes(), "
                                      "Not published hyper-patch shape", SALOME_CMOD::BAD_PARAM );
      entryList[ j ] = CORBA::string_dup( entry );
    }
  }
  this->SetHyperPatchEntries( patchList );
}

//=============================================================================
BLSURFPlugin::THyperPatchList*
BLSURFPlugin_Hypothesis_i::GetHyperPatches( GEOM::GEOM_Object_ptr mainShape )
{
  const ::BLSURFPlugin_Hypothesis::THyperPatchList& hpl = GetImpl()->GetHyperPatches();
  BLSURFPlugin::THyperPatchList*                 resHpl = new BLSURFPlugin::THyperPatchList();
  if ( hpl.empty() &&
       !CORBA::is_nil( mainShape ) &&
       !GetImpl()->GetHyperPatchEntries().empty() )
  {
    // set IDs by entries
    SMESH_Gen_i* smeshGen = SMESH_Gen_i::GetSMESHGen();
    TopoDS_Shape S = smeshGen->GeomObjectToShape( mainShape );
    if ( !S.IsNull() )
    {
      std::map< std::string, TopoDS_Shape > entryToShape;
      BLSURFPlugin_BLSURF::FillEntryToShape( GetImpl(), entryToShape );
      GetImpl()->SetHyperPatchIDsByEntry( S, entryToShape );
    }
  }
  resHpl->length((CORBA::ULong) hpl.size() );

  ::BLSURFPlugin_Hypothesis::THyperPatchList::const_iterator hpIt = hpl.begin();
  for ( int i = 0; hpIt != hpl.end(); ++hpIt, ++i )
  {
    const ::BLSURFPlugin_Hypothesis::THyperPatchTags& hp = *hpIt;
    BLSURFPlugin::THyperPatch& resHp = (*resHpl)[ i ];
    resHp.length((CORBA::ULong) hp.size() );

    ::BLSURFPlugin_Hypothesis::THyperPatchTags::const_iterator tag = hp.begin();
    for ( int j = 0; tag != hp.end(); ++tag, ++j )
      resHp[ j ] = *tag;
  }
  return resHpl;
}

//=============================================================================
BLSURFPlugin::THyperPatchEntriesList* BLSURFPlugin_Hypothesis_i::GetHyperPatchShapes()
{
  const ::BLSURFPlugin_Hypothesis::THyperPatchEntriesList& hpel = GetImpl()->GetHyperPatchEntries();
  BLSURFPlugin::THyperPatchEntriesList* resHpl = new BLSURFPlugin::THyperPatchEntriesList();
  resHpl->length((CORBA::ULong) hpel.size() );

  ::BLSURFPlugin_Hypothesis::THyperPatchEntriesList::const_iterator hpIt = hpel.begin();
  for ( int i = 0; hpIt != hpel.end(); ++hpIt, ++i )
  {
    const ::BLSURFPlugin_Hypothesis::THyperPatchEntries& hp = *hpIt;
    BLSURFPlugin::THyperPatchEntries& resHp = (*resHpl)[ i ];
    resHp.length((CORBA::ULong) hp.size() );

    ::BLSURFPlugin_Hypothesis::THyperPatchEntries::const_iterator entry = hp.begin();
    for ( int j = 0; entry != hp.end(); ++entry, ++j )
      resHp[ j ] = CORBA::string_dup( entry->c_str() );
  }
  return resHpl;
}

//=============================================================================
/*!
 *  BLSURFPlugin_Hypothesis_i::SetPreCADMergeEdges
 *
 *  Set true or false
 */
//=============================================================================
void BLSURFPlugin_Hypothesis_i::SetPreCADMergeEdges(CORBA::Boolean theValue) {
  ASSERT(myBaseImpl);
  this->GetImpl()->SetPreCADMergeEdges(theValue);
  std::string theValueStr = theValue ? "True" : "False";
  SMESH::TPythonDump() << _this() << ".SetPreCADMergeEdges( " << theValueStr.c_str() << " )";
}

//=============================================================================
/*!
 *  BLSURFPlugin_Hypothesis_i::GetPreCADMergeEdges
 *
 *  Get true or false
 */
//=============================================================================
CORBA::Boolean BLSURFPlugin_Hypothesis_i::GetPreCADMergeEdges() {
  ASSERT(myBaseImpl);
  return this->GetImpl()->GetPreCADMergeEdges();
}

//=============================================================================
/*!
 *  BLSURFPlugin_Hypothesis_i::SetPreCADRemoveDuplicateCADFaces
 *
 *  Set true or false
 */
//=============================================================================
void BLSURFPlugin_Hypothesis_i::SetPreCADRemoveDuplicateCADFaces(CORBA::Boolean theValue) {
  ASSERT(myBaseImpl);
  this->GetImpl()->SetPreCADRemoveDuplicateCADFaces(theValue);
  std::string theValueStr = theValue ? "True" : "False";
  SMESH::TPythonDump() << _this() << ".SetPreCADRemoveDuplicateCADFaces( " << theValueStr.c_str() << " )";
}

//=============================================================================
/*!
 *  BLSURFPlugin_Hypothesis_i::GetPreCADRemoveDuplicateCADFaces
 *
 *  Get true or false
 */
//=============================================================================
CORBA::Boolean BLSURFPlugin_Hypothesis_i::GetPreCADRemoveDuplicateCADFaces() {
  ASSERT(myBaseImpl);
  return this->GetImpl()->GetPreCADRemoveDuplicateCADFaces();
}

//=============================================================================
/*!
 *  BLSURFPlugin_Hypothesis_i::SetPreCADProcess3DTopology
 *
 *  Set true or false
 */
//=============================================================================
void BLSURFPlugin_Hypothesis_i::SetPreCADProcess3DTopology(CORBA::Boolean theValue) {
  ASSERT(myBaseImpl);
  this->GetImpl()->SetPreCADProcess3DTopology(theValue);
  std::string theValueStr = theValue ? "True" : "False";
  SMESH::TPythonDump() << _this() << ".SetPreCADProcess3DTopology( " << theValueStr.c_str() << " )";
}

//=============================================================================
/*!
 *  BLSURFPlugin_Hypothesis_i::GetPreCADProcess3DTopology
 *
 *  Get true or false
 */
//=============================================================================
CORBA::Boolean BLSURFPlugin_Hypothesis_i::GetPreCADProcess3DTopology() {
  ASSERT(myBaseImpl);
  return this->GetImpl()->GetPreCADProcess3DTopology();
}

//=============================================================================
/*!
 *  BLSURFPlugin_Hypothesis_i::SetPreCADDiscardInput
 *
 *  Set true or false
 */
//=============================================================================
void BLSURFPlugin_Hypothesis_i::SetPreCADDiscardInput(CORBA::Boolean theValue) {
  ASSERT(myBaseImpl);
  this->GetImpl()->SetPreCADDiscardInput(theValue);
  std::string theValueStr = theValue ? "True" : "False";
  SMESH::TPythonDump() << _this() << ".SetPreCADDiscardInput( " << theValueStr.c_str() << " )";
}

//=============================================================================
/*!
 *  BLSURFPlugin_Hypothesis_i::GetPreCADDiscardInput
 *
 *  Get true or false
 */
//=============================================================================
CORBA::Boolean BLSURFPlugin_Hypothesis_i::GetPreCADDiscardInput() {
  ASSERT(myBaseImpl);
  return this->GetImpl()->GetPreCADDiscardInput();
}


//=============================================================================

void BLSURFPlugin_Hypothesis_i::SetOptionValue(const char* optionName, const char* optionValue)
{
  ASSERT(myBaseImpl);
  try {
    std::string name( optionName );
    if ( !optionValue || !optionValue[0] )
      UnsetOption( optionName );

    // basic options (visible in Advanced table)

    else if ( name == "enforce_cad_edge_sizes" )
      SetEnforceCadEdgesSize( GetImpl()->ToBool( optionValue ));

    else if ( name == "jacobian_rectification_respect_geometry" )
      SetJacobianRectificationRespectGeometry( GetImpl()->ToBool( optionValue ));

    else if ( name == "max_number_of_points_per_patch" )
      SetMaxNumberOfPointsPerPatch( GetImpl()->ToInt( optionValue ));

    else if ( name == "max_number_of_threads" )
      SetMaxNumberOfThreads( GetImpl()->ToInt( optionValue ));

    else if ( name == "rectify_jacobian" )
      SetJacobianRectification( GetImpl()->ToBool( optionValue ));

    else if ( name == "use_deprecated_patch_mesher" )
      SetUseDeprecatedPatchMesher( GetImpl()->ToBool( optionValue ));

    else if ( name == "respect_geometry" )
      SetRespectGeometry( GetImpl()->ToBool( optionValue ));

    else if ( name == "tiny_edge_avoid_surface_intersections" )
      SetTinyEdgesAvoidSurfaceIntersections( GetImpl()->ToBool( optionValue ));

    else if ( name == "closed_geometry" )
      SetClosedGeometry( GetImpl()->ToBool( optionValue ));

    else if ( name == "debug" )
      SetDebug( GetImpl()->ToBool( optionValue ));

    else if ( name == "discard_input_topology" )
      SetPreCADDiscardInput( GetImpl()->ToBool( optionValue ));

    else if ( name == "merge_edges" )
      SetPreCADMergeEdges( GetImpl()->ToBool( optionValue ));

    else if ( name == "periodic_tolerance" )
      SetPeriodicTolerance( GetImpl()->ToDbl( optionValue ));

    else if ( name == "remove_duplicate_cad_faces" )
      SetPreCADRemoveDuplicateCADFaces( GetImpl()->ToBool( optionValue ));

    else if ( name == "required_entities" )
      SetRequiredEntities( optionValue );

    else if ( name == "sewing_tolerance" )
      SetSewingTolerance( GetImpl()->ToDbl( optionValue ));

    else if ( name == "tags" )
      SetTags( optionValue );

    // other basic options with specific methods

    else if ( name == "correct_surface_intersections" )
      SetCorrectSurfaceIntersection( GetImpl()->ToBool( optionValue ));

    else if ( name == "optimise_tiny_edges" )
      SetOptimiseTinyEdges( GetImpl()->ToBool( optionValue ));

    else if ( name == "surface_intersections_processing_max_cost" )
      SetCorrectSurfaceIntersectionMaxCost( GetImpl()->ToDbl( optionValue ));

    else if ( name == "volume_gradation" )
      SetVolumeGradation( GetImpl()->ToDbl( optionValue ));

    else if ( name == "tiny_edge_optimisation_length" )
      SetTinyEdgeOptimisationLength( GetImpl()->ToDbl( optionValue ));

    else if ( name == "proximity" )
      SetVolumeProximity( GetImpl()->ToBool( optionValue ));

    else if ( name == "prox_ratio" )
      SetVolumeProximityRatio( GetImpl()->ToDbl( optionValue ));

    else if ( name == "prox_nb_layer" )
      SetNbVolumeProximityLayers((CORBA::Short) GetImpl()->ToInt( optionValue ));

    // advanced options (for backward compatibility)

    else if ( name == "create_tag_on_collision" ||
              name == "tiny_edge_respect_geometry" )
      AddOption( optionName, optionValue );

    else {
      bool valueChanged;
      valueChanged = ( this->GetImpl()->GetOptionValue( name ) != optionValue &&
                       this->GetImpl()->GetOptionValue( name, &valueChanged ) != optionValue );
      if ( valueChanged )
      {
        this->GetImpl()->SetOptionValue(optionName, optionValue);
        SMESH::TPythonDump() << _this() << ".SetOptionValue( '" << optionName << "', '" << optionValue << "' )";
      }
    }
  } catch (const std::invalid_argument& ex) {
    THROW_SALOME_CORBA_EXCEPTION( ex.what() ,SALOME_CMOD::BAD_PARAM );
  } catch (SALOME_Exception& ex) {
    THROW_SALOME_CORBA_EXCEPTION( ex.what() ,SALOME_CMOD::BAD_PARAM );
  }
}

//=============================================================================

void BLSURFPlugin_Hypothesis_i::SetPreCADOptionValue(const char* optionName, const char* optionValue)
{
  ASSERT(myBaseImpl);
  bool valueChanged = false;
  try {
    std::string name( optionName );
    if ( !optionValue || !optionValue[0] )
      UnsetOption( optionName );

    else if ( name == "closed_geometry" )
      SetClosedGeometry( GetImpl()->ToBool( optionValue ));

    else if ( name == "debug" )
      SetDebug( GetImpl()->ToBool( optionValue ));

    else if ( name == "discard_input_topology" )
      SetPreCADDiscardInput( GetImpl()->ToBool( optionValue ));

    else if ( name == "merge_edges" )
      SetPreCADMergeEdges( GetImpl()->ToBool( optionValue ));

    else if ( name == "periodic_tolerance" )
      SetPeriodicTolerance( GetImpl()->ToDbl( optionValue ));

    else if ( name == "remove_duplicate_cad_faces" )
      SetPreCADRemoveDuplicateCADFaces( GetImpl()->ToBool( optionValue ));

    else if ( name == "required_entities" )
      SetRequiredEntities( optionValue );

    else if ( name == "sewing_tolerance" )
      SetSewingTolerance( GetImpl()->ToDbl( optionValue ));

    else if ( name == "tags" )
      SetTags( optionValue );

    // other basic options with specific methods

    else if ( name == "correct_surface_intersections" )
      SetCorrectSurfaceIntersection( GetImpl()->ToBool( optionValue ));

    else if ( name == "optimise_tiny_edges" )
      SetOptimiseTinyEdges( GetImpl()->ToBool( optionValue ));

    else if ( name == "surface_intersections_processing_max_cost" )
      SetCorrectSurfaceIntersectionMaxCost( GetImpl()->ToDbl( optionValue ));

    else if ( name == "volume_gradation" )
      SetVolumeGradation( GetImpl()->ToDbl( optionValue ));

    else if ( name == "tiny_edge_optimisation_length" )
      SetTinyEdgeOptimisationLength( GetImpl()->ToDbl( optionValue ));

    else if ( name == "process_3d_topology" )
      SetPreCADProcess3DTopology( GetImpl()->ToBool( optionValue ));

    // advanced options (for backward compatibility)

    else if ( name == "create_tag_on_collision" ||
              name == "tiny_edge_respect_geometry" ||
              name == "remove_tiny_edges" ||
              name == "tiny_edge_length")
      AddPreCADOption( optionName, optionValue );

    else {
      valueChanged = (this->GetImpl()->GetPreCADOptionValue(optionName) != optionValue);
      if (valueChanged)
        this->GetImpl()->SetPreCADOptionValue(optionName, optionValue);
    }
  } catch (const std::invalid_argument& ex) {
    THROW_SALOME_CORBA_EXCEPTION( ex.what() ,SALOME_CMOD::BAD_PARAM );
  } catch (SALOME_Exception& ex) {
    THROW_SALOME_CORBA_EXCEPTION( ex.what() ,SALOME_CMOD::BAD_PARAM );
  }
  if (valueChanged)
    SMESH::TPythonDump() << _this() << ".SetPreCADOptionValue( '" << optionName << "', '" << optionValue << "' )";
}

//=============================================================================

char* BLSURFPlugin_Hypothesis_i::GetOptionValue(const char* optionName) {
  ASSERT(myBaseImpl);
  try {
    bool isDefault;
    return CORBA::string_dup(this->GetImpl()->GetOptionValue(optionName,&isDefault).c_str());
  } catch (const std::invalid_argument& ex) {
    THROW_SALOME_CORBA_EXCEPTION( ex.what() ,SALOME_CMOD::BAD_PARAM );
  } catch (SALOME_Exception& ex) {
    THROW_SALOME_CORBA_EXCEPTION( ex.what() ,SALOME_CMOD::BAD_PARAM );
  }
  return 0;
}

//=============================================================================

char* BLSURFPlugin_Hypothesis_i::GetPreCADOptionValue(const char* optionName) {
  ASSERT(myBaseImpl);
  try {
    bool isDefault;
    return CORBA::string_dup(this->GetImpl()->GetPreCADOptionValue(optionName,&isDefault).c_str());
  } catch (const std::invalid_argument& ex) {
    THROW_SALOME_CORBA_EXCEPTION( ex.what() ,SALOME_CMOD::BAD_PARAM );
  } catch (SALOME_Exception& ex) {
    THROW_SALOME_CORBA_EXCEPTION( ex.what() ,SALOME_CMOD::BAD_PARAM );
  }
  return 0;
}

//=============================================================================

void BLSURFPlugin_Hypothesis_i::UnsetOption(const char* optionName) {
  ASSERT(myBaseImpl);
  if ( !GetImpl()->GetOptionValue( optionName ).empty() )
  {
    this->GetImpl()->ClearOption(optionName);
    SMESH::TPythonDump() << _this() << ".UnsetOption( '" << optionName << "' )";
  }
}

//=============================================================================

void BLSURFPlugin_Hypothesis_i::UnsetPreCADOption(const char* optionName) {
  ASSERT(myBaseImpl);
  if ( !GetImpl()->GetPreCADOptionValue( optionName ).empty() )
  {
    this->GetImpl()->ClearPreCADOption(optionName);
    SMESH::TPythonDump() << _this() << ".UnsetPreCADOption( '" << optionName << "' )";
  }
}

//=============================================================================

BLSURFPlugin::string_array* BLSURFPlugin_Hypothesis_i::GetOptionValues() {
  ASSERT(myBaseImpl);
  BLSURFPlugin::string_array_var result = new BLSURFPlugin::string_array();

  const ::BLSURFPlugin_Hypothesis::TOptionValues & opts = this->GetImpl()->GetOptionValues();
  result->length((CORBA::ULong) opts.size());
  int i=0;

  bool isDefault;
  ::BLSURFPlugin_Hypothesis::TOptionValues::const_iterator opIt = opts.begin();
  for (; opIt != opts.end(); ++opIt, ++i) {
    string name_value_type = opIt->first;
    if (!opIt->second.empty()) {
      name_value_type += ":";
      name_value_type += GetImpl()->GetOptionValue( opIt->first, &isDefault );
      name_value_type += isDefault ? ":0" : ":1";
    }
    result[i] = CORBA::string_dup(name_value_type.c_str());
  }

  return result._retn();
}

//=============================================================================

BLSURFPlugin::string_array* BLSURFPlugin_Hypothesis_i::GetPreCADOptionValues() {
  ASSERT(myBaseImpl);
  BLSURFPlugin::string_array_var result = new BLSURFPlugin::string_array();

  const ::BLSURFPlugin_Hypothesis::TOptionValues & opts = this->GetImpl()->GetPreCADOptionValues();
  result->length((CORBA::ULong) opts.size());
  int i=0;

  bool isDefault;
  ::BLSURFPlugin_Hypothesis::TOptionValues::const_iterator opIt = opts.begin();
  for (; opIt != opts.end(); ++opIt, ++i) {
    string name_value_type = opIt->first;
    if (!opIt->second.empty()) {
      name_value_type += ":";
      name_value_type += GetImpl()->GetPreCADOptionValue( opIt->first, &isDefault );
      name_value_type += isDefault ? ":0" : ":1";
    }
    result[i] = CORBA::string_dup(name_value_type.c_str());
  }
  return result._retn();
}

//=============================================================================

BLSURFPlugin::string_array* BLSURFPlugin_Hypothesis_i::GetAdvancedOptionValues()
{
  BLSURFPlugin::string_array_var result = new BLSURFPlugin::string_array();

  const ::BLSURFPlugin_Hypothesis::TOptionValues & custom_opts = this->GetImpl()->GetCustomOptionValues();
  result->length((CORBA::ULong) custom_opts.size());
  int i=0;

  ::BLSURFPlugin_Hypothesis::TOptionValues::const_iterator opIt = custom_opts.begin();
  for (; opIt != custom_opts.end(); ++opIt, ++i) {
    string name_value_type = opIt->first;
    if (!opIt->second.empty()) {
      name_value_type += ":";
      name_value_type += opIt->second;
      name_value_type += ":1"; // user defined
    }
    result[i] = CORBA::string_dup(name_value_type.c_str());
  }
  return result._retn();
}

//=============================================================================

void BLSURFPlugin_Hypothesis_i::SetOptionValues(const BLSURFPlugin::string_array& options)
{
  ASSERT(myBaseImpl);
  for (CORBA::ULong i = 0; i < options.length(); ++i) {
    string name_value_type = options[i].in();
    if(name_value_type.empty())
      continue;
    size_t colonPos = name_value_type.find(':');
    string name, value;
    if (colonPos == string::npos) // ':' not found
      name = name_value_type;
    else {
      name = name_value_type.substr(0, colonPos);
      if (colonPos < name_value_type.size() - 1 && name_value_type[colonPos] != ' ') {
        string value_type = name_value_type.substr(colonPos + 1);
        colonPos = value_type.find(':');
        value = value_type.substr(0, colonPos);
        if (colonPos < value_type.size() - 1 && value_type[colonPos] != ' ')
          if ( value_type.substr(colonPos + 1) == "0" ) // is default
            value.clear();
      }
    }
    SetOptionValue(name.c_str(), value.c_str());
  }
}

//=============================================================================

void BLSURFPlugin_Hypothesis_i::SetPreCADOptionValues(const BLSURFPlugin::string_array& options)
{
  ASSERT(myBaseImpl);
  for ( CORBA::ULong i = 0; i < options.length(); ++i) {
    string name_value_type = options[i].in();
    if(name_value_type.empty())
      continue;
    size_t colonPos = name_value_type.find(':');
    string name, value;
    if (colonPos == string::npos) // ':' not found
      name = name_value_type;
    else {
      name = name_value_type.substr(0, colonPos);
      if (colonPos < name_value_type.size() - 1 && name_value_type[colonPos] != ' ') {
        string value_type = name_value_type.substr(colonPos + 1);
        colonPos = value_type.find(':');
        value = value_type.substr(0, colonPos);
        if (colonPos < value_type.size() - 1 && value_type[colonPos] != ' ')
          if ( value_type.substr(colonPos + 1) == "0" ) // is default
            value.clear();
      }
    }
    SetPreCADOptionValue(name.c_str(), value.c_str());
  }
}

//=============================================================================

void BLSURFPlugin_Hypothesis_i::SetAdvancedOptionValues(const BLSURFPlugin::string_array& options)
{
  SMESH::TPythonDump dump;

  string optionsAndValues;
  for ( CORBA::ULong i = 0; i < options.length(); ++i) {
    string name_value_type = options[i].in();
    if(name_value_type.empty())
      continue;
    size_t colonPos = name_value_type.find(':');
    string name, value;
    if (colonPos == string::npos) // ':' not found
      name = name_value_type;
    else {
      name = name_value_type.substr(0, colonPos);
      if (colonPos < name_value_type.size() - 1 && name_value_type[colonPos] != ' ') {
        string value_type = name_value_type.substr(colonPos + 1);
        colonPos = value_type.find(':');
        value = value_type.substr(0, colonPos);
      }
    }
    AddOption(name.c_str(), value.c_str());

    optionsAndValues += name + " " + value + " ";
  }

  if ( !optionsAndValues.empty() )
    dump << _this() << ".SetAdvancedOptions( '" << optionsAndValues.c_str() << "' )";
}

//=============================================================================

void BLSURFPlugin_Hypothesis_i::SetAdvancedOption(const char* optionsAndValues)
{
  if ( !optionsAndValues ) return;

  SMESH::TPythonDump dump;

  std::istringstream strm( optionsAndValues );
  std::istream_iterator<std::string> sIt( strm ), sEnd;
  while ( sIt != sEnd )
  {
    std::string option = *sIt;
    if ( ++sIt != sEnd )
    {
      std::string value = *sIt;
      ++sIt;
      AddOption( option.c_str(), value.c_str() );
    }
    else
    {
      THROW_SALOME_CORBA_EXCEPTION( "Uneven number of options and values" ,SALOME_CMOD::BAD_PARAM );
    }
  }
  dump << _this() << ".SetAdvancedOption( '" << optionsAndValues << "' )";
}

//=============================================================================

void BLSURFPlugin_Hypothesis_i::AddOption(const char* optionName, const char* optionValue)
{
  // backward compatibility
  {
    std::string name( optionName );
    if ( name == "proximity" )
      SetVolumeProximity( GetImpl()->ToBool( optionValue ));

    else if ( name == "prox_ratio" )
      SetVolumeProximityRatio( GetImpl()->ToDbl( optionValue ));

    else if ( name == "prox_nb_layer" )
      SetNbVolumeProximityLayers( (CORBA::Short) GetImpl()->ToInt( optionValue ));
  }
  bool valueChanged = (this->GetImpl()->GetOption(optionName) != optionValue);
  if (valueChanged) {
    this->GetImpl()->AddOption(optionName, optionValue);
    SMESH::TPythonDump() << _this() << ".AddOption( '" << optionName << "', '" << optionValue << "' )";
  }
}

//=============================================================================

void BLSURFPlugin_Hypothesis_i::AddPreCADOption(const char* optionName, const char* optionValue)
{
  ASSERT(myBaseImpl);
  bool valueChanged = (this->GetImpl()->GetPreCADOption(optionName) != optionValue);
  if (valueChanged) {
    this->GetImpl()->AddPreCADOption(optionName, optionValue);
    SMESH::TPythonDump() << _this() << ".AddPreCADOption( '" << optionName << "', '" << optionValue << "' )";
  }
}

//=============================================================================

char* BLSURFPlugin_Hypothesis_i::GetOption(const char* optionName)
{
  ASSERT(myBaseImpl);
  return CORBA::string_dup(this->GetImpl()->GetOption(optionName).c_str());
}

//=============================================================================

char* BLSURFPlugin_Hypothesis_i::GetPreCADOption(const char* optionName)
{
  ASSERT(myBaseImpl);
  return CORBA::string_dup(this->GetImpl()->GetPreCADOption(optionName).c_str());
}

//=============================================================================

void BLSURFPlugin_Hypothesis_i::SetSizeMapEntry(const char* entry, const char* sizeMap)
{
  ASSERT(myBaseImpl);
  if ( !entry || !entry[0] )
    THROW_SALOME_CORBA_EXCEPTION( "SetSizeMapEntry(): empty geom entry", SALOME_CMOD::BAD_PARAM );
  bool valueChanged = false;
  try {
    valueChanged = (this->GetImpl()->GetSizeMapEntry(entry) != sizeMap);
    if (valueChanged)
      this->GetImpl()->SetSizeMapEntry(entry, sizeMap);
  } catch (const std::invalid_argument& ex) {
    SALOME_CMOD::ExceptionStruct ExDescription;
    ExDescription.text = ex.what();
    ExDescription.type = SALOME_CMOD::BAD_PARAM;
    ExDescription.sourceFile = "BLSURFPlugin_Hypothesis::SetSizeMapEntry(entry,sizemap)";
    ExDescription.lineNumber = 0;
    throw SALOME_CMOD::SALOME_Exception(ExDescription);
  } catch (SALOME_Exception& ex) {
    THROW_SALOME_CORBA_EXCEPTION( ex.what() ,SALOME_CMOD::BAD_PARAM );
  }
  if (valueChanged)
    SMESH::TPythonDump() << _this() << ".SetSizeMap(" << entry << ", '" << sizeMap << "' )";
}

//=============================================================================

void BLSURFPlugin_Hypothesis_i::SetConstantSizeMapEntry(const char* entry, GEOM::shape_type shapeType, CORBA::Double sizeMap)
{
  ASSERT(myBaseImpl);
  bool valueChanged = false;
  std::ostringstream sizeMapFunction;
  switch (shapeType) {
  case GEOM::FACE:   sizeMapFunction << "def f(u,v): return " << sizeMap ; break;
  case GEOM::EDGE:   sizeMapFunction << "def f(t): return " << sizeMap ; break;
  case GEOM::VERTEX: sizeMapFunction << "def f(): return " << sizeMap ; break;
  default:;
  }
  try {
    valueChanged = (this->GetImpl()->GetSizeMapEntry(entry) != sizeMapFunction.str());
    if (valueChanged)
      this->GetImpl()->SetSizeMapEntry(entry, sizeMapFunction.str());
  } catch (const std::invalid_argument& ex) {
    SALOME_CMOD::ExceptionStruct ExDescription;
    ExDescription.text = ex.what();
    ExDescription.type = SALOME_CMOD::BAD_PARAM;
    ExDescription.sourceFile = "BLSURFPlugin_Hypothesis::SetSizeMapEntry(entry,sizemap)";
    ExDescription.lineNumber = 0;
    throw SALOME_CMOD::SALOME_Exception(ExDescription);
  } catch (SALOME_Exception& ex) {
    THROW_SALOME_CORBA_EXCEPTION( ex.what() ,SALOME_CMOD::BAD_PARAM );
  }
  if (valueChanged)
    SMESH::TPythonDump() << _this() << ".SetConstantSizeMap(" << entry << ", " << sizeMap << " )";
}

//=============================================================================

void BLSURFPlugin_Hypothesis_i::SetAttractorEntry(const char* entry, const char* attractor)
{
  ASSERT(myBaseImpl);
  bool valueChanged = false;
  try {
    valueChanged = ( this->GetImpl()->GetAttractorEntry(entry) != attractor );
    if ( valueChanged ) {
      boost::regex re("^ATTRACTOR\\((?:(-?0(\\.\\d*)*|-?[1-9]+\\d*(\\.\\d*)*|-?\\.(\\d)+);){5}(True|False)(?:;(-?0(\\.\\d*)*|-?[1-9]+\\d*(\\.\\d*)*|-?\\.(\\d)+))?\\)$");
      if (!boost::regex_match(string(attractor), re))
        throw std::invalid_argument("Error: an attractor is defined with the following pattern: ATTRACTOR(xa;ya;za;a;b;True|False;d(opt.))");
      this->GetImpl()->SetAttractorEntry(entry, attractor);
    }
  } catch (const std::invalid_argument& ex) {
    SALOME_CMOD::ExceptionStruct ExDescription;
    ExDescription.text = ex.what();
    ExDescription.type = SALOME_CMOD::BAD_PARAM;
    ExDescription.sourceFile = "BLSURFPlugin_Hypothesis::SetAttractorEntry(entry,attractor)";
    ExDescription.lineNumber = 0;
    throw SALOME_CMOD::SALOME_Exception(ExDescription);
  } catch (SALOME_Exception& ex) {
    THROW_SALOME_CORBA_EXCEPTION( ex.what() ,SALOME_CMOD::BAD_PARAM );
  }
  if (valueChanged)
    SMESH::TPythonDump() << _this() << ".SetAttractor(" << entry << ", '" << attractor << "' )";
}

//=============================================================================

void BLSURFPlugin_Hypothesis_i::SetClassAttractorEntry(const char* entry, const char* att_entry, CORBA::Double StartSize, CORBA::Double EndSize, CORBA::Double ActionRadius, CORBA::Double ConstantRadius) //TODO ?? finir
{
  ASSERT(myBaseImpl);
  //bool valueChanged = false;
  try {
    this->GetImpl()->SetClassAttractorEntry(entry, att_entry, StartSize, EndSize, ActionRadius, ConstantRadius);
  }
  catch (const std::invalid_argument& ex) {
    SALOME_CMOD::ExceptionStruct ExDescription;
    ExDescription.text = ex.what();
    ExDescription.type = SALOME_CMOD::BAD_PARAM;
    ExDescription.sourceFile = "BLSURFPlugin_Hypothesis::SetClassAttractorEntry(entry, att_entry, StartSize, EndSize, ActionRadius, ConstantRadius)";
    ExDescription.lineNumber = 0;
    throw SALOME_CMOD::SALOME_Exception(ExDescription);
  } catch (SALOME_Exception& ex) {
    THROW_SALOME_CORBA_EXCEPTION( ex.what() ,SALOME_CMOD::BAD_PARAM );
  }
  //if ( valueChanged )
  SMESH::TPythonDump() << _this() << ".SetAttractorGeom( "
                       << entry << ", " << att_entry << ", "<<StartSize<<", "<<EndSize<<", "<<ActionRadius<<", "<<ConstantRadius<<" )";
}

//=============================================================================

char* BLSURFPlugin_Hypothesis_i::GetSizeMapEntry(const char* entry) {
  ASSERT(myBaseImpl);
  try {
    return CORBA::string_dup(this->GetImpl()->GetSizeMapEntry(entry).c_str());
  } catch (const std::invalid_argument& ex) {
    SALOME_CMOD::ExceptionStruct ExDescription;
    ExDescription.text = ex.what();
    ExDescription.type = SALOME_CMOD::BAD_PARAM;
    ExDescription.sourceFile = "BLSURFPlugin_Hypothesis::GetSizeMapEntry(name)";
    ExDescription.lineNumber = 0;
    throw SALOME_CMOD::SALOME_Exception(ExDescription);
  } catch (SALOME_Exception& ex) {
    THROW_SALOME_CORBA_EXCEPTION( ex.what() ,SALOME_CMOD::BAD_PARAM );
  }
  return 0;
}

//=============================================================================

char* BLSURFPlugin_Hypothesis_i::GetAttractorEntry(const char* entry) {
  ASSERT(myBaseImpl);
  try {
    return CORBA::string_dup(this->GetImpl()->GetAttractorEntry(entry).c_str());
  } catch (const std::invalid_argument& ex) {
    SALOME_CMOD::ExceptionStruct ExDescription;
    ExDescription.text = ex.what();
    ExDescription.type = SALOME_CMOD::BAD_PARAM;
    ExDescription.sourceFile = "BLSURFPlugin_Hypothesis::GetAttractorEntry(name)";
    ExDescription.lineNumber = 0;
    throw SALOME_CMOD::SALOME_Exception(ExDescription);
  } catch (SALOME_Exception& ex) {
    THROW_SALOME_CORBA_EXCEPTION( ex.what() ,SALOME_CMOD::BAD_PARAM );
  }
  return 0;
}

// //=============================================================================
// 
// // TODO coder cette fonction (utilis??e pour savoir si la valeur a chang??
// // A finir pour le dump
// char* BLSURFPlugin_Hypothesis_i::GetClassAttractorEntry(const char* entry)
// {
//   ASSERT(myBaseImpl);
//   try {
//     return CORBA::string_dup( this->GetImpl()->GetClassAttractorEntry(entry).c_str());
//   }
//   catch (const std::invalid_argument& ex) {
//     SALOME_CMOD::ExceptionStruct ExDescription;
//     ExDescription.text = ex.what();
//     ExDescription.type = SALOME_CMOD::BAD_PARAM;
//     ExDescription.sourceFile = "BLSURFPlugin_Hypothesis::GetClassAttractorEntry(name)";
//     ExDescription.lineNumber = 0;
//     throw SALOME_CMOD::SALOME_Exception(ExDescription);
//   }
//   catch (SALOME_Exception& ex) {
//     THROW_SALOME_CORBA_EXCEPTION( ex.what() ,SALOME_CMOD::BAD_PARAM );
//   }
//   return 0;
// }

//=============================================================================

void BLSURFPlugin_Hypothesis_i::UnsetEntry(const char* entry) {
  ASSERT(myBaseImpl);
  this->GetImpl()->ClearEntry(entry);
  //  SMESH::TPythonDump() << _this() << ".UnsetSizeMap( " << entry << " )";
}

//=============================================================================

BLSURFPlugin::string_array* BLSURFPlugin_Hypothesis_i::GetSizeMapEntries() {
  ASSERT(myBaseImpl);
  BLSURFPlugin::string_array_var result = new BLSURFPlugin::string_array();

  const ::BLSURFPlugin_Hypothesis::TSizeMap sizeMaps = this->GetImpl()->_GetSizeMapEntries();
  result->length((CORBA::ULong) sizeMaps.size());

  ::BLSURFPlugin_Hypothesis::TSizeMap::const_iterator smIt = sizeMaps.begin();
  for (int i = 0; smIt != sizeMaps.end(); ++smIt, ++i) {
    string entry_sizemap = smIt->first;
    if (!smIt->second.empty()) {
      entry_sizemap += "|";
      entry_sizemap += smIt->second;
    }
    result[i] = CORBA::string_dup(entry_sizemap.c_str());
  }
  return result._retn();
}

//=============================================================================

BLSURFPlugin::string_array* BLSURFPlugin_Hypothesis_i::GetAttractorEntries() {
  ASSERT(myBaseImpl);
  BLSURFPlugin::string_array_var result = new BLSURFPlugin::string_array();

  const ::BLSURFPlugin_Hypothesis::TSizeMap attractors = this->GetImpl()->_GetAttractorEntries();
  result->length((CORBA::ULong) attractors.size());

  ::BLSURFPlugin_Hypothesis::TSizeMap::const_iterator atIt = attractors.begin();
  for (int i = 0; atIt != attractors.end(); ++atIt, ++i) {
    string entry_attractor = atIt->first;
    if (!atIt->second.empty()) {
      entry_attractor += "|";
      entry_attractor += atIt->second;
    }
    result[i] = CORBA::string_dup(entry_attractor.c_str());
  }
  return result._retn();
}

//=============================================================================

BLSURFPlugin::TAttParamsMap* BLSURFPlugin_Hypothesis_i::GetAttractorParams()
{
  ASSERT(myBaseImpl);
  BLSURFPlugin::TAttParamsMap_var result = new BLSURFPlugin::TAttParamsMap();

  const ::BLSURFPlugin_Hypothesis::TAttractorMap attractors= this->GetImpl()->_GetClassAttractorEntries();
  result->length((CORBA::ULong) attractors.size() );

  ::BLSURFPlugin_Hypothesis::TAttractorMap::const_iterator atIt = attractors.begin();
  for ( int i = 0 ; atIt != attractors.end(); ++atIt, ++i ) {
    string faceEntry = atIt->first;
    string attEntry;
    double startSize=0., endSize=0., infDist=0., constDist=0.;
    if ( !atIt->second->Empty() ) {
      attEntry = atIt->second->GetAttractorEntry();
      std::vector<double> params = atIt->second->GetParameters();
      startSize = params[0];
      endSize = params[1];
      infDist = params[2];
      constDist = params[3];
    }
    result[i].faceEntry = CORBA::string_dup(faceEntry.c_str());
    result[i].attEntry = CORBA::string_dup(attEntry.c_str());
    result[i].startSize = startSize;
    result[i].endSize = endSize;
    result[i].infDist = infDist;
    result[i].constDist = constDist;
  }
  return result._retn();
}

//=============================================================================

void BLSURFPlugin_Hypothesis_i::SetSizeMapEntries(const BLSURFPlugin::string_array& sizeMaps)
{
  ASSERT(myBaseImpl);
  for ( CORBA::ULong i = 0; i < sizeMaps.length(); ++i) {
    string entry_sizemap = sizeMaps[i].in();
    size_t colonPos = entry_sizemap.find('|');
    string entry, sizemap;
    if (colonPos == string::npos) // '|' separator not found
      entry = entry_sizemap;
    else {
      entry = entry_sizemap.substr(0, colonPos);
      if (colonPos < entry_sizemap.size() - 1 && entry_sizemap[colonPos] != ' ')
        sizemap = entry_sizemap.substr(colonPos + 1);
    }
    this->GetImpl()->SetSizeMapEntry(entry.c_str(), sizemap.c_str());
  }
}

//=============================================================================

void BLSURFPlugin_Hypothesis_i::ClearSizeMaps() {
  ASSERT(myBaseImpl);
  this->GetImpl()->ClearSizeMaps();
}

//=============================================================================

void BLSURFPlugin_Hypothesis_i::SetSizeMap(const GEOM::GEOM_Object_ptr GeomObj, const char* sizeMap)
{
  ASSERT(myBaseImpl);
  string entry;
  entry = GeomObj->GetStudyEntry();
  SetSizeMapEntry(entry.c_str(), sizeMap);
}

//=============================================================================

void BLSURFPlugin_Hypothesis_i::SetConstantSizeMap(const GEOM::GEOM_Object_ptr GeomObj, CORBA::Double sizeMap) {
  ASSERT(myBaseImpl);
  string entry = GeomObj->GetStudyEntry();
  GEOM::shape_type shapeType = GeomObj->GetShapeType();
  if (shapeType == GEOM::COMPOUND)
    shapeType = GeomObj->GetMaxShapeType();
  SetConstantSizeMapEntry(entry.c_str(), shapeType, sizeMap);
}

//=============================================================================
void BLSURFPlugin_Hypothesis_i::UnsetSizeMap(const GEOM::GEOM_Object_ptr GeomObj) {
  ASSERT(myBaseImpl);
  string entry;
  entry = GeomObj->GetStudyEntry();
  UnsetEntry(entry.c_str());
  SMESH::TPythonDump() << _this() << ".UnsetSizeMap( " << entry.c_str() << " )";
}

void BLSURFPlugin_Hypothesis_i::SetAttractor(GEOM::GEOM_Object_ptr GeomObj, const char* attractor) {
  ASSERT(myBaseImpl);
  string entry;
  entry = GeomObj->GetStudyEntry();
  SetAttractorEntry(entry.c_str(), attractor);
}

void BLSURFPlugin_Hypothesis_i::UnsetAttractor(GEOM::GEOM_Object_ptr GeomObj) {
  ASSERT(myBaseImpl);
  string entry;
  entry = GeomObj->GetStudyEntry();
  UnsetEntry(entry.c_str());
  SMESH::TPythonDump() << _this() << ".UnsetAttractor( " << entry.c_str() << " )";
}

void BLSURFPlugin_Hypothesis_i::SetAttractorGeom(GEOM::GEOM_Object_ptr theFace, GEOM::GEOM_Object_ptr theAttractor, CORBA::Double StartSize, CORBA::Double EndSize, CORBA::Double ActionRadius, CORBA::Double ConstantRadius)
{
  ASSERT(myBaseImpl);
  string theFaceEntry;
  string theAttEntry;
  theFaceEntry = theFace->GetStudyEntry();
  theAttEntry  = theAttractor->GetStudyEntry();
  
  GEOM::GEOM_Gen_ptr geomGen = SMESH_Gen_i::GetGeomEngine( theFace );
  string aName;
  
  if (theFaceEntry.empty()) {
    aName = "Face_";
    aName += theFace->GetEntry();
    SALOMEDS::SObject_wrap theSFace = geomGen->PublishInStudy(NULL, theFace, aName.c_str());
    if (!theSFace->_is_nil())
      theFaceEntry = theSFace->GetID();
  }
  if (theFaceEntry.empty())
    THROW_SALOME_CORBA_EXCEPTION( "Geom object is not published in study" ,SALOME_CMOD::BAD_PARAM );
  
  if (theAttEntry.empty()) {
    if (theAttractor->GetShapeType() == GEOM::VERTEX)
      aName = "Vertex_";
    if (theAttractor->GetShapeType() == GEOM::EDGE)
      aName = "Edge_";
    if (theAttractor->GetShapeType() == GEOM::WIRE)
      aName = "Wire_";
    if (theAttractor->GetShapeType() == GEOM::COMPOUND)
      aName = "Compound_";
    aName += theAttractor->GetEntry();
    SALOMEDS::SObject_wrap theSAtt = geomGen->PublishInStudy(NULL, theAttractor, aName.c_str());
    if (!theSAtt->_is_nil())
      theAttEntry = theSAtt->GetID();
  }
  if (theAttEntry.empty())
    THROW_SALOME_CORBA_EXCEPTION( "Geom object is not published in study" ,SALOME_CMOD::BAD_PARAM );
  
  TopoDS_Face FaceShape = TopoDS::Face(SMESH_Gen_i::GetSMESHGen()->GeomObjectToShape( theFace ));
  TopoDS_Shape AttractorShape = SMESH_Gen_i::GetSMESHGen()->GeomObjectToShape( theAttractor );
  SetClassAttractorEntry( theFaceEntry.c_str(), theAttEntry.c_str(), StartSize, EndSize, ActionRadius, ConstantRadius);
}

void BLSURFPlugin_Hypothesis_i::UnsetAttractorGeom(GEOM::GEOM_Object_ptr theFace,
                                                   GEOM::GEOM_Object_ptr theAttractor)
{
  ASSERT(myBaseImpl);
  CORBA::String_var theFaceEntry = theFace->GetStudyEntry();
  CORBA::String_var theAttrEntry = theAttractor->GetStudyEntry();
  
  // GEOM::GEOM_Gen_ptr geomGen = SMESH_Gen_i::GetGeomEngine( theFace );
  // string aName;
  
  // if (theFaceEntry.empty()) {
  //   aName = "Face_";
  //   aName += theFace->GetEntry();
  //   SALOMEDS::SObject_wrap theSFace = geomGen->PublishInStudy(NULL, theFace, aName.c_str());
  //   if (!theSFace->_is_nil())
  //     theFaceEntry = theSFace->GetID();
  // }
  if ( !theFaceEntry.in() || !theFaceEntry.in()[0] ||
       !theAttrEntry.in() || !theAttrEntry.in()[0] )
    THROW_SALOME_CORBA_EXCEPTION( "Geom object is not published in study" ,SALOME_CMOD::BAD_PARAM );
  
  GetImpl()->ClearEntry( theFaceEntry.in(), theAttrEntry.in() );
  SMESH::TPythonDump() << _this() << ".UnsetAttractorGeom( "
                       << theFace << ", " << theAttractor << " )";
}

void BLSURFPlugin_Hypothesis_i::UnsetAttractorEntry(const char* faceEntry,
                                                    const char* attractorEntry)
{
  GetImpl()->ClearEntry( faceEntry, attractorEntry );
  SMESH::TPythonDump() << _this() << ".UnsetAttractorEntry( '"
                       << faceEntry << "', '" << attractorEntry << "' )";
}


/*
  void BLSURFPlugin_Hypothesis_i::SetCustomSizeMap(GEOM::GEOM_Object_ptr GeomObj, const char* sizeMap)
  {}

  void BLSURFPlugin_Hypothesis_i::UnsetCustomSizeMap(GEOM::GEOM_Object_ptr GeomObj)
  {}

  void BLSURFPlugin_Hypothesis_i::SetCustomSizeMapEntry(const char* entry,const char* sizeMap )
  {}

  char* BLSURFPlugin_Hypothesis_i::GetCustomSizeMapEntry(const char* entry)
  {}

  void BLSURFPlugin_Hypothesis_i::UnsetCustomSizeMapEntry(const char* entry)
  {
  ASSERT(myBaseImpl);
  this->GetImpl()->UnsetCustomSizeMap(entry);
  SMESH::TPythonDump() << _this() << ".UnsetCustomSizeMap( " << entry << " )";
  }


  BLSURFPlugin::string_array* BLSURFPlugin_Hypothesis_i::GetCustomSizeMapEntries()
  {}

*/

// ///////////////////////
// // ENFORCED VERTICES //
// ///////////////////////


/**
 * Returns the list of enforced vertices for a given Face entry
 * @return A map of Face entry / List of enforced vertices
 *
 */
BLSURFPlugin::TFaceEntryEnfVertexListMap* BLSURFPlugin_Hypothesis_i::GetAllEnforcedVerticesByFace() {
  ASSERT(myBaseImpl);

  BLSURFPlugin::TFaceEntryEnfVertexListMap_var resultMap = new BLSURFPlugin::TFaceEntryEnfVertexListMap();

  const ::BLSURFPlugin_Hypothesis::TFaceEntryEnfVertexListMap faceEntryEnfVertexListMap =
    this->GetImpl()->_GetAllEnforcedVerticesByFace();
  resultMap->length((CORBA::ULong) faceEntryEnfVertexListMap.size());

  ::BLSURFPlugin_Hypothesis::TEnfVertexList _enfVertexList;
  ::BLSURFPlugin_Hypothesis::TFaceEntryEnfVertexListMap::const_iterator it_entry = faceEntryEnfVertexListMap.begin();
  for (int i = 0; it_entry != faceEntryEnfVertexListMap.end(); ++it_entry, ++i) {
    BLSURFPlugin::TFaceEntryEnfVertexListMapElement_var mapElement =
      new BLSURFPlugin::TFaceEntryEnfVertexListMapElement();
    mapElement->faceEntry = CORBA::string_dup(it_entry->first.c_str());

    _enfVertexList = it_entry->second;
    BLSURFPlugin::TEnfVertexList_var enfVertexList = new BLSURFPlugin::TEnfVertexList();
    enfVertexList->length((CORBA::ULong) _enfVertexList.size());

    ::BLSURFPlugin_Hypothesis::TEnfVertexList::const_iterator it_enfVertex = _enfVertexList.begin();
    ::BLSURFPlugin_Hypothesis::TEnfVertex *currentEnfVertex;
    for (int j = 0; it_enfVertex != _enfVertexList.end(); ++it_enfVertex, ++j) {
      currentEnfVertex = (*it_enfVertex);

      BLSURFPlugin::TEnfVertex_var enfVertex = new BLSURFPlugin::TEnfVertex();

      // Name
      enfVertex->name = CORBA::string_dup(currentEnfVertex->name.c_str());

      // Geom entry
      enfVertex->geomEntry = CORBA::string_dup(currentEnfVertex->geomEntry.c_str());

      // Coords
      BLSURFPlugin::TEnfVertexCoords_var coords = new BLSURFPlugin::TEnfVertexCoords();
      coords->length((CORBA::ULong) currentEnfVertex->coords.size());
      for (CORBA::ULong i=0;i<coords->length();i++)
        coords[i] = currentEnfVertex->coords[i];
      enfVertex->coords = coords;

      // Group name
      enfVertex->grpName = CORBA::string_dup(currentEnfVertex->grpName.c_str());
      
      // Face entry list
      BLSURFPlugin::TEntryList_var faceEntryList = new BLSURFPlugin::TEntryList();
      faceEntryList->length((CORBA::ULong) currentEnfVertex->faceEntries.size());
      ::BLSURFPlugin_Hypothesis::TEntryList::const_iterator it_entry = currentEnfVertex->faceEntries.begin();
      for (int ind = 0; it_entry != currentEnfVertex->faceEntries.end();++it_entry, ++ind)
        faceEntryList[ind] = CORBA::string_dup((*it_entry).c_str());
      enfVertex->faceEntries = faceEntryList;

      ostringstream msg;
      msg << "Enforced vertex: \n"
          << "Name: " << enfVertex->name << "\n";
      if (coords->length())
        msg << "Coords: " << enfVertex->coords[0] << ", " << enfVertex->coords[1] << ", " << enfVertex->coords[2] << "\n";
      msg << "Geom entry: " << enfVertex->geomEntry << "\n"
          << "Group Name: " << enfVertex->grpName;

      enfVertexList[j] = enfVertex;
    }
    mapElement->enfVertexList = enfVertexList;

    resultMap[i] = mapElement;

  }
  return resultMap._retn();
}

/**
 * Returns the list of all enforced vertices
 * @return a list of enforced vertices
 *
 */
BLSURFPlugin::TEnfVertexList* BLSURFPlugin_Hypothesis_i::GetAllEnforcedVertices() {
  ASSERT(myBaseImpl);
  BLSURFPlugin::TEnfVertexList_var resultMap = new BLSURFPlugin::TEnfVertexList();
  const ::BLSURFPlugin_Hypothesis::TEnfVertexList enfVertexList = this->GetImpl()->_GetAllEnforcedVertices();
  resultMap->length((CORBA::ULong) enfVertexList.size());

  ::BLSURFPlugin_Hypothesis::TEnfVertexList::const_iterator evlIt = enfVertexList.begin();
  ::BLSURFPlugin_Hypothesis::TEnfVertex *currentEnfVertex;
  for (int i = 0; evlIt != enfVertexList.end(); ++evlIt, ++i) {
    currentEnfVertex = (*evlIt);
    BLSURFPlugin::TEnfVertex_var enfVertex = new BLSURFPlugin::TEnfVertex();
    // Name
    enfVertex->name = CORBA::string_dup(currentEnfVertex->name.c_str());
    // Geom entry
    enfVertex->geomEntry = CORBA::string_dup(currentEnfVertex->geomEntry.c_str());
    // Coords
    BLSURFPlugin::TEnfVertexCoords_var coords = new BLSURFPlugin::TEnfVertexCoords();
    coords->length((CORBA::ULong) currentEnfVertex->coords.size());
    for (CORBA::ULong ind = 0; ind < coords->length(); ind++)
      coords[ind] = currentEnfVertex->coords[ind];
    enfVertex->coords = coords;
    // Group name
    enfVertex->grpName = CORBA::string_dup(currentEnfVertex->grpName.c_str());  
    // Face entry list
    BLSURFPlugin::TEntryList_var faceEntryList = new BLSURFPlugin::TEntryList();
    faceEntryList->length((CORBA::ULong) currentEnfVertex->faceEntries.size());
    ::BLSURFPlugin_Hypothesis::TEntryList::const_iterator it_entry = currentEnfVertex->faceEntries.begin();
    for (int ind = 0; it_entry != currentEnfVertex->faceEntries.end();++it_entry, ++ind)
      faceEntryList[ind] = CORBA::string_dup((*it_entry).c_str());
    enfVertex->faceEntries = faceEntryList;

    ostringstream msg;
    msg << "Enforced vertex: \n"
        << "Name: " << enfVertex->name << "\n";
    if (coords->length())
      msg << "Coords: " << enfVertex->coords[0] << ", " << enfVertex->coords[1] << ", " << enfVertex->coords[2] << "\n";
    msg << "Geom entry: " << enfVertex->geomEntry << "\n"
        << "Group Name: " << enfVertex->grpName;

    resultMap[i] = enfVertex;
  }
  return resultMap._retn();

}

/**
 * Returns the list of enforced vertices coords for a given Face entry.
 * They are the coords of the "manual" enforced vertices.
 * @return A map of Face entry / List of enforced vertices coords
 *
 */
BLSURFPlugin::TFaceEntryCoordsListMap* BLSURFPlugin_Hypothesis_i::GetAllCoordsByFace() {
  ASSERT(myBaseImpl);

  BLSURFPlugin::TFaceEntryCoordsListMap_var resultMap = new BLSURFPlugin::TFaceEntryCoordsListMap();

  const ::BLSURFPlugin_Hypothesis::TFaceEntryCoordsListMap entryCoordsListMap = this->GetImpl()->_GetAllCoordsByFace();
  resultMap->length((CORBA::ULong) entryCoordsListMap.size());

  ::BLSURFPlugin_Hypothesis::TEnfVertexCoordsList _coordsList;
  ::BLSURFPlugin_Hypothesis::TFaceEntryCoordsListMap::const_iterator it_entry = entryCoordsListMap.begin();
  for (int i = 0; it_entry != entryCoordsListMap.end(); ++it_entry, ++i) {
    BLSURFPlugin::TFaceEntryCoordsListMapElement_var mapElement = new BLSURFPlugin::TFaceEntryCoordsListMapElement();
    mapElement->faceEntry = CORBA::string_dup(it_entry->first.c_str());

    _coordsList = it_entry->second;
    BLSURFPlugin::TEnfVertexCoordsList_var coordsList = new BLSURFPlugin::TEnfVertexCoordsList();
    coordsList->length((CORBA::ULong) _coordsList.size());

    ::BLSURFPlugin_Hypothesis::TEnfVertexCoordsList::const_iterator it_coords = _coordsList.begin();
    for (int j = 0; it_coords != _coordsList.end(); ++it_coords, ++j) {
      BLSURFPlugin::TEnfVertexCoords_var coords = new BLSURFPlugin::TEnfVertexCoords();
      coords->length((CORBA::ULong) (*it_coords).size());
      for (CORBA::ULong i=0;i<coords->length();i++)
        coords[i] = (*it_coords)[i];
      coordsList[j] = coords;
    }
    mapElement->coordsList = coordsList;

    resultMap[i] = mapElement;

  }
  return resultMap._retn();
}

/**
 * Returns a map of enforced vertices coords / enforced vertex.
 * They are the coords of the "manual" enforced vertices.
 */
BLSURFPlugin::TCoordsEnfVertexMap* BLSURFPlugin_Hypothesis_i::GetAllEnforcedVerticesByCoords() {
  ASSERT(myBaseImpl);

  BLSURFPlugin::TCoordsEnfVertexMap_var resultMap = new BLSURFPlugin::TCoordsEnfVertexMap();
  const ::BLSURFPlugin_Hypothesis::TCoordsEnfVertexMap coordsEnfVertexMap =
    this->GetImpl()->_GetAllEnforcedVerticesByCoords();
  resultMap->length((CORBA::ULong) coordsEnfVertexMap.size());

  ::BLSURFPlugin_Hypothesis::TCoordsEnfVertexMap::const_iterator it_coords = coordsEnfVertexMap.begin();
  ::BLSURFPlugin_Hypothesis::TEnfVertex *currentEnfVertex;
  for (int i = 0; it_coords != coordsEnfVertexMap.end(); ++it_coords, ++i) {
    currentEnfVertex = (it_coords->second);
    BLSURFPlugin::TCoordsEnfVertexElement_var mapElement = new BLSURFPlugin::TCoordsEnfVertexElement();
    BLSURFPlugin::TEnfVertexCoords_var coords = new BLSURFPlugin::TEnfVertexCoords();
    coords->length((CORBA::ULong) it_coords->first.size());
    for (CORBA::ULong ind=0;ind<coords->length();ind++)
      coords[ind] = it_coords->first[ind];
    mapElement->coords = coords;

    BLSURFPlugin::TEnfVertex_var enfVertex = new BLSURFPlugin::TEnfVertex();
    // Name
    enfVertex->name = CORBA::string_dup(currentEnfVertex->name.c_str());
    // Geom entry
    enfVertex->geomEntry = CORBA::string_dup(currentEnfVertex->geomEntry.c_str());
    // Coords
    BLSURFPlugin::TEnfVertexCoords_var coords2 = new BLSURFPlugin::TEnfVertexCoords();
    coords2->length((CORBA::ULong) currentEnfVertex->coords.size());
    for (CORBA::ULong ind=0;ind<coords2->length();ind++)
      coords2[ind] = currentEnfVertex->coords[ind];
    enfVertex->coords = coords2;
    // Group name
    enfVertex->grpName = CORBA::string_dup(currentEnfVertex->grpName.c_str());  
    // Face entry list
    BLSURFPlugin::TEntryList_var faceEntryList = new BLSURFPlugin::TEntryList();
    faceEntryList->length((CORBA::ULong) currentEnfVertex->faceEntries.size());
    ::BLSURFPlugin_Hypothesis::TEntryList::const_iterator it_entry = currentEnfVertex->faceEntries.begin();
    for (int ind = 0; it_entry != currentEnfVertex->faceEntries.end();++it_entry, ++ind)
      faceEntryList[ind] = CORBA::string_dup((*it_entry).c_str());
    enfVertex->faceEntries = faceEntryList;
      
    mapElement->enfVertex = enfVertex;
    ostringstream msg;
    msg << "Enforced vertex: \n"
        << "Name: " << enfVertex->name << "\n";
    if (coords->length())
      msg << "Coords: " << enfVertex->coords[0] << ", " << enfVertex->coords[1] << ", " << enfVertex->coords[2] << "\n";
    msg << "Geom entry: " << enfVertex->geomEntry << "\n"
        << "Group Name: " << enfVertex->grpName;

    resultMap[i] = mapElement;
  }
  return resultMap._retn();
}

/**
 * Returns the list of enforced vertices entries for a given Face entry.
 * They are the geom entries of the enforced vertices based on geom shape (vertex, compound, group).
 * @return A map of Face entry / List of enforced vertices geom entries
 *
 */
BLSURFPlugin::TFaceEntryEnfVertexEntryListMap* BLSURFPlugin_Hypothesis_i::GetAllEnfVertexEntriesByFace() {
  ASSERT(myBaseImpl);

  BLSURFPlugin::TFaceEntryEnfVertexEntryListMap_var resultMap = new BLSURFPlugin::TFaceEntryEnfVertexEntryListMap();

  const ::BLSURFPlugin_Hypothesis::TFaceEntryEnfVertexEntryListMap entryEnfVertexEntryListMap =
    this->GetImpl()->_GetAllEnfVertexEntriesByFace();
  resultMap->length((CORBA::ULong) entryEnfVertexEntryListMap.size());

  ::BLSURFPlugin_Hypothesis::TEntryList _enfVertexEntryList;
  ::BLSURFPlugin_Hypothesis::TFaceEntryEnfVertexEntryListMap::const_iterator it_entry =
      entryEnfVertexEntryListMap.begin();
  for (int i = 0; it_entry != entryEnfVertexEntryListMap.end(); ++it_entry, ++i) {
    BLSURFPlugin::TFaceEntryEnfVertexEntryListMapElement_var mapElement =
      new BLSURFPlugin::TFaceEntryEnfVertexEntryListMapElement();
    mapElement->faceEntry = CORBA::string_dup(it_entry->first.c_str());

    _enfVertexEntryList = it_entry->second;
    BLSURFPlugin::TEntryList_var enfVertexEntryList = new BLSURFPlugin::TEntryList();
    enfVertexEntryList->length((CORBA::ULong) _enfVertexEntryList.size());

    ::BLSURFPlugin_Hypothesis::TEntryList::const_iterator it_enfVertexEntry = _enfVertexEntryList.begin();
    for (int j = 0; it_enfVertexEntry != _enfVertexEntryList.end(); ++it_enfVertexEntry, ++j) {
      enfVertexEntryList[j] = CORBA::string_dup((*it_enfVertexEntry).c_str());
    }
    mapElement->enfVertexEntryList = enfVertexEntryList;

    resultMap[i] = mapElement;

  }
  return resultMap._retn();
}

/**
 * Returns a map of enforced vertices geom entry / enforced vertex.
 * They are the geom entries of the enforced vertices defined with geom shape (vertex, compound, group).
 */
BLSURFPlugin::TEnfVertexEntryEnfVertexMap* BLSURFPlugin_Hypothesis_i::GetAllEnforcedVerticesByEnfVertexEntry() {
  ASSERT(myBaseImpl);

  BLSURFPlugin::TEnfVertexEntryEnfVertexMap_var resultMap = new BLSURFPlugin::TEnfVertexEntryEnfVertexMap();
  const ::BLSURFPlugin_Hypothesis::TEnfVertexEntryEnfVertexMap enfVertexEntryEnfVertexMap =
    this->GetImpl()->_GetAllEnforcedVerticesByEnfVertexEntry();
  resultMap->length((CORBA::ULong) enfVertexEntryEnfVertexMap.size());

  ::BLSURFPlugin_Hypothesis::TEnfVertexEntryEnfVertexMap::const_iterator it_enfVertexEntry = enfVertexEntryEnfVertexMap.begin();
  ::BLSURFPlugin_Hypothesis::TEnfVertex *currentEnfVertex;
  for (int i = 0; it_enfVertexEntry != enfVertexEntryEnfVertexMap.end(); ++it_enfVertexEntry, ++i) {
    currentEnfVertex = it_enfVertexEntry->second;
    BLSURFPlugin::TEnfVertexEntryEnfVertexElement_var mapElement = new BLSURFPlugin::TEnfVertexEntryEnfVertexElement();
    mapElement->enfVertexEntry = CORBA::string_dup(it_enfVertexEntry->first.c_str());;

    BLSURFPlugin::TEnfVertex_var enfVertex = new BLSURFPlugin::TEnfVertex();
    // Name
    enfVertex->name = CORBA::string_dup(currentEnfVertex->name.c_str());
    // Geom entry
    enfVertex->geomEntry = CORBA::string_dup(currentEnfVertex->geomEntry.c_str());
    // Coords
    BLSURFPlugin::TEnfVertexCoords_var coords = new BLSURFPlugin::TEnfVertexCoords();
    coords->length((CORBA::ULong) currentEnfVertex->coords.size());
    for (CORBA::ULong ind=0;ind<coords->length();ind++)
      coords[ind] = currentEnfVertex->coords[ind];
    enfVertex->coords = coords;
    // Group name
    enfVertex->grpName = CORBA::string_dup(currentEnfVertex->grpName.c_str());  
    // Face entry list
    BLSURFPlugin::TEntryList_var faceEntryList = new BLSURFPlugin::TEntryList();
    faceEntryList->length((CORBA::ULong) currentEnfVertex->faceEntries.size());
    ::BLSURFPlugin_Hypothesis::TEntryList::const_iterator it_entry = currentEnfVertex->faceEntries.begin();
    for (int ind = 0; it_entry != currentEnfVertex->faceEntries.end();++it_entry, ++ind)
      faceEntryList[ind] = CORBA::string_dup((*it_entry).c_str());
    enfVertex->faceEntries = faceEntryList;

    ostringstream msg;
    msg << "Enforced vertex: \n"
        << "Name: " << enfVertex->name << "\n";
    if (coords->length())
      msg << "Coords: " << enfVertex->coords[0] << ", " << enfVertex->coords[1] << ", " << enfVertex->coords[2] << "\n";
    msg << "Geom entry: " << enfVertex->geomEntry << "\n"
        << "Group Name: " << enfVertex->grpName;

    mapElement->enfVertex = enfVertex;
    resultMap[i] = mapElement;
  }
  return resultMap._retn();
}

/**
 * Erase all enforced vertices
 */
void BLSURFPlugin_Hypothesis_i::ClearAllEnforcedVertices() {
  ASSERT(myBaseImpl);
  this->GetImpl()->ClearAllEnforcedVertices();
  SMESH::TPythonDump() << _this() << ".ClearAllEnforcedVertices()";
}

/*!
 * Set/get/unset an enforced vertex on face - OBSOLETE
 */
bool BLSURFPlugin_Hypothesis_i::SetEnforcedVertex(GEOM::GEOM_Object_ptr theFace, CORBA::Double x, CORBA::Double y,
                                                  CORBA::Double z) {
  ASSERT(myBaseImpl);

  if ((theFace->GetShapeType() != GEOM::FACE) && (theFace->GetShapeType() != GEOM::COMPOUND)) {
    THROW_SALOME_CORBA_EXCEPTION("theFace shape type is not FACE or COMPOUND", SALOME_CMOD::BAD_PARAM);
  }

  string theFaceEntry = theFace->GetStudyEntry();
  
  if (theFaceEntry.empty()) {
    GEOM::GEOM_Gen_ptr geomGen = SMESH_Gen_i::GetGeomEngine( theFace );
    string aName;
    if (theFace->GetShapeType() == GEOM::FACE)
      aName = "Face_";
    if (theFace->GetShapeType() == GEOM::COMPOUND)
      aName = "Compound_";
    aName += theFace->GetEntry();
    SALOMEDS::SObject_wrap theSFace = geomGen->PublishInStudy(NULL, theFace, aName.c_str());
    if (!theSFace->_is_nil())
      theFaceEntry = theSFace->GetID();
  }
  if (theFaceEntry.empty())
    THROW_SALOME_CORBA_EXCEPTION( "Geom object is not published in study" ,SALOME_CMOD::BAD_PARAM );
  try {
    return SetEnforcedVertexEntry(theFaceEntry.c_str(), x, y, z);
  } catch (SALOME_Exception& ex) {
    THROW_SALOME_CORBA_EXCEPTION( ex.what() ,SALOME_CMOD::BAD_PARAM );
  }
}

/*!
 * Set/get/unset an enforced vertex with name on face
 */
bool BLSURFPlugin_Hypothesis_i::SetEnforcedVertexNamed(GEOM::GEOM_Object_ptr theFace, CORBA::Double x, CORBA::Double y,
                                                       CORBA::Double z, const char* theVertexName) {
  ASSERT(myBaseImpl);

  if ((theFace->GetShapeType() != GEOM::FACE) && (theFace->GetShapeType() != GEOM::COMPOUND)) {
    THROW_SALOME_CORBA_EXCEPTION("theFace shape type is not FACE or COMPOUND", SALOME_CMOD::BAD_PARAM);
  }

  string theFaceEntry = theFace->GetStudyEntry();
  
  if (theFaceEntry.empty()) {
    GEOM::GEOM_Gen_ptr geomGen = SMESH_Gen_i::GetGeomEngine( theFace );
    string aName;
    if (theFace->GetShapeType() == GEOM::FACE)
      aName = "Face_";
    if (theFace->GetShapeType() == GEOM::COMPOUND)
      aName = "Compound_";
    aName += theFace->GetEntry();
    SALOMEDS::SObject_wrap theSFace = geomGen->PublishInStudy(NULL, theFace, aName.c_str());
    if (!theSFace->_is_nil())
      theFaceEntry = theSFace->GetID();
  }
  if (theFaceEntry.empty())
    THROW_SALOME_CORBA_EXCEPTION( "Geom object is not published in study" ,SALOME_CMOD::BAD_PARAM );
  
  try {
    return SetEnforcedVertexEntry(theFaceEntry.c_str(), x, y, z, theVertexName);
  } catch (SALOME_Exception& ex) {
    THROW_SALOME_CORBA_EXCEPTION( ex.what() ,SALOME_CMOD::BAD_PARAM );
  }
}

/*!
 * Set/get/unset an enforced vertex with geom object on face
 */
bool BLSURFPlugin_Hypothesis_i::SetEnforcedVertexGeom(GEOM::GEOM_Object_ptr theFace, GEOM::GEOM_Object_ptr theVertex)
{
  ASSERT(myBaseImpl);

  if ((theFace->GetShapeType() != GEOM::FACE) && (theFace->GetShapeType() != GEOM::COMPOUND)) {
    THROW_SALOME_CORBA_EXCEPTION("theFace shape type is not FACE or COMPOUND", SALOME_CMOD::BAD_PARAM);
  }

  if ((theVertex->GetShapeType() != GEOM::VERTEX) && (theVertex->GetShapeType() != GEOM::COMPOUND)) {
    THROW_SALOME_CORBA_EXCEPTION("theVertex shape type is not VERTEX or COMPOUND", SALOME_CMOD::BAD_PARAM);
  }

  //  GEOM::GEOM_Gen_ptr geomGen = SMESH_Gen_i::GetGeomEngine( theFace );
  //  GEOM::GEOM_IMeasureOperations_var measureOp = geomGen->GetIMeasureOperations();
  //  if (CORBA::is_nil(measureOp))
  //    return false;
  //
  //  CORBA::Double x, y, z;
  //  x = y = z = 0.;
  //  measureOp->PointCoordinates(theVertex, x, y, z);

  string theFaceEntry = theFace->GetStudyEntry();
  string theVertexEntry = theVertex->GetStudyEntry();
  
  GEOM::GEOM_Gen_ptr geomGen = SMESH_Gen_i::GetGeomEngine( theFace );
  string aName;
  
  if (theFaceEntry.empty()) {
    if (theFace->GetShapeType() == GEOM::FACE)
      aName = "Face_";
    if (theFace->GetShapeType() == GEOM::COMPOUND)
      aName = "Compound_";
    aName += theFace->GetEntry();
    SALOMEDS::SObject_wrap theSFace = geomGen->PublishInStudy(NULL, theFace, aName.c_str());
    if (!theSFace->_is_nil())
      theFaceEntry = theSFace->GetID();
  }
  if (theFaceEntry.empty())
    THROW_SALOME_CORBA_EXCEPTION( "Geom object is not published in study" ,SALOME_CMOD::BAD_PARAM );
  
  if (theVertexEntry.empty()) {
    if (theVertex->GetShapeType() == GEOM::VERTEX)
      aName = "Vertex_";
    if (theVertex->GetShapeType() == GEOM::COMPOUND)
      aName = "Compound_";
    aName += theVertex->GetEntry();
    SALOMEDS::SObject_wrap theSVertex = geomGen->PublishInStudy(NULL, theVertex, aName.c_str());
    if (!theSVertex->_is_nil())
      theVertexEntry = theSVertex->GetID();
  }
  if (theVertexEntry.empty())
    THROW_SALOME_CORBA_EXCEPTION( "Geom object is not published in study" ,SALOME_CMOD::BAD_PARAM );

  string theVertexName = theVertex->GetName();
  try {
    return SetEnforcedVertexEntry(theFaceEntry.c_str(), 0, 0, 0, theVertexName.c_str(), theVertexEntry.c_str());
  } catch (SALOME_Exception& ex) {
    THROW_SALOME_CORBA_EXCEPTION( ex.what() ,SALOME_CMOD::BAD_PARAM );
  }
}

/*!
 * Set an enforced vertex with group name on face
 */
bool BLSURFPlugin_Hypothesis_i::SetEnforcedVertexWithGroup(GEOM::GEOM_Object_ptr theFace, CORBA::Double x, CORBA::Double y, CORBA::Double z, const char* theGroupName)
{
  ASSERT(myBaseImpl);

  if ((theFace->GetShapeType() != GEOM::FACE) && (theFace->GetShapeType() != GEOM::COMPOUND)) {
    THROW_SALOME_CORBA_EXCEPTION("theFace shape type is not FACE or COMPOUND", SALOME_CMOD::BAD_PARAM);
  }

  string theFaceEntry = theFace->GetStudyEntry();
  
  if (theFaceEntry.empty()) {
    GEOM::GEOM_Gen_ptr geomGen = SMESH_Gen_i::GetGeomEngine( theFace );
    string aName;
    if (theFace->GetShapeType() == GEOM::FACE)
      aName = "Face_";
    if (theFace->GetShapeType() == GEOM::COMPOUND)
      aName = "Compound_";
    aName += theFace->GetEntry();
    SALOMEDS::SObject_wrap theSFace = geomGen->PublishInStudy(NULL, theFace, aName.c_str());
    if (!theSFace->_is_nil())
      theFaceEntry = theSFace->GetID();
  }
  if (theFaceEntry.empty())
    THROW_SALOME_CORBA_EXCEPTION( "Geom object is not published in study" ,SALOME_CMOD::BAD_PARAM );
  try {
    return SetEnforcedVertexEntry(theFaceEntry.c_str(), x, y, z, "", "", theGroupName);
  } catch (SALOME_Exception& ex) {
    THROW_SALOME_CORBA_EXCEPTION( ex.what() ,SALOME_CMOD::BAD_PARAM );
  }
}

/*!
 * Set an enforced vertex with name and group name on face
 */
bool BLSURFPlugin_Hypothesis_i::SetEnforcedVertexNamedWithGroup(GEOM::GEOM_Object_ptr theFace, CORBA::Double x, CORBA::Double y, CORBA::Double z, 
                                                                const char* theVertexName, const char* theGroupName)
{
  ASSERT(myBaseImpl);

  if ((theFace->GetShapeType() != GEOM::FACE) && (theFace->GetShapeType() != GEOM::COMPOUND)) {
    THROW_SALOME_CORBA_EXCEPTION("theFace shape type is not FACE or COMPOUND", SALOME_CMOD::BAD_PARAM);
  }

  string theFaceEntry = theFace->GetStudyEntry();
  
  if (theFaceEntry.empty()) {
    GEOM::GEOM_Gen_ptr geomGen = SMESH_Gen_i::GetGeomEngine( theFace );
    string aName;
    if (theFace->GetShapeType() == GEOM::FACE)
      aName = "Face_";
    if (theFace->GetShapeType() == GEOM::COMPOUND)
      aName = "Compound_";
    aName += theFace->GetEntry();
    SALOMEDS::SObject_wrap theSFace = geomGen->PublishInStudy(NULL, theFace, aName.c_str());
    if (!theSFace->_is_nil())
      theFaceEntry = theSFace->GetID();
  }
  if (theFaceEntry.empty())
    THROW_SALOME_CORBA_EXCEPTION( "Geom object is not published in study" ,SALOME_CMOD::BAD_PARAM );
  try {
    return SetEnforcedVertexEntry(theFaceEntry.c_str(), x, y, z, theVertexName, "", theGroupName);
  } catch (SALOME_Exception& ex) {
    THROW_SALOME_CORBA_EXCEPTION( ex.what() ,SALOME_CMOD::BAD_PARAM );
  }
}

/*!
 * Set an enforced vertex with geom entry and group name on face
 */
bool BLSURFPlugin_Hypothesis_i::SetEnforcedVertexGeomWithGroup(GEOM::GEOM_Object_ptr theFace, GEOM::GEOM_Object_ptr theVertex, const char* theGroupName)
{
  ASSERT(myBaseImpl);

  if ((theFace->GetShapeType() != GEOM::FACE) && (theFace->GetShapeType() != GEOM::COMPOUND)) {
    THROW_SALOME_CORBA_EXCEPTION("theFace shape type is not FACE or COMPOUND", SALOME_CMOD::BAD_PARAM);
  }

  if ((theVertex->GetShapeType() != GEOM::VERTEX) && (theVertex->GetShapeType() != GEOM::COMPOUND)) {
    THROW_SALOME_CORBA_EXCEPTION("theVertex shape type is not VERTEX or COMPOUND", SALOME_CMOD::BAD_PARAM);
  }

  string theFaceEntry = theFace->GetStudyEntry();
  string theVertexEntry = theVertex->GetStudyEntry();
  
  GEOM::GEOM_Gen_ptr geomGen = SMESH_Gen_i::GetGeomEngine( theFace );
  string aName;
  
  if (theFaceEntry.empty()) {
    if (theFace->GetShapeType() == GEOM::FACE)
      aName = "Face_";
    if (theFace->GetShapeType() == GEOM::COMPOUND)
      aName = "Compound_";
    aName += theFace->GetEntry();
    SALOMEDS::SObject_wrap theSFace = geomGen->PublishInStudy(NULL, theFace, aName.c_str());
    if (!theSFace->_is_nil())
      theFaceEntry = theSFace->GetID();
  }
  if (theFaceEntry.empty())
    THROW_SALOME_CORBA_EXCEPTION( "Geom object is not published in study" ,SALOME_CMOD::BAD_PARAM );
  
  if (theVertexEntry.empty()) {
    if (theVertex->GetShapeType() == GEOM::VERTEX)
      aName = "Vertex_";
    if (theVertex->GetShapeType() == GEOM::COMPOUND)
      aName = "Compound_";
    aName += theVertex->GetEntry();
    SALOMEDS::SObject_wrap theSVertex = geomGen->PublishInStudy(NULL, theVertex, aName.c_str());
    if (!theSVertex->_is_nil())
      theVertexEntry = theSVertex->GetID();
  }
  if (theVertexEntry.empty())
    THROW_SALOME_CORBA_EXCEPTION( "Geom object is not published in study" ,SALOME_CMOD::BAD_PARAM );

  string theVertexName = theVertex->GetName();
  try {
    return SetEnforcedVertexEntry(theFaceEntry.c_str(), 0, 0, 0, theVertexName.c_str(), theVertexEntry.c_str(), theGroupName);
  } catch (SALOME_Exception& ex) {
    THROW_SALOME_CORBA_EXCEPTION( ex.what() ,SALOME_CMOD::BAD_PARAM );
  }
}

//Enable internal enforced vertices on specific face if requested by user
///*!
// * Are internal enforced vertices used for a face ?
// */
//CORBA::Boolean BLSURFPlugin_Hypothesis_i::GetInternalEnforcedVertex(GEOM::GEOM_Object_ptr theFace)
//{
//  ASSERT(myBaseImpl);

//  if ((theFace->GetShapeType() != GEOM::FACE) && (theFace->GetShapeType() != GEOM::COMPOUND)) {
//    THROW_SALOME_CORBA_EXCEPTION("theFace shape type is not FACE or COMPOUND", SALOME_CMOD::BAD_PARAM);
//  }

//  string theFaceEntry = theFace->GetStudyEntry();
  
//  if (theFaceEntry.empty()) {
//    GEOM::GEOM_Gen_ptr geomGen = SMESH_Gen_i::GetGeomEngine( theFace );
//    string aName;
//    if (theFace->GetShapeType() == GEOM::FACE)
//      aName = "Face_";
//    if (theFace->GetShapeType() == GEOM::COMPOUND)
//      aName = "Compound_";
//    aName += theFace->GetEntry();
//    SALOMEDS::SObject_wrap theSFace = geomGen->PublishInStudy(NULL, theFace, aName.c_str());
//    if (!theSFace->_is_nil())
//      theFaceEntry = theSFace->GetID();
//  }
//  if (theFaceEntry.empty())
//    THROW_SALOME_CORBA_EXCEPTION( "Geom object is not published in study" ,SALOME_CMOD::BAD_PARAM );

//  try {
//    return GetInternalEnforcedVertexEntry(theFaceEntry.c_str());
//  } catch (SALOME_Exception& ex) {
//    THROW_SALOME_CORBA_EXCEPTION( ex.what() ,SALOME_CMOD::BAD_PARAM );
//  }
//}

/*!
 * Get the list of all enforced vertices
 */
BLSURFPlugin::TEnfVertexList* BLSURFPlugin_Hypothesis_i::GetEnforcedVertices(GEOM::GEOM_Object_ptr theFace)
{
  ASSERT(myBaseImpl);

  if ((theFace->GetShapeType() != GEOM::FACE) && (theFace->GetShapeType() != GEOM::COMPOUND)) {
    THROW_SALOME_CORBA_EXCEPTION("theFace shape type is not FACE or COMPOUND", SALOME_CMOD::BAD_PARAM);
  }

  string theFaceEntry = theFace->GetStudyEntry();
  
  if (theFaceEntry.empty()) {
    GEOM::GEOM_Gen_ptr geomGen = SMESH_Gen_i::GetGeomEngine( theFace );
    string aName;
    if (theFace->GetShapeType() == GEOM::FACE)
      aName = "Face_";
    if (theFace->GetShapeType() == GEOM::COMPOUND)
      aName = "Compound_";
    aName += theFace->GetEntry();
    SALOMEDS::SObject_wrap theSFace = geomGen->PublishInStudy(NULL, theFace, aName.c_str());
    if (!theSFace->_is_nil())
      theFaceEntry = theSFace->GetID();
  }
  if (theFaceEntry.empty())
    THROW_SALOME_CORBA_EXCEPTION( "Geom object is not published in study" ,SALOME_CMOD::BAD_PARAM );

  try {
    return GetEnforcedVerticesEntry(theFaceEntry.c_str());
  } catch (SALOME_Exception& ex) {
    THROW_SALOME_CORBA_EXCEPTION( ex.what() ,SALOME_CMOD::BAD_PARAM );
  }
}

bool BLSURFPlugin_Hypothesis_i::UnsetEnforcedVertex(GEOM::GEOM_Object_ptr theFace, CORBA::Double x, CORBA::Double y,
                                                    CORBA::Double z) {
  ASSERT(myBaseImpl);

  if ((theFace->GetShapeType() != GEOM::FACE) && (theFace->GetShapeType() != GEOM::COMPOUND)) {
    THROW_SALOME_CORBA_EXCEPTION("theFace shape type is not FACE or COMPOUND", SALOME_CMOD::BAD_PARAM);
  }

  string theFaceEntry = theFace->GetStudyEntry();
  
  if (theFaceEntry.empty()) {
    GEOM::GEOM_Gen_ptr geomGen = SMESH_Gen_i::GetGeomEngine( theFace );
    string aName;
    if (theFace->GetShapeType() == GEOM::FACE)
      aName = "Face_";
    if (theFace->GetShapeType() == GEOM::COMPOUND)
      aName = "Compound_";
    aName += theFace->GetEntry();
    SALOMEDS::SObject_wrap theSFace = geomGen->PublishInStudy(NULL, theFace, aName.c_str());
    if (!theSFace->_is_nil())
      theFaceEntry = theSFace->GetID();
  }
  if (theFaceEntry.empty())
    THROW_SALOME_CORBA_EXCEPTION( "Geom object is not published in study" ,SALOME_CMOD::BAD_PARAM );

  try {
    return UnsetEnforcedVertexEntry(theFaceEntry.c_str(), x, y, z);
  } catch (SALOME_Exception& ex) {
    THROW_SALOME_CORBA_EXCEPTION( ex.what() ,SALOME_CMOD::BAD_PARAM );
  }
}

bool BLSURFPlugin_Hypothesis_i::UnsetEnforcedVertexGeom(GEOM::GEOM_Object_ptr theFace, GEOM::GEOM_Object_ptr theVertex)
{
  ASSERT(myBaseImpl);

  if ((theFace->GetShapeType() != GEOM::FACE) && (theFace->GetShapeType() != GEOM::COMPOUND)) {
    THROW_SALOME_CORBA_EXCEPTION("theFace shape type is not FACE or COMPOUND", SALOME_CMOD::BAD_PARAM);
  }
  if ((theVertex->GetShapeType() != GEOM::VERTEX) && (theVertex->GetShapeType() != GEOM::COMPOUND)) {
    THROW_SALOME_CORBA_EXCEPTION("theVertex shape type is not VERTEX or COMPOUND", SALOME_CMOD::BAD_PARAM);
  }

  //  GEOM::GEOM_Gen_ptr geomGen = SMESH_Gen_i::GetGeomEngine( theFace );
  //  GEOM::GEOM_IMeasureOperations_var measureOp = geomGen->GetIMeasureOperations();
  //  if (CORBA::is_nil(measureOp))
  //    return false;
  //
  //  CORBA::Double x, y, z;
  //  x = y = z = 0.;
  //  measureOp->PointCoordinates(theVertex, x, y, z);

  std::string theFaceEntry = theFace->GetStudyEntry();
  std::string theVertexEntry = theVertex->GetStudyEntry();
  
  GEOM::GEOM_Gen_ptr geomGen = SMESH_Gen_i::GetGeomEngine( theFace );
  string aName;
  
  if (theFaceEntry.empty()) {
    if (theFace->GetShapeType() == GEOM::FACE)
      aName = "Face_";
    if (theFace->GetShapeType() == GEOM::COMPOUND)
      aName = "Compound_";
    aName += theFace->GetEntry();
    SALOMEDS::SObject_wrap theSFace = geomGen->PublishInStudy(NULL, theFace, aName.c_str());
    if (!theSFace->_is_nil())
      theFaceEntry = theSFace->GetID();
  }
  if (theFaceEntry.empty())
    THROW_SALOME_CORBA_EXCEPTION( "Geom object is not published in study" ,SALOME_CMOD::BAD_PARAM );
  
  if (theVertexEntry.empty()) {
    if (theVertex->GetShapeType() == GEOM::VERTEX)
      aName = "Vertex_";
    if (theVertex->GetShapeType() == GEOM::COMPOUND)
      aName = "Compound_";
    aName += theVertex->GetEntry();
    SALOMEDS::SObject_wrap theSVertex = geomGen->PublishInStudy(NULL, theVertex, aName.c_str());
    if (!theSVertex->_is_nil())
      theVertexEntry = theSVertex->GetID();
  }
  if (theVertexEntry.empty())
    THROW_SALOME_CORBA_EXCEPTION( "Geom object is not published in study" ,SALOME_CMOD::BAD_PARAM );
  

  try {
    return UnsetEnforcedVertexEntry(theFaceEntry.c_str(), 0, 0, 0, theVertexEntry.c_str());
  } catch (SALOME_Exception& ex) {
    THROW_SALOME_CORBA_EXCEPTION( ex.what() ,SALOME_CMOD::BAD_PARAM );
  }
}

bool BLSURFPlugin_Hypothesis_i::UnsetEnforcedVertices(GEOM::GEOM_Object_ptr theFace) {
  ASSERT(myBaseImpl);

  if ((theFace->GetShapeType() != GEOM::FACE) && (theFace->GetShapeType() != GEOM::COMPOUND)) {
    THROW_SALOME_CORBA_EXCEPTION("theFace shape type is not FACE or COMPOUND", SALOME_CMOD::BAD_PARAM);
  }

  string theFaceEntry = theFace->GetStudyEntry();
  
  if (theFaceEntry.empty()) {
    GEOM::GEOM_Gen_ptr geomGen = SMESH_Gen_i::GetGeomEngine( theFace );
    string aName;
    if (theFace->GetShapeType() == GEOM::FACE)
      aName = "Face_";
    if (theFace->GetShapeType() == GEOM::COMPOUND)
      aName = "Compound_";
    aName += theFace->GetEntry();
    SALOMEDS::SObject_wrap theSFace = geomGen->PublishInStudy(NULL, theFace, aName.c_str());
    if (!theSFace->_is_nil())
      theFaceEntry = theSFace->GetID();
  }
  if (theFaceEntry.empty())
    THROW_SALOME_CORBA_EXCEPTION( "Geom object is not published in study" ,SALOME_CMOD::BAD_PARAM );
  

  try {
    return UnsetEnforcedVerticesEntry(theFaceEntry.c_str());
  } catch (SALOME_Exception& ex) {
    THROW_SALOME_CORBA_EXCEPTION( ex.what() ,SALOME_CMOD::BAD_PARAM );
  }
}

/*!
 * Set/get/unset an enforced vertex on face - NEW (no face)
 */
bool BLSURFPlugin_Hypothesis_i::AddEnforcedVertex(CORBA::Double x, CORBA::Double y, CORBA::Double z)
{
  ASSERT(myBaseImpl);

  try {
    return SetEnforcedVertexEntry("", x, y, z);
  } catch (SALOME_Exception& ex) {
    THROW_SALOME_CORBA_EXCEPTION( ex.what() ,SALOME_CMOD::BAD_PARAM );
  }
}

/*!
 * Set/get/unset an enforced vertex with name on face
 */
bool BLSURFPlugin_Hypothesis_i::AddEnforcedVertexNamed(CORBA::Double x, CORBA::Double y, CORBA::Double z, const char* theVertexName)
{
  try {
    return SetEnforcedVertexEntry("", x, y, z, theVertexName);
  } catch (SALOME_Exception& ex) {
    THROW_SALOME_CORBA_EXCEPTION( ex.what() ,SALOME_CMOD::BAD_PARAM );
  }
}

/*!
 * Set/get/unset an enforced vertex with geom object on face
 */
bool BLSURFPlugin_Hypothesis_i::AddEnforcedVertexGeom(GEOM::GEOM_Object_ptr theVertex)
{
  if ((theVertex->GetShapeType() != GEOM::VERTEX) && (theVertex->GetShapeType() != GEOM::COMPOUND)) {
    THROW_SALOME_CORBA_EXCEPTION("theVertex shape type is not VERTEX or COMPOUND", SALOME_CMOD::BAD_PARAM);
  }
  string theVertexEntry = theVertex->GetStudyEntry();
  
  GEOM::GEOM_Gen_ptr geomGen = SMESH_Gen_i::GetGeomEngine( theVertex );
  string aName;
  
  if (theVertexEntry.empty()) {
    if (theVertex->GetShapeType() == GEOM::VERTEX)
      aName = "Vertex_";
    if (theVertex->GetShapeType() == GEOM::COMPOUND)
      aName = "Compound_";
    aName += theVertex->GetEntry();
    SALOMEDS::SObject_wrap theSVertex = geomGen->PublishInStudy( NULL, theVertex, aName.c_str());
    if (!theSVertex->_is_nil())
      theVertexEntry = theSVertex->GetID();
  }
  if (theVertexEntry.empty())
    THROW_SALOME_CORBA_EXCEPTION( "Geom object is not published in study" ,SALOME_CMOD::BAD_PARAM );

  string theVertexName = theVertex->GetName();
  try {
    return SetEnforcedVertexEntry("", 0, 0, 0, theVertexName.c_str(), theVertexEntry.c_str());
  } catch (SALOME_Exception& ex) {
    THROW_SALOME_CORBA_EXCEPTION( ex.what() ,SALOME_CMOD::BAD_PARAM );
  }
}

/*!
 * Set an enforced vertex with group name on face
 */
bool BLSURFPlugin_Hypothesis_i::AddEnforcedVertexWithGroup(CORBA::Double x, CORBA::Double y, CORBA::Double z, const char* theGroupName)
{
  ASSERT(myBaseImpl);

  try {
    return SetEnforcedVertexEntry("", x, y, z, "", "", theGroupName);
  } catch (SALOME_Exception& ex) {
    THROW_SALOME_CORBA_EXCEPTION( ex.what() ,SALOME_CMOD::BAD_PARAM );
  }
}

/*!
 * Set an enforced vertex with name and group name on face
 */
bool BLSURFPlugin_Hypothesis_i::AddEnforcedVertexNamedWithGroup(CORBA::Double x, CORBA::Double y, CORBA::Double z, 
                                                                const char* theVertexName, const char* theGroupName)
{
  ASSERT(myBaseImpl);

  try {
    return SetEnforcedVertexEntry("", x, y, z, theVertexName, "", theGroupName);
  } catch (SALOME_Exception& ex) {
    THROW_SALOME_CORBA_EXCEPTION( ex.what() ,SALOME_CMOD::BAD_PARAM );
  }
}

/*!
 * Set an enforced vertex with geom entry and group name on face
 */
bool BLSURFPlugin_Hypothesis_i::AddEnforcedVertexGeomWithGroup(GEOM::GEOM_Object_ptr theVertex, const char* theGroupName)
{
  if ((theVertex->GetShapeType() != GEOM::VERTEX) && (theVertex->GetShapeType() != GEOM::COMPOUND)) {
    THROW_SALOME_CORBA_EXCEPTION("theVertex shape type is not VERTEX or COMPOUND", SALOME_CMOD::BAD_PARAM);
  }

  string theVertexEntry = theVertex->GetStudyEntry();
  
  GEOM::GEOM_Gen_ptr geomGen = SMESH_Gen_i::GetGeomEngine( theVertex );
  string aName;
  
  if (theVertexEntry.empty()) {
    if (theVertex->GetShapeType() == GEOM::VERTEX)
      aName = "Vertex_";
    if (theVertex->GetShapeType() == GEOM::COMPOUND)
      aName = "Compound_";
    aName += theVertex->GetEntry();
    SALOMEDS::SObject_wrap theSVertex = geomGen->PublishInStudy( NULL, theVertex, aName.c_str());
    if (!theSVertex->_is_nil())
      theVertexEntry = theSVertex->GetID();
  }
  if (theVertexEntry.empty())
    THROW_SALOME_CORBA_EXCEPTION( "Geom object is not published in study" ,SALOME_CMOD::BAD_PARAM );

  string theVertexName = theVertex->GetName();
  try {
    return SetEnforcedVertexEntry("", 0, 0, 0, theVertexName.c_str(), theVertexEntry.c_str(), theGroupName);
  } catch (SALOME_Exception& ex) {
    THROW_SALOME_CORBA_EXCEPTION( ex.what() ,SALOME_CMOD::BAD_PARAM );
  }
}

bool BLSURFPlugin_Hypothesis_i::RemoveEnforcedVertex(CORBA::Double x, CORBA::Double y, CORBA::Double z)
{
  try {
    return UnsetEnforcedVertexEntry("", x, y, z);
  } catch (SALOME_Exception& ex) {
    THROW_SALOME_CORBA_EXCEPTION( ex.what() ,SALOME_CMOD::BAD_PARAM );
  }
}

bool BLSURFPlugin_Hypothesis_i::RemoveEnforcedVertexGeom(GEOM::GEOM_Object_ptr theVertex)
{
  if ((theVertex->GetShapeType() != GEOM::VERTEX) && (theVertex->GetShapeType() != GEOM::COMPOUND)) {
    THROW_SALOME_CORBA_EXCEPTION("theVertex shape type is not VERTEX or COMPOUND", SALOME_CMOD::BAD_PARAM);
  }
  std::string theVertexEntry = theVertex->GetStudyEntry();
  
  GEOM::GEOM_Gen_ptr geomGen = SMESH_Gen_i::GetGeomEngine( theVertex );
  string aName;
  
  if (theVertexEntry.empty()) {
    if (theVertex->GetShapeType() == GEOM::VERTEX)
      aName = "Vertex_";
    if (theVertex->GetShapeType() == GEOM::COMPOUND)
      aName = "Compound_";
    aName += theVertex->GetEntry();
    SALOMEDS::SObject_wrap theSVertex = geomGen->PublishInStudy( NULL, theVertex, aName.c_str());
    if (!theSVertex->_is_nil())
      theVertexEntry = theSVertex->GetID();
  }
  if (theVertexEntry.empty())
    THROW_SALOME_CORBA_EXCEPTION( "Geom object is not published in study" ,SALOME_CMOD::BAD_PARAM );
  
  try {
    return UnsetEnforcedVertexEntry("", 0, 0, 0, theVertexEntry.c_str());
  } catch (SALOME_Exception& ex) {
    THROW_SALOME_CORBA_EXCEPTION( ex.what() ,SALOME_CMOD::BAD_PARAM );
  }
}

bool BLSURFPlugin_Hypothesis_i::RemoveEnforcedVertices()
{
  try {
    return UnsetEnforcedVerticesEntry("");
  } catch (SALOME_Exception& ex) {
    THROW_SALOME_CORBA_EXCEPTION( ex.what() ,SALOME_CMOD::BAD_PARAM );
  }
}

/*!
 * Set/get/unset an enforced vertex on geom object given by entry
 */
bool BLSURFPlugin_Hypothesis_i::SetEnforcedVertexEntry(const char* theFaceEntry,
                                                       CORBA::Double x,
                                                       CORBA::Double y,
                                                       CORBA::Double z,
                                                       const char* theVertexName,
                                                       const char* theVertexEntry,
                                                       const char* theGroupName)
{
  bool newValue = false;
  if (string(theVertexEntry).empty()) {
    try {
      ::BLSURFPlugin_Hypothesis::TEnfVertexCoordsList coordsList =
        this->GetImpl()->GetEnfVertexCoordsList(theFaceEntry);
      ::BLSURFPlugin_Hypothesis::TEnfVertexCoords coords;
      coords.push_back(x);
      coords.push_back(y);
      coords.push_back(z);
      if (coordsList.find(coords) == coordsList.end()) {
        newValue = true;
      } else {
        ::BLSURFPlugin_Hypothesis::TEnfVertex *enfVertex = this->GetImpl()->GetEnfVertex(coords);
        if ((enfVertex->name != theVertexName) || (enfVertex->grpName != theGroupName)) {
          newValue = true;
        }
      }
    } catch (const std::invalid_argument& ex) {
      // no enforced vertex for entry
      newValue = true;
    }
    if (newValue) {
      if (string(theVertexName).empty()) {
        if (string(theGroupName).empty())
          SMESH::TPythonDump() << _this() << ".AddEnforcedVertex(" << x << ", " << y << ", " << z << ")";
        else
          SMESH::TPythonDump() << _this() << ".AddEnforcedVertexWithGroup(" << x << ", " << y << ", " << z << ", \"" << theGroupName << "\")";
      }
      else {
        if (string(theGroupName).empty())
          SMESH::TPythonDump() << _this() << ".AddEnforcedVertexNamed(" << x << ", " << y << ", " << z << ", \"" << theVertexName << "\")";
        else
          SMESH::TPythonDump() << _this() << ".AddEnforcedVertexNamedWithGroup(" << x << ", " << y << ", " << z << ", \""
                               << theVertexName << "\", \"" << theGroupName << "\")";
      }
    }
  } else {
    try {
      ::BLSURFPlugin_Hypothesis::TEntryList enfVertexEntryList = this->GetImpl()->GetEnfVertexEntryList(theFaceEntry);
      ::BLSURFPlugin_Hypothesis::TEntryList::const_iterator it = enfVertexEntryList.find(theVertexEntry);
      if ( it == enfVertexEntryList.end()) {
        newValue = true;
      }
      else {
        ::BLSURFPlugin_Hypothesis::TEnfVertex *enfVertex = this->GetImpl()->GetEnfVertex((*it));
        if ((enfVertex->name != theVertexName) || (enfVertex->grpName != theGroupName)) {
          newValue = true;
        }
      }
    } catch (const std::invalid_argument& ex) {
      // no enforced vertex for entry
      newValue = true;
    }
    if (newValue) {
      if (string(theGroupName).empty())
        SMESH::TPythonDump() << _this() << ".AddEnforcedVertexGeom(" << theVertexEntry << ")";
      else
        SMESH::TPythonDump() << _this() << ".AddEnforcedVertexGeomWithGroup(" << theVertexEntry << ", \"" << theGroupName << "\")";
    }
  }

  if (newValue)
    this->GetImpl()->SetEnforcedVertex(theFaceEntry, theVertexName, theVertexEntry, theGroupName, x, y, z);

  return newValue;
}

BLSURFPlugin::TEnfVertexList* BLSURFPlugin_Hypothesis_i::GetEnforcedVerticesEntry(const char* entry)
{
  try {
    BLSURFPlugin::TEnfVertexList_var vertexList = new BLSURFPlugin::TEnfVertexList();
    ::BLSURFPlugin_Hypothesis::TEnfVertexList _vList = this->GetImpl()->GetEnfVertexList(entry);
    vertexList->length((CORBA::ULong) _vList.size());
    ::BLSURFPlugin_Hypothesis::TEnfVertexList::const_iterator evlIt = _vList.begin();
    for (int i = 0; evlIt != _vList.end(); ++evlIt, ++i) {
      ::BLSURFPlugin_Hypothesis::TEnfVertex *_enfVertex = (*evlIt);

      BLSURFPlugin::TEnfVertex_var enfVertex = new BLSURFPlugin::TEnfVertex();

      // Name
      enfVertex->name = CORBA::string_dup(_enfVertex->name.c_str());
      // Geom Vertex Entry
      enfVertex->geomEntry = CORBA::string_dup(_enfVertex->geomEntry.c_str());
      // Coords
      BLSURFPlugin::TEnfVertexCoords_var coords = new BLSURFPlugin::TEnfVertexCoords();
      coords->length((CORBA::ULong) _enfVertex->coords.size());
      for ( CORBA::ULong ind = 0; ind < coords->length(); ind++ )
        coords[ind] = _enfVertex->coords[ind];
      enfVertex->coords = coords;
      // Group Name
      enfVertex->grpName = CORBA::string_dup(_enfVertex->grpName.c_str());
      // Face entry list
      BLSURFPlugin::TEntryList_var faceEntryList = new BLSURFPlugin::TEntryList();
      faceEntryList->length((CORBA::ULong) _enfVertex->faceEntries.size());
      ::BLSURFPlugin_Hypothesis::TEntryList::const_iterator it_entry = _enfVertex->faceEntries.begin();
      for (int ind = 0; it_entry != _enfVertex->faceEntries.end();++it_entry, ++ind)
        faceEntryList[ind] = CORBA::string_dup((*it_entry).c_str());
      enfVertex->faceEntries = faceEntryList;

      vertexList[i] = enfVertex;
    }
    return vertexList._retn();
  } catch (const std::invalid_argument& ex) {
    SALOME_CMOD::ExceptionStruct ExDescription;
    ExDescription.text = ex.what();
    ExDescription.type = SALOME_CMOD::BAD_PARAM;
    ExDescription.sourceFile = "BLSURFPlugin_Hypothesis_i::GetEnforcedVerticesEntry(entry)";
    ExDescription.lineNumber = 1385;
    throw SALOME_CMOD::SALOME_Exception(ExDescription);
  } catch (const std::exception& ex) {
    std::cout << "Exception: " << ex.what() << std::endl;
    THROW_SALOME_CORBA_EXCEPTION( ex.what() ,SALOME_CMOD::BAD_PARAM );
  }
}

bool BLSURFPlugin_Hypothesis_i::UnsetEnforcedVertexEntry(const char* theFaceEntry, CORBA::Double x, CORBA::Double y, CORBA::Double z, const char* theVertexEntry)
{
  ASSERT(myBaseImpl);

  bool res = false;
  try {
    res = this->GetImpl()->ClearEnforcedVertex(theFaceEntry, x, y, z, theVertexEntry);

    if (string(theVertexEntry).empty())
      SMESH::TPythonDump() << "isDone = " << _this() << ".RemoveEnforcedVertex(" << x << ", " << y << ", " << z
                           << ")";
    else
      SMESH::TPythonDump() << "isDone = " << _this() << ".RemoveEnforcedVertexGeom(" << theVertexEntry << ")";

  } catch (const std::invalid_argument& ex) {
    return false;
  } catch (const std::exception& ex) {
    std::cout << "Exception: " << ex.what() << std::endl;
    THROW_SALOME_CORBA_EXCEPTION( ex.what() ,SALOME_CMOD::BAD_PARAM );
  }

  return res;
}
bool BLSURFPlugin_Hypothesis_i::UnsetEnforcedVerticesEntry(const char* theFaceEntry)
{
  ASSERT(myBaseImpl);

  try {
    this->GetImpl()->ClearEnforcedVertices(theFaceEntry);
    SMESH::TPythonDump() << _this() << ".RemoveEnforcedVertices()";
  } catch (const std::invalid_argument& ex) {
    return false;
  } catch (const std::exception& ex) {
    THROW_SALOME_CORBA_EXCEPTION( ex.what() ,SALOME_CMOD::BAD_PARAM );
  }

  return true;
}

//=============================================================================
/*!
 *  BLSURFPlugin_Hypothesis_i::SetInternalEnforcedVertexAllFaces
 *
 *  Set true or false
 */
//=============================================================================
void BLSURFPlugin_Hypothesis_i::SetInternalEnforcedVertexAllFaces(CORBA::Boolean theValue)
{
  ASSERT(myBaseImpl);
  this->GetImpl()->SetInternalEnforcedVertexAllFaces(theValue);
  std::string theValueStr = theValue ? "True" : "False";
  SMESH::TPythonDump() << _this() << ".SetInternalEnforcedVertexAllFaces( " << theValueStr.c_str() << " )";
}

//=============================================================================
/*!
 *  BLSURFPlugin_Hypothesis_i::GetInternalEnforcedVertexAllFaces
 *
 *  Get true or false
 */
//=============================================================================
CORBA::Boolean BLSURFPlugin_Hypothesis_i::GetInternalEnforcedVertexAllFaces()
{
  ASSERT(myBaseImpl);
  return this->GetImpl()->_GetInternalEnforcedVertexAllFaces();
}

//=============================================================================
/*!
 *  BLSURFPlugin_Hypothesis_i::SetInternalEnforcedVertexAllFacesGroup
 *
 *  Set group name
 */
//=============================================================================
void BLSURFPlugin_Hypothesis_i::SetInternalEnforcedVertexAllFacesGroup(const char*  groupName)
{
  ASSERT(myBaseImpl);
  this->GetImpl()->SetInternalEnforcedVertexAllFacesGroup(groupName);
  SMESH::TPythonDump() << _this() << ".SetInternalEnforcedVertexAllFacesGroup( \"" << groupName << "\" )";
}

//=============================================================================
/*!
 *  BLSURFPlugin_Hypothesis_i::GetInternalEnforcedVertexAllFacesGroup
 *
 *  Get group name
 */
//=============================================================================
char* BLSURFPlugin_Hypothesis_i::GetInternalEnforcedVertexAllFacesGroup()
{
  ASSERT(myBaseImpl);
  return CORBA::string_dup(this->GetImpl()->_GetInternalEnforcedVertexAllFacesGroup().c_str());
}

/*
 * Enable internal enforced vertices on specific face if requested by user
 *
 void BLSURFPlugin_Hypothesis_i::SetInternalEnforcedVertex(GEOM::GEOM_Object_ptr theFace, CORBA::Boolean toEnforceInternalVertices)
 {
 try {
 SetInternalEnforcedVertexWithGroup(theFace, toEnforceInternalVertices);
 } catch (SALOME_Exception& ex) {
 THROW_SALOME_CORBA_EXCEPTION( ex.what() ,SALOME_CMOD::BAD_PARAM );
 }
 }

 void BLSURFPlugin_Hypothesis_i::SetInternalEnforcedVertexWithGroup(GEOM::GEOM_Object_ptr theFace, CORBA::Boolean toEnforceInternalVertices, const char* theGroupName)
 {
 if ((theFace->GetShapeType() != GEOM::FACE) && (theFace->GetShapeType() != GEOM::COMPOUND)) {
 THROW_SALOME_CORBA_EXCEPTION("theFace shape type is not FACE or COMPOUND", SALOME_CMOD::BAD_PARAM);
 }

 string theFaceEntry = theFace->GetStudyEntry();

 if (theFaceEntry.empty()) {
 GEOM::GEOM_Gen_ptr geomGen = SMESH_Gen_i::GetGeomEngine( theFace );
 SMESH_Gen_i *smeshGen = SMESH_Gen_i::GetSMESHGen();
 string aName;
 if (theFace->GetShapeType() == GEOM::FACE)
 aName = "Face_";
 if (theFace->GetShapeType() == GEOM::COMPOUND)
 aName = "Compound_";
 aName += theFace->GetEntry();
 SALOMEDS::SObject_wrap theSFace = geomGen->PublishInStudy(NULL, theFace, aName.c_str());
 if (!theSFace->_is_nil())
 theFaceEntry = theSFace->GetID();
 }
 if (theFaceEntry.empty())
 THROW_SALOME_CORBA_EXCEPTION( "Geom object is not published in study" ,SALOME_CMOD::BAD_PARAM );

 try {
 SetInternalEnforcedVertexEntry(theFaceEntry.c_str(), toEnforceInternalVertices, theGroupName);
 } catch (SALOME_Exception& ex) {
 THROW_SALOME_CORBA_EXCEPTION( ex.what() ,SALOME_CMOD::BAD_PARAM );
 }
 }

 void BLSURFPlugin_Hypothesis_i::SetInternalEnforcedVertexEntry(const char* theFaceEntry, CORBA::Boolean toEnforceInternalVertices, const char* theGroupName)
 {
 ASSERT(myBaseImpl);
 try {
 this->GetImpl()->SetInternalEnforcedVertex(theFaceEntry, toEnforceInternalVertices, theGroupName);
 std::string theValueStr = toEnforceInternalVertices ? "True" : "False";
 if (string(theGroupName).empty())
 SMESH::TPythonDump() << _this() << ".SetInternalEnforcedVertex( " << theFaceEntry << ", " << theValueStr.c_str() << " )";
 else
 SMESH::TPythonDump() << _this() << ".SetInternalEnforcedVertexWithGroup( " << theFaceEntry << ", " << theValueStr.c_str() << ", \"" << theGroupName << "\" )";
 } catch (const std::exception& ex) {
 std::cout << "Exception: " << ex.what() << std::endl;
 THROW_SALOME_CORBA_EXCEPTION( ex.what() ,SALOME_CMOD::BAD_PARAM );
 }
 }

*/

/* TODO GROUPS
   char* BLSURFPlugin_Hypothesis_i::GetEnforcedVertexGroupName(CORBA::Double x, CORBA::Double y, CORBA::Double z)
   
   {
   ASSERT(myBaseImpl);
   try {
   return CORBA::string_dup( this->GetImpl()->GetEnforcedVertexGroupName(x, y, z).c_str());
   }
   catch (const std::invalid_argument& ex) {
   SALOME_CMOD::ExceptionStruct ExDescription;
   ExDescription.text = ex.what();
   ExDescription.type = SALOME_CMOD::BAD_PARAM;
   ExDescription.sourceFile = "BLSURFPlugin_Hypothesis_i::GetEnforcedVertexGroupName(entry)";
   ExDescription.lineNumber = 1146;
   throw SALOME_CMOD::SALOME_Exception(ExDescription);
   }
   catch (SALOME_Exception& ex) {
   THROW_SALOME_CORBA_EXCEPTION( ex.what() ,SALOME_CMOD::BAD_PARAM );
   }
   return 0;
   }


   void BLSURFPlugin_Hypothesis_i::SetEnforcedVertexGroupName(CORBA::Double x, CORBA::Double y, CORBA::Double z, const char* groupName)
   {
   ASSERT(myBaseImpl);
   try {
   this->GetImpl()->SetEnforcedVertexGroupName(x, y, z, groupName);
   }
   catch (const std::invalid_argument& ex) {
   SALOME_CMOD::ExceptionStruct ExDescription;
   ExDescription.text = ex.what();
   ExDescription.type = SALOME_CMOD::BAD_PARAM;
   ExDescription.sourceFile = "BLSURFPlugin_Hypothesis::SetEnforcedVertexGroupName(x,y,z)";
   ExDescription.lineNumber = 1170;
   throw SALOME_CMOD::SALOME_Exception(ExDescription);
   }
   catch (SALOME_Exception& ex) {
   THROW_SALOME_CORBA_EXCEPTION( ex.what() ,SALOME_CMOD::BAD_PARAM );
   }

   SMESH::TPythonDump() << _this() << ".SetEnforcedVertexGroupName("
   << x << ", " << y << ", " << z << ", '" << groupName << "' )";

   }
*/
///////////////////////

///////////////////////
// PERIODICITY       //
///////////////////////


std::string BLSURFPlugin_Hypothesis_i::ShapeTypeToString(GEOM::shape_type theShapeType)
{
  std::map<GEOM::shape_type, std::string> MapShapeTypeToString;
  MapShapeTypeToString[GEOM::COMPOUND] = std::string("COMPOUND");
  MapShapeTypeToString[GEOM::COMPSOLID] = std::string("COMPSOLID");
  MapShapeTypeToString[GEOM::SOLID] = std::string("SOLID");
  MapShapeTypeToString[GEOM::SHELL] = std::string("SHELL");
  MapShapeTypeToString[GEOM::FACE] = std::string("FACE");
  MapShapeTypeToString[GEOM::WIRE] = std::string("WIRE");
  MapShapeTypeToString[GEOM::EDGE] = std::string("EDGE");
  MapShapeTypeToString[GEOM::VERTEX] = std::string("VERTEX");
  MapShapeTypeToString[GEOM::SHAPE] = std::string("SHAPE");
  std::string txtShapeType = MapShapeTypeToString[theShapeType];
  return txtShapeType;
}

void BLSURFPlugin_Hypothesis_i::CheckShapeTypes(GEOM::GEOM_Object_ptr shape, std::vector<GEOM::shape_type> theShapeTypes)
{
  // Check shape types
  bool ok = false;
  std::stringstream typesTxt;
  for (std::size_t i=0; i<theShapeTypes.size(); i++)
  {
    GEOM::shape_type theShapeType = theShapeTypes[i];
    if (shape->GetShapeType() == theShapeType)
      ok = true;
    typesTxt << ShapeTypeToString(theShapeType);
    if (i < theShapeTypes.size()-1 )
      typesTxt << ", ";
  }
  if (!ok)
  {
    std::stringstream msg;
    msg << "shape type is not in" << typesTxt.str();
    THROW_SALOME_CORBA_EXCEPTION(msg.str().c_str(), SALOME_CMOD::BAD_PARAM);
  }
}

void BLSURFPlugin_Hypothesis_i::CheckShapeType(GEOM::GEOM_Object_ptr shape, GEOM::shape_type theShapeType)
{
  // Check shape type
  if (shape->GetShapeType() != theShapeType) {
    std::stringstream msg;
    msg << "shape shape type is not " << ShapeTypeToString(theShapeType);
    THROW_SALOME_CORBA_EXCEPTION(msg.str().c_str(), SALOME_CMOD::BAD_PARAM);
  }
}

std::string BLSURFPlugin_Hypothesis_i::PublishIfNeeded(GEOM::GEOM_Object_ptr shape, GEOM::shape_type theShapeType, std::string prefix)
{
  // Check shape is published in the object browser
  string shapeEntry = shape->GetStudyEntry();

  GEOM::GEOM_Gen_ptr geomGen = SMESH_Gen_i::GetGeomEngine( shape );
  string aName;

  // Publish shape if needed
  if (shapeEntry.empty()) {
    if (shape->GetShapeType() == theShapeType)
      aName = prefix;
    aName += shape->GetEntry();
    SALOMEDS::SObject_wrap theSFace1 = geomGen->PublishInStudy(NULL, shape, aName.c_str());
    if (!theSFace1->_is_nil())
      shapeEntry = theSFace1->GetID();
  }
  if (shapeEntry.empty())
    THROW_SALOME_CORBA_EXCEPTION( "Geom object is not published in study" ,SALOME_CMOD::BAD_PARAM );
  return shapeEntry;
}

// Format the output of two vectors to use it in MESSAGE and PythonDump
std::string BLSURFPlugin_Hypothesis_i::FormatVerticesEntries(vector<string> &theSourceVerticesEntries, vector<string> &theTargetVerticesEntries)
{
  std::stringstream listEntriesTxt;

  if (!theSourceVerticesEntries.empty())
  {
    listEntriesTxt << ", [" ;
    size_t i =0;
    for (std::vector<std::string>::const_iterator it = theSourceVerticesEntries.begin(); it != theSourceVerticesEntries.end(); it++, i++)
    {
      if (i>0)
        listEntriesTxt << ", ";
      listEntriesTxt << *it;
    }

    listEntriesTxt << "], [" ;
    i =0;
    for (std::vector<std::string>::const_iterator it = theTargetVerticesEntries.begin(); it != theTargetVerticesEntries.end(); it++, i++)
    {
      if (i>0)
        listEntriesTxt << ", ";
      listEntriesTxt << *it;
    }
    listEntriesTxt << "]" ;
  }
  return listEntriesTxt.str();
}

/**
 * Erase all PreCad periodicity associations
 */
void BLSURFPlugin_Hypothesis_i::ClearPreCadPeriodicityVectors() {
  ASSERT(myBaseImpl);
  this->GetImpl()->ClearPreCadPeriodicityVectors();
  SMESH::TPythonDump() << _this() << ".ClearPreCadPeriodicityVectors()";
}

BLSURFPlugin::TPeriodicityList* BLSURFPlugin_Hypothesis_i::GetPreCadFacesPeriodicityVector()
{
  const ::BLSURFPlugin_Hypothesis::TPreCadPeriodicityVector preCadPeriodicityVector =
    this->GetImpl()->_GetPreCadFacesPeriodicityVector();

  BLSURFPlugin::TPeriodicityList_var periodicityList = PreCadVectorToSequence(preCadPeriodicityVector);

  return periodicityList._retn();
}

BLSURFPlugin::TPeriodicityList* BLSURFPlugin_Hypothesis_i::GetPreCadEdgesPeriodicityVector()
{
  const ::BLSURFPlugin_Hypothesis::TPreCadPeriodicityVector preCadPeriodicityVector =
    this->GetImpl()->_GetPreCadEdgesPeriodicityVector();

  BLSURFPlugin::TPeriodicityList_var periodicityList = PreCadVectorToSequence(preCadPeriodicityVector);

  return periodicityList._retn();
}

// convert a vector preCadPeriodicityVector into TPeriodicityList Corba sequence
BLSURFPlugin::TPeriodicityList* BLSURFPlugin_Hypothesis_i::PreCadVectorToSequence(const ::BLSURFPlugin_Hypothesis::TPreCadPeriodicityVector& preCadPeriodicityVector)
{
  BLSURFPlugin::TPeriodicityList_var periodicityList = new BLSURFPlugin::TPeriodicityList();

  periodicityList->length((CORBA::ULong) preCadPeriodicityVector.size());

  for ( CORBA::ULong i = 0; i<preCadPeriodicityVector.size(); i++)
  {
    ::BLSURFPlugin_Hypothesis::TPreCadPeriodicity preCadPeriodicityVector_i = preCadPeriodicityVector[i];

    BLSURFPlugin::TPreCadPeriodicity_var myPreCadPeriodicity = new BLSURFPlugin::TPreCadPeriodicity();
    myPreCadPeriodicity->shape1Entry = CORBA::string_dup(preCadPeriodicityVector_i.shape1Entry.c_str());
    myPreCadPeriodicity->shape2Entry = CORBA::string_dup(preCadPeriodicityVector_i.shape2Entry.c_str());

    BLSURFPlugin::TEntryList_var sourceVertices = new BLSURFPlugin::TEntryList();
    if (! preCadPeriodicityVector_i.theSourceVerticesEntries.empty())
    {
      sourceVertices->length((CORBA::ULong) preCadPeriodicityVector_i.theSourceVerticesEntries.size());
      for (CORBA::ULong j=0; j<preCadPeriodicityVector_i.theSourceVerticesEntries.size(); j++)
        sourceVertices[j]=CORBA::string_dup(preCadPeriodicityVector_i.theSourceVerticesEntries[j].c_str());
    }

    myPreCadPeriodicity->theSourceVerticesEntries = sourceVertices;

    BLSURFPlugin::TEntryList_var targetVertices = new BLSURFPlugin::TEntryList();
    if (! preCadPeriodicityVector_i.theTargetVerticesEntries.empty())
    {
      targetVertices->length((CORBA::ULong) preCadPeriodicityVector_i.theTargetVerticesEntries.size());
      for (CORBA::ULong j=0; j<preCadPeriodicityVector_i.theTargetVerticesEntries.size(); j++)
        targetVertices[j]=CORBA::string_dup(preCadPeriodicityVector_i.theTargetVerticesEntries[j].c_str());
    }

    myPreCadPeriodicity->theTargetVerticesEntries = targetVertices;

    periodicityList[i] = myPreCadPeriodicity;
  }


  return periodicityList._retn();
}


void BLSURFPlugin_Hypothesis_i::AddPreCadFacesPeriodicity(GEOM::GEOM_Object_ptr theFace1, GEOM::GEOM_Object_ptr theFace2)
{
  ASSERT(myBaseImpl);
  const GEOM::ListOfGO theSourceVertices;
  const GEOM::ListOfGO theTargetVertices;
  AddPreCadFacesPeriodicityWithVertices(theFace1, theFace2, theSourceVertices, theTargetVertices);
}


void BLSURFPlugin_Hypothesis_i::AddPreCadFacesPeriodicityWithVertices(GEOM::GEOM_Object_ptr theFace1, GEOM::GEOM_Object_ptr theFace2,
                                                                      const GEOM::ListOfGO& theSourceVertices, const GEOM::ListOfGO& theTargetVertices)
{
  ASSERT(myBaseImpl);

  size_t theLength = theSourceVertices.length();
  if (theLength != theTargetVertices.length())
    THROW_SALOME_CORBA_EXCEPTION( "The sizes of theSourceVertices and theTargetVertices must be the same" ,SALOME_CMOD::BAD_PARAM );

  std::vector<GEOM::shape_type> allowedShapeTypes;
  allowedShapeTypes.push_back(GEOM::FACE);
  allowedShapeTypes.push_back(GEOM::COMPOUND);

  string prefix1 = "Source_face_";
  CheckShapeTypes(theFace1, allowedShapeTypes);
  string theFace1Entry = PublishIfNeeded(theFace1, GEOM::FACE, prefix1);

  string prefix2 = "Target_face_";
  CheckShapeTypes(theFace2, allowedShapeTypes);
  string theFace2Entry = PublishIfNeeded(theFace2, GEOM::FACE, prefix2);

  string prefix3 = "Source_vertex_";
  BLSURFPlugin::TEntryList_var theSourceVerticesEntries = new BLSURFPlugin::TEntryList();
  theSourceVerticesEntries->length((CORBA::ULong) theLength);
  GEOM::GEOM_Object_ptr theVtx_i;
  string theEntry_i;
  for (CORBA::ULong ind = 0; ind < theLength; ind++) {
    theVtx_i = theSourceVertices[ind];
    theEntry_i = PublishIfNeeded(theVtx_i, GEOM::VERTEX, prefix3);
    theSourceVerticesEntries[ind] = CORBA::string_dup(theEntry_i.c_str());
  }

  string prefix4 = "Target_vertex_";
  BLSURFPlugin::TEntryList_var theTargetVerticesEntries = new BLSURFPlugin::TEntryList();
  theTargetVerticesEntries->length((CORBA::ULong) theLength);
  for ( CORBA::ULong  ind = 0; ind < theLength; ind++) {
    theVtx_i = theTargetVertices[ind];
    theEntry_i = PublishIfNeeded(theVtx_i, GEOM::VERTEX, prefix4);
    theTargetVerticesEntries[ind] = CORBA::string_dup(theEntry_i.c_str());
  }

  string theFace2Name = theFace2->GetName();
  try {
    AddPreCadFacesPeriodicityEntry(theFace1Entry.c_str(), theFace2Entry.c_str(),
                                   theSourceVerticesEntries, theTargetVerticesEntries);
  } catch (SALOME_Exception& ex) {
    THROW_SALOME_CORBA_EXCEPTION( ex.what() ,SALOME_CMOD::BAD_PARAM );
  }
}


void BLSURFPlugin_Hypothesis_i::AddPreCadFacesPeriodicityEntry(const char* theFace1Entry, const char* theFace2Entry,
                                                               const BLSURFPlugin::TEntryList& theSourceVerticesEntriesCorba, const BLSURFPlugin::TEntryList& theTargetVerticesEntriesCorba)
{
  ASSERT(myBaseImpl);

  // Convert BLSURFPlugin::TEntryList to vector<string>
  vector<string> theSourceVerticesEntries, theTargetVerticesEntries;
  for ( CORBA::ULong  ind = 0; ind < theSourceVerticesEntriesCorba.length(); ind++) {
    theSourceVerticesEntries.push_back(theSourceVerticesEntriesCorba[ind].in());
    theTargetVerticesEntries.push_back(theTargetVerticesEntriesCorba[ind].in());
  }

  string listEntriesTxt = FormatVerticesEntries(theSourceVerticesEntries, theTargetVerticesEntries);


  this->GetImpl()->AddPreCadFacesPeriodicity(theFace1Entry, theFace2Entry,
                                             theSourceVerticesEntries, theTargetVerticesEntries);

  SMESH::TPythonDump pd;
  if (!theSourceVerticesEntries.empty())
  {
    pd << _this() << ".AddPreCadFacesPeriodicityWithVertices(" << theFace1Entry << ", " << theFace2Entry;
    pd << listEntriesTxt.c_str();
    pd << ")";
  }
  else
    pd << _this() << ".AddPreCadFacesPeriodicity(" << theFace1Entry << ", " << theFace2Entry << ")";
}

void BLSURFPlugin_Hypothesis_i::AddPreCadEdgesPeriodicity(GEOM::GEOM_Object_ptr theEdge1, GEOM::GEOM_Object_ptr theEdge2)
{
  ASSERT(myBaseImpl);
  const GEOM::ListOfGO theSourceVertices;
  const GEOM::ListOfGO theTargetVertices;
  AddPreCadEdgesPeriodicityWithVertices(theEdge1, theEdge2, theSourceVertices, theTargetVertices);
}

void BLSURFPlugin_Hypothesis_i::AddPreCadEdgesPeriodicityWithVertices(GEOM::GEOM_Object_ptr theEdge1, GEOM::GEOM_Object_ptr theEdge2,
                                                                      const GEOM::ListOfGO& theSourceVertices, const GEOM::ListOfGO& theTargetVertices)
{
  ASSERT(myBaseImpl);

  size_t theLength = theSourceVertices.length();
  if (theLength != theTargetVertices.length())
    THROW_SALOME_CORBA_EXCEPTION( "The sizes of theSourceVertices and theTargetVertices must be the same" ,SALOME_CMOD::BAD_PARAM );

  std::vector<GEOM::shape_type> allowedShapeTypes;
  allowedShapeTypes.push_back(GEOM::EDGE);
  allowedShapeTypes.push_back(GEOM::COMPOUND);

  string prefix1 = "Source_edge_";
  CheckShapeTypes(theEdge1, allowedShapeTypes);
  string theEdge1Entry = PublishIfNeeded(theEdge1, GEOM::EDGE, prefix1);

  string prefix2 = "Target_edge_";
  CheckShapeTypes(theEdge2, allowedShapeTypes);
  string theEdge2Entry = PublishIfNeeded(theEdge2, GEOM::EDGE, prefix2);

  string prefix3 = "Source_vertex_";
  BLSURFPlugin::TEntryList_var theSourceVerticesEntries = new BLSURFPlugin::TEntryList();
  theSourceVerticesEntries->length((CORBA::ULong) theLength);
  GEOM::GEOM_Object_ptr theVtx_i;
  string theEntry_i;
  for (CORBA::ULong ind = 0; ind < theLength; ind++) {
    theVtx_i = theSourceVertices[ind];
    theEntry_i = PublishIfNeeded(theVtx_i, GEOM::VERTEX, prefix3);
    theSourceVerticesEntries[ind] = CORBA::string_dup(theEntry_i.c_str());
  }

  string prefix4 = "Target_vertex_";
  BLSURFPlugin::TEntryList_var theTargetVerticesEntries = new BLSURFPlugin::TEntryList();
  theTargetVerticesEntries->length((CORBA::ULong) theLength);
  for (CORBA::ULong ind = 0; ind < theLength; ind++) {
    theVtx_i = theTargetVertices[ind];
    theEntry_i = PublishIfNeeded(theVtx_i, GEOM::VERTEX, prefix4);
    theTargetVerticesEntries[ind] = CORBA::string_dup(theEntry_i.c_str());
  }

  string theEdge2Name = theEdge2->GetName();
  try {
    AddPreCadEdgesPeriodicityEntry(theEdge1Entry.c_str(), theEdge2Entry.c_str(),
                                   theSourceVerticesEntries, theTargetVerticesEntries);
  } catch (SALOME_Exception& ex) {
    THROW_SALOME_CORBA_EXCEPTION( ex.what() ,SALOME_CMOD::BAD_PARAM );
  }
}


void BLSURFPlugin_Hypothesis_i::AddPreCadEdgesPeriodicityEntry(const char* theEdge1Entry, const char* theEdge2Entry,
                                                               const BLSURFPlugin::TEntryList& theSourceVerticesEntriesCorba, const BLSURFPlugin::TEntryList& theTargetVerticesEntriesCorba)
{

  ASSERT(myBaseImpl);

  // Convert BLSURFPlugin::TEntryList to vector<string>
  vector<string> theSourceVerticesEntries, theTargetVerticesEntries;
  for (CORBA::ULong  ind = 0; ind < theSourceVerticesEntriesCorba.length(); ind++) {
    theSourceVerticesEntries.push_back(theSourceVerticesEntriesCorba[ind].in());
    theTargetVerticesEntries.push_back(theTargetVerticesEntriesCorba[ind].in());
  }

  string listEntriesTxt = FormatVerticesEntries(theSourceVerticesEntries, theTargetVerticesEntries);

  this->GetImpl()->AddPreCadEdgesPeriodicity(theEdge1Entry, theEdge2Entry,
                                             theSourceVerticesEntries, theTargetVerticesEntries);

  SMESH::TPythonDump pd;
  if (!theSourceVerticesEntries.empty())
  {
    pd << _this() << ".AddPreCadEdgesPeriodicityWithVertices(" << theEdge1Entry << ", " << theEdge2Entry;
    pd << listEntriesTxt.c_str();
    pd << ")";
  }
  else
    pd << _this() << ".AddPreCadEdgesPeriodicity(" << theEdge1Entry << ", " << theEdge2Entry << ")";

}


//================================================================================
/*!
 * \brief Sets the file for export resulting mesh in GMF format
 * \param theFileName - full name of the file (.mesh, .meshb)
 * 
 * After compute, export the resulting mesh in the given file with the GMF format (.mesh)
 */
//================================================================================  
// void BLSURFPlugin_Hypothesis_i::SetGMFFile(const char* theFileName, CORBA::Boolean isBinary) {
void BLSURFPlugin_Hypothesis_i::SetGMFFile(const char* theFileName) {
  ASSERT(myBaseImpl);
  bool valueChanged/*, modeChanged*/ = false;
  try {
    valueChanged = (this->GetImpl()->GetGMFFile() != theFileName);
    //     modeChanged = (this->GetImpl()->GetGMFFileMode() != isBinary);
    if (valueChanged)// or (!valueChanged && modeChanged))
      this->GetImpl()->SetGMFFile(theFileName);// ,isBinary);
  } catch (const std::exception& ex) {
    THROW_SALOME_CORBA_EXCEPTION( ex.what() ,SALOME_CMOD::BAD_PARAM );
  }
  if (valueChanged)// or (!valueChanged && modeChanged))
    SMESH::TPythonDump() << _this() << ".SetGMFFile(\"" << theFileName << "\")"; //", " << isBinary << ")";
}

//================================================================================
/*!
 * \brief Gets the file name for export resulting mesh in GMF format
 * \retval char* - The file name
 * 
 * Returns the GMF file name
 */
//================================================================================  
char* BLSURFPlugin_Hypothesis_i::GetGMFFile() {
  ASSERT(myBaseImpl);
  return CORBA::string_dup(this->GetImpl()->GetGMFFile().c_str());
}

// //================================================================================
// /*!
//  * \brief Gets the file mode for export resulting mesh in GMF format
//  * \retval CORBA::Boolean - TRUE if binary mode, FALSE if ascii mode
//  * 
//  * Returns the GMF file mode
//  */
// //================================================================================  
// CORBA::Boolean BLSURFPlugin_Hypothesis_i::GetGMFFileMode() {
//   ASSERT(myBaseImpl);
//   return this->GetImpl()->GetGMFFileMode();
// }

//=============================================================================
/*!
 *  BLSURFPlugin_Hypothesis_i::GetImpl
 *
 *  Get implementation
 */
//=============================================================================
::BLSURFPlugin_Hypothesis* BLSURFPlugin_Hypothesis_i::GetImpl() {
  return (::BLSURFPlugin_Hypothesis*) myBaseImpl;
}

//================================================================================
/*!
 * \brief Verify whether hypothesis supports given entity type
 * \param type - dimension (see SMESH::Dimension enumeration)
 * \retval CORBA::Boolean - TRUE if dimension is supported, FALSE otherwise
 *
 * Verify whether hypothesis supports given entity type (see SMESH::Dimension enumeration)
 */
//================================================================================
CORBA::Boolean BLSURFPlugin_Hypothesis_i::IsDimSupported(SMESH::Dimension type) {
  return type == SMESH::DIM_2D;
}


//================================================================================
/*!
 * \brief Return geometry this hypothesis depends on. Return false if there is no geometry parameter
 */
//================================================================================

bool
BLSURFPlugin_Hypothesis_i::getObjectsDependOn( std::vector< std::string > & entryArray,
                                               std::vector< int >         & subIDArray ) const
{
  typedef ::BLSURFPlugin_Hypothesis BH;
  const BH* impl = static_cast<const BH*>( myBaseImpl );

  {
    const BH::TSizeMap& sizeMap = impl->_GetSizeMapEntries();
    BH::TSizeMap::const_iterator entry2size = sizeMap.cbegin();
    for ( ; entry2size != sizeMap.cend(); ++entry2size )
      entryArray.push_back( entry2size->first );
  }
  {
    const BH::TSizeMap& sizeMap = impl->_GetAttractorEntries();
    BH::TSizeMap::const_iterator entry2size = sizeMap.cbegin();
    for ( ; entry2size != sizeMap.cend(); ++entry2size )
      entryArray.push_back( entry2size->first );
  }
  {
    const BH::TAttractorMap& classAttractors = impl-> _GetClassAttractorEntries();
    BH::TAttractorMap::const_iterator entry2size = classAttractors.cbegin();
    for ( ; entry2size != classAttractors.cend(); ++entry2size )
      entryArray.push_back( entry2size->first );
  }
  {
    const BH::TFaceEntryEnfVertexListMap& faceEntryEnfVertexListMap = impl->_GetAllEnforcedVerticesByFace();
    BH::TFaceEntryEnfVertexListMap::const_iterator entry2evList = faceEntryEnfVertexListMap.cbegin();
    for ( ; entry2evList != faceEntryEnfVertexListMap.cend(); ++entry2evList )
    {
      entryArray.push_back( entry2evList->first );

      const BH::TEnfVertexList& evList = entry2evList->second;
      BH::TEnfVertexList::const_iterator evIt = evList.cbegin();
      for ( ; evIt != evList.cend(); ++evIt )
      {
        const BH::TEnfVertex* ev = *evIt;
        entryArray.push_back( ev->geomEntry );
        entryArray.insert( entryArray.end(), ev->faceEntries.cbegin(), ev->faceEntries.cend() );
      }
    }
  }
  // { // duplicated data of faceEntryEnfVertexListMap
  //   const BH::TEnfVertexList& enfVertexList = impl->_GetAllEnforcedVertices();
  //   const BH::TFaceEntryCoordsListMap& faceEntryCoordsListMap = impl->_GetAllCoordsByFace();
  //   const BH::TFaceEntryEnfVertexEntryListMap& faceEntryEnfVertexEntryListMap = impl->_GetAllEnfV  //   const BH::TEnfVertexEntryEnfVertexMap& enfVertexEntryEnfVertexMap = impl->_GetAllEnforcedVert  // }
  {
    const BH::TPreCadPeriodicityVector& preCadFacesPeriodicityVector = impl->_GetPreCadFacesPeriodicityVector();
    BH::TPreCadPeriodicityVector::const_iterator pcp = preCadFacesPeriodicityVector.cbegin();
    for ( ; pcp != preCadFacesPeriodicityVector.cend(); ++pcp )
    {
      entryArray.push_back( pcp->shape1Entry );
      entryArray.push_back( pcp->shape2Entry );
      entryArray.insert( entryArray.end(),
                         pcp->theSourceVerticesEntries.cbegin(),
                         pcp->theSourceVerticesEntries.cend() );
      entryArray.insert( entryArray.end(),
                         pcp->theTargetVerticesEntries.cbegin(),
                         pcp->theTargetVerticesEntries.cend() );
    }
  }
  {
    const BH::TPreCadPeriodicityVector& preCadEdgesPeriodicityVector = impl->_GetPreCadEdgesPeriodicityVector();
    BH::TPreCadPeriodicityVector::const_iterator pcp = preCadEdgesPeriodicityVector.cbegin();
    for ( ; pcp != preCadEdgesPeriodicityVector.cend(); ++pcp )
    {
      entryArray.push_back( pcp->shape1Entry );
      entryArray.push_back( pcp->shape2Entry );
      entryArray.insert( entryArray.end(),
                         pcp->theSourceVerticesEntries.cbegin(),
                         pcp->theSourceVerticesEntries.cend() );
      entryArray.insert( entryArray.end(),
                         pcp->theTargetVerticesEntries.cbegin(),
                         pcp->theTargetVerticesEntries.cend() );
    }
  }
  {
    const BH::THyperPatchList& hyperPatchList = impl->GetHyperPatches();
    BH::THyperPatchList::const_iterator idSet = hyperPatchList.cbegin();
    for ( ; idSet != hyperPatchList.cend(); ++idSet )
    {
      subIDArray.insert( subIDArray.end(), idSet->cbegin(), idSet->cend() );
    }
  }
  return true;
}

//================================================================================
/*!
 * \brief Set new geometry instead of that returned by getObjectsDependOn()
 */
//================================================================================

bool
BLSURFPlugin_Hypothesis_i::setObjectsDependOn( std::vector< std::string > & entryArray,
                                               std::vector< int >         & subIDArray )
{
  typedef ::BLSURFPlugin_Hypothesis BH;
  BH* impl = static_cast<BH*>( myBaseImpl );

  size_t iEnt = 0;
  {
    BH::TSizeMap& sizeMapNew = const_cast< BH::TSizeMap& >( impl->_GetSizeMapEntries() );
    BH::TSizeMap sizeMap;
    sizeMap.swap( sizeMapNew );
    BH::TSizeMap::const_iterator entry2size = sizeMap.cbegin();
    for ( ; entry2size != sizeMap.cend(); ++entry2size, ++iEnt )
      if ( entryArray[ iEnt ].empty() == entry2size->first.empty() )
        sizeMapNew[ entryArray[ iEnt ]] =  entry2size->second;
  }
  {
    BH::TSizeMap& sizeMapNew = const_cast< BH::TSizeMap& >( impl->_GetAttractorEntries() );
    BH::TSizeMap sizeMap;
    sizeMap.swap( sizeMapNew );
    BH::TSizeMap::const_iterator entry2size = sizeMap.cbegin();
    for ( ; entry2size != sizeMap.cend(); ++entry2size, ++iEnt )
      if ( entryArray[ iEnt ].empty() == entry2size->first.empty() )
        sizeMapNew[ entryArray[ iEnt ]] =  entry2size->second;
  }
  {
    BH::TAttractorMap& attrMapNew =
      const_cast< BH::TAttractorMap& > ( impl->_GetClassAttractorEntries() );
    BH::TAttractorMap attrMap;
    attrMap.swap( attrMapNew );
    BH::TAttractorMap::const_iterator entry2size = attrMap.cbegin();
    for ( ; entry2size != attrMap.cend(); ++entry2size, ++iEnt )
      if ( entryArray[ iEnt ].empty() == entry2size->first.empty() )
        attrMapNew.insert( std::make_pair( entryArray[ iEnt ], entry2size->second ));
      else
        delete entry2size->second;
  }
  {
    BH::TFaceEntryEnfVertexListMap& faceEntryEnfVertexListMapNew =
      const_cast< BH::TFaceEntryEnfVertexListMap& >( impl->_GetAllEnforcedVerticesByFace() );
    BH::TFaceEntryEnfVertexListMap faceEntryEnfVertexListMap;
    faceEntryEnfVertexListMap.swap( faceEntryEnfVertexListMapNew );

    BH::TEnfVertexList& enfVertexList =
      const_cast< BH::TEnfVertexList& > ( impl->_GetAllEnforcedVertices() );
    enfVertexList.clear(); // avoid removal

    impl->ClearAllEnforcedVertices();

    BH::TFaceEntryEnfVertexListMap::iterator entry2evList = faceEntryEnfVertexListMap.begin();
    for ( ; entry2evList != faceEntryEnfVertexListMap.end(); ++entry2evList )
    {
      const BH::TEntry& entry = entryArray[ iEnt++ ];
      bool faceOk = ( entry.empty() == entry2evList->first.empty() );

      BH::TEnfVertexList& evList = entry2evList->second;
      BH::TEnfVertexList::iterator evIt = evList.begin();
      for ( ; evIt != evList.end(); ++evIt )
      {
        BH::TEnfVertex* ev = *evIt;
        bool ok = faceOk && ( ev->geomEntry.empty() != entryArray[ iEnt ].empty() );
        ev->geomEntry = entryArray[ iEnt++ ];
        BH::TEntryList faceEntriesNew;
        BH::TEntryList::iterator fEnt = ev->faceEntries.begin();
        for ( ; fEnt != ev->faceEntries.end(); ++fEnt, ++iEnt )
        {
          if ( !entryArray[ iEnt ].empty() )
            faceEntriesNew.insert( entryArray[ iEnt ]);
        }
        if ( ok )
        {
          ev->faceEntries.swap( faceEntriesNew );
          impl->AddEnforcedVertex( entry, ev );
        }
        else
        {
          delete ev;
        }
      }
    }
  }
  {
    BH::TPreCadPeriodicityVector& preCadPeriodicityVector =
      const_cast< BH::TPreCadPeriodicityVector&> ( impl->_GetPreCadFacesPeriodicityVector() );
    BH::TPreCadPeriodicityVector::iterator pcp = preCadPeriodicityVector.begin();
    for ( ; pcp != preCadPeriodicityVector.end(); ++pcp )
    {
      pcp->shape1Entry = entryArray[ iEnt++ ];
      pcp->shape2Entry = entryArray[ iEnt++ ];
      for ( size_t i = 0; i < pcp->theSourceVerticesEntries.size(); ++i, iEnt++ )
        pcp->theSourceVerticesEntries[i] = entryArray[ iEnt ];

      for ( size_t i = 0; i < pcp->theTargetVerticesEntries.size(); ++i, iEnt++ )
        pcp->theTargetVerticesEntries[i] = entryArray[ iEnt ];
    }
  }
  {
    BH::TPreCadPeriodicityVector& preCadPeriodicityVector =
      const_cast< BH::TPreCadPeriodicityVector&> ( impl->_GetPreCadEdgesPeriodicityVector() );
    BH::TPreCadPeriodicityVector::iterator pcp = preCadPeriodicityVector.begin();
    for ( ; pcp != preCadPeriodicityVector.end(); ++pcp )
    {
      pcp->shape1Entry = entryArray[ iEnt++ ];
      pcp->shape2Entry = entryArray[ iEnt++ ];
      for ( size_t i = 0; i < pcp->theSourceVerticesEntries.size(); ++i, iEnt++ )
        pcp->theSourceVerticesEntries[i] = entryArray[ iEnt ];

      for ( size_t i = 0; i < pcp->theTargetVerticesEntries.size(); ++i, iEnt++ )
        pcp->theTargetVerticesEntries[i] = entryArray[ iEnt ];
    }
  }

  size_t iID = 0;
  {
    BH::THyperPatchList& hyperPatchListNew =
      const_cast< BH::THyperPatchList& >( impl->GetHyperPatches() );
    BH::THyperPatchList hyperPatchList;
    hyperPatchList.swap( hyperPatchListNew );
    BH::THyperPatchList::iterator idSet = hyperPatchList.begin();
    for ( ; idSet != hyperPatchList.end(); ++idSet )
    {
      BH::THyperPatchTags& ids = *idSet;
      BH::THyperPatchTags idsNew;
      BH::THyperPatchTags::iterator i = ids.begin();
      for ( ; i != ids.end(); ++i, ++iID )
        if ( subIDArray[ iID ] > 0 )
          idsNew.insert( subIDArray[ iID ]);
      if ( !idsNew.empty() )
        hyperPatchListNew.push_back( idsNew );
    }
  }

  return ( iEnt == entryArray.size() && iID == subIDArray.size() );
}
