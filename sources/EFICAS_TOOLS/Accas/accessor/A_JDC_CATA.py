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
from Accas.processing import P_JDC_CATA


debug = 0
class JDC_CATA:
    def __init__(self):
        if debug : print ('!!!!!!!!!!!!!!!!! in init', self)
        self.l_noms_entites = []

    def getListeCmd(self):
        self.l_noms_entites.sort()
        return self.l_noms_entites

    def getDocu(self):
        return

    def enregistre(self, commande):
        """
        Cette methode complete la methode de la classe de processing
        l_nom_entite pour le coeur d eficas et commandes pour les affichages IHM
        l ordre des listes peut etre different
        """
        if debug : print ('enregistre de A_JDC_CATA', commande)
        P_JDC_CATA.JDC_CATA.enregistre(self, commande)
        self.l_noms_entites.append(commande.nom)
