# Copyright (C) 2008 - 2026 EDF R&D
#
# This file is part of SALOME ADAO module
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License.
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
import os, re
import Accas
from Accas import *
monFichier=os.path.abspath(__file__)

JdC = JDC_CATA (
    code='Essai'
    )
VERSION_CATALOGUE='V_0'

#leProc = PROC(nom = 'leProc',
#      unSimp = SIMP(statut='o', typ ='I'),
#      bloc1 = BLOC(condition = "UnSimp == 1",
#         leFact1 = FACT(statut = 'o',
#               Name = SIMP(typ='TXM', statut='o',),
#               ScalarFluxModel = SIMP(typ='TXM', statut='o'),
#          ),
#      ), # fin bloc1
#      bloc2 = BLOC(condition = "UnSimp == 2",
#         leFact1 = FACT(statut = 'o',
#               Name = SIMP(typ='TXM', statut='o',),
#         ),
#      )
#)
leProcV2 = PROC(nom = 'leProcV2',
      unSimpV2 = SIMP(statut='o', typ ='I'),
      blocV21 = BLOC(condition = "UnSimpV2 == 1",
         leFactV21 = FACT(statut = 'o',
            ScalarV2 = FACT(statut = 'f', max ='**',
               NameV2 = SIMP(typ='TXM', statut='o',),
               ScalarFluxModelV2 = SIMP(typ='TXM', statut='o'),
            ),# Scalar
          ),
      ), # fin bloc1
      blocV22 = BLOC(condition = "UnSimp == 2",
         leFactV21 = FACT(statut = 'o',
            ScalarV2 = FACT (  statut = 'f', max ='**',
               NameV2 = SIMP(typ='TXM', statut='o',),
          ),# ScalarV2
         ),
      ), # fin bloc2
)
