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

import types, os, re
pattern_name = re.compile(r"^[^\d\W]\w*\Z")

# Modules Eficas

from PyQt6.QtWidgets import QDialog, QMessageBox
from PyQt6.QtCore import Qt
from Accas.extensions.eficas_translation import tr
from UiQT6.desWidgetCreeParam import Ui_desWidgetCreeParam


class MonWidgetCreeParam(Ui_desWidgetCreeParam, QDialog):
    """ """

    def __init__(self, editor, name=None, fl=0):
        self.editor = editor
        self.editor.afficheMessageQt("")
        QDialog.__init__(self, editor)
        self.setupUi(self)
        self.connecterSignaux()
        self.dejaExistant = 0
        self.listeTousParam = self.editor.jdc.params
        self.dictListe = {}
        self.initToutesVal()

    def connecterSignauxQT4(self):
        self.connect(
            self.lineEditVal, SIGNAL("returnPressed()"), self.lineEditValReturnPressed
        )
        self.connect(
            self.lineEditNom, SIGNAL("returnPressed()"), self.lineEditNomReturnPressed
        )

    def connecterSignaux(self):
        self.lineEditVal.returnPressed.connect(self.lineEditValReturnPressed)
        self.lineEditNom.returnPressed.connect(self.lineEditNomReturnPressed)
        self.LBParam.itemDoubleClicked.connect(self.paramClicked)

    def paramClicked(self, item):
        if self.editor.nodeEnCours == None:
            QMessageBox.warning(
                self, tr("Pas de Mot-Clef"), tr("Attention! selectionnez un mot-clef")
            )
            return
        param = self.dictListe[item.text()]
        self.editor.nodeEnCours.lineEditVal.setText(param)
        self.editor.nodeEnCours.LEvaleurPressed()

    def creeParametre(self):
        nom = str(self.lineEditNom.text())
        val = str(self.lineEditVal.text())
        if val == "" or None:
            return
        if nom == "" or None:
            return
        if len(self.editor.tree.selectedItems()) == 0:
            itemAvant = self.editor.tree.racine
        else:
            itemAvant = self.editor.tree.selectedItems()[0]
        param = itemAvant.addParameters(True)
        param.item.setNom(nom)
        # PN self.val permet d entrer du texte
        param.item.setValeur(self.val)
        param.updateNodeTexte()
        param.updateNodeValid()
        self.LBParam.addItem((repr(param.item.object)))
        self.dictListe[repr(param.item.object)] = param.item.object.nom
        self.lineEditVal.setText("")
        self.lineEditNom.setText("")
        self.lineEditNom.setFocus(True)

    def lineEditValReturnPressed(self):
        qtVal = self.lineEditVal.text()
        valString = str(self.lineEditVal.text())
        self.val = ""
        contexte = {}
        exec("from math import *", contexte)
        jdc = self.editor.jdc
        if jdc == None:
            self.editor.afficheMessageQt( 
               tr( "La Creation de parametre n est possible que dans un jeu de donnees"), Qt.GlobalColor.red,)
            return

        for p in jdc.params:
            try:
                tp = p.nom + "=" + str(repr(p.valeur))
                exec(tp, contexte)
            except:
                pass
        monTexte = "monParam=" + valString
        try:
            exec(monTexte, contexte)
            self.val = valString
        except:
            try:
                monTexte = "monParam='" + valString + "'"
                self.val = "'" + valString + "'"
            except:
                self.editor.afficheMessageQt(tr("Valeur incorrecte"), Qt.GlobalColor.red)
        if self.lineEditNom.text() != "" and self.dejaExistant == False:
            self.creeParametre()

    def lineEditNomReturnPressed(self):
        qtNom = self.lineEditNom.text()
        nom = str(qtNom)
        if not pattern_name.match(nom):
            self.lineEditNom.setText("")
            commentaire = nom + tr(" n est pas un identifiant correct\n ")
            self.editor.afficheMessageQt(commentaire, Qt.GlobalColor.red)
        for p in self.editor.jdc.params:
            if p.nom == nom:
                commentaire = nom + tr(" existe deja\n ")
                self.editor.afficheMessageQt(commentaire, Qt.GlobalColor.red)
                return

        if self.lineEditVal.text() != "":
            self.creeParametre()
        self.lineEditVal.setFocus(Qt.FocusPolicy.OtherFocusReason)

    def initToutesVal(self):
        self.LBParam.clear()
        for param in self.listeTousParam:
            self.LBParam.addItem((repr(param)))
            self.dictListe[repr(param)] = param.nom

    def valideParam(self):
        if self.LBParam.selectedItems() == None:
            return
        lParam = []
        for indice in range(len(self.LBParam.selectedItems())):
            i = self.LBParam.selectedItems()[indice].text()
            param = self.dictListe[i]
            lParam.append(param)

        try:
            self.panel.ajoutNValeur(lParam)
        except:
            for p in lParam:
                self.panel.ajout1Valeur(p)
        self.close()
