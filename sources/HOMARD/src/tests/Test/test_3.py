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
Test test_3
"""
__revision__ = "V4.06"

#========================================================================
TEST_NAME = "test_3"
DEBUG = False
N_ITER_TEST_FILE = 2
N_BOUCLE = 2
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
  # Creation of the discrete boundary
    boundary_3_1 = HOMARD.CreateBoundaryDi('courbes', 'COURBES', os.path.join(REP_DATA, TEST_NAME + '.fr.med'))
  #
  # Creation of the external cylinder
    boundary_3_2 = HOMARD.CreateBoundaryCylinder('cyl_ext', 50.0, 25., -25., 1., 0., 0., 100.)
  #
  # Creation of the internal cylinder
    boundary_3_3 = HOMARD.CreateBoundaryCylinder('cyl_int', 50.0, 25., -25., 1., 0., 0., 50.)
  #
  # Creation of the first sphere
    boundary_3_4 = HOMARD.CreateBoundarySphere('sphere_1', 50.0, 25., -25., 100.)
  #
  # Creation of the second sphere
    boundary_3_5 = HOMARD.CreateBoundarySphere('sphere_2', 450.0, 25., -25., 100.)
  #
  # Creation of the hypotheses
  # ==========================
  # Uniform refinement
    hyponame = "hypo_" + TEST_NAME
    print("-------- Creation of the hypothesis", hyponame)
    hypo_test_3 = HOMARD.CreateHypothesis(hyponame)
    hypo_test_3.SetUnifRefinUnRef(1)
    print(hyponame, " : zones utilisées :", hypo_test_3.GetZones())
    print(hyponame, " : champ utilisé :", hypo_test_3.GetFieldName())
    print(hyponame, " : composantes utilisées :", hypo_test_3.GetComps())
  #
    for num in range (N_BOUCLE+1) :
  #
      print("-------- num =", num, "--------")
  #
  # Creation of the case case_test_3
  # ===========================
      if ( num <= 1 ) :
        print("-------- Creation of the case", TEST_NAME)
        mesh_file = os.path.join(REP_DATA, TEST_NAME + '.00.med')
        case_test_3 = HOMARD.CreateCase(TEST_NAME, 'MOYEU', mesh_file)
        case_test_3.SetDirName(DIRCASE)
        case_test_3.AddBoundary('courbes')
        case_test_3.AddBoundaryGroup('cyl_ext', 'EXT')
        case_test_3.AddBoundaryGroup('cyl_int', 'INT')
        case_test_3.AddBoundaryGroup('sphere_1', 'END_1')
        case_test_3.AddBoundaryGroup('sphere_2', 'END_2')
  #
  # Creation of the iterations
  # ==========================
  # Creation of the iteration 1
      iter_name = "I_" + TEST_NAME + "_1"
      print("-------- Creation of the iteration", iter_name)
      iter_test_3_1 = case_test_3.NextIteration(iter_name)
      iter_test_3_1.SetMeshName('MOYEU_1')
      iter_test_3_1.SetMeshFile(os.path.join(DIRCASE, 'maill.01.med'))
      iter_test_3_1.AssociateHypo('hypo_test_3')
      error = iter_test_3_1.Compute(1, 1)
      if error :
        error = 10*num + 1
        break

  # Creation of the iteration 2
      iter_name = "I_" + TEST_NAME + "_2"
      print("-------- Creation of the iteration", iter_name)
      iter_test_3_2 = iter_test_3_1.NextIteration(iter_name)
      iter_test_3_2.SetMeshName('MOYEU_2')
      iter_test_3_2.SetMeshFile(os.path.join(DIRCASE, 'maill.02.med'))
      iter_test_3_2.AssociateHypo('hypo_test_3')
      error = iter_test_3_2.Compute(1, 1)
      if error :
        error = 10*num + 2
        break
  #
  # Creation of the schema YACS
  # ===========================
      scriptfile = os.path.join(PATH_HOMARD, "share", "doc", "salome", "gui", "HOMARD", "en", "_downloads", "yacs_script_test.py")
      scriptfile = os.path.normpath(scriptfile)
      dirname = DIRCASE
      yacsname = "YACS_" + TEST_NAME
      print("-------- Creation of the schema", yacsname)
      yacs_test_3 = case_test_3.CreateYACSSchema(yacsname, scriptfile, dirname, mesh_file)
      yacs_test_3.SetType(2)
      yacs_test_3.SetMaxIter(N_ITER_TEST_FILE)
      error = yacs_test_3.Write()
      if error :
        error = 10*num + 5
        break

  # Destructions
  # ============
  # Destruction of the schema, sauf a la fin
      if ( num < N_BOUCLE ) :
        print("-------- Destruction of the schema", yacs_test_3.GetName())
        error = yacs_test_3.Delete(1)
        if error :
          error = 10*num + 6
          break
  # After the first loop, the case is deleted, except the final mesh files
  # All the iterations are deleted
      if ( num == 0 ) :
        print("-------- Destruction of the case", case_test_3.GetName())
        error = case_test_3.Delete(0)
        if error :
          break
  # After the second loop, the iterations are deleted, with the final mesh files
      elif ( num == 1 ) :
  # Recursive destruction of the iterations
        print("-------- Recursive destruction of the iteration", iter_test_3_1.GetName())
        error = iter_test_3_1.Delete(1)
        if error :
          error = 10*num + 3
          break
  # Destruction and creation of the hypothese
        if ( num == 1 ) :
          print("-------- Destruction of the hypothese", hypo_test_3.GetName())
          error = hypo_test_3.Delete()
          if error :
            error = 10*num + 4
            break
          hyponame = "hypo_test_3"
          print("-------- Creation of the hypothesis", hyponame)
          hypo_test_3 = HOMARD.CreateHypothesis(hyponame)
          hypo_test_3.SetUnifRefinUnRef(1)
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
N_REP_TEST_FILE = N_ITER_TEST_FILE*N_BOUCLE
DESTROY_DIR = not DEBUG

if platform.system() == 'Windows':
  DESTROY_DIR = DEBUG
  N_REP_TEST_FILE = 6
  texte_sup= "Le maillage est conforme par boites." 
  update_test_win(DIRCASE,N_REP_TEST_FILE,N_ITER_TEST_FILE,texte_sup)

test_results(REP_DATA, TEST_NAME, DIRCASE, N_ITER_TEST_FILE, N_REP_TEST_FILE, DESTROY_DIR)
#
if salome.sg.hasDesktop():
  salome.sg.updateObjBrowser()
  iparameters.getSession().restoreVisualState(1)

