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

import types, os

# Modules Eficas
from Accas.extensions.eficas_translation import tr

from InterfaceGUI.QT5.feuille import Feuille
from InterfaceGUI.QT5.monWidgetSimpTuple import MonWidgetSimpTuple
from UiQT5.desWidgetDate import Ui_WidgetDate


class MonWidgetDate(Ui_WidgetDate, MonWidgetSimpTuple):
    def __init__(self, node, monSimpDef, nom, objSimp, parentQt, commande):
        self.nbValeurs = 3
        MonWidgetSimpTuple.__init__(
            self, node, monSimpDef, nom, objSimp, parentQt, commande
        )
        if self.objSimp.isImmuable():
            self.lineEditVal1.setDisabled(True)
            self.lineEditVal2.setDisabled(True)
            self.lineEditVal3.setDisabled(True)
            self.lineEditVal1.setStyleSheet(
                QString.fromUtf8("background:rgb(244,244,244);\n" "border:0px;\n")
            )
            self.lineEditVal2.setStyleSheet(
                QString.fromUtf8("background:rgb(244,244,244);\n" "border:0px;\n")
            )
            self.lineEditVal3.setStyleSheet(
                QString.fromUtf8("background:rgb(244,244,244);\n" "border:0px;\n")
            )
            self.lineEditVal1.setToolTip(tr("Valeur non modifiable"))
            self.lineEditVal2.setToolTip(tr("Valeur non modifiable"))
            self.lineEditVal3.setToolTip(tr("Valeur non modifiable"))
        else:
            self.maCommande.listeAffichageWidget.append(self.lineEditVal1)
        # self.maCommande.listeAffichageWidget.append(self.lineEditVal2)
        # self.maCommande.listeAffichageWidget.append(self.lineEditVal3)
