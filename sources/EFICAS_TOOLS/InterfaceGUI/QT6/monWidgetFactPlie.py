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

from UiQT6.desWidgetFactPlie import Ui_WidgetFactPlie
from InterfaceGUI.QT6.groupe import Groupe
from Accas.extensions.eficas_translation import tr

class MonWidgetFactPlie(Ui_WidgetFactPlie, Groupe):
    """ """

    # def __init__(self,node,editor,parentQt,definition, obj, niveau,commande,insertIn=-1):
    def __init__(self, node, editor, parentQt, definition, obj, niveau, commande):
        # print "fact plie : ",node.item.nom
        node.fenetreAAfficher = self
        Groupe.__init__(self, node, editor, parentQt, definition, obj, niveau, commande)
        self.groupBox.setText(self.node.item.getLabelText()[0])
        self.parentQt.commandesLayout.insertWidget(-1, self)

    def traiteClicSurLabel(self, texte):
        return
