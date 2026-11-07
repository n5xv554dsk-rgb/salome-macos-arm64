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
#

INCLUDE_DIRECTORIES(
   ${CPPUNIT_INCLUDE_DIRS}
   ${CMAKE_CURRENT_SOURCE_DIR}/
   ${CMAKE_CURRENT_SOURCE_DIR}/..
)

ADD_DEFINITIONS(${CPPUNIT_DEFINITIONS})

SET(TestPMML_SOURCES
  TestPMML.cxx
  PMMLBasicsTest1.cxx
  tools.cxx
)

ADD_EXECUTABLE(TestPMML ${TestPMML_SOURCES})

TARGET_LINK_LIBRARIES(TestPMML pmmlLib ${CPPUNIT_LIBRARIES} ${PLATFORM_LIBS})

ADD_TEST(TestPMML TestPMML)

FILE(COPY ${PROJECT_SOURCE_DIR}/Test/samples  DESTINATION .)
INSTALL(TARGETS TestPMML DESTINATION ${PMML_INSTALL_BINS})

SET(LOCAL_TEST_DIR ${PMML_INSTALL_TESTS}/Test)
INSTALL(TARGETS TestPMML DESTINATION ${LOCAL_TEST_DIR})
INSTALL(FILES CTestTestfileInstall.cmake DESTINATION ${LOCAL_TEST_DIR} RENAME CTestTestfile.cmake)
FILE(GLOB sample_files  ${PROJECT_SOURCE_DIR}/Test/samples/*)
INSTALL(FILES ${sample_files} DESTINATION ${LOCAL_TEST_DIR}/samples)
