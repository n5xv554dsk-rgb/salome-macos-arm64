# -*- coding: iso-8859-1 -*-
# Copyright (C) 2007-2026   EDF R&D
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
#
"""
   Ce package contient les Accas. qui seront effectivement utilisees dans les applications.
   C'est dans ce package que sont realisees les combinaisons de Accas. de base
   avec les Accas. MIXIN qui implementent les fonctionnalites qui ont ete separees
   du processing pour des raisons de modularite afin de faciliter la maintenance et
   l'extensibilite.

   De plus toutes les Accas. utilisables par les applications sont remontees au
   niveau du package afin de rendre le plus independant possible l'utilisation des
   Accas. et leur implementation.
"""


import warnings

warnings.filterwarnings("error", "Non-ASCII character.*pep-0263", DeprecationWarning)

from Accas.classes.C_JDC_CATA import JDC_CATA
from Accas.classes.C_JDC_CATA_SINGLETON import JDC_CATA_SINGLETON
from Accas.classes.C_OPER import OPER
from Accas.classes.C_PROC import PROC
from Accas.classes.C_MACRO import MACRO
from Accas.classes.C_FORM import FORM
from Accas.classes.C_BLOC import BLOC
from Accas.classes.C_FACT import FACT
from Accas.classes.C_SIMP import SIMP
from Accas.classes.C_EVAL import EVAL
from Accas.classes.C_NUPLET import NUPL
from Accas.classes.C_TUPLE import Tuple
from Accas.classes.C_TUPLE import Matrice


from Accas.classes.C_JDC import JDC
from Accas.classes.C_ETAPE import ETAPE
from Accas.classes.C_PROC_ETAPE import PROC_ETAPE
from Accas.classes.C_MACRO_ETAPE import MACRO_ETAPE
from Accas.classes.C_FORM_ETAPE import FORM_ETAPE
from Accas.classes.C_MCFACT import MCFACT
from Accas.classes.C_MCLIST import MCList
from Accas.classes.C_MCBLOC import MCBLOC
from Accas.classes.C_MCSIMP import MCSIMP

# Les regles
from Accas.classes.C_AU_MOINS_UN import AU_MOINS_UN
from Accas.classes.C_MEME_NOMBRE import MEME_NOMBRE
from Accas.classes.C_AU_PLUS_UN import AU_PLUS_UN
from Accas.classes.C_UN_PARMI import UN_PARMI
from Accas.classes.C_PRESENT_PRESENT import PRESENT_PRESENT
from Accas.classes.C_PRESENT_ABSENT import PRESENT_ABSENT
from Accas.classes.C_EXCLUS import EXCLUS
from Accas.classes.C_ENSEMBLE import ENSEMBLE
from Accas.classes.C_A_CLASSER import A_CLASSER
from Accas.classes.C_AVANT import AVANT

from Accas.classes.C_ASSD import ASSD, assd, UserASSD, UserASSDMultiple
from Accas.classes.C_ASSD import ASSD as A_ASSD # pour Efi2Xsd/MCAccasXML.py
from Accas.classes.C_ASSD import CO
from Accas.classes.C_ASSD import GEOM, geom

# Pour le moment on laisse fonction (ceinture et bretelles)
from Accas.classes.C_ASSD import FONCTION, fonction
from Accas.classes.C_ASSD import formule
from Accas.classes.C_ASSD import formule_c

from Accas.processing.P__F import _F

from Accas.processing.P_Exception import AsException
from Accas.processing.P_utils import AsType
from Accas.processing.P_utils import AsType
from Accas.processing.P_OPS import OPS, EMPTY_OPS
from Accas.processing.P_ASSD import not_checked

from Accas.classes.C_VALIDATOR import OrVal, AndVal, OnlyStr
from Accas.classes.C_VALIDATOR import OrdList, NoRepeat, LongStr, Compulsory, Absent, Together
from Accas.classes.C_VALIDATOR import RangeVal, EnumVal, TypeVal, PairVal
from Accas.classes.C_VALIDATOR import CardVal, InstanceVal
from Accas.classes.C_VALIDATOR import VerifTypeTuple, VerifExiste
from Accas.classes.C_VALIDATOR import FileExtVal, FunctionVal
from Accas.classes.C_VALIDATOR import CreeMotClef
from Accas.classes.C_VALIDATOR import compareAutreMC
from Accas.classes.C_VALIDATOR import infFrereMC, supFrereMC

from Accas.classes.C_SENSIBILITE import CONCEPT_SENSIBLE, REUSE_SENSIBLE, DERIVABLE

from Accas.extensions.niveau import NIVEAU
from Accas.extensions.etape_niveau import ETAPE_NIVEAU
from Accas.extensions.commentaire import COMMENTAIRE
from Accas.extensions.parametre import PARAMETRE
from Accas.extensions.parametre_eval import PARAMETRE_EVAL
from Accas.extensions.commande_comm import COMMANDE_COMM
from Accas.extensions.mcnuplet import MCNUPLET

from Accas.classes.C_SALOME_ENTRY import SalomeEntry
