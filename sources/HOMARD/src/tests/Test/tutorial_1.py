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
Test tutorial_1 associe au tutorial 1
"""
__revision__ = "V4.07"

#========================================================================
TEST_NAME = "tutorial_1"
DEBUG = False
N_ITER_TEST_FILE = 3
#========================================================================
import os
import sys
import platform
#
# ==================================
PATH_HOMARD = os.getenv("HOMARD_ROOT_DIR")
# Repertoire des scripts utilitaires
REP_PYTHON = os.path.join(PATH_HOMARD, "bin", "salome", "test", "HOMARD")
REP_PYTHON = os.path.normpath(REP_PYTHON)
sys.path.append(REP_PYTHON)
from test_util import get_dir
from test_util import test_results
from test_util import update_test_win
# ==================================
# Répertoires pour ce test
REP_DATA, DIRCASE = get_dir(PATH_HOMARD, TEST_NAME, DEBUG)
# ==================================
#
from salome.kernel import salome
salome.salome_init_without_session()
from salome.kernel import HOMARD
from salome.kernel import iparameters
IPAR = iparameters.IParameters(salome.myStudy.GetCommonParameters("Interface Applicative", 1))
IPAR.append("AP_MODULES_LIST", "Homard")
#
#
#========================= Debut de la fonction ==================================
#
def homard_exec(nom, ficmed, verbose=False):
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
    # Hypotheses
    # ==========
    if verbose :
      print(". Hypothèses")
    hypo_1 = HOMARD.CreateHypothesis('hypo_1')
    hypo_1.SetUnifRefinUnRef(1)
    #
    # Cas
    # ===
    if verbose :
      print(". Cas")
    le_cas = HOMARD.CreateCase('case_1', nom, ficmed)
    le_cas.SetDirName(DIRCASE)
    #
    # Itérations
    # ==========
    if verbose :
      option = 2
    else :
      option = 1
    if verbose :
      print(". Itérations")
    # Iteration "iter_1_1"
    iter_1_1 = le_cas.NextIteration('iter_1_1')
    iter_1_1.SetMeshName('MESH')
    iter_1_1.SetMeshFile(os.path.join(DIRCASE, "maill.01.med"))
    iter_1_1.AssociateHypo('hypo_1')
    erreur = iter_1_1.Compute(1, option)
    if erreur :
      break

    # Iteration "iter_1_2"
    iter_1_2 = iter_1_1.NextIteration('iter_1_2')
    iter_1_2.SetMeshName('MESH')
    iter_1_2.SetMeshFile(os.path.join(DIRCASE, "maill.01.med"))
    iter_1_2.AssociateHypo('hypo_1')
    erreur = iter_1_2.Compute(1, option)
    if erreur :
      break

    # Iteration "iter_1_3"
    iter_1_3 = iter_1_2.NextIteration('iter_1_3')
    iter_1_3.SetMeshName('MESH')
    iter_1_3.SetMeshFile(os.path.join(DIRCASE, "maill.03.med"))
    iter_1_3.AssociateHypo('hypo_1')
    erreur = iter_1_3.Compute(1, option)
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
  FICMED = os.path.join(REP_DATA, TEST_NAME+".00.med")
  try:
    ERREUR, MESSAGE = homard_exec("MAILL", FICMED, DEBUG)
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

  test_results(REP_DATA, TEST_NAME, DIRCASE, N_ITER_TEST_FILE, N_REP_TEST_FILE, DESTROY_DIR)
  #
  break
#
if ERREUR:
  raise Exception(MESSAGE)
#
#
if salome.sg.hasDesktop():
  salome.sg.updateObjBrowser()
  iparameters.getSession().restoreVisualState(1)

