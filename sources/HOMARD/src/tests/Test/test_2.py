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
Test test_2
"""
__revision__ = "V4.05"

#========================================================================
TEST_NAME = "test_2"
DEBUG = False
N_ITER_TEST_FILE = 3
#========================================================================
import os
import sys
import platform
from salome.kernel import HOMARD
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
  # Creation of the boundaries
  # ==========================
  # Creation of the discrete boundary boundary_1
    boundary_1 = HOMARD.CreateBoundaryDi('internal_boundary', 'plaque', os.path.join(REP_DATA, TEST_NAME + '.fr.med'))
  #
  # Creation of the hypotheses
  # ==========================
  # Creation of the hypothesis 1
    hyponame_1 = "hypo_" + TEST_NAME + "_1"
    print("-------- Creation of the hypothesis", hyponame_1)
    hypo_test_2_1 = HOMARD.CreateHypothesis(hyponame_1)
    hypo_test_2_1.SetUnifRefinUnRef(1)
    hypo_test_2_1.AddGroup('EG')
    hypo_test_2_1.AddGroup('BANDE')
    print(hyponame_1, " : zones utilisées :", hypo_test_2_1.GetZones())
    print(hyponame_1, " : champ utilisé :", hypo_test_2_1.GetFieldName())
    print(hyponame_1, " : composantes utilisées :", hypo_test_2_1.GetComps())
    if ( len (hypo_test_2_1.GetFieldName()) > 0 ) :
      print(".. caractéristiques de l'adaptation :", hypo_test_2_1.GetField())

  # Creation of the hypothesis 2
    hyponame_2 = "hypo_" + TEST_NAME + "_2"
    print("-------- Creation of the hypothesis", hyponame_2)
    hypo_test_2_2 = HOMARD.CreateHypothesis(hyponame_2)
    hypo_test_2_2.SetUnifRefinUnRef(1)
    hypo_test_2_2.AddGroup('M_D')
    print(hyponame_2, " : zones utilisées :", hypo_test_2_2.GetZones())
    print(hyponame_2, " : champ utilisé :", hypo_test_2_2.GetFieldName())
    print(hyponame_2, " : composantes utilisées :", hypo_test_2_2.GetComps())
    if ( len (hypo_test_2_2.GetFieldName()) > 0 ) :
      print(".. caractéristiques de l'adaptation :", hypo_test_2_2.GetField())
  #
  # Creation of the cases
  # =====================
    # Creation of the case
    mesh_file = os.path.join(REP_DATA, TEST_NAME + '.00.med')
    case_test_2 = HOMARD.CreateCase(TEST_NAME, 'PLAQUE_0', mesh_file)
    case_test_2.SetDirName(DIRCASE)
    case_test_2.AddBoundaryGroup('internal_boundary', '')
  #
  # Creation of the iterations
  # ==========================
  # Creation of the iteration 1
    iter_name = "I_" + TEST_NAME + "_1"
    iter_test_2_1 = case_test_2.NextIteration(iter_name)
    iter_test_2_1.SetMeshName('PLAQUE_1')
    iter_test_2_1.SetMeshFile(os.path.join(DIRCASE, 'maill.01.med'))
    iter_test_2_1.AssociateHypo(hyponame_1)
    error = iter_test_2_1.Compute(1, 1)
    if error :
      error = 1
      break

  # Creation of the iteration 2
    iter_name = "I_" + TEST_NAME + "_2"
    iter_test_2_2 = iter_test_2_1.NextIteration(iter_name)
    iter_test_2_2.SetMeshName('PLAQUE_2')
    iter_test_2_2.SetMeshFile(os.path.join(DIRCASE, 'maill.02.med'))
    iter_test_2_2.AssociateHypo(hyponame_1)
    error = iter_test_2_2.Compute(1, 1)
    if error :
      error = 2
      break

  # Creation of the iteration 3
    iter_name = "I_" + TEST_NAME + "_3"
    iter_test_2_3 = iter_test_2_2.NextIteration(iter_name)
    iter_test_2_3.SetMeshName('PLAQUE_3')
    iter_test_2_3.SetMeshFile(os.path.join(DIRCASE, 'maill.03.med'))
    iter_test_2_3.AssociateHypo(hyponame_2)
    error = iter_test_2_3.Compute(1, 1)
    if error :
      error = 3
      break
  #
  # Creation of the schema YACS
  # ===========================
    scriptfile = os.path.join(PATH_HOMARD, "share", "doc", "salome", "gui", "HOMARD", "en", "_downloads", "yacs_script_test.py")
    scriptfile = os.path.normpath(scriptfile)
    dirname = DIRCASE
    yacs_test_2 = case_test_2.CreateYACSSchema("YACS_test_2", scriptfile, dirname, mesh_file)
    yacs_test_2.SetMaxIter(N_ITER_TEST_FILE+1)
    yacs_test_2.SetType(1)
    filexml = os.path.join(DIRCASE, 'yacs_test_2.xml')
    error = yacs_test_2.WriteOnFile(filexml)
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

