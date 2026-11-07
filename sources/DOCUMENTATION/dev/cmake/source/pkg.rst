.. _package:

Package detection mechanism
===========================

SALOME modules need some external packages in order to compile and run properly. For example KERNEL relies on the Python libraries, on the Boost libraries, etc ... The correct detection of those prerequisites is a key point of the CMake build procedure.

Philosophy
----------

The philosophy of the SALOME package detection is, first, to rely as 
much as possible on the standard CMake detection modules (FindXyz.cmake files, located in the standard CMake installation directory).
It is assumed those modules will get better and better with newer releases of CMake
and using them ensures future compatibility with newer versions of CMake.

Second, the implementation of the detection process relies exclusively
on the XYZ_ROOT_DIR variable giving the installation path of the package. This means the user compiling SALOME should not have to set anything else than those XYZ variables (no PATH override, no LD_LIBRARY_PATH override should be necessary). This is not strictly always possible, but should enforce as often as possible.

Finally only the direct dependencies of a module should be explicitly detected: for example GUI has no source code which uses MPI functionalities. Hence GUI does not detect the MPI package. However if KERNEL was compiled with MPI, then some of the information (include directories, definitions, ...) needs to be propagated to GUI (in this case for example, MPI needs to be in the list of include directories, since GUI include KERNEL headers, which themselves include MPI headers). This is done exclusively through the variables exposed in the KERNEL configuration file: KERNEL_INCLUDE_DIRS, KERNEL_DEFINITIONS.

Root dir variables and priority order
-------------------------------------

The detection is however guided through a variable of the form XYZ_ROOT_DIR which
gives the root directory of an installation of the package. For example, to indicate
that we wish to use the Python installed in our home directory, one sets PYTHON_ROOT_DIR to
"/home/smith/Python-2.7.0".

The variable guiding the detection is always builts as::

  XYZ_ROOT_DIR

where <XYZ> is (*exactly*) the upper case name of the standard CMake module. For example, the
detection of Qt4 is guided by setting QT4_ROOT_DIR. The variables \*_ROOT_DIR are only there to guide the process, not to force it. Typically under Linux, one would never set PTHREAD_ROOT_DIR, thus leaving the logic find the system installation. 

Beware that package names in the CMakeLists.txt are case-sensitive, but the corresponding variables are always upper-case (because on some platforms environment variables are not case-sensitive).

The order of priority for the detection of a package is (from high to low priority):

1. CMake variables explicitly set by the user (typically on the command line with -DXYZ_ROOT_DIR=...)
2. Environment variables set by the user (with the same name XYZ_ROOT_DIR)
3. Default value based on a previous dependency using the tool already
4. Detection direclty in the host system by the standard CMake logic

CMake has two possible modes of detection, CONFIG mode and MODULE mode. The order of priority is explicitly set in SALOME to:

1. CONFIG (also called NO_MODULE) mode: this tries to load a xyz-config.cmake file from the package installation itself. Note that by default, this mode doesn't look at a potential system installation. If you do want the CONFIG mode to also inspect your system, you have to explicitly set the XYZ_ROOT_DIR variable to your system's path (typically "/usr").
2. MODULE mode: this relies on the logic written in a FindXyz.cmake macro, looking directly for representative libraries, binaries or headers of the package.

The first mode is preferred as it allows to directly include the CMake targets of the prerequisite.

The package detection is only made in the root CMakeLists.txt, potentially conditionned on some
user options. 

Writing the detection macro of a new SALOME prerequisite
--------------------------------------------------------

All detection macros are located under the soure directory::

  salome_adm/cmake_files

or::

  adm_local/cmake_files

All prerequisite detection in SALOME should be implemented by:

* writing a file FindSalome<Xyz>.cmake (note the extra ''Salome''), where <Xyz> matches *exactly* the name of the standard CMake module (see below if there is no standard module for <Xyz>)
* invoking FIND_PACKAGE() command in the root CMakeLists.txt::
  
    FIND_PACKAGE(SalomeLibXml2 REQUIRED)

* potentially, a prerequisite might be optional. In this case the following syntax is preferred::
  
    FIND_PACKAGE(SalomeLibXml2)
    SALOME_LOG_OPTIONAL_PACKAGE(LibXml2 SALOME_FOO_FEATURE)
    

* the custom macro SALOME_LOG_OPTIONAL_PACKAGE registers internally the fact that the package is optional, and the flag that can be changed to avoid its detection. The final status of what has been found or not can then be displayed by calling SALOME_PACKAGE_REPORT_AND_CHECK(). This will trigger the failure of the configuration process if some package is missing, and it will also display the flag that should be turned OFF to avoid the issue::

    # Final report and global check of optional prerequisites:
    SALOME_PACKAGE_REPORT_AND_CHECK()

Typically the FindSalome<Xyz>.cmake file looks like this::

    SALOME_FIND_PACKAGE_AND_DETECT_CONFLICTS(CppUnit CPPUNIT_INCLUDE_DIRS 1)
    MARK_AS_ADVANCED(CPPUNIT_INCLUDE_DIRS CPPUNIT_LIBRARIES CPPUNIT_CONFIG_BIN CPPUNIT_SUBLIB_cppunit CPPUNIT_SUBLIB_dl)

It invokes the SALOME macro SALOME_FIND_PACKAGE_AND_DETECT_CONFLICTS() which takes:

* as first argument the name of the package (here CppUnit), 
* as second argument, the name of a (path) variable set when the package is found properly, 
* as third argument, the number of levels this variable should be browsed up to reach the root directory of the package installation.
    

In the example above,

* we look for the package CppUnit (note that this is case-sensitive). There is already a standard CMake module to detect CppUnit, which sets the CMake variable CPPUNIT_INCLUDE_DIRS to the (list of) directories to include when compiling with CppUnit. 
* going one level up from the include directory (typically /usr/include) gives the root directory of the installation (/usr).
* all the variables exposed in the cache by the standard detection logic (CPPUNIT_INCLUDE_DIRS, CPPUNIT_LIBRARIES, etc ...) are marked as "advanced" so that they do not automatically appear in ccmake or cmake-gui.

Note that the reference variable may be a list, only its first element is then considered.

Writing a new generic detection macro (advanced)
------------------------------------------------

If you need to include in SALOME a prerequisite for which the standard CMake distribution 
doesn't provide the FindXyz.cmake module, you will need to write it yourself.
This also applies if you judge that the standard FindXyz.cmake CMake module doesn't do its job
properly (yes, it can happen).

The following guidelines apply:

* make the module as generic as possible, considering that it should also run properly outside SALOME. This separates clearly the basic detection of the package from the SALOME logic. Basically the module represents the point 4. in the order of priority given above and should behave as much as possible like any standard CMake module
* invoking the FIND_LIBRARY(), FIND_PROGRAM(), FIND_PATH() and FIND_FILE() commands should be done without specifying an explicit PATH option to the command (this is not always possible - see for example FindOmniORBPy.cmake). The idea is that the root directory for the search is set by the SALOME encapsulation (by setting CMAKE_PREFIX_PATH)
* document properly which variables you are setting, respecting the CMake standard (see for example FindOmniORB.cmake)
* use the CMake code found in many standard modules::

    INCLUDE(FindPackageHandleStandardArgs)
    FIND_PACKAGE_HANDLE_STANDARD_ARGS(Graphviz REQUIRED_VARS GRAPHVIZ_EXECUTABLE)


* This macro takes care (among other things) of setting the XYZ_FOUND variable (upper case), and of displaying a message if not in QUIET mode (TBC).
* the macro should be saved in the same directory as above
* respect the naming conventions for the variables you set (start with the package name, upper case - see :ref:`naming_conventions`)
* do not do any ADD_DEFINITIONS() or INCLUDE_DIRECTORIES() in such a macro. This should be done by the caller or in a UseXYZ.cmake file. The purpose of a FindXXX.cmake macro is to detect, not to make usable. This rule does not apply to FindSalomeXXX.cmake macros where we know we are always in the SALOME context.
* here is a simple example of the detection of Sphinx::

    # - Sphinx detection
    #
    # Output variable: SPHINX_EXECUTABLE
    #                  
    # 
    # The executable 'sphinx-build' is looked for and returned in the above variable.
    #

    ###########################################################################
    # Copyright (C) 2007-2026  CEA, EDF, OPEN CASCADE
    <...>
    ###########################################################################

    FIND_PROGRAM(SPHINX_EXECUTABLE sphinx-build)

    # Handle the standard arguments of the find_package() command:
    INCLUDE(FindPackageHandleStandardArgs)
    FIND_PACKAGE_HANDLE_STANDARD_ARGS(Sphinx REQUIRED_VARS SPHINX_EXECUTABLE)


.. _pkg_impl:

Implementation details (advanced)
---------------------------------

The core of the SALOME detection logic is located in the macro
SALOME_FIND_PACKAGE_AND_DETECT_CONFLICTS() implemented in KERNEL/salome_adm/cmake_files/SalomeMacros.cmake.

All the logic is thus concentrated in one (hopefully well documented) macro. This means: one place to fix if there is a bug, and better, one place to amend if we ever want to define a new behaviour (for example if we want to change the order of priorities between CONFIG and MODULE mode). The end user (someone developing in SALOME) just needs to call it. It is the responsability of the core SALOME developpers to understand and maintain this macro.

The reader is invited to have the code at hand when reading the following.

The macro signature is
::

  SALOME_FIND_PACKAGE_DETECT_CONFLICTS(pkg referenceVariable upCount)

where:

* *pkg*              : name of the system package to be detected
* *referenceVariable*: variable containing a path that can be browsed up to retrieve the package root directory (xxx_ROOT_DIR)
* *upCount*          : number of times we have to go up from the path <referenceVariable> to obtain the package root directory.

For example::  

  SALOME_FIND_PACKAGE_DETECT_CONFLICTS(SWIG SWIG_EXECUTABLE 2) 

The macro has a significant size but is very linear:

1. Load a potential env variable XYZ_ROOT_DIR as a default choice for the cache entry XYZ_ROOT_DIR.
   If empty, load a potential XYZ_ROOT_DIR_EXP as default value (path exposed by another package depending
   directly on XYZ)
2. Invoke FIND_PACKAGE() in this order:

  * in CONFIG mode first (if possible): priority is given to a potential "XYZ-config.cmake" file. In this mode, the standard system paths are skipped. If you however want to force a detection in CONFIG mode into a system path, you have to set explicitly the XYZ_ROOT_DIR variable to "/usr".
  * then switch to the standard MODULE mode, appending on CMAKE_PREFIX_PATH the above XYZ_ROOT_DIR variable.

3. Extract the path actually found into a temp variable _XYZ_TMP_DIR
4. Warn if XYZ_ROOT_DIR is set and doesn't match what was found (e.g. when CMake found the system installation
   instead of what is pointed to by XYZ_ROOT_DIR - happens when there is a typo in the content of XYZ_ROOT_DIR).
5. Conflict detection: check the temporary variable against a potentially existing XYZ_ROOT_DIR_EXP
6. Finally expose what was *actually* found in XYZ_ROOT_DIR.  This might be different from the initial XYZ_ROOT_DIR, but there has been a warning in such a case.


The specific stuff (for example exposing a prerequisite of XYZ to the rest of the world for future conflict detection) is added after the call to the macro by the callee. See for example the FindSalomeHDF5.cmake macro which exposes the MPI_ROOT_DIR if HDF5 was compiled with parallel support.

If the invokation of FIND_PACKAGE() was done with some options:

* QUIET, REQUIRED
* COMPONENTS
* VERSION [EXACT]

those options are completly handled through the analysis of the standard CMake variables (which are automatically set when those options are given):

* Xyz_FIND_QUIETLY and Xyz_FIND_REQUIRED
* Xyz_FIND_COMPONENTS
* Xyz_FIND_VERSION and Xyz_FIND_VERSION_EXACT





