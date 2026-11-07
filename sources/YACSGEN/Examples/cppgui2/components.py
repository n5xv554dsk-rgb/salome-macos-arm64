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

#import context from ..
exec(compile(open("../context.py").read(), "../context.py", 'exec'))

import os
from module_generator import *


modul=Module("cppcompos",components=[],prefix="./install",
             doc=["*.rst",],
             gui=["cppcomposGUI.cxx","cppcomposGUI.h","demo.ui","*.png"],
            )

g=Generator(modul,context)
g.generate()
g.configure()
g.make()
g.install()
g.make_appli("appli", restrict=["KERNEL","GUI","YACS"], sys_modules=SYS_MODULES)

