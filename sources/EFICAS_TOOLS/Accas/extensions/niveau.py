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
"""
    Ce module contient la classe NIVEAU qui sert a definir
    des groupes de commandes dans le catalogue
"""
from builtins import object


class NIVEAU(object):
    def __init__(self, nom="", label="", niveaux=(), valide_vide=1, actif=1):
        self.nom = nom
        self.label = label
        self.statut = "o"
        self.min = 1
        self.max = 1
        self.entites = []
        self.l_noms_entites = []
        self.valide_vide = valide_vide
        self.actif = actif
        self.d_niveaux = {}
        self.lNiveaux = niveaux
        for niveau in niveaux:
            self.d_niveaux[niveau.nom] = niveau
            self.d_niveaux.update(niveau.d_niveaux)

    def enregistre(self, commande):
        self.entites.append(commande)
        self.l_noms_entites.append(commande.nom)

    def getListeCmd(self):
        self.l_noms_entites.sort()
        return self.l_noms_entites
