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

"""
  Module that defines PACOComponent for SALOME PaCO++ components implemented in C++
"""
import os
from module_generator.gener import Component, Invalid
from module_generator.paco_tmpl import compoMakefile, hxxCompo, cxxService
from module_generator.paco_tmpl import initService, cxxCompo, paco_sources
from module_generator.paco_tmpl import cxxFactoryDummy, cxxFactoryMpi, cxx_des_parallel_stream
from module_generator.paco_tmpl import hxxparallel_instream, hxxparallel_outstream, hxxinit_ok
from module_generator.paco_tmpl import hxxparallel_instream_init, hxxparallel_outstream_init, cxxService_connect
from module_generator.paco_tmpl import cxx_cons_service, cxx_cons_parallel_outstream, cxx_cons_parallel_instream
from module_generator.cata_tmpl import parallel_interface

class PACOComponent(Component):

  def __init__(self, name, parallel_lib, services=None, libs="", rlibs="", includes="", 
                     kind="lib", exe_path=None, sources=None):
    self.exe_path = exe_path
    self.parallel_lib = parallel_lib
    Component.__init__(self, name, services, impl="PACO", libs=libs, 
                       rlibs=rlibs, includes=includes, kind=kind,
                       sources=sources)
  def validate(self):
    """ validate component definition parameters"""
    Component.validate(self)
    kinds = ("lib")
    if self.kind not in kinds:
      raise Invalid("kind must be one of %s for component %s" % (kinds,self.name))
    parallel_libs = ("dummy", "mpi")
    if self.parallel_lib not in parallel_libs:
      raise Invalid("parallel_lib must be one of %s" % parallel_libs)

  def makeCompo(self, gen):
    """generate files for PaCO++ component
       
       return a dict where key is the file name and value is the content of the file
    """
    cxxfile = "%s.cxx" % self.name
    hxxfile = "%s.hxx" % self.name
    if self.kind == "lib":
      sources = " ".join(map(os.path.basename, self.sources))
      sources += " "
      sources += paco_sources.substitute(module=gen.module.name,
                                         component=self.name)
      return {"Makefile.am":compoMakefile.substitute(module=gen.module.name, 
                                                     component=self.name,
                                                     libs=self.libs, 
                                                     rlibs=self.rlibs,
                                                     sources=sources,
                                                     includes=self.includes),
              cxxfile:self.makecxx(gen), 
              hxxfile:self.makehxx(gen)}

  def makehxx(self, gen):
    """return a string that is the content of .hxx file
    """
    services = []
    parallel_instream = ""
    parallel_outstream = ""
    services_init_ok = ""
    parallelstreamports = ""
    for serv in self.services:
      service = "    void %s(" % serv.name
      service = service+gen.makeArgs(serv)+");"
      services.append(service)
      services_init_ok += hxxinit_ok.substitute(service_name=serv.name)

      # Ajout des ports parallel DataStream
      for name, type in serv.parallel_instream:
        parallel_instream += hxxparallel_instream.substitute(name=name,
                                                             type=type)
      for name, type in serv.parallel_outstream:
        parallel_outstream += hxxparallel_outstream.substitute(name=name,
                                                               type=type)
    servicesdef = "\n".join(services)
    parallelstreamports += parallel_instream
    parallelstreamports += parallel_outstream
    return hxxCompo.substitute(component=self.name, 
                               module=gen.module.name, 
                               servicesdef=servicesdef,
                               services_init_ok=services_init_ok,
                               parallelstreamports=parallelstreamports,
                               parallel_lib=self.parallel_lib)

  def makecxx(self, gen):
    """return a string that is the content of .cxx file
    """
    services = []
    inits = []
    defs = []
    cons_services = ""
    des_services = ""
    for serv in self.services:
      defs.append(serv.defs)
    
      # Constructeur
      cons_services += cxx_cons_service.substitute(service_name=serv.name)
      for name, type in serv.parallel_instream:
        cons_services += cxx_cons_parallel_instream.substitute(name=name)
      for name, type in serv.parallel_outstream:
        cons_services += cxx_cons_parallel_outstream.substitute(name=name)

      # Destructeur  
      # On détruit uniquement les ports uses
      # Les ports provides sont détruit lors de la destruction du poa
      for name, type in serv.parallel_outstream:
        des_services += cxx_des_parallel_stream.substitute(name=name)

      # init_service
      init_parallel_datastream_ports=""
      for name, type in serv.parallel_instream:
        init_parallel_datastream_ports += hxxparallel_instream_init.substitute(name=name,
                                                                               type=type)
      for name, type in serv.parallel_outstream:
        init_parallel_datastream_ports += hxxparallel_outstream_init.substitute(name=name,
                                                                                type=type)
      init = initService.substitute(service_name=serv.name,
                                    init_parallel_datastream_ports=init_parallel_datastream_ports)
      inits.append(init)

      # Code du service
      connect_parallel_streamport = ""
      for name, type in serv.parallel_outstream:
        connect_parallel_streamport += cxxService_connect.substitute(name=name)

      service = cxxService.substitute(component=self.name, service=serv.name, 
                                      parameters=gen.makeArgs(serv),
                                      body=serv.body,
                                      connect_parallel_streamport=connect_parallel_streamport)
      services.append(service)
    
    cxxfile = cxxCompo.substitute(component=self.name, module=gen.module.name, 
                                  servicesdef="\n".join(defs), 
                                  servicesimpl="\n".join(services), 
                                  initservice='\n'.join(inits),
                                  cons_services=cons_services,
                                  des_services=des_services)

    if self.parallel_lib == "dummy":
      cxxfile += cxxFactoryDummy.substitute(component=self.name, module=gen.module.name)
    elif self.parallel_lib == "mpi":
      cxxfile += cxxFactoryMpi.substitute(component=self.name, module=gen.module.name)

    return cxxfile

  def getIdlServices(self):
    services = []
    for serv in self.services:
      params = []
      for name, typ in serv.inport:
        if typ == "file":continue #files are not passed through IDL interface
        params.append("in %s %s" % (idlTypes[typ], name))
      for name, typ in serv.outport:
        if typ == "file":continue #files are not passed through IDL interface
        params.append("out %s %s" % (idlTypes[typ], name))
      service = "    void %s(" % serv.name
      service = service+",".join(params)+");"
      services.append(service)
    return services

  def getIdlInterfaces(self):
    services = self.getIdlServices()
    return parallel_interface.substitute(component=self.name, services="\n".join(services))

  def getIdlDefs(self):
    idldefs = """
#include "SALOME_PACOExtension.idl"
"""
    if self.interfacedefs:
      idldefs = idldefs + self.interfacedefs
    return idldefs
