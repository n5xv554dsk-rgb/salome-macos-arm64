# -*- coding: iso-8859-1 -*-
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
import os, sys


from Accas.extensions.eficas_exception import EficasException
from Editeur import session
from Editeur.getVersion import getEficasVersion
from Accas.extensions.eficas_translation import tr
from Accas.extensions.codeErreur import dictErreurs 

from uuid import uuid1

from threading import Lock
sessionCount  = 0
lock = Lock()


activeLogging=0
if activeLogging :
   from Editeur.loggingEnvironnement import loggingEnvironnement, fonctionLoguee
else :
   fonctionLoguee = lambda func: func


#-----------------
class EficasAppli:
#-----------------
    """
    Class implementing the main user interface.
    """

    #-------------------------------------------------------------------------------------------------------------------------------------------------------------
    def __init__(self, code=None, versionCode=None, salome=1, multi=False, langue=None, ssCode=None, cataFile=None, GUIPath=None, appWeb=None, prefsFile = None ):
    #-------------------------------------------------------------------------------------------------------------------------------------------------------------
        """
        Constructor d appli eficas. classe mere de appli-qtEficas et de appli-web eficas et utilisee sans IHM pour les
        transformations des catas en XSD, des comm en XML et de validation des donnees
        les parametres sont :
            nom du code (exple Adao)
            versionCode (version du code permet de retrouver le catalogue dans le fichier prefs : exple V10-4)
            salome  : lance ou non a partir de salome 
            multi (permet de ne pas specifier le code mais de le demander )
            langue des messages
            ssCode (utilise pour MAP permet de distinguer un patron specifique, un catalogue specifique...)
            fichier catalogue utilise
            preference pour le GUI (QT5, 6 ou Web)
            appWeb si necessaire
        """
        self.code = code
        self.ssCode = ssCode
        self.multi = multi
        self.salome = salome
        self.appWeb = appWeb
        self.dictEditorIdChannelId = {}
        self.dictEditorIdChannelIdExternEid = {}
        self.dictExternalEidEditor = {}
        self.dictChannelType = {} # contient le type de la session ( QT, WEB pour rediriger les messages)
        self.webEditor = None
        self.qtEditors = []

        version = getEficasVersion()
        self.versionEficas = "Eficas Salome " + version
        self.GUIPath = GUIPath
        self.dict_reels = {}
        self.fichierIn = None
        self.fichierOut = None

        self.ficRecents = {}
        self.mesScripts = {}
        self.listePathAEnlever = []

        if session.d_env.cataFile != None : self.cataFile = session.d_env.cataFile
        else: self.cataFile = cataFile
        if session.d_env.versionCode != None : self.versionCode = session.d_env.versionCode
        else : self.versionCode = versionCode
        if session.d_env.prefsFile != None : self.prefsFile = session.d_env.prefsFile
        else: self.prefsFile = prefsFile

        if self.salome:
            try:
                from Accas import SalomeEntry
                #Accas.SalomeEntry = eficasSalome.SalomeEntry
            except  Exception as e:
                print ("impossible d importer les salome entry")
                print (str(e))


        self.langue = langue 
        if self.multi == False:
            self.definitCode(code, ssCode)
            if code == None: return
        else : 
            from Editeur.configuration import BaseConfiguration
            self.maConfiguration = BaseConfiguration(self)
            self.langue = self.maConfiguration.lang 

        self.withUQ = False
        self.genereXSD = False
        from Editeur.editor_manager import EditorManager
        self.editorManager = EditorManager(self)
        # Attention n appelle pas openFiles car les classes derivees
        # changent l editorManager

    #--------------------
    def getVersion(self):
    #--------------------
        return getEficasVersion()

    #-----------------------------------
    def definitCode(self, code, ssCode):
    #-----------------------------------
        # ssCode sert pour Map
        self.code = code
        self.ssCode = ssCode
        if self.code == None: return  

        if ssCode != None:
            self.formatFichierOut = ssCode  # par defaut
            prefsCode.NAME_SCHEME = ssCode
        else:
            self.formatFichierIn = "python"  # par defaut
            self.formatFichierOut = "python"  # par defaut

        self.listePathAEnlever = []
        from Editeur.configuration import BaseConfiguration
        self.maConfiguration = BaseConfiguration(self)
        self.langue = self.maConfiguration.lang 

        from Accas.extensions import localisation
        localisation.localise( self.langue, translatorFile=self.maConfiguration.translatorFile)

        # Comment faire si Multi ?
        if session.d_env.withXSD : self.withXSD = session.d_env.withXSD
        else : self.withXSD = False

    #-------------------------
    def getSource(self, file):
    #-------------------------
        # appele par Editeur/session.py
        import Accas.IO.reader

        p = convert.plugins["python"]()
        p.readfile(file)
        texte = p.convert("execnoparseur")
        return texte

    #-------------------------------------------------------------------------------------------------------
    def getEditorForXSDGeneration(self, cataFile=None, datasetFile=None, formatIn='python', formatOut='xml'):
    #--------------------------------------------------------------------------------------------------------
        if (hasattr(self, "editor")) and self.editor != None:
            print("un seul editeur par application eficas_appli pour generer un XSD ")
            sys.exit()
        self.editor = self.editorManager.getEditorForXSDGeneration(cataFile, datasetFile, formatIn, formatOut)
        return self.editor

    # -------------------------------------------------------------------------------------------------
    def getEditorForGeneration(self, cataFile,datasetFile=None, formatIn='python', formatOut='python'):
    # -------------------------------------------------------------------------------------------------
        if (hasattr(self, "editor")) and self.editor != None:
            print("un seul editeur par application eficas_appli pour generer des autres formats ")
            sys.exit()
        self.editor = self.editorManager.getEditorForXSDGeneration(cataFile, datasetFile, formatIn, formatOut)
        return self.editor

        from Editeur.editor import Editor
        editor = Editor(self.appliEficas, cataFile=cataFile, dataSetFile=None, formatIn=None, formatOut=None)


    #-------------------------------------------------------------------------------------------------------------------
    def getWebEditor(self, cId, cataFile = None, datasetFile=None, jdc=None, include=0, formatIn='python', formatOut='python'):
    # TO DO : separer proprement TUI et WEB. bien reflechir au ligne 
    # avant : refaire l API qu on veut en TUI
    #-------------------------------------------------------------------------------------------------------------------
        debug = 0
        if debug : 
           print ('______________________________ Eficas_appli getWebEditor ________________________')
           print ('self', self)
           print (cId, cataFile, datasetFile, jdc, include, formatIn, formatOut)

        #PN TODO initialiser info
        info = ''
        if cId == None :
           CR = 1000 + 40
           message = dictErreurs[1000].format('cId') + dictErreurs[40] 
           return (None, CR, message, info)

        if formatIn not in ('python', 'xml') : 
           CR = 1000 + 40
           message = dictErreurs[1000].format('formatIn') + dictErreurs[40] 
           return (None, CR, message, info)

        if formatOut not in ('python', 'xml') : 
           CR = 1000 + 40
           message = dictErreurs[1000].format('formatIn') + dictErreurs[40] 
           return (None, CR, message, info)

        if cId in self.dictChannelType.keys() and self.dictChannelType[cId] != 'Web' :
            CR = 100
            return (cId, None, CR, dictErreurs[100], info) 
        if not cId in self.dictChannelType.keys() : self.dictChannelType[cId]  =  'Web'

        (editor, CR, message, info)   = self.editorManager.getWebEditor(cId, cataFile,datasetFile, jdc, include)
        if not editor : return (None, CR, message, info)

        # on pose une lock egalement pour la mise a jour des dico
        with lock :
            externalEditorId = uuid1().hex
            if editor.editorId not in self.dictEditorIdChannelIdExternEid.keys() :
                self.dictEditorIdChannelIdExternEid[editor.editorId] = {}
            if cId not in self.dictEditorIdChannelIdExternEid[editor.editorId] :
                self.dictEditorIdChannelIdExternEid[editor.editorId][cId] = [externalEditorId,]
            else : 
                self.dictEditorIdChannelIdExternEid[editor.editorId][cId].append(externalEditorId)

        self.dictExternalEidEditor[externalEditorId] = editor

        if debug : 
           if editor : print ('getWebEditor id de sesssion :', cId, ' editor : ', editor.editorId, 'externe ',  externalEditorId)
           print ('dictionnaire ' , self.dictEditorIdChannelIdExternEid)
           print ('______________________________ fin getWebEditor ________________________')
        return (externalEditorId, CR, message, info) 

    #--------------------------------------
    def getWebEditorById(self, cId, eId):
    #--------------------------------------
        if cId == None : 
           return ( None, 1000, dict[1000].format ('session Id'), "")
        editor = self.dictExternalEidEditor[eId]
        if cId not in self.dictEditorIdChannelIdExternEid[editor.editorId] :
           return ( None, 1000, 'la session ne possede pas cet Editeur', "")
        if eId not in self.dictEditorIdChannelIdExternEid[editor.editorId][cId] :
           return ( None, 1000, 'incoherence entre Editeur et session', "")
        return (editor, 0, "", "")
        

    #--------------------------------------------------------------------------------------------------------------------------------
    def getTUIEditor (self,cId = None, cataFile = None, datasetFile=None, jdc=None, include=0, formatIn='python', formatOut='python'):
    #---------------------------------------------------------------------------------------------------------------------------------
        if cId == None : 
           self.affichageMessage('Requete non valide', 'Le parametre identifiant la Session Eficas est obligatoire',True)
        self.dictChannelType[cId]  =  'TUI'
        (editor, CR, errorMessage, infoMessage)   = self.editorManager.getTUIEditor(cId, cataFile, datasetFile, jdc, include)
        return (editor, CR, errorMessage, infoMessage) 

    #---------------------------
    def getEditorById(self, eId):
    #----------------------------
        return self.editorManager.getEditorById(eId)

    #----------------------------------
    def setCurrentEditorById(self,id):
    #----------------------------------
        return self.editorManager.setCurrentEditorById(self,id)

    #------------------
    def fileSave(self):
    #-------------------
        return self.editorManager.saveFile()

    #------------------------------
    def fileSaveAs(self, fileName):
    #------------------------------
        return self.editorManager.saveFile()
        if self.editor == None:
            return False
        ok = editor.saveFileAs()
        print("ok ", ok)

    #-----------------------------------------
    def dumpXsd(self, withAbstractElt=False):
    #-----------------------------------------
        currentCata = CONTEXT.getCurrentCata()
        texteXSD = currentCata.dumpXsd(withAbstractElt)
        return texteXSD


    #-------------------
    def saveUQFile(self):
    #-------------------
        self.editorManager.saveUQFile()

    #----------------------
    def exeUQScript(self):
    #----------------------
        self.editorManager.exeUQScript()

    #----------------------
    def savePersalys(self):
    #----------------------
        self.editorManager.savePersalys()

    #----------------------
    def ajoutCommentaire(self):
    #----------------------
        self.editorManager.ajoutCommentaire()

    #----------------------
    def openFiles(self):
    #----------------------
        # Ouverture des fichiers de commandes donnes sur la ligne de commande
        cwd = os.getcwd()
        self.dir = cwd
        if session.d_env.studies == []  : return
        for study in session.d_env.studies:
            os.chdir(cwd)
            d = session.getUnit(study, self)
            self.editorManager.openFile(fichier=study["comm"])


    #---------------------
    def saveFullFile(self):
    #----------------------
    # Pour Telemac
        return self.editorManager.saveCompleteCurrentEditor()

    #-----------------
    def fileNew(self):
    #-------------------
        try:
            self.editorManager.getEditor()
        except EficasException as exc:
            msg = str(exc)
            if msg != "":
                QMessageBox.warning(self, tr("Erreur"), msg)


    #------------------------------
    def fileSaveInLigneFormat(self):
    #------------------------------
        return self.editorManager.fileSaveInLigneFormat()

    #------------------
    def fileSave(self):
    #------------------
        return self.editorManager.handleSave()

    #--------------------
    def fileSaveAs(self):
    #--------------------
        return self.editorManager.handleSaveAs()

    #-------------------
    def fileClose(self):
    #-------------------
        return self.editorManager.fileClose()

    #-------------------
    def closeAllFiles(self):
    #-------------------
        self.editorManager.closeAllFiles()

    #------------
    def run(self):
    #-------------
        self.editorManager.run()

    #----------------
    def saveRun(self):
    #----------------
        self.editorManager.saveRun()

    #--------------------------
    def getJdcFichierSource(self):
    #--------------------------
        return self.editorManager.getJdcFichierSource()

    #-----------------------
    def getJdcRapport(self):
    #-----------------------
        return self.editorManager.getJdcRapport()

    #-----------------------
    def getJjdcRegles(self):
    #-----------------------
        return self.editorManager.JdcRegles()

    #------------------------------
    def getJdcFichierResultat(self):
    #------------------------------
        self.editorManager.getJdcFichierResultat()

    #------------------------------------
    def handleAjoutEtape(self, nomEtape):
    #------------------------------------
        self.editorManager.handleAjoutEtape(nomEtape)

    #----------------
    def ajoutUQ(self):
    #----------------
        self.withUQ = True
        self.formatFichierIn = "pythonUQ"  # par defaut

    #----------------------
    def getSessionId(self):
    #----------------------
    # TODO doit on mettre le type de session en parametre ?
    # tant qu on a pas pris un editor la session est tague TUI
        global sessionCount
        try : 
            with lock:
                sessionCount += 1
                self.dictChannelType[sessionCount]='TUI'
                return (sessionCount, 0, '')
        except Exception as e:
            return (sessionCount, 1000, 'impossible de donner un id : {}.format(str(e))')

    #---------------------------------------------------------------------------
    def propageToWebApp(self, fction, sessionId, externEditorId, *args, **kwargs):
    #---------------------------------------------------------------------------
        #if fction =='propageValide' :
        debug=0
        if debug  : print ('WebEficasAppli.toWebApp',  fction,  *args, **kwargs)
        if self.appWeb == None  : return
        self.appWeb.fromConnecteur(fction, sessionId, externEditorId,  *args, **kwargs)

    #--------------------------------------------------------------------------
    def afficheMessage (self, titre, texte, critical=False, emitEditorId = None ):
    #--------------------------------------------------------------------------
        print ('*******************************')
        print (titre, texte, critical, emitEditorId )
        if emitEditorId != None :
            print ('message emis par ', emitEditorId)

        print (titre)
        print ('-------------------------------')
        print (texte)
        print ('-------------------------------')
        if critical : exit(1)

                
    #-------------------------------------------------------------------------------------------------
    def propageChange (self, editorId, emitChannelId , emitEditorId,  toAll , fction, *args, **kwargs):
    #--------------------------------------------------------------------------------------------------
        #if fction == 'appendChildren' : debug = 1
        #else : debug = 0
        debug = 0
        if debug : 
           print ("------------------------------------------ Eficas")
           print ('propageChange avec les arguments ')
           print ( editorId, emitChannelId, emitEditorId, toAll , fction, *args, **kwargs)
           print (self.dictEditorIdChannelId)
           print ("------------------------------------------ ")
           print (self.dictEditorIdChannelId[editorId])
        for channelId in self.dictEditorIdChannelId[editorId]:
            if debug : print ('channelId', channelId)
            if self.dictChannelType[channelId] == 'TUI': 
                print ('la session est TUI, on ne fait rien')
                continue # Rien a faire le JDC est correcte
            elif self.dictChannelType[channelId] == 'Web': # on verra le QT apres
                if debug : print ( self.dictEditorIdChannelIdExternEid)
                for exId in self.dictEditorIdChannelIdExternEid[editorId][channelId] :
                    if debug : print ('exId', exId)
                    if not toAll and exId == emitEditorId and channelId == emitChannelId : continue
                    if debug : print ('on propage pour ', exId )
                    if debug and 'indexId' in args : print (' et pour ', args['indexId'])
                    self.propageToWebApp(fction, channelId, exId,  *args, **kwargs)

    #---------------------------------------------------------------------------
    #PN --> normalement les codes retours et les messages de retour sont suffisants
    #def displayMessageInSid (self, Sid, titre, texte, critical=True ):
    #---------------------------------------------------------------------------

if __name__ == "__main__":
    # Modules Eficas
    pass
