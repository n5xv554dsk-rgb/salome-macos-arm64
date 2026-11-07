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
    Ce module contient la classe MCList qui sert à controler la valeur
    d'une liste de mots-clés facteur par rapport à sa définition portée par un objet
    de type ENTITE
"""
from copy import copy
import types
from collections import UserList

class MCList(UserList):

    """Liste semblable a la liste Python
    mais avec quelques methodes en plus
    = liste de MCFACT
    """

    nature = "MCList"

    def init(self, nom, parent):
        self.objPyxbDeConstruction = None
        self.definition = None
        self.nom = nom
        self.parent = parent
        if parent:
            self.jdc = self.parent.jdc
            self.niveau = self.parent.niveau
            self.etape = self.parent.etape
        else:
            # Le mot cle a été créé sans parent
            self.jdc = None
            self.niveau = None
            self.etape = None

    def getValeur(self):
        """
        Retourne la "valeur" d'un objet MCList. Sert à construire
        un contexte d'évaluation pour une expression Python.
        On retourne l'objet lui-meme.
        """
        return self

    def getVal(self):
        """
        Une autre méthode qui retourne une "autre" valeur d'une MCList
        Elle est utilisée par la méthode getMocle
        """
        return self

    def supprime(self):
        """
        Méthode qui supprime toutes les références arrières afin que l'objet puisse
        etre correctement détruit par le garbage collector
        """
        self.parent = None
        self.etape = None
        self.jdc = None
        self.niveau = None
        for child in self.data:
            child.supprime()

    def getChild(self, name, restreint="non"):
        """
        Retourne le fils de nom name s'il est contenu dans self
        Par défaut retourne le fils du premier de la liste
        """
        obj = self.data[0]
        # Phase 1 : on cherche dans les fils directs de obj
        for child in obj.mcListe:
            if child.nom == name:
                return child
        # Phase 2 : on cherche dans les blocs de self
        for child in obj.mcListe:
            if child.isBLOC():
                resu = child.getChild(name)
                if resu != None:
                    return resu
        # Phase 3 : on cherche dans les entites possibles pour les défauts
        for k, v in list(obj.definition.entites.items()):
            # if k == name: return v.defaut
            if k == name:
                if v.defaut != None:
                    return v(None, k, None)
        # si on passe ici, c'est que l'on demande un fils qui n'est pas possible --> erreur
        # print "Erreur : %s ne peut etre un descendant de %s" %(name,self.nom)
        return None

    def getAllChild(self, name):
        # A utiliser uniquement dans un filtre
        maListeRetour = MCList()
        for obj in self.data:
            for objFils in obj.getChild(name):
                maListeRetour.append(objFils)
        return maListeRetour

    def isBLOC(self):
        """
        Indique si l'objet est de type BLOC
        """
        return 0

    def accept(self, visitor):
        """
        Cette methode permet de parcourir l'arborescence des objets
        en utilisant le pattern VISITEUR
        """
        visitor.visitMCList(self)

    def getSd_utilisees(self):
        """
        Retourne la liste des concepts qui sont utilisés à l'intérieur de self
        ( comme valorisation d'un MCS)
        """
        l = []
        for child in self.data:
            l.extend(child.getSd_utilisees())
        return l

    def getSdMCSUtilisees(self):
        """
        Retourne la ou les SD utilisée par self sous forme d'un dictionnaire :
          - Si aucune sd n'est utilisée, le dictionnaire est vide.
          - Sinon, les clés du dictionnaire sont les mots-clés derrière lesquels on
            trouve des sd ; la valeur est la liste des sd attenante.

            Exemple ::

              { 'VALE_F': [ <Cata.cata.fonction_sdaster instance at 0x9419854>,
                            <Cata.cata.fonction_sdaster instance at 0x941a204> ],
                'MODELE': [<Cata.cata.modele instance at 0x941550c>] }
        """
        dico = {}
        for child in self.data:
            daux = child.getSdMCSUtilisees()
            for cle in daux:
                dico[cle] = dico.get(cle, [])
                dico[cle].extend(daux[cle])
        return dico

    def getMcsWithCo(self, co):
        """
        Cette methode retourne l'objet MCSIMP fils de self
        qui a le concept co comme valeur.
        En principe, elle ne doit etre utilisee que pour les concepts
        instances de la classe CO
        """
        l = []
        for child in self.data:
            l.extend(child.getMcsWithCo(co))
        return l

    def getAllCo(self):
        """
        Cette methode retourne tous les concepts instances de CO
        """
        l = []
        for child in self.data:
            l.extend(child.getAllCo())
        return l

    def copy(self):
        """
        Réalise la copie d'une MCList
        """
        liste = self.data[0].definition.list_instance()
        # FR -->Il faut spécifier un parent pour la méthode init qui attend 2
        # arguments ...
        liste.init(self.nom, self.parent)
        for objet in self:
            new_obj = objet.copy()
            # Pour etre coherent avec le constructeur de mots cles facteurs P_FACT.__call__
            # dans lequel le parent de l'element d'une MCList est le parent de
            # la MCList
            new_obj.reparent(self.parent)
            liste.append(new_obj)
        return liste

    def reparent(self, parent):
        """
        Cette methode sert a reinitialiser la parente de l'objet
        """
        self.parent = parent
        self.jdc = parent.jdc
        self.etape = parent.etape
        for mcfact in self.data:
            mcfact.reparent(parent)

    def getEtape(self):
        """
        Retourne l'étape à laquelle appartient self
        Un objet de la catégorie etape doit retourner self pour indiquer que
        l'étape a été trouvée
        XXX double emploi avec self.etape ???
        """
        if self.parent == None:
            return None
        return self.parent.getEtape()

    def __getitem__(self, key):
        """
        Dans le cas d un mot cle facteur de longueur 1 on simule un scalaire
        """
        if type(key) != int and len(self) == 1:
            return self.data[0].getMocle(key)
        else:
            return self.data[key]

    def List_F(self):
        """
        Retourne une liste de dictionnaires (eventuellement singleton) qui peut etre
        passe directement derriere un mot-cle facteur (pour les macros).
        """
        dresu = []
        for mcf in self:
            dico = mcf.creeDictValeurs(mcf.mcListe)
            for i in list(dico.keys()):
                if dico[i] == None:
                    del dico[i]
            dresu.append(dico)
        return dresu

    def longueurDsArbre(self):
        # pour Pyxb : longueur  dans le orderedcontent de pyxb
        return len(self)
    def longueurDsArbreAvecConsigne(self):
        return self.longueurDsArbre()
