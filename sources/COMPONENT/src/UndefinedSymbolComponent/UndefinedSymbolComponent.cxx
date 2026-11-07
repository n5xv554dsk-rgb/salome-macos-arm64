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

//  SuperVisionTest UndefinedSymbolComponent : example of component that devides two numbers
//  File   : UndefinedSymbolComponentEngine.cxx
//  Author : MARC TAJCHMAN, CEA
//  Module : SuperVisionTest
//
#include <stdio.h>
#include <unistd.h>
#include <fstream>
#include <sstream>
#include <string>

//#include "utilities.h"
#include "UndefinedSymbolComponent.hxx"
#include "COMPONENT_version.h"

using namespace std;

UndefinedSymbolComponentEngine::UndefinedSymbolComponentEngine( CORBA::ORB_ptr orb,
				    PortableServer::POA_ptr poa,
				    PortableServer::ObjectId * contId, 
				    const char *instanceName,
                                    const char *interfaceName, bool withRegistry) :
  Engines_Component_i(orb, poa, contId, instanceName, interfaceName,1,withRegistry)
{
//  MESSAGE("UndefinedSymbolComponentEngine::UndefinedSymbolComponentEngine activate object instanceName("
//          << instanceName << ") interfaceName(" << interfaceName << ")" )
  _thisObj = this ;
  _id = _poa->activate_object(_thisObj);
}

UndefinedSymbolComponentEngine::UndefinedSymbolComponentEngine() :
  Engines_Component_i()
{
}

UndefinedSymbolComponentEngine::~UndefinedSymbolComponentEngine()
{
}

char* UndefinedSymbolComponentEngine::getVersion()
{
#if COMPONENT_DEVELOPMENT
  return CORBA::string_dup(COMPONENT_VERSION_STR"dev");
#else
  return CORBA::string_dup(COMPONENT_VERSION_STR);
#endif
}

extern "C" { long CallUndefined() ; } ;

CORBA::Long UndefinedSymbolComponentEngine::UndefinedSymbol() {
  beginService( " UndefinedSymbolComponentEngine::UndefinedSymbol" );
  int S = 10 ;
  while ( S ) {
    S = sleep( S ) ;
  }
  long value = CallUndefined() ;
  endService( " UndefinedSymbolComponentEngine::UndefinedSymbol"  );
  return value ;
}

extern "C"
{
  PortableServer::ObjectId * UndefinedSymbolComponentEngine_factory
     (CORBA::ORB_ptr orb,
      PortableServer::POA_ptr poa, 
      PortableServer::ObjectId * contId,
      const char *instanceName,
      const char *interfaceName)
  {
    MESSAGE("UndefinedSymbolComponentEngine_factory UndefinedSymbolComponentEngine ("
            << instanceName << "," << interfaceName << ")");
    UndefinedSymbolComponentEngine * myUndefinedSymbolComponent = nullptr;
    CORBA::Object_var o = poa->id_to_reference(*contId);
    Engines::Container_var cont = Engines::Container::_narrow(o);    
    if(cont->is_SSL_mode())
     {
       myUndefinedSymbolComponent = new UndefinedSymbolComponentEngine_SSL(orb, poa, contId, instanceName, interfaceName);
     }
    else
    {
      myUndefinedSymbolComponent = new UndefinedSymbolComponentEngine_No_SSL(orb, poa, contId, instanceName, interfaceName);
    }
    return myUndefinedSymbolComponent->getId() ;
  }
}


