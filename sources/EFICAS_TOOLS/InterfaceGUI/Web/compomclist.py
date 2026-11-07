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

from InterfaceGUI.Web import compofact
from InterfaceGUI.Web import browser
from InterfaceGUI.Web import typeNode
from Accas.extensions.eficas_translation import tr

from InterfaceGUI.Common import objecttreeitem
from Accas.processing.P_OBJECT import ErrorObj


class Node(browser.JDCNode,typeNode.PopUpMenuNodeMinimal):


    def __init__( self, treeParent, item, itemExpand=False, ancien=False ):
    #--------------------------------------------------------------------
        browser.JDCNode.__init__(self, treeParent, item, itemExpand,ancien)
        # depend si le comm contient deja une liste ou si elle cree a  l ihm
        if self.item.nature == 'MCList' :
           self.minListe   = self.item.data[0].definition.min
           self.maxListe   = self.item.data[0].definition.max
           self.statutListe= self.item.data[0].definition.statut
        else:
           self.minListe   = self.item.definition.min
           self.maxListe   = self.item.definition.max
           self.statutListe= self.item.definition.statut

    def getIdUnique(self):
    #---------------------
        print ('pas d iD unique pour la MCLIST')
       # on renvoie l'ID du 1er MCFact
       # print (self.item._object[0].idUnique)
        return self.item._object[0].idUnique

    def onValid(self):
    #-----------------
       # on ne fait rien
       pass

    def onAdd(self,ajout):
    #----------------------
        debug=0
        if debug : print (' ***************** on add de compomclist', 'ajout', ajout, ' dans ', self.item.nom, self.item, self)
        if debug : print ('on add de compomclist', '______ ajout', ajout, ' dans ', self.item.nom, self.item, self)
        if debug : print ('nature de l ajout', ajout[0].nature)

        self.buildChildren()

        # si on a un copie multiple --> pas gere correctement 
        # pas gere du tout
        if len(ajout) > 1 : 
            print ('add multiple non gere')
            return
 
        ouAjouter=self.getTreeParentIdUnique()

        mcAjoute= ajout[0]  
        posDansSelf = 0; 
        trouve=0
        # a priori on ajoute toujours le dernier FACT a la MCListe
        # on garde quand meme la boucle si cela evolue
        for c in self.children :
            if c.item._object == mcAjoute :
                 trouve=1
                 break
            posDansSelf +=1 
        if not trouve : print ('souci au add *************************')
        if debug : print  ('posDansSelf', posDansSelf)
        if debug : print (self.children[posDansSelf].item.getDicoForFancy())
        laListe=(self.children[posDansSelf].item.getDicoForFancy(),)


        posDansArbre = posDansSelf; 
        for c in self.treeParent.children : 
            if  c == self: break
            posDansArbre +=c.item.longueurDsArbreAvecConsigne()

        if debug : print  (' posDansArbre ', posDansArbre , ' posDansSelf ', posDansSelf)
        self.editor.appliEficas.propageChange( self.editor.editorId, None, None, True, 'appendChildren',ouAjouter,laListe,posDansArbre)
        #print ('la pos ', posOuAjouter)
        #print (' appel appendChild',self.item.idUnique,laListe,pos)
        self.updateChildrenProperties()


    def onSupp(self,suppression):
    #---------------------------
        browser.JDCNode.onSupp(self, suppression)
        self.updateChildrenProperties()

    
    def updateChildrenProperties(self):
    #----------------------------------
        if self.item.nature == 'MCFACT': 
           children=(self.item.fauxNoeudGraphique,)
           children[0].updateNodeLabel()
        else :
           if len(self.item.data) == 2 : self.children[0].updateNodeLabel()
           children=self.children
        for nodeChild in children : 
           if nodeChild.item.isOblig() : newStatut ='o'
           else : newStatut = 'f' 
           if  newStatut != nodeChild.oldStatut : 
               nodeChild.updateStatut(newStatut) 
               nodeChild.oldStatut=newStatut
           newRepetable=nodeChild.item.isRepetable()
           if  newRepetable != nodeChild.oldRepetable : 
               nodeChild.updateRepetable(newRepetable) 
               nodeChild.oldRepetable=newRepetable
           


class MCListTreeItem(objecttreeitem.SequenceTreeItem,compofact.FACTTreeItem):
    """ La classe MCListTreeItem joue le role d'un adaptateur pour les objets
        du processing Accas instances de la classe MCLIST.
        Elle adapte ces objets pour leur permettre d'etre integres en tant que
        noeuds dans un arbre graphique (voir treewidget.py et ObjectTreeItem.py).
        Cette classe delegue les appels de methode et les acces
        aux attributs a l'objet du processing soit manuellement soit
        automatiquement (voir classe Delegate et attribut object).
    """
    itemNode=Node

    def init(self):
        # Avant Si l'objet Accas (MCList) a moins d'un mot cle facteur
        # on utilise directement ce mot cle facteur comme delegue
        self.updateDelegate()

    def updateDelegate(self):
        self.setDelegate(self._object)
        return
        if len(self._object) > 1:
            self.setDelegate(self._object)
        else:
            self.setDelegate(self._object.data[0])

    def isExpandable(self):
        if len(self._object) > 1:
            return objecttreeitem.SequenceTreeItem.isExpandable(self)
        else:
            return compofact.FACTTreeItem.isExpandable(self)


    def getSubList(self):
        self.updateDelegate()
        
        #if len(self._object) <= 1:
        #    self._object.data[0].alt_parent=self._object
        #    return compofact.FACTTreeItem.getSubList(self)

        liste=self._object.data
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
                    object=value
                item = self.makeObjecttreeitem(self.appliEficas, obj.nom + " : ", obj, setFunction)
                sublist[pos]=item
                #Attention : on ajoute une information supplementaire pour l'actualisation de
                # la validite. L'attribut parent d'un MCFACT pointe sur le parent de la MCLISTE
                # et pas sur la MCLISTE elle meme ce qui rompt la chaine de remontee des
                # informations de validite. alt_parent permet de remedier a ce defaut.
                obj.alt_parent=self._object
            pos=pos+1

        self.sublist=sublist

        #if len(self._object) <= 1:
        #    self._object.data[0].alt_parent=self._object
        #    return compofact.FACTTreeItem.getSubList(self)

        return self.sublist

    def getIconName(self):
        if self._object.isValid():
            return "ast-green-los"
        elif self._object.isOblig():
            return "ast-red-los"
        else:
            return "ast-yel-los"

    def getDocu(self):
        """ Retourne la clef de doc de l'objet pointe par self """
        return self.object.getDocu()

    def isCopiable(self):
        if len(self._object) > 1:
            return Objecttreeitem.SequenceTreeItem.isCopiable(self)
        else:
            return compofact.FACTTreeItem.isCopiable(self)

    def isMCFact(self):
        """
        Retourne 1 si l'objet pointe par self est un MCFact, 0 sinon
        """
        return len(self._object) <= 1

    def isMCList(self):
        """
        Retourne 1 si l'objet pointe par self est une MCList, 0 sinon
        """
        return len(self._object) > 1

    def getCopieObjet(self):
        return self._object.data[0].copy()

    #def addItem(self,obj,pos):
    #    print ("compomclist.addItem",obj,pos)
    #    if len(self._object) <= 1:
    #        return compofact.FACTTreeItem.addItem(self,obj,pos)
    #    o = self.object.addEntite(obj,pos)
    #    return o

    def suppItem(self,item):
        """
        Retire un objet MCFACT de la MCList (self.object)
        """
        #print "compomclist.suppItem",item
        obj=item.getObject()
        if len(self._object) <= 1:
            return compofact.FACTTreeItem.suppItem(self,item)

        if self.object.suppEntite(obj):
            if len(self._object) == 1: self.updateDelegate()
            message = "Mot-clef " + obj.nom + " supprime"
            return (1,message)
        else:
            return (0,tr('Impossible de supprimer ce mot-clef'))

            

import Accas
objet = Accas.MCList

def treeitem(appliEficas,labeltext,object,setFunction):
    """ Factory qui produit un objet treeitem adapte a un objet
        Accas.MCList (attribut objet de ce module)
    """
    return MCListTreeItem(appliEficas,labeltext,object,setFunction)
