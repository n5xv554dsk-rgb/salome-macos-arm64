A C++ standalone component (executable form)
=================================================

To build this example, modify the ../exec.sh file to take into account your configuration.
Run build.sh to build and test the component.

You should get a SALOME module in source form (cppcompos_SRC), its installation (install) and
a SALOME application (appli) composed of modules KERNEL, GUI, YACS and the new module cppcompos.
You also get the standalone component (executable named prog).

To run a coupling:

 1. start SALOME in background : ./appli/runAppli -t
 2. start a SALOME session : ./appli/runSession
 3. start YACS coupler with coupling file : driver coupling.xml
 4. examine output files in /tmp
 5. shutdown SALOME : shutdowSalome.py
 6. exit session : CTRL-D (or exit)
