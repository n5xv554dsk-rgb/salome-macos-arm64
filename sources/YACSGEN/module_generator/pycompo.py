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
  Module that defines PYComponent for SALOME components implemented in Python
"""
import os
from module_generator.gener import Component, Invalid
from module_generator.pyth_tmpl import pyinitService, pyService, pyCompoEXE, pyCompo, cmake_src_compo_py
import textwrap

def indent(text, prefix='    '):
  """Indent text by prepending a given prefix to each line."""
  if not text: return ''
  lines = text.split('\n')
  lines = list(map(lambda line, prefix=prefix: prefix + line, lines))
  if lines: lines[-1] = lines[-1].rstrip()
  return '\n'.join(lines)

class PYComponent(Component):
  """
   A :class:`PYComponent` instance represents a Python SALOME component with services given as a list of :class:`Service`
   instances with the parameter *services*.

   :param name: gives the name of the component.
   :type name: str
   :param services: the list of services (:class:`Service`) of the component.
   :param kind: If it is given and has the value "exe", the component will be built as a standalone
      component (python executable). The default is to build the component as a python module.
   :param sources: gives all the external Python source files to add in the component directory (list of paths).
   :param python_path: If it is given (as a list of paths), all the paths are added to the python path (sys.path).
   :param compodefs: can be used to add extra definition code in the component for example when using a base class
      to define the component class by deriving it (see *inheritedclass* parameter)
   :param inheritedclass: can be used to define a base class for the component. The base class can be defined in external
      source or with the *compodefs* parameter. The value of the *inheritedclass* parameter is the name of the base class.
   :param idls: can be used to add extra idl CORBA interfaces. This parameter must gives a list of idl file names that are
      added into the generated module (idl directory) and compiled with the generated idl of the module.
   :param interfacedefs: can be used to add idl definitions (or includes of idl files) into the generated idl of the module.
   :param inheritedinterface: can be used to make the component inherit an extra idl interface that has been included through
      the *idls* and *interfacedefs* parameters. See the pygui1 example for how to use these last parameters.

   For example, the following call defines a Python component named "mycompo" with one service s1 (it must have been defined before)::

      >>> c1 = module_generator.PYComponent('mycompo', services=[s1,],
                                                       python_path="apath")

  """
  def __init__(self, name, services=None, kind="lib", sources=None, python_path=None,
                     compodefs="", inheritedclass="", idls=None, interfacedefs="", inheritedinterface=""):
    """initialise component attributes"""
    self.python_path = python_path or []
    Component.__init__(self, name, services, impl="PY", kind=kind, sources=sources,
                             inheritedclass=inheritedclass, compodefs=compodefs,
                             idls=idls,interfacedefs=interfacedefs,inheritedinterface=inheritedinterface)

  def validate(self):
    """validate component attributes"""
    Component.validate(self)
    kinds = ("lib","exe")
    if self.kind not in kinds:
      raise Invalid("kind must be one of %s for component %s" % (kinds,self.name))

  def libraryName(self):
    """ Name of the target library
        No library for a python component
    """
    return ""
    
  def makeCompo(self, gen):
    """generate component sources as a dictionary containing
       file names (key) and file content (values)
    """
    pyfile = ""
    file_content = ""
    if self.kind == "lib":
      pyfile = self.name  + ".py"
      file_content = self.makepy(gen)
    elif self.kind == "exe":
      pyfile = self.name + ".exe"
      file_content = self.makepyexe(gen)
    else :
      raise Invalid("Invalid kind ()%s for component %s" % (
                                    self.kind, self.name))
    
    sources = pyfile + "".join(["\n  " + os.path.basename(x) for x in self.sources])
    cmake_content = cmake_src_compo_py.substitute(sources=sources)
    
    return {"CMakeLists.txt":cmake_content,
            pyfile:file_content
           }

  def makepy(self, gen):
    """generate standard SALOME component source (python module)"""
    services = []
    inits = []
    defs = []
    for serv in self.services:
      defs.append(serv.defs)
      params = []
      pyparams = []
      for name, typ in serv.inport:
        if typ=="file":continue #files are not passed through service interface
        params.append(name)
        if typ == "pyobj":
          pyparams.append("      %s=pickle.loads(%s)" %(name, name))
      inparams = ",".join(params)
      convertinparams = '\n'.join(pyparams)

      params = []
      pyparams = []
      for name, typ in serv.outport:
        if typ=="file":continue #files are not passed through service interface
        params.append(name)
        if typ == "pyobj":
          pyparams.append("      %s=pickle.dumps(%s,-1)" %(name, name))
      outparams = ",".join(params)
      convertoutparams = '\n'.join(pyparams)
      #dedent and indent the body
      body=textwrap.dedent(serv.body)
      body=indent(body,' '*6)

      service = pyService.substitute(component=self.name, service=serv.name, inparams=inparams,
                                     outparams=outparams, body= body,
                                     convertinparams=convertinparams,
                                     convertoutparams=convertoutparams)
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

    inheritedclass=self.inheritedclass
    callconstructor=""
    if self.inheritedclass:
      inheritedclass= self.inheritedclass + ","
      callconstructor="""
    if hasattr(%s,"__init__"):
      %s.__init__(self)""" % (self.inheritedclass,self.inheritedclass)

    return pyCompo.substitute(component=self.name, module=gen.module.name,
                              servicesdef="\n".join(defs), servicesimpl="\n".join(services),
                              initservice='\n'.join(inits),
                              python_path=python_path,inheritedclass=inheritedclass,
                              compodefs=self.compodefs, callconstructor=callconstructor)

  def makepyexe(self, gen):
    """generate standalone component source (python executable)"""
    services = []
    inits = []
    defs = []
    for serv in self.services:
      defs.append(serv.defs)
      params = []
      pyparams = []
      for name, typ in serv.inport:
        if typ=="file":continue #files are not passed through service interface
        params.append(name)
        if typ == "pyobj":
          pyparams.append("      %s=pickle.loads(%s)" %(name, name))
      inparams = ",".join(params)
      convertinparams = '\n'.join(pyparams)

      params = []
      pyparams = []
      for name, typ in serv.outport:
        if typ=="file":continue #files are not passed through service interface
        params.append(name)
        if typ == "pyobj":
          pyparams.append("      %s=pickle.dumps(%s,-1)" %(name, name))
      outparams = ",".join(params)
      convertoutparams = '\n'.join(pyparams)
      #dedent and indent the body
      body=textwrap.dedent(serv.body)
      body=indent(body,' '*6)
      service = pyService.substitute(component=self.name, service=serv.name,
                                     inparams=inparams, outparams=outparams,
                                     body=body,
                                     convertinparams=convertinparams,
                                     convertoutparams=convertoutparams,
                                    )
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

    inheritedclass=self.inheritedclass
    callconstructor=""
    if self.inheritedclass:
      inheritedclass= self.inheritedclass + ","
      callconstructor="""
    if hasattr(%s,"__init__"):
      %s.__init__(self)""" % (self.inheritedclass,self.inheritedclass)

    return pyCompoEXE.substitute(component=self.name, module=gen.module.name,
                                 servicesdef="\n".join(defs),
                                 servicesimpl="\n".join(services),
                                 initservice='\n'.join(inits),
                                 python_path=python_path,inheritedclass=inheritedclass,
                                 compodefs=self.compodefs, callconstructor=callconstructor)

