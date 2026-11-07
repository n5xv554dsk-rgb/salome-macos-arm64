A example of a MPI component 
=========================================

To build this example, modify the ../exec.sh file to take into account your configuration.
Run build.sh to build and test the component.

You should get a SALOME module in source form (mymodule_SRC), its installation (install) and
a SALOME application (appli) composed of modules KERNEL, GUI, YACS and the new module cppcompos.

To run a coupling:

 1. start SALOME in background : ./appli/salome -t
 2. run the example schema in a SALOME session : ./appli/salome shell -- driver coupling.xml
 3. examine output files in /tmp
 4. shutdown SALOME : ./appli/salome killall
