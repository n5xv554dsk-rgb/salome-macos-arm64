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


# tout est Facultatif car sinon, on ne peut pas supprimer et c 'est ce qu on veut tester

DefinitionListe = PROC( nom='DefinitionListe',
        listeTexte = SIMP( statut='f', typ = 'TXM',max='**'),
        listeIntInto = SIMP( statut='f', typ = 'I',homo="SansOrdreNiDoublon",max='**', into=(1,2,3,4)),
        listeIntIntoOrdre = SIMP( statut='f', typ = 'I',max='**', into=(1,2,3,4)),
)
