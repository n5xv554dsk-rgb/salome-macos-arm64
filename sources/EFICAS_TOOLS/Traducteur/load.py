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
import re
from Traducteur import parseur
from Traducteur.mocles import parseKeywords

jdcSet = set()


class JDCTrad:
    """Cet objet conserve toutes les informations relatives a un fichier de commandes .comm"""

    def __init__(self, src, atraiter):
    # ----------------------------------------
        self.atraiter = atraiter
        self.init(src, atraiter)
        commands = self.root.childNodes[:]
        commands.reverse()
        for c in commands:
            jdcSet.add(c.name)

    def init(self, src, atraiter):
    # ---------------------------
        # construction de self.lines
        self.root = parseur.parser(src, atraiter)
        self.lines = src.splitlines(1)

    def parseKeywords(self):
    # -----------------------
        # construction de fils (cf mocles.py)
        parseKeywords(self.root)

    def reset(self, src):
    # -----------------------
        # reconstruction
        self.init(src, self.atraiter)
        self.parseKeywords()

    def getSource(self):
    # -----------------------
        # retourne la concatenation de
        # toutes les lignes
        return "".join(self.getLines())

    def getLine(self, linenum):
    # -----------------------
        # retourne la linenumieme ligne
        return self.getLines()[linenum - 1]

    def getLines(self):
    # ----------------------------
        # retourne toutes les lignes
        return self.lines

    def addLine(self, ligne, numero):
    # ----------------------------
        # insere le texte contenu dans ligne
        # dans la liste self.lines au rang numero
        Ldebut = self.lines[0:numero]
        Lmilieu = [
            ligne,
        ]
        Lfin = self.lines[numero:]
        self.lines = Ldebut + Lmilieu + Lfin

    def splitLine(self, numeroLigne, numeroColonne):
    # ----------------------------------------------
        # coupe la ligne numeroLigne en 2 a numeroColonne
        # ajoute des blancs en debut de 2nde Ligne pour
        # aligner
        numeroLigne = numeroLigne - 1
        Ldebut = self.lines[0:numeroLigne]
        if len(self.lines) > numeroLigne:
            Lfin = self.lines[numeroLigne + 1 :]
        else:
            Lfin = []
        Lsplit = self.lines[numeroLigne]
        LigneSplitDebut = Lsplit[0:numeroColonne] + "\n"
        LigneSplitFin = " " * numeroColonne + Lsplit[numeroColonne:]
        Lmilieu = [LigneSplitDebut, LigneSplitFin]

        self.lines = Ldebut + Lmilieu + Lfin

    def joinLineandNext(self, numeroLigne):
    # --------------------------------------
        # concatene les lignes numeroLigne et numeroLigne +1
        # enleve les blancs de debut de la ligne (numeroLigne +1)
        Ldebut = self.lines[0 : numeroLigne - 1]
        if len(self.lines) > numeroLigne:
            Lfin = self.lines[numeroLigne + 1 :]
        else:
            Lfin = []

        ligneMilieuDeb = self.lines[numeroLigne - 1]
        ligneMilieuDeb = ligneMilieuDeb[0:-1]
        ligneMilieuFin = self.lines[numeroLigne]
        for i in range(len(ligneMilieuFin)):
            if ligneMilieuFin[i] != " ":
                ligneMilieuFin = ligneMilieuFin[i:]
                break
        Lmilieu = [
            ligneMilieuDeb + ligneMilieuFin,
        ]

        self.lines = Ldebut + Lmilieu + Lfin

    def supLignes(self, debut, fin):
    # ------------------------
        Ldebut = self.lines[0 : debut - 1]
        Lfin = self.lines[fin:]
        self.lines = Ldebut + Lfin

    def remplaceLine(self, numeroLigne, nouveauTexte):
    # ------------------------------------------------
        self.lines[numeroLigne] = nouveauTexte


def getJDC(filename, atraiter):
    # ----------------------------
    # lit le JDC
    f = open(filename)
    src = f.read()
    f.close()
    jdc = JDCTrad(src, atraiter)
    return jdc


def getJDCFromTexte(texte, atraiter):
    # -----------------------------------
    # lit le JDC
    jdc = JDCTrad(texte, atraiter)
    return jdc
