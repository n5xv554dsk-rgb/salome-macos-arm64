# Copyright (C) 2007-2026  CEA, EDF, OPEN CASCADE
#
# Copyright (C) 2003-2007  OPEN CASCADE, EADS/CCR, LIP6, CEA/DEN,
# CEDRAT, EDF R&D, LEG, PRINCIPIA R&D, BUREAU VERITAS
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

SET(PYHELLO_RESOURCES_FILES
  ExecPYHELLO.png
  handshake.png
  PYHELLO_small.png
  PYHELLO.png
  stop.png
  schema.xml
)

INSTALL(FILES ${PYHELLO_RESOURCES_FILES} DESTINATION ${SALOME_PYHELLO_INSTALL_RES_DATA})

SALOME_CONFIGURE_FILE(${CMAKE_CURRENT_SOURCE_DIR}/SalomeApp.xml.in ${CMAKE_CURRENT_BINARY_DIR}/SalomeApp.xml INSTALL ${SALOME_PYHELLO_INSTALL_RES_DATA})

SALOME_CONFIGURE_FILE(${CMAKE_CURRENT_SOURCE_DIR}/SalomeApp.xml.in ${CMAKE_CURRENT_BINARY_DIR}/SalomeAppSL.xml INSTALL ${SALOME_PYHELLO_INSTALL_RES_DATA})

SALOME_CONFIGURE_FILE(${CMAKE_CURRENT_SOURCE_DIR}/PYHELLOCatalog.xml.in ${CMAKE_CURRENT_BINARY_DIR}/PYHELLOCatalog.xml INSTALL ${SALOME_PYHELLO_INSTALL_RES_DATA})
