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
import types

# Modules Eficas

from UiQT5.desWidgetCBSelectionVP import Ui_WidgetSelectionVPCB
from InterfaceGUI.QT5.monWidgetCB  import MonWidgetCBCommun


class MonWidgetSpecifique(Ui_WidgetSelectionVPCB,MonWidgetCBCommun):

    def __init__(self,node,maDefinition,nom,objSimp,parentQt,commande):
        if type(maDefinition.into) ==types.FunctionType :
           self.maListeDeValeur = maDefinition.into()
        else :
           self.maListeDeValeur = maDefinition.into
        MonWidgetCBCommun. __init__(self,node,maDefinition,nom,objSimp,parentQt,commande)
        if len(self.maListeDeValeur) == 1 :
           self.CBChoix.setCurrentIndex(0)
           self.choixSaisi()
        self.CBChoix.currentIndexChanged.connect(self.metAJourSelection)

    def  metAJourSelection(self):
        #texte = '{} = {}'.format(self.label.text(), repr(self.node.item.valeur))
        self.editor.metAJourSelection(self.label.text(), texteValeur=repr(self.node.item.valeur))
        #self.editor.metAJourSelection(self.node.item.nom)

