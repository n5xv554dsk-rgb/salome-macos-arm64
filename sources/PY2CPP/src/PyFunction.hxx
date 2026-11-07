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
#ifndef PY2CPP_FUNCTIONCALLS_HXX
#define PY2CPP_FUNCTIONCALLS_HXX

#include "py2cppExports.hxx"
#include <Python.h>
#include <tuple>
#include "TypeConversions.hxx"
#include "Errors.hxx"

namespace py2cpp
{
class PY2CPP_EXPORT PyFunction : public PyPtr
{
public:
  /*! Load a callable object from a python module.*/
  bool load(const std::string& module, const std::string& function);
  /*! Load a callable object member of a python object.*/
  bool load(const PyPtr& obj, const std::string& function);
  bool load(PyObject* obj, const std::string& function);

  // The following versions of the functions throw ExecutionException in case of
  // failure.
  void loadExp(const std::string& module, const std::string& function);
  void loadExp(const PyPtr& obj, const std::string& function);
  void loadExp(PyObject* obj, const std::string& function);

  /*!
   * The evaluation returns nullptr if the python function throws an exception.
   * See PyObject_CallObject documentation.
   * You can use getLastPyError in order to get the last python error.
   */
  template <class ...Ts>
  PyPtr safeEval(const Ts&... args)
  {
    PyPtr result;
    PyObject * myFunc = get();
    if(myFunc && PyCallable_Check(myFunc))
    {
      std::tuple<const Ts&...> tupleArgs(args...);
      PyPtr pyArgs(toPy(tupleArgs));
      result.reset(PyObject_CallObject(myFunc, pyArgs.get()));
    }
    return result;
  }

  /*!
   * The evaluation throws ExecutionException if the python function throws an
   * exception.
   */
  template <class ...Ts>
  PyPtr operator()(const Ts&... args)
  {
    PyPtr result = safeEval(args...);
    if(!result)
    {
      throw ExecutionException(getLastPyError());
    }
    return result;
  }
};
}

#endif //PY2CPP_FUNCTIONCALLS_HXX
