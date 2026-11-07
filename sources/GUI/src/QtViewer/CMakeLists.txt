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
  ${PROJECT_SOURCE_DIR}/src/Qtx
  ${PROJECT_SOURCE_DIR}/src/SUIT
  ${PROJECT_SOURCE_DIR}/src/ImageComposer
)

# additional preprocessor / compiler flags
ADD_DEFINITIONS(${QT_DEFINITIONS})

# libraries to link to
SET(_link_LIBRARIES ${QT_LIBRARIES} qtx suit ImageComposer)

# --- headers ---

# header files / to be processed by moc
SET(_moc_HEADERS   
  QtViewer_Scene.h
  QtViewer_Selector.h
  QtViewer_ViewFrame.h
  QtViewer_ViewManager.h
  QtViewer_ViewPort.h
  QtViewer_Viewer.h
)

# header files / no moc processing
SET(_other_HEADERS
  QtViewer.h
  QtViewer_Object.h
  QtViewer_PainterObject.h
)

# header files / to install
SET(QtViewer_HEADERS ${_moc_HEADERS} ${_other_HEADERS})

# --- resources ---

# resource files / to be processed by lrelease
SET(_ts_RESOURCES
  resources/QtViewer_images.ts
  resources/QtViewer_msg_en.ts
  resources/QtViewer_msg_fr.ts
  resources/QtViewer_msg_ja.ts
)

# resource files / static
SET(_other_RESOURCES
  resources/qtviewer_cursor_zoom.png
  resources/qtviewer_dump.png
  resources/qtviewer_fitall.png
  resources/qtviewer_fitarea.png
  resources/qtviewer_fitselect.png
  resources/qtviewer_glpan.png
  resources/qtviewer_pan.png
  resources/qtviewer_reset.png
  resources/qtviewer_rotate.png
  resources/qtviewer_zoom.png
)

# --- sources ---

# sources / moc wrappings
QT_WRAP_MOC(_moc_SOURCES ${_moc_HEADERS})

# sources / static
SET(_other_SOURCES
  QtViewer_Object.cxx
  QtViewer_PainterObject.cxx
  QtViewer_Scene.cxx
  QtViewer_Selector.cxx
  QtViewer_ViewFrame.cxx
  QtViewer_ViewManager.cxx
  QtViewer_ViewPort.cxx
  QtViewer_Viewer.cxx
)

# sources / to compile
SET(QtViewer_SOURCES ${_other_SOURCES} ${_moc_SOURCES})

# --- rules ---

ADD_LIBRARY(QtViewer ${QtViewer_SOURCES})
TARGET_LINK_LIBRARIES(QtViewer ${_link_LIBRARIES})
INSTALL(TARGETS QtViewer EXPORT ${PROJECT_NAME}TargetGroup DESTINATION ${SALOME_INSTALL_LIBS})

INSTALL(FILES ${QtViewer_HEADERS} DESTINATION ${SALOME_INSTALL_HEADERS})
QT_INSTALL_TS_RESOURCES("${_ts_RESOURCES}" "${SALOME_GUI_INSTALL_RES_DATA}")

INSTALL(FILES ${_other_RESOURCES} DESTINATION ${SALOME_GUI_INSTALL_RES_DATA})
