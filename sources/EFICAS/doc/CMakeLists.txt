# Copyright (C) 2001-2026  EDF R&D
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

SET(RSTFILES
  index.rst
  eficas_for_Aster.rst
  eficas_in_salome.rst
  eficas_personnalisation.rst
  eficas_presentation.rst
  eficas_principles.rst
  eficas_rules.rst
  python_rules.rst
  )

SET(SPHINXOPTS )
SET(SOURCEDIR ${CMAKE_CURRENT_SOURCE_DIR})
SET(PAPEROPT_a4 -D latex_paper_size=a4)
SET(ALLSPHINXOPTS -d doctrees ${PAPEROPT_a4} ${SPHINXOPTS} ${SOURCEDIR})

# install user's documentation

SALOME_CONFIGURE_FILE(conf.py.in conf.py)

ADD_CUSTOM_TARGET(htm 
  COMMAND ${CMAKE_COMMAND} -E make_directory html 
  COMMAND ${CMAKE_COMMAND} -E make_directory doctrees
  COMMAND ${SPHINX_EXECUTABLE} -c ${CMAKE_BINARY_DIR}/doc -b html ${ALLSPHINXOPTS} html
  DEPENDS ${RSTFILES}
  WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
  )
INSTALL(CODE "EXECUTE_PROCESS(COMMAND \"${CMAKE_COMMAND}\" --build ${PROJECT_BINARY_DIR} --target htm)")
INSTALL(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/html/ 
  DESTINATION ${SALOME_INSTALL_DOC}/gui/EFICAS 
  USE_SOURCE_PERMISSIONS
  PATTERN ".buildinfo" EXCLUDE
  )
  
SET_DIRECTORY_PROPERTIES(PROPERTIES ADDITIONAL_MAKE_CLEAN_FILES html)
SET_DIRECTORY_PROPERTIES(PROPERTIES ADDITIONAL_MAKE_CLEAN_FILES doctrees)

