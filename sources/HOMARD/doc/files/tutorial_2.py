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
DIRCASE = creation_dircase(2)
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
# Creation des zones
# ==================
# Box "Zone_0"
Zone_0 = homard.CreateZoneBox ('Zone_0', -0.1, 1.1, -0.1, 1.1, 0.9, 1.1)
#
# Sphere "Zone_1"
Zone_1 = homard.CreateZoneSphere ('Zone_1', 0., 0., 0., 1.05)
#
# Box "Zone_2"
Zone_2 = homard.CreateZoneBox ('Zone_2', -0.1, 0.51, -0.1, 0.51, -0.1, 0.51)
#
# Hypothese "hypo_2"
# ==================
l_hypothese = homard.CreateHypothesis('hypo_2')
l_hypothese.AddZone('Zone_1', 1)
l_hypothese.AddZone('Zone_0', 1)
#
# Hypothese "hypo_2_bis"
# ======================
l_hypothese_bis = homard.CreateHypothesis('hypo_2_bis')
l_hypothese_bis.AddZone('Zone_0', -1)
l_hypothese_bis.AddZone('Zone_2', 1)
#
# Cas
# ===
le_cas = homard.CreateCase('Case_2', 'MZERO', os.path.join(DATA_TUTORIAL, "tutorial_2.00.med"))
le_cas.SetDirName(DIRCASE)
#
# Iteration "iter_2_1"
# ====================
iter_2_1 = le_cas.NextIteration('iter_2_1')
iter_2_1.SetMeshName('M_1')
iter_2_1.SetMeshFile(os.path.join(DIRCASE, "maill.01.med"))
iter_2_1.AssociateHypo('hypo_2')
erreur = iter_2_1.Compute(1, 2)
#
# Iteration "iter_2_2"
# ====================
iter_2_2 = iter_2_1.NextIteration('iter_2_2')
iter_2_2.SetMeshName('M_2')
iter_2_2.SetMeshFile(os.path.join(DIRCASE, "maill.02.med"))
iter_2_2.AssociateHypo('hypo_2_bis')
erreur = iter_2_2.Compute(1, 2)
#
#============================== Fin des commandes ==============================

if salome.sg.hasDesktop():
  salome.sg.updateObjBrowser()
