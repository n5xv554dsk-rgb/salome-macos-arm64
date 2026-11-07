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
__revision__ = "V3.04"
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
DIRCASE = creation_dircase(5)
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
# Frontière
# =========
# Creation of the discrete boundary boun_5_1
boun_5_1 = homard.CreateBoundaryDi('boun_5_1', 'MAIL_EXT', os.path.join(DATA_TUTORIAL, "tutorial_5.fr.med"))
#
# Creation des zones
# ==================
# Creation of the disk with hole enveloppe
enveloppe = homard.CreateZoneDiskWithHole( 'enveloppe', 0., 0., 250., 193., 1 )
# Creation of the rectangle quart_sup
quart_sup = homard.CreateZoneBox2D( 'quart_sup', 0., 250., 0., 250., 1 )
#
# Hypotheses
# ==========
# Creation of the hypothesis hypo_5
l_hypothese = homard.CreateHypothesis('hypo_5')
l_hypothese.AddZone('enveloppe', 1)
# Creation of the hypothesis l_hypothese_bis
l_hypothese_bis = homard.CreateHypothesis('hypo_5_bis')
l_hypothese_bis.AddZone('quart_sup', 1)
#
# Cas
# ===
le_cas = homard.CreateCase('Case_5', 'COEUR_2D', os.path.join(DATA_TUTORIAL, "tutorial_5.00.med"))
le_cas.SetDirName(DIRCASE)
le_cas.SetConfType(1)
le_cas.AddBoundary('boun_5_1')
#
# Iteration "iter_5_1"
# ====================
iter_5_1 = le_cas.NextIteration('iter_5_1')
iter_5_1.SetMeshName('COEUR_2D_01')
iter_5_1.SetMeshFile(os.path.join(DIRCASE, "maill.01.med"))
iter_5_1.AssociateHypo('hypo_5')
erreur = iter_5_1.Compute(1, 2)
#
# Iteration "iter_5_2"
# ====================
iter_5_2 = iter_5_1.NextIteration('iter_5_2')
iter_5_2.SetMeshName('COEUR_2D_02')
iter_5_2.SetMeshFile(os.path.join(DIRCASE, "maill.02.med"))
iter_5_2.AssociateHypo('hypo_5_bis')
erreur = iter_5_2.Compute(1, 2)
#
#============================== Fin des commandes ==============================
#
if salome.sg.hasDesktop():
  salome.sg.updateObjBrowser()
