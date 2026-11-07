*****************
SAT version 5.9.1
*****************

Release Notes, January 2025
============================


New features and improvements
-----------------------------


**New option: --with-extra.env.d**

to create one environment file per product, run: ::

  ./sat launcher <application> --with-extra.env.d

SAT will create one environment file per product in subdirectory: ``extra.env.d``. These environment files will then be dynamically loaded by the SALOME launcher.

To generate an application archive with one environment file per product, run: ::

  ./sat package <application> --with-extra.env.d

