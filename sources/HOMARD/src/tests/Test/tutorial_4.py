# -*- coding: utf-8 -*-

# Copyright (C) 2011-2026  CEA, EDF
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

"""
Python script for HOMARD
Test tutorial_4 associe au tutorial 4
"""
__revision__ = "V5.07"

#========================================================================
TEST_NAME = "tutorial_4"
DEBUG = False
VERBOSE = False
N_ITER_TEST_FILE = 3
#========================================================================
import os
import sys
import platform
#
# ==================================
PATH_HOMARD = os.getenv('HOMARD_ROOT_DIR')
# Repertoire des scripts utilitaires
REP_PYTHON = os.path.join(PATH_HOMARD, "bin", "salome", "test", "HOMARD")
REP_PYTHON = os.path.normpath(REP_PYTHON)
sys.path.append(REP_PYTHON)
from test_util import get_dir
from test_util import test_results
from test_util import update_test_win
from test_util import test_tutorial4_results
# ==================================
# Répertoires pour ce test
REP_DATA, DIRCASE = get_dir(PATH_HOMARD, TEST_NAME, DEBUG)
# ==================================
#
from salome.kernel import salome
salome.salome_init_without_session()
from salome.kernel import HOMARD
#
from salome.kernel import iparameters
IPAR = iparameters.IParameters(salome.myStudy.GetCommonParameters("Interface Applicative", 1))
IPAR.append("AP_MODULES_LIST", "Homard")
#
#
#========================= Debut de la fonction ==================================
#
def homard_exec(nom, ficmed, xao_file, verbose=True):
  """
Python script for HOMARD
  """
  erreur = 0
  message = ""
#
  while not erreur :
    #
  #  HOMARD.UpdateStudy()
    #
    # Frontières
    # ==========
    if verbose :
      print(". Frontières")
    cao_name = "CAO_" + nom
    la_frontiere = HOMARD.CreateBoundaryCAO(cao_name, xao_file)
    #
    # Hypotheses
    # ==========
    if verbose :
      print(". Hypothèses")
    # Creation of the hypothesis hypo_0_1
    l_hypothese_0_1 = HOMARD.CreateHypothesis('hypo_4_0_1')
    l_hypothese_0_1.SetUnifRefinUnRef(1)
    l_hypothese_0_1.AddGroup('IN1')
    l_hypothese_0_1.AddGroup('IN2')
    l_hypothese_0_1.AddGroup('T1_INT_I')
    l_hypothese_0_1.AddGroup('T1_INT_O')
    l_hypothese_0_1.AddGroup('T2_INT')
    # Creation of the hypothesis hypo_1_2
    l_hypothese_1_2 = HOMARD.CreateHypothesis('hypo_4_1_2')
    l_hypothese_1_2.SetUnifRefinUnRef(1)
    l_hypothese_1_2.AddGroup('T1_EXT_I')
    l_hypothese_1_2.AddGroup('T1_EXT_O')
    l_hypothese_1_2.AddGroup('T2_EXT')
    # Creation of the hypothesis hypo_2_3
    l_hypothese_2_3 = HOMARD.CreateHypothesis('hypo_4_2_3')
    l_hypothese_2_3.SetUnifRefinUnRef(1)
    l_hypothese_2_3.AddGroup('INT_I')
    l_hypothese_2_3.AddGroup('INT_E')
    l_hypothese_2_3.AddGroup('IN1')
    l_hypothese_2_3.AddGroup('IN2')
    #
    # Cas
    # ===
    if verbose :
      print(". Cas")
    le_cas = HOMARD.CreateCase('case_'+nom, nom, ficmed)
    le_cas.SetDirName(DIRCASE)
    le_cas.AddBoundary(cao_name)
    #
    # Itérations
    # ==========
    if verbose :
      option = 2
    else :
      option = 1
    if verbose :
      print(". Itérations")
    # Iteration iter_4_1 : raffinement selon les faces internes
    iter_4_1 = le_cas.NextIteration('iter_4_1')
    iter_4_1.SetMeshName('PIQUAGE_1')
    iter_4_1.SetMeshFile(os.path.join(DIRCASE, "maill.01.med"))
    iter_4_1.AssociateHypo('hypo_4_0_1')
    erreur = iter_4_1.Compute(1, option)
    print ("erreur = %d" % erreur)
    if erreur :
      break
    # Iteration iter_4_2 : raffinement selon les faces externes
    iter_4_2 = iter_4_1.NextIteration('iter_4_2')
    iter_4_2.SetMeshName('PIQUAGE_2')
    iter_4_2.SetMeshFile(os.path.join(DIRCASE, "maill.02.med"))
    iter_4_2.AssociateHypo('hypo_4_1_2')
    erreur = iter_4_2.Compute(1, option)
    if erreur :
      break
    # Iteration iter_4_3 : second raffinement selon les faces externes
    iter_4_3 = iter_4_2.NextIteration('iter_4_3')
    iter_4_3.SetMeshName('PIQUAGE_3')
    iter_4_3.SetMeshFile(os.path.join(DIRCASE, "maill.03.med"))
    iter_4_3.AssociateHypo('hypo_4_2_3')
    erreur = iter_4_3.Compute(1, option)
    if erreur :
      break
  #
    break
  #
  if erreur :
    message += "Erreur au calcul de l'itération %d" % erreur
  #
  return erreur, message
#
#==========================  Fin de la fonction ==================================
#
ERREUR = 0
MESSAGE = ""
while not ERREUR :
  #
  # A. Exec of HOMARD-SALOME
  #
  HOMARD = salome.lcc.FindOrLoadComponent('FactoryServer', 'HOMARD')
  assert HOMARD is not None, "Impossible to load homard engine"
  HOMARD.SetLanguageShort("fr")
#
  FICMED = os.path.join(REP_DATA, "tutorial_4.00.med")
  XAO_FILE = os.path.join(REP_DATA, TEST_NAME+".xao")
  try:
    ERREUR, MESSAGE = homard_exec("PIQUAGE", FICMED, XAO_FILE, VERBOSE)
  except RuntimeError as eee:
    ERREUR = 2
    MESSAGE = str(eee.message)
  #
  if ERREUR :
    MESSAGE += "Pb in homard_exec"
    break
  #
  # B. Test of the results
  #
  N_REP_TEST_FILE = N_ITER_TEST_FILE
  DESTROY_DIR = not DEBUG
  
  if platform.system() == 'Windows':
    DESTROY_DIR = DEBUG
    texte_sup= "Le maillage est conforme par boites." 
    update_test_win(DIRCASE,N_REP_TEST_FILE,N_ITER_TEST_FILE,texte_sup)
    test_tutorial4_results(REP_DATA, TEST_NAME, DIRCASE, N_ITER_TEST_FILE, N_REP_TEST_FILE, DESTROY_DIR)
  else:
    test_results(REP_DATA, TEST_NAME, DIRCASE, N_ITER_TEST_FILE, N_REP_TEST_FILE, DESTROY_DIR)
  #
  break
#
if ERREUR:
  raise Exception(MESSAGE)
#

if salome.sg.hasDesktop():
  salome.sg.updateObjBrowser()
  iparameters.getSession().restoreVisualState(1)

