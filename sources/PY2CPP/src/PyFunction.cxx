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
#include "PyFunction.hxx"
namespace py2cpp
{
bool PyFunction::load(const std::string& module, const std::string& function)
{
  bool result = false;
  reset(nullptr);
  PyPtr moduleName(PyUnicode_FromString(module.c_str()));
  PyPtr moduleObj(PyImport_Import(moduleName.get()));
  if(moduleObj)
  {
    PyObject * newFunction = PyObject_GetAttrString(moduleObj.get(),
                                                    function.c_str());
    if(newFunction && PyCallable_Check(newFunction))
    {
      reset(newFunction);
      result = true;
    }
  }
  return result;
}

bool PyFunction::load(const PyPtr& obj, const std::string& function)
{
  return load(obj.get(), function);
}

bool PyFunction::load(PyObject* obj, const std::string& function)
{
  bool result = false;
  reset(nullptr);
  if(obj && PyObject_HasAttrString(obj, function.c_str()))
  {
    PyObject * fn = PyObject_GetAttrString(obj, function.c_str());
    if(fn && PyCallable_Check(fn))
    {
      reset(fn);
      result = true;
    }
    else
      Py_XDECREF(fn);
  }
  return result;
}

void PyFunction::loadExp(const std::string& module, const std::string& function)
{
  if(!load(module, function))
  {
    std::string errorMessage = "Failed to load function '";
    errorMessage += function;
    errorMessage += "' from module '";
    errorMessage += module;
    errorMessage += "'\n";
    throw ExecutionException(errorMessage+getLastPyError());
  }
}

void PyFunction::loadExp(const PyPtr& obj, const std::string& function)
{
  if(!load(obj, function))
  {
    std::string errorMessage = "Failed to load function '";
    errorMessage += function;
    errorMessage += "' from a python object.\n";
    throw ExecutionException(errorMessage+getLastPyError());
  }
}

void PyFunction::loadExp(PyObject* obj, const std::string& function)
{
  if(!load(obj, function))
  {
    std::string errorMessage = "Failed to load function '";
    errorMessage += function;
    errorMessage += "' from a python object.\n";
    throw ExecutionException(errorMessage+getLastPyError());
  }
}

}
