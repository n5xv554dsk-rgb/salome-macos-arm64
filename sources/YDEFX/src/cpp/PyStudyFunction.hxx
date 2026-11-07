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
#ifndef YDEFX_PYSTUDYFUNCTION_H
#define YDEFX_PYSTUDYFUNCTION_H
#include "StudyFunction.hxx"
#include "PyConversions.hxx"

namespace ydefx
{
class PyStudyFunction :  StudyFunction
{
public:
  PyStudyFunction();
  PyStudyFunction(const PyStudyFunction& copy);
  PyStudyFunction& operator=(const PyStudyFunction& copy);
  virtual ~PyStudyFunction();
  virtual void loadFile(const std::string& path);
  virtual void loadString(const std::string&);
  virtual void save(const std::string& path);
  virtual std::string content()const;
  virtual std::list<std::string> inputNames()const;
  virtual std::list<std::string> outputNames()const;
  virtual std::string errors()const;
  virtual bool isValid()const;
  virtual std::list<std::string> datafiles()const;
  py2cpp::PyPtr createEmptySample()const;
  friend PyObject * py2cpp::toPy(const PyStudyFunction& jp);
private:
  py2cpp::PyPtr _pyObject;
};
}
#endif // YDEFX_PYSTUDYFUNCTION_H
