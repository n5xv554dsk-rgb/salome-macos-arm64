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

from PyQt5.QtWidgets import QLineEdit
from PyQt5.QtCore import Qt

from Accas.extensions.eficas_translation import tr

from InterfaceGUI.QT5.feuille import Feuille
from UiQT5.desWidgetSimpSalome import Ui_WidgetSimpSalome
from InterfaceGUI.Common.politiquesValidation import PolitiqueUnique
from InterfaceGUI.QT5.traiteSaisie import SaisieValeur


class MonWidgetSimpSalome(Ui_WidgetSimpSalome, Feuille):
    def __init__(self, node, monSimpDef, nom, objSimp, parentQt, commande):
        Feuille.__init__(self, node, monSimpDef, nom, objSimp, parentQt, commande)
        self.parentQt.commandesLayout.insertWidget(-1, self, 1)
        self.setFocusPolicy(Qt.StrongFocus)
        self.politique = PolitiqueUnique(self.node, self.editor)
        self.lineEditVal.returnPressed.connect(self.LEvaleurPressed)
        self.AAfficher = self.lineEditVal
        self.maCommande.listeAffichageWidget.append(self.lineEditVal)

    def LEvaleurPressed(self):
        if str(self.lineEditVal.text()) == "" or str(self.lineEditVal.text()) == None:
            return
        SaisieValeur.LEvaleurPressed(self)
        self.parentQt.donneFocus()
        self.setValeurs()
        self.reaffiche()

    def setValeurs(self):
        valeur = self.node.item.getValeur()
        if valeur != None:
            self.lineEditVal.setText(str(valeur))
