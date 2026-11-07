# Copyright (C) 2009-2026  EDF
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

try:
  from string import Template
except:
  from module_generator.compat import Template,set

pyCompo="""
import sys,traceback,os
sys.path=sys.path+[${python_path}]
import ${module}_ORB__POA
import calcium
import dsccalcium
from salome.kernel import SALOME
from salome.kernel import Engines
import pickle

try:
  import numpy
except:
  numpy=None

#COMPODEFS
${compodefs}
#ENDDEF

#DEFS
${servicesdef}
#ENDDEF

class ${component}(${module}_ORB__POA.${component}, ${inheritedclass} dsccalcium.PyDSCComponent):
  '''
     To be identified as a SALOME component this Python class
     must have the same name as the component, inherit omniorb
     class ${module}_ORB__POA.${component} and DSC class dsccalcium.PyDSCComponent
     that implements DSC API.
  '''
  def __init__ ( self, orb, poa, contID, containerName, instanceName, interfaceName ):
    dsccalcium.PyDSCComponent.__init__(self, orb, poa,contID,containerName,instanceName,interfaceName)
${callconstructor}

  def init_service(self,service):
${initservice}
    return False

${servicesimpl}
"""

pyCompoEXE="""#!/usr/bin/env python
"""+pyCompo+"""
  def destroy(self):
     self._orb.shutdown(0)

if __name__ == '__main__':
  from omniORB import CORBA
  print( sys.argv)
  orb = CORBA.ORB_init(sys.argv, CORBA.ORB_ID)
  poa = orb.resolve_initial_references("RootPOA")
  print( "ORB and POA initialized",orb,poa)
  sys.stdout.flush()
  sys.stderr.flush()

  container=orb.string_to_object(sys.argv[1])
  containerName=sys.argv[2]
  instanceName=sys.argv[3]

  compo=${component}(orb,poa,container,containerName, instanceName, "${component}")
  comp_o = compo._this()
  comp_iors = orb.object_to_string(comp_o)
  print( "ior ${component}",comp_iors)

  sys.stdout.flush()
  sys.stderr.flush()

  #activate the POA
  poaManager = poa._get_the_POAManager()
  poaManager.activate()

  orb.run()
  print( "fin du composant ${component} standalone")

"""

pyCompo=Template(pyCompo)
pyCompoEXE=Template(pyCompoEXE)

pyService="""
  def ${service}(self,${inparams}):
    self.beginService("${component}.${service}")
    component=self.proxy
    returns=None
    try:
${convertinparams}
#BODY
${body}
#ENDBODY
      sys.stdout.flush()
      self.endService("${component}.${service}")
${convertoutparams}
      return ${outparams}
    except:
      sys.stdout.flush()
      exc_typ,exc_val,exc_fr=sys.exc_info()
      l=traceback.format_exception(exc_typ,exc_val,exc_fr)
      raise SALOME.SALOME_Exception(SALOME.ExceptionStruct(SALOME.BAD_PARAM,"".join(l),"${component}.py",0)) """
pyService=Template(pyService)

pyinitService="""    if service == "${service}":
       #initialization CALCIUM ports IN
${instream}
       #initialization CALCIUM ports OUT
${outstream}
       return True """
pyinitService=Template(pyinitService)
pyinitCEXEService=pyinitService
pyinitEXEService=pyinitService

# CMakeLists.txt in src/<component> for a python component
# template parameters:
#   sources: source files, separated by spaces
cmake_src_compo_py="""
# scripts / static
SET(_bin_SCRIPTS
  ${sources}
)

# --- rules ---
SALOME_INSTALL_SCRIPTS("$${_bin_SCRIPTS}" $${SALOME_INSTALL_SCRIPT_PYTHON})
"""
cmake_src_compo_py=Template(cmake_src_compo_py)