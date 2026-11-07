# Copyright (C) 2019-2026 EDF
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

SET(CMAKE_AUTOMOC ON)

INCLUDE_DIRECTORIES(
  ${PROJECT_SOURCE_DIR}/src/cpp
  ${PYTHON_INCLUDE_DIR}
)

ADD_DEFINITIONS(
  ${PYTHON_DEFINITIONS}
)

SET(YDEFXGUI_SOURCES
  ResourceWidget.cxx
  ParamsConfig.cxx
  PathsConfig.cxx
  QuickConfig.cxx
)

SET(YDEFXGUI_HEADERS
  ResourceWidget.hxx
)

SET(YDEFXGUI_link_LIBRARIES
  Qt5::Widgets
  ydefx
)

ADD_LIBRARY(ydefxgui ${YDEFXGUI_SOURCES})
TARGET_LINK_LIBRARIES(ydefxgui ${YDEFXGUI_link_LIBRARIES})
TARGET_INCLUDE_DIRECTORIES(ydefxgui PUBLIC
                          $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src/gui>
                          $<INSTALL_INTERFACE:${SALOME_INSTALL_HEADERS}>)

ADD_EXECUTABLE(ydefxgui.exe ydefxgui.cxx)
TARGET_LINK_LIBRARIES(ydefxgui.exe ydefxgui)

INSTALL(TARGETS ydefxgui DESTINATION ${SALOME_INSTALL_LIBS})
INSTALL(TARGETS ydefxgui EXPORT ydefxCfg_cmake LIBRARY DESTINATION ${SALOME_INSTALL_LIBS})
INSTALL(FILES ${YDEFXGUI_HEADERS} DESTINATION ${SALOME_INSTALL_HEADERS}/ydefx)
