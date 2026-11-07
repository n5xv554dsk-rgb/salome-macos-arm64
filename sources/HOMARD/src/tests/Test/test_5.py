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
Specific conditions for Code_Saturne
Test test_5
"""
__revision__ = "V2.05"

import os
import sys
import platform
import numpy as np

from salome.kernel import salome
from salome.kernel import HOMARD
import medcoupling as mc
import MEDLoader as ml

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
TEST_NAME = "test_5"
DEBUG = False
VERBOSE = False
N_ITER_TEST_FILE = 3
NBCELL_X = 10
NBCELL_Y = 10
NBCELL_Z = 10
LG_X = 360.
LG_Y = 240.
LG_Z = 160.
MESH_NAME = "MESH"
# Répertoires pour ce test
REP_DATA, DIRCASE = get_dir(PATH_HOMARD, TEST_NAME, DEBUG)
#========================================================================

salome.salome_init_without_session()

#========================================================================
def mesh_exec():
  """Python script for MED"""
  error = 0

  while not error :

# Creation of the mesh
# ====================
    maillage_3d = ml.MEDCouplingUMesh(MESH_NAME, 2)
    maillage_3d.setMeshDimension(3)

# Creation of the nodes
# ====================

    nbno_x = NBCELL_X + 1
    nbno_y = NBCELL_Y + 1
    nbno_z = NBCELL_Z + 1

    delta_x = LG_X / float(NBCELL_X)
    delta_y = LG_Y / float(NBCELL_Y)
    delta_z = LG_Z / float(NBCELL_Z)

    coordinates = list()
    coo_z = -0.5*LG_Z
    for _ in range(nbno_z) :
      coo_y = -0.5*LG_Y
      for _ in range(nbno_y) :
        coo_x = -0.5*LG_X
        for _ in range(nbno_x) :
          coordinates.append(coo_x)
          coordinates.append(coo_y)
          coordinates.append(coo_z)
          coo_x += delta_x
        coo_y += delta_y
      coo_z += delta_z

    nbno = nbno_x*nbno_y*nbno_z
    les_coords = ml.DataArrayDouble(coordinates, nbno, 3)
    maillage_3d.setCoords(les_coords)

# Creation of the cells
# =====================

    nbr_cell_3d = NBCELL_X*NBCELL_Y*NBCELL_Z
    maillage_3d.allocateCells(nbr_cell_3d)

    decala_z = nbno_x*nbno_y
#   kaux = numero de la tranche en z
    for kaux in range(1, nbno_z) :

      #print ". Tranche en z numero %d" % kaux
      decala = decala_z*(kaux-1)
#     jaux = numero de la tranche en y
      for jaux in range(1, nbno_y) :

        #print ". Tranche en y numero %d" % jaux
#       iaux = numero de la tranche en x
        for iaux in range(1, nbno_x) :

          #print ". Tranche en x numero %d" % iaux
          nref = decala+iaux-1
          laux = [nref, nref+nbno_x, nref+1+nbno_x, nref+1, nref+decala_z, nref+nbno_x+decala_z, nref+1+nbno_x+decala_z, nref+1+decala_z]
          if VERBOSE:
            if ( ( iaux==1 and jaux==1 and kaux==1 ) or ( iaux==(nbno_x-1) and jaux==(nbno_y-1) and kaux==(nbno_z-1) ) ) :
              print (". Maille {} : {}".format((iaux*jaux*kaux),laux))
          maillage_3d.insertNextCell(ml.NORM_HEXA8, 8, laux)

        decala += nbno_x

    maillage_3d.finishInsertingCells()

# Agregation into a structure of MEDLoader
# ========================================

    meshMEDFile3D = ml.MEDFileUMesh()
    meshMEDFile3D.setName(MESH_NAME)

    meshMEDFile3D.setMeshAtLevel(0, maillage_3d)

    meshMEDFile3D.rearrangeFamilies()

# MED exportation
# ===============
    try:
      ficmed = os.path.join(DIRCASE, 'maill.00.med')
      #print "Ecriture du maillage dans le fichier", ficmed
      meshMEDFile3D.write(ficmed, 2)
    except IOError as eee:
      error = 2
      raise Exception('MEDFileUMesh.write() failed. ' + str(eee))

    break

  return error

#========================================================================

#========================================================================
def field_exec(niter):
  """
Python script for MEDCoupling
  """
  error = 0

  while not error :

# The mesh
# ========
    ficmed = os.path.join(DIRCASE, 'maill.%02d.med' % niter)
    meshMEDFileRead = ml.MEDFileMesh.New(ficmed)
    mesh_read0 = meshMEDFileRead.getMeshAtLevel(0)
# Barycenter of the cells
# =======================
    cg_hexa_ml = mesh_read0.computeIsoBarycenterOfNodesPerCell()
    cg_hexa = cg_hexa_ml.toNumPyArray()
# Target
# ======
    xyz_p = np.zeros(3, dtype=np.float32)
    xyz_p[0] = -0.20*float(1-niter) * LG_X
    xyz_p[1] = -0.15*float(1-niter) * LG_Y
    xyz_p[2] = -0.10*float(1-niter) * LG_Z
# Values of the field
# ===================
    nbr_cell_3d = mesh_read0.getNumberOfCells()
    valeur = mc.DataArrayDouble(nbr_cell_3d)
    for num_mail in range(nbr_cell_3d) :
      #ligne   = "x = %f" % cg_hexa[num_mail][0]
      #ligne  += ", y = %f" % cg_hexa[num_mail][1]
      #ligne  += ", z = %f" % cg_hexa[num_mail][2]
      #print ligne
      distance = np.linalg.norm(cg_hexa[num_mail]-xyz_p)
      valeur[num_mail] = 1.e0 / max ( 1.e-5, distance)
    #print ". valeur", valeur
    nparr = valeur.toNumPyArray()
    print(". mini/maxi {}/{}".format(nparr.min(),nparr.max()))

# Creation of the field
# =====================
    field = ml.MEDCouplingFieldDouble(ml.ON_CELLS, ml.ONE_TIME)
    field.setArray(valeur)
    field.setMesh(mesh_read0)
    field.setName("DISTANCE")

    fMEDFile_ch = ml.MEDFileField1TS()
    fMEDFile_ch.setFieldNoProfileSBT(field)     # No profile desired on the field, Sort By Type
    fMEDFile_ch.write(ficmed, 0) # 0 to indicate that we *append* (and no overwrite) to the MED file

    break

  return error, ficmed

#========================================================================

#========================================================================
def homard_exec():
  """Python script for HOMARD"""
  error = 0

  while not error :

# Creation of the hypothese DISTANCE INVERSE
# ==========================================
    hyponame = "DISTANCE INVERSE"
    print("-------- Creation of the hypothesis", hyponame)
    hypo_5 = HOMARD.CreateHypothesis(hyponame)
    hypo_5.SetField('DISTANCE')
    hypo_5.SetUseComp(0)
    hypo_5.SetRefinThr(1, 0.020)
    hypo_5.SetUnRefThr(1, 0.015)
    print(hyponame, " : champ utilisé :", hypo_5.GetFieldName())
    print(".. caractéristiques de l'adaptation :", hypo_5.GetField())

# Creation of the cases
# =====================
    print("-------- Creation of the case", TEST_NAME)
    mesh_file = os.path.join(DIRCASE, 'maill.00.med')
    case_test_5 = HOMARD.CreateCase(TEST_NAME, 'MESH', mesh_file)
    case_test_5.SetDirName(DIRCASE)
    case_test_5.SetConfType(1)
    case_test_5.SetExtType(1)

# Creation of the iterations
# ==========================

    for niter in range(N_ITER_TEST_FILE) :

      s_niterp1 = "%02d" % (niter + 1)

    # Creation of the indicator
    #
      error, ficmed_indic = field_exec(niter)
      if error :
        error = 10
        break

    # Creation of the iteration

      iter_name = "I_" + TEST_NAME + "_" + s_niterp1
      print("-------- Creation of the iteration", iter_name)
      if ( niter == 0 ) :
        iter_test_5 = case_test_5.NextIteration(iter_name)
      else :
        iter_test_5 = iter_test_5.NextIteration(iter_name)
      iter_test_5.AssociateHypo(hyponame)
      iter_test_5.SetFieldFile(ficmed_indic)
      iter_test_5.SetMeshName(MESH_NAME+"_" + s_niterp1)
      iter_test_5.SetMeshFile(os.path.join(DIRCASE, "maill."+s_niterp1+".med"))
      error = iter_test_5.Compute(1, 2)
      if error :
        error = 20
        break

    break

  return error

#========================================================================

# Geometry and Mesh

try :
  ERROR = mesh_exec()
  if ERROR :
    raise Exception('Pb in mesh_exec')
except RuntimeError as eee:
  raise Exception('Pb in mesh_exec: '+str(eee.message))

HOMARD = salome.lcc.FindOrLoadComponent('FactoryServer', 'HOMARD')
assert HOMARD is not None, "Impossible to load homard engine"
HOMARD.SetLanguageShort("fr")

# Exec of HOMARD-SALOME

try :
  ERROR = homard_exec()
  if ERROR :
    raise Exception('Pb in homard_exec at iteration %d' %ERROR )
except RuntimeError as eee:
  raise Exception('Pb in homard_exec: '+str(eee.message))

# Test of the results

N_REP_TEST_FILE = N_ITER_TEST_FILE
DESTROY_DIR = not DEBUG

if platform.system() == 'Windows':
  DESTROY_DIR = DEBUG
  texte_sup= "Le maillage est conforme." 
  update_test_win(DIRCASE,N_REP_TEST_FILE,N_ITER_TEST_FILE,texte_sup)

test_results(REP_DATA, TEST_NAME, DIRCASE, N_ITER_TEST_FILE, N_REP_TEST_FILE, DESTROY_DIR)

if salome.sg.hasDesktop():
  salome.sg.updateObjBrowser()
