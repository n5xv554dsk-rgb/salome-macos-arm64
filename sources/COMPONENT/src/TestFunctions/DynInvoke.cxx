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

//  SUPERV GraphExecutor : contains classes that permit execution of graphs and particularly the execution automaton
//  File   : DataFlowBase_DynInvoke.cxx
//  Author : Marc Tajchman, CEA
//  Module : SUPERV
//  $Header:
//
#include <iostream>
#ifndef WIN32
#include <unistd.h>
#endif
#include <iostream>
#include <fstream>
#include <sstream>
#include <iomanip>
#include <string>
#include <map>

#include <SALOMEconfig.h>
#include CORBA_CLIENT_HEADER(SALOME_Component)

#include "DynInvoke.hxx"

#include <stdarg.h>

using namespace std;
using namespace CORBA ;

void DynInvoke( Engines::EngineComponent_ptr objComponent ,
		const char *method , 
		ServicesAnyData * inParams , int nInParams ,
		ServicesAnyData * outParams , int nOutParams ) {
  Request_var req = objComponent->_request( method ) ;
  const char *ArgName ;
  int Type ;

  NVList_ptr arguments = req->arguments() ;

  int i ;

  int n_in  = nInParams ;
  int n_out = nOutParams ;

//  char * aComponent = ObjectToString( objComponent ) ;
//  MESSAGE( aComponent << "->" << method ) ;
  for ( i = 0 ; i < n_in ; i++ ) {
    CORBA::Any & data = inParams[i].Value ;
    ArgName           = inParams[i].Name.c_str() ;
    Type              = data.type()->kind() ;
    arguments->add_value( ArgName , data , CORBA::ARG_IN ) ;
#if 0
    switch ( Type ) {
    case CORBA::tk_string : {
      char * t ;
      data >>= t ;
      MESSAGE( "ArgIn" << i << " : " << ArgName << " Value " << t << " (string)" ) ;
      break ;
    }
    case CORBA::tk_boolean : {
      bool b ;
      data >>= (CORBA::Any::to_boolean ) b ;
      MESSAGE( "ArgIn" << i << " : " << ArgName << " Value " << b << " (boolean)" ) ;
      break ;
    }
    case CORBA::tk_char : {
      unsigned char c ;
      data >>= (CORBA::Any::to_char ) c ;
      MESSAGE( "ArgIn" << i << " : " << ArgName << " Value " << (int ) c << " (char)" ) ;
      break ;
    }
    case CORBA::tk_short : {
      short s ;
      data >>= s ;
      MESSAGE( "ArgIn" << i << " : " << ArgName << " Value " << s << " (short)" ) ;
      break ;
    }
    case CORBA::tk_long : {
      long l ;
      data >>= l ;
      MESSAGE( "ArgIn" << i << " : " << ArgName << " Value " << l << " (long)" ) ;
      break ;
    }
    case CORBA::tk_float : {
      float f ;
      data >>= f ;
      MESSAGE( "ArgIn" << i << " : " << ArgName << " Value " << f << " (float)" ) ;
      break ;
    }
    case CORBA::tk_double : {
      double d ;
      data >>= d ;
      MESSAGE( "ArgIn" << i << " : " << ArgName << " Value " << d << " (double)" ) ;
      break ;
    }
    case CORBA::tk_objref : {
      CORBA::Object_ptr obj ;
      char * retstr = "Catched ERROR";
      try {
        data >>= obj ;
        retstr = ObjectToString( obj ) ;
      }
      catch( ... ) {
      }
      MESSAGE( "ArgIn" << i << " : " << ArgName << " Value " << retstr << "(object reference)" ) ;
      break ;
    }
    default : {
      MESSAGE( "ArgIn" << i << " : " << ArgName << " Value " << "(other ERROR) kind " << Type ) ;
    }
    }
    MESSAGE("") ;
#endif
  }

  for ( i = 0 ; i < n_out ; i++ ) {
    CORBA::Any & data = outParams[i].Value ;
    ArgName           = outParams[i].Name.c_str() ;
    Type              = data.type()->kind() ;
    arguments->add_value( ArgName , data , CORBA::ARG_OUT ) ;
#if 0
    switch ( Type ) {
    case CORBA::tk_string : {
      char * t ;
      data >>= t ;
      MESSAGE( "ArgOut" << i << " : " << ArgName << " Value " << t << " (string)" ) ;
      break ;
    }
    case CORBA::tk_boolean : {
      bool b ;
      data >>= (CORBA::Any::to_boolean ) b ;
      MESSAGE( "ArgOut" << i << " : " << ArgName << " Value " << b << " (boolean)" ) ;
      break ;
    }
    case CORBA::tk_char : {
      unsigned char c ;
      data >>= (CORBA::Any::to_char ) c ;
      MESSAGE( "ArgOut" << i << " : " << ArgName << " Value " << (int ) c << " (char)" ) ;
      break ;
    }
    case CORBA::tk_short : {
      short s ;
      data >>= s ;
      MESSAGE( "ArgOut" << i << " : " << ArgName << " Value " << s << " (short)" ) ;
      break ;
    }
    case CORBA::tk_long : {
      long l ;
      data >>= l ;
      MESSAGE( "ArgOut" << i << " : " << ArgName << " Value " << l << " (long)" ) ;
      break ;
    }
    case CORBA::tk_float : {
      float f ;
      data >>= f ;
      MESSAGE( "ArgOut" << i << " : " << ArgName << " Value " << f << " (float)" ) ;
      break ;
    }
    case CORBA::tk_double : {
      double d ;
      data >>= d ;
      MESSAGE( "ArgOut" << i << " : " << ArgName << " Value " << d << " (double)" ) ;
      break ;
    }
    case CORBA::tk_objref : {
      CORBA::Object_ptr obj ;
      char * retstr = "Catched ERROR";
      try {
        data >>= obj ;
        retstr = ObjectToString( obj ) ;
      }
      catch( ... ) {
      }
      MESSAGE( "ArgOut" << i << " : " << ArgName << " Value " << retstr << "(object reference)" ) ;
      break ;
    }
    default : {
      MESSAGE( "ArgOut" << i << " : " << ArgName << " Value " << "(other ERROR) kind " << Type ) ;
    }
    }
    MESSAGE("") ;
#endif
  }

  req->invoke();

  if( req->env()->exception() ) {
    req->env()->exception()->_raise() ;
    return ; // pas utile ?
  }

  for ( i = 0 ; i < n_out ; i++ ) {

      outParams[i].Value = *( arguments->item( i + n_in )->value() ) ;
  }

  return;

}
