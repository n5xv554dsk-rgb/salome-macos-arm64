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
from ast import NodeVisitor

debug = 0


class MatchFinder(NodeVisitor):
    """Visiteur de base : gestion des matches"""

    def reset(self, line):
        self.matches = []
        self._matches = []
        self.words = re.split("(\w+)", line)  # every other one is a non word
        self.positions = []
        i = 0
        for word in self.words:
            self.positions.append(i)
            i += len(word)
        self.index = 0
        if debug:
            print("fin reset", self.words)

    def popWordsUpTo(self, word):
        if word == "*":
            return  # won't be able to find this
        posInWords = self.words.index(word)
        idx = self.positions[posInWords]
        self.words = self.words[posInWords + 1 :]
        self.positions = self.positions[posInWords + 1 :]

    def appendMatch(self, name):
        idx = self.getNextIndexOfWord(name)
        self._matches.append((idx, name))

    def getNextIndexOfWord(self, name):
        return self.positions[self.words.index(name)]


class KeywordFinder(MatchFinder):
    """Visiteur pour les keywords d'une commande"""

    def visit_keyword(self, node):
        if debug:
            print(" visit_keyword", node.arg)
        idx = self.getNextIndexOfWord(node.arg)
        self.popWordsUpTo(node.arg)
        prevmatches = self._matches
        self._matches = []
        # for child in node.getChildNodes():
        #    self.visit(child)
        self.generic_visit(node)
        prevmatches.append((idx, node.arg, self._matches))
        self._matches = prevmatches
        # on ne garde que les matches du niveau Keyword le plus haut
        self.matches = self._matches

    def visit_Tuple(self, node):
        matchlist = []
        # Pour eviter les tuples et listes ordinaires,
        if not hasattr(node, "getChildNodes"):
            return
        print("*********************************************************************")
        print("_____________ visit_Tuple", node)
        for child in node.getChildNodes():
            self._matches = []
            self.visit(child)
            if self._matches:
                # Pour eviter les tuples et listes ordinaires,
                # on ne garde que les visites fructueuses
                matchlist.append(self._matches)
        self._matches = matchlist
        # self.generic_visit(node)

    visit_List = visit_Tuple

    def visit_Name(self, node):
        if debug:
            print("visit_Name", node.id)
        self.popWordsUpTo(node.id)
        self.generic_visit(node)

    def visit_AssName(self, node):
        if debug:
            print("visit_AssName", node.id)
        self.popWordsUpTo(node.id)
        self.generic_visit(node)
