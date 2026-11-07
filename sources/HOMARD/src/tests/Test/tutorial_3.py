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
Test tutorial_3 associe au tutorial 3
"""
__revision__ = "V4.07"

#========================================================================
TEST_NAME = "tutorial_3"
DEBUG = False
N_ITER_TEST_FILE = 2
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
    # Hypothese "hypo_0vers1"
    # =======================
    hypo_0vers1 = HOMARD.CreateHypothesis('hypo_0vers1')
    # Characterization of the field
    hypo_0vers1.SetField('SOLU_0__QIRE_ELEM_SIGM__________')
    hypo_0vers1.SetUseComp(0)
    hypo_0vers1.AddComp('ERREST          ')
    hypo_0vers1.SetRefinThr(3, 1.0)
    hypo_0vers1.SetTypeFieldInterp(2)
    hypo_0vers1.AddFieldInterp('SOLU_0__DEPL____________________')
    hypo_0vers1.AddFieldInterp('SOLU_0__ERRE_ELEM_SIGM__________')
    #
    # Hypothese "hypo_1vers2"
    # =======================
    hypo_1vers2 = HOMARD.CreateHypothesis('hypo_1vers2')
    # Characterization of the field
    hypo_1vers2.SetField('SOLU_1__QIRE_ELEM_SIGM__________')
    hypo_1vers2.SetUseComp(0)
    hypo_1vers2.AddComp('ERREST          ')
    hypo_1vers2.SetRefinThr(3, 1.5)
    hypo_1vers2.SetUnRefThr(3, 6.)
    hypo_1vers2.SetTypeFieldInterp(2)
    hypo_1vers2.AddFieldInterp('SOLU_1__DEPL____________________')
    hypo_1vers2.AddFieldInterp('SOLU_1__QIRE_ELEM_SIGM__________')
    #
    # Hypothese "hypo_1vers2_bis"
    # ===========================
    hypo_1vers2_bis = HOMARD.CreateHypothesis('hypo_1vers2_bis')
    # Characterization of the field
    hypo_1vers2_bis.SetField('SOLU_1__DEPL____________________')
    hypo_1vers2_bis.SetUseComp(1)
    hypo_1vers2_bis.AddComp('DX')
    hypo_1vers2_bis.AddComp('DY')
    hypo_1vers2_bis.AddComp('DZ')
    hypo_1vers2_bis.SetRefinThr(1, 0.0001)
    hypo_1vers2_bis.SetUnRefThr(1, 0.000001)
    hypo_1vers2_bis.SetTypeFieldInterp(0)
    #
    # Cas
    # ===
    if verbose :
      print(". Cas")
    le_cas = HOMARD.CreateCase('case_3', nom, ficmed)
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
    # Iteration "iter_3_1"
    # ====================
    iter_3_1 = le_cas.NextIteration('iter_3_1')
    iter_3_1.SetMeshName('H_1')
    iter_3_1.SetMeshFile(os.path.join(DIRCASE, "maill.01.med"))
    iter_3_1.SetFieldFile(os.path.join(REP_DATA, "tutorial_3.00.med"))
    iter_3_1.SetTimeStepRank( 1, 1)
    iter_3_1.AssociateHypo('hypo_0vers1')
    erreur = iter_3_1.Compute(1, option)
    if erreur :
      break
    #
    # Iteration "iter_3_2"
    # ====================
    iter_3_2 = iter_3_1.NextIteration('iter_3_2')
    iter_3_2.SetMeshName('H_2')
    iter_3_2.SetMeshFile(os.path.join(DIRCASE, "maill.02.med"))
    iter_3_2.SetFieldFile(os.path.join(REP_DATA, "tutorial_3.01.med"))
    iter_3_2.SetTimeStepRank(1, 1)
    iter_3_2.AssociateHypo('hypo_1vers2')
    erreur = iter_3_2.Compute(1, option)
    if erreur :
      break
    #
    # Iteration "iter_3_2_bis"
    # ========================
    iter_3_2_bis = iter_3_1.NextIteration('iter_3_2_bis')
    iter_3_2_bis.SetMeshName('H_2_bis')
    iter_3_2_bis.SetMeshFile(os.path.join(DIRCASE, "maill.02.bis.med"))
    iter_3_2_bis.SetFieldFile(os.path.join(REP_DATA, "tutorial_3.01.med"))
    iter_3_2_bis.SetTimeStepRank(1, 1)
    iter_3_2_bis.AssociateHypo('hypo_1vers2_bis')
    erreur = iter_3_2_bis.Compute(1, option)
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
    ERREUR, MESSAGE = homard_exec("G_0", FICMED, DEBUG)
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
  N_REP_TEST_FILE = 3
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
if salome.sg.hasDesktop():
  salome.sg.updateObjBrowser()
  iparameters.getSession().restoreVisualState(1)

