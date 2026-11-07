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
# Modules Eficas

from UiQT6.desChoixCommandes import Ui_ChoixCommandes
from PyQt6.QtWidgets import QWidget, QButtonGroup, QRadioButton, QLabel, QPushButton, QGridLayout
from PyQt6.QtGui import QIcon, QPixmap
from PyQt6.QtCore import QSize, QRect

from Accas.extensions.eficas_translation import tr
import os


class MonChoixCommande(Ui_ChoixCommandes, QWidget):
    """ """

    def __init__(self, node, jdc_item, editor):
        QWidget.__init__(self, parent=None)
        self.setupUi(self)

        self.repIcon = os.path.join(
            os.path.dirname(os.path.abspath(__file__)), "..", "Editeur", "icons"
        )
        iconeFile = os.path.join(self.repIcon, "lettreRblanc30.png")
        icon = QIcon(iconeFile)
        self.RBRegle.setIcon(icon)
        self.RBRegle.setIconSize(QSize(21, 31))

        self.item = jdc_item
        self.node = node
        self.editor = editor
        self.simpleClic = self.editor.maConfiguration.simpleClic
        self.jdc = self.item.object.getJdcRoot()
        debutTitre = self.editor.titre
        self.listeWidget = []
        self.dicoCmd = {}
        if self.editor.dataSetFile != None:
            nouveauTitre = debutTitre + " " + os.path.basename(self.editor.dataSetFile)
        else:
            nouveauTitre = debutTitre
        self.editor.appliEficas.setWindowTitle(nouveauTitre)

        self.RBalpha.clicked.connect(self.afficheAlpha)
        self.RBGroupe.clicked.connect(self.afficheGroupe)
        self.RBOrdre.clicked.connect(self.afficheOrdre)
        self.RBClear.clicked.connect(self.clearFiltre)
        self.RBCasse.toggled.connect(self.ajouteRadioButtons)
        self.LEFiltre.returnPressed.connect(self.ajouteRadioButtons)
        self.LEFiltre.textChanged.connect(self.ajouteRadioButtons)

        if self.node.tree.item.getRegles() == ():
            self.RBRegle.close()
            self.labelRegle.close()
        else:
            self.RBRegle.clicked.connect(self.afficheRegle)

        if self.editor.readercata.ordreDesCommandes == None:
            self.RBOrdre.close()

        # self.editor.labelCommentaire.setText("")
        if self.editor.widgetOptionnel != None:
            self.editor.fermeOptionnel()
            self.editor.widgetOptionnel = None
        self.name = None

        self.boolAlpha = 0
        self.boolGroupe = 0
        self.boolOrdre = 0
        if self.editor.maConfiguration.affiche == "alpha":
            self.boolAlpha == 1
            self.RBalpha.setChecked(True)
            self.afficheAlpha()
        elif self.editor.maConfiguration.affiche == "groupe":
            self.boolGroupe == 1
            self.RBGroupe.setChecked(True)
            self.afficheGroupe()
        elif self.editor.maConfiguration.affiche == "ordre":
            self.boolOrdre == 1
            self.RBOrdre.setChecked(True)
            self.afficheOrdre()
        if (
            self.editor.maConfiguration.closeFrameRechercheCommandeSurPageDesCommandes
            == True
        ):
            self.frameAffichage.close()

        if self.editor.widgetTree != None:
            self.editor.restoreSplitterSizes(2)
        else:
            self.editor.restoreSplitterSizes(3)

    def afficheRegle(self):
        self.node.tree.appellebuildLBRegles()

    def afficheAlpha(self):
        self.boolAlpha = 1
        self.boolGroupe = 0
        self.boolOrdre = 0
        self.ajouteRadioButtons()

    def afficheGroupe(self):
        self.boolAlpha = 0
        self.boolGroupe = 1
        self.boolOrdre = 0
        self.ajouteRadioButtons()

    def afficheOrdre(self):
        self.boolAlpha = 0
        self.boolGroupe = 0
        self.boolOrdre = 1
        self.ajouteRadioButtons()

    def insereNoeudApresClick(self, event):
        # print self.editor.Classement_Commandes_Ds_Arbre
        # if self.editor.Classement_Commandes_Ds_Arbre!= () : self.chercheOu()
        # print ('dans insereNoeudApresClick')
        nodeCourrant = self.node.tree.currentItem()
        if nodeCourrant == None:
            nodeCourrant = self.node.tree.racine
        if self.name != None:
            plier = self.editor.maConfiguration.afficheCommandesPliees
            if nodeCourrant == self.node:
                nouveau = self.node.appendChild(self.name, "first", plier)
            else:
                nouveau = nodeCourrant.appendBrother(self.name, plier=plier)
        else:
            nouveau = 0
        # on n a pas insere le noeud
        if nouveau == 0: return  

        nouveau.setDeplie()
        # if self.editor.afficheApresInsert==True : nouveau.plieToutEtReaffiche()
        if self.editor.afficheApresInsert == True:
            # if self.editor.affichePlie==True:  nouveau.plieToutEtReaffiche()
            if self.editor.maConfiguration.afficheCommandesPliees == True:
                nouveau.plieToutEtReaffiche()
            else:
                nouveau.deplieToutEtReaffiche()
            nouveau.fenetre.donnePremier()
            # nouveau.deplieToutEtReaffiche()
        else:
            self.node.setSelected(False)
            nouveau.setSelected(True)
            self.node.tree.setCurrentItem(nouveau)
        if event != None:
            event.accept()

    def creeListeCommande(self, filtre):
        listeGroupes, dictGroupes = self.jdc.getGroups()
        sensibleALaCasse = self.RBCasse.isChecked()
        if "CACHE" in dictGroupes:
            aExclure = list(dictGroupes["CACHE"])
        else:
            aExclure = []
        listeACreer = []
        listeEtapesDejaPresentes = []
        if self.editor.maConfiguration.rendVisiblesLesCaches:
            for e in self.jdc.etapes:
                listeEtapesDejaPresentes.append(e.nom)
            for c in aExclure:
                if c not in listeEtapesDejaPresentes:
                    aExclure.remove(c)
        # for e in self.jdc.etapes:
        #    print (e.nom)
        #    print (e.definition.repetable)
        #    if e.definition.repetable == 'n' : aExclure.append(e.nom)
        # print (aExclure)
        for l in self.jdc.getListeCmd():
            if l not in aExclure:
                if sensibleALaCasse and (filtre != None and not filtre in l):
                    continue
                if (
                    (not sensibleALaCasse)
                    and filtre != None
                    and (not filtre in l)
                    and (not filtre.upper() in l)
                ):
                    continue
                listeACreer.append(l)
        return listeACreer

    def ajouteRadioButtons(self):
        if self.editor.maConfiguration.nombreDeBoutonParLigne != 0:
            self.ajoutePushButtons()
            return
        # print 'ds ajouteRadioButtons'
        filtre = str(self.LEFiltre.text())
        if filtre == str(""):
            filtre = None
        if hasattr(self, "buttonGroup"):
            for b in self.buttonGroup.buttons():
                self.buttonGroup.removeButton(b)
                b.setParent(None)
                b.close()
        else:
            self.buttonGroup = QButtonGroup()
        for w in self.listeWidget:
            w.setParent(None)
            w.close()
        self.listeWidget = []
        if self.boolAlpha == 1:
            liste = self.creeListeCommande(filtre)
            for cmd in liste:
                self.dicoCmd[tr(cmd)] = cmd
                rbcmd = QRadioButton(tr(cmd))
                self.buttonGroup.addButton(rbcmd)
                self.commandesLayout.addWidget(rbcmd)
                # if self.simpleClic :  rbcmd.mouseReleaseEvent=self.insereNoeudApresClick
                # else : rbcmd.mouseDoubleClickEvent=self.insereNoeudApresClick
                # self.buttonGroup.buttonClicked.connect(self.rbClique)
                if not (self.simpleClic):
                    rbcmd.mouseDoubleClickEvent = self.insereNoeudApresClick
            if self.simpleClic:
                self.buttonGroup.buttonClicked.connect(self.rbCliqueEtInsere)
            else:
                self.buttonGroup.buttonClicked.connect(self.rbClique)
        elif self.boolGroupe == 1:
            listeGroupes, dictGroupes = self.jdc.getGroups()
            for grp in listeGroupes:
                if grp == "CACHE":
                    continue
                label = QLabel(self)
                text = tr(
                    '<html><head/><body><p><span style=" font-weight:600;">Groupe : '
                    + tr(grp)
                    + "</span></p></body></html>"
                )
                label.setText(text)
                self.listeWidget.append(label)
                aAjouter = 1
                sensibleALaCasse = self.RBCasse.isChecked()
                for cmd in dictGroupes[grp]:
                    if sensibleALaCasse and (filtre != None and not filtre in cmd):
                        continue
                    if (
                        (not sensibleALaCasse)
                        and filtre != None
                        and (not filtre in cmd)
                        and (not filtre.upper() in cmd)
                    ):
                        continue
                    if aAjouter == 1:
                        self.commandesLayout.addWidget(label)
                        aAjouter = 0
                    self.dicoCmd[tr(cmd)] = cmd
                    rbcmd = QRadioButton(tr(cmd))
                    self.buttonGroup.addButton(rbcmd)
                    self.commandesLayout.addWidget(rbcmd)
                    if not (self.simpleClic):
                        rbcmd.mouseDoubleClickEvent = self.insereNoeudApresClick
                if self.simpleClic:
                    self.buttonGroup.buttonClicked.connect(self.rbCliqueEtInsere)
                else:
                    self.buttonGroup.buttonClicked.connect(self.rbClique)
                label2 = QLabel(self)
                label2.setText(" ")
                self.listeWidget.append(label2)
                self.commandesLayout.addWidget(label2)
        elif self.boolOrdre == 1:
            listeFiltre = self.creeListeCommande(filtre)
            liste = []
            if self.editor.readercata.ordreDesCommandes == None:
                ordreDesCommandes = listeFiltre
            else:
                ordreDesCommandes = self.editor.readercata.ordreDesCommandes
            for cmd in ordreDesCommandes:
                if cmd in listeFiltre:
                    liste.append(cmd)
            for cmd in liste:
                self.dicoCmd[tr(cmd)] = cmd
                rbcmd = QRadioButton(tr(cmd))
                self.buttonGroup.addButton(rbcmd)
                self.commandesLayout.addWidget(rbcmd)
                if not (self.simpleClic):
                    rbcmd.mouseDoubleClickEvent = self.insereNoeudApresClick
            if self.simpleClic:
                self.buttonGroup.buttonClicked.connect(self.rbCliqueEtInsere)
            else:
                self.buttonGroup.buttonClicked.connect(self.rbClique)

    def ajoutePushButtons(self):
        if hasattr(self, "buttonGroup"):
            for b in self.buttonGroup.buttons():
                self.buttonGroup.removeButton(b)
                b.setParent(None)
                b.close()
        else:
            self.buttonGroup = QButtonGroup()
            self.buttonGroup.buttonClicked.connect(self.rbCliqueEtInsere)
        for w in self.listeWidget:
            w.setParent(None)
            w.close()
        self.listeWidget = []

        if not hasattr(self, "maGrilleBouton"):
            # self.commandesLayout.close()
            self.maGrilleBouton = QGridLayout()
            self.maGrilleBouton.setSpacing(20)
            self.verticalLayout.addLayout(self.maGrilleBouton)
        col = -1
        ligne = 0

        if self.boolAlpha == 1:
            liste = self.creeListeCommande(None)
        elif self.boolOrdre:
            liste = self.creeListeCommande(None)
            listeFiltre = self.creeListeCommande(None)
            liste = []
            if self.editor.readercata.ordreDesCommandes == None:
                ordreDesCommandes = listeFiltre
            else:
                ordreDesCommandes = self.editor.readercata.ordreDesCommandes
            for cmd in ordreDesCommandes:
                if cmd in listeFiltre:
                    liste.append(cmd)
        elif self.boolGroupe:
            # On considere que cela n a pas de sens de filtrer sur les groupes ou ?
            return
        for cmd in liste:
            col = col + 1
            if col == self.editor.maConfiguration.nombreDeBoutonParLigne:
                col = 0
                ligne = ligne + 1
            self.dicoCmd[tr(cmd)] = cmd
            rbcmd = QPushButton(tr(cmd))
            rbcmd.setGeometry(QRect(40, 20, 211, 71))
            rbcmd.setMaximumSize(QSize(250, 81))
            rbcmd.setStyleSheet(
                "background-color : rgb(66, 165, 238);\n"
                "/*border-style : outset;*/\n"
                "border-radius : 20px;\n"
                "border-width : 30 px;\n"
                "border-color : beige;\n"
                "text-align : center"
            )
            # print ('self.editor.maConfiguration.dicoImages', self.editor.maConfiguration.dicoImages)
            if cmd in self.editor.maConfiguration.dicoImages:
                fichier = self.editor.maConfiguration.dicoImages[cmd]
                icon = QIcon()
                icon.addPixmap(QPixmap(fichier), QIcon.Normal, QIcon.Off)
                rbcmd.setIcon(icon)
                rbcmd.setIconSize(QSize(48, 48))

            self.buttonGroup.addButton(rbcmd)
            self.maGrilleBouton.addWidget(rbcmd, ligne, col)

    def clearFiltre(self):
        self.LEFiltre.setText("")
        self.ajouteRadioButtons()

    def rbCliqueEtInsere(self, id):
        self.rbClique(id)
        self.insereNoeudApresClick(None)

    def rbClique(self, id):
        try:
            self.name = self.dicoCmd[id.text()]
        except:
            try:
                self.name = self.dicoCmd[str(id.text())]
            except:
                print("pb d accent : contacter la maintenance")

        definitionEtape = getattr(self.jdc.cata, self.name)
        # commentaire=getattr(definitionEtape,self.jdc.lang)
        try:
            commentaire = getattr(definitionEtape, self.jdc.lang)
        except:
            try:
                commentaire = getattr(definitionEtape, "ang")
            except:
                commentaire = ""
        self.editor.afficheCommentaire(commentaire)

    def setValide(self):
        # PNPN a priori pas d icone mais peut-etre a faire
        pass
