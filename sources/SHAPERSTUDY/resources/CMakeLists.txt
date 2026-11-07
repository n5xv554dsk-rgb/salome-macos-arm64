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

SET(SHAPERSTUDY_RESOURCES_FILES
    compsolid.png
    edge.png
    face.png
    shaper.png
    shell.png
    solid.png
    vertex.png
    wire.png
    compsolid_field.png
    vertex_field.png
    edge_field.png
    face_field.png
    shell_field.png
    solid_field.png
    wire_field.png
    compsolid_dead.png
    vertex_dead.png
    edge_dead.png
    face_dead.png
    shell_dead.png
    solid_dead.png
    wire_dead.png
)

INSTALL(FILES ${SHAPERSTUDY_RESOURCES_FILES} DESTINATION ${SALOME_SHAPERSTUDY_INSTALL_RES_DATA})

SALOME_CONFIGURE_FILE(${CMAKE_CURRENT_SOURCE_DIR}/SalomeApp.xml.in ${CMAKE_CURRENT_BINARY_DIR}/SalomeApp.xml INSTALL ${SALOME_SHAPERSTUDY_INSTALL_RES_DATA})
SALOME_CONFIGURE_FILE(${CMAKE_CURRENT_SOURCE_DIR}/SalomeApp.xml.in ${CMAKE_CURRENT_BINARY_DIR}/SalomeAppSL.xml INSTALL ${SALOME_SHAPERSTUDY_INSTALL_RES_DATA})
SALOME_CONFIGURE_FILE(${CMAKE_CURRENT_SOURCE_DIR}/SHAPERSTUDYCatalog.xml.in ${CMAKE_CURRENT_BINARY_DIR}/SHAPERSTUDYCatalog.xml INSTALL ${SALOME_SHAPERSTUDY_INSTALL_RES_DATA})
