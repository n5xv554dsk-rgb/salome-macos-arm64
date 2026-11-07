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

INCLUDE(UseQtExt)

# --- options ---
# additional include directories
INCLUDE_DIRECTORIES(
  ${QT_INCLUDES}
  ${OpenCASCADE_INCLUDE_DIR}
  ${PYTHON_INCLUDE_DIRS}
  ${Boost_INCLUDE_DIRS}
  ${OMNIORB_INCLUDE_DIR}
  ${KERNEL_INCLUDE_DIRS}
  ${GUI_INCLUDE_DIRS}
  ${PROJECT_BINARY_DIR}
  ${PROJECT_BINARY_DIR}/idl
  ${PROJECT_SOURCE_DIR}/src/HELLO
)

# additional preprocessor / compiler flags
ADD_DEFINITIONS(
  ${QT_DEFINITIONS}
  ${OMNIORB_DEFINITIONS}
  ${OpenCASCADE_DEFINITIONS}
  ${BOOST_DEFINITIONS}
  ${PYTHON_DEFINITIONS}
)

# libraries to link to
SET(_link_LIBRARIES
  ${KERNEL_SalomeLifeCycleCORBA}
  ${KERNEL_SalomeDS}
  ${GUI_SalomeApp}
  HELLOEngine
)

# --- headers ---

# header files / to be processed by moc
SET(HELLOGUI_HEADERS
  HELLOGUI.h
)

# --- sources ---

# sources / moc wrappings
QT_WRAP_MOC(_moc_SOURCES ${HELLOGUI_HEADERS})


# sources / static
SET(_other_SOURCES
  HELLOGUI.cxx
)

# sources / to compile
SET(HELLOGUI_SOURCES ${_other_SOURCES} ${_moc_SOURCES})

# --- resources ---

# resource files / to be processed by lrelease
SET(_ts_RESOURCES
  HELLO_icons.ts
  HELLO_msg_en.ts
  HELLO_msg_fr.ts
  HELLO_msg_ja.ts
) 

# --- rules ---

ADD_LIBRARY(HELLO ${HELLOGUI_SOURCES})
TARGET_LINK_LIBRARIES(HELLO SalomeIDLHELLO ${_link_LIBRARIES} )
INSTALL(TARGETS HELLO EXPORT ${PROJECT_NAME}TargetGroup DESTINATION ${SALOME_INSTALL_LIBS})

INSTALL(FILES ${HELLOGUI_HEADERS} DESTINATION ${SALOME_INSTALL_HEADERS})
QT_INSTALL_TS_RESOURCES("${_ts_RESOURCES}" "${SALOME_HELLO_INSTALL_RES_DATA}")
