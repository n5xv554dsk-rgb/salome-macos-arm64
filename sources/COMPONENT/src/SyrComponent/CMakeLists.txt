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
  ${PROJECT_SOURCE_DIR}/src/AddComponent
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
  ${KERNEL_SalomeResourcesManager}
  ${SALOMEBOOTSTRAP_SALOMEBasics}
  ${KERNEL_ResourcesManager}
  ${KERNEL_SalomeIDLKERNEL}
  SalomeIDLCOMPONENT
)

# --- headers ---

# header files / no moc processing
SET(SyrComponentEngine_HEADERS
  SyrComponent_Impl.hxx 
)

# --- sources ---

# sources / static
SET(SyrComponentEngine_SOURCES
  SyrComponent_Impl.cxx
)

# bin programs
SET(SyrComponent_CheckOfUndefined_SOURCES
  SyrComponent_CheckOfUndefined.cxx
)

# --- scripts ---

# scripts / static
SET(_bin_SCRIPTS
  COMPONENT_shared_modules.py
)

# --- rules ---

ADD_LIBRARY(SyrComponentEngine ${SyrComponentEngine_SOURCES})
TARGET_LINK_LIBRARIES(SyrComponentEngine ${_link_LIBRARIES} )
INSTALL(TARGETS SyrComponentEngine EXPORT ${PROJECT_NAME}TargetGroup DESTINATION ${SALOME_INSTALL_LIBS})

ADD_EXECUTABLE(SyrComponent_CheckOfUndefined ${SyrComponent_CheckOfUndefined_SOURCES})
TARGET_LINK_LIBRARIES(SyrComponent_CheckOfUndefined ${_link_LIBRARIES})
INSTALL(TARGETS SyrComponent_CheckOfUndefined EXPORT ${PROJECT_NAME}TargetGroup DESTINATION ${SALOME_INSTALL_BINS})

INSTALL(FILES ${SyrComponentEngine_HEADERS} DESTINATION ${SALOME_INSTALL_HEADERS})

SALOME_INSTALL_SCRIPTS("${_bin_SCRIPTS}" ${SALOME_INSTALL_PYTHON_SHARED})
