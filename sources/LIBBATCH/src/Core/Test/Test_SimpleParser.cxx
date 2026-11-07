// Copyright (C) 2007-2021  CEA/DEN, EDF R&D, OPEN CASCADE
//
// Copyright (C) 2003-2007  OPEN CASCADE, EADS/CCR, LIP6, CEA/DEN,
// CEDRAT, EDF R&D, LEG, PRINCIPIA R&D, BUREAU VERITAS
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
//
// See http://www.salome-platform.org/ or email : webmaster.salome@opencascade.com
//
/*
 *  Test_SimpleParser.cxx :
 *
 *  Created on: 23 juil. 2009
 *  Author : Renaud BARATE - EDF R&D
 */

#include <cassert>
#include <iostream>

#include <Test_config.h>

#include "SimpleParser.hxx"

using namespace std;

int main(int /*argc*/, char** /*argv*/)
{
  cout << "*******************************************************************************************" << endl;
  cout << "This program tests the simple parser that parses the configuration file used in the other" << endl;
  cout << "tests. For this test, the environment variable " << TEST_CONFIG_FILE_ENV_VAR << " must " << endl;
  cout << "exist and contain the path to the configuration file to use for the tests." << endl;
  cout << "*******************************************************************************************" << endl;

  // Create the parser
  SimpleParser parser;

  try {
    // Parse the configuration file
    parser.parseTestConfigFile();
  } catch (const ParserException& e) {
    cerr << "Parser error: " << e.what() << endl;
    return 1;
  }

  // Print the configuration
  cout << "Configuration map:" << endl;
  cout << parser << endl;

  return 0;
}
