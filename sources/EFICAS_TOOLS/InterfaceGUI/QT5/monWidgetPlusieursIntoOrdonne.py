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

import types, os

# Modules Eficas
from InterfaceGUI.QT5.feuille import Feuille
from UiQT5.desWidgetPlusieursIntoOrdonne import Ui_WidgetPlusieursIntoOrdonne
from InterfaceGUI.Common.politiquesValidation import PolitiquePlusieurs
from InterfaceGUI.QT5.traiteSaisie import SaisieValeur
from InterfaceGUI.QT5.gereListe import GereListe
from InterfaceGUI.QT5.gereListe import GerePlie
from InterfaceGUI.QT5.gereListe import LECustom
from InterfaceGUI.QT5.gereListe import MonLabelListeClic
from Accas.extensions.eficas_translation import tr

from PyQt5.QtWidgets import QFrame, QApplication, QScrollBar
from PyQt5.QtCore import QTimer, QSize, Qt
from PyQt5.QtGui import QIcon, QPalette


class MonWidgetPlusieursIntoOrdonne(
    Ui_WidgetPlusieursIntoOrdonne, Feuille, GereListe, GerePlie
):
    def __init__(self, node, monSimpDef, nom, objSimp, parent, commande):
        self.nomLine = "LEResultat"
        self.listeLE = []
        self.ouAjouter = 0
        self.numLineEditEnCours = 0
        self.alpha = 0
        self.filtre = ""
        Feuille.__init__(self, node, monSimpDef, nom, objSimp, parent, commande)
        GereListe.__init__(self)
        # self.finCommentaireListe()
        self.gereIconePlier()
        self.listeValeursCourantes = self.node.item.getListeValeurs()
        try:
            self.maCommande.listeAffichageWidget.append(self.lineEditVal1)
        except:
            # cas ou on ne peut rien ajouter
            pass
        self.prepareListeResultat()
        if len(self.listeAAfficher) < 20:
            self.frameRecherche2.close()
        if len(self.listeAAfficher) < 20:
            self.frameRecherche.close()
        self.adjustSize()
        repIcon = self.node.editor.appliEficas.repIcon
        fichier = os.path.join(repIcon, "arrow_up.png")
        icon = QIcon(fichier)
        self.RBHaut.setIcon(icon)
        self.RBHaut.setIconSize(QSize(32, 32))
        fichier2 = os.path.join(repIcon, "arrow_down.png")
        icon2 = QIcon(fichier2)
        self.RBBas.setIcon(icon2)
        icon = QIcon(self.repIcon + "/MoinsBleu.png")
        self.RBMoins.setIcon(icon)
        icon = QIcon(self.repIcon + "/PlusBleu.png")
        self.RBPlus.setIcon(icon)
        icon = QIcon(self.repIcon + "/verre-loupe-icone-6087-64.png")
        self.RBVoisListe.setIcon(icon)
        self.PBFind.setIcon(icon)
        icon = QIcon(self.repIcon + "/CleanFilter.png")
        self.PBClean.setIcon(icon)

        self.PBClean.clicked.connect(self.cleanListeResultatFiltre)
        self.parentQt.commandesLayout.insertWidget(-1, self)
        self.listeRouge = []

    def prepareListeResultat(self):
        for i in self.listeLE: i.close()
        self.listeLE = []
        self.vScrollBar = self.scrollArea.verticalScrollBar()
        self.listeValeursCourantes = self.node.item.getListeValeurs()
        if hasattr(self.node.item.definition.validators, "set_MCSimp"):
            obj = self.node.item.getObject()
            self.node.item.definition.validators.set_MCSimp(obj)
            if self.node.item.isValid() == 0:
                liste = []
                for item in self.listeValeursCourantes:
                    if self.node.item.definition.validators.verifItem(item) == 1:
                        liste.append(item)
                self.listeAAfficher = self.node.item.getListePossible(liste)
            else:
                self.listeAAfficher = self.node.item.getListePossible([])
        else:
            self.listeAAfficher = self.node.item.getListePossible(self.listeValeursCourantes)

        if self.listeAAfficher == []:
            self.ajoutLE(0)
            return
        self.filtreListe()
        if len(self.listeAAfficher) * 20 > 400:
            self.setMinimumHeight(400)
        else:
            if self.monSimpDef.min > len(self.listeAAfficher):
                self.setMinimumHeight(self.monSimpDef.min * 30 + 300)
            elif self.monSimpDef.max > len(self.listeAAfficher):
                self.setMinimumHeight(400)
            else:
                self.setMinimumHeight(len(self.listeAAfficher) * 30 + 30)
        self.setMinimumHeight(300)
        self.adjustSize()

        self.politique = PolitiquePlusieurs(self.node, self.editor)
        for i in range(1, len(self.listeAAfficher) + 1):
            self.ajoutLE(i)
        for i in range(len(self.listeAAfficher)):
            nomLE = "lineEditVal" + str(i + 1)
            courant = getattr(self, nomLE)
            courant.setText(str(self.listeAAfficher[i]))
        self.vScrollBar.triggerAction(QScrollBar.SliderToMinimum)
        if len(self.listeAAfficher) < 15 and hasattr(self, "frameRecherche"):
            self.frameRecherche.close()
        if len(self.listeAAfficher) < 15 and hasattr(self, "frameRecherche2"):
            self.frameRecherche2.close()

    def setValeurs(self, first=True):
        self.listeValeursCourantes = self.node.item.getListeValeurs()
        if first:
            if self.monSimpDef.max == "**" or self.monSimpDef.max == float("inf"):
                aConstruire = 7
            else:
                aConstruire = self.monSimpDef.max
            if len(self.listeValeursCourantes) > aConstruire:
                aConstruire = len(self.listeValeursCourantes)
            self.indexDernierLabel = aConstruire
            for i in range(1, aConstruire + 1):
                self.ajoutLEResultat(i)
        index = 1
        for val in self.listeValeursCourantes:
            nomLE = "LEResultat" + str(index)
            courant = getattr(self, nomLE)
            courant.setText(str(val))
            courant.setReadOnly(True)
            index = index + 1
        while index < self.indexDernierLabel:
            nomLE = "LEResultat" + str(index)
            courant = getattr(self, nomLE)
            courant.setText("")
            courant.setReadOnly(True)
            index = index + 1
        # self.prepareListeResultat()

    def moinsPushed(self):
        self.ouAjouter = self.ouAjouter - 1
        GereListe.moinsPushed(self)
        self.setValeurs(first=False)

    def prepareListeResultatFiltre(self):
        for i in self.listeRouge:
            nomLE = "lineEditVal" + str(i + 1)
            courant = getattr(self, nomLE)
            texte = courant.text()
            palette = QPalette(Qt.black)
            palette.setColor(QPalette.WindowText, Qt.black)
            courant.setPalette(palette)
            courant.setText(texte)

        self.listeRouge = []
        filtre = str(self.LEFiltre.text())
        if filtre == "": return
        for i in range(len(self.listeAAfficher)):
            nomLE = "lineEditVal" + str(i + 1)
            courant = getattr(self, nomLE)
            texte = courant.text()
            if texte.find(filtre) == 0:
                palette = QPalette(Qt.red)
                palette.setColor(QPalette.WindowText, Qt.red)
                courant.setPalette(palette)
                courant.setText(texte)
            self.listeRouge.append(i)

    def cleanListeResultatFiltre(self):
        self.LEFiltre.setText("")
        self.filtre=""
        self.prepareListeResultatFiltre()

    def cataPushed(self):
        self.cleanListeResultatFiltre()
        GereListe.cataPushed(self)

    def alphaPushed(self):
        self.cleanListeResultatFiltre()
        GereListe.alphaPushed(self)

    def ajoutLEResultat(self, index, valeur=None):
        # print ('ajoutLEResultat', index, valeur)
        nomLE = "LEResultat" + str(index)
        if not (hasattr(self, nomLE)):
            nouveauLE = LECustom(self.scrollAreaRE, self, index)
            nouveauLE.setFrame(False)
            self.CBChoisis.insertWidget(self.ouAjouter, nouveauLE)
            self.ouAjouter = self.ouAjouter + 1
            nouveauLE.setReadOnly(True)
            if index % 2 == 1:
                nouveauLE.setStyleSheet("background:rgb(210,210,210)")
            else:
                nouveauLE.setStyleSheet("background:rgb(240,240,240)")
            self.vScrollBarRE = self.scrollAreaRE.verticalScrollBar()
            self.vScrollBarRE.triggerAction(QScrollBar.SliderToMaximum)
            setattr(self, nomLE, nouveauLE)
            self.estVisibleRE = nouveauLE
        else:
            nouveauLE = getattr(self, nomLE)

        if valeur == None:
            nouveauLE.setText("")
        else:
            nouveauLE.setText(str(valeur))

    def ajoutLE(self, index, valeur=None):
        # print ('ajoutLE')
        nomLE = "lineEditVal" + str(index)
        nouveauLE = MonLabelListeClic(self)
        # self.CBLayout.addWidget(nouveauLE)
        self.CBLayout.insertWidget(index - 1, nouveauLE)
        self.listeLE.append(nouveauLE)
        nouveauLE.setFrameShape(QFrame.NoFrame)
        QApplication.processEvents()
        nouveauLE.setText("")
        if index % 2 == 1:
            nouveauLE.setStyleSheet("background:rgb(210,210,210)")
        else:
            nouveauLE.setStyleSheet("background:rgb(240,240,240)")
        self.vScrollBar.triggerAction(QScrollBar.SliderToMaximum)
        nouveauLE.setFocus()
        setattr(self, nomLE, nouveauLE)

    def ajoutLineEdit(self):
        # print ('ajoutLineEdit')
        self.indexDernierLabel = self.indexDernierLabel + 1
        self.ajoutLEResultat(self.indexDernierLabel)

    def traiteClicSurLabelListe(self, valeur):
        if valeur == None:
            return
        liste, validite = SaisieValeur.TraiteLEValeur(self, str(valeur))
        if validite == 0:
            return
        if liste == []:
            return
        listeVal = []

        self.listeValeursCourantes = self.node.item.getListeValeurs()
        min, max = self.node.item.getMinMax()
        if len(self.listeValeursCourantes) + 1 > max:
            self.editor.afficheMessageQt(
                tr("Nombre maximal de valeurs : ") + str(max), Qt.red
            )
            return
        else:
            self.editor.afficheMessageQt("")

        affiche = False
        for i in range(1, self.indexDernierLabel + 1):
            nomLE = "LEResultat" + str(i)
            courant = getattr(self, nomLE)
            if str(courant.text()) == str(""):
                courant.setText(valeur)
                courant.setReadOnly(True)
                affiche = True
                self.estVisibleRE = courant
                QTimer.singleShot(1, self.rendVisibleLigneRE)
                break

        if affiche == False:
            self.indexDernierLabel = self.indexDernierLabel + 1
            self.ajoutLEResultat(self.indexDernierLabel, str(valeur))
            self.vScrollBarRE.triggerAction(QScrollBar.SliderToMaximum)
            QTimer.singleShot(1, self.rendVisibleLigneRE)
        self.changeValeur()
        self.setValeurs(first=False)

    def changeValeur(self, changeDePlace=False, oblige=False):
        # def changeValeur(self,changeDePlace=False,oblige=False, numero=None):
        # PN les 2 arg sont pour que la signature de ma fonction soit identique a monWidgetPlusieursBase
        listeVal = []
        for i in range(1, self.indexDernierLabel + 1):
            nomLE = "LEResultat" + str(i)
            courant = getattr(self, nomLE)
            valeur = courant.text()
            if str(valeur) == "":
                continue
            liste, validite = SaisieValeur.TraiteLEValeur(self, str(valeur))
            listeVal.append(str(valeur))

        validite, comm, comm2, listeRetour = self.politique.ajoutValeurs(
            listeVal, -1, []
        )

        self.listeValeursCourantes = self.node.item.getListeValeurs()
        min, max = self.node.item.getMinMax()
        if len(self.listeValeursCourantes) < min:
            self.editor.afficheMessageQt(
                tr("Nombre minimal de valeurs : ") + str(min), Qt.red
            )
        else:
            self.editor.afficheMessageQt("")

        if len(listeRetour) == 0:
            self.node.item.setValeur(None)
        elif validite:
            self.node.item.setValeur(listeRetour)
        else:
            commentaire = comm + " " + comm2
            self.editor.afficheMessageQt(commentaire, Qt.red)
        self.setValide()
        self.reaffiche()

    #
    def rendVisibleLigneRE(self):
        QApplication.processEvents()
        self.estVisibleRE.setFocus()
        self.scrollArea.ensureWidgetVisible(self.estVisibleRE, 0, 0)

    #
    def rendVisibleLigne(self):
        self.estVisibleRE = self.estVisible
        # rendVisibleLigneRE()
