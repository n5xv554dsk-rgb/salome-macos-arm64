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

//  SuperVisionTest SubComponent : example of component that sunstracts one number from another
//  File   : SubComponentEngine.cxx
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

#include "COMPONENT_version.h"
#include "SubComponent.hxx"

using namespace std;

SubComponentEngine::SubComponentEngine( CORBA::ORB_ptr orb,
				    PortableServer::POA_ptr poa,
				    PortableServer::ObjectId * contId, 
				    const char *instanceName,
                                    const char *interfaceName, bool withRegistry) :
  Engines_Component_i(orb, poa, contId, instanceName, interfaceName,1,withRegistry)
{
//  MESSAGE("SubComponentEngine::SubComponentEngine activate object instanceName("
//          << instanceName << ") interfaceName(" << interfaceName << ")" )
  _thisObj = this ;
  _id = _poa->activate_object(_thisObj);
  _nexec = 0 ;
}

SubComponentEngine::SubComponentEngine()
{
}

SubComponentEngine::~SubComponentEngine()
{
}

char* SubComponentEngine::getVersion()
{
#if COMPONENT_DEVELOPMENT
  return CORBA::string_dup(COMPONENT_VERSION_STR"dev");
#else
  return CORBA::string_dup(COMPONENT_VERSION_STR);
#endif
}

void SubComponentEngine::Sub( double x , double y , double & z ) {
  beginService( " SubComponentEngine::Sub" );
  z = x - y ;
  int S;
  
  sendMessage(NOTIF_STEP, "Sub is Computing");
//  S = 1+(int) (15.0*rand()/(RAND_MAX+1.0));
  S = 5 ;
#ifndef WIN32
  while ( S ) {
    S = sleep( S ) ;
  }
#else
  Sleep(S*1000);
#endif
  MESSAGE( "SubComponentEngine::Sub( " <<  x << " , " << y << " , " << z
       << " ) after " << S << " seconds" );
  endService( " SubComponentEngine::Sub"  );
}

extern "C"
{
  PortableServer::ObjectId * SubComponentEngine_factory
     (CORBA::ORB_ptr orb,
      PortableServer::POA_ptr poa, 
      PortableServer::ObjectId * contId,
      const char *instanceName,
      const char *interfaceName)
  {
    MESSAGE("SubComponentEngine_factory SubComponentEngine ("
            << instanceName << "," << interfaceName << ")");
    SubComponentEngine * mySubComponent = nullptr;
    CORBA::Object_var o = poa->id_to_reference(*contId);
    Engines::Container_var cont = Engines::Container::_narrow(o);
    if(cont->is_SSL_mode())
    {
      mySubComponent = new SubComponentEngine_SSL(orb, poa, contId, instanceName, interfaceName);
    }
    else
    {
      mySubComponent = new SubComponentEngine_No_SSL(orb, poa, contId, instanceName, interfaceName);
    }
    return mySubComponent->getId() ;
  }
}


