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
"""
from builtins import str
from builtins import object
import types, os, sys
from copy import copy, deepcopy
from uuid import uuid1

# import du chargeur de composants
from InterfaceGUI.Common.comploader import makeObjecttreeitem
from Accas.accessor import CONNECTOR
from Accas.extensions.eficas_translation import tr
from Accas.extensions.eficas_exception import EficasException

from reprlib import Repr

myrepr = Repr()
myrepr.maxstring = 100
myrepr.maxother = 100


class TreeItem(object):

    """Abstract class representing tree items.

    Methods should typically be overridden, otherwise a default action
    is used.

    """

    # itemNode est une factory qui doit retourner un objet de la classe Node
    # ou derive de cette classe.
    # Le widget arbre utilisera cet objet comme noeud associe au tree item.
    # Par defaut, utilise la classe Node de base
    # La signature de la factory est la suivante :
    # itemNode(treeOrNode,item,command,rmenu)
    # ou treeOrNode est le noeud parent, item est l'item associe
    # command est une fonction python appelee sur selection graphique
    # du noeud et rmenu est une fonction python appelee sur click droit sur le noeud
    itemNode = None

    def __init__(self):
        """Constructor.  Do whatever you need to do."""

    def getText(self):
        """Return text string to display."""

    def getLabelText(self):
        """Return label text string to display in front of text (if any)."""

    expandable = None

    def _isExpandable(self):
        if self.expandable is None:
            self.expandable = self.isExpandable()
        return self.expandable

    def isExpandable(self):
        """Return whether there are subitems."""
        return 1

    def _getSubList(self):
        """Do not override!  Called by TreeNode."""
        if not self.isExpandable():
            return []
        sublist = self.getSubList()
        if not sublist:
            self.expandable = 0
        return sublist

    def IsEditable(self):
        """Return whether the item's text may be edited."""
        pass

    def SetText(self, text):
        """Change the item's text (if it is editable)."""
        pass

    def getIconName(self):
        """Return name of icon to be displayed normally."""
        pass

    def getSelectedIconName(self):
        """Return name of icon to be displayed when selected."""
        pass

    def getSubList(self):
        """Return list of items forming sublist."""
        pass

    def onDoubleClick(self):
        """Called on a double-click on the item."""
        pass


class Delegate(object):
    def __init__(self, delegate=None):
        self.object = delegate
        self.__cache = {}

    def setDelegate(self, delegate):
        self.resetcache()
        self.object = delegate

    def getDelegate(self):
        return self.object

    def __getattr__(self, name):
        attr = getattr(self.object, name)  # May raise AttributeError
        setattr(self, name, attr)
        self.__cache[name] = attr
        return attr

    def resetcache(self):
        for key in list(self.__cache.keys()):
            try:
                delattr(self, key)
            except AttributeError:
                pass
        self.__cache.clear()

    def cachereport(self):
        keys = list(self.__cache.keys())
        keys.sort()
        # print keys


class ObjectTreeItem(TreeItem, Delegate):
    def __init__(self, appliEficas, labeltext, object, setFunction=None):
        self.labeltext = labeltext
        self.appliEficas = appliEficas
        # L'objet delegue est stocke dans l'attribut object
        # L'objet associe a l'item est stocke dans l'attribut _object
        # Il peut etre obtenu par appel a la methode getObject
        # Attention : le delegue peut etre different de l'objet associe (MCLIST)
        # Dans le cas d'une MCListe de longueur 1, l'objet associe est la MCListe
        # et l'objet delegue est le MCFACT (object = _object.data[0])
        Delegate.__init__(self, object)
        # On cache l'objet initial (pour destruction eventuelle
        # ulterieure)
        self._object = object
        self.setFunction = setFunction
        self.expandable = 1
        self.sublist = []
        self.init()


        # La partie suivante  ne sert que pour le Web
        # on met le meme id au noeud et a l objet
        # utile pour les MCList
        if hasattr(object, "idUnique"):
            self.idUnique = object.idUnique
        else:
            self.idUnique = uuid1().hex

        if self._object.nature == "MCList" and len(self._object.data) == 1:
            # pour les suppressions on met le meme id a l objet et a la liste
            self._object.data[0].idUnique = self.idUnique
            self._object.idUnique = self._object.data[0].idUnique
            #if hasattr(self.appliEficas, "dicoIdNode"):
            #    self.appliEficas.dicoIdNode[self._object.data[0].idUnique] = self
            #22 fevrier. pourquoi ?
            self.idUnique = 0
            return

        self._object.idUnique = self.idUnique
        #print (self, self._object.nom, self.idUnique)
        #if hasattr(self.appliEficas, "dicoIdNode") and self.idUnique:
        #    self.appliEficas.dicoIdNode[self.idUnique] = self

    def init(self):
        return

    def getObject(self):
        return self._object

    def connect(self, channel, callable, args):
        """Connecte la fonction callable (avec arguments args) a l'item self sur le
        canal channel
        """
        # print self,channel,callable,args
        CONNECTOR.Connect(self._object, channel, callable, args)
        CONNECTOR.Connect(self.object, channel, callable, args)

    def copy(self):
        """
        Cree un item copie de self
        """
        object = self._object.copy()
        appliEficas = copy(self.appliEficas)
        labeltext = copy(self.labeltext)
        fonction = deepcopy(self.setFunction)
        item = makeObjecttreeitem(appliEficas, labeltext, object, fonction)
        return item

    def isActif(self):
        if hasattr(self.object, "actif"):
            return self.object.actif
        else:
            return 1

    def update(self, item):
        """
        Met a jour l'item courant a partir d'un autre item passe en argument
        Ne fait rien par defaut
        """
        pass

    def getLabelText(self):
        """Retourne 3 valeurs :
        - le texte a afficher dans le noeud representant l'item
        - la fonte dans laquelle afficher ce texte
        - la couleur du texte
        """
        # None --> fonte et couleur par defaut
        return tr(self.labeltext), None, None

    def getNature(self):
        """
        Retourne la nature de l'item et de l'objet
        """
        return self.object.nature

    def getRegles(self):
        """retourne les regles de l'objet pointe par self"""
        # Attention aux MCList
        # on prend le 1er : tous ont la meme regle
        if self.object.isMCList(): 
           return self.object[0].getRegles()
        return self.object.getRegles()

    def getListeMcPresents(self):
        """Retourne la liste des mots-cles fils de l'objet pointe par self"""
        return self.object.listeMcPresents()

    def getVal(self):
        """Retourne le nom de la valeur de l'objet pointe par self dans le cas
        ou celle-ci est un objet (ASSD)"""
        return self.object.getVal()

    def get_definition(self):
        """
        Retourne l'objet definition de l'objet pointe par self
        """
        return self.object.definition

    def getListeMcOrdonnee(self, liste, dico):
        """retourne la liste ordonnee (suivant le catalogue) brute des mots-cles
        d'une entite composee dont le chemin complet est donne sous forme
        d'une liste du type :ETAPE + MCFACT ou MCBLOC + ...
        il faut encore rearranger cette liste (certains mots-cles deja
        presents ne doivent plus etre proposes, regles ...)"""
        return self.object.getListeMcOrdonnee(liste, dico)

    def getListeMcOrdonneeBrute(self, liste, dico):
        """
        retourne la liste ordonnee (suivant le catalogue) BRUTE des mots-cles
        d'une entite composee dont le chemin complet est donne sous forme
        d'une liste du type :ETAPE + MCFACT ou MCBLOC + ...
        """
        return self.object.getListeMcOrdonneeBrute(liste, dico)

    def getGenealogie(self):
        """
        Retourne la liste des noms des ascendants (noms de MCSIMP,MCFACT,MCBLOC ou ETAPE)
        de l'objet pointe par self
        """
        return self.object.getGenealogie()

    def getIndexChild(self, nom_fils):
        """
        Retourne l'index dans la liste des fils de self du nouveau fils de nom nom_fils
        Necessaire pour savoir a quelle position dans la liste des fils il faut ajouter
        le nouveau mot-cle
        """
        return self.object.getIndexChild(nom_fils)

    def getIndexChild_old(self, nom_fils):
        """
        Retourne l'index dans la liste des fils de self du nouveau fils de nom nom_fils
        Necessaire pour savoir a quelle position dans la liste des fils il faut ajouter
        le nouveau mot-cle
        """
        liste_noms_mc_ordonnee = self.getListeMcOrdonneeBrute(
            self.getGenealogie(), self.getJdc().dicoCataOrdonne
        )
        liste_noms_mc_presents = self.object.listeMcPresents()
        l = []
        for nom in liste_noms_mc_ordonnee:
            if nom in liste_noms_mc_presents or nom == nom_fils:
                l.append(nom)
        # l contient les anciens mots-cles + le nouveau dans l'ordre
        return l.index(nom_fils)

    def appendChild(self, name, pos=None):
        """
        Permet d'ajouter un item fils a self
        """
        if pos == "first":
            index = 0
        elif pos == "last":
            index = len(self.listeMcPresents())
        elif type(pos) == int:
            # la position est fixee
            index = pos
        # elif type(pos) == types.InstanceType:
        elif type(pos) == object:
            # pos est un item. Il faut inserer name apres pos
            index = self.getIndex(pos) + 1
        # elif type(name) == types.InstanceType:
        elif type(name) == object:
            index = self.getIndexChild(name.nom)
        else:
            index = self.getIndexChild(name)
        return self.addobject(name, index)

    def appendBrother(self, name, pos="after"):
        """
        Permet d'ajouter un frere a self
        par defaut on l'ajoute apres self
        """
        index = self._object.parent.getIndex(self.getObject())
        if pos == "before":
            index = index
        elif pos == "after":
            index = index + 1
        else:
            print((tr("%d n'est pas un index valide pour appendBrother", pos)))
            return
        return self.parent.addobject(name, index)

    def getCopieObjet(self):
        """Retourne une copie de l'objet pointe par self"""
        return self.object.copy()

    def getPosition(self):
        """Retourne la valeur de l'attribut position de l'objet pointe par self"""
        definition = self.get_definition()
        try:
            return getattr(definition, "position")
        except AttributeError:
            return "local"

    def getNom(self):
        """Retourne le nom de l'objet pointe par self"""
        return self.object.nom

    def getJdc(self):
        """Retourne le jdc auquel appartient l'objet pointe par self"""
        return self.object.jdc

    def getValeur(self):
        """Retourne la valeur de l'objet pointe par self"""
        return self.object.valeur

    def getCr(self):
        """Retourne le compte-rendu CR de self"""
        return self.object.report()

    def getObjetCommentarise(self):
        """
        Cette methode retourne un objet commentarise
        representatif de self.object
        --> a surcharger par les differents items
        """
        raise EficasException(
            "MESSAGE AU DEVELOPPEUR : il faut \
                                 surcharger la methode getObjetCommentarise() \
                                 pour la classe %s",
            self.__class__.__name__,
        )

    def isValid(self):
        """Retourne 1 si l'objet pointe par self est valide, 0 sinon"""
        return self.object.isValid()

    def isCopiable(self):
        """
        Retourne 1 si l'objet est copiable, 0 sinon
        Par defaut retourne 0
        """
        return 0

    def getMcPresents(self):
        """Retourne le dictionnaire des mots-cles presents de l'objet pointe par self"""
        return self.object.dictMcPresents()

    def verifConditionRegles(self, l_mc_presents):
        return self.object.verifConditionRegles(l_mc_presents)

    def getFr(self):
        """Retourne le fr de l'objet pointe par self"""
        try:
            return self.object.getFr()
        except:
            return ""

    def getDocu(self):
        """Retourne la cle de doc de l'objet pointe par self"""
        return self.object.getDocu()

    def setValeur(self, new_valeur):
        """Remplace la valeur de l'objet pointe par self par new_valeur"""
        return self.object.setValeur(new_valeur)

    def getText(self):
        return myrepr.repr(self.object)

    def getIconName(self):
        if not self.isExpandable():
            return "python"

    def IsEditable(self):
        return self.setFunction is not None

    def SetText(self, text):
        try:
            value = eval(text)
            self.setFunction(value)
        except:
            pass

    def isExpandable(self):
        return 1

    def getSubList(self):
        keys = dir(self.object)
        sublist = []
        for key in keys:
            try:
                value = getattr(self.object, key)
            except AttributeError:
                continue
            item = makeObjecttreeitem(
                self.appliEficas,
                str(key) + " =",
                value,
                lambda value, key=key, object=self.object: setattr(object, key, value),
            )
            sublist.append(item)
        return sublist

        # a piori inutile PN 06 11 17
        # def wait_fichier_init(self):
        """ Retourne 1 si l'object pointe par self attend un fichier d'initialisation
        (ex: macros POURSUITE et INCLUDE de Code_Aster), 0 SINON """

    #    return self.object.definition.fichier_ini

    def makeObjecttreeitem(self, appliEficas, labeltext, object, setFunction=None):
        """
        Cette methode, globale pour les objets de type item, permet de construire et de retourner un objet
        de type item associe a l'object passe en argument.
        """
        return makeObjecttreeitem(appliEficas, labeltext, object, setFunction)

    # def __del__(self):
    #    print "__del__",self


class AtomicObjectTreeItem(ObjectTreeItem):
    def isExpandable(self):
        return 0


class SequenceTreeItem(ObjectTreeItem):
    def isExpandable(self):
        return len(self._object) > 0

    def __len__(self):
        return len(self._object)

    def keys(self):
        return list(range(len(self._object)))

    def getIconName(self):
        if self._object.isValid():
            return "ast-green-los"
        elif self._object.isOblig():
            return "ast-red-los"
        else:
            return "ast-yel-los"

    def ajoutPossible(self):
        return self._object.ajoutPossible()

    def getIndex(self, child):
        """Retourne le numero de child dans la liste des enfants de self"""
        return self._object.getIndex(child.getObject())

    def getText(self):
        return "    "

    def addItem(self, obj, pos):
        self._object.insert(pos, obj)
        item = self.makeObjecttreeitem(self.appliEficas, obj.nom + ":", obj)
        return item

    def suppItem(self, item):
        try:
            self._object.remove(item.getObject())
            # la liste peut etre retournee vide !
            message = "Mot-clef " + item.getObject().nom + " supprime"
            self.appliEficas.afficheMessages(message)
            return 1
        except:
            return 0

    def getSubList(self):
        isublist = iter(self.sublist)
        liste = self._object.data
        iliste = iter(liste)
        self.sublist = []

        while 1:
            old_obj = obj = None
            for item in isublist:
                old_obj = item.getObject()
                if old_obj in liste:
                    break

            for obj in iliste:
                if obj is old_obj:
                    break

                # nouvel objet : on cree un nouvel item
                def setFunction(value, object=obj):
                    object = value

                it = self.makeObjecttreeitem(
                    self.appliEficas, obj.nom + " : ", obj, setFunction
                )
                self.sublist.append(it)
            if old_obj is None and obj is None:
                break
            if old_obj is obj:
                self.sublist.append(item)
        return self.sublist
