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

import  locale

# Modules Eficas
from PyQt5.QtWidgets import QLineEdit, QRadioButton
from PyQt5.QtCore import Qt


from Accas.extensions.eficas_translation import tr

from InterfaceGUI.QT5.feuille import Feuille
from UiQT5.desWidgetSimpComplexe import Ui_WidgetSimpComplexe
from InterfaceGUI.Common.politiquesValidation import PolitiqueUnique
from InterfaceGUI.QT5.traiteSaisie import SaisieValeur


class MonWidgetSimpComplexe(Ui_WidgetSimpComplexe, Feuille):
    def __init__(self, node, monSimpDef, nom, objSimp, parentQt, commande):
        Feuille.__init__(self, node, monSimpDef, nom, objSimp, parentQt, commande)
        self.parentQt.commandesLayout.insertWidget(-1, self)
        self.setFocusPolicy(Qt.StrongFocus)
        self.LEImag.returnPressed.connect(self.LEImagRPressed)
        self.LEReel.returnPressed.connect(self.LEReelRPressed)
        self.RBRI.clicked.connect(self.valeurPressed)
        self.RBMP.clicked.connect(self.valeurPressed)
        self.maCommande.listeAffichageWidget.append(self.RBRI)
        self.maCommande.listeAffichageWidget.append(self.RBMP)
        self.maCommande.listeAffichageWidget.append(self.LEReel)
        self.maCommande.listeAffichageWidget.append(self.LEImag)

    def setValeurs(self):
        self.politique = PolitiqueUnique(self.node, self.editor)
        valeur = self.node.item.getValeur()
        if valeur == None or valeur == "": return
        if type(valeur) not in (list, tuple):
            self.LEComp.setText(str(valeur))
            commentaire = tr("complexe form deprecated, od value : ", valeur)
            self.editor.afficheMessageQt(commentaire, Qt.red)
        else:
            typCplx, x1, x2 = valeur
            self.LEReel.setText(str(x1))
            self.LEImag.setText(str(x2))
            if typCplx == "RI": self.RBRI.setChecked(1)
            else: self.RBMP.setChecked(1)

    # def LECompRPressed(self) :
    #    self.LEReel.clear()
    #    self.LEImag.clear()
    #    commentaire=tr("expression valide")
    #    valeur = str(self.LEComp.text())
    #    d={}
    #    if 1 :
    #    try :
    #        v=eval(valeur,d)
    #    except :
    #        commentaire=tr("expression invalide")
    #        self.editor.afficheMessageQt(commentaire,Qt.red)
    #        return
    #    try :
    #        i=v.imag
    #        self.editor.afficheMessageQt(commentaire)
    #        self.valeurPressed()
    #    except :
    #        commentaire=tr("l expression n est pas de la forme a+bj")
    #        self.editor.afficheMessageQt(commentaire,Qt.red)

    def LEReelRPressed(self):
        # self.LEComp.clear()
        commentaire = tr("expression valide")
        valeur = str(self.LEReel.text())
        try:
            a = locale.atof(valeur)
            self.editor.afficheMessageQt(commentaire)
        except:
            commentaire = tr("expression invalide")
            self.editor.afficheMessageQt(commentaire, Qt.red)
        if self.LEImag.text() != "":
            self.valeurPressed()
        else:
            self.LEImag.setFocus(True)

    def LEImagRPressed(self):
        commentaire = tr("expression valide")
        valeur = str(self.LEImag.text())
        try:
            a = locale.atof(valeur)
            self.editor.afficheMessageQt(commentaire)
        except:
            commentaire = tr("expression invalide")
            self.editor.afficheMessageQt(commentaire, Qt.red)
        if self.LEReel.text() != "":
            self.valeurPressed()
        else:
            self.LEReel.setFocus(True)

    def finCommentaire(self):
        commentaire = "valeur de type complexe"
        return commentaire

    def valeurPressed(self):
        if self.LEReel.text() == "" and self.LEImag.text() == "":
            self.LEReel.setFocus(True)
        if self.LEReel.text() != "" and self.LEImag.text() == "":
            self.LEImag.setFocus(True)
        valeur = self.getValeurRI()
        if not valeur : return
        (ok, commentaire) = self.politique.recordValeur(valeur)
        if not ok : 
          self.editor.afficheMessageQt(commentaire)
          self.reaffiche()
        self.parentQt.donneFocus()

    def getValeurRI(self):
        """
        Retourne le complexe saisi par l'utilisateur
        """
        l = []
        if self.RBMP.isChecked() == 1: l.append("MP")
        elif self.RBRI.isChecked() == 1: l.append("RI")
        else : return None
        if self.LEReel.text() == "" : return None
        if self.LEImag.text() == "" : return None
        try :
            l.append(locale.atof(str(self.LEReel.text())))
            l.append(locale.atof(str(self.LEImag.text())))
        except : 
            self.editor.afficheMessageQt('Valeurs saisies non conformes', Qt.red)
            return None
        return repr(tuple(l))
