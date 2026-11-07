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
from __future__ import print_function

import types,sys,os, re
import traceback


# Modules Eficas
from Accas.extensions.eficas_translation import tr
from Accas.extensions.eficas_exception import EficasException
from Accas.extensions.codeErreur import dictErreurs
from Editeur.loggingEnvironnement import loggingEnvironnement, fonctionLoguee


from InterfaceGUI.Common import comploader
from InterfaceGUI.Common import objecttreeitem
from InterfaceGUI.Web import browser

debug = False

from Editeur.editor import Editor


# -------------------------------- #
class WebEditorExtension(Editor):
# -------------------------------- #
    """
       Extension de l'Editeur de jdc pour la Web
    """

    #-------------------------------
    def __init__ (self, editorPere):
    #-------------------------------
        self.editorPere = editorPere
        self.appliEficas = self.editorPere.appliEficas
        self.jdc = self.editorPere.jdc
        self.editorId = self.editorPere.editorId
        self.dicoIdNode={}
        comploader.chargerComposants('Web')
        self.tree=None
        if self.jdc:
            self.jdc_item=objecttreeitem.makeObjecttreeitem( self.appliEficas, "nom", self.jdc )
            if self.jdc_item :
               self.tree = browser.JDCTree( self.jdc_item,  self )



    #-----------------------------
    @fonctionLoguee
    def getNodeById(self,nodeId ):
    #-----------------------------
        if nodeId in self.dicoIdNode : return self.dicoIdNode[nodeId]
        else : return None

    #---------------------------------------
    @fonctionLoguee
    def reconstruitChaineDIndex(self,nodeId):
    #---------------------------------------
        """ utilise pour logguer les fonctions """
        if nodeId in self.dicoIdNode : 
           node=self.dicoIdNode[nodeId]
           if node.object  == self.jdc : 
               return 'monEditeur.webEditorExtension.tree.racine.item.idUnique'
           chaine="['key']"
           templateChaine='["children"][{}]'
           aTraiter=node.object
           while hasattr(aTraiter,'parent') and aTraiter.parent:
               chaine=templateChaine.format(aTraiter.getIndexDsParent())+chaine
               aTraiter=aTraiter.parent
           chaine='d'+chaine
           return (chaine)
        else : return None


    #-----------------------------
    @fonctionLoguee
    def getDicoForFancy(self,obj) :
    #-----------------------------
        if self.tree == None : return {}
        return obj.getDicoForFancy()

    #-----------------------------------------------------
    @fonctionLoguee
    def updateSDName(self,cId, externEditorId, nodeId, sdnom) :
    #------------------------------------------------------
         monNode=self.getNodeById(nodeId)
         if not monNode : return  (6000, dictErreurs[6000].format(nodeId))
         ok,message =  monNode.fauxNoeudGraphique.updateSDName(sdnom)
         if ok :
            self.appliEficas.propageChange(self.editorId, cId, externEditorId, True, 'updateNodeInfo', nodeId, monNode.fauxNoeudGraphique.getDicoForUpdateNodeName())
            return (0, message, 'nommage effectué')
         else :
            return (7000, dictErreurs[7000].format(nodeId,message), "")

    #-----------------------------------------------
    @fonctionLoguee
    def removeNode(self, cId, externEditorId, nodeId):
    #-----------------------------------------------
         monNode=self.getNodeById(nodeId)
         if not monNode : return  (6000, dictErreurs[6000].format(nodeId))
         if debug : print ('in suppNode pour monNode', monNode)
         (ret,commentaire)=monNode.fauxNoeudGraphique.delete()
         if ret : return (0, "", commentaire)
         else : return ( 8000, commentaire, "")

    #------------------------------------------------------------
    @fonctionLoguee
    def appendChild(self,cid, externEditorId, nodeId, name, pos):
    #-------------------------------------------------------------
         """
         Methode pour ajouter un objet fils name a l objet associe au noeud id.
         On peut l'ajouter en debut de liste (pos='first'), en fin (pos='last')
         ou en position pos_ieme de la liste. (pos = n, avec n = 0 pour avant la 1ere commande)
         retour = nouvelIdUnique ou None
         """
         monNode=self.getNodeById(nodeId)
         if not monNode : return  (None, 6000, dictErreurs[6000].format(nodeId))
         if debug : print (monNode.fauxNoeudGraphique)
         newId, retour, commentaire = monNode.fauxNoeudGraphique.appendChild(name,pos)
         if not retour : return (newId, 0, '', commentaire)
         else : return (newId,  8000, commentaire, '')


    #-------------------------------------------------------------
    @fonctionLoguee
    def changeValue(self, cId, externEditorId, nodeId, valeur) :
    #-------------------------------------------------------------
         """
         cId : canal emetteur
         externEditorId : canel de editor externe emetteur (pour la diffusion ou non)
         nodeId : identifiant unique
         valeur : valeur saisie dans le formulaire
         """
         debug = 0
         if debug : print (' changeValeur cId, externEditorId, nodeId, valeur' ,cId, externEditorId, nodeId, valeur)
         monNode=self.getNodeById(nodeId)
         if not monNode : 
            codeErreur = 6000
            msgErreur = dictErreurs[codeErreur].format(nodeId)
            return (nodeId, CodeErreur, msgErreur, msgInfo)
         if debug : print (' changeValeur', monNode)
         idRetour, validite, commentaire = monNode.fauxNoeudGraphique.traiteValeurSaisie(valeur)
         dicoNode = self.getDicoForFancy(monNode)
         if validite :
             self.appliEficas.propageChange(self.editorId, cId, externEditorId, False, 'updateNodeInfo', nodeId, monNode.fauxNoeudGraphique.getDicoForUpdateNodeInfo())
             if debug : print (' changeValeur', monNode.fauxNoeudGraphique.treeParent, monNode.fauxNoeudGraphique.treeParent.item.nom)
             monNode.fauxNoeudGraphique.treeParent.updateOptionnels()
             return (dicoNode, 0, "", commentaire)
         if not validite :
            return (dicoNode, 40, dictErreurs[40] + commentaire, "")

    #------------------------------------------------------
    def afficheMessage(self, titre, texte, couleur = None):
    #-----------------------------------------------------
    # on ne fait rien
    # contraitement a QT le commentaire est dans le retour de la fonction
         debug = 0
         if debug : print (titre, texte)
