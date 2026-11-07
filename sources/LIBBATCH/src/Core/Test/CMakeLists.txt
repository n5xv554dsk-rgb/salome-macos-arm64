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

# Declare the configuration variable for the test scripts
SET (LIBBATCH_TEST_CONF_ENV_VAR "BATCH_TEST_CONFIG_FILE" CACHE STRING
     "Name of the environment variable containing the configuration file name for the tests (only necessary for test target)")

# Configure the config file for the test scripts
CONFIGURE_FILE(${CMAKE_CURRENT_SOURCE_DIR}/Test_config.h.in ${CMAKE_CURRENT_BINARY_DIR}/Test_config.h)

# Set the include directories
include_directories(${CMAKE_CURRENT_BINARY_DIR})
include_directories(${PROJECT_SOURCE_DIR}/src/Core)

# Build SimpleParser library
add_library (SimpleParser STATIC SimpleParser.cxx)

# Build the test program for SimpleParser
add_executable(Test_SimpleParser Test_SimpleParser.cxx)
target_link_libraries(Test_SimpleParser SimpleParser)

# Add the test itself
ADD_TEST(SimpleParser Test_SimpleParser)

# Build the test program for the batch managers
add_executable(Test_BatchManager Test_BatchManager.cxx)
target_link_libraries(Test_BatchManager batch SimpleParser)
