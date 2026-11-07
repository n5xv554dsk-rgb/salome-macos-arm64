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

from InterfaceGUI.Web import browser
from InterfaceGUI.Web import typeNode
from InterfaceGUI.Common import objecttreeitem
from Accas.extensions.eficas_translation import tr


class Node(browser.JDCNode,typeNode.PopUpMenuNodePartiel):

    def delete(self):
    #----------------
        """
            Methode externe pour la destruction de l'objet associe au noeud
        """
        debug = 0
        if debug : print ('******* mcfact :_appel de delete _______', self, self.vraiParent, self.item.nature)
        if len(self.vraiParent.item._object) == 1 :
             treeParent=self.vraiParent.treeParent
             ret,commentaire=self.vraiParent.treeParent.item.suppItem(self.vraiParent.item)
             if ret!=0 : treeParent.buildChildren()
             return (ret,commentaire) 

     
        obj=self.item.getObject()
        indexFact=self.vraiParent.item._object.index(obj)
        ret,commentaire=self.vraiParent.item.suppItem(self.item)
        if not ret : return (ret,commentaire) 
        self.treeParent.buildChildren()
        self.vraiParent.buildChildren()
        for c in  self.vraiParent.children[indexFact:] :
            c.updateNodeLabel()
        self.treeParent.updateOptionnels()
        return (ret,commentaire) 



class FACTTreeItem(objecttreeitem.ObjectTreeItem):
    itemNode=Node

    def isExpandable(self):
    # ----------------------
        return 1

    def getText(self):
    # ----------------
        return  ''

    def getLabelText(self):
    # ----------------------
        """ Retourne 3 valeurs :
          - le texte à afficher dans le noeud representant l'item
          - la fonte dans laquelle afficher ce texte
          - la couleur du texte
        """
        # None --> fonte et couleur par defaut
        if not(hasattr(self.object,'getLabelText')): return self.object.nom,None,None
        return self.object.getLabelText(),None,None

    def isValid(self):
    # ----------------
        return self.object.isValid()

    def isCopiable(self):
    # ----------------
        return 1

    def getIconName(self):
    # ----------------
        if self.object.isValid()  : return "ast-green-los"
        elif self.object.isOblig(): return "ast-red-los"
        else                      : return "ast-yel-los"


    def getSubList(self):
    # ----------------
        """
           Reactualise la liste des items fils stockes dans self.sublist
        """
        liste=self.object.mcListe
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

    #def addItem(self,name,pos):
    #    objet = self.object.addEntite(name,pos)
    #    return objet

    def suppItem(self,item) :
        """
           Cette methode a pour fonction de supprimer l'item passee en argument
           dans l'item FACT qui est son pere
             - item = item du MOCLE a supprimer du MOCLE pere
             - item.getObject() = MCSIMP ou MCBLOC
        """
        itemobject=item.getObject()
        if itemobject.isOblig() :
            return (0, tr('Impossible de supprimer un mot-cle obligatoire '))

        if self.object.suppEntite(itemobject):
            message = tr("Mot-cle %s supprime")+ itemobject.nom
            return (1, message)
        else:
            return (0,tr('Pb interne : impossible de supprimer ce mot-cle'))

import Accas
objet = Accas.MCFACT
treeitem = FACTTreeItem
