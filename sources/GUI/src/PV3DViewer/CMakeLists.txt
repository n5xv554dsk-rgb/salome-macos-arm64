# Copyright (C) 2014-2026  CEA, EDF, OPEN CASCADE
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

INCLUDE_DIRECTORIES(
  ${SALOMEBOOTSTRAP_INCLUDE_DIRS}
  ${KERNEL_INCLUDE_DIRS}
  ${PROJECT_SOURCE_DIR}/src/Qtx
  ${PROJECT_SOURCE_DIR}/src/SUIT
  ${PROJECT_SOURCE_DIR}/src/PV3DViewer
  ${PROJECT_SOURCE_DIR}/src/PVViewer
  ${PROJECT_SOURCE_DIR}/src/PVServerService
  )

ADD_DEFINITIONS(
  ${KERNEL_DEFINITIONS}
  ${PYTHON_DEFINITIONS}
  )

SET(_link_LIBRARIES 
  ${SALOMEBOOTSTRAP_SALOMELocalTrace}
  ${KERNEL_OpUtil}
  suit 
  PVViewer
  PVServerService
  ParaView::pqApplicationComponents
  ParaView::pqPython
  )

# --- headers ---

# header files / to be processed by moc
SET(_moc_HEADERS
  PV3DViewer_ViewManager.h
  PV3DViewer_ViewModel.h
  PV3DViewer_ViewWindow.h
  # PV3DViewer_Behaviors.h
  # PV3DViewer_GUIElements.h
  # PV3DViewer_InitSingleton.h
)

# header files / no moc processing
SET(_other_HEADERS
  PV3DViewer.h
  # PV3DViewer_OutputWindow.h
  # PV3DViewer_Core.h
)
# header files / to install
SET(PV3DViewer_HEADERS ${_moc_HEADERS} ${_other_HEADERS})

# resource files / to be processed by lrelease
SET(_ts_RESOURCES
  resources/PV3DViewer_msg_en.ts
  resources/PV3DViewer_msg_ja.ts
  resources/PV3DViewer_msg_fr.ts
)

# --- sources ---

# sources / moc wrappings
QT_WRAP_MOC(_moc_SOURCES ${_moc_HEADERS})

# sources / rcc wrappings
QT_ADD_RESOURCES(_rcc_SOURCES ${_rcc_RESOURCES})

# sources / static
SET(_other_SOURCES
  PV3DViewer_ViewManager.cxx
  PV3DViewer_ViewModel.cxx
  PV3DViewer_ViewWindow.cxx
  # PV3DViewer_OutputWindow.cxx
  # PV3DViewer_Behaviors.cxx
  # PV3DViewer_GUIElements.cxx
  # PV3DViewer_Core.cxx
  # PV3DViewer_InitSingleton.cxx
  )
  
# sources / to compile
SET(PV3DViewer_SOURCES 
  ${_other_SOURCES} 
  ${_moc_SOURCES} 
  ${_rcc_SOURCES}
  )

# --- rules ---
ADD_LIBRARY(PV3DViewer ${PV3DViewer_SOURCES})

TARGET_LINK_LIBRARIES(PV3DViewer ${_link_LIBRARIES})
INSTALL(TARGETS PV3DViewer EXPORT ${PROJECT_NAME}TargetGroup DESTINATION ${SALOME_INSTALL_LIBS})

QT_INSTALL_TS_RESOURCES("${_ts_RESOURCES}" "${SALOME_GUI_INSTALL_RES_DATA}")

# --- header and resources installation ---
INSTALL(FILES ${PV3DViewer_HEADERS} DESTINATION ${SALOME_INSTALL_HEADERS})
