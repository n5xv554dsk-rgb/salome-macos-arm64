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

//  SuperVisionTest DataStreamComponent : example of component
//  File   : DataStreamComponent_Impl.hxx
//  Author : Jean Rahuel
//  Module : SuperVisionTest
//  $Header:
//
#ifndef _DATASTREAMINTERFACE_IMPL_HXX_
#define _DATASTREAMINTERFACE_IMPL_HXX_

#ifdef WIN32
# if defined DATASTREAMFACTORYENGINE_EXPORTS || defined DataStreamFactoryEngine_EXPORTS
#  define DATASTREAMFACTORYENGINE_EXPORT __declspec( dllexport )
# else
#  define DATASTREAMFACTORYENGINE_EXPORT __declspec( dllimport )
# endif
#else
# define DATASTREAMFACTORYENGINE_EXPORT
#endif

#include <SALOMEconfig.h>
#include CORBA_SERVER_HEADER(DataStreamComponent)
#include CORBA_SERVER_HEADER(SALOME_Component)
#include "SALOME_Component_i.hxx"

class DATASTREAMFACTORYENGINE_EXPORT DataStreamFactory_Impl :  public POA_DataStreamComponent::DataStreamFactory ,
                                                               public Engines_Component_i {
public:
  DataStreamFactory_Impl() ;
  DataStreamFactory_Impl( CORBA::ORB_ptr orb,
		          PortableServer::POA_ptr poa,
		          PortableServer::ObjectId * contId, 
		          const char *instanceName,
                          const char *interfaceName, bool withRegistry);

  virtual ~DataStreamFactory_Impl();

  virtual char* getVersion();

  virtual void Setxy( CORBA::Long x , CORBA::Long y ) ;

  virtual void Getxy( CORBA::Long & x , CORBA::Long & y ) ;

  virtual void Add( CORBA::Long x , CORBA::Long y , CORBA::Long & z ) ;
  virtual void Sub( CORBA::Long x , CORBA::Long y , CORBA::Long & z ) ;
  virtual void Mul( CORBA::Long x , CORBA::Long y , CORBA::Long & z ) ;
  virtual void Div( CORBA::Long x , CORBA::Long y , CORBA::Long & z ) ;

  virtual DataStreamComponent::DataStream_ptr NewDataStream() ;

private:

  long _x ;
  long _y ;

};

class DATASTREAMFACTORYENGINE_EXPORT DataStreamFactory_Impl_SSL : public DataStreamFactory_Impl
{
public:
  DataStreamFactory_Impl_SSL( CORBA::ORB_ptr orb,
		          PortableServer::POA_ptr poa,
		          PortableServer::ObjectId * contId, 
		          const char *instanceName,
                          const char *interfaceName):DataStreamFactory_Impl(orb,poa,contId,instanceName,interfaceName,false) { }
};

class DATASTREAMFACTORYENGINE_EXPORT DataStreamFactory_Impl_No_SSL : public DataStreamFactory_Impl
{
public:
  DataStreamFactory_Impl_No_SSL( CORBA::ORB_ptr orb,
		          PortableServer::POA_ptr poa,
		          PortableServer::ObjectId * contId, 
		          const char *instanceName,
                          const char *interfaceName):DataStreamFactory_Impl(orb,poa,contId,instanceName,interfaceName,true) { }
};

extern "C"
  DATASTREAMFACTORYENGINE_EXPORT
  PortableServer::ObjectId * DataStreamFactoryEngine_factory
                                   ( CORBA::ORB_ptr orb ,
                                     PortableServer::POA_ptr poa , 
                                     PortableServer::ObjectId * contId ,
                                     const char *instanceName ,
                                     const char *interfaceName ) ;


class DATASTREAMFACTORYENGINE_EXPORT DataStream_Impl :  public POA_DataStreamComponent::DataStream ,
                                                        public Engines_Component_i {
protected:
  DataStream_Impl() ;
  DataStream_Impl( CORBA::ORB_ptr orb ,
	           PortableServer::POA_ptr poa ,
	           PortableServer::ObjectId * contId , 
	           const char *instanceName ,
                   const char *interfaceName , 
                   const char * graphName ,
                   const char * nodeName, bool withRegistry );

  virtual ~DataStream_Impl();

  virtual char* getVersion();

  virtual void StreamSetxy( CORBA::Long x , CORBA::Long y ) ;

  virtual void StreamGetxy( CORBA::Long & x , CORBA::Long & y ) ;

  virtual void StreamAdd( CORBA::Long x , CORBA::Long y , CORBA::Long & z ) ;
  virtual void StreamSub( CORBA::Long x , CORBA::Long y , CORBA::Long & z ) ;
  virtual void StreamMul( CORBA::Long x , CORBA::Long y , CORBA::Long & z ) ;
  virtual void StreamDiv( CORBA::Long x , CORBA::Long y , CORBA::Long & z ) ;

private:

  long _x ;
  long _y ;

};

class DATASTREAMFACTORYENGINE_EXPORT DataStream_Impl_SSL :  public DataStream_Impl {
public:
  DataStream_Impl_SSL( CORBA::ORB_ptr orb ,
	           PortableServer::POA_ptr poa ,
	           PortableServer::ObjectId * contId , 
	           const char *instanceName ,
                   const char *interfaceName , 
                   const char * graphName ,
                   const char * nodeName):DataStream_Impl(orb,poa,contId,instanceName,interfaceName,graphName,nodeName,false) { }
};

class DATASTREAMFACTORYENGINE_EXPORT DataStream_Impl_No_SSL :  public DataStream_Impl {
public:
  DataStream_Impl_No_SSL( CORBA::ORB_ptr orb ,
	           PortableServer::POA_ptr poa ,
	           PortableServer::ObjectId * contId , 
	           const char *instanceName ,
                   const char *interfaceName , 
                   const char * graphName ,
                   const char * nodeName):DataStream_Impl(orb,poa,contId,instanceName,interfaceName,graphName,nodeName,true) { }
};

#endif
