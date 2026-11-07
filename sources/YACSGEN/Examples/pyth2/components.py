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
from module_generator import Generator,Module,Service,PYComponent

cwd=os.getcwd()


body="""
      #b1
      dep=calcium.CP_ITERATION
      val=numpy.zeros(10,'d')
      val[5]=a*b
      nval=10
      print ("--------> Appel calcium.cp_edb")
      info=calcium.cp_edb(component, dep, 0., 1, "ba", nval,val)
      val=numpy.zeros(10,'d')
      info,tt,ii,mval=calcium.cp_ldb(component, dep, 0.,1., 1, "aa", nval,val)
      print (mval,val)
      c=a+b
      d=a-b
      err=calcium.cp_fin(component,calcium.CP_ARRET)
"""
c1=PYComponent("compo2",services=[
          Service("s1",inport=[("a","double"),("b","double")],
                       outport=[("c","double"),("d","double")],
                       instream=[("aa","CALCIUM_double","I"),],
                       outstream=[("ba","CALCIUM_double","I"),],
                       defs="#def1",body=body,
                 ),
         ],
         kind="exe",
         )


g=Generator(Module("pycompos",components=[c1],prefix="./install"),context)
g.generate()
g.configure()
g.make()
g.install()
g.make_appli("appli", restrict=["KERNEL"], altmodules={"GUI":GUI_ROOT_DIR,
                                "YACS":YACS_ROOT_DIR}, sys_modules=SYS_MODULES)

