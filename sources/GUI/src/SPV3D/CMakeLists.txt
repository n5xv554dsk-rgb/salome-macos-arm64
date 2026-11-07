# Copyright (C) 2023-2026  CEA, EDF
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
  ${OpenCASCADE_INCLUDE_DIR}
  ${QT_INCLUDES}
  ${Boost_INCLUDE_DIRS}
  ${PTHREAD_INCLUDE_DIR}
  ${PROJECT_SOURCE_DIR}/src/Qtx
  ${PROJECT_SOURCE_DIR}/src/SUIT
  ${PROJECT_SOURCE_DIR}/src/OBJECT
  ${PROJECT_SOURCE_DIR}/src/Prs
  ${PROJECT_SOURCE_DIR}/src/PV3DViewer
  ${PROJECT_SOURCE_DIR}/src/PVViewer
  ${PROJECT_SOURCE_DIR}/src/PVServerService
)

# additional preprocessor / compiler flags
ADD_DEFINITIONS(${QT_DEFINITIONS} ${OpenCASCADE_DEFINITIONS} ${BOOST_DEFINITIONS})

# libraries to link to
SET(_link_LIBRARIES 
  ${QT_LIBRARIES}
  ${OPENGL_LIBRARIES}
  ${OpenCASCADE_FoundationClasses_LIBRARIES} ${OpenCASCADE_Visualization_LIBRARIES}
  ${KERNEL_OpUtil}
  qtx suit 
  SalomeObject SalomePrs PV3DViewer PVViewer PVServerService
  ParaView::pqApplicationComponents
  ParaView::pqPython
  ParaView::RemotingViews
)

# --- headers ---

# header files / to be processed by moc
SET(_moc_HEADERS
   SPV3D_ViewManager.h
   SPV3D_ViewModel.h
   SPV3D_ViewWindow.h
   SPV3D_CADSelection.h
)

# header files / no moc processing
SET(_other_HEADERS
   SPV3D.h
   SPV3D_Prs.h
)

# header files / to install
SET(SPV3D_HEADERS ${_moc_HEADERS} ${_other_HEADERS})

# --- sources ---

# sources / moc wrappings
QT_WRAP_MOC(_moc_SOURCES ${_moc_HEADERS} ${_moc_internal_HEADERS})

# sources / static
SET(_other_SOURCES
   SPV3D_Prs.cxx
   SPV3D_ViewManager.cxx
   SPV3D_ViewModel.cxx
   SPV3D_ViewWindow.cxx
   SPV3D_CADSelection.cxx
)

# sources / to compile
SET(SPV3D_SOURCES ${_other_SOURCES} ${_moc_SOURCES})

# --- rules ---

ADD_LIBRARY(SPV3D ${SPV3D_SOURCES})
TARGET_LINK_LIBRARIES(SPV3D ${_link_LIBRARIES})
INSTALL(TARGETS SPV3D EXPORT ${PROJECT_NAME}TargetGroup DESTINATION ${SALOME_INSTALL_LIBS})

INSTALL(FILES ${SPV3D_HEADERS} DESTINATION ${SALOME_INSTALL_HEADERS})
# QT_INSTALL_TS_RESOURCES("${_ts_RESOURCES}" "${SALOME_GUI_INSTALL_RES_DATA}")

INSTALL(FILES ${_other_RESOURCES} DESTINATION ${SALOME_GUI_INSTALL_RES_DATA})
