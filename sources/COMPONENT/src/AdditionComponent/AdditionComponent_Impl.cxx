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

//  SuperVisionTest AdditionComponent : example of component that adds two numbers
//  File   : AdditionComponent_Impl.cxx
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

#include "AdditionComponent_Impl.hxx"
#include "Addition_Adder_Impl.hxx"
#include "COMPONENT_version.h"

using namespace std;

AdditionInterface_Impl::AdditionInterface_Impl( CORBA::ORB_ptr orb,
				      PortableServer::POA_ptr poa,
				      PortableServer::ObjectId * contId, 
				      const char *instanceName,
                                      const char *interfaceName, bool withRegistry) :
  Engines_Component_i(orb, poa, contId, instanceName, interfaceName,1,withRegistry) {
  MESSAGE("AdditionInterface_Impl::AdditionInterface_Impl this " << hex << this << dec
          << "activate object instanceName("
          << instanceName << ") interfaceName(" << interfaceName << ")" );
  _thisObj = this ;
  _id = _poa->activate_object(_thisObj);
  LastAddition = 0 ;
}

AdditionInterface_Impl::AdditionInterface_Impl() {
  LastAddition = 0 ;
}

AdditionInterface_Impl::~AdditionInterface_Impl() {
}

char* AdditionInterface_Impl::getVersion()
{
#if COMPONENT_DEVELOPMENT
  return CORBA::string_dup(COMPONENT_VERSION_STR"dev");
#else
  return CORBA::string_dup(COMPONENT_VERSION_STR);
#endif
}

CORBA::Double AdditionInterface_Impl::Add( CORBA::Double x , CORBA::Double y , CORBA::Double & z ) {
  beginService( " AdditionInterface_Impl::Add" );
  z = x + y ;
  int S;
  
  sendMessage(NOTIF_STEP, "AdditionInterface_Impl::Add is Computing");
//  S = 1+(int) (15.0*rand()/(RAND_MAX+1.0));
  S = 5 ;
#ifndef WIN32
  while ( S ) {
    S = sleep( S ) ;
  }
#else
  Sleep(S*1000);
#endif  
    MESSAGE( "AdditionInterface_Impl::Add( " <<  x << " , " << y << " , " << z << " ) returns " << (x - y) << " after " << S << " seconds" );
  LastAddition = z ;
  endService( " AdditionInterface_Impl::Add"  );
  return (x - y) ;
}

CORBA::Double AdditionInterface_Impl::AddWithoutSleep( CORBA::Double x , CORBA::Double y , CORBA::Double & z ) {
  beginService( " AdditionInterface_Impl::AddWithoutSleep" );
  z = x + y ;
  LastAddition = z ;
  endService( " AdditionInterface_Impl::AddWithoutSleep" );
  return (x - y) ;
}

CORBA::Long AdditionInterface_Impl::Sigma( CORBA::Long n ) {
  long sigma = 0 ;
  int i , j ;
  beginService( " AdditionInterface_Impl::Sigma" );
  for ( j = 0 ; j < 1000000 ; j++ ) {
    sigma = 0 ;
    for ( i = 1 ; i <= n ; i++ ) {
      sigma = sigma + i ;
    }
  }
  endService( " AdditionInterface_Impl::Sigma"  );
  return sigma ;
}

void AdditionInterface_Impl::Setx( CORBA::Double x ) {
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

void AdditionInterface_Impl::Sety( CORBA::Double y ) {
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

CORBA::Double AdditionInterface_Impl::Addxy() {
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

CORBA::Double AdditionInterface_Impl::AddyTox( CORBA::Double y ) {
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

CORBA::Double AdditionInterface_Impl::LastResult() {
  beginService( " AdditionInterface_Impl::LastResult" );
  sendMessage(NOTIF_STEP, "AdditionInterface_Impl::LastResult is Computing");
  endService( " AdditionInterface_Impl::LastResult"  );
  return LastAddition ;
}

AdditionComponent::Adder_ptr AdditionInterface_Impl::Addition() {
  beginService( "AdditionInterface_Impl::Addition" );
  sendMessage(NOTIF_STEP, "AdditionInterface_Impl creates Adder_Impl");
  Adder_Impl * myAdder ;
  myAdder = this->BuildNewAdderImplObj() ;
  AdditionComponent::Adder_var iobject ;
  PortableServer::ObjectId * id = myAdder->getId() ;
  CORBA::Object_var obj = _poa->id_to_reference(*id);
  iobject = AdditionComponent::Adder::_narrow(obj) ;
  endService( "AdditionInterface_Impl::Addition" );
  return iobject._retn() ;
//  return AdditionComponent::Adder::_duplicate(iobject) ;
}

Adder_Impl *AdditionInterface_Impl::BuildNewAdderImplObj()
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

bool AdditionInterface_Impl::AdditionObjRef1( AdditionComponent::Adder_out aAdder ) {
  beginService( "AdditionInterface_Impl::Addition" );
  sendMessage(NOTIF_STEP, "AdditionInterface_Impl creates Adder_Impl");
  Adder_Impl * myAdder = nullptr;
  myAdder = this->BuildNewAdderImplObj() ;
  AdditionComponent::Adder_var iobject ;
  PortableServer::ObjectId * id = myAdder->getId() ;
  CORBA::Object_var obj = _poa->id_to_reference(*id);
  iobject = AdditionComponent::Adder::_narrow(obj) ;
  endService( "AdditionInterface_Impl::Addition" );
  aAdder = AdditionComponent::Adder::_duplicate(iobject) ;
  return true ;
}

void AdditionInterface_Impl::AdditionObjRef2( CORBA::Boolean & FuncValue ,
                                              AdditionComponent::Adder_out aAdder ) {
  beginService( "AdditionInterface_Impl::Addition" );
  sendMessage(NOTIF_STEP, "AdditionInterface_Impl creates Adder_Impl");
  Adder_Impl * myAdder ;
  myAdder = this->BuildNewAdderImplObj() ;
  AdditionComponent::Adder_var iobject ;
  PortableServer::ObjectId * id = myAdder->getId() ;
  CORBA::Object_var obj = _poa->id_to_reference(*id);
  iobject = AdditionComponent::Adder::_narrow(obj) ;
  endService( "AdditionInterface_Impl::Addition" );
  aAdder = AdditionComponent::Adder::_duplicate(iobject) ;
  FuncValue = true ;
}

CORBA::Boolean AdditionInterface_Impl::AdditionObjRefs( AdditionComponent::AdditionInterface_ptr AdditionInterface1 ,
                                                        AdditionComponent::AdditionInterface_ptr Adder2 ,
                                                        AdditionComponent::AdditionInterface_ptr Adder3 ,
                                                        AdditionComponent::AdditionInterface_out RetAdditionInterface1 ,
                                                        AdditionComponent::AdditionInterface_out RetAdder2 ,
                                                        AdditionComponent::AdditionInterface_out RetAdder3 ) {
  bool RetVal = true ;
  beginService( "AdditionInterface_Impl::AdditionObjRefs" );
  cout << "beginService AdditionInterface_Impl::AdditionObjRefs" << endl ;
  CORBA::ORB_var orb = KERNEL::GetRefToORB();
  char * IOR = orb->object_to_string( AdditionInterface1 );
  cout << "AdditionInterface_Impl::AdditionObjRefs AdditionInterface1 " << AdditionInterface1 << " IOR "
       << IOR << " nil " << CORBA::is_nil( AdditionInterface1 ) << endl ;
  RetAdditionInterface1 = AdditionComponent::AdditionInterface::_duplicate( AdditionInterface1 ) ;
  IOR = orb->object_to_string( Adder2 );
  cout << "AdditionInterface_Impl::AdditionObjRefs Adder2 " << Adder2 << " IOR " << IOR << " nil "
       << CORBA::is_nil( Adder2 ) << endl ;
  RetAdder2 = AdditionComponent::AdditionInterface::_duplicate( Adder2 ) ;
  IOR = orb->object_to_string( Adder3 );
  cout << "AdditionInterface_Impl::AdditionObjRefs Adder3 " << Adder3 << " IOR " << IOR << " nil "
       << CORBA::is_nil( Adder3 ) << endl ;
  RetAdder3 = AdditionComponent::AdditionInterface::_duplicate( Adder3 ) ;
  if ( CORBA::is_nil( AdditionInterface1 ) || CORBA::is_nil( Adder2 ) ||
       CORBA::is_nil( Adder3 ) || CORBA::is_nil( RetAdditionInterface1 ) ||
       CORBA::is_nil( RetAdder2 ) || CORBA::is_nil( RetAdder3 ) ) {
    RetVal = false ;
  }
  cout << "endService AdditionInterface_Impl::AdditionObjRefs" << endl ;
  endService( "AdditionInterface_Impl::AdditionObjRefs" );
  return RetVal ;
}

//AdditionComponentEngine_factory
extern "C"
{
  PortableServer::ObjectId * AdditionComponentEngine_factory
     (CORBA::ORB_ptr orb,
      PortableServer::POA_ptr poa, 
      PortableServer::ObjectId * contId,
      const char *instanceName,
      const char *interfaceName)
  {
#ifndef WIN32
    MESSAGE("AdditionComponentEngine_factory AdditionInterfaceEngine ("
            << instanceName << "," << interfaceName << "," << getpid() << ")");
#else
    MESSAGE("AdditionComponentEngine_factory AdditionInterfaceEngine ("
            << instanceName << "," << interfaceName << "," << _getpid() << ")");
#endif
    AdditionInterface_Impl * myAdditionInterface = nullptr;
    CORBA::Object_var o = poa->id_to_reference(*contId);
    Engines::Container_var cont = Engines::Container::_narrow(o);
    if(cont->is_SSL_mode())
    {
      myAdditionInterface = new AdditionInterface_Impl_SSL(orb, poa, contId, instanceName, interfaceName);
    }
    else
    {
      myAdditionInterface = new AdditionInterface_Impl_No_SSL(orb, poa, contId, instanceName, interfaceName);
    }
    return myAdditionInterface->getId() ;
  }
}

