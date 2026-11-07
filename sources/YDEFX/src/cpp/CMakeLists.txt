# Copyright (C) 2019-2026 EDF
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

INCLUDE_DIRECTORIES(
  ${PYTHON_INCLUDE_DIR}
)

ADD_DEFINITIONS(
  ${PYTHON_DEFINITIONS}
)

SET(ydefx_SOURCES
  PyStudyFunction.cxx
  JobParametersProxy.cxx
  Exceptions.cxx
  MonoPyJob.cxx
  PyStudyJob.cxx
)

SET(ydefx_HEADERS
  PyStudyFunction.hxx
  StudyFunction.hxx
  JobParametersProxy.hxx
  Sample.hxx
  SamplePyConversions.hxx
  PyConversions.hxx
  Exceptions.hxx
  MonoPyJob.hxx
  TMonoPyJob.hxx
  Job.hxx
  Launcher.hxx
  PyStudyJob.hxx
  TPyStudyJob.hxx
)

IF(WIN32)
  SET(ydefx_LINK
    ${PY2CPP_ROOT_DIR}/lib/py2cpp.lib
    ${PYTHON_LIBRARIES}
    ${PLATFORM_LIBS}
    )
ELSE(WIN32)
  SET(ydefx_LINK
    py2cpp
    ${PYTHON_LIBRARIES}
  )
ENDIF(WIN32)

ADD_LIBRARY(ydefx ${ydefx_SOURCES})
TARGET_LINK_LIBRARIES(ydefx ${ydefx_LINK})
IF(WIN32)
  TARGET_INCLUDE_DIRECTORIES(ydefx PUBLIC
                             $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src/cpp>
                             $<INSTALL_INTERFACE:${SALOME_INSTALL_HEADERS}>
                             ${PY2CPP_ROOT_DIR}/include)
ELSE(WIN32)
  TARGET_INCLUDE_DIRECTORIES(ydefx PUBLIC
                             $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src/cpp>
                             $<INSTALL_INTERFACE:${SALOME_INSTALL_HEADERS}>)
ENDIF(WIN32)
INSTALL(TARGETS ydefx DESTINATION ${SALOME_INSTALL_LIBS})
INSTALL(TARGETS ydefx EXPORT ydefxCfg_cmake LIBRARY DESTINATION ${SALOME_INSTALL_LIBS})
INSTALL(FILES ${ydefx_HEADERS} DESTINATION ${SALOME_INSTALL_HEADERS}/ydefx)

ADD_SUBDIRECTORY(Test)
