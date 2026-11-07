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
from __future__ import absolute_import
import types,os

# Modules Eficas
from Accas.extensions.eficas_translation import tr

from UiQT5.desWidgetDateVP import Ui_WidgetDateVP
from InterfaceGUI.QT5.monWidgetSimpDate  import MonWidgetSimpDate
from PyQt5.QtCore import QDate, QDateTime


class MonWidgetSpecifique (Ui_WidgetDateVP, MonWidgetSimpDate):

    def __init__(self,node,monSimpDef,nom,objSimp,parentQt,commande):
        MonWidgetSimpDate.__init__(self,node,monSimpDef,nom,objSimp,parentQt,commande)
        self.oldValue = None

    def setValeurs(self):
        valeur=self.node.item.getValeur()
        if valeur == None  : return
        self.oldValue = valeur
        laDate = QDateTime.fromSecsSinceEpoch(valeur).toString("dd/MM/yyyy hh:mm:ss")
        qDate = QDate.fromString(laDate.split(' ')[0],"dd/MM/yyyy")
        self.dateEdit.setDate(qDate)


    def dateChanged(self,qDate):
        value=qDate.toTime_t()
        validite,commentaire=self.politique.recordValeur(value)
        if not(validite) :
           self.parentQt.editor.afficheMessage('mauvaise valeur', commentaire)
           self.setValeurs()
        self.setValide()
        if self.oldValue != value :
           self.editor.metAJourSelection(self.label.text())
           self.oldValue = value
