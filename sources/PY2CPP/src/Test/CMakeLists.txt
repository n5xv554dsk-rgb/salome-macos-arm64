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

# additional include directories
INCLUDE_DIRECTORIES(
  ${CPPUNIT_INCLUDE_DIRS}
  ${CMAKE_CURRENT_SOURCE_DIR}/..
)

# libraries to link to
SET(_link_LIBRARIES
  ${CPPUNIT_LIBRARIES}
  ${PYTHON_LIBRARIES}
  py2cpp
)

SET(Test_SOURCES
  ConversionTest.cxx
)

ADD_EXECUTABLE(py2cppTest ${Test_SOURCES})
TARGET_LINK_LIBRARIES(py2cppTest ${_link_LIBRARIES})
ADD_TEST(Py2cppTest py2cppTest)
SET_TESTS_PROPERTIES(Py2cppTest PROPERTIES ENVIRONMENT
"PYTHONPATH=${CMAKE_CURRENT_SOURCE_DIR}:$ENV{PYTHONPATH}")

INSTALL(TARGETS py2cppTest RUNTIME DESTINATION bin)
