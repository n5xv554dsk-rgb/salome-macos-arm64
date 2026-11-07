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

#ifndef YDEFX_SAMPLETEST_HXX
#define YDEFX_SAMPLETEST_HXX

#include <cppunit/extensions/HelperMacros.h>

class SampleTest: public CppUnit::TestFixture
{
  CPPUNIT_TEST_SUITE(SampleTest);
  CPPUNIT_TEST(pointState);
  CPPUNIT_TEST(pyConversions);
  CPPUNIT_TEST(pyConversionsErrors);
  CPPUNIT_TEST(params);
  CPPUNIT_TEST_SUITE_END();
public:
  void setUp();
  void tearDown();
  void cleanUp();
  void pointState();
  void pyConversions();
  void pyConversionsErrors();
  void params();
};

#endif // YDEFX_SAMPLETEST_HXX
