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

ADD_SUBDIRECTORY(resources)

INCLUDE(UseQtExt)

# --- options ---
# additional include directories
INCLUDE_DIRECTORIES(
  ${QT_INCLUDES}
  ${OpenCASCADE_INCLUDE_DIR}
  ${PYTHON_INCLUDES}
  ${KERNEL_INCLUDE_DIRS}
  ${GUI_INCLUDE_DIRS}
  ${GEOM_INCLUDE_DIRS}
  ${SMESH_INCLUDE_DIRS}
  ${MEDCOUPLING_INCLUDE_DIRS}
  ${Boost_INCLUDE_DIRS}
  ${OMNIORB_INCLUDE_DIR}
  ${CMAKE_CURRENT_BINARY_DIR}
  ${PROJECT_BINARY_DIR}/idl
  ${PROJECT_SOURCE_DIR}/src/HexoticPlugin
  ${PROJECT_SOURCE_DIR}/src/GUI
)

# additional preprocessor / compiler flags
ADD_DEFINITIONS(
  ${QT_DEFINITIONS}
  ${OMNIORB_DEFINITIONS}
  ${OpenCASCADE_DEFINITIONS}
  ${BOOST_DEFINITIONS}
)

# libraries to link to
SET(_link_LIBRARIES
  ${SMESH_SMESH}
  ${SMESH_StdMeshersGUI}
  ${SMESH_PluginUtils}
  ${OpenCASCADE_FoundationClasses_LIBRARIES}
  ${GUI_suit}
  ${GUI_qtx}
  ${GUI_SalomeApp}
  ${QT_LIBRARIES}
  SalomeIDLHexoticPLUGIN
  HexoticEngine
)

# --- headers ---

# header files / to be processed by moc
SET(_moc_HEADERS
  HexoticPluginGUI_HypothesisCreator.h
  HexoticPluginGUI_Dlg.h
  HexoticPluginGUI_TreeWidget.h
)

# header files / no moc processed
SET(_other_HEADERS
  HexoticPluginGUI.h 
)

SET(HexoticPluginGUI_HEADERS ${_moc_HEADERS} ${_other_HEADERS})

# --- sources ---

# sources / moc wrappings
QT_WRAP_MOC(_moc_SOURCES ${_moc_HEADERS})

# sources / static
SET(_other_SOURCES
  HexoticPluginGUI.cxx
  HexoticPluginGUI_StdWidget.cxx
  HexoticPluginGUI_AdvWidget.cxx
  HexoticPluginGUI_SizeMapsWidget.cxx
  HexoticPluginGUI_ViscousLayersWidget.cxx
  HexoticPluginGUI_HypothesisCreator.cxx
  HexoticPluginGUI_TreeWidget.cxx
)

# --- resources ---

# resource files / to be processed by lrelease
SET(_ts_RESOURCES
  HexoticPLUGIN_images.ts
  HexoticPLUGIN_msg_en.ts
  HexoticPLUGIN_msg_fr.ts
  HexoticPLUGIN_msg_ja.ts
) 

# resource files / to be processed by uic
SET(_uic_files
  HexoticPluginGUI_StdWidget_QTD.ui
  HexoticPluginGUI_AdvWidget_QTD.ui
  HexoticPluginGUI_SizeMapsWidget_QTD.ui
  HexoticPluginGUI_ViscousLayersWidget_QTD.ui
)

# header files / uic wrappings
QT_WRAP_UIC(_uic_HEADERS ${_uic_files})

# sources / to compile
SET(HexoticPluginGUI_SOURCES ${_other_SOURCES} ${_moc_SOURCES} ${_uic_HEADERS})

# --- rules ---

ADD_LIBRARY(HexoticPluginGUI ${HexoticPluginGUI_SOURCES})
TARGET_LINK_LIBRARIES(HexoticPluginGUI ${_link_LIBRARIES} )
INSTALL(TARGETS HexoticPluginGUI EXPORT ${PROJECT_NAME}TargetGroup DESTINATION ${SALOME_INSTALL_LIBS})

INSTALL(FILES ${HexoticPluginGUI_HEADERS} DESTINATION ${SALOME_INSTALL_HEADERS})

QT_INSTALL_TS_RESOURCES("${_ts_RESOURCES}" "${SALOME_HexoticPLUGIN_INSTALL_RES_DATA}")
