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
#ifndef PY2CPP_RESULT_HXX
#define PY2CPP_RESULT_HXX
#include "py2cppExports.hxx"
#include <Python.h>
#include <tuple>
#include "TypeConversions.hxx"
#include "Errors.hxx"

namespace py2cpp
{

template<class ...Ts>
class Result;

/*! class Result is used by pyResult function for syntax sugar purpose.
 * You can write this:
 *   double d;
 *   std::string str;
 *   py2cpp::PyFunction fn;
 *   fn.load("mymodule", "myfunction");
 *   try
 *     py2cpp::pyResult(d, str) = fn(42);
 *   catch (const py2cpp::Exception& err)
 *     std::cerr << err.what();
 *
 * Instead of that:
 *   double d;
 *   std::string str;
 *   py2cpp::PyFunction fn;
 *   fn.load("mymodule", "myfunction");
 *   py2cpp::PyPtr fn_result = fn(42);
 *   if(fn_result)
 *   {
 *     std::tuple<double&, std::string&> cpp_result(d, str);
 *     ConversionCheck check = fromPyPtr(fn_result, cpp_result);
 *     if(!check)
 *       std::cerr << err.getMessage();
 *   }
 *   else
 *     std::cerr << py2cpp::getLastPyError();
 **/
template<>
class Result<>
{
public:
  void operator=(PyObject * po)
  {
    if(!po)
      throw ExecutionException(getLastPyError());
  }
  void operator=(const PyPtr& po){*this = po.get();}
};

template<class T>
class Result<T>
{
public:
  Result() = delete;
  Result(T& v):_data(v){}
  void operator=(PyObject *po)
  {
    if(!po)
      throw ExecutionException(getLastPyError());
    ConversionCheck check;
    check = fromPy(po, _data);
    if(!check)
    {
      throw ConversionException(check.getMessage());
    }
  }
  void operator=(const PyPtr& po){ *this = po.get();}
private:
  T& _data;
};

template<class ...Ts>
class Result
{
public:
  Result() = delete;
  Result(Ts&...args):_data(args...){}
  void operator=(PyObject *po)
  {
    if(!po)
      throw ExecutionException(getLastPyError());
    ConversionCheck check;
    check = fromPy(po, _data);
    if(!check)
      throw ConversionException(check.getMessage());
  }
  void operator=(const PyPtr& po){ *this = po.get();};
private:
  std::tuple<Ts&...> _data;
};

template<class ...Ts>
Result<Ts...> pyResult(Ts&... args)
{
  return Result<Ts...>(args...);
}

}

#endif //PY2CPP_RESULT_HXX
