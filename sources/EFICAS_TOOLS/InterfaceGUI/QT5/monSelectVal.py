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
# Modules Eficas

from UiQT5.desSelectVal import Ui_DSelVal
from Accas.extensions.eficas_translation import tr

from PyQt5.QtWidgets import QDialog, QFileDialog, QMessageBox
from PyQt5.QtCore import QTimer, Qt
from PyQt5.QtGui import QPalette


class DSelVal(Ui_DSelVal, QDialog):
    def __init__(self, parent, modal):
        QDialog.__init__(self, parent)
        self.setupUi(self)


class MonSelectVal(DSelVal):
    """
    Classe definissant le panel associe aux mots-cles qui demandent
    a l'utilisateur de choisir une seule valeur parmi une liste de valeurs
    discretes
    """

    def __init__(self, file, parent, name=None, fl=0):
        # print "MonSelectVal"
        self.parent = parent
        DSelVal.__init__(self, parent, 0)
        self.separateur = " "
        self.texte = " "
        self.textTraite = ""
        self.file = str(file)
        self.readVal()
        self.initVal()
        self.connecterSignaux()

    def connecterSignaux(self):
        self.Bespace.clicked.connect(self.selectEsp)
        self.BpointVirgule.clicked.connect(self.selectPoint)
        self.Bvirgule.clicked.connect(self.selectVir)
        self.BImportSel.clicked.connect(self.BImportSelPressed)
        self.BImportTout.clicked.connect(self.BImportToutPressed)
        self.parent.editor.sb.messageChanged.connect(self.messageAChanger)

    def connecterSignauxQT4(self):
        self.connect(self.Bespace, SIGNAL("clicked()"), self.selectEsp)
        self.connect(self.BpointVirgule, SIGNAL("clicked()"), self.selectPoint)
        self.connect(self.Bvirgule, SIGNAL("clicked()"), self.selectVir)
        self.connect(self.BImportSel, SIGNAL("clicked()"), self.BImportSelPressed)
        self.connect(self.BImportTout, SIGNAL("clicked()"), self.BImportToutPressed)
        self.connect(
            self.parent.editor.sb,
            SIGNAL("messageChanged(QString)"),
            self.messageAChanger,
        )

    def messageAChanger(self):
        message = self.parent.editor.sb.currentMessage()
        mapalette = self.sb.palette()
        mapalette.setColor(QPalette.Text, Qt.red)
        self.sb.setPalette(mapalette)
        self.sb.setText(message)
        QTimer.singleShot(3000, self.efface)

    def efface(self):
        self.sb.setText("")

    def readVal(self):
        if self.file == "":
            return
        try:
            f = open(self.file, "r")
            self.texte = f.read()
            f.close()
        except:
            QMessageBox.warning(
                self, tr("Fichier Indisponible"), tr("Lecture impossible")
            )
            self.texte = ""
            return

    def initVal(self):
        self.TBtext.clear()
        self.TBtext.setText(self.texte)

    def selectEsp(self):
        self.separateur = " "

    def selectVir(self):
        self.separateur = ","

    def selectPoint(self):
        self.separateur = ";"

    def BImportSelPressed(self):
        texte = self.TBtext.textCursor().selectedText()
        textTraite = texte.replace("\u2029", "\n")
        self.textTraite = str(textTraite)
        self.traitement()

    def BImportToutPressed(self):
        self.textTraite = self.texte
        self.traitement()

    def traitement(self):
        if self.textTraite == "":
            return
        if self.textTraite[-1] == "\n":
            self.textTraite = self.textTraite[0:-1]
        self.textTraite = self.textTraite.replace("\n", self.separateur)
        liste1 = self.textTraite.split(self.separateur)
        liste = []
        for val in liste1:
            if val != "" and val != " " and val != self.separateur:
                val = str(val)
                try:
                    # if 1 :
                    val2 = eval(val, {})
                    liste.append(val2)
                except:
                    pass
        self.parent.ajoutNValeur(liste)
