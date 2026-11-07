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
#include "Errors.hxx"
#include <Python.h>

namespace py2cpp
{
std::string getLastPyError()
{
  std::string result="";
  if (PyErr_Occurred())
  {
    PyObject *ptype, *pvalue, *ptraceback;
    PyObject *pystr, *module_name, *pyth_module, *pyth_func;
    PyErr_Fetch(&ptype, &pvalue, &ptraceback);
    PyErr_NormalizeException(&ptype, &pvalue, &ptraceback);
    pystr = PyObject_Str(pvalue);
    const char* charstr = PyUnicode_AsUTF8(pystr);
    if(charstr != nullptr)
      result = std::string(charstr);
    result += "\n";
    Py_DECREF(pystr);
    
    /* See if we can get a full traceback */
    if(ptraceback)
    {
      module_name = PyUnicode_FromString("traceback");
      pyth_module = PyImport_Import(module_name);
      Py_DECREF(module_name);
      if (pyth_module)
      {
        pyth_func = PyObject_GetAttrString(pyth_module, "format_exception");
        if (pyth_func && PyCallable_Check(pyth_func))
        {
          PyObject *pyList;
          pyList = PyObject_CallFunctionObjArgs(pyth_func, ptype, pvalue, ptraceback, NULL);
          if(pyList)
          {
            int n = PyList_Size(pyList);
            for(int i=0; i<n; i++)
            {
              pystr = PyList_GetItem(pyList,i);
              const char* charstr = PyUnicode_AsUTF8(pystr);
              if(charstr != nullptr)
                result += charstr;
            }
            Py_DECREF(pyList);
          }
        }
        Py_XDECREF(pyth_func);
        Py_DECREF(pyth_module);
      }
    }
    Py_XDECREF(ptype);
    Py_XDECREF(pvalue);
    Py_XDECREF(ptraceback);
  }
  return result;
}

ConversionCheck::ConversionCheck()
: _message()
{
}

ConversionCheck::ConversionCheck(const std::string& error)
: _message(error)
{
}

ConversionCheck::~ConversionCheck()
{
}

ConversionCheck::operator bool()const
{
  return _message.size() == 0;
}

const std::string& ConversionCheck::getMessage()const
{
  return _message;
}

void ConversionCheck::addError(const std::string& expectedType, PyObject * obj)
{
  std::string newMessage;
  if(obj)
  {
    std::string pyRepr;
    PyObject* pyResult = PyObject_Repr(obj);
    if(pyResult && PyUnicode_Check(pyResult))
    {
      const char* charstr = PyUnicode_AsUTF8(pyResult);
      if(charstr != nullptr)
        pyRepr = charstr;
    }
    else
      pyRepr = "unknown representation";
    Py_XDECREF(pyResult);
    if(pyRepr.size() > 80)
    {
      pyRepr = pyRepr.substr(0, 76);
      pyRepr += "...";
    }
    const std::string beginMessage = "Cannot convert the python object ";
    const std::string midMessage = " to c++ type ";
    int messageSize = pyRepr.size() + beginMessage.size() + midMessage.size();
    newMessage = beginMessage;
    if(messageSize >= 80)
      newMessage += "\n";
    newMessage += "<";
    newMessage += pyRepr;
    newMessage += ">";
    if(messageSize > 80)
      newMessage += "\n";
    newMessage += " to c++ type ";
    newMessage += expectedType;
    newMessage += ".\n";
  }
  else
  {
    newMessage = "Cannont convert a NULL python object to c++ type ";
    newMessage += expectedType;
    newMessage += ".\n";
  }
  addErrorMessage(newMessage);
}

void ConversionCheck::addError(const ConversionCheck& err)
{
  _message += err.getMessage();
}

void ConversionCheck::addErrorMessage(const std::string& message)
{
  _message += message;
}

void ConversionCheck::reset()
{
  _message = "";
}

Exception::Exception(const std::string& message)
: std::exception()
, _message(message)
{
}

const char* Exception::what() const noexcept
{
  return _message.c_str();
}

ConversionException::ConversionException(const std::string& message)
: Exception(message)
{
}

ExecutionException::ExecutionException(const std::string& message)
: Exception(message)
{
}

AttributeException::AttributeException(const std::string& message)
: Exception(message)
{
}

}
