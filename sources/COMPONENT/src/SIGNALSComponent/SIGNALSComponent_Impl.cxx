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

//  SuperVisionTest SIGNALSComponent : example of component that devides two numbers
//  File   : SIGNALSComponent.cxx
//  Author : MARC TAJCHMAN, CEA
//  Module : SuperVisionTest
//
#include <stdio.h>
#ifndef WIN32
#include <unistd.h>
#endif
#include <fstream>
#include <sstream>
#include <string>

//#include "utilities.h"
#include "SIGNALSComponent_Impl.hxx"
#include "COMPONENT_version.h"

using namespace std;

SIGNALSComponent_Impl::SIGNALSComponent_Impl( CORBA::ORB_ptr orb,
				    PortableServer::POA_ptr poa,
				    PortableServer::ObjectId * contId, 
				    const char *instanceName,
                                    const char *interfaceName, bool withRegistry) :
  Engines_Component_i(orb, poa, contId, instanceName, interfaceName,1,withRegistry)
{
  MESSAGE("SIGNALSComponent_Impl::SIGNALSComponent_Impl activate object instanceName("
          << instanceName << ") interfaceName(" << interfaceName << ")" );
  _thisObj = this ;
  _id = _poa->activate_object(_thisObj);
  NULLPTR = NULL ;
}

SIGNALSComponent_Impl::SIGNALSComponent_Impl() :
  Engines_Component_i()
{
  NULLPTR = NULL ;
}

SIGNALSComponent_Impl::~SIGNALSComponent_Impl()
{
}

char* SIGNALSComponent_Impl::getVersion()
{
#if COMPONENT_DEVELOPMENT
  return CORBA::string_dup(COMPONENT_VERSION_STR"dev");
#else
  return CORBA::string_dup(COMPONENT_VERSION_STR);
#endif
}

CORBA::Long SIGNALSComponent_Impl::SIGSEGVfunc() {
  beginService( " SIGNALSComponent_Impl::SIGSEGVfunc" );
#ifndef WIN32
  cout << pthread_self() << "SIGNALSComponent_Impl::SIGSEGVfunc" << endl ;
#else
  cout << pthread_self().p << "SIGNALSComponent_Impl::SIGSEGVfunc" << endl ;
#endif
  int S = 1+(int) (15.0*rand()/(RAND_MAX+1.0));

#ifndef WIN32
  while ( S ) {
    S = sleep( S ) ;
  }
#else
  Sleep(S*1000);
#endif
  long _nullptr = *NULLPTR ;
  endService( " SIGNALSComponent_Impl::SIGSEGVfunc"  );
  return _nullptr ;
}

CORBA::Long SIGNALSComponent_Impl::SIGFPEfunc( CORBA::Long a , CORBA::Long b ) {
  beginService( " SIGNALSComponent_Impl::SIGFPEfunc" );
#ifndef WIN32
  cout << pthread_self() << "SIGNALSComponent_Impl::SIGFPEfunc" << endl ;
#else 
  cout << pthread_self().p << "SIGNALSComponent_Impl::SIGFPEfunc" << endl ;
#endif
  int S = 1+(int) (15.0*rand()/(RAND_MAX+1.0));
#ifndef WIN32
  while ( S ) {
    S = sleep( S ) ;
  }
#else
  Sleep(S*1000);
#endif
  long c = a/b ;
  endService( " SIGNALSComponent_Impl::SIGFPEfunc"  );
  return c ;
}

void SIGNALSComponent_Impl::MethodToKill() {
  beginService( " SIGNALSComponent_Impl::MethodToKill" );
  while ( 1 ) {
#ifndef WIN32
    sleep(1);
#else
    Sleep(1000);
#endif

  }
  endService( " SIGNALSComponent_Impl::MethodToKill"  );
  return ;
}

void * RunMethodToKill( void * ptr ) {
  SIGNALSComponent_Impl * mySIGNALSComponent ;
  mySIGNALSComponent = ( SIGNALSComponent_Impl * ) ptr ;
  mySIGNALSComponent->MethodToKill() ;
  return ptr ;
}

void SIGNALSComponent_Impl::WaitKill() {
  pthread_t T;
  pthread_create( &T , NULL , RunMethodToKill , this ) ;
  pthread_join( T , NULL ) ;
}

extern "C"
{
  PortableServer::ObjectId * SIGNALSComponentEngine_factory
     (CORBA::ORB_ptr orb,
      PortableServer::POA_ptr poa, 
      PortableServer::ObjectId * contId,
      const char *instanceName,
      const char *interfaceName)
  {
    MESSAGE("SIGNALSComponentEngine_factory SIGNALSComponent_Impl("
            << instanceName << "," << interfaceName << ")");
    SIGNALSComponent_Impl * mySIGNALSComponent = nullptr;
    CORBA::Object_var o = poa->id_to_reference(*contId);
    Engines::Container_var cont = Engines::Container::_narrow(o);    
    if(cont->is_SSL_mode())
    {
      mySIGNALSComponent = new SIGNALSComponentEngine_SSL(orb, poa, contId, instanceName, interfaceName);
    }
    else
    {
      mySIGNALSComponent = new SIGNALSComponentEngine_No_SSL(orb, poa, contId, instanceName, interfaceName);
    }
    return mySIGNALSComponent->getId() ;
  }
}


