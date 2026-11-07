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
#include "PyStudyFunction.hxx"
#include <fstream>
#include <sstream>
#include <py2cpp/py2cpp.hxx>

PyObject * py2cpp::toPy(const ydefx::PyStudyFunction& studyFn)
{
  PyObject * result = studyFn._pyObject.get();
  Py_IncRef(result);
  return result;
}

namespace ydefx
{
PyStudyFunction::PyStudyFunction()
: _pyObject(nullptr)
{
  py2cpp::AutoGIL gil;
  py2cpp::PyFunction objConstructor;
  objConstructor.loadExp("pydefx", "PyScript");
  _pyObject = objConstructor();
}

PyStudyFunction::PyStudyFunction(const PyStudyFunction& copy)
: _pyObject(nullptr)
{
  if(copy._pyObject)
  {
    py2cpp::AutoGIL gil;
    py2cpp::PyFunction deepCopyFn;
    deepCopyFn.loadExp("copy", "deepcopy");
    _pyObject = deepCopyFn(copy._pyObject);
  }
}

PyStudyFunction::~PyStudyFunction()
{
  py2cpp::AutoGIL gil;
  _pyObject.reset(nullptr);
}

PyStudyFunction& PyStudyFunction::operator=(const PyStudyFunction& copy)
{
  if(this != &copy)
  {
    py2cpp::AutoGIL gil;
    if(copy._pyObject)
    {
      py2cpp::PyFunction deepCopyFn;
      deepCopyFn.loadExp("copy", "deepcopy");
      _pyObject = deepCopyFn(copy._pyObject);
    }
    else
      _pyObject.reset(nullptr);
  }
  return *this;
}

void PyStudyFunction::loadFile(const std::string& path)
{
  py2cpp::AutoGIL gil;
  py2cpp::PyFunction pyFn;
  pyFn.loadExp(_pyObject, "loadFile");
  pyFn(path);
}

void PyStudyFunction::loadString(const std::string& value)
{
  py2cpp::AutoGIL gil;
  py2cpp::PyFunction pyFn;
  pyFn.loadExp(_pyObject, "loadString");
  pyFn(value);
}

void PyStudyFunction::save(const std::string& path)
{
  py2cpp::AutoGIL gil;
  py2cpp::PyFunction pyFn;
  pyFn.loadExp(_pyObject, "saveFile");
  pyFn(path);
}

std::string PyStudyFunction::content()const
{
  std::string result;
  py2cpp::AutoGIL gil;
  py2cpp::PyFunction pyFn;
  pyFn.loadExp(_pyObject, "content");
  py2cpp::pyResult(result) = pyFn();
  return result;
}

std::list<std::string> PyStudyFunction::inputNames()const
{
  std::list<std::string> result;
  py2cpp::AutoGIL gil;
  py2cpp::PyFunction pyFn;
  pyFn.loadExp(_pyObject, "getInputNames");
  py2cpp::pyResult(result) = pyFn();
  return result;
}

std::list<std::string> PyStudyFunction::outputNames()const
{
  std::list<std::string> result;
  py2cpp::AutoGIL gil;
  py2cpp::PyFunction pyFn;
  pyFn.loadExp(_pyObject, "getOutputNames");
  py2cpp::pyResult(result) = pyFn();
  return result;
}

std::string PyStudyFunction::errors()const
{
  std::string result;
  py2cpp::AutoGIL gil;
  py2cpp::PyFunction pyFn;
  pyFn.loadExp(_pyObject, "getErrors");
  py2cpp::pyResult(result) = pyFn();
  return result;
}

bool PyStudyFunction::isValid()const
{
  std::string err = errors();
  return err.empty();
}

std::list<std::string> PyStudyFunction::datafiles()const
{
  return std::list<std::string>();
}

py2cpp::PyPtr PyStudyFunction::createEmptySample()const
{
  py2cpp::PyPtr sample;
  py2cpp::PyFunction fnCreateEmptySample;
  fnCreateEmptySample.loadExp(_pyObject, "CreateEmptySample");
  sample = fnCreateEmptySample();
  return sample;
}

}
