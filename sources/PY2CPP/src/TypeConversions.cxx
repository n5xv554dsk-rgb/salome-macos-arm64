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
#include "TypeConversions.hxx"

namespace py2cpp
{
ConversionCheck fromPy(PyObject * po, int& result)
{
  ConversionCheck check;
  if(po && PyLong_Check(po))
    result = PyLong_AsLong(po);
  else
    check.addError("int", po);
  return check;
}

PyObject * toPy(int val)
{
  return PyLong_FromLong(val);
}

ConversionCheck fromPy(PyObject * po, unsigned int& result)
{
  ConversionCheck check;
  if(po && PyLong_Check(po))
    result = PyLong_AsUnsignedLong(po);
  else
    check.addError("int", po);
  return check;
}

PyObject * toPy(unsigned int val)
{
  return PyLong_FromUnsignedLong(val);
}

ConversionCheck fromPy(PyObject * po, bool& result)
{
  ConversionCheck check;
  if(po && PyBool_Check(po))
    result = (Py_True == po);
  else
    check.addError("bool", po);
  return check;
}

PyObject * toPy(bool val)
{
  return PyBool_FromLong(val);
}

ConversionCheck fromPy(PyObject * po, double& result)
{
  ConversionCheck check;
  if(po && PyFloat_Check(po))
    result = PyFloat_AsDouble(po);
  else if(po && PyLong_Check(po))
  {
    int v = PyLong_AsLong(po);
    result = v;
  }
  else 
    check.addError("double", po);
  return check;
}

PyObject * toPy(double val)
{
  return PyFloat_FromDouble(val);
}

ConversionCheck fromPy(PyObject * po, std::string& result)
{
  ConversionCheck check;
  if(po && PyUnicode_Check(po))
  {
    const char* charstr = PyUnicode_AsUTF8(po);
    if(charstr != nullptr)
      result = charstr;
    else
      result = "";
  }
  else
    check.addError("std::string", po);
  return check;
}

PyObject * toPy(const std::string& val)
{
  return PyUnicode_FromString(val.c_str());
}

PyObject * toPy(const char* val)
{
  return PyUnicode_FromString(val);
}

ConversionCheck fromPy( PyObject *po, PyObject *& result)
{
  result = po;
  Py_XINCREF(result);
  return ConversionCheck();
}

PyObject * toPy(PyObject * obj)
{
  Py_XINCREF(obj);
  return obj;
}

ConversionCheck fromPy( PyObject *po, PyPtr& result)
{
  Py_XINCREF(po);
  result.reset(po);
  return ConversionCheck();
}

PyObject * toPy(const PyPtr& obj)
{
  PyObject * result = obj.get();
  Py_XINCREF(result);
  return result;
}

template<>
PyPtr fromPy<PyPtr>( PyObject *po)
{
  return PyPtr(po);
}

}
