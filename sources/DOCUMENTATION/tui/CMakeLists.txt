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

# Install [tui] documentation for SALOME modules
# ==============================================

SET(_modules
  BLSURFPLUGIN
  GEOM
  GUI
  KERNEL
  SHAPER
  SMESH
  YACS
)

FOREACH(_module ${_modules})
  SET(_root_dir $ENV{${_module}_ROOT_DIR})
  IF(_root_dir)
    FILE(TO_CMAKE_PATH "${_root_dir}/share/doc/salome/tui/${_module}" _doc_path)
    SALOME_INSTALL_MODULE_DOC("${_doc_path}"
                              DESTINATION ${SALOME_INSTALL_DOC_TUI})
  ENDIF()
ENDFOREACH()
