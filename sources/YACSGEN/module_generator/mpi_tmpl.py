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

# cxx file of a MPI component.
# template parameters:
#   component : component name
#   servicesdef : extra "#include"
#   servicesimpl : services implementations
cxxCompo="""
#include "${component}.hxx"
#include <string>
#include <unistd.h>
#include <signal.h>
#include <SALOME_NamingService.hxx>
#include <Utils_SALOME_Exception.hxx>
#include "Utils_CorbaException.hxx"
#include <pthread.h>
#include <execinfo.h>

typedef struct
{
  bool exception;
  std::string msg;
} exception_st;

//DEFS
${servicesdef}
//ENDDEF


using namespace std;

//! Constructor for component "${component}" instance
/*!
 *
 */
${component}_i::${component}_i(CORBA::ORB_ptr orb,
                     PortableServer::POA_ptr poa,
                     PortableServer::ObjectId * contId,
                     const char *instanceName,
                     const char *interfaceName,
                     bool regist)
          : Engines_Component_i(orb, poa, contId, instanceName, interfaceName,
                                false, regist)
{
  _thisObj = this ;
  _id = _poa->activate_object(_thisObj);
}

${component}_i::${component}_i(CORBA::ORB_ptr orb,
                     PortableServer::POA_ptr poa,
                     Engines::Container_ptr container,
                     const char *instanceName,
                     const char *interfaceName,
                     bool regist)
          : Engines_Component_i(orb, poa, container, instanceName, interfaceName,
                                false, regist)
{
  _thisObj = this ;
  _id = _poa->activate_object(_thisObj);
}

//! Destructor for component "${component}" instance
${component}_i::~${component}_i()
{
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
    int is_mpi_container;
    bool regist;
    int numproc;
    
    MPI_Initialized(&is_mpi_container);
    if (!is_mpi_container)
    {
      int argc = 0;
      char ** argv = NULL;
      MPI_Init(&argc, &argv);
    }
    
    MPI_Comm_rank( MPI_COMM_WORLD, &numproc );
    regist = ( numproc == 0 );
    ${component}_i * myEngine = new ${component}_i(orb, poa, contId, instanceName, interfaceName, regist);
    return myEngine->getId() ;
  }
}
"""
cxxCompo=Template(cxxCompo)

# Header file of a MPI component
# template parameters:
#   component : component name
#   module : module name
#   compodefs : additional "#include" and other specific declarations
#   servicesdef : declaration of component services
hxxCompo="""
#ifndef _${component}_HXX_
#define _${component}_HXX_

#include <SALOME_Component.hh>
#include "Superv_Component_i.hxx"
#include "${module}.hh"
#include "MPIObject_i.hxx"

//COMPODEFS
${compodefs}
//ENDDEF

class ${component}_i: public virtual POA_${module}_ORB::${component},
                      ${inheritedclass}
                      public virtual MPIObject_i,
                      public virtual Engines_Component_i
{
  public:
    ${component}_i(CORBA::ORB_ptr orb, PortableServer::POA_ptr poa,
              PortableServer::ObjectId * contId,
              const char *instanceName, const char *interfaceName,
              bool regist = true);
    ${component}_i(CORBA::ORB_ptr orb, PortableServer::POA_ptr poa,
              Engines::Container_ptr container,
              const char *instanceName, const char *interfaceName,
              bool regist = true);
    virtual ~${component}_i();
${servicesdef}
};

extern "C"
{
    PortableServer::ObjectId * ${component}Engine_factory( CORBA::ORB_ptr orb,
                                                      PortableServer::POA_ptr poa,
                                                      PortableServer::ObjectId * contId,
                                                      const char *instanceName,
                                                      const char *interfaceName);
}
#endif

"""
hxxCompo=Template(hxxCompo)

# Declaration of the thread function to run a MPI service.
# template parameters:
#   service : name of the service.
#   input_vals : declarations of input ports of the service.
hxxThreadService="""
void * th_${service}(void * s);
typedef struct {
  int ip; // mpi process id
  Engines::IORTab* tior;
  ${input_vals}
} thread_${service}_struct;

"""
hxxThreadService=Template(hxxThreadService)

# Body of a service.
# template parameters:
#   module : module name
#   component : component name
#   service : service name
#   out_vals : declaration of output ports ("type1 name1;\ntype2 name2;")
#   service_call : 
#   in_vals : copy of input ports to thread structure
#   parameters : list of parameters ("type1 name1, type2 name2")
#   body : user body
cxxService="""
void * th_${service}(void * s)
{
  std::ostringstream msg;
  exception_st *est = new exception_st;
  est->exception = false;
  
  thread_${service}_struct *st = (thread_${service}_struct *)s;
  
  try
  {
    ${out_vals}
    ${module}_ORB::${component}_var compo = ${module}_ORB::${component}::_narrow((*(st->tior))[st->ip]);
    compo->${service_call};
  }
  catch(const SALOME::SALOME_Exception &ex)
  {
    est->exception = true;
    est->msg = ex.details.text;
  }
  catch(const CORBA::Exception &ex)
  {
    est->exception = true;
    msg << "CORBA::Exception: " << ex;
    est->msg = msg.str();
  }
  
  delete st;
  return ((void*)est);
}

void ${component}_i::${service}(${parameters})
{
  beginService("${component}_i::${service}");
  void *ret_th;
  pthread_t *th;
  exception_st *est;

  try
    {
      // Run the service in every MPI process
      if(_numproc == 0)
      {
        th = new pthread_t[_nbproc];
        for(int ip=1;ip<_nbproc;ip++)
        {
            thread_${service}_struct *st = new thread_${service}_struct;
            st->ip = ip;
            st->tior = _tior;
            ${in_vals}
            pthread_create(&(th[ip]),NULL,th_${service},(void*)st);
        }
      }
      
//BODY
${body}
//ENDBODY
      if(_numproc == 0)
      {
        for(int ip=1;ip<_nbproc;ip++)
        {
          pthread_join(th[ip],&ret_th);
          est = (exception_st*)ret_th;
          if(est->exception)
          {
              std::ostringstream msg;
              msg << "[" << ip << "] " << est->msg;
              delete est;
              delete[] th;
              THROW_SALOME_CORBA_EXCEPTION(msg.str().c_str(),SALOME::INTERNAL_ERROR);
          }
          delete est;
        }
        delete[] th;
      }
    }
  catch ( const SALOME_Exception & ex)
    {
      THROW_SALOME_CORBA_EXCEPTION(CORBA::string_dup(ex.what()), SALOME::INTERNAL_ERROR);
    }
  catch ( const SALOME::SALOME_Exception & ex)
    {
      throw;
    }
  catch ( const std::exception& ex)
    {
      THROW_SALOME_CORBA_EXCEPTION(CORBA::string_dup(ex.what()), SALOME::INTERNAL_ERROR);
    }
  catch (...)
    {
      THROW_SALOME_CORBA_EXCEPTION("unknown exception", SALOME::INTERNAL_ERROR);
    }
  endService("${component}_i::${service}");
}

"""
cxxService=Template(cxxService)

interface="""
  interface ${component}:${inheritedinterface} Engines::MPIObject, Engines::EngineComponent
  {
${services}
  };
"""
interface=Template(interface)