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
  ${SMESH_INCLUDE_DIRS}
  ${OMNIORB_INCLUDE_DIR}
  ${MEDCOUPLING_INCLUDE_DIRS}
  ${Boost_INCLUDE_DIRS}
  ${OpenCASCADE_INCLUDE_DIR}
  ${MESHGEMS_INCLUDE_DIRS}
  ${SALOMEBOOTSTRAP_INCLUDE_DIRS}
  ${KERNEL_INCLUDE_DIRS}
  ${GUI_INCLUDE_DIRS}
  ${GEOM_INCLUDE_DIRS}
  ${BLSURFPLUGIN_INCLUDE_DIRS}
  ${PROJECT_BINARY_DIR}/idl
)

# additional preprocessor / compiler flags
ADD_DEFINITIONS(
  ${OMNIORB_DEFINITIONS}
  ${OpenCASCADE_DEFINITIONS}
  ${BOOST_DEFINITIONS}
)

# libraries to link to
SET(_link_LIBRARIES
  TKernel
  TKMath
  TKG3d
  TKTopAlgo
  TKBRep
  ${CAS_SALOMELocalTrace}
  ${MESHGEMS_HEXA_LIBRARY}
  ${SMESH_SMESHimpl}
  ${SMESH_SMESHEngine}
  ${SMESH_StdMeshersEngine}
  ${SMESH_MeshDriverGMF}
  ${SMESH_SMDS}
  ${SMESH_SMESHDS}
  ${SMESH_SalomeIDLSMESH}
  ${SMESH_SMESHUtils}
  ${KERNEL_SalomeGenericObj}
  ${SALOMEBOOTSTRAP_SALOMELocalTrace}
  SalomeIDLHexoticPLUGIN
)

# --- headers ---

# header files
SET(HexoticEngine_HEADERS
  HexoticPlugin_Defs.hxx
  HexoticPlugin_Hexotic.hxx
  HexoticPlugin_Hexotic_i.hxx
  HexoticPlugin_Hypothesis.hxx
  HexoticPlugin_Hypothesis_i.hxx
  MG_Hexotic_API.hxx
)

# --- sources ---

# sources / static
SET(HexoticEngine_SOURCES
  HexoticPlugin_Hexotic.hxx
  HexoticPlugin_Hexotic.cxx
  HexoticPlugin_Hexotic_i.hxx
  HexoticPlugin_Hexotic_i.cxx
  HexoticPlugin_Hypothesis.hxx
  HexoticPlugin_Hypothesis.cxx
  HexoticPlugin_Hypothesis_i.hxx
  HexoticPlugin_Hypothesis_i.cxx
  HexoticPlugin_i.cxx
  HexoticPlugin_Defs.hxx
  MG_Hexotic_API.cxx
)

# --- scripts ---

# scripts / static
SET(_python_SCRIPTS
  #__init__.py
  HexoticPLUGINBuilder.py
)

# --- rules ---

ADD_LIBRARY(HexoticEngine ${HexoticEngine_SOURCES})
TARGET_LINK_LIBRARIES(HexoticEngine ${_link_LIBRARIES} )
INSTALL(TARGETS HexoticEngine EXPORT ${PROJECT_NAME}TargetGroup DESTINATION ${SALOME_INSTALL_LIBS})

INSTALL(FILES ${HexoticEngine_HEADERS} DESTINATION ${SALOME_INSTALL_HEADERS})

SALOME_INSTALL_SCRIPTS("${_python_SCRIPTS}" ${SALOME_INSTALL_HEXOPLG_SCRIPT_PYTHON}/salome/kernel/HexoticPLUGIN)
