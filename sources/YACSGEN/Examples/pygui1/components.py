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

import os

#import context from ..
exec(compile(open("../context.py").read(), "../context.py", 'exec'))

from module_generator import *

defs="""
"""

body="""
      c=a+b
      d=a-b
"""

idldefs="""
#include "myinterface.idl"
"""

compodefs=r"""
import SALOME_DriverPy
import traceback

class A(SALOME_DriverPy.SALOME_DriverPy_i):
    def __init__(self):
      SALOME_DriverPy.SALOME_DriverPy_i.__init__(self,"pycompos")
      return

    def createObject( self, study, name ):
      "Create object.  "
      try:
        print (study,name)
        builder = study.NewBuilder()
        father = study.FindComponent( "pycompos" )
        if father is None:
            father = builder.NewComponent( "pycompos" )
            attr = builder.FindOrCreateAttribute( father, "AttributeName" )
            attr.SetValue( "pycompos" )

        object  = builder.NewObject( father )
        attr    = builder.FindOrCreateAttribute( object, "AttributeName" )
        attr.SetValue( name )
      except:
        traceback.print_exc()

    def DumpPython( self, study, isPublished ):
       abuffer = []
       abuffer.append( "def RebuildData( theStudy ):" )
       names = []
       father = study.FindComponent( "pycompos" )
       if father:
           iter = study.NewChildIterator( father )
           while iter.More():
               name = iter.Value().GetName()
               if name: names.append( name )
               iter.Next()
               pass
           pass
       if names:
           abuffer += [ "  from salome import lcc" ]
           abuffer += [ "  import pycompos_ORB" ]
           abuffer += [ "  " ]
           abuffer += [ "  compo = lcc.FindOrLoadComponent( 'FactoryServerPy', 'pycompos' )" ]
           abuffer += [ "  " ]
           abuffer += [ "  compo.createObject( theStudy, '%s' )" % name for name in names ]
           pass
       abuffer += [ "  " ]

       return ("\n".join( abuffer ), 1)

"""

c1=PYComponent("pycompos",services=[
          Service("s1",inport=[("a","double"),("b","double")],
                       outport=[("c","double"),("d","double")],
                       defs=defs,body=body,
                 ),
         ],
              idls=["*.idl"],
              interfacedefs=idldefs,
              inheritedinterface="Idl_A",
              compodefs=compodefs,
              inheritedclass="A",
         )

modul=Module("pycompos",components=[c1],prefix="./install",
              doc=["*.rst","*.png"],
              gui=["pycomposGUI.py","demo.ui","*.png"],
            )

g=Generator(modul,context)
g.generate()
#g.configure("-DTBB_INCLUDE_DIR=/opt/tbb/2018.u6/include  -DTBB_ROOT=/opt/tbb/2018.u6/")
g.configure()
g.make()
g.install()
g.make_appli("appli", restrict=["KERNEL"], altmodules={"GUI":GUI_ROOT_DIR,
                                "YACS":YACS_ROOT_DIR}, sys_modules=SYS_MODULES)


