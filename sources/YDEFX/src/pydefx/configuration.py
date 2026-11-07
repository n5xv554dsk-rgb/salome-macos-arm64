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
from . import salome_proxy
from . import parameters
import tempfile
import pathlib
import os
import json

def defaultWorkingDir(resource):
  resManager = salome_proxy.getResourcesManager()
  resource_definition = resManager.GetResourceDefinition(resource)
  return resource_definition.working_directory

def defaultNbBranches(resource):
  """
  Return the number of cores available on a resource.
  """
  resManager = salome_proxy.getResourcesManager()
  resource_definition = resManager.GetResourceDefinition(resource)
  ret = resource_definition.nb_node * resource_definition.nb_proc_per_node
  if ret < 1:
    ret = 1
  return ret

def allCoresAvailable():
  """
  Return the total number of cores of all resources that can run containers.
  ( "canRunContainers" attribute set to true in CatalogResources.xml )
  """
  resManager = salome_proxy.getResourcesManager()
  params     = salome_proxy.createSalomeParameters()
  params.resource_required.can_run_containers = True
  resources  = resManager.GetFittingResources(params.resource_required)
  return sum([defaultNbBranches(res) for res in resources ])

def defaultBaseDirectory():
  """Return the default path to the root of any new result directory."""
  return str(pathlib.Path.home())

def newResultDirectory(basedir=None):
  """ A new directory is created and the path is returned."""
  if basedir is None :
    basedir = defaultBaseDirectory()
  return tempfile.mkdtemp(prefix='idefix',dir=basedir)

def defaultWckey(resource="localhost"):
  result = ""
  if resource != "localhost":
    result = "P12H8:SALOME"
  return result

def availableResources():
  """
  Return the list of resources defined in the current catalog that are able to
  launch jobs.
  Ydefx can launch the evaluations in a job on one of these resources.
  """
  resManager = salome_proxy.getResourcesManager()
  params     = salome_proxy.createSalomeParameters()
  params.resource_required.can_launch_batch_jobs = True
  # GetFittingResources returns a tuple if in no salome session mode.
  # Force to list for uniformity between the two modes.
  return list(resManager.GetFittingResources(params.resource_required))

def exportConfig(dicconfig, directory = None):
  """ Save the configuration to a directory.
      dicconfig is a dictionary which contains the parameters to be saved.
      If directory is None, the configuration is saved to the current directory.
      Return the path to the configuration file.
  """
  if directory is None:
    directory = os.getcwd()
  configpath = os.path.join(directory, "idefixconfig.json")
  with open(configpath, "w") as f:
    json.dump(dicconfig, f, indent=2)
  return configpath

def loadConfig(directory = None):
  """ Return the configuration dictionary from a directory.
      If the directory is None, use the current directory.
  """
  if directory is None:
    directory = os.getcwd()
  configpath = os.path.join(directory, "idefixconfig.json")
  if not pathlib.Path(configpath).is_file():
    configpath = os.path.join(directory, "..", "idefixconfig.json")
  if not pathlib.Path(configpath).is_file():
    message = "Configuration file not found in directory " + str(directory)
    raise FileNotFoundError(message)
  with open(configpath, "r") as f:
    config = json.load(f)
  return config

def loadJobConfig(directory = None):
  """ Return the salome job parameters loaded from a directory which contains
      a idefixconfig.json file.
      If the directory is None, use the current directory.
  """
  config = loadConfig(directory)
  params = parameters.Parameters()
  params.loadDict(config["params"])
  result = params.salome_parameters
  return result
