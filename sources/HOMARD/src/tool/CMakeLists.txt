# Copyright (C) 2016-2026  CEA, EDF
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

cmake_minimum_required (VERSION 2.8)
PROJECT (Homard C Fortran)

SET(${PROJECT_NAME_UC}_VERSION_MAJOR 11)
SET(${PROJECT_NAME_UC}_VERSION_MINOR 99)
SET(${PROJECT_NAME_UC}_VERSION_PATCH 0)
SET(${PROJECT_NAME_UC}_VERSION ${${PROJECT_NAME_UC}_VERSION_MAJOR}.${${PROJECT_NAME_UC}_VERSION_MINOR}.${${PROJECT_NAME_UC}_VERSION_PATCH})

# Fortran options

IF (WIN32)
   SET(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -fpp -i8 /iface:mixed_str_len_arg ")
ELSE()
   SET(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -ffixed-line-length-0 -fdefault-double-8 -fdefault-real-8 -fdefault-integer-8 -fimplicit-none -O2") 
ENDIF (WIN32)

# static libraries to build
SET(_HT_libs
  HOMARD_00
  Suivi_Frontiere
  Information
  Modification
  AV_Conversion
  Decision
  Creation_Maillage
  AP_Conversion
  ES_Xfig
  ES_HOMARD
  ES_MED
  Utilitaire
  Gestion_MTU
  Dependance_Machine
 )

IF (WIN32)
  ADD_DEFINITIONS(-Dextern_stdcall)
  ADD_DEFINITIONS(-D_DEBUG_HOMARD_)
  ADD_DEFINITIONS(-D_USE_64_BITS)
ENDIF (WIN32)

FUNCTION(HT_BUILD_LIBRARY dir)
  FILE(GLOB _f_sources LIST_DIRECTORIES false ${CMAKE_CURRENT_SOURCE_DIR}/${dir}/*.F)
  FILE(GLOB _c_sources LIST_DIRECTORIES false ${CMAKE_CURRENT_SOURCE_DIR}/${dir}/*.c)
  INCLUDE_DIRECTORIES(Includes_Generaux ${CMAKE_CURRENT_SOURCE_DIR})
  
  IF (WIN32)
    IF (_f_sources)
      INCLUDE_DIRECTORIES(Includes_Generaux ${CMAKE_CURRENT_SOURCE_DIR})
      ADD_LIBRARY (${dir}_f_lib STATIC ${_f_sources})
      set_target_properties(${dir}_f_lib PROPERTIES LINKER_LANGUAGE Fortran)
      set_target_properties(${dir}_f_lib PROPERTIES COMPILE_FLAGS " -fpp -i8 /iface:mixed_str_len_arg " )
      SET(TARGET_OBJECTS_LIST $<TARGET_OBJECTS:${dir}_f_lib> )
    ENDIF()
    IF (_c_sources)
      ADD_LIBRARY (${dir}_c_lib STATIC ${_c_sources})
      set_target_properties(${dir}_c_lib PROPERTIES COMPILE_FLAGS "/MT" )
      SET(TARGET_OBJECTS_LIST ${TARGET_OBJECTS_LIST} $<TARGET_OBJECTS:${dir}_c_lib> )
    ENDIF()
    INCLUDE_DIRECTORIES(Includes_Generaux ${CMAKE_CURRENT_SOURCE_DIR})
    add_library(${dir} STATIC ${TARGET_OBJECTS_LIST})
  ELSE()
     ADD_LIBRARY (${dir} STATIC ${_f_sources} ${_c_sources})
  ENDIF (WIN32)
ENDFUNCTION()


FOREACH(_HT_lib ${_HT_libs})
  HT_BUILD_LIBRARY(${_HT_lib})
ENDFOREACH()

# additional libraries to link with
SET(_link_LIBRARIES
  ${HDF5_LIBRARIES}
  ${MEDFILE_LIBRARIES})

# Main executable
ADD_EXECUTABLE(homard homard.f)
IF (WIN32)
   set_target_properties(homard PROPERTIES COMPILE_FLAGS " -fpp -i8 /iface:mixed_str_len_arg " )
ENDIF (WIN32)

TARGET_LINK_LIBRARIES(homard ${_HT_libs} ${_link_LIBRARIES})
INSTALL(TARGETS homard EXPORT ${PROJECT_NAME}TargetGroup DESTINATION ${SALOME_INSTALL_BINS})
