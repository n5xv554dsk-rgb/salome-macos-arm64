# -*- coding: utf-8 -*-
# Copyright (C) 2007 - 2026   EDF R&D
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
from Accas.extensions.eficas_translation import tr
from InterfaceGUI.QT6.monWidgetSimpTxt import MonWidgetSimpTxt
from InterfaceGUI.QT6.monWidgetPlusieursBase import MonWidgetPlusieursBase
from copy import copy, deepcopy
from PyQt6.QtCore import Qt


class MonWidgetPlusieursCreeUserAssd(MonWidgetPlusieursBase):
    def __init__(self, node, monSimpDef, nom, objSimp, parentQt, commande):
        MonWidgetPlusieursBase.__init__(
            self, node, monSimpDef, nom, objSimp, parentQt, commande
        )
        self.etablitOrdre()
        self.scrollArea.leaveEvent = self.leaveEventScrollArea
        self.RBHaut.close()
        self.RBBas.close()

    def ajout1Valeur(self, valeur=None):
        if not valeur in list(self.dictValeurs.keys()):
            validite, commentaire = self.objSimp.creeUserASSDetSetValeur(valeur)
            MonWidgetPlusieursBase.ajout1Valeur(self, valeur)

    def changeValeur(self, changeDePlace=False, oblige=False):
        # print ('dans changeValeur du CreeUserAssd', changeDePlace, self.numLineEditEnCours)
        # import traceback
        # traceback.print_stack()
        self.changeUnLineEdit = False
        valeur = self.lineEditEnCours.text()
        if self.numLineEditEnCours in list(self.dictLE.keys()):
            oldValeurUserAssd = self.dictLE[self.numLineEditEnCours]
            if oldValeurUserAssd == None or oldValeurUserAssd == "":
                enCreation = True
                oldValeurUserAssd == True
            else:
                enCreation = False
        else:
            enCreation = True
            oldValeurUserAssd = None

        if oldValeurUserAssd and oldValeurUserAssd.nom == valeur:
            self.selectionneNext()
            return

        if valeur != "":
            if not enCreation:
                validite, commentaire = self.node.item.renommeSdCreeDsListe(
                    oldValeurUserAssd, valeur
                )
                if commentaire != "" and not validite:
                    self.editor.afficheMessageQt(commentaire, Qt.GlobalColor.red)
                    self.lineEditEnCours.setText(oldValeurUserAssd.nom)
                nomDernierLineEdit = "lineEditVal" + str(self.numLineEditEnCours + 1)
                dernier = getattr(self, nomDernierLineEdit)
                dernier.setFocus()
                return

            validite, objASSD, commentaire = self.objSimp.creeUserASSD(valeur)
            if commentaire != "" and not validite:
                self.editor.afficheMessageQt(commentaire, Qt.GlobalColor.red)
                self.lineEditEnCours.setText("")
                if objASSD:
                    objASSD.supprime(self.objSimp)
                return
        else:
            validite = 1
            objASSD = None
            commentaire = ""

        # on relit tout pour tenir compte des lignes blanches
        oldValeur = self.objSimp.valeur
        liste = []
        for i in range(1, self.indexDernierLabel + 1):
            if i == self.numLineEditEnCours and objASSD:
                liste.append(objASSD)
            elif self.dictLE[i] != None and self.dictLE[i] != "":
                liste.append(self.dictLE[i])
        validite = self.node.item.setValeur(liste)
        if not validite:
            self.objSimp.valeur = oldValeur
            self.objSimp.state = "changed"
            self.setValide()
            if objASSD:
                objASSD.supprime(self.objSimp)
            self.lineEditEnCours.setText(oldValeurUserASSD.nom)
            return

        validite = self.node.item.isValid()
        if validite:
            self.dictLE[self.numLineEditEnCours] = objASSD
            self.node.item.rattacheUserASSD(objASSD)
            if self.indexDernierLabel < len(liste):
                self.ajoutLineEdit()
            nomDernierLineEdit = "lineEditVal" + str(self.numLineEditEnCours + 1)
            self.listeValeursCourantes = liste
            dernier = getattr(self, nomDernierLineEdit)
            dernier.setFocus()
        else:
            self.editor.afficheMessageQt("ajout impossible", Qt.GlobalColor.red)
            if objASSD:
                objASSD.supprime(self.objSimp)
            self.lineEditEnCours.setText("")
        self.parentQt.propageChange(self.objSimp.definition.type[0], self)

    def selectionneDernier(self):
        index = len(self.listeValeursCourantes)
        self.listeAffichageWidget[index].setFocus()

    def leaveEventScrollArea(self, event):
        pass

    #  def echangeDeuxValeurs(self):
    #    self.changeUnLineEdit=False
    #    obj1=self.dictLE[self.num1]
    #    obj2=self.dictLE[self.num2]
    #    self.dictLE[self.num1]=obj2
    #    self.dictLE[self.num2]=obj1
    #    nomLineEdit=self.nomLine+str(self.num1)
    #    courant=getattr(self,nomLineEdit)
    #    if self.dictLE[self.num1] != None : courant.setText(self.dictLE[self.num1].nom)
    #    else : courant.setText("")
    #    nomLineEdit=self.nomLine+str(self.num2)
    #    courant=getattr(self,nomLineEdit)
    #    if self.dictLE[self.num2] != None : courant.setText(self.dictLE[self.num2].nom)
    #    else : courant.setText("")
    #    liste=[]
    #    for i in list(self.dictLE.keys()):
    #       if self.dictLE[i] != None and self.dictLE[i] != "" : liste.append(self.dictLE[i])
    #    validite=self.node.item.setValeur(liste)
    #    self.listeValeursCourantes=liste
    #    courant.setFocus(True)

    def descendLesLignes(self):
        self.changeUnLineEdit = False
        if self.numLineEditEnCours == self.indexDernierLabel:
            return
        nouvelleValeur = None
        for i in range(self.numLineEditEnCours + 1, self.indexDernierLabel):
            valeurAGarder = self.dictLE[i]
            self.dictLE[i] = nouvelleValeur
            nomLineEdit = self.nomLine + str(i)
            courant = getattr(self, nomLineEdit)
            if nouvelleValeur != None:
                courant.setText(nouvelleValeur.nom)
            else:
                courant.setText("")
            nouvelleValeur = valeurAGarder

    def moinsPushed(self):
        if self.numLineEditEnCours == 0:
            return
        if self.indexDernierLabel == 0:
            return
        objASSD = self.dictLE[self.numLineEditEnCours]
        if objASSD:
            objASSD.supprime(self.objSimp)
        self.lineEditEnCours.setText("")
        self.dictLE[self.numLineEditEnCours] = None

        for i in range(self.numLineEditEnCours, self.indexDernierLabel - 1):
            self.dictLE[i] = self.dictLE[i + 1]
            nomLineEdit = self.nomLine + str(i)
            courant = getattr(self, nomLineEdit)
            if self.dictLE[i] != None:
                courant.setText(self.dictLE[i].nom)
            else:
                courant.setText("")
        nomLineEdit = self.nomLine + str(self.indexDernierLabel)
        courant = getattr(self, nomLineEdit)
        courant.setText("")
        self.dictLE[self.indexDernierLabel] = None
        liste = []
        for i in list(self.dictLE.keys()):
            if self.dictLE[i] != None and self.dictLE[i] != "":
                liste.append(self.dictLE[i])
        print(liste)
        validite = self.node.item.setValeur(liste)
        self.listeValeursCourantes = liste
