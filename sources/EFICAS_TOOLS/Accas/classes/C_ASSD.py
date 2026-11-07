# -*- coding: utf-8 -*-
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

from Accas.accessor import A_ASSD
from Accas.accessor import A_LASSD
from Accas.accessor import A_FONCTION
from Accas.processing import P_ASSD
from Accas.processing import P_GEOM
from Accas.processing import P_FONCTION
from Accas.processing import P_CO
from Accas.processing import P_UserASSD
from Accas.processing import P_UserASSDMultiple

# On ajoute la classe ASSD dans l'heritage multiple pour recreer
# une hierarchie d'heritage identique a celle de Noyau
# pour faire en sorte que isinstance(o,ASSD) marche encore apres
# derivation


class ASSD(A_ASSD.ASSD, P_ASSD.ASSD):
    pass


# class LASSD(A_LASSD.LASSD,N_LASSD.LASSD):pass
class LASSD(A_LASSD.LASSD):
    pass


class UserASSD(P_UserASSD.UserASSD, ASSD):
    pass


class UserASSDMultiple(P_UserASSDMultiple.UserASSDMultiple, UserASSD):
    pass


class assd(P_ASSD.assd, A_ASSD.assd, ASSD):
    pass


class FONCTION(P_FONCTION.FONCTION, A_FONCTION.FONCTION, ASSD):
    def __init__(self, etape=None, sd=None, reg="oui"):
        P_FONCTION.FONCTION.__init__(self, etape=etape, sd=sd, reg=reg)
        A_FONCTION.FONCTION.__init__(self, etape=etape, sd=sd, reg=reg)


class formule(A_FONCTION.formule, P_FONCTION.formule, ASSD):
    def __init__(self, etape=None, sd=None, reg="oui"):
        P_FONCTION.formule.__init__(self, etape=etape, sd=sd, reg=reg)
        A_FONCTION.formule.__init__(self, etape=etape, sd=sd, reg=reg)


class formule_c(formule):
    pass


# On conserve fonction (ceinture et bretelles)
# fonction n'existe plus dans P_FONCTION on le remplace par formule
class fonction(P_FONCTION.formule, A_FONCTION.fonction, ASSD):
    """obsolete class : use formule instead"""

    def __init__(self, etape=None, sd=None, reg="oui"):
        P_FONCTION.formule.__init__(self, etape=etape, sd=sd, reg=reg)
        A_FONCTION.fonction.__init__(self, etape=etape, sd=sd, reg=reg)


class GEOM(P_GEOM.GEOM, A_ASSD.GEOM, ASSD):
    pass


class geom(P_GEOM.geom, A_ASSD.geom, ASSD):
    pass


class CO(P_CO.CO, A_ASSD.CO, ASSD):
    pass
