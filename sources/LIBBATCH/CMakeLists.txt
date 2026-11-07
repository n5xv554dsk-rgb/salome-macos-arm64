# Copyright (C) 2007-2021  CEA/DEN, EDF R&D, OPEN CASCADE
#
# Copyright (C) 2003-2007  OPEN CASCADE, EADS/CCR, LIP6, CEA/DEN,
# CEDRAT, EDF R&D, LEG, PRINCIPIA R&D, BUREAU VERITAS
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

PROJECT(LibBatch C CXX)

# Versioning
# ===========
# Project name, upper case
STRING(TOUPPER ${PROJECT_NAME} PROJECT_NAME_UC)

SET(${PROJECT_NAME_UC}_MAJOR_VERSION 2)
SET(${PROJECT_NAME_UC}_MINOR_VERSION 6)
SET(${PROJECT_NAME_UC}_PATCH_VERSION 0)
SET(${PROJECT_NAME_UC}_VERSION
  ${${PROJECT_NAME_UC}_MAJOR_VERSION}.${${PROJECT_NAME_UC}_MINOR_VERSION}.${${PROJECT_NAME_UC}_PATCH_VERSION})

# Our own set of macros:
LIST(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/CMakeModules)
INCLUDE(libbatchMacros)

# User options
# ============
IF(WIN32 AND NOT CYGWIN)
  # This is really stupid: in the FIND_PACKAGE() command, the default paths 
  # are not the same under Win and Nix (see CMake doc). This means we have to specify 
  # different installation directories for LibBatchConfig.cmake:
  SET(INSTALL_CMAKE_CONFIG_DIR cmake)
ELSE()
  SET(INSTALL_CMAKE_CONFIG_DIR share/cmake/libbatch)
ENDIF()
SET(INSTALL_INCLUDE_DIR include)

SET(LIBBATCH_LOCAL_SUBMISSION TRUE CACHE BOOL "Build classes for local submission")
SET(LIBBATCH_PYTHON_WRAPPING TRUE CACHE BOOL "Generate Python wrapping")
SET(LIBBATCH_BUILD_TESTS FALSE CACHE BOOL "Enable testing")

IF(LIBBATCH_BUILD_TESTS)
  ENABLE_TESTING()
ENDIF()
IF(LIBBATCH_LOCAL_SUBMISSION)
  LIBBATCH_FIND_ALL_LOCAL_COMMANDS()
ENDIF()

INCLUDE(CheckCXXCompilerFlag)

# Option: C++ standard to use
# Note: CMake by default enables C++ extensions; they can be disabled by additionally
#       specifying -DCMAKE_CXX_EXTENSIONS=OFF
SET(LIBBATCH_CXX_STANDARD 11 CACHE STRING "C++ standard to use")
SET(_supported_standards 11 14 17 20)
SET(_standard_ok FALSE)
FOREACH(_standard ${_supported_standards})
  IF(LIBBATCH_CXX_STANDARD STREQUAL _standard)
    SET(_standard_ok TRUE)
    BREAK()
  ENDIF()
ENDFOREACH()
IF(NOT _standard_ok)
  MESSAGE(FATAL_ERROR "Unsupported C++ standard: ${LIBBATCH_CXX_STANDARD}; allowed values: ${_supported_standards}")
ENDIF()
UNSET(_supported_standards)
UNSET(_standard)
UNSET(_standard_ok)
MESSAGE(STATUS "Setting C++ standard to ${LIBBATCH_CXX_STANDARD}")
SET(CMAKE_CXX_STANDARD ${LIBBATCH_CXX_STANDARD})
SET(CMAKE_CXX_STANDARD_REQUIRED ON)

IF(NOT (WIN32 OR APPLE))
  SET(LIBBATCH_DEBUG_WARNINGS FALSE CACHE BOOL "Print more compiler warnings")
  SET(LIBBATCH_TREAT_WARNINGS_AS_ERRORS FALSE CACHE BOOL "Treat compiler warnings as errors")
  IF(LIBBATCH_DEBUG_WARNINGS)
    SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -Wextra -Wpedantic")
    SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wextra -Wpedantic")
  ENDIF()
  IF(LIBBATCH_TREAT_WARNINGS_AS_ERRORS)
    SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Werror")
    SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Werror")
  ENDIF()
ENDIF()

# Compiler flag to disable treating alternative C++ tokens (compatibility with MSVS)
CHECK_CXX_COMPILER_FLAG("-fno-operator-names" COMPILER_SUPPORTS_NO_OPERATOR_NAMES)
IF(COMPILER_SUPPORTS_NO_OPERATOR_NAMES)
  SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fno-operator-names")
ENDIF()

# Prerequisites detection:
# ========================
FIND_PACKAGE(LibbatchPThread REQUIRED)

IF (LIBBATCH_PYTHON_WRAPPING)
  FIND_PACKAGE(LibbatchPython REQUIRED)
  FIND_PACKAGE(LibbatchSWIG REQUIRED)
  
  SET(PYTHON_VERSION "${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}")
  SET(LIBBATCH_PYTHONPATH lib/python${PYTHON_VERSION}/site-packages)
ENDIF()

# Configuration summary
# =====================
LIBBATCH_SUMMARY()

# Configure
# =========
CONFIGURE_FILE(${CMAKE_CURRENT_SOURCE_DIR}/libbatch_config.h.in ${CMAKE_CURRENT_BINARY_DIR}/libbatch_config.h)
ADD_SUBDIRECTORY(src)
ADD_SUBDIRECTORY(misc)

# Export logic
# ============
INCLUDE(CMakePackageConfigHelpers)

# Add all targets to the build-tree export set
EXPORT(TARGETS batch
  FILE ${PROJECT_BINARY_DIR}/${PROJECT_NAME}Targets.cmake)

# Create the configuration files:
#   - in the build tree:

#      Ensure the variables are always defined for the configure:
SET(LIBBATCH_PYTHONPATH "${LIBBATCH_PYTHONPATH}")
SET(PYTHON_ROOT_DIR "${PYTHON_ROOT_DIR}")
SET(SWIG_ROOT_DIR "${SWIG_ROOT_DIR}")
 
SET(CONF_INCLUDE_DIRS "${PROJECT_SOURCE_DIR}/include" "${PROJECT_BINARY_DIR}/include")
CONFIGURE_PACKAGE_CONFIG_FILE(misc/${PROJECT_NAME}Config.cmake.in 
    ${PROJECT_BINARY_DIR}/${PROJECT_NAME}Config.cmake
    INSTALL_DESTINATION "${INSTALL_CMAKE_CONFIG_DIR}"
    PATH_VARS CONF_INCLUDE_DIRS INSTALL_CMAKE_CONFIG_DIR CMAKE_INSTALL_PREFIX LIBBATCH_PYTHONPATH
              PYTHON_ROOT_DIR SWIG_ROOT_DIR PTHREAD_ROOT_DIR)

#   - in the install tree:
#       Get the relative path of the include directory so 
#       we can register it in the generated configuration files:
SET(CONF_INCLUDE_DIRS "${CMAKE_INSTALL_PREFIX}/${INSTALL_INCLUDE_DIR}")
CONFIGURE_PACKAGE_CONFIG_FILE(misc/${PROJECT_NAME}Config.cmake.in 
    ${PROJECT_BINARY_DIR}/to_install/${PROJECT_NAME}Config.cmake
    INSTALL_DESTINATION "${INSTALL_CMAKE_CONFIG_DIR}"
    PATH_VARS CONF_INCLUDE_DIRS INSTALL_CMAKE_CONFIG_DIR CMAKE_INSTALL_PREFIX LIBBATCH_PYTHONPATH
            PYTHON_ROOT_DIR SWIG_ROOT_DIR PTHREAD_ROOT_DIR)

WRITE_BASIC_PACKAGE_VERSION_FILE(${PROJECT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake
    VERSION ${${PROJECT_NAME_UC}_VERSION}
    COMPATIBILITY AnyNewerVersion)
  
# Install the CMake configuration files:
INSTALL(FILES
  "${PROJECT_BINARY_DIR}/to_install/${PROJECT_NAME}Config.cmake"
  "${PROJECT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake"
  DESTINATION "${INSTALL_CMAKE_CONFIG_DIR}")

# Install the export set for use with the install-tree
INSTALL(EXPORT LibBatchTargets DESTINATION "${INSTALL_CMAKE_CONFIG_DIR}")

# Packaging logic
# ===============
SET(CPACK_GENERATOR TGZ)
SET(CPACK_SOURCE_GENERATOR TGZ ZIP)
SET(CPACK_PACKAGE_VERSION_MAJOR ${${PROJECT_NAME}_MAJOR_VERSION})
SET(CPACK_PACKAGE_VERSION_MINOR ${${PROJECT_NAME}_MINOR_VERSION})
SET(CPACK_PACKAGE_VERSION_PATCH ${${PROJECT_NAME}_PATCH_VERSION})
SET(CPACK_SOURCE_IGNORE_FILES /\\\\.;/CVS/;~;/.git/)
SET(CPACK_SOURCE_PACKAGE_FILE_NAME ${PROJECT_NAME}-${${PROJECT_NAME}_VERSION})
INCLUDE(CPack)

