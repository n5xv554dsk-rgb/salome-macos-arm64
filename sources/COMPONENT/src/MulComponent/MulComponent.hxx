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

//  SuperVisionTest MulComponent : example of component that multiplies two numbers
//  File   : MulComponentEngine.hxx
//  Author : MARC TAJCHMAN, CEA
//  Module : SuperVisionTest
//  $Header$
//
#ifndef _MULCOMPONENTENGINE_HXX_
#define _MULCOMPONENTENGINE_HXX_

#ifdef WIN32
# if defined MULCOMPONENTENGINE_EXPORTS || defined MulComponentEngine_EXPORTS
#  define MULCOMPONENTENGINE_EXPORT __declspec( dllexport )
# else
#  define MULCOMPONENTENGINE_EXPORT __declspec( dllimport )
# endif
#else
# define MULCOMPONENTENGINE_EXPORT
#endif

//#include <iostream.h>
#include <SALOMEconfig.h>
#include CORBA_SERVER_HEADER(MulComponent)
#include CORBA_SERVER_HEADER(SALOME_Component)
#include "SALOME_Component_i.hxx"

class MULCOMPONENTENGINE_EXPORT MulComponentEngine :  public POA_SuperVisionTest::MulComponent ,
                                                      public Engines_Component_i {
public:
  MulComponentEngine() ;
  MulComponentEngine( CORBA::ORB_ptr orb,
		      PortableServer::POA_ptr poa,
		      PortableServer::ObjectId * contId, 
		      const char *instanceName,
                      const char *interfaceName, bool withRegistry);

  virtual ~MulComponentEngine();

  virtual char* getVersion();

  void Mul( double x , double y , double & z ) ;

private:

  int _nexec ;

};

class MULCOMPONENTENGINE_EXPORT MulComponentEngine_SSL :  public MulComponentEngine
{
public:
  MulComponentEngine_SSL(CORBA::ORB_ptr orb,
		      PortableServer::POA_ptr poa,
		      PortableServer::ObjectId * contId, 
		      const char *instanceName,
                      const char *interfaceName):MulComponentEngine(orb,poa,contId,instanceName,interfaceName,false) { }
};

class MULCOMPONENTENGINE_EXPORT MulComponentEngine_No_SSL :  public MulComponentEngine
{
public:
  MulComponentEngine_No_SSL(CORBA::ORB_ptr orb,
		      PortableServer::POA_ptr poa,
		      PortableServer::ObjectId * contId, 
		      const char *instanceName,
                      const char *interfaceName):MulComponentEngine(orb,poa,contId,instanceName,interfaceName,true) { }
};

extern "C"
  MULCOMPONENTENGINE_EXPORT
  PortableServer::ObjectId * MulComponentEngine_factory
                                   ( CORBA::ORB_ptr orb ,
                                     PortableServer::POA_ptr poa , 
                                     PortableServer::ObjectId * contId ,
                                     const char *instanceName ,
                                     const char *interfaceName ) ;

#endif
