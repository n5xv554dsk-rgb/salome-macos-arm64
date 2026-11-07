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

from UiQT5.desWidgetFormule import Ui_WidgetFormule
from InterfaceGUI.QT5.gereIcones import FacultatifOuOptionnel

from PyQt5.QtWidgets import QWidget
from PyQt5.QtGui import QIcon
from PyQt5.QtCore import Qt


from Accas.extensions.eficas_translation import tr
import Accas
import os


# Import des panels


class MonWidgetFormule(QWidget, Ui_WidgetFormule, FacultatifOuOptionnel):
    """ """

    def __init__(self, node, editor, etape):
        # print "MonWidgetFormule ", self
        QWidget.__init__(self, None)
        self.node = node
        self.node.fenetre = self
        self.editor = editor
        self.appliEficas = self.editor.appliEficas
        self.repIcon = self.appliEficas.repIcon
        self.setupUi(self)

        self.setIconePoubelle()
        self.setIconesGenerales()
        self.setValeurs()
        self.setValide()

        if self.editor.code in ["MAP", "CARMELCND"]:
            self.bCatalogue.close()
        else:
            self.bCatalogue.clicked.connect(self.afficheCatalogue)
        if self.editor.code in ["Adao", "MAP", "ADAO"]:
            self.bAvant.close()
            self.bApres.close()
        else:
            self.bAvant.clicked.connect(self.afficheAvant)
            self.bApres.clicked.connect(self.afficheApres)
        self.LENom.returnPressed.connect(self.nomChange)
        self.LENomFormule.returnPressed.connect(self.nomFormuleSaisi)
        self.LENomsArgs.returnPressed.connect(self.argsSaisis)
        self.LECorpsFormule.returnPressed.connect(self.FormuleSaisie)

        self.racine = self.node.tree.racine
        self.monOptionnel = None
        self.editor.fermeOptionnel()
        # print "fin init de widget Commande"

    def donnePremier(self):
        self.listeAffichageWidget[0].setFocus(7)

    def setValeurs(self):
        self.LENomFormule.setText(self.node.item.getNom())
        self.LECorpsFormule.setText(self.node.item.getCorps())
        texte_args = ""
        if self.node.item.getArgs() != None:
            for i in self.node.item.getArgs():
                if texte_args != "":
                    texte_args = texte_args + ","
                texte_args = texte_args + i
        self.LENomsArgs.setText(texte_args)

    def nomChange(self):
        nom = str(self.LENom.text())
        self.LENomFormule.setText(nom)
        self.nomFormuleSaisi()

    def afficheCatalogue(self):
        if self.editor.widgetOptionnel != None:
            self.monOptionnel.hide()
        self.racine.affichePanneau()
        if self.node:
            self.node.select()
        else:
            self.racine.select()

    def afficheApres(self):
        self.node.selectApres()

    def afficheAvant(self):
        self.node.selectAvant()

    def setValide(self):
        if not (hasattr(self, "RBValide")):
            return
        icon = QIcon()
        if self.node.item.object.isValid():
            icon = QIcon(self.repIcon + "/ast-green-ball.png")
        else:
            icon = QIcon(self.repIcon + "/ast-red-ball.png")
        if self.node.item.getIconName() == "ast-yellow-square":
            icon = QIcon(self.repIcon + "/ast-yel-ball.png")
        self.RBValide.setIcon(icon)

    def nomFormuleSaisi(self):
        nomFormule = str(self.LENomFormule.text())
        if nomFormule == "":
            return
        self.LENom.setText(nomFormule)
        test, erreur = self.node.item.verifNom(nomFormule)
        if test:
            commentaire = nomFormule + tr(" est un nom valide pour une FORMULE")
            self.editor.afficheMessageQt(commentaire)
        else:
            commentaire = nomFormule + tr(" n'est pas un nom valide pour une FORMULE")
            self.editor.afficheMessageQt(commentaire, Qt.red)
            return
        if str(self.LENomsArgs.text()) != "" and str(self.LECorpsFormule.text()) != "":
            self.BOkPressedFormule()
        self.LENomsArgs.setFocus(7)

    def argsSaisis(self):
        arguments = str(self.LENomsArgs.text())
        if arguments == "":
            return
        test, erreur = self.node.item.verifArguments(arguments)
        if test:
            commentaire = tr("Argument(s) valide(s) pour une FORMULE")
            self.editor.afficheMessageQt(commentaire)
        else:
            commentaire = tr("Argument(s) invalide(s) pour une FORMULE")
            self.editor.afficheMessageQt(commentaire, Qt.red)
        if (
            str(self.LECorpsFormule.text()) != ""
            and str(self.LENomFormule.text()) != ""
        ):
            self.BOkPressedFormule()
        self.LECorpsFormule.setFocus(7)

    def FormuleSaisie(self):
        nomFormule = str(self.LENomFormule.text())
        arguments = str(self.LENomsArgs.text())
        expression = str(self.LECorpsFormule.text())
        if expression == "":
            return
        test, erreur = self.node.item.verifFormule_python(
            (nomFormule, "REEL", arguments, expression)
        )

        if test:
            commentaire = tr("Corps de FORMULE valide")
            self.editor.afficheMessageQt(commentaire)
        else:
            commentaire = tr("Corps de FORMULE invalide")
            self.editor.afficheMessageQt(commentaire, Qt.red)
        if str(self.LENomsArgs.text()) != "" and str(self.LENomFormule.text()) != "":
            self.BOkPressedFormule()

    def BOkPressedFormule(self):
        # print dir(self)
        # if self.parent.modified == 'n' : self.parent.initModif()

        nomFormule = str(self.LENomFormule.text())
        test, erreur = self.node.item.verifNom(nomFormule)
        if not test:
            self.editor.afficheMessageQt(erreur, Qt.red)
            return

        arguments = str(self.LENomsArgs.text())
        test, erreur = self.node.item.verifArguments(arguments)
        if not test:
            self.editor.afficheMessageQt(erreur, Qt.red)
            return

        expression = str(self.LECorpsFormule.text())
        test, erreur = self.node.item.verifFormule_python(
            (nomFormule, "REEL", arguments, expression)
        )
        if not test:
            self.editor.afficheMessageQt(erreur, Qt.red)
            return

        test = self.node.item.object.updateFormulePython(
            formule=(nomFormule, "REEL", arguments, expression)
        )
        test, erreur = self.node.item.saveFormule(
            nomFormule, "REEL", arguments, expression
        )
        if test:
            self.node.onValid()
            self.node.update_valid()
            commentaire = "Formule saisie"
            self.editor.afficheMessageQt(commentaire)
        else:
            commentaire = "Formule incorrecte : " + erreur
            self.editor.afficheMessageQt(commentaire, Qt.red)
        self.editor.initModif()
