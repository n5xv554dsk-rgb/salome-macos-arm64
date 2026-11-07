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

import traceback


# -------------
class JDCTree:
# --------------

    def __init__(self, jdcItem, editor):
    # ----------------------------------
        self.editor = editor
        self.item = jdcItem
        self.tree = self
        self.appliEficas = self.editor.appliEficas
        self.childrenComplete = []
        self.plie = False
        self.racine = self.item.itemNode(self, self.item)
        self.affichePremier()

    def affichePremier(self):
    # -----------------------
        if self.racine.children != []:
            self.racine.children[0].affichePanneau()


# -----------
class JDCNode:
# -------------
    def __init__( self, treeParent, item, itemExpand=False, ancien=False, creeChildren=True):
    # -----------------------------------------------------------------------------------------
        #print ("creation d'un noeud : ", item, " ",item.nom,"", treeParent, self)
        self.item = item
        self.vraiParent = treeParent
        self.treeParent = treeParent
        self.tree = self.treeParent.tree
        self.editor = self.treeParent.editor
        self.appliEficas = treeParent.appliEficas
        self.appartientAUnNoeudPlie = False
        self.childrenComplete = []

        self.treeParent = treeParent
        # while (isinstance(self.treeParent,compobloc.Node) or ( isinstance(self.treeParent,compomclist.Node) and self.treeParent.item.isMCList())) :
        #    self.treeParent.childrenComplete.append(self)
        #    self.treeParent=self.treeParent.vraiParent
        self.treeParent.childrenComplete.append(self)
        self.item.connect("redessine", self.onRedessine, ())

        self.buildChildren()

    def buildChildren(self):
    # -----------------------
        """Construit la liste des enfants de self"""
        """ Se charge de remettre les noeuds Expanded dans le meme etat """
        debug = 0
        if debug: print("*********** buildChildren ", self, self.item, self.item.nom)

        self.listeItemExpanded = []
        self.listeItemPlie = []

        for enfant in self.childrenComplete:
            if enfant.plie:
                self.listeItemPlie.append(enfant.item)
            else:
                self.listeItemExpanded.append(enfant.item)

        self.children = []
        self.childrenComplete = []
        sublist = self.item._getSubList()

        for item in sublist:
            itemExpand = False
            ancien = False
            if item in self.listeItemExpanded:
                itemExpand = True
                ancien = True
            if item in self.listeItemPlie:
                itemExpand = False
                ancien = True
            nouvelItem = item.itemNode(self, item, itemExpand, ancien)
            self.children.append(nouvelItem)

    def affichePanneau(self):
    # -------------------------
        debug = 0
        if debug: print("dans affichePanneau pour", self.item.nom)
        self.fenetre = self.getPanel()

    def onRedessine(self):
    # -----------------------
        debug = 0
        if debug : print ('dans onRedessine', self.item.nom)
        self.treeParent.widget.redessineWidget(self, self.widget)

  
