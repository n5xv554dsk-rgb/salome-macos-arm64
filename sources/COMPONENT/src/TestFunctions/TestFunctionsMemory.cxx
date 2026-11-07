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

  int i ;
  for ( i = 0 ; i < 10000 ; i++ ) {

// Direct call to AdditionObjRef1
    SuperVisionTest::Adder_var Adder1 ;
    bool sts1 = AddInterface->AdditionObjRef1( Adder1 ) ;
    double Func1 , z1 ;
    Func1 = Adder1->AddWithoutSleep( 1. , 2. , z1 ) ;
    cout << i << ". TestFunctionsMemory sts1 " << sts1 << " Func1 " << Func1 << " z1 " << z1 << endl ;
    Adder1->destroy() ;

// Call to AdditionObjRef1 via dynamic invocation
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
    CORBA::release( objptr ) ;
    Func1 = DynAdder1->AddWithoutSleep( 1. , 2. , z1 ) ;
    cout << i << ". TestFunctionsMemory DynInvoke sts1 " << sts1 << " Func1 " << Func1 << " z1 " << z1
         << endl ;
    DynAdder1->destroy() ;

// Direct call to AdditionObjRef2
    SuperVisionTest::Adder_var Adder2 ;
    bool sts2 ;
    AddInterface->AdditionObjRef2( sts2 , Adder2 ) ;
    double Func2 , z2 ;
    Func2 = Adder2->AddWithoutSleep( 1. , 2. , z2 ) ;
    cout << i << ". TestFunctions sts2 " << sts2 << " Func2 " << Func2 << " z2 " << z2 << endl ;
    Adder2->destroy() ;

// Call to AdditionObjRef2 via dynamic invocation
    outParams[ 0 ].Value <<= (CORBA::Any::from_boolean ) b ;
    outParams[ 1 ].Value <<= CORBA::Object::_nil()  ;
    DynInvoke( AddInterface , "AdditionObjRef2" , inParams , ninParams ,
                                                outParams , noutParams ) ;
    outParams[ 0 ].Value >>= sts2 ;
    outParams[ 1 ].Value >>= objptr ;
    SuperVisionTest::Adder_var DynAdder2 ;
    DynAdder2 = SuperVisionTest::Adder::_narrow( objptr ) ;
    CORBA::release( objptr ) ;
    Func2 = DynAdder2->AddWithoutSleep( 1. , 2. , z2 ) ;
    cout << i << ". TestFunctionsMemory DynInvoke sts2 " << sts2 << " Func2 " << Func2 << " z2 " << z2
         << endl ;
    DynAdder2->destroy() ;

    delete [] outParams ;
  }

  return 0;
}
