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

from InterfaceGUI.QT5.feuille import Feuille
from InterfaceGUI.QT5.monWidgetSimpTuple import MonWidgetSimpTuple
from UiQT5.desWidgetTuple2 import Ui_WidgetTuple2
from UiQT5.desWidgetTuple3 import Ui_WidgetTuple3
from UiQT5.desWidgetTuple4 import Ui_WidgetTuple4
from UiQT5.desWidgetTuple5 import Ui_WidgetTuple5
from UiQT5.desWidgetTuple6 import Ui_WidgetTuple6
from UiQT5.desWidgetTuple7 import Ui_WidgetTuple7
from UiQT5.desWidgetTuple8 import Ui_WidgetTuple8
from UiQT5.desWidgetTuple9 import Ui_WidgetTuple9
from UiQT5.desWidgetTuple10 import Ui_WidgetTuple10


class MonWidgetSimpTuple2(Ui_WidgetTuple2, MonWidgetSimpTuple):
    def __init__(self, node, monSimpDef, nom, objSimp, parentQt, commande):
        self.nbValeurs = 2
        MonWidgetSimpTuple.__init__(
            self, node, monSimpDef, nom, objSimp, parentQt, commande
        )
        if self.objSimp.isImmuable():
            self.lineEditVal1.setDisabled(True)
            self.lineEditVal2.setDisabled(True)
            self.lineEditVal1.setStyleSheet(
                "background:rgb(244,244,244);\n" "border:0px;\n"
            )
            self.lineEditVal2.setStyleSheet(
                "background:rgb(244,244,244);\n" "border:0px;\n"
            )
            self.lineEditVal1.setToolTip(tr("Valeur non modifiable"))
            self.lineEditVal2.setToolTip(tr("Valeur non modifiable"))
        else:
            self.maCommande.listeAffichageWidget.append(self.lineEditVal1)


class MonWidgetSimpTuple3(Ui_WidgetTuple3, MonWidgetSimpTuple):
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
                "background:rgb(244,244,244);\n" "border:0px;\n"
            )
            self.lineEditVal2.setStyleSheet(
                "background:rgb(244,244,244);\n" "border:0px;\n"
            )
            self.lineEditVal3.setStyleSheet(
                "background:rgb(244,244,244);\n" "border:0px;\n"
            )
            self.lineEditVal1.setToolTip(tr("Valeur non modifiable"))
            self.lineEditVal2.setToolTip(tr("Valeur non modifiable"))
            self.lineEditVal3.setToolTip(tr("Valeur non modifiable"))
        else:
            self.maCommande.listeAffichageWidget.append(self.lineEditVal1)


class MonWidgetSimpTuple4(Ui_WidgetTuple4, MonWidgetSimpTuple):
    def __init__(self, node, monSimpDef, nom, objSimp, parentQt, commande):
        # print (self,node,monSimpDef,nom,objSimp,parentQt,commande)
        self.nbValeurs = 4
        MonWidgetSimpTuple.__init__(
            self, node, monSimpDef, nom, objSimp, parentQt, commande
        )


class MonWidgetSimpTuple5(Ui_WidgetTuple5, MonWidgetSimpTuple):
    def __init__(self, node, monSimpDef, nom, objSimp, parentQt, commande):
        self.nbValeurs = 5
        MonWidgetSimpTuple.__init__(
            self, node, monSimpDef, nom, objSimp, parentQt, commande
        )


class MonWidgetSimpTuple6(Ui_WidgetTuple6, MonWidgetSimpTuple):
    def __init__(self, node, monSimpDef, nom, objSimp, parentQt, commande):
        self.nbValeurs = 6
        MonWidgetSimpTuple.__init__(
            self, node, monSimpDef, nom, objSimp, parentQt, commande
        )


class MonWidgetSimpTuple7(Ui_WidgetTuple7, MonWidgetSimpTuple):
    def __init__(self, node, monSimpDef, nom, objSimp, parentQt, commande):
        self.nbValeurs = 7
        MonWidgetSimpTuple.__init__(
            self, node, monSimpDef, nom, objSimp, parentQt, commande
        )


class MonWidgetSimpTuple8(Ui_WidgetTuple8, MonWidgetSimpTuple):
    def __init__(self, node, monSimpDef, nom, objSimp, parentQt, commande):
        self.nbValeurs = 8
        MonWidgetSimpTuple.__init__(
            self, node, monSimpDef, nom, objSimp, parentQt, commande
        )


class MonWidgetSimpTuple9(Ui_WidgetTuple9, MonWidgetSimpTuple):
    def __init__(self, node, monSimpDef, nom, objSimp, parentQt, commande):
        self.nbValeurs = 9
        MonWidgetSimpTuple.__init__(
            self, node, monSimpDef, nom, objSimp, parentQt, commande
        )


class MonWidgetSimpTuple10(Ui_WidgetTuple10, MonWidgetSimpTuple):
    def __init__(self, node, monSimpDef, nom, objSimp, parentQt, commande):
        self.nbValeurs = 10
        MonWidgetSimpTuple.__init__(
            self, node, monSimpDef, nom, objSimp, parentQt, commande
        )
