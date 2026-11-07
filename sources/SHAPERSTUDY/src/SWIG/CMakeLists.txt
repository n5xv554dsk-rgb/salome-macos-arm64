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

INCLUDE(${SWIG_USE_FILE})

# --- options ---
# additional include directories
INCLUDE_DIRECTORIES(
  ${PYTHON_INCLUDE_DIRS}
  ${OpenCASCADE_INCLUDE_DIR}
  ${OMNIORB_INCLUDE_DIR}
  ${PROJECT_SOURCE_DIR}/src/StudyData
)

# additional preprocessor / compiler flags
ADD_DEFINITIONS(
  ${OpenCASCADE_DEFINITIONS}
  ${OMNIORB_DEFINITIONS}
  ${PYTHON_DEFINITIONS}
)

# libraries to link to
SET(_link_LIBRARIES
  StudyData
  ${PYTHON_LIBRARIES}
)

# --- headers ---

# header files / to be processed by moc
SET(SHAPERSTUDY_Swig_HEADERS
)

# --- sources ---

# sources / static
SET(StudyData_Swig_SOURCES
  StudyData_Swig.i
  #${SHAPERSTUDY_Swig_HEADERS}
)

# workaround about SWIG_ADD_MODULE bug: remove duplicates in include directories
GET_DIRECTORY_PROPERTY(_cmake_include_directories INCLUDE_DIRECTORIES)
LIST(REMOVE_DUPLICATES _cmake_include_directories)
SET_DIRECTORY_PROPERTIES(PROPERTIES INCLUDE_DIRECTORIES "${_cmake_include_directories}")

# swig flags
SET_SOURCE_FILES_PROPERTIES(StudyData_Swig.i PROPERTIES CPLUSPLUS ON)
SET_SOURCE_FILES_PROPERTIES(StudyData_Swig.i PROPERTIES SWIG_FLAGS "-py3")
SET_SOURCE_FILES_PROPERTIES(StudyData_swig_wrap.cpp PROPERTIES COMPILE_FLAGS "-DHAVE_CONFIG_H")

# --- scripts ---

# scripts / swig wrappings
SET(_swig_SCRIPTS
  ${CMAKE_CURRENT_BINARY_DIR}/StudyData_Swig.py 
)

# --- rules ---
IF(${CMAKE_VERSION} VERSION_LESS "3.8.0") 
  SWIG_ADD_MODULE(StudyData_Swig python ${StudyData_Swig_SOURCES})
ELSE()
  SWIG_ADD_LIBRARY(StudyData_Swig LANGUAGE python SOURCES ${StudyData_Swig_SOURCES})
ENDIF()


SWIG_LINK_LIBRARIES(StudyData_Swig ${_link_LIBRARIES})
SWIG_CHECK_GENERATION(StudyData_Swig)
IF(WIN32)
  SET_TARGET_PROPERTIES(_StudyData_Swig PROPERTIES DEBUG_OUTPUT_NAME _StudyData_Swig_d)
ENDIF(WIN32)

INSTALL(TARGETS _StudyData_Swig DESTINATION ${SALOME_INSTALL_LIBS})

INSTALL(FILES ${StudyData_Swig_HEADERS} DESTINATION ${SALOME_INSTALL_HEADERS})

SALOME_INSTALL_SCRIPTS("${_swig_SCRIPTS}"  ${SALOME_INSTALL_BINS} EXTRA_DPYS "${SWIG_MODULE_StudyData_Swig_REAL_NAME}")
