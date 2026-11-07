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
#include "JobParametersProxy.hxx"
#include "Exceptions.hxx"
#include <py2cpp/py2cpp.hxx>

PyObject * py2cpp::toPy(const ydefx::JobParametersProxy& jp)
{
  PyObject * result = jp._pyParameters.get();
  Py_IncRef(result);
  return result;
}

namespace ydefx
{

JobParametersProxy::JobParametersProxy()
:  _pyParameters(nullptr)
{
  py2cpp::AutoGIL gil;
  py2cpp::PyFunction objConstructor;
  objConstructor.loadExp("pydefx", "Parameters");
  _pyParameters = objConstructor();
}

JobParametersProxy::JobParametersProxy(const JobParametersProxy& copy)
:  _pyParameters(nullptr)
{
  if(copy._pyParameters)
  {
    py2cpp::AutoGIL gil;
    py2cpp::PyFunction deepCopyFn;
    deepCopyFn.loadExp("copy", "deepcopy");
    _pyParameters = deepCopyFn(copy._pyParameters);
  }
}

JobParametersProxy::~JobParametersProxy()
{
  py2cpp::AutoGIL gil;
  _pyParameters.reset(nullptr);
}

JobParametersProxy& JobParametersProxy::operator=(const JobParametersProxy& copy)
{
  if(this != &copy)
  {
    py2cpp::AutoGIL gil;
    if(copy._pyParameters)
    {
      py2cpp::PyFunction deepCopyFn;
      deepCopyFn.loadExp("copy", "deepcopy");
      _pyParameters = deepCopyFn(copy._pyParameters);
    }
    else
      _pyParameters.reset(nullptr);
  }
  return *this;
}

std::string
JobParametersProxy::getAttrString(const std::string& attributeName)const
{
  std::string result;
  py2cpp::AutoGIL gil;
  py2cpp::pyResult(result) = _pyParameters.getAttr("salome_parameters")
                                          .getAttr(attributeName);
  return result;
}

void
JobParametersProxy::setAttr(const std::string& attributeName,
                            const std::string& value)
{
  py2cpp::AutoGIL gil;
  _pyParameters.getAttr("salome_parameters")
               .setAttr(attributeName, py2cpp::toPyPtr(value));
}

int JobParametersProxy::getResAttr(const std::string& attributeName)const
{
  int result;
  py2cpp::AutoGIL gil;
  py2cpp::pyResult(result) = _pyParameters.getAttr("salome_parameters")
                                          .getAttr("resource_required")
                                          .getAttr(attributeName);
  return result;
}

void JobParametersProxy::setResAttr(const std::string& attributeName, int value)
{
  py2cpp::AutoGIL gil;
  _pyParameters.getAttr("salome_parameters")
               .getAttr("resource_required")
               .setAttr(attributeName, py2cpp::toPyPtr(value));
}

std::string JobParametersProxy::job_name()const
{
  return getAttrString("job_name");
}

void JobParametersProxy::job_name(const std::string& v)
{
  setAttr("job_name", v);
}

std::string JobParametersProxy::job_type()const
{
  return getAttrString("job_type");
}

void JobParametersProxy::job_type(const std::string& v)
{
  setAttr("job_type", v);
}

std::string JobParametersProxy::job_file()const
{
  return getAttrString("job_file");
}

void JobParametersProxy::job_file(const std::string& v)
{
  setAttr("job_file", v);
}

std::string JobParametersProxy::pre_command()const
{
  return getAttrString("pre_command");
}

void JobParametersProxy::pre_command(const std::string& v)
{
  setAttr("pre_command", v);
}

std::string JobParametersProxy::env_file()const
{
  return getAttrString("env_file");
}

void JobParametersProxy::env_file(const std::string& v)
{
  setAttr("env_file", v);
}

std::list<std::string> JobParametersProxy::in_files()const
{
  py2cpp::AutoGIL gil;
  std::list<std::string> result;
  py2cpp::pyResult(result) = _pyParameters.getAttr("salome_parameters")
                                          .getAttr("in_files");
  return result;
}

void JobParametersProxy::add_in_files(const std::list<std::string>& pathList)
{
  std::list<std::string> newList = in_files();
  newList.insert(newList.end(), pathList.begin(), pathList.end());
  in_files(newList);
}

void JobParametersProxy::remove_in_file(const std::string& path)
{
  std::list<std::string> newList = in_files();
  newList.remove(path);
  in_files(newList);
}

void JobParametersProxy::in_files(const std::list<std::string>& pathList)
{
  py2cpp::AutoGIL gil;
  _pyParameters.getAttr("salome_parameters")
               .setAttr("in_files", py2cpp::toPyPtr(pathList));
}

std::string JobParametersProxy::work_directory()const
{
  return getAttrString("work_directory");
}

void JobParametersProxy::work_directory(const std::string& v)
{
  setAttr("work_directory", v);
}

std::string JobParametersProxy::local_directory()const
{
  return getAttrString("local_directory");
}

void JobParametersProxy::local_directory(const std::string& v)
{
  setAttr("local_directory", v);
}

std::string JobParametersProxy::result_directory()const
{
  return getAttrString("result_directory");
}

void JobParametersProxy::result_directory(const std::string& v)
{
  setAttr("result_directory", v);
}

std::string JobParametersProxy::maximum_duration()const
{
  return getAttrString("maximum_duration");
}

void JobParametersProxy::maximum_duration(const std::string& v)
{
  setAttr("maximum_duration", v);
}

// ResourceParameters
std::string JobParametersProxy::resource_name()const
{
  py2cpp::AutoGIL gil;
  std::string result;
  py2cpp::pyResult(result) = _pyParameters.getAttr("salome_parameters")
                                          .getAttr("resource_required")
                                          .getAttr("name");
  return result;
}

void JobParametersProxy::resource_name(const std::string& name)
{
  py2cpp::AutoGIL gil;
  _pyParameters.getAttr("salome_parameters")
               .getAttr("resource_required")
               .setAttr("name", py2cpp::toPyPtr(name));
}

int JobParametersProxy::nb_proc()const
{
  return getResAttr("nb_proc");
}

void JobParametersProxy::nb_proc(int v)
{
  setResAttr("nb_proc", v);
}

int JobParametersProxy::mem_mb()const
{
  return getResAttr("mem_mb");
}

void JobParametersProxy::mem_mb(int v)
{
  setResAttr("mem_mb", v);
}

int JobParametersProxy::nb_node()const
{
  return getResAttr("nb_node");
}

void JobParametersProxy::nb_node(int v)
{
  setResAttr("nb_node", v);
}

int JobParametersProxy::nb_proc_per_node()const
{
  return getResAttr("nb_proc_per_node");
}

void JobParametersProxy::nb_proc_per_node(int v)
{
  setResAttr("nb_proc_per_node", v);
}

std::string JobParametersProxy::queue()const
{
  return getAttrString("queue");
}

void JobParametersProxy::queue(const std::string& v)
{
  setAttr("queue", v);
}

std::string JobParametersProxy::partition()const
{
  return getAttrString("partition");
}

void JobParametersProxy::partition(const std::string& v)
{
  setAttr("partition", v);
}

bool JobParametersProxy::exclusive()const
{
  py2cpp::AutoGIL gil;
  bool result;
  py2cpp::pyResult(result) = _pyParameters.getAttr("salome_parameters")
                                          .getAttr("exclusive");
  return result;
}

void JobParametersProxy::exclusive(bool v)
{
  py2cpp::AutoGIL gil;
  _pyParameters.getAttr("salome_parameters")
               .setAttr("exclusive", py2cpp::toPyPtr(v));
}

unsigned int JobParametersProxy::mem_per_cpu()const
{
  py2cpp::AutoGIL gil;
  int result;
  py2cpp::pyResult(result) = _pyParameters.getAttr("salome_parameters")
                                          .getAttr("mem_per_cpu");
  if(result < 0)
    result = 0;
  return result;
}

void JobParametersProxy::mem_per_cpu(unsigned int v)
{
  py2cpp::AutoGIL gil;
  _pyParameters.getAttr("salome_parameters")
               .setAttr("mem_per_cpu", py2cpp::toPyPtr(v));
}

std::string JobParametersProxy::wckey()const
{
  return getAttrString("wckey");
}

void JobParametersProxy::wckey(const std::string& v)
{
  setAttr("wckey", v);
}

std::string JobParametersProxy::extra_params()const
{
  return getAttrString("extra_params");
}

void JobParametersProxy::extra_params(const std::string& v)
{
  setAttr("extra_params", v);
}


unsigned int JobParametersProxy::nb_branches()const
{
  py2cpp::AutoGIL gil;
  unsigned int result;
  py2cpp::pyResult(result) = _pyParameters.getAttr("nb_branches");
  return result;
}

void JobParametersProxy::nb_branches(unsigned int v)
{
  py2cpp::AutoGIL gil;
  _pyParameters.setAttr("nb_branches", py2cpp::toPyPtr(v));
}

void JobParametersProxy::configureResource(const std::string& resourceName)
{
  py2cpp::AutoGIL gil;
  py2cpp::PyFunction pyFn;
  pyFn.loadExp(_pyParameters, "configureResource");
  pyFn(resourceName);
}

void JobParametersProxy::createResultDirectory(const std::string& basePath)
{
  py2cpp::AutoGIL gil;
  py2cpp::PyFunction pyFn;
  pyFn.loadExp(_pyParameters, "createResultDirectory");
  pyFn(basePath);
}

void JobParametersProxy::createTmpResultDirectory()
{
  py2cpp::AutoGIL gil;
  py2cpp::PyFunction pyFn;
  pyFn.loadExp(_pyParameters, "createTmpResultDirectory");
  pyFn();
}

std::list<std::string> JobParametersProxy::AvailableResources()
{
  py2cpp::AutoGIL gil;
  std::list<std::string> result;
  py2cpp::PyFunction pyFn;
  pyFn.loadExp("pydefx.configuration", "availableResources");
  py2cpp::pyResult(result) = pyFn();

  return result;
}

}
