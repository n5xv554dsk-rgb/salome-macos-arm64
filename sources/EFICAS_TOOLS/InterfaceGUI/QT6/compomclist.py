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


import types
import traceback

from InterfaceGUI.QT6 import compofact
from InterfaceGUI.QT6 import browser
from InterfaceGUI.QT6 import typeNode
from Accas.extensions.eficas_translation import tr

from InterfaceGUI.Common import objecttreeitem
from Accas.processing.P_OBJECT import ErrorObj


class Node(browser.JDCNode, typeNode.PopUpMenuNodeMinimal):
    def createPopUpMenu(self):
        typeNode.PopUpMenuNodeMinimal.createPopUpMenu(self)

    def getPanelGroupe(self, parentQt, commande):
        maDefinition = self.item.get_definition()
        monObjet = self.item.object
        monNom = self.item.nom
        maCommande = commande
        if hasattr(parentQt, "niveau"):
            self.niveau = parentQt.niveau + 1
        else:
            self.niveau = 1
        # attention si l objet est une mclist on utilise bloc
        if not (monObjet.isMCList()):
            if hasattr(self, "plie") and self.plie == True:
                from InterfaceGUI.QT6.monWidgetFactPlie import MonWidgetFactPlie

                widget = MonWidgetFactPlie(
                    self,
                    self.editor,
                    parentQt,
                    maDefinition,
                    monObjet,
                    self.niveau,
                    maCommande,
                )
            elif self.editor.maConfiguration.afficheFirstPlies and self.firstAffiche:
                self.firstAffiche = False
                self.setPlie()
                from InterfaceGUI.QT6.monWidgetFactPlie import MonWidgetFactPlie

                widget = MonWidgetFactPlie(
                    self,
                    self.editor,
                    parentQt,
                    maDefinition,
                    monObjet,
                    self.niveau,
                    maCommande,
                )
            else:
                from InterfaceGUI.QT6.monWidgetFact import MonWidgetFact

                widget = MonWidgetFact(
                    self,
                    self.editor,
                    parentQt,
                    maDefinition,
                    monObjet,
                    self.niveau,
                    maCommande,
                )
        else:
            from InterfaceGUI.QT6.monWidgetBloc import MonWidgetBloc

            widget = MonWidgetBloc(
                self,
                self.editor,
                parentQt,
                maDefinition,
                monObjet,
                self.niveau,
                maCommande,
            )
        return widget

    def doPaste(self, node_selected, pos):
        objet_a_copier = self.item.getCopieObjet()
        # before est un effet de bord heureux sur l index
        child = self.appendBrother(objet_a_copier, "before")
        if self.editor.fenetreCentraleAffichee:
            self.editor.fenetreCentraleAffichee.node.affichePanneau()
        self.update_NodeLabelInBlack()
        self.parent().buildChildren()
        return child


class MCListTreeItem(objecttreeitem.SequenceTreeItem, compofact.FACTTreeItem):
    """La classe MCListTreeItem joue le role d'un adaptateur pour les objets
    du processing Accas instances de la classe MCLIST.
    Elle adapte ces objets pour leur permettre d'etre integres en tant que
    noeuds dans un arbre graphique (voir treewidget.py et ObjectTreeItem.py).
    Cette classe delegue les appels de methode et les acces
    aux attributs a l'objet du processing soit manuellement soit
    automatiquement (voir classe Delegate et attribut object).
    """

    itemNode = Node

    def init(self):
        # Si l'objet Accas (MCList) a moins d'un mot cle facteur
        # on utilise directement ce mot cle facteur comme delegue
        self.updateDelegate()

    def updateDelegate(self):
        if len(self._object) > 1:
            self.setDelegate(self._object)
        else:
            self.setDelegate(self._object.data[0])

    def panel(self, jdcdisplay, pane, node):
        """Retourne une instance de l'objet panneau associe a l'item (self)
        Si la liste ne contient qu'un mot cle facteur, on utilise le panneau
        FACTPanel.
        Si la liste est plus longue on utilise le panneau MCLISTPanel.
        """
        if len(self._object) > 1:
            return MCLISTPanel(jdcdisplay, pane, node)
        elif isinstance(self._object.data[0], ErrorObj):
            return compoerror.ERRORPanel(jdcdisplay, pane, node)
        else:
            return compofact.FACTPanel(jdcdisplay, pane, node)

    def isExpandable(self):
        if len(self._object) > 1:
            return objecttreeitem.SequenceTreeItem.isExpandable(self)
        else:
            return compofact.FACTTreeItem.isExpandable(self)

    def getSubList(self):
        self.updateDelegate()
        if len(self._object) <= 1:
            self._object.data[0].alt_parent = self._object
            return compofact.FACTTreeItem.getSubList(self)

        liste = self._object.data
        sublist = [None] * len(liste)
        # suppression des items lies aux objets disparus
        for item in self.sublist:
            old_obj = item.getObject()
            if old_obj in liste:
                pos = liste.index(old_obj)
                sublist[pos] = item
            else:
                pass  # objets supprimes ignores
        # ajout des items lies aux nouveaux objets
        pos = 0
        for obj in liste:
            if sublist[pos] is None:
                # nouvel objet : on cree un nouvel item
                def setFunction(value, object=obj):
                    object = value

                item = self.makeObjecttreeitem(
                    self.appliEficas, obj.nom + " : ", obj, setFunction
                )
                sublist[pos] = item
                # Attention : on ajoute une information supplementaire pour l'actualisation de
                # la validite. L'attribut parent d'un MCFACT pointe sur le parent de la MCLISTE
                # et pas sur la MCLISTE elle meme ce qui rompt la chaine de remontee des
                # informations de validite. alt_parent permet de remedier a ce defaut.
                obj.alt_parent = self._object
            pos = pos + 1

        self.sublist = sublist
        return self.sublist

    def getIconName(self):
        if self._object.isValid():
            return "ast-green-los"
        elif self._object.isOblig():
            return "ast-red-los"
        else:
            return "ast-yel-los"

    def getDocu(self):
        """Retourne la clef de doc de l'objet pointe par self"""
        return self.object.getDocu()

    def isCopiable(self):
        if len(self._object) > 1:
            return Objecttreeitem.SequenceTreeItem.isCopiable(self)
        else:
            return compofact.FACTTreeItem.isCopiable(self)

    def isMCFact(self):
        """
        Retourne 1 si l'objet pointe par self est un MCFact, 0 sinon
        """
        return len(self._object) <= 1

    def isMCList(self):
        """
        Retourne 1 si l'objet pointe par self est une MCList, 0 sinon
        """
        return len(self._object) > 1

    def getCopieObjet(self):
        return self._object.data[0].copy()

    def addItem(self, obj, pos):
        # print "compomclist.addItem",obj,pos
        if len(self._object) <= 1:
            return compofact.FACTTreeItem.addItem(self, obj, pos)

        o = self.object.addEntite(obj, pos)
        return o

    def suppItem(self, item):
        """
        Retire un objet MCFACT de la MCList (self.object)
        """
        # print "compomclist.suppItem",item
        obj = item.getObject()
        if len(self._object) <= 1:
            return compofact.FACTTreeItem.suppItem(self, item)

        if self.object.suppEntite(obj):
            if len(self._object) == 1:
                self.updateDelegate()
            message = "Mot-clef " + obj.nom + " supprime"
            return (1, message)
        else:
            return (0, tr("Impossible de supprimer ce mot-clef"))


import Accas

objet = Accas.MCList


def treeitem(appliEficas, labeltext, object, setFunction):
    """Factory qui produit un objet treeitem adapte a un objet
    Accas.MCList (attribut objet de ce module)
    """
    return MCListTreeItem(appliEficas, labeltext, object, setFunction)
