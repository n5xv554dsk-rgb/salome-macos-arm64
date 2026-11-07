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

import types, os

# Modules Eficas
from Accas.extensions.eficas_translation import tr

from InterfaceGUI.QT5.feuille import Feuille
from UiQT5.desWidgetCB import Ui_WidgetCB
from InterfaceGUI.Common.politiquesValidation import PolitiqueUnique
from InterfaceGUI.QT5.traiteSaisie import SaisieValeur

from PyQt5.QtWidgets import QComboBox, QCompleter
from PyQt5.QtCore import Qt, QEvent


class MonWidgetCBCommun(Feuille):
    def __init__(self, node, monSimpDef, nom, objSimp, parentQt, commande):
        Feuille.__init__(self, node, monSimpDef, nom, objSimp, parentQt, commande)
        self.politique = PolitiqueUnique(self.node, self.editor)
        self.determineChoix()
        self.setValeursApresBouton()
        self.CBChoix.currentIndexChanged.connect(self.choixSaisi)
        self.CBChoix.wheelEvent = self.wheelEvent
        if hasattr(self.parentQt, "commandesLayout"):
            self.parentQt.commandesLayout.insertWidget(-1, self)
        self.maCommande.listeAffichageWidget.append(self.CBChoix)
        self.AAfficher = self.CBChoix

    def setValeursApresBouton(self):
        # print (self.objSimp.getValeur())
        if (
            self.node.item.definition.homo == "constant"
            and self.objSimp.getValeur() == None
        ):
            self.CBChoix.addItem(tr("Choisir dans la partie probabiliste"))
            self.CBChoix.setCurrentIndex(
                self.CBChoix.findText(tr("Choisir dans la partie probabiliste"))
            )
            self.CBChoix.setEnabled(0)
            return
        if self.objSimp.getValeur() == None:
            self.CBChoix.setCurrentIndex(-1)
            self.CBChoix.lineEdit().setText(tr("Select"))
            return
        valeur = self.objSimp.getValeur()
        if not (type(valeur) == str):
            valeur = str(valeur)
        self.CBChoix.setCurrentIndex(self.CBChoix.findText(valeur))

    def determineChoix(self):
        listeChoix = []
        if self.maListeDeValeur == None:
            self.maListeDeValeur = []
        for choix in self.maListeDeValeur:
            if not (type(choix) == str):
                choix = str(choix)
            listeChoix.append(choix)
            self.CBChoix.addItem(choix)
        if self.node.item.definition.homo == "constant":
            self.CBChoix.setEnabled(0)
            if self.objSimp.getValeur() != None:
                self.CBChoix.setStyleSheet(
                    (
                        "\n"
                        "QComboBox {\n"
                        "    border: 1px solid gray;\n"
                        "    background: rgb(0,255,0);\n"
                        "    color: rgb(24,24,7);\n"
                        "    }\n"
                        "QComboBox::drop-down {\n"
                        "       image: none; \n"
                        " }"
                    )
                )
        else:
            self.CBChoix.setEditable(True)
            monCompleteur = QCompleter(listeChoix, self)
            monCompleteur.setCompletionMode(QCompleter.PopupCompletion)
            self.CBChoix.setCompleter(monCompleteur)

    def choixSaisi(self):
        self.CBChoix.lineEdit().setStyleSheet(
            (
                "\n"
                "QLineEdit {\n"
                "     font : italic ;\n"
                "     background: rgb(235,235,235);\n"
                " }"
            )
        )
        valeur = str(self.CBChoix.currentText())
        SaisieValeur.LEvaleurPressed(self, valeur)
        self.reaffiche()

    def wheelEvent(self, event):
        # Sinon poum sur les fenetres trop longues
        # lorsque la widget attrape le wheelevent
        event.ignore()

 


class MonWidgetCB(Ui_WidgetCB, MonWidgetCBCommun):
    def __init__(self, node, monSimpDef, nom, objSimp, parentQt, commande):
        self.maListeDeValeur = monSimpDef.into
        MonWidgetCBCommun.__init__(
            self, node, monSimpDef, nom, objSimp, parentQt, commande
        )


class MonWidgetCBSD(Ui_WidgetCB, MonWidgetCBCommun):
    def __init__(self, node, monSimpDef, nom, objSimp, parentQt, commande):
        self.maListeDeValeur = node.item.getSdAvantDuBonType()
        MonWidgetCBCommun.__init__(
            self, node, monSimpDef, nom, objSimp, parentQt, commande
        )
