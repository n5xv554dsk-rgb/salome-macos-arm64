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
#ifndef YDEFX_SAMPLEPYCONVERSIONS_HXX
#define YDEFX_SAMPLEPYCONVERSIONS_HXX

#include <py2cpp/py2cpp.hxx>
#include "Sample.hxx"
#include "Exceptions.hxx"

namespace ydefx
{
/*!
 * The goal of this class is to iterate over the types of a sample.
 * S : template type of the sample.
 *     For the highest level call, this is Sample<Ts...>.
 * Ts : list of types managed by this converter. This list is included in the
 *      list of sample types.
 */
template <class S, class... Ts>
class SamplePyConverter;

/*!
 * Convert input variables of a sample to a python dictionary.
 * All input variables should have the same size. No verification is done here.
 * The returned value is NULL in case of error.
 */
template <class ...Ts>
PyObject* inputToPy(const Sample<Ts...>& sample);

/*!
 * Fill the input values of the sample from a python dictionary.
 * The sample should already contain the names of the input values.
 * For each type in the sample, for each variable name of the iterated type,
 * fetch the values from the python dictionary and put them in the c++
 * container. The old input values of the sample are cleared.
 * The returned value contains the conversion errors if they exist.
 * Keys from the python dictionary that do not exist in the sample are ignored.
 */
template <class ...Ts>
py2cpp::ConversionCheck inputFromPy(PyObject* obj, Sample<Ts...>& sample);

/*!
 * Convert output variables of a sample to a python dictionary.
 * Some points could have unset output values. The python dictionary will have
 * None values for the unset points.
 * The size of the lists of values in the python dictionary will be the same for
 * every variable name. It will be sample.maxSize().
 * The returned value is NULL in case of error.
 */
template <class ...Ts>
PyObject* outputToPy(const Sample<Ts...>& sample);

/*!
 * Fill the output values of a sample from a python dictionary.
 * The sample should already contain the keys (variable names) of the output
 * values. The python dictionary may contain None values. A None value means the
 * value is not set.
 * Keys of the python dictionary which do not exist in the c++ sample are
 * ignored.
 */
template <class ...Ts>
py2cpp::ConversionCheck outputFromPy(PyObject* obj, Sample<Ts...>& sample);

/*!
 * Fill the error values of a sample from a python list of strings.
 * The python list may contain None values which are translated to empty
 * strings.
 */
template <class ...Ts>
py2cpp::ConversionCheck errorsFromPy(PyObject* obj, Sample<Ts...>& sample);

/*!
 * Fetch output values and errors from the python objet.
 * The c++ sample should already contain the names of variables when this
 * function is called.
 */
template <class ...Ts>
py2cpp::ConversionCheck fetchResults(PyObject* obj, Sample<Ts...>& sample);

////////////////////////////////////////////////////////////////////////////////
// Template implementations
////////////////////////////////////////////////////////////////////////////////

template <class S>
class SamplePyConverter<S>
{
public:
  bool inputToPy(const S& sample, PyObject* result){return true;}
  py2cpp::ConversionCheck inputFromPy(PyObject* obj, S& sample)
  { return py2cpp::ConversionCheck();}
  bool outputToPy(const S& sample, PyObject* result){return true;}
  py2cpp::ConversionCheck outputFromPy(PyObject* obj, S& sample)
  { return py2cpp::ConversionCheck();}
};

template <class S, class T, class... Ts>
class SamplePyConverter<S,T, Ts...> : public SamplePyConverter<S, Ts...>
{
public:
  /*! Add sample.inputs<T> to result.
   *  result should be a python dictionary.
   */
  bool inputToPy(const S& sample, PyObject* result)
  {
    bool ok = true;
    std::list<std::string> names = sample.OneTypeSample<T>::inputs().names();
    for(const std::string& name : names)
    {
      const std::vector<T>& values = sample.OneTypeSample<T>::inputs().get(name);
      py2cpp::PyPtr pyValue(py2cpp::toPy(values));
      ok = PyDict_SetItemString(result, name.c_str(), pyValue.get()) == 0;
      if(!ok)
        break;
    }
    if(ok)
      ok = SamplePyConverter<S, Ts...>::inputToPy(sample, result);
    return ok;
  }

  py2cpp::ConversionCheck inputFromPy(PyObject* obj, S& sample)
  {
    py2cpp::ConversionCheck check;
    std::list<std::string> names = sample.OneTypeSample<T>::inputs().names();
    for(const std::string& name : names)
    {
      PyObject* pyValues = PyDict_GetItemString(obj, name.c_str());
      if(!pyValues)
      {
        std::string error = "The key '";
        error += name;
        error += "' was not found in the python object.\n";
        check.addErrorMessage(error);
      }
      else if(PyList_Check(pyValues))
      {
        std::size_t size = PyList_Size(pyValues);
        std::size_t i=size;
        // We prefer to fill the values from highest index to 0 in order
        // to avoid the resize of the vector when the index grows.
        bool stop = (i == 0) || !check;
        while(!stop)
        {
          i--;
          T value;
          PyObject* pyVal = PyList_GetItem(pyValues, i);
          check.addError(py2cpp::fromPy(pyVal, value));
          if(check)
            sample.OneTypeSample<T>::inputs().set(name, i, value);
          stop = (i == 0) || !check;
        }
      }
      else
        check.addError("sample input list", obj);
    }
    if(check)
      check = SamplePyConverter<S, Ts...>::inputFromPy(obj, sample);
    return check;
  }

  bool outputToPy(const S& sample, PyObject* result)
  {
    bool ok = true;
    std::size_t maxsize = sample.maxSize();
    std::list<std::string> names = sample.OneTypeSample<T>::outputs().names();
    for(const std::string& name : names)
    {
      py2cpp::PyPtr newList( PyList_New(maxsize));
      if(newList == nullptr)
      {
        ok = false;
        break;
      }
      for(std::size_t i=0; i<maxsize; i++)
      {
        if(sample.OneTypeSample<T>::outputs().isSet(name, i))
        {
          const T& cppValue = sample.OneTypeSample<T>::outputs().get(name,i);
          PyObject * pyValue = py2cpp::toPy(cppValue);
          PyList_SetItem(newList.get(), i, pyValue);
        }
        else
        {
          Py_INCREF(Py_None);
          PyList_SetItem(newList.get(), i, Py_None);
        }
      }
      ok = PyDict_SetItemString(result, name.c_str(), newList.get()) == 0;
      if(!ok)
        break;
    }
    if(ok)
      ok = SamplePyConverter<S, Ts...>::outputToPy(sample, result);
    return ok;
  }

  py2cpp::ConversionCheck outputFromPy(PyObject* obj, S& sample)
  {
    py2cpp::ConversionCheck check;
    std::list<std::string> names = sample.OneTypeSample<T>::outputs().names();
    for(const std::string& name : names)
    {
      PyObject* pyValues = PyDict_GetItemString(obj, name.c_str());
      if(!pyValues)
      {
        std::string error = "The key '";
        error += name;
        error += "' was not found in the python object.\n";
        check.addErrorMessage(error);
      }
      else if(PyList_Check(pyValues))
      {
        std::size_t size = PyList_Size(pyValues);
        std::size_t i=size;
        // We prefer to fill the values from highest index to 0 in order
        // to avoid the resize of the vector when the index grows.
        bool stop = (i == 0) || !check;
        while(!stop)
        {
          i--;
          PyObject* pyVal = PyList_GetItem(pyValues, i);
          if(Py_None == pyVal)
          {
            sample.OneTypeSample<T>::outputs().unset(name, i);
          }
          else
          {
            T value;
            check.addError(py2cpp::fromPy(pyVal, value));
            if(check)
              sample.OneTypeSample<T>::outputs().set(name, i, value);
          }
          stop = (i == 0) || !check;
        }
      }
      else
        check.addError("sample input list", obj);
    }
    if(check)
      check = SamplePyConverter<S, Ts...>::outputFromPy(obj, sample);
    return check;
  }
};

template <class ...Ts>
PyObject* inputToPy(const Sample<Ts...>& sample)
{
  PyObject * result = PyDict_New();
  if(result)
  {
    SamplePyConverter<Sample<Ts...>, Ts...> converter;
    if(! converter.inputToPy(sample, result))
    {
      Py_XDECREF(result);
      result = nullptr;
    }
  }
  // TODO: errors
  return result;
}

template <class ...Ts>
py2cpp::ConversionCheck inputFromPy(PyObject* obj, Sample<Ts...>& sample)
{
  py2cpp::ConversionCheck check;
  if(PyDict_Check(obj))
  {
    sample.clearInputValues();
    SamplePyConverter<Sample<Ts...>, Ts...> converter;
    check.addError(converter.inputFromPy(obj,sample));
  }
  else
    check.addError("Sample input", obj);

  return check;
}

template <class ...Ts>
PyObject* outputToPy(const Sample<Ts...>& sample)
{
  PyObject * result = PyDict_New();
  if(result)
  {
    SamplePyConverter<Sample<Ts...>, Ts...> converter;
    if(! converter.outputToPy(sample, result))
    {
      Py_XDECREF(result);
      result = nullptr;
    }
  }
  return result;
}

template <class ...Ts>
py2cpp::ConversionCheck outputFromPy(PyObject* obj, Sample<Ts...>& sample)
{
  py2cpp::ConversionCheck check;
  if(PyDict_Check(obj))
  {
    sample.clearOutputValues();
    SamplePyConverter<Sample<Ts...>, Ts...> converter;
    check.addError(converter.outputFromPy(obj,sample));
  }
  else
    check.addError("Sample output", obj);
  return check;
}

template <class ...Ts>
py2cpp::ConversionCheck errorsFromPy(PyObject* obj, Sample<Ts...>& sample)
{
  py2cpp::ConversionCheck check;
  if(PyList_Check(obj))
  {
    sample.clearErrors();
    std::size_t size = PyList_Size(obj);
    sample.errors().resize(size);
    for(std::size_t i=0; i < size && check; i++)
    {
      PyObject* pyValue = PyList_GetItem(obj, i);
      // Py_None values are translated to empty strings in c++.
      std::string cppValue("");
      if(Py_None != pyValue)
        check.addError(py2cpp::fromPy(pyValue, cppValue));
      if(check)
        sample.errors()[i] = cppValue;
    }
  }
  else
    check.addError("Sample error", obj);
  return check;
}

template <class ...Ts>
py2cpp::ConversionCheck fetchResults(const py2cpp::PyPtr& obj, Sample<Ts...>& sample)
{
  py2cpp::ConversionCheck check;
  check.addError(outputFromPy(obj.getAttr("_output").get(), sample));
  check.addError(errorsFromPy(obj.getAttr("_messages").get(), sample));
  return check;
}

}
#endif //YDEFX_SAMPLEPYCONVERSIONS_HXX
