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

#ifndef _HELLO_HXX_
#define _HELLO_HXX_

#ifdef WIN32
# if defined HELLOENGINE_EXPORTS || defined HELLOEngine_EXPORTS
#  define HELLOENGINE_EXPORT __declspec( dllexport )
# else
#  define HELLOENGINE_EXPORT __declspec( dllimport )
# endif
#else
# define HELLOENGINE_EXPORT
#endif


#include <SALOMEconfig.h>
#include CORBA_SERVER_HEADER(HELLO_Gen)
#include <SALOME_Component_i.hxx>

class HELLOENGINE_EXPORT HELLO_Abstract :
  public POA_HELLO_ORB::HELLO_Gen,
  public Engines_Component_i 
{
public:
  HELLO_Abstract( CORBA::ORB_ptr orb,
	 PortableServer::POA_ptr poa,
	 PortableServer::ObjectId* contId, 
	 const char* instanceName, 
	 const char* interfaceName ,
	 bool withRegistry = true);
  virtual ~HELLO_Abstract();

  HELLO_ORB::status hello  ( const char* name );
  HELLO_ORB::status goodbye( const char* name );
  void              copyOrMove( const HELLO_ORB::object_list& what,
				SALOMEDS::SObject_ptr where,
				CORBA::Long row, CORBA::Boolean isCopy );
  virtual char*     getVersion();
  // Get Study
  virtual SALOMEDS::Study_var getStudyServant() = 0;
};

class HELLOENGINE_EXPORT HELLO_Session : public HELLO_Abstract
{
public:
  HELLO_Session( CORBA::ORB_ptr orb,
	 PortableServer::POA_ptr poa,
	 PortableServer::ObjectId* contId, 
	 const char* instanceName, 
	 const char* interfaceName):HELLO_Abstract(orb,poa,contId,instanceName,interfaceName,true) { }
   SALOMEDS::Study_var getStudyServant() override;
};

class HELLOENGINE_EXPORT HELLO_No_Session : public HELLO_Abstract
{
public:
  HELLO_No_Session( CORBA::ORB_ptr orb,
	 PortableServer::POA_ptr poa,
	 PortableServer::ObjectId* contId, 
	 const char* instanceName, 
	 const char* interfaceName):HELLO_Abstract(orb,poa,contId,instanceName,interfaceName,false) { }
  SALOMEDS::Study_var getStudyServant() override;
};

extern "C"
HELLOENGINE_EXPORT
PortableServer::ObjectId* HELLOEngine_factory( CORBA::ORB_ptr orb,
					       PortableServer::POA_ptr poa,
					       PortableServer::ObjectId* contId,
					       const char* instanceName,
					       const char* interfaceName );

#endif
