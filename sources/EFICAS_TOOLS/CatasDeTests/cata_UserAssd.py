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

class laClasseUser(UserASSD): pass
class laClasseUserDerive(laClasseUser): pass
class lASSD(ASSD): pass

# En fait, cela n pas vraiment de sens que cela soit dans le fact
# ou si ? pour l instant on laisse de cote

DefinitionDsFactDsOper = OPER( nom='DefinitionDsFactDsOper', sd_prod=lASSD,
     unFact1 = FACT(statut='f', max="**",
        creeUserAssd = SIMP( statut='f', typ = (laClasseUser,'createObject'),),
       ),
)

DefinitionDsSimpDsOper = OPER( nom='DefinitionDsSimpDsOper', sd_prod=lASSD,
      creeUserAssd = SIMP( statut='f', typ = (laClasseUserDerive,'createObject'),),
)

DefinitionDsFactDsProc = PROC( nom='DefinitionDsFactDsProc',
     unFact = FACT(statut='f',
        creeUserAssd = SIMP( statut='f', typ = (laClasseUser,'createObject'),),
       ),
)
DefinitionDsSimpDsProc = PROC( nom='DefinitionDsSimpDsProc',
        creeUserAssd = SIMP( statut='f', typ = (laClasseUser,'createObject'),),
)

DefinitionDsSimpListe = PROC( nom='DefinitionDsSimpListe',
        creeUserAssd = SIMP( statut='f', typ = (laClasseUser,'createObject'),max='**'),
)

UtiliseUnUserAssD = PROC( nom = 'UtiliseUnUserAssD',
        utiliseUnUserAssd  = SIMP(statut= 'o',typ =laClasseUser),
)
UtiliseEtDefinitDsLeMemeProc = PROC( nom = 'UtiliseEtDefinitDsLeMemeProc',
        utiliseUserAssd  = SIMP(statut= 'o',typ= laClasseUser,max='**'),
        creeUserAssd = SIMP( statut='f', typ = (laClasseUser,'createObject'),),
)
