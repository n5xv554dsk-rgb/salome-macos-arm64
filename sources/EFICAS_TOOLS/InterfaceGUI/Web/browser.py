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

import re
import types,sys,os
import traceback

from  Accas.extensions.eficas_translation  import tr

#------------------------------------------
class JDCTree():
#------------------------------------------

    def __init__( self, jdc_item, editor):
    #----------------------------------------
        #print ('__init__ JDCTree')
        self.editor        = editor
        #print ('browser', self.editor)
        self.plie          = False
        self.item          = jdc_item
        self.tree          = self
        self.appliEficas   = self.editor.appliEficas
        self.racine        = self.item.itemNode(self,self.item)
        self.itemCourant=None
        self.node_selected = self.racine
        self.inhibeExpand  =  True
        self.childrenComplete=[]
        self.oldValidite='init'
        self.item.idUnique = self.tree.racine.item.idUnique
        # Est-ce que l editeur a besoin de cet idUnique ?? a priori non 
        #print ('fin __init__ JDCTree')

    # def handleContextMenu(self,item,coord):
    #-------------------------------------
    # def handleCollapsedItem(self,item):
    #----------------------------------
    # def handleExpandedItem(self,item):
    #----------------------------------
    # def handleOnItem(self,item,int):
    #----------------------------------
    # def choisitPremier(self,name):
    #----------------------------
# type de noeud
COMMENT     = "COMMENTAIRE"
PARAMETERS  = "PARAMETRE"

#---------------
class JDCNode():
#--------------
    def __init__( self, treeParent, item, itemExpand=False, ancien=False ):
    #----------------------------------------------------------------------
        #print ("creation d'un noeud : ", item, " ",item.nom,"", treeParent, treeParent.item.nom,self)
        self.item        = item
        self.vraiParent  = treeParent
        self.treeParent  = treeParent
        self.tree        = self.treeParent.tree
        self.editor      = self.treeParent.editor
        #print ('browser Node', self.editor)
        self.appliEficas = treeParent.appliEficas
        self.firstAffiche = True
        self.childrenComplete=[]
        self.oldValidite  = 'init'
        self.oldRepetable = 'init'
        self.oldStatut    = 'init'
        self.item.fauxNoeudGraphique = self
        if item.nom != tr(item.nom)                           : name = str(tr(item.nom)+" :")

        from . import compomclist
        from . import compobloc
        while (isinstance(self.treeParent,compobloc.Node) or ( isinstance(self.treeParent,compomclist.Node) and self.treeParent.item.isMCList())) :
            self.treeParent=self.treeParent.vraiParent

        self.children = []
        self.buildChildren()
        self.editor.dicoIdNode[item.idUnique] = item

        self.item.connect("valid",self.onValid,())
        self.item.connect("supp" ,self.onSupp,())
        self.item.connect("add"  ,self.onAdd,())
        self.item.connect("demandeUpdateOptionnels"  ,self.updateOptionnels,())


    def onValid(self):
    #-----------------
        debug=0
        validite=self.item.isValid()
        if debug : print ('ds onValid', self.item.nom, self.oldValidite, validite)
        #if self.oldValidite==validite : return
        if self.oldValidite=='init' : 
           self.oldValidite=validite
           if debug : print ('self.item.state' , self.item.state)
           if self.item.state != 'modified' :  return
        self.oldValidite=validite
        self.appliEficas.propageChange(self.editor.editorId, None, None, True, 'propageValide',self.getIdUnique(), validite)
        if debug : print ('appel de propageValide pour ', self.item.nom, validite,self.oldValidite)

    def onAdd(self,ajout):
    #----------------------
        # derive pour MCList et MCBLOC
        debug=0
        if debug : print ('on add de browser', '________ ajout', ajout, ' dans ', self.item.nom)
        if debug : print ('nature de  l item', self.item.nature)
        #if self.oldValidite=='init'  : self.oldValidite='unknown'
        self.buildChildren()

        # si on a un copie multiple --> pas gere correctement 
        # pas gere du tout
        if len(ajout) > 1 : 
            return
 
        # test inutile
        ouAjouter=self.getIdUnique()

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

        if not trouve : print ('browser : souci au add *************************')
        if debug : print  ('posDansSelf', posDansSelf)
        if debug : print  ('posDansArbre', posDansArbre)

        if self.children[posDansSelf].item.nature == 'MCBLOC' : laListe=self.children[posDansSelf].item.getDicoForFancy()
        elif self.children[posDansSelf].item.nature == 'MCList' : laListe=self.children[posDansSelf].item.getDicoForFancy()
        else : laListe=(self.children[posDansSelf].item.getDicoForFancy(),)

        posOuAjouter=posDansArbre
               
        self.editor.appliEficas.propageChange( self.editor.editorId, None, None, True, 'appendChildren',ouAjouter,laListe,posOuAjouter)
        #print ('la pos ', posOuAjouter)
        #print (' appel appendChild',self.item.idUnique,laListe,pos)

    def onSupp(self,suppression):
    #---------------------------
        #print ('onSupp pour', self, self.item.nom, suppression)
        #if self.treeParent.oldValidite=='init'  : self.treeParent.oldValidite='unknown'
        if len(suppression) > 1 : 
            print ('onSupp suppression multiple non valeur')
            return
        mcSupprime= suppression[0]  
        if mcSupprime.nature == 'MCBLOC' : 
            liste=[]
            listeMC=mcSupprime.getAllChildInBloc()
            for mc in listeMC : liste.append(mc.idUnique)
        elif mcSupprime.nature == 'MCList' : 
            liste=[]
            for mc in mcSupprime.data :
               liste.append(mc.idUnique)
        else :
            liste=(mcSupprime.idUnique,)
        self.buildChildren()
        self.updateOptionnels()
        self.editor.appliEficas.propageChange( self.editor.editorId, None, None, True, 'deleteChildren',  liste)
        #print (' appel deleteChildren',liste)

    def onRedessine(self):
    #----------------------
        print ('on Redessine pour ', self)
    #---------------------
    #    self.affichePanneau()

    def getIdUnique(self):
    #---------------------
    # surcharge pour mcliste
        return self.item.idUnique

    def getTreeParentIdUnique(self):
    #------------------------------
        return self.treeParent.getIdUnique()

    def buildChildren(self,posInsertion=10000):
    #------------------------------------------
        """ Construit la liste des enfants de self """
        """ Se charge de remettre les noeuds Expanded dans le meme etat """
        debug=0
        if debug : print ("*********** buildChildren ",self,self.item, self.item.nom,self.children)
        if debug : print ("*********** buildChildren ",self,self.item, self.item.nom)


        self.children = []
        self.childrenItemComplete = []
        sublist = self.item._getSubList()
        if debug :
           print ('sublist : ')
           for s in sublist : print (s.nom)
        ind=0

        # si le faux noeud graphique existe deja on ne le recree pas
        # sinon on a trop de connect sur les items
        for item in sublist :
            if hasattr(item,'fauxNoeudGraphique') :
               self.children.append(item.fauxNoeudGraphique)
            else:
               nouvelItem=item.itemNode(self,item)
               item.fauxNoeudGraphique=nouvelItem
               self.children.append(nouvelItem)
 
        self.childrenItemComplete=self.construitChildrenComplete()

        if debug : print ("fin *********** buildChildren ",self,self.item, self.item.nom, self.children)

     
    def construitChildrenComplete(self):
    #------------------------------------------
    # PN a tester avec des blocs de blocs
         from . import compobloc
         liste=[]
         for itemFils in self.item._getSubList():
            if isinstance(itemFils,compobloc.Node):
                for itemPetitFils in itemFils.construitChildrenComplete():
                  liste.append(itemPetitFils)
                  itemPetitFils.treeParent=self
            else :
                liste.append(itemFils)
         return liste
            
    #-------------------------
    def getDicoForFancy(self):
    #-------------------------
        return self.item.getDicoForFancy()

    #-----------------------------------
    def appendChild(self,name,pos=None):
    #-----------------------------------
        """
           Methode pour ajouter un objet fils a l'objet associe au noeud self.
           On peut l'ajouter en debut de liste (pos='first'), en fin (pos='last')
           ou en position intermediaire.
           Si pos vaut None, on le place a la position du catalogue.
           Attention a la delegation et aux dictionnaires 
        """
        debug=0
        if debug : print ("************** appendChild ",self.item.getLabelText(), pos, name )

        if self.item.nature != 'JDC' : dictMCVenantDesBlocs=self.item.object.dictMCVenantDesBlocs
        else : dictMCVenantDesBlocs={}

        if debug : print ("dictMCVenantDesBlocs" , dictMCVenantDesBlocs)
        if name in dictMCVenantDesBlocs  :
        # cas d un MC sous un bloc
            mcPere = self.item.object.dictMCVenantDesBlocs[name]
            try :
                if   pos == 'first'       : index = 0
                elif pos == 'last'        : index = len(self.children)
                elif type(pos)   == int   : index = pos  # position fixee
                elif type(pos)  == object : index = mcPere.getIndex(pos) +1 # pos est un item. Il faut inserer name apres pos
                elif type(name) == object : index = mcPere.getIndexChild(name.nom)
                elif self.item.nature != 'JDC' : index = mcPere.getIndexChild(name)
                else : index = self.item.getIndexChild(name)
                #else : return None
            except :
                txt=' Impossible d ajouter {} en position {}'.format(name, pos)
                self.editor.afficheMessage(txt,'rouge')
                return (None, 1, txt)
            if debug : print ('name : ', name, ' a pour index : ', index)
            obj = mcPere.addEntite(name,index)
            if debug : print ('mcPere', mcPere.nom, mcPere.mcListe)
        else : 
            try :
                if   pos == 'first'       : index = 0
                elif pos == 'last'        : index = len(self.children)
                elif type(pos)   == int   : index = pos  # position fixee
                elif type(pos)  == object : index = self.item.getIndex(pos) +1 # pos est un item. Il faut inserer name apres pos
                elif type(name) == object : index = self.item.getIndexChild(name.nom)
                elif self.item.nature != 'JDC' : index = self.item.getIndexChild(name)
                else : index = self.item.getIndexChild(name)
            except :
                txt=' Impossible d ajouter {} en position {}'.format(name, pos)
                self.editor.afficheMessage(txt,'rouge')
                return (None,1, txt) 
            if debug : print ('name : ', name, ' a pour index : ', index)
            obj = self.item.addEntite(name,index) # emet le signal 'add'
        
        if not obj : return (None, 1, "message a affiner")
        if debug : print ('obj', obj.nom, obj.mcListe)
        self.updateOptionnels()
        # on n a pas l ID unique a ce stade car il est porte par l ObjectTreeItem
        return ( 1, 0, "")
        #return child.getIdUnique()

    def delete(self):
    #----------------
        """
            Methode externe pour la destruction de l'objet associe au noeud
        """
        #print ('browser :_appel de delete _______', self, self.vraiParent, self.item.nature)
        
        ret,commentaire=self.vraiParent.item.suppItem(self.item)
        if ret!=0 : 
           self.treeParent.buildChildren()
           self.treeParent.updateOptionnels()
        return (ret,commentaire) 

    def updateOptionnels(self):
    #--------------------------
        debug = 0
        if debug : print ('updateOptionnels pour', self.item.nom)
        if self.item.nature == 'MCList' or self.item.nature == 'JDC' or self.item.nature=='MCSIMP' : return
        monDictPartiel={} 
        monDictPartiel['infoOptionnels'] = self.item.calculOptionnelInclutBlocs()
        if debug : print ('updateOptionnels pour', monDictPartiel)
        self.appliEficas.propageChange(self.editor.editorId, None, None, True, 'updateNodeInfo',self.getIdUnique(), monDictPartiel)

    def updateNodeLabel(self):
    #-------------------------
        monDictPartiel={} 
        label=self.item.getLabelText()[0]
        if label[-1]==":" : label=label[0:-1]
        monDictPartiel['title']=label
        self.appliEficas.propageChange(self.editor.editorId, None, None, True, 'updateNodeInfo',self.getIdUnique(), monDictPartiel)

    def updateRepetable(self,isRepetable):
    #-------------------------------------
        if self.oldRepetable == isRepetable : return
        self.oldRepetable = isRepetable 
        monDictPartiel={} 
        monDictPartiel['repetable']=isRepetable
        self.appliEficas.propageChange(self.editor.editorId, None, None, True, 'updateNodeInfo',self.getIdUnique(), monDictPartiel)

    def updateStatut(self,statut):
    #-----------------------------
        if self.oldStatut == statut : return
        self.oldStatut = statut 
        monDictPartiel={} 
        monDictPartiel['statut']=statut
        self.appliEficas.propageChange(self.editor.editorId, None, None, True, 'updateNodeInfo',self.getIdUnique(), monDictPartiel)

    def getDicoForUpdateNodeName(self):
    #---------------------------------
        monDictPartiel={} 
        monDictPartiel['sdnom'] = self.item.getSdname()
        return monDictPartiel

    def getDicoForUpdateOptionnels(self):
    #-----------------------------------
        if self.item.nature == 'MCList' or self.item.nature == 'JDC' or self.item.nature=='MCSIMP' : return
        monDictPartiel={} 
        monDictPartiel['infoOptionnels'] = self.item.calculOptionnelInclutBlocs()
        return monDictPartiel

    def getDicoForUpdateNodeInfo(self):
    #---------------------------------
        if self.item.nature == 'MCList' or self.item.nature == 'JDC' : print ('dans updateNodeInfo reflechir SVP')
        monDico= self.item.getDicoForFancy()
        return monDico



