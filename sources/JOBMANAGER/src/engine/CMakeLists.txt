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
  ${OMNIORB_INCLUDE_DIR}
  ${KERNEL_INCLUDE_DIRS}
  ${PROJECT_BINARY_DIR}/idl
  ${PROJECT_SOURCE_DIR}/src/bases
)

# additional preprocessor / compiler flags
ADD_DEFINITIONS(
  ${OMNIORB_DEFINITIONS}
)

# libraries to link to
SET(_link_LIBRARIES
  ${CORBA_LIBS}
  ${KERNEL_SalomeIDLKernel}
  ${KERNEL_SalomeNS}
  ${KERNEL_SalomeLifeCycleCORBA}
  BL_Bases
  JOBMANAGER_IDL
)

# --- sources ---

# sources / static
SET(BL_Engine_SOURCES
  BL_Engine.hxx 
  BL_JobsManager.hxx 
  BL_JobsManager.cxx
  BL_Job.hxx 
  BL_Job.cxx
  BL_SALOMEServices.hxx 
  BL_SALOMEServices.cxx
  BL_Observer.hxx
  BL_NamingService_Wrapper.hxx
  BL_NamingService_Wrapper.cxx
)

# --- rules ---

ADD_LIBRARY(BL_Engine ${BL_Engine_SOURCES})
TARGET_LINK_LIBRARIES(BL_Engine ${_link_LIBRARIES} )
INSTALL(TARGETS BL_Engine EXPORT ${PROJECT_NAME}TargetGroup DESTINATION ${SALOME_INSTALL_LIBS})
