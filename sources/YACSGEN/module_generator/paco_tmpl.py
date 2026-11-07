#!/usr/bin/env python
# -*- coding: utf-8 *-
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

#  Author : Andre RIBES (EDF R&D)

try:
  from string import Template
except:
  from module_generator.compat import Template,set
  
compoMakefile="""
include $$(top_srcdir)/adm_local/make_common_starter.am

BUILT_SOURCES = SALOME_Exception.hxx SALOME_GenericObj.hxx SALOMEDS.hxx SALOME_PyNode.hxx SALOME_Comm.hxx SALOME_Parametric.hxx

%.hxx : @KERNEL_ROOT_DIR@/idl/salome/%.idl
\t$$(OMNIORB_IDL) -bcxx $$(IDLCXXFLAGS) $$(OMNIORB_IDLCXXFLAGS) $$(IDL_INCLUDES) -I@KERNEL_ROOT_DIR@/idl/salome -Wbh=.hxx -Wbs=.cxx $$<

AM_CFLAGS=$$(KERNEL_INCLUDES) $$(PACO_INCLUDES) -fexceptions

lib_LTLIBRARIES = lib${component}Engine.la
lib${component}Engine_la_SOURCES      = ${component}.cxx ${sources}
nodist_lib${component}Engine_la_SOURCES =
lib${component}Engine_la_CXXFLAGS = -I$$(top_builddir)/idl $$(SALOME_INCLUDES) $$(PACO_INCLUDES) $$(MPI_INCLUDES) ${includes}
lib${component}Engine_la_LIBADD   = -L$$(top_builddir)/idl -lSalomeIDL${module} @KERNEL_ROOT_DIR@/lib/salome/libSalomeParallelDSCContainer.la @PACOPATH@/lib/libPaCO_direct_comScheduling.la $$(FLIBS) ${libs} $$(PACO_LIBS) $$(SALOME_LIBS)
lib${component}Engine_la_LDFLAGS = ${rlibs}
salomeinclude_HEADERS = ${component}.hxx
"""
compoMakefile=Template(compoMakefile)

paco_sources = """\
$$(top_builddir)/idl/${module}PaCO_${module}_ORB_${component}_client.cxx $$(top_builddir)/idl/${module}PaCO_${module}_ORB_${component}_server.cxx $$(top_builddir)/idl/${module}PaCO.cxx $$(top_builddir)/idl/${module}.cxx
"""
paco_sources = Template(paco_sources)

hxxCompo="""
#ifndef _${component}_HXX_
#define _${component}_HXX_

#include "${module}PaCO_${module}_ORB_${component}_server.hxx"
#include "ParallelDSC_i.hxx"
#include "Param_Double_Port_uses_i.hxx"
#include "Param_Double_Port_provides_i.hxx"

#include "PortProperties_i.hxx"
#include <Utils_SALOME_Exception.hxx>
#include <paco_omni.h>
#include <paco_${parallel_lib}.h>
#include <paco_dummy.h>

class ${component}_i:
  public virtual ${module}_ORB::${component}_serv,
  public virtual Engines_ParallelDSC_i
{
  public:
    ${component}_i(CORBA::ORB_ptr orb,
                   char * ior,
                   int rank,
                   PortableServer::POA_ptr poa,
                   PortableServer::ObjectId * contId, 
                   const char *instanceName, 
                   const char *interfaceName);

    virtual ~${component}_i();

    void provides_port_changed(const char* provides_port_name,
			       int connection_nbr,
			       const Engines::DSC::Message message) {}

    void uses_port_changed(const char* uses_port_name,
			   Engines::DSC::uses_port * new_uses_port,
			   const Engines::DSC::Message message) {delete new_uses_port;}

    CORBA::Boolean init_service(const char * service_name);

${servicesdef}
 private:
   PortProperties_i *  _fake_properties;
${services_init_ok} 
${parallelstreamports}
};

extern "C"
{
  PortableServer::ObjectId * ${component}Engine_factory(CORBA::ORB_ptr orb,
                                                        char * ior,
                                                        int rank,
                                                        PortableServer::POA_ptr poa,
                                                        PortableServer::ObjectId * contId,
                                                        const char *instanceName,
                                                        const char *interfaceName);

  PortableServer::ObjectId * ${component}EngineProxy_factory(CORBA::ORB_ptr orb,
                                                             paco_fabrique_thread * fab_thread,
                                                             PortableServer::POA_ptr poa,
                                                             PortableServer::ObjectId * contId,
                                                             RegistryConnexion **,
                                                             const char *instanceName,
                                                             int node_number);
  void ${component}_isAPACO_Component() {};                                                             
}
#endif

"""
hxxCompo=Template(hxxCompo)

hxxinit_ok = """\
   bool _${service_name}_init_ok;"""
hxxinit_ok = Template(hxxinit_ok)

hxxparallel_outstream = """\
   ${type}_uses_i * _${name}_port;
   bool _${name}_port_start_ok;"""
hxxparallel_outstream = Template(hxxparallel_outstream)

hxxparallel_instream = """\
   ${type}_provides_i * _${name}_port;"""
hxxparallel_instream = Template(hxxparallel_instream)

cxxCompo="""
#include "${component}.hxx"
#include <string>

//DEFS
${servicesdef}
//ENDDEF

//! Constructor for component "${component}" instance
/*!
 *
 */
${component}_i::${component}_i(CORBA::ORB_ptr orb,
		               char * ior,
                               int rank,
                               PortableServer::POA_ptr poa,
                               PortableServer::ObjectId * contId, 
                               const char *instanceName, 
                               const char *interfaceName) :
  ${module}_ORB::${component}_serv(orb, ior, rank),
  ${module}_ORB::${component}_base_serv(orb, ior, rank),
  Engines_ParallelDSC_i(orb, ior, rank, poa, contId, instanceName, interfaceName),
  Engines_Parallel_Component_i(orb, ior, rank, poa, contId, instanceName, interfaceName),
  Engines::Parallel_DSC_serv(orb, ior, rank),
  InterfaceParallel_impl(orb,ior, rank),
  Engines::Superv_Component_serv(orb, ior, rank),
  Engines::DSC_serv(orb, ior, rank), 
  Engines::EngineComponent_serv(orb,ior, rank), 
  Engines::Parallel_Component_serv(orb,ior, rank), 
  Engines::Parallel_DSC_base_serv(orb, ior, rank),
  Engines::Superv_Component_base_serv(orb, ior, rank),
  Engines::DSC_base_serv(orb, ior, rank), 
  Engines::EngineComponent_base_serv(orb,ior, rank), 
  Engines::Parallel_Component_base_serv(orb,ior, rank) 

{
  std::cerr << "creating paralle component" << std::endl;
  _thisObj = this ;
  _id = _poa->activate_object(_thisObj);
${cons_services}  
}

//! Destructor for component "${component}" instance
${component}_i::~${component}_i()
{
${des_services}  
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
"""
cxxCompo=Template(cxxCompo)

cxx_cons_service = """\
  _${service_name}_init_ok = false;
"""
cxx_cons_service = Template(cxx_cons_service)

cxx_cons_parallel_outstream = """\
  _${name}_port = NULL;
  _${name}_port_start_ok = false;
"""
cxx_cons_parallel_outstream = Template(cxx_cons_parallel_outstream)

cxx_cons_parallel_instream = """\
  _${name}_port = NULL;
"""
cxx_cons_parallel_instream = Template(cxx_cons_parallel_instream)

cxx_des_parallel_stream = """\
  if (_${name}_port)
    delete _${name}_port;
"""
cxx_des_parallel_stream = Template(cxx_des_parallel_stream)

initService="""\
  if (s_name == "${service_name}")
  {
    if (!_${service_name}_init_ok)
    {
${init_parallel_datastream_ports}
      _${service_name}_init_ok = true;
    }
    rtn = true;
  }
"""
initService=Template(initService)

hxxparallel_outstream_init = """\
      _${name}_port = new ${type}_uses_i(this, \"${name}\", _orb);
      _${name}_port->add_port_to_component();
"""
hxxparallel_outstream_init = Template(hxxparallel_outstream_init)

hxxparallel_instream_init = """\
      _${name}_port = ${type}_provides_i::init_port(this, \"${name}\", _orb);
      ${type}_provides_i::wait_init_port(this, \"${name}\", _orb);
"""
hxxparallel_instream_init = Template(hxxparallel_instream_init)

cxxService="""
void ${component}_i::${service}(${parameters})
{
  std::cerr << "Begin of ${component}_i::${service} of node " << _myRank << std::endl;
  if (_myRank == 0)
    beginService("${component}_i::${service}");
${connect_parallel_streamport}
  try
    {
//BODY
${body}
//ENDBODY
    }
  catch ( const SALOME_Exception & ex)
    {
      SALOME::ExceptionStruct es;
      es.text=CORBA::string_dup(ex.what());
      es.type=SALOME::INTERNAL_ERROR;
      throw SALOME::SALOME_Exception(es);
    }
  catch ( const SALOME::SALOME_Exception & ex)
    {
      throw;
    }
  catch ( const std::exception& ex)
    {
      SALOME::ExceptionStruct es;
      es.text=CORBA::string_dup(ex.what());
      es.type=SALOME::INTERNAL_ERROR;
      throw SALOME::SALOME_Exception(es);
    }
  catch (...)
    {
      std::cerr << "unknown exception" << std::endl;
      SALOME::ExceptionStruct es;
      es.text=CORBA::string_dup(" unknown exception");
      es.type=SALOME::INTERNAL_ERROR;
      throw SALOME::SALOME_Exception(es);
    }
  if (_myRank == 0)
    endService("${component}_i::${service}");
  std::cerr << "End of ${component}_i::${service} of node " << _myRank << std::endl;
}

"""
cxxService=Template(cxxService)

cxxService_connect = """\
  if (!_${name}_port_start_ok)
  {
    _${name}_port->start_port();
    _${name}_port_start_ok = true;
  }
"""
cxxService_connect = Template(cxxService_connect)

cxxFactoryDummy = """
extern "C"
{
  PortableServer::ObjectId * ${component}Engine_factory(CORBA::ORB_ptr orb, char * ior, int rank,
							PortableServer::POA_ptr poa, 
                                                        PortableServer::ObjectId * contId,
                                                        const char *instanceName, 
                                                        const char *interfaceName)
  {
    std::cerr << "Begin of ${component}Engine_factory()" << std::endl;

    paco_fabrique_manager * pfm = paco_getFabriqueManager();
    pfm->register_com("${component}_node_dummy", new paco_dummy_fabrique());
    pfm->register_thread("${component}_node_omni", new paco_omni_fabrique());
    ${component}_i * ${component}_node = new ${component}_i(CORBA::ORB::_duplicate(orb), ior, rank, poa, contId, instanceName, interfaceName);
    ${component}_node->setLibCom("${component}_node_dummy", ${component}_node);
    ${component}_node->setLibThread("${component}_node_omni");

    std::cerr << "End of ${component}Engine_factory()" << std::endl;
    return ${component}_node->getId();
  }

  PortableServer::ObjectId * ${component}EngineProxy_factory(CORBA::ORB_ptr orb, 
							     paco_fabrique_thread * fab_thread,
                                                             PortableServer::POA_ptr poa,
                                                             PortableServer::ObjectId * contId,
                                                             RegistryConnexion ** connexion,
                                                             const char *instanceName,
                                                             int node_number)
  {
    cerr << "Begin of ${component}EngineProxy_factory()" << endl;
    
    paco_fabrique_manager* pfm = paco_getFabriqueManager();
    pfm->register_com("proxy_dummy", new paco_dummy_fabrique());
    pfm->register_thread("proxy_thread", new paco_omni_fabrique());
    ${module}_ORB::${component}_proxy_impl * proxy = new ${module}_ORB::${component}_proxy_impl(CORBA::ORB::_duplicate(orb),
                                                                                        fab_thread);
    PortableServer::ObjectId * id = poa->activate_object(proxy);
    proxy->_remove_ref();
    // Initialisation du proxy
    proxy->setLibCom("proxy_dummy", proxy);
    proxy->setLibThread("proxy_thread");
    PaCO::PacoTopology_t serveur_topo;
    serveur_topo.total = node_number;
    proxy->setTopology(serveur_topo);

    // Ajout dans le registry ...
    CORBA::Object_var o = poa->id_to_reference(*contId); // container ior...  
    const CORBA::String_var the_ior = orb->object_to_string(o);
    *connexion = new RegistryConnexion(0, 0, the_ior, "theSession", instanceName);

    cerr << "End of ${component}EngineProxy_factory()" << endl;
    return id;
  }
}
"""
cxxFactoryDummy = Template(cxxFactoryDummy)

cxxFactoryMpi = """
extern "C"
{
  PortableServer::ObjectId * ${component}Engine_factory(CORBA::ORB_ptr orb, char * ior, int rank,
							PortableServer::POA_ptr poa, 
                                                        PortableServer::ObjectId * contId,
                                                        const char *instanceName, 
                                                        const char *interfaceName)
  {
    std::cerr << "Begin of ${component}Engine_factory()" << std::endl;

    paco_fabrique_manager * pfm = paco_getFabriqueManager();
    pfm->register_com("${component}_node_mpi", new paco_mpi_fabrique());
    pfm->register_thread("${component}_node_omni", new paco_omni_fabrique());
    ${component}_i * ${component}_node = new ${component}_i(CORBA::ORB::_duplicate(orb), ior, rank, poa, contId, instanceName, interfaceName);
    MPI_Comm parallel_object_group = MPI_COMM_WORLD;
    ${component}_node->setLibCom("${component}_node_mpi", &parallel_object_group);
    ${component}_node->setLibThread("${component}_node_omni");

    std::cerr << "End of ${component}Engine_factory()" << std::endl;
    return ${component}_node->getId();
  }

  PortableServer::ObjectId * ${component}EngineProxy_factory(CORBA::ORB_ptr orb, 
							     paco_fabrique_thread * fab_thread,
                                                             PortableServer::POA_ptr poa,
                                                             PortableServer::ObjectId * contId,
                                                             RegistryConnexion ** connexion,
                                                             const char *instanceName,
                                                             int node_number)
  {
    cerr << "Begin of ${component}EngineProxy_factory()" << endl;
    
    paco_fabrique_manager* pfm = paco_getFabriqueManager();
    pfm->register_com("proxy_dummy", new paco_dummy_fabrique());
    pfm->register_thread("proxy_thread", new paco_omni_fabrique());
    ${module}_ORB::${component}_proxy_impl * proxy = new ${module}_ORB::${component}_proxy_impl(CORBA::ORB::_duplicate(orb),
                                                                                        fab_thread);
    PortableServer::ObjectId * id = poa->activate_object(proxy);
    proxy->_remove_ref();
    // Initialisation du proxy
    proxy->setLibCom("proxy_dummy", proxy);
    proxy->setLibThread("proxy_thread");
    PaCO::PacoTopology_t serveur_topo;
    serveur_topo.total = node_number;
    proxy->setTopology(serveur_topo);

    // Ajout dans le registry ...
    CORBA::Object_var o = poa->id_to_reference(*contId); // container ior...  
    const CORBA::String_var the_ior = orb->object_to_string(o);
    *connexion = new RegistryConnexion(0, 0, the_ior, "theSession", instanceName);

    cerr << "End of ${component}EngineProxy_factory()" << endl;
    return id;
  }
}
"""
cxxFactoryMpi = Template(cxxFactoryMpi)
