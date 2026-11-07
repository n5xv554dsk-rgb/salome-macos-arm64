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
  ${QWT_INCLUDE_DIR}
  ${PYTHON_INCLUDE_DIRS}
  ${Boost_INCLUDE_DIRS}
  ${SALOMEBOOTSTRAP_INCLUDE_DIRS}
  ${CMAKE_CURRENT_SOURCE_DIR}
  ${PROJECT_SOURCE_DIR}/src/CAM
  ${PROJECT_SOURCE_DIR}/src/Event
  ${PROJECT_SOURCE_DIR}/src/LightApp
  ${PROJECT_SOURCE_DIR}/src/LogWindow
  ${PROJECT_SOURCE_DIR}/src/OBJECT
  ${PROJECT_SOURCE_DIR}/src/ObjBrowser
  ${PROJECT_SOURCE_DIR}/src/Qtx
  ${PROJECT_SOURCE_DIR}/src/SALOME_PYQT/SALOME_PYQT_GUILight
  ${PROJECT_SOURCE_DIR}/src/STD
  ${PROJECT_SOURCE_DIR}/src/SUIT
  ${PROJECT_SOURCE_DIR}/tools/PyInterp/src
  ${PROJECT_SOURCE_DIR}/tools/PyConsole/src
)

if(NOT SALOME_USE_PYSIDE)
  INCLUDE_DIRECTORIES(${SIP_INCLUDE_DIR})
endif(NOT SALOME_USE_PYSIDE)

IF(SALOME_USE_OCCVIEWER)
  INCLUDE_DIRECTORIES(${PROJECT_SOURCE_DIR}/src/OCCViewer)
ENDIF(SALOME_USE_OCCVIEWER)
IF(SALOME_USE_VTKVIEWER)
  INCLUDE_DIRECTORIES(${PROJECT_SOURCE_DIR}/src/VTKViewer)
  INCLUDE_DIRECTORIES(${PROJECT_SOURCE_DIR}/src/SVTK)  
ENDIF()
IF(SALOME_USE_PV3DVIEWER)
  INCLUDE_DIRECTORIES(${PROJECT_SOURCE_DIR}/src/PV3DViewer)
  INCLUDE_DIRECTORIES(${PROJECT_SOURCE_DIR}/src/SPV3D)  
ENDIF()
IF(SALOME_USE_PVVIEWER)
  INCLUDE_DIRECTORIES(${PROJECT_SOURCE_DIR}/src/PVViewer)
ENDIF(SALOME_USE_PVVIEWER)

IF (SALOME_USE_PYSIDE)
  IF(SALOME_USE_PLOT2DVIEWER)
    INCLUDE_DIRECTORIES(${PROJECT_SOURCE_DIR}/src/Plot2d)
  ENDIF(SALOME_USE_PLOT2DVIEWER)
  IF(NOT SALOME_LIGHT_ONLY)
    INCLUDE_DIRECTORIES(
      ${PROJECT_SOURCE_DIR}/src/SalomeApp
    )
  ENDIF(NOT SALOME_LIGHT_ONLY)
ELSE(SALOME_USE_PYSIDE)
  IF(SALOME_USE_PLOT2DVIEWER)
    INCLUDE_DIRECTORIES(${PROJECT_SOURCE_DIR}/src/Plot2d)
  ELSE(SALOME_USE_PLOT2DVIEWER)
    #disable 'ENABLE_PLOT2D' feature
    SET(PYQT_SIPFLAGS ${PYQT_SIPFLAGS} "-xENABLE_PLOT2D;")
  ENDIF(SALOME_USE_PLOT2DVIEWER)
  IF(SALOME_LIGHT_ONLY)
    #disable 'ENABLE_CORBA' feature
    SET(PYQT_SIPFLAGS ${PYQT_SIPFLAGS} "-xENABLE_CORBA;")
  ELSE(SALOME_LIGHT_ONLY)
    INCLUDE_DIRECTORIES(
      ${PROJECT_SOURCE_DIR}/src/SalomeApp
    )
  ENDIF(SALOME_LIGHT_ONLY)
ENDIF(SALOME_USE_PYSIDE)


# additional preprocessor / compiler flags
ADD_DEFINITIONS(
  ${QWT_DEFINITIONS}
  ${QT_DEFINITIONS}
  ${OpenCASCADE_DEFINITIONS}
  ${BOOST_DEFINITIONS}
  ${PYTHON_DEFINITIONS}
  ${OMNIORB_DEFINITIONS}
  ${SALOMEBOOTSTRAP_DEFINITIONS}
)

# libraries to link to
SET(_link_LIBRARIES
  ${PYTHON_LIBRARIES}
  ${OPENGL_LIBRARIES}
  ${QWT_LIBRARY}
  SalomePyQtGUILight
) 

# sources / static
SET(_other_SOURCES SalomePyQt.cxx)

# --- headers ---

# header files / to be processed by moc
SET(_moc_HEADERS SalomePyQt.h)

# --- resources ---

# --- sources ---

# sources / moc wrappings
QT_WRAP_MOC(_moc_SOURCES ${_moc_HEADERS})

IF(NOT SALOME_USE_PYSIDE)
  # sip files / to be processed by sip
  SET(_sip_files SalomePyQt.sip)
  IF(SALOME_USE_PLOT2DVIEWER)
    LIST(APPEND _sip_files SalomePyQt_Plot2d.sip)
  ENDIF(SALOME_USE_PLOT2DVIEWER)
  # sources / sip wrappings
  PYQT_WRAP_SIP(_sip_SOURCES ${_sip_files})

  # sources / to compile
  SET(SalomePyQt_SOURCES ${_other_SOURCES} ${_moc_SOURCES} ${_sip_SOURCES})

  # --- rules ---

  ADD_LIBRARY(SalomePyQt MODULE ${SalomePyQt_SOURCES})
  TARGET_LINK_LIBRARIES(SalomePyQt ${_link_LIBRARIES})
  INSTALL(TARGETS SalomePyQt DESTINATION ${SALOME_INSTALL_LIBS})

  IF(WIN32)
    SET_TARGET_PROPERTIES(SalomePyQt PROPERTIES SUFFIX ".pyd" DEBUG_OUTPUT_NAME SalomePyQt_d RELEASE_OUTPUT_NAME SalomePyQt)
  ELSE()
    SET_TARGET_PROPERTIES(SalomePyQt PROPERTIES PREFIX "")
  ENDIF()

  FILE(GLOB make_clean_files ${CMAKE_CURRENT_BINARY_DIR}/sip*)
  SET_DIRECTORY_PROPERTIES(PROPERTIES ADDITIONAL_MAKE_CLEAN_FILES "${make_clean_files}")
ELSE(NOT SALOME_USE_PYSIDE)
  SET(SalomePyQt_generated_sources
    ${CMAKE_CURRENT_BINARY_DIR}/SalomePyQt/salomepyqt_module_wrapper.cpp
    ${CMAKE_CURRENT_BINARY_DIR}/SalomePyQt/salomepyqt_wrapper.cpp
    ${CMAKE_CURRENT_BINARY_DIR}/SalomePyQt/salome_selection_wrapper.cpp
    ${CMAKE_CURRENT_BINARY_DIR}/SalomePyQt/plot2d_curve_wrapper.cpp
  )
  SET(CMAKE_SKIP_BUILD_RPATH FALSE)
  SET(CMAKE_BUILD_WITH_INSTALL_RPATH TRUE)
  SET(CMAKE_INSTALL_RPATH ${SHIBOKEN2_MODULE_PATH} ${CMAKE_CURRENT_BINARY_DIR})
  SET(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)
  SET(SalomePyQt_SOURCES ${_other_SOURCES} ${_moc_SOURCES})
  ADD_LIBRARY(libSalomePyQt SHARED ${SalomePyQt_SOURCES})
  TARGET_COMPILE_DEFINITIONS(libSalomePyQt PRIVATE  SalomePyQt_EXPORTS __SALOME_USE_PYSIDE__)
  TARGET_LINK_LIBRARIES(libSalomePyQt ${_link_LIBRARIES})
  SET_PROPERTY(TARGET libSalomePyQt PROPERTY PREFIX "")

  # Needed mostly on Windows to export symbols, and create a .lib file, otherwise the binding
  # library can't link to the sample library.
  TARGET_COMPILE_DEFINITIONS(libSalomePyQt PRIVATE BINDINGS_BUILD)

  # ========================== Shiboken Target for generating binding C++ files =================
  get_directory_property(include_directories_list INCLUDE_DIRECTORIES)
  list(APPEND include_directories_list ${PYSIDE2_INCLUDE_DIRS} ${SHIBOKEN2_INCLUDE_DIR})

  salome_generate_pyside_bindings(
    PYSIDE2_BINDING_GENERATED_SOURCES ${SalomePyQt_generated_sources}
    PYSIDE2_BINDING_WRAPPED_HEADER ${CMAKE_CURRENT_SOURCE_DIR}/SalomePyQt_bindings.h
    PYSIDE2_BINDING_TYPESYSTEM_FILE ${CMAKE_CURRENT_SOURCE_DIR}/SalomePyQt_bindings.xml
    PYSIDE2_BINDING_BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}
    PYSIDE2_BINDING_INCLUDE_DIRECTORIES ${include_directories_list}
  )

  # =============================== CMake target - bindings_library =============================
  # Define and build the bindings library.
  SET(SalomePyQt_sources ${SalomePyQt_generated_sources} ${_moc_SOURCES})
  ADD_LIBRARY(SalomePyQt MODULE ${SalomePyQt_sources})
  TARGET_COMPILE_DEFINITIONS(SalomePyQt PRIVATE  SalomePyQt_EXPORTS __SALOME_USE_PYSIDE__)

  # Apply relevant include and link flags.
  TARGET_INCLUDE_DIRECTORIES(SalomePyQt PRIVATE
    ${include_directories_list}
    ${PYSIDE2_PYTHON_INCLUDE_DIR}
    ${SHIBOKEN2_INCLUDE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${PYSIDE2_INCLUDE_DIRS}
  )
  TARGET_LINK_LIBRARIES(SalomePyQt PRIVATE
    ${SHIBOKEN2_SHARED_LIBRARIES}
    ${PYSIDE2_SHARED_LIBRARIES}
    libSalomePyQt
    ${_link_LIBRARIES}
  )

  # Adjust the name of generated module.
  SET_PROPERTY(TARGET SalomePyQt PROPERTY PREFIX "")
  SET_PROPERTY(TARGET SalomePyQt PROPERTY OUTPUT_NAME "SalomePyQt${PYTHON_EXTENSION_SUFFIX}")
  IF(WIN32)
    SET_TARGET_PROPERTIES(SalomePyQt PROPERTIES SUFFIX ".pyd" DEBUG_OUTPUT_NAME SalomePyQt_d RELEASE_OUTPUT_NAME SalomePyQt)
  ELSE(WIN32)
    SET_TARGET_PROPERTIES(SalomePyQt PROPERTIES PREFIX "")
  ENDIF(WIN32)
  # Install the library and the bindings module into the source folder near the main.py file, so
  # that the Python interpeter successfully imports the used module.
  INSTALL(TARGETS SalomePyQt libSalomePyQt
    LIBRARY DESTINATION ${SALOME_INSTALL_LIBS}
    RUNTIME DESTINATION ${SALOME_INSTALL_LIBS}
  )
ENDIF(NOT SALOME_USE_PYSIDE)

