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

# --- options ---
# additional include directories
INCLUDE_DIRECTORIES(
  ${SALOMEBOOTSTRAP_INCLUDE_DIRS}
  ${KERNEL_INCLUDE_DIRS}
)

# additional preprocessor / compiler flags
ADD_DEFINITIONS(
  ${KERNEL_DEFINITIONS}
)

# libraries to link to
SET(_link_LIBRARIES
  ${SALOMEBOOTSTRAP_SALOMELocalTrace}
  ${KERNEL_SALOMELocalTrace}
)

# --- headers ---

# header files
SET(HOMARDImpl_HEADERS
  HOMARD.hxx
  HOMARD_Cas.hxx
  HOMARD_Boundary.hxx
  HOMARD_Hypothesis.hxx
  HOMARD_Iteration.hxx
  HOMARD_Zone.hxx
  HOMARD_Gen.hxx
  HOMARD_DriverTools.hxx
  HOMARD_YACS.hxx
  HomardDriver.hxx
  YACSDriver.hxx
)

# --- sources ---

# sources / static
SET(HOMARDImpl_SOURCES
  HOMARD_Cas.cxx
  HOMARD_Boundary.cxx
  HOMARD_Hypothesis.cxx
  HOMARD_Iteration.cxx
  HOMARD_Zone.cxx
  HOMARD_Gen.cxx
  HOMARD_DriverTools.cxx
  HOMARD_YACS.cxx
  HomardDriver.cxx
  YACSDriver.cxx
)

# --- rules ---

ADD_LIBRARY(HOMARDImpl ${HOMARDImpl_SOURCES})
TARGET_LINK_LIBRARIES(HOMARDImpl ${_link_LIBRARIES} )
INSTALL(TARGETS HOMARDImpl EXPORT ${PROJECT_NAME}TargetGroup DESTINATION ${SALOME_INSTALL_LIBS})

INSTALL(FILES ${HOMARDImpl_HEADERS} DESTINATION ${SALOME_INSTALL_HEADERS})
