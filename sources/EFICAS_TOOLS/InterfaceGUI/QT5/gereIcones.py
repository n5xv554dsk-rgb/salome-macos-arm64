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
# Modules Python


import types, os, re, sys
import traceback
import inspect

from PyQt5.QtWidgets import QMessageBox, QFileDialog, QMenu, QPushButton, QTreeView, QListView, QAbstractItemView
from PyQt5.QtGui import QIcon
from PyQt5.QtCore import QFileInfo, Qt, QSize, QVariant


from Accas.extensions.eficas_translation import tr

listeSuffixe = ("bmp", "png", "jpg", "txt", "med")


class FacultatifOuOptionnel(object):
#-----------------------------------
    """ Gere les boutons """
    def setReglesEtAide(self):
        listeRegles = ()
        listeRegles = self.node.item.getRegles()
        if hasattr(self, "RBRegle"):
            if listeRegles == (): self.RBRegle.close()
            else:
                icon = QIcon(self.repIcon + "/lettreRblanc30.png")
                self.RBRegle.setIcon(icon)
                self.RBRegle.clicked.connect(self.viewRegles)

        cle_doc = None

        if not hasattr(self, "RBInfo"): return
        icon = QIcon(self.repIcon + "/point-interrogation30.png")
        self.RBInfo.setIcon(icon)

        from InterfaceGUI.QT5.monWidgetCommande import MonWidgetCommande
        if isinstance(self, MonWidgetCommande) and self.editor.code == "MAP": self.cle_doc = self.chercheDocMAP()
        else: self.cle_doc = self.node.item.getDocu()
        if self.cle_doc == None: self.RBInfo.close()
        else: self.RBInfo.clicked.connect(self.viewDoc)

    def chercheDocMAP(self):
        try:
            clef = self.editor.maConfiguration.adresse + "/"
        except:
            return None
        for k in self.editor.readercata.cata.JdC.dict_groupes:
            if self.obj.nom in self.editor.readercata.cata.JdC.dict_groupes[k]:
                clef += k
                break
        clef += (
            "/"
            + self.obj.nom[0:-5].lower()
            + "/spec_"
            + self.obj.nom[0:-5].lower()
            + ".html"
        )

        return clef

    def viewDoc(self):
        try:
            if sys.platform[0:5] == "linux":
                cmd = "xdg-open " + self.cle_doc
            else:
                cmd = "start " + self.cle_doc
            os.system(cmd)
        except:
            QMessageBox.warning(
                self, tr("Aide Indisponible"), tr("l'aide n est pas installee ")
            )

    def viewRegles(self):
        self.node.appellebuildLBRegles()

    def setIconePoubelle(self):
        if not (hasattr(self, "RBPoubelle")):
            return

        if self.node.item.object.isOblig() and not (
            hasattr(self.node.item.object, "isDeletable")
        ):
            icon = QIcon(self.repIcon + "/deleteRondVide.png")
            self.RBPoubelle.setIcon(icon)
            return
        icon = QIcon(self.repIcon + "/deleteRond.png")
        self.RBPoubelle.setIcon(icon)
        self.RBPoubelle.clicked.connect(self.aDetruire)

    def setIconesSalome(self):
        if not (hasattr(self, "RBSalome")):
            return
        from Accas import SalomeEntry

        mc = self.node.item.get_definition()
        mctype = mc.type[0]
        enable_salome_selection = "grma" in repr(mctype) or "grno" in repr(mctype) or "SalomeEntry" in repr(mctype)
        # or (hasattr(mctype, "enable_salome_selection" and mctype.enable_salome_selection))

        if enable_salome_selection:
            icon = QIcon(self.repIcon + "/flecheSalome.png")
            self.RBSalome.setIcon(icon)
            self.RBSalome.pressed.connect(self.BSalomePressed)

            # PNPN --> Telemac A revoir surement
            # cela ou le catalogue grpma ou salomeEntry
            if not (("grma" in repr(mctype)) or ("grno" in repr(mctype))) or not (
                self.editor.salome
            ):
                if hasattr(self, "RBSalomeVue"):
                    self.RBSalomeVue.close()
            else:
                icon1 = QIcon(self.repIcon + "/eye.png")
                self.RBSalomeVue.setIcon(icon1)
                self.RBSalomeVue.clicked.connect(self.BView2DPressed)
        else:
            self.RBSalome.close()
            self.RBSalomeVue.close()

    def setIconesFichier(self):
        if not (hasattr(self, "BFichier")):
            return
        mc = self.node.item.get_definition()
        mctype = mc.type[0]
        if mctype == "FichierOuRepertoire":
            self.BFichierOuRepertoire = self.BFichier
            self.BFichierOuRepertoire.clicked.connect(self.BFichierOuRepertoirePressed)
            self.BVisuFichier.close()
        elif mctype == "Repertoire":
            self.BRepertoire = self.BFichier
            self.BRepertoire.clicked.connect(self.BRepertoirePressed)
            self.BVisuFichier.close()
        else:
            self.BFichier.clicked.connect(self.BFichierPressed)
            self.BVisuFichier.clicked.connect(self.BFichierVisu)

    def setIconesGenerales(self):
        repIcon = self.node.editor.appliEficas.repIcon
        if hasattr(self, "BVisuListe"):
            fichier = os.path.join(repIcon, "plusnode.png")
            icon = QIcon(fichier)
            self.BVisuListe.setIcon(icon)
        if hasattr(self, "RBDeplie"):
            fichier = os.path.join(repIcon, "plusnode.png")
            icon = QIcon(fichier)
            self.RBDeplie.setIcon(icon)
        if hasattr(self, "RBPlie"):
            fichier = os.path.join(repIcon, "minusnode.png")
            icon = QIcon(fichier)
            self.RBPlie.setIcon(icon)
        if hasattr(self, "BVisuFichier"):
            fichier = os.path.join(repIcon, "visuFichier.png")
            icon = QIcon(fichier)
            self.BVisuFichier.setIcon(icon)

    def setRun(self):
        if hasattr(self.editor.appliEficas, "mesScripts"):
            if self.editor.code in self.editor.appliEficas.mesScripts:
                self.dict_commandes_mesScripts = self.appliEficas.mesScripts[
                    self.editor.code
                ].dict_commandes
                if self.obj.nom in self.dict_commandes_mesScripts:
                    self.ajoutScript()
                    icon = QIcon(self.repIcon + "/roue.png")
                    if hasattr(self, "RBRun"):
                        self.RBRun.setIcon(icon)
                    return
        if hasattr(self, "RBRun"):
            self.RBRun.close()
        if hasattr(self, "CBScripts"):
            self.CBScripts.close()

    def aDetruire(self):
        self.node.delete()

    def setValide(self):
        if not (hasattr(self, "RBValide")):
            return
        couleur = self.node.item.getIconName()
        monIcone = QIcon(self.repIcon + "/" + couleur + ".png")
        self.RBValide.setIcon(monIcone)

    # il faut chercher la bonne fenetre
    def rendVisible(self):
        # print "je passe par rendVisible de FacultatifOuOptionnel"
        # print self
        # print self.node.fenetre
        # print "return pour etre sure"
        return
        # PNPN
        newNode = self.node.treeParent.chercheNoeudCorrespondant(self.node.item.object)
        # print newNode
        self.editor.fenetreCentraleAffichee.scrollAreaCommandes.ensureWidgetVisible(
            newNode.fenetre
        )
        # newNode.fenetre.setFocus()

    def ajoutScript(self):
        if not hasattr(self, "CBScripts"):
            return  # Cas des Widgets Plies
        self.dictCommandes = {}
        listeCommandes = self.dict_commandes_mesScripts[self.obj.nom]
        if type(listeCommandes) != tuple:
            listeCommandes = (listeCommandes,)
        i = 0
        for commande in listeCommandes:
            conditionSalome = commande[3]
            if self.appliEficas.salome == 0 and conditionSalome == True:
                continue
            self.CBScripts.addItem(commande[1])
            self.dictCommandes[commande[1]] = i
            i = i + 1
        self.CBScripts.activated.connect(self.choixSaisi)

    def choixSaisi(self):
        fction = str(self.CBScripts.currentText())
        numero = self.dictCommandes[fction]
        self.node.appelleFonction(numero, nodeTraite=self.node)
        # self.reaffiche()


class ContientIcones(object):
#---------------------------
    def BFichierVisu(self):
        fichier = self.lineEditVal.text()
        if fichier == None or str(fichier) == "":
            return
        from InterfaceGUI.QT5.monViewTexte import ViewText

        try:
            if sys.platform[0:5] == "linux":
                # cmd="xdg-open "+ str(fichier)
                # changer pour marcher dans l'EDC
                # cmd="gedit "+ str(fichier)
                from os.path import splitext

                fileName, extension = splitext(fichier)
                if (
                    extension
                    in self.parentQt.editor.appliEficas.maConfiguration.utilParextensions
                ):
                    cmd = (
                        self.parentQt.editor.appliEficas.maConfiguration.utilParextensions[
                            extension
                        ]
                        + " "
                        + str(fichier)
                    )
                else:
                    cmd = "xdg-open " + str(fichier)
                os.system(cmd)
            else:
                os.startfile(str(fichier))
        except:
            try:
                fp = open(fichier)
                txt = fp.read()
                nomFichier = QFileInfo(fichier).baseName()
                maVue = ViewText(self, entete=nomFichier)
                maVue.setText(txt)
                maVue.show()
                fp.close()
            except:
                QMessageBox.warning(
                    None,
                    tr("Visualisation Fichier "),
                    tr("Impossibilite d'afficher le Fichier"),
                )

    def BFichierPressed(self):
        mctype = self.node.item.get_definition().type
        if len(mctype) > 1:
            filters = mctype[1]
        elif hasattr(mctype[0], "filters"):
            filters = mctype[0].filters
        else:
            filters = ""
        if len(mctype) > 2 and mctype[2] == "Sauvegarde":
            fichier = QFileDialog.getSaveFileName(
                self.appliEficas,
                tr("Use File"),
                self.appliEficas.maConfiguration.saveDir,
                filters,
            )
        else:
            # print(filters)
            fichier = QFileDialog.getOpenFileName(
                self.appliEficas,
                tr("Ouvrir Fichier"),
                self.appliEficas.maConfiguration.saveDir,
                filters,
            )

        fichier = fichier[0]
        if not (fichier == ""):
            ulfile = os.path.abspath(fichier)
            self.appliEficas.maConfiguration.saveDir = os.path.split(ulfile)[0]
            self.lineEditVal.setText(fichier)
            self.editor.afficheCommentaire(tr("Fichier selectionne"))
            self.LEvaleurPressed()
            if QFileInfo(fichier).suffix() in listeSuffixe:
                self.image = fichier
                if not hasattr(self, "BSelectInFile"):
                    try:
                        self.BSelectInFile = QPushButton(self)
                        self.BSelectInFile.setMinimumSize(QSize(140, 40))
                        self.BSelectInFile.setObjectName("BSelectInFile")
                        self.gridLayout.addWidget(self.BSelectInFile, 1, 1, 1, 1)
                        self.BSelectInFile.setText(tr("Selection"))
                        self.BSelectInFile.clicked.connect(self.BSelectInFilePressed)
                    except:
                        pass
                else:
                    self.BSelectInFile.setVisible(1)

            elif hasattr(self, "BSelectInFile"):
                self.BSelectInFile.setVisible(0)

    def BFichierOuRepertoirePressed(self):
        self.fileName = ""
        self.file_dialog = QFileDialog()
        self.file_dialog.setFileMode(QFileDialog.Directory)
        self.file_dialog.setFileMode(QFileDialog.Directory | QFileDialog.ExistingFiles)
        self.file_dialog.setOption(QFileDialog.DontUseNativeDialog, True)
        self.file_dialog.setWindowTitle("Choose File or Directory")
        self.explore(self.file_dialog)
        self.file_dialog.exec_()
        if self.fileName == "":
            return
        self.lineEditVal.setText(self.fileName)
        self.LEvaleurPressed()

    def explore(self, widget):
        for c in widget.children():
            if isinstance(c, QTreeView):
                c.clicked.connect(self.changeBoutonOpen)
                self.monTreeView = c
            try:
                if c.text() == "&Open":
                    self.monBoutonOpen = c
            except:
                pass
            self.explore(c)

    def changeBoutonOpen(self):
        self.monBoutonOpen.setEnabled(True)
        self.monBoutonOpen.setText("Choose")
        self.monBoutonOpen.clicked.connect(self.monBoutonOpenClicked)
        index = self.monTreeView.currentIndex()
        self.fileName2 = self.monTreeView.model().data(index)

    def monBoutonOpenClicked(self):
        try:
            self.fileName = self.file_dialog.selectedFiles()[0]
        except:
            self.fileName = self.file_dialog.directory().absolutePath()
        self.file_dialog.close()
        self.file_dialog = None

    def BRepertoirePressed(self):
        directory = QFileDialog.getExistingDirectory(
            self.appliEficas,
            directory=self.appliEficas.maConfiguration.saveDir,
            options=QFileDialog.ShowDirsOnly,
        )

        if not (directory == ""):
            absdir = os.path.abspath(directory)
            self.appliEficas.maConfiguration.saveDir = os.path.dirname(absdir)
            self.lineEditVal.setText(directory)
            self.LEvaleurPressed()

    def BSelectInFilePressed(self):
        from InterfaceGUI.QT5.monSelectImage import MonSelectImage
        MonSelectImage(file=self.image, parent=self).show()

    def BSalomePressed(self):
        self.editor.afficheCommentaire("")
        selection = []
        commentaire = ""
        genea = self.node.item.getGenealogie()
        kwType = self.node.item.get_definition().type[0]
        for e in genea:
            if "GROUP_NO" in e:
                kwType = "GROUP_NO"
            if "GROUP_MA" in e:
                kwType = "GROUP_MA"

        if "grno" in repr(kwType):
            kwType = "GROUP_NO"
        if "grma" in repr(kwType):
            kwType = "GROUP_MA"

        if kwType in ("GROUP_NO", "GROUP_MA"):
            selection, commentaire = self.appliEficas.selectGroupFromSalome(
                kwType, editor=self.editor
            )

        mc = self.node.item.get_definition()

        if isinstance(mc.type, tuple) and len(mc.type) > 1 and "(*.med)" in mc.type[1]:
            selection, commentaire = self.appliEficas.selectMeshFile(editor=self.editor)
            # print selection, commentaire
            if commentaire != "":
                QMessageBox.warning(
                    None,
                    tr("Export Med vers Fichier "),
                    tr("Impossibilite d exporter le Fichier"),
                )
                return
            else:
                self.lineEditVal.setText(str(selection))
                return

        from Accas import SalomeEntry

        if inspect.isclass(kwType) and issubclass(kwType, SalomeEntry):
            selection, commentaire = self.appliEficas.selectEntryFromSalome(
                kwType, editor=self.editor
            )

        if commentaire != "":
            self.editor.afficheMessageQt(tr(str(commentaire)))
        if selection == []:
            return

        min, max = self.node.item.getMinMax()
        if max > 1:
            self.ajoutNValeur(selection)
            return

        monTexte = ""
        for geomElt in selection:
            monTexte = geomElt + ","
        monTexte = monTexte[0:-1]
        self.lineEditVal.setText(str(monTexte))
        self.LEvaleurPressed()

    def BView2DPressed(self):
        try:
            # cas d un Simp de base
            valeur = self.lineEditVal.text()
        except:
            valeur = self.textSelected
        valeur = str(valeur)
        if valeur == str(""):
            return
        if valeur:
            ok, msgError = self.appliEficas.displayShape(valeur)
            if not ok:
                self.editor.afficheMessageQt(msgError, Qt.red)

    def BParametresPressed(self):
        liste = self.node.item.getListeParamPossible()
        from InterfaceGUI.QT5.monListeParamPanel import MonListeParamPanel
        MonListeParamPanel(liste=liste, parent=self).show()
