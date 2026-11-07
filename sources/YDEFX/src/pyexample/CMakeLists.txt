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
ADD_TEST(YdefxPyExampleTest runUnitTest.sh)
SET_TESTS_PROPERTIES(YdefxPyExampleTest PROPERTIES ENVIRONMENT
                    "PYTHONPATH=${CMAKE_SOURCE_DIR}/src:$ENV{PYTHONPATH}")
IF(SALOME_BUILD_TESTS)
  # For salome test
  SET(LOCAL_TEST_DIR ${SALOME_YDEFX_INSTALL_TEST}/pyexample)
  SET(TESTFILES
  test_insitu.py
  test_prescript.py
  test_default.py
  test_ydefx_base.py
  test_mpmcn.py
  )
  INSTALL(FILES ${TESTFILES} DESTINATION ${LOCAL_TEST_DIR})
  INSTALL(PROGRAMS runUnitTest.sh
         DESTINATION ${LOCAL_TEST_DIR})
  SET(INSITU_TESTFILES
  insitu/insituiterator.py
  insitu/insitumanager.py
  )
  INSTALL(FILES ${INSITU_TESTFILES} DESTINATION ${LOCAL_TEST_DIR}/insitu)
  
  INSTALL(FILES CTestTestfileInstall.cmake
          DESTINATION ${LOCAL_TEST_DIR}
          RENAME CTestTestfile.cmake)
ENDIF()
