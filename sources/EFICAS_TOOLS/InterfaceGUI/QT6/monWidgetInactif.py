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


from PyQt6.QtWidgets import QWidget

from Accas.extensions.eficas_translation import tr
from UiQT6.desWidgetInactif import Ui_WidgetInactif
import Accas
import os


# Import des panels


class MonWidgetInactif(QWidget, Ui_WidgetInactif):
    """ """

    def __init__(self, node, editor):
        QWidget.__init__(self, None)
        self.node = node
        self.editor = editor
        self.setupUi(self)
        from InterfaceGUI.QT6.monWidgetOptionnel import MonWidgetOptionnel

        if self.editor.widgetOptionnel != None:
            self.monOptionnel = self.editor.widgetOptionnel
        else:
            self.monOptionnel = MonWidgetOptionnel(self)
            self.editor.widgetOptionnel = self.monOptionnel
            self.editor.splitter.addWidget(self.monOptionnel)
            self.editor.restoreSplitterSizes()
        self.afficheOptionnel()
        self.bAvant.clicked.connect(self.afficheAvant)
        self.bApres.clicked.connect(self.afficheApres)
        self.bCatalogue.clicked.connect(self.afficheCatalogue)
        self.labelNomCommande.setText(tr(self.node.item.nom))
        self.labelNomCommande.setEnabled(False)

    def traiteClicSurLabel(self):
        pass

    def donnePremier(self):
        pass

    def setValide(self):
        pass

    def afficheOptionnel(self):
        # N a pas de parentQt. doit donc etre redefini
        if self.editor.maConfiguration.closeOptionnel:
            return
        liste = []
        # print "dans afficheOptionnel", self.monOptionnel
        # dans le cas ou l insertion n a pas eu leiu (souci d ordre par exemple)
        # if self.monOptionnel == None : return
        self.monOptionnel.parentMC = self
        self.monOptionnel.afficheOptionnelVide()

    def afficheCatalogue(self):
        if self.editor.widgetOptionnel != None:
            self.monOptionnel.hide()
        self.node.tree.racine.affichePanneau()
        self.node.tree.racine.select()

    def afficheApres(self):
        self.node.selectApres()

    def afficheAvant(self):
        self.node.selectAvant()
