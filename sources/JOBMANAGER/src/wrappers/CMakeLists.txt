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

# --- options ---
# additional include directories
INCLUDE_DIRECTORIES(
  ${QT_INCLUDES}
  ${OMNIORB_INCLUDE_DIR}
  ${KERNEL_INCLUDE_DIRS}
  ${GUI_INCLUDE_DIRS}
  ${Boost_INCLUDE_DIRS}
  ${PROJECT_SOURCE_DIR}/src/bases
)

# additional preprocessor / compiler flags
ADD_DEFINITIONS(
  ${QT_DEFINITIONS}
  ${OMNIORB_DEFINITIONS}
  ${BOOST_DEFINITIONS}
)

# libraries to link to
SET(_link_LIBRARIES_Wrappers_Qt
  ${QT_LIBRARIES}
  BL_Bases
)

SET(_link_LIBRARIES_Wrappers_SALOME
  ${CORBA_LIBS}
  ${GUI_LightApp}
  ${GUI_SalomeApp}
  ${GUI_SalomeSession}
  ${GUI_CAM}
  ${GUI_suit}
  ${KERNEL_SalomeIDLKernel}
  ${_link_LIBRARIES_Wrappers_Qt}
)

# --- sources ---

# sources / static
SET(BL_Wrappers_Qt_SOURCES
  BL_MainWindows_Wrap.hxx
  BL_MainWindows_Qt.cxx
  BL_MainWindows_Qt.hxx
)

SET(BL_Wrappers_SALOME_SOURCES
  BL_MainWindows_Wrap.hxx
  BL_MainWindows_SALOME.cxx
  BL_MainWindows_SALOME.hxx
)

# --- rules ---

ADD_LIBRARY(BL_Wrappers_Qt ${BL_Wrappers_Qt_SOURCES})
TARGET_LINK_LIBRARIES(BL_Wrappers_Qt ${_link_LIBRARIES_Wrappers_Qt} )
INSTALL(TARGETS BL_Wrappers_Qt EXPORT ${PROJECT_NAME}TargetGroup DESTINATION ${SALOME_INSTALL_LIBS})

ADD_LIBRARY(BL_Wrappers_SALOME ${BL_Wrappers_SALOME_SOURCES})
TARGET_LINK_LIBRARIES(BL_Wrappers_SALOME ${_link_LIBRARIES_Wrappers_SALOME} )
INSTALL(TARGETS BL_Wrappers_SALOME EXPORT ${PROJECT_NAME}TargetGroup DESTINATION ${SALOME_INSTALL_LIBS})
