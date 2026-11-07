# Copyright (C) 2007-2026  CEA, EDF
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

IF(SALOME_BUILD_GUI)
  SET(HexoticPLUGIN_RESOURCES_FILES_WITH_GUI
	sd_mode_geom.png
    sd_mode_1.png
    sd_mode_2.png
    sd_mode_3.png
    sd_mode_4.png
  )
ENDIF(SALOME_BUILD_GUI)

INSTALL(FILES ${HexoticPLUGIN_RESOURCES_FILES_WITH_GUI} DESTINATION ${SALOME_HexoticPLUGIN_INSTALL_RES_DATA})
