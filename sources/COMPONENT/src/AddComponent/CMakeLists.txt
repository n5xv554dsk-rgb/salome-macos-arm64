# Copyright (C) 2013-2026  CEA, EDF, OPEN CASCADE
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
  ${PYTHON_INCLUDE_DIRS}
  ${OMNIORB_INCLUDE_DIR}
  ${SALOMEBOOTSTRAP_INCLUDE_DIRS}
  ${KERNEL_INCLUDE_DIRS}
  ${PROJECT_BINARY_DIR}
  ${PROJECT_BINARY_DIR}/idl
)

# additional preprocessor / compiler flags
ADD_DEFINITIONS(
  ${OMNIORB_DEFINITIONS}
  ${PYTHON_DEFINITIONS}
)

# libraries to link to
SET(_link_LIBRARIES
  ${KERNEL_SalomeGenericObj}
  ${KERNEL_SalomeContainer}
  ${KERNEL_SalomeHDFPersist}
  ${KERNEL_SalomeNS}
  ${KERNEL_OpUtil}
  ${KERNEL_Registry}
  ${KERNEL_SalomeNotification}
  ${SALOMEBOOTSTRAP_SALOMELocalTrace}
  ${KERNEL_SalomeLifeCycleCORBA}
  ${KERNEL_SalomeResourcesManager}
  ${SALOMEBOOTSTRAP_SALOMEBasics}
  ${KERNEL_ResourcesManager}
  ${KERNEL_SalomeIDLKERNEL}
  SalomeIDLCOMPONENT
)

# --- headers ---

# header files / no moc processing
SET(AddComponentEngine_HEADERS
  AddComponent_Impl.hxx
  Adder_Impl.hxx
  AddComponent.hxx 
)

# --- sources ---

# sources / static
SET(AddComponentEngine_SOURCES
  AddComponent_Impl.cxx
  Adder_Impl.cxx 
)

# bin programs
SET(AddComponent_CheckOfUndefined_SOURCES
  AddComponent_CheckOfUndefined.cxx
  HandleServerSideSignals.cxx
)

# --- rules ---

ADD_LIBRARY(AddComponentEngine ${AddComponentEngine_SOURCES})
TARGET_LINK_LIBRARIES(AddComponentEngine ${_link_LIBRARIES} )
INSTALL(TARGETS AddComponentEngine EXPORT ${PROJECT_NAME}TargetGroup DESTINATION ${SALOME_INSTALL_LIBS})

ADD_EXECUTABLE(AddComponent_CheckOfUndefined ${AddComponent_CheckOfUndefined_SOURCES})
TARGET_LINK_LIBRARIES(AddComponent_CheckOfUndefined ${_link_LIBRARIES})
INSTALL(TARGETS AddComponent_CheckOfUndefined EXPORT ${PROJECT_NAME}TargetGroup DESTINATION ${SALOME_INSTALL_BINS})

INSTALL(FILES ${AddComponentEngine_HEADERS} DESTINATION ${SALOME_INSTALL_HEADERS})
