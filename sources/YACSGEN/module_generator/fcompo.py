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

from module_generator.gener import Component
from module_generator.cppcompo import CPPComponent

import platform
archi = platform.architecture()[0]

if archi == "64bit":
  f77Types = {"double":"double *", "long":"int *", "string":"const char *"}
else:
  f77Types = {"double":"double *", "long":"long *", "string":"const char *"}

class F77Component(CPPComponent):
  """
   A :class:`F77Component` instance represents a Fortran SALOME component with services given as a list of :class:`Service`
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
   :param sources: gives all the external source files to add in the compilation step (list of paths).
   :param exe_path: is only used when kind is "exe" and gives the path to the standalone component.

   For example, the following call defines a Fortran component named "mycompo" with one service s1 (it must have been defined before).
   This component is implemented as a dynamic library linked with a user's library "mylib"::

      >>> c1 = module_generator.F77Component('mycompo', services=[s1,],
                                                       libs=[[Library(name="mylib", path=mydir)])

  """
  def __init__(self, name, services=None, libs=[], rlibs="", 
                     kind="lib", exe_path=None, sources=None):
    CPPComponent.__init__(self, name, services, libs=libs, rlibs=rlibs, 
                                kind=kind, exe_path=exe_path, sources=sources)
    self.impl = "F77"

  def makebody(self):
    """generate definitions (defs attribute of services) et bodys (body attribute of services)"""
    for serv in self.services:
      #defs generation
      params=[]
      if serv.instream or serv.outstream:
        params = ["void *compo"]
      strparams = []
      for name, typ in serv.inport:
        if typ == "file":continue #files are not passed through service interface
        if typ == "string":
          params.append("const STR_PSTR(%s)"%name)
          strparams.append("STR_PLEN(%s)"%name)
        else:
          params.append("%s %s" % (f77Types[typ], name))
      for name, typ in serv.outport:
        if typ == "file":continue #files are not passed through service interface
        if typ == "string":
          params.append("const STR_PSTR(%s)"%name)
          strparams.append("STR_PLEN(%s)"%name)
        else:
          params.append("%s %s" % (f77Types[typ], name))
      args = ','.join(params)+" " + " ".join(strparams)
      serv.defs = serv.defs+'\nextern "C" void F_FUNC(%s,%s)(%s);' % (serv.name.lower(), serv.name.upper(), args)

      #body generation
      params=[]
      if serv.instream or serv.outstream:
        params = ["&component"]
      strparams = []
      strallocs = []
      #length allocated for out string
      lstr = 20
      for name, typ in serv.inport:
        if typ == "file":continue #files are not passed through service interface
        if typ == "string":
          params.append("STR_CPTR(%s)" % name)
          strparams.append("STR_CLEN(%s)"%name)
        else:
          params.append("&%s" % name)
      for name, typ in serv.outport:
        if typ == "file":continue #files are not passed through service interface
        if typ == "string":
          params.append("STR_CPTR(%s.ptr())" % name)
          strparams.append("STR_CLEN(%s.ptr())"%name)
          strallocs.append('%s=CORBA::string_dup("%s");' %(name, " "*lstr))
        else:
          params.append("&%s" % name)
      serv.body = '\n'.join(strallocs)+'\n'+serv.body
      args = ','.join(params)+" " + " ".join(strparams)
      serv.body = serv.body+"\n   F_CALL(%s,%s)(%s);" % (serv.name.lower(), serv.name.upper(), args)

  def makeCompo(self, gen):
    """build a dictionary that defines component files
       dictionary key = file name
       dictionary value = file content or dictionary defining subdirectory content
    """
    self.makebody()
    return CPPComponent.makeCompo(self, gen)
