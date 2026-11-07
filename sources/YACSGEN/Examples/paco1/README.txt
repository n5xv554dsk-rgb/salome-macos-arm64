A C++ component dynamically loadable
=========================================

To build this example, modify the components.py file
to take into account your configuration.

1- your prerequisite file 
2- your KERNEL_ROOT_DIR
3- your PaCO++ installed

Then set the environment (including PYTHONPATH for YACGEN, ../.. from here and execute components.py ::

  source <your prerequisite file>
  python components.py

You should get a SALOME module in source form (cppcompos_SRC), its installation (install) and
a SALOME application (appli) composed of modules KERNEL, GUI, YACS and cppcompos.

To run a coupling:

 1. start SALOME in background : ./appli/runAppli -t
 2. start a SALOME session : ./appli/runSession
 3. start YACS coupler with coupling file : driver coupling.xml
 4. examine output files in /tmp
 5. shutdown SALOME : shutdowSalome.py
 6. exit session : CTRL-D (or exit)
