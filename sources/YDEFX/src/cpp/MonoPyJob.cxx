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
#include "MonoPyJob.hxx"
#include <py2cpp/py2cpp.hxx>

namespace ydefx
{
MonoPyJob::MonoPyJob()
: _pyStudy()
, _lastError()
, _waitDelay(10)
{
  py2cpp::PyFunction objConstructor;
  objConstructor.loadExp("pydefx", "PyStudy");
  _pyStudy = objConstructor();
}

MonoPyJob::~MonoPyJob()
{
}

std::string MonoPyJob::state()
{
  std::string result;
  _lastError = "";
  try
  {
    py2cpp::PyFunction pyFn;
    pyFn.loadExp(_pyStudy, "getJobState");
    py2cpp::pyResult(result) = pyFn();
  }
  catch(std::exception& e)
  {
    _lastError = "An error occured while retrieving job's state.\n";
    _lastError += e.what();
  }
  return result;
}

double MonoPyJob::progress()
{
  double result;
  py2cpp::PyFunction pyFn;
  _lastError = "";
  try
  {
    pyFn.loadExp(_pyStudy, "getProgress");
    py2cpp::pyResult(result) = pyFn();
  }
  catch(std::exception& e)
  {
    _lastError = "An error occured while retrieving job's progress.\n";
    _lastError += e.what();
  }
  return result;
}

std::string MonoPyJob::dump()
{
  std::string result;
  _lastError = "";
  try
  {
    py2cpp::PyFunction pyFn;
    pyFn.loadExp(_pyStudy, "dump");
    py2cpp::pyResult(result) = pyFn();
  }
  catch(std::exception& e)
  {
    _lastError = "An error occured while dumping the job.\n";
    _lastError += e.what();
  }
  return result;
}

bool MonoPyJob::launch()
{
  _lastError = "";
  try
  {
    py2cpp::PyFunction pyFn;
    pyFn.loadExp(_pyStudy, "launch");
    pyFn();
  }
  catch(std::exception& e)
  {
    _lastError = "An error occured while launching the job.\n";
    _lastError += e.what();
  }
  return _lastError.empty();
}

const std::string& MonoPyJob::lastError()
{
  return _lastError;
}

bool MonoPyJob::wait()
{
  _lastError = "";
  try
  {
    py2cpp::PyFunction pyFn;
    pyFn.loadExp(_pyStudy, "wait");
    pyFn(_waitDelay);
  }
  catch(std::exception& e)
  {
    _lastError = "An error occured while waiting the end of the job.\n";
    _lastError += e.what();
  }
  return _lastError.empty();
}

void MonoPyJob::configureWaitDelay(int seconds)
{
  _waitDelay = seconds;
}

bool MonoPyJob::cancel()
{
  _lastError = "";
  try
  {
    py2cpp::PyFunction pyFn;
    pyFn.loadExp(_pyStudy, "cancel");
    pyFn();
  }
  catch(std::exception& e)
  {
    _lastError = "An error occured while canceling the job.\n";
    _lastError += e.what();
  }
  return _lastError.empty();
}

}
