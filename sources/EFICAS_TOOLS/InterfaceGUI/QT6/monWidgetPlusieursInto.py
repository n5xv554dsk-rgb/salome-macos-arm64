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

# Modules Eficas
from PyQt6.QtWidgets import QCheckBox, QScrollBar, QFrame, QApplication, QLabel
from PyQt6.QtWidgets import QSizePolicy, QSpacerItem
from PyQt6.QtGui import QPalette, QFont
from PyQt6.QtCore import Qt

from Accas.extensions.eficas_translation import tr

from InterfaceGUI.QT6.feuille import Feuille
from UiQT6.desWidgetPlusieursInto import Ui_WidgetPlusieursInto
from InterfaceGUI.Common.politiquesValidation import PolitiquePlusieurs
from InterfaceGUI.QT6.traiteSaisie import SaisieValeur
from InterfaceGUI.QT6.gereListe import GerePlie
from InterfaceGUI.QT6.gereListe import GereListe


class MonWidgetPlusieursInto(Ui_WidgetPlusieursInto, Feuille, GerePlie, GereListe):
    def __init__(self, node, monSimpDef, nom, objSimp, parentQt, commande):
        self.index = 1
        self.alpha = 0
        self.listeCB = []
        self.listeCbRouge = []
        self.listeValeursCourantes = node.item.getListeValeurs()
        if self.listeValeursCourantes == None:
            self.listeValeursCourantes = []

        Feuille.__init__(self, node, monSimpDef, nom, objSimp, parentQt, commande)
        GereListe.__init__(self)

        self.parentQt.commandesLayout.insertWidget(-1, self)
        self.CBCheck.stateChanged.connect(self.changeTout)

        self.gereIconePlier()
        self.editor.listeDesListesOuvertes.add(self.node.item)
        self.inhibe = False
        # self.finCommentaireListe()

        if self.listeAAfficher == None or self.listeAAfficher == []:
            spacerItem = QSpacerItem(30, 20, QSizePolicy.Policy.Fixed, QSizePolicy.Policy.Minimum)
            self.CBLayout.addItem(spacerItem)
            nouveauCommentaire = QLabel()
            maPolice = QFont("Times", 16)
            nouveauCommentaire.setFont(maPolice)
            nouveauCommentaire.setText(tr("Pas de valeurs possibles"))
            self.CBLayout.addWidget(nouveauCommentaire)
            spacerItem2 = QSpacerItem(40, 70, QSizePolicy.Policy.Fixed, QSizePolicy.Policy.Minimum)
            self.CBLayout.addItem(spacerItem2)

        if len(self.listeAAfficher) < 30 and hasattr(self, "frameRecherche"):
            self.frameRecherche.close()
        if len(self.listeAAfficher) == len(self.listeValeursCourantes):
            self.CBCheck.setChecked(True)
        if len(self.listeAAfficher) < 10:
            self.setMinimumHeight(len(self.listeAAfficher) * 22 + 55)
        else:
            self.setMinimumHeight(300)

        # try except si la liste des possibles est vide
        # prevoir qqchose
        try:
            self.maCommande.listeAffichageWidget.append(self.lineEditVal1)
        except:
            pass

    def changeTout(self, int):
        # print ('changeTout')
        if self.inhibe:
            return
        self.inhibe = True
        if not (self.CBCheck.isChecked()):
            min, max = self.node.item.getMinMax()
            if max < len(self.listeAAfficher):
                commentaire = tr("impossible de tout selectionner : max =") + str(max)
                self.editor.afficheMessageQt(commentaire, Qt.GlobalColor.red)
                self.inhibe = False
                return
            for i in range(len(self.listeAAfficher)):
                nomCB = "lineEditVal" + str(i + 1)
                courant = getattr(self, nomCB)
                courant.setChecked(True)
            self.CBCheck.setChecked(False)
        else:
            for i in range(len(self.listeAAfficher)):
                nomCB = "lineEditVal" + str(i + 1)
                courant = getattr(self, nomCB)
                courant.setChecked(False)
            self.CBCheck.setChecked(True)
        self.inhibe = False
        self.changeValeur()

    def setValeurs(self):
        # print ('setValeurs')
        self.listeValeursCourantes = self.node.item.getValeur()
        if self.listeValeursCourantes == None:
            self.listeValeursCourantes = []
        # print ("ds set Valeur", self.listeValeursCourantes, self.node.item.getValeur())
        self.politique = PolitiquePlusieurs(self.node, self.editor)
        self.vScrollBar = self.scrollArea.verticalScrollBar()

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
            self.listeAAfficher = self.node.item.getListePossible([])

        if self.node.item.hasIntoSug():
            self.listeAAfficher = self.node.item.getListePossibleAvecSug([])

        if self.objSimp.waitAssd():
            self.listeAAfficher = self.node.item.getSdAvantDuBonType()
        if self.listeAAfficher == None or self.listeAAfficher == []:
            self.listeAAfficher = []

        # if len(self.listeAAfficher)*20 > 400 : self.setMinimumHeight(400)
        # else : self.setMinimumHeight(len(self.listeAAfficher)*30)

        self.PourEtreCoche = []
        if self.objSimp.waitUserAssd():
            for concept in self.listeValeursCourantes:
                self.PourEtreCoche.append(concept)
        elif self.objSimp.waitAssd():
            for concept in self.listeValeursCourantes:
                self.PourEtreCoche.append(concept.nom)
        else:
            for val in self.listeValeursCourantes:
                self.PourEtreCoche.append(val)

        maListe = []
        for i in self.listeAAfficher:
            maListe.append(i)
        if self.alpha == 1:
            maListe.sort()
        for i in range(1, len(maListe) + 1):
            self.ajoutCB(i)

        self.inhibe = True
        for i in range(len(maListe)):
            nomCB = "lineEditVal" + str(i + 1)
            courant = getattr(self, nomCB)
            courant.setText(str(maListe[i]))
            if maListe[i] in self.PourEtreCoche:
                courant.setChecked(True)
            else:
                courant.setChecked(False)

            courant.toggled.connect(self.changeValeur)
        self.inhibe = False

        self.vScrollBar.triggerAction(QScrollBar.SliderToMinimum)

    def ajoutCB(self, index, valeur=None):
        # print ('ajoutCB')
        nomCB = "lineEditVal" + str(index)
        if hasattr(self, nomCB):
            return
        nouveauCB = QCheckBox(self.scrollArea)
        self.CBLayout.insertWidget(index - 1, nouveauCB)
        self.listeCB.append(nouveauCB)
        nouveauCB.setText("")
        if index % 2 == 1:
            nouveauCB.setStyleSheet("background:rgb(210,210,210)")
        else:
            nouveauCB.setStyleSheet("background:rgb(240,240,240)")
        self.vScrollBar.triggerAction(QScrollBar.SliderToMaximum)
        nouveauCB.setFocus()
        setattr(self, nomCB, nouveauCB)

    def ajout1Valeur(self, valeur=None):
        # print ('ajout1Valeur')
        if valeur == None:
            return
        liste, validite = SaisieValeur.TraiteLEValeur(self, str(valeur))
        if validite == 0:
            return
        if liste == []:
            return
        listeVal = []
        for valeur in self.listeValeursCourantes:
            listeVal.append(valeur)
        validite, comm, comm2, listeRetour = self.politique.ajoutValeurs(
            liste, -1, listeVal
        )
        if comm2 != "" and comm != None:
            return comm2
        if validite:
            self.listeValeursCourantes = self.listeValeursCourantes + listeRetour
            return None
        else:
            return comm2 + " " + comm

    def changeValeur(self):
        # def changeValeur(self,changeDePlace=False,oblige=True, numero=None):
        # print ('changeValeur')
        if self.inhibe == True:
            return
        if hasattr(self, "LEFiltre"):
            self.noircirResultatFiltre()
        self.listeValeursCourantesAvant = self.listeValeursCourantes
        self.listeValeursCourantes = []

        for i in range(1, len(self.listeAAfficher) + 1):
            nomLineEdit = "lineEditVal" + str(i)
            courant = getattr(self, nomLineEdit)
            if not (courant.isChecked()):
                continue
            valeur = courant.text()
            if valeur != None and valeur != "":
                commentaire = self.ajout1Valeur(valeur)
                if commentaire != None:
                    self.editor.afficheMessageQt(commentaire, Qt.GlobalColor.red)
                    self.listeValeursCourantesAvant = self.listeValeursCourantes
                    self.setValeurs()

        min, max = self.node.item.getMinMax()
        if len(self.listeValeursCourantes) < min:
            self.editor.afficheMessageQt(
                tr("Nombre minimal de valeurs : ") + str(min), Qt.GlobalColor.red
            )
        elif len(self.listeValeursCourantes) > max:
            self.editor.afficheMessageQt(
                tr("Nombre maximal de valeurs : ") + str(max), Qt.GlobalColor.red
            )

        if self.listeValeursCourantes == []:
            self.node.item.setValeur([])
        else:
            self.node.item.setValeur(self.listeValeursCourantes)

        # Exception pour PSEN
        if min == 0 and self.listeValeursCourantes == []:
            self.node.item.setValeur([])
        self.setValide()

    def prepareListeResultatFiltre(self):
        # print ('prepareListeResultatFiltre')
        filtre = str(self.LEFiltre.text())
        for cb in self.listeCB:
            texte = cb.text()
            if texte.find(filtre) == 0:
                palette = QPalette(Qt.GlobalColor.red)
                palette.setColor(QPalette.WindowText, Qt.GlobalColor.red)
                cb.setPalette(palette)
                t = cb.text()
                cb.setText(t)
                self.listeCbRouge.append(cb)

    def prepareListeResultat(self):
        # print ('prepareListeResultat')
        self.clearAll()
        self.setValeurs()

    def clearAll(self):
        # print ('clearAll')
        for cb in self.listeCB:
            cb.setText("")
