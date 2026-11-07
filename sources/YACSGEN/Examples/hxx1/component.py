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
from module_generator import Generator,Module,Service
from module_generator import CPPComponent,PYComponent,HXX2SALOMEComponent
class Invalid(Exception):
    pass

kernel_root_dir=os.environ["KERNEL_ROOT_DIR"]
gui_root_dir=os.environ["GUI_ROOT_DIR"]
yacs_root_dir=os.environ["YACS_ROOT_DIR"]
med_root_dir=os.environ["MED_ROOT_DIR"]
geom_root_dir=os.environ["GEOM_ROOT_DIR"]
SALOME_ROOT=os.getenv("SALOME_DIR")
prereq_file=os.path.join(SALOME_ROOT, "salome_prerequisites.sh")

if not os.path.exists(prereq_file):
    prereq_file=os.path.join(kernel_root_dir,"..","..","env_products.sh")
if not os.path.exists(prereq_file):
    raise Invalid("prerequisite file env_products.sh not found. please replace it manually in component.py")

#import context from ..
context={'update':1,
         "makeflags":"",
         "prerequisites":prereq_file,
         "kernel":kernel_root_dir,
         "gui":gui_root_dir,
         "geom":geom_root_dir,
         "med":med_root_dir,
         "yacs":yacs_root_dir,
        }

cwd=os.getcwd()
cpppath=os.path.join(cwd,"COMPONENTCPP_INSTALL")

    
# PUT HERE DEFINITIONS OF THE COMPONENTS AND THE SERVICES


os.environ["CALCULCPP_ROOT_DIR"]=cpppath
os.environ["ICOCOCPP_ROOT_DIR"]=cpppath
c1=HXX2SALOMEComponent("CALCUL.hxx","libCALCULCXX.so" , cpppath )
c4=HXX2SALOMEComponent("ICOCO.hxx","libICOCOCXX.so" , cpppath )


g=Generator(Module("hxxcompos",components=[c4,c1],prefix="./install"),context)
g.generate()
g.configure()
g.make()
g.install()
g.make_appli("appli",
             restrict=["KERNEL","GUI","YACS","MED","GEOM"],
#             altmodules={"GUI":gui_root_dir,
#                         "MED":med_root_dir,
#                         "YACS":yacs_root_dir,
#                         "GEOM":geom_root_dir})
            )
cppenv=""" export CALCULCPP_ROOT_DIR=%(cpppath)s
export ICOCOCPP_ROOT_DIR=%(cpppath)s """  % {"cpppath" : cpppath}

cppenvfile=open("appli/env.d/cppEnv.sh","w")
cppenvfile.write(cppenv)
cppenvfile.close()
