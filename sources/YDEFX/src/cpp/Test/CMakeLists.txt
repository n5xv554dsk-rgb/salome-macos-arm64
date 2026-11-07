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
FIND_PACKAGE(SalomeCppUnit REQUIRED)

# additional include directories
SET(_include_DIRECTORIES
    ${CPPUNIT_INCLUDE_DIRS}
    ${CMAKE_CURRENT_SOURCE_DIR}/..
  )
IF(WIN32)
  LIST(APPEND _include_DIRECTORIES ${PY2CPP_ROOT_DIR}/include)
ENDIF(WIN32)

INCLUDE_DIRECTORIES(${_include_DIRECTORIES})

IF(WIN32)
 SET(py2cpp_lib ${PY2CPP_ROOT_DIR}/lib/py2cpp.lib)
ELSE(WIN32)
 SET(py2cpp_lib py2cpp)
ENDIF(WIN32)
# libraries to link to
SET(_link_LIBRARIES
  ${CPPUNIT_LIBRARIES}
  ${py2cpp_lib}
  ydefx
)

SET(Test_SOURCES
    SampleTest.cxx
)

ADD_EXECUTABLE(SampleTest ${Test_SOURCES})
TARGET_LINK_LIBRARIES(SampleTest ${_link_LIBRARIES})
ADD_TEST(YdefxSampleTest SampleTest)
SET_TESTS_PROPERTIES(YdefxSampleTest PROPERTIES ENVIRONMENT
                    "PYTHONPATH=${CMAKE_SOURCE_DIR}/src:$ENV{PYTHONPATH}")

ADD_EXECUTABLE(StudyGeneralTest StudyGeneralTest.cxx)
TARGET_LINK_LIBRARIES(StudyGeneralTest ${_link_LIBRARIES})
ADD_TEST(YdefxStudyGeneralTest StudyGeneralTest)
SET_TESTS_PROPERTIES(YdefxStudyGeneralTest PROPERTIES ENVIRONMENT
                    "PYTHONPATH=${CMAKE_SOURCE_DIR}/src:$ENV{PYTHONPATH}")

ADD_EXECUTABLE(StudyRestartTest StudyRestartTest.cxx)
TARGET_LINK_LIBRARIES(StudyRestartTest ${_link_LIBRARIES})
ADD_TEST(YdefxStudyRestartTest StudyRestartTest)
SET_TESTS_PROPERTIES(YdefxStudyRestartTest PROPERTIES ENVIRONMENT
                    "PYTHONPATH=${CMAKE_SOURCE_DIR}/src:$ENV{PYTHONPATH}")
IF(SALOME_BUILD_TESTS)
  # For salome test
  SET(LOCAL_TEST_DIR ${SALOME_YDEFX_INSTALL_TEST}/cpp)
  INSTALL(TARGETS SampleTest DESTINATION ${LOCAL_TEST_DIR})
  INSTALL(TARGETS StudyGeneralTest DESTINATION ${LOCAL_TEST_DIR})
  INSTALL(TARGETS StudyRestartTest DESTINATION ${LOCAL_TEST_DIR})
  INSTALL(FILES CTestTestfileInstall.cmake
          DESTINATION ${LOCAL_TEST_DIR}
          RENAME CTestTestfile.cmake)
ENDIF()
