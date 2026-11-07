# Copyright (C) 2012-2026  CEA, EDF
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

INCLUDE(UseQtExt)

# --- options ---
# additional include directories
INCLUDE_DIRECTORIES(
  ${Boost_INCLUDE_DIRS}
  ${OMNIORB_INCLUDE_DIR}
  ${KERNEL_INCLUDE_DIRS}
  ${GUI_INCLUDE_DIRS}
  ${PROJECT_BINARY_DIR}
  ${PROJECT_BINARY_DIR}/idl
  ${PROJECT_SOURCE_DIR}/src/genericgui
  ${PROJECT_SOURCE_DIR}/src/wrappers
  ${PROJECT_SOURCE_DIR}/src/engine
  ${PROJECT_SOURCE_DIR}/src/bases
)

# additional preprocessor / compiler flags
ADD_DEFINITIONS(
  ${OMNIORB_DEFINITIONS}
  ${BOOST_DEFINITIONS}
)

# libraries to link to
SET(_link_LIBRARIES
  ${CORBA_LIBS}
  BL_Bases
  BL_Engine
  BL_GenericGui
  BL_Wrappers_SALOME
  JOBMANAGER_IDL
)

# --- headers ---

# header files / to be processed by moc
SET(JOBMANAGER_HEADERS
  BL_SalomeGui.hxx
)

# --- sources ---

# sources / moc wrappings
QT_WRAP_MOC(_moc_SOURCES ${JOBMANAGER_HEADERS})

# sources / static
SET(_other_SOURCES
  BL_SalomeGui.cxx
)

# --- resources ---

SALOME_CONFIGURE_FILE(${CMAKE_CURRENT_SOURCE_DIR}/resources/SalomeApp.xml.in ${CMAKE_CURRENT_BINARY_DIR}/resources/SalomeApp.xml INSTALL ${SALOME_JOBMANAGER_INSTALL_RES_DATA})
SALOME_CONFIGURE_FILE(${CMAKE_CURRENT_SOURCE_DIR}/resources/SalomeApp.xml.in ${CMAKE_CURRENT_BINARY_DIR}/resources/SalomeAppSL.xml INSTALL ${SALOME_JOBMANAGER_INSTALL_RES_DATA})

# resource files / static
SET(_other_RESOURCES
  resources/jobmanager.png
)

# sources / to compile
SET(JOBMANAGER_SOURCES ${_other_SOURCES} ${_moc_SOURCES})

# --- rules ---

ADD_LIBRARY(JOBMANAGER ${JOBMANAGER_SOURCES})
TARGET_LINK_LIBRARIES(JOBMANAGER ${_link_LIBRARIES} )
INSTALL(TARGETS JOBMANAGER EXPORT ${PROJECT_NAME}TargetGroup DESTINATION ${SALOME_INSTALL_LIBS})

INSTALL(FILES ${JOBMANAGER_HEADERS} DESTINATION ${SALOME_INSTALL_HEADERS})

INSTALL(FILES ${_other_RESOURCES} DESTINATION ${SALOME_JOBMANAGER_INSTALL_RES_DATA})