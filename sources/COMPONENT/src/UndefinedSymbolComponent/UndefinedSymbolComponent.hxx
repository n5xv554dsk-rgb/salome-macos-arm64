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
//  File   : UndefinedSymbolComponentEngine.hxx
//  Author : MARC TAJCHMAN, CEA
//  Module : SuperVisionTest
//  $Header$
//
#ifndef _UNDEFINEDSYMBOLCOMPONENTENGINE_HXX_
#define _UNDEFINEDSYMBOLCOMPONENTENGINE_HXX_

//#include <iostream.h>
#include <SALOMEconfig.h>
#include CORBA_SERVER_HEADER(UndefinedSymbolComponent)
#include CORBA_SERVER_HEADER(SALOME_Component)
#include "SALOME_Component_i.hxx"

class UndefinedSymbolComponentEngine :  public POA_SuperVisionTest::UndefinedSymbolComponent ,
                            public Engines_Component_i {
public:
  UndefinedSymbolComponentEngine() ;
  UndefinedSymbolComponentEngine( CORBA::ORB_ptr orb,
		      PortableServer::POA_ptr poa,
		      PortableServer::ObjectId * contId, 
		      const char *instanceName,
                      const char *interfaceName, bool withRegistry);

  virtual ~UndefinedSymbolComponentEngine();

  virtual char* getVersion();

  CORBA::Long UndefinedSymbol() ;

private:

  int _nexec ;

};

class UndefinedSymbolComponentEngine_SSL :  public UndefinedSymbolComponentEngine {
public:
  UndefinedSymbolComponentEngine_SSL( CORBA::ORB_ptr orb,
		      PortableServer::POA_ptr poa,
		      PortableServer::ObjectId * contId, 
		      const char *instanceName,
                      const char *interfaceName):UndefinedSymbolComponentEngine(orb,poa,contId,instanceName,interfaceName,false) { }
};

class UndefinedSymbolComponentEngine_No_SSL :  public UndefinedSymbolComponentEngine {
public:
  UndefinedSymbolComponentEngine_No_SSL( CORBA::ORB_ptr orb,
		      PortableServer::POA_ptr poa,
		      PortableServer::ObjectId * contId, 
		      const char *instanceName,
                      const char *interfaceName):UndefinedSymbolComponentEngine(orb,poa,contId,instanceName,interfaceName,true) { }
};

extern "C"
  PortableServer::ObjectId * UndefinedSymbolComponentEngine_factory
                                   ( CORBA::ORB_ptr orb ,
                                     PortableServer::POA_ptr poa , 
                                     PortableServer::ObjectId * contId ,
                                     const char *instanceName ,
                                     const char *interfaceName ) ;

#endif
