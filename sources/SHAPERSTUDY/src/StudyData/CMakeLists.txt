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


# --- options ---
# additional include directories
INCLUDE_DIRECTORIES(
  ${OpenCASCADE_INCLUDE_DIR}
)

# additional preprocessor / compiler flags
ADD_DEFINITIONS(
  ${OpenCASCADE_DEFINITIONS}
  ${OMNIORB_DEFINITIONS}
)

# libraries to link to
SET(_link_LIBRARIES
  SalomeIDLGEOM
  ${OpenCASCADE_ModelingAlgorithms_LIBRARIES}
  ${LIB_XAOShaper}
)

# --- headers ---

# header files / no moc processing
SET(STUDYDATA_HEADERS
    StudyData.h
    StudyData_Object.h
    StudyData_Operation.h
    StudyData_XAO.h
)

# --- sources ---

# sources / static
SET(STUDYDATA_SOURCES
    StudyData_Object.cpp
    StudyData_Operation.cpp
    StudyData_XAO.cpp
)

# --- rules ---

ADD_LIBRARY(StudyData ${STUDYDATA_HEADERS} ${STUDYDATA_SOURCES})
#IF(WIN32)
#  TARGET_COMPILE_OPTIONS(SudyData PRIVATE /bigobj) 
#ENDIF(WIN32)

TARGET_LINK_LIBRARIES(StudyData ${_link_LIBRARIES} )
INSTALL(TARGETS StudyData EXPORT ${PROJECT_NAME}TargetGroup DESTINATION ${SALOME_INSTALL_LIBS})

INSTALL(FILES ${STUDYDATA_HEADERS} DESTINATION ${SALOME_INSTALL_HEADERS})
