Various guidelines and conventions (advanced)
=============================================

.. _debug:

Debugging CMake
---------------

CMake generates a build process which is per default much less verbose than the Autotools one. 
One doesn't see automatically the compilation/linking commands being invoked. 
Each of the following solutions displays the full command line for each build action::

  make VERBOSE=1
  env VERBOSE=1 make
  export VERBOSE=1; make

To have this by default for every build, one can specify this setting at the configuration 
step by toggling the CMAKE_VERBOSE_MAKEFILE to ON.

Normally detection problems are wrapped by the macro SALOME_FIND_PACKAGE_AND_DETECT_CONFLICTS() to print a simple error message that mostly shows the current content of the XYZ_ROOT_DIR variable. The developper can switch the flag::

  SALOME_CMAKE_DEBUG
  
to ON to see the full original CMake error message.

.. _conventions:

General conventions
-------------------
* Specify the languages used in the project::

    PROJECT(MyProject C CXX)

* the version of the module is specified in one place: the root CMakeLists.txt file via standard variables
* never, I said *NEVER*, specify includes or libraries by overriding COMPILE_FLAGS. CMake provide standard commands for this (INCLUDE_DIRECTORIES, TARGET_LINK_LIBRARIES) and produces much more portable build files! If a directory includes two or more targets that compulsory need different set of include dir, split into several subdirectories, and put the different targets in them (MEDFile has plenty of this).
* at present there is no management in SALOME of API versioning. So there is no need to deal with SO_VERSION in \*.so libraries (\*.so.1.2.3 …)
* No use of GLOBS for sources (\*.cxx), but GLOBS can be used for includes and \*.i on installation
* no \*.hxx in <SMTH>_SOURCES variable
* FIND_PACKAGE() is called only in root <Module>/CMakeLists.txt
* INCLUDE() directives, if needed, must come early in the file
* ADD_SUBDIRECTORY() directives, if needed, must be done just after INCLUDE and FIND_PACKAGE, then the specific part of subdirectory can be done
* INSTALL should be called at the end of the CMakelists.txt
* Create MACRO in \*.cmake to factorize some repetitive lines. (Try to) comment them. 
* All <Module>/CMakeLists.txt (see KERNEL_SRC/CMakeLists.txt) contains the definition of the variables which specify the location of installation directories. Only these variables should be used in subdirectories, and the model given in KERNEL should be followed.
* Use builtin WIN32 variable instead of WINDOWS variable to detect a Windows platform. Potentially avoid CYGWIN also::

    IF(WIN32 AND NOT CYGWIN)
     ...
    ENDIF()

* Use FILE(TO_CMAKE_PATH) instead of REPLACE(“\\” “/”) and FILE(TO_NATIVE_PATH) to convert a path to the CMake internal format
* Use strictly python to execute portably a script
* Use PROJECT_BINARY_DIR and PROJECT_SOURCE_DIR instead of CMAKE_BINARY_DIR and CMAKE_SOURCE_DIR. This helps having a proper behavior when the module is included as a sub-folder in the code of a bigger project.
* It is not necessary to rewrite the full text when closing a conditional statement or a control flow statement. This is up to you::

    IF(A_VERY_LONG_CONDITION)
      ..
    ENDIF() # no need to repeat A_VERY_LONG_CONDITION 

* When appending to CMake lists, the following syntax should be used::

    LIST(APPEND a_variable ${element1} ...)

* Names of variables used internally should start with an underscore
* For every path read from outside CMake (typically from an environment variable), the following conversion should be used to ensure the path format is compatible with the internal CMake syntax::

    FILE(TO_CMAKE_PATH ...)

* all install paths should be relative
* beware that variables inside macros are persistent (static) - do not assume they are reset everytime you re-enter the macro (think of a macro as a simple text subsitution at the place it was called)
* always use variables to reference targets, do not reference target directly (this will save some effort the day we want to rename a target ...)


.. _naming_conventions:

Naming conventions
------------------
They are few of them but let's try to be consistent:

* use upper case for CMake commands. For vars, the case is free. Why? As targets are generally in lower case it allows discriminating more easily CMake commands from local vars and targets.
* for sources the convention <Target>_SOURCES is used to store sources needed by target <Target>.
* for headers the convention <Target>_HEADERS is used to store headers to be installed in pair with <Target>.
* for all the variables set by a given package, the naming convention is based on a CMake prefix (upper case if possible)::

    <PRODUCE>_myVariable

* temporary variables (not used outside the macro or outside the module) should start with an underscore


.. _dependencies:

Parallel compilation - Correct dependencies
-------------------------------------------
Contrary to Autotools, CMake is working by targets and not by directories. If parallel compilation fails, it means that some dependencies are missing or not properly set. This can happen mainly with generated sources (such as the ones produced by the IDL compiler, or by SWIG).

The linked libraries of the target are automatically considered as dependency by CMake. But, for instance, when a library needs only generated includes from Kernel IDL (no link needed with the generated code for a CORBA client), the dependency should be explicitly added by the::

  ADD_DEPENDENCIES(<target> SalomeIDLKernel) 

command in the CMakeLists.txt.

To check parallel compilation (i.e. dependencies) of a target, the developer must start from an empty, generated by CMake build directory and use the “make (-jX) <target>”.

.. _cmd_conventions:

Command specific conventions
----------------------------

* INCLUDE(): only specify the name of the macro, e.g. INCLUDE(SalomeMacros). The directory is almost always already in the CMAKE_MODULE_PATH.
* Strings: variables representing strings or paths should always be used quoted. For example "${my_var}". This ensures a proper behavior if the string contains a semi-colonn
* appending an element to a list variable should be done with::

    LIST(APPEND xyz ...)

  and not with::
    
    SET(xyz ${xyz} ...)    



