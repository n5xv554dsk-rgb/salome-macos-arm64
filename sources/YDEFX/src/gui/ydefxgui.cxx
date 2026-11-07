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
#include <Python.h>
#include "ResourceWidget.hxx"
#include <QApplication>
#include <iostream>

int main(int argc, char *argv[])
{
  int ret = 0;
  QApplication app(argc,argv);
  Py_Initialize();
  {
    ydefx::JobParametersProxy jpp;
    jpp.createResultDirectory("/tmp");
    ydefx::ResourceWidget mygui(jpp);
    mygui.show();
    ret = app.exec();
    std::cout << "job_name:" << jpp.job_name() << std::endl;
    std::cout << "job_type:" << jpp.job_type() << std::endl;
    std::cout << "job_file:" << jpp.job_file() << std::endl;
    std::cout << "pre_command:" << jpp.pre_command() << std::endl;
    std::cout << "env_file:" << jpp.env_file() << std::endl;
    std::cout << "work_directory:" << jpp.work_directory() << std::endl;
    std::cout << "local_directory:" << jpp.local_directory() << std::endl;
    std::cout << "result_directory:" << jpp.result_directory() << std::endl;
    std::cout << "maximum_duration:" << jpp.maximum_duration() << std::endl;
    std::cout << "resource_name:" << jpp.resource_name() << std::endl;
    std::cout << "nb_proc:" << jpp.nb_proc() << std::endl;
    std::cout << "mem_mb:" << jpp.mem_mb() << std::endl;
    std::cout << "nb_node:" << jpp.nb_node() << std::endl;
    std::cout << "nb_proc_per_node:" << jpp.nb_proc_per_node() << std::endl;
    std::cout << "queue:" << jpp.queue() << std::endl;
    std::cout << "partition:" << jpp.partition() << std::endl;
    std::cout << "exclusive:" << jpp.exclusive() << std::endl;
    std::cout << "mem_per_cpu:" << jpp.mem_per_cpu() << std::endl;
    std::cout << "wckey:" << jpp.wckey() << std::endl;
    std::cout << "extra_params:" << jpp.extra_params() << std::endl;
    std::cout << "nb_branches:" << jpp.nb_branches() << std::endl;
    std::cout << "in_files: ";
    for(const std::string& it : jpp.in_files())
      std::cout << it << ", ";
    std::cout << std::endl;
  }
  Py_Finalize();
  return ret;
}
