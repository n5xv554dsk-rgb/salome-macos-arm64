# Copyright (C) 2019-2026 EDF
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
CMAKE_MINIMUM_REQUIRED(VERSION 3.0)
PROJECT(ydefx)

SET (CMAKE_CXX_STANDARD 11)
ENABLE_TESTING()
SET(BUILD_SHARED_LIBS TRUE)

IF(WIN32)
  SET(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)
ENDIF(WIN32)

SET(CONFIGURATION_ROOT_DIR $ENV{CONFIGURATION_ROOT_DIR} CACHE PATH "Path to the Salome CMake configuration files")
IF(EXISTS ${CONFIGURATION_ROOT_DIR})
  LIST(APPEND CMAKE_MODULE_PATH "${CONFIGURATION_ROOT_DIR}/cmake")
  INCLUDE(SalomeMacros NO_POLICY_SCOPE)
ELSE()
  MESSAGE(FATAL_ERROR "We absolutely need the Salome CMake configuration files, please define CONFIGURATION_ROOT_DIR !")
ENDIF()

SET(KERNEL_ROOT_DIR $ENV{KERNEL_ROOT_DIR} CACHE PATH "Path to the Salome KERNEL")
IF(EXISTS ${KERNEL_ROOT_DIR})
  FIND_PACKAGE(SalomeKERNEL REQUIRED)
  ADD_DEFINITIONS(${KERNEL_DEFINITIONS})
  INCLUDE_DIRECTORIES(${KERNEL_INCLUDE_DIRS})
ELSE(EXISTS ${KERNEL_ROOT_DIR})
  MESSAGE(FATAL_ERROR "We absolutely need a Salome KERNEL, please define KERNEL_ROOT_DIR")
ENDIF(EXISTS ${KERNEL_ROOT_DIR})

# Platform setup
# ==============
INCLUDE(SalomeSetupPlatform)   # From CONFIGURATION
# Always build libraries as shared objects:
SET(BUILD_SHARED_LIBS TRUE)
OPTION(YDEFX_BUILD_GUI "Generate widgets" ON)
IF(WIN32)
  SET(PY2CPP_ROOT_DIR $ENV{PY2CPP_ROOT_DIR})
ELSE(WIN32)
  FIND_PACKAGE(Py2cpp REQUIRED)
ENDIF(WIN32)

IF(NOT SalomeKERNEL_FOUND)
  MESSAGE("SalomeKERNEL not found. Salome installation paths will not be used")
ELSE()
  SET(SALOME_BUILD_TESTS ON)
  SET(SALOME_YDEFX_INSTALL_TEST ${SALOME_INSTALL_SCRIPT_SCRIPTS}/test CACHE PATH
      "Install path: SALOME Test files")
ENDIF()

IF(NOT DEFINED SALOME_INSTALL_PYTHON)
  EXECUTE_PROCESS ( COMMAND ${PYTHON_EXECUTABLE} -c
  "from distutils import sysconfig; print(sysconfig.get_python_lib(plat_specific=True, prefix='${CMAKE_INSTALL_PREFIX}'))"
                        OUTPUT_VARIABLE _ABS_PYTHON_MODULE_PATH
                        RESULT_VARIABLE _PYTHON_pythonlib_result
                        OUTPUT_STRIP_TRAILING_WHITESPACE )

  IF (_PYTHON_pythonlib_result)
    MESSAGE (SEND_ERROR "Could not set SALOME_INSTALL_PYTHON!")
  ENDIF ()
  GET_FILENAME_COMPONENT(_ABS_PYTHON_MODULE_PATH
                         ${_ABS_PYTHON_MODULE_PATH} ABSOLUTE)
  FILE(RELATIVE_PATH SALOME_INSTALL_PYTHON
                     ${CMAKE_INSTALL_PREFIX} ${_ABS_PYTHON_MODULE_PATH})
ENDIF(NOT DEFINED SALOME_INSTALL_PYTHON)

IF(NOT DEFINED SALOME_INSTALL_BINS)
  SET(SALOME_INSTALL_BINS "bin")
ENDIF()
IF(NOT DEFINED SALOME_INSTALL_LIBS)
  SET(SALOME_INSTALL_LIBS "lib")
ENDIF()
IF(NOT DEFINED SALOME_INSTALL_HEADERS)
  SET(SALOME_INSTALL_HEADERS "include")
ENDIF()
IF(NOT DEFINED SALOME_INSTALL_CMAKE)
  SET(SALOME_INSTALL_CMAKE "lib/cmake/ydefx")
ENDIF()

FIND_PACKAGE(SalomePythonInterp REQUIRED)
FIND_PACKAGE(SalomePythonLibs REQUIRED)

SET(SALOME_YDEFX_INSTALL_PYTHON "lib/python${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}/site-packages" CACHE PATH "Path to install Python files")

SET(SALOME_INSTALL_BINS "${SALOME_INSTALL_BINS}" CACHE PATH "Path to install binary files")
SET(SALOME_INSTALL_LIBS "${SALOME_INSTALL_LIBS}" CACHE PATH "Path to install libraries")
SET(SALOME_INSTALL_HEADERS "${SALOME_INSTALL_HEADERS}" CACHE PATH "Path to install headers")
SET(SALOME_INSTALL_CMAKE "${SALOME_INSTALL_CMAKE}" CACHE PATH "Path to install cmake configuration files")

# there are some problems if the configuration tools are included before the
# detection of py2cpp and SalomeKERNEL
SET(CONFIGURATION_ROOT_DIR $ENV{CONFIGURATION_ROOT_DIR} CACHE PATH "Path to the Salome CMake configuration files")
IF(EXISTS ${CONFIGURATION_ROOT_DIR})
  LIST(APPEND CMAKE_MODULE_PATH "${CONFIGURATION_ROOT_DIR}/cmake")
  INCLUDE(SalomeMacros)
  INCLUDE(SalomeSetupPlatform)
ELSE()
  MESSAGE(FATAL_ERROR "We absolutely need the Salome CMake configuration files, please define CONFIGURATION_ROOT_DIR !"
)
ENDIF()



IF(YDEFX_BUILD_GUI)
  FIND_PACKAGE(Qt5Widgets CONFIG REQUIRED)
ENDIF(YDEFX_BUILD_GUI)

ADD_SUBDIRECTORY(src)

INSTALL(EXPORT ydefxCfg_cmake DESTINATION ${SALOME_INSTALL_CMAKE} FILE ydefxConfig.cmake)
