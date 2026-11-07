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

"""
  Module that defines CPPComponent for SALOME components implemented in C++
"""

import os
from module_generator.gener import Component, Invalid
from module_generator.cpp_tmpl import initService, cxxService, hxxCompo, cxxCompo
from module_generator.cpp_tmpl import exeCPP, cmake_src_compo_cpp
from module_generator.yacstypes import corba_rtn_type, corba_in_type
from module_generator import mpi_tmpl
from module_generator.cppcompo import CPPComponent

try:
  from string import Template
except:
  from module_generator.compat import Template,set

class MPIComponent(CPPComponent):
  """
   A :class:`MPIComponent` instance represents a C++ SALOME component with services given as a list of :class:`Service`
   instances with the parameter *services*.

   :param name: gives the name of the component.
   :type name: str
   :param services: the list of services (:class:`Service`) of the component.
   :param kind: For this type of component, "lib" is the unique valid option. The component is built as a dynamic library.
   :param libs: list of the additional libraries. see *Library* class.
      If you want to add "libmylib.so", installed in "/path/to/lib" you should use:
         libs=[Library(name="mylib", path="/path/to/lib")]
      For more advanced features, see the documentation of cmake / FIND_LIBRARY
   :param rlibs: space-separated list specifying the rpath to use in installed targets
   :param includes: additional include directories, separated by spaces.
   :param sources: gives all the external source files to add in the compilation step (list of paths).
   :param exe_path: is only used when kind is "exe" and gives the path to the standalone component.
   :param compodefs: can be used to add extra definition code in the component for example when using a base class
      to define the component class by deriving it (see *inheritedclass* parameter)
   :param inheritedclass: can be used to define a base class for the component. The base class can be defined in external
      source or with the *compodefs* parameter. The value of the *inheritedclass* parameter is the name of the base class.
   :param idls: can be used to add extra idl CORBA interfaces to the component. This parameter must gives a list of idl file
      names that are added into the generated module (idl directory) and compiled with the generated idl of the module.
   :param interfacedefs: can be used to add idl definitions (or includes of idl files) into the generated idl of the module.
   :param inheritedinterface: can be used to make the component inherit an extra idl interface that has been included through
      the *idls* and *interfacedefs* parameters. See the cppgui1 example for how to use these last parameters.
   :param addedmethods: is a C++ specific parameter that can be used to redefine a component method (DumpPython for example). This
      parameter is a string that must contain the definition and implementation code of the method. See the cppgui1 example
      for how to use it.

   For example, the following call defines a standalone component named "mycompo" with one service s1 (it must have been defined before)::

      >>> c1 = module_generator.CPPComponent('mycompo', services=[s1,], kind="exe",
                                             exe_path="./launch.sh")
  """
  def __init__(self, name, services=None, libs=[], rlibs="", includes="", kind="lib",
                     exe_path=None, sources=None, inheritedclass="", compodefs="",
                     idls=None,interfacedefs="",inheritedinterface="",addedmethods=""):
    self.exe_path = exe_path
    Component.__init__(self, name, services, impl="CPP", libs=libs, rlibs=rlibs,
                             includes=includes, kind=kind, sources=sources,
                             inheritedclass=inheritedclass, compodefs=compodefs, idls=idls,
                             interfacedefs=interfacedefs, inheritedinterface=inheritedinterface,
                             addedmethods=addedmethods)

  def validate(self):
    """ validate component definition parameters"""
    Component.validate(self)
    kinds = ("lib")
    if self.kind not in kinds:
      raise Invalid("kind must be one of %s for component %s" % (kinds,self.name))

  def libraryName(self):
    """ Name of the target library
    """
    ret=""
    if self.kind == "lib":
      ret = self.name + "Engine"
    else:
      raise Invalid("Invalid kind of component: %s. Supported kinds are 'lib' and 'exe'" % self.name)
    return ret
    
  def makeCompo(self, gen):
    """generate files for C++ component

       return a dict where key is the file name and value is the file content
    """
    (cmake_text, cmake_vars) = self.additionalLibraries()
    cmake_vars = "${KERNEL_SalomeMPIContainer}\n  " + cmake_vars
    cxxfile = "%s.cxx" % self.name
    hxxfile = "%s.hxx" % self.name
    ret = { cxxfile:self.makecxx(gen),
            hxxfile:self.makehxx(gen)
          }
    sources = " ".join(map(os.path.basename,self.sources))
    cmakelist_content = cmake_src_compo_cpp.substitute(
                        module = gen.module.name,
                        component = self.name,
                        componentlib = self.libraryName(),
                        includes = self.includes,
                        sources = sources,
                        libs = cmake_vars,
                        find_libs = cmake_text,
                        target_properties = self.targetProperties())
    
    ret["CMakeLists.txt"] = cmakelist_content
    
    return ret

  def makeThServiceDeclaration(self, service, module_name):
    inputVals = []
    for port in service.inport:
      name, typ = service.validatePort(port)
      inputVals.append("%s %s;" % (corba_in_type(typ, module_name), name ))
    return mpi_tmpl.hxxThreadService.substitute(service=service.name,
                                       input_vals="\n".join(inputVals))

  def makehxx(self, gen):
    """return a string that is the content of .hxx file
    """
    services = []
    compodefs=self.compodefs
    for serv in self.services:
      service = "    %s %s(" % (corba_rtn_type(serv.ret,gen.module.name),serv.name)
      service = service+gen.makeArgs(serv)+");"
      services.append(service)
      compodefs = compodefs + self.makeThServiceDeclaration(serv,gen.module.name)

    if self.addedmethods:
      services.append(self.addedmethods)
    servicesdef = "\n".join(services)

    inheritedclass=self.inheritedclass
    if self.inheritedclass:
      inheritedclass= " public virtual " + self.inheritedclass + ","

    return mpi_tmpl.hxxCompo.substitute(component=self.name, module=gen.module.name,
                               servicesdef=servicesdef, inheritedclass=inheritedclass,
                               compodefs=compodefs)

  def makecxx(self, gen):
    """return a string that is the content of .cxx file
    """
    services = []
    inits = []
    defs = []
    for serv in self.services:
      defs.append(serv.defs)
      in_vals = []
      out_vals = []
      call_params = []
      for name, typ in serv.inport:
        in_vals.append("st->%s = %s;" % (name, name ))
        call_params.append("st->%s" % name)
        
      for name, typ in serv.outport:
        out_vals.append("%s %s;" % (corba_in_type(typ, gen.module.name), name ))
        call_params.append(name)
      
      service_call = "%s(%s)" % (serv.name, ",".join(call_params))
      
      service = mpi_tmpl.cxxService.substitute(module=gen.module.name,
                                      component=self.name, service=serv.name,
                                      out_vals="\n".join(out_vals),
                                      service_call=service_call,
                                      in_vals="\n".join(in_vals),
                                      parameters=gen.makeArgs(serv),
                                      body=serv.body)
      services.append(service)

    return mpi_tmpl.cxxCompo.substitute(component=self.name,
                               servicesdef="\n".join(defs),
                               servicesimpl="\n".join(services))

  def getIdlInterfaces(self):
    services = self.getIdlServices()
    inheritedinterface=""
    if self.inheritedinterface:
      inheritedinterface=self.inheritedinterface+","
    return mpi_tmpl.interface.substitute(component=self.name,
                                         services="\n".join(services),
                                         inheritedinterface=inheritedinterface)

  def getIdlDefs(self):
    idldefs = """
#include "SALOME_MPIObject.idl"
"""
    if self.interfacedefs:
      idldefs = idldefs + self.interfacedefs
    return idldefs
  
  def additionalLibraries(self):
    cmake_text, cmake_vars = Component.additionalLibraries(self)
    if "MED" in self.getDependentModules():
      cmake_vars = cmake_vars + """
  ${MED_paramedmemcompo}
  ${MED_paramedcouplingcorba}  
"""
    return cmake_text, cmake_vars

