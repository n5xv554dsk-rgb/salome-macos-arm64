.. _config:

Exposing a module's configuration (advanced)
============================================

.. _cfg_principle:

Principle
---------

When invoking the FIND_PACKAGE() command in CMake, two modes are possible:

* MODULE mode - this is the standard mode. CMake then looks for a file called FindXXX.cmake, pre-sets some variables (indicating if the package is required, etc ... see :ref:`pkg_impl`) and invokes the code in the macro. 
* CONFIG (or NO_MODULE) mode - if the package was itself compiled with CMake, it might offer a file called xyz-config.cmake or XyzConfig.cmake (where <Xyz> is the case-sensitive name of the package) exposing the configuration elements for an usage by a dependent project. This mechanism allows to remain in a pure CMake logic, where the package detection triggers the inclusion of the targets it references. Those targets can then be used directly. For example finding HDF5 in CONFIG mode allows to directly reference the "hdf5" target (and to link against it). It also provides the ability to pass more configuration elements than just libraries and binaries (for example user options for compilation, etc ...)

Take a look at the official CMake documentation for more details.

With this last setup (and if done properly!), a project can theoritically be either:

* configured, built and installed in a standalone fashion
* or have its sources directly be included as a sub-folder in the soure code of another bigger project. An ADD_SUBDIRECTORY in the root CMakeLists.txt of the encapsulating project should then trigger the proper configuration/build of the sub-project. 

The last point was however never tested in the SALOME context, and probably needs some further debug.

In the SALOME context this logic offers the advantage to have a minimal specification on the prerequisites. Technically one just needs to set the _ROOT_DIR variables for the packages that were never found before, and to get "for free" what was already found in a dependent module (for example Qt4 in GUI, but not OmniORB as it was already used by KERNEL). This works thanks to the exposition of all the ROOT_DIR used by one module into its configuration file. This can then be automatically reused by a dependent module.

Inspired from the CMake tutorial (http://www.cmake.org/Wiki/CMake/Tutorials/How_to_create_a_ProjectConfig.cmake_file) some 
important module use this scheme and install the \*Config.cmake files facilitating the configuration of other dependent modules. Most important SALOME modules (KERNEL, GUI, FIELDS) expose their configuration in such a way. 


Guidelines
----------

* When writing such CMake files, care must be taken to use PROJECT_BINARY_DIR and PROJECT_SOURCE_DIR variables instead of CMAKE_BINARY_DIR and CMAKE_SOURCE_DIR. This ensures that the project will also work properly when included as a sub-folder of a bigger project.
* The use of the local (or global) CMake Registry (via the EXPORT(PACKAGE ...) command) is not recommended. This overrides some of the FIND_PACKAGE mechanisms and quickly becomes a mess when compiling several versions of the same package on the same machine (typically the case for SALOME developers).
* Only level one dependency configurations are exported in the XXXConfig.cmake files (direct dependencies). See below :ref:`config_file` how the level 2 dependencies are automatically reloaded.
* Care must be taken to explicitly request a target to be part of the export set in the code sub-folders, when installing it  (EXPORT option)::

    INSTALL(TARGETS kerncompo kern_main
       # IMPORTANT: Add the library kerncompo to the "export-set" so it will be available 
       # to dependent projects
       EXPORT ${PROJECT_NAME}Targets
       LIBRARY DESTINATION "${INSTALL_LIB_DIR}"
       RUNTIME DESTINATION "${INSTALL_BIN_DIR}")


The rules are a bit lengthy but very generic. The idea is to define a set of targets to be exported, and to then explicitly
call the export command to generate the appropriate files (some fragments have been cut for readability).
The standard CMake macro CONFIGURE_PACKAGE_CONFIG_FILE() and WRITE_BASIC_PACKAGE_VERSION_FILE() (both located
in CMakePackageConfigHelpers) help generate a suitable configuration file (see next section)::

  # Configuration export
  # ====================
  INCLUDE(CMakePackageConfigHelpers)

  # List of targets in this project we want to make visible to the rest of the world.
  # They all have to be INSTALL'd with the option "EXPORT ${PROJECT_NAME}TargetGroup"
  SET(_${PROJECT_NAME}_exposed_targets
    CalciumC SalomeCalcium DF Launcher  
  ...)
    
  # Add all targets to the build-tree export set
  EXPORT(TARGETS ${_${PROJECT_NAME}_exposed_targets}
    FILE ${PROJECT_BINARY_DIR}/${PROJECT_NAME}Targets.cmake)

  # Create the configuration files:
  #   - in the build tree:

  #      Ensure the variables are always defined for the configure:
  SET(CPPUNIT_ROOT_DIR "${CPPUNIT_ROOT_DIR}")
  ...
   
  SET(CONF_INCLUDE_DIRS "${PROJECT_SOURCE_DIR}/include" "${PROJECT_BINARY_DIR}/include")
  CONFIGURE_PACKAGE_CONFIG_FILE(salome_adm/cmake_files/${PROJECT_NAME}Config.cmake.in 
      ${PROJECT_BINARY_DIR}/${PROJECT_NAME}Config.cmake
      INSTALL_DESTINATION "${SALOME_INSTALL_CMAKE}"
      PATH_VARS CONF_INCLUDE_DIRS SALOME_INSTALL_CMAKE CMAKE_INSTALL_PREFIX
          ...)

  #   - in the install tree:
  #       Get the relative path of the include directory so 
  #       we can register it in the generated configuration files:
  SET(CONF_INCLUDE_DIRS "${CMAKE_INSTALL_PREFIX}/${INSTALL_INCLUDE_DIR}")
  CONFIGURE_PACKAGE_CONFIG_FILE(salome_adm/cmake_files/${PROJECT_NAME}Config.cmake.in 
      ${PROJECT_BINARY_DIR}/to_install/${PROJECT_NAME}Config.cmake
      INSTALL_DESTINATION "${SALOME_INSTALL_CMAKE}"
      PATH_VARS CONF_INCLUDE_DIRS SALOME_INSTALL_CMAKE CMAKE_INSTALL_PREFIX 
        ...)

  WRITE_BASIC_PACKAGE_VERSION_FILE(${PROJECT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake
      VERSION ${${PROJECT_NAME_UC}_VERSION}
      COMPATIBILITY AnyNewerVersion)
    
  # Install the CMake configuration files:
  INSTALL(FILES
    "${PROJECT_BINARY_DIR}/to_install/${PROJECT_NAME}Config.cmake"
    "${PROJECT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake"
    DESTINATION "${SALOME_INSTALL_CMAKE}")

  # Install the export set for use with the install-tree
  INSTALL(EXPORT ${PROJECT_NAME}TargetGroup DESTINATION "${SALOME_INSTALL_CMAKE}" 
          FILE ${PROJECT_NAME}Targets.cmake)


.. _config_file:

Configuration file
------------------

The configuration file exposed in the build tree (e.g. SalomeGUIConfig.cmake) and in the install tree is itself configured by CMake by substituing variables and other stuff in a template file (e.g. SalomeGUIConfig.cmake.in).

We present here the config file of GUI as it loads itself the KERNEL. 

The first part does some initialization (the tag @PACKAGE_INIT@ is expanded by the macro CONFIGURE_PACKAGE_CONFIG_FILE() and serves mainly to locate the root directory of the installation)::

  ### Initialisation performed by CONFIGURE_PACKAGE_CONFIG_FILE:
  @PACKAGE_INIT@


The target file is loaded only if a representative target of the project (here in GUI the target ''Event'') is not already defined. This distinguishes between an inclusion of the project directly in the source directory or after a full standalone installation (see :ref:`cfg_principle` above)::

  # Load the dependencies for the libraries of @PROJECT_NAME@ 
  # (contains definitions for IMPORTED targets). This is only 
  # imported if we are not built as a subproject (in this case targets are already there)
  IF(NOT TARGET Event AND NOT @PROJECT_NAME@_BINARY_DIR)
    INCLUDE("@PACKAGE_SALOME_INSTALL_CMAKE@/@PROJECT_NAME@Targets.cmake")
  ENDIF()   

Note how the variable SALOME_INSTALL_CMAKE is prefixed with PACKAGE_SALOME_INSTALL_CMAKE. With this setup the helper macro CONFIGURE_PACKAGE_CONFIG_FILE() is able to adjust correctly the path (contained in SALOME_INSTALL_CMAKE) to always point to the right place (regardless of wether the SalomeGUIConfig.cmake file is in the build tree or in the install tree).
This is why the variable SALOME_INSTALL_CMAKE is passed as an argument when calling CONFIGURE_PACKAGE_CONFIG_FILE(). 

The user options, and the directories of the level 1 prerequisites (i.e. direct dependencies) are exposed in a variable called ''XYZ_ROOT_DIR_EXP'' (note the trailing ''EXP'' like EXPosed). This will be used by the package detection logic to check for potential conflicts.
The @PACKAGE_XYZ_ROOT_DIR@ variables are expanded by CONFIGURE_PACKAGE_CONFIG_FILE(). If you want to use a @PACKAGE_XYZ_ROOT_DIR@ in the config file, don't forget to add explicitly the XYZ_ROOT_DIR variable to the list of variables to be expanded by CONFIGURE_PACKAGE_CONFIG_FILE():: 

  # Package root dir:
  SET_AND_CHECK(GUI_ROOT_DIR_EXP "@PACKAGE_CMAKE_INSTALL_PREFIX@")

  # Include directories
  SET_AND_CHECK(GUI_INCLUDE_DIRS "${GUI_ROOT_DIR_EXP}/@SALOME_INSTALL_HEADERS@")
  SET(GUI_DEFINITIONS "@KERNEL_DEFINITIONS@")

  # Options exported by the package:
  SET(SALOME_USE_MPI     @SALOME_USE_MPI@)
  ...

  # Advanced options
  SET(SALOME_USE_OCCVIEWER    @SALOME_USE_OCCVIEWER@)
  ...

  # Level 1 prerequisites:
  SET_AND_CHECK(KERNEL_ROOT_DIR_EXP "@PACKAGE_KERNEL_ROOT_DIR@")
  SET_AND_CHECK(SIP_ROOT_DIR_EXP "@PACKAGE_SIP_ROOT_DIR@")
  ...

  # Optional level 1 prerequisites:
  IF(SALOME_USE_OCCVIEWER)
    SET_AND_CHECK(CAS_ROOT_DIR_EXP "@PACKAGE_CAS_ROOT_DIR@")    
  ENDIF()
  ...

Then a specific logic is included to ensure the following: if a prerequisite of GUI was detected and used (in GUI) in CONFIG mode, then its targets should be included again when a third project uses GUI. For example, if GUI uses VTK, and VTK was found if CONFIG mode, it means that some GUI libraries were linked directly using a reference to a VTK target instead of a full path (simply ''vtkCommon'' instead of ''/usr/lib/bla/bli/libvtkCommon.so''). A project which needs to link on GUI must then also be able to link (indirectly) against VTK (which is just referred as ''-lvtkCommon'' in the GUI library description exposed by CMake).

This avoids having to set the LD_LIBRARY_PATH (or PATH under Windows).

The following loop detects such a situation (there is always a variable Xyz_DIR when the package was found in CONFIG mode) and reloads if necessary the corresponding target by calling FIND_PACKAGE() in CONFIG mode on the exact same directory. This is done for all level 1 prerequisites of GUI, and would in our case expose the target ''vtkCommon'' to a project linking against GUI::

  # For all prerequisites, load the corresponding targets if the package was used 
  # in CONFIG mode. This ensures dependent projects link correctly
  # without having to set LD_LIBRARY_PATH:
  SET(_PREREQ CAS OpenGL PyQt4 Qt4 Qwt SIP VTK)
  SET(_PREREQ_CONFIG_DIR "@CAS_DIR@" "@OpenGL_DIR@" "@PyQt4_DIR@" "@Qt4_DIR@" "@Qwt_DIR@" "@SIP_DIR@" "@VTK_DIR@")
  LIST(LENGTH _PREREQ_CONFIG_DIR _list_len)
  # Another CMake stupidity - FOREACH(... RANGE r) generates r+1 numbers ...
  MATH(EXPR _range "${_list_len}-1")
  FOREACH(_p RANGE ${_range})  
    LIST(GET _PREREQ            ${_p} _pkg    )
    LIST(GET _PREREQ_CONFIG_DIR ${_p} _pkg_dir)
    IF(_pkg_dir)
       MESSAGE(STATUS "===> Reloading targets from ${_pkg} ...")
       FIND_PACKAGE(${_pkg} REQUIRED NO_MODULE 
            PATHS "${_pkg_dir}" 
            NO_DEFAULT_PATH)
    ENDIF()
  ENDFOREACH()

We also make sure, in the case of GUI, that the same is done for KERNEL's targets::

  # Include KERNEL targets if they were not already loaded:
  IF(NOT (TARGET SALOMEBasics)) 
    INCLUDE("${KERNEL_ROOT_DIR_EXP}/${SALOME_INSTALL_CMAKE}/SalomeKERNELTargets.cmake")
  ENDIF()

We finally expose the installation directories and define the target variables that will be used to link against targets given in the export list::

  # Installation directories
  SET(SALOME_INSTALL_BINS "@SALOME_INSTALL_BINS@")
  SET(SALOME_INSTALL_LIBS "@SALOME_INSTALL_LIBS@")
  ...

  # Exposed GUI targets:
  SET(GUI_caf caf)
  SET(GUI_CAM CAM)
  ...






