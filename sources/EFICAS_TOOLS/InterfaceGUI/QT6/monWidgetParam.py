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

import os, re
import types

from UiQT6.desWidgetParam import Ui_WidgetParam
from InterfaceGUI.QT6.gereIcones import FacultatifOuOptionnel
from PyQt6.QtWidgets import QWidget, QMessageBox
from PyQt6.QtGui import QIcon

from Accas.extensions.eficas_translation import tr
from Accas.extensions.eficas_exception import EficasException

pattern_name = re.compile(r"^[^\d\W]\w*\Z")

class MonWidgetParam(QWidget, Ui_WidgetParam, FacultatifOuOptionnel):
    """ """

    def __init__(self, node, editor, commentaire):
        QWidget.__init__(self, None)
        self.node = node
        self.node.fenetre = self
        self.setupUi(self)
        self.editor = editor
        self.appliEficas = self.editor.appliEficas
        self.repIcon = self.appliEficas.repIcon

        self.setIconePoubelle()
        if not (self.node.item.object.isValid()):
            icon = QIcon(self.repIcon + "/ast-red-ball.png")
            self.RBValide.setIcon(icon)

        self.remplit()
        # if self.editor.code in ['MAP','CARMELCND','CF'] : self.bCatalogue.close()
        if self.editor.code in ["MAP", "CARMELCND"]:
            self.bCatalogue.close()
        else:
            self.bCatalogue.clicked.connect(self.afficheCatalogue)

        self.lineEditVal.returnPressed.connect(self.LEvaleurPressed)
        self.lineEditNom.returnPressed.connect(self.LENomPressed)
        self.bAvant.clicked.connect(self.afficheAvant)
        self.bApres.clicked.connect(self.afficheApres)
        self.bVerifie.clicked.connect(self.verifiePressed)

        self.editor.fermeOptionnel()

    def afficheCatalogue(self):
        self.node.tree.racine.affichePanneau()
        if self.node:
            self.node.select()
        else:
            self.node.tree.racine.select()

    def remplit(self):
        nom = self.node.item.getNom()
        self.lineEditNom.setText(nom)

        valeur = self.node.item.getValeur()
        if valeur == None:
            self.lineEditVal.clear()
        elif type(valeur) == list:
            texte = "["
            for l in valeur:
                texte = texte + str(l) + ","
            texte = texte[0:-1] + "]"
            self.lineEditVal.setText(texte)
        else:
            self.lineEditVal.setText(str(valeur))

    def donnePremier(self):
        self.lineEditVal.setFocus(7)

    def LEvaleurPressed(self):
        if self.verifiePressed() == False:
            QMessageBox.warning(
                self, tr("Modification Impossible"), tr("le parametre n'est pas valide")
            )
        nom = str(self.lineEditNom.text())
        val = str(self.lineEditVal.text())
        self.node.item.setNom(nom)
        self.node.item.setValeur(val)
        self.node.updateTexte()

    def LENomPressed(self):
        self.LEvaleurPressed()

    def verifiePressed(self):
        nomString = str(self.lineEditNom.text())
        if not pattern_name.match(nomString):
            self.LECommentaire.setText(
                nomString + tr(" n est pas un identifiant correct")
            )
            return False

        valString = str(self.lineEditVal.text())

        contexte = {}
        exec("from InterfaceGUI.QT6.ath import *", contexte)
        jdc = self.node.item.getJdc()
        for p in jdc.params:
            try:
                tp = p.nom + "=" + str(repr(p.valeur))
                exec(tp, contexte)
            except exc:
                pass

        monTexte = nomString + "=" + valString
        try:
            exec(monTexte, contexte)
        except (
            ValueError,
            TypeError,
            NameError,
            RuntimeError,
            ZeroDivisionError,
        ) as exc:
            self.LECommentaire.setText(tr("Valeur incorrecte: ") + str(exc))
            return False
        except:
            self.LECommentaire.setText(tr("Valeur incorrecte "))
            return False

        self.LECommentaire.setText(tr("Valeur correcte "))
        return True

    def afficheApres(self):
        self.node.selectApres()

    def afficheAvant(self):
        self.node.selectAvant()
