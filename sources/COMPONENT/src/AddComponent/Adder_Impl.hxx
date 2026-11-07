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

//  SuperVisionTest AddComponent : example of component that adds two numbers
//  File   : Adder_Impl.hxx
//  Author : Jean Rahuel, CEA
//  Module : SuperVisionTest
//  $Header:
//
#ifndef _ADDER_IMPL_HXX_
#define _ADDER_IMPL_HXX_

#include "AddComponent.hxx"
#include <iostream>
#include <SALOMEconfig.h>
#include CORBA_SERVER_HEADER(AddComponent)
#include CORBA_SERVER_HEADER(SALOME_Component)
#include "SALOME_Component_i.hxx"

class ADDCOMPONENTENGINE_EXPORT Adder_Impl :  public POA_SuperVisionTest::Adder ,
                                              public Engines_Component_i {
  protected:
    Adder_Impl() ;
    Adder_Impl( CORBA::ORB_ptr orb ,
	        PortableServer::POA_ptr poa ,
	        PortableServer::ObjectId * contId , 
	        const char *instanceName ,
                const char *interfaceName , 
                const char * graphName ,
                const char * nodeName, bool withRegistry );
  public:
    virtual ~Adder_Impl();

    virtual char* getVersion();

    virtual void destroy() ;

    virtual CORBA::Double Add( CORBA::Double x , CORBA::Double y , CORBA::Double & z ) ;

    virtual CORBA::Double AddWithoutSleep( CORBA::Double x , CORBA::Double y , CORBA::Double & z ) ;

    virtual CORBA::Double AddAndCompare( CORBA::Double x , CORBA::Double y ,
                                         SuperVisionTest::Adder_ptr anOtherAdder ,
                                          CORBA::Double & z ) ;

    virtual void SetLastResult( CORBA::Double z ) ;

    virtual void LastResult( CORBA::Double & z ) ;

    virtual Engines::EngineComponent_ptr LccAddComponent( const char * aContainer ,
                                                          const char * aComponentName ) ;

  private:

    double LastAddition ;

};

class ADDCOMPONENTENGINE_EXPORT Adder_Impl_SSL : public Adder_Impl
{
public:
  Adder_Impl_SSL( CORBA::ORB_ptr orb ,
	        PortableServer::POA_ptr poa ,
	        PortableServer::ObjectId * contId , 
	        const char *instanceName ,
                const char *interfaceName , 
                const char * graphName ,
                const char * nodeName):Adder_Impl(orb,poa,contId,instanceName,interfaceName,graphName,nodeName,false) { }
};

class ADDCOMPONENTENGINE_EXPORT Adder_Impl_No_SSL : public Adder_Impl
{
public:
  Adder_Impl_No_SSL( CORBA::ORB_ptr orb ,
	        PortableServer::POA_ptr poa ,
	        PortableServer::ObjectId * contId , 
	        const char *instanceName ,
                const char *interfaceName , 
                const char * graphName ,
                const char * nodeName):Adder_Impl(orb,poa,contId,instanceName,interfaceName,graphName,nodeName,true) { }
};

#endif
