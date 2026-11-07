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

//  SuperVisionTest AddComponent : example of component that adds two numbers
//  File   : AddComponent_Impl.cxx
//  Author : Jean Rahuel, CEA
//  Module : SuperVisionTest
//
#include <stdio.h>
#ifndef WIN32
#include <unistd.h>
#endif
#include <fstream>
#include <sstream>
#include <string>

#include "utilities.h"
#include "OpUtil.hxx"
#include "SALOME_NamingService.hxx"
#include "SALOME_LifeCycleCORBA.hxx"

#include "Adder_Impl.hxx"
#include "COMPONENT_version.h"

using namespace std;

Adder_Impl::Adder_Impl( CORBA::ORB_ptr orb ,
			PortableServer::POA_ptr poa ,
	       	        PortableServer::ObjectId * contId , 
			const char * instanceName ,
                        const char * interfaceName , 
			const char * graphName ,
                        const char * nodeName, bool withRegistry ) :
  Engines_Component_i(orb, poa, contId, instanceName, interfaceName,1,withRegistry) {
  Names( graphName , nodeName ) ;
  MESSAGE("Adder_Impl::Adder_Impl activate object instanceName("
          << instanceName << ") interfaceName(" << interfaceName << ") --> "
          << hex << (void *) this << dec );
  beginService( "Adder_Impl::Adder_Impl" );
  _thisObj = this ;
  _id = _poa->activate_object(_thisObj);
  LastAddition = 0 ;
  sendMessage(NOTIF_STEP, "Adder_Impl is Created");
  endService( "Adder_Impl::Adder_Impl" );
}

Adder_Impl::Adder_Impl() {
  LastAddition = 0 ;
}

Adder_Impl::~Adder_Impl() {
  beginService( "Adder_Impl::~Adder_Impl" );
  endService( "Adder_Impl::~Adder_Impl" );
}

char* Adder_Impl::getVersion()
{
#if COMPONENT_DEVELOPMENT
  return CORBA::string_dup(COMPONENT_VERSION_STR"dev");
#else
  return CORBA::string_dup(COMPONENT_VERSION_STR);
#endif
}

void Adder_Impl::destroy() {
  _poa->deactivate_object(*_id) ;
  CORBA::release(_poa) ;
  delete(_id) ;
  _thisObj->_remove_ref();
}

CORBA::Double Adder_Impl::Add( CORBA::Double x , CORBA::Double y , CORBA::Double & z ) {
  beginService( " Adder_Impl::Add" );
  z = x + y ;
  int S;
  
  sendMessage(NOTIF_STEP, "Adder_Impl::Add is Computing");
//  S = 1+(int) (15.0*rand()/(RAND_MAX+1.0));
  S = 5 ;
#ifndef WIN32
  while ( S ) {
    S = sleep( S ) ;
  }
#else
  Sleep(S*1000);
#endif
  MESSAGE( "Adder_Impl::Add( " <<  x << " , " << y << " , " << z
       << " ) returns " << -(x - y) << " after " << S << " seconds" );
  LastAddition = z ;
  endService( " Adder_Impl::Add"  );
  return -(x - y) ;
}

CORBA::Double Adder_Impl::AddWithoutSleep( CORBA::Double x , CORBA::Double y , CORBA::Double & z ) {
  beginService( " Adder_Impl::AddWithoutSleep" );
  z = x + y ;
  endService( " Adder_Impl::AddWithoutSleep"  );
  return -(x - y) ;
}

CORBA::Double Adder_Impl::AddAndCompare( CORBA::Double x , CORBA::Double y ,
                                         SuperVisionTest::Adder_ptr anOtherAdder ,
                                         CORBA::Double & z ) {
  beginService( " Adder_Impl::AddAndCompare" );
  z = x + y ;
  int S;
  
  sendMessage(NOTIF_STEP, "Adder_Impl::AddAndCompare is Computing");
//  S = 1+(int) (15.0*rand()/(RAND_MAX+1.0));
  S = 5 ;
#ifndef WIN32
  while ( S ) {
    S = sleep( S ) ;
  }
#else
  Sleep(S*1000);
#endif
  MESSAGE( "Adder_Impl::AddAndCompare( " <<  x << " , " << y << " , " << z
       << " ) returns " << -(x - y) << " after " << S << " seconds" );
  LastAddition = z ;
  double ValFunc ;
  sendMessage(NOTIF_TRACE, "Adder_Impl::AddAndCompare will call anOtherAdder->LastValue()");
  double RetVal ;
  anOtherAdder->LastResult( RetVal ) ;
  if ( RetVal > 0 ) {
    ValFunc = (x - y) ;
  }
  else {
    ValFunc = -(x - y) ;
  }
  sendMessage(NOTIF_TRACE, "Adder_Impl::AddAndCompare has called anOtherAdder->LastValue()");
  sendMessage(NOTIF_STEP, "Adder_Impl::AddAndCompare is Finished");
  endService( " Adder_Impl::AddAndCompare"  );
  return ValFunc ;
}

void Adder_Impl::SetLastResult( CORBA::Double z ) {
  beginService( " Adder_Impl::SetLastResult" );
  sendMessage(NOTIF_STEP, "Adder_Impl::SetLastResult is Computing");
  int S;
//  S = 1+(int) (15.0*rand()/(RAND_MAX+1.0));
  S = 5 ;
#ifndef WIN32
  while ( S ) {
    S = sleep( S ) ;
  }
#else
  Sleep(S*1000);
#endif
  LastAddition = z ;
  endService( " Adder_Impl::SetLastResult"  );
  return ;
}

void Adder_Impl::LastResult( CORBA::Double & z ) {
  beginService( " Adder_Impl::LastResult" );
  sendMessage(NOTIF_STEP, "Adder_Impl::LastResult is Computing");
  int S;
//  S = 1+(int) (15.0*rand()/(RAND_MAX+1.0));
  S = 5 ;
#ifndef WIN32
  while ( S ) {
    S = sleep( S ) ;
  }
#else
  Sleep(S*1000);
#endif
  z = LastAddition ;
  endService( " Adder_Impl::LastResult"  );
  return ;
}

Engines::EngineComponent_ptr Adder_Impl::LccAddComponent( const char * aContainer ,
                                                          const char * aComponentName ) {
  beginService( "Adder_Impl::LccAddComponent" );
  Engines::EngineComponent_ptr objComponent ;
  objComponent = Engines::EngineComponent::_nil() ;

  CORBA::ORB_var orb = KERNEL::GetRefToORB();
  SALOME_NamingService *_NS ;
  _NS = new SALOME_NamingService();
  _NS->init_orb( CORBA::ORB::_duplicate(orb) ) ;
	  
  SALOME_LifeCycleCORBA LCC( _NS ) ;
  objComponent = LCC.FindOrLoad_Component( aContainer ,
					   aComponentName );
  endService( "Adder_Impl::LccAddComponent"  );
  return objComponent ;
}
