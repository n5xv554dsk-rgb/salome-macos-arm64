.. _skeleton:

Anatomy of a CMakeLists.txt file
================================

Root CMakeLists.txt
-------------------

The root CMakeLists.txt should contain the following elements:

* Versioning: definition of the major, minor and patch version number. This is the sole place where those numbers should be defined.
* Platform setup: specific flags, detection of the architecture, ... This it typically done by including the SalomeSetupPlatform macro.
* User option definitions: in SALOME the following flags should be found in all modules:

  * SALOME_USE_MPI: wether Salome should be built using MPI containers
  * SALOME_BUILD_TESTS: wether the unit tests should be built
  * SALOME_BUILD_DOC: wether the documentation for the current module should be generated and installed

  Other flags specific to the module might be added, and should then start with *SALOME_XYZ_* where <XYZ> is the module's name (FIELDS for example).

* Detection of the required prerequisites for the module. All prerequisites in SALOME are detected through a call to FIND_PACKAGE(SalomeXYZ ...). See section :ref:`package`::

    FIND_PACKAGE(SalomePython REQUIRED)
    FIND_PACKAGE(SalomePThread REQUIRED)
    FIND_PACKAGE(SalomeSWIG REQUIRED)


* Detection of the optional prerequisites (potentially conditioned on some user options - see :ref:`package` for more on this)::

    IF(SALOME_BUILD_DOC)
      FIND_PACKAGE(SalomeDoxygen)
      FIND_PACKAGE(SalomeGraphviz)
      FIND_PACKAGE(SalomeSphinx)
      SALOME_UPDATE_FLAG_AND_LOG_PACKAGE(Doxygen SALOME_BUILD_DOC)
      SALOME_UPDATE_FLAG_AND_LOG_PACKAGE(Graphviz SALOME_BUILD_DOC)
      SALOME_UPDATE_FLAG_AND_LOG_PACKAGE(Sphinx SALOME_BUILD_DOC)
    ENDIF(SALOME_BUILD_DOC)


* Printing a report about the detection status::

    SALOME_PACKAGE_REPORT()


* Common installation directories. Those directories should be used consistently across all SALOME modules::

    SET(SALOME_INSTALL_BINS bin/salome CACHE PATH "Install path: SALOME binaries")
    SET(SALOME_INSTALL_LIBS lib/salome CACHE PATH "Install path: SALOME libs")
    SET(SALOME_INSTALL_IDLS idl/salome CACHE PATH "Install path: SALOME IDL files")
    SET(SALOME_INSTALL_HEADERS include/salome CACHE PATH "Install path: SALOME headers")
    SET(SALOME_INSTALL_SCRIPT_SCRIPTS ${SALOME_INSTALL_BINS} CACHE PATH "Install path: SALOME scripts")
    ...


* Specific installation directories. Those should start with SALOME_<MODULE>::

    SET(SALOME_GUI_INSTALL_PARAVIEW_LIBS lib/paraview CACHE PATH "Install path: SALOME GUI ParaView libraries")
    SET(SALOME_GUI_INSTALL_RES_DATA "${SALOME_INSTALL_RES}/gui" CACHE PATH "Install path: SALOME GUI specific data")    
    ...


* Inclusion of the source code directories to be compiled::

    IF(NOT SALOME_LIGHT_ONLY)
      ADD_SUBDIRECTORY(idl)
    ENDIF()
    ADD_SUBDIRECTORY(src)


* Header configuration: creation of the version header files, among other
* Configuration export (see dedicated section :ref:`config`)


CMakeLists.txt dedicated to the build of a target
-------------------------------------------------

First, include directories::

  INCLUDE_DIRECTORIES(
    ${OMNIORB_INCLUDE_DIR}
    ${PTHREAD_INCLUDE_DIRS}
    ${PROJECT_BINARY_DIR}/salome_adm
    ${CMAKE_CURRENT_SOURCE_DIR}/../Basics
    ${CMAKE_CURRENT_SOURCE_DIR}/../SALOMELocalTrace
    ${CMAKE_CURRENT_SOURCE_DIR}/../Utils
    ${PROJECT_BINARY_DIR}/idl
    )

Then we define the sources list <target>_SOURCES::

  SET(SalomeNS_SOURCES
    SALOME_NamingService.cxx
    ServiceUnreachable.cxx
    NamingService_WaitForServerReadiness.cxx
  )

Set the common compilation flags of all targets of the directory::

  ADD_DEFINITIONS(${OMNIORB_DEFINITIONS})

Ensure dependencies are correctly set, if needed (please refer to :ref:`dependencies`)::

  ADD_DEPENDENCIES(SalomeNS SalomeIDLKernel)

Then the standard way to compile, link and install a library or executable is::

  ADD_LIBRARY(SalomeNS ${SalomeNS_SOURCES})
  TARGET_LINK_LIBRARIES(SalomeNS OpUtil)
  INSTALL(TARGETS SalomeNS DESTINATION ${SALOME_INSTALL_LIBS})

Note that there is no SHARED reference, no SET_TARGET_PROPERTIES( .. COMPILE_FLAGS ..). If you need to link against a KERNEL or other SALOME target, use the variable name of the target, not the target directly::

  TARGET_LINK_LIBRARIES(xyz ${KERNEL_SalomeNS})   # OK
  TARGET_LINK_LIBRARIES(xyz SalomeNS)             # Bad!!

Finally write the specific installation rule for scripts or headers::

  SALOME_INSTALL_SCRIPTS(SALOME_NamingServicePy.py ${SALOME_INSTALL_SCRIPT_SCRIPTS})
  FILE(GLOB COMMON_HEADERS_HXX "${CMAKE_CURRENT_SOURCE_DIR}/*.hxx")
  INSTALL(FILES ${COMMON_HEADERS_HXX} DESTINATION ${SALOME_INSTALL_HEADERS})



