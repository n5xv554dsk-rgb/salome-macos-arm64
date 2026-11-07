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
from PyQt5.QtCore import Qt
from PyQt5.QtWidgets import QWidget


# Modules Eficas

from InterfaceGUI.QT5.groupe import Groupe
from UiQT5.selectionVP import Ui_Selection
from Accas.extensions.eficas_translation import tr

# Import des panels


class MonWidgetSpecifique(Ui_Selection, Groupe):
    def __init__(self, node, editor, parentQt, fenetrePPal):
        Groupe.__init__(self, node, editor, parentQt, fenetrePPal)
        labeltext, fonte, couleur = self.node.item.getLabelText()
        self.groupBox.setTitle(tr(labeltext))
        self.searchButton.clicked.connect(self.searchActived)

    def afficheMots(self):
        import traceback
        indexColonne = 0
        indexLigne = 0
        for node in self.node.children:
            widget = node.getPanel(self, self.editor)
            if ( hasattr(node.item.definition, "affichage")
                and node.item.definition.affichage != None):
                widgetMere = getattr(self, node.item.definition.affichage[0])
                indexLigne = node.item.definition.affichage[1]
                indexColonne = node.item.definition.affichage[2]
                widgetMere.addWidget(widget, indexLigne, indexColonne)
        # print "fin pour " , self.node.item.nom

    def searchActived(self):
        debug = 0
        if debug: print ('searchActived')
        self.editor.searchActived()

    def redessineWidget(self,node, oldWidget):
         widget = node.getPanel(self, self.editor)
         if ( hasattr(node.item.definition, "affichage")):
             widgetMere = getattr(self, node.item.definition.affichage[0])
             widgetMere.removeWidget(oldWidget)
             oldWidget.close()
             indexLigne = node.item.definition.affichage[1]
             indexColonne = node.item.definition.affichage[2]
             widgetMere.addWidget(widget, indexLigne, indexColonne)
       
           
           
        
