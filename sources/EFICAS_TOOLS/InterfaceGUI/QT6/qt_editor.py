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


import types, sys, os, re
import subprocess

from PyQt6.QtWidgets import QWidget, QMessageBox, QFileDialog, QApplication, QSplitter, QLabel
from PyQt6.QtGui     import QPalette, QFont
from PyQt6.QtCore    import QProcess, QFileInfo, QTimer, Qt, QDir, QSize, QProcessEnvironment

import traceback

# Modules Eficas
from Accas.extensions.eficas_translation import tr
from Editeur import session
from InterfaceGUI.Common import comploader
from InterfaceGUI.Common import objecttreeitem
from InterfaceGUI.QT6 import browser

from UiQT6.desBaseWidget import Ui_baseWidget
from InterfaceGUI.QT6.monViewTexte import ViewText
from InterfaceGUI.QT6.monWidgetCreeParam import MonWidgetCreeParam

Dictextensions = {"MAP": ".map", "TELEMAC": ".cas"}
debug = False


from Editeur.editor import Editor


class QtEditor(Editor, Ui_baseWidget, QWidget):
# -------------------------------------------- #
    """
    Editeur de jdc
    """

    def __init__( self, appliEficas, cataFile = None, dataSetFile=None, formatIn = 'python', formatOut = 'python', jdc=None, QWParent=None, include=0):
    # ---------------------------------------------------------------------------------------------------------------------------------------------

        QWidget.__init__(self, None)
        self.setupUi(self)

        self.inhibeSplitter = 0
        self.widgetOptionnel = None
        self.fenetreCentraleAffichee = None
        self.dejaDansPlieTout = False
        self.listeDesListesOuvertes = set()
        if appliEficas != None and hasattr(appliEficas, "statusBar"):
            self.sb = appliEficas.statusBar()
        else:
            self.sb = None
        self.QWParent = QWParent

        Editor.__init__(self, appliEficas=appliEficas, cataFile = cataFile , dataSetFile = dataSetFile , jdc = jdc, include = include, formatIn = formatIn , formatOut = formatOut)

        # on enleve la gestion du dicEditor necessaire dans les autres cas
        # mais ici l index est le numero de page et non l editorId
        del self.appliEficas.editorManager.dictEditors[self.editorId]

        if self.jdc:
            comploader.chargerComposants(self.appliEficas.GUIPath)
            self.jdc_item = objecttreeitem.makeObjecttreeitem(self, "nom", self.jdc)

        # Particularites IHM : met la fenetre a jour
        self.initSplitterSizes()
        self.afficheListesPliees = self.maConfiguration.afficheListesPliees

        if self.maConfiguration.closeArbre: self.fermeArbre()
        if self.maConfiguration.closeOptionnel: self.fermeOptionnel()
        if self.maConfiguration.boutonDsMenuBar: self.appliEficas.remplitIconesCommandes()

        self.formatFichierOut = self.appliEficas.formatFichierOut
        self.formatFichierIn = self.appliEficas.formatFichierIn

        self.node_selected = []
        self.deplier = True
        self.message = ""
        self.afficheApresInsert = False
        if self.maConfiguration.closeArbre: self.afficheApresInsert = True
        if self.code in ["Adao", "ADAO", "MAP"]:
            self.afficheApresInsert = True
        if self.code in [ "TELEMAC", ]: self.enteteQTree = "premier"
        else: self.enteteQTree = "complet"
        if self.code in ["Adao", "ADAO", "TELEMAC", "VP"]:
            self.affichePlie = True
        else:
            self.affichePlie = False

        # PN. a specifier vraiment pour savoir 
        # ou se trouve le fichier de traduction si demandeCatalogue
        # cat appel a  t il sa place ici ?
        if self.appliEficas.readercata.demandeCatalogue == True:
            translatorFileSpecalise =  self.appliEficas.maConfiguration.translatorFile
            localisation.localise(language=self.appliEficas.langue, translatorFile=self.appliEficas.maConfiguration.translatorFile)

        self.appliEficas.construitMenu()
        if self.jdc_item : self.tree = browser.JDCTree(self.jdc_item, self)
        self.adjustSize()

    # -----------------#
    def readCata(self) :
    # -----------------#
        if ( not hasattr(self.appliEficas, "readercata")
            or self.appliEficas.readercata.demandeCatalogue == True
            or self.appliEficas.multi == True):

            if self.maConfiguration.typeDeCata == "XML":
                from Accas.catalog import reader_cata_XML as reader_cata
            else:
                from Accas.catalog import reader_cata
            self.readercata = reader_cata.ReaderCata(self.appliEficas, self)
            self.appliEficas.readercata = self.readercata
            self.appliEficas.code = self.code
        else:
            self.readercata = self.appliEficas.readercata

        if self.readercata :
            self.titre = self.readercata.titre



    # --------------------#
    def readFile(self, fn):
    # --------------------#
        """
        Public slot to read the text from a file.
        @param fn filename to read from (string or QString)
        """

        jdc = Editor.readFile(self, fn)

        # Particularites IHM : met le titre de la fenetre a jour
        #        qApp.restoreOverrideCursor()
        if self.fileInfo != None:
            self.lastModified = self.fileInfo.lastModified()
        nouveauTitre = self.titre + "              " + os.path.basename(self.dataSetFile)
        self.appliEficas.setWindowTitle(nouveauTitre)

        return jdc

    # -----------------------------------------------------------------------#
    def _viewText(self, txt, caption="File_viewer", largeur=1200, hauteur=600):
    # ------------------------------------------------------------------------#
        w = ViewText(self.QWParent, self, caption, txt, largeur, hauteur)
        w.show()

    # ------------------------------------------#
    def informe(self, titre, txt, critique=True):
    # ------------------------------------------#
        if critique:
            self.afficheMessageQt(tr(txt), Qt.GlobalColor.red)
            QMessageBox.critical(self, tr(titre), tr(txt))
        else:
            QMessageBox.warning(self, tr(titre), tr(txt))

    # ------------------------#
    def ajoutCommentaire(self):
    # ------------------------#
        if self.tree.selectedItems() == []:
            QMessageBox.warning(
                self,
                tr("Pas de noeud selectionne"),
                tr( "Selectionnez un Noeud \nLe commentaire sera place apres le noeud selectionne"
                ),
            )
            return
        noeudAvantCommentaire = self.tree.selectedItems()[0]
        if noeudAvantCommentaire == self.tree.racine:
            self.tree.racine.appendChild("COMMENTAIRE", pos=0)
            return
        noeudAvantCommentaire.addComment(True)

    # -----------------------------------------------------------------------------------------------#
    def _viewTextExecute( self, txt, prefix, suffix, fichierExe=None, shell="sh", texteCommande=None):
    # -----------------------------------------------------------------------------------------------#
        self.myWidget = ViewText(self.QWParent)
        self.myWidget.setWindowTitle("execution")
        self.myWidget.view.setFont(QFont("Monospace"))
        self.monExe = QProcess(self.myWidget)
        pid = self.monExe.pid()
        if not fichierExe and txt:
            fichierExe = self.generateTempFilename(prefix, suffix=".sh")
            f = open(fichierExe, "self.myWidget")
        f.write(txt)
        f.close()
        self.monExe.readyReadStandardOutput.connect(self.readFromStdOut)
        self.monExe.readyReadStandardError.connect(self.readFromStdErr)
        if texteCommande != None:
            exe = texteCommande
        else:
            exe = shell + " " + fichierExe
        monEnv = QProcessEnvironment.systemEnvironment()
        monEnv.insert("COLUMNS", "500")
        self.monExe.setProcessEnvironment(monEnv)
        self.monExe.start(exe)
        self.monExe.closeWriteChannel()
        self.myWidget.exec_()
        if self.monExe != None:
            self.monExe.readyReadStandardOutput.disconnect()
            self.monExe.readyReadStandardError.disconnect()
        if txt:
            commande = "rm  " + fichierExe
            os.system(commande)
        return 1

    # -----------------------#
    def readFromStdErr(self):
    # -----------------------#
        a = self.monExe.readAllStandardError()
        chaine = str(a.data(), encoding="utf-8")
        self.myWidget.view.append(chaine)
        # self.myWidget.view.append(str(a.data()))

    # ----------------------#
    def readFromStdOut(self):
    # ----------------------#
        a = self.monExe.readAllStandardOutput()
        chaine = str(a.data(), encoding="utf-8")
        self.myWidget.view.append(chaine)

    # self.wmyWidget.view.append(str(a.data()))

    # -----------------------#
    def gestionParam(self):
    # -----------------------#
        w = MonWidgetCreeParam(self)
        w.show()

    # ----------------#
    def closeIt(self):
    # ----------------#
        """
        Public method called by the editorManager to finally get rid of us.
        """
        if self.jdc:
            self.jdc.supprime()
        self.close()

    # ----------------------------------------------------#
    #def afficheMessage(self, titre, message, couleur=Qt.GlobalColor.black):
    def afficheMessage(self, titre, message, couleur=None):
    # ----------------------------------------------------#
        # Pour garder le meme fonctionnement pour les 3 utilisations
        # on a un afficheMessageQt qui affiche dans la SB
        QMessageBox.information(self, titre, message)

    # ----------------------------------------------#
    #def afficheMessageQt(self, message, couleur=Qt.GlobalColor.black):
    def afficheMessageQt(self, message, couleur=None):
    # ----------------------------------------------#
    # couleur = couleur Qt ou red ou None
        if couleur == "red": couleur = Qt.GlobalColor.red
        if self.sb:
            mapalette = self.sb.palette()
            mapalette.setColor(QPalette.ColorRole.WindowText, couleur)
            self.sb.setPalette(mapalette)
            self.sb.showMessage(message, 4000)
            self.couleur = couleur

    # -------------------------------------#
    def afficheAlerte(self, titre, message):
    # -------------------------------------#
        QMessageBox.information(self, titre, message)

    # -----------------------------------#
    def afficheCommentaire(self, message):
    # -----------------------------------#
        self.labelCommentaire.setText(message)
        QTimer.singleShot(6000, self.rendInvisible)

    # ----------------------#
    def rendInvisible(self):
    # ----------------------#
        self.labelCommentaire.setText("")

    # ---------------------------------------#
    def chercheNoeudSelectionne(self, copie=1):
    # ---------------------------------------#
        """
        appele par Cut et Copy pour positionner self.node_selected
        """
        self.node_selected = []
        if len(self.tree.selectedItems()) == 0:
            return
        self.node_selected = self.tree.selectedItems()

    # ---------------------#
    def handleSupprimer(self):
    # ---------------------#
        self.chercheNoeudSelectionne()
        if len(self.node_selected) == 0:
            return
        self.QWParent.noeud_a_editer = []
        if self.node_selected[0] == self.tree.racine:
            return
        if len(self.node_selected) == 1:
            self.node_selected[0].delete()
        else:
            self.node_selected[0].deleteMultiple(self.node_selected)

    # ------------------------#
    def rechercherConceptOuMotClef(self):
    # ------------------------#
        from InterfaceGUI.QT6.monRecherche import DRecherche
        monRechercheDialg = DRecherche(parent=self, fl=0)
        monRechercheDialg.show()

    # -----------------------------------#
    def rechercherMotClefDsCatalogue(self):
    # -----------------------------------#
        from InterfaceGUI.QT6.monRechercheCatalogue import DRechercheCatalogue

        monRechercheDialg = DRechercheCatalogue(self.QWParent, self)
        monRechercheDialg.show()

    # ---------------------#
    def deplier(self):
    # ---------------------#
        if self.tree == None:
            return
        # self.tree.collapseAll()
        if self.deplier:
            # print "je plie"
            self.tree.expandItem(self.tree.topLevelItem(0))
            self.deplier = False
            if self.fenetreCentraleAffichee != None:
                if hasattr(self.fenetreCentraleAffichee.node, "plieToutEtReaffiche"):
                    self.fenetreCentraleAffichee.node.plieToutEtReaffiche()
        else:
            # print "je deplie"
            self.tree.expandItem(self.tree.topLevelItem(0))
            self.deplier = True
            if self.fenetreCentraleAffichee != None:
                if hasattr(self.fenetreCentraleAffichee.node, "deplieToutEtReaffiche"):
                    self.fenetreCentraleAffichee.node.deplieToutEtReaffiche()

    # ---------------------#
    def handleEditCut(self):
    # ---------------------#
        """
        Stocke dans Eficas.noeud_a_editer le noeud a couper
        """
        # print "handleEditCut"
        self.chercheNoeudSelectionne()
        self.QWParent.edit = "couper"
        self.QWParent.noeud_a_editer = self.node_selected

    # -----------------------#
    def handleEditCopy(self):
    # -----------------------#
        """
        Stocke dans Eficas.noeud_a_editer le noeud a copier
        """
        self.chercheNoeudSelectionne()
        if len(self.node_selected) == 0:
            return
        if len(self.node_selected) == 1:
            self.node_selected[0].updateNodeLabelInBlue()
        else:
            self.node_selected[0].updatePlusieursNodeLabelInBlue(self.node_selected)
        self.QWParent.edit = "copier"
        self.QWParent.noeud_a_editer = self.node_selected

    # ------------------------#
    def handleEditPaste(self):
    # ------------------------#
        """
        Lance la copie de l'objet place dans self.QWParent.noeud_a_editer
        Ne permet que la copie d'objets de type Commande ou MCF
        """
        self.chercheNoeudSelectionne()
        if (not (hasattr(self.QWParent, "noeud_a_editer"))) or len(
            self.QWParent.noeud_a_editer
        ) == 0:
            QMessageBox.information(
                self,
                tr("Copie impossible"),
                tr("Veuillez selectionner un objet a copier"),
            )
            return
        if len(self.node_selected) != 1:
            QMessageBox.information(
                self,
                tr("Copie impossible"),
                tr(
                    "Veuillez selectionner un seul objet : la copie se fera apres le noeud selectionne"
                ),
            )
            return
        noeudOuColler = self.node_selected[0]

        if len(self.QWParent.noeud_a_editer) != 1:
            # self.handleEditPasteMultiple()
            QMessageBox.information(
                self, tr("Copie impossible"), tr("Aucun Objet n a ete copie ou coupe")
            )
            return

        noeudACopier = self.QWParent.noeud_a_editer[0]

        if self.QWParent.edit != "couper":
            # print   (noeudOuColler.item.parent.getChild(noeudOuColler.item.nom))
            try:
                if noeudOuColler == self.tree.racine:
                    child = noeudOuColler.doPastePremier(noeudACopier)
                else:
                    child = noeudACopier.doPaste(noeudOuColler, "after")

                if child == None or child == 0:
                    QMessageBox.critical(
                        self,
                        tr("Copie refusee"),
                        tr("Eficas n a pas reussi a copier l objet"),
                    )
                    self.message = ""
                    self.afficheMessageQt("Copie refusee", Qt.GlobalColor.red)
                if noeudACopier.treeParent.editor != noeudOuColler.treeParent.editor:
                    try:
                        nom = noeudACopier.item.sd.nom
                        child.item.nommeSd(nom)
                    except:
                        pass
                return
                self.initModif()
                child.select()
            except:
                traceback.print_exc()
                QMessageBox.critical(
                    self, tr("Copie refusee"), tr("Copie refusee pour ce type d objet")
                )
                self.message = ""
                self.afficheMessageQt("Copie refusee", Qt.GlobalColor.red)
                return

        # il faut declarer le JDCDisplay_courant modifie
        # suppression eventuelle du noeud selectionne
        # si possible on renomme l objet comme le noeud couper

        if self.QWParent.edit == "couper":
            if noeudACopier.treeParent.editor != noeudOuColler.treeParent.editor:
                QMessageBox.critical(
                    self,
                    tr("Deplacement refuse"),
                    tr(
                        "Deplacement refuse entre 2 fichiers. Seule la copie est autorisee "
                    ),
                )

            # if 1:
            try:
                # indexNoeudACopier=noeudACopier.treeParent.children.index(noeudACopier)
                indexNoeudACopier = self.getTreeIndex(noeudACopier)
                noeudACopier.treeParent.item.deplaceEntite(
                    indexNoeudACopier, indexNoeudOuColler, pos
                )
                noeudACopier.treeParent.buildChildren()

            # else:
            except:
                pass
            self.QWParent.noeud_a_editer = []

        # on rend la copie a nouveau possible en liberant le flag edit
        self.QWParent.edit = "copier"
        noeudACopier.select()

    # ------------------------------#
    def handleDeplaceMultiple(self):
    # ------------------------------#
        print ('a programmer')
        pass

    # --------------------------------#
    def handleEditPasteMultiple(self):
    # -------------------------------#

        # On ne garde que les niveaux "Etape"
        # On insere dans l'ordre du JDC
        listeNoeudsACouper = []
        listeIndex = []
        listeChild = []
        listeItem = []
        from InterfaceGUI.QT6 import compojdc

        noeudOuColler = self.node_selected[0]
        if not (isinstance(noeudOuColler.treeParent, compojdc.Node)):
            QMessageBox.information(
                self,
                tr(
                    "Copie impossible a cet endroit",
                ),
                tr(
                    "Veuillez selectionner une commande, un parametre, un commentaire ou une macro"
                ),
            )
            return
        indexNoeudOuColler = noeudOuColler.treeParent.children.index(noeudOuColler)

        for noeud in self.QWParent.noeud_a_editer:
            if not (isinstance(noeud.treeParent, compojdc.Node)):
                continue
            indexInTree = noeud.treeParent.children.index(noeud)
            indice = 0
            for index in listeIndex:
                if index < indexInTree:
                    indice = indice + 1
            listeIndex.insert(indice, indexInTree)
            listeNoeudsACouper.insert(indice, noeud)

        noeudJdc = noeudOuColler.treeParent
        dejaCrees = 0
        # on les cree a l'envers parcequ'on ajoute a NoeudOuColler
        listeIndex.reverse()
        for index in listeIndex:
            indexTravail = index
            if indexNoeudOuColler < index:
                indexTravail = indexTravail + dejaCrees
            noeudOuColler = noeudJdc.children[indexNoeudOuColler]
            noeud = noeudJdc.children[indexTravail]
            child = noeud.doPaste(noeudOuColler)
            listeChild.append(child)
            dejaCrees = dejaCrees + 1

        self.QWParent.noeud_a_editer = []
        for i in range(len(listeIndex)):
            noeud = noeudJdc.children[indexNoeudOuColler + 1 + i]
            self.QWParent.noeud_a_editer.append(noeud)

        listeASupprimer = []
        if self.QWParent.edit != "couper":
            return

        for index in listeIndex:
            indexTravail = index
            if indexNoeudOuColler < index:
                indexTravail = indexTravail + (len(listeIndex))
            noeud = noeudJdc.children[indexTravail]

            listeItem.append(noeud.item)
            listeASupprimer.append(noeud)

        for i in range(len(listeChild)):
            self.tree.item.suppItem(listeItem[i])
            listeChild[i].item.update(listeItem[i])

        self.QWParent.noeud_a_editer = []

    # ----------------------------------#
    def handleAjoutEtape(self, nomEtape):
    # ----------------------------------#
        self.chercheNoeudSelectionne()
        if len(self.node_selected) == 0 or self.node_selected[0] == self.tree.racine:
            nodeOuAjouter = self.tree.racine
            nouveau = nodeOuAjouter.appendChild(nomEtape, pos="first")
        else:
            nodeOuAjouter = self.node_selected[0]
            if nodeOuAjouter != self.tree.racine:
                while nodeOuAjouter.treeParent != self.tree.racine:
                    nodeOuAjouter = nodeOuAjouter.treeParent
            nouveau = nodeOuAjouter.appendBrother(nomEtape)
        try:
            self.node_selected[0].setSelected(False)
        except:
            pass
        nouveau.setSelected(True)
        nouveau.affichePanneau()

    # -----------------------#
    def getFileVariable(self):
    # -----------------------#
        titre = tr("Choix d'un fichier XML")
        texte = tr("Le fichier contient une commande MODEL\n")
        texte = texte + tr(
            "Donnez le nom du fichier XML qui contient la description des variables"
        )
        QMessageBox.information(self, titre, tr(texte))

        fichier = QFileDialog.getOpenFileName(
            self.appliEficas,
            tr("Ouvrir Fichier"),
            self.appliEficas.maConfiguration.saveDir,
            tr("Wrapper Files (*.xml);;" "All Files (*)"),
        )
        return fichier

    # ------------#
    def run(self):
    # ------------#
        fonction = "run" + self.code
        if fonction in QtEditor.__dict__: QtEditor.__dict__[fonction](
                self,
            )

    # ------------#
    def saveRun(self):
    # ------------#
        fonction = "saveRun" + self.code
        if fonction in QtEditor.__dict__:
            QtEditor.__dict__[fonction](
                self,
            )

    # ------------------------------------
    # Methodes qui n existent pas sans Ihm 
    # -------------------------------------

    # --------------------------------------------#
    def determineNomFichier(self, path, extension):
    # --------------------------------è-----------#
        if self.appliEficas.code in Dictextensions:
            chaine1 = ( Dictextensions[self.appliEficas.code] + " (*." + Dictextensions[self.appliEficas.code] + ");;")
            extensions = tr(chaine1 + "All Files (*)")
        else:
            extensions = tr("JDC (*.comm);;" "All Files (*)")

        fn = QFileDialog.getSaveFileName(
            self, tr("sauvegarde"),
            path, extensions, None,
            QFileDialog.DontConfirmOverwrite,
        )
        if fn == None:
            return (0, None)
        fn = fn[0]
        if fn == "":
            return (0, None)

        ext = QFileInfo(fn).suffix()
        if ext == "":
            fn += extension

        if QFileInfo(fn).exists():
            msgBox = QMessageBox(self)
            msgBox.setWindowTitle(tr("Sauvegarde du Fichier"))
            msgBox.setText(tr("Le fichier") + "  " + str(fn) + "  " + tr("existe deja"))
            msgBox.addButton(tr("&Ecraser"), 0)
            msgBox.addButton(tr("&Abandonner"), 1)
            abort = msgBox.exec_()
            if abort == 1:
                return (0, "")
        return (1, fn)

    # -----------------#
    def saveRunMAP(self):
    # -----------------#
        extension = ".input"
        if not (self.jdc.isValid()):
            QMessageBox.critical(
                self,
                tr("Sauvegarde de l'input impossible "),
                tr("Un JdC valide est necessaire pour creer un .input"),
            )
            return
        try:
            composant = self.jdc.etapes[0].nom.lower()[0:-5]
        except:
            QMessageBox.critical(
                self,
                tr("Sauvegarde de l'input impossible "),
                tr("Choix du composant obligatoire"),
            )
            return
        path = self.maConfiguration.saveDir

        monNomFichier = ""
        if self.dataSetFile is not None and self.dataSetFile != "":
            maBase = str(QFileInfo(self.dataSetFile).baseName()) + ".input"
            monPath = str(QFileInfo(self.dataSetFile).absolutePath())
            monNomFichier = os.path.join(monPath, maBase)
        elif hasattr(self, "monNomFichierInput"):
            monNomFichier = self.monNomFichierInput

        monDialog = QFileDialog(self.appliEficas)
        monDialog.setDirectory(path)
        monDialog.setWindowTitle("Save")

        for c in monDialog.children():
            if isinstance(c, QDialogButtonBox):
                for b in c.children():
                    if isinstance(b, QPushButton):
                        avant = b.text()
                        if avant == "&Open":
                            b.setText("Save")
        mesFiltres = "input Map (*.input);;All Files (*)"
        monDialog.setNameFilters(mesFiltres)
        if monNomFichier != "":
            monDialog.selectFile(monNomFichier)
        BOk = monDialog.exec_()
        if BOk == 0:
            return
        fn = str(monDialog.selectedFiles()[0])
        if fn == "" or fn == None:
            return
        if not fn.endswith(".input"):
            fn += ".input"
        self.monNomFichierInput = fn

        if (
            not hasattr(self, "fichierMapInput")
            or not self.fichierMapInput
            or not os.path.exists(self.fichierMapInput)
        ):
            self.fichierMapInput = self.generateTempFilename(
                prefix="map_run", suffix=".map"
            )
            texte = self.getTextJDC("MAP")
            self.writeFile(self.fichierMapInput, txt=texte)

        cmd = (
            "map gen -t dat -n "
            + composant
            + " -i "
            + self.fichierMapInput
            + " -o "
            + fn
        )
        p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE)
        (output, err) = p.communicate()


    # -----------------------------------------#
    def ajoutGroupe(self, listeGroup):
    # -----------------------------------------#
        try:
            # if 1:
            from InterfaceGUI.QT6.ajoutGroupe import ajoutGroupeFiltre

            # print listeGroup
            ajoutGroupeFiltre(self, listeGroup)
            # print "apres ajoutGroupeFiltre"
        except:
            # else :
            pass

    # ----------------------------------------------------------------------#
    def saveCompleteFile(self, path=None, saveas=0, formatLigne="beautifie"):
    # ----------------------------------------------------------------------#
        extension = ".casR"
        fn = self.fichierComplet
        # saveas=True # Pour forcer le nom
        self.myWriter = self.mesWriters.plugins[self.formatFichierOut]()
        if self.fichierComplet is None or saveas:
            if path is None:
                path = self.maConfiguration.saveDir
            bOK, fn = self.determineNomFichier(path, extension)
            if bOK == 0:
                return (0, None)
            if fn == None:
                return (0, None)
            if fn == "":
                return (0, None)

            ulfile = os.path.abspath(fn)
            self.appliEficas.maConfiguration.saveDir = os.path.split(ulfile)[0]
            fn = QDir.toNativeSeparators(fn)

        self.fichierComplet = os.path.splitext(fn)[0] + extension

        if hasattr(self.myWriter, "writeComplet"):
            self.myWriter.writeComplet(
                self.fichierComplet,
                self.jdc,
                config=self.appliEficas.maConfiguration,
                appliEficas=self.appliEficas,
            )

        if self.appliEficas.salome:
            self.appliEficas.addJdcInSalome(self.fichierComplet)

        self.modified = 0
        nouveauTitre = (
            self.titre + "              " + str(os.path.basename(self.fichierComplet))
        )
        self.appliEficas.setWindowTitle(nouveauTitre)
        return (1, self.fichierComplet)

    # --------------------------------------------------------------#
    def saveFile(self, path=None, saveas=0, formatLigne="beautifie"):
    # --------------------------------------------------------------#
        """
        Public slot to save the text to a file.

        @param path directory to save the file in (string or QString)
        @return tuple of two values (boolean, string) giving a success indicator and
            the name of the saved file
        """

        self.modified = 1
        if not self.modified and not saveas:
            return (0, None)  # do nothing if text wasn't changed

        if self.appliEficas.code in Dictextensions:
            extension = Dictextensions[self.appliEficas.code]
        else:
            extension = ".comm"

        newName = None
        fn = self.dataSetFile
        if self.dataSetFile is None or saveas:
            if path is None:
                path = self.maConfiguration.saveDir
            bOK, fn = self.determineNomFichier(path, extension)
            if bOK == 0:
                return (0, None)
            if fn == None:
                return (0, None)
            if fn == "":
                return (0, None)

            ulfile = os.path.abspath(fn)
            self.appliEficas.maConfiguration.saveDir = os.path.split(ulfile)[0]
            fn = QDir.toNativeSeparators(fn)
            newName = fn

        if not (self.writeFile(fn, formatLigne=formatLigne)):
            return (0, None)
        self.dataSetFile = fn
        self.modified = False
        if self.fileInfo is None or saveas:
            self.fileInfo = QFileInfo(self.dataSetFile)
            self.fileInfo.setCaching(0)
        self.lastModified = self.fileInfo.lastModified()
        if newName is not None:
            self.appliEficas.addToRecentList(newName)
            self.tree.racine.item.getObject().nom = os.path.basename(newName)
            self.tree.racine.updateNodeLabel()

        if self.jdc.cata.modeleMetier:
            self.jdc.toXml(self.dataSetFile)
        if self.jdc.cata.modeleMetier and self.jdc.isValid():
            if self.myWriter != self.XMLWriter:
                self.XMLWriter.gener(self.jdc)
                self.XMLWriter.writeDefault(fn)

        if self.jdc.isValid() != 0 and hasattr(self.myWriter, "writeDefault"):
            self.myWriter.writeDefault(fn)
        elif self.code == "TELEMAC" and hasattr(self.myWriter, "writeDefault"):
            msgBox = QMessageBox(None)
            msgBox.setWindowTitle(tr("Fichier .cas invalide / incomplet"))
            msgBox.setText(tr("Le fichier .cas est invalide / incomplet"))
            msgBox.addButton(tr("&Sauvegarder"), 1)
            msgBox.addButton(tr("&Quitter sans sauvegarder"), 0)
            msgBox.addButton(tr("&Annuler"), 2)
            res = msgBox.exec_()
            if res == 0:
                self.myWriter.writeDefault(fn)
                return (1, self.dataSetFile)
            if res == 2:
                return (0, None)
            if self.appliEficas.salome:
                self.appliEficas.close()
            else:
                sys.exit(1)

        if self.appliEficas.salome:
            self.appliEficas.addJdcInSalome(self.dataSetFile)
        self.modified = 0
        nouveauTitre = (
            self.titre + "              " + str(os.path.basename(self.dataSetFile))
        )
        self.appliEficas.setWindowTitle(nouveauTitre)

        return (1, self.dataSetFile)

    # ---------------------------------------#
    def sauvePourPersalys(self, fichier=None):
    # ---------------------------------------#
        if self.jdc.isValid() == 0:
            self.informe(
                "Fichier invalide/incomplet",
                "Impossible de sauvegarder l étude Persalys",
                critique=False,
            )
            return
        if self.dataSetFile is None:
            if path is None:
                path = self.maConfiguration.saveDir
            bOK, fn = self.determineNomFichier(path, "comm")
            if bOK == 0:
                return (0, None)
            if fn == None:
                return (0, None)
            if fn == "":
                return (0, None)
            ulfile = os.path.abspath(fn)
            self.appliEficas.maConfiguration.saveDir = os.path.split(ulfile)[0]
            fn = QDir.toNativeSeparators(fn)
            self.dataSetFile = fn
        else:
            fn = self.dataSetFile
        ret, comm = Editor.sauvePourPersalys(self, fn)
        if not ret:
            if not comm:
                comm = "Impossible de sauvegarder l étude Persalys"
            self.informe(" invalide/incomplet", comm, critique=False)
            return

    # --------------------------------------------#
    def saveUQFile(self, fichier=None, path=None):
    # -------------------------------------------#
        if self.dataSetFile is None:
            if path is None:
                path = self.maConfiguration.saveDir
            bOK, fn = self.determineNomFichier(path, "comm")

            if bOK == 0: return (0, None)
            if fn == None: return (0, None)
            if fn == "": return (0, None)

            ulfile = os.path.abspath(fn)
            self.appliEficas.maConfiguration.saveDir = os.path.split(ulfile)[0]
            fn = QDir.toNativeSeparators(fn)
            self.dataSetFile = fn
        else:
            fn = self.dataSetFile

        if self.jdc.isValid() == 0:
            msgBox = QMessageBox(None)
            msgBox.setWindowTitle(tr("Fichier invalide / incomplet"))
            msgBox.setText(
                tr(
                    "Le fichier .comm est invalide / incomplet \n Seuls les .comm et _det.comm seront sauvegardes"
                )
            )
            msgBox.addButton(tr("&Sauvegarder les .comm et _det.comm"), 0)
            msgBox.addButton(tr("&Quitter sans sauvegarder"), 1)
            msgBox.addButton(tr("&Annuler"), 2)
            res = msgBox.exec_()
            if res == 2:
                return (0, None)
            if res == 0:
                ret, fichier = Editor.saveUQFile(self, fn)
                if ret:
                    self.dataSetFile = fichier
                if self.appliEficas.salome and ret:
                    self.appliEficas.addJdcInSalome(self.dataSetFile)
                return (1, self.dataSetFile)
            if self.appliEficas.salome:
                self.appliEficas.close()
            else:
                sys.exit(1)

        ret, comm = Editor.saveUQFile(self, fn)
        if not ret:
            if comm:
                titre = "Probleme de sauvegarde des fichiers"
                texte = "Impossible de sauvegarder {}".format(fn)
                QMessageBox.information(self, titre, texte)
            return (0, self.dataSetFile)
        return (1, self.dataSetFile)

    # --------------------------------------#
    def exeUQ(self, fichier=None, path=None):
    # --------------------------------------#
        # if self.modified or not self.dataSetFile :
        sauvegarde, fichier = self.saveUQFile()
        if not sauvegarde:
            return 0
        # texteCommande=' export COLUMNS=200;'
        try:
            virtual_env = os.environ["VIRTUAL_ENV"]
        except:
            titre = "Probleme d'environnement"
            texte = "La variable d'environnement VIRTUAL_ENV n'est pas positionnée"
            QMessageBox.information(self, titre, texte)
            return False

        texteCommande = (
            os.path.join(os.environ["VIRTUAL_ENV"], "bin/salome")
            + " start -k -t python3 "
            + os.path.join(
                self.myWriter.cheminFichierComm, self.myWriter.fichierUQExe
            )
        )
        # self._viewTextExecute(None,None,None, fichierExe=self.myWriter.fichierUQExe, shell='python3')
        # self._viewTextExecute('ls -l /tmp','essaiLs','.sh',)
        # self._viewTextExecute(None,None,None, fichierExe='/home/A96028/QT6Dev/eficasRN/ReacteurNumerique/a.py',shell='python3',)
        self._viewTextExecute(None, None, None, texteCommande=texteCommande)
        return True

    # --------------------#
    def saveLigneFile(self):
    # --------------------#
        self.modified = 1
        return self.saveFile(formatLigne="Ligne")

    # --------------------------------------------#
    def saveFileAs(self, path=None, fileName=None):
    # ---------------------------------------------#
        """
        save a file with a new name.

        @param path directory to save the file in (string or QString)
        @return tuple of two values (boolean, string) giving a success indicator and
            the name of the saved file
        """
        if fileName != None:
            self.dataSetFile = fileName
            return self.saveFile()
        return self.saveFile(path, 1, "beautifie")

    # -------------------------------------------#
    def getFile(self, unite=None, fic_origine=""):
    # -------------------------------------------#
        ulfile = None
        jdcText = ""

        titre = ""

        if unite:
            titre = tr("Choix unite %d ", unite)
            texte = ( tr("Le fichier %s contient une commande INCLUDE \n", str(fic_origine)) + "\n")
            texte = ( texte
                + tr("Donnez le nom du fichier correspondant a l unite logique ") + repr(unite))
            labeltexte = tr("Fichier pour unite ") + repr(unite)
        else:
            titre = tr("Choix d'un fichier de poursuite")
            texte = tr("Le fichier %s contient une commande POURSUITE\n", fic_origine)
            texte = texte + tr(
                "Donnez le nom du fichier dont vous \n voulez faire une poursuite"
            )

        QMessageBox.information(self, titre, texte)
        fn = QFileDialog.getOpenFileName(
            self.appliEficas, titre, self.appliEficas.maConfiguration.saveDir
        )

        if fn == "": return None, " "
        if not fn: return (0, " ")
        fn = fn[0]

        ulfile = os.path.abspath(fn)
        self.appliEficas.maConfiguration.saveDir = os.path.split(ulfile)[0]

        # On utilise le convertisseur defini par formatFichierIn
        source = self.getSource(ulfile)
        if source:
            # On a reussia convertir le fichier self.ulfile
            jdcText = source
        else:
            # Une erreur a ete rencontree
            jdcText = ""
        return ulfile, jdcText

    # -------------------------------#
    def updateJdc(self, etape, texte):
    # -------------------------------#
        # ajoute une etape  de JdC a partir d un texte
        CONTEXT.setCurrentStep(etape)
        etape.buildIncludeEtape(texte)
        if not (etape.text_included_converted):
            QMessageBox.information(
                self, tr("Impossible d importer le texte"), etape.text_included_error
            )

        self.tree.racine.buildChildren()

    # ----------------------------------------#
    def updateJdcEtape(self, itemApres, texte):
    # -----------------------------------------#
        # ajoute une etape  de JdC a partir d un texte
        monItem = itemApres
        etape = monItem.item.object

        CONTEXT.setCurrentStep(etape)
        try:
            ok = etape.buildIncludeEtape(texte)
        except:
            ok = 0
        if not ok:
            QMessageBox.information(
                self, tr("Import texte"), tr("Impossible d importer le texte")
            )
        self.tree.racine.buildChildren()
        return ok

    # ----------------------------------------#
    def updateJdcAfterEtape(self, etape, texte):
    # ----------------------------------------#
        # ajoute une etape  de JdC a partir d un texte
        CONTEXT.setCurrentStep(etape)
        try:
            ok = etape.buildIncludeEtape(texte, doitEtreValide=0)
        except:
            ok = 0
        if not ok:
            QMessageBox.information(
                self, tr("Import texte"), tr("Impossible d importer le texte")
            )
        self.tree.racine.buildChildren()
        return ok

    # -------------------------------------#
    def initSplitterSizes(self, nbWidget=3):
    # -------------------------------------#
        # print ("je passe ds initSplitterSizes", nbWidget)

        if self.code in ["Adao", "ADAO", "MAP"]:
            self.splitterSizes3 = [1, 1550, 300]
        # elif self.code in [ 'MAP']            : self.splitterSizes3=[700,300]
        else:
            self.splitterSizes3 = [150, 1000, 300]

        if self.code in ["Adao", "ADAO", "MAP"]:
            self.splitterSizes2 = [5, 1500]
        else:
            self.splitterSizes2 = [300, 1000]

    # ----------------------------------------#
    def restoreSplitterSizes(self, nbWidget=3):
    # ----------------------------------------#

        # traceback.print_stack()
        # print ("je passe ds restoreSplitterSizes")
        if not (hasattr(self, "splitter")):
            return
        if nbWidget == 2:
            newSizes = self.splitterSizes2
        if nbWidget == 3:
            newSizes = self.splitterSizes3
        # self.inhibeSplitter = 1
        # print (newSizes)
        self.splitter.setSizes(newSizes)
        # self.inhibeSplitter = 0
        QApplication.processEvents()
        # seule la fentetre du milieu est necessaire
        self.splitter.widget(1).resizeEvent = self.saveSplitterSizes

    # --------------------------------#
    def saveSplitterSizes(self, event):
    # --------------------------------#
        # print ("je passe ds saveSplitterSizes")
        if self.inhibeSplitter:
            return
        if self.widgetOptionnel == None:
            self.splitterSizes2 = self.splitter.sizes()[0:2]
        else:
            self.splitterSizes3 = self.splitter.sizes()[0:3]

    # -----------------------#
    def fermeOptionnel(self):
    # -----------------------#
        if self.widgetOptionnel == None:
            return

        self.inhibeSplitter = 1
        self.widgetOptionnel.setParent(None)
        self.widgetOptionnel.close()
        self.widgetOptionnel.deleteLater()
        self.widgetOptionnel = None
        self.inhibeSplitter = 0
        self.restoreSplitterSizes(2)

    # ----------------------#
    def ajoutOptionnel(self):
    # ----------------------#
        # if len(self.splitterSizes) == 2 : self.splitterSizes.append(self.oldSizeWidgetOptionnel)
        # else : self.splitterSizes[2] = self.oldSizeWidgetOptionnel # ceinture pour les close bizarres
        # self.splitterSizes[1] = self.splitterSizes[1] - self.splitterSizes[2]

        self.restoreSplitterSizes(3)

    # ------------------#
    def fermeArbre(self):
    # ------------------#
        # print (self.widgetTree)
        self.oldWidgetTree = self.widgetTree
        self.widgetTree.hide()
        # self.widgetTree=None

    # ------------------#
    def ouvreArbre(self):
    # ------------------#
        # print ('je passe la')
        # print (self.widgetTree)
        # self.widgetTree=self.oldWidgetTree
        self.widgetTree.show()
        # self.restoreSplitterSizes(3)

    # -----------------------#
    def getEtapeCourante(self):
    # -----------------------#
        if len(self.tree.selectedItems()) != 1:
            return None
        etape = self.tree.selectedItems()[0].item.object.getEtape()
        return etape

    # ----------------------------#
    def getTreeIndex(self, noeud):
    # ----------------------------#
        indexNoeud = -1
        if noeud in noeud.treeParent.children:
            indexNoeud = noeud.treeParent.children.index(noeud)
        else:
            if hasattr(noeud, "vraiParent"):
                noeudVrai = noeud
                noeudVraiParent = noeud.vraiParent
                while noeudVraiParent != noeud.treeParent and hasattr(
                    noeudVraiParent, "vraiParent"
                ):
                    noeudVrai = noeudVraiParent
                    noeudVraiParent = noeudVraiParent.vraiParent
                    pass
                if noeudVraiParent == noeud.treeParent:
                    indexNoeud = noeud.treeParent.children.index(noeudVrai)
                    pass
                pass
            pass
        return indexNoeud

    # ----------------------------#
    def viewJdcFichierSource(self):
    # ----------------------------#
        strSource = self.getJdcFichierSource() 
        self._viewText(strSource, "JDC Source")

    # ----------------------------#
    def viewJdcFichierResultat(self):
    # ----------------------------#
        strResultat = self.getJdcFichierResultat() 
        self._viewText(strResultat, "JDC Resultat")

    # -----------------------#
    def viewJdcRegles(self):
    # -----------------------#
        strRegle = self.getJdcRegles() 
        self._viewText(strRegle, "Regles du JDC")

    # ----------------------------#
    def viewJdcRapport(self):
    # ----------------------------#
        strRapport = self.getJdcRapport() 
        self._viewText(strRapport, "Rapport Validation du JDC")
  
    # ------------------#
    def _newJDCCND(self):
    # ------------------#
        """ obsolete """
    # allait chercher les groupes med. gardé pour l exemple
        extensions = tr("Fichiers Med (*.med);;" "Tous les Fichiers (*)")
        QMessageBox.information(
            self, tr("Fichier Med"), tr("Veuillez selectionner un fichier Med")
        )
        QSfichier = QFileDialog.getOpenFileName(
            self.appliEficas, caption="Fichier Med", filter=extensions
        )
        QSfichier = QSfichier[0]
        self.fichierMED = QSfichier
        from Accas.extensions.acquiert_groupes import getGroupes
        erreur, self.listeGroupes, self.nomMaillage, self.dicoCoord = getGroupes(
            self.fichierMED
        )
        if erreur != "": print("a traiter")
        texteComm = (
            "COMMENTAIRE(u'Cree - fichier : "
            + self.fichierMED
            + " - Nom Maillage : "
            + self.nomMaillage
            + "');\nPARAMETRES()\n"
        )
        texteSources = ""
        texteCond = ""
        texteNoCond = ""
        texteVcut = ""
        texteZs = ""
        for groupe in self.listeGroupes:
            if groupe[0:8] == "CURRENT_":
                texteSources += groupe[8:] + "=SOURCE("
                texteSources += "VecteurDirecteur=(1.0,2.0,3.0,),);\n"
            if groupe[0:5] == "COND_":
                texteCond += groupe[5:] + "=CONDUCTEUR();\n"
            if groupe[0:7] == "NOCOND_":
                texteNoCond += groupe[7:] + "=NOCOND();\n"
            if groupe[0:5] == "VCUT_":
                texteVcut += "V_" + groupe[5:] + "=VCUT();\n"
            if groupe[0:3] == "ZS_":
                texteZs += groupe[3:] + "=ZS();\n"
        texte = texteComm + texteSources + texteCond + texteNoCond + texteVcut + texteZs
        self.newTexteCND = texte
        self.modified = 1
                             

if __name__ == "__main__":
    print("in main")
