# Copyright (C) 2015-2026  CEA, EDF, OPEN CASCADE
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
# Author : Vadim SANDLER, Open CASCADE S.A.S. (vadim.sandler@opencascade.com)
#

INCLUDE(UseQtExt)

INCLUDE(SalomeQtPythonBindings)
SALOME_SETUP_QT_PYTHON_BINDINGS()
IF(SALOME_USE_PYSIDE)
  ADD_DEFINITIONS(-D__SALOME_USE_PYSIDE__)
  SALOME_SETUP_PYSIDE_SHIBOKEN()
ENDIF()

# --- options ---

# additional include directories
INCLUDE_DIRECTORIES(
  ${QT_INCLUDES}
  ${PYTHON_INCLUDE_DIRS}
  ${SIP_INCLUDE_DIR}
  ${PROJECT_BINARY_DIR}
  ${CMAKE_CURRENT_SOURCE_DIR}/..
)

if (SALOME_USE_PYSIDE)
  INCLUDE_DIRECTORIES(
    ${CMAKE_CURRENT_SOURCE_DIR}/../PyInterp
    ${CMAKE_CURRENT_SOURCE_DIR}/../PyEditor
    ${PYSIDE2_INCLUDE_DIRS}
    ${SHIBOKEN2_INCLUDE_DIR}
  )
else(SALOME_USE_PYSIDE)
  INCLUDE_DIRECTORIES(${SIP_INCLUDE_DIR})
endif(SALOME_USE_PYSIDE)

# additional preprocessor / compiler flags
ADD_DEFINITIONS(${QT_DEFINITIONS})

# libraries to link to
SET(_link_LIBRARIES ${QT_LIBRARIES} ${PYTHON_LIBRARIES} PyConsole)

# --- sources ---
if (SALOME_USE_PYSIDE)
  SET(CMAKE_SKIP_BUILD_RPATH FALSE)
  SET(CMAKE_BUILD_WITH_INSTALL_RPATH TRUE)
  SET(CMAKE_INSTALL_RPATH ${SHIBOKEN2_MODULE_PATH} ${CMAKE_CURRENT_BINARY_DIR})
  SET(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)
  SET(PyConsolePy_wrapped_header  ${CMAKE_CURRENT_SOURCE_DIR}/PyConsolePy_bindings.h)
  SET(PyConsolePy_typesystem_file ${CMAKE_CURRENT_SOURCE_DIR}/PyConsolePy_bindings.xml)
  SET(PyConsolePy_generated_sources ${CMAKE_CURRENT_BINARY_DIR}/PyConsolePy/pyconsolepy_module_wrapper.cpp
    ${CMAKE_CURRENT_BINARY_DIR}/PyConsolePy/pyconsole_editor_wrapper.cpp
    ${CMAKE_CURRENT_BINARY_DIR}/PyConsolePy/pyconsole_console_wrapper.cpp
    #{CMAKE_CURRENT_BINARY_DIR}/PyConsolePy/pyconsole_interp_wrapper.cpp
  )
  get_directory_property(include_directories_list INCLUDE_DIRECTORIES)

  salome_generate_pyside_bindings(
    PYSIDE2_BINDING_GENERATED_SOURCES ${PyConsolePy_generated_sources}
    PYSIDE2_BINDING_WRAPPED_HEADER ${CMAKE_CURRENT_SOURCE_DIR}/PyConsolePy_bindings.h
    PYSIDE2_BINDING_TYPESYSTEM_FILE ${CMAKE_CURRENT_SOURCE_DIR}/PyConsolePy_bindings.xml
    PYSIDE2_BINDING_BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}
    PYSIDE2_BINDING_INCLUDE_DIRECTORIES ${include_directories_list}
  )
  SET(PyConsolePy_sources ${PyConsolePy_generated_sources})
  ADD_LIBRARY(PyConsolePy MODULE ${PyConsolePy_sources})


  # Apply relevant include and link flags.
  TARGET_INCLUDE_DIRECTORIES(PyConsolePy PRIVATE
    ${include_directories_list}
    ${PYSIDE2_PYTHON_INCLUDE_DIR}
    ${SHIBOKEN2_INCLUDE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${PYSIDE2_INCLUDE_DIRS}
  )
  TARGET_LINK_LIBRARIES(PyConsolePy PRIVATE
    ${SHIBOKEN2_SHARED_LIBRARIES}
    ${PYSIDE2_SHARED_LIBRARIES}
    ${_link_LIBRARIES}
  )
  # Adjust the name of generated module.
  SET_PROPERTY(TARGET PyConsolePy PROPERTY PREFIX "")
  SET_PROPERTY(TARGET PyConsolePy PROPERTY OUTPUT_NAME "PyConsolePy${PYTHON_EXTENSION_SUFFIX}")
  IF(WIN32)
    set_property(TARGET PyConsolePy PROPERTY SUFFIX ".pyd" DEBUG_OUTPUT_NAME PyConsolePy_d RELEASE_OUTPUT_NAME PyConsolePy)
  ELSE(WIN32)
    SET_TARGET_PROPERTIES(PyConsolePy PROPERTIES PREFIX "")
  ENDIF(WIN32)
  # Install the library and the bindings module into the source folder near the main.py file, so
  # that the Python interpeter successfully imports the used module.
  INSTALL(TARGETS PyConsolePy
    LIBRARY DESTINATION ${SALOME_INSTALL_LIBS}
    RUNTIME DESTINATION ${SALOME_INSTALL_LIBS}
  )
else(SALOME_USE_PYSIDE)
  # sip files / to be processed by sip
  SET(_sip_files PyConsolePy.sip)

  # sources / sip wrappings
  PYQT_WRAP_SIP(_sip_SOURCES ${_sip_files})

  # sources / to compile
  SET(PyConsolePy_SOURCES ${_sip_SOURCES})
  # --- rules ---
  ADD_LIBRARY(PyConsolePy ${PyConsolePy_SOURCES})
  IF(WIN32)
    SET_TARGET_PROPERTIES(PyConsolePy PROPERTIES SUFFIX ".pyd" DEBUG_OUTPUT_NAME PyConsolePy_d RELEASE_OUTPUT_NAME PyConsolePy)
  ELSE(WIN32)
    SET_TARGET_PROPERTIES(PyConsolePy PROPERTIES PREFIX "")
  ENDIF(WIN32)
  TARGET_LINK_LIBRARIES(PyConsolePy ${_link_LIBRARIES})
  INSTALL(TARGETS PyConsolePy EXPORT ${PYCONSOLE_EXPORT_NAME}TargetGroup DESTINATION ${PYCONSOLE_INSTALL_PYTHON})
endif(SALOME_USE_PYSIDE)

