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

from Accas.processing.P_ASSD import ASSD
from Accas.accessor import CONNECTOR


class UserASSD(ASSD):
    """
    Classe de base pour definir des types de structures de donnees definie par
    l utilisateur
    equivalent d un concept ASSD pour un SIMP ou un FACT
    Attention : le parent est a None au debut  et non le MC createur que l on ne connait pas
    Lorsqu on ecrit le jdc, n ecrit nom=UserASSD()
    le parent est le SIMP qui cree l objet
    a la lecture si la classe commence par un majuscule on fait le boulot dans MCSIMP, sinon dans
    l init de parametre car le parsing considere qu on a un parametre
    """

    def __init__(self, nom="sansNom"):
        # print ('dans init de UserASSD pour ', nom, type(nom))
        self.nom = nom
        self.jdc = CONTEXT.getCurrentJdC()
        self.parent = None
        self.initialiseValeur()
        self.utilisePar = set()
        if self.nom != "sansNom":
            self.id = self.jdc.regSD(self)
        if self.nom != "sansNom":
            self.initialiseNom(nom)
        else:
            self.id = None
        self.ptr_sdj = None

    def initialiseParent(self, parent):
        # attention parent.parent peut être un bloc
        # print ('je passe initialiseParent pour : ', self, parent.nom)
        self.parent = parent
        self.etape = self.parent.getEtape()
        self.etape.userASSDCrees.append(self)
        if self.parent.parent != self.etape:
            if self.parent.parent.estIdentifiePar != None:
                print(
                    "il y a un souci dans l initialisation de l identifiant pour",
                    self.parent.parent.nom,
                )
                print(self.parent.nom)
                print(self.nom)
            self.parent.parent.estIdentifiePar = self

    def initialiseNom(self, nom):
        # print ('je passe initialiseNom pour : ', self, nom, type(nom))
        for i, j in list(self.jdc.sdsDict.items()):
            if j == self:
                del self.jdc.sdsDict[i]
        self.jdc.sdsDict[nom] = self
        self.nom = nom
        if self.nom != "sansNom" and self.id == None:
            self.id = self.jdc.regSD(self)

    def initialiseValeur(self, valeur=None):
        self.valeur = valeur

    def ajoutUtilisePar(self, mc):
        # print ('je passe ajoutUtilisePar pour : ', self.nom)
        self.utilisePar.add(mc)

    def enleveUtilisePar(self, mc):
        try:
            self.utilisePar.remove(mc)
        except:
            pass

    def renomme(self, nouveauNom):
        print("je passe dans renomme")
        self.jdc.delConcept(self.nom)
        self.jdc.sdsDict[nouveauNom] = self
        self.setName(nouveauNom)
        # print ('je suis dans renomme',nouveauNom, self.nom)
        # print (self.utilisePar)
        for mc in self.utilisePar:
            mc.demandeRedessine()

    def transfere(self, obj):
        # uniquement utise pour les lectures XML
        self.utilisePar = obj.utilisePar
        self.id = obj.id
        for mc in self.utilisePar:
            mc.valeur = self

    def deleteReference(self, mcCreateur=None):
        print("je passe dans supprime de P_UserASSDMultiple")
        # meme signature que UserASSDMultiple
        for MC in self.utilisePar:
            # le delete est appele en cascade par toute la hierachie
            # du mcsimp (au cas ou on detruise le fact ou le proc)
            # du coup pas beau
            try:
                if type(MC.valeur) in (list, tuple):
                    MC.valeur = list(MC.valeur)
                    while self in MC.valeur:
                        MC.valeur.remove(self)
                    if MC.valeur == []:
                        MC.Valeur = None
                else:
                    MC.valeur = None
                MC.state = "changed"
                MC.isValid()
                CONNECTOR.Emit(MC, "valid")
            except:
                pass
            # on peut avoir des listes qui contiennent plusieurs fois la meme valeur
        self.jdc.delConcept(self.nom)

    def executeExpression(self, condition, dico):
        # if self.nom == 'shape1' : print ('je suis dans executeExpression ', self.nom, ' ', condition)
        dict = locals()
        dict.update(dico)
        # if self.nom == 'shape1' or self.nom == 'G1' : print (dict)
        # if self.nom == 'shape1' :
        #    print (self.getParentsWithId().getListeUserASSD("systemGeometryId"))
        #    print (self.getParentsWithId().getListeUserASSD("SystemGeometryId"))
        #    test = eval(condition, globals(), dict)
        #    print ('-------------------------------------------------------------------------')
        try:
            test = eval(condition, globals(), dict)
        except:
            print("executeExpression ", self.nom, " ", condition, "exception")
            test = 0
        return test

    def getEficasAttribut(self, attribut):
        # print ('je suis dans getEficasAttr', attribut)
        if self.parent == None:
            return None
        # print ('apres if')
        # parent est le SIMP donc c est bien parent.parent
        try:
            valeur = self.parent.parent.getMocle(attribut)
        except:
            valeur = None
        # print (valeur)
        return valeur

    def supprime(self, mcCreateur=None):
        # mcCreateur utile pour P_UserASSDMultiple
        print("je passe dans supprime de P_UserASSDMultiple")
        self.deleteReference(mcCreateur)

    def __repr__(self):
        return "concept " + self.getName() + " type " + self.__class__.__name__

    def __str__(self):
        return self.getName() or "<None>"
