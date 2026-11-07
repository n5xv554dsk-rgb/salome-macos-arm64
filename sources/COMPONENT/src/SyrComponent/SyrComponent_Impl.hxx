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

//  SuperVisionTest SyrComponent : example of component performing some mathinatical operations
//  File   : SyrComponent_Impl.hxx
//  Author : Jean Rahuel, CEA
//  Module : SuperVisionTest
//  $Header:
//
#ifndef _SYRCOMPONENT_IMPL_HXX_
#define _SYRCOMPONENT_IMPL_HXX_

#ifdef WIN32
# if defined SYRCOMPONENTENGINE_EXPORTS || defined SyrComponentEngine_EXPORTS                                                   
#  define SYRCOMPONENTENGINE_EXPORT __declspec( dllexport )
# else
#  define SYRCOMPONENTENGINE_EXPORT __declspec( dllimport )
# endif
#else
# define SYRCOMPONENTENGINE_EXPORT
#endif

//#include <iostream.h>
#include <SALOMEconfig.h>
#include CORBA_SERVER_HEADER(SyrComponent)
#include CORBA_SERVER_HEADER(SALOME_Component)
#include "SALOME_Component_i.hxx"

class SYRCOMPONENTENGINE_EXPORT SyrComponent_Impl : public POA_SuperVisionTest::SyrComponent,
                                                      public Engines_Component_i {
public:
  SyrComponent_Impl() ;
  SyrComponent_Impl( CORBA::ORB_ptr orb ,
		     PortableServer::POA_ptr poa ,
		     PortableServer::ObjectId * contId , 
		     const char *instanceName ,
                     const char *interfaceName ,
                     const bool kactivate, bool withRegistry ) ;

  virtual ~SyrComponent_Impl();

  virtual char* getVersion();

  virtual CORBA::Long C_ISEVEN( CORBA::Long anInteger ) ;

  virtual CORBA::Long C_ISONE( CORBA::Long anOddInteger ) ;

  virtual CORBA::Long C_M3( CORBA::Long anOddInteger ) ;

  virtual CORBA::Long C_M3P1( CORBA::Long anOddInteger ) ;

  virtual CORBA::Long C_DIV2( CORBA::Long anEvenInteger ) ;

  virtual CORBA::Long C_INCR( CORBA::Long aCount ) ;

  virtual void CPP_SETLONG( CORBA::Long aLong ) ;

  virtual CORBA::Long CPP_ADDTOLONG( CORBA::Long anIncr ) ;

  virtual CORBA::Long C_MIN( CORBA::Long aMinVal , CORBA::Long anInteger ) ;

  virtual CORBA::Long C_MAX( CORBA::Long aMaxVal , CORBA::Long anInteger ) ;

  virtual SuperVisionTest::ListOfSyr_ptr C_LISTOFSYR() ;

  virtual SuperVisionTest::ListOfSyr_ptr C_AVERAGE(
                       SuperVisionTest::ListOfSyr_ptr aListOfSyr ,
                       CORBA::Long anInteger ,
                       CORBA::Long aCount ,
                       CORBA::Double & anAverage ) ;

  virtual SuperVisionTest::Syr_ptr Init( CORBA::Long anOddInteger ) ;

private:

  long _Count ;
};

class SYRCOMPONENTENGINE_EXPORT SyrComponent_Impl_No_SSL : public SyrComponent_Impl
{
public:
  SyrComponent_Impl_No_SSL() { }
  SyrComponent_Impl_No_SSL( CORBA::ORB_ptr orb ,
		     PortableServer::POA_ptr poa ,
		     PortableServer::ObjectId * contId , 
		     const char *instanceName , const char *interfaceName , const bool kactivate = true ):SyrComponent_Impl(orb,poa,contId,instanceName,interfaceName,kactivate,true) { }
};

class SYRCOMPONENTENGINE_EXPORT SyrComponent_Impl_SSL : public SyrComponent_Impl
{
public:
  SyrComponent_Impl_SSL() { }
  SyrComponent_Impl_SSL( CORBA::ORB_ptr orb ,
		     PortableServer::POA_ptr poa ,
		     PortableServer::ObjectId * contId , 
		     const char *instanceName , const char *interfaceName , const bool kactivate = true ):SyrComponent_Impl(orb,poa,contId,instanceName,interfaceName,kactivate,false) { }
};

class SYRCOMPONENTENGINE_EXPORT ListOfSyr_Impl :  public POA_SuperVisionTest::ListOfSyr ,
                                                   public Engines_Component_i {
protected:
  ListOfSyr_Impl( CORBA::ORB_ptr orb ,
	          PortableServer::POA_ptr poa ,
	          PortableServer::ObjectId * contId , 
	          const char *instanceName ,
                  const char *interfaceName , 
                  const char * graphName ,
                  const char * nodeName, bool withRegistry ) ;
  ListOfSyr_Impl() ;
public:
  virtual ~ListOfSyr_Impl();

  virtual char* getVersion();

  virtual SuperVisionTest::SeqOfSyr * GetSeqOfSyr() ;

  virtual void SetSeqOfSyr( const SuperVisionTest::SeqOfSyr & ) ;

private:
  SuperVisionTest::SeqOfSyr _SeqOfSyr ;

};

class SYRCOMPONENTENGINE_EXPORT ListOfSyr_Impl_SSL : public ListOfSyr_Impl
{
public:
  ListOfSyr_Impl_SSL( CORBA::ORB_ptr orb ,
	          PortableServer::POA_ptr poa ,
	          PortableServer::ObjectId * contId , 
	          const char *instanceName ,
                  const char *interfaceName , 
                  const char * graphName ,
                  const char * nodeName):ListOfSyr_Impl(orb,poa,contId,instanceName,interfaceName,graphName,nodeName,false) { }
};

class SYRCOMPONENTENGINE_EXPORT ListOfSyr_Impl_No_SSL : public ListOfSyr_Impl
{
public:
  ListOfSyr_Impl_No_SSL( CORBA::ORB_ptr orb ,
	          PortableServer::POA_ptr poa ,
	          PortableServer::ObjectId * contId , 
	          const char *instanceName ,
                  const char *interfaceName , 
                  const char * graphName ,
                  const char * nodeName):ListOfSyr_Impl(orb,poa,contId,instanceName,interfaceName,graphName,nodeName,true) { }
};

extern "C"
  SYRCOMPONENTENGINE_EXPORT
  PortableServer::ObjectId * SyrComponentEngine_factory
                                   ( CORBA::ORB_ptr orb ,
                                     PortableServer::POA_ptr poa , 
                                     PortableServer::ObjectId * contId ,
                                     const char *instanceName ,
                                     const char *interfaceName ) ;

class SYRCOMPONENTENGINE_EXPORT Syr_Impl :  public POA_SuperVisionTest::SyrComponent ,
                                             public SyrComponent_Impl {
public:
  Syr_Impl() ;
  Syr_Impl( CORBA::ORB_ptr orb ,
	    PortableServer::POA_ptr poa ,
	    PortableServer::ObjectId * contId , 
	    const char *instanceName ,
            const char *interfaceName , 
            const char * graphName ,
            const char * nodeName ,
            const CORBA::Long anOddInteger, bool withRegistry);

  virtual ~Syr_Impl();

  virtual CORBA::Long Initial() ;

  virtual CORBA::Long Current() ;

  virtual CORBA::Long IsEven() ;

  virtual CORBA::Long IsOne() ;

  virtual CORBA::Long Count() ;

  virtual void M3p1() ;

  virtual void Div2() ;

  virtual void Incr() ;

private:

  long _InitialInteger ;
  long _CurrentInteger ;
  long _Count ;

};

class SYRCOMPONENTENGINE_EXPORT Syr_Impl_SSL :  public Syr_Impl
{
public:
  Syr_Impl_SSL(CORBA::ORB_ptr orb ,
	    PortableServer::POA_ptr poa ,
	    PortableServer::ObjectId * contId , 
	    const char *instanceName ,
            const char *interfaceName , 
            const char * graphName ,
            const char * nodeName ,
            const CORBA::Long anOddInteger) : Syr_Impl(orb,poa,contId,instanceName,interfaceName,graphName,nodeName,anOddInteger,false) { }
};

class SYRCOMPONENTENGINE_EXPORT Syr_Impl_No_SSL :  public Syr_Impl
{
public:
  Syr_Impl_No_SSL(CORBA::ORB_ptr orb ,
	    PortableServer::POA_ptr poa ,
	    PortableServer::ObjectId * contId , 
	    const char *instanceName ,
            const char *interfaceName , 
            const char * graphName ,
            const char * nodeName ,
            const CORBA::Long anOddInteger) : Syr_Impl(orb,poa,contId,instanceName,interfaceName,graphName,nodeName,anOddInteger,true) { }
};

#endif
