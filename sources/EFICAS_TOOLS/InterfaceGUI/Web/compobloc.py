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


from InterfaceGUI.Common import objecttreeitem

from InterfaceGUI.Web import compofact
from InterfaceGUI.Web import browser
from InterfaceGUI.Web import typeNode


class Node(browser.JDCNode,typeNode.PopUpMenuNodeMinimal):



    def onAdd(self,ajout):
    #----------------------
        debug=1
        print ('jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj')
        if debug : print ('on add de mcbloc', '________ ajout', ajout, ' dans ', self.item.nom)
        if debug : print ('nature de  l item', self.item.nature)
        self.buildChildren()

        # si on a un copie multiple --> pas gere correctement 
        # pas gere du tout
        if len(ajout) > 1 : 
            print ('ajout multiple non gere')
            return
 
        ouAjouter=self.getTreeParentIdUnique()

        mcAjoute= ajout[0]  
        posDansSelf = 0; 
        trouve=0
        posDansArbre=0

        for c in self.children :
            if c.item._object == mcAjoute : 
                 trouve=1
                 break
            posDansSelf +=1 
            posDansArbre+=c.item.longueurDsArbreAvecConsigne()
        if not trouve : print ('souci au add *************************')
        if debug : print  ('posDansSelf', posDansSelf)
        if debug : print  ('posDansArbre', posDansSelf)
        if self.children[posDansSelf].item.nature == 'MCBLOC' : laListe=self.children[posDansSelf].item.getDicoForFancy()
        else : laListe=(self.children[posDansSelf].item.getDicoForFancy(),)

        posOuAjouter=posDansArbre
        mesParents=self.item.getParentsJusqua(self.treeParent.item)
        mesParents.insert(0,self.item.getObject())
        index=0
        while index < len(mesParents) -1 :
            parentTraite=mesParents[index+1]
            jusqua=mesParents[index]
            for c in parentTraite.mcListe:
                if c == jusqua :  break
                posOuAjouter += c.longueurDsArbreAvecConsigne()
            index=index+1
               

        #self.editor.connecteur.toWebApp('appendChildren',ouAjouter,laListe,posOuAjouter)
        self.appliEficas.propageChange(self.editor.editorId, None, None, True, 'appendChildren',ouAjouter,laListe,posOuAjouter)

        #print ('la pos ', posOuAjouter)
        #print (' appel appendChild',self.item.idUnique,laListe,pos)


class BLOCTreeItem(compofact.FACTTreeItem):
    itemNode=Node

    def isCopiable(self):
        return 0


import Accas
treeitem = BLOCTreeItem
objet = Accas.MCBLOC
