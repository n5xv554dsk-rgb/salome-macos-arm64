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
//  File   : SubComponentEngine.hxx
//  Author : MARC TAJCHMAN, CEA
//  Module : SuperVisionTest
//  $Header$
//
#ifndef _SUBCOMPONENTENGINE_HXX_
#define _SUBCOMPONENTENGINE_HXX_

#ifdef WIN32
# if defined SUBCOMPONENTENGINE_EXPORTS || defined SubComponentEngine_EXPORTS
#  define SUBCOMPONENTENGINE_EXPORT __declspec( dllexport )
# else
#  define SUBCOMPONENTENGINE_EXPORT __declspec( dllimport )
# endif
#else
# define SUBCOMPONENTENGINE_EXPORT
#endif

#include <SALOMEconfig.h>
#include CORBA_SERVER_HEADER(SubComponent)
#include CORBA_SERVER_HEADER(SALOME_Component)
#include "SALOME_Component_i.hxx"

class SUBCOMPONENTENGINE_EXPORT SubComponentEngine :  public POA_SuperVisionTest::SubComponent ,
                                                      public Engines_Component_i {
public:
  SubComponentEngine() ;
  SubComponentEngine( CORBA::ORB_ptr orb,
		      PortableServer::POA_ptr poa,
		      PortableServer::ObjectId * contId, 
		      const char *instanceName,
                      const char *interfaceName, bool withRegistry);

  virtual ~SubComponentEngine();

  virtual char* getVersion();

  void Sub( double x , double y , double & z ) ;

private:

  int _nexec ;

};

class SUBCOMPONENTENGINE_EXPORT SubComponentEngine_SSL :  public SubComponentEngine
{
public:
  SubComponentEngine_SSL(CORBA::ORB_ptr orb,
		      PortableServer::POA_ptr poa,
		      PortableServer::ObjectId * contId, 
		      const char *instanceName,
                      const char *interfaceName):SubComponentEngine(orb,poa,contId,instanceName,interfaceName,false) { }
};

class SUBCOMPONENTENGINE_EXPORT SubComponentEngine_No_SSL :  public SubComponentEngine
{
public:
  SubComponentEngine_No_SSL(CORBA::ORB_ptr orb,
		      PortableServer::POA_ptr poa,
		      PortableServer::ObjectId * contId, 
		      const char *instanceName,
                      const char *interfaceName):SubComponentEngine(orb,poa,contId,instanceName,interfaceName,true) { }
};

extern "C"
  SUBCOMPONENTENGINE_EXPORT
  PortableServer::ObjectId * SubComponentEngine_factory
                                   ( CORBA::ORB_ptr orb ,
                                     PortableServer::POA_ptr poa , 
                                     PortableServer::ObjectId * contId ,
                                     const char *instanceName ,
                                     const char *interfaceName ) ;

#endif
