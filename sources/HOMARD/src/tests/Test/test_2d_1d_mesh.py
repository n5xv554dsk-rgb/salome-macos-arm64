#!/usr/bin/env python

###
### This file is generated automatically by SALOME v9.11.0 with dump python functionality
###

import sys
from salome.kernel import salome
import platform
from os import path
import shutil
from MEDLoader import *

salome.salome_init()
from salome.kernel import salome_notebook
notebook = salome_notebook.NoteBook()

import tempfile
tmp_folder = tempfile.mkdtemp()
print("Temporary folder", tmp_folder)

# Create mesh
mesh_name = "mesh"

arr = DataArrayDouble(list(range(10)))
mesh = MEDCouplingUMesh(mesh_name, 1)


coords = [0.,0., 1.,0., 2.,0., 3.,0., 4.,0., 5.,0., 6.,0., 7.,0.]

mesh.allocateCells(7)

for i in range(7):
    mesh.insertNextCell(NORM_SEG2, [i,i+1])

mesh.finishInsertingCells()

coordsArr=DataArrayDouble(coords, len(coords)//2, 2)

mesh.setCoords(coordsArr)
mesh.setMeshDimension(2)

mesh_file = path.join(tmp_folder, "mesh_2d_1d.med")
#mesh_file = "mesh_2d_1d.med"

WriteMesh(mesh_file, mesh, True)
print("mesh_file ", mesh_file)

###
### HOMARD component
###

from salome.kernel import HOMARD
homard = salome.lcc.FindOrLoadComponent('FactoryServer','HOMARD')
homard.UpdateStudy()
#
# Creation of the hypotheses
# ==========================
# Creation of the hypothesis Hypo_1
Hypo_1 = homard.CreateHypothesis("Hypo_1")
Hypo_1.SetUnifRefinUnRef(1)
#
# Creation of the cases
# =====================
# Creation of the case Case_1
Case_1 = homard.CreateCase("Case_1", mesh_name, mesh_file)
Case_1.SetDirName(tmp_folder)
Case_1.SetConfType(0)
Case_1.SetExtType(0)
#
# Creation of the iterations
# ==========================
# Creation of the iteration Iter_1
Iter_1 = Case_1.NextIteration("Iter_1")
Iter_1.AssociateHypo("Hypo_1")
Iter_1.SetMeshName(mesh_name)
refined_mesh = path.join(tmp_folder, "maill.01.med")
Iter_1.SetMeshFile(refined_mesh)
print("refined_mesh ", refined_mesh)
codret = Iter_1.Compute(1, 1)

ref_mesh = ReadUMeshFromFile(refined_mesh)
coords = ref_mesh.getCoords()
y_coords = coords.getValues()[1::2]

## Checking that Y values are still zeros
assert all([val<1e-8 for val in y_coords]), y_coords

if platform.system() != 'Windows':
   shutil.rmtree(tmp_folder)
