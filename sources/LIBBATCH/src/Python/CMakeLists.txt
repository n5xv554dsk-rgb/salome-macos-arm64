# Copyright (C) 2007-2021  CEA/DEN, EDF R&D, OPEN CASCADE
#
# Copyright (C) 2003-2007  OPEN CASCADE, EADS/CCR, LIP6, CEA/DEN,
# CEDRAT, EDF R&D, LEG, PRINCIPIA R&D, BUREAU VERITAS
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

INCLUDE(UseSWIG)

INCLUDE_DIRECTORIES(${PYTHON_INCLUDE_DIRS})
INCLUDE_DIRECTORIES(${CMAKE_CURRENT_SOURCE_DIR})

SET(SWIG_SRC_FILE libBatch_Swig.i)

SET(SWIG_EXTRA_DEPS
    libBatch_Swig_exception.i
    libBatch_Swig_typemap.i 
    )
SET(SWIG_LB_DPYS
    ../Core/Defines.hxx
    ../Core/Constants.hxx
    ../Core/Job.hxx
    ../Core/JobId.hxx
    ../Core/JobInfo.hxx
    ../Core/CommunicationProtocol.hxx
    ../Core/BatchManager.hxx
    ../Core/BatchManagerCatalog.hxx
    ../Core/FactBatchManager.hxx
    )
SET(CMAKE_SWIG_FLAGS "-py3")
SET_PROPERTY(SOURCE ${SWIG_SRC_FILE} PROPERTY CPLUSPLUS ON)
SET(SWIG_MODULE_libbatch_EXTRA_DEPS ${SWIG_EXTRA_DEPS})
SWIG_ADD_LIBRARY(libbatch LANGUAGE python SOURCES ${SWIG_LB_DPYS} ${SWIG_SRC_FILE})
SWIG_LINK_LIBRARIES(libbatch batch ${PYTHON_LIBRARIES})
INSTALL(TARGETS ${SWIG_MODULE_libbatch_REAL_NAME} DESTINATION ${LIBBATCH_PYTHONPATH})
INSTALL(FILES ${CMAKE_CURRENT_BINARY_DIR}/libbatch.py
        DESTINATION ${LIBBATCH_PYTHONPATH})

IF (LIBBATCH_BUILD_TESTS)
  ADD_SUBDIRECTORY(Test)
ENDIF ()
