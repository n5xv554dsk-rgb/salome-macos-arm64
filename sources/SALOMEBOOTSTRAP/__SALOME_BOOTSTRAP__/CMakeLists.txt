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

SALOME_CONFIGURE_FILE(SalomeOnDemandTK/__init__.py.in SalomeOnDemandTK/__init__.py)

SET(BOOTSTRAP_SCRIPTS
  ${CMAKE_CURRENT_BINARY_DIR}/SalomeOnDemandTK/__init__.py
  SalomeOnDemandTK/extension_unpacker.py
  SalomeOnDemandTK/extension_query.py
  SalomeOnDemandTK/extension_query_impl.py
  SalomeOnDemandTK/extension_remover.py
  SalomeOnDemandTK/extension_utilities.py
  )

SET(SALOME_PKG_DRIVER
  salome_pkg
  salome_pkg_install.py
  salome_pkg_remove.py
)
INSTALL(PROGRAMS ${SALOME_PKG_DRIVER}
        DESTINATION ${SALOME_BOOTSTRAP})
INSTALL(FILES ${BOOTSTRAP_SCRIPTS} DESTINATION ${SALOME_BOOTSTRAP}/SalomeOnDemandTK)
