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
"""Python script for HOMARD - Test test_4"""
__revision__ = "V4.01"

import os
import sys
import numpy as np
import platform

from salome.kernel import salome
import SHAPERSTUDY
from salome.kernel import SMESH
from salome.kernel import HOMARD
import medcoupling as mc
import MEDLoader as ml

from salome.shaper import model
from salome.smesh import smeshBuilder
from MEDCouplingRemapper import MEDCouplingRemapper

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
TEST_NAME = "test_4"
DEBUG = False
N_ITER_TEST_FILE = 3
DX = 600.
DY = 400.
DZ = 200.
# Répertoires pour ce test
REP_DATA, DIRCASE = get_dir(PATH_HOMARD, TEST_NAME, DEBUG)
#========================================================================

salome.salome_init_without_session()

#========================================================================
def create_cao_smesh ():
  """CAO and mesh"""

  structure_sh = create_cao ()

  error, mesh_file = create_mesh (structure_sh)

  return error, mesh_file
#========================================================================

#========================================================================
def create_cao ():
  """CAO"""

  model.begin()
  partset = model.moduleDocument()

  part_1 = model.addPart(partset)
  part_1_doc = part_1.document()

  structure_sh = model.addBox(part_1_doc, DX, DY, DZ,)
  structure_sh.setName(TEST_NAME)
  structure_sh.result().setName(TEST_NAME)

  model.end()

  return structure_sh
#========================================================================

#========================================================================
def create_mesh (structure_sh):
  """Mesh"""
  error = 0
  mesh_file = os.path.join(DIRCASE, 'maill.00.med')
  while not error :

# 1. Importation to the study
# ===========================
    model.publishToShaperStudy()
    l_aux = SHAPERSTUDY.shape(model.featureStringId(structure_sh))

# 2. Creation of the mesh
# =======================
    smesh = smeshBuilder.New()
    structure_m = smesh.Mesh(l_aux[0])

# Creation of the hypotheses
    regular_1d = structure_m.Segment()
    smesh.SetName(regular_1d.GetAlgorithm(), 'Regular_1D')
    length = min(DX, DY, DZ) / 5.
    local_length = regular_1d.LocalLength(length, None, 1e-07)
    smesh.SetName(local_length, 'Local Length')

    quadrangle_2d = structure_m.Quadrangle(algo=smeshBuilder.QUADRANGLE)
    smesh.SetName(quadrangle_2d.GetAlgorithm(), 'Quadrangle_2D')

    hexa_3d = structure_m.Hexahedron(algo=smeshBuilder.Hexa)
    smesh.SetName(hexa_3d.GetAlgorithm(), 'Hexa_3D')

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

#========================================================================
def field_exec(niter):
  """Python script for MEDCoupling"""
  error = 0

  while not error :

# 1. The mesh
# ===========
    ficmed = os.path.join(DIRCASE, 'maill.%02d.med' % niter)
    meshMEDFileRead = ml.MEDFileMesh.New(ficmed)
    meshRead0 = meshMEDFileRead.getMeshAtLevel(0)
# 2. Values of the field
# ======================
    nbNodes = meshRead0.getNumberOfNodes()
    valeur = mc.DataArrayDouble(nbNodes)
    for iaux, taux in enumerate(meshRead0.getCoords()) :
      #ligne   = "x = %f" % taux[0]
      #ligne  += ", y = %f" % taux[1]
      #ligne  += ", z = %f" % taux[2]
      #print ligne
      #distance = (taux[0]-DX*0.2)**2 + (taux[1]-DY*0.2)**2 + (taux[2]-DZ*0.4)**2
      distance = min(abs(taux[0]-DX*0.4), abs(taux[1]-DY*0.2), abs(taux[2]-DZ*0.4))
      valeur[iaux] = 1.e0 / max ( 1.e-5, np.sqrt(distance) )
    #print ". valeur", valeur
    nparr = valeur.toNumPyArray()
    print(". mini/maxi {}/{}".format(nparr.min(),nparr.max()))

# 3. Creation of the field
# ========================
    field = ml.MEDCouplingFieldDouble(ml.ON_NODES, ml.ONE_TIME)
    field.setArray(valeur)
    field.setMesh(meshRead0)
    field.setName("DISTANCE")

    fMEDFile_ch = ml.MEDFileField1TS()
    fMEDFile_ch.setFieldNoProfileSBT(field)     # No profile desired on the field, Sort By Type
    fMEDFile_ch.write(ficmed, 0) # 0 to indicate that we *append* (and no overwrite) to the MED file

    break

  return error

#========================================================================

#========================================================================
def homard_exec(mesh_file):
  """Python script for HOMARD"""
  error = 0

  while not error :

# 1. Creation of the zones
# ========================
# Creation of the box zone_4_1
    epsilon = min(DX, DY, DZ) / 100.
    _ = HOMARD.CreateZoneBox('Zone_4_1', -epsilon, DX/3.+epsilon, DY/4.-epsilon, 3.*DY/4.+epsilon, 4.*DZ/5.-epsilon, DZ+epsilon)

# Creation of the sphere zone_4_2
    rayon = min(DX, DY, DZ) / 4.
    _ = HOMARD.CreateZoneSphere('Zone_4_2', DX/3., DY*0.3, DZ*0.6, rayon)

# 2. Creation of the hypotheses
# =============================
    error, hyponame = homard_exec_hypo ()
    if error :
      break

# 3. Creation of the cases
# ========================
    # Creation of the case
    print("-------- Creation of the case {}".format(TEST_NAME))
    case_test_4 = HOMARD.CreateCase(TEST_NAME, TEST_NAME, mesh_file)
    case_test_4.SetDirName(DIRCASE)

# 4. Creation of the iterations
# =============================
    error = homard_exec_iter(case_test_4, hyponame)

    break

  return error

#========================================================================

#========================================================================
def homard_exec_hypo():
  """Python script for HOMARD - Creation of the hypotheses"""

  error = 0
  while not error :

    dico = dict()
    dico["1"] = "raffinement"
    dico["-1"] = "deraffinement"
    hyponame = list()

# 1. Creation of the hypothesis hypo_4_1
# ======================================
    hyponame.append("Zone_1")
    print("-------- Creation of the hypothesis {}".format(hyponame[0]))
    hypo_4_1 = HOMARD.CreateHypothesis(hyponame[0])
    hypo_4_1.AddZone('Zone_4_1', 1)
    hypo_4_1.SetExtraOutput(2)
    laux = hypo_4_1.GetZones()
    nbzone = len(laux) // 2
    jaux = 0
    for _ in range(nbzone) :
      print(hyponame[0], " : ", dico[laux[jaux+1]], "sur la zone", laux[jaux])
      jaux += 2
# 2. Creation of the hypothesis hypo_4_2
# ======================================
    hyponame.append("Zone_2")
    print("-------- Creation of the hypothesis {}".format(hyponame[1]))
    hypo_4_2 = HOMARD.CreateHypothesis(hyponame[1])
    hypo_4_2.AddZone('Zone_4_2', 1)
    hypo_4_2.SetExtraOutput(2)
    laux = hypo_4_2.GetZones()
    nbzone = len(laux) // 2
    jaux = 0
    for _ in range(nbzone) :
      print(hyponame[1], " : ", dico[laux[jaux+1]], "sur la zone", laux[jaux])
      jaux += 2
# 3. Creation of the hypothesis DISTANCE INVERSE
# ==============================================
    hyponame.append("DISTANCE INVERSE")
    print("-------- Creation of the hypothesis {}".format(hyponame[2]))
    hypo_4_3 = HOMARD.CreateHypothesis(hyponame[2])
    hypo_4_3.SetField('DISTANCE')
    hypo_4_3.SetUseComp(0)
    hypo_4_3.SetRefinThr(1, 0.3)
    hypo_4_3.SetUnRefThr(1, 0.2)
    hypo_4_3.AddFieldInterp('DISTANCE')
    hypo_4_3.SetExtraOutput(2)
    print(hyponame[2], " : zones utilisées : {}".format(hypo_4_3.GetZones()))
    print(hyponame[2], " : champ utilisé : {}".format(hypo_4_3.GetFieldName()))
    print(hyponame[2], " : composantes utilisées : {}".format(hypo_4_3.GetComps()))
    if len (hypo_4_3.GetFieldName()):
      print(".. caractéristiques de l'adaptation : {}".format(hypo_4_3.GetField()))
    print(hyponame[2], " : champs interpolés : {}".format(hypo_4_3.GetFieldInterps()))

    break

  return error, hyponame

#========================================================================

#========================================================================
def homard_exec_iter(case_test_4, hyponame):
  """Python script for HOMARD - Creation of the iterations"""

  error = 0
  while not error :

# 1. Creation of the iteration 1
    iter_name = "I_" + TEST_NAME + "_1"
    print("-------- Creation of the iteration", iter_name)
    iter_test_4_1 = case_test_4.NextIteration(iter_name)
    iter_test_4_1.AssociateHypo(hyponame[0])
    print(". Hypothese :", hyponame[0])
    iter_test_4_1.SetMeshName('M1')
    iter_test_4_1.SetMeshFile(os.path.join(DIRCASE, 'maill.01.med'))
    error = iter_test_4_1.Compute(1, 2)
    if error :
      error = 1
      break

# 2. Creation of the iteration 2
    iter_name = "I_" + TEST_NAME + "_2"
    print("-------- Creation of the iteration", iter_name)
    iter_test_4_2 = iter_test_4_1.NextIteration(iter_name)
    iter_test_4_2.AssociateHypo(hyponame[1])
    print(". Hypothese :", hyponame[1])
    iter_test_4_2.SetMeshName('M2')
    iter_test_4_2.SetMeshFile(os.path.join(DIRCASE, 'maill.02.med'))
    error = iter_test_4_2.Compute(1, 2)
    if error :
      error = 2
      break

# 3. Creation of the iteration 3

    error = field_exec(2)
    if error :
      error = 30
      break

    iter_name = "I_" + TEST_NAME + "_3"
    print("-------- Creation of the iteration", iter_name)
    iter_test_4_3 = iter_test_4_2.NextIteration(iter_name)
    iter_test_4_3.AssociateHypo(hyponame[2])
    print(". Hypothese :", hyponame[2])
    iter_test_4_3.SetMeshName('M3')
    iter_test_4_3.SetFieldFile(os.path.join(DIRCASE, 'maill.02.med'))
    iter_test_4_3.SetMeshFile(os.path.join(DIRCASE, 'maill.03.med'))
    error = iter_test_4_3.Compute(1, 2)
    if error :
      error = 3
      break

    break

  return error

#========================================================================

# CAO and Mesh

try :
  ERROR, MESH_FILE = create_cao_smesh()
  if ERROR :
    raise Exception('Pb in create_cao_smesh')
except RuntimeError as eee:
  raise Exception('Pb in create_cao_smesh: '+str(eee.message))

HOMARD = salome.lcc.FindOrLoadComponent('FactoryServer', 'HOMARD')
assert HOMARD is not None, "Impossible to load homard engine"
HOMARD.SetLanguageShort("fr")

# Exec of HOMARD-SALOME

try :
  ERROR = homard_exec(MESH_FILE)
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
