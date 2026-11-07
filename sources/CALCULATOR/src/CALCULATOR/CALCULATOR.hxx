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

#ifndef CALCULATOR_HXX
#define CALCULATOR_HXX

#ifdef WIN32
#  if defined CALCULATOREngine_EXPORTS
#    define CALCULATORENGINE_EXPORT __declspec( dllexport )
#  else
#    define CALCULATORENGINE_EXPORT __declspec( dllimport )
#  endif
#else
#  define CALCULATORENGINE_EXPORT
#endif

#include <SALOMEconfig.h>
#include CORBA_SERVER_HEADER(CALCULATOR_Gen)
#include CORBA_CLIENT_HEADER(MEDCouplingCorbaServant)
#include <SALOME_Component_i.hxx>

class CALCULATORENGINE_EXPORT CALCULATOR_Abstract:
  public POA_CALCULATOR_ORB::CALCULATOR_Gen,
  public Engines_Component_i 
{
public:
  CALCULATOR_Abstract( CORBA::ORB_ptr,
		       PortableServer::POA_ptr,
		       PortableServer::ObjectId*, 
		       const char*, 
		       const char*,
		       bool withRegistry = true );
    virtual ~CALCULATOR_Abstract();
    virtual char* getVersion();

    CORBA::Double convergenceCriteria( SALOME_MED::MEDCouplingFieldDoubleCorbaInterface_ptr );
    CORBA::Double normMax( SALOME_MED::MEDCouplingFieldDoubleCorbaInterface_ptr );
    CORBA::Double normL2( SALOME_MED::MEDCouplingFieldDoubleCorbaInterface_ptr );
    CORBA::Double norm2( SALOME_MED::MEDCouplingFieldDoubleCorbaInterface_ptr );
    CORBA::Double normL1( SALOME_MED::MEDCouplingFieldDoubleCorbaInterface_ptr );
    SALOME_MED::MEDCouplingFieldDoubleCorbaInterface_ptr applyLin( SALOME_MED::MEDCouplingFieldDoubleCorbaInterface_ptr,
                                                                   CORBA::Double, CORBA::Double );
    SALOME_MED::MEDCouplingFieldDoubleCorbaInterface_ptr add( SALOME_MED::MEDCouplingFieldDoubleCorbaInterface_ptr,
                                                              SALOME_MED::MEDCouplingFieldDoubleCorbaInterface_ptr );
    void printField( SALOME_MED::MEDCouplingFieldDoubleCorbaInterface_ptr );
    void cloneField( SALOME_MED::MEDCouplingFieldDoubleCorbaInterface_ptr,
                     SALOME_MED::MEDCouplingFieldDoubleCorbaInterface_out,
                     SALOME_MED::MEDCouplingFieldDoubleCorbaInterface_out,
                     SALOME_MED::MEDCouplingFieldDoubleCorbaInterface_out,
                     SALOME_MED::MEDCouplingFieldDoubleCorbaInterface_out );
    CORBA::Boolean isDone();
    CALCULATOR_ORB::ErrorCode getErrorCode();

protected:
    CALCULATOR_ORB::ErrorCode _errorCode;
};

class CALCULATORENGINE_EXPORT CALCULATOR_Session : public CALCULATOR_Abstract
{
public:
  CALCULATOR_Session( CORBA::ORB_ptr orb,
		      PortableServer::POA_ptr poa,
		      PortableServer::ObjectId* contId, 
		      const char* instanceName, 
		      const char* interfaceName)
    : CALCULATOR_Abstract(orb, poa, contId, instanceName, interfaceName, true) {}
};

class CALCULATORENGINE_EXPORT CALCULATOR_No_Session : public CALCULATOR_Abstract
{
public:
  CALCULATOR_No_Session( CORBA::ORB_ptr orb,
			 PortableServer::POA_ptr poa,
			 PortableServer::ObjectId* contId, 
			 const char* instanceName, 
			 const char* interfaceName)
    : CALCULATOR_Abstract(orb, poa, contId, instanceName, interfaceName, false) { }
};


#endif // CALCULATOR_HXX
