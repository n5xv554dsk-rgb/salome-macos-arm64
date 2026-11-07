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
from Accas.accessor.A_ASSD import ASSD
from Accas.extensions.eficas_translation import tr
from Accas.extensions.eficas_exception import EficasException


class FONCTION(ASSD):
    def __init__(self, etape=None, sd=None, reg="oui"):
        if reg == "oui":
            self.jdc.registerFonction(self)

    def getFormule(self):
        """
        Retourne une formule decrivant self sous la forme d'un tuple :
        (nom,type_retourne,arguments,corps)
        """
        if hasattr(self.etape, "getFormule"):
            # on est dans le cas d'une formule Aster
            return self.etape.getFormule()
        else:
            # on est dans le cas d'une fonction
            return (self.nom, "REEL", "(REEL:x)", """bidon""")


# On ajoute la classe formule pour etre coherent avec la
# modification de C Durand sur la gestion des formules dans le superviseur
# On conserve l'ancienne classe fonction (ceinture et bretelles)
class fonction(FONCTION):
    pass


from Accas.extensions import param2


class formule(FONCTION):
    def __call__(self, *val):
        if len(val) != len(self.nompar):
            raise TypeError(
                " %s() takes exactly %d argument (%d given)"
                % (self.nom, len(self.nompar), len(val))
            )
        return param2.Unop2(self.nom, self.realCall, val)

    def realCall(self, *val):
        if hasattr(self.parent, "contexte_fichier_init"):
            context = self.parent.contexte_fichier_init
        else:
            context = {}
        i = 0
        for param in self.nompar:
            context[param] = val[i]
            i = i + 1
        try:
            res = eval(self.expression, self.jdc.const_context, context)
        except:
            print(75 * "!")
            print("! " + "Erreur evaluation formule %s" % self.nom + 20 * "!")
            print(75 * "!")
            raise EficasException
        return res
