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
import re
import os

from PyQt6.QtWidgets import QToolButton, QToolTip
from Accas.extensions.eficas_translation import tr

class MonBoutonValide(QToolButton):
    def __init__(self, parent):
        QToolButton.__init__(self, parent)
        while not (hasattr(parent, "node")):
            parent = parent.parent()
        self.parent = parent

    def mouseDoubleClickEvent(self, event):
        # print "dans mouseDoubleClickEvent"
        strAide = self.parent.node.item.object.getFr()
        if hasattr(self.parent.node.item.object.definition, "defaut"):
            strAide += "\ndefaut : \n" + str(
                self.parent.node.item.object.definition.defaut
            )
        strRapport = str(self.parent.node.item.object.report())
        self.parent.editor._viewText(strAide + "\n" + strRapport, "JDC_RAPPORT")

    def mousePressEvent(self, event):
        # print "dans mousePressEvent"
        if self.parent.node.item.object.isValid():
            myToolTip = tr("objet valide")
            if self.parent.editor.maConfiguration.differencieSiDefaut:
                if hasattr(self.parent.node.item.object.definition, "defaut"):
                    if (
                        self.parent.node.item.object.valeur
                        != self.parent.node.item.object.definition.defaut
                    ):
                        myToolTip += "\ndefaut : \n" + str(
                            self.parent.node.item.object.definition.defaut
                        )

            QToolTip.showText(event.globalPos(), myToolTip)
        else:
            t = ""
            texte = self.parent.node.item.object.report().report()
            deb = 1
            for l in texte.split("\n")[2:-2]:
                if re.match("^[\t !]*$", l):
                    continue
                if re.match("^ *Fin Mot-cl", l):
                    continue
                if re.match("^ *D?but Mot-cl", l):
                    continue
                if re.match("^ *Mot-cl", l):
                    continue
                l = l.replace("!", "")
                if deb:
                    deb = 0
                    t = l
                else:
                    t = t + "\n" + l
            myToolTip = tr(t)
        QToolTip.showText(event.globalPos(), myToolTip)
