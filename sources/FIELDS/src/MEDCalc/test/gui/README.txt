test_qttesting.py
=================

Tests based on QtTesting framework from ParaView.
Main entry point is test_qttesting.py.
Each scenario is described in a XML file and can be recorded directly in the GUI via the "Record test" button. 

A scenario must save a final screenshot of the ParaView view in a file located in the temp directory (TODO: review
this). This file is compared against a baseline saved in the baselines subdirectory.


guiTester.pro 
=============

This is a simple Qt framework to test the dialog widgets.

To build the project:
* specify the sources files in the .pro file
* run qmake, then make
* run guiTester

To clean the project:
* run "make clean"
* remove binary and Makefile
  $ rm guiTester Makefile
