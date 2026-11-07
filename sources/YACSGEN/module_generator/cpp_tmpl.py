# Copyright (C) 2009-2026  EDF
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
#
# See http://www.salome-platform.org/ or email : webmaster.salome@opencascade.com
#

try:
  from string import Template
except:
  from module_generator.compat import Template,set

cxxCompo="""
#include "${component}.hxx"
#include <string>
#include <unistd.h>

#include <Calcium.hxx>
#include <CalciumException.hxx>
${CalciumInterface}
#include <signal.h>
#include <SALOME_Embedded_NamingService_Client.hxx>
#include <SALOME_NamingService.hxx>
#include <Utils_SALOME_Exception.hxx>
#include <pthread.h>
#include <execinfo.h>

#define BUILD_EXE ${exe}

typedef void (*sighandler_t)(int);
sighandler_t setsig(int sig, sighandler_t handler)
{
  struct sigaction context, ocontext;
  context.sa_handler = handler;
  sigemptyset(&context.sa_mask);
  context.sa_flags = 0;
  if (sigaction(sig, &context, &ocontext) == -1)
    return SIG_ERR;
  return ocontext.sa_handler;
}

static void AttachDebugger()
{
  void *array[20];
  size_t size=20;
  char **strings;
  size_t i;
  std::string _what;
  size = backtrace (array, size);
  strings = backtrace_symbols (array, size);
  for (i = 0; i < size; i++)
     _what=_what+strings[i]+ '\\n';
  free (strings);

  std::cerr << pthread_self() << std::endl;
  std::cerr << _what << std::endl;

  if(getenv ("DEBUGGER"))
    {
      std::stringstream exec;
#if BUILD_EXE
      exec << "$$DEBUGGER " << "${exe_path} " << getpid() << "&";
#else
      exec << "$$DEBUGGER SALOME_Container " << getpid() << "&";
#endif
      std::cerr << exec.str() << std::endl;
      system(exec.str().c_str());
      while(1);
    }
}

static void THandler(int theSigId)
{
  std::cerr << "SIGSEGV: "  << std::endl;
  AttachDebugger();
  //to exit or not to exit
  _exit(1);
}

static void terminateHandler(void)
{
  std::cerr << "Terminate: not managed exception !"  << std::endl;
  AttachDebugger();
  throw SALOME_Exception("Terminate: not managed exception !");
}

static void unexpectedHandler(void)
{
  std::cerr << "Unexpected: unexpected exception !"  << std::endl;
  AttachDebugger();
  throw SALOME_Exception("Unexpected: unexpected exception !");
}


#define  _(A,B)   A##B
#ifdef _WIN32
#define F_FUNC(lname,uname) __stdcall uname
#define F_CALL(lname,uname) uname
#define STR_PSTR(str)       char *str, int _(Len,str)
#define STR_PLEN(str)
#define STR_PTR(str)        str
#define STR_LEN(str)        _(Len,str)
#define STR_CPTR(str)        str,strlen(str)
#define STR_CLEN(str)
#else
#define F_FUNC(lname,uname) _(lname,_)        /* Fortran function name */
#define F_CALL(lname,uname) _(lname,_)        /* Fortran function call */
#define STR_PSTR(str)       char *str         /* fortran string arg pointer */
#define STR_PLEN(str)       , int _(Len,str)  /* fortran string arg length */
#define STR_PTR(str)        str               /* fortran string pointer */
#define STR_LEN(str)        _(Len,str)        /* fortran string length */
#define STR_CPTR(str)        str              /* fortran string calling arg pointer */
#define STR_CLEN(str)       , strlen(str)     /* fortran string calling arg length */
#endif

//DEFS
${servicesdef}
//ENDDEF

#include <calcium.h>

extern "C" void cp_exit(int err);

extern "C" void F_FUNC(cpexit,CPEXIT)(int *err)
{
  if(*err==-1)
    _exit(-1);
  else
    cp_exit(*err);
}

using namespace std;

//! Constructor for component "${component}" instance
/*!
 *
 */
${component}_i::${component}_i(CORBA::ORB_ptr orb,
                     PortableServer::POA_ptr poa,
                     PortableServer::ObjectId * contId,
                     const char *instanceName,
                     const char *interfaceName)
          : Superv_Component_i(orb, poa, contId, instanceName, interfaceName)
{
#if BUILD_EXE
  setsig(SIGSEGV,&THandler);
  set_terminate(&terminateHandler);
  set_unexpected(&unexpectedHandler);
#endif
  _thisObj = this ;
  _id = _poa->activate_object(_thisObj);
}

${component}_i::${component}_i(CORBA::ORB_ptr orb,
                     PortableServer::POA_ptr poa,
                     Engines::Container_ptr container,
                     const char *instanceName,
                     const char *interfaceName)
          : Superv_Component_i(orb, poa, container, instanceName, interfaceName)
{
#if BUILD_EXE
  setsig(SIGSEGV,&THandler);
  set_terminate(&terminateHandler);
  set_unexpected(&unexpectedHandler);
#endif
  _thisObj = this ;
  _id = _poa->activate_object(_thisObj);
}

//! Destructor for component "${component}" instance
${component}_i::~${component}_i()
{
}

void ${component}_i::destroy()
{
#if BUILD_EXE
  _remove_ref();
  if(!CORBA::is_nil(_orb))
    _orb->shutdown(0);
#else
  Engines_Component_i::destroy();
#endif
}

//! Register datastream ports for a component service given its name
/*!
 *  \param service_name : service name
 *  \\return true if port registering succeeded, false if not
 */
CORBA::Boolean
${component}_i::init_service(const char * service_name) {
  CORBA::Boolean rtn = false;
  string s_name(service_name);
${initservice}
  return rtn;
}

${servicesimpl}

extern "C"
{
  PortableServer::ObjectId * ${component}Engine_factory( CORBA::ORB_ptr orb,
                                                    PortableServer::POA_ptr poa,
                                                    PortableServer::ObjectId * contId,
                                                    const char *instanceName,
                                                    const char *interfaceName)
  {
    MESSAGE("PortableServer::ObjectId * ${component}Engine_factory()");
    ${component}_i * myEngine = new ${component}_i(orb, poa, contId, instanceName, interfaceName);
    return myEngine->getId() ;
  }
  void yacsinit()
  {
    int argc=0;
    char *argv=0;
    CORBA::ORB_var orb = CORBA::ORB_init( argc , &argv ) ;
    PortableServer::POAManager_var pman;
    CORBA::Object_var obj;
    try
      {
        obj = orb->resolve_initial_references("RootPOA");
        PortableServer::POA_var  poa = PortableServer::POA::_narrow(obj);
        PortableServer::POAManager_var pman = poa->the_POAManager();
        std::string containerName(getenv("SALOME_CONTAINERNAME"));
        std::string instanceName(getenv("SALOME_INSTANCE"));
        obj=orb->string_to_object(getenv("SALOME_CONTAINER"));
        Engines::Container_var container = Engines::Container::_narrow(obj);
        ${component}_i * myEngine = new ${component}_i(orb, poa, container, instanceName.c_str(), "${component}");
        pman->activate();
        obj=myEngine->POA_${module}_ORB::${component}::_this();
        Engines::EngineComponent_var component = Engines::EngineComponent::_narrow(obj);
        string component_registerName = containerName + "/" + instanceName;
        Engines::EmbeddedNamingService_var embedded_NS = container->get_embedded_NS_if_ssl();
        if( CORBA::is_nil(embedded_NS))
        {
          // Use the salome session to get the naming service
          SALOME_NamingService salome_NS(orb);
          salome_NS.Register(component,component_registerName.c_str());
        }
        else
        {
          SALOME_Embedded_NamingService_Client ns_client(embedded_NS);
          ns_client.Register(component,component_registerName.c_str());
        }
        orb->run();
        orb->destroy();
      }
    catch(CORBA::Exception&)
      {
        std::cerr << "Caught CORBA::Exception."<< std::endl;
      }
    catch(std::exception& exc)
      {
        std::cerr << "Caught std::exception - "<<exc.what() << std::endl;
      }
    catch(...)
      {
        std::cerr << "Caught unknown exception." << std::endl;
      }
  }

  void F_FUNC(yacsinit,YACSINIT)()
  {
    yacsinit();
  }
}
"""
cxxCompo=Template(cxxCompo)

hxxCompo="""
#ifndef _${component}_HXX_
#define _${component}_HXX_

#include <SALOME_Component.hh>
#include "Superv_Component_i.hxx"
#include "${module}.hh"

//COMPODEFS
${compodefs}
//ENDDEF

class ${component}_i: public virtual POA_${module}_ORB::${component},
                      ${inheritedclass} public virtual Superv_Component_i
{
  public:
    ${component}_i(CORBA::ORB_ptr orb, PortableServer::POA_ptr poa,
              PortableServer::ObjectId * contId,
              const char *instanceName, const char *interfaceName);
    ${component}_i(CORBA::ORB_ptr orb, PortableServer::POA_ptr poa,
              Engines::Container_ptr container,
              const char *instanceName, const char *interfaceName);
    virtual ~${component}_i();
    void destroy();
    CORBA::Boolean init_service(const char * service_name);
${servicesdef}
};

extern "C"
{
    PortableServer::ObjectId * ${component}Engine_factory( CORBA::ORB_ptr orb,
                                                      PortableServer::POA_ptr poa,
                                                      PortableServer::ObjectId * contId,
                                                      const char *instanceName,
                                                      const char *interfaceName);
    void yacsinit();
}
#endif

"""
hxxCompo=Template(hxxCompo)

cxxService="""
void ${component}_i::${service}(${parameters})
{
  beginService("${component}_i::${service}");
  Superv_Component_i * component = dynamic_cast<Superv_Component_i*>(this);
  //char       nom_instance[INSTANCE_LEN];
  //int info = cp_cd(component,nom_instance);
  try
    {
//BODY
${body}
//ENDBODY
      //cp_fin(component,CP_ARRET);
    }
  catch ( const CalciumException & ex)
    {
      std::cerr << ex.what() << std::endl;
      //cp_fin(component,CP_ARRET);
      SALOME::ExceptionStruct es;
      es.text=CORBA::string_dup(ex.what());
      es.type=SALOME::INTERNAL_ERROR;
      throw SALOME::SALOME_Exception(es);
    }
  catch ( const SALOME_Exception & ex)
    {
      //cp_fin(component,CP_ARRET);
      SALOME::ExceptionStruct es;
      es.text=CORBA::string_dup(ex.what());
      es.type=SALOME::INTERNAL_ERROR;
      throw SALOME::SALOME_Exception(es);
    }
  catch ( const SALOME::SALOME_Exception & ex)
    {
      //cp_fin(component,CP_ARRET);
      throw;
    }
  catch ( const std::exception& ex)
    {
      //std::cerr << typeid(ex).name() << std::endl;
      SALOME::ExceptionStruct es;
      es.text=CORBA::string_dup(ex.what());
      es.type=SALOME::INTERNAL_ERROR;
      throw SALOME::SALOME_Exception(es);
    }
  catch (...)
    {
      std::cerr << "unknown exception" << std::endl;
#if BUILD_EXE
      _exit(-1);
#endif
      //cp_fin(component,CP_ARRET);
      SALOME::ExceptionStruct es;
      es.text=CORBA::string_dup(" unknown exception");
      es.type=SALOME::INTERNAL_ERROR;
      throw SALOME::SALOME_Exception(es);
    }
  endService("${component}_i::${service}");
}

"""
cxxService=Template(cxxService)

initService="""
  if (s_name == "${service}")
    {
      try
        {
          //initialization CALCIUM ports IN
${instream}
          //initialization CALCIUM ports OUT
${outstream}
        }
      catch(const PortAlreadyDefined& ex)
        {
          std::cerr << "${component}: " << ex.what() << std::endl;
          //Ports already created : we use them
        }
      catch ( ... )
        {
          std::cerr << "${component}: unknown exception" << std::endl;
        }
      rtn = true;
    }
"""
initService=Template(initService)

exeCPP="""#!/bin/sh

export SALOME_CONTAINER=$$1
export SALOME_CONTAINERNAME=$$2
export SALOME_INSTANCE=$$3

${compoexe}
"""
exeCPP=Template(exeCPP)

# Makefile

# CMakeLists.txt in src/<component>
# template parameters:
#   module : module name
#   component : component name
#   componentlib : name of the target library
#   includes : additional headers, separated by spaces or \n. can be empty
#   sources : additional sources, separated by spaces or \n. can be empty
#   libs : additional libraries
#   find_libs : find_library commands
#   target_properties : set_target_properties commands
cmake_src_compo_cpp = """
# --- options ---
# additional include directories
INCLUDE_DIRECTORIES(
  $${KERNEL_INCLUDE_DIRS}
  $${OMNIORB_INCLUDE_DIR}
  $${PROJECT_BINARY_DIR}
  $${PROJECT_BINARY_DIR}/idl
  ${includes}
)

# --- definitions ---
ADD_DEFINITIONS(
  $${OMNIORB_DEFINITIONS}
)

# find additional libraries
${find_libs}

# libraries to link to
SET(_link_LIBRARIES
  $${OMNIORB_LIBRARIES}
  $${KERNEL_SalomeIDLKernel}
  $${KERNEL_OpUtil}
  $${KERNEL_SalomeContainer}
  SalomeIDL${module}
  ${libs}
)

# --- headers ---

# header files / no moc processing

SET(${module}_HEADERS
  ${component}.hxx
)

# --- sources ---

# sources / static
SET(${module}_SOURCES
  ${component}.cxx
  ${sources}
)

# --- rules ---

ADD_LIBRARY(${componentlib} $${${module}_SOURCES})
TARGET_LINK_LIBRARIES(${componentlib} $${_link_LIBRARIES} )
${target_properties}
INSTALL(TARGETS ${componentlib} EXPORT $${PROJECT_NAME}TargetGroup DESTINATION $${SALOME_INSTALL_LIBS})

INSTALL(FILES $${${module}_HEADERS} DESTINATION $${SALOME_INSTALL_HEADERS})
"""
cmake_src_compo_cpp = Template(cmake_src_compo_cpp)
