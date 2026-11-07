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

# Modules Eficas
from PyQt6.QtWidgets import QRadioButton
from Accas.extensions.eficas_translation import tr

from InterfaceGUI.QT6.feuille import Feuille
from UiQT6.desWidgetSimpBool import Ui_WidgetSimpBool
from InterfaceGUI.Common.politiquesValidation import PolitiqueUnique
from InterfaceGUI.QT6.traiteSaisie import SaisieValeur


class MonWidgetSimpBool(Ui_WidgetSimpBool, Feuille):
    def __init__(self, node, monSimpDef, nom, objSimp, parentQt, commande):
        Feuille.__init__(self, node, monSimpDef, nom, objSimp, parentQt, commande)
        self.politique = PolitiqueUnique(self.node, self.editor)
        self.RBTrue.clicked.connect(self.boutonTrueClic)
        self.RBFalse.clicked.connect(self.boutonFalseClic)
        self.parentQt.commandesLayout.insertWidget(-1, self)
        self.maCommande.listeAffichageWidget.append(self.RBTrue)
        self.AAfficher = self.RBTrue

    def setValeurs(self):
        valeur = self.node.item.getValeur()
        if valeur == None:
            return
        if valeur == True:
            self.RBTrue.setChecked(True)
        if valeur == False:
            self.RBFalse.setChecked(True)
        if self.monSimpDef.homo == "constant":
            if valeur == True:
                self.RBFalse.setDisabled(True)
            else:
                self.RBTrue.setDisabled(True)

    def boutonTrueClic(self):
        SaisieValeur.LEvaleurPressed(self, True)
        self.reaffiche()

    def boutonFalseClic(self):
        SaisieValeur.LEvaleurPressed(self, False)
        self.reaffiche()
