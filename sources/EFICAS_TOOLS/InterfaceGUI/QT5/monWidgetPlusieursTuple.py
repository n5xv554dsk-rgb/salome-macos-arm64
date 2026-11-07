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

import os
from PyQt5.QtWidgets import QFrame, QApplication, QFrame, QWidget
from PyQt5.QtGui import QIcon
from PyQt5.QtCore import QSize, Qt, QTimer

from Accas.extensions.eficas_translation import tr

from InterfaceGUI.QT5.feuille import Feuille
from InterfaceGUI.Common.politiquesValidation import PolitiquePlusieurs
from InterfaceGUI.QT5.traiteSaisie import SaisieValeur
from InterfaceGUI.QT5.gereListe import GereListe
from InterfaceGUI.QT5.gereListe import LECustom
from UiQT5.Tuple2 import Ui_Tuple2
from UiQT5.Tuple3 import Ui_Tuple3
from UiQT5.Tuple4 import Ui_Tuple4
from UiQT5.Tuple5 import Ui_Tuple5
from UiQT5.Tuple6 import Ui_Tuple6
from UiQT5.Tuple7 import Ui_Tuple7
from UiQT5.Tuple8 import Ui_Tuple8
from UiQT5.Tuple9 import Ui_Tuple9
from UiQT5.Tuple10 import Ui_Tuple10


# --------------------------
class TupleCustom(object):
    # --------------------------

    def __init__(self, tailleTuple, parent, parentQt, index):
    # -------------------------------------------------
        QWidget.__init__(self, parent)
        self.setupUi(self)
        self.tailleTuple = tailleTuple
        self.parent = parent
        self.parentQt = parentQt
        self.valeur = []
        self.index = index
        self.inFocusOutEvent = False

        for i in range(self.tailleTuple):
            nomLE = "lineEditVal" + str(i + 1)
            courant = getattr(self, nomLE)
            courant.num = index
            courant.dansUnTuple = True
            courant.returnPressed.connect(self.valueChange)
            courant.numDsLaListe = i + 1
            courant.tupleCustomParent = self
            courant.parentTuple = self

    def valueChange(self):
    # ----------------------

        listeVal = []
        for i in range(self.tailleTuple):
            nomLE = "lineEditVal" + str(i + 1)
            courant = getattr(self, nomLE)
            val = str(courant.text())

            if str(val) == "" or val == None:
                if not self.inFocusOutEvent:
                    courant.setFocus()
                return

            try:
                valeur = eval(val, {})
            except:
                try:
                    d = self.parentQt.objSimp.jdc.getContexteAvant(
                        self.parentQt.objSimp.etape
                    )
                    valeur = eval(val, d)
                except:
                    valeur = val
            listeVal.append(valeur)
        self.valeur = listeVal
        self.parentQt.changeValeur()

    def setValeur(self, value):
    # ----------------------

        listeVal = []
        valeurNulle = True
        for i in range(self.tailleTuple):
            nomLE = "lineEditVal" + str(i + 1)
            courant = getattr(self, nomLE)
            try:
                if str(value[i]) != "":
                    valeurNulle = False
            except:
                pass

            try:
                courant.setText(str(value[i]))
            except:
                courant.setText("")
            val = str(courant.text())
            try:
                valeur = eval(val, {})
            except:
                try:
                    d = self.parentQt.objSimp.jdc.getContexteAvant(
                        self.parentQt.objSimp.etape
                    )
                    valeur = eval(val, d)
                except:
                    valeur = val
            listeVal.append(valeur)
        if valeurNulle == True:
            self.valeur = None
        else:
            self.valeur = listeVal

    def getValeurbad(self):
    # ----------------------
        self.valeur = []
        vide = True
        print(self.tailleTuple)
        for i in range(self.tailleTuple):
            nomLE = "lineEditVal" + str(i + 1)
            courant = getattr(self, nomLE)
            self.valeur.append(courant.valeur)
            if courant.valeur != None:
                vide = False
        if vide:
            self.valeur = []
        return self.valeur

    def getValeur(self):
    # ----------------------
        return self.valeur

    def text(self):
    # --------------
        return self.valeur

    def setText(self, value):
    # -----------------------
        self.setValeur(value)

    def clean(self):
    # -------------------
        self.valeur = None
        for i in range(self.tailleTuple):
            nomLE = "lineEditVal" + str(i + 1)
            courant = getattr(self, nomLE)
            courant.setText("")

    def finCommentaire(self):
    # -------------------
        return self.finCommentaireListe()


# -------------------------------------------------
class TupleCustom2(QWidget, Ui_Tuple2, TupleCustom):
    # -------------------------------------------------
    def __init__(self, tailleTuple, parent, parentQt, index):
    # -------------------
        TupleCustom.__init__(self, tailleTuple, parent, parentQt, index)
        if self.parentQt.editor.maConfiguration.closeParenthese:
            self.label_5.close()
            self.label_7.close()


# -------------------------------------------------
class TupleCustom3(QWidget, Ui_Tuple3, TupleCustom):
    # -------------------------------------------------
    def __init__(self, tailleTuple, parent, parentQt, index):
    # -------------------
        TupleCustom.__init__(self, tailleTuple, parent, parentQt, index)


# -------------------------------------------------
class TupleCustom4(QWidget, Ui_Tuple4, TupleCustom):
    # -------------------------------------------------
    def __init__(self, tailleTuple, parent, parentQt, index):
    # -------------------
        TupleCustom.__init__(self, tailleTuple, parent, parentQt, index)


# -------------------------------------------------
class TupleCustom5(QWidget, Ui_Tuple5, TupleCustom):
    # -------------------------------------------------
    def __init__(self, tailleTuple, parent, parentQt, index):
    # -------------------
        TupleCustom.__init__(self, tailleTuple, parent, parentQt, index)


# -------------------------------------------------
class TupleCustom6(QWidget, Ui_Tuple6, TupleCustom):
    # -------------------------------------------------
    def __init__(self, tailleTuple, parent, parentQt, index):
    # -------------------
        TupleCustom.__init__(self, tailleTuple, parent, parentQt, index)


# -------------------------------------------------
class TupleCustom7(QWidget, Ui_Tuple7, TupleCustom):
    # -------------------------------------------------
    def __init__(self, tailleTuple, parent, parentQt, index):
    # -------------------
        TupleCustom.__init__(self, tailleTuple, parent, parentQt, index)


# -------------------------------------------------
class TupleCustom8(QWidget, Ui_Tuple8, TupleCustom):
    # -------------------------------------------------
    def __init__(self, tailleTuple, parent, parentQt, index):
    # -------------------
        TupleCustom.__init__(self, tailleTuple, parent, parentQt, index)


# -------------------------------------------------
class TupleCustom9(QWidget, Ui_Tuple9, TupleCustom):
    # -------------------------------------------------
    def __init__(self, tailleTuple, parent, parentQt, index):
    # -------------------
        TupleCustom.__init__(self, tailleTuple, parent, parentQt, index)


# -------------------------------------------------
class TupleCustom10(QWidget, Ui_Tuple10, TupleCustom):
    # -------------------------------------------------
    def __init__(self, tailleTuple, parent, parentQt, index):
    # -------------------
        TupleCustom.__init__(self, tailleTuple, parent, parentQt, index)
        if self.parentQt.editor.maConfiguration.closeParenthese:
            self.label_5.close()
            self.label_7.close()


# -------------------------------------------- #
class MonWidgetPlusieursTuple(Feuille, GereListe):
    # -------------------------------------------- #

    def __init__(self, node, monSimpDef, nom, objSimp, parentQt, commande):
    # -----------------------------------------------------

        self.indexDernierLabel = 0
        self.numLineEditEnCours = 0
        self.nomLine = "TupleVal"
        self.listeAffichageWidget = []
        Feuille.__init__(self, node, monSimpDef, nom, objSimp, parentQt, commande)
        GereListe.__init__(self)
        self.finCommentaireListe()
        self.politique = PolitiquePlusieurs(self.node, self.editor)
        self.parentQt.commandesLayout.insertWidget(-1, self)

        if 1:
            # Pour MT
            repIcon = self.node.editor.appliEficas.repIcon
            fichier = os.path.join(repIcon, "arrow_up.png")
            icon = QIcon(fichier)
            self.RBHaut.setIcon(icon)
            self.RBHaut.setIconSize(QSize(32, 32))
            fichier2 = os.path.join(repIcon, "arrow_down.png")
            icon2 = QIcon(fichier2)
            self.RBBas.setIcon(icon2)
            fichier3 = os.path.join(repIcon, "file-explorer.png")
            icon3 = QIcon(fichier3)
            self.BSelectFichier.setIcon(icon3)
            self.BSelectFichier.setIconSize(QSize(32, 32))
        self.BSelectFichier.clicked.connect(self.selectInFile)

    def ajoutLineEdit(self, valeur=None, inInit=False):
    # ------------------------------------------------
        self.indexDernierLabel = self.indexDernierLabel + 1
        nomLineEdit = self.nomLine + str(self.indexDernierLabel)
        if hasattr(self, nomLineEdit):
            self.indexDernierLabel = self.indexDernierLabel - 1
            return

        nomCustomTuple = "TupleCustom" + str(self.nbValeurs)
        laClasseDuTuple = globals()[nomCustomTuple]
        nouveauLE = laClasseDuTuple(
            self.nbValeurs, self.scrollArea, self, self.indexDernierLabel
        )

        # if self.nbValeurs == 2 : nouveauLE = TupleCustom2(self.nbValeurs,self.scrollArea,self,self.indexDernierLabel)
        # else                   : nouveauLE = TupleCustom3(self.nbValeurs,self.scrollArea,self,self.indexDernierLabel)

        self.verticalLayoutLE.insertWidget(self.indexDernierLabel - 1, nouveauLE)
        setattr(self, nomLineEdit, nouveauLE)
        if valeur != None:
            nouveauLE.setValeur(valeur)

        for i in range(self.nbValeurs):
            num = i + 1
            nomLineEdit = "lineEditVal" + str(num)
            lineEditVal = getattr(nouveauLE, nomLineEdit)
            self.listeAffichageWidget.append(lineEditVal)
        # self.listeAffichageWidget.append(nouveauLE.lineEditVal1)
        # self.listeAffichageWidget.append(nouveauLE.lineEditVal2)
        # if self.nbValeurs == 3 : self.listeAffichageWidget.append(nouveauLE.lineEditVal3)

        self.etablitOrdre()

        # deux lignes pour que le ensureVisible fonctionne
        self.estVisible = nouveauLE.lineEditVal1
        if inInit == False:
            QTimer.singleShot(1, self.rendVisibleLigne)

    def etablitOrdre(self):
    # ---------------------
        i = 0
        while i + 1 < len(self.listeAffichageWidget):
            self.listeAffichageWidget[i].setFocusPolicy(Qt.StrongFocus)
            self.setTabOrder(
                self.listeAffichageWidget[i], self.listeAffichageWidget[i + 1]
            )
            i = i + 1

    def setValeurs(self):
    # ---------------------
        if self.editor.code == "PSEN":
            self.RBListePush()
        valeurs = self.node.item.getValeur()
        min, max = self.node.item.getMinMax()
        if max == "**" or max > 8:
            aCreer = 8
        else:
            aCreer = max

        if valeurs == () or valeurs == None:
            for i in range(aCreer):
                self.ajoutLineEdit(inInit=True)
            return

        for v in valeurs:
            self.ajoutLineEdit(v, inInit=True)

        for i in range(len(valeurs), aCreer):
            self.ajoutLineEdit(inInit=True)

    def rendVisibleLigne(self):
    # -------------------------
        QApplication.processEvents()
        self.estVisible.setFocus(True)
        self.scrollArea.ensureWidgetVisible(self.estVisible, 0, 0)

    def changeValeur(self, changeDePlace=False, oblige=True):
    # -----------------------------------------------------
        # Pour compatibilite signature
        # print ('dschangeValeur', self.indexDernierLabel)

        aLeFocus = self.focusWidget()
        listeComplete = []
        libre = False
        # print (self.indexDernierLabel)
        for i in range(self.indexDernierLabel):
            nom = self.nomLine + str(i + 1)
            courant = getattr(self, nom)
            valeurTuple = courant.valeur
            if valeurTuple == None or valeurTuple == "" or valeurTuple == []:
                libre = True
                continue
            validite, comm, comm2, listeRetour = self.politique.ajoutTuple(
                valeurTuple, listeComplete
            )
            if not validite:
                if comm2 != "":
                    comm += " " + comm2
                self.editor.afficheMessageQt(
                    comm + " " + str(self.objSimp.definition.validators.typeDesTuples),
                    Qt.red,
                )
                return
            listeComplete.append(tuple(courant.valeur))
        # print ('listeComplete', listeComplete)
        if listeComplete == []:
            listeComplete = None
        self.node.item.setValeur(listeComplete)

        if changeDePlace:
            return
        min, max = self.node.item.getMinMax()
        if self.indexDernierLabel == max:
            self.editor.afficheMessageQt(tr("Nb maximum de valeurs atteint"))
        if self.indexDernierLabel < max and libre == False:
            self.ajoutLineEdit()
            self.listeAffichageWidget[-2].setFocus(True)
        else:
            try:
                QApplication.processEvents()
                w = self.listeAffichageWidget[
                    self.listeAffichageWidget.index(aLeFocus) + 1
                ]
                w.setFocus(True)
                self.scrollArea.ensureWidgetVisible(w, 0, 0)
            except:
                pass

    def echange(self, num1, num2):
        # on donne le focus au a celui ou on a bouge
        # par convention le 2
        nomLineEdit = self.nomLine + str(num1)
        courant = getattr(self, nomLineEdit)
        valeurAGarder = courant.getValeur()
        nomLineEdit2 = self.nomLine + str(num2)
        courant2 = getattr(self, nomLineEdit2)
        courant.setText(courant2.text())
        courant2.setText(valeurAGarder)
        self.changeValeur(changeDePlace=True)
        self.numLineEditEnCours = num2
        self.lineEditEnCours = courant2
        courant2.lineEditVal1.setFocus(True)

    def ajoutNValeur(self, liste):
    # ----------------------------
        # attention quand on charge par un fichier, on ne peut pas se contenter d ajouter N fois 1 valeur
        # car alors le temps de verification devient prohibitif  reconstructu=ion et verification a
        # chaque valeur. d ou l ajout de ajoutNTuple a politique plusieurs

        if len(liste) % self.nbValeurs != 0:
            texte = "Nombre incorrect de valeurs"
            self.editor.afficheMessageQt(tr(texte), Qt.red)
            return

        i = 0
        longueur = len(liste) // self.nbValeurs
        increment = self.nbValeurs
        listeFormatee = [
            liste[k * increment : (k + 1) * increment] for k in range(longueur)
        ]
        listeFormatee = tuple(listeFormatee)

        min, max = self.node.item.getMinMax()
        if self.objSimp.valeur == None:
            listeComplete = listeFormatee
        else:
            listeComplete = self.objSimp.valeur + listeFormatee

        if len(listeComplete) > max:
            texte = tr("Nombre maximum de valeurs ") + str(max) + tr(" atteint")
            self.editor.afficheMessageQt(texte, Qt.red)
            return

        validite, comm, comm2, listeRetour = self.politique.ajoutNTuple(listeComplete)
        if not validite:
            self.editor.afficheMessageQt(comm + comm2, Qt.red)
            return

        # on calcule le dernier lineedit rempli avant de changer la valeur
        if self.objSimp.valeur != None:
            indexDernierRempli = len(self.objSimp.valeur)
        else:
            indexDernierRempli = 0

        self.politique.recordValeur(listeComplete)

        while i < len(liste):
            try:
                t = tuple(liste[i : i + self.nbValeurs])
            except:
                t = tuple(liste[i : len(liste)])
            i = i + self.nbValeurs
            if indexDernierRempli < self.indexDernierLabel:
                nomLEARemplir = self.nomLine + str(indexDernierRempli + 1)
                LEARemplir = getattr(self, nomLEARemplir)
                for n in range(self.nbValeurs):
                    nomLineEdit = "lineEditVal" + str(n + 1)
                    lineEditVal = getattr(LEARemplir, nomLineEdit)
                    lineEditVal.setText(str(t[n]))
            else:
                # ne pas appeler ajoutLineEdit(t,False ) pb de boucle pb du a etablitOrdre et a listeWidgetAffichage qui bouge
                self.indexDernierLabel = self.indexDernierLabel + 1
                nomLineEdit = self.nomLine + str(self.indexDernierLabel)

                nomCustomTuple = "TupleCustom" + str(self.nbValeurs)
                laClasseDuTuple = globals()[nomCustomTuple]
                nouveauLE = laClasseDuTuple(
                    self.nbValeurs, self.scrollArea, self, self.indexDernierLabel
                )

                self.verticalLayoutLE.insertWidget(
                    self.indexDernierLabel - 1, nouveauLE
                )
                setattr(self, nomLineEdit, nouveauLE)
                nouveauLE.setValeur(t)

                for n in range(self.nbValeurs):
                    nomLineEdit = "lineEditVal" + str(n + 1)
                    lineEditVal = getattr(nouveauLE, nomLineEdit)
                    self.listeAffichageWidget.append(lineEditVal)
            indexDernierRempli = indexDernierRempli + 1

        self.etablitOrdre()

    def RBListePush(self):
    # ----------------------
        # PN a rendre generique avec un truc tel prerempli
        # pour l instant specifique PSEN

        if self.editor.code == "VP":
            return
        if self.objSimp.valeur != None and self.objSimp.valeur != []:
            return
        if not hasattr(self.editor.readercata.cata, "sd_ligne"):
            self.editor.readercata.cata.sd_ligne = None
        if not hasattr(self.editor.readercata.cata, "sd_generateur"):
            self.editor.readercata.cata.sd_generateur = None
        if not hasattr(self.editor.readercata.cata, "sd_transfo"):
            self.editor.readercata.cata.sd_transfo = None
        if not hasattr(self.editor.readercata.cata, "sd_charge"):
            self.editor.readercata.cata.sd_charge = None
        if not hasattr(self.editor.readercata.cata, "sd_moteur"):
            self.editor.readercata.cata.sd_moteur = None
        if (
            self.objSimp.definition.validators.typeDesTuples[0]
            == self.editor.readercata.cata.sd_ligne
        ):
            val = []
            if hasattr(self.objSimp.jdc, "LineDico"):
                for k in self.objSimp.jdc.LineDico:
                    try:
                        valeur = self.objSimp.jdc.getConcept(k)
                        val.append((valeur, 0))
                    except:
                        pass
            self.node.item.setValeur(val)
        if (
            self.objSimp.definition.validators.typeDesTuples[0]
            == self.editor.readercata.cata.sd_generateur
        ):
            val = []
            if hasattr(self.objSimp.jdc, "MachineDico"):
                for k in self.objSimp.jdc.MachineDico:
                    try:
                        valeur = self.objSimp.jdc.getConcept(k)
                        val.append((valeur, 0))
                    except:
                        pass
            self.node.item.setValeur(val)
        if (
            self.objSimp.definition.validators.typeDesTuples[0]
            == self.editor.readercata.cata.sd_transfo
        ):
            val = []
            if hasattr(self.objSimp.jdc, "TransfoDico"):
                for k in self.objSimp.jdc.TransfoDico:
                    try:
                        valeur = self.objSimp.jdc.getConcept(k)
                        val.append((valeur, 0))
                    except:
                        pass
            self.node.item.setValeur(val)
        if (
            self.objSimp.definition.validators.typeDesTuples[0]
            == self.editor.readercata.cata.sd_charge
        ):
            val = []
            if hasattr(self.objSimp.jdc, "LoadDico"):
                for k in self.objSimp.jdc.LoadDico:
                    try:
                        valeur = self.objSimp.jdc.getConcept(k)
                        val.append((valeur, 0))
                    except:
                        pass
            self.node.item.setValeur(val)
        if (
            self.objSimp.definition.validators.typeDesTuples[0]
            == self.editor.readercata.cata.sd_moteur
        ):
            val = []
            if hasattr(self.objSimp.jdc, "MotorDico"):
                for k in self.objSimp.jdc.MotorDico:
                    try:
                        valeur = self.objSimp.jdc.getConcept(k)
                        val.append((valeur, 0))
                    except:
                        pass
            self.node.item.setValeur(val)
