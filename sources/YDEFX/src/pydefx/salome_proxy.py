from salome.kernel import salome
from salome.kernel import pylauncher
import os
from salome.kernel.SALOME_CMOD import SALOME_Exception
from .studyexception import StudyRunException

_use_salome_servers = None

def _default():
  global _use_salome_servers
  if _use_salome_servers is None:
    try:
      salome.salome_init()
      _use_salome_servers = True
    except RuntimeError:
      _use_salome_servers = False

def forceSalomeServers():
  global _use_salome_servers
  if not _use_salome_servers:
    salome.salome_init()
  _use_salome_servers = True

def forceNoSalomeServers():
  global _use_salome_servers
  _use_salome_servers = False

def createSalomeParameters():
  from salome.kernel.LifeCycleCORBA import JobParameters, ResourceParameters
  _default()
  if _use_salome_servers:
    result = JobParameters()
    result.resource_required = ResourceParameters()
  else:
    result = pylauncher.JobParameters_cpp()
  return result
  
_resourceManager = None
def getResourcesManager():
  global _resourceManager
  _default()
  if _resourceManager is None:
    if _use_salome_servers:
      _resourceManager = salome.lcc.getResourcesManager()
    else:
      catalog_path = os.environ.get("USER_CATALOG_RESOURCES_FILE", "")
      if not os.path.isfile(catalog_path):
        salome_path = os.environ.get("ROOT_SALOME_INSTALL", "")
        catalog_path = os.path.join(salome_path, "CatalogResources.xml")
      if not os.path.isfile(catalog_path):
        catalog_path = ""
      _resourceManager = pylauncher.ResourcesManager_cpp(catalog_path)
  return _resourceManager

def format_salome_exception(f):
  """
  Get a more readable format of SALOME_Exception.
  :param f: function that could raise SALOME_Exception.
  """
  def wrap_func(*args, **kwargs):
    try:
      return f(*args, **kwargs)
    except SALOME_Exception as ex:
      raise StudyRunException(ex.args[0].text)
  return wrap_func

class LauncherWrap:
  def __init__(self, launcher):
    self._launcher = launcher

  def __getattr__(self, name):
    attr = getattr(self._launcher, name)
    if callable(attr):
      return format_salome_exception(attr)
    else:
      return attr

_launcher = None
def getLauncher():
  global _launcher
  _default()
  if _launcher is None:
    if _use_salome_servers:
      _launcher = LauncherWrap(salome.naming_service.Resolve('/SalomeLauncher'))
    else:
      _launcher = pylauncher.Launcher_cpp()
      _launcher.SetResourcesManager(getResourcesManager())
  return _launcher
