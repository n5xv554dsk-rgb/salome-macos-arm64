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

# Modules Python

import os, sys
import types
import traceback

# Modules Eficas
from InterfaceGUI.Common import objecttreeitem
from Accas.extensions.eficas_translation import tr
from InterfaceGUI.QT5 import compooper
from InterfaceGUI.QT5 import browser
from InterfaceGUI.QT5 import typeNode


class MACRONode(browser.JDCNode, typeNode.PopUpMenuNode):
    def getPanel(self):
        from InterfaceGUI.QT5.monWidgetCommande import MonWidgetCommande

        return MonWidgetCommande(self, self.editor, self.item.object)

    def createPopUpMenu(self):
        typeNode.PopUpMenuNode.createPopUpMenu(self)


#    def view3D(self) :
#        from InterfaceGUI.QT5.Editeur import TroisDPal
#        troisD=TroisDPal.TroisDPilote(self.item,self.editor.appliEficas)
#        troisD.envoievisu()


class MACROTreeItem(compooper.EtapeTreeItem):
    #  """ Cette classe herite d'une grande partie des comportements
    #      de la classe compooper.EtapeTreeItem
    #  """
    itemNode = MACRONode


# ------------------------------------
#  Classes necessaires a INCLUDE
# ------------------------------------


class INCLUDETreeItemBase(MACROTreeItem):
    def __init__(self, appliEficas, labeltext, object, setFunction):
        MACROTreeItem.__init__(self, appliEficas, labeltext, object, setFunction)

    def isCopiable(self):
        return 0


class INCLUDENode(browser.JDCNode, typeNode.PopUpMenuNode):
    def getPanel(self):
        from InterfaceGUI.QT5.monWidgetCommande import MonWidgetCommande

        return MonWidgetCommande(self, self.editor, self.item.object)

    def createPopUpMenu(self):
        typeNode.PopUpMenuNode.createPopUpMenu(self)

    def makeEdit(self):  # ,appliEficas,node
        if self.item.object.text_converted == 0:
            # Le texte du fichier inclus n'a pas pu etre converti par le module convert
            msg = tr(
                "Le fichier de commande n'a pas pu etre converti pour etre editable par Eficas\n\n"
            )
            msg = msg + self.item.object.text_error
            return

        if not hasattr(self.item.object, "jdc_aux") or self.item.object.jdc_aux is None:
            # L'include n'est pas initialise
            self.item.object.buildInclude(None, "")

        # On cree un nouvel onglet dans le bureau
        self.editor.vm.displayJDC(
            self.item.object.jdc_aux, self.item.object.jdc_aux.nom
        )


class INCLUDETreeItem(INCLUDETreeItemBase):
    itemNode = INCLUDENode


# ------------------------------------
#  Classes necessaires a POURSUITE
# ------------------------------------


class POURSUITENode(browser.JDCNode, typeNode.PopUpMenuNode):
    def getPanel(self):
        from InterfaceGUI.QT5.monWidgetCommande import MonWidgetCommande

        return MonWidgetCommande(self, self.editor, self.item.object)

    def createPopUpMenu(self):
        typeNode.PopUpMenuNode.createPopUpMenu(self)

    def makeEdit(self):  # ,appliEficas,node
        if self.item.object.text_converted == 0:
            msg = tr(
                "Le fichier de commande n'a pas pu etre converti pour etre editable par Eficas\n\n"
            )
            msg = msg + self.item.object.text_error
            return

        if not hasattr(self.item.object, "jdc_aux") or self.item.object.jdc_aux is None:
            text = """DEBUT()
                    FIN()"""
            self.object.buildPoursuite(None, text)

        # On cree un nouvel onglet dans le bureau
        self.editor.vm.displayJDC(
            self.item.object.jdc_aux, self.item.object.jdc_aux.nom
        )


class POURSUITETreeItem(INCLUDETreeItemBase):
    itemNode = POURSUITENode


# ----------------------------------------
#  Classes necessaires a INCLUDE MATERIAU
# ----------------------------------------


class MATERIAUNode(MACRONode):
    def getPanel(self):
        from InterfaceGUI.QT5.monWidgetCommande import MonWidgetCommande

        return MonWidgetCommande(self, self.editor, self.item.object)

    def createPopUpMenu(self):
        typeNode.PopUpMenuNode.createPopUpMenu(self)

    def makeView(self):
        if (
            hasattr(self.item.object, "fichier_ini")
            and self.item.object.fichier_ini == None
        ):
            QMessageBox.information(
                self,
                tr("Include vide"),
                tr("L'include doit etre correctement initialise pour etre visualise"),
            )
            return
        f = open(self.item.object.fichier_ini, "rb")
        texte = f.read()
        f.close()
        from InterfaceGUI.QT5.desVisu import DVisu

        monVisuDialg = DVisu(parent=self.editor.appliEficas, fl=0)
        monVisuDialg.TB.setText(texte)
        monVisuDialg.show()


class INCLUDE_MATERIAUTreeItem(INCLUDETreeItemBase):
    itemNode = MATERIAUNode


# ------------------------------------
# TreeItem
# ------------------------------------


def treeitem(appliEficas, labeltext, object, setFunction=None):
    """Factory qui retourne l'item adapte au type de macro :
    INCLUDE, POURSUITE, MACRO
    """
    if object.nom == "INCLUDE_MATERIAU":
        return INCLUDE_MATERIAUTreeItem(appliEficas, labeltext, object, setFunction)
    elif object.nom == "INCLUDE" or object.nom == "DICTDATA":
        return INCLUDETreeItem(appliEficas, labeltext, object, setFunction)
    elif object.nom == "POURSUITE":
        return POURSUITETreeItem(appliEficas, labeltext, object, setFunction)
    else:
        return MACROTreeItem(appliEficas, labeltext, object, setFunction)


import Accas

objet = Accas.MACRO_ETAPE
