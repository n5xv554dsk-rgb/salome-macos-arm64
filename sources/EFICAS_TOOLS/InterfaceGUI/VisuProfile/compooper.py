#-*- coding: iso-8859-1 -*-
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
import os
import tempfile

from InterfaceGUI.Common import objecttreeitem
from InterfaceGUI.VisuProfile import browser

class Node(browser.JDCNode ):

    def getPanel(self):

        maDefinition = self.item.get_definition()
        if maDefinition.item.get_definition() != None :
            widgetParticularise=maDefinition.fenetreIhm
            if widgetParticularise != None:
                from importlib import import_module
                module = import_module(widgetParticularise)
                classeWidget = getattr(module,'MonWidgetSpecifique')
                self.widget=classeWidget(self,self.editor, self.item.object)
                return widget

        from .monWidgetCommande import MonWidgetCommande
        return MonWidgetCommande(self,self.editor,self.item.object)


class EtapeTreeItem(objecttreeitem.ObjectTreeItem):
    """ La classe EtapeTreeItem est un adaptateur des objets ETAPE du processing
        Accas. Elle leur permet d'etre affichés comme des noeuds
        d'un arbre graphique.
        Cette classe a entre autres deux attributs importants :
          - _object qui est un pointeur vers l'objet du processing
          - object qui pointe vers l'objet auquel sont délégués les
            appels de méthode et les acces aux attributs
        Dans le cas d'une ETAPE, _object et object pointent vers le
        meme objet.
    """
    itemNode=Node

    def getSubList(self):
        """
           Reactualise la liste des items fils stockes dans self.sublist
        """
        if self.isActif():
            liste=self.object.mcListe
        else:
            liste=[]

        sublist=[None]*len(liste)
        # suppression des items lies aux objets disparus
        for item in self.sublist:
            old_obj=item.getObject()
            if old_obj in liste:
                pos=liste.index(old_obj)
                sublist[pos]=item
            else:
                pass # objets supprimes ignores

        # ajout des items lies aux nouveaux objets
        pos=0
        for obj in liste:
            if sublist[pos] is None:
                # nouvel objet : on cree un nouvel item
                def setFunction(value, object=obj): 
                    object.setval(value)
                item = self.makeObjecttreeitem(self.appliEficas, obj.nom + " : ", obj, setFunction)
                sublist[pos]=item
            pos=pos+1

        self.sublist=sublist
        return self.sublist


import Accas
treeitem = EtapeTreeItem
objet = Accas.ETAPE
