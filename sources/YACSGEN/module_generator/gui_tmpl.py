# Copyright (C) 2009-2026  EDF
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

try:
  from string import Template
except:
  from module_generator.compat import Template,set

# SalomeApp.xml file for a python gui.
# template parameters:
#   module : module name
#   lmodule : module name in lower case
#   version : version number of the module
pysalomeapp="""
<document>
  <section name="${module}">
    <parameter name="name" value="${module}"/>
    <parameter name="icon" value="${module}.png"/>
    <parameter name="library" value="SalomePyQtGUI"/>
    <parameter name="documentation" value="${lmodule}_help"/>
    <parameter name="version" value="${version}"/>
  </section>
  <section name="resources">
    <parameter name="${module}" value="$${${module}_ROOT_DIR}/share/salome/resources/${lmodule}"/>
  </section>
  <section name="${lmodule}_help" >
    <parameter name="sub_menu"          value="%1 module"/>
    <parameter name="User's Guide"      value="%${module}_ROOT_DIR%/share/doc/salome/gui/${lmodule}/index.html"/>
  </section>
</document>
"""
pysalomeapp=Template(pysalomeapp)

# SalomeApp.xml file for a cpp gui.
# template parameters:
#   module : module name
#   lmodule : module name in lower case
#   version : version number of the module
cppsalomeapp="""
<document>
  <section name="${module}">
    <parameter name="name" value="${module}"/>
    <parameter name="icon" value="${module}.png"/>
    <parameter name="documentation" value="${lmodule}_help"/>
    <parameter name="version" value="${version}"/>
  </section>
  <section name="resources">
    <parameter name="${module}" value="$${${module}_ROOT_DIR}/share/salome/resources/${lmodule}"/>
  </section>
  <section name="${lmodule}_help" >
    <parameter name="sub_menu"          value="%1 module"/>
    <parameter name="User's Guide"      value="%${module}_ROOT_DIR%/share/doc/salome/gui/${lmodule}/index.html"/>
  </section>
</document>
"""
cppsalomeapp=Template(cppsalomeapp)

# CMakeLists.txt for a c++ GUI of the module (src/{module}GUI/CMakeLists.txt)
# template parameters:
#   module : module name
#   include_dirs : additional include directories
#   libs : libraries to link to
#   uic_files : .ui files
#   moc_headers : header files - to be processed by moc
#   sources : .cxx
#   resources : resource files
#   ts_resources : .ts files - to be processed by lrelease
cmake_cpp_gui = """
INCLUDE(UseQtExt)

# --- options ---
# additional include directories
INCLUDE_DIRECTORIES(
  $${QT_INCLUDES}
  $${OMNIORB_INCLUDE_DIR}
  $${KERNEL_INCLUDE_DIRS}
  $${GUI_INCLUDE_DIRS}
  $${PROJECT_BINARY_DIR}/idl
  ${include_dirs}
)

# additional preprocessor / compiler flags
ADD_DEFINITIONS(
  $${QT_DEFINITIONS}
  $${OMNIORB_DEFINITIONS}
  $${KERNEL_DEFINITIONS}
  $${GUI_DEFINITIONS}
)

# libraries to link to
SET(_link_LIBRARIES
  $${QT_LIBRARIES}
  SalomeIDL${module}
  ${libs}
)

# --- resources ---

# resource files / to be processed by uic
SET(_uic_files
  ${uic_files}
)

# --- headers ---

# header files / to be processed by moc
SET(_moc_HEADERS
  ${moc_headers}
)

# header files / uic wrappings
QT_WRAP_UIC(_uic_HEADERS $${_uic_files})

# --- sources ---

# sources / moc wrappings
QT_WRAP_MOC(_moc_SOURCES $${_moc_HEADERS})  

# sources / static
SET(_other_SOURCES
  ${sources}
)

# sources / to compile
SET(${module}GUI_SOURCES 
  $${_other_SOURCES}
  $${_moc_SOURCES}
  $${_uic_files}
)

# --- resources ---

# resource files / to be processed by lrelease
SET(_ts_files
  ${ts_resources}
) 

SET(_res_files
  SalomeApp.xml
  ${resources}
) 

# --- rules ---

ADD_LIBRARY(${module} $${${module}GUI_SOURCES})
TARGET_LINK_LIBRARIES(${module} $${_link_LIBRARIES} )
INSTALL(TARGETS ${module} EXPORT $${PROJECT_NAME}TargetGroup DESTINATION $${SALOME_INSTALL_LIBS})

INSTALL(FILES $${_moc_HEADERS} DESTINATION $${SALOME_INSTALL_HEADERS})
INSTALL(FILES $${_res_files} DESTINATION "$${SALOME_${module}_INSTALL_RES_DATA}")
QT_INSTALL_TS_RESOURCES("$${_ts_files}" "$${SALOME_${module}_INSTALL_RES_DATA}")
"""
cmake_cpp_gui = Template(cmake_cpp_gui)

# CMakeLists.txt for a python GUI (src/{module}GUI/CMakeLists.txt)
# template parameters:
#   module : module name
#   scripts : .py files
#   ts_resources : .ts files - to be processed by lrelease
#   resources : other resource files
cmake_py_gui = """
INCLUDE(UseQtExt)

# additional include directories
INCLUDE_DIRECTORIES(
  $${QT_INCLUDES}
)

# --- scripts ---

# scripts / static
SET(_bin_SCRIPTS
  ${scripts}
)

# --- resources ---

# resource files / to be processed by lrelease
SET(_ts_RESOURCES
  ${ts_resources}
)

SET(_res_files
  SalomeApp.xml
  ${resources}
)

# --- rules ---

SALOME_INSTALL_SCRIPTS("$${_bin_SCRIPTS}" $${SALOME_INSTALL_SCRIPT_PYTHON})
INSTALL(FILES $${_res_files} DESTINATION "$${SALOME_${module}_INSTALL_RES_DATA}")
QT_INSTALL_TS_RESOURCES("$${_ts_RESOURCES}" "$${SALOME_${module}_INSTALL_RES_DATA}")
"""
cmake_py_gui = Template(cmake_py_gui)
