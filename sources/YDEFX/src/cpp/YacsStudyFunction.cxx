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
#include "YacsStudyFunction.hxx"
#include <fstream>
#include <sstream>
namespace ydefx
{
YacsStudyFunction::YacsStudyFunction()
: _content()
, _input()
, _output()
, _errors()
{
  _errors.push_back("Function \"_exec\" not found!");
}

YacsStudyFunction::~YacsStudyFunction(){}

void YacsStudyFunction::loadFile(const std::string& path)
{
  std::ifstream infile(path.c_str());
  std::stringstream buffer;
  buffer << infile.rdbuf();
  loadString(buffer.str());
}

void YacsStudyFunction::loadString(const std::string& value)
{
  _content = value;
  _input.clear();
  _output.clear();
  _errors.clear();
  // TODO: use YACS
}

void YacsStudyFunction::save(const std::string& path)
{
  std::ofstream outfile(path.c_str());
  outfile << _content;
}

const std::string& YacsStudyFunction::content()const
{
  return _content;
}

const std::list<std::string>& YacsStudyFunction::inputNames()const
{
  return _input;
}

const std::list<std::string>& YacsStudyFunction::outputNames()const
{
  return _output;
}

const std::list<std::string>& YacsStudyFunction::errors()const
{
  return _errors;
}

}
