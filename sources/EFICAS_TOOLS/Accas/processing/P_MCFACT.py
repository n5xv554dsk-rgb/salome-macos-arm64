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
    Ce module contient la classe MCFACT qui sert à controler la valeur
    d'un mot-clé facteur par rapport à sa définition portée par un objet
    de type ENTITE
"""
from Accas.processing import P_MCCOMPO


class MCFACT(P_MCCOMPO.MCCOMPO):
    nature = "MCFACT"

    def __init__(self, val, definition, nom, parent, dicoPyxbDeConstruction):
        """
        Attributs :
         - val : valeur du mot clé simple
         - definition
         - nom
         - parent
        """
        # print ('MCFACT', self, val, definition, nom, parent, dicoPyxbDeConstruction)
        # import traceback
        # traceback.print_stack()
        self.dicoPyxbDeConstruction = dicoPyxbDeConstruction
        if self.dicoPyxbDeConstruction:
            self.objPyxbDeConstruction = self.dicoPyxbDeConstruction["objEnPyxb"]
            del self.dicoPyxbDeConstruction["objEnPyxb"]
        else:
            self.objPyxbDeConstruction = None
        self.definition = definition
        self.nom = nom
        self.val = val
        self.parent = parent
        self.estIdentifiePar = None
        self.valeur = self.getValeurEffective(self.val)
        if parent:
            self.jdc = self.parent.jdc
            self.niveau = self.parent.niveau
            self.etape = self.parent.etape
        else:
            # Le mot cle a été créé sans parent
            self.jdc = None
            self.niveau = None
            self.etape = None
        self.mcListe = self.buildMc()

    def getValeurEffective(self, val):
        """
        Retourne la valeur effective du mot-clé en fonction
        de la valeur donnée. Defaut si val == None
        """
        if val is None and hasattr(self.definition, "defaut"):
            return self.definition.defaut
        else:
            return val

    def getValeur(self):
        """
        Retourne la "valeur" d'un mot-clé facteur qui est l'objet lui-meme.
        Cette valeur est utilisée lors de la création d'un contexte
        d'évaluation d'expressions à l'aide d'un interpréteur Python
        """
        return self

    def getVal(self):
        """
        Une autre méthode qui retourne une "autre" valeur du mot clé facteur.
        Elle est utilisée par la méthode getMocle
        """
        return [self]

    def __getitem__(self, key):
        """
        Dans le cas d un mot cle facteur unique on simule une liste de
        longueur 1
        """
        if key == 0:
            return self
        return self.getMocle(key)

    def accept(self, visitor):
        """
        Cette methode permet de parcourir l'arborescence des objets
        en utilisant le pattern VISITEUR
        """
        visitor.visitMCFACT(self)

    def makeobjet(self):
        return self.definition.class_instance(
            val=None, nom=self.nom, definition=self.definition, parent=self.parent
        )
