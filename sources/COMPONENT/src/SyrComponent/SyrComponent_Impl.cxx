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
//  File   : SyrComponent_Impl.cxx
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

#include "COMPONENT_version.h"
#include "SyrComponent_Impl.hxx"
#include "Adder_Impl.hxx"

using namespace std;

SyrComponent_Impl::SyrComponent_Impl( CORBA::ORB_ptr orb ,
				      PortableServer::POA_ptr poa ,
				      PortableServer::ObjectId * contId , 
				      const char *instanceName ,
                                      const char *interfaceName ,
                                      const bool kactivate , bool withRegistry ) :
  Engines_Component_i(orb, poa, contId, instanceName, interfaceName,true/*notif is true here for message*/,withRegistry) {
  MESSAGE("SyrComponent_Impl::SyrComponent_Impl this " << hex << this << dec
          << "activate object instanceName("
          << instanceName << ") interfaceName(" << interfaceName << ")" );
  if ( kactivate ) {
    _thisObj = this ;
    _id = _poa->activate_object(_thisObj);
  }
}

SyrComponent_Impl::SyrComponent_Impl() {
}

SyrComponent_Impl::~SyrComponent_Impl() {
}

char* SyrComponent_Impl::getVersion()
{
#if COMPONENT_DEVELOPMENT
  return CORBA::string_dup(COMPONENT_VERSION_STR"dev");
#else
  return CORBA::string_dup(COMPONENT_VERSION_STR);
#endif
}

CORBA::Long SyrComponent_Impl::C_ISEVEN( CORBA::Long anInteger ) {
  bool RetVal ;
  beginService( " SyrComponent_Impl::C_ISEVEN" );
  sendMessage(NOTIF_STEP, "SyrComponent_Impl::C_ISEVEN is Computing");
//  int S = 1+(int) (2.0*rand()/(RAND_MAX+1.0));
  int S = 1 ;
#ifndef WIN32
  while ( S ) {
    S = sleep( S ) ;
  }
#else
  Sleep(S*1000);
#endif
  RetVal = ( anInteger & 1 ) == 0 ;
  endService( " SyrComponent_Impl::C_ISEVEN"  );
  return RetVal ;
}

CORBA::Long SyrComponent_Impl::C_ISONE( CORBA::Long anOddInteger ) {
  bool RetVal ;
  beginService( " SyrComponent_Impl::C_ISONE" );
  sendMessage(NOTIF_STEP, "SyrComponent_Impl::C_ISONE is Computing");
//  int S = 1+(int) (2.0*rand()/(RAND_MAX+1.0));
  int S = 1 ;
#ifndef WIN32
  while ( S ) {
    S = sleep( S ) ;
  }
#else
  Sleep(S*1000);
#endif
  RetVal = ( anOddInteger == 1 ) ;
  endService( " SyrComponent_Impl::C_ISONE"  );
  return RetVal ;
}

CORBA::Long SyrComponent_Impl::C_M3( CORBA::Long anOddInteger ) {
  beginService( " SyrComponent_Impl::C_M3" );
  sendMessage(NOTIF_STEP, "SyrComponent_Impl::C_M3 is Computing");
//  int S = 1+(int) (2.0*rand()/(RAND_MAX+1.0));
  int S = 1 ;
#ifndef WIN32
  while ( S ) {
    S = sleep( S ) ;
  }
#else
  Sleep(S*1000);
#endif  endService( " SyrComponent_Impl::C_M3"  );
  if ( C_ISEVEN( anOddInteger ) )
    return 0 ;
  return ( 3*anOddInteger ) ;
}

CORBA::Long SyrComponent_Impl::C_M3P1( CORBA::Long anOddInteger ) {
  beginService( " SyrComponent_Impl::C_M3P1" );
  sendMessage(NOTIF_STEP, "SyrComponent_Impl::C_M3P1 is Computing");
//  int S = 1+(int) (2.0*rand()/(RAND_MAX+1.0));
  int S = 1 ;
#ifndef WIN32
  while ( S ) {
    S = sleep( S ) ;
  }
#else
  Sleep(S*1000);
#endif
  endService( " SyrComponent_Impl::C_M3P1"  );
  if ( C_ISEVEN( anOddInteger ) )
    return 0 ;
  return ( 3*anOddInteger + 1 ) ;
}

CORBA::Long SyrComponent_Impl::C_DIV2( CORBA::Long anEvenInteger ) {
  beginService( " SyrComponent_Impl::C_DIV2" );
  sendMessage(NOTIF_STEP, "SyrComponent_Impl::C_DIV2 is Computing");
//  int S = 1+(int) (2.0*rand()/(RAND_MAX+1.0));
  int S = 1 ;
#ifndef WIN32
  while ( S ) {
    S = sleep( S ) ;
  }
#else
  Sleep(S*1000);
#endif
  endService( " SyrComponent_Impl::C_DIV2"  );
  if ( !C_ISEVEN( anEvenInteger ) )
    return 0 ;
  return ( anEvenInteger >> 1 ) ;
}

CORBA::Long SyrComponent_Impl::C_INCR( CORBA::Long aCount ) {
  beginService( " SyrComponent_Impl::C_INCR" );
  sendMessage(NOTIF_STEP, "SyrComponent_Impl::C_INCR is Computing");
//  int S = 1+(int) (2.0*rand()/(RAND_MAX+1.0));
  int S = 1 ;
#ifndef WIN32
  while ( S ) {
    S = sleep( S ) ;
  }
#else
  Sleep(S*1000);
#endif
  endService( " SyrComponent_Impl::C_INCR"  );
  return ( aCount + 1 ) ;
}

void SyrComponent_Impl::CPP_SETLONG( CORBA::Long aCount ) {
  beginService( " SyrComponent_Impl::CPP_SETLONG" );
  sendMessage(NOTIF_STEP, "SyrComponent_Impl::CPP_SETLONG is Computing");
//  int S = 1+(int) (2.0*rand()/(RAND_MAX+1.0));
  int S = 1 ;
#ifndef WIN32
  while ( S ) {
    S = sleep( S ) ;
  }
#else
  Sleep(S*1000);
#endif
  _Count = aCount ;
  endService( " SyrComponent_Impl::CPP_SETLONG"  );
  return ;
}

CORBA::Long SyrComponent_Impl::CPP_ADDTOLONG( CORBA::Long anIncr ) {
  beginService( " SyrComponent_Impl::CPP_ADDTOLONG" );
  sendMessage(NOTIF_STEP, "SyrComponent_Impl::CPP_ADDTOLONG is Computing");
//  int S = 1+(int) (2.0*rand()/(RAND_MAX+1.0));
  int S = 1 ;
#ifndef WIN32
  while ( S ) {
    S = sleep( S ) ;
  }
#else
  Sleep(S*1000);
#endif
  endService( " SyrComponent_Impl::CPP_ADDTOLONG"  );
  return ( _Count + anIncr ) ;
}

CORBA::Long SyrComponent_Impl::C_MIN( CORBA::Long aMinVal , CORBA::Long anInteger ) {
  beginService( " SyrComponent_Impl::C_MIN" );
  sendMessage(NOTIF_STEP, "SyrComponent_Impl::C_MIN is Computing");
//  int S = 1+(int) (2.0*rand()/(RAND_MAX+1.0));
  int S = 1 ;
#ifndef WIN32
  while ( S ) {
    S = sleep( S ) ;
  }
#else
  Sleep(S*1000);
#endif
  int min = aMinVal ;
  if ( anInteger < min || aMinVal == 0 ) {
    min = anInteger ;
  }
  string trace = "SyrComponent_Impl::C_MIN : " ;
  char cmin[ 30 ] ;
  sprintf( cmin , "%d" , min ) ;
  trace += cmin ;
  sendMessage(NOTIF_TRACE, trace.c_str() );
  endService( " SyrComponent_Impl::C_MIN"  );
  return min ;
}

CORBA::Long SyrComponent_Impl::C_MAX( CORBA::Long aMaxVal , CORBA::Long anInteger ) {
  beginService( " SyrComponent_Impl::C_MAX" );
  sendMessage(NOTIF_STEP, "SyrComponent_Impl::C_MAX is Computing");
//  int S = 1+(int) (2.0*rand()/(RAND_MAX+1.0));
  int S = 1 ;
#ifndef WIN32
  while ( S ) {
    S = sleep( S ) ;
  }
#else
  Sleep(S*1000);
#endif
  int max = aMaxVal ;
  if ( anInteger > max ) {
    max = anInteger ;
  }
  string trace = "SyrComponent_Impl::C_MAX : " ;
  char cmax[ 30 ] ;
  sprintf( cmax , "%d" , max ) ;
  trace += cmax ;
  sendMessage(NOTIF_TRACE, trace.c_str() );
  endService( " SyrComponent_Impl::C_MAX"  );
  return max ;
}

SuperVisionTest::ListOfSyr_ptr SyrComponent_Impl::C_LISTOFSYR() {
  beginService( " SyrComponent_Impl::C_LISTOFSYR" );
  sendMessage(NOTIF_STEP, "SyrComponent_Impl::C_LISTOFSYR is Computing");
//  int S = 1+(int) (2.0*rand()/(RAND_MAX+1.0));
  int S = 1 ;
#ifndef WIN32
  while ( S ) {
    S = sleep( S ) ;
  }
#else
  Sleep(S*1000);
#endif
  ListOfSyr_Impl * aNewListOfSyr = nullptr;
  Engines::Container_var cont = this->GetContainerRef();
  if( cont->is_SSL_mode() )
  {
    aNewListOfSyr = new ListOfSyr_Impl_SSL( _orb , _poa, _contId,
                        instanceName() , interfaceName() ,
                        graphName() , nodeName() ) ;
  }
  else
  {
    aNewListOfSyr = new ListOfSyr_Impl_No_SSL( _orb , _poa, _contId,
                        instanceName() , interfaceName() ,
                        graphName() , nodeName() ) ;
  }
  SuperVisionTest::ListOfSyr_var iobject = (SuperVisionTest::ListOfSyr_var ) NULL ;
  PortableServer::ObjectId * id = aNewListOfSyr->getId() ;
  CORBA::Object_var obj = _poa->id_to_reference(*id);
  iobject = SuperVisionTest::ListOfSyr::_narrow(obj) ;
  endService( " SyrComponent_Impl::C_LISTOFSYR"  );
  return SuperVisionTest::ListOfSyr::_duplicate( iobject ) ;
//  return ( aNewListOfSyr._retn() ) ;
}

SuperVisionTest::ListOfSyr_ptr SyrComponent_Impl::C_AVERAGE(
                       SuperVisionTest::ListOfSyr_ptr aListOfSyr ,
                       CORBA::Long anInteger ,
                       CORBA::Long aCount ,
                       CORBA::Double & anAverage ) {
  beginService( " SyrComponent_Impl::C_AVERAGE" );
  sendMessage(NOTIF_STEP, "SyrComponent_Impl::C_AVERAGE is Computing");
//  int S = 1+(int) (2.0*rand()/(RAND_MAX+1.0));
  int S = 1 ;
#ifndef WIN32
  while ( S ) {
    S = sleep( S ) ;
  }
#else
  Sleep(S*1000);
#endif
  SuperVisionTest::SeqOfSyr * aSeqOfSyr = aListOfSyr->GetSeqOfSyr() ;
  int len = aSeqOfSyr->length() ;
  aSeqOfSyr->length( len + 1 ) ;
  (*aSeqOfSyr)[ len ] = anInteger ;
  aListOfSyr->SetSeqOfSyr( *aSeqOfSyr ) ;
  anAverage = 0 ;
  int i ;
  for ( i = 0 ; i < len + 1 ; i++ ) {
    anAverage += (*aSeqOfSyr)[ i ] ;
  }
  anAverage = anAverage / ( len + 1 ) ;
  string end = " SyrComponent_Impl::C_AVERAGE " ;
  char caverage[ 30 ] ;
  sprintf( caverage , "%fd" , anAverage ) ;
  end += caverage ;
  endService( end.c_str() );
  return SuperVisionTest::ListOfSyr::_duplicate( aListOfSyr ) ;
}

SuperVisionTest::Syr_ptr SyrComponent_Impl::Init( CORBA::Long anOddInteger ) {
  beginService( "SyrComponent_Impl::Init" );
  sendMessage(NOTIF_STEP, "SyrComponent_Impl creates Syr_Impl");
//  int S = 1+(int) (2.0*rand()/(RAND_MAX+1.0));
  int S = 1 ;
#ifndef WIN32
  while ( S ) {
    S = sleep( S ) ;
  }
#else
  Sleep(S*1000);
#endif
  Syr_Impl * mySyr = nullptr;
  if ( this->isSSLMode() )
  {
    mySyr = new Syr_Impl_SSL( _orb , _poa, _contId,
                        instanceName() , interfaceName() ,
                        graphName() , nodeName() , anOddInteger ) ;
  }
  else
  {
    mySyr = new Syr_Impl_No_SSL( _orb , _poa, _contId,
                        instanceName() , interfaceName() ,
                        graphName() , nodeName() , anOddInteger ) ;
  }
  SuperVisionTest::Syr_var iobject = (SuperVisionTest::Syr_var ) NULL ;
  PortableServer::ObjectId * id = mySyr->getId() ;
  CORBA::Object_var obj = _poa->id_to_reference(*id);
  iobject = SuperVisionTest::Syr::_narrow(obj) ;
  endService( "SyrComponent_Impl::Init" );
  return SuperVisionTest::Syr::_duplicate(iobject) ;
}

ListOfSyr_Impl::ListOfSyr_Impl( CORBA::ORB_ptr orb ,
		    PortableServer::POA_ptr poa ,
	       	    PortableServer::ObjectId * contId , 
		    const char * instanceName ,
                    const char * interfaceName , 
		    const char * graphName ,
                    const char * nodeName, bool withRegistry) :
  Engines_Component_i(orb, poa, contId, instanceName, interfaceName,1,withRegistry) {
  Names( graphName , nodeName ) ;
  MESSAGE("ListOfSyr_Impl::ListOfSyr_Impl activate object instanceName("
          << instanceName << ") interfaceName(" << interfaceName << ") --> "
          << hex << (void *) this << dec );
  beginService( "ListOfSyr_Impl::ListOfSyr_Impl" );
  _thisObj = this ;
  _id = _poa->activate_object(_thisObj);
  sendMessage(NOTIF_STEP, "ListOfSyr_Impl is Created");
  endService( "ListOfSyr_Impl::ListOfSyr_Impl" );
}

ListOfSyr_Impl::ListOfSyr_Impl() {
}

ListOfSyr_Impl::~ListOfSyr_Impl() {
  beginService( "ListOfSyr_Impl::~ListOfSyr_Impl" );
  endService( "ListOfSyr_Impl::~ListOfSyr_Impl" );
}

char* ListOfSyr_Impl::getVersion()
{
#if COMPONENT_DEVELOPMENT
  return CORBA::string_dup(COMPONENT_VERSION_STR"dev");
#else
  return CORBA::string_dup(COMPONENT_VERSION_STR);
#endif
}

SuperVisionTest::SeqOfSyr * ListOfSyr_Impl::GetSeqOfSyr() {
  SuperVisionTest::SeqOfSyr_var aSeqOfSyr = new SuperVisionTest::SeqOfSyr( _SeqOfSyr ) ;
  return ( aSeqOfSyr._retn() ) ;
}

void ListOfSyr_Impl::SetSeqOfSyr( const SuperVisionTest::SeqOfSyr & aSeqOfSyr ) {
  _SeqOfSyr = aSeqOfSyr ;
  return ;
}

extern "C"
{
  PortableServer::ObjectId * SyrComponentEngine_factory
     (CORBA::ORB_ptr orb,
      PortableServer::POA_ptr poa, 
      PortableServer::ObjectId * contId,
      const char *instanceName,
      const char *interfaceName)
  {
#ifndef WIN32
    MESSAGE("SyrComponentEngine_factory SyrComponentEngine ("
            << instanceName << "," << interfaceName << "," << getpid() << ")");
#else
    MESSAGE("SyrComponentEngine_factory SyrComponentEngine ("
            << instanceName << "," << interfaceName << "," << _getpid() << ")");
#endif
    SyrComponent_Impl * mySyrComponent = nullptr;
    CORBA::Object_var o = poa->id_to_reference(*contId);
    Engines::Container_var cont = Engines::Container::_narrow(o);
    if(cont->is_SSL_mode())
    {
      mySyrComponent = new SyrComponent_Impl_SSL(orb, poa, contId, instanceName, interfaceName);
    }
    else
    {
      mySyrComponent = new SyrComponent_Impl_No_SSL(orb, poa, contId, instanceName, interfaceName);
    }
    return mySyrComponent->getId() ;
  }
}

Syr_Impl::Syr_Impl( CORBA::ORB_ptr orb ,
		    PortableServer::POA_ptr poa ,
	       	    PortableServer::ObjectId * contId , 
		    const char * instanceName ,
                    const char * interfaceName , 
		    const char * graphName ,
                    const char * nodeName ,
                    const CORBA::Long anOddInteger, bool withRegistry) :
  SyrComponent_Impl(orb, poa, contId, instanceName, interfaceName,false,withRegistry) {
  Names( graphName , nodeName ) ;
  MESSAGE("Syr_Impl::Syr_Impl activate object instanceName("
          << instanceName << ") interfaceName(" << interfaceName << ") --> "
          << hex << (void *) this << dec );
  beginService( "Syr_Impl::Syr_Impl" );
  _thisObj = this ;
  _id = _poa->activate_object(_thisObj);
  _InitialInteger = anOddInteger ;
  _CurrentInteger = anOddInteger ;
  _Count = 0 ;
  sendMessage(NOTIF_STEP, "Syr_Impl is Created");
  endService( "Syr_Impl::Syr_Impl" );
}

Syr_Impl::Syr_Impl() {
}

Syr_Impl::~Syr_Impl() {
  beginService( "Syr_Impl::~Syr_Impl" );
  endService( "Syr_Impl::~Syr_Impl" );
}

CORBA::Long Syr_Impl::Initial() {
  beginService( " Syr_Impl::Initial" );
  sendMessage(NOTIF_STEP, "Syr_Impl::Initial is Computing");
//  int S = 1+(int) (2.0*rand()/(RAND_MAX+1.0));
  int S = 1 ;
#ifndef WIN32
  while ( S ) {
    S = sleep( S ) ;
  }
#else
  Sleep(S*1000);
#endif
  endService( " Syr_Impl::Initial"  );
  return _InitialInteger ;
}

CORBA::Long Syr_Impl::Current() {
  beginService( " Syr_Impl::Current" );
  sendMessage(NOTIF_STEP, "Syr_Impl::Current is Computing");
//  int S = 1+(int) (2.0*rand()/(RAND_MAX+1.0));
  int S = 1 ;
#ifndef WIN32
  while ( S ) {
    S = sleep( S ) ;
  }
#else
  Sleep(S*1000);
#endif
  endService( " Syr_Impl::Current"  );
  return _CurrentInteger ;
}

CORBA::Long Syr_Impl::IsEven() {
  bool RetVal ;
  beginService( " Syr_Impl::IsEven" );
  sendMessage(NOTIF_STEP, "Syr_Impl::IsEven is Computing");
//  int S = 1+(int) (2.0*rand()/(RAND_MAX+1.0));
  int S = 1 ;
#ifndef WIN32
  while ( S ) {
    S = sleep( S ) ;
  }
#else
  Sleep(S*1000);
#endif
  RetVal = ( _CurrentInteger & 1 ) == 0 ;
  MESSAGE( " Syr_Impl::IsEven " << _CurrentInteger << " " << RetVal );
  endService( " Syr_Impl::IsEven"  );
  return RetVal ;
}

CORBA::Long Syr_Impl::IsOne() {
  bool RetVal ;
  beginService( " Syr_Impl::IsOne" );
  sendMessage(NOTIF_STEP, "Syr_Impl::IsOne is Computing");
//  int S = 1+(int) (2.0*rand()/(RAND_MAX+1.0));
  int S = 1 ;
#ifndef WIN32
  while ( S ) {
    S = sleep( S ) ;
  }
#else
  Sleep(S*1000);
#endif
  RetVal = ( _CurrentInteger == 1 ) ;
  MESSAGE( " Syr_Impl::IsOne " << _CurrentInteger << " " << RetVal );
  endService( " Syr_Impl::IsOne"  );
  return RetVal ;
}

CORBA::Long Syr_Impl::Count() {
  beginService( " Syr_Impl::Count" );
  sendMessage(NOTIF_STEP, "Syr_Impl::Count is Computing");
//  int S = 1+(int) (2.0*rand()/(RAND_MAX+1.0));
  int S = 1 ;
#ifndef WIN32
  while ( S ) {
    S = sleep( S ) ;
  }
#else
  Sleep(S*1000);
#endif
  MESSAGE( " Syr_Impl::Count " << _Count );
  endService( " Syr_Impl::Count"  );
  return _Count ;
}

void Syr_Impl::M3p1() {
  beginService( " Syr_Impl::M3p1" );
  sendMessage(NOTIF_STEP, "Syr_Impl::M3p1 is Computing");
//  int S = 1+(int) (2.0*rand()/(RAND_MAX+1.0));
  int S = 1 ;
#ifndef WIN32
  while ( S ) {
    S = sleep( S ) ;
  }
#else
  Sleep(S*1000);
#endif
  if ( IsEven() )
    _CurrentInteger = 0 ;
  else
    _CurrentInteger = 3*_CurrentInteger + 1 ;
  MESSAGE( " Syr_Impl::M3p1 " << _CurrentInteger );
  endService( " Syr_Impl::M3p1"  );
}

void Syr_Impl::Div2() {
  beginService( " Syr_Impl::Div2" );
  sendMessage(NOTIF_STEP, "Syr_Impl::Div2 is Computing");
//  int S = 1+(int) (2.0*rand()/(RAND_MAX+1.0));
  int S = 1 ;
#ifndef WIN32
  while ( S ) {
    S = sleep( S ) ;
  }
#else
  Sleep(S*1000);
#endif
  if ( !IsEven() )
    _CurrentInteger = 0 ;
  else
    _CurrentInteger = ( _CurrentInteger >> 1 ) ;
  MESSAGE( " Syr_Impl::Div2 " << _CurrentInteger );
  endService( " Syr_Impl::Div2"  );
}

void Syr_Impl::Incr() {
  beginService( " Syr_Impl::Incr" );
  sendMessage(NOTIF_STEP, "Syr_Impl::Incr is Computing");
//  int S = 1+(int) (2.0*rand()/(RAND_MAX+1.0));
  int S = 1 ;
#ifndef WIN32
  while ( S ) {
    S = sleep( S ) ;
  }
#else
  Sleep(S*1000);
#endif
  _Count = _Count + 1 ;
  MESSAGE( " Syr_Impl::Incr " << _Count );
  endService( " Syr_Impl::Incr"  );
}



