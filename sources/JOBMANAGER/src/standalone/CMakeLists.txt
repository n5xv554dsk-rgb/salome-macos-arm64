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
  ${QT_INCLUDES}
  ${SALOMEBOOTSTRAP_INCLUDE_DIRS}
  ${KERNEL_INCLUDE_DIRS}
  ${OMNIORB_INCLUDE_DIR}
  ${PROJECT_BINARY_DIR}/idl
  ${PROJECT_SOURCE_DIR}/src/bases
  ${PROJECT_SOURCE_DIR}/src/engine
  ${PROJECT_SOURCE_DIR}/src/wrappers
  ${PROJECT_SOURCE_DIR}/src/genericgui
)

# additional preprocessor / compiler flags
ADD_DEFINITIONS(
  ${OMNIORB_DEFINITIONS}
)

# libraries to link to
SET(_link_LIBRARIES
  ${CORBA_LIBS}
  ${QT_LIBRARIES}
  ${KERNEL_SalomeLifeCycleCORBA}
  ${KERNEL_SalomeIDLKernel}
  ${KERNEL_SalomeNS}
  ${KERNEL_OpUtil}
  ${SALOMEBOOTSTRAP_SALOMELocalTrace}
  ${SALOMEBOOTSTRAP_SALOMEBasics}
  ${KERNEL_SalomeContainer}
  ${KERNEL_SalomeHDFPersist}
  ${KERNEL_SalomeResourcesManager}
  ${KERNEL_ResourcesManager}
  ${KERNEL_SalomeGenericObj}
  ${KERNEL_SalomeNotification}
  ${KERNEL_Registry}
  BL_GenericGui
  BL_Engine
  BL_Wrappers_Qt
  JOBMANAGER_IDL
)

# --- sources ---

# sources / static
SET(jobmanager_gui_SOURCES
  main.cxx 
)

# --- rules ---

ADD_EXECUTABLE(jobmanager_gui ${jobmanager_gui_SOURCES})
TARGET_LINK_LIBRARIES(jobmanager_gui ${_link_LIBRARIES})
INSTALL(TARGETS jobmanager_gui EXPORT ${PROJECT_NAME}TargetGroup DESTINATION ${SALOME_INSTALL_BINS})

SALOME_CONFIGURE_FILE(${CMAKE_CURRENT_SOURCE_DIR}/start_jobmanager.sh.in ${CMAKE_CURRENT_BINARY_DIR}/start_jobmanager.sh INSTALL ${SALOME_INSTALL_BINS})
