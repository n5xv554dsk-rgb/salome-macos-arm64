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


class MonWidgetCB(Ui_WidgetCB, Feuille):
    def __init__(self, node, monSimpDef, nom, objSimp, parentQt, commande):
        Feuille.__init__(self, node, monSimpDef, nom, objSimp, parentQt, commande)
        self.politique = PolitiqueUnique(self.node, self.editor)
        self.determineChoix()
        self.setValeursApresBouton()
        self.CBChoix.currentIndexChanged.connect(self.choixSaisi)

        self.parentQt.commandesLayout.insertWidget(-1, self)
        self.maCommande.listeAffichageWidget.append(self.CBChoix)
        # print self.objSimp.isOblig()

    def setValeursApresBouton(self):
        if self.objSimp.getValeur() == None:
            self.CBChoix.setCurrentIndex(-1)
            return
        valeur = self.objSimp.getValeur()
        if not (type(valeur) == str):
            valeur = str(valeur)
        self.CBChoix.setCurrentIndex(self.CBChoix.findText(valeur))

    def determineChoix(self):
        self.CBChoix.currentIndexChanged.connect(self.choixSaisi)

        for choix in self.monSimpDef.into:
            if not (type(choix) == str):
                choix = str(choix)
            self.CBChoix.currentIndexChanged.connect(self.choixSaisi)
            self.CBChoix.addItem(choix)
        self.CBChoix.setEditable(True)
        monCompleteur = QCompleter(listeChoix, self)
        monCompleteur.setCompletionMode(QCompleter.PopupCompletion)
        self.CBChoix.setCompleter(monCompleteur)

    def choixSaisi(self):
        valeur = str(self.CBChoix.currentText())
        SaisieValeur.LEvaleurPressed(self, valeur)
        self.reaffiche()
