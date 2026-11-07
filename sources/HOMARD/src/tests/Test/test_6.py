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
"""Python script for HOMARD - Test test_6"""
__revision__ = "V2.01"

import os
import sys
import platform

from salome.kernel import salome
import SHAPERSTUDY
from salome.kernel import SMESH
from salome.kernel import HOMARD

from salome.shaper import model
from salome.smesh import smeshBuilder

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

#========================================================================
TEST_NAME = "test_6"
DEBUG = False
VERBOSE = False
N_ITER_TEST_FILE = 3
TAILLE = 10.
LG_ARETE = TAILLE*2.5
# Répertoires pour ce test
REP_DATA, DIRCASE = get_dir(PATH_HOMARD, TEST_NAME, DEBUG)
#========================================================================

salome.salome_init_without_session()

#========================================================================
def create_cao_smesh ():
  """CAO and mesh"""

  structure_sh, xao_file = create_cao ()

  error, mesh_file = create_mesh (structure_sh)

  return error, xao_file, mesh_file
#========================================================================

#========================================================================
def create_cao ():
  """CAO"""

  if VERBOSE :
    texte = "Géométrie '{}'\n".format(TEST_NAME)
    texte += "Taille de base ={}".format(TAILLE)
    print (texte)

  model.begin()
  partset = model.moduleDocument()

  part_1 = model.addPart(partset)
  part_1_doc = part_1.document()

  ### Create Point
  _ = model.addPoint(part_1_doc,  0.*TAILLE,  0.*TAILLE, 0.*TAILLE)

  ### Create Point
  _ = model.addPoint(part_1_doc,  5.*TAILLE,  2.*TAILLE, 0.*TAILLE)

  ### Create Point
  _ = model.addPoint(part_1_doc, 10.*TAILLE,  1.*TAILLE, 0.*TAILLE)

  ### Create Point
  _ = model.addPoint(part_1_doc, 16.*TAILLE,  4.*TAILLE, 0.*TAILLE)

  ### Create Point
  _ = model.addPoint(part_1_doc, 16.*TAILLE, 10.*TAILLE, 0.*TAILLE)

  ### Create interpolation
  interpolation_1_objects = [model.selection("VERTEX", "all-in-Point_1"), \
                            model.selection("VERTEX", "all-in-Point_2"), \
                            model.selection("VERTEX", "all-in-Point_3"), \
                            model.selection("VERTEX", "all-in-Point_4"), \
                            model.selection("VERTEX", "all-in-Point_5")]
  _ = model.addInterpolation(part_1_doc, interpolation_1_objects, False, False)


  ### Create Point
  _ = model.addPoint(part_1_doc,  0.*TAILLE,  0.*TAILLE, 20.*TAILLE)

  ### Create Point
  _ = model.addPoint(part_1_doc,  6.*TAILLE, -5.*TAILLE, 20.*TAILLE)

  ### Create Point
  _ = model.addPoint(part_1_doc, 11.*TAILLE, -2.*TAILLE, 20.*TAILLE)

  ### Create Point
  _ = model.addPoint(part_1_doc, 12.*TAILLE,  3.*TAILLE, 20.*TAILLE)

  ### Create Point
  _ = model.addPoint(part_1_doc, 16.*TAILLE, 10.*TAILLE, 20.*TAILLE)

  ### Create interpolation
  interpolation_2_objects = [model.selection("VERTEX", "all-in-Point_6"), \
                            model.selection("VERTEX", "all-in-Point_7"), \
                            model.selection("VERTEX", "all-in-Point_8"), \
                            model.selection("VERTEX", "all-in-Point_9"), \
                            model.selection("VERTEX", "all-in-Point_10")]
  _ = model.addInterpolation(part_1_doc, interpolation_2_objects, False, False)

  ### Create Filling
  structure_sh = model.addFilling(part_1_doc, [model.selection("EDGE", "Interpolation_1_1"), model.selection("EDGE", "Interpolation_2_1")])
  structure_sh.setName(TEST_NAME)
  structure_sh.result().setName(TEST_NAME)

  ### Create Group
  group_1 = model.addGroup(part_1_doc, "Faces", [model.selection("FACE", TEST_NAME)])
  group_1.setName("Voile")
  group_1.result().setName("Voile")

  ### Create Group
  group_2 = model.addGroup(part_1_doc, "Edges", [model.selection("EDGE", "Interpolation_1_1")])
  group_2.setName("C_0")
  group_2.result().setName("C_0")

  ### Create Group
  group_3 = model.addGroup(part_1_doc, "Edges", [model.selection("EDGE", "Interpolation_2_1")])
  group_3.setName("C_1")
  group_3.result().setName("C_1")

  ### Create Group
  group_4 = model.addGroup(part_1_doc, "Edges", [model.selection("EDGE", TEST_NAME+"/Edge_0_1")])
  group_4.setName("D_0")
  group_4.result().setName("D_0")

  ### Create Group
  group_5 = model.addGroup(part_1_doc, "Edges", [model.selection("EDGE", TEST_NAME+"/Edge_0_3")])
  group_5.setName("D_1")
  group_5.result().setName("D_1")

  xao_file = os.path.join(DIRCASE, TEST_NAME+".xao")
  model.exportToXAO(part_1_doc, xao_file, model.selection("FACE", TEST_NAME), "GN", TEST_NAME)

  model.end()

  return structure_sh, xao_file
#========================================================================

#========================================================================
def create_mesh (structure_sh):
  """Mesh"""
  error = 0
  mesh_file = os.path.join(DIRCASE, 'maill.00.med')

  if VERBOSE :
    texte = "Maillage de '{}'\n".format(TEST_NAME)
    texte += "lg_arete = {}\n".format(LG_ARETE)
    print (texte)

  while not error :

# 1. Importation to the study
# ===========================
    model.publishToShaperStudy()
    l_aux = SHAPERSTUDY.shape(model.featureStringId(structure_sh))

# 2. Creation of the mesh
# =======================
    smesh = smeshBuilder.New()
    structure_m = smesh.Mesh(l_aux[0])

    MG_CADSurf = structure_m.Triangle(algo=smeshBuilder.MG_CADSurf)
    smesh.SetName(MG_CADSurf.GetAlgorithm(), 'MG_CADSurf')

    MG_CADSurf_Parameters = MG_CADSurf.Parameters()
    smesh.SetName(MG_CADSurf_Parameters, 'MG_CADSurf Triangles')
    MG_CADSurf_Parameters.SetPhySize( LG_ARETE )
    MG_CADSurf_Parameters.SetMinSize( LG_ARETE/20. )
    MG_CADSurf_Parameters.SetMaxSize( LG_ARETE*5. )
    MG_CADSurf_Parameters.SetChordalError( LG_ARETE )
    MG_CADSurf_Parameters.SetAngleMesh( 12. )

# Les groupes issus de la géométrie
    for groupe in l_aux[1:]:
      groupe_nom = groupe.GetName()
      if ( groupe_nom == "Voile" ):
        shape = SMESH.FACE
      else:
        shape = SMESH.EDGE
      _ = structure_m.GroupOnGeom(groupe,groupe_nom,shape)

# Computation
    isDone = structure_m.Compute()
    if not isDone :
      error = 1
      break

# MED exportation
    try:
      structure_m.ExportMED(mesh_file)
    except IOError as eee:
      error = 2
      raise Exception('ExportMED() failed. ' + str(eee))

    break

  return error, mesh_file
#========================================================================

#========================= Debut de la fonction ==================================

def homard_exec(xao_file, mesh_file):
  """Python script for HOMARD"""
  error = 0

  while not error :
    #
    #HOMARD.UpdateStudy()
    #
    # Frontière
    # =========
    if VERBOSE :
      print(". Frontière")
    cao_name = "CAO_" + TEST_NAME
    _ = HOMARD.CreateBoundaryCAO(cao_name, xao_file)
    #
    # Hypotheses
    # ==========
    if VERBOSE :
      print(". Hypothèses")
    hyponame = "hypo_" + TEST_NAME
    l_hypothese = HOMARD.CreateHypothesis(hyponame)
    l_hypothese.SetUnifRefinUnRef(1)
    #
    # Cas
    # ===
    if VERBOSE :
      print(". Cas")
    le_cas = HOMARD.CreateCase('case_'+TEST_NAME, TEST_NAME, mesh_file)
    le_cas.SetDirName(DIRCASE)
    le_cas.AddBoundary(cao_name)
    #
    # Creation of the iterations
    # ==========================
    if VERBOSE :
      option = 2
    else :
      option = 1
    #
    for niter in range(1, N_ITER_TEST_FILE+1):
      if VERBOSE :
        print(". Itération numéro %d" % niter)
      iter_name = "I_" + TEST_NAME + "_%02d" % niter
      if ( niter == 1 ) :
        l_iteration = le_cas.NextIteration(iter_name)
      else :
        l_iteration = l_iteration.NextIteration(iter_name)
      l_iteration.SetMeshName(TEST_NAME)
      mesh_file = os.path.join(DIRCASE, "maill.%02d.med" % niter)
      l_iteration.SetMeshFile(mesh_file)
      l_iteration.AssociateHypo(hyponame)
      error = l_iteration.Compute(1, option)
      if error :
        error = niter
        break
    #
    break

  return error
#
#==========================  Fin de la fonction ==================================

# CAO and Mesh

try :
  ERROR, XAO_FILE, MESH_FILE = create_cao_smesh()
  if ERROR :
    raise Exception('Pb in create_cao_smesh')
except RuntimeError as eee:
  raise Exception('Pb in create_cao_smesh: '+str(eee.message))

HOMARD = salome.lcc.FindOrLoadComponent('FactoryServer', 'HOMARD')
assert HOMARD is not None, "Impossible to load homard engine"
HOMARD.SetLanguageShort("fr")

# Exec of HOMARD-SALOME

try :
  ERROR = homard_exec(XAO_FILE, MESH_FILE)
  if ERROR :
    raise Exception('Pb in homard_exec at iteration %d' %ERROR )
except RuntimeError as eee:
  raise Exception('Pb in homard_exec: '+str(eee.message))

# Test of the results

N_REP_TEST_FILE = N_ITER_TEST_FILE
DESTROY_DIR = not DEBUG

if platform.system() == 'Windows':
  DESTROY_DIR = DEBUG
  texte_sup= "Le maillage est conforme par boites." 
  update_test_win(DIRCASE,N_REP_TEST_FILE,N_ITER_TEST_FILE,texte_sup)

test_results(REP_DATA, TEST_NAME, DIRCASE, N_ITER_TEST_FILE, N_REP_TEST_FILE, DESTROY_DIR)

if salome.sg.hasDesktop():
  salome.sg.updateObjBrowser()
