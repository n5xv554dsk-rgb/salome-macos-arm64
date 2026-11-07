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

//  SuperVisionTest SyrComponent : example of component performing some mathinatical operations
//  File   : TypesCheck_Impl.cxx
//  Author : Jean Rahuel
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

#include "TypesCheck_Impl.hxx"
#include "COMPONENT_version.h"

using namespace std;

TypesCheck_Impl::TypesCheck_Impl( CORBA::ORB_ptr orb ,
				  PortableServer::POA_ptr poa ,
				  PortableServer::ObjectId * contId , 
				  const char *instanceName ,
                                  const char *interfaceName ,
                                  const bool kactivate, bool withRegistry ) :
  Engines_Component_i(orb, poa, contId, instanceName, interfaceName,1,withRegistry) {
  MESSAGE("TypesCheck_Impl::TypesCheck_Impl this " << hex << this << dec
          << "activate object instanceName("
          << instanceName << ") interfaceName(" << interfaceName << ")" );
  if ( kactivate ) {
    _thisObj = this ;
    _id = _poa->activate_object(_thisObj);
  }
}

TypesCheck_Impl::TypesCheck_Impl() {
  beginService( "TypesCheck_Impl::TypesCheck_Impl" );
  endService( "TypesCheck_Impl::TypesCheck_Impl" );
}

TypesCheck_Impl::~TypesCheck_Impl() {
  beginService( "TypesCheck_Impl::~TypesCheck_Impl" );
  endService( "TypesCheck_Impl::~TypesCheck_Impl" );
}

char* TypesCheck_Impl::getVersion()
{
#if COMPONENT_DEVELOPMENT
  return CORBA::string_dup(COMPONENT_VERSION_STR"dev");
#else
  return CORBA::string_dup(COMPONENT_VERSION_STR);
#endif
}

void TypesCheck_Impl::StringCheck( const char * InString , _CORBA_String_out OutString ) {
  beginService( "TypesCheck_Impl::StringCheck" );
  OutString = CORBA::string_dup( InString ) ;
  endService( "TypesCheck_Impl::StringCheck" );
}

void TypesCheck_Impl::BoolCheck( bool InBool , bool & OutBool ) {
  beginService( "TypesCheck_Impl::BoolCheck" );
  OutBool = InBool ;
  endService( "TypesCheck_Impl::BoolCheck" );
}

void TypesCheck_Impl::CharCheck( unsigned char InChar , unsigned char & OutChar ) {
  beginService( "TypesCheck_Impl::CharCheck" );
  OutChar = InChar ;
  endService( "TypesCheck_Impl::CharCheck" );
}

void TypesCheck_Impl::ShortCheck( short InShort , short & OutShort ) {
  beginService( "TypesCheck_Impl::ShortCheck" );
  OutShort = InShort ;
  endService( "TypesCheck_Impl::ShortCheck" );
}

void TypesCheck_Impl::IntCheck( int InInt , int & OutInt ) {
  beginService( "TypesCheck_Impl::IntCheck" );
  OutInt = InInt ;
  endService( "TypesCheck_Impl::IntCheck" );
}

void TypesCheck_Impl::LongCheck( CORBA::Long InLong , CORBA::Long & OutLong ) {
  beginService( "TypesCheck_Impl::LongCheck" );
  int inInt = InLong ;
  int outInt = OutLong ;
  IntCheck( inInt , outInt ) ;
  OutLong = outInt ;
  endService( "TypesCheck_Impl::LongCheck" );
}

void TypesCheck_Impl::FloatCheck( float InFloat , float & OutFloat ) {
  beginService( "TypesCheck_Impl::FloatCheck" );
  OutFloat = InFloat ;
  endService( "TypesCheck_Impl::FloatCheck" );
}

void TypesCheck_Impl::DoubleCheck( double InDouble , double & OutDouble ) {
  beginService( "TypesCheck_Impl::DoubleCheck" );
  OutDouble = InDouble ;
  endService( "TypesCheck_Impl::DoubleCheck" );
}

void TypesCheck_Impl::ObjRefCheck( SuperVisionTest::Adder_ptr InObjRef , SuperVisionTest::Adder_out OutObjRef ) {
  beginService( "TypesCheck_Impl::ObjRefCheck" );
  OutObjRef = SuperVisionTest::Adder::_duplicate( InObjRef ) ;
  endService( "TypesCheck_Impl::ObjRefCheck" );
}

void TypesCheck_Impl::MiscTypes( const char * InString , bool InBool , unsigned char InChar , short InShort , CORBA::Long InLong , float InFloat , double InDouble , SuperVisionTest::Adder_ptr InObjRef , _CORBA_String_out OutString ,bool & OutBool , unsigned char & OutChar , short & OutShort , CORBA::Long & OutLong , float & OutFloat , double & OutDouble , SuperVisionTest::Adder_out OutObjRef ) {
  beginService( "TypesCheck_Impl::MiscTypes" );
  OutString = CORBA::string_dup( InString ) ;
  OutBool = InBool ;
  OutChar = InChar ;
  OutShort = InShort ;
  OutLong = InLong ;
  OutFloat = InFloat ;
  OutDouble = InDouble ;
  OutObjRef = SuperVisionTest::Adder::_duplicate( InObjRef ) ;
  endService( "TypesCheck_Impl::MiscTypes" );
}

extern "C"
{
  PortableServer::ObjectId * TypesCheckEngine_factory( CORBA::ORB_ptr orb ,
                                                       PortableServer::POA_ptr poa , 
                                                       PortableServer::ObjectId * contId ,
                                                       const char *instanceName ,
                                                       const char *interfaceName ) {
#ifndef WIN32
    MESSAGE("TypesCheckEngine_factory TypesCheckEngine ("
            << instanceName << "," << interfaceName << "," << getpid()<< ")");
#else
    MESSAGE("TypesCheckEngine_factory TypesCheckEngine ("
            << instanceName << "," << interfaceName << "," << _getpid()<< ")");
#endif
    CORBA::Object_var o = poa->id_to_reference(*contId);
    Engines::Container_var cont = Engines::Container::_narrow(o);    
    TypesCheck_Impl * myTypesCheck  = nullptr;
    if(cont->is_SSL_mode())
    {
      myTypesCheck = new TypesCheck_Impl_SSL(orb, poa, contId, instanceName, interfaceName);
    }
    else
    {
      myTypesCheck = new TypesCheck_Impl_No_SSL(orb, poa, contId, instanceName, interfaceName);
    }
    return myTypesCheck->getId() ;
  }
}

