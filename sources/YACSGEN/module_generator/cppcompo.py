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
from module_generator.yacstypes import corba_rtn_type

try:
  from string import Template
except:
  from module_generator.compat import Template,set

class CPPComponent(Component):
  """
   A :class:`CPPComponent` instance represents a C++ SALOME component with services given as a list of :class:`Service`
   instances with the parameter *services*.

   :param name: gives the name of the component.
   :type name: str
   :param services: the list of services (:class:`Service`) of the component.
   :param kind: If it is given and has the value "exe", the component will be built as a standalone
      component (executable or shell script). The default is to build the component as a dynamic library.
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
   :param calciumextendedinterface: if you want to use the Calcium extended interface for C++ as defined by the header CalciumInterface.hxx
      set this parameter to 1. By default its value is 0 so to not use extended interface. The extended interface requires boost as a dependency.

   For example, the following call defines a standalone component named "mycompo" with one service s1 (it must have been defined before)::

      >>> c1 = module_generator.CPPComponent('mycompo', services=[s1,], kind="exe",
                                             exe_path="./launch.sh")
  """
  def __init__(self, name, services=None, libs=[], rlibs="", includes="", kind="lib",
                     exe_path=None, sources=None, inheritedclass="", compodefs="",
                     idls=None,interfacedefs="",inheritedinterface="",addedmethods="",
                     calciumextendedinterface=0):
    self.exe_path = exe_path
    self.calciumextendedinterface=calciumextendedinterface
    Component.__init__(self, name, services, impl="CPP", libs=libs, rlibs=rlibs,
                             includes=includes, kind=kind, sources=sources,
                             inheritedclass=inheritedclass, compodefs=compodefs, idls=idls,
                             interfacedefs=interfacedefs, inheritedinterface=inheritedinterface,
                             addedmethods=addedmethods)

  def validate(self):
    """ validate component definition parameters"""
    Component.validate(self)
    kinds = ("lib", "exe")
    if self.kind not in kinds:
      raise Invalid("kind must be one of %s for component %s" % (kinds,self.name))

    if self.kind == "exe" :
      if not self.exe_path:
        raise Invalid("exe_path must be defined for component %s" % self.name)

  def targetProperties(self):
    """ define the rpath property of the target using self.rlibs
    return
      string containing the commands to add to cmake
    """
    text=""
    if self.rlibs.strip() :
      text="SET_TARGET_PROPERTIES( %sEngine PROPERTIES INSTALL_RPATH %s)\n" % (self.name, self.rlibs)
    return text

  def libraryName(self):
    """ Name of the target library
    """
    ret=""
    if self.kind == "lib":
      ret = self.name + "Engine"
    elif self.kind == "exe":
      ret = self.name + "Exelib"
    else:
      raise Invalid("Invalid kind of component: %s. Supported kinds are 'lib' and 'exe'" % self.name)
    return ret
    
  def makeCompo(self, gen):
    """generate files for C++ component

       return a dict where key is the file name and value is the file content
    """
    (cmake_text, cmake_vars) = self.additionalLibraries()
    # DSC_libs are needed for datastream ports only
    DSC_libs = """${KERNEL_SalomeDSCContainer}
  ${KERNEL_SalomeDSCSuperv}
  ${KERNEL_SalomeDatastream}
  ${KERNEL_SalomeDSCSupervBasic}
  ${KERNEL_CalciumC}
  """
    cmake_vars = DSC_libs + cmake_vars
    cxxfile = "%s.cxx" % self.name
    hxxfile = "%s.hxx" % self.name
    if self.kind == "exe":
      exe_opt = 1
    else:
      exe_opt = 0
    ret = { cxxfile:self.makecxx(gen, exe_opt),
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
    if self.kind == "exe":
      exe_file = self.name+".exe"
      install_commande = "\nINSTALL(PROGRAMS %s DESTINATION ${SALOME_INSTALL_BINS})\n" % exe_file
      cmakelist_content = cmakelist_content + install_commande
      ret[exe_file] = exeCPP.substitute(compoexe=self.exe_path)
    pass
    
    ret["CMakeLists.txt"] = cmakelist_content
    
    return ret

  def makehxx(self, gen):
    """return a string that is the content of .hxx file
    """
    services = []
    for serv in self.services:
      service = "    %s %s(" % (corba_rtn_type(serv.ret,gen.module.name),serv.name)
      service = service+gen.makeArgs(serv)+");"
      services.append(service)

    if self.addedmethods:
      services.append(self.addedmethods)
    servicesdef = "\n".join(services)

    inheritedclass=self.inheritedclass
    if self.inheritedclass:
      inheritedclass= " public virtual " + self.inheritedclass + ","

    return hxxCompo.substitute(component=self.name, module=gen.module.name,
                               servicesdef=servicesdef, inheritedclass=inheritedclass,
                               compodefs=self.compodefs)

  def makecxx(self, gen, exe=0):
    """return a string that is the content of .cxx file
    """
    services = []
    inits = []
    defs = []
    for serv in self.services:
      defs.append(serv.defs)
      service = cxxService.substitute(component=self.name, service=serv.name,
                                      parameters=gen.makeArgs(serv),
                                      body=serv.body, exe=exe)
      streams = []
      for name, typ, dep in serv.instream:
        streams.append('          create_calcium_port(this,(char *)"%s",(char *)"%s",(char *)"IN",(char *)"%s");'% (name, typ, dep))
      instream = "\n".join(streams)
      streams = []
      for name, typ, dep in serv.outstream:
        streams.append('          create_calcium_port(this,(char *)"%s",(char *)"%s",(char *)"OUT",(char *)"%s");'% (name, typ, dep))
      outstream = "\n".join(streams)

      init = initService.substitute(component=self.name, service=serv.name,
                                    instream=instream, outstream=outstream)
      services.append(service)
      inits.append(init)

    CalciumInterface=""
    if self.calciumextendedinterface:
      CalciumInterface="#include <CalciumInterface.hxx>"

    return cxxCompo.substitute(component=self.name, module=gen.module.name,
                               exe=exe, exe_path=self.exe_path,
                               servicesdef="\n".join(defs),
                               servicesimpl="\n".join(services),
                               initservice='\n'.join(inits),
                               CalciumInterface=CalciumInterface)

