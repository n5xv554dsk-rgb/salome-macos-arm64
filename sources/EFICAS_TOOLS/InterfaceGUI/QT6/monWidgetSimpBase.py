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
from PyQt6.QtWidgets import QLineEdit
from PyQt6.QtCore import Qt
from Accas.extensions.eficas_translation import tr

from InterfaceGUI.QT6.feuille import Feuille
from UiQT6.desWidgetSimpBase import Ui_WidgetSimpBase
from InterfaceGUI.Common.politiquesValidation import PolitiqueUnique
from InterfaceGUI.QT6.traiteSaisie import SaisieValeur


class MonWidgetSimpBase(Ui_WidgetSimpBase, Feuille):
    def __init__(self, node, monSimpDef, nom, objSimp, parentQt, commande):
        Feuille.__init__(self, node, monSimpDef, nom, objSimp, parentQt, commande)
        if "R" or "I" in self.monSimpDef.type:
            self.lineEditVal.setMinimumWidth(525)
        if hasattr(self.parentQt, "commandesLayout"):
            self.parentQt.commandesLayout.insertWidget(-1, self, 1)
        self.setFocusPolicy(Qt.FocusPolicy.StrongFocus)
        # selon les heritages (comme 5C), on pourrait ne pas avoir un LineEditVal 
        if hasattr(self, "lineEditVal"):
            if monSimpDef.homo == "constant":
                self.lineEditVal.setReadOnly(True)
                self.lineEditVal.setStyleSheet(
                    "background:rgb(210,235,235);\n" "border:0px;"
                )
            else:
                 self.lineEditVal.returnPressed.connect(self.LEvaleurPressed)
        self.AAfficher = self.lineEditVal
        self.maCommande.listeAffichageWidget.append(self.lineEditVal)
        self.lineEditVal.focusInEvent = self.monFocusInEvent
        self.lineEditVal.focusOutEvent = self.monFocusOutEvent

    def monFocusInEvent(self, event):
        self.editor.nodeEnCours = self
        QLineEdit.focusInEvent(self.lineEditVal, event)

    def monFocusOutEvent(self, event):
        if self.oldValeurTexte != self.lineEditVal.text():
            self.oldValeurTexte = self.lineEditVal.text()
            self.LEvaleurPressed()
        QLineEdit.focusOutEvent(self.lineEditVal, event)

    def setValeurs(self):
        self.oldValeurTexte = ""
        self.politique = PolitiqueUnique(self.node, self.editor)
        valeur = self.node.item.getValeur()
        valeurTexte = self.politique.getValeurTexte(valeur)
        chaine = ""

        if valeurTexte != None:
            from decimal import Decimal

            if isinstance(valeurTexte, Decimal):
                chaine = str(valeurTexte)
            elif repr(valeurTexte.__class__).find("PARAMETRE") > 0:
                chaine = repr(valeur)
            else:
                chaine = str(valeurTexte)
        self.oldValeurTexte = chaine
        self.lineEditVal.setText(chaine)

    def finCommentaire(self):
        mc = self.objSimp.definition
        d_aides = {
            "TXM": tr("Une chaine de caracteres est attendue.  "),
            "R": tr("Un reel est attendu. "),
            "I": tr("Un entier est attendu.  "),
            "Matrice": tr("Une Matrice est attendue.  "),
            "Fichier": tr("Un fichier est attendu.  "),
            "FichierNoAbs": tr("Un fichier est attendu.  "),
            "Repertoire": tr("Un repertoire est attendu.  "),
            "FichierOuRepertoire": tr("Un repertoire ou un fichier est attendu.  "),
            "Heure": tr("Heure sous la forme HH:MM"),
            "Date": tr("Date sous la forme JJ/MM/AA"),
        }
        if mc.type[0] != type:
            commentaire = d_aides.get(mc.type[0], tr("Type de base inconnu"))
        else:
            commentaire = ""
        return commentaire

    def LEvaleurPressed(self):
        # pour les soucis d encoding
        try:
            if (
                str(self.lineEditVal.text()) == ""
                or str(self.lineEditVal.text()) == None
            ):
                return
        except:
            pass
        SaisieValeur.LEvaleurPressed(self)
        # self.parentQt.donneFocus()
        self.setValeurs()
        self.reaffiche()
