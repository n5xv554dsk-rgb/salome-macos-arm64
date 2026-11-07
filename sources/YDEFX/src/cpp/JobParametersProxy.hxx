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
#ifndef YDEFX_JOBPARAMETERSPROXY_H
#define YDEFX_JOBPARAMETERSPROXY_H
#include <string>
#include <list>
#include <map>
#include "PyConversions.hxx"

namespace ydefx
{
class JobParametersProxy
{
public:
  JobParametersProxy();
  JobParametersProxy(const JobParametersProxy& copy);
  JobParametersProxy& operator=(const JobParametersProxy& copy);
  ~JobParametersProxy();

  std::string job_name()const;
  void job_name(const std::string& v);

  std::string job_type()const;
  void job_type(const std::string& v);

  std::string job_file()const;
  void job_file(const std::string& v);

  std::string pre_command()const;
  void pre_command(const std::string& v);

  std::string env_file()const;
  void env_file(const std::string& v);

  std::list<std::string> in_files()const;
  void add_in_files(const std::list<std::string>& pathList);
  void remove_in_file(const std::string& path);
  void in_files(const std::list<std::string>& pathList);

  std::string work_directory()const;
  void work_directory(const std::string& v);

  std::string local_directory()const;
  void local_directory(const std::string& v);

  std::string result_directory()const;
  void result_directory(const std::string& v);

  std::string maximum_duration()const;
  void maximum_duration(const std::string& v);

  // ResourceParameters
  std::string resource_name()const;
  void resource_name(const std::string& name);

  int nb_proc()const;
  void nb_proc(int v);

  int mem_mb()const;
  void mem_mb(int v);

  int nb_node()const;
  void nb_node(int v);

  int nb_proc_per_node()const;
  void nb_proc_per_node(int v);

  std::string queue()const;
  void queue(const std::string& v);

  std::string partition()const;
  void partition(const std::string& v);

  bool exclusive()const;
  void exclusive(bool v);

  unsigned int mem_per_cpu()const;
  void mem_per_cpu(unsigned int v);

  std::string wckey()const;
  void wckey(const std::string& v);

  std::string extra_params()const;
  void extra_params(const std::string& v);

  unsigned int nb_branches()const;
  void nb_branches(unsigned int v);

  /*!
   * Set the resource and the default values associated with that resource:
   * work_directory, nb_branches, nb_proc and wckey.
   */
  void configureResource(const std::string& resourceName);
  //! create a new result directory as a subdirectory of the given path.
  void createResultDirectory(const std::string& basePath);
  //! create a new result directory in the system tmp
  void createTmpResultDirectory();

  friend PyObject * py2cpp::toPy(const JobParametersProxy& jp);
  static std::list<std::string> AvailableResources();

private:
  py2cpp::PyPtr _pyParameters;
private:
  std::string getAttrString(const std::string& attributeName)const;
  void setAttr(const std::string& attributeName, const std::string& value);
  int getResAttr(const std::string& attributeName)const;
  void setResAttr(const std::string& attributeName, int value);
};
}
#endif // YDEFX_JOBPARAMETERSPROXY_H
