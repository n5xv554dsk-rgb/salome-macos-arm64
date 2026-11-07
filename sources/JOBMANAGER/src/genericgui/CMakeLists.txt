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

INCLUDE(UseQtExt)

# --- options ---
# additional include directories
INCLUDE_DIRECTORIES(
  ${QT_INCLUDES}
  ${OMNIORB_INCLUDE_DIR}
  ${KERNEL_INCLUDE_DIRS}
  ${CMAKE_CURRENT_BINARY_DIR}
  ${PROJECT_BINARY_DIR}/idl
  ${PROJECT_SOURCE_DIR}/src/bases
  ${PROJECT_SOURCE_DIR}/src/engine
  ${PROJECT_SOURCE_DIR}/src/wrappers
)

# additional preprocessor / compiler flags
ADD_DEFINITIONS(
  ${QT_DEFINITIONS}
  ${OMNIORB_DEFINITIONS}
)

# libraries to link to
SET(_link_LIBRARIES
  ${QT_LIBRARIES}
  BL_Bases
  BL_Engine
)

# --- headers ---

# header files / to be processed by moc
SET(BL_GenericGui_HEADERS
  BL_GenericGui.hxx
  BL_JobsTable.hxx
  BL_JobTab.hxx
  BL_Buttons.hxx 
  BL_JobsManager_QT.hxx
  BL_QModelManager.hxx 
  BL_CreateJobWizard.hxx
  BL_Summary.hxx 
  JM_ResourceCatalog.hxx
  JM_SalomeResource.hxx 
  JM_EditSalomeResource.hxx
)

# --- sources ---

# sources / moc wrappings
QT_WRAP_MOC(_moc_SOURCES ${BL_GenericGui_HEADERS})

# sources / static
SET(_other_SOURCES 
  BL_GenericGui.cxx 
  BL_JobsTable.cxx 
  BL_JobTab.cxx
  BL_Buttons.cxx
  BL_JobsManager_QT.cxx 
  BL_QModelManager.cxx 
  BL_CreateJobWizard.cxx 
  BL_Summary.cxx 
  JM_ResourceCatalog.cxx 
  JM_SalomeResource.cxx 
  JM_EditSalomeResource.cxx
)

# --- resources ---

# resource files / to be processed by uic
SET(_uic_files
  ResourceRequirementsWizardPage.ui
  FilesWizardPage.ui
  AdvancedParametersWizardPage.ui
)

# header files / uic wrappings
QT_WRAP_UIC(_uic_HEADERS ${_uic_files})

# sources / to compile
SET(BL_GenericGui_SOURCES ${_other_SOURCES} ${_moc_SOURCES} ${_uic_HEADERS})

# --- rules ---

ADD_LIBRARY(BL_GenericGui ${BL_GenericGui_SOURCES})
TARGET_LINK_LIBRARIES(BL_GenericGui ${_link_LIBRARIES} )
INSTALL(TARGETS BL_GenericGui EXPORT ${PROJECT_NAME}TargetGroup DESTINATION ${SALOME_INSTALL_LIBS})
