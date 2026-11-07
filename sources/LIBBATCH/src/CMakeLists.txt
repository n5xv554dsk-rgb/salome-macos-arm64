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

MACRO(APPEND_CLASSES_TO_SRC_FILES)
    FOREACH(CLASS ${ARGV})
        LIST(APPEND SRC_FILES ${CLASS}.cxx)
    ENDFOREACH(CLASS ${ARGV})
    SET(SRC_FILES ${SRC_FILES} PARENT_SCOPE)
ENDMACRO(APPEND_CLASSES_TO_SRC_FILES)

MACRO(APPEND_CLASSES_TO_HDR_FILES)
    FOREACH(CLASS ${ARGV})
        LIST(APPEND HDR_FILES ${CLASS}.hxx)
    ENDFOREACH(CLASS ${ARGV})
    SET(HDR_FILES ${HDR_FILES} PARENT_SCOPE)
ENDMACRO(APPEND_CLASSES_TO_HDR_FILES)

IF (WIN32)
  ADD_DEFINITIONS(/wd4251 /wd4290)  # Disable annoying Visual C++ warnings
ENDIF (WIN32)

INCLUDE_DIRECTORIES(${PROJECT_BINARY_DIR} 
     ${PTHREAD_INCLUDE_DIR})

ADD_SUBDIRECTORY (Core)

IF (LIBBATCH_LOCAL_SUBMISSION)
    ADD_SUBDIRECTORY (Local)
ENDIF ()

ADD_SUBDIRECTORY (CCC)
ADD_SUBDIRECTORY (LSF)
ADD_SUBDIRECTORY (PBS)
ADD_SUBDIRECTORY (OAR)
ADD_SUBDIRECTORY (COORM)
ADD_SUBDIRECTORY (SGE)
ADD_SUBDIRECTORY (LoadLeveler)
ADD_SUBDIRECTORY (Slurm)

# Vishnu is not available for Windows
IF (NOT WIN32)
    ADD_SUBDIRECTORY (Vishnu)
ENDIF (NOT WIN32)

ADD_LIBRARY (batch SHARED ${SRC_FILES})

INCLUDE_DIRECTORIES(${CMAKE_CURRENT_SOURCE_DIR}/Core)
INCLUDE_DIRECTORIES(${CMAKE_CURRENT_SOURCE_DIR}/Local)
TARGET_LINK_LIBRARIES(batch ${PTHREAD_LIBRARY})

IF (WIN32)
    TARGET_LINK_LIBRARIES(batch ws2_32)
ENDIF (WIN32)

# If necessary, activate all warnings (useful for debugging and code cleaning)
# add_definitions(-Wall -Werror -ansi -pedantic)

INSTALL(TARGETS batch 
        EXPORT LibBatchTargets 
        DESTINATION lib)
INSTALL(FILES ${HDR_FILES} DESTINATION include/libbatch)

IF (LIBBATCH_PYTHON_WRAPPING AND PYTHONINTERP_FOUND AND PYTHONLIBS_FOUND AND SWIG_FOUND)
    ADD_SUBDIRECTORY(Python)
ENDIF ()
