# Copyright (C) 2012-2026  CEA, EDF, OPEN CASCADE
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
#
# See http://www.salome-platform.org/ or email : webmaster.salome@opencascade.com
#
CMAKE_MINIMUM_REQUIRED(VERSION 2.8.8 FATAL_ERROR)
INCLUDE(CMakeDependentOption)

# Project name
# ============
# original
PROJECT(SalomeGUI C CXX)
# upper case
STRING(TOUPPER ${PROJECT_NAME} PROJECT_NAME_UC)
# Common CMake macros
# ===================
SET(CONFIGURATION_ROOT_DIR $ENV{CONFIGURATION_ROOT_DIR} CACHE PATH "Path to the Salome CMake configuration files")
IF(EXISTS ${CONFIGURATION_ROOT_DIR})
  LIST(APPEND CMAKE_MODULE_PATH "${CONFIGURATION_ROOT_DIR}/cmake")
  INCLUDE(SalomeMacros NO_POLICY_SCOPE)
ELSE()
  MESSAGE(FATAL_ERROR "We absolutely need the Salome CMake configuration files, please define CONFIGURATION_ROOT_DIR !")
ENDIF()

# Use PySide2/Shiboken2 or PyQt5/SIP5
# ===================================
SET (SALOME_USE_PYSIDE $ENV{SALOME_USE_PYSIDE} CACHE BOOL "Use PySide or PyQt")

# Versioning
# ===========
SALOME_SETUP_VERSION(9.16.0)
MESSAGE(STATUS "Building ${PROJECT_NAME_UC} ${${PROJECT_NAME_UC}_VERSION} from \"${${PROJECT_NAME_UC}_GIT_SHA1}\"")

# Platform setup
# ==============
INCLUDE(SalomeSetupPlatform)   # From CONFIGURATION
# Always build libraries as shared objects:
SET(BUILD_SHARED_LIBS TRUE)

# User options
# ============
OPTION(SALOME_BUILD_DOC "Generate SALOME GUI documentation" ON)
OPTION(SALOME_BUILD_TESTS "Build SALOME tests" ON)
OPTION(SALOME_GUI_USE_OBSERVERS "Use study observers in GUI (advanced)" ON)
OPTION(SALOME_ON_DEMAND "Activate SALOME on demand feature" ON)
CMAKE_DEPENDENT_OPTION(SALOME_GUI_BUILD_FRENCH_DOC "Generate SALOME GUI French documentation" OFF
                       "SALOME_BUILD_DOC" OFF)

# Advanced options:
CMAKE_DEPENDENT_OPTION(SALOME_LIGHT_ONLY "Build SALOME Light only (no CORBA)" OFF
                       "NOT SALOME_KERNEL_LIGHT_ONLY" ON)
OPTION(SALOME_USE_VTKVIEWER "Enable VTK visualization (Mandatory in classic configurations)" ON)
OPTION(SALOME_USE_OCCVIEWER "Enable OCC visualization (Mandatory in classic configurations)" ON)
OPTION(SALOME_USE_PV3DVIEWER "Enable ParaView3D visualization (Optionally in classic configurations)" ON)
OPTION(SALOME_USE_GLVIEWER "Enable OpenGL visualization (Mandatory in classic configurations)" ON)
OPTION(SALOME_USE_GRAPHICSVIEW "Enable GraphicsView visualization (Mandatory in classic configurations)" ON)
OPTION(SALOME_USE_QTVIEWER "Enable Qt viewer visualization (Mandatory in classic configurations)" ON)
OPTION(SALOME_USE_PYVIEWER "Enable Python viewer (Mandatory in classic configurations)" ON)
OPTION(SALOME_USE_PLOT2DVIEWER "Enable Plot2D visualization (Mandatory in classic configurations)" ON)
OPTION(SALOME_USE_PYCONSOLE "Enable Python GUI interface (Mandatory in classic configurations)" ON)
OPTION(SALOME_USE_QXGRAPHVIEWER "Enable QX graph visualization (Mandatory in classic configurations)" ON)
OPTION(SALOME_USE_PVVIEWER "Enable ParaView visualization (Mandatory in classic configurations)" ON)
OPTION(SUIT_ONLY "Generate only suit libraries" OFF)

CMAKE_DEPENDENT_OPTION(SALOME_USE_SALOMEOBJECT "Enable Salome Object (Mandatory in classic configurations)" ON
                       "SALOME_LIGHT_ONLY" ON)

MARK_AS_ADVANCED(SALOME_LIGHT_ONLY SALOME_USE_VTKVIEWER SALOME_USE_GRAPHICSVIEW SALOME_USE_QTVIEWER SALOME_USE_PVVIEWER)
MARK_AS_ADVANCED(SALOME_USE_SALOMEOBJECT SALOME_USE_OCCVIEWER SALOME_USE_GLVIEWER SALOME_USE_PLOT2DVIEWER)
MARK_AS_ADVANCED(SALOME_USE_PYCONSOLE SALOME_USE_QXGRAPHVIEWER SALOME_USE_PYVIEWER SALOME_USE_PV3DVIEWER)

# Prerequisites common (SUIT + SALOMEGUI)
# =======================================
# BOOST
FIND_PACKAGE(SalomeBoost REQUIRED)
# OpenCASCADE
FIND_PACKAGE(SalomeOpenCASCADE REQUIRED)

# OpenGL
IF(SALOME_USE_OCCVIEWER OR SALOME_USE_VTKVIEWER OR SALOME_USE_GLVIEWER)
  FIND_PACKAGE(SalomeOpenGL REQUIRED)
ENDIF()

# Qt
FIND_PACKAGE(SalomeQt5 REQUIRED)
SET(QT_SALOME_VERSION 5)
SET(SALOME_GUI_ENABLE_QTXWEBBROWSER TRUE)
IF(NOT "${QT_VERSION}" VERSION_LESS "5.6.0")
  # Check that WebEngineWidgets component was found
  IF(NOT Qt5WebEngineWidgets_FOUND)
    SET(SALOME_GUI_ENABLE_QTXWEBBROWSER FALSE)
    ADD_DEFINITIONS("-DDISABLE_QTXWEBBROWSER")
    MESSAGE("Qt5WebEngineWidgets is not found, SALOME internal help browser will be unavailable !")
  ENDIF()
ENDIF()

FIND_PACKAGE(SalomePythonInterp REQUIRED)
FIND_PACKAGE(SalomePythonLibs REQUIRED)

# Find SalomeBootstrap
# ===========
SET(SALOMEBOOTSTRAP_ROOT_DIR $ENV{SALOMEBOOTSTRAP_ROOT_DIR} CACHE PATH "Path to the Salome Bootstrap")
IF(EXISTS ${SALOMEBOOTSTRAP_ROOT_DIR})
  FIND_PACKAGE(SalomeBootstrap REQUIRED)
  ADD_DEFINITIONS(${SALOMEBOOTSTRAP_DEFINITIONS})
  INCLUDE_DIRECTORIES(${SALOMEBOOTSTRAP_INCLUDE_DIRS})
ELSE(EXISTS ${SALOMEBOOTSTRAP_ROOT_DIR})
  MESSAGE(FATAL_ERROR "We absolutely need a Salome Bootstrap, please define SALOMEBOOTSTRAP_ROOT_DIR")
ENDIF(EXISTS ${SALOMEBOOTSTRAP_ROOT_DIR})

#For SALOME GUI
#==============
IF(SUIT_ONLY)

  ADD_DEFINITIONS("-DSUIT_ONLY")
  OPTION(SALOME_BUILD_TESTS "Build SALOME tests" OFF)
  SET(SALOME_INSTALL_BINS "bin" CACHE PATH "Install path: SUIT binaries")
  SET(SALOME_INSTALL_LIBS "lib" CACHE PATH "Install path: SUIT libs")
  SET(SALOME_INSTALL_HEADERS "include" CACHE PATH "Install path: SALOME headers")
  SET(SALOME_INSTALL_CMAKE_LOCAL "adm_local/cmake_files" CACHE PATH
      "Install path: local SALOME CMake files")
  SET(SALOME_INSTALL_RES resources CACHE PATH "Install path: SUIT resources")



ELSE(SUIT_ONLY)

  # Find KERNEL
  # ===========
  SET(KERNEL_ROOT_DIR $ENV{KERNEL_ROOT_DIR} CACHE PATH "Path to the Salome KERNEL")
  IF(EXISTS ${KERNEL_ROOT_DIR})
    FIND_PACKAGE(SalomeKERNEL REQUIRED)
    ADD_DEFINITIONS(${KERNEL_DEFINITIONS})
    INCLUDE_DIRECTORIES(${KERNEL_INCLUDE_DIRS})
  ELSE(EXISTS ${KERNEL_ROOT_DIR})
    MESSAGE(FATAL_ERROR "We absolutely need a Salome KERNEL, please define KERNEL_ROOT_DIR")
  ENDIF(EXISTS ${KERNEL_ROOT_DIR})

  # Directories
  # (default values taken from KERNEL)
  # ===========

  SET(SALOME_INSTALL_BINS "${SALOME_INSTALL_BINS}" CACHE PATH "Install path: SALOME binaries")
  SET(SALOME_INSTALL_LIBS "${SALOME_INSTALL_LIBS}" CACHE PATH "Install path: SALOME libs")
  SET(SALOME_INSTALL_IDLS "${SALOME_INSTALL_IDLS}" CACHE PATH "Install path: SALOME IDL files")
  SET(SALOME_INSTALL_HEADERS "${SALOME_INSTALL_HEADERS}" CACHE PATH "Install path: SALOME headers")
  SET(SALOME_INSTALL_SCRIPT_SCRIPTS "${SALOME_INSTALL_SCRIPT_SCRIPTS}" CACHE PATH
     "Install path: SALOME scripts")
  SET(SALOME_INSTALL_SCRIPT_DATA "${SALOME_INSTALL_SCRIPT_DATA}" CACHE PATH
     "Install path: SALOME script data")
  SET(SALOME_INSTALL_SCRIPT_PYTHON "${SALOME_INSTALL_SCRIPT_PYTHON}" CACHE PATH
     "Install path: SALOME Python scripts")
  SET(_pydir lib/python${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}/site-packages)
  SET(SALOME_GUI_INSTALL_PYTHON ${_pydir} CACHE PATH "Install path: SALOME Python stuff")
  SET(SALOME_GUI_INSTALL_PYTHON "${SALOME_GUI_INSTALL_PYTHON}" CACHE PATH "Install path: SALOME Python stuff")
  SET(SALOME_INSTALL_PYTHON_SHARED "${SALOME_INSTALL_PYTHON_SHARED}" CACHE PATH
     "Install path: SALOME Python shared modules")
  SET(SALOME_INSTALL_CMAKE "${SALOME_INSTALL_CMAKE}" CACHE PATH "Install path: SALOME CMake files")
  SET(SALOME_INSTALL_CMAKE_LOCAL "${SALOME_INSTALL_CMAKE_LOCAL}" CACHE PATH
      "Install path: local SALOME CMake files")
  SET(SALOME_INSTALL_AMCONFIG_LOCAL "${SALOME_INSTALL_AMCONFIG_LOCAL}" CACHE PATH
    "Install path: local SALOME config files (obsolete, to be removed)")

  SET(SALOME_INSTALL_DOC "${SALOME_INSTALL_DOC}" CACHE PATH "Install path: SALOME documentation")

  # Prerequisites
  # =============
  # Find "big" prerequisites first - they reference themselves many others
  #   -> this can help finding the smaller prerequisites and detect conficts.
  # In our case KERNEL has already loaded many prereq which are also used in GUI:

  ##
  ## From KERNEL:
  ##

  # Various
  FIND_PACKAGE(SalomePThread REQUIRED)
  FIND_PACKAGE(SalomeSWIG REQUIRED)
  FIND_PACKAGE(SalomeHDF5 REQUIRED COMPONENTS C)

  # Other KERNEL optionals:
  IF(NOT SALOME_LIGHT_ONLY)
    FIND_PACKAGE(SalomeOmniORB REQUIRED)
    FIND_PACKAGE(SalomeOmniORBPy REQUIRED)
  ELSE()
    ADD_DEFINITIONS("-DGUI_DISABLE_CORBA")
  ENDIF()
  IF(SALOME_BUILD_TESTS)
    ENABLE_TESTING()
    FIND_PACKAGE(SalomeCppUnit)
    SALOME_LOG_OPTIONAL_PACKAGE(CppUnit SALOME_BUILD_TESTS)
  ENDIF()

  IF(SALOME_BUILD_DOC)
    FIND_PACKAGE(SalomeDoxygen)
    FIND_PACKAGE(SalomeGraphviz)
    FIND_PACKAGE(SalomeSphinx)
    SALOME_LOG_OPTIONAL_PACKAGE(Doxygen SALOME_BUILD_DOC)
    SALOME_LOG_OPTIONAL_PACKAGE(Graphviz SALOME_BUILD_DOC)
    SALOME_LOG_OPTIONAL_PACKAGE(Sphinx SALOME_BUILD_DOC)
  ELSE(SALOME_BUILD_DOC)
    FIND_PACKAGE(SalomeGraphviz)
  ENDIF()

  ##
  ## GUI specifics
  ##

 
  IF(NOT SALOME_USE_PYSIDE)
    FIND_PACKAGE(SalomeSIP REQUIRED)  # should come after Python and before PyQt
  ENDIF(NOT SALOME_USE_PYSIDE)
  # Build with GUI observers feature
  IF(SALOME_GUI_USE_OBSERVERS)
    ADD_DEFINITIONS(-DWITH_SALOMEDS_OBSERVER)
  ENDIF()

  # SALOME on demand
  IF(SALOME_ON_DEMAND)
    ADD_DEFINITIONS(-DWITH_SALOME_ON_DEMAND)
  ENDIF()

  # Single-study GUI
  IF(SALOME_USE_SINGLE_DESKTOP)
    ADD_DEFINITIONS(-DSINGLE_DESKTOP)
  ENDIF()

  if (NOT SALOME_USE_PYSIDE)
    # PyQt
    FIND_PACKAGE(SalomePyQt5 REQUIRED)
  endif(NOT SALOME_USE_PYSIDE)
  # Optional packages for GUI and their pre-requisites

  # - GL viewer: no prereqs
  IF(NOT SALOME_USE_GLVIEWER)
    ADD_DEFINITIONS("-DDISABLE_GLVIEWER")
  ENDIF()

  # - OCC viewer: no prereqs
  IF(NOT SALOME_USE_OCCVIEWER)
    ADD_DEFINITIONS("-DDISABLE_OCCVIEWER")
  ENDIF()

  # - PV viewer: ParaView
  IF (SALOME_USE_PVVIEWER)
    FIND_PACKAGE(SalomeParaView)
    SALOME_LOG_OPTIONAL_PACKAGE(ParaView SALOME_USE_PVVIEWER)
  ELSE()
    ADD_DEFINITIONS("-DDISABLE_PVVIEWER")
  ENDIF()

  # - PV3D viewer: ParaView3D
  IF (SALOME_USE_PV3DVIEWER)
    FIND_PACKAGE(SalomeParaView)
    SALOME_LOG_OPTIONAL_PACKAGE(ParaView SALOME_USE_PV3DVIEWER)
  ELSE()
    ADD_DEFINITIONS("-DDISABLE_PV3DVIEWER")
  ENDIF()

  # - Graphics viewer: no prereqs
  IF (NOT SALOME_USE_GRAPHICSVIEW)
    ADD_DEFINITIONS("-DDISABLE_GRAPHICSVIEW")
  ENDIF()

  # - Qt viewer: no prereqs
  IF (NOT SALOME_USE_QTVIEWER)
    ADD_DEFINITIONS("-DDISABLE_QTVIEWER")
  ENDIF()

  # - Python editor: no prereqs
  IF (NOT SALOME_USE_PYVIEWER)
    ADD_DEFINITIONS("-DDISABLE_PYVIEWER")
  ENDIF()

  # - Qx viewer: no prereqs
  IF(NOT SALOME_USE_QXGRAPHVIEWER)
    ADD_DEFINITIONS("-DDISABLE_QXGRAPHVIEWER")
  ENDIF()

  # - SALOME object: no prereqs
  IF(NOT SALOME_USE_SALOMEOBJECT)
    ADD_DEFINITIONS("-DDISABLE_SALOMEOBJECT")
  ENDIF()
ENDIF(SUIT_ONLY)

# - VTK viewer: VTK
IF(SALOME_USE_VTKVIEWER OR SUIT_ONLY)
  # Required components are listed in the FindSalomeVTK.cmake file:
  FIND_PACKAGE(SalomeVTK)
  SALOME_LOG_OPTIONAL_PACKAGE(VTK SALOME_USE_VTKVIEWER)
  # VSR: TODO: since ParaView 5.8 the following is not needed, as OPENGL2 is hardcoded: to be removed (everywhere)
  ADD_DEFINITIONS("-DVTK_OPENGL2")
  SET(SALOME_GUI_USE_OPENGL2 TRUE)
ELSE()
  ADD_DEFINITIONS("-DDISABLE_VTKVIEWER")
ENDIF()


# - Plot2d viewer: Qwt
IF(SALOME_USE_PLOT2DVIEWER OR SUIT_ONLY)
  FIND_PACKAGE(SalomeQwt)
  SALOME_LOG_OPTIONAL_PACKAGE(Qwt SALOME_USE_PLOT2DVIEWER)
ELSE()
  ADD_DEFINITIONS("-DDISABLE_PLOT2DVIEWER")
ENDIF()

# - Python console: no prereqs
IF(SALOME_USE_PYCONSOLE OR SUIT_ONLY)
  # Build with obsolete Python module's methods
  ADD_DEFINITIONS(-DCALL_OLD_METHODS)
ELSE()
  ADD_DEFINITIONS("-DDISABLE_PYCONSOLE")
ENDIF()

# Other global definitions
ADD_DEFINITIONS("-DGLOBAL_DOUBLE_CONVERSION")

# Detection summary:
SALOME_PACKAGE_REPORT_AND_CHECK()

IF(NOT SUIT_ONLY)
  # Specific to GUI:
  SET(SALOME_GUI_INSTALL_RES_DATA "${SALOME_INSTALL_RES}/gui" CACHE PATH
      "Install path: SALOME GUI specific data")
  SET(SALOME_GUI_INSTALL_RES_SCRIPTS "${SALOME_INSTALL_RES}/gui" CACHE PATH
      "Install path: SALOME GUI scripts")
  SET(SALOME_GUI_INSTALL_PLUGINS share/salome/plugins/gui CACHE PATH
      "Install path: SALOME GUI plugins")
ELSE(NOT SUIT_ONLY)
  # Specific to SUIT:
  SET(SALOME_GUI_INSTALL_RES_DATA "${SALOME_INSTALL_RES}" CACHE PATH
      "Install path: SALOME SUIT specific data")
  SET(SALOME_GUI_INSTALL_RES_SCRIPTS "${SALOME_INSTALL_RES}" CACHE PATH
    "Install path: SALOME SUIT scripts")
ENDIF(NOT SUIT_ONLY)

MARK_AS_ADVANCED(SALOME_INSTALL_BINS SALOME_INSTALL_LIBS SALOME_INSTALL_IDLS SALOME_INSTALL_HEADERS)
MARK_AS_ADVANCED(SALOME_INSTALL_SCRIPT_SCRIPTS SALOME_INSTALL_SCRIPT_DATA SALOME_INSTALL_SCRIPT_PYTHON)
MARK_AS_ADVANCED(SALOME_INSTALL_APPLISKEL_SCRIPTS  SALOME_INSTALL_APPLISKEL_PYTHON SALOME_INSTALL_CMAKE SALOME_INSTALL_CMAKE_LOCAL SALOME_INSTALL_RES)
MARK_AS_ADVANCED(SALOME_GUI_INSTALL_PYTHON SALOME_INSTALL_PYTHON_SHARED)
MARK_AS_ADVANCED(SALOME_GUI_INSTALL_RES_DATA SALOME_GUI_INSTALL_RES_SCRIPTS SALOME_GUI_INSTALL_PLUGINS)
MARK_AS_ADVANCED(SALOME_INSTALL_AMCONFIG_LOCAL SALOME_INSTALL_DOC)

# Accumulate environment variables for GUI module
SALOME_ACCUMULATE_ENVIRONMENT(PYTHONPATH NOCHECK ${CMAKE_INSTALL_PREFIX}/${SALOME_INSTALL_BINS}
                                                 ${CMAKE_INSTALL_PREFIX}/${SALOME_GUI_INSTALL_PYTHON}
                                                 ${CMAKE_INSTALL_PREFIX}/${SALOME_INSTALL_LIBS}
                                                 ${CMAKE_INSTALL_PREFIX}/${SALOME_INSTALL_PYTHON_SHARED})
SALOME_ACCUMULATE_ENVIRONMENT(LD_LIBRARY_PATH NOCHECK ${CMAKE_INSTALL_PREFIX}/${SALOME_INSTALL_LIBS})

# Sources
# ========
IF(SUIT_ONLY)
  ADD_SUBDIRECTORY(src)
  ADD_SUBDIRECTORY(tools)
ELSE(SUIT_ONLY)
  IF(NOT SALOME_LIGHT_ONLY)
    ADD_SUBDIRECTORY(idl)
  ENDIF()

  ADD_SUBDIRECTORY(adm_local)
  ADD_SUBDIRECTORY(src)
  ADD_SUBDIRECTORY(tools)
  IF(SALOME_BUILD_DOC)
    ADD_SUBDIRECTORY(doc)
  ENDIF()
  ADD_SUBDIRECTORY(bin)
ENDIF(SUIT_ONLY)
# Header configuration
# ====================
SALOME_CONFIGURE_FILE(GUI_version.h.in GUI_version.h INSTALL ${SALOME_INSTALL_HEADERS})

# Configuration export
# (here only the level 1 prerequisites are exposed)
# ====================
INCLUDE(CMakePackageConfigHelpers)

# List of targets in this project we want to make visible to the rest of the world.
# They all have to be INSTALL'd with the option "EXPORT ${PROJECT_NAME}TargetGroup"
SET(_${PROJECT_NAME}_exposed_targets
    CAM CASCatch DDS Event LightApp LogWindow ObjBrowser
    QDS qtx SalomePrs SalomeStyle std SUITApp suit ViewerTools ViewerData
    ImageComposer
    SalomeApprc_utils
)

IF(SALOME_USE_OCCVIEWER OR SALOME_USE_VTKVIEWER OR SALOME_USE_GLVIEWER AND NOT SUIT)
  LIST(APPEND _${PROJECT_NAME}_exposed_targets
       OpenGLUtils)
ENDIF(SALOME_USE_OCCVIEWER OR SALOME_USE_VTKVIEWER OR SALOME_USE_GLVIEWER AND NOT SUIT)

# SALOME object specific targets:
IF(SALOME_USE_SALOMEOBJECT)
  LIST(APPEND _${PROJECT_NAME}_exposed_targets
       SalomeObject)
ENDIF(SALOME_USE_SALOMEOBJECT)

# GL specific targets:
IF(SALOME_USE_GLVIEWER)
  LIST(APPEND _${PROJECT_NAME}_exposed_targets
       GLViewer)
ENDIF(SALOME_USE_GLVIEWER)

# VTK specific targets:
IF(SALOME_USE_VTKVIEWER)
  LIST(APPEND _${PROJECT_NAME}_exposed_targets
       VTKViewer )
  IF(SALOME_USE_SALOMEOBJECT)
    LIST(APPEND _${PROJECT_NAME}_exposed_targets
         SVTK)
  ENDIF(SALOME_USE_SALOMEOBJECT)
ENDIF(SALOME_USE_VTKVIEWER)

# OCC specific targets:
IF(SALOME_USE_OCCVIEWER)
  LIST(APPEND _${PROJECT_NAME}_exposed_targets
       OCCViewer)
  IF(SALOME_USE_SALOMEOBJECT)
    LIST(APPEND _${PROJECT_NAME}_exposed_targets
         SOCC)
  ENDIF(SALOME_USE_SALOMEOBJECT)
ENDIF(SALOME_USE_OCCVIEWER)

# PV3D specific targets:
IF(SALOME_USE_PV3DVIEWER)
  LIST(APPEND _${PROJECT_NAME}_exposed_targets 
       PV3DViewer)
  IF(SALOME_USE_SALOMEOBJECT)
    LIST(APPEND _${PROJECT_NAME}_exposed_targets 
         SPV3D)
  ENDIF(SALOME_USE_SALOMEOBJECT)
ENDIF(SALOME_USE_PV3DVIEWER)

# Plot2d specific targets:
IF(SALOME_USE_PLOT2DVIEWER)
  LIST(APPEND _${PROJECT_NAME}_exposed_targets
       Plot2d)
  IF(SALOME_USE_SALOMEOBJECT)
    LIST(APPEND _${PROJECT_NAME}_exposed_targets
         SPlot2d)
  ENDIF(SALOME_USE_SALOMEOBJECT)
ENDIF(SALOME_USE_PLOT2DVIEWER)

# Qx specific targets:
IF(SALOME_USE_QXGRAPHVIEWER)
  LIST(APPEND _${PROJECT_NAME}_exposed_targets
       QxScene)
ENDIF(SALOME_USE_QXGRAPHVIEWER)

# GraphicsView specific targets:
IF(SALOME_USE_GRAPHICSVIEW)
  LIST(APPEND _${PROJECT_NAME}_exposed_targets
       GraphicsView)
ENDIF(SALOME_USE_GRAPHICSVIEW)

# QtViewer specific targets:
IF(SALOME_USE_QTVIEWER)
  LIST(APPEND _${PROJECT_NAME}_exposed_targets
       QtViewer)
ENDIF(SALOME_USE_QTVIEWER)

# PyEditor/Viewer specific targets:
IF(SALOME_USE_PYVIEWER)
  LIST(APPEND _${PROJECT_NAME}_exposed_targets
       PyEditor PyViewer)
ENDIF(SALOME_USE_PYVIEWER)

# ParaView viewer specific targets:
IF(SALOME_USE_PVVIEWER)
  LIST(APPEND _${PROJECT_NAME}_exposed_targets PVViewer PVServerService)
ENDIF()

# Python-based packages specific targets:
IF(SALOME_USE_PYCONSOLE)
  LIST(APPEND _${PROJECT_NAME}_exposed_targets
       PyInterp PyConsole SalomePyQtGUILight)
  IF(SALOME_USE_PLOT2DVIEWER)
    LIST(APPEND _${PROJECT_NAME}_exposed_targets SalomePyQt)
  ENDIF()
  IF(NOT SALOME_LIGHT_ONLY)
    LIST(APPEND _${PROJECT_NAME}_exposed_targets SalomePyQtGUI)
  ENDIF()
  IF(SALOME_USE_VTKVIEWER)
    LIST(APPEND _${PROJECT_NAME}_exposed_targets SalomePy)
  ENDIF(SALOME_USE_VTKVIEWER)
ENDIF(SALOME_USE_PYCONSOLE)

# CORBA specific targets:
IF(NOT SALOME_LIGHT_ONLY)
  LIST(APPEND _${PROJECT_NAME}_exposed_targets
       SalomeIDLGUI SalomeSession SalomeApp SalomeAppSL SalomeAppImpl SalomeGuiHelpers SalomeTreeData ToolsGUI)
ENDIF(NOT SALOME_LIGHT_ONLY)

# SUIT only
IF(SUIT_ONLY)
  SET(_${PROJECT_NAME}_exposed_targets
    CAM ObjBrowser qtx suit
    std VTKViewer Event LogWindow
    OCCViewer Plot2d ViewerData CASCatch ViewerTools OpenGLUtils
    SalomeObject SalomePrs SalomeStyle
    PyInterp PyConsole
  )
ENDIF()

# Add all targets to the build-tree export set
EXPORT(TARGETS ${_${PROJECT_NAME}_exposed_targets}
  FILE ${PROJECT_BINARY_DIR}/${PROJECT_NAME}Targets.cmake)

# Create the configuration files:
#   - in the build tree:

# Ensure the variables are always defined for the configure:
SET(KERNEL_ROOT_DIR "${KERNEL_ROOT_DIR}")
SET(QT_ROOT_DIR "${QT5_ROOT_DIR}")
if (NOT SALOME_USE_PYSIDE)
  SET(PYQT_ROOT_DIR "${PYQT5_ROOT_DIR}")
  SET(SIP_ROOT_DIR "${SIP_ROOT_DIR}")
endif(NOT SALOME_USE_PYSIDE)
SET(OPENCASCADE_ROOT_DIR "${OPENCASCADE_ROOT_DIR}")
SET(OPENGL_ROOT_DIR "${OPENGL_ROOT_DIR}")
SET(PARAVIEW_ROOT_DIR "${PARAVIEW_ROOT_DIR}")
SET(VTK_ROOT_DIR "${VTK_ROOT_DIR}")
SET(QWT_ROOT_DIR "${QWT_ROOT_DIR}")

SET(CONF_INCLUDE_DIRS "${PROJECT_SOURCE_DIR}/include" "${PROJECT_BINARY_DIR}/include")

# Build variables that will be expanded when configuring Salome<MODULE>Config.cmake:
if (NOT SALOME_USE_PYSIDE)
  SALOME_CONFIGURE_PREPARE(OpenCASCADE OpenGL Qt5 PyQt5 Qwt SIP ParaView VTK)
  CONFIGURE_PACKAGE_CONFIG_FILE(${PROJECT_NAME}Config.cmake.in
    ${PROJECT_BINARY_DIR}/${PROJECT_NAME}Config.cmake
    INSTALL_DESTINATION "${SALOME_INSTALL_CMAKE_LOCAL}"
    PATH_VARS CONF_INCLUDE_DIRS SALOME_INSTALL_CMAKE_LOCAL CMAKE_INSTALL_PREFIX
       KERNEL_ROOT_DIR SIP_ROOT_DIR QT_ROOT_DIR PYQT_ROOT_DIR OPENCASCADE_ROOT_DIR
       OPENGL_ROOT_DIR PARAVIEW_ROOT_DIR VTK_ROOT_DIR QWT_ROOT_DIR SALOME_USE_PYSIDE)
else (NOT SALOME_USE_PYSIDE)
  SALOME_CONFIGURE_PREPARE(OpenCASCADE OpenGL Qt5 Qwt ParaView VTK)

  CONFIGURE_PACKAGE_CONFIG_FILE(${PROJECT_NAME}Config.cmake.in
    ${PROJECT_BINARY_DIR}/${PROJECT_NAME}Config.cmake
    INSTALL_DESTINATION "${SALOME_INSTALL_CMAKE_LOCAL}"
    PATH_VARS CONF_INCLUDE_DIRS SALOME_INSTALL_CMAKE_LOCAL CMAKE_INSTALL_PREFIX
       KERNEL_ROOT_DIR QT_ROOT_DIR PYSIDE2_ROOT_DIR OPENCASCADE_ROOT_DIR
       OPENGL_ROOT_DIR PARAVIEW_ROOT_DIR VTK_ROOT_DIR QWT_ROOT_DIR SALOME_USE_PYSIDE)
endif(NOT SALOME_USE_PYSIDE)

WRITE_BASIC_PACKAGE_VERSION_FILE(${PROJECT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake
    VERSION ${${PROJECT_NAME_UC}_VERSION}
    COMPATIBILITY AnyNewerVersion)

# Install the CMake configuration files:
INSTALL(FILES
  "${PROJECT_BINARY_DIR}/${PROJECT_NAME}Config.cmake"
  "${PROJECT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake"
  DESTINATION "${SALOME_INSTALL_CMAKE_LOCAL}")

# Install the export set for use with the install-tree
INSTALL(EXPORT ${PROJECT_NAME}TargetGroup DESTINATION "${SALOME_INSTALL_CMAKE_LOCAL}"
        FILE ${PROJECT_NAME}Targets.cmake)
