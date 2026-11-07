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
#ifndef PY2CPP_TYPECONVERSIONS_HXX
#define PY2CPP_TYPECONVERSIONS_HXX
#include "py2cppExports.hxx"
#include <Python.h>

#include <list>
#include <vector>
#include <map>
#include <string>
#include <tuple>
#include "PyPtr.hxx"
#include "Errors.hxx"

namespace py2cpp
{
/*!
 * toPy functions return a new python object built from a c++ object.
 * The conversion is always possible and it does not throw exceptions.
 */
PY2CPP_EXPORT PyObject * toPy(int);
PY2CPP_EXPORT PyObject * toPy(unsigned int);
PY2CPP_EXPORT PyObject * toPy(bool);
PY2CPP_EXPORT PyObject * toPy(double);
PY2CPP_EXPORT PyObject * toPy(const std::string&);
PY2CPP_EXPORT PyObject * toPy(const char*);
PY2CPP_EXPORT PyObject * toPy(PyObject *);
PY2CPP_EXPORT PyObject * toPy(const PyPtr&);
template <class T>
PY2CPP_EXPORT PyObject * toPy(const std::vector<T>& values);
template <class T>
PY2CPP_EXPORT PyObject * toPy(const std::list<T>& values);
template <class K, class V>
PY2CPP_EXPORT PyObject * toPy(const std::map<K, V>& values);
template<class ...Ts>
PY2CPP_EXPORT PyObject * toPy(const std::tuple<Ts...>& vars );

/*!
 * fromPy functions convert a python object to a c++ object.
 * If the convertion fails, the ConversionCheck object returned contains the
 * error message. No exception is thrown.
 */
PY2CPP_EXPORT ConversionCheck fromPy( PyObject *, int&);
PY2CPP_EXPORT ConversionCheck fromPy( PyObject *, unsigned int&);
PY2CPP_EXPORT ConversionCheck fromPy( PyObject *, bool&);
PY2CPP_EXPORT ConversionCheck fromPy( PyObject *, double&);
PY2CPP_EXPORT ConversionCheck fromPy( PyObject *, std::string&);
PY2CPP_EXPORT ConversionCheck fromPy( PyObject *, PyObject *&);
PY2CPP_EXPORT ConversionCheck fromPy( PyObject *, PyPtr&);
template<class ...Ts>
PY2CPP_EXPORT ConversionCheck fromPy(PyObject * obj, std::tuple<Ts&...>& vars);
template <class T>
PY2CPP_EXPORT ConversionCheck fromPy( PyObject *obj, std::vector<T>& result);
template <class T>
PY2CPP_EXPORT ConversionCheck fromPy( PyObject *obj, std::list<T>& result);
template <class K, class V>
PY2CPP_EXPORT ConversionCheck fromPy( PyObject *obj, std::map<K, V>& result);

/*! This templated version  of fromPy throws ConversionException if the
 * conversion fails.
 */
template<class T>
PY2CPP_EXPORT T fromPy( PyObject *po);

// These versions of fromPy and toPy use PyPtr instead of PyObject *
template<class T>
PY2CPP_EXPORT T fromPyPtr( const PyPtr& py);
template<class T>
PY2CPP_EXPORT ConversionCheck fromPyPtr( const PyPtr& py, T& var);
template<class T>
PY2CPP_EXPORT PyPtr toPyPtr(const T& v);
template<>
PY2CPP_EXPORT PyPtr fromPy<PyPtr>( PyObject *po);

////////////////////////////////////////////////////////////////////////////////
// Template implementations
////////////////////////////////////////////////////////////////////////////////

// std::tuple
template<std::size_t I = 0, class ...Ts>
inline typename std::enable_if<I == sizeof...(Ts), void>::type
addInPyTuple(PyObject * result, const std::tuple<Ts...>& vars )
{
}

template<std::size_t I = 0, class ...Ts>
inline typename std::enable_if<I < sizeof...(Ts), void>::type
addInPyTuple(PyObject * result, const std::tuple<Ts...>& vars )
{
  PyObject * obj = toPy(std::get<I>(vars));
  PyTuple_SetItem(result, I, obj);
  addInPyTuple<I+1, Ts... >(result, vars);
}

template<class ...Ts>
PyObject * toPy(const std::tuple<Ts...>& vars )
{
  PyObject * result = PyTuple_New(sizeof...(Ts));
  addInPyTuple<0, Ts... >(result, vars);
  return result;
}

// std containers
template <class T>
PyObject * toPy(const std::vector<T>& values)
{
  PyObject * result = PyList_New(values.size());
  for(std::size_t i = 0; i < values.size(); ++i)
    PyList_SetItem(result, i, toPy(values[i]));
  return result;
}

template <class T>
PyObject * toPy(const std::list<T>& values)
{
  PyObject * result = PyList_New(values.size());
  std::size_t i = 0;
  for(const T& it : values)
  {
    PyList_SetItem(result, i, toPy(it));
    ++i;
  }
  return result;
}

template <class K, class V>
PyObject * toPy(const std::map<K, V>& values)
{
  PyObject * result = PyDict_New();
  for(const auto& it: values)
  {
    PyPtr pyKey(toPy(it.first));
    PyPtr pyValue(toPy(it.second));
    PyDict_SetItem(result, pyKey.get(), pyValue.get());
  }
  return result;
}

template<std::size_t I = 0, class ...Ts>
inline typename std::enable_if<I == sizeof...(Ts), ConversionCheck>::type
getFromPyTuple(PyObject * tup, std::tuple<Ts&...>& vars )
{
  return ConversionCheck();
}

template<std::size_t I = 0, class ...Ts>
inline typename std::enable_if<I < sizeof...(Ts), ConversionCheck>::type
getFromPyTuple(PyObject * tup, std::tuple<Ts&...>& vars )
{
  ConversionCheck check;
  PyObject * obj = PyTuple_GetItem(tup, I);
  typedef typename std::tuple_element<I, std::tuple<Ts...> >::type T;
  check.addError(fromPy(obj, std::get<I>(vars)));
  if(check)
    check.addError(getFromPyTuple<I+1, Ts...>(tup, vars));
  return check;
}

template<class ...Ts>
ConversionCheck fromPy(PyObject * obj, std::tuple<Ts&...>& vars)
{
  ConversionCheck check;
  if(obj)
  {
    if(PyTuple_Check(obj) && 
      PyTuple_Size(obj) == std::tuple_size<std::tuple<Ts&...> >::value)
    {
      check.addError(getFromPyTuple<0, Ts...>(obj, vars));
    }
    else
      if(1 == std::tuple_size<std::tuple<Ts&...> >::value)
      {
        check.addError(fromPy(obj, std::get<0>(vars)));
      }
    if(!check)
      check.addError("std::tuple", obj);
  }
  else
    check.addError("std::tuple", obj);
  return check;
}

template <class T>
ConversionCheck fromPy( PyObject *obj, std::vector<T>& result)
{
  ConversionCheck check;
  if(PyList_Check(obj))
  {
    result.clear();
    std::size_t size = PyList_Size(obj);
    result.resize(size);
    for(std::size_t i=0; i < size && check; i++)
      check.addError(fromPy(PyList_GetItem(obj, i), result[i]));
    if(!check)
      check.addError("std::vector", obj);
  }
  else if(PyTuple_Check(obj))
  {
    result.clear();
    std::size_t size = PyTuple_Size(obj);
    result.resize(size);
    for(std::size_t i=0; i < size && check; i++)
      check.addError(fromPy(PyTuple_GetItem(obj, i), result[i]));
    if(!check)
      check.addError("std::vector", obj);
  }
  else
    check.addError("std::vector", obj);
  return check;
}

template <class T>
ConversionCheck fromPy( PyObject *obj, std::list<T>& result)
{
  ConversionCheck check;
  if(PyList_Check(obj))
  {
    result.clear();
    std::size_t size = PyList_Size(obj);
    result.resize(size); //result will have "size" default constructed elements.
    std::size_t i = 0;
    for(T& it : result)
    {
      check.addError(fromPy(PyList_GetItem(obj, i), it));
      if(!check)
      {
        check.addError("std::list", obj);
        break;
      }
      ++i;
    }
  }
  else if(PyTuple_Check(obj))
  {
    result.clear();
    std::size_t size = PyTuple_Size(obj);
    result.resize(size); //result will have "size" default constructed elements.
    std::size_t i = 0;
    for(T& it : result)
    {
      check.addError(fromPy(PyTuple_GetItem(obj, i), it));
      if(!check)
      {
        check.addError("std::list", obj);
        break;
      }
      ++i;
    }
  }
  else
    check.addError("std::list", obj);
  return check;
}

template <class K, class V>
ConversionCheck fromPy( PyObject *obj, std::map<K, V>& result)
{
  ConversionCheck check;
  if(PyDict_Check(obj))
  {
    result.clear();
    PyPtr pyKeys(PyDict_Keys(obj));
    std::size_t size = PyList_Size(pyKeys.get());
    for(std::size_t i =0; i < size && check; ++i)
    {
      PyObject * curKey = PyList_GetItem(pyKeys.get(), i);
      K key;
      V value;
      check.addError(fromPy(curKey, key));
      if(check)
        check.addError(fromPy(PyDict_GetItem(obj, curKey), value));
      if(check)
        result[key]=value;
      else
        check.addError("std::map", obj);
    }
  }
  else
    check.addError("std::map", obj);
  return check;
}

// PyPtr
template<class T>
T fromPyPtr( const PyPtr& py)
{
  T result;
  fromPy(py.get(), result);
  return result;
}

template<class T>
ConversionCheck fromPyPtr( const PyPtr& py, T& var)
{
  return fromPy(py.get(), var);
}

template<class T>
PyPtr toPyPtr(const T& v)
{
  return PyPtr(toPy(v));
}

template<class T>
T fromPy( PyObject *po)
{
  T result;
  ConversionCheck check;
  check = fromPy(po, result);
  if(!check)
    throw ConversionException(check.getMessage());
  return result;
}

}
#endif //PY2CPP_TYPECONVERSIONS_HXX
