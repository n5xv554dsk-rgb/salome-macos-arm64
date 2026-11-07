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
from InterfaceGUI.QT6.monWidgetSimpTxt import MonWidgetSimpTxt
from InterfaceGUI.QT6.monWidgetPlusieursBase import MonWidgetPlusieursBase
from copy import copy, deepcopy
from PyQt6.QtCore import Qt


class MonWidgetCreeUserAssd(MonWidgetSimpTxt):
    def __init__(self, node, monSimpDef, nom, objSimp, parentQt, commande):
        MonWidgetSimpTxt.__init__(
            self, node, monSimpDef, nom, objSimp, parentQt, commande
        )
        # self.lineEditVal.returnPressed.connect(self.LEValeurAjouteDsPossible)

    def LEvaleurPressed(self):
        try:
            if (
                str(self.lineEditVal.text()) == ""
                or str(self.lineEditVal.text()) == None
            ):
                return
        except:
            pass
        valeurEntree = str(self.lineEditVal.text())
        if valeurEntree == self.oldValeurTexte:
            return
        if self.oldValeurTexte == "":
            enCreation = True
        else:
            enCreation = False
        if enCreation:
            validite, commentaire = self.objSimp.creeUserASSDetSetValeur(valeurEntree)
        else:
            validite, commentaire = self.objSimp.renommeSdCree(valeurEntree)
        if not enCreation:
            self.node.updateNodeTexte()
        # PNPNPN -- signal update sur les fils ou ?
        if commentaire != "":
            if validite:
                self.editor.afficheCommentaire(commentaire)
                self.oldValeurTexte = self.lineEditVal.text()
            else:
                self.editor.afficheMessageQt(commentaire, Qt.GlobalColor.red)
                self.lineEditVal.setText("")
                self.oldValeurTexte = ""
        self.parentQt.propageChange(self.objSimp.definition.type[0], self)
