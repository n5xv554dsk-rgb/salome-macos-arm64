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
from PyQt6.QtWidgets import QLabel, QSizePolicy, QSpacerItem
from PyQt6.QtCore import QSize

from InterfaceGUI.QT6.feuille import Feuille
from InterfaceGUI.QT6.monWidgetPlusieursTuple import MonWidgetPlusieursTuple
from UiQT6.desWidgetPlusieursTuple import Ui_WidgetPlusieursTuple
from UiQT6.desWidgetTableau import Ui_WidgetTableau

maxLen = 3


class MonWidgetTableau(Ui_WidgetTableau, MonWidgetPlusieursTuple):
    def __init__(self, node, monSimpDef, nom, objSimp, parentQt, commande):
        self.nbValeurs = len(monSimpDef.homo)
        MonWidgetPlusieursTuple.__init__(
            self, node, monSimpDef, nom, objSimp, parentQt, commande
        )

        sizePolicy = QSizePolicy(QSizePolicy.Policy.Preferred, QSizePolicy.Policy.Fixed)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)

        for i in range(len(monSimpDef.homo)):
            nomCol = "LECol" + str(i + 1)
            objCol = QLabel(self)
            objCol.setMinimumSize(QSize(80, 25))
            objCol.setText(monSimpDef.homo[i])
            self.LATitre.addWidget(objCol)
            setattr(self, nomCol, objCol)
            spacerItem = QSpacerItem(40, 20, QSizePolicy.Policy.Expanding, QSizePolicy.Policy.Minimum)
            self.LATitre.addItem(spacerItem)
        self.resize(self.width(), 1800)

    def ajoutLineEdit(self, valeur=None, inInit=False):
        hauteurAvant = self.frame.height()
        MonWidgetPlusieursTuple.ajoutLineEdit(self, valeur, inInit)
