# -*- coding: utf-8 -*-
import os
from module_generator import Generator,Module,Service
from module_generator import MPIComponent
from module_generator import Library

SALOME_ROOT=os.getenv("SALOME_DIR")
prerequis_file=os.path.join(SALOME_ROOT, "salome_prerequisites.sh")

kernel_root_dir=os.getenv("KERNEL_ROOT_DIR")
gui_root_dir=os.getenv("GUI_ROOT_DIR")
yacs_root_dir=os.getenv("YACS_ROOT_DIR")

context={'update':1,
         "makeflags":"-j2",
         "prerequisites":prerequis_file,
         "kernel":kernel_root_dir
        }

cwd=os.getcwd()

# PUT HERE DEFINITIONS OF THE COMPONENTS AND THE SERVICES
body_a="""
Mylibmpi myinstance;
res_val = myinstance.mympi_funct(in_val);
"""

defs_service="""
"""

service_s = Service("mpifunc",
                    inport=[("in_val", "long")],
                    outport=[("res_val", "long")],
                    body=body_a,
                    defs=defs_service
                    )

mpilib_root_path = os.path.join(cwd, "mpilib")
mpilib_include_path = os.path.join(mpilib_root_path, "include")
mpilib_lib_path = os.path.join(mpilib_root_path, "lib")

compodefs = """
#include "mylibmpi.h"
"""

compo=MPIComponent("mycompoMpi",
                 services=[service_s],
                 compodefs=compodefs,
                 libs=[Library(name="mylibmpi", path=mpilib_lib_path)],
                 rlibs=mpilib_lib_path,
                 includes=mpilib_include_path,
                )

g=Generator(Module("mymodule",components=[compo],prefix="./install"),context)
g.generate()
g.configure()
g.make()
g.install()
g.make_appli("appli",
             restrict=["KERNEL","GUI","YACS","JOBMANAGER"],
             sys_modules=SYS_MODULES)


