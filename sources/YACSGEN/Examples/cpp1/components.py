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
from module_generator import Generator,Module,Service,CPPComponent

cwd=os.getcwd()

body="""
std::cerr << "a: " << a << std::endl;
std::cerr << "b: " << b << std::endl;
int info;
double t1,t2;
int i=1;
int mval;
double val[10],rval[10];
val[0]=3.2;
cp_edb(component,CP_ITERATION,0.,1,"ba",1,val);
info=cp_ldb(component,CP_ITERATION,&t1,&t2,&i,"aa",1,&mval,rval);
std::cerr << "rval: " << rval[0] << std::endl;
c=2*rval[0];
std::cerr << "c: " << c << std::endl;
"""
c1=CPPComponent("compo1",services=[
          Service("s1",inport=[("a","double"),("b","double")],
                       outport=[("c","double")],
                       instream=[("aa","CALCIUM_double","I"),],
                       outstream=[("ba","CALCIUM_double","I"),],
                       defs="//def1",body=body,
                 ),
          ],
         calciumextendedinterface=1,
         )


g=Generator(Module("cppcompos",components=[c1],prefix="./install"),context)
g.generate()
g.configure()
g.make()
g.install()
g.make_appli("appli", restrict=["KERNEL"], altmodules={"GUI":GUI_ROOT_DIR,
                                "YACS":YACS_ROOT_DIR}, sys_modules=SYS_MODULES)

