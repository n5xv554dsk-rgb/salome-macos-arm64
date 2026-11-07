// Copyright (C) 2007-2026  CEA, EDF, OPEN CASCADE
//
// Copyright (C) 2003-2007  OPEN CASCADE, EADS/CCR, LIP6, CEA/DEN,
// CEDRAT, EDF R&D, LEG, PRINCIPIA R&D, BUREAU VERITAS
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

#include "CALCULATOR.hxx"
#include "CALCULATOR_version.h"

#include <MCAuto.hxx>
#include <MEDCouplingFieldDoubleClient.hxx>
#include <MEDCouplingFieldDoubleServant.hxx>
#include <MEDCouplingMemArray.hxx>
#include <MEDCouplingMeshClient.hxx>
#include <MEDCouplingMeshServant.hxx>

#include <iostream>

/*!
  \brief Constructor
  \param orb Reference to CORBA ORB 
  \param poa Reference to Root POA
  \param contId Parent SALOME container ID
  \param instanceName Instance name of this engine
  \param interfaceName Interface name of this engine
*/
CALCULATOR_Abstract::CALCULATOR_Abstract( CORBA::ORB_ptr orb,
					  PortableServer::POA_ptr poa,
					  PortableServer::ObjectId* contId, 
					  const char* instanceName, 
					  const char* interfaceName,
					  bool withRegistry )
  : Engines_Component_i( orb, poa, contId, instanceName, interfaceName, true, withRegistry ),
    _errorCode( CALCULATOR_ORB::RES_OK )
{
  _thisObj = this;
  _id = _poa->activate_object( _thisObj );
}

/*!
  \brief Destructor
*/
CALCULATOR_Abstract::~CALCULATOR_Abstract()
{
}

/*!
  \brief Get Euclidian norm of field
  \param field Input field
  \return Euclidian norm value
*/
CORBA::Double CALCULATOR_Abstract::norm2( SALOME_MED::MEDCouplingFieldDoubleCorbaInterface_ptr field )
{
  beginService( "CALCULATOR_Abstract::norm2" );
  _errorCode = CALCULATOR_ORB::RES_OK;
        
  if ( CORBA::is_nil( field ) )
  {
    _errorCode = CALCULATOR_ORB::INVALID_FIELD;
    return 0.0;
  }

  MEDCoupling::MCAuto<MEDCoupling::MEDCouplingFieldDouble> f1 =
    MEDCoupling::MEDCouplingFieldDoubleClient::New( field );

  CORBA::Double norme = 0.0;

  try
  {
    norme = f1->norm2();
  }    
  catch (...)
  {
    _errorCode = CALCULATOR_ORB::EXCEPTION_RAISED;
  }
  
  endService( "CALCULATOR_Abstract::norm2" );
  return norme;
}

/*!
  \brief Get L2 norm of field
  \param field Input field
  \return L2 norm value
*/
CORBA::Double CALCULATOR_Abstract::normL2( SALOME_MED::MEDCouplingFieldDoubleCorbaInterface_ptr field )
{
  beginService( "CALCULATOR_Abstract::normL2" );
  _errorCode = CALCULATOR_ORB::RES_OK;

  if ( CORBA::is_nil( field ) )
  {
    _errorCode = CALCULATOR_ORB::INVALID_FIELD;
    return 0.0;
  }

  MEDCoupling::MCAuto<MEDCoupling::MEDCouplingFieldDouble> f1 =
    MEDCoupling::MEDCouplingFieldDoubleClient::New( field );
  
  // Check that the source field is not on the nodes (a limitation of normL2)
  if ( f1->getTypeOfField() == MEDCoupling::ON_NODES)
  {
    _errorCode = CALCULATOR_ORB::NOT_COMPATIBLE;
    return 0.0;
  }
        
  CORBA::Double norme = 0.0;

  try
  {
    norme = f1->normL2( 0 );
  }    
  catch (...)
  {
    _errorCode = CALCULATOR_ORB::EXCEPTION_RAISED;
  }
  
  endService( "CALCULATOR_Abstract::normL2" );
  return norme;
}

/*!
  \brief Get max norm of field
  \param field Input field
  \return Max norm value
*/
CORBA::Double CALCULATOR_Abstract::normMax( SALOME_MED::MEDCouplingFieldDoubleCorbaInterface_ptr field )
{
  beginService( "CALCULATOR_Abstract::normMax" );
  _errorCode = CALCULATOR_ORB::RES_OK;
         
  if ( CORBA::is_nil( field ) )
  {
    _errorCode = CALCULATOR_ORB::INVALID_FIELD;
    return 0.0;
  }
  
  MEDCoupling::MCAuto<MEDCoupling::MEDCouplingFieldDouble> f1 =
    MEDCoupling::MEDCouplingFieldDoubleClient::New( field );

  CORBA::Double norme = 0.0;

  try
  {
    norme = f1->normMax( 0 );
  }
  catch (...)
  {
    _errorCode = CALCULATOR_ORB::EXCEPTION_RAISED;
  }
 
  endService( "CALCULATOR_Abstract::normMax" );
  return norme;
}

/*!
  \brief Get L1 norm of field
  \param field Input field
  \return L1 norm value
*/
CORBA::Double CALCULATOR_Abstract::normL1( SALOME_MED::MEDCouplingFieldDoubleCorbaInterface_ptr field )
{
  beginService( "CALCULATOR_Abstract::normL1" );
  _errorCode = CALCULATOR_ORB::RES_OK;

  if ( CORBA::is_nil( field ) )
  {
    _errorCode = CALCULATOR_ORB::INVALID_FIELD;
    return 0.0;
  }

  MEDCoupling::MCAuto<MEDCoupling::MEDCouplingFieldDouble> f1 =
    MEDCoupling::MEDCouplingFieldDoubleClient::New( field );

  // Check that the source field is not on the nodes (a limitation of normL1)
  if ( f1->getTypeOfField() == MEDCoupling::ON_NODES ) {
    _errorCode = CALCULATOR_ORB::NOT_COMPATIBLE;
    return 0.0;
  }       
  
  CORBA::Double norme = 0.0;
  try
  {
    norme = f1->normL1( 0 );
  }
  catch (...)
  {
    _errorCode = CALCULATOR_ORB::EXCEPTION_RAISED;
  }

  endService( "CALCULATOR_Abstract::normL1" );
  return norme;
}

/*!
  \brief Apply to each (scalar) field component the linear function x -> ax+b
  \param field Input field
  \param a First coefficient of linear function
  \param b Second coefficient of linear function
  \return Resulting field
*/
SALOME_MED::MEDCouplingFieldDoubleCorbaInterface_ptr
CALCULATOR_Abstract::applyLin( SALOME_MED::MEDCouplingFieldDoubleCorbaInterface_ptr field,
			       CORBA::Double a, CORBA::Double b )
{
  beginService( "CALCULATOR_Abstract::applyLin" );
  _errorCode = CALCULATOR_ORB::RES_OK;
    
  if ( CORBA::is_nil( field ) )
  {
    _errorCode = CALCULATOR_ORB::INVALID_FIELD;
    return NULL;
  }

  // Create a local field on the heap, because it has to remain after exiting the function
  MEDCoupling::MCAuto<MEDCoupling::MEDCouplingFieldDouble> f1 =
    MEDCoupling::MEDCouplingFieldDoubleClient::New( field );

  int nbOfCompo = f1->getArray()->getNumberOfComponents();
  f1->getArray()->rearrange(1);
  MEDCoupling::MEDCouplingFieldDoubleServant* NewField = NULL;
  SALOME_MED::MEDCouplingFieldDoubleCorbaInterface_ptr myFieldIOR;

  try
  {
    f1->applyLin( a, b, 0 );
    f1->getArray()->rearrange( nbOfCompo );
    // Create servant from f1, give it the property of c++ field (parameter true).
    // This implies that when the client will release it's field, it will delete NewField,
    // and f1 too.
    NewField = new MEDCoupling::MEDCouplingFieldDoubleServant( f1 );
    // Activate servant
    myFieldIOR = NewField->_this();
  }
  catch (...)
  {
    _errorCode = CALCULATOR_ORB::EXCEPTION_RAISED;
  }
  
  endService( "CALCULATOR_Abstract::applyLin" );
  return myFieldIOR;
}

/*!
  \brief Sum two fields
  \param field1 First input field
  \param field2 Second input field
  \return Resulting field
*/
SALOME_MED::MEDCouplingFieldDoubleCorbaInterface_ptr
CALCULATOR_Abstract::add( SALOME_MED::MEDCouplingFieldDoubleCorbaInterface_ptr field1,
			  SALOME_MED::MEDCouplingFieldDoubleCorbaInterface_ptr field2 )
{
  beginService( "CALCULATOR_Abstract::add" );
  _errorCode = CALCULATOR_ORB::RES_OK;

  if ( CORBA::is_nil( field1 ) || CORBA::is_nil( field2 ) )
  {
    _errorCode = CALCULATOR_ORB::INVALID_FIELD;
    return NULL;
  }
  
  // Create local fields from source corba fields
  MEDCoupling::MCAuto<MEDCoupling::MEDCouplingFieldDouble> f1 =
    MEDCoupling::MEDCouplingFieldDoubleClient::New( field1 );
  MEDCoupling::MCAuto<MEDCoupling::MEDCouplingFieldDouble> f2 =
    MEDCoupling::MEDCouplingFieldDoubleClient::New( field2 );
    
  MEDCoupling::MCAuto<MEDCoupling::MEDCouplingFieldDouble> fres;
  
  try
  {
    f2->changeUnderlyingMesh( f1->getMesh(), 0, 1e-12 );
    fres = (*f1) + (*f2);
  }
  catch ( INTERP_KERNEL::Exception )
  {
    _errorCode = CALCULATOR_ORB::NOT_COMPATIBLE;
    return NULL;
  }

  // Create CORBA field from c++ field fres; give property to servant (true).
  MEDCoupling::MEDCouplingFieldDoubleServant* myFieldDoubleI = new MEDCoupling::MEDCouplingFieldDoubleServant( fres );
  // Activate servant
  SALOME_MED::MEDCouplingFieldDoubleCorbaInterface_ptr myFieldIOR = myFieldDoubleI->_this();

  endService( "CALCULATOR_Abstract::add" );
  return myFieldIOR;
}

/*!
  \brief Clone source field into four copies
  \param field Input field
  \param clone1 First resulting clone field
  \param clone2 Second resulting clone field
  \param clone3 Third resulting clone field
  \param clone4 Fourth resulting clone field
*/
void CALCULATOR_Abstract::cloneField( SALOME_MED::MEDCouplingFieldDoubleCorbaInterface_ptr field,
				      SALOME_MED::MEDCouplingFieldDoubleCorbaInterface_out clone1,
				      SALOME_MED::MEDCouplingFieldDoubleCorbaInterface_out clone2,
				      SALOME_MED::MEDCouplingFieldDoubleCorbaInterface_out clone3,
				      SALOME_MED::MEDCouplingFieldDoubleCorbaInterface_out clone4 )
{
  beginService( "CALCULATOR_Abstract::cloneField" );
  _errorCode = CALCULATOR_ORB::RES_OK;

  if ( CORBA::is_nil( field ) )
  {
    _errorCode = CALCULATOR_ORB::INVALID_FIELD;
    return;
  }
  
  MEDCoupling::MCAuto<MEDCoupling::MEDCouplingFieldDouble> f =
    MEDCoupling::MEDCouplingFieldDoubleClient::New( field );

  // Create four c++ fields on the heap by copying source field.
  MEDCoupling::MCAuto<MEDCoupling::MEDCouplingFieldDouble> fc1 =
    MEDCoupling::MEDCouplingFieldDoubleClient::New( field );
  MEDCoupling::MCAuto<MEDCoupling::MEDCouplingFieldDouble> fc2 =
    MEDCoupling::MEDCouplingFieldDoubleClient::New( field );
  MEDCoupling::MCAuto<MEDCoupling::MEDCouplingFieldDouble> fc3 =
    MEDCoupling::MEDCouplingFieldDoubleClient::New( field );
  MEDCoupling::MCAuto<MEDCoupling::MEDCouplingFieldDouble> fc4 =
    MEDCoupling::MEDCouplingFieldDoubleClient::New( field );
    
  // Initialize out references: 
  // Create CORBA clones from c++ fields - give property of c++ fields to servant (true)
  MEDCoupling::MEDCouplingFieldDoubleServant* myClone1 = new MEDCoupling::MEDCouplingFieldDoubleServant( fc1 );
  MEDCoupling::MEDCouplingFieldDoubleServant* myClone2 = new MEDCoupling::MEDCouplingFieldDoubleServant( fc2 );
  MEDCoupling::MEDCouplingFieldDoubleServant* myClone3 = new MEDCoupling::MEDCouplingFieldDoubleServant( fc3 );
  MEDCoupling::MEDCouplingFieldDoubleServant* myClone4 = new MEDCoupling::MEDCouplingFieldDoubleServant( fc4 );
  // Activate servants
  clone1 = myClone1->_this();
  clone2 = myClone2->_this();
  clone3 = myClone3->_this();
  clone4 = myClone4->_this();

  endService( "CALCULATOR_Abstract::cloneField" );
}

/*!
  \brief Print out the coordinates and field values to standard output
  \param field Input field
*/
void CALCULATOR_Abstract::printField( SALOME_MED::MEDCouplingFieldDoubleCorbaInterface_ptr field )
{
  beginService( "CALCULATOR_Abstract::printField" );
  _errorCode = CALCULATOR_ORB::RES_OK;

  if ( CORBA::is_nil( field ) )
  {
    _errorCode = CALCULATOR_ORB::INVALID_FIELD;
    return;
  }

  // Create a local field from source corba field.
  // Use auto_ptr to perform automatic deletion after usage.
  // The deletion of the client object will delete the remote corba object.
  MEDCoupling::MCAuto<MEDCoupling::MEDCouplingFieldDouble> myField =
    MEDCoupling::MEDCouplingFieldDoubleClient::New( field );

  std::cout << myField->advancedRepr(); 
  std::cout << std::endl;
  std::cout << "Euclidian norm: " << myField->norm2() << std::endl;
  std::cout << "Max norm:       " << myField->normMax( 0 ) << std::endl;
  std::cout << "------------------------------------------------------------------------" << std::endl << std::endl;

  endService( "CALCULATOR_Abstract::printField" );
}

/*!
  \brief Calculate maximum relative difference of field with the previous one
  \param field Input field
  \return Convergence criterion value
*/
CORBA::Double CALCULATOR_Abstract::convergenceCriteria( SALOME_MED::MEDCouplingFieldDoubleCorbaInterface_ptr field )
{
  beginService( "CALCULATOR_Abstract::convergenceCriteria" );
  _errorCode = CALCULATOR_ORB::RES_OK;

  if ( CORBA::is_nil( field ) )
  {
    _errorCode = CALCULATOR_ORB::INVALID_FIELD;
    return 0.0;
  }
  
  double criteria = 1;
  static MEDCoupling::MCAuto<MEDCoupling::MEDCouplingFieldDouble> fold;
  MEDCoupling::MCAuto<MEDCoupling::MEDCouplingFieldDouble> fnew =
    MEDCoupling::MEDCouplingFieldDoubleClient::New( field );

  try
  {
    if ( (MEDCoupling::MEDCouplingFieldDouble*)fold == NULL )
    {
      // if old field is not set, set it and return 1
      fold = fnew;
    }
    else
    {
      // if size of fields are not equal, return 1
      // catch exception for non compatible fields
      MEDCoupling::MCAuto<MEDCoupling::MEDCouplingFieldDouble> fres;
      try
      {
        fnew->changeUnderlyingMesh( fold->getMesh(), 0, 1e-12 );
        fres = (*fnew) - (*fold);
        criteria = fres->normMax( 0 );
      }
      catch ( INTERP_KERNEL::Exception )
      {
        _errorCode = CALCULATOR_ORB::NOT_COMPATIBLE;
      }
    }
  }
  catch (...)
  {
    _errorCode = CALCULATOR_ORB::EXCEPTION_RAISED;
  }
  
  endService( "CALCULATOR_Abstract::convergenceCriteria" );
  return criteria;
}

/*!
  \brief Get last operation status
  \return Last operation status: \c true if last operation succeded or \c false otherwise
*/
CORBA::Boolean CALCULATOR_Abstract::isDone()
{
  return (_errorCode == CALCULATOR_ORB::RES_OK );
}

/*!
  \brief Get last operation status
  \return Last error code
*/
CALCULATOR_ORB::ErrorCode CALCULATOR_Abstract::getErrorCode()
{
  return _errorCode;
}

/*!
  \brief Get version information
  \return Version of CALCULATOR engine
*/
char* CALCULATOR_Abstract::getVersion()
{
#if defined(CALCULATOR_DEVELOPMENT)
  return CORBA::string_dup( CALCULATOR_VERSION_STR"dev" );
#else
  return CORBA::string_dup( CALCULATOR_VERSION_STR );
#endif
}

extern "C"
{
  CALCULATORENGINE_EXPORT
  PortableServer::ObjectId* CALCULATOREngine_factory( CORBA::ORB_ptr orb,
                                                      PortableServer::POA_ptr poa,
                                                      PortableServer::ObjectId* contId,
                                                      const char* instanceName,
                                                      const char* interfaceName )
  {
    CORBA::Object_var o = poa->id_to_reference(*contId);
    Engines::Container_var cont = Engines::Container::_narrow(o);
    if (cont->is_SSL_mode())
    {
      CALCULATOR_No_Session* calc = new CALCULATOR_No_Session(orb, poa, contId, instanceName, interfaceName);
      return calc->getId();
    }
    else
    {
      CALCULATOR_Session* calc = new CALCULATOR_Session( orb, poa, contId, instanceName, interfaceName );
      return calc->getId();
    }
  }
}
