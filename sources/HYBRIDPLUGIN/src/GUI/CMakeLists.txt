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
  ${QT_INCLUDES}
  ${OpenCASCADE_INCLUDE_DIR}
  ${PYTHON_INCLUDE_DIRS}
  ${SALOMEBOOTSTRAP_INCLUDE_DIRS}
  ${KERNEL_INCLUDE_DIRS}
  ${GUI_INCLUDE_DIRS}
  ${GEOM_INCLUDE_DIRS}
  ${SMESH_INCLUDE_DIRS}
  ${MEDCOUPLING_INCLUDE_DIRS}
  ${Boost_INCLUDE_DIRS}
  ${OMNIORB_INCLUDE_DIR}
  ${CMAKE_CURRENT_BINARY_DIR}
  ${PROJECT_BINARY_DIR}/idl
  ${PROJECT_SOURCE_DIR}/src/HYBRIDPlugin
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
  ${QT_LIBRARIES}
  ${SALOMEBOOTSTRAP_SALOMELocalTrace}
  ${GEOM_GEOM}
  ${SMESH_SMESH}
  ${SMESH_PluginUtils}
  ${SMESH_StdMeshersGUI}
  ${SMESH_SMESHFiltersSelection}
  ${GUI_suit}
  ${GUI_qtx}
  ${GUI_SalomeApp}
  ${OpenCASCADE_FoundationClasses_LIBRARIES}
  SalomeIDLHYBRIDPLUGIN
)

# --- headers ---

# header files / to be processed by moc
SET(_moc_HEADERS
  HYBRIDPluginGUI_TreeWidget.h
  HYBRIDPluginGUI_HypothesisCreator.h
  HYBRIDPluginGUI_Dlg.h
)

# header files / no moc processed
SET(_other_HEADERS
  HYBRIDPluginGUI_Enums.h
)

SET(HYBRIDPluginGUI_HEADERS ${_moc_HEADERS} ${_other_HEADERS})

# --- sources ---

# sources / moc wrappings
QT_WRAP_MOC(_moc_SOURCES ${_moc_HEADERS})

# sources / static
SET(_other_SOURCES
  HYBRIDPluginGUI.cxx
  HYBRIDPluginGUI_HypothesisCreator.cxx
  HYBRIDPluginGUI_StdWidget.cxx
  HYBRIDPluginGUI_AdvWidget.cxx
  HYBRIDPluginGUI_TreeWidget.cxx
)

# --- resources ---

# resource files / to be processed by lrelease
SET(_ts_RESOURCES
  HYBRIDPlugin_images.ts
  HYBRIDPlugin_msg_en.ts
  HYBRIDPlugin_msg_fr.ts
  HYBRIDPlugin_msg_ja.ts
)

# resource files / to be processed by uic
SET(_uic_files
  HYBRIDPluginGUI_StdWidget_QTD.ui
  HYBRIDPluginGUI_AdvWidget_QTD.ui
)

# header files / uic wrappings
QT_WRAP_UIC(_uic_HEADERS ${_uic_files})

# sources / to compile
SET(HYBRIDPluginGUI_SOURCES ${_other_SOURCES} ${_moc_SOURCES} ${_uic_HEADERS})

# --- rules ---

ADD_LIBRARY(HYBRIDPluginGUI ${HYBRIDPluginGUI_SOURCES})
TARGET_LINK_LIBRARIES(HYBRIDPluginGUI ${_link_LIBRARIES} )
INSTALL(TARGETS HYBRIDPluginGUI EXPORT ${PROJECT_NAME}TargetGroup DESTINATION ${SALOME_INSTALL_LIBS})

INSTALL(FILES ${HYBRIDPluginGUI_HEADERS} DESTINATION ${SALOME_INSTALL_HEADERS})
QT_INSTALL_TS_RESOURCES("${_ts_RESOURCES}" "${SALOME_HYBRIDPLUGIN_INSTALL_RES_DATA}")
