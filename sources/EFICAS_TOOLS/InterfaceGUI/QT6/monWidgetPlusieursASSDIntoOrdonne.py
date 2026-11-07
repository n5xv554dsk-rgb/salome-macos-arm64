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
from Accas.extensions.eficas_translation import tr
from InterfaceGUI.QT6.monWidgetPlusieursIntoOrdonne import MonWidgetPlusieursIntoOrdonne
from InterfaceGUI.Common.politiquesValidation import PolitiquePlusieurs

from PyQt6.QtWidgets import QScrollBar


class MonWidgetPlusieursASSDIntoOrdonne(MonWidgetPlusieursIntoOrdonne):
    def __init__(self, node, monSimpDef, nom, objSimp, parentQt, commande):
        self.numLineEditEnCours = 0
        MonWidgetPlusieursIntoOrdonne.__init__(
            self, node, monSimpDef, nom, objSimp, parentQt, commande
        )

    def prepareListeResultat(self):
        for i in self.listeLE:
            i.close()
        self.listeLE = []
        self.vScrollBar = self.scrollArea.verticalScrollBar()
        self.listeAAfficher = self.node.item.getSdAvantDuBonType()

        if len(self.listeAAfficher) == 0:
            self.ajoutLE(0)
            return

        if len(self.listeAAfficher) * 30 > 400:
            self.resize(self.width(), 200)
        else:
            self.resize(self.width(), len(self.listeAAfficher) * 30)
        self.politique = PolitiquePlusieurs(self.node, self.editor)
        for i in range(1, len(self.listeAAfficher) + 1):
            self.ajoutLE(i)
        for i in range(len(self.listeAAfficher)):
            nomLE = "lineEditVal" + str(i + 1)
            courant = getattr(self, nomLE)
            courant.setText(str(self.listeAAfficher[i]))
        self.vScrollBar.triggerAction(QScrollBar.SliderToMinimum)
