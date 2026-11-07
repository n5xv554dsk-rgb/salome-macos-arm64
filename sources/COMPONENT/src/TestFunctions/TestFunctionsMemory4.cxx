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

//  SuperVisionTest TestFunctionsMemory : Check of memory leaks ...
//  File   : TestFunctionsMemory.cxx
//  Author : Jean Rahuel
//  Module : SuperVisionTest
//
#include <iostream>
#include <fstream>
#ifndef WIN32
#include <unistd.h>
#endif

#include <SALOMEconfig.h>
#include CORBA_CLIENT_HEADER(AddComponent)
#include CORBA_CLIENT_HEADER(SALOME_Component)

#include "utilities.h"
#include "SALOME_NamingService.hxx"
#include "SALOME_LifeCycleCORBA.hxx"
#include <OpUtil.hxx>

#include "DynInvoke.hxx"

using namespace std;

int main(int argc, char **argv) {
  CORBA::ORB_var orb = CORBA::ORB_init(argc, argv);
  CORBA::Object_var obj = orb->resolve_initial_references("RootPOA") ;
  PortableServer::POA_var poa = PortableServer::POA::_narrow(obj) ;
  SALOME_NamingService _NS(orb) ;
  SALOME_LifeCycleCORBA _LCC(&_NS) ;

  Engines::EngineComponent_var AddComponent = _LCC.FindOrLoad_Component( "FactoryServer" ,
                                                                         "AddComponent");
  SuperVisionTest::AddComponent_var AddInterface ;
  AddInterface = SuperVisionTest::AddComponent::_narrow( AddComponent );

  SuperVisionTest::Adder_var Adder1 ;
  bool sts1 = AddInterface->AdditionObjRef1( Adder1 ) ;

  int ninParams = 0 ;
  ServicesAnyData * inParams = NULL ;
  int noutParams = 2 ;
  ServicesAnyData * outParams = new ServicesAnyData[noutParams] ;
  bool b = 0 ;
  outParams[ 0 ].Value <<= (CORBA::Any::from_boolean ) b ;
  outParams[ 1 ].Value <<= CORBA::Object::_nil()  ;
  DynInvoke( AddInterface , "AdditionObjRef1" , inParams , ninParams ,
                                                outParams , noutParams ) ;
  outParams[ 0 ].Value >>= sts1 ;
  CORBA::Object_ptr objptr ;
  outParams[ 1 ].Value >>= objptr ;
  SuperVisionTest::Adder_var DynAdder1 ;
  DynAdder1 = SuperVisionTest::Adder::_narrow( objptr ) ;

  SuperVisionTest::Adder_var Adder2 ;
  bool sts2 ;
  AddInterface->AdditionObjRef2( sts2 , Adder2 ) ;

  outParams[ 0 ].Value <<= (CORBA::Any::from_boolean ) b ;
  outParams[ 1 ].Value <<= CORBA::Object::_nil()  ;
  DynInvoke( AddInterface , "AdditionObjRef2" , inParams , ninParams ,
                                                outParams , noutParams ) ;
  outParams[ 0 ].Value >>= sts2 ;
  outParams[ 1 ].Value >>= objptr ;
  SuperVisionTest::Adder_var DynAdder2 ;
  DynAdder2 = SuperVisionTest::Adder::_narrow( objptr ) ;

  delete [] outParams ;

  int i ;
  for ( i = 0 ; i < 10000 ; i++ ) {

    int ninParams = 2 ;
    ServicesAnyData * inParams = new ServicesAnyData[ninParams] ;
    int noutParams = 2 ;
    ServicesAnyData * outParams = new ServicesAnyData[noutParams] ;

// Direct call to AdditionObjRef1
    double d1 = 1. ;
    inParams[0].Name = string( "x1" ) ;
    inParams[0].Value <<= d1 ;
    double d2 = 2. ;
    inParams[1].Name = string( "y1" ) ;
    inParams[1].Value <<= d2 ;
    double Func1 = 0. ;
    outParams[ 0 ].Name = string( "Func1" ) ;
    outParams[ 0 ].Value <<= Func1 ;
    double z1 = 0. ;
    outParams[ 1 ].Name = string( "z1" ) ;
    outParams[ 1 ].Value <<= z1 ;
    DynInvoke( Adder1 , "AddWithoutSleep" , inParams , ninParams ,
                                            outParams , noutParams ) ;
    outParams[ 0 ].Value >>= Func1 ;
    outParams[ 1 ].Value >>= z1 ;
    cout << i << ". TestFunctionsMemory " << " Func1 " << Func1 << " z1 " << z1 << endl ;

// Call to AdditionObjRef1 via dynamic invocation
    Func1 = 0. ;
    outParams[ 0 ].Value <<= Func1 ;
    z1 = 0. ;
    outParams[ 1 ].Value <<= z1 ;
    DynInvoke( DynAdder1 , "AddWithoutSleep" , inParams , ninParams ,
                                               outParams , noutParams ) ;
    outParams[ 0 ].Value >>= Func1 ;
    outParams[ 1 ].Value >>= z1 ;
    Func1 = DynAdder1->AddWithoutSleep( 1. , 2. , z1 ) ;
    cout << i << ". TestFunctionsMemory DynInvoke " << " Func1 " << Func1 << " z1 " << z1
         << endl ;

// Direct call to AdditionObjRef2
    inParams[0].Name = string( "x2" ) ;
    inParams[1].Name = string( "y2" ) ;
    double Func2 = 0. ;
    outParams[ 0 ].Name = string( "Func2" ) ;
    outParams[ 0 ].Value <<= Func2 ;
    double z2 = 0. ;
    outParams[ 1 ].Name = string( "z2" ) ;
    outParams[ 1 ].Value <<= z2 ;
    DynInvoke( Adder2 , "AddWithoutSleep" , inParams , ninParams ,
                                            outParams , noutParams ) ;
    outParams[ 0 ].Value >>= Func2 ;
    outParams[ 1 ].Value >>= z2 ;
    cout << i << ". TestFunctions " << " Func2 " << Func2 << " z2 " << z2 << endl ;

// Call to AdditionObjRef2 via dynamic invocation
    outParams[ 0 ].Value <<= Func2 ;
    outParams[ 1 ].Value <<= z2 ;
    DynInvoke( DynAdder2 , "AddWithoutSleep" , inParams , ninParams ,
                                               outParams , noutParams ) ;
    outParams[ 0 ].Value >>= Func2 ;
    outParams[ 1 ].Value >>= z2 ;
    cout << i << ". TestFunctionsMemory DynInvoke " << " Func2 " << Func2 << " z2 " << z2
         << endl ;

    delete [] inParams ;
    delete [] outParams ;

  }

  Adder1->destroy() ;
  DynAdder1->destroy() ;
  Adder2->destroy() ;
  DynAdder2->destroy() ;

  return 0;
}
