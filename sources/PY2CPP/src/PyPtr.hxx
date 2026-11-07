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
#ifndef PY2CPP_PYPTR_HXX
#define PY2CPP_PYPTR_HXX
#include "py2cppExports.hxx"
#include <Python.h>
#include <memory>
#include <string>

namespace py2cpp
{
class PY2CPP_EXPORT PyPtrDeleter
{
public:
  void operator()(PyObject * po){Py_DECREF(po);}
};

typedef std::unique_ptr<PyObject, PyPtrDeleter> _PyPtr;

class PY2CPP_EXPORT PyPtr: public _PyPtr
{
public:
  PyPtr();
  PyPtr(std::nullptr_t copy);
  PyPtr(PyObject* pyObj);
  PyPtr(const PyPtr& copy);
  PyPtr(PyPtr&& move);
  PyPtr& operator=(const PyPtr& copy);
  PyPtr& operator=(PyPtr&& move);
  PyPtr& operator=(std::nullptr_t copy);

  PyPtr getAttr(const std::string& attribute)const;
  void setAttr(const std::string& attribute, const PyPtr& value)const;
  std::string repr()const;
};

class PY2CPP_EXPORT AutoGIL
{
public:
  AutoGIL():_gstate(PyGILState_Ensure()) { }
  ~AutoGIL() { PyGILState_Release(_gstate); }
private:
  PyGILState_STATE _gstate;
};

}

#endif // PY2CPP_PYPTR_HXX
