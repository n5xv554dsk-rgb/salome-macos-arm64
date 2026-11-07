#!/usr/bin/env python3
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
Exemple de couplage HOMARD-Salome
Copyright EDF 1996, 2010, 2019
"""
__revision__ = "V3.03"
#
import os
import sys
#
# ==================================
PATH_HOMARD = os.getenv("HOMARD_ROOT_DIR")
# Repertoire des donnees du tutorial
DATA_TUTORIAL = os.path.join(PATH_HOMARD, "share", "doc", "salome", "gui", "HOMARD", "fr", "_downloads")
DATA_TUTORIAL = os.path.normpath(DATA_TUTORIAL)
sys.path.append(DATA_TUTORIAL)
from tutorial_util import creation_dircase
# ==================================
DIRCASE = creation_dircase(1)
# ==================================
#
from salome.kernel import salome
salome.salome_init()
from salome.kernel import HOMARD
#
homard = salome.lcc.FindOrLoadComponent("FactoryServer", "HOMARD")
homard.UpdateStudy()
#
#============================= Début des commandes =============================
#
# Hypotheses
# ==========
l_hypothese = homard.CreateHypothesis('hypo_1')
l_hypothese.SetUnifRefinUnRef(1)
#
# Cas
# ===
le_cas = homard.CreateCase('Case_1', 'MAILL', os.path.join(DATA_TUTORIAL, "tutorial_1.00.med"))
le_cas.SetDirName(DIRCASE)
#
# Iterations
# ==========
# Iteration "iter_1_1"
iter_1_1 = le_cas.NextIteration('iter_1_1')
iter_1_1.SetMeshName('MESH')
iter_1_1.SetMeshFile(os.path.join(DIRCASE, "maill.01.med"))
iter_1_1.AssociateHypo('hypo_1')
erreur = iter_1_1.Compute(1, 2)

# Iteration "iter_1_2"
iter_1_2 = iter_1_1.NextIteration('iter_1_2')
iter_1_2.SetMeshName('MESH')
iter_1_2.SetMeshFile(os.path.join(DIRCASE, "maill.02.med"))
iter_1_2.AssociateHypo('hypo_1')
erreur = iter_1_2.Compute(1, 2)

# Iteration "iter_1_3"
iter_1_3 = iter_1_2.NextIteration('iter_1_3')
iter_1_3.SetMeshName('MESH')
iter_1_3.SetMeshFile(os.path.join(DIRCASE, "maill.03.med"))
iter_1_3.AssociateHypo('hypo_1')
erreur = iter_1_3.Compute(1, 2)
#
#============================== Fin des commandes ==============================
#
if salome.sg.hasDesktop():
  salome.sg.updateObjBrowser()
