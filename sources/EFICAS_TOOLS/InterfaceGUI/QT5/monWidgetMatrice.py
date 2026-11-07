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

import types, os, sys

# Modules Eficas
from Accas.extensions.eficas_translation import tr
from InterfaceGUI.QT5.feuille import Feuille
from Accas.extensions.eficas_exception import EficasException


from UiQT5.desWidgetMatrice import Ui_desWidgetMatrice

from PyQt5.QtCore import QSize, Qt
from PyQt5.QtWidgets import QTableWidgetItem, QTableWidget
from PyQt5.QtGui import QIcon, QColor
from PyQt5.QtWidgets import QMessageBox


class MonWidgetMatrice(Ui_desWidgetMatrice, Feuille):
    # c est juste la taille des differents widgets de base qui change

    def __init__(self, node, monSimpDef, nom, objSimp, parentQt, commande):
        Feuille.__init__(self, node, monSimpDef, nom, objSimp, parentQt, commande)
        self.monType = self.node.item.object.definition.type[0]
        parentQt.commandesLayout.insertWidget(-1, self)
        self.nbLigs = 0
        self.nbCols = 0
        self.creeColonnes()
        self.connecterSignaux()
        self.initialValeur()

    def connecterSignaux(self):
        self.TBMatrice.itemChanged.connect(self.itemChanged)
        self.PBrefresh.clicked.connect(self.acceptVal)
        self.TBMatrice.focusOutEvent = self.monFocusOutEvent

    def monFocusOutEvent(self, event):
        self.acceptVal()
        QTableWidget.focusOutEvent(self.TBMatrice, event)

    def itemChanged(self):
        monItem = self.TBMatrice.currentItem()
        if monItem == None:
            return
        texte = monItem.text()
        if texte == "":
            return
        boolOk, commentaire = self.monType.verifItem(texte, self.node.item.object)
        if not boolOk:
            self.editor.afficheMessageQt(tr(commentaire), 'red')
            monItem.setText("")
            return
        if self.monType.coloree:
            self.coloreItem(monItem, texte)

    def coloreItem(self, monItem, texte):
        if texte in self.monType.dictCouleurs.keys():
            monItem.setBackground(self.monType.dictCouleurs[texte])
        else:
            i = self.monType.indiceCouleur % 20
            newCouleur = QColor(*self.monType.listeCouleurs[i])
            monItem.setBackground(newCouleur)
            self.monType.dictCouleurs[texte] = newCouleur
            self.monType.indiceCouleur += 1

    def creeColonnes(self):
        if self.monType.methodeCalculTaille != None:
            try:
                MonWidgetMatrice.__dict__[self.monType.methodeCalculTaille](*(self,))
            except:
                QMessageBox.critical(
                    self,
                    tr("Mauvaise execution "),
                    tr("impossible d executer la methode ")
                    + self.monType.methodeCalculTaille,
                )
                return
        else:
            self.nbLigs = self.monType.nbLigs
            self.nbCols = self.monType.nbCols
        self.TBMatrice.setColumnCount(self.nbCols)
        self.TBMatrice.setRowCount(self.nbLigs)
        if self.nbLigs < 15:
            taille = 50
        else:
            taille = 40
        for i in range(self.nbLigs):
            self.TBMatrice.setRowHeight(i, taille)
        for i in range(self.nbCols):
            self.TBMatrice.setColumnWidth(i, taille)
        if self.monType.listeHeaders != None:
            self.TBMatrice.setHorizontalHeaderLabels(self.monType.listeHeaders[0])
            self.TBMatrice.setVerticalHeaderLabels(self.monType.listeHeaders[1])
        else:
            self.TBMatrice.verticalHeader().hide()
            self.TBMatrice.horizontalHeader().hide()
        #   self.TBMatrice.setFixedSize(self.nbCols*20+10,self.nbLigs*20+10)

    def initialValeur(self):
        liste = self.node.item.getValeur()
        if liste == None:
            return
        dejaAffiche = 0
        if (len(liste)) != self.nbLigs:
            QMessageBox.critical(
                self,
                tr("Mauvaise dimension de matrice"),
                tr("le nombre de ligne n est pas egal a ") + str(self.nbLigs),
            )
            return
        for i in range(self.nbLigs):
            inter = liste[i]
            if (len(inter)) != self.nbCols:
                QMessageBox.critical(
                    self,
                    tr("Mauvaise dimension de matrice"),
                    tr("le nombre de colonne n est pas egal a ") + str(self.nbCols),
                )
                raise EficasException("dimension")
            for j in range(self.nbCols):
                self.TBMatrice.setItem(i, j, QTableWidgetItem(str(liste[i][j])))
                if self.monType.coloree:
                    self.coloreItem(self.TBMatrice.item(i, j), str(liste[i][j]))

    def acceptVal(self):
        liste = []
        for i in range(self.nbLigs):
            listeCol = []
            for j in range(self.nbCols):
                monItem = self.TBMatrice.item(i, j)
                if monItem:
                    texte = monItem.text()
                else:
                    texte = ""
                if texte != "":
                    val = self.monType.convertItem(texte)
                else:
                    val = None
                listeCol.append(val)
            liste.append(listeCol)
        self.node.item.setValeur(liste)


class MonWidgetMatriceOT(MonWidgetMatrice):
    def __init__(self, node, monSimpDef, nom, objSimp, parentQt, commande):
        monWidgetMatrice.__init__(
            self, node, monSimpDef, nom, objSimp, parentQt, commande
        )

    def connecterSignaux(self):
        self.TBMatrice.itemChanged.connect(self.itemChanged)
        self.PBrefresh.clicked.connect(self.afficheEntete)

    def afficheEntete(self):
        self.objSimp.changeEnteteMatrice()
        self.TBMatrice.clear()
        if self.node.item.getValeur() == None:
            self.initialSsValeur()
        else:
            try:
                self.initialValeur()
            except:
                self.initialSsValeur()
        self.node.item.object.state = "changed"
        self.node.item.object.parent.state = "changed"
        self.setValide()
        self.parentQt.setValide()
        self.node.item.jdc.isValid()

    def itemChanged(self):
        monItem = self.TBMatrice.currentItem()
        if monItem == None:
            return
        texte = monItem.text()
        if texte == "":
            return
        try:
            val = float(str(texte))
            ok = True
        except:
            ok = False
        if ok == False:
            self.editor.afficheMessageQt(tr("Entrer un float SVP"), 'red')
            monItem.setText("")
            return
        if self.monType.valSup != None:
            if val > self.monType.valSup:
                self.editor.afficheMessageQt(
                    tr("Entrer un float inferieur a ") + repr(self.monType.valSup),'red')
                monItem.setText("")
                return
        if self.monType.valMin != None:
            if val < self.monType.valMin:
                self.editor.afficheMessageQt(
                    tr("Entrer un float superieur a ") + repr(self.monType.valMin), 'red',)
                monItem.setText("")
                return
        self.editor.afficheMessageQt("")
        if self.monType.structure != None:
            MonWidgetMatrice.__dict__[self.monType.structure](*(self,))
        self.acceptVal()

    def creeColonnes(self):
        if self.monType.methodeCalculTaille != None:
            try:
                MonWidgetMatrice.__dict__[self.monType.methodeCalculTaille](*(self,))
            except:
                QMessageBox.critical(
                    self,
                    tr("Mauvaise execution "),
                    tr("impossible d executer la methode ")
                    + self.monType.methodeCalculTaille,
                )
                return
        else:
            self.nbLigs = self.monType.nbLigs
            self.nbCols = self.monType.nbCols

    def nbDeVariables(self):
        # uniquement pour OT
        jdc = self.node.item.object.jdc
        etape = self.node.item.object.etape
        self.listeVariables = jdc.getVariables(etape)
        if self.listeVariables == []:
            QMessageBox.critical(
                self, tr("Mauvaise Commande "), tr("Aucune variable connue")
            )
            return
        self.TBMatrice.setColumnCount(len(self.listeVariables))
        self.TBMatrice.setRowCount(len(self.listeVariables))
        self.nbLigs = len(self.listeVariables)
        self.nbCols = len(self.listeVariables)

    def initialSsValeur(self):
        # uniquement pour OT
        self.listeVariables = []
        for row in range(self.nbLigs):
            for column in range(self.nbCols):
                if row == column:
                    initialFloat = 1
                else:
                    initialFloat = 0
                self.TBMatrice.setItem(row, column, QTableWidgetItem(str(initialFloat)))
        header = []
        for var in liste[0]:
            header.append(str(var))
        self.TBMatrice.setVerticalHeaderLabels(header)
        self.TBMatrice.setHorizontalHeaderLabels(header)

    def nbDeVariables(self):
        # uniquement pour OT
        jdc = self.node.item.object.jdc
        etape = self.node.item.object.etape
        self.listeVariables = jdc.getVariables(etape)
        if self.listeVariables == []:
            QMessageBox.critical(
                self,
                tr("Mauvaise Commande "),
                tr("Aucune variable connue. Entrez les variables avant la matrice"),
            )
            return
        self.TBMatrice.setColumnCount(len(self.listeVariables))
        self.TBMatrice.setRowCount(len(self.listeVariables))
        self.nbLigs = len(self.listeVariables)
        self.nbCols = len(self.listeVariables)

    def initialValeur(self):
        # uniquement pour OT
        liste = self.node.item.getValeur()
        dejaAffiche = 0
        if (len(liste)) != self.nbLigs + 1:
            QMessageBox.critical(
                self,
                tr("Mauvaise dimension de matrice"),
                tr("le nombre de ligne n est pas egal a ") + str(self.nbLigs),
            )
            raise EficasException("dimension")
        for i in range(self.nbLigs):
            inter = liste[i + 1]
            if (len(inter)) != self.nbCols:
                QMessageBox.critical(
                    self,
                    tr("Mauvaise dimension de matrice"),
                    tr("le nombre de colonne n est pas egal a ") + str(self.nbCols),
                )
                raise EficasException("dimension")
            for j in range(self.nbCols):
                self.TBMatrice.setItem(i, j, QTableWidgetItem(str(liste[i][j])))
        header = []
        for var in liste[0]:
            header.append(str(var))
        self.TBMatrice.setVerticalHeaderLabels(header)
        self.TBMatrice.setHorizontalHeaderLabels(header)
