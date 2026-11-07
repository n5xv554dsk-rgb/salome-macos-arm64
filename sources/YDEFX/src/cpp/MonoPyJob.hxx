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
#ifndef YDEFX_MONOPYJOB_HXX
#define YDEFX_MONOPYJOB_HXX
#include "Job.hxx"
#include <py2cpp/PyPtr.hxx>

namespace ydefx
{
class MonoPyJob : public Job
{
public:
  MonoPyJob();
  virtual ~MonoPyJob();
  virtual std::string state();
  virtual double progress();
  virtual std::string dump();
  virtual bool launch(); // return false when it fails
  virtual bool fetch()=0; // return false when it fails
  virtual const std::string& lastError();
  virtual bool wait(); // Wait for the end of the job. Return false when it fails.
  virtual void configureWaitDelay(int seconds);
  virtual bool cancel(); // cancel the job and return false when it fails.
protected:
  py2cpp::PyPtr _pyStudy;
  std::string _lastError;
  int _waitDelay;
};

}

#endif //YDEFX_MONOPYJOB_HXX
