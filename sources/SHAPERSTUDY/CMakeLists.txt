# Copyright (C) 2019-2026  CEA, EDF
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

# Project name
# ============
# original
PROJECT(SalomeSHAPERSTUDY C CXX)
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

# Versioning
# ===========
SALOME_SETUP_VERSION(9.16.0)
MESSAGE(STATUS "Building ${PROJECT_NAME_UC} ${${PROJECT_NAME_UC}_VERSION} from \"${${PROJECT_NAME_UC}_GIT_SHA1}\"")

# Platform setup (from CONFIGURATION)
# ==============
INCLUDE(SalomeSetupPlatform)
# Always build libraries as shared objects:
SET(BUILD_SHARED_LIBS TRUE)

# Find KERNEL
# ===========
SET(KERNEL_ROOT_DIR $ENV{KERNEL_ROOT_DIR} CACHE PATH "Path to the Salome KERNEL")
IF(EXISTS ${KERNEL_ROOT_DIR})
  FIND_PACKAGE(SalomeKERNEL REQUIRED)
  KERNEL_WITH_CORBA() # check whether KERNEL builded with CORBA
  ADD_DEFINITIONS(${KERNEL_DEFINITIONS})
  INCLUDE_DIRECTORIES(${KERNEL_INCLUDE_DIRS})
ELSE(EXISTS ${KERNEL_ROOT_DIR})
  MESSAGE(FATAL_ERROR "We absolutely need a Salome KERNEL, please define KERNEL_ROOT_DIR")
ENDIF(EXISTS ${KERNEL_ROOT_DIR})

# User options
# ============
OPTION(SALOME_BUILD_TESTS "Build SALOME tests" ON)
# TODO: documentation
# OPTION(SALOME_BUILD_DOC "Generate SALOME SHAPERSTUDY documentation" ON)

IF(SALOME_BUILD_TESTS)
  ENABLE_TESTING()
ENDIF()
# TODO: documentation
# IF(SALOME_BUILD_DOC)
#   FIND_PACKAGE(SalomeDoxygen)
#   FIND_PACKAGE(SalomeGraphviz)
#   FIND_PACKAGE(SalomeSphinx)
#   SALOME_LOG_OPTIONAL_PACKAGE(Doxygen SALOME_BUILD_DOC)
#   SALOME_LOG_OPTIONAL_PACKAGE(Graphviz SALOME_BUILD_DOC)
#   SALOME_LOG_OPTIONAL_PACKAGE(Sphinx SALOME_BUILD_DOC)
# ENDIF()

##
## From KERNEL:
##
FIND_PACKAGE(SalomePythonInterp REQUIRED)
FIND_PACKAGE(SalomePythonLibs REQUIRED)
FIND_PACKAGE(SalomeOmniORB REQUIRED)
FIND_PACKAGE(SalomeOmniORBPy REQUIRED)
FIND_PACKAGE(SalomeSWIG REQUIRED)

# Find GEOM
# ===========
SET(GEOM_ROOT_DIR $ENV{GEOM_ROOT_DIR} CACHE PATH "Path to the Salome GEOM")
IF(EXISTS ${GEOM_ROOT_DIR})
  FIND_PACKAGE(SalomeGEOM REQUIRED)
  ADD_DEFINITIONS(${GEOM_DEFINITIONS})
  INCLUDE_DIRECTORIES(${GEOM_INCLUDE_DIRS})
  IF(SALOME_BUILD_GUI)
    IF(NOT SALOME_GEOM_BUILD_GUI)
      MESSAGE(FATAL_ERROR "We absolutely need a Salome GEOM with GUI, please set SALOME_BUILD_GUI=ON in GEOM module")
    ENDIF(NOT SALOME_GEOM_BUILD_GUI)
  ENDIF(SALOME_BUILD_GUI)
ELSE(EXISTS ${GEOM_ROOT_DIR})
  MESSAGE(FATAL_ERROR "We absolutely need a Salome GEOM, please define GEOM_ROOT_DIR")
ENDIF(EXISTS ${GEOM_ROOT_DIR})

# Find SHAPER
# ===========
# TODO: Change SHAPER detection procedure, as soon as config file's support is implemented in SHAPER
SET(SHAPER_ROOT_DIR $ENV{SHAPER_ROOT_DIR} CACHE PATH "Path to the Salome SHAPER")
IF(EXISTS ${SHAPER_ROOT_DIR})
  SET_AND_CHECK(SHAPER_INCLUDE_DIRS "${SHAPER_ROOT_DIR}/include/salome")
  INCLUDE_DIRECTORIES(${SHAPER_INCLUDE_DIRS})
  find_library(LIB_XAOShaper NAMES XAOShaper PATHS ${SHAPER_ROOT_DIR}/lib/salome)
  SALOME_ACCUMULATE_ENVIRONMENT(PYTHONPATH NOCHECK ${SHAPER_ROOT_DIR}/lib/python${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}/site-packages/salome)
  SALOME_ACCUMULATE_ENVIRONMENT(LD_LIBRARY_PATH NOCHECK ${SHAPER_ROOT_DIR}/lib/salome) 
ELSE(EXISTS ${SHAPER_ROOT_DIR})
  MESSAGE(FATAL_ERROR "We absolutely need a Salome SHAPER, please define SHAPER_ROOT_DIR")
ENDIF(EXISTS ${SHAPER_ROOT_DIR})

# Detection summary:
# TODO: Uncomment in case if any products are used optionally
# SALOME_PACKAGE_REPORT_AND_CHECK()

# Directories
# (default values taken from KERNEL)
# ===========
SET(SALOME_INSTALL_BINS           "${SALOME_INSTALL_BINS}"           CACHE PATH "Install path: SALOME binaries")
SET(SALOME_INSTALL_LIBS           "${SALOME_INSTALL_LIBS}"           CACHE PATH "Install path: SALOME libs")
SET(SALOME_INSTALL_IDLS           "${SALOME_INSTALL_IDLS}"           CACHE PATH "Install path: SALOME IDL files")
SET(SALOME_INSTALL_HEADERS        "${SALOME_INSTALL_HEADERS}"        CACHE PATH "Install path: SALOME headers")
SET(SALOME_INSTALL_SCRIPT_SCRIPTS "${SALOME_INSTALL_SCRIPT_SCRIPTS}" CACHE PATH "Install path: SALOME scripts")
SET(SALOME_INSTALL_SCRIPT_DATA    "${SALOME_INSTALL_SCRIPT_DATA}"    CACHE PATH "Install path: SALOME script data")
SET(SALOME_INSTALL_SCRIPT_PYTHON  "${SALOME_INSTALL_SCRIPT_PYTHON}"  CACHE PATH "Install path: SALOME Python executable scripts")
SET(SALOME_SHAPER_STUDY_INSTALL_PYTHON         "${INSTALL_PYIDL_DIR}"         CACHE PATH "Install path: SALOME Python import modules")
SET(SALOME_INSTALL_CMAKE_LOCAL    "${SALOME_INSTALL_CMAKE_LOCAL}"    CACHE PATH "Install path: SALOME CMake files")
SET(SALOME_INSTALL_RES            "${SALOME_INSTALL_RES}"            CACHE PATH "Install path: SALOME resources")
SET(SALOME_INSTALL_DOC            "${SALOME_INSTALL_DOC}"            CACHE PATH "Install path: SALOME documentation")
# Specific to SHAPERSTUDY:
SET(SALOME_SHAPERSTUDY_INSTALL_RES_DATA "${SALOME_INSTALL_RES}/shaperstudy" CACHE PATH 
    "Install path: SHAPERSTUDY resources")
   
MARK_AS_ADVANCED(SALOME_INSTALL_BINS SALOME_INSTALL_LIBS SALOME_INSTALL_IDLS SALOME_INSTALL_HEADERS)
MARK_AS_ADVANCED(SALOME_INSTALL_SCRIPT_SCRIPTS SALOME_INSTALL_SCRIPT_DATA SALOME_INSTALL_SCRIPT_PYTHON)
MARK_AS_ADVANCED(SALOME_SHAPER_STUDY_INSTALL_PYTHON SALOME_INSTALL_CMAKE_LOCAL SALOME_INSTALL_RES SALOME_INSTALL_DOC)
MARK_AS_ADVANCED(SALOME_SHAPERSTUDY_INSTALL_RES_DATA)

# Accumulate environment variables for SHAPERSTUDY module
SALOME_ACCUMULATE_ENVIRONMENT(PYTHONPATH NOCHECK ${CMAKE_INSTALL_PREFIX}/${SALOME_INSTALL_BINS}
                                                 ${CMAKE_INSTALL_PREFIX}/${SALOME_SHAPER_STUDY_INSTALL_PYTHON})
SALOME_ACCUMULATE_ENVIRONMENT(LD_LIBRARY_PATH NOCHECK ${CMAKE_INSTALL_PREFIX}/${SALOME_INSTALL_LIBS}) 

# Sources 
# ========

ADD_SUBDIRECTORY(idl)
ADD_SUBDIRECTORY(resources)
ADD_SUBDIRECTORY(src)
ADD_SUBDIRECTORY(bin)
# IF(SALOME_BUILD_DOC)
#   ADD_SUBDIRECTORY(doc)
# ENDIF()

# Configuration export
# (here only the level 1 prerequisites are exposed)
# ====================
INCLUDE(CMakePackageConfigHelpers)

# List of targets in this project we want to make visible to the rest of the world.
# They all have to be INSTALL'd with the option "EXPORT ${PROJECT_NAME}TargetGroup"
SET(_${PROJECT_NAME}_exposed_targets 
  SalomeIDLSHAPERSTUDY StudyData
)

# Add all targets to the build-tree export set
EXPORT(TARGETS ${_${PROJECT_NAME}_exposed_targets}
  FILE ${PROJECT_BINARY_DIR}/${PROJECT_NAME}Targets.cmake)

# Create the configuration files:

# Ensure the variables are always defined for the configure:
SET(KERNEL_ROOT_DIR "${KERNEL_ROOT_DIR}")
SET(GEOM_ROOT_DIR "${GEOM_ROOT_DIR}")
SET(SHAPER_ROOT_DIR "${SHAPER_ROOT_DIR}")

SET(CONF_INCLUDE_DIRS "${PROJECT_SOURCE_DIR}/include" "${PROJECT_BINARY_DIR}/include")

# Build variables that will be expanded when configuring Salome<MODULE>Config.cmake:
# TODO: Uncomment if any 1st level pre-requisites built with CMake are used
# SALOME_CONFIGURE_PREPARE()

CONFIGURE_PACKAGE_CONFIG_FILE(${PROJECT_NAME}Config.cmake.in
    ${PROJECT_BINARY_DIR}/${PROJECT_NAME}Config.cmake
    INSTALL_DESTINATION "${SALOME_INSTALL_CMAKE_LOCAL}"
    PATH_VARS CONF_INCLUDE_DIRS SALOME_INSTALL_CMAKE_LOCAL CMAKE_INSTALL_PREFIX
    KERNEL_ROOT_DIR GEOM_ROOT_DIR SHAPER_ROOT_DIR)

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
