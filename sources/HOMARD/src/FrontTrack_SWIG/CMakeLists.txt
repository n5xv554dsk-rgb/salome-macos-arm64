# Copyright (C) 2017-2026  CEA, EDF
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

ADD_DEFINITIONS(${PYTHON_DEFINITIONS})

SET_SOURCE_FILES_PROPERTIES(FrontTrack.i PROPERTIES CPLUSPLUS ON)
SET_SOURCE_FILES_PROPERTIES(FrontTrack.i PROPERTIES SWIG_DEFINITIONS "-shadow")

INCLUDE_DIRECTORIES(
  ${PYTHON_INCLUDE_DIRS}
  ${PTHREAD_INCLUDE_DIR} # pthread dependancy due to python2.7 library
  ${CMAKE_CURRENT_SOURCE_DIR}
  ${CMAKE_CURRENT_SOURCE_DIR}/../FrontTrack
  )

IF(${CMAKE_VERSION} VERSION_LESS "3.8.0")
  SWIG_ADD_MODULE(FrontTrack python FrontTrack.i)
ELSE()
  SWIG_ADD_LIBRARY(FrontTrack LANGUAGE python SOURCES FrontTrack.i)
ENDIF()

SWIG_LINK_LIBRARIES(FrontTrack ${PYTHON_LIBRARIES} ${PLATFORM_LIBS} FrontTrack)

IF(WIN32)
  SET_TARGET_PROPERTIES(_FrontTrack PROPERTIES DEBUG_OUTPUT_NAME _FrontTrack_d)
ENDIF(WIN32)
set(SALOME_HOMARD_INSTALL_PYTHON "lib/python${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}/site-packages")
INSTALL(TARGETS ${SWIG_MODULE_FrontTrack_REAL_NAME} DESTINATION ${SALOME_HOMARD_INSTALL_PYTHON})
SALOME_INSTALL_SCRIPTS(${CMAKE_CURRENT_BINARY_DIR}/FrontTrack.py ${SALOME_HOMARD_INSTALL_PYTHON} EXTRA_DPYS "${SWIG_MODULE_FrontTrack_REAL_NAME}")
