A Code_Aster component dynamically loadable
===============================================

To build this example, modify the files ../context.py, ../makefile.inc, fcompo/Makefile, myaster/Makefile
to take into account your configuration.

1- your prerequisite file 
2- your KERNEL_ROOT_DIR
3- your Code_Aster installation
4- your FORTRAN compiler

Then set the environment (including PYTHONPATH for YACSGEN, ../.. from here)::

  source <your prerequisite file>

Build the fcompo library ::

  cd fcompo
  make

Build the Code_Aster library ::

  cd myaster
  make

process components.py ::

  python components.py

You should get a SALOME module in source form (astmod_SRC), its installation (install) and
a SALOME application (appli) composed of modules KERNEL, GUI, YACS and the new module astmod.

To run a coupling:

 1. start SALOME in background : ./appli/runAppli -t
 2. start a SALOME session : ./appli/runSession
 3. start YACS coupler with coupling file : driver coupling.xml
 4. examine output files in /tmp
 5. shutdown SALOME : shutdowSalome.py
 6. exit session : CTRL-D (or exit)
