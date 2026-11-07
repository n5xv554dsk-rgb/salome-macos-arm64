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

//  SuperVisionTest DataStreamComponent : example
//  File   : DataStreamComponent_Impl.cxx
//  Author : Jean Rahuel
//  Module : SuperVisionTest
//
#include <stdio.h>
#ifndef WIN32
#include <unistd.h>
#else
#include <process.h>
#endif
#include <fstream>
#include <sstream>
#include <string>

#include "COMPONENT_version.h"
#include "DataStreamComponent_Impl.hxx"

using namespace std;

DataStreamFactory_Impl::DataStreamFactory_Impl( CORBA::ORB_ptr orb,
				                PortableServer::POA_ptr poa,
				                PortableServer::ObjectId * contId, 
				                const char *instanceName,
                                                const char *interfaceName, bool withRegistry) :
  Engines_Component_i(orb, poa, contId, instanceName, interfaceName,1,withRegistry) {
  MESSAGE("DataStreamFactory_Impl::DataStreamFactory_Impl this " << hex << this << dec
          << "activate object instanceName("
          << instanceName << ") interfaceName(" << interfaceName << ")" );
  _thisObj = this ;
  _id = _poa->activate_object(_thisObj);
}

DataStreamFactory_Impl::DataStreamFactory_Impl() {
}

DataStreamFactory_Impl::~DataStreamFactory_Impl() {
}

char* DataStreamFactory_Impl::getVersion()
{
#if COMPONENT_DEVELOPMENT
  return CORBA::string_dup(COMPONENT_VERSION_STR"dev");
#else
  return CORBA::string_dup(COMPONENT_VERSION_STR);
#endif
}

void DataStreamFactory_Impl::Setxy( CORBA::Long x , CORBA::Long y ) {
  _x = x ;
  _y = y ;
}

void DataStreamFactory_Impl::Getxy( CORBA::Long & x , CORBA::Long & y ) {
  x = _x ;
  y = _y ;
}

void DataStreamFactory_Impl::Add( CORBA::Long x , CORBA::Long y , CORBA::Long & z ) {
  z = x+y ;
}
void DataStreamFactory_Impl::Sub( CORBA::Long x , CORBA::Long y , CORBA::Long & z ) {
  z = x-y ;
}
void DataStreamFactory_Impl::Mul( CORBA::Long x , CORBA::Long y , CORBA::Long & z ) {
  z = x*y ;
}
void DataStreamFactory_Impl::Div( CORBA::Long x , CORBA::Long y , CORBA::Long & z ) {
  z = x/y ;
}

DataStreamComponent::DataStream_ptr DataStreamFactory_Impl::NewDataStream() {
  beginService( "DataStreamFactory_Impl::NewDataStream" );
  sendMessage(NOTIF_STEP, "DataStreamFactory_Impl creates DataStream_Impl");
  DataStream_Impl * myDataStream = nullptr;
  Engines::Container_var cont = this->GetContainerRef();
  if( cont->is_SSL_mode() )
  {
    myDataStream = new DataStream_Impl_SSL( _orb , _poa, _contId,
                                      instanceName() , interfaceName() ,
                                      graphName() , nodeName() ) ;
  }
  else
  {
    myDataStream = new DataStream_Impl_No_SSL( _orb , _poa, _contId,
                                      instanceName() , interfaceName() ,
                                      graphName() , nodeName() ) ;
  }
  DataStreamComponent::DataStream_var iobject ;
  PortableServer::ObjectId * id = myDataStream->getId() ;
  CORBA::Object_var obj = _poa->id_to_reference(*id);
  iobject = DataStreamComponent::DataStream::_narrow(obj) ;
  endService( "DataStreamFactory_Impl::NewDataStream" );
  return DataStreamComponent::DataStream::_duplicate(iobject) ;
}

extern "C"
{
  PortableServer::ObjectId * DataStreamFactoryEngine_factory
     (CORBA::ORB_ptr orb,
      PortableServer::POA_ptr poa, 
      PortableServer::ObjectId * contId,
      const char *instanceName,
      const char *interfaceName)
  {
#ifndef WIN32
    MESSAGE("DataStreamFactoryEngine_factory DataStreamFactoryEngine ("
            << instanceName << "," << interfaceName << "," << getpid() << ")");
#else
    MESSAGE("DataStreamFactoryEngine_factory DataStreamFactoryEngine ("
            << instanceName << "," << interfaceName << "," << _getpid() << ")");
#endif
    DataStreamFactory_Impl * myDataStreamFactory = nullptr;
    CORBA::Object_var o = poa->id_to_reference(*contId);
    Engines::Container_var cont = Engines::Container::_narrow(o);    
    if(cont->is_SSL_mode())
    {
      myDataStreamFactory = new DataStreamFactory_Impl_SSL(orb, poa, contId, instanceName, interfaceName);
    }
    else
    {
      myDataStreamFactory = new DataStreamFactory_Impl_No_SSL(orb, poa, contId, instanceName, interfaceName);
    }
    return myDataStreamFactory->getId() ;
  }
}

DataStream_Impl::DataStream_Impl( CORBA::ORB_ptr orb ,
			          PortableServer::POA_ptr poa ,
	       	                  PortableServer::ObjectId * contId , 
		          	  const char * instanceName ,
                                  const char * interfaceName , 
		          	  const char * graphName ,
                                  const char * nodeName , bool withRegistry) :
  Engines_Component_i(orb, poa, contId, instanceName, interfaceName,1,withRegistry) {
  Names( graphName , nodeName ) ;
  MESSAGE("DataStream_Impl::DataStream_Impl activate object instanceName("
          << instanceName << ") interfaceName(" << interfaceName << ") --> "
          << hex << (void *) this << dec );
  beginService( "DataStream_Impl::DataStream_Impl" );
  _thisObj = this ;
  _id = _poa->activate_object(_thisObj);
  sendMessage(NOTIF_STEP, "DataStream_Impl is Created");
  endService( "DataStream_Impl::DataStream_Impl" );
}

DataStream_Impl::DataStream_Impl() {
}

DataStream_Impl::~DataStream_Impl() {
  beginService( "DataStream_Impl::~DataStream_Impl" );
  endService( "DataStream_Impl::~DataStream_Impl" );
}

char* DataStream_Impl::getVersion()
{
#if COMPONENT_DEVELOPMENT
  return CORBA::string_dup(COMPONENT_VERSION_STR"dev");
#else
  return CORBA::string_dup(COMPONENT_VERSION_STR);
#endif
}

void DataStream_Impl::StreamSetxy( CORBA::Long x , CORBA::Long y ) {
  _x = x ;
  _y = y ;
}

void DataStream_Impl::StreamGetxy( CORBA::Long & x , CORBA::Long & y ) {
  x = _x ;
  y = _y ;
}

void DataStream_Impl::StreamAdd( CORBA::Long x , CORBA::Long y , CORBA::Long & z ) {
  z = x+y ;
}
void DataStream_Impl::StreamSub( CORBA::Long x , CORBA::Long y , CORBA::Long & z ) {
  z = x-y ;
}
void DataStream_Impl::StreamMul( CORBA::Long x , CORBA::Long y , CORBA::Long & z ) {
  z = x*y ;
}
void DataStream_Impl::StreamDiv( CORBA::Long x , CORBA::Long y , CORBA::Long & z ) {
  z = x/y ;
}

