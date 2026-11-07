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
"""
   Ce module contient les classes permettant de definir les objets graphiques
   representant un objet de type PARAMETRE, cad le panneau et l'item de l'arbre
   d'EFICAS
"""


# import modules EFICAS
from InterfaceGUI.Common.param_treeItem_commun import PARAMTreeItemCommun
from InterfaceGUI.Web import typeNode
from InterfaceGUI.Web import browser
from Accas.extensions.eficas_translation import tr
from Accas.extensions.parametre import PARAMETRE

class Node(browser.JDCNode, typeNode.PopUpMenuNodePartiel):
    pass

class PARAMTreeItem(PARAMTreeItemCommun):
    itemNode = Node

treeitem = PARAMTreeItem
objet = PARAMETRE
