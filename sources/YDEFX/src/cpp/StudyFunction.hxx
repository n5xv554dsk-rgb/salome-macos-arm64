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
#ifndef YDEFX_STUDYFUNCTION_H
#define YDEFX_STUDYFUNCTION_H
#include <string>
#include <list>

namespace ydefx
{
class StudyFunction
{
public:
  virtual ~StudyFunction(){}
  virtual void loadFile(const std::string& path)=0;
  virtual void loadString(const std::string&)=0;
  virtual void save(const std::string& path)=0;
  virtual std::string content()const=0;
  virtual std::list<std::string> inputNames()const=0;
  virtual std::list<std::string> outputNames()const=0;
  virtual std::string errors()const=0;
  virtual std::list<std::string> datafiles()const=0;
  virtual bool isValid()const=0;
};
}
#endif // YDEFX_STUDYFUNCTION_H
