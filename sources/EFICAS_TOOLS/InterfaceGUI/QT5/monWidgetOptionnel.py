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


from PyQt5.QtWidgets import QCheckBox, QWidget
from PyQt5.QtCore import Qt

from Accas.extensions.eficas_translation import tr
from UiQT5.desWidgetOptionnel import Ui_WidgetOptionnel
from InterfaceGUI.QT5.monGroupeOptionnel import MonGroupeOptionnel


# Import des panels
class MonWidgetOptionnel(QWidget, Ui_WidgetOptionnel):
    def __init__(self, parentQt):
        # print ("dans init de monWidgetOptionnel ", parentQt )
        QWidget.__init__(self, None)
        self.setupUi(self)
        self.dicoMCWidgetOptionnel = {}
        self.parentQt = parentQt

    def afficheOptionnel(self, liste, liste_rouge, MC):
        # print ('afficheOptionnel MonWidgetOptionnel',self, liste,MC.node.item.nom)
        self.vireLesAutres(MC)

        if MC.node.item.nom in self.dicoMCWidgetOptionnel:
            # print (MC.node.item.nom)
            self.dicoMCWidgetOptionnel[MC.node.item.nom].close()
            self.dicoMCWidgetOptionnel[MC.node.item.nom].setParent(None)
            self.dicoMCWidgetOptionnel[MC.node.item.nom].deleteLater()
            del self.dicoMCWidgetOptionnel[MC.node.item.nom]
        if liste == []:
            return
        groupe = MonGroupeOptionnel(liste, liste_rouge, self, MC)
        self.groupesOptionnelsLayout.insertWidget(0, groupe)
        self.dicoMCWidgetOptionnel[MC.node.item.nom] = groupe
        return groupe

    def vireLesAutres(self, MC):
        # print( "je passe dans vireLesAutres")
        genea = MC.obj.getGenealogie()
        # print (genea)
        for k in list(self.dicoMCWidgetOptionnel.keys()):
            # print (k)
            # if k not in genea :  print ( k)
            if k not in genea:
                self.dicoMCWidgetOptionnel[k].close()
                del self.dicoMCWidgetOptionnel[k]
        # print( "fin vireLesAutres")

    def vireTous(self):
        for k in list(self.dicoMCWidgetOptionnel.keys()):
            self.dicoMCWidgetOptionnel[k].close()
            del self.dicoMCWidgetOptionnel[k]

    def afficheOptionnelVide(self):
        self.GeneaLabel.setText("")
        for k in list(self.dicoMCWidgetOptionnel.keys()):
            self.dicoMCWidgetOptionnel[k].close()
            del self.dicoMCWidgetOptionnel[k]

    def titre(self, MC):
        if (
            self.parentCommande.node.editor.maConfiguration.closeFrameRechercheCommande
            == True
        ):
            self.frameLabelCommande.close()
            return
        labeltext, fonte, couleur = self.parentCommande.node.item.getLabelText()
        l = tr(labeltext)
        li = []
        while len(l) > 25:
            li.append(l[0:24])
            l = l[24:]
        li.append(l)
        texte = ""
        for l in li:
            texte += l + "\n"
        texte = texte[0:-2]
        self.GeneaLabel.setText(tr("Options pour \n") + texte)
