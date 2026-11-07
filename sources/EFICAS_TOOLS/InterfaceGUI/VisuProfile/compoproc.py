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
from __future__ import absolute_import
from InterfaceGUI.Common  import objecttreeitem
from InterfaceGUI.VisuProfile import browser
from InterfaceGUI.VisuProfile import compooper


class Node(browser.JDCNode):

    def getPanel(self):
        debug=0
        if debug : print ('in getPanel compoproc ', self.item.nom )
        maDefinition = self.item.get_definition()
        if maDefinition.fenetreIhm != None :
            if debug : print ('in getPanel compoproc, fenetreIhm  = ', maDefinition.fenetreIhm )
            widgetParticularise=maDefinition.fenetreIhm
            if widgetParticularise != None:
                from importlib import import_module
                module = import_module(widgetParticularise)
                if debug : print (module)
                classeWidget = getattr(module,'MonWidgetSpecifique')
                if debug : print (classeWidget)
                self.widget=classeWidget(self,self.editor, self.treeParent, self.editor)
                return self.widget

        from InterfaceGUI.QT5.monWidgetCommande import MonWidgetCommande
        return MonWidgetCommande(self,self.editor,self.item.object)


class ProcEtapeTreeItem(compooper.EtapeTreeItem):
    itemNode=Node

import Accas
treeitem = ProcEtapeTreeItem
objet = Accas.PROC_ETAPE
