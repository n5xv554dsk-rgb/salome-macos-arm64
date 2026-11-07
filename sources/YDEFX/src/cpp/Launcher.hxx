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
#ifndef YDEFX_LAUNCHER_H
#define YDEFX_LAUNCHER_H

#include "TMonoPyJob.hxx"
#include "TPyStudyJob.hxx"

namespace ydefx
{
class Job;
class Launcher
{
public:
  Launcher():_lastError(){}
  const std::string& lastError()const{return _lastError;}

  /*!
   * Create and submit a new job.
   * Return nullptr in case of failure. Check the error with lastError().
   */
  template <class ...Ts>
  Job* submitMonoPyJob(const PyStudyFunction& fnScript,
                       Sample<Ts...>& sample,
                       const JobParametersProxy& params);

  template <class ...Ts>
  Job* submitPyStudyJob(py2cpp::PyPtr& pyStudyObj,
                        const PyStudyFunction& fnScript,
                        Sample<Ts...>& sample,
                        const JobParametersProxy& params);

  /*!
   * Connect to an already created job.
   * Return nullptr in case of failure. Check the error with lastError().
   */
  template <class ...Ts>
  Job* connectJob(const std::string& jobDump, Sample<Ts...>& sample);

  template <class ...Ts>
  Job* submitMultiPyJob(const PyStudyFunction& fn,
                        Sample<Ts...>& sample,
                        const JobParametersProxy& params);

private:
  std::string _lastError;
};

////////////////////////////////////////////////////////////////////////////////
// Template implementations
////////////////////////////////////////////////////////////////////////////////

template <class ...Ts>
Job* Launcher::submitMonoPyJob(const PyStudyFunction& fnScript,
                    Sample<Ts...>& sample,
                    const JobParametersProxy& params)
{
  Job* result = nullptr;
  _lastError = "";
  try
  {
    result = new TMonoPyJob<Ts...>(fnScript, sample, params);
  }
  catch(std::exception& e)
  {
    if(result != nullptr)
      delete result;
    result = nullptr;
    _lastError = e.what();
    return result;
  }

  if(!result->lastError().empty())
  {
    _lastError  = result->lastError();
    delete result;
    result = nullptr;
    return result;
  }

  if(!result->launch())
  {
    _lastError  = result->lastError();
    delete result;
    result = nullptr;
  }
  return result;
}

template <class ...Ts>
Job* Launcher::submitPyStudyJob(py2cpp::PyPtr& pyStudyObj,
                                const PyStudyFunction& fnScript,
                                Sample<Ts...>& sample,
                                const JobParametersProxy& params)
{
  Job* result = nullptr;
  _lastError = "";
  try
  {
    result = new TPyStudyJob<Ts...>(pyStudyObj, fnScript, sample, params);
  }
  catch(std::exception& e)
  {
    if(result != nullptr)
      delete result;
    result = nullptr;
    _lastError = e.what();
    return result;
  }

  if(!result->lastError().empty())
  {
    _lastError = result->lastError();
    delete result;
    result = nullptr;
    return result;
  }

  if(!result->launch())
  {
    _lastError  = result->lastError();
    delete result;
    result = nullptr;
  }
  return result;
}

template <class ...Ts>
Job* Launcher::connectJob(const std::string& jobDump,
                      Sample<Ts...>& sample)
{
  Job* result = nullptr;
  _lastError = "";
  try
  {
    result = new TMonoPyJob<Ts...>(jobDump, sample);
  }
  catch(std::exception& e)
  {
    if(result != nullptr)
      delete result;
    result = nullptr;
    _lastError = e.what();
  }

  return result;
}

template <class ...Ts>
Job* Launcher::submitMultiPyJob(const PyStudyFunction& fn,
                      Sample<Ts...>& sample,
                      const JobParametersProxy& params)
{
  // TODO
  _lastError = "Not implemented!";
  return nullptr;
}

}
#endif // YDEFX_LAUNCHER_H
