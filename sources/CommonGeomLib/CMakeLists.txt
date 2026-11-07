# Copyright (C) 2024-2026  CEA, EDF
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

CMAKE_MINIMUM_REQUIRED(VERSION 2.8.12 FATAL_ERROR)

# Project name
# ============
# original
PROJECT(CommonGeomLib C CXX)
# upper case
STRING(TOUPPER ${PROJECT_NAME} PROJECT_NAME_UC)


IF (${CMAKE_VERSION} VERSION_GREATER_EQUAL 3.3)
  cmake_policy(SET CMP0057 NEW)
  IF (${CMAKE_VERSION} VERSION_GREATER_EQUAL 3.13)
    cmake_policy(SET CMP0078 OLD)
  ENDIF()
  IF (${CMAKE_VERSION} VERSION_GREATER_EQUAL 3.14)
    cmake_policy(SET CMP0086 OLD)
  ENDIF()
ENDIF()


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

# Platform setup
# ==============
INCLUDE(SalomeSetupPlatform)

# Always build libraries as shared objects:
SET(BUILD_SHARED_LIBS TRUE)

# User options 
# ============
INCLUDE(CMakeDependentOption)

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

# OCCT
FIND_PACKAGE(SalomeOpenCASCADE REQUIRED)

# Pthread
FIND_PACKAGE(SalomePThread REQUIRED)

# Detection summary:
SALOME_PACKAGE_REPORT_AND_CHECK()

# Directories
# ===========
SET(CommonGeomLib_INSTALL_LIBS lib/salome CACHE PATH "Install path: CommonGeomLib libs")
SET(CommonGeomLib_INSTALL_HEADERS include/salome CACHE PATH "Install path: CommonGeomLib headers")
SET(CommonGeomLib_INSTALL_CMAKE_LOCAL cmake_files CACHE PATH "Install path: local CommonGeomLib CMake files")

MARK_AS_ADVANCED(CommonGeomLib_INSTALL_LIBS CommonGeomLib_INSTALL_HEADERS CommonGeomLib_INSTALL_CMAKE_LOCAL)

# Header configuration
# ====================
SALOME_CONFIGURE_FILE(CommonGeomLib_version.h.in CommonGeomLib_version.h INSTALL ${CommonGeomLib_INSTALL_HEADERS})

# Accumulate environment variables for CommonGeomLib module
SALOME_ACCUMULATE_ENVIRONMENT(LD_LIBRARY_PATH NOCHECK ${CMAKE_INSTALL_PREFIX}/${CommonGeomLib_INSTALL_LIBS}) 

# Sources
# ========
ADD_SUBDIRECTORY(src)

# Configuration export
# (here only the level 1 prerequisites are exposed)
# ====================
INCLUDE(CMakePackageConfigHelpers)

# List of targets in this project we want to make visible to the rest of the world.
# They all have to be INSTALL'd with the option "EXPORT ${PROJECT_NAME}TargetGroup"
SET(_${PROJECT_NAME}_exposed_targets
  GeomAnaTool BlockFix GEOMAlgo
)

# Add all targets to the build-tree export set
EXPORT(TARGETS ${_${PROJECT_NAME}_exposed_targets}
  FILE ${PROJECT_BINARY_DIR}/${PROJECT_NAME}Targets.cmake)

# Create the configuration files:
#   - in the build tree:

SET(OPENCASCADE_ROOT_DIR "${OPENCASCADE_ROOT_DIR}")

SET(CONF_INCLUDE_DIRS "${CMAKE_INSTALL_PREFIX}/${INSTALL_INCLUDE_DIR}")

# Build variables that will be expanded when configuring Salome<MODULE>Config.cmake:
SALOME_CONFIGURE_PREPARE(OpenCASCADE)

CONFIGURE_PACKAGE_CONFIG_FILE(${PROJECT_NAME}Config.cmake.in 
    ${PROJECT_BINARY_DIR}/${PROJECT_NAME}Config.cmake
    INSTALL_DESTINATION "${CommonGeomLib_INSTALL_CMAKE_LOCAL}"
    PATH_VARS CONF_INCLUDE_DIRS CommonGeomLib_INSTALL_CMAKE_LOCAL CMAKE_INSTALL_PREFIX
    OPENCASCADE_ROOT_DIR)

WRITE_BASIC_PACKAGE_VERSION_FILE(${PROJECT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake
    VERSION ${${PROJECT_NAME_UC}_VERSION}
    COMPATIBILITY AnyNewerVersion)

# Install the CMake configuration files:
INSTALL(FILES
  "${PROJECT_BINARY_DIR}/${PROJECT_NAME}Config.cmake"
  "${PROJECT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake"
  DESTINATION "${CommonGeomLib_INSTALL_CMAKE_LOCAL}")

# Install the export set for use with the install-tree
INSTALL(EXPORT ${PROJECT_NAME}TargetGroup
        DESTINATION "${CommonGeomLib_INSTALL_CMAKE_LOCAL}" 
        FILE ${PROJECT_NAME}Targets.cmake)
