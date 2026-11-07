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
    Ce module contient la classe MCBLOC qui sert à controler la valeur
    d'un bloc de mots-clés par rapport à sa définition portée par un objet
    de type ENTITE
"""


import types
from Accas.processing import P_MCCOMPO


class MCBLOC(P_MCCOMPO.MCCOMPO):

    """
    Classe support d'un bloc de mots-clés.

    """

    nature = "MCBLOC"

    def __init__(self, val, definition, nom, parent, dicoPyxbDeConstruction=None):
        """
        Attributs :

         - val : valeur du bloc (dictionnaire dont les clés sont des noms de mots-clés et les valeurs
                 les valeurs des mots-clés)
         - definition : objet de définition de type BLOC associé au bloc (porte les attributs de définition)
         - nom : nom du bloc. Ce nom lui est donné par celui qui crée le bloc de mot-clé
         - parent : le créateur du bloc. Ce peut etre un mot-clé facteur ou un autre objet composite de type
                    OBJECT. Si parent vaut None, le bloc ne possède pas de contexte englobant.
         - mcListe : liste des sous-objets du bloc construite par appel à la méthode buildMc
        """
        # print ('MCBLOC' ,  val, definition, nom, parent)
        self.definition = definition
        self.nom = nom
        self.val = val
        self.parent = parent
        self.valeur = val
        self.objPyxbDeConstruction = None
        self.dicoPyxbDeConstruction = dicoPyxbDeConstruction
        self.estIdentifiePar = None
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

    def getValeur(self):
        """
        Retourne la "valeur" de l'objet bloc. Il s'agit d'un dictionnaire dont
        les clés seront les noms des objets de self.mcListe et les valeurs
        les valeurs des objets de self.mcListe obtenues par application de
        la méthode getValeur.

        Dans le cas particulier d'un objet bloc les éléments du dictionnaire
        obtenu par appel de la méthode getValeur sont intégrés au niveau
        supérieur.

        """
        dico = {}
        for mocle in self.mcListe:
            if mocle.isBLOC():
                # Si mocle est un BLOC, on inclut ses items dans le dictionnaire
                # représentatif de la valeur de self. Les mots-clés fils de blocs sont
                # donc remontés au niveau supérieur.
                dico.update(mocle.getValeur())
            else:
                dico[mocle.nom] = mocle.getValeur()

        # On rajoute tous les autres mots-clés locaux possibles avec la valeur
        # par défaut ou None
        # Pour les mots-clés facteurs, on ne traite que ceux avec statut défaut ('d')
        # et caché ('c')
        # On n'ajoute aucune information sur les blocs. Ils n'ont pas de défaut seulement
        # une condition.
        for k, v in list(self.definition.entites.items()):
            if not k in dico:
                if v.label == "SIMP":
                    # Mot clé simple
                    dico[k] = v.defaut
                elif v.label == "FACT":
                    if v.statut in ("c", "d"):
                        # Mot clé facteur avec défaut ou caché provisoire
                        dico[k] = v(val=None, nom=k, parent=self)
                        # On demande la suppression des pointeurs arrieres
                        # pour briser les eventuels cycles
                        dico[k].supprime()
                    else:
                        dico[k] = None

        return dico
    def longueurDsArbreAvecConsigne(self):
        longueur=0
        for mc in self.mcListe :
            longueur = longueur + mc.longueurDsArbreAvecConsigne()
        return longueur

    def longueurDsArbre(self):
        # PN 24/01/22 --> Cette methde n est pas surchage
        # il y a une surchagre sur N_BLOC mais pas sur N_MCBLOC
        # ???
        print ('bizarre, ne devrait on pas surchager la methode')
        return 

    def getAllChildInBloc(self):
    # contrairement a getValeur ne retourne que les enfants de mcListe
        liste=[]
        for mc in self.mcListe:
            if mc.isBLOC():
                for petitfils in mc.getAllChildInBloc() : liste.append(petitfils)
            else:
                liste.append(mc)
        return liste

    def isBLOC(self):
        """
        Indique si l'objet est un BLOC
        """
        return 1

    def accept(self, visitor):
        """
        Cette methode permet de parcourir l'arborescence des objets
        en utilisant le pattern VISITEUR
        """
        visitor.visitMCBLOC(self)

    def makeobjet(self):
        return self.definition(val=None, nom=self.nom, parent=self.parent)
