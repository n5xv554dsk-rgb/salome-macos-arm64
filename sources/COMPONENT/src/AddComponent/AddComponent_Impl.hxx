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
//  File   : AddComponent_Impl.hxx
//  Author : Jean Rahuel, CEA
//  Module : SuperVisionTest
//  $Header:
//
#ifndef _ADDINTERFACE_IMPL_HXX_
#define _ADDINTERFACE_IMPL_HXX_


#include "AddComponent.hxx"
#include <SALOMEconfig.h>
#include CORBA_SERVER_HEADER(AddComponent)
#include CORBA_SERVER_HEADER(SALOME_Component)
#include "SALOME_Component_i.hxx"

class Adder_Impl;

class ADDCOMPONENTENGINE_EXPORT AddComponent_Impl :  public POA_SuperVisionTest::AddComponent ,
                                                     public Engines_Component_i {
protected:
  AddComponent_Impl() ;
  AddComponent_Impl( CORBA::ORB_ptr orb,
		     PortableServer::POA_ptr poa,
		     PortableServer::ObjectId * contId, 
		     const char *instanceName,
                     const char *interfaceName, bool withRegistry);
public:
  virtual ~AddComponent_Impl();

  virtual char* getVersion();

  virtual CORBA::Double Add( CORBA::Double x , CORBA::Double y , CORBA::Double & z ) ;
  virtual CORBA::Double AddWithoutSleep( CORBA::Double x , CORBA::Double y , CORBA::Double & z ) ;

  virtual void Setx( CORBA::Double x ) ;
  virtual void Sety( CORBA::Double y ) ;
  virtual CORBA::Double Addxy() ;
  virtual CORBA::Double AddyTox( CORBA::Double y ) ;

  virtual CORBA::Long Sigma( CORBA::Long n ) ;

  virtual CORBA::Double LastResult() ;

  virtual SuperVisionTest::Adder_ptr Addition() ;

  virtual CORBA::Boolean AdditionObjRef1( SuperVisionTest::Adder_out ) ;

  virtual void AdditionObjRef2( CORBA::Boolean & FuncValue , SuperVisionTest::Adder_out ) ;

  virtual CORBA::Boolean AdditionObjRefs( SuperVisionTest::AddComponent_ptr AddComponent1 ,
                                          SuperVisionTest::AddComponent_ptr Adder2 ,
                                          SuperVisionTest::AddComponent_ptr Adder3 ,
                                          SuperVisionTest::AddComponent_out RetAddComponent1 ,
                                          SuperVisionTest::AddComponent_out RetAdder2 ,
                                          SuperVisionTest::AddComponent_out RetAdder3 ) ;
private:

  Adder_Impl *BuildNewAdderImplObj();

private:

  double xx ;
  double yy ;
  double LastAddition ;

};

class ADDCOMPONENTENGINE_EXPORT AddComponent_Impl_SSL : public AddComponent_Impl
{
public:
  AddComponent_Impl_SSL( CORBA::ORB_ptr orb,
		     PortableServer::POA_ptr poa,
		     PortableServer::ObjectId * contId, 
		     const char *instanceName,
         const char *interfaceName):AddComponent_Impl(orb,poa,contId,instanceName,interfaceName,false) { }
};

class ADDCOMPONENTENGINE_EXPORT AddComponent_Impl_No_SSL : public AddComponent_Impl
{
public:
  AddComponent_Impl_No_SSL( CORBA::ORB_ptr orb,
		     PortableServer::POA_ptr poa,
		     PortableServer::ObjectId * contId, 
		     const char *instanceName,
         const char *interfaceName):AddComponent_Impl(orb,poa,contId,instanceName,interfaceName,true) { }
};

extern "C"
  ADDCOMPONENTENGINE_EXPORT
  PortableServer::ObjectId * AddComponentEngine_factory
                                   ( CORBA::ORB_ptr orb ,
                                     PortableServer::POA_ptr poa , 
                                     PortableServer::ObjectId * contId ,
                                     const char *instanceName ,
                                     const char *interfaceName ) ;

#endif
