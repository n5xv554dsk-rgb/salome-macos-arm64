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
from PyQt6.QtCore                      import QDate
from UiQT6.desWidgetDate               import Ui_WidgetDate
from InterfaceGUI.Common.politiquesValidation  import PolitiqueUnique
from InterfaceGUI.QT6.feuille               import Feuille



class MonWidgetSimpDate(Ui_WidgetDate,Feuille):

    def __init__(self,node,monSimpDef,nom,objSimp,parentQt,commande):
        Feuille.__init__(self,node,monSimpDef,nom,objSimp,parentQt,commande)
        self.politique=PolitiqueUnique(self.node,self.editor)
        if hasattr(self.parentQt, 'commandesLayout') : self.parentQt.commandesLayout.insertWidget(-1,self)
        self.maCommande.listeAffichageWidget.append(self.dateEdit)
        self.dateEdit.dateTimeChanged.connect(self.dateChanged)

    def setValeurs(self):
        valeur=self.node.item.getValeur()
        if valeur == None  : return
        qtDate = QDate.fromString(valeur, 'yyyy-MM-dd')
        self.dateEdit.setDate(qtDate)
        if self.monSimpDef.homo == 'constant' :
           self.dateEdit.setDisabled(True)

    def dateChanged(self,qDate):
        value=qDate.toString("yyyy-MM-dd")
        validite,commentaire=self.politique.recordValeur(value)
        if not(validite) : 
           self.setValeurs()
           print (commentaire)
        self.setValide()

