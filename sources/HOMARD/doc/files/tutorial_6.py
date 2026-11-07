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
Copyright EDF 1996, 2011, 2019
"""
__revision__ = "V4.06"
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
DIRCASE = creation_dircase(6)
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
# Frontières
# ==========
boun_6_1 = homard.CreateBoundaryDi('intersection', 'COURBES', os.path.join(DATA_TUTORIAL, "tutorial_6.fr.med"))
#
boun_6_2 = homard.CreateBoundaryCylinder('cyl_1_ext', 0.0, 25., -25., 25., 50., 75., 100.)
#
boun_6_3 = homard.CreateBoundaryCylinder('cyl_2_ext', 17.5, -2.5, -12.5, -100., -75., -25., 50.)
#
boun_6_4 = homard.CreateBoundaryCylinder('cyl_1_int', 0.0, 25., -25., 25., 50., 75., 75.)
#
boun_6_5 = homard.CreateBoundaryCylinder('cyl_2_int', 17.5, -2.5, -12.5, -100., -75., -25., 25.)
#
# Cas
# ===
le_cas = homard.CreateCase('Case_6', 'PIQUAGE', os.path.join(DATA_TUTORIAL, "tutorial_4.00.med"))
le_cas.SetDirName(DIRCASE)
le_cas.AddBoundary( 'intersection' )
le_cas.AddBoundaryGroup( 'cyl_1_int', 'T1_INT_I' )
le_cas.AddBoundaryGroup( 'cyl_1_ext', 'T1_EXT_I' )
le_cas.AddBoundaryGroup( 'cyl_1_int', 'T1_INT_O' )
le_cas.AddBoundaryGroup( 'cyl_1_ext', 'T1_EXT_O' )
le_cas.AddBoundaryGroup( 'cyl_2_int', 'T2_INT' )
le_cas.AddBoundaryGroup( 'cyl_2_ext', 'T2_EXT' )
#
#============================== Fin des commandes ==============================
#
# Hypotheses
# ==========
# Creation of the hypothesis hypo_6
l_hypothese = homard.CreateHypothesis('hypo_6')
l_hypothese.SetUnifRefinUnRef(1)
l_hypothese.AddGroup('IN1')
l_hypothese.AddGroup('IN2')
l_hypothese.AddGroup('T1_INT_I')
l_hypothese.AddGroup('T1_INT_O')
l_hypothese.AddGroup('T2_INT')
# Creation of the hypothesis hypo_6_bis
l_hypothese_bis = homard.CreateHypothesis('hypo_6_bis')
l_hypothese_bis.SetUnifRefinUnRef(1)
l_hypothese_bis.AddGroup('T1_EXT_I')
l_hypothese_bis.AddGroup('T1_EXT_O')
l_hypothese_bis.AddGroup('T2_EXT')
#
# Iterations
# ==========
# Iteration iter_6_1 : raffinement selon les faces internes
iter_6_1 = le_cas.NextIteration('iter_6_1')
iter_6_1.SetMeshName('PIQUAGE_6_1')
iter_6_1.SetMeshFile(os.path.join(DIRCASE, "maill.01.med"))
iter_6_1.AssociateHypo('hypo_6')
erreur = iter_6_1.Compute(1, 2)
# Iteration iter_6_2 : raffinement selon les faces externes
iter_6_2 = iter_6_1.NextIteration('iter_6_2')
iter_6_2.SetMeshName('PIQUAGE_6_2')
iter_6_2.SetMeshFile(os.path.join(DIRCASE, "maill.02.med"))
iter_6_2.AssociateHypo('hypo_6_bis')
erreur = iter_6_2.Compute(1, 2)
# Iteration iter_6_3 : second raffinement selon les faces externes
iter_6_3 = iter_6_2.NextIteration('iter_6_3')
iter_6_3.SetMeshName('PIQUAGE_6_3')
iter_6_3.SetMeshFile(os.path.join(DIRCASE, "maill.03.med"))
iter_6_3.AssociateHypo('hypo_6_bis')
erreur = iter_6_3.Compute(1, 2)
#
if salome.sg.hasDesktop():
  salome.sg.updateObjBrowser()
