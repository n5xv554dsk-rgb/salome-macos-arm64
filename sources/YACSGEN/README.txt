

YACSGEN : Component and module generator for SALOME
=====================================================

YACSGEN is a python package (module_generator) to generate a SALOME module
automatically from a short description of the components it shall contain.
That description is done with the python language.

It is not able to handle all kinds of component (components with GUI, for example) but it
should be sufficient to ease integration of many scientific codes.
It is mainly aimed at integration of Fortran libraries into which are done calls to 
SALOME/YACS coupling API (datastream ports, to be more precise).

More details can be found in the SALOME/YACS documentation.

Supported python versions and architectures 
-----------------------------------------------------------------
module_generator uses python 2.4 functionalities (string template) but it has a compatibility 
mode to work with python 2.3.

It can work on 32 bits architecture as well as 64 bits (lightly tested).

Installation
----------------------------
First uncompress and untar the archive file then use one of the two following methods.

1. Use python way::

    python setup.py install

2. Add the directory containing module_generator to your PYTHONPATH

Examples
-------------
You can find some examples of using YACSGEN for Fortran, C++ and Python components
in the examples directory.

