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

IF(MED_INT_IS_LONG)
  # Homard tests are unavailable if medfile is built with 32-bits UIDs
  IF(SALOME_BUILD_TESTS)
    ADD_SUBDIRECTORY(Test)
  ENDIF(SALOME_BUILD_TESTS)

  FILE(GLOB sample_files
    ${PROJECT_SOURCE_DIR}/src/tests/samples/*.med
    ${PROJECT_SOURCE_DIR}/src/tests/samples/*.bilan
    ${PROJECT_SOURCE_DIR}/src/tests/samples/*.odt
    ${PROJECT_SOURCE_DIR}/src/tests/samples/*.pdf
    ${PROJECT_SOURCE_DIR}/src/tests/samples/*.png
    ${PROJECT_SOURCE_DIR}/src/tests/samples/*.xao)
  INSTALL(FILES ${sample_files} DESTINATION ${SALOME_HOMARD_INSTALL_SAMPLES})
ENDIF(MED_INT_IS_LONG)
