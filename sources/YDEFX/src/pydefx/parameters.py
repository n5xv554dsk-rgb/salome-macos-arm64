# -*- coding: utf-8 -*-
# Copyright (C) 2019-2026 EDF
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
#
# See http://www.salome-platform.org/ or email : webmaster.salome@opencascade.com
#
import tempfile
from . import salome_proxy
from . import configuration

class Parameters:
  def __init__(self, resource="localhost",
               nb_branches=None, salome_parameters=None):
    if salome_parameters is None :
      job_params = salome_proxy.createSalomeParameters()
      job_params.job_type = "yacs_file"
      job_params.resource_required.name = resource
      job_params.job_name = "idefix_job"
      job_params.wckey = configuration.defaultWckey(resource)
      job_params.work_directory = configuration.defaultWorkingDir(resource)
      if nb_branches is None:
        nb_branches = configuration.defaultNbBranches(resource)
      job_params.resource_required.nb_proc = nb_branches
      self.nb_branches = nb_branches
      self.salome_parameters = job_params
    else:
      if nb_branches is None:
        nb_branches = salome_parameters.resource_required.nb_proc
      self.nb_branches = nb_branches
      self.salome_parameters = salome_parameters

  def configureResource(self, resource):
    self.salome_parameters.resource_required.name = resource
    self.salome_parameters.work_directory = configuration.defaultWorkingDir(
                                                                       resource)
    nb_branches = configuration.defaultNbBranches(resource)
    self.salome_parameters.resource_required.nb_proc = nb_branches
    self.nb_branches = nb_branches
    self.salome_parameters.wckey = configuration.defaultWckey(resource)

  def createResultDirectory(self, result_base_dir):
    self.salome_parameters.result_directory = configuration.newResultDirectory(
                                                                result_base_dir)

  def createTmpResultDirectory(self):
    self.salome_parameters.result_directory = configuration.newResultDirectory(
                                                          tempfile.gettempdir())

  # Specific deep copy function is needed because the default one does not work
  # for swig objects, when we are in no salome session mode.
  def __deepcopy__(self, memo):
    cls = self.__class__
    newobj = cls.__new__(cls)
    newobj.nb_branches = self.nb_branches
    newobj.salome_parameters = salome_proxy.createSalomeParameters()
    newobj.salome_parameters.job_name = self.salome_parameters.job_name
    newobj.salome_parameters.job_type = self.salome_parameters.job_type
    newobj.salome_parameters.job_file = self.salome_parameters.job_file
    newobj.salome_parameters.pre_command = self.salome_parameters.pre_command
    newobj.salome_parameters.env_file = self.salome_parameters.env_file
    newobj.salome_parameters.in_files = list(self.salome_parameters.in_files)
    newobj.salome_parameters.out_files = list(self.salome_parameters.out_files)
    newobj.salome_parameters.work_directory = self.salome_parameters.work_directory
    newobj.salome_parameters.local_directory = self.salome_parameters.local_directory
    newobj.salome_parameters.result_directory = self.salome_parameters.result_directory
    newobj.salome_parameters.maximum_duration = self.salome_parameters.maximum_duration
    newobj.salome_parameters.queue = self.salome_parameters.queue
    newobj.salome_parameters.partition = self.salome_parameters.partition
    newobj.salome_parameters.exclusive = self.salome_parameters.exclusive
    newobj.salome_parameters.mem_per_cpu = self.salome_parameters.mem_per_cpu
    newobj.salome_parameters.wckey = self.salome_parameters.wckey
    newobj.salome_parameters.extra_params = self.salome_parameters.extra_params
    #newobj.salome_parameters.specific_parameters = self.salome_parameters.specific_parameters
    newobj.salome_parameters.resource_required.name = self.salome_parameters.resource_required.name
    newobj.salome_parameters.resource_required.hostname = self.salome_parameters.resource_required.hostname
    newobj.salome_parameters.resource_required.can_launch_batch_jobs = self.salome_parameters.resource_required.can_launch_batch_jobs
    newobj.salome_parameters.resource_required.can_run_containers = self.salome_parameters.resource_required.can_run_containers
    newobj.salome_parameters.resource_required.OS = self.salome_parameters.resource_required.OS
    newobj.salome_parameters.resource_required.nb_proc = self.salome_parameters.resource_required.nb_proc
    newobj.salome_parameters.resource_required.mem_mb = self.salome_parameters.resource_required.mem_mb
    newobj.salome_parameters.resource_required.cpu_clock = self.salome_parameters.resource_required.cpu_clock
    newobj.salome_parameters.resource_required.nb_node = self.salome_parameters.resource_required.nb_node
    newobj.salome_parameters.resource_required.nb_proc_per_node = self.salome_parameters.resource_required.nb_proc_per_node

    return newobj

  def dumpDict(self):
    """Create a dictionary with all the properties.
       Can be used for serialization with json."""
    newdict = {
      "nb_branches" : self.nb_branches,
      "salome_parameters" : {
          "job_name" : self.salome_parameters.job_name,
          "job_type" : self.salome_parameters.job_type,
          "job_file" : self.salome_parameters.job_file,
          "pre_command" : self.salome_parameters.pre_command,
          "env_file" : self.salome_parameters.env_file,
          "in_files" : list(self.salome_parameters.in_files),
          "out_files" : list(self.salome_parameters.out_files),
          "work_directory" : self.salome_parameters.work_directory,
          "local_directory" : self.salome_parameters.local_directory,
          "result_directory" : self.salome_parameters.result_directory,
          "maximum_duration" : self.salome_parameters.maximum_duration,
          "queue" : self.salome_parameters.queue,
          "partition" : self.salome_parameters.partition,
          "exclusive" : self.salome_parameters.exclusive,
          "mem_per_cpu" : self.salome_parameters.mem_per_cpu,
          "wckey" : self.salome_parameters.wckey,
          "extra_params" : self.salome_parameters.extra_params,
          #"specific_parameters" : str(self.salome_parameters.specific_parameters),
          "resource_required" : {
              "name" : self.salome_parameters.resource_required.name,
              "hostname" : self.salome_parameters.resource_required.hostname,
              "can_launch_batch_jobs" : self.salome_parameters.resource_required.can_launch_batch_jobs,
              "can_run_containers" : self.salome_parameters.resource_required.can_run_containers,
              "OS" : self.salome_parameters.resource_required.OS,
              "nb_proc" : self.salome_parameters.resource_required.nb_proc,
              "mem_mb" : self.salome_parameters.resource_required.mem_mb,
              "cpu_clock" : self.salome_parameters.resource_required.cpu_clock,
              "nb_node" : self.salome_parameters.resource_required.nb_node,
              "nb_proc_per_node" : self.salome_parameters.resource_required.nb_proc_per_node
          }
      }
    }
    return newdict

  def loadDict(self, dico):
    self.nb_branches = dico["nb_branches"]
    #self.salome_parameters = salome_proxy.createSalomeParameters()
    self.salome_parameters.job_name = dico["salome_parameters"]["job_name"]
    self.salome_parameters.job_type = dico["salome_parameters"]["job_type"]
    self.salome_parameters.job_file = dico["salome_parameters"]["job_file"]
    self.salome_parameters.pre_command = dico["salome_parameters"]["pre_command"]
    self.salome_parameters.env_file = dico["salome_parameters"]["env_file"]
    self.salome_parameters.in_files = dico["salome_parameters"]["in_files"]
    self.salome_parameters.out_files = dico["salome_parameters"]["out_files"]
    self.salome_parameters.work_directory = dico["salome_parameters"]["work_directory"]
    self.salome_parameters.local_directory = dico["salome_parameters"]["local_directory"]
    self.salome_parameters.result_directory = dico["salome_parameters"]["result_directory"]
    self.salome_parameters.maximum_duration = dico["salome_parameters"]["maximum_duration"]
    self.salome_parameters.queue = dico["salome_parameters"]["queue"]
    self.salome_parameters.partition = dico["salome_parameters"]["partition"]
    self.salome_parameters.exclusive = dico["salome_parameters"]["exclusive"]
    self.salome_parameters.mem_per_cpu = dico["salome_parameters"]["mem_per_cpu"]
    self.salome_parameters.wckey = dico["salome_parameters"]["wckey"]
    self.salome_parameters.extra_params = dico["salome_parameters"]["extra_params"]
    self.salome_parameters.resource_required.name = dico["salome_parameters"]["resource_required"]["name"]
    self.salome_parameters.resource_required.hostname = dico["salome_parameters"]["resource_required"]["hostname"]
    self.salome_parameters.resource_required.can_launch_batch_jobs = dico["salome_parameters"]["resource_required"]["can_launch_batch_jobs"]
    self.salome_parameters.resource_required.can_run_containers = dico["salome_parameters"]["resource_required"]["can_run_containers"]
    self.salome_parameters.resource_required.OS = dico["salome_parameters"]["resource_required"]["OS"]
    self.salome_parameters.resource_required.nb_proc = dico["salome_parameters"]["resource_required"]["nb_proc"]
    self.salome_parameters.resource_required.mem_mb = dico["salome_parameters"]["resource_required"]["mem_mb"]
    self.salome_parameters.resource_required.cpu_clock = dico["salome_parameters"]["resource_required"]["cpu_clock"]
    self.salome_parameters.resource_required.nb_node = dico["salome_parameters"]["resource_required"]["nb_node"]
    self.salome_parameters.resource_required.nb_proc_per_node = dico["salome_parameters"]["resource_required"]["nb_proc_per_node"]
