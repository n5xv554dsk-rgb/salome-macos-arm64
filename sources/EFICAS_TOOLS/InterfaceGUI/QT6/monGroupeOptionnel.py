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


from PyQt6.QtWidgets import QCheckBox, QWidget, QLabel, QPushButton
from PyQt6.QtCore import Qt, QRect
from PyQt6.QtGui import QPalette

from Accas.extensions.eficas_translation import tr
from UiQT6.desGroupeOptionnel import Ui_groupeOptionnel
from UiQT6.desPBOptionnelMT import Ui_customPB


# Import des panels


class MonRBButtonCustom(QCheckBox):
    def __init__(self, texte, monOptionnel, parent=None, couleur=None):
        QCheckBox.__init__(self, tr(texte), parent)
        self.mousePressed = True
        self.monOptionnel = monOptionnel
        self.setToolTip(tr("clicker: affichage aide, double-click: ajout"))
        if couleur != None:
            mapalette = self.palette()
            mapalette.setColor(QPalette.WindowText, couleur)
            mapalette.setColor(QPalette.Base, Qt.GlobalColor.green)
            self.setPalette(mapalette)
            self.setText(tr(texte))
            try:
                monToolTip = monOptionnel.parentMC.dictToolTipMc[texte]
                self.setToolTip(monToolTip)
            except:
                pass

    def mouseDoubleClickEvent(self, event):
        # print "dans mouseDoubleClickEvent", self
        if self not in self.monOptionnel.dicoCb:
            event.accept()
            return
        listeCheckedMC = "+" + self.monOptionnel.dicoCb[self]
        self.monOptionnel.parentMC.ajoutMC(listeCheckedMC)
        event.accept()

    def mousePressEvent(self, event):
        if not (event.button() != Qt.Type.RightButton):
            event.accept()
            return
        if self.monOptionnel.cbPressed != None:
            self.monOptionnel.cbPressed.setChecked(False)
        self.monOptionnel.cbPressed = self
        if self.mousePressed == False:
            self.mousePressed = True
        else:
            self.mousePressed = False
            self.ajoutAideMC()
        QCheckBox.mousePressEvent(self, event)
        event.accept()

    def ajoutAideMC(self):
        try:
            maDefinition = self.monOptionnel.parentMC.definition.entites[self.texte]
            maLangue = self.monOptionnel.parentMC.jdc.lang
            if hasattr(maDefinition, maLangue):
                self.monAide = getattr(
                    maDefinition, self.monOptionnel.parentMC.jdc.lang
                )
            else:
                self.monAide = ""
        except:
            self.monAide = ""
        self.monOptionnel.parentMC.editor.afficheCommentaire(self.monAide)


class MonPBButtonCustom(QWidget, Ui_customPB):
    def __init__(self, texte, monOptionnel, parent=None, couleur=None):
        QWidget.__init__(self)
        self.setupUi(self)
        if couleur != None:
            self.monPb.setText(texte)
            self.monPb.setStyleSheet(
                "QPushButton {background-color: #A3C1DA; color: red;}"
            )
            # mapalette=self.monPb.palette()
            # mapalette.setColor( QPalette.ButtonText, Qt.GlobalColor.red )
            # self.monPb.setPalette( mapalette )
            self.monPb.update()
            # self.update()
            try:
                monToolTip = monOptionnel.parentMC.dictToolTipMc[texte]
                self.monPb.setToolTip(monToolTip)
            except:
                pass
        self.monPb.setText(texte)
        self.monPb.clicked.connect(self.ajoutMC)

        self.texte = texte
        self.monOptionnel = monOptionnel
        self.definitAideMC()
        self.setToolTip(self.monAide)

    def ajoutMC(self):
        listeCheckedMC = "+" + self.monOptionnel.dicoCb[self]
        self.monOptionnel.parentMC.ajoutMC(listeCheckedMC)

    def definitAideMC(self):
        try:
            maDefinition = self.monOptionnel.parentMC.definition.entites[self.texte]
            maLangue = self.monOptionnel.parentMC.jdc.lang
            if hasattr(maDefinition, maLangue):
                self.monAide = getattr(
                    maDefinition, self.monOptionnel.parentMC.jdc.lang
                )
        except:
            self.monAide = ""


class MonGroupeOptionnel(QWidget, Ui_groupeOptionnel):
    """ """

    def __init__(self, liste, liste_rouge, parentQt, parentMC):
        # print ("dans init de monWidgetOptionnel ", parentQt, liste,parentMC)
        QWidget.__init__(self, None)
        self.setupUi(self)
        self.listeChecked = []
        self.dicoCb = {}
        self.mousePressed = False
        self.cbPressed = None
        self.cb = None
        self.parentQt = parentQt
        self.parentMC = parentMC

        if liste != []:
            self.affiche(liste, liste_rouge)
            self.afficheTitre()
        elif self.parentQt.parentQt.maConfiguration.afficheOptionnelVide != False:
            self.afficheTitre()
            self.MCOptionnelLayout.insertWidget(0, QLabel(tr("Pas de MC Optionnel")))
        else:
            self.frameLabelMC.close()
        # print "dans fin de monWidgetOptionnel ", parentQt

    def afficheTitre(self):
        labeltext, fonte, couleur = self.parentMC.node.item.getLabelText()
        # print (labeltext)
        l = tr(labeltext)
        li = []
        while len(l) > 25:
            li.append(l[0:24])
            l = l[24:]
        li.append(l)
        texte = ""
        for l in li:
            texte += l + "\n"
        texte = texte[0:-1]
        self.MCLabel.setText(texte)

    def affiche(self, liste, liste_rouge):
        # print ("dans Optionnel ____ affiche", liste,liste_rouge)
        self.dicoCb = {}
        liste.reverse()
        for mot in liste:
            # if mot in liste_rouge : print ('je dois afficher en rouge' , mot)
            couleur = None
            if mot in liste_rouge:
                couleur = Qt.GlobalColor.red
            if self.parentQt.parentQt.maConfiguration.simpleClic == False:
                cb = MonRBButtonCustom(mot, self, couleur=couleur)
                cb.clicked.connect(cb.ajoutAideMC)
            else:
                cb = MonPBButtonCustom(mot, self, couleur=couleur)

            self.MCOptionnelLayout.insertWidget(0, cb)
            self.dicoCb[cb] = mot
        self.scrollAreaCommandesOptionnelles.horizontalScrollBar().setSliderPosition(0)
