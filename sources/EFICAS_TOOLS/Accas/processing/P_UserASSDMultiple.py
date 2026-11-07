# coding=utf-8
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

"""
"""

import traceback
import sys

from Accas.processing.P_UserASSD import UserASSD
from Accas.processing.P_ASSD import ASSD

from collections import UserList


class UserASSDMultiple(UserASSD):
    """
    Classe de base pour definir des types de structures de donnees definie par
    l utilisateur
    equivalent d un concept ASSD pour un SIMP ou un FACT
    mais pouvant referencer 2 objets par exemple les groupes de mailles qui peuvent porter
    le meme nom dans 2 maillages differents
    """

    def __init__(self, nom="sansNom"):
        # print ('dans init de UserASSDMultiple ',nom)
        UserASSD.__init__(self, nom)
        self.peres = []

    def ajouteUnPere(self, pere):
        # print ('dans ajouteUnPere', self.peres, self.nom, pere)
        if pere not in self.peres:
            self.peres.append(pere)
        etape = pere.getEtape()
        if self not in etape.userASSDCrees:
            etape.userASSDCrees.append(self)

    def renomme(self, nouveauNom):
        print("je passe dans renomme")
        # import traceback
        # traceback.print_stack()
        self.jdc.delConcept(self.nom)
        self.jdc.sdsDict[nouveauNom] = self
        self.setName(nouveauNom)
        for mc in self.utilisePar:
            mc.demandeRedessine()

    def initialiseParent(self, pere):
        # surcharge P_UserASSD  parent ici n a pas de sens
        pass

    def deleteReference(self, mcCreateur):
        print("je passe dans deleteReference", mcCreateur.nom)
        if not (mcCreateur in self.peres):
            return
        self.peres.pop(self.peres.index(mcCreateur))
        if len(self.peres) == 0:
            UserASSD.deleteReference(self)

    def getParentsWithId(self):
        # print ('je suis dans getParentsWithId ')
        listeRetour = listUserASSD()
        for pere in self.peres:
            pereWithId = pere.parent
            monEtape = pere.getEtape()
            while pereWithId:
                if pereWithId == monEtape:
                    listeRetour.append(pereWithId)
                    break
                if pereWithId.estIdentifiePar != None:
                    listeRetour.append(pereWithId)
                    break
                pereWithId = pereWithId.parent
        return listeRetour

    def getEtapes(self):
        listeRetour = listUserASSD()
        for pere in self.peres:
            if pere.etape not in listeRetour:
                listeRetour.append(pere.etape)
        return listeRetour


class listUserASSD(UserList):
    def getListeMotsCles(self, nomMc):
        if self.data == None:
            return []
        listeRetour = []
        for concept in self.data:
            listeRetour.append(concept.getChild(nomMc).val)
        return listeRetour

    def getListeNomsUserASSD(self, nomMc):
        if self.data == None:
            return []
        listeRetour = []
        for concept in self.data:
            listeRetour.append(concept.getChild(nomMc).val.nom)
        return listeRetour

    def getListeUserASSD(self, nomMc):
        if self.data == None:
            return []
        listeRetour = []
        for concept in self.data:
            if concept.getChild(nomMc):
                if concept.getChild(nomMc).val:
                    listeRetour.append(concept.getChild(nomMc).val)
        return listeRetour
