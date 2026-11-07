# ==============================================================================
# SALOME_CREATE_SYMLINK macro creates symbolic link during installation step
#
# USAGE: SALOME_CREATE_SYMLINK(src_path link_path)
#
# ARGUMENTS:
#
# src_path     Source path to the file or directory.
# link_path    Target symbolic link path.
#
# WARNING:     Link is created only on those platforms which support this.
#
# ==============================================================================

MACRO(SALOME_CREATE_SYMLINK src_path link_path)
  IF(SALOME_RELATIVE_SYMLINKS)
    FILE(RELATIVE_PATH _link "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/${link_path}/.." "${src_path}")
  ELSE()
    SET(_link "${src_path}")
  ENDIF()
  INSTALL(CODE "
          IF(EXISTS \"${src_path}\")
            MESSAGE(STATUS \"Creating symbolic link \$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/${link_path}\")
            GET_FILENAME_COMPONENT(_path \"$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/${link_path}\" DIRECTORY)
            EXECUTE_PROCESS(COMMAND ${CMAKE_COMMAND} -E make_directory
                    \"\${_path}\")
            EXECUTE_PROCESS(COMMAND ${CMAKE_COMMAND} -E create_symlink
                    \"${_link}\" \"\$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/${link_path}\"
                    WORKING_DIRECTORY \"${_path}\")
          ENDIF()
          ")
ENDMACRO()

# ==============================================================================
# SALOME_INSTALL_MODULE_DOC macro creates symbolic link during installation step
#
# USAGE: SALOME_INSTALL_MODULE_DOC(src ... DESTINATION dest_dir [INDEX index_dir ...])
#
# ARGUMENTS:
#
# src          Directory of file to install.
# dest_dir     Target directory.
# index_dir    Sub-directory(-ies) to put stub index file.
#
# ==============================================================================

MACRO(SALOME_INSTALL_MODULE_DOC)
  CMAKE_PARSE_ARGUMENTS(_SALOME_INSTALL_MODULE_DOC "" "DESTINATION" "INDEX" ${ARGN})
  SET(_args ${_SALOME_INSTALL_MODULE_DOC_UNPARSED_ARGUMENTS})
  IF(SALOME_INSTALL_MODULES_DOC)
    FOREACH(_arg ${_args})
      GET_FILENAME_COMPONENT(_arg_name ${_arg} NAME)
      IF(EXISTS "${_arg}")
        IF(NOT WIN32 AND SALOME_CREATE_SYMLINKS)
          SALOME_CREATE_SYMLINK("${_arg}" "${_SALOME_INSTALL_MODULE_DOC_DESTINATION}/${_arg_name}")
        ELSE()
          IF(IS_DIRECTORY "${_arg}")
            INSTALL(DIRECTORY "${_arg}"
                    DESTINATION "${_SALOME_INSTALL_MODULE_DOC_DESTINATION}")
          ELSE()
            INSTALL(FILES "${_arg}"
                    DESTINATION "${_SALOME_INSTALL_MODULE_DOC_DESTINATION}")
          ENDIF()
        ENDIF()
      ELSE()
        IF(_SALOME_INSTALL_MODULE_DOC_INDEX)
          FOREACH(_index ${_SALOME_INSTALL_MODULE_DOC_INDEX})
            SET(_install_dir "${_SALOME_INSTALL_MODULE_DOC_DESTINATION}/${_arg_name}/${_index}")
            INSTALL(FILES ${CMAKE_SOURCE_DIR}/cmake/dummy_index.html DESTINATION "${_install_dir}" RENAME index.html)
          ENDFOREACH()
        ELSE()
          SET(_install_dir "${_SALOME_INSTALL_MODULE_DOC_DESTINATION}/${_arg_name}")
          INSTALL(FILES ${CMAKE_SOURCE_DIR}/cmake/dummy_index.html DESTINATION "${_install_dir}" RENAME index.html)
        ENDIF()
      ENDIF()
    ENDFOREACH()
  ENDIF()
  UNSET(_args)
ENDMACRO()
