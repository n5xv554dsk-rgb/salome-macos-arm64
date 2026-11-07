# Copyright (C) 2016-2026  CEA, EDF
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

# For salome test

IF (WIN32)
  #test_5 is currently not passed on Windows -  see issue #32454
  SET(HOMARD_TEST_FILES
  test_1.py
  test_2.py
  test_3.py
  test_4.py
  test_6.py
  tutorial_1.py
  tutorial_2.py
  tutorial_3.py
  tutorial_4.py
  tutorial_5.py
  tutorial_6.py
  test_util.py
  test_2d_1d_mesh.py
)
ELSE()
  SET(HOMARD_TEST_FILES
  test_1.py
  test_2.py
  test_3.py
  test_4.py
  test_5.py
  test_6.py
  tutorial_1.py
  tutorial_2.py
  tutorial_3.py
  tutorial_4.py
  tutorial_5.py
  tutorial_6.py
  test_util.py
  test_2d_1d_mesh.py
)
ENDIF (WIN32)

INSTALL(FILES ${HOMARD_TEST_FILES}
        DESTINATION ${SALOME_HOMARD_INSTALL_TEST})

INSTALL(FILES CTestTestfileInstall.cmake
        DESTINATION ${SALOME_HOMARD_INSTALL_TEST}
        RENAME CTestTestfile.cmake)
