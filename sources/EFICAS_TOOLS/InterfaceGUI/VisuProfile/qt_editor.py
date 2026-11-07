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
#Pour test pre_TimeProfile_general
import traceback
import os
import subprocess
import datetime, time
import concurrent.futures
from collections import OrderedDict
from copy import copy

# Modules Eficas
from Accas.extensions.eficas_translation import tr

from PyQt5.QtWidgets import QWidget, QMessageBox
from PyQt5.QtGui     import QPalette
from PyQt5.QtCore    import Qt

from Editeur.editor            import Editor
from UiQT5.editorVP            import Ui_editorVP
from InterfaceGUI.Common       import comploader
from InterfaceGUI.Common       import objecttreeitem
from InterfaceGUI.VisuProfile  import browser
from InterfaceGUI.VisuProfile.connectDB import connectDB

import Accas.IO.writer as generator


dicoFonctionSelection = {'code_name' : 'initApresChgtCode', 'test_name' : 'initApresChgtChamp', 
                         'host' : 'initApresChgtChamp', 'procs' : 'initApresChgtChamp', 
                         'OS' :  'initApresChgtChamp', 'build_type' : 'initApresChgtChamp', 
                         'version' : 'initApresChgtChamp', 'execution' : 'initApresChgtChamp',
                         'performance' : 'setTypePerformance'}
listeDesChampsAChanger = ('test_name' ,'host', 'procs', 'OS', 'build_type', 'execution', 'version')

def dateCommitGit (gitDir) :
#---------------------------
    #cmd = 'git --git-dir={}/.git --work-tree={} log -1 --format=format:%ci {}'.format(gitDir, gitDir,sha1)
    cmd = 'git --git-dir={}/.git --work-tree={} log --format=format:"%H %ci"'.format(gitDir, gitDir)
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    debug = 0
    if debug : print (result)
    dico = {}
    if result.returncode == 0 :
        if debug : print (result.stdout)
        for ligne in result.stdout.split('\n'):
            if debug : print (ligne)
            (sha1,dateString) = ligne.split(' ',1) 
            if debug : print (sha1,dateString)
            element = datetime.datetime.strptime(dateString.strip(),'%Y-%m-%d %H:%M:%S +%f')
            tuple = element.timetuple()
            timestamp = time.mktime(tuple)
            dico[sha1.strip()] = timestamp
    if debug : print (dico)
    return (result.returncode, dico)


class QtEditor(Ui_editorVP, Editor, QWidget):
# ------------------------------------------ #
    """
       Editeur de jdc VisuProfile
    """

    def __init__(self, appliEficas, cataFile=None, dataSetFile=None, formatIn='python', formatOut='python', QWParent=None, jdc=None  , include = None):
    #----------------------------------------------------------------------------------------------------------------------------

        debug = 0
        if debug : print ('__init__ de QtEditorVP :', appliEficas,dataSetFile, jdc, QWParent)

        QWidget.__init__(self,None)
        self.setupUi(self)
        Editor.__init__( self, appliEficas=appliEficas, cataFile=cataFile, dataSetFile=dataSetFile, 
                         formatIn = formatIn , formatOut=formatOut , jdc=jdc, include = include)
        comploader.chargerComposants(self.appliEficas.GUIPath)
        self.inhibeSplitter=0
        self.widgetOptionnel=None
        self.fenetreCentraleAffichee=self
        self.listeDesListesOuvertes=set()
        self.listeAffichageWidget=[]
        self.afficheListesPliees=False
        self.QWParent=QWParent
        self.node_selected = []
        self.message=''
        self.widgetResultats = None
        self.listeSha1 = []
        self.listeRunId = []
        self.dicoDonnees={}
        self.enteteQTree = 'premier'
        self.connecteur = connectDB()
        self.gitDir=appliEficas.gitDir
        self.typePerformance = 'CPU'
        (resultat, self.dictSha1Date) = dateCommitGit (self.gitDir)
        if resultat :
            self.afficheMessage ('donnees incompletes', 'pb de connexion à la base Git')
            exit()
           

        # a envisager si on garde une selection ?
        self.generatorCondition = generator.plugins['VPRequeteSelection']()
        self.initSelection()

        #self.formatFichierOut =  self.appliEficas.formatFichierOut
        #self.formatFichierIn =  self.appliEficas.formatFichierOut
        self.formatFichierOut = formatOut 
        self.formatFichierIn =  formatIn
        self.node_selected = []
        self.message=''

        # a remettre au gout du jour si on a besoin d un tr
        #    from Accas.extensions import localisation
        #    localisation.localise(self.appliEficas.langue,translatorFile='VisuProfile')
        self.jdcCPU=self._newJDC(texte='')
        self.jdcCPU.analyseXML()
        self.dicoDonneesCPU = {}
        self.afficheCPU([],[],{})


    def initSelection(self) :
    #------------------------
        debug = 0
        if debug : print ('initSelection', texte)
        defSelection = self.readercata.cata.identifiantSelection
        texte = defSelection.nom +'()'
        if debug : print ('texte ' , texte)
        # PNPN : on peut peut-etre sauvagarder et relire des selections anterieures?
        self.jdcSelection=self._newJDC(texte=texte)
        self.jdcSelection.analyse()
        self.etapeSelection = self.jdcSelection.etapes[0]
        if debug : print (self.jdcSelection.etapes)
        self.jdcSelectionItem = objecttreeitem.makeObjecttreeitem( self, "nom", self.jdcSelection )
        if self.jdcSelectionItem :
           self.treeJdcSelection = browser.JDCTree( self.jdcSelectionItem, self )
           if debug : print (self.treeJdcSelection)
           self.widgetSelection = self.treeJdcSelection.racine.children[0].fenetre
           self.editorVPLayout.insertWidget(0,self.widgetSelection)
           self.initCode('','')
         

    def searchActived(self):
    #------------------------
        debug = 0
        if debug: print ('searchActived')
        if debug: print ('traite', self.typePerformance)
        if self.typePerformance == 'CPU' : self.afficheLabels()
        if self.typePerformance == 'Memory' : self.afficheMemory()


    def afficheCommentaire(self,message):
    #------------------------------------
        #self.labelCommentaire.setText(message)
        # a reprogrammer
        debug = 0
        if debug : print (message)

    def  afficheSuivant(self,f):
    #----------------------------
        #print ('ds afficheSuivant')
        try :
            i=self.listeAffichageWidget.index(f)
            next=i+1
            if (next==len(self.listeAffichageWidget) ): next =0
            try : self.listeAffichageWidget[next].setFocus(7)
            except : pass
        except : pass

    def afficheLabels(self, debug = 1): 
    #-----------------------------------
        condition = self.generatorCondition.genereConditionSelection(self.jdcSelection)
        if len(self.listeSha1) == 0 :
            self.afficheMessage ('donnees incompletes', 'pas de sha1 correspondant')
            return
        if len(self.listeSha1) == 1 :
            condition += "and sha1 = '{}'".format(self.listeSha1[0])
        else : condition += 'and sha1 in {}'.format(tuple(self.listeSha1))
        self.listeRunId = self.readercata.cata.cherche_in_profile('run_id', condition = condition, debug=1)
        if len(self.listeRunId) == 0 :
            self.afficheMessage ('donnees incompletes', 'pas de runId correspondant')
            return
        if len(self.listeSha1) == 1 :
            condition = ' run_id  = {}'.format(self.listeRunId[0])
        else : condition = ' run_id in {}'.format(tuple(self.listeRunId))
        if debug : print (condition)
        listeLabelsPossibless = self.readercata.cata.cherche_name(condition)
        if debug : print (listeLabelsPossibless)
        retour = self.changeIntoDefMC('PresentationLabels',('labels',),listeLabelsPossibless, rechercheParNom=True)
        if not retour : self.afficheMessage ('pb sur les labels', 'prevenir la maintenance')
        if debug : print ('init JDC LesLabels')
        texte =  'PresentationLabels();'
        if debug : print ('texte newJDC' , texte)
        self.jdcLabels=self._newJDC(texte=texte)
        self.jdcLabels.analyse()
        jdcLabelsItem = objecttreeitem.makeObjecttreeitem( self, "nom", self.jdcLabels )
        if jdcLabelsItem :
           treeJdcLabels = browser.JDCTree( jdcLabelsItem, self )
           widgetLabels = treeJdcLabels.racine.children[0].fenetre
           widgetLabels.show()

         
    def metAJourSelection(self, nomChamp, texteValeur,  debug = 0):
    #--------------------------------------------------------------#
       if debug : print ('metAJourSelection pour ' , label, texteValeur)
       if nomChamp in dicoFonctionSelection : 
           fonct = dicoFonctionSelection[nomChamp]
           if debug : print ('appel de fonction ' , QtEditor.__dict__[fonct])
           QtEditor.__dict__[fonct](self, nomChamp, texteValeur)

    def initCode(self, nomChamp, valeur):
    #----------------------------------#
    # nomChamp est juste pour pouvoir appeler la fonction
       mcCodeName = self.treeJdcSelection.racine.children[0].item.getChild('code_name')
       if mcCodeName.valeur != None : self.initApresChgtCode()

    def initApresChgtCode(self, debug = 0):
    #-------------------------------------#
       #debug = 1
       if debug : print ('init pour Code ')
       condition  = self.generatorCondition.genereConditionSelection(self.jdcSelection)
       if debug : print ('condition', condition)
       listeTestName = self.readercata.cata.cherche_test_name(condition = condition)
       self.rechercheMCMetAJourInto(self.etapeSelection, 'test_name', listeTestName)

    def initApresChgtChamp(self, nomChamp, valeur):
    #--------------------------------------------#
       debug = 0
       condition  = self.generatorCondition.genereConditionSelection(self.jdcSelection)
       for champ in listeDesChampsAChanger :
            if debug : print (champ)
            if champ == nomChamp : continue
            if debug : print ('traite')
            listeInto = self.readercata.cata.cherche_in_profile(champ, condition = condition)
            if debug : print (listeInto)
            if len(listeInto) > 1 :
                listeChamp = self.etapeSelection.definition.chercheDefinition(champ)
                if len(listeChamp) == 1 :
                    if 'TXM' in listeChamp[0].type : listeInto.append('All')
            self.rechercheMCMetAJourInto(self.etapeSelection, champ, listeInto)
       self.initSha1()

    def initSha1(self):
    #-------------------
       condition  = self.generatorCondition.genereConditionSelection(self.jdcSelection)
       self.listeSha1 = self.readercata.cata.cherche_in_profile('sha1', condition = condition)
       self.ordonneListeSha1()
       self.rechercheMCMetAJourInto(self.etapeSelection, 'sha1_debut', self.listeSha1, initRedessine = False)
       self.rechercheMCMetAJourInto(self.etapeSelection, 'sha1_fin', self.listeSha1Inverse, initRedessine = False)
       self.rechercheMCMetAJourValeur(self.etapeSelection, 'sha1_debut', self.listeSha1[0])
       self.rechercheMCMetAJourValeur(self.etapeSelection, 'sha1_fin', self.listeSha1Inverse[0])

    def rechercheMCMetAJourInto(self, etape, mcName, liste, initRedessine = True):
    #-----------------------------------------------------------------------------
       try :
       #print ('PNPNPN : Attention chgt try en if')
       #if 1 :
          mcObj = etape.getChild(mcName)
          mcObj.definition.changeInto(liste,self.jdcSelection)
          if initRedessine : mcObj.initRedessine()
       except : 
          self.afficheMessage('pb', 'prevenir la maintenance',)

    def rechercheMCMetAJourValeur(self, etape, mcName, valeur):
    #----------------------------------------------------------
       try :
       #print ('PNPNPN : Attention chgt try en if')
       #if 1 :
          mcObj = etape.getChild(mcName)
          mcObj.setValeur(valeur)
          mcObj.initRedessine()
       except : 
          self.afficheMessage('pb', 'prevenir la maintenance',)

    def ordonneListeSha1(self, debug = 1):
    #-------------------------------------
        if debug : print (self.dictSha1Date)
        #self.listeSha1 = sorted(self.listeSha1, key=lambda x: self.dictSha1Date[x])
        self.listeSha1Inverse = copy(self.listeSha1)
        self.listeSha1Inverse.reverse()
        if debug : print ('self.listeSha1', self.listeSha1)
        if debug : print ('self.listeSha1', self.listeSha1)


    def afficheMessage(self,titre,message,critique=True):
    #----------------------------------------------------
        if critique :
           from PyQt5.QtWidgets import QMessageBox
           QMessageBox.critical(None, titre, message)
        else :
           from PyQt5.QtWidgets import QMessageBox
           QMessageBox.information(None, titre, message)

    def afficheMessageQt(self, message, couleur=Qt.black):
    # ----------------------------------------------#
        if couleur == "red": couleur = Qt.red
        if not hasattr(self,'sb') : 
           if couleur == "red": 
              titre = "error"
              critique = True
           else : 
              titre = "info"
              critique = False
           self.afficheMessage(titre, message,critique)
           return
        if self.sb:
            mapalette = self.sb.palette()
            mapalette.setColor(QPalette.WindowText, couleur)
            self.sb.setPalette(mapalette)
            self.sb.showMessage(message, 4000)
            self.couleur = couleur

        dictOrdonne = OrderedDict((sha1, index) for index, sha1 in enumerate(self.listeSha1))
        listeDonneesOrdonnees = sorted(listeDonnees, key=lambda x: dictOrdonne[x[1]])
        for l in listeDonneesOrdonnees :
            dico['Sha1'][l[0]]=l[1] 



    def prepareAfficheCPU(self) :
    #-----------------------------
        debug=1
        if debug : print ('dans prepareAfficheCPU')
        etape=self.jdcLabels.getEtapesByName('PresentationLabels')[0]
        listeLabels = etape.getChild('labels').valeur
        print ('PN a faire tant qu on a des doublons')
        if debug : print ('listeLabels', listeLabels)
        if debug : print ('listeRunId', self.listeRunId)
        if debug : print ('listeSha1', self.listeSha1)
        if len(self.listeRunId ) == 0:
            self.afficheMessage('donnees insuffisantes', 'Pas d enregistrement correspondant')
            return
        if len(self.listeRunId ) > 1 :
            instruction = 'select run_id, sha1, total_cpu_time from profile where run_id in {}'.format(tuple(listeRunId))
        else :
            instruction = 'select run_id, sha1, total_cpu_time from profile where run_id == {}'.format(listeRunId[0])
        liste_total_cpu_time = self.readercata.cata.executeSelect(instruction)
        dicoDonneesCPU = {}
        dicoDonneesCPU['CpuTotalTime']=OrderedDict()
        dicoDonneesCPU['Sha1']=OrderedDict()
        dictOrdonne = OrderedDict((sha1, index) for index, sha1 in enumerate(self.listeSha1))
        listeDonneesOrdonnees = sorted(listeDonnees, key=lambda x: dictOrdonne[x[1]])
        if debug : print ('self listeRunId avant ordonnancement' , self.listeRunId)
        self.listeRunId = []
        for l in listeDonneesOrdonnees :
            self.listeRunId.append(l[0])
            dico['Sha1'][l[0]]=l[1] 
            dico['CpuTotalTime'][l[0]]=l[2] 
        if debug : print ('self.dicoDonneesCPU' , self.dicoDonneesCPU)
        if debug : print ('self listeRunId Ordonnee' , self.listeRunId)
        # Faut-il reordonner la liste des runIds ?
        self.afficheCPU( self.listeRunId, listeLabels, self.dicoDonneesCPU, 1)


    def afficheCPU(self, listeId, listeLabels, dicoDonnees,  debug = 0):
    #----------------------------------------------------------------------------
        if self.widgetResultats : self.editorVPLayout.removeWidget(self.widgetResultats)
        from InterfaceGUI.VisuProfile.monWidgetProfile import MonWidgetProfile
        self.widgetResultats=MonWidgetProfile(self, listeId, listeLabels, dicoDonnees, debug=debug)
        self.editorVPLayout.insertWidget(1,self.widgetResultats)
        if debug : print ('afficheCPU self.widgetResultats', self.widgetResultats)


    def getValuesOfAllMC(self,obj,McPath):
    #------------------------------------
        return obj.getValuesOfAllMC(McPath)
 

    def selectXYWhereCondition(self, MCPath1, MCPath2, MCARetourner, MCCondition, valeur):
    #-----------------------------------------------------------------------------------
    # est-ce que cette signature est bonne ou faut il indiquer le jdc  ?
        return self.jdcCPU.selectXYWhereCondition(MCPath1, MCPath2, MCARetourner, MCCondition, valeur)
        

    def selectXY(self, MCPath1, MCPath2):
    #------------------------------------
        return self.jdcCPU.selectXY(MCPath1, MCPath2)


    def setTypePerformance(self, nomChamp, valeur):
    #---------------------------------------------
       self.typePerformance = valeur 
       

    def afficheInfosForId (self,id):
    #----------------------------
        maRequete = 'select sha1, testName, version,date, CMakeBuildType,execution,procs, host, OS, totalCputime from jobperformance where id = {}'.format(id)
        lesInfos = self.appelleExecutionRequete(maRequete)
        print (lesInfos)
        #texte="Selection(sha1='{}',testName='{}',version='{}',date='{}', CMakeBuildType='{}',execution='{}',procs={}, host='{}', OS='{}');'.format(lesInfos[0],lesInfos[1],lesInfos[2],lesInfos[3],lesInfos[4],lesInfos[5],lesInfos[6],lesInfos[7],lesInfos[8],lesInfos[9])
        #jdcAAfficher=self._newJDC(texte=texte)
        #jdcAAfficher.analyse()


