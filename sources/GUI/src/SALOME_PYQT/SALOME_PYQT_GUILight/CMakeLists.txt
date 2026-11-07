# Copyright (C) 2012-2026  CEA, EDF, OPEN CASCADE
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

INCLUDE(SalomeQtPythonBindings)
SALOME_SETUP_QT_PYTHON_BINDINGS()
IF(SALOME_USE_PYSIDE)
  SALOME_SETUP_PYSIDE_SHIBOKEN()
  ADD_DEFINITIONS(-D__SALOME_USE_PYSIDE__)
ENDIF()


# --- options ---

# additional include directories
INCLUDE_DIRECTORIES(
  ${OpenCASCADE_INCLUDE_DIR}
  ${QT_INCLUDES}
  ${PYTHON_INCLUDE_DIRS}
  ${PTHREAD_INCLUDE_DIR}
  ${CMAKE_CURRENT_BINARY_DIR}
  ${PROJECT_SOURCE_DIR}/src/CAM
  ${PROJECT_SOURCE_DIR}/src/Event
  ${PROJECT_SOURCE_DIR}/src/LightApp
  ${PROJECT_SOURCE_DIR}/src/OCCViewer
  ${PROJECT_SOURCE_DIR}/src/Plot2d
  ${PROJECT_SOURCE_DIR}/src/Qtx
  ${PROJECT_SOURCE_DIR}/src/STD
  ${PROJECT_SOURCE_DIR}/src/SUIT
  ${PROJECT_SOURCE_DIR}/src/SUITApp
  ${PROJECT_SOURCE_DIR}/src/ObjBrowser
  ${PROJECT_SOURCE_DIR}/tools/PyConsole/src
  ${PROJECT_SOURCE_DIR}/tools/PyInterp/src
)
if (SALOME_USE_PYSIDE)
  INCLUDE_DIRECTORIES(
    ${PYSIDE2_INCLUDE_DIRS}
    ${SHIBOKEN2_INCLUDE_DIR}
    ${PROJECT_SOURCE_DIR}/src/SalomeApp
    ${PROJECT_SOURCE_DIR}/tools/PyEditor/src
  )
else (SALOME_USE_PYSIDE)
  INCLUDE_DIRECTORIES(
    ${SIP_INCLUDE_DIR}
  )
endif(SALOME_USE_PYSIDE)
IF(SALOME_USE_SALOMEOBJECT)
  INCLUDE_DIRECTORIES(${PROJECT_SOURCE_DIR}/src/OBJECT)
ENDIF()

# additional preprocessor / compiler flags
ADD_DEFINITIONS(
  ${QT_DEFINITIONS}
  ${OpenCASCADE_DEFINITIONS}
  ${PYTHON_DEFINITIONS}
)

# libraries to link to
SET(_link_LIBRARIES
  ${PYTHON_LIBRARIES}
  ${OPENGL_LIBRARIES}
  LightApp
)
IF(NOT SALOME_LIGHT_ONLY)
  LIST(APPEND _link_LIBRARIES ${KERNEL_SalomeContainer})
ENDIF()

# --- headers ---

# header files / to be processed by moc
SET(_moc_HEADERS   
  SALOME_PYQT_DataModelLight.h
  SALOME_PYQT_ModuleLight.h
  SALOME_PYQT_PyModule.h
  SALOME_PYQT_Selector.h
)

# header files / no moc processing
SET(_other_HEADERS
  SALOME_PYQT_DataObjectLight.h
  SALOME_PYQT_BorrowedDataObjectLight.h
  SALOME_PYQT_GUILight.h
  SALOME_PYQT_PyInterp.h
)

# header files / to install
SET(SalomePyQtGUILight_HEADERS ${_moc_HEADERS} ${_other_HEADERS})

# --- resources ---

# --- sources ---

# sources / moc wrappings
QT_WRAP_MOC(_moc_SOURCES ${_moc_HEADERS})

# sources / sip wrappings
if (NOT SALOME_USE_PYSIDE)
  # sip files / to be processed by sip
  SET(_sip_files SALOME_PYQT_GUILight.sip)
  PYQT_WRAP_SIP(_sip_SOURCES ${_sip_files})
endif(NOT SALOME_USE_PYSIDE)

# sources / static
SET(_other_SOURCES
  SALOME_PYQT_DataModelLight.cxx
  SALOME_PYQT_DataObjectLight.cxx
  SALOME_PYQT_BorrowedDataObjectLight.cxx
  SALOME_PYQT_ModuleLight.cxx
  SALOME_PYQT_PyInterp.cxx
  SALOME_PYQT_PyModule.cxx
  SALOME_PYQT_Selector.cxx
)

if (SALOME_USE_PYSIDE)
  set(SalomePyQtGUILight_generated_sources
    ${CMAKE_CURRENT_BINARY_DIR}/SalomePyQtGUILight/salomepyqtguilight_module_wrapper.cpp
    ${CMAKE_CURRENT_BINARY_DIR}/SalomePyQtGUILight/salome_pyqt_modulelight_wrapper.cpp
  )

  set(CMAKE_SKIP_BUILD_RPATH FALSE)
  set(CMAKE_BUILD_WITH_INSTALL_RPATH TRUE)
  set(CMAKE_INSTALL_RPATH ${SHIBOKEN2_MODULE_PATH} ${CMAKE_CURRENT_BINARY_DIR})
  set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)

  get_directory_property(include_directories_list INCLUDE_DIRECTORIES)

  salome_generate_pyside_bindings(
    PYSIDE2_BINDING_GENERATED_SOURCES ${SalomePyQtGUILight_generated_sources}
    PYSIDE2_BINDING_WRAPPED_HEADER ${CMAKE_CURRENT_SOURCE_DIR}/SalomePyQtGUILight_bindings.h
    PYSIDE2_BINDING_TYPESYSTEM_FILE ${CMAKE_CURRENT_SOURCE_DIR}/SalomePyQtGUILight_bindings.xml
    PYSIDE2_BINDING_BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}
    PYSIDE2_BINDING_INCLUDE_DIRECTORIES ${include_directories_list}
  )

  set(SalomePyQtGUILight_SOURCES ${_other_SOURCES} ${_moc_SOURCES} ${SalomePyQtGUILight_generated_sources})

else(SALOME_USE_PYSIDE)
  # sources / to compile
  SET(SalomePyQtGUILight_SOURCES ${_other_SOURCES} ${_moc_SOURCES} ${_sip_SOURCES})
endif(SALOME_USE_PYSIDE)

# --- rules ---

if (SALOME_USE_PYSIDE)
  ADD_LIBRARY(SalomePyQtGUILight ${SalomePyQtGUILight_SOURCES})
  target_compile_definitions(SalomePyQtGUILight PRIVATE BINDINGS_BUILD)
  target_include_directories(SalomePyQtGUILight PRIVATE
    ${include_directories_list}
    ${PYSIDE2_PYTHON_INCLUDE_DIR}
    ${SHIBOKEN2_INCLUDE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${PYSIDE2_INCLUDE_DIRS}
  )
  target_link_libraries(SalomePyQtGUILight
    ${SHIBOKEN2_SHARED_LIBRARIES}
    ${PYSIDE2_SHARED_LIBRARIES}
    ${_link_LIBRARIES}
  )
  INSTALL(TARGETS SalomePyQtGUILight DESTINATION ${SALOME_INSTALL_LIBS})
  INSTALL(FILES ${SalomePyQtGUILight_HEADERS} DESTINATION ${SALOME_INSTALL_HEADERS})
else(SALOME_USE_PYSIDE)
  ADD_LIBRARY(SalomePyQtGUILight ${SalomePyQtGUILight_SOURCES})
  TARGET_LINK_LIBRARIES(SalomePyQtGUILight ${_link_LIBRARIES})
  INSTALL(TARGETS SalomePyQtGUILight DESTINATION ${SALOME_INSTALL_LIBS})

  INSTALL(FILES ${SalomePyQtGUILight_HEADERS} DESTINATION ${SALOME_INSTALL_HEADERS})

  FILE(GLOB make_clean_files ${CMAKE_CURRENT_BINARY_DIR}/sip*)
  SET_DIRECTORY_PROPERTIES(PROPERTIES ADDITIONAL_MAKE_CLEAN_FILES "${make_clean_files}")
endif(SALOME_USE_PYSIDE)

