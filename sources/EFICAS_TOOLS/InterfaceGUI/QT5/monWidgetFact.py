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

from PyQt5.QtCore import Qt, QTimer
from PyQt5.QtWidgets import QWidget

from InterfaceGUI.QT5.groupe import Groupe
from UiQT5.desWidgetFact import Ui_WidgetFact
from Accas.extensions.eficas_translation import tr

# Import des panels


# PN 18 mai 2020 : affiche systematique des optionnels
class MonWidgetFactCommun(Groupe):
    """ """

    def __init__(self, node, editor, parentQt, definition, obj, niveau, commande):
        # print ("fact : ",node.item.nom)
        Groupe.__init__(self, node, editor, parentQt, definition, obj, niveau, commande)
        labeltext, fonte, couleur = self.node.item.getLabelText()
        self.GroupBox.setText(tr(labeltext))
        # self.GroupBox.setTextInteractionFlags(Qt.TextSelectableByMouse)
        self.parentQt.commandesLayout.insertWidget(-1, self)
        self.doitAfficherOptionnel = True
        min, max = obj.getMinMax()
        if max > 1 and hasattr(self, "RBPlus"):
            self.RBPlus.clicked.connect(self.ajouteMCParPB)
        if max < 2 and hasattr(self, "RBPlus"):
            self.RBPlus.close()
        if ( max > 2 and obj.alt_parent.nature == "MCList"
            and len(obj.alt_parent) >= max
            and hasattr(self, "RBPlus")):
            self.RBPlus.close()

        if max > 2 and definition.statut == "cache" and hasattr(self, "RBPlus"):
            self.RBPlus.close()

    def enterEvent(self, event):
        # print "enterEvent ", self.node.item.getLabelText()[0]
        self.doitAfficherOptionnel = True
        QWidget.enterEvent(self, event)
        QTimer.singleShot(500, self.delayAffiche)

    def leaveEvent(self, event):
        # print "leaveEvent", self.node.item.getLabelText()[0]
        # self.doitAfficherOptionnel=False
        QWidget.leaveEvent(self, event)

    def delayAffiche(self):
        # print "delayAffiche, self.doitAfficherOptionnel = ", self.doitAfficherOptionnel
        if self.doitAfficherOptionnel and self.editor.code != "CARMELCND":
            self.afficheOptionnel()

    def ajouteMCParPB(self):
        texteListeNom = "+" + self.obj.nom
        parentOuAjouter = self.parentQt
        from InterfaceGUI.QT5.monWidgetBloc import MonWidgetBloc

        while parentOuAjouter and isinstance(parentOuAjouter, MonWidgetBloc):
            parentOuAjouter = parentOuAjouter.parentQt
        parentOuAjouter.ajoutMC(texteListeNom)


#  def reaffiche(self, nodeAVoir=None):
#      print ('ds reaffiche : ', self.obj.nom, self.node.firstDeplie)
#      if self.node.editor.maConfiguration.afficheFirstPlies and self.node.firstDeplie:
#         self.node.firstDeplie =False
#         self.node.setPlie()
#      Groupe.reaffiche(self,nodeAVoir)


class MonWidgetFact(Ui_WidgetFact, MonWidgetFactCommun):
    # def __init__(self,node,editor,parentQt,definition, obj, niveau,commande,insertIn=1):
    #    MonWidgetFactCommun.__init__(self,node,editor,parentQt, definition,obj,niveau,commande,insertIn)
    def __init__(self, node, editor, parentQt, definition, obj, niveau, commande):
        MonWidgetFactCommun.__init__(
            self, node, editor, parentQt, definition, obj, niveau, commande
        )


class MonWidgetFactTableau(Ui_WidgetFact, MonWidgetFactCommun):
    # def __init__(self,node,editor,parentQt,definition, obj, niveau,commande,insertIn=1):
    #    MonWidgetFactCommun.__init__(self,node,editor,parentQt, definition,obj,niveau,commande,insertIn)
    def __init__(self, node, editor, parentQt, definition, obj, niveau, commande):
        MonWidgetFactCommun.__init__(
            self, node, editor, parentQt, definition, obj, niveau, commande
        )
        MonWidgetFactTableau.__init__(
            self, node, editor, parentQt, definition, obj, niveau, commande
        )
