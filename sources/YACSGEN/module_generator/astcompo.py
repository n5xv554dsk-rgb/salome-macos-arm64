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
  This module defines the ASTERComponent class for ASTER component generation
  An ASTER component comes in 3 flavors :
   - implemented as a dynamic library (kind='lib')
   - implemented as a standalone component (kind='exe')
   - implemented as a specific container (kind='cexe')
"""
import re, os, sys

from module_generator.gener import Component, Invalid, makedirs

from module_generator.pyth_tmpl import pyinitEXEService, pyinitCEXEService, pyinitService
from module_generator import aster_tmpl
from module_generator.aster_tmpl import asterCEXEService, asterEXEService
from module_generator.aster_tmpl import asterService, asterEXECompo, asterCEXECompo, asterCompo
from module_generator.aster_tmpl import comm, make_etude, cexe, exeaster
from module_generator.aster_tmpl import container, component
from module_generator.aster_tmpl import cmake_src_compo_aster, cmake_src_compo_aster_lib

class ASTERComponent(Component):
  """
   A :class:`ASTERComponent` instance represents an ASTER SALOME component (special component for Code_Aster that is a mix of
   Fortran and Python code) with services given as a list of :class:`Service` instances with the parameter *services*.

   :param name: gives the name of the component.
   :type name: str
   :param services: the list of services (:class:`Service`) of the component.
   :param kind: If it is given and has the value "exe", the component will be built as a standalone
      component (executable or shell script). The default is to build the component as a dynamic library.
   :param libs: gives all the libraries options to add when linking the generated component (-L...).
   :param rlibs: gives all the runtime libraries options to add when linking the generated component (-R...).
   :param exe_path: is only used when kind is "exe" and gives the path to the standalone component.
   :param aster_dir: gives the Code_Aster installation directory.
   :param python_path: If it is given (as a list of paths), all the paths are added to the python path (sys.path).
   :param argv: is a list of strings that gives the command line parameters for Code_Aster. This parameter is only useful when
      kind is "lib".

   For example, the following call defines a Code_Aster component named "mycompo" with one service s1 (it must have been defined before).
   This standalone component takes some command line arguments::

      >>> c1 = module_generator.ASTERComponent('mycompo', services=[s1,], kind="exe",
                                                          exe_path="launch.sh",
                                                          argv=["-memjeveux","4"])
  """
  def __init__(self, name, services=None, libs="", rlibs="", aster_dir="",
                     python_path=None, argv=None, kind="lib", exe_path=None, aster_version_type="stable"):
    """initialise component attributes"""
    self.aster_dir = aster_dir
    self.python_path = python_path or []
    self.argv = argv or []
    self.exe_path = exe_path
    self.aster_version_type = aster_version_type
    Component.__init__(self, name, services, impl="ASTER", libs=libs, 
                             rlibs=rlibs, kind=kind)

  def validate(self):
    """validate the component definition"""
    Component.validate(self)
    if not self.aster_dir:
      raise Invalid("aster_dir must be defined for component %s" % self.name)

    kinds = ("lib", "cexe", "exe")
    if self.kind not in kinds:
      raise Invalid("kind must be one of %s for component %s" % (kinds,self.name))
    if self.kind == "lib" and not self.python_path:
      raise Invalid("python_path must be defined for component %s" % self.name)
    if self.kind == "cexe" :
      if not self.exe_path:
        raise Invalid("exe_path must be defined for component %s" % self.name)
    if self.kind == "exe" :
      if not self.exe_path:
        raise Invalid("exe_path must be defined for component %s" % self.name)

    #Si un port de nom jdc n'est pas defini dans la liste des inports du service,
    #on en ajoute un de type string en premiere position
    for serv in self.services:
      found=False
      for port_name,port_type in serv.inport:
        if port_name == "jdc":
          found=True
          break
      if not found:
        serv.inport.insert(0, ("jdc", "string"))

  def libraryName(self):
    """ Name of the target library
        No library for an aster component
    """
    return ""
    
  def getAsterPythonPath(self):
    """Directory of aster python modules
    """
    python_version_dir = 'python%s.%s' % (sys.version_info[0], sys.version_info[1])
    aster_python_path = os.path.join(self.aster_dir, "lib", python_version_dir, "site-packages")

    if not os.path.exists(aster_python_path) :
      aster_python_path = os.path.join(self.aster_dir, "bibpyt")
      
    return aster_python_path

  def makeCompo(self, gen):
    """drive the generation of SALOME module files and code files
       depending on the choosen component kind
    """
    filename = "%s.py" % self.name
    #on suppose que les composants ASTER sont homogenes (utilisent meme install)
    gen.aster = self.aster_dir

    if self.kind == "lib":
      f = self.name+".py"
      return {"CMakeLists.txt":cmake_src_compo_aster_lib.substitute(sources=f),
              filename:self.makeaster(gen)}
    elif self.kind == "cexe":
      fdict=self.makecexepath(gen)
      sources = self.name + ".py\n  " + self.name + "_container.py"
      d= {"CMakeLists.txt":cmake_src_compo_aster.substitute(
                                            sources=sources,
                                            module=gen.module.name,
                                            resources=self.name+"_config.txt",
                                            scripts=self.name+".exe"),
           self.name+".exe":cexe.substitute(compoexe=self.exe_path),
           filename:self.makecexeaster(gen)
         }
      d.update(fdict)
      return d
    elif self.kind == "exe":
      fdict=self.makeexepath(gen)
      sources =  self.name + "_module.py\n  "
      sources =  sources + self.name + "_component.py"
      d= {"CMakeLists.txt":cmake_src_compo_aster.substitute(
                                            sources=sources,
                                            module=gen.module.name,
                                            resources=self.name+"_config.txt",
                                            scripts=self.name+".exe"),
           self.name+".exe":exeaster.substitute(compoexe=self.exe_path),
           self.name+"_module.py":self.makeexeaster(gen)
         }
      d.update(fdict)
      return d

  def makeexepath(self, gen):
    """standalone component: generate files for calculation code"""

    fdict={}
    #use a specific main program (modification of config.txt file)
    config = ""
    path_config = os.path.join(self.aster_dir, "config.txt")
    if os.path.exists(path_config) :
      fil = open(path_config)
      config = fil.read()
      fil.close()
#      config = re.sub(" profile.sh", os.path.join(self.aster_dir, "profile.sh"), config)
#      path=os.path.join(os.path.abspath(gen.module.prefix),'lib',
#                      'python%s.%s' % (sys.version_info[0], sys.version_info[1]),
#                      'site-packages','salome','%s_component.py'%self.name)
#      config = re.sub("Execution\/E_SUPERV.py", path, config)
    else :
      config = "# a completer:%s n'existe pas" % path_config

    fdict["%s_config.txt" % self.name] = config
    fdict["%s_component.py" % self.name] = component.substitute(component=self.name)

    return fdict

  def makecexepath(self, gen):
    """specific container: generate files"""

    fdict={}
    fdict["%s_container.py" % self.name] = container
    return fdict

  def getImportESuperv(self):
    importesuperv="""
VERS="%s"
import os.path as osp
from asrun.run import AsRunFactory
from asrun.config import AsterConfig

run = AsRunFactory()
path = run.get_version_path(VERS)
cfg = AsterConfig(osp.join(path, 'config.txt'))
pypath = cfg['REPPY'][0]

sys.path.insert(0, pypath)
from Execution.E_SUPERV import SUPERV
""" % self.aster_version_type
    return importesuperv


  def makeexeaster(self, gen):
    """standalone component: generate SALOME component source"""
    services = []
    inits = []
    defs = []
    for serv in self.services:
      defs.append(serv.defs)
      params = []
      datas = []
      for name, typ in serv.inport:
        if typ=="file":continue #files are not passed through service interface
        params.append(name)
        if typ == "pyobj":
          datas.append('"%s":pickle.loads(%s)' % (name, name))
        else:
          datas.append('"%s":%s' % (name, name))
      #ajout de l'adresse du composant
      datas.append('"component":self.proxy.ptr()')
      dvars = "{"+','.join(datas)+"}"
      inparams = ",".join(params)

      params = []
      datas = []
      for name, typ in serv.outport:
        if typ=="file":continue #files are not passed through service interface
        params.append(name)
        if typ == "pyobj":
          datas.append('pickle.dumps(j.g_context["%s"],-1)'%name)
        else:
          datas.append('j.g_context["%s"]'%name)
      outparams = ",".join(params)
      rvars = ",".join(datas)

      service = asterEXEService.substitute(component=self.name,
                                           service=serv.name,
                                           inparams=inparams,
                                           outparams=outparams,
                                           body=serv.body,
                                           dvars=dvars, rvars=rvars)
      streams = []
      for name, typ, dep in serv.instream:
        streams.append('       calcium.create_calcium_port(self.proxy,"%s","%s","IN","%s")'% (name, typ, dep))
      instream = "\n".join(streams)
      streams = []
      for name, typ, dep in serv.outstream:
        streams.append('       calcium.create_calcium_port(self.proxy,"%s","%s","OUT","%s")'% (name, typ, dep))
      outstream = "\n".join(streams)

      init = pyinitEXEService.substitute(component=self.name, service=serv.name,
                                         instream=instream, outstream=outstream)
      services.append(service)
      inits.append(init)

    importesuperv = self.getImportESuperv()

    return asterEXECompo.substitute(component=self.name, module=gen.module.name,
                                    servicesdef="\n".join(defs),
                                    servicesimpl="\n".join(services),
                                    initservice='\n'.join(inits),
                                    aster_dir=self.aster_dir,
                                    importesuperv=importesuperv,
                                    )

  def makecexeaster(self, gen):
    """specific container: generate SALOME component source"""
    services = []
    inits = []
    defs = []
    for serv in self.services:
      defs.append(serv.defs)
      params = []
      datas = []
      for name, typ in serv.inport:
        if typ=="file":continue #files are not passed through service interface
        params.append(name)
        if typ == "pyobj":
          datas.append('"%s":pickle.loads(%s)' % (name, name))
        else:
          datas.append('"%s":%s' % (name, name))
      #ajout de l'adresse du composant
      datas.append('"component":self.proxy.ptr()')
      dvars = "{"+','.join(datas)+"}"
      inparams = ",".join(params)

      params = []
      datas = []
      for name, typ in serv.outport:
        params.append(name)
        if typ == "pyobj":
          datas.append('pickle.dumps(j.g_context["%s"],-1)'%name)
        else:
          datas.append('j.g_context["%s"]'%name)
      outparams = ",".join(params)
      rvars = ",".join(datas)

      service = asterCEXEService.substitute(component=self.name,
                                            service=serv.name,
                                            inparams=inparams,
                                            outparams=outparams,
                                            body=serv.body,
                                            dvars=dvars, rvars=rvars)
      streams = []
      for name, typ, dep in serv.instream:
        streams.append('       calcium.create_calcium_port(self.proxy,"%s","%s","IN","%s")'% (name, typ, dep))
      instream = "\n".join(streams)
      streams = []
      for name, typ, dep in serv.outstream:
        streams.append('       calcium.create_calcium_port(self.proxy,"%s","%s","OUT","%s")'% (name, typ, dep))
      outstream = "\n".join(streams)

      init = pyinitCEXEService.substitute(component=self.name, 
                                          service=serv.name,
                                          instream=instream, 
                                          outstream=outstream)
      services.append(service)
      inits.append(init)

    importesuperv = self.getImportESuperv()

    return asterCEXECompo.substitute(component=self.name, 
                                     module=gen.module.name,
                                     servicesdef="\n".join(defs), 
                                     servicesimpl="\n".join(services), 
                                     initservice='\n'.join(inits),
                                     aster_dir=self.aster_dir,
                                     importesuperv=importesuperv,
                                     )

  def getImpl(self):
    if self.kind == "cexe":
      return "CEXE", self.name+".exe"
    else:
      return "SO", ""

  def makeaster(self, gen):
    """library component: generate SALOME component source"""
    services = []
    inits = []
    defs = []
    for serv in self.services:
      defs.append(serv.defs)
      params = []
      datas = []
      for name, typ in serv.inport:
        if typ=="file":continue #files are not passed through service interface
        params.append(name)
        if typ == "pyobj":
          datas.append('"%s":pickle.loads(%s)' % (name, name))
        else:
          datas.append('"%s":%s' % (name, name))
      #ajout de l'adresse du composant
      datas.append('"component":self.proxy.ptr()')
      dvars = "{"+','.join(datas)+"}"
      inparams = ",".join(params)

      params = []
      datas = []
      for name, typ in serv.outport:
        params.append(name)
        if typ == "pyobj":
          datas.append('pickle.dumps(j.g_context["%s"],-1)'%name)
        else:
          datas.append('j.g_context["%s"]'%name)
      outparams = ",".join(params)
      rvars = ",".join(datas)

      service = asterService.substitute(component=self.name, service=serv.name, 
                                        inparams=inparams, outparams=outparams, 
                                        body=serv.body, 
                                        dvars=dvars, rvars=rvars)
      streams = []
      for name, typ, dep in serv.instream:
        streams.append('       calcium.create_calcium_port(self.proxy,"%s","%s","IN","%s")'% (name, typ, dep))
      instream = "\n".join(streams)
      streams = []
      for name, typ, dep in serv.outstream:
        streams.append('       calcium.create_calcium_port(self.proxy,"%s","%s","OUT","%s")'% (name, typ, dep))
      outstream = "\n".join(streams)

      init = pyinitService.substitute(component=self.name, service=serv.name,
                                      instream=instream, outstream=outstream)
      services.append(service)
      inits.append(init)

    python_path = ",".join([repr(p) for p in self.python_path])
    argv = ",".join([repr(p) for p in self.argv])
    return asterCompo.substitute(component=self.name, module=gen.module.name,
                                 servicesdef="\n".join(defs), 
                                 servicesimpl="\n".join(services), 
                                 initservice='\n'.join(inits),
                                 aster_dir=self.aster_dir, 
                                 python_path=python_path, argv=argv)

