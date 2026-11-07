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

from PyQt5.QtCore import Qt
from .monViewRegles import ViewRegles
from Accas.extensions.eficas_translation import tr


class GereRegles(object):
    def appellebuildLBRegles(self):
        from .browser import JDCTree

        if isinstance(self, JDCTree):
            self.appellebuildLBReglesForJdC()
        else:
            self.appellebuildLBReglesForCommand()
        self.buildLBRegles(self.listeRegles, self.listeNomsEtapes)
        self.afficheRegles()

    def appellebuildLBReglesForCommand(self):
        self.listeRegles = self.item.getRegles()
        self.listeNomsEtapes = self.item.getMcPresents()

    def appellebuildLBReglesForJdC(self):
        self.listeRegles = self.item.getRegles()
        self.listeNomsEtapes = self.item.getLNomsEtapes()

    def buildLBRegles(self, listeRegles, listeNomsEtapes):
        self.liste = []
        if len(listeRegles) > 0:
            for regle in listeRegles:
                texteRegle = regle.getText()
                texteMauvais, test = regle.verif(listeNomsEtapes)
                for ligne in texteRegle.split("\n"):
                    if ligne == "":
                        continue
                    if ligne[0] == "\t":
                        ligne = "     " + ligne[1:]
                    if test:
                        self.liste.append((ligne, Qt.black))
                    else:
                        self.liste.append((ligne, Qt.red))
                self.liste.append(("", Qt.red))
        if self.liste == []:
            self.liste.append(
                ("pas de regle de construction pour ce jeu de commandes", Qt.black)
            )

    def afficheRegles(self):
        titre = "Regles pour " + self.item.nom
        w = ViewRegles(self.editor, self.liste, titre)
        w.exec_()
