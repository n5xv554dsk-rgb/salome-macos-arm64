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

import types

from UiQT5.desWidgetCommande import Ui_WidgetCommande
from InterfaceGUI.QT5.groupe import Groupe
from InterfaceGUI.QT5.gereIcones import FacultatifOuOptionnel

from PyQt5.QtWidgets import (
    QApplication,
    QWidget,
    QSpacerItem,
    QSizePolicy,
    QRadioButton,
)
from PyQt5.QtGui import QFont, QIcon
from PyQt5.QtCore import QTimer
from PyQt5.QtCore import Qt


from Accas.extensions.eficas_translation import tr
import Accas
import os


# Import des panels


class MonWidgetCommande(Ui_WidgetCommande, Groupe):
    """ """

    def __init__(self, node, editor, etape):
        self.listeAffichageWidget = []
        self.inhibe = 0
        self.ensure = 0
        editor.inhibeSplitter = 1
        Groupe.__init__(self, node, editor, None, etape.definition, etape, 1, self)
        spacerItem = QSpacerItem(21, 500, QSizePolicy.Expanding, QSizePolicy.Expanding)
        self.verticalLayoutCommande.addItem(spacerItem)
        editor.inhibeSplitter = 0

        # Gestion du nom de L OPER si il est nomme
        if not (hasattr(etape.definition, "sd_prod")) or (
            etape.definition.sd_prod == None
        ):
            self.LENom.close()
        elif (
            hasattr(etape.definition, "sd_prod")
            and type(etape.definition.sd_prod) == types.FunctionType
        ):
            self.LENom.close()
        elif (
            (hasattr(etape, "sdnom"))
            and etape.sdnom != "sansnom"
            and etape.sdnom != None
        ):
            self.LENom.setText(etape.sdnom)
        else:
            self.LENom.setText("")
        if hasattr(self, "LENom"):
            self.LENom.returnPressed.connect(self.nomChange)
        self.racine = self.node.tree.racine
        if self.node.item.getIconName() == "ast-red-square":
            self.LENom.setDisabled(True)

        # Gestion de la doc de l objet
        if node.item.getFr() != "":
            self.labelDoc.setText(node.item.getFr())
            nouvelleSize = self.frameAffichage.height() + 60
            self.frameAffichage.setMinimumHeight(nouvelleSize)
            self.frameAffichage.resize(self.frameAffichage.width(), nouvelleSize)
        else:
            self.labelDoc.close()

        # Gestion du nom de l etape
        maPolice = QFont(
            "Times",
            10,
        )
        self.setFont(maPolice)
        self.labelNomCommande.setText(tr(self.obj.nom))

        # Gestion du Frame d affichage des autres commandes
        if self.editor.maConfiguration.closeAutreCommande == True:
            self.closeAutreCommande()
        else:
            self.bCatalogue.clicked.connect(self.afficheCatalogue)
            self.bAvant.clicked.connect(self.afficheAvant)
            self.bApres.clicked.connect(self.afficheApres)

        if self.editor.maConfiguration.closeFrameRechercheCommande == True:
            self.frameAffichage.close()
            self.closeAutreCommande()

        self.setAcceptDrops(True)
        self.etablitOrdre()

        if self.editor.maConfiguration.enleverPoubellePourCommande:
            self.RBPoubelle.close()  # JDC Fige

        if self.editor.maConfiguration.pasDeMCOptionnels:
            return  # Pas de MC Optionnels pour Carmel

        from InterfaceGUI.QT5.monWidgetOptionnel import MonWidgetOptionnel

        if self.editor.widgetOptionnel != None:
            self.monOptionnel = self.editor.widgetOptionnel
        else:
            self.editor.inhibeSplitter = 1
            self.monOptionnel = MonWidgetOptionnel(self.editor)
            self.editor.widgetOptionnel = self.monOptionnel
            self.editor.splitter.addWidget(self.monOptionnel)
            self.editor.ajoutOptionnel()
            self.editor.inhibeSplitter = 0
            self.monOptionnel = self.editor.widgetOptionnel
        self.afficheOptionnel()

        # print "fin init de widget Commande"

    def closeAutreCommande(self):
        self.bCatalogue.close()
        self.bAvant.close()
        self.bApres.close()

    def donnePremier(self):
        # print "dans donnePremier"
        QApplication.processEvents()
        if self.listeAffichageWidget != []:
            self.listeAffichageWidget[0].setFocus(7)
        QApplication.processEvents()
        # print self.focusWidget()

    def focusNextPrevChild(self, next):
        # on s assure que ce n est pas un chgt de fenetre
        # print "je passe dans focusNextPrevChild"
        if self.editor.fenetreCentraleAffichee != self:
            return True
        f = self.focusWidget()
        if f not in self.listeAffichageWidget:
            i = 0
            while not hasattr(f, "AAfficher"):
                if f == None:
                    i = -1
                    break
                f = f.parentWidget()
            if hasattr(f, "AAfficher"):
                f = f.AAfficher
            if i != -1:
                i = self.listeAffichageWidget.index(f)
        else:
            i = self.listeAffichageWidget.index(f)
        if (i == len(self.listeAffichageWidget) - 1) and next and not self.inhibe:
            try:
                self.listeAffichageWidget[1].setFocus(7)
                w = self.focusWidget()
                self.inhibe = 1
                w.focusPreviousChild()
                self.inhibe = 0
                return True
            except:
                pass
                # print self.listeAffichageWidget
                # print "souci ds focusNextPrevChild"
        if i == 0 and next == False and not self.inhibe:
            if hasattr(self.editor.fenetreCentraleAffichee, "scrollArea"):
                self.editor.fenetreCentraleAffichee.scrollArea.ensureWidgetVisible(
                    self.listeAffichageWidget[-1]
                )
            self.listeAffichageWidget[-2].setFocus(7)
            self.inhibe = 1
            w = self.focusWidget()
            w.focusNextChild()
            self.inhibe = 0
            return True
        if i == 0 and next == True and not self.inhibe:
            self.listeAffichageWidget[0].setFocus(7)
            self.inhibe = 1
            w = self.focusWidget()
            w.focusNextChild()
            self.inhibe = 0
            return True
        if i > 0 and next == False and not self.inhibe:
            if isinstance(self.listeAffichageWidget[i - 1], QRadioButton):
                self.listeAffichageWidget[i - 1].setFocus(7)
                return True
        return QWidget.focusNextPrevChild(self, next)

    def etablitOrdre(self):
        i = 0
        while i + 1 < len(self.listeAffichageWidget):
            self.setTabOrder(
                self.listeAffichageWidget[i], self.listeAffichageWidget[i + 1]
            )
            i = i + 1
        # si on boucle on perd l'ordre

    def afficheSuivant(self, f):
        # print ('ds afficheSuivant')
        try:
            i = self.listeAffichageWidget.index(f)
            next = i + 1
        except:
            next = 1
        if next == len(self.listeAffichageWidget):
            next = 0
        # self.f=next
        try:
            self.listeAffichageWidget[next].setFocus(7)
        except:
            pass

    def nomChange(self):
        nom = str(self.LENom.text())
        nom = nom.strip()
        if nom == "":
            return  # si pas de nom, on ressort sans rien faire
        test, mess = self.node.item.nommeSd(nom)
        self.editor.afficheCommentaire(mess)

        # Notation scientifique
        # 5 mars 24 : completement idiot ?
        #if test:
        #    from InterfaceGUI.Common.politiquesValidation import Validation
        #    validation = Validation(self.node, self.editor)
        #    validation.ajoutDsDictReelEtape()

    def afficheOptionnel(self):
        # N a pas de parentQt. doit donc etre redefini
        if self.editor.maConfiguration.closeOptionnel:
            self.editor.fermeOptionnel()
        liste, liste_rouge = self.ajouteMCOptionnelDesBlocs()
        # print "dans afficheOptionnel", self.monOptionnel
        # dans le cas ou l insertion n a pas eu leiu (souci d ordre par exemple)
        # if self.monOptionnel == None : return
        self.monOptionnel.parentCommande = self
        self.monOptionnel.titre(self.obj.nom)
        self.monGroupe = self.monOptionnel.afficheOptionnel(liste, liste_rouge, self)

    def focusInEvent(self, event):
        # print "je mets a jour dans focusInEvent de monWidget Commande "
        self.afficheOptionnel()

    def reaffiche(self, nodeAVoir=None):
        # Attention delicat. 
        self.avantH = ( self.editor.fenetreCentraleAffichee.scrollAreaCommandes.horizontalScrollBar().sliderPosition())
        self.avantV = ( self.editor.fenetreCentraleAffichee.scrollAreaCommandes.verticalScrollBar().sliderPosition())
        self.inhibeExpand = True

        # Attention : lorsqu'on reconstruit l arbre au milieu par une fonction siValide (exemple dans UQ)
        # alors self.node.item.node est different de self.node
        # il faut regarder si la Widget utililse self.node a d autres endroits
        self.node.item.node.affichePanneau()
        if nodeAVoir != None and nodeAVoir != 0:
            fenetre = nodeAVoir.fenetre
            if fenetre == None:
                newNode = nodeAVoir.treeParent.chercheNoeudCorrespondant( nodeAVoir.item.object) 
                fenetre = newNode.fenetre
            if fenetre != None and fenetre.isVisible():
                self.inhibeExpand = False
                return
            if fenetre != None:
                #print (fenetre)
                self.rendVisible(fenetre)
            else:
                self.recentre()
        else:
            self.recentre()
        self.inhibeExpand = False

    def recentre(self):
        QApplication.processEvents()
        s = self.editor.fenetreCentraleAffichee.scrollAreaCommandes
        s.horizontalScrollBar().setSliderPosition(self.avantH)
        s.verticalScrollBar().setSliderPosition(self.avantV)

    def rendVisible(self, fenetre):
        #print ('je passe dans rendVisible')
        QApplication.processEvents()
        #fenetre.setFocus(7)
        self.editor.fenetreCentraleAffichee.scrollAreaCommandes.ensureWidgetVisible(fenetre)

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
        nomIcone = self.node.item.getIconName()
        if nomIcone == "ast-yellow-square":
            icon = QIcon(self.repIcon + "/ast-yel-ball.png")
        if nomIcone == "ast-red-square":
            self.LENom.setDisabled(True)

        self.LENom.setDisabled(False)
        self.RBValide.setIcon(icon)

    def propageChange(self, typeChange, donneLeFocus):
        aReecrire = self.propageChangeEnfant(self.node.item.object, typeChange)
        if aReecrire:
            self.node.affichePanneau()
        if hasattr(donneLeFocus.node.fenetre, "selectionneDernier"):
            QApplication.processEvents()
            self.editor.fenetreCentraleAffichee.scrollAreaCommandes.ensureWidgetVisible(
                donneLeFocus.node.fenetre
            )
            donneLeFocus.node.fenetre.selectionneDernier()

    def propageChangeEnfant(self, mc, typeChange):
        for enfant in mc.mcListe:
            if enfant.nature == "MCSIMP":
                if enfant.waitUserAssd():
                    if enfant.definition.type[0] == typeChange:
                        return True
            else:
                if enfant.nature == "MCList":
                    enfant = enfant[0]
                if self.propageChangeEnfant(enfant, typeChange):
                    return True
        return False
