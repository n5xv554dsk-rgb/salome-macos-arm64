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
Test tutorial_5 associe au tutorial 5
"""
__revision__ = "V4.07"

#========================================================================
TEST_NAME = "tutorial_5"
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
def homard_exec(nom, ficmed, nomfr, ficfrmed, verbose=False):
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
    # Frontiere
    # =========
    if verbose :
      print(". Frontière")
    # Creation of the discrete boundary Boun_5_1
    boun_5_1 = HOMARD.CreateBoundaryDi('Boun_5_1', nomfr, ficfrmed)
    #
    # Creation des zones
    # ==================
    if verbose :
      print(". Zones")
    # Creation of the disk with hole enveloppe
    enveloppe = HOMARD.CreateZoneDiskWithHole( 'enveloppe', 0., 0., 250., 193., 1 )
    # Creation of the rectangle quart_sup
    quart_sup = HOMARD.CreateZoneBox2D( 'quart_sup', 0., 250., 0., 250., 1 )
    #
    # Hypotheses
    # ==========
    if verbose :
      print(". Hypothèses")
    # Creation of the hypothesis hypo_5
    hypo_5 = HOMARD.CreateHypothesis('hypo_5')
    hypo_5.AddZone('enveloppe', 1)
    # Creation of the hypothesis hypo_5_bis
    hypo_5_bis = HOMARD.CreateHypothesis('hypo_5_bis')
    hypo_5_bis.AddZone('quart_sup', 1)
    #
    # Cas
    # ===
    if verbose :
      print(". Cas")
    le_cas = HOMARD.CreateCase('case_5', nom, ficmed)
    le_cas.SetDirName(DIRCASE)
    le_cas.SetConfType(1)
    le_cas.AddBoundary('Boun_5_1')
    #
    # Itérations
    # ==========
    if verbose :
      option = 2
    else :
      option = 1
    if verbose :
      print(". Itérations")
    #
    # Iteration "iter_5_1"
    # ====================
    iter_5_1 = le_cas.NextIteration('iter_5_1')
    iter_5_1.SetMeshName('COEUR_2D_01')
    iter_5_1.SetMeshFile(os.path.join(DIRCASE, "maill.01.med"))
    iter_5_1.AssociateHypo('hypo_5')
    erreur = iter_5_1.Compute(1, option)
    if erreur :
      break
    #
    # Iteration "iter_5_2"
    # ====================
    iter_5_2 = iter_5_1.NextIteration('iter_5_2')
    iter_5_2.SetMeshName('COEUR_2D_02')
    iter_5_2.SetMeshFile(os.path.join(DIRCASE, "maill.02.med"))
    iter_5_2.AssociateHypo('hypo_5_bis')
    erreur = iter_5_2.Compute(1, option)
    if erreur :
      break
  #
    break
  #
  if erreur :
    message += "Erreur au calcul de l'itération %d" % erreur
  #
  return erreur, message

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
  FICFRMED = os.path.join(REP_DATA, TEST_NAME+".fr.med")
  try:
    ERREUR, MESSAGE = homard_exec("COEUR_2D", FICMED, "MAIL_EXT", FICFRMED, DEBUG)
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
     texte_sup= "Le maillage est conforme." 
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

