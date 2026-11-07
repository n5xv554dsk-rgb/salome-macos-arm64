# Copyright (C) 2024-2026  CEA, EDF
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

# sources
SET(GeomAnaTool_SOURCES
    GeomAnaTool_ExtractBOPFailure.cxx
    GeomAnaTool_Tools.cxx
)

INCLUDE_DIRECTORIES(
  ${OpenCASCADE_INCLUDE_DIR}
  ${PTHREAD_INCLUDE_DIR}
  ${CMAKE_CURRENT_SOURCE_DIR}
)

# additional preprocessor / compiler flags
ADD_DEFINITIONS(
  -DGEOMANATOOL_EXPORTS
  ${OpenCASCADE_DEFINITIONS}
)

# libraries to link to
SET(_link_LIBRARIES
  ${OpenCASCADE_FoundationClasses_LIBRARIES}
  ${OpenCASCADE_ModelingAlgorithms_LIBRARIES}
)

# headers
SET(GeomAnaTool_HEADERS
    GeomAnaTool.h
    GeomAnaTool_ExtractBOPFailure.hxx
    GeomAnaTool_Tools.hxx
)

# rules
ADD_LIBRARY(GeomAnaTool SHARED ${GeomAnaTool_SOURCES} ${GeomAnaTool_HEADERS})

TARGET_LINK_LIBRARIES(GeomAnaTool ${_link_LIBRARIES} ${PLATFORM_LIBS})

INSTALL(TARGETS GeomAnaTool EXPORT ${PROJECT_NAME}TargetGroup DESTINATION ${CommonGeomLib_INSTALL_LIBS})

INSTALL(FILES ${GeomAnaTool_HEADERS} DESTINATION ${CommonGeomLib_INSTALL_HEADERS})
