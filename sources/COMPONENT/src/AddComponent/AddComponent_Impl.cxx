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
#else
#include <process.h>
#endif
#include <fstream>
#include <sstream>
#include <string>

#include "utilities.h"
#include "OpUtil.hxx"
#include "SALOME_NamingService.hxx"
#include "SALOME_LifeCycleCORBA.hxx"
#include "SALOME_Container_i.hxx"

#include "AddComponent_Impl.hxx"
#include "Adder_Impl.hxx"
#include "COMPONENT_version.h"

using namespace std;

AddComponent_Impl::AddComponent_Impl( CORBA::ORB_ptr orb,
				      PortableServer::POA_ptr poa,
				      PortableServer::ObjectId * contId, 
				      const char *instanceName,
              const char *interfaceName, bool withRegistry) :
  Engines_Component_i(orb, poa, contId, instanceName, interfaceName,1,withRegistry) {
  MESSAGE("AddComponent_Impl::AddComponent_Impl this " << hex << this << dec
          << "activate object instanceName("
          << instanceName << ") interfaceName(" << interfaceName << ")" );
  _thisObj = this ;
  _id = _poa->activate_object(_thisObj);
  LastAddition = 0 ;
}

AddComponent_Impl::AddComponent_Impl() {
  LastAddition = 0 ;
}

AddComponent_Impl::~AddComponent_Impl() {
}

char* AddComponent_Impl::getVersion()
{
#if COMPONENT_DEVELOPMENT
  return CORBA::string_dup(COMPONENT_VERSION_STR"dev");
#else
  return CORBA::string_dup(COMPONENT_VERSION_STR);
#endif
}

CORBA::Double AddComponent_Impl::Add( CORBA::Double x , CORBA::Double y , CORBA::Double & z ) {
  beginService( " AddComponent_Impl::Add" );
  z = x + y ;
  int S;
  
  sendMessage(NOTIF_STEP, "AddComponent_Impl::Add is Computing");
//  S = 1+(int) (15.0*rand()/(RAND_MAX+1.0));
  S = 5 ;
#ifndef WIN32
  while ( S ) {
    S = sleep( S ) ;
  }
#else
  Sleep(S*1000);
#endif
  MESSAGE( "AddComponent_Impl::Add( " <<  x << " , " << y << " , " << z
       << " ) returns " << (x - y) << " after " << S << " seconds" );
  LastAddition = z ;
  endService( " AddComponent_Impl::Add"  );
  return (x - y) ;
}

CORBA::Double AddComponent_Impl::AddWithoutSleep( CORBA::Double x , CORBA::Double y , CORBA::Double & z ) {
  beginService( " AddComponent_Impl::AddWithoutSleep" );
  z = x + y ;
  LastAddition = z ;
  endService( " AddComponent_Impl::AddWithoutSleep" );
  return (x - y) ;
}

CORBA::Long AddComponent_Impl::Sigma( CORBA::Long n ) {
  long sigma = 0 ;
  int i , j ;
  beginService( " AddComponent_Impl::Sigma" );
  for ( j = 0 ; j < 1000000 ; j++ ) {
    sigma = 0 ;
    for ( i = 1 ; i <= n ; i++ ) {
      sigma = sigma + i ;
    }
  }
  endService( " AddComponent_Impl::Sigma"  );
  return sigma ;
}

void AddComponent_Impl::Setx( CORBA::Double x ) {
  int S = 1+(int) (15.0*rand()/(RAND_MAX+1.0));
#ifndef WIN32
  while ( S ) {
    S = sleep( S ) ;
  }
#else
  Sleep(S*1000);
#endif
  xx = x ;
}

void AddComponent_Impl::Sety( CORBA::Double y ) {
  int S = 1+(int) (15.0*rand()/(RAND_MAX+1.0));
#ifndef WIN32
  while ( S ) {
    S = sleep( S ) ;
  }
#else
  Sleep(S*1000);
#endif
  yy = y ;
}

CORBA::Double AddComponent_Impl::Addxy() {
  int S = 1+(int) (15.0*rand()/(RAND_MAX+1.0));
#ifndef WIN32
  while ( S ) {
    S = sleep( S ) ;
  }
#else
  Sleep(S*1000);
#endif
  double zz = xx + yy ;
  LastAddition = zz ;
  return zz;
}

CORBA::Double AddComponent_Impl::AddyTox( CORBA::Double y ) {
  int S = 1+(int) (15.0*rand()/(RAND_MAX+1.0));
#ifndef WIN32
  while ( S ) {
    S = sleep( S ) ;
  }
#else
  Sleep(S*1000);
#endif
  double zz = xx + y ;
  LastAddition = zz ;
  return zz;
}

CORBA::Double AddComponent_Impl::LastResult() {
  beginService( " AddComponent_Impl::LastResult" );
  sendMessage(NOTIF_STEP, "AddComponent_Impl::LastResult is Computing");
  endService( " AddComponent_Impl::LastResult"  );
  return LastAddition ;
}

SuperVisionTest::Adder_ptr AddComponent_Impl::Addition() {
  beginService( "AddComponent_Impl::Addition" );
  sendMessage(NOTIF_STEP, "AddComponent_Impl creates Adder_Impl");
  Adder_Impl * myAdder ;
  myAdder = this->BuildNewAdderImplObj();
  SuperVisionTest::Adder_var iobject ;
  PortableServer::ObjectId * id = myAdder->getId() ;
  CORBA::Object_var obj = _poa->id_to_reference(*id);
  iobject = SuperVisionTest::Adder::_narrow(obj) ;
  endService( "AddComponent_Impl::Addition" );
  return iobject._retn() ;
//  return SuperVisionTest::Adder::_duplicate(iobject) ;
}

Adder_Impl *AddComponent_Impl::BuildNewAdderImplObj()
{
  Engines::Container_var cont = this->GetContainerRef();
  if( cont->is_SSL_mode() )
  {
    return new Adder_Impl_SSL( _orb , _poa, _contId, instanceName() , interfaceName() , graphName() , nodeName() ) ;
  }
  else
  {
    return new Adder_Impl_No_SSL( _orb , _poa, _contId, instanceName() , interfaceName() , graphName() , nodeName() ) ;
  }
}

CORBA::Boolean AddComponent_Impl::AdditionObjRef1( SuperVisionTest::Adder_out aAdder ) {
  beginService( "AddComponent_Impl::Addition" );
  sendMessage(NOTIF_STEP, "AddComponent_Impl creates Adder_Impl");
  Adder_Impl * myAdder = nullptr;
  myAdder = this->BuildNewAdderImplObj();
  SuperVisionTest::Adder_var iobject ;
  PortableServer::ObjectId * id = myAdder->getId() ;
  CORBA::Object_var obj = _poa->id_to_reference(*id);
  iobject = SuperVisionTest::Adder::_narrow(obj) ;
  endService( "AddComponent_Impl::Addition" );
  aAdder = SuperVisionTest::Adder::_duplicate(iobject) ;
  return true ;
}

void AddComponent_Impl::AdditionObjRef2( CORBA::Boolean & FuncValue ,
                                         SuperVisionTest::Adder_out aAdder ) {
  beginService( "AddComponent_Impl::Addition" );
  sendMessage(NOTIF_STEP, "AddComponent_Impl creates Adder_Impl");
  Adder_Impl * myAdder ;
  myAdder = this->BuildNewAdderImplObj();
  SuperVisionTest::Adder_var iobject ;
  PortableServer::ObjectId * id = myAdder->getId() ;
  CORBA::Object_var obj = _poa->id_to_reference(*id);
  iobject = SuperVisionTest::Adder::_narrow(obj) ;
  endService( "AddComponent_Impl::Addition" );
  aAdder = SuperVisionTest::Adder::_duplicate(iobject) ;
  FuncValue = true ;
}

CORBA::Boolean AddComponent_Impl::AdditionObjRefs( SuperVisionTest::AddComponent_ptr AddComponent1 ,
                                                   SuperVisionTest::AddComponent_ptr Adder2 ,
                                                   SuperVisionTest::AddComponent_ptr Adder3 ,
                                                   SuperVisionTest::AddComponent_out RetAddComponent1 ,
                                                   SuperVisionTest::AddComponent_out RetAdder2 ,
                                                   SuperVisionTest::AddComponent_out RetAdder3 ) {
  bool RetVal = true ;
  beginService( "AddComponent_Impl::AdditionObjRefs" );
  cout << "beginService AddComponent_Impl::AdditionObjRefs" << endl ;
  CORBA::ORB_var orb = KERNEL::GetRefToORB();
  char * IOR = orb->object_to_string( AddComponent1 );
  cout << "AddComponent_Impl::AdditionObjRefs AddComponent1 " << AddComponent1 << " IOR "
       << IOR << " nil " << CORBA::is_nil( AddComponent1 ) << endl ;
  RetAddComponent1 = SuperVisionTest::AddComponent::_duplicate( AddComponent1 ) ;
  IOR = orb->object_to_string( Adder2 );
  cout << "AddComponent_Impl::AdditionObjRefs Adder2 " << Adder2 << " IOR " << IOR << " nil "
       << CORBA::is_nil( Adder2 ) << endl ;
  RetAdder2 = SuperVisionTest::AddComponent::_duplicate( Adder2 ) ;
  IOR = orb->object_to_string( Adder3 );
  cout << "AddComponent_Impl::AdditionObjRefs Adder3 " << Adder3 << " IOR " << IOR << " nil "
       << CORBA::is_nil( Adder3 ) << endl ;
  RetAdder3 = SuperVisionTest::AddComponent::_duplicate( Adder3 ) ;
  if ( CORBA::is_nil( AddComponent1 ) || CORBA::is_nil( Adder2 ) ||
       CORBA::is_nil( Adder3 ) || CORBA::is_nil( RetAddComponent1 ) ||
       CORBA::is_nil( RetAdder2 ) || CORBA::is_nil( RetAdder3 ) ) {
    RetVal = false ;
  }
  cout << "endService AddComponent_Impl::AdditionObjRefs" << endl ;
  endService( "AddComponent_Impl::AdditionObjRefs" );
  return RetVal ;
}


extern "C"
{
  PortableServer::ObjectId * AddComponentEngine_factory
     (CORBA::ORB_ptr orb,
      PortableServer::POA_ptr poa, 
      PortableServer::ObjectId * contId,
      const char *instanceName,
      const char *interfaceName)
  {
#ifndef WIN32
    MESSAGE("AddComponentEngine_factory AddComponentEngine ("
            << instanceName << "," << interfaceName << "," << getpid() << ")");
#else 
    MESSAGE("AddComponentEngine_factory AddComponentEngine ("
            << instanceName << "," << interfaceName << "," << _getpid() << ")");
#endif
    CORBA::Object_var o = poa->id_to_reference(*contId);
    Engines::Container_var cont = Engines::Container::_narrow(o);
    AddComponent_Impl * myAddComponent = nullptr;
    if(cont->is_SSL_mode())
    {
      myAddComponent = new AddComponent_Impl_SSL(orb, poa, contId, instanceName, interfaceName);
    }
    else
    {
      myAddComponent = new AddComponent_Impl_No_SSL(orb, poa, contId, instanceName, interfaceName);
    }
    return myAddComponent->getId() ;
  }
}

