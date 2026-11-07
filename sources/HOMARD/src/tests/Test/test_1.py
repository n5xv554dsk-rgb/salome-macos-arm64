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
Test test_1
"""
__revision__ = "V4.05"

#========================================================================
TEST_NAME = "test_1"
DEBUG = False
N_ITER_TEST_FILE = 3
#========================================================================
import os
import sys

from salome.kernel import HOMARD
import platform
from salome.kernel import salome
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

salome.salome_init_without_session()
from salome.kernel import iparameters
IPAR = iparameters.IParameters(salome.myStudy.GetCommonParameters("Interface Applicative", 1))
IPAR.append("AP_MODULES_LIST", "Homard")
#
#========================================================================
#========================================================================
def homard_exec():
  """
Python script for HOMARD
  """
  error = 0
#
  while not error :
  #
  #  HOMARD.UpdateStudy()
  #
  # Creation of the zones
  # =====================
  # Creation of the box zone_1_1
    zone_1_1 = HOMARD.CreateZoneBox('Zone_1_1', -0.01, 1.01, -0.01, 0.4, -0.01, 0.6)

  # Creation of the sphere zone_1_2
    zone_1_2 = HOMARD.CreateZoneSphere('Zone_1_2', 0.5, 0.6, 0.7, 0.75)
  #
  # Creation of the hypotheses
  # ==========================
    dico = {}
    dico["1"] = "raffinement"
    dico["-1"] = "deraffinement"
  # Creation of the hypothesis a10_1pc_de_mailles_a_raffiner_sur_ERRE_ELEM_SIGM
    hyponame_1 = "a10_1pc_de_mailles_a_raffiner_sur_ERRE_ELEM_SIGM"
    print("-------- Creation of the hypothesis", hyponame_1)
    hypo_1_1 = HOMARD.CreateHypothesis(hyponame_1)
    hypo_1_1.SetField('RESU____ERRE_ELEM_SIGM__________')
    hypo_1_1.SetUseComp(0)
    hypo_1_1.AddComp('ERREST')
    hypo_1_1.SetRefinThr(3, 10.1)
    hypo_1_1.AddFieldInterp('RESU____DEPL____________________')
    hypo_1_1.AddFieldInterp('RESU____ERRE_ELEM_SIGM__________')
    print(hyponame_1, " : champ utilisé :", hypo_1_1.GetFieldName())
    print(hyponame_1, " : composantes utilisées :", hypo_1_1.GetComps())
    if ( len (hypo_1_1.GetFieldName()) > 0 ) :
      print(".. caractéristiques de l'adaptation :", hypo_1_1.GetField())
    print(hyponame_1, " : champs interpolés :", hypo_1_1.GetFieldInterps())
  # Creation of the hypothesis Zones_1_et_2
    hyponame_2 = "Zones_1_et_2"
    print("-------- Creation of the hypothesis", hyponame_2)
    zones_1_et_2 = HOMARD.CreateHypothesis(hyponame_2)
    zones_1_et_2.AddZone('Zone_1_1', 1)
    zones_1_et_2.AddZone('Zone_1_2', 1)
    laux = zones_1_et_2.GetZones()
    nbzone = len(laux) // 2
    iaux = 0
    for _ in range(nbzone) :
      print(hyponame_2, " : ", dico[laux[iaux+1]], "sur la zone", laux[iaux])
      iaux += 2
    print(hyponame_2, " : champ utilisé :", zones_1_et_2.GetFieldName())
    if ( len (zones_1_et_2.GetFieldName()) > 0 ) :
      print(".. caractéristiques de l'adaptation :", zones_1_et_2.GetField())
    print(hyponame_2, " : champs interpolés :", zones_1_et_2.GetFieldInterps())
  #
  # Creation of the cases
  # =====================
    # Creation of the case
    print("-------- Creation of the case", TEST_NAME)
    mesh_file = os.path.join(REP_DATA, TEST_NAME + '.00.med')
    case_test_1 = HOMARD.CreateCase(TEST_NAME, 'MAILL', mesh_file)
    case_test_1.SetDirName(DIRCASE)
  #
  # Creation of the iterations
  # ==========================
  # Creation of the iteration 1
    iter_name = "I_" + TEST_NAME + "_1"
    print("-------- Creation of the iteration", iter_name)
    iter_test_1_1 = case_test_1.NextIteration(iter_name)
    iter_test_1_1.AssociateHypo(hyponame_1)
    print(". Hypothese :", hyponame_1)
    iter_test_1_1.SetMeshName('M1')
    iter_test_1_1.SetMeshFile(os.path.join(DIRCASE, 'maill.01.med'))
    iter_test_1_1.SetFieldFile(os.path.join(REP_DATA, TEST_NAME + '.00.med'))
    iter_test_1_1.SetTimeStepRank(1, 1)
    iter_test_1_1.SetFieldInterpTimeStep('RESU____DEPL____________________', 1)
    iter_test_1_1.SetFieldInterpTimeStepRank('RESU____ERRE_ELEM_SIGM__________', 1, 1)
    print(". Instants d'interpolation :", iter_test_1_1.GetFieldInterpsTimeStepRank())
    error = iter_test_1_1.Compute(1, 1)
    if error :
      error = 1
      break

  # Creation of the iteration 2
    iter_name = "I_" + TEST_NAME + "_2"
    print("-------- Creation of the iteration", iter_name)
    iter_test_1_2 = iter_test_1_1.NextIteration(iter_name)
    iter_test_1_2.AssociateHypo(hyponame_1)
    print(". Hypothese :", hyponame_1)
    iter_test_1_2.SetMeshName('M2')
    iter_test_1_2.SetMeshFile(os.path.join(DIRCASE, 'maill.02.med'))
    iter_test_1_2.SetFieldFile(os.path.join(REP_DATA, TEST_NAME + '.01.med'))
    iter_test_1_2.SetTimeStepRank(1, 1)
    iter_test_1_2.SetFieldInterpTimeStep('RESU____DEPL____________________', 1)
    iter_test_1_2.SetFieldInterpTimeStepRank('RESU____ERRE_ELEM_SIGM__________', 1, 1)
    print(". Instants d'interpolation :", iter_test_1_2.GetFieldInterpsTimeStepRank())
    error = iter_test_1_2.Compute(1, 1)
    if error :
      error = 2
      break

  # Creation of the iteration 3
    iter_name = "I_" + TEST_NAME + "_3"
    print("-------- Creation of the iteration", iter_name)
    iter_test_1_3 = iter_test_1_2.NextIteration(iter_name)
    iter_test_1_3.AssociateHypo(hyponame_2)
    print(". Hypothese :", hyponame_2)
    iter_test_1_3.SetMeshName('M3')
    iter_test_1_3.SetMeshFile(os.path.join(DIRCASE, 'maill.03.med'))
    iter_test_1_2.SetFieldFile(os.path.join(REP_DATA, TEST_NAME + '.02.med'))
    print(". Instants d'interpolation :", iter_test_1_3.GetFieldInterpsTimeStepRank())
    error = iter_test_1_3.Compute(1, 1)
    if error :
      error = 3
      break
  #
  # Creation of the schema YACS
  # ===========================
  
    scriptfile = os.path.join(PATH_HOMARD, "share", "doc", "salome", "gui", "HOMARD", "en", "_downloads", "yacs_script_test.py")
    scriptfile = os.path.normpath(scriptfile)
    dirname = DIRCASE
    yacs_test_1 = case_test_1.CreateYACSSchema("YACS_test_1", scriptfile, dirname, mesh_file)
    yacs_test_1.SetMaxIter(N_ITER_TEST_FILE)
    error = yacs_test_1.Write()
    if error :
     error = 4
     break
  #
    break
  #
  return error

#========================================================================

HOMARD = salome.lcc.FindOrLoadComponent('FactoryServer', 'HOMARD')
assert HOMARD is not None, "Impossible to load homard engine"
HOMARD.SetLanguageShort("fr")
#
# Exec of HOMARD-SALOME
#
try :
  ERROR = homard_exec()
  if ERROR :
    raise Exception('Pb in homard_exec at iteration %d' %ERROR )
except RuntimeError as eee:
  raise Exception('Pb in homard_exec: '+str(eee.message))
#
# Test of the results
#
N_REP_TEST_FILE = N_ITER_TEST_FILE
DESTROY_DIR = not DEBUG

if platform.system() == 'Windows':
  DESTROY_DIR = DEBUG
  texte_sup= "Le maillage est conforme par boites." 
  update_test_win(DIRCASE,N_REP_TEST_FILE,N_ITER_TEST_FILE,texte_sup)

test_results(REP_DATA, TEST_NAME, DIRCASE, N_ITER_TEST_FILE, N_REP_TEST_FILE, DESTROY_DIR)
#
if salome.sg.hasDesktop():
  salome.sg.updateObjBrowser()
  iparameters.getSession().restoreVisualState(1)

