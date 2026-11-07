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

import os, shutil, glob, socket
import traceback
import warnings

try:
  from string import Template
except:
  from module_generator.compat import Template, set

class Invalid(Exception):
  pass

debug=0

from module_generator.mod_tmpl import *
from module_generator.cata_tmpl import catalog, interface, idl
from module_generator.cata_tmpl import xml, xml_interface, xml_service
from module_generator.cata_tmpl import idlMakefilePaCO_BUILT_SOURCES, idlMakefilePaCO_nodist_salomeinclude_HEADERS
from module_generator.cata_tmpl import idlMakefilePACO_salomepython_DATA, idlMakefilePACO_salomeidl_DATA
from module_generator.cata_tmpl import idlMakefilePACO_INCLUDES
from module_generator.cata_tmpl import cataOutStream, cataInStream, cataOutparam, cataInparam
from module_generator.cata_tmpl import cataOutParallelStream, cataInParallelStream
from module_generator.cata_tmpl import cataService, cataCompo
#from aster_tmpl import check_aster
from module_generator.salomemodules import salome_modules
from module_generator.yacstypes import corbaTypes, corbaOutTypes, moduleTypes, idlTypes, corba_in_type, corba_out_type
from module_generator.yacstypes import ValidTypes, PyValidTypes, calciumTypes, DatastreamParallelTypes
from module_generator.yacstypes import ValidImpl, ValidImplTypes, ValidStreamTypes, ValidParallelStreamTypes, ValidDependencies
from module_generator.gui_tmpl import cmake_py_gui, pysalomeapp, cmake_cpp_gui, cppsalomeapp
from module_generator.doc_tmpl import docmakefile, docconf, docsalomeapp
from module_generator import yacsgen_version

def makedirs(namedir):
  """Create a new directory named namedir. If a directory already exists copy it to namedir.bak"""
  if os.path.exists(namedir):
    dirbak = namedir+".bak"
    if os.path.exists(dirbak):
      shutil.rmtree(dirbak)
    os.rename(namedir, dirbak)
    os.listdir(dirbak) #needed to update filesystem on special machines (cluster with NFS, for example)
  os.makedirs(namedir)

class Module(object):
  """
   A :class:`Module` instance represents a SALOME module that contains components given as a list of
   component instances (:class:`CPPComponent` or :class:`PYComponent` or :class:`F77Component` or :class:`ASTERComponent`)
   with the parameter *components*.

   :param name: gives the name of the module. The SALOME source module
      will be located in the <name_SRC> directory.
   :type name: str
   :param components: gives the list of components of the module.
   :param prefix: is the path of the installation directory.
   :param doc: can be used to add an online documentation to the module. It must be a list of file names (sources, images, ...) that will be
      used to build a sphinx documentation (see http://sphinx.pocoo.org, for more information). If not given, the Makefile.am
      and the conf.py (sphinx configuration) files are generated. In this case, the file name extension of source files must be .rst.
      See small examples in Examples/pygui1 and Examples/cppgui1.
   :param gui: can be used to add a GUI to the module. It must be a list of file names (sources, images, qt designer files, ...).
      If not given, the CMakeLists.txt and SalomeApp.xml are generated. All image files are put in the resources directory of the module.
      The GUI can be implemented in C++ (file name extension '.cxx') or in Python (file name extension '.py').
      See small examples in Examples/pygui1 and Examples/cppgui1.

   For example, the following call defines a module named "mymodule" with 2 components c1 and c2  (they must have been
   defined before) that will be installed in the "install" directory::

      >>> m = module_generator.Module('mymodule', components=[c1,c2],
                                                  prefix="./install")

  """
  def __init__(self, name, components=None, prefix="", doc=None, gui=None):
    self.name = name
    self.components = components or []
    self.prefix = prefix or "%s_INSTALL" % name
    self.doc = doc
    self.gui = gui
    try:
      self.validate()
    except Invalid as e:
      if debug:
        traceback.print_exc()
      print("Error in module %s: %s" % (name,e))
      raise SystemExit

  def validate(self):
    # Test Module name, canot have a "-" in the name
    if self.name.find("-") != -1:
      raise Invalid("Module name %s is not valid, remove character - in the module name" % self.name)
    lcompo = set()
    for compo in self.components:
      if compo.name in lcompo:
        raise Invalid("%s is already defined as a component of the module" % compo.name)
      lcompo.add(compo.name)
      compo.validate()

class Library(object):
  """
     A :class:'Library' instance contains the informations of a user library.
     
     :param name: name of the library (exemple: "cppunit", "calcul")
     :param path: path where to find the library (exemple: "/home/user/libs")
  """
  
  def __init__(self, name, path):
    self.name=name
    self.path=path

  def findLibrary(self):
    """
    return : text for the FIND_LIBRARY command for cmake.
    Feel free to overload this function for your own needs.
    """
    return "FIND_LIBRARY( "+self.cmakeVarName()+" "+self.name+" PATH "+self.path + ")\n"
    
  def cmakeVarName(self):
    """
    return : name of the cmake variable used by FIND_LIBRARY
    """
    return "_userlib_" + self.name.split()[0]

class Component(object):
  def __init__(self, name, services=None, impl="PY", libs=[], rlibs="",
                     includes="", kind="lib", sources=None,
                     inheritedclass="",compodefs="",
                     idls=None,interfacedefs="",inheritedinterface="",addedmethods=""):
    self.name = name
    self.impl = impl
    self.kind = kind
    self.services = services or []
    self.libs = libs
    self.rlibs = rlibs
    self.includes = includes
    self.sources = sources or []
    self.inheritedclass=inheritedclass
    self.compodefs=compodefs
    self.idls=idls
    self.interfacedefs=interfacedefs
    self.inheritedinterface=inheritedinterface
    self.addedmethods=addedmethods

  def additionalLibraries(self):
    """ generate the cmake code for finding the additional libraries
    return
      string containing a list of "find_library"
      string containing a list of cmake variables defined
    """
    cmake_text=""
    cmake_vars=""
    
    for lib in self.libs:
      cmake_text = cmake_text + lib.findLibrary()
      cmake_vars = cmake_vars + "${" + lib.cmakeVarName() + "}\n  "
    
    var_template = Template("$${${name}_SalomeIDL${name}}")
    for mod in self.getDependentModules():
      if salome_modules[mod]["linklibs"]:
        cmake_vars = cmake_vars + salome_modules[mod]["linklibs"]
      else:
        default_lib = var_template.substitute(name=mod)
        print("Unknown libraries for module " + mod)
        print("Using default library name " + default_lib)
        cmake_vars = cmake_vars + default_lib + "\n  "
    
    return cmake_text, cmake_vars

  def validate(self):
    if self.impl not in ValidImpl:
      raise Invalid("%s is not a valid implementation. It should be one of %s" % (self.impl, ValidImpl))

    lnames = set()
    for serv in self.services:
      serv.impl = self.impl
      if serv.name in lnames:
        raise Invalid("%s is already defined as a service of the module" % serv.name)
      lnames.add(serv.name)
      serv.validate()

    for src in self.sources:
      if not os.path.exists(src):
        raise Invalid("Source file %s does not exist" % src)

  def getImpl(self):
    return "SO", ""

  def getMakefileItems(self,gen):
    return {}

  def setPrerequisites(self, prerequisites_file):
    self.prerequisites = prerequisites_file

  def getIdlInterfaces(self):
    services = self.getIdlServices()
    inheritedinterface=""
    if self.inheritedinterface:
      inheritedinterface=self.inheritedinterface+","
    return interface.substitute(component=self.name,
                                services="\n".join(services),
                                inheritedinterface=inheritedinterface)

  def getIdlServices(self):
    services = []
    for serv in self.services:
      params = []
      for name, typ in serv.inport:
        if typ == "file":continue #files are not passed through IDL interface
        if self.impl in ("PY", "ASTER") and typ == "pyobj":
          typ = "Engines::fileBlock"
        else:
          typ=idlTypes[typ]
        params.append("in %s %s" % (typ, name))
      for name, typ in serv.outport:
        if typ == "file":continue #files are not passed through IDL interface
        if self.impl in ("PY", "ASTER") and typ == "pyobj":
          typ = "Engines::fileBlock"
        else:
          typ=idlTypes[typ]
        params.append("out %s %s" % (typ, name))
      service = "    %s %s(" % (idlTypes[serv.ret],serv.name)
      service = service+",".join(params)+") raises (SALOME::SALOME_Exception);"
      services.append(service)
    return services

  def getIdlDefs(self):
    idldefs = """
#include "DSC_Engines.idl"
#include "SALOME_Parametric.idl"
"""
    if self.interfacedefs:
      idldefs = idldefs + self.interfacedefs
    return idldefs

  def getDependentModules(self):
    """get the list of SALOME modules used by the component
    """
    def get_dependent_modules(mod,modules):
      modules.add(mod)
      if "depends" in salome_modules[mod]:
        for m in salome_modules[mod]["depends"]:
          if m not in modules:
            get_dependent_modules(m,modules)

    depend_modules = set()
    for serv in self.services:
      for name, typ in serv.inport + serv.outport + [ ("return",serv.ret) ] :
        mod = moduleTypes[typ]
        if mod:
          get_dependent_modules(mod,depend_modules)
    return depend_modules

class Service(object):
  """
   A :class:`Service` instance represents a component service with dataflow and datastream ports.

   :param name: gives the name of the service.
   :type name: str
   :param inport: gives the list of input dataflow ports.
   :param outport: gives the list of output dataflow ports. An input or output dataflow port is defined
      by a 2-tuple (port name, data type name). The list of supported basic data types is: "double", "long", "string",
      "dblevec", "stringvec", "intvec", "file" and "pyobj" only for Python services. Depending on the implementation
      language, it is also possible to use some types from SALOME modules (see :ref:`yacstypes`).
   :param ret: gives the type of the return parameter
   :param instream: gives the list of input datastream ports.
   :param outstream: gives the list of output datastream ports. An input or output datastream port is defined
      by a 3-tuple (port name, data type name, mode name). The list of possible data types is: "CALCIUM_double", "CALCIUM_integer",
      "CALCIUM_real", "CALCIUM_string", "CALCIUM_complex", "CALCIUM_logical", "CALCIUM_long". The mode can be "I" (iterative mode)
      or "T" (temporal mode).
   :param defs: gives the source code to insert in the definition section of the component. It can be C++ includes
      or Python imports
   :type defs: str
   :param body: gives the source code to insert in the service call. It can be any C++
      or Python code that fits well in the body of the service method.
   :type body: str

   For example, the following call defines a minimal Python service with one input dataflow port (name "a", type double)
   and one input datastream port::

      >>> s1 = module_generator.Service('myservice', inport=[("a","double"),],
                                        instream=[("aa","CALCIUM_double","I")],
                                        body="print( a)")


  """
  def __init__(self, name, inport=None, outport=None, ret="void", instream=None, outstream=None,
                     parallel_instream=None, parallel_outstream=None, defs="", body="", impl_type="sequential"):
    self.name = name
    self.inport = inport or []
    self.outport = outport or []
    self.ret = ret
    self.instream = instream or []
    self.outstream = outstream or []
    self.parallel_instream = parallel_instream or []
    self.parallel_outstream = parallel_outstream or []
    self.defs = defs
    self.body = body
    self.impl = ""
    self.impl_type = impl_type

  def validate(self):
    lports = set()
    for port in self.inport:
      name, typ = self.validatePort(port)
      if name in lports:
        raise Invalid("%s is already defined as a service parameter" % name)
      lports.add(name)

    for port in self.outport:
      name, typ = self.validatePort(port)
      if name in lports:
        raise Invalid("%s is already defined as a service parameter" % name)
      lports.add(name)

    lports = set()
    for port in self.instream:
      name, typ, dep = self.validateStream(port)
      if name in lports:
        raise Invalid("%s is already defined as a stream port" % name)
      lports.add(name)

    for port in self.outstream:
      name, typ, dep = self.validateStream(port)
      if name in lports:
        raise Invalid("%s is already defined as a stream port" % name)
      lports.add(name)

    for port in self.parallel_instream:
      name, typ = self.validateParallelStream(port)
      if name in lports:
        raise Invalid("%s is already defined as a stream port" % name)
      lports.add(name)

    for port in self.parallel_outstream:
      name, typ = self.validateParallelStream(port)
      if name in lports:
        raise Invalid("%s is already defined as a stream port" % name)
      lports.add(name)

    self.validateImplType()

  def validatePort(self, port):
    try:
      name, typ = port
    except:
      raise Invalid("%s is not a valid definition of an data port (name,type)" % (port,))

    if self.impl in ("PY", "ASTER"):
      validtypes = PyValidTypes
    else:
      validtypes = ValidTypes

    if typ not in validtypes:
      raise Invalid("%s is not a valid type. It should be one of %s" % (typ, validtypes))
    return name, typ

  def validateImplType(self):
    if self.impl_type not in ValidImplTypes:
      raise Invalid("%s is not a valid impl type. It should be one of %s" % (self.impl_type, ValidImplTypes))

  def validateStream(self, port):
    try:
      name, typ, dep = port
    except:
      raise Invalid("%s is not a valid definition of a stream port (name,type,dependency)" % (port,))
    if typ not in ValidStreamTypes:
      raise Invalid("%s is not a valid type. It should be one of %s" % (typ, ValidStreamTypes))
    if dep not in ValidDependencies:
      raise Invalid("%s is not a valid dependency. It should be one of %s" % (dep, ValidDependencies))
    return name, typ, dep

  def validateParallelStream(self, port):
    try:
      name, typ = port
    except:
      raise Invalid("%s is not a valid definition of a parallel stream port (name,type)" % (port,))
    if typ not in ValidParallelStreamTypes:
      raise Invalid("%s is not a valid type. It should be one of %s" % (typ, ValidParallelStreamTypes))
    return name, typ

class Generator(object):
  """
   A :class:`Generator` instance take a :class:`Module` instance as its first parameter and can be used to generate the
   SALOME source module, builds it, installs it and includes it in a SALOME application.

   :param module: gives the :class:`Module` instance that will be used for the generation.
   :param context: If given , its content is used to specify the prerequisites
      environment file (key *"prerequisites"*) and the SALOME KERNEL installation directory (key *"kernel"*).
   :type context: dict

   For example, the following call creates a generator for the module m::

      >>> g = module_generator.Generator(m,context)
  """
  def __init__(self, module, context=None):
    self.module = module
    self.context = context or {}
    self.kernel = self.context["kernel"]
    self.gui = self.context.get("gui")
    self.makeflags = self.context.get("makeflags")
    self.aster = ""
    if self.module.gui and not self.gui:
      raise Invalid("To generate a module with GUI, you need to set the 'gui' parameter in the context dictionnary")
    for component in self.module.components:
      component.setPrerequisites(self.context.get("prerequisites"))

  def sourceDir(self):
    """ get the name of the source directory"""
    return self.module.name+"_SRC"

  def generate(self):
    """Generate a SALOME source module"""
    module = self.module
    namedir = self.sourceDir()
    force = self.context.get("force")
    update = self.context.get("update")
    paco = self.context.get("paco")
    if os.path.exists(namedir):
      if force:
        shutil.rmtree(namedir)
      elif not update:
        raise Invalid("The directory %s already exists" % namedir)
    if update:
      makedirs(namedir)
    else:
      os.makedirs(namedir)

    srcs = {}

    #get the list of SALOME modules used and put it in used_modules attribute
    modules = set()
    for compo in module.components:
      modules |= compo.getDependentModules()
      
    self.used_modules = modules

    for compo in module.components:
      #for components files
      fdict=compo.makeCompo(self)
      srcs[compo.name] = fdict

    cmakecontent = ""
    components_string = "".join([x.name+" " for x in module.components])

    if self.module.gui:
      GUIname=module.name+"GUI"
      fdict=self.makeGui(namedir)
      srcs[GUIname] = fdict
      components_string = components_string + "\n  " + GUIname
      
    cmakecontent = cmake_src.substitute(components=components_string)
    srcs["CMakeLists.txt"] = cmakecontent

    docsubdir=""
    if module.doc:
      docsubdir="doc"
      cmake_doc="ON"
    else:
      cmake_doc="OFF"

    #for catalog files
    catalogfile = "%sCatalog.xml" % module.name

    if module.gui:
      cmake_gui="ON"
    else:
      cmake_gui="OFF"
      
    prefix = os.path.abspath(self.module.prefix)
    component_libs = "".join([x.libraryName()+" " for x in module.components])
    add_modules = ""
    for x in self.used_modules:
      if x == "MED":
        cmake_text = cmake_find_module.substitute(module="FIELDS")
        cmake_text = cmake_text + """
#####################################
# FIND MEDCOUPLING
#####################################
SET(MEDCOUPLING_ROOT_DIR $ENV{MEDCOUPLING_ROOT_DIR} CACHE PATH "Path to MEDCOUPLING module")
IF(EXISTS ${MEDCOUPLING_ROOT_DIR})
  LIST(APPEND CMAKE_MODULE_PATH "${MEDCOUPLING_ROOT_DIR}/cmake_files")
  FIND_PACKAGE(SalomeMEDCoupling REQUIRED)
  ADD_DEFINITIONS(${MEDCOUPLING_DEFINITIONS})
  INCLUDE_DIRECTORIES(${MEDCOUPLING_INCLUDE_DIRS})
ELSE(EXISTS ${MEDCOUPLING_ROOT_DIR})
  MESSAGE(FATAL_ERROR "We absolutely need MEDCOUPLING module, please define MEDCOUPLING_ROOT_DIR")
ENDIF(EXISTS ${MEDCOUPLING_ROOT_DIR})
#####################################

"""
      else:
        cmake_text = cmake_find_module.substitute(module=x)

      add_modules = add_modules + cmake_text
      pass
    
    self.makeFiles({"CMakeLists.txt":cmake_root_cpp.substitute(
                                                 module=self.module.name,
                                                 module_min=self.module.name.lower(),
                                                 compolibs=component_libs,
                                                 with_doc=cmake_doc,
                                                 with_gui=cmake_gui,
                                                 add_modules=add_modules,
                                                 major_version=yacsgen_version.major_version,
                                                 minor_version=yacsgen_version.minor_version,
                                                 patch_version=yacsgen_version.patch_version),
                    "README":"", "NEWS":"", "AUTHORS":"", "ChangeLog":"",
                    "src":srcs,
                    "resources":{"CMakeLists.txt":cmake_ressources.substitute(
                                                        module=self.module.name),
                                 catalogfile:self.makeCatalog()},
                    }, namedir)

    files={}
    #for idl files
    idlfile = "%s.idl" % module.name

    #if components have other idls
    other_idls=""
#    other_sks=""
    for compo in module.components:
      if compo.idls:
        for idl in compo.idls:
          for fidl in glob.glob(idl):
            other_idls=other_idls+os.path.basename(fidl) +" "
#            other_sks=other_sks+os.path.splitext(os.path.basename(fidl))[0]+"SK.cc "

    include_template=Template("$${${module}_ROOT_DIR}/idl/salome")
    link_template=Template("$${${module}_SalomeIDL${module}}")
    opt_inc=""
    opt_link=""
    for x in self.used_modules:
      if x=="MED":
        # here template cannot be used as we mix FIELDS and MED
        opt_inc+="${FIELDS_ROOT_DIR}/idl/salome\n  "
        opt_link+="${FIELDS_SalomeIDLMED}\n  "
      else:
        opt_inc+=include_template.substitute(module=x)+"\n  "
        opt_link+=link_template.substitute(module=x)+"\n  "

    
    idlfiles={"CMakeLists.txt":cmake_idl.substitute(module=module.name,
                                                    extra_idl=other_idls,
                                                    extra_include=opt_inc,
                                                    extra_link=opt_link),
              idlfile         :self.makeidl(),
             }

    files["idl"]=idlfiles

    self.makeFiles(files,namedir)

    #copy source files if any in created tree
    for compo in module.components:
      for src in compo.sources:
        shutil.copyfile(src, os.path.join(namedir, "src", compo.name, os.path.basename(src)))

      if compo.idls:
        #copy provided idl files in idl directory
        for idl in compo.idls:
          for fidl in glob.glob(idl):
            shutil.copyfile(fidl, os.path.join(namedir, "idl", os.path.basename(fidl)))

    self.makeDoc(namedir)
    return

  def makeDoc(self,namedir):
    if not self.module.doc:
      return
    rep=os.path.join(namedir,"doc")
    os.makedirs(rep)
    doc_files=""
    for docs in self.module.doc:
      for doc in glob.glob(docs):
        name = os.path.basename(doc)
        doc_files = doc_files + name + "\n  "
        shutil.copyfile(doc, os.path.join(rep, name))

    d={}

    if not self.module.gui:
       #without gui but with doc: create a small SalomeApp.xml in doc directory
       if not os.path.exists(os.path.join(namedir, "doc", "SalomeApp.xml")):
         #create a minimal SalomeApp.xml
         salomeapp=docsalomeapp.substitute(module=self.module.name,
                                           lmodule=self.module.name.lower(),
                                           version=yacsgen_version.complete_version)
         d["SalomeApp.xml"]=salomeapp

    if not os.path.exists(os.path.join(namedir, "doc", "CMakeLists.txt")):
      #create a minimal CMakeLists.txt
      makefile_txt=docmakefile.substitute(module=self.module.name,
                                          files=doc_files)
      if not self.module.gui:
        txt = 'INSTALL(FILES SalomeApp.xml DESTINATION \
"${SALOME_%s_INSTALL_RES_DATA}")\n' % self.module.name
        makefile_txt = makefile_txt + txt
        pass
      
      d["CMakeLists.txt"]=makefile_txt
      pass

    if not os.path.exists(os.path.join(namedir, "doc", "conf.py")):
      #create a minimal conf.py
      d["conf.py"]=docconf.substitute(module=self.module.name)

    self.makeFiles(d,os.path.join(namedir,"doc"))

  def makeGui(self,namedir):
    if not self.module.gui:
      return
    ispython=False
    iscpp=False
    #Force creation of intermediate directories
    os.makedirs(os.path.join(namedir, "src", self.module.name+"GUI"))

    for srcs in self.module.gui:
      for src in glob.glob(srcs):
        shutil.copyfile(src, os.path.join(namedir, "src", self.module.name+"GUI", os.path.basename(src)))
        if src[-3:]==".py":ispython=True
        if src[-4:]==".cxx":iscpp=True
    if ispython and iscpp:
      raise Invalid("Module GUI must be pure python or pure C++ but not mixed")
    if ispython:
      return self.makePyGUI(namedir)
    if iscpp:
      return self.makeCPPGUI(namedir)
    raise Invalid("Module GUI must be in python or C++ but it is none of them")

  def makePyGUI(self,namedir):
    d={}
    if not os.path.exists(os.path.join(namedir, "src", self.module.name+"GUI", "CMakeLists.txt")):
      #create a minimal CMakeLists.txt
      sources=""
      other=""
      ui_files=""
      ts_files=""
      for srcs in self.module.gui:
        for src in glob.glob(srcs):
          if src[-3:]==".py":
            sources=sources+os.path.basename(src)+"\n  "
          elif src[-3:]==".ts":
            ts_files=ts_files+os.path.basename(src)+"\n  "
          else:
            other=other+os.path.basename(src)+"\n  "
      makefile=cmake_py_gui.substitute(module=self.module.name,
                                       scripts=sources,
                                       ts_resources=ts_files,
                                       resources=other)
      d["CMakeLists.txt"]=makefile

    if not os.path.exists(os.path.join(namedir, "src", self.module.name+"GUI", "SalomeApp.xml")):
      #create a minimal SalomeApp.xml
      salomeapp=pysalomeapp.substitute(module=self.module.name,
                                       lmodule=self.module.name.lower(),
                                       version=yacsgen_version.complete_version)
      d["SalomeApp.xml"]=salomeapp

    return d

  def makeCPPGUI(self,namedir):
    d={}
    if not os.path.exists(os.path.join(namedir, "src", self.module.name+"GUI", "CMakeLists.txt")):
      #create a minimal CMakeLists.txt
      sources=""
      headers=""
      other=""
      ui_files=""
      ts_files=""
      for srcs in self.module.gui:
        for src in glob.glob(srcs):
          if src[-4:]==".cxx" or src[-4:]==".cpp":
            sources=sources+os.path.basename(src)+"\n  "
          elif src[-2:]==".h" or src[-4:]==".hxx":
            headers=headers+os.path.basename(src)+"\n  "
          elif src[-3:]==".ui":
            ui_files=ui_files+os.path.basename(src)+"\n  "
          elif src[-3:]==".ts":
            ts_files = ts_files + os.path.basename(src) + "\n  "
          else:
            other=other+os.path.basename(src)+"\n  "

      compo_dirs = "".join(["${PROJECT_SOURCE_DIR}/src/"+x.name+"\n  " for x in self.module.components])
      compo_dirs = compo_dirs + "${PROJECT_BINARY_DIR}/src/" + self.module.name + "GUI\n"
      component_libs = "".join([x.libraryName()+" " for x in self.module.components])
      makefile=cmake_cpp_gui.substitute(module=self.module.name,
                                    include_dirs=compo_dirs,
                                    libs=component_libs,
                                    uic_files=ui_files,
                                    moc_headers=headers,
                                    sources=sources,
                                    resources=other,
                                    ts_resources=ts_files)
      d["CMakeLists.txt"]=makefile

    if not os.path.exists(os.path.join(namedir, "src", self.module.name+"GUI", "SalomeApp.xml")):
      #create a minimal SalomeApp.xml
      salomeapp=cppsalomeapp.substitute(module=self.module.name,
                                        lmodule=self.module.name.lower(),
                                        version=yacsgen_version.complete_version)
      d["SalomeApp.xml"]=salomeapp

    return d

  def makeMakefile(self,makefileItems):
    makefile=""
    if "header" in makefileItems:
      makefile=makefile + makefileItems["header"]+'\n'
    if "lib_LTLIBRARIES" in makefileItems:
      makefile=makefile+"lib_LTLIBRARIES= "+" ".join(makefileItems["lib_LTLIBRARIES"])+'\n'
    if "salomepython_PYTHON" in makefileItems:
      makefile=makefile+"salomepython_PYTHON= "+" ".join(makefileItems["salomepython_PYTHON"])+'\n'
    if "dist_salomescript_SCRIPTS" in makefileItems:
      makefile=makefile+"dist_salomescript_SCRIPTS= "+" ".join(makefileItems["dist_salomescript_SCRIPTS"])+'\n'
    if "salomeres_DATA" in makefileItems:
      makefile=makefile+"salomeres_DATA= "+" ".join(makefileItems["salomeres_DATA"])+'\n'
    if "salomeinclude_HEADERS" in makefileItems:
      makefile=makefile+"salomeinclude_HEADERS= "+" ".join(makefileItems["salomeinclude_HEADERS"])+'\n'
    if "body" in makefileItems:
      makefile=makefile+makefileItems["body"]+'\n'
    return makefile

  def makeArgs(self, service):
    """generate source service for arguments"""
    params = []
    for name, typ in service.inport:
      if typ=="file":continue #files are not passed through service interface
      params.append("%s %s" % (corba_in_type(typ, self.module.name), name))
    for name, typ in service.outport:
      if typ=="file":continue #files are not passed through service interface
      params.append("%s %s" % (corba_out_type(typ, self.module.name), name))
    return ",".join(params)

  def makeCatalog(self):
    """generate SALOME components catalog source"""
    components = []
    for compo in self.module.components:
      services = []
      for serv in compo.services:
        params = []
        for name, typ in serv.inport:
          params.append(cataInparam.substitute(name=name, type=typ))
        inparams = "\n".join(params)
        params = []
        for name, typ in serv.outport:
          params.append(cataOutparam.substitute(name=name, type=typ))
        if serv.ret != "void" :
          params.append(cataOutparam.substitute(name="return", type=serv.ret))
        outparams = "\n".join(params)
        streams = []
        for name, typ, dep in serv.instream:
          streams.append(cataInStream.substitute(name=name, type=calciumTypes[typ], dep=dep))
        for name, typ, dep in serv.outstream:
          streams.append(cataOutStream.substitute(name=name, type=calciumTypes[typ], dep=dep))
        for name, typ in serv.parallel_instream:
          streams.append(cataInParallelStream.substitute(name=name, type=DatastreamParallelTypes[typ]))
        for name, typ in serv.parallel_outstream:
          streams.append(cataOutParallelStream.substitute(name=name, type=DatastreamParallelTypes[typ]))
        datastreams = "\n".join(streams)
        services.append(cataService.substitute(service=serv.name, author="EDF-RD",
                                               inparams=inparams, outparams=outparams, datastreams=datastreams))
      impltype, implname = compo.getImpl()
      components.append(cataCompo.substitute(component=compo.name, author="EDF-RD", impltype=impltype, implname=implname,
                                             services='\n'.join(services)))
    return catalog.substitute(components='\n'.join(components))

  def makeidl(self):
    """generate module IDL file source (CORBA interface)"""
    interfaces = []
    idldefs=""
    for compo in self.module.components:
      interfaces.append(compo.getIdlInterfaces())

    #build idl includes for SALOME modules
    for mod in self.used_modules:
      idldefs = idldefs + salome_modules[mod]["idldefs"]

    for compo in self.module.components:
      idldefs = idldefs + compo.getIdlDefs()
    
    filteredDefs = []
    for defLine in idldefs.split('\n'):
      if defLine not in filteredDefs:
        filteredDefs.append(defLine)

    return idl.substitute(module=self.module.name,
                          interfaces='\n'.join(interfaces),
                          idldefs='\n'.join(filteredDefs) )

  # For PaCO++
  def makexml(self):
    from .pacocompo import PACOComponent
    interfaces = []
    for compo in self.module.components:
      if isinstance(compo, PACOComponent):
        services = []
        for serv in compo.services:
          if serv.impl_type == "parallel":
            service = xml_service.substitute(service_name=serv.name)
            services.append(service)
        interfaces.append(xml_interface.substitute(component=compo.name, xml_services="\n".join(services)))
    return xml.substitute(module=self.module.name, interfaces='\n'.join(interfaces))

  def makeFiles(self, dic, basedir):
    """create files and directories defined in dictionary dic in basedir directory
       dic key = file name to create
       dic value = file content or dictionary defining the content of a sub directory
    """
    for name, content in list(dic.items()):
      filename = os.path.join(basedir, name)
      if isinstance(content, str):
        # encodage to utf-8 if unicode string / on python3 str are unicode
        with open(filename, 'w') as fil:
          fil.write(content)
      else:
        if not os.path.exists(filename):
          os.makedirs(filename)
        self.makeFiles(content, filename)

  def configure(self, extra_params = None):
    """Execute the second build step (configure) with installation prefix as given by the prefix attribute of module"""
    if extra_params is None:
        extra_params = ""
    prefix = os.path.abspath(self.module.prefix)

    self.build_dir = "%s_build" % self.module.name
    makedirs(self.build_dir)
    
    build_sh = "cd %s; cmake ../%s -DCMAKE_INSTALL_PREFIX:PATH=%s %s"%(
                self.build_dir, self.sourceDir(), prefix, extra_params)
    ier = os.system(build_sh)
    if ier != 0:
      raise Invalid("configure has ended in error")

  def make(self):
    """Execute the third build step (compile and link) : make"""
    make_command = "cd %s; make " % self.build_dir
    if self.makeflags:
      make_command += self.makeflags
    ier = os.system(make_command)
    if ier != 0:
      raise Invalid("make has ended in error")

  def install(self):
    """Execute the installation step : make install """
    make_command = "cd %s; make install" % self.build_dir
    ier = os.system(make_command)
    if ier != 0:
      raise Invalid("install has ended in error")

  def make_appli(self, appliname, restrict=None, altmodules=None, resources="",
                 sys_modules=None):
    """
   Create a SALOME application containing the module and preexisting SALOME modules.

   :param appliname: is a string that gives the name of the application (directory path where the application
      will be installed).
   :type appliname: str
   :param restrict: If given (a list of module names), only those SALOME modules will be included in the
      application. The default is to include all modules that are located in the same directory as the KERNEL module and have
      the same suffix (for example, if KERNEL directory is KERNEL_V5 and GEOM directory is GEOM_V5, GEOM module is automatically
      included, except if restrict is used).
   :param altmodules: can be used to add SALOME modules that cannot be managed with the precedent rule. This parameter
      is a dict with a module name as the key and the installation path as the value.
   :param resources: can be used to define an alternative resources catalog (path of the file).
   :param sys_modules: list of system modules to be loaded with "module load"
      command within the salome environment.

   For example, the following calls create a SALOME application with external modules and resources catalog in "appli" directory::

     >>> g=Generator(m,context)
     >>> g.generate()
     >>> g.configure()
     >>> g.make()
     >>> g.install()
     >>> g.make_appli("appli", restrict=["KERNEL"], altmodules={"GUI":GUI_ROOT_DIR, "YACS":YACS_ROOT_DIR},
                      resources="myresources.xml")

    """
    makedirs(appliname)
    if sys_modules is None:
        sys_modules = []

    rootdir, kerdir = os.path.split(self.kernel)

    #collect modules besides KERNEL module with the same suffix if any
    modules_dict = {}
    if kerdir[:6] == "KERNEL":
      suffix = kerdir[6:]
      for mod in os.listdir(rootdir):
        if mod[-len(suffix):] == suffix:
          module = mod[:-len(suffix)]
          path = os.path.join(rootdir, mod)
          #try to find catalog files
          lcata = glob.glob(os.path.join(path, "share", "salome", "resources", "*", "*Catalog.xml"))
          if not lcata:
            #catalogs have not been found : try the upper level
            lcata = glob.glob(os.path.join(path, "share", "salome", "resources", "*Catalog.xml"))
          if lcata:
            #catalogs have been found : add the corresponding entries in the application
            for cata in lcata:
              catadir, catafile = os.path.split(cata)
              name = catafile[:-11]
              modules_dict[name] = '  <module name="%s" path="%s"/>' % (name, path)
          else:
            modules_dict[module] = '  <module name="%s" path="%s"/>' % (module, path)

    modules_dict["KERNEL"] = '  <module name="KERNEL" path="%s"/>' % self.kernel

    #keep only the modules which names are in restrict if given
    modules = []
    if restrict:
      for mod in restrict:
        if mod in modules_dict:
          modules.append(modules_dict[mod])
    else:
      modules = list(modules_dict.values())

    #add the alternate modules if given
    if altmodules:
      for module, path in list(altmodules.items()):
        modules.append('  <module name="%s" path="%s"/>' % (module, path))

    #add the generated module
    modules.append('  <module name="%s" path="%s"/>' % (self.module.name, os.path.abspath(self.module.prefix)))

    ROOT_SALOME=os.getenv("ROOT_SALOME")
    #try to find a prerequisites file
    prerequisites = self.context.get("prerequisites")
    if not prerequisites:
      #try to find one in rootdir
      prerequisites = os.path.join(ROOT_SALOME, "salome_prerequisites.sh")
    if not os.path.exists(prerequisites):
      raise Invalid("Can not create an application : prerequisites file not defined or does not exist")

    salome_context = self.context.get("salome_context")
    if not salome_context:
      #try to find one in rootdir
      salome_context = os.path.join(ROOT_SALOME, "salome_context.cfg")
    if not os.path.exists(salome_context):
      raise Invalid("Can not create an application : salome_context file not defined or does not exist")

    #add resources catalog if it exists
    resources_spec=""
    if os.path.isfile(resources):
      resources_spec='<resources path="%s" />' % os.path.abspath(resources)

    sys_modules_str = ""
    for mod in sys_modules:
        sys_modules_str += "  <env_module name='{}'/>\n".format(mod)

    #create config_appli.xml file
    appli = application.substitute(prerequisites=prerequisites,
                                   context=salome_context,
                                   env_modules=sys_modules_str,
                                   modules="\n".join(modules),
                                   resources=resources_spec)
    fil = open(os.path.join(appliname, "config_appli.xml"), 'w')
    fil.write(appli)
    fil.close()

    #execute appli_gen.py script
    appligen = os.path.join(self.kernel, "bin", "salome", "appli_gen.py")
    ier = os.system("cd %s;%s" % (appliname, appligen))
    if ier != 0:
      raise Invalid("make_appli has ended in error")

    #add CatalogResources.xml if not created by appli_gen.py
    if not os.path.exists(os.path.join(appliname, "CatalogResources.xml")):
      #CatalogResources.xml does not exist create a minimal one
      fil  = open(os.path.join(appliname, 'CatalogResources.xml'), 'w')
      command = """<!DOCTYPE ResourcesCatalog>
<resources>
    <machine hostname="%s" protocol="ssh" mode="interactive" />
</resources>
"""
      host = socket.gethostname().split('.')[0]
      fil.write(command % host)
      fil.close()
