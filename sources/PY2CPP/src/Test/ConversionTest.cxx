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
#include "ConversionTest.hxx"
#include "py2cpp.hxx"

void ConversionTest::setUp()
{
  Py_Initialize();
}

void ConversionTest::tearDown()
{
  Py_Finalize();
}

void ConversionTest::cleanUp(){}

void ConversionTest::basicTest()
{
  CPPUNIT_ASSERT(42==py2cpp::fromPyPtr<int>(py2cpp::toPyPtr(42)));
  CPPUNIT_ASSERT(4.2==py2cpp::fromPyPtr<double>(py2cpp::toPyPtr(4.2)));
  CPPUNIT_ASSERT(py2cpp::fromPyPtr<bool>(py2cpp::toPyPtr(true)));
  CPPUNIT_ASSERT(!py2cpp::fromPyPtr<bool>(py2cpp::toPyPtr(false)));
  std::string toto;
  toto = py2cpp::fromPyPtr<std::string>(py2cpp::toPyPtr(std::string("toto")));
  CPPUNIT_ASSERT(toto == "toto");

  auto v = std::make_tuple(4, 4.2);
  py2cpp::PyPtr obj = py2cpp::toPyPtr(v);

  std::string s1;
  double d;
  int i;
  std::tuple<int&, double&> tup(i, d);
  py2cpp::fromPyPtr(obj, tup);
  CPPUNIT_ASSERT(4==std::get<0>(tup));
  CPPUNIT_ASSERT(4.2==std::get<1>(tup));
  int i2;
  double d2;
  py2cpp::pyResult(i2, d2) = obj;
  CPPUNIT_ASSERT(4==i2);
  CPPUNIT_ASSERT(4.2==d2);
  py2cpp::pyResult(i2) = py2cpp::toPyPtr(42);
  CPPUNIT_ASSERT(42 == i2);
  py2cpp::PyPtr copy(obj);
  i2=0; d2=0.;
  py2cpp::pyResult(i2, d2) = copy;
  CPPUNIT_ASSERT(4==i2);
  CPPUNIT_ASSERT(4.2==d2);
  py2cpp::PyPtr copy2;
  copy2 = obj;
  i2=0; d2=0.;
  py2cpp::pyResult(i2, d2) = copy2;
  CPPUNIT_ASSERT(4==i2);
  CPPUNIT_ASSERT(4.2==d2);
}

void ConversionTest::functionTest()
{
  int i;
  double d;
  std::string str;
  py2cpp::PyFunction fn;

  CPPUNIT_ASSERT(fn.load("TestPy2cpp", "f1"));
  CPPUNIT_ASSERT(fn);
  py2cpp::pyResult(i, d) = fn(5, 4.8);
  CPPUNIT_ASSERT(4==i);
  CPPUNIT_ASSERT(6.7==d);
  CPPUNIT_ASSERT(0==py2cpp::getLastPyError().size());

  fn.load("TestPy2cpp", "f2");
  CPPUNIT_ASSERT(fn);
  py2cpp::pyResult(str) = fn();
  CPPUNIT_ASSERT(str=="Hello world!");
  CPPUNIT_ASSERT(0==py2cpp::getLastPyError().size());

  fn.load("TestPy2cpp", "f3");
  CPPUNIT_ASSERT(fn);
  py2cpp::pyResult(d, str) = fn(7, 2, "Toto");
  CPPUNIT_ASSERT(3.5 == d);
  CPPUNIT_ASSERT(str == "Toto is here!");
  CPPUNIT_ASSERT(0==py2cpp::getLastPyError().size());

  CPPUNIT_ASSERT(!fn.load("nonexistent","nonexistent"));
  CPPUNIT_ASSERT(!fn);
  CPPUNIT_ASSERT(0 < py2cpp::getLastPyError().size());
}

void ConversionTest::vectorTest()
{
  std::vector<double> v = {1.1, 2.2, 3.3, 4.4};
  py2cpp::PyPtr obj = py2cpp::toPyPtr(v);
  py2cpp::fromPyPtr(obj, v);

  std::vector<double> result;
  py2cpp::PyFunction fn;
  fn.load("TestPy2cpp", "add1ToList");
  py2cpp::pyResult(result) = fn(v);

  CPPUNIT_ASSERT(std::vector<double>({2.1, 3.2, 4.3, 5.4}) == result);

  auto tup = std::make_tuple(4, 4.2);
  py2cpp::PyPtr pyTup = py2cpp::toPyPtr(tup);
  py2cpp::fromPyPtr(pyTup, result);
  CPPUNIT_ASSERT(std::vector<double>({4, 4.2}) == result);
}

void ConversionTest::listTest()
{
  std::list<double> v = {1.1, 2.2, 3.3, 4.4};
  py2cpp::PyPtr obj = py2cpp::toPyPtr(v);
  py2cpp::fromPyPtr(obj, v);

  std::list<double> result;
  py2cpp::PyFunction fn;
  fn.load("TestPy2cpp", "add1ToList");
  py2cpp::pyResult(result) = fn(v);

  CPPUNIT_ASSERT(std::list<double>({2.1, 3.2, 4.3, 5.4}) == result);

  auto tup = std::make_tuple(4, 4.2);
  py2cpp::PyPtr pyTup = py2cpp::toPyPtr(tup);
  py2cpp::fromPyPtr(pyTup, result);
  CPPUNIT_ASSERT(std::list<double>({4, 4.2}) == result);
}

void ConversionTest::pyobjTest()
{
  py2cpp::PyFunction objcall;
  objcall.load("TestPy2cpp","MyClass");
  CPPUNIT_ASSERT(objcall);
  py2cpp::PyPtr obj = objcall(std::list<std::string>({"Toto", "Titi", "Zaza"}),
                              std::vector<double>({5.5, 2.7, 1.8, 9.2}));
  py2cpp::PyFunction objFn1, objFn2, objFn3;
  objFn1.load(obj, "namesTogether");
  objFn2.load(obj, "valuesSum");
  objFn3.load(obj, "addVal");
  std::string strResult;
  double dbResult;
  py2cpp::pyResult(strResult) = objFn1();
  py2cpp::pyResult(dbResult) = objFn2();
  CPPUNIT_ASSERT(strResult == "Toto-Titi-Zaza");
  CPPUNIT_ASSERT(19.2 == dbResult);

  objFn3(1);
  py2cpp::pyResult(dbResult) = objFn2();
  CPPUNIT_ASSERT(23.2 == dbResult);

  py2cpp::PyFunction myObjectSize;
  myObjectSize.load("TestPy2cpp", "myObjectSize");
  int i;
  py2cpp::pyResult(i) = myObjectSize(obj);
  CPPUNIT_ASSERT(7==i);
  CPPUNIT_ASSERT(obj.getAttr("names").repr() == "['Toto', 'Titi', 'Zaza']");
  CPPUNIT_ASSERT(obj.getAttr("values").repr() == "[6.5, 3.7, 2.8, 10.2]");

  objFn1.load("TestPy2cpp","newobj");
  py2cpp::PyPtr newobj;
  py2cpp::pyResult(newobj, i) = objFn1(obj, std::vector<int>({1,2,3}));
  CPPUNIT_ASSERT(6==i);
  CPPUNIT_ASSERT(newobj.getAttr("names").repr() == "['Toto', 'Titi', 'Zaza']");
  CPPUNIT_ASSERT(newobj.getAttr("values").repr() == "[1, 2, 3]");
}

void ConversionTest::pyErrorTest()
{
  double d;
  std::string str;
  py2cpp::PyFunction fn;
  fn.load("TestPy2cpp", "f3");
  try
  {
    fn(7, 0, "problem");
    CPPUNIT_FAIL("Expected exception 'py2cpp::ExecutionException'!");
  }
  catch (const py2cpp::ExecutionException& err)
  {
    str = err.what();
    CPPUNIT_ASSERT(str.find("ZeroDivisionError:") != std::string::npos) ;
  }

  try
  {
    py2cpp::pyResult(d, str) = fn(7, 0, "problem");
    CPPUNIT_FAIL("Expected exception 'py2cpp::ExecutionException'!");
  }
  catch (const py2cpp::ExecutionException& err)
  {
    str = err.what();
    CPPUNIT_ASSERT(str.find("ZeroDivisionError:") != std::string::npos) ;
  }
}

void ConversionTest::castErrorTest()
{
  int i;
  double d;
  std::string str;
  std::vector<int> vi;
  std::vector<double> vd;
  std::vector<std::string> vs;
  std::map<std::string, std::vector<double> > msvd;
  py2cpp::ConversionCheck check;
  py2cpp::PyPtr obj;

  obj = py2cpp::toPyPtr(42);
  check = py2cpp::fromPyPtr(obj, d);
  CPPUNIT_ASSERT(check);
  check = py2cpp::fromPyPtr(obj, vi);
  CPPUNIT_ASSERT(check.getMessage() ==
"Cannot convert the python object <42> to c++ type std::vector.\n");
  check = py2cpp::fromPyPtr(obj, str);
  CPPUNIT_ASSERT(check.getMessage() ==
"Cannot convert the python object <42> to c++ type std::string.\n");
  check = py2cpp::fromPyPtr(obj, msvd);
  CPPUNIT_ASSERT(check.getMessage() ==
"Cannot convert the python object <42> to c++ type std::map.\n");

  obj = py2cpp::toPyPtr(std::vector<int>({1,2,3,4,5,6}));
  check = py2cpp::fromPyPtr(obj, i);
  CPPUNIT_ASSERT(check.getMessage() ==
"Cannot convert the python object <[1, 2, 3, 4, 5, 6]> to c++ type int.\n");
  check = py2cpp::fromPyPtr(obj, d);
  CPPUNIT_ASSERT(check.getMessage() ==
"Cannot convert the python object <[1, 2, 3, 4, 5, 6]> to c++ type double.\n");
  check = py2cpp::fromPyPtr(obj, vi);
  CPPUNIT_ASSERT(check);
  check = py2cpp::fromPyPtr(obj, vd);
  CPPUNIT_ASSERT(check);
  check = py2cpp::fromPyPtr(obj, str);
  CPPUNIT_ASSERT(check.getMessage() ==
"Cannot convert the python object <[1, 2, 3, 4, 5, 6]> to c++ type std::string.\n"
  );

  check = py2cpp::fromPyPtr(obj, vs);
  CPPUNIT_ASSERT(check.getMessage() ==
"Cannot convert the python object <1> to c++ type std::string.\n"
"Cannot convert the python object <[1, 2, 3, 4, 5, 6]> to c++ type std::vector.\n"
  );
  check = py2cpp::fromPyPtr(obj, msvd);
  CPPUNIT_ASSERT(check.getMessage() ==
"Cannot convert the python object <[1, 2, 3, 4, 5, 6]> to c++ type std::map.\n");
  
  std::map<int, double> mid({ {1, 1.1},{2, 2.2},{3, 3.3},{4, 4.4},{5, 5.5}});
  obj = py2cpp::toPyPtr(mid);
  check = py2cpp::fromPyPtr(obj, i);
  // Cannot check the message because the string representation of the python
  // dictionary may change.
  CPPUNIT_ASSERT(!check);
  check = py2cpp::fromPyPtr(obj, vd);
  CPPUNIT_ASSERT(!check);
  check = py2cpp::fromPyPtr(obj, msvd);
  CPPUNIT_ASSERT(!check);

  std::map<std::string, double> msd({ {"1", 1.1},{"2", 2.2},{"3", 3.3},
                                    {"4", 4.4},{"5", 5.5}});
  obj = py2cpp::toPyPtr(msd);
  check = py2cpp::fromPyPtr(obj, msvd);
  CPPUNIT_ASSERT(!check);

  std::map<std::string, std::vector<std::string> > msvs ;
  msvs["a"] = std::vector<std::string>({"azer", "aqwx"});
  msvs["b"] = std::vector<std::string>({"bn,", "bvcxw"});
  obj = py2cpp::toPyPtr(msvs);
  check = py2cpp::fromPyPtr(obj, msvd);
  CPPUNIT_ASSERT(!check);
}

CPPUNIT_TEST_SUITE_REGISTRATION( ConversionTest );
#include "TestMain.cxx"
