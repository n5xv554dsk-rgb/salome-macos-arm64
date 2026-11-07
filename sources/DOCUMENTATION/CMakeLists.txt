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

# Project name
# ============
# original
PROJECT(SalomeDOCUMENTATION)
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

# Platform setup
# ==============
LIST(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake)
INCLUDE(SalomeSetupPlatform)
INCLUDE(SalomeDocumentationMacros)
INCLUDE(DocumentationMacros)

# User options
# ============
INCLUDE(CMakeDependentOption)
OPTION(SALOME_INSTALL_MODULES_DOC "Install documentation of SALOME modules" OFF)
CMAKE_DEPENDENT_OPTION(SALOME_CREATE_SYMLINKS "Create symlinks instead of installing docs" OFF
                       "NOT WIN32;SALOME_INSTALL_MODULES_DOC" OFF)
CMAKE_DEPENDENT_OPTION(SALOME_RELATIVE_SYMLINKS "Make relative symlinks instead of absolute ones" OFF
                       "NOT WIN32;SALOME_INSTALL_MODULES_DOC;SALOME_CREATE_SYMLINKS" OFF)

# Find prerequisites needed to documentation generation
# =====================================================
FIND_PACKAGE(SalomePythonInterp)
FIND_PACKAGE(SalomePythonLibs)
FIND_PACKAGE(SalomeDoxygen)
FIND_PACKAGE(SalomeGraphviz)
FIND_PACKAGE(SalomeSphinx)

# Directories
# ===========
SET(SALOME_INSTALL_DOC share/doc/salome
    CACHE PATH "Install path: SALOME documentation")
SET(SALOME_INSTALL_DOC_MAIN ${SALOME_INSTALL_DOC}
    CACHE PATH "Install path: main documentation")
SET(SALOME_INSTALL_DOC_GUI ${SALOME_INSTALL_DOC}/gui
    CACHE PATH "Install path: user documentation")
SET(SALOME_INSTALL_DOC_TUI ${SALOME_INSTALL_DOC}/tui
    CACHE PATH "Install path: developer documentation")
SET(SALOME_INSTALL_DOC_DEV ${SALOME_INSTALL_DOC}/dev
    CACHE PATH "Install path: additional developer documentation")
SET(SALOME_INSTALL_DOC_EXAMPLES ${SALOME_INSTALL_DOC}/examples
    CACHE PATH "Install path: examples")
SET(SALOME_INSTALL_DOC_EXTRA ${SALOME_INSTALL_DOC}/extra
    CACHE PATH "Install path: extra documentation")

MARK_AS_ADVANCED(
  SALOME_INSTALL_DOC
  SALOME_INSTALL_DOC_MAIN
  SALOME_INSTALL_DOC_GUI 
  SALOME_INSTALL_DOC_TUI
  SALOME_INSTALL_DOC_DEV
  SALOME_INSTALL_DOC_EXAMPLES
  SALOME_INSTALL_DOC_EXTRA
)

# Sources
# =======
IF(SALOME_INSTALL_MODULES_DOC)
  ADD_SUBDIRECTORY(main)
ELSE()
  ADD_SUBDIRECTORY(no_main)
ENDIF()
ADD_SUBDIRECTORY(tui)
ADD_SUBDIRECTORY(gui)
ADD_SUBDIRECTORY(examples)
ADD_SUBDIRECTORY(dev)
ADD_SUBDIRECTORY(extra)
