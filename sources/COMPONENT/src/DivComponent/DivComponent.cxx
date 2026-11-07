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

//  SuperVisionTest DivComponent : example of component that devides two numbers
//  File   : DivComponentEngine.cxx
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
#include "DivComponent.hxx"
#include "COMPONENT_version.h"

using namespace std;

DivComponentEngine::DivComponentEngine( CORBA::ORB_ptr orb,
				    PortableServer::POA_ptr poa,
				    PortableServer::ObjectId * contId, 
				    const char *instanceName,
                                    const char *interfaceName, bool withRegistry) :
  Engines_Component_i(orb, poa, contId, instanceName, interfaceName,1,withRegistry)
{
//  MESSAGE("DivComponentEngine::DivComponentEngine activate object instanceName("
//          << instanceName << ") interfaceName(" << interfaceName << ")" )
  _thisObj = this ;
  _id = _poa->activate_object(_thisObj);
  _nexec = 0 ;
}

DivComponentEngine::DivComponentEngine()
{
}

DivComponentEngine::~DivComponentEngine()
{
}

char* DivComponentEngine::getVersion()
{
#if COMPONENT_DEVELOPMENT
  return CORBA::string_dup(COMPONENT_VERSION_STR"dev");
#else
  return CORBA::string_dup(COMPONENT_VERSION_STR);
#endif
}

void DivComponentEngine::Div( double x , double y , double & z ) {
  beginService( " DivComponentEngine::Div" );
  z = x / y ;
  int S;
  
  sendMessage(NOTIF_STEP, "Div is Computing");
//  S = 1+(int) (15.0*rand()/(RAND_MAX+1.0));
  S = 5 ;
#ifndef WIN32
  while ( S ) {
    S = sleep( S ) ;
  }
#else
  Sleep(S*1000);
#endif
  sendMessage(NOTIF_TRACE, "Div is Much More Difficult Operation");
  MESSAGE("DivComponentEngine::Div( " <<  x << " , " << y << " , " << z
       << " ) after " << S << " seconds" );
  endService( " DivComponentEngine::Div"  );
}

extern "C"
{
  PortableServer::ObjectId * DivComponentEngine_factory
     (CORBA::ORB_ptr orb,
      PortableServer::POA_ptr poa, 
      PortableServer::ObjectId * contId,
      const char *instanceName,
      const char *interfaceName)
  {
    MESSAGE("DivComponentEngine_factory DivComponentEngine ("
            << instanceName << "," << interfaceName << ")");
    CORBA::Object_var o = poa->id_to_reference(*contId);
    Engines::Container_var cont = Engines::Container::_narrow(o);
    DivComponentEngine * myDivComponent = nullptr;
    if(cont->is_SSL_mode())
    {
      myDivComponent = new DivComponentEngine_SSL(orb, poa, contId, instanceName, interfaceName);
    }
    else
    {
      myDivComponent = new DivComponentEngine_No_SSL(orb, poa, contId, instanceName, interfaceName);
    }
    return myDivComponent->getId() ;
  }
}


