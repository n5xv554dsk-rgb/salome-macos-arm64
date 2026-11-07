#!/usr/bin/env python3
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

from PyQt5.QtWidgets import QApplication, QMainWindow, QGridLayout, QBoxLayout, QMenu, QAction, QMessageBox
from PyQt5.QtGui import QIcon
from PyQt5.QtCore import Qt, QSize


from Editeur import session
from Editeur.eficas_appli import EficasAppli
from UiQT5.myMain import Ui_Eficas
from InterfaceGUI.QT5.qt_editor_manager import QtEditorManager

from Accas.extensions.eficas_translation import tr
from Accas.extensions.eficas_exception import EficasException
from Accas.extensions import param2


class QtEficasAppli(EficasAppli, Ui_Eficas, QMainWindow):
    """
    Class implementing the main QT user interface.
    contains mainly overloading with qt widgets
    manages the main window and connect qt
    """

    #--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    def __init__(self, code=None, versionCode=None, salome=1, multi=False, langue=None, ssCode=None, cataFile=None, GUIPath="QT5", appWeb = None, parent = None, prefsFile=None):
    #--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        """
        Constructor
        """
        QMainWindow.__init__(self,parent)
        Ui_Eficas.__init__(self)
        EficasAppli.__init__( self, code, versionCode, salome, multi, langue,  ssCode, cataFile, GUIPath, appWeb, prefsFile)
        self.setupUi(self)
        
        self.editorManager = QtEditorManager(self)
        #TODO --> a virer apres accord JPA
        self.viewmanager=self.editorManager

        self.GUIPath = GUIPath
        self.suiteTelemac = self.maConfiguration.suiteTelemac
        self.multi = multi
        if self.maConfiguration.demandeLangue:
            from InterfaceGUI.QT5.monChoixLangue import MonChoixLangue
            widgetLangue = MonChoixLangue(self)
            ret = widgetLangue.exec_()

        self.recemmentUtilises = []
        from Accas.extensions import localisation
        localisation.localise(self.langue, translatorFile=self.maConfiguration.translatorFile,)
        self.repIcon = os.path.join( os.path.dirname(os.path.abspath(__file__)),"..", "..", "Editeur", "icons")

        if not self.salome:
            self.resize(self.maConfiguration.taille, self.height())

        if hasattr (self, 'actionParametres') :
            icon = QIcon(self.repIcon + "/parametres.png")
            self.actionParametres.setIcon(icon)

        if self.maConfiguration.boutonDsMenuBar:
            self.frameEntete.setMaximumSize(QSize(16777215, 100))
            self.frameEntete.setMinimumSize(QSize(0, 100))

        if self.maConfiguration.enleverActionStructures:
            self.enleverActionsStructures()
        if self.maConfiguration.enleverParametres:
            self.enleverParametres()
        if self.maConfiguration.enleverSupprimer:
            self.enleverSupprimer()

        if hasattr(self, "frameEntete"):
            self.myQtab.removeTab(0)
            self.blEnteteGlob = QBoxLayout(2, self.frameEntete)
            self.blEnteteGlob.setSpacing(0)
            self.blEnteteGlob.setContentsMargins(0, 0, 0, 0)

            self.blEntete = QBoxLayout(0)
            self.blEntete.insertWidget(0, self.toolBar)
            self.blEntete.insertWidget(0, self.menubar)
            self.blEnteteGlob.insertLayout(0, self.blEntete)

        if self.maConfiguration.boutonDsMenuBar:
            self.blEnteteCommmande = QBoxLayout(0)
            self.blEnteteCommmande.insertWidget(0, self.toolBarCommande)
            self.toolBarCommande.setIconSize(QSize(96, 96))
            self.blEnteteGlob.insertLayout(-1, self.blEnteteCommmande)
        else:
            if hasattr(self, 'toolBarCommande') :self.toolBarCommande.close()

        if self.maConfiguration.closeEntete :
            self.closeEntete()

        self.recentMenu = QMenu(tr("&Recents"))

        # actionARemplacer ne sert que pour l insert Menu
        if hasattr(self, "actionARemplacer"):
            self.menuFichier.insertMenu(self.actionARemplacer, self.recentMenu)
            self.menuFichier.removeAction(self.actionARemplacer)
        self.connecterSignaux()
        if hasattr(self, 'toolBar') : self.toolBar.addSeparator()

        if self.code != None: self.construitMenu()
        self.setWindowTitle(self.versionEficas)
        try :
        #if 1 :
         #print ('attention try devient if 1')
            self.openFiles()
        except EficasException as exc:
            print ("je suis dans le except", exc)
            if self.salome == 0 : exit()

    #-------------------------
    def openFileFromMenu(self):
    #-------------------------
        self.editorManager.openFile()

    #--------------------
    def closeEntete(self):
    #--------------------
        self.menuBar().close()
        self.toolBar.close()
        self.frameEntete.close()

    #-----------------------------------
    def definitCode(self, code, ssCode):
    #-----------------------------------
        self.code = code
        self.ssCode = ssCode
        if self.code == None:
            from InterfaceGUI.QT5.monChoixCode import MonChoixCode
            widgetChoix = MonChoixCode(self)
            ret = widgetChoix.exec_()
        if self.code == None:
            return  # pour permettre une sortie propre
        EficasAppli.definitCode(self, self.code, ssCode)


    #-----------------------
    def construitMenu(self):
    #-----------------------
        self.initPatrons()
        self.readListRecentlyOpen()
        self.initAides()
        for intituleMenu in (
            "menuTraduction",
            "menuOptions",
            "menuMesh",
            "menuExecution",
        ):
            if hasattr(self, intituleMenu):
                menu = getattr(self, intituleMenu)
                menu.setAttribute(Qt.WA_DeleteOnClose)
                menu.close()
                delattr(self, intituleMenu)
        for intituleAction in ("actionExecution", "actionSaveRun"):
            if hasattr(self, intituleAction):
                action = getattr(self, intituleAction)
                self.toolBar.removeAction(action)
        if self.code.upper() in QtEficasAppli.__dict__:
            QtEficasAppli.__dict__[self.code.upper()]( self,)
        if self.suiteTelemac:
            self.lookSuiteTelemac()
        self.metMenuAJourUtilisateurs()
        if hasattr(self, "maConfiguration") and self.maConfiguration.ajoutExecution:
            self.ajoutExecution()

    #-------------------
    def initAides(self):
    #-------------------
        # print "je passe la"
        repAide = os.path.dirname(os.path.abspath(__file__))
        fileName = "index.html"
        self.docPath = repAide + "../../Aide"
        if hasattr(self, "maConfiguration") and hasattr( self.maConfiguration, "docPath"):
            self.docPath = self.maConfiguration.docPath
        if hasattr(self, "maConfiguration") and hasattr( self.maConfiguration, "fileName"):
            fileName = self.maConfiguration.fileName
        self.fileDoc = os.path.join(self.docPath, fileName)
        self.actionCode.setText(tr("Aide specifique ") + str(self.code))
        if not os.path.isfile(self.fileDoc):
            self.fileDoc = ""
            self.docPath = ""
            self.actionCode.setEnabled(False)
            return

        self.actionCode.setEnabled(True)
        self.menuAide.addAction(self.actionCode)


    #-----------------
    def ajoutUQ(self):
    #-----------------
        EficasAppli.ajoutUQ(self)
        self.menuUQ = self.menubar.addMenu(tr("Incertitude"))
        self.actionSaveUQ = QAction(self)
        self.actionSaveUQ.setText(
            tr("Sauvegarde des fichiers pour l'étude incertaine")
        )
        self.menuUQ.addAction(self.actionSaveUQ)
        self.actionSaveUQ.triggered.connect(self.saveUQFile)
        self.actionExeUQ = QAction(self)
        self.actionExeUQ.setText(tr("Sauvegarde et Lancement de l'étude"))
        self.menuUQ.addAction(self.actionExeUQ)
        self.actionExeUQ.triggered.connect(self.exeUQScript)
        self.actionSauvePersalys = QAction(self)
        self.actionSauvePersalys.setText(tr("Sauvegarde du script Persalys"))
        self.menuUQ.addAction(self.actionSauvePersalys)
        self.actionSauvePersalys.triggered.connect(self.savePersalys)
        # self.actionEnregistrer.setDisabled(True)
        # self.actionEnregistrer_sous.setDisabled(True)


    #------------------------
    def ajoutExecution(self):
    #------------------------
        self.menuExecution = self.menubar.addMenu(tr("&Run"))
        self.actionExecution = QAction(self)
        if sys.platform[0:5] == "linux":
            icon6 = QIcon(self.repIcon + "/roue.png")
            self.actionExecution.setIcon(icon6)
        else:
            self.actionExecution.setText(tr("Run"))
        self.actionExecution.setObjectName("actionExecution")
        self.menuExecution.addAction(self.actionExecution)
        if not (self.actionExecution in self.toolBar.actions()):
            self.toolBar.addAction(self.actionExecution)
        self.actionExecution.setText(tr("Run"))
        self.actionExecution.triggered.connect(self.run)

    #-----------------------------
    def ajoutSauveExecution(self):
    #-----------------------------
        self.actionSaveRun = QAction(self)
        icon7 = QIcon(self.repIcon + "/export_MAP.png")
        self.actionSaveRun.setIcon(icon7)
        self.actionSaveRun.setObjectName("actionSaveRun")
        self.menuExecution.addAction(self.actionSaveRun)
        if not (self.actionSaveRun in self.toolBar.actions()):
            self.toolBar.addAction(self.actionSaveRun)
        self.actionSaveRun.setText(tr("Save Run"))
        self.actionSaveRun.triggered.connect(self.saveRun)

    #---------------------------------
    def griserActionsStructures(self):
    #---------------------------------
        self.actionCouper.setEnabled(False)
        self.actionColler.setEnabled(False)
        self.actionCopier.setEnabled(False)
        self.actionSupprimer.setEnabled(False)

    #---------------------------------
    def enleverActionsStructures(self):
    #---------------------------------
        self.toolBar.removeAction(self.actionCopier)
        self.toolBar.removeAction(self.actionColler)
        self.toolBar.removeAction(self.actionCouper)
        self.menuEdition.removeAction(self.actionCouper)
        self.menuEdition.removeAction(self.actionCopier)
        self.menuEdition.removeAction(self.actionColler)

    #---------------------------
    def enleverParametres(self):
    #---------------------------
        self.toolBar.removeAction(self.actionParametres)
        self.menuJdC.removeAction(self.actionParametres)

    #---------------------------
    def enleverSupprimer(self):
    #---------------------------
        self.toolBar.removeAction(self.actionSupprimer)

    #---------------------------
    def enlevernewInclude(self):
    #---------------------------
        self.actionNouvel_Include.setVisible(False)

    #-------------------------------------
    def enleverRechercherDsCatalogue(self):
    #-------------------------------------
        self.actionRechercherDsCatalogue.setVisible(False)

    #-------------------------------------
    def connectRechercherDsCatalogue(self):
    #------------------------------------
        if hasattr(self, "rechercherDejaLa"): return
        self.rechercherDejaLa = True
        self.actionRechercherDsCatalogue.triggered.connect( self.rechercherMotClefDsCatalogue)

    #-----------------------------
    def ajoutSortieComplete(self):
    #---------------------------
        if hasattr(self, "actionSortieComplete"):
            return
        self.actionSortieComplete = QAction(self)
        self.actionSortieComplete.setText(tr("Sortie Complete"))
        self.menuFichier.insertAction(
            self.actionEnregistrer_sous, self.actionSortieComplete
        )
        self.actionSortieComplete.triggered.connect(self.saveFullFile)

    #--------------
    def ADAO(self):
    #--------------
        self.enleverActionsStructures()
        self.enlevernewInclude()

    #-----------------
    def TELEMAC(self):
    #-----------------
        self.enleverActionsStructures()
        self.enlevernewInclude()
        self.connectRechercherDsCatalogue()
        self.ajoutSortieComplete()

    #-------------------------
    def lookSuiteTelemac(self):
    #-------------------------
        self.enleverActionsStructures()
        self.enlevernewInclude()
        self.enleverParametres()
        self.enleverSupprimer()
        self.enleverRechercherDsCatalogue()

    #------------------------
    def ChercheGrpMesh(self):
    #------------------------
        Msg, listeGroup = self.ChercheGrpMeshInSalome()
        if Msg == None:
            self.editorManager.ajoutGroupe(listeGroup)
        else:
            print("il faut gerer les erreurs")

    #------------------------
    def ChercheGrpMaille(self):
    #------------------------
        # Normalement la variable self.salome permet de savoir si on est ou non dans Salome
        try:
            Msg, listeGroup = self.ChercheGrpMailleInSalome()  # recherche dans Salome
            # Msg = None; listeGroup = None # recherche manuelle, i.e., sans Salome si ligne precedente commentee
        except:
            raise ValueError("Salome non ouvert")
        if Msg == None:
            self.editorManager.ajoutGroupe(listeGroup)
        else:
            print("il faut gerer les erreurs")

    #---------------------
    def ajoutIcones(self):
    #----------------------
        # Pour pallier les soucis de repertoire d icone
        # print self.repIcon
        icon = QIcon(self.repIcon + "/new_file.png")
        self.action_Nouveau.setIcon(icon)
        icon1 = QIcon(self.repIcon + "/ouvrir.png")
        self.actionOuvrir.setIcon(icon1)
        icon2 = QIcon(self.repIcon + "/save.png")
        self.actionEnregistrer.setIcon(icon2)
        icon6 = QIcon(self.repIcon + "/delete.png")
        self.actionSupprimer.setIcon(icon6)
        icon7 = QIcon(self.repIcon + "/roue.png")
        self.actionExecution.setIcon(icon7)


    #--------------------------
    def connecterSignaux(self):
    #--------------------------
        self.recentMenu.aboutToShow.connect(self.showRecentMenu)
        self.action_Nouveau.triggered.connect(self.fileNew)
        self.actionNouvel_Include.triggered.connect(self.newInclude)
        self.actionOuvrir.triggered.connect(self.openFileFromMenu)
        self.actionEnregistrer.triggered.connect(self.fileSave)
        self.actionEnregistrer_sous.triggered.connect(self.fileSaveAs)
        self.actionFermer.triggered.connect(self.fileClose)
        self.actionFermer_tout.triggered.connect(self.closeAllFiles)
        self.actionQuitter.triggered.connect(self.fileExit)

        self.actionEficas.triggered.connect(self.aidePPal)
        self.actionVersion.triggered.connect(self.version)
        self.actionParametres.triggered.connect(self.gestionParam)
        self.actionCommentaire.triggered.connect(self.ajoutCommentaire)

        self.actionCouper.triggered.connect(self.handleEditCut)
        self.actionCopier.triggered.connect(self.handleEditCopy)
        self.actionColler.triggered.connect(self.handleEditPaste)
        self.actionSupprimer.triggered.connect(self.supprimer)
        self.actionRechercher.triggered.connect(self.rechercher)
        self.actionDeplier_replier.triggered.connect(self.deplier)

        self.actionRapport_de_Validation.triggered.connect(self.viewJdcRapport)
        self.actionRegles_du_JdC.triggered.connect(self.viewJdcRegles)
        self.actionFichier_Source.triggered.connect(self.viewJdcFichierSource)
        self.actionFichier_Resultat.triggered.connect(self.viewJdcFichierResultat)
        self.actionAfficher_l_Arbre.triggered.connect(self.ouvreArbre)
        self.actionCacher_l_Arbre.triggered.connect(self.fermeArbre)

        # Pour Aster
        self.actionTraduitV9V10 = QAction(self)
        self.actionTraduitV9V10.setObjectName("actionTraduitV9V10")
        self.actionTraduitV9V10.setText(tr("TraduitV9V10"))
        self.actionTraduitV10V11 = QAction(self)
        self.actionTraduitV10V11.setObjectName("actionTraduitV10V11")
        self.actionTraduitV10V11.setText(tr("TraduitV10V11"))
        self.actionTraduitV11V12 = QAction(self)
        self.actionTraduitV11V12.setObjectName("actionTraduitV11V12")
        self.actionTraduitV11V12.setText(tr("TraduitV11V12"))
        self.actionSaveLigne = QAction(self)
        self.actionSaveLigne.setText(tr("Sauve Format Ligne"))

        # self.actionParametres_Eficas.triggered.connect(self.optionEditeur)
        self.actionTraduitV9V10.triggered.connect(self.traductionV9V10)
        self.actionTraduitV10V11.triggered.connect(self.traductionV10V11)
        self.actionTraduitV11V12.triggered.connect(self.traductionV11V12)
        self.actionSaveLigne.triggered.connect(self.fileSaveInLigneFormat)

        # Pour Carmel
        self.actionChercheGrpMaille = QAction(self)
        self.actionChercheGrpMaille.setText(tr("Acquiert Groupe Maille"))


        # Pour Aide
        self.actionCode = QAction(self)
        self.actionCode.setText(tr("Specificites Maille"))
        self.actionCode.triggered.connect(self.aideCode)

    #----------------
    def deplier(self):
    #-----------------
        self.editorManager.deplier()

    #-------------------------
    def ajoutCommentaire(self):
    #-------------------------
        self.editorManager.ajoutCommentaire()

    #---------------------
    def initPatrons(self):
    #---------------------
        # Mise a jour du menu des fichiers recemment ouverts
        from Editeur import listePatrons

        if not (self.code in listePatrons.sous_menus):
            if hasattr(self, "menuPatrons"):
                self.menuPatrons.setAttribute(Qt.WA_DeleteOnClose)
                self.menuPatrons.close()
                delattr(self, "menuPatrons")
            return
        if not hasattr(self, "menuPatrons"):
            self.menuPatrons = QMenu(self.menubar)
            self.menuPatrons.setObjectName("menuPatrons")
            self.menubar.addAction(self.menuPatrons.menuAction())
            self.menuPatrons.setTitle(tr("Patrons"))
        else:
            self.menuPatrons.clear()
        self.listePatrons = listePatrons.listePatrons(self.code)
        idx = 0
        for nomSsMenu in self.listePatrons.liste:
            ssmenu = self.menuPatrons.addMenu(nomSsMenu)
            for fichier in self.listePatrons.liste[nomSsMenu]:
                id = ssmenu.addAction(fichier)
                self.ficPatrons[id] = fichier
                self.id.triggered.connect(self.openPatrons)
                #   self.Patrons.setItemParameter(id,idx)
                idx = idx + 1

    #------------------------------
    def readListRecentlyOpen(self):
    #------------------------------
        self.recemmentUtilises = []
        rep = self.maConfiguration.repUser
        monFichier = rep + "/listefichiers_" + self.code
        index = 0
        try:
            with open(monFichier) as f:
                while index < 9:
                    ligne = f.readline()
                    if ligne != "":
                        l = (ligne.split("\n"))[0]
                        self.recemmentUtilises.append(l)
                    index = index + 1
        except:
            pass

    #----------------------------
    def addToRecentList(self, fn):
    #-----------------------------
        while fn in self.recemmentUtilises:
            self.recemmentUtilises.remove(fn)
        self.recemmentUtilises.insert(0, fn)
        if len(self.recemmentUtilises) > 9:
            self.recemmentUtilises = self.recemmentUtilises[:9]

    #-----------------------------
    def saveListRecentlyOpen(self):
    #-----------------------------
        if len(self.recemmentUtilises) == 0: return
        rep = self.maConfiguration.repUser
        if not (os.path.isdir(rep)) :
            try:
              os.makedirs(rep)
            except:
              self.afficheMessageQt ('liste des fichiers recents','creation de la directory impossible')
              return
          
        monFichier = rep + "/listefichiers_" + self.code
        try:
            index = 0
            with open(monFichier, "w") as f:
                while index < len(self.recemmentUtilises):
                    ligne = str(self.recemmentUtilises[index]) + "\n"
                    f.write(ligne)
                    index = index + 1
        except:
            self.afficheMessageQt ('liste des fichiers recents','impossible de sauvegarder la liste des fichiers recents')

    #-------------------------
    def traductionV11V12(self):
    #-------------------------
        from InterfaceGUI.QT5.gereTraduction import traduction
        traduction(self.maConfiguration.repIni, self.editorManager, "V11V12")

    #--------------------------
    def traductionV10V11(self):
    #---------------------------
        from InterfaceGUI.QT5.gereTraduction import traduction
        traduction(self.maConfiguration.repIni, self.editorManager, "V10V11")

    #----------------------------
    def traductionV9V10(self):
    #----------------------------
        from InterfaceGUI.QT5.gereTraduction import traduction
        traduction(self.maConfiguration.repIni, self.editorManager, "V9V10")

    #--------------------------------------------------
    def afficheMessageQt(self, titre, texte,critical=True):
    #--------------------------------------------------
        if critical :
          QMessageBox.critical( None, tr(titre), tr(texte))
        else : 
          QMessageBox.warning( None, tr(titre), tr(texte))

    #----------------
    def version(self):
    #----------------
        from InterfaceGUI.QT5.monVisu import DVisu

        titre = tr("version ")
        monVisuDialg = DVisu(parent=self, fl=0)
        monVisuDialg.setWindowTitle(titre)
        if self.code != None:
            monVisuDialg.TB.setText(self.versionEficas + tr(" pour ") + self.code)
        else:
            monVisuDialg.TB.setText(self.versionEficas)
        monVisuDialg.adjustSize()
        monVisuDialg.show()

    #----------------
    def aidePPal(self):
    #----------------
        repAide = os.path.dirname(os.path.abspath(__file__))
        maD = os.path.join(repAide, "..", "Doc")
        try:
            indexAide = os.path.join(maD, "index.html")
            if sys.platform[0:5] == "linux":
                cmd = "xdg-open " + indexAide
            else:
                cmd = "start " + indexAide
            os.system(cmd)
        except:
            QMessageBox.warning(
                self, tr("Aide Indisponible"), tr("l'aide n est pas installee ")
            )

    #----------------
    def aideCode(self):
    #----------------
        if self.code == None: return
        try:
            if sys.platform[0:5] == "linux":
                cmd = "xdg-open " + self.fileDoc
            else:
                cmd = "start " + self.fileDoc
            os.system(cmd)
        except:
            # else:
            QMessageBox.warning(
                self, tr("Aide Indisponible"), tr("l'aide n est pas installee ")
            )

    #------------------------
    def optionEditeur(self):
    #------------------------
    # a revoir entierement
    # en particulier pour le nom de la configuration
    # obsolete
        try:
            name = "monOptions_" + self.code
        except:
            QMessageBox.critical( self, tr("Parametrage"), tr("Veuillez d abord choisir un code"))
            return
        try:
        # if 1:
            optionCode = __import__(name)
        except:
        # else :
            QMessageBox.critical( self, tr("Parametrage"), tr("Pas de possibilite de personnalisation de la configuration "),)
            return
        monOption = optionCode.Options(
            parent=self, modal=0, configuration=self.maConfiguration
        )
        monOption.show()

    #------------------
    def optionPdf(self):
    #---------------------
        from InterfaceGUI.QT5.monOptionsPdf import OptionPdf
        monOption = OptionPdf(parent=self, modal=0, configuration=self.maConfiguration)
        monOption.show()

    #------------------------
    def showRecentMenu(self):
    #------------------------
        """
        Private method to set up recent files menu.
        """
        self.recentMenu.clear()

        for rp in self.recemmentUtilises:
            id = self.recentMenu.addAction(rp)
            self.ficRecents[id] = rp
            id.triggered.connect(self.openRecentFile)
        self.recentMenu.addSeparator()
        self.recentMenu.addAction(tr("&Effacer"), self.clearListRecent)

    #---------------------
    def openPatrons(self):
    #---------------------
        repPatrons = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..","..","Codes","Patrons","self.code")
        idx = self.sender()
        fichier = self.repPatrons+"/"+ self.ficPatrons[idx]
        self.editorManager.openFile(fichier=fichier, patron=1)

    #------------------------
    def openRecentFile(self):
    #------------------------
        idx = self.sender()
        fichier = self.ficRecents[idx]
        self.editorManager.openFile(fichier=fichier, patron=0)

    #-------------------------
    def clearListRecent(self):
    #------------------------
        self.recemmentUtilises = []
        self.saveListRecentlyOpen()

    #--------------------------------------
    def rechercherMotClefDsCatalogue(self):
    #--------------------------------------
        if not self.editorManager: return
        self.editorManager.rechercherMotClefDsCatalogue()

    #----------------
    def fileNew(self):
    #----------------
        try:
            self.editorManager.getEditor()
        except EficasException as exc:
            msg = str(exc)
            if msg != "":
                QMessageBox.warning(self, tr("Erreur"), msg)


    #-----------------
    def fileExit(self):
    #-----------------
        # On peut sortir sur Abort
        # equivalent du closeEvent sur la fenetre
        res = self.editorManager.closeAllFiles()
        if res != 2: self.close()
        return res

    #------------------------
    def handleEditCopy(self):
    #------------------------
        self.editorManager.handleEditCopy()

    #------------------------
    def handleEditCut(self):
    #------------------------
        self.editorManager.handleEditCut()

    #------------------------
    def handleEditPaste(self):
    #------------------------
        self.editorManager.handleEditPaste()

    #-------------------
    def rechercher(self):
    #---------------------
        self.editorManager.rechercherConceptOuMotClef()

    #----------------
    def supprimer(self):
    #----------------
        self.editorManager.handleSupprimer()

    #-----------------------------
    def viewJdcFichierSource(self):
    #-----------------------------
        self.editorManager.viewJdcFichierSource()

    #------------------------
    def viewJdcRapport(self):
    #------------------------
        self.editorManager.viewJdcRapport()

    #------------------------
    def viewJdcRegles(self):
    #------------------------
        self.editorManager.viewJdcRegles()

    #------------------------------
    def viewJdcFichierResultat(self):
    #-------------------------------
        self.editorManager.viewJdcFichierResultat()

    #------------------------
    def gestionParam(self):
    #------------------------
        self.editorManager.handleGestionParam()

    #--------------------
    def ouvreArbre(self):
    #--------------------
        self.editorManager.ouvreArbre()

    #--------------------
    def fermeArbre(self):
    #--------------------
        self.editorManager.fermeArbre()

    #--------------------
    def newInclude(self):
    #--------------------
        self.editorManager.newIncludeEditor()

    #---------------------------
    def closeEvent(self, event):
    #---------------------------
        res = self.fileExit()
        if res == 2: event.ignore()

    #-------------------------------
    def remplitIconesCommandes(self):
    #-------------------------------
    # permet de remplacer les commandes par des icones
    # plus usite depuis machine tournante
    # a retester
        if self.maConfiguration.boutonDsMenuBar == False: return
        if not hasattr(self, "readercata"): return

        from InterfaceGUI.QT5.monLayoutBouton import MonLayoutBouton
        if hasattr(self, "monLayoutBoutonRempli"): return
        self.monLayoutBoutonRempli = MonLayoutBouton(self)


    #-----------------------------------
    def metMenuAJourUtilisateurs(self):
    #----------------------------------
        self.lesFonctionsUtilisateurs = {}
        if self.code not in self.mesScripts:
            return
        if not hasattr(self.mesScripts[self.code], "dict_menu"):
            return
        for monMenu in iter(self.mesScripts[self.code].dict_menu.items()):
            titre, lesFonctions = monMenu
            self.menuOptions = self.menubar.addMenu("menuOptions")
            self.menuOptions.setTitle(tr(titre))
            for elt in lesFonctions:
                laFonctionUtilisateur, label, lesArguments = elt
                action = QAction(self)
                action.setText(label)
                # action.triggered.connect(self.appelleFonctionUtilisateur)
                self.menuOptions.addAction(action)
                self.lesFonctionsUtilisateurs[action] = (
                    laFonctionUtilisateur,
                    lesArguments,
                )
            self.menuOptions.triggered.connect(self.handleFonctionUtilisateur)

    #-------------------------------------------
    def handleFonctionUtilisateur(self, action):
    #-------------------------------------------
        (laFonctionUtilisateur, lesArguments) = self.lesFonctionsUtilisateurs[action]
        self.editorManager.handleFonctionUtilisateur(laFonctionUtilisateur, lesArguments)


if __name__ == "__main__":
    # Modules Eficas
    rep = os.path.abspath(
        os.path.join(os.path.dirname(os.path.abspath(__file__), "..", "Adao"))
    )
    sys.path.append(rep)
    from Adao import prefs
    from Adao import prefs_Adao

    # Analyse des arguments de la ligne de commande
    options = session.parse(sys.argv)
    code = options.code

    app = QApplication(sys.argv)
    # app.setMainWidget(mw) (qt3)
    Eficas = Appli()
    Eficas.show()

    # mw.show()

    res = app.exec_()
    sys.exit(res)
