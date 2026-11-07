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
from PyQt5.QtWidgets import QCheckBox, QScrollBar, QFrame, QApplication, QLabel
from PyQt5.QtWidgets import QSizePolicy, QSpacerItem
from PyQt5.QtGui import QPalette, QFont
from PyQt5.QtCore import Qt

from Accas.extensions.eficas_translation import tr

from UiQT5.desWidgetIntoSug import Ui_WidgetIntoSug
from InterfaceGUI.QT5.monWidgetPlusieursInto import MonWidgetPlusieursInto


class GereAjoutDsPossible:
    def LEValeurAjouteDsPossible(self):
        text = str(self.lineEditVal.text())
        if text == "":
            return
        # il faudrait essauer d en obtenir un reel, un tuple ou ...
        # si cela est utilise pour autre chose que Telemac
        # tout devrait etre fait ici
        if not isinstance(text, str):
            self.lineEditVal.setText("")
            return
        if self.node.item.hasIntoSug():
            self.maListeDeValeur = list(self.node.item.getListePossibleAvecSug([]))
            self.maListeDeValeur.insert(0, text)
        else:
            try:
                self.monSimpDef.intoSug.insert(0, text)
            except:
                self.monSimpDef.intoSug = list(self.monSimpDef.intoSug)
                self.monSimpDef.intoSug.insert(0, text)
        # selon si on est une liste ou un combo
        try:
            self.ajouteValeurPossible(text)
        except:
            self.setValeurs()


class MonWidgetIntoSug(Ui_WidgetIntoSug, MonWidgetPlusieursInto, GereAjoutDsPossible):
    # Attention Attention
    # cette wdget ne fonctionne actuellement que pour Telemac
    # on attend du texte . on n essaye pas de transformer

    def __init__(self, node, monSimpDef, nom, objSimp, parentQt, commande):
        MonWidgetPlusieursInto.__init__(
            self, node, monSimpDef, nom, objSimp, parentQt, commande
        )
        self.lineEditVal.returnPressed.connect(self.LEValeurAjouteDsPossible)
