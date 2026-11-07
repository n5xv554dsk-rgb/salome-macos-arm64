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
# Modules Eficas


from UiQT6.desWidgetBloc import Ui_WidgetBloc
from InterfaceGUI.QT6.groupe import Groupe
from Accas.extensions.eficas_translation import tr

# Import des panels
class MonWidgetBloc(Ui_WidgetBloc, Groupe):
    """ """

    def __init__(self, node, editor, parentQt, definition, obj, niveau, commande):
        # print ("bloc : ",node.item.nom)
        Groupe.__init__(self, node, editor, parentQt, definition, obj, niveau, commande)
        # if self.editor.maConfiguration.afficheCommandesPliees ==True:  self.node.plieToutEtReaffiche()
        self.parentQt.commandesLayout.insertWidget(-1, self, 1)

    def afficheOptionnel(self):
        return
