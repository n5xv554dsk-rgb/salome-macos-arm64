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
#include "PyPtr.hxx"
#include "Errors.hxx"

namespace py2cpp
{

PyPtr::PyPtr()
: _PyPtr()
{
}

PyPtr::PyPtr(std::nullptr_t copy)
: _PyPtr(copy)
{
}

PyPtr::PyPtr(PyObject* pyObj)
: _PyPtr(pyObj)
{
}

PyPtr::PyPtr(const PyPtr& copy)
: _PyPtr(copy.get())
{
  Py_XINCREF(copy.get());
}

PyPtr::PyPtr(PyPtr&& move)
: _PyPtr(std::move(move))
{
}

PyPtr& PyPtr::operator=(std::nullptr_t copy)
{
  _PyPtr::operator=(copy);
  return *this;
}

PyPtr& PyPtr::operator=(const PyPtr& copy)
{
  PyObject* pyCopy = copy.get();
  if(get() != pyCopy)
  {
    Py_XINCREF(pyCopy);
    reset(pyCopy);
  }
  return *this;
}

PyPtr& PyPtr::operator=(PyPtr&& move)
{
  _PyPtr::operator=(std::move(move));
  return *this;
}

PyPtr PyPtr::getAttr(const std::string& attribute)const
{
  PyObject* result = nullptr;
  PyObject* thisObj = get();
  if(nullptr == thisObj)
  {
    std::string message = "Cannot get attribute ";
    message += attribute;
    message += " on a NULL object.\n";
    throw AttributeException(message);
  }

  if(!PyObject_HasAttrString(thisObj, attribute.c_str()))
  {
    std::string message = "Attribute ";
    message += attribute;
    message += " does not exist.\n";
    throw AttributeException(message);
  }

  result = PyObject_GetAttrString(thisObj, attribute.c_str());
  return PyPtr(result);
}

void PyPtr::setAttr(const std::string& attribute, const PyPtr& value)const
{
  PyObject* thisObj = get();
  if(nullptr == thisObj)
  {
    std::string message = "Cannot set attribute ";
    message += attribute;
    message += " on a NULL object.\n";
    throw AttributeException(message);
  }

  if(0 > PyObject_SetAttrString(thisObj, attribute.c_str(), value.get()))
  {
    std::string message = "Failed to set attribute ";
    message += attribute;
    message += ".\n";
    message += getLastPyError();
    throw AttributeException(message);
  }
}

std::string PyPtr::repr()const
{
  std::string result;
  PyObject* thisObj = get();
  if(thisObj)
  {
    PyObject* pyResult = PyObject_Repr(thisObj);
    if(pyResult && PyUnicode_Check(pyResult))
    {
      const char* charstr = PyUnicode_AsUTF8(pyResult);
      if(charstr != nullptr)
        result = charstr;
    }
    Py_XDECREF(pyResult);
  }
  return result;
}

}
