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
import types,os
import traceback

from Accas.extensions.eficas_translation import tr
from PyQt5.QtCore import Qt
from PyQt5.QtWidgets import QDialog
from UiQT5.desWidgetLabels import Ui_WidgetLabels

# ---------------------------------------------- #
class MonWidgetSpecifique(Ui_WidgetLabels,QDialog):
# ---------------------------------------------- #
    """
    Classe permettant la visualisation de texte
    """
    def __init__( self, node, editor, parentQt, fenetrePPal):
    # ------------------------------------------------------ 
        QDialog.__init__(self)
        self.setupUi(self)
        self.setModal(True)
        self.node=node
        self.editor=editor
        self.afficheMots()

    def afficheMots(self):
    # --------------------
        for node in self.node.children:
            widget = node.getPanel(self, self.editor)
            # on vire ce qui est en trop dans le widget generique
            for monLayout in (widget.horizontalLayout, widget.verticalCadre1, widget.verticalLayout2,widget.verticalLayout):
                for i in range(monLayout.count()):
                    layoutItem = monLayout.itemAt(i)
                    monLayout.removeItem(layoutItem)
            if hasattr(widget, 'frameRecherche'): widget.frameRecherche.close()
        # print "fin pour " , self.node.item.nom

    def accept(self):
    # ---------------
        self.editor.prepareAfficheCPU()
        super(MonWidgetSpecifique, self).accept()


