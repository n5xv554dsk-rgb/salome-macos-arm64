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
  ${CMAKE_CURRENT_SOURCE_DIR}/../src
  ${PYTHON_INCLUDE_DIR}
)

ADD_DEFINITIONS(
  ${PYTHON_DEFINITIONS}
)

# libraries to link to
SET(_link_LIBRARIES
  ${PYTHON_LIBRARIES}
  py2cpp
)

SET(Main_SOURCES
  main.cxx
)

ADD_EXECUTABLE(main ${Main_SOURCES})
TARGET_LINK_LIBRARIES(main ${_link_LIBRARIES})
INSTALL(TARGETS main RUNTIME DESTINATION example)
INSTALL(FILES mymodule.py DESTINATION example)
