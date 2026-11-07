// Copyright (C) 2019-2026 EDF
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
#ifndef PY2CPP_CONVERSIONTEST_HXX
#define PY2CPP_CONVERSIONTEST_HXX

#include <cppunit/extensions/HelperMacros.h>

class ConversionTest: public CppUnit::TestFixture
{
  CPPUNIT_TEST_SUITE(ConversionTest);
  CPPUNIT_TEST(basicTest);
  CPPUNIT_TEST(functionTest);
  CPPUNIT_TEST(vectorTest);
  CPPUNIT_TEST(listTest);
  CPPUNIT_TEST(pyobjTest);
  CPPUNIT_TEST(pyErrorTest);
  CPPUNIT_TEST(castErrorTest);
  CPPUNIT_TEST_SUITE_END();
public:
  void setUp();
  void tearDown();
  void cleanUp();
  void basicTest();
  void functionTest();
  void vectorTest();
  void listTest();
  void pyobjTest();
  void pyErrorTest();
  void castErrorTest();
};

#endif // PY2CPP_CONVERSIONTEST_HXX
