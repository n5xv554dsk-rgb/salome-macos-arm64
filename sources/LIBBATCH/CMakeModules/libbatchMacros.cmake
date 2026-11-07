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

#
# Set of macros to identify local shell commands for file deletion,
# file copy, etc ... (under Windows and Unix).
#
MACRO(FIND_LOCAL_COMMAND VAR UNIX_COMMAND WIN32_COMMAND)
    IF (WIN32)
        FIND_PROGRAM(${VAR} ${WIN32_COMMAND})
    ELSE (WIN32)
        SET(${VAR} ${UNIX_COMMAND})
    ENDIF (WIN32)
    IF (${VAR})
        MESSAGE(STATUS "${VAR} found : ${${VAR}}")
    ELSE (${VAR})
        MESSAGE(STATUS "${VAR} not found, local submission might not work properly")
    ENDIF (${VAR})
ENDMACRO(FIND_LOCAL_COMMAND)

MACRO(FIND_LOCAL_COMMAND_WIN32_DEF VAR UNIX_COMMAND WIN32_DEFAULT)
    IF (WIN32)
        SET(${VAR} ${WIN32_DEFAULT} CACHE STRING "${VAR}")
        MESSAGE(STATUS "${VAR} found : using '${${VAR}}' (Windows default)")
    ELSE (WIN32)
        FIND_LOCAL_COMMAND(${VAR} ${UNIX_COMMAND} ${WIN32_DEFAULT})
    ENDIF (WIN32)
ENDMACRO(FIND_LOCAL_COMMAND_WIN32_DEF)

MACRO(EVAL VAR)
   IF(${ARGN})
     SET(${VAR} TRUE)
   ELSE(${ARGN})
     SET(${VAR} FALSE)
   ENDIF(${ARGN})
ENDMACRO(EVAL)

MACRO(LIBBATCH_FIND_ALL_LOCAL_COMMANDS)
  MESSAGE(STATUS "Looking for commands needed for local submission...")

  FIND_LOCAL_COMMAND_WIN32_DEF(LIBBATCH_RM_COMMAND rm del)
  FIND_LOCAL_COMMAND(LIBBATCH_SH_COMMAND sh cmd.exe)
  FIND_LOCAL_COMMAND_WIN32_DEF(LIBBATCH_CP_COMMAND cp copy)
  FIND_LOCAL_COMMAND_WIN32_DEF(LIBBATCH_MKDIR_COMMAND mkdir md)
  FIND_LOCAL_COMMAND(LIBBATCH_RSH_COMMAND rsh rsh)
  FIND_LOCAL_COMMAND(LIBBATCH_RCP_COMMAND rcp rcp)
  FIND_LOCAL_COMMAND(LIBBATCH_SSH_COMMAND ssh plink)
  FIND_LOCAL_COMMAND(LIBBATCH_SCP_COMMAND scp pscp)
  FIND_LOCAL_COMMAND(LIBBATCH_RSYNC_COMMAND rsync pscp)

  # Mark shell commands as advanced options
  # and assign the names without the LIBBATCH_ in front:
  SET (_cmds "RM;SH;CP;MKDIR;RSH;RCP;SSH;SCP;RSYNC")
  FOREACH(_cmd ${_cmds})    
    MARK_AS_ADVANCED(LIBBATCH_${_cmd}_COMMAND)
    SET(${_cmd}_COMMAND ${LIBBATCH_${_cmd}_COMMAND})
  ENDFOREACH()
ENDMACRO()

#
# Display configuration summary
#
MACRO(LIBBATCH_SUMMARY)
  MESSAGE(STATUS "")
  MESSAGE(STATUS "**************** Libbatch Summary *******")
  MESSAGE(STATUS "")
  IF (LIBBATCH_LOCAL_SUBMISSION)
    MESSAGE(STATUS "Local submission .................... Yes")
  ELSE()
    MESSAGE(STATUS "Local submission .......... Not requested")
  ENDIF()

  IF (LIBBATCH_PYTHON_WRAPPING)
    IF (PYTHONINTERP_FOUND AND PYTHONLIBS_FOUND AND SWIG_FOUND)
      MESSAGE(STATUS "Python wrapping ..................... Yes")
    ELSE()
      MESSAGE(STATUS "Python wrapping ............... Python libs (or Swig) not found")
    ENDIF()
  ELSE()
    MESSAGE(STATUS "Python wrapping ........... Not requested")
  ENDIF()

  MESSAGE(STATUS "")
  MESSAGE(STATUS "************** End Summary **************")
  MESSAGE(STATUS "")
ENDMACRO()

###
# SALOME_CHECK_EQUAL_PATHS(result path1 path2)
#  Check if two paths are identical, resolving links. If the paths do not exist a simple
#  text comparison is performed.
#  result is a boolean.
###
MACRO(SALOME_CHECK_EQUAL_PATHS varRes path1 path2)  
  SET("${varRes}" OFF)
  IF(EXISTS "${path1}")
    GET_FILENAME_COMPONENT(_tmp1 "${path1}" REALPATH)
  ELSE()
    SET(_tmp1 "${path1}")
  ENDIF() 

  IF(EXISTS "${path2}")
    GET_FILENAME_COMPONENT(_tmp2 "${path2}" REALPATH)
  ELSE()
    SET(_tmp2 "${path2}")
  ENDIF() 

  IF("${_tmp1}" STREQUAL "${_tmp2}")
    SET("${varRes}" ON)
  ENDIF()
#  MESSAGE(${${varRes}})
ENDMACRO()


####
# SALOME_FIND_PACKAGE(englobingPackageName standardPackageName modus)
# Encapsulate the call to the standard FIND_PACKAGE(standardPackageName) passing all the options
# given when calling the command FIND_PACKAGE(customPackageName)
# Modus is either MODULE or CONFIG (cf standard FIND_PACKAGE() documentation).
# This macro is to be called from within the FindCustomPackage.cmake file.
####
MACRO(SALOME_FIND_PACKAGE englobPkg stdPkg mode)
  # Only bother if the package was not already found:
  # Some old packages use the lower case version - standard should be to always use
  # upper case:
  STRING(TOUPPER ${stdPkg} stdPkgUC)
  IF(NOT (${stdPkg}_FOUND OR ${stdPkgUC}_FOUND))
    IF(${englobPkg}_FIND_QUIETLY)
      SET(_tmp_quiet "QUIET")
    ELSE()
      SET(_tmp_quiet)
    ENDIF()  
    IF(${englobPkg}_FIND_REQUIRED)
      SET(_tmp_req "REQUIRED")
    ELSE()
      SET(_tmp_req)
    ENDIF()  
    IF(${englobPkg}_FIND_VERSION_EXACT)
      SET(_tmp_exact "EXACT")
    ELSE()
      SET(_tmp_exact)
    ENDIF()
    IF(${englobPkg}_FIND_COMPONENTS)
      STRING(REPLACE ";" " " _tmp_compo ${${englobPkg}_FIND_COMPONENTS})
    ELSE()
      SET(_tmp_compo)
    ENDIF()

    # Call the root FIND_PACKAGE():
    #MESSAGE("blabla ${englobPkg} / ${${englobPkg}_FIND_VERSION_EXACT} / ${stdPkg} ${${englobPkg}_FIND_VERSION} ${_tmp_exact} ${mode}")
    IF(_tmp_compo)
      FIND_PACKAGE(${stdPkg} ${${englobPkg}_FIND_VERSION} ${_tmp_exact} ${mode} ${_tmp_quiet} ${_tmp_req} COMPONENTS ${_tmp_compo})
    ELSE()
      FIND_PACKAGE(${stdPkg} ${${englobPkg}_FIND_VERSION} ${_tmp_exact} ${mode} ${_tmp_quiet} ${_tmp_req})
    ENDIF()
  ENDIF()
ENDMACRO()

####################################################################"
# SALOME_FIND_PACKAGE_DETECT_CONFLICTS(pkg referenceVariable upCount)
#    pkg              : name of the system package to be detected
#    referenceVariable: variable containing a path that can be browsed up to 
# retrieve the package root directory (xxx_ROOT_DIR)
#    upCount          : number of times we have to go up from the path <referenceVariable>
# to obtain the package root directory.  
#   
# For example:  SALOME_FIND_PACKAGE_DETECT_CONFLICTS(SWIG SWIG_EXECUTABLE 2) 
#
# Generic detection (and conflict check) procedure for package XYZ:
# 1. Load a potential env variable XYZ_ROOT_DIR as a default choice for the cache entry XYZ_ROOT_DIR
#    If empty, load a potential XYZ_ROOT_DIR_EXP as default value (path exposed by another package depending
# directly on XYZ)
# 2. Invoke FIND_PACKAGE() in this order:
#    * in CONFIG mode first (if possible): priority is given to a potential 
#    "XYZ-config.cmake" file
#    * then switch to the standard MODULE mode, appending on CMAKE_PREFIX_PATH 
# the above XYZ_ROOT_DIR variable
# 3. Extract the path actually found into a temp variable _XYZ_TMP_DIR
# 4. Warn if XYZ_ROOT_DIR is set and doesn't match what was found (e.g. when CMake found the system installation
#    instead of what is pointed to by XYZ_ROOT_DIR - happens when a typo in the content of XYZ_ROOT_DIR).
# 5. Conflict detection:
#    * check the temp variable against a potentially existing XYZ_ROOT_DIR_EXP
# 6. Finally expose what was *actually* found in XYZ_ROOT_DIR.  
# 7. Specific stuff: for example exposing a prerequisite of XYZ to the rest of the world for future 
# conflict detection. This is added after the call to the macro by the callee.
#
MACRO(SALOME_FIND_PACKAGE_AND_DETECT_CONFLICTS pkg referenceVariable upCount)
  STRING(TOUPPER ${pkg} pkg_UC)

  # 1. Load environment or any previously detected root dir for the package
  IF(DEFINED ENV{${pkg_UC}_ROOT_DIR})
    FILE(TO_CMAKE_PATH "$ENV{${pkg_UC}_ROOT_DIR}" _${pkg_UC}_ROOT_DIR_ENV)
    SET(_dflt_value "${_${pkg_UC}_ROOT_DIR_ENV}")
  ELSE()
    # will be blank if no package was previously loaded
    SET(_dflt_value "${${pkg_UC}_ROOT_DIR_EXP}")
  ENDIF()

  #   Make cache entry 
  SET(${pkg_UC}_ROOT_DIR "${_dflt_value}" CACHE PATH "Path to ${pkg_UC} directory")

  # 2. Find package - config mode first (i.e. looking for XYZ-config.cmake)
  IF(EXISTS "${${pkg_UC}_ROOT_DIR}")
    # Hope to find direclty a CMake config file there
    SET(_CONF_DIR "${${pkg_UC}_ROOT_DIR}/share/cmake") 

    # Try find_package in config mode with a hard-coded guess. This
    # has the priority.
    FIND_PACKAGE(${pkg} NO_MODULE QUIET PATHS "${_CONF_DIR}")
    MARK_AS_ADVANCED(${pkg}_DIR)
      
    IF (NOT ${pkg_UC}_FOUND)  
      SET(CMAKE_PREFIX_PATH "${${pkg_UC}_ROOT_DIR}")
    ELSE()
      MESSAGE(STATUS "Found ${pkg} in CONFIG mode!")
    ENDIF()
  ENDIF()

  # Otherwise try the standard way (module mode, with the standard CMake Find*** macro):
  SALOME_FIND_PACKAGE("Salome${pkg}" ${pkg} MODULE)
  #MESSAGE("dbg ${pkg_UC} / ${PTHREAD_FOUND} / ${${pkg_UC}_FOUND}")
  # Set the "FOUND" variable for the SALOME wrapper:
  IF(${pkg_UC}_FOUND OR ${pkg}_FOUND)
    SET(SALOME${pkg_UC}_FOUND TRUE)
  ELSE()
    SET(SALOME${pkg_UC}_FOUND FALSE)
  ENDIF()
  
  IF (${pkg_UC}_FOUND OR ${pkg}_FOUND)
    # 3. Set the root dir which was finally retained by going up "upDir" times
    # from the given reference path. The variable "referenceVariable" may be a list
    # - we take its first element. 
    #   Note the double de-reference of "referenceVariable":
    LIST(LENGTH "${${referenceVariable}}" _tmp_len)
    IF(_tmp_len)
       LIST(GET "${${referenceVariable}}" 0 _tmp_ROOT_DIR)
    ELSE()
       SET(_tmp_ROOT_DIR "${${referenceVariable}}")
    ENDIF()
    IF(${upCount})
      MATH(EXPR _rge "${upCount}-1") 
      FOREACH(_unused RANGE ${_rge})        
        GET_FILENAME_COMPONENT(_tmp_ROOT_DIR "${_tmp_ROOT_DIR}" PATH)
      ENDFOREACH()
    ENDIF()

    # 4. Warn if CMake found something not located under ENV(XYZ_ROOT_DIR)
    IF(DEFINED ENV{${pkg_UC}_ROOT_DIR})
      SALOME_CHECK_EQUAL_PATHS(_res "${_tmp_ROOT_DIR}" "${_${pkg_UC}_ROOT_DIR_ENV}")
      IF(NOT _res)
        MESSAGE(WARNING "${pkg} was found, but not at the path given by the "
            "environment ${pkg_UC}_ROOT_DIR! Is the variable correctly set? "
            "The two paths are: ${_tmp_ROOT_DIR} and: ${_${pkg_UC}_ROOT_DIR_ENV}")
        
      ELSE()
        MESSAGE(STATUS "${pkg} found directory matches what was specified in the ${pkg_UC}_ROOT_DIR variable, all good!")    
      ENDIF()
    ELSE()
        MESSAGE(STATUS "Variable ${pkg_UC}_ROOT_DIR was not explicitly defined: "
          "an installation was found anyway: ${_tmp_ROOT_DIR}")
    ENDIF()

    # 5. Conflict detection
    # 5.1  From another prerequisite using the package
    IF(${pkg_UC}_ROOT_DIR_EXP)
        SALOME_CHECK_EQUAL_PATHS(_res "${_tmp_ROOT_DIR}" "${${pkg_UC}_ROOT_DIR_EXP}") 
        IF(NOT _res)
           MESSAGE(WARNING "Warning: ${pkg}: detected version conflicts with a previously found ${pkg}!"
                            "The two paths are " ${_tmp_ROOT_DIR} " vs " ${${pkg_UC}_ROOT_DIR_EXP})
        ELSE()
            MESSAGE(STATUS "${pkg} directory matches what was previously exposed by another prereq, all good!")
        ENDIF()        
    ENDIF()
    
    # 6. Save the found installation
    #
    SET(${pkg_UC}_ROOT_DIR "${_tmp_ROOT_DIR}")
     
  ELSE()
    MESSAGE(STATUS "${pkg} was not found.")  
  ENDIF()
ENDMACRO(SALOME_FIND_PACKAGE_AND_DETECT_CONFLICTS)
