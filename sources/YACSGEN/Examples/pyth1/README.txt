A Python component dynamically loadable
===============================================

To build this example, modify the ../exec.sh file to take into account your configuration.
Run build.sh to build and test the component.

You should get a SALOME module in source form (pycompos_SRC), its installation (install) and
a SALOME application (appli) composed of modules KERNEL, GUI, YACS and the new module pycompos.

To run a coupling:

 1. start SALOME in background : ./appli/runAppli -t
 2. start a SALOME session : ./appli/runSession
 3. start YACS coupler with coupling file : driver coupling.xml
 4. examine output files in /tmp
 5. shutdown SALOME : shutdowSalome.py
 6. exit session : CTRL-D (or exit)
