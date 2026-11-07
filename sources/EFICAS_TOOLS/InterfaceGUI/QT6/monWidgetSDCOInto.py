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
from UiQT6.desWidgetSDCOInto import Ui_WidgetSDCOInto
from InterfaceGUI.QT6.traiteSaisie import SaisieSDCO
from InterfaceGUI.Common.politiquesValidation import PolitiqueUnique


class MonWidgetSDCOInto(Ui_WidgetSDCOInto, Feuille, SaisieSDCO):
    def __init__(self, node, monSimpDef, nom, objSimp, parentQt, commande):
        # print "MonWidgetSDCOInto init"
        Feuille.__init__(self, node, monSimpDef, nom, objSimp, parentQt, commande)
        self.politique = PolitiqueUnique(self.node, self.editor)
        self.parentQt.commandesLayout.insertWidget(-1, self)
        self.maCommande.listeAffichageWidget.append(self.LESDCO)
        self.AAficher = self.LESDCO
        self.initLBSDCO()

        self.LESDCO.returnPressed.connect(self.LESDCOReturnPressed)
        self.LBSDCO.itemDoubleClicked.connect(self.LBSDCODoubleClicked)

    def LESDCOReturnPressed(self):
        self.LBSDCO.clearSelection()
        SaisieSDCO.LESDCOReturnPressed(self)

    def initLBSDCO(self):
        listeNomsSDCO = self.node.item.getSdAvantDuBonType()
        for aSDCO in listeNomsSDCO:
            self.LBSDCO.insertItem(1, aSDCO)
        valeur = self.node.item.getValeur()
        if valeur != "" and valeur != None:
            self.LESDCO.setText(str(valeur.nom))

    def LBSDCODoubleClicked(self):
        """
        Teste si la valeur fournie par l'utilisateur est une valeur permise :
         - si oui, l'enregistre
         - si non, restaure l'ancienne valeur
        """
        nomConcept = str(self.LBSDCO.currentItem().text())
        self.LESDCO.clear()
        self.editor.initModif()
        anc_val = self.node.item.getValeur()
        test_CO = self.node.item.isCO(anc_val)

        valeur, validite = self.node.item.evalValeur(nomConcept)
        test = self.node.item.setValeur(valeur)
        if not test:
            commentaire = tr("impossible d'evaluer : ") + valeur
        elif validite:
            commentaire = tr("Valeur du mot-clef enregistree")
            if test_CO:
                # il faut egalement propager la destruction de l'ancien concept
                self.node.item.deleteValeurCo(valeur=anc_val)
                self.node.item.object.etape.getType_produit(force=1)
                self.node.item.object.etape.parent.resetContext()
                self.LESDCO.setText(nomConcept)
        else:
            commentaire = self.node.item.getCr()
            self.reset_old_valeur(anc_val, mess=mess)
            self.editor.afficheMessageQt(commentaire, Qt.GlobalColor.red)
        self.Commentaire.setText(tr(commentaire))
