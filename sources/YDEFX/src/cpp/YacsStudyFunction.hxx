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
#ifndef YDEFX_YACSSTUDYFUNCTION_H
#define YDEFX_YACSSTUDYFUNCTION_H
#include "StudyFunction.hxx"
namespace ydefx
{
//TODO not implemented!
class YacsStudyFunction :  StudyFunction
{
public:
  YacsStudyFunction();
  virtual ~YacsStudyFunction();
  virtual void loadFile(const std::string& path);
  virtual void loadString(const std::string&);
  virtual void save(const std::string& path);
  virtual const std::string& content()const;
  virtual const std::list<std::string>& inputNames()const;
  virtual const std::list<std::string>& outputNames()const;
  virtual const std::list<std::string>& errors()const;
private:
  std::string _content;
  std::list<std::string> _input;
  std::list<std::string> _output;
  std::list<std::string> _errors;
};
}
#endif // YDEFX_YACSSTUDYFUNCTION_H
