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
exec(compile(open("../pacocontext.py").read(), "../pacocontext.py", 'exec'))
from module_generator import Generator,Module,Service,PACOComponent

cwd=os.getcwd()

body="""
c = a + b;
"""

c1=PACOComponent("paco1",
                 "dummy",
                 services=[
                   Service("run",inport=[("a","double"),("b","double")],
                           outport=[("c","double")],
                           body=body,
                           impl_type="parallel"
                          ),
                ],
               )


g=Generator(Module("pacocompos",components=[c1],prefix="./install"),context)
g.generate()
g.bootstrap()
g.configure()
g.make()
g.install()
g.make_appli("appli", restrict=["KERNEL"], altmodules={"GUI":GUI_ROOT_DIR,
                                "YACS":YACS_ROOT_DIR}, sys_modules=SYS_MODULES)

