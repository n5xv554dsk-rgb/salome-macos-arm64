# Copyright (C) 2012-2026  CEA/DEN, EDF R&D, OPEN CASCADE
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

# Common CMake macros
# ===================
SET(CONFIGURATION_ROOT_DIR $ENV{CONFIGURATION_ROOT_DIR} CACHE PATH "Path to the Salome CMake configuration files")
IF(EXISTS ${CONFIGURATION_ROOT_DIR})
  LIST(APPEND CMAKE_MODULE_PATH "${CONFIGURATION_ROOT_DIR}/cmake")
  INCLUDE(SalomeMacros NO_POLICY_SCOPE)
ELSE()
  MESSAGE(FATAL_ERROR "We absolutely need the Salome CMake configuration files, please define CONFIGURATION_ROOT_DIR !")
ENDIF()

FIND_PACKAGE(SalomeQt5)

# additional include directories
INCLUDE_DIRECTORIES(
  ${QT_INCLUDES}
  ${PROJECT_SOURCE_DIR}/src/Qtx
  ${PROJECT_SOURCE_DIR}/src/SUIT
)
# additional preprocessor / compiler flags
ADD_DEFINITIONS(${QT_DEFINITIONS} ${PYTHON_DEFINITIONS})

# libraries to link to
SET(_link_LIBRARIES ${QT_LIBRARIES} qtx suit)

## --- headers ---
#
# header files / to be processed by moc
SET(_moc_HEADERS   
  SalomeApprc_utils.h
)
#
# header files / to install
SET(SalomeApprc_utils_HEADERS ${_moc_HEADERS})

# sources / moc wrappings
QT5_WRAP_CPP(_moc_SOURCES SalomeApprc_utils.cxx)

# --- rules ---

ADD_LIBRARY(SalomeApprc_utils SalomeApprc_utils.cxx)
TARGET_LINK_LIBRARIES(SalomeApprc_utils ${_link_LIBRARIES})
INSTALL(TARGETS SalomeApprc_utils EXPORT ${PROJECT_NAME}TargetGroup DESTINATION ${SALOME_INSTALL_LIBS})

if(WIN32)
   MESSAGE(STATUS "Add SalomeApprc_utils static library")
  add_library(SalomeApprc_utils_lib STATIC  SalomeApprc_utils.cxx)
  TARGET_LINK_LIBRARIES(SalomeApprc_utils_lib ${_link_LIBRARIES})
  set_target_properties(SalomeApprc_utils_lib PROPERTIES OUTPUT_NAME SalomeApprc_utils)
  INSTALL(TARGETS SalomeApprc_utils_lib DESTINATION ${SALOME_INSTALL_LIBS})
endif(WIN32)

INSTALL(FILES ${SalomeApprc_utils_HEADERS} DESTINATION ${SALOME_INSTALL_HEADERS})
