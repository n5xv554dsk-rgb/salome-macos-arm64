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

asterCompo="""
import sys,traceback,os
import ${module}_ORB__POA
import calcium
import dsccalcium
from salome.kernel import SALOME
import linecache
import shutil

sys.path=sys.path+[${python_path}]
import aster
import Accas
import Cata.cata
from Execution.E_SUPERV import SUPERV

aster_dir="${aster_dir}"

try:
  import numpy
except:
  numpy=None

#DEFS
${servicesdef}
#ENDDEF

class ${component}(${module}_ORB__POA.${component},dsccalcium.PyDSCComponent,SUPERV):
  '''
     To be identified as a SALOME component this Python class
     must have the same name as the component, inherit omniorb
     class ${module}_ORB__POA.${component} and DSC class dsccalcium.PyDSCComponent
     that implements DSC API.
  '''
  def __init__ ( self, orb, poa, contID, containerName, instanceName, interfaceName ):
    dsccalcium.PyDSCComponent.__init__(self, orb, poa,contID,containerName,instanceName,interfaceName)
    self.argv=[${argv}]
    #modif pour aster 9.0
    if hasattr(self,"init_timer"):
      self.init_timer()
    #fin modif pour aster 9.0
    elements_file = ""
    if os.path.exists(os.path.join(aster_dir,"share", "aster", "elements")):
      elements_file = os.path.join(aster_dir,"elements")
    elif os.path.exists(os.path.join(aster_dir,"elements")):
      elements_file = os.path.join(aster_dir,"elements")
    else:
      elements_file = os.path.join(aster_dir,"catobj","elements")
    shutil.copyfile(elements_file,"elem.1")
    

  def init_service(self,service):
${initservice}
    return False

${servicesimpl}
"""
asterCompo=Template(asterCompo)

asterCEXECompo="""
# Par rapport a la version precedente
# Chaque service est complete par l'appel initial a Complement
# Cette methode rajoute a l'appel du premier service de l'instance un prefixe au fichier de commande
# Ce prefixe est fourni dans le fichier fort.99 via as_run et exeaster
# Le fichier est lu a la creation du module
# Interet: introduire DEBUT() dans ce prefixe pour ne plus avoir a s'en preoccuper (ex: boucle for each)
import sys,traceback,os
import string
import ${module}_ORB__POA
import calcium
import dsccalcium
from salome.kernel import SALOME
import linecache
${importesuperv}

try:
  import numpy
except:
  numpy=None

#DEFS
${servicesdef}
#ENDDEF

class ExecutionError(Exception):
  '''General exception during execution'''

class ${component}(${module}_ORB__POA.${component},dsccalcium.PyDSCComponent,SUPERV):
  '''
     To be identified as a SALOME component this Python class
     must have the same name as the component, inherit omniorb
     class ${module}_ORB__POA.${component} and DSC class dsccalcium.PyDSCComponent
     that implements DSC API.
  '''
  def __init__ ( self, orb, poa, contID, containerName, instanceName, interfaceName ):
    self.init=0
    if os.path.isfile('fort.99'):
      prefixFile = file("fort.99","r")
      self.prefixJdc = prefixFile.read()
      prefixFile.close()
    else:
      self.prefixJdc = ""
    dsccalcium.PyDSCComponent.__init__(self, orb, poa,contID,containerName,instanceName,interfaceName)

  def init_service(self,service):
${initservice}
    return False

  def insertPrefix(self,jdc):
    if not self.init:
      jdc = self.prefixJdc + jdc
    return jdc

  def insertPrePost(self,jdc,prepost):
    if prepost != "":
      exec(prepost)
      try:
        jdc = os.linesep + pre + os.linesep + jdc + os.linesep + post + os.linesep
      except NameError:
        pass
    return jdc
    
  def interpstring(self,text,args):
    try:
      self.jdc.g_context.update(args)
      CONTEXT.set_current_step(self.jdc)
      linecache.cache['<string>']=0,None,string.split(text,'\\n'),'<string>'
      exec(text in self.jdc.const_context,self.jdc.g_context)
      CONTEXT.unset_current_step()
    except EOFError:
      CONTEXT.unset_current_step()
    except:
      CONTEXT.unset_current_step()
      raise

${servicesimpl}
"""

asterEXECompo=asterCEXECompo+"""
  def destroy(self):
     self._orb.shutdown(0)
"""

asterCEXECompo=Template(asterCEXECompo)
asterEXECompo=Template(asterEXECompo)

asterService="""
  def ${service}(self,${inparams}):
    self.beginService("${component}.${service}")
    self.jdc=Cata.cata.JdC(procedure=jdc,cata=Cata.cata,nom="Salome",context_ini=${dvars})
    j=self.jdc
    #modif pour aster 9.0
    if hasattr(self,"init_timer"):
      j.timer = self.timer
    #fin modif pour aster 9.0

    # On compile le texte Python
    j.compile()

    #modif pour aster 9.0
    # On initialise les tops de mesure globale de temps d'execution du jdc
    if hasattr(self,"init_timer"):
       j.cpu_user=os.times()[0]
       j.cpu_syst=os.times()[1]
    #fin modif pour aster 9.0

    if not j.cr.estvide():
       msg="ERREUR DE COMPILATION DANS ACCAS - INTERRUPTION"
       self.MESSAGE(msg)
       print (">> JDC.py : DEBUT RAPPORT")
       print (j.cr)
       print (">> JDC.py : FIN RAPPORT")
       j.supprime()
       sys.stdout.flush()
       raise SALOME.SALOME_Exception(SALOME.ExceptionStruct(SALOME.BAD_PARAM,msg+'\\n'+str(j.cr),"${component}.py",0))

    #surcharge des arguments de la ligne de commande (defaut stocke dans le composant) par un eventuel port de nom argv
    try:
      self.argv=self.argv+argv.split()
    except:
      pass

    #initialisation des arguments de la ligne de commande (remplace la methode initexec de B_JDC.py)
    aster.argv(self.argv)
    aster.init(CONTEXT.debug)
    j.setmode(1)
    j.ini=1

    try:
      j.exec_compile()
    except:
      sys.stdout.flush()
      exc_typ,exc_val,exc_fr=sys.exc_info()
      l=traceback.format_exception(exc_typ,exc_val,exc_fr)
      raise SALOME.SALOME_Exception(SALOME.ExceptionStruct(SALOME.BAD_PARAM,"".join(l),"${component}.py",0))

    ier=0
    if not j.cr.estvide():
       msg="ERREUR A L'INTERPRETATION DANS ACCAS - INTERRUPTION"
       self.MESSAGE(msg)
       ier=1
       print (">> JDC.py : DEBUT RAPPORT")
       print (j.cr)
       print (">> JDC.py : FIN RAPPORT")
       sys.stdout.flush()
       raise SALOME.SALOME_Exception(SALOME.ExceptionStruct(SALOME.BAD_PARAM,msg+'\\n'+str(j.cr), "${component}.py",0))

    if j.par_lot == 'NON':
       print ("FIN EXECUTION")
       #err=calcium.cp_fin(self.proxy,calcium.CP_ARRET)
       #retour sans erreur (il faut pousser les variables de sortie)
       sys.stdout.flush()
       self.endService("${component}.${service}")
       return ${rvars}

    # Verification de la validite du jeu de commande
    cr=j.report()
    if not cr.estvide():
       msg="ERREUR A LA VERIFICATION SYNTAXIQUE - INTERRUPTION"
       self.MESSAGE(msg)
       print( ">> JDC.py : DEBUT RAPPORT")
       print( cr)
       print( ">> JDC.py : FIN RAPPORT")
       sys.stdout.flush()
       raise SALOME.SALOME_Exception(SALOME.ExceptionStruct(SALOME.BAD_PARAM,msg+'\\n'+str(cr),"${component}.py",0))

    j.set_par_lot("NON")
    try:
       j.BuildExec()
       ier=0
       if not j.cr.estvide():
          msg="ERREUR A L'EXECUTION - INTERRUPTION"
          self.MESSAGE(msg)
          ier=1
          print( ">> JDC.py : DEBUT RAPPORT")
          print( j.cr)
          print( ">> JDC.py : FIN RAPPORT")
          sys.stdout.flush()
          raise SALOME.SALOME_Exception(SALOME.ExceptionStruct(SALOME.BAD_PARAM,msg+'\\n'+str(j.cr),"${component}.py",0))
       else:
         #retour sans erreur (il faut pousser les variables de sortie)
         #err=calcium.cp_fin(self.proxy,calcium.CP_ARRET)
         sys.stdout.flush()
         self.endService("${component}.${service}")
         return ${rvars}
    except :
      self.MESSAGE("ERREUR INOPINEE - INTERRUPTION")
      sys.stdout.flush()
      exc_typ,exc_val,exc_fr=sys.exc_info()
      l=traceback.format_exception(exc_typ,exc_val,exc_fr)
      raise SALOME.SALOME_Exception(SALOME.ExceptionStruct(SALOME.BAD_PARAM,"".join(l),"${component}.py",0))
"""
asterService=Template(asterService)

asterCEXEService="""
  def ${service}(self,${inparams}):
    self.beginService("${component}.${service}")
    try:
      args=${dvars}
      if "jdc" not in args:
        fcomm=open("jdc",'r')
        jdc=fcomm.read()
        fcomm.close()
        #args["jdc"]=jdc
      prepost = '''${body}'''
      jdc = self.insertPrePost(jdc,prepost)
      jdc = self.insertPrefix(jdc)
      if not self.init:
        self.init=1
        fcomm=open("fort.1",'w')
        fcomm.write(jdc)
        fcomm.close()
        ier=self.main(args)
        if ier != 0:
          raise ExecutionError("Error in initial execution")
      else:
        self.interpstring(jdc,args)

      self.endService("${component}.${service}")
      j=self.jdc
      return ${rvars}
    except:
      exc_typ,exc_val,exc_fr=sys.exc_info()
      l=traceback.format_exception(exc_typ,exc_val,exc_fr)
      self.endService("${component}.${service}")
      sys.stdout.flush()
      sys.stderr.flush()
      raise SALOME.SALOME_Exception(SALOME.ExceptionStruct(SALOME.BAD_PARAM,"".join(l),"${component}.py",0))
"""
asterCEXEService=Template(asterCEXEService)
asterEXEService=asterCEXEService

comm="""
DEBUT(PAR_LOT='NON')
"""

make_etude="""P actions make_etude
P version NEW9
P nomjob salome
P ncpus 1
A memjeveux 4.000000
P mem_aster 100
A tpmax 60
P memjob 32768
P mpi_nbcpu 1
P mpi_nbnoeud 1
P tpsjob 1
P mode batch
P soumbtc oui
P consbtc oui
F conf ${config} D 0
F comm ${comm} D 1
${extras}
"""
make_etude=Template(make_etude)

make_etude_exe="""P actions make_etude
P version NEW9
P nomjob salome
P ncpus 1
A memjeveux 4.000000
P mem_aster 100
A tpmax 60
P memjob 32768
P mpi_nbcpu 1
P mpi_nbnoeud 1
P tpsjob 1
P mode batch
P soumbtc oui
P consbtc oui
F comm ${comm} D 1
"""
make_etude_exe=Template(make_etude_exe)

cexe="""#!/bin/sh

export SALOME_CONTAINERNAME=$$1

${compoexe}
"""
cexe=Template(cexe)

exeaster="""#!/bin/sh

export SALOME_CONTAINER=$$1
export SALOME_CONTAINERNAME=$$2
export SALOME_INSTANCE=$$3

${compoexe}
"""
exeaster=Template(exeaster)

container="""import sys,os
from omniORB import CORBA
from SALOME_ContainerPy import SALOME_ContainerPy_i

if __name__ == '__main__':

  print( sys.argv)
  orb = CORBA.ORB_init(sys.argv, CORBA.ORB_ID)
  poa = orb.resolve_initial_references("RootPOA")
  print( "ORB and POA initialized")
  containerName=os.getenv("SALOME_CONTAINERNAME")
  cpy_i = SALOME_ContainerPy_i(orb, poa, containerName)
  print( "SALOME_ContainerPy_i instance created ",cpy_i)
  cpy_o = cpy_i._this()
  print( "SALOME_ContainerPy_i instance activated ",cpy_o)
  sys.stdout.flush()
  sys.stderr.flush()

  #activate the POA
  poaManager = poa._get_the_POAManager()
  poaManager.activate()

  #Block for ever
  orb.run()
  print( "fin container aster")
  sys.stdout.flush()
  sys.stderr.flush()
"""

component="""import sys,os
from omniORB import CORBA
from ${component}_module import ${component}

if __name__ == '__main__':

  print( sys.argv)
  orb = CORBA.ORB_init(sys.argv, CORBA.ORB_ID)
  poa = orb.resolve_initial_references("RootPOA")
  print( "ORB and POA initialized",orb,poa)
  sys.stdout.flush()
  sys.stderr.flush()

  container=orb.string_to_object(os.getenv("SALOME_CONTAINER"))
  containerName=os.getenv("SALOME_CONTAINERNAME")
  instanceName=os.getenv("SALOME_INSTANCE")

  compo=${component}(orb,poa,container,containerName, instanceName, "${component}")
  comp_o = compo._this()
  comp_iors = orb.object_to_string(comp_o)
  print( "ior aster",comp_iors)

  sys.stdout.flush()
  sys.stderr.flush()

  #activate the POA
  poaManager = poa._get_the_POAManager()
  poaManager.activate()

  orb.run()
  print( "fin du composant aster standalone")

"""
component=Template(component)

# CMakeLists.txt in src/<component> for an aster component
# template parameters:
#   sources: source files, separated by spaces
#   module: module name
#   resources: files to be installed in resources directory
#   scripts: scripts to be installed
cmake_src_compo_aster="""
# scripts / static
SET(_bin_py
  ${sources}
)

SET(_res_files
  ${resources}
)

SET(_bin_scripts
  ${scripts}
)

# --- rules ---
INSTALL(FILES $${_res_files} DESTINATION $${SALOME_${module}_INSTALL_RES_DATA})
SALOME_INSTALL_SCRIPTS("$${_bin_scripts}" $${SALOME_INSTALL_SCRIPT_SCRIPTS})
SALOME_INSTALL_SCRIPTS("$${_bin_py}" $${SALOME_INSTALL_PYTHON})
"""
cmake_src_compo_aster=Template(cmake_src_compo_aster)

# CMakeLists.txt in src/<component> for an aster lib component
# template parameters:
#   sources: source files, separated by spaces
cmake_src_compo_aster_lib="""
# scripts / static
SET(_bin_SCRIPTS
  ${sources}
)

# --- rules ---
SALOME_INSTALL_SCRIPTS("$${_bin_SCRIPTS}" $${SALOME_INSTALL_PYTHON})
"""
cmake_src_compo_aster_lib=Template(cmake_src_compo_aster_lib)
