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
import re, string

debug = 0

escapedQuotesRE = re.compile(r"(\\\\|\\\"|\\\')")
stringsAndCommentsRE = re.compile(
    "(\"\"\".*?\"\"\"|'''.*?'''|\"[^\"]*\"|'[^']*'|#.*?\n)", re.DOTALL
)

allchars = bytes.maketrans(b"", b"")
allcharsExceptNewline = (
        allchars[: allchars.index(b"\n")] + allchars[allchars.index(b"\n") + 1 :]
    )
allcharsExceptNewlineTranstable = bytes.maketrans(
        allcharsExceptNewline, b"*" * len(allcharsExceptNewline)
    )


# ------------------------------
def maskStringsAndComments(src):
    # ------------------------------
    """Remplace tous les caracteres dans commentaires et strings par des *"""

    src = escapedQuotesRE.sub("**", src)
    allstrings = stringsAndCommentsRE.split(src)
    # every odd element is a string or comment
    for i in range(1, len(allstrings), 2):
        if allstrings[i].startswith("'''") or allstrings[i].startswith('"""'):
            allstrings[i] = (
                allstrings[i][:3]
                + allstrings[i][3:-3].translate(allcharsExceptNewlineTranstable)
                + allstrings[i][-3:]
            )
        else:
            allstrings[i] = (
                allstrings[i][0]
                + allstrings[i][1:-1].translate(allcharsExceptNewlineTranstable)
                + allstrings[i][-1]
            )

    return "".join(allstrings)


# un nombre queconque de blancs,un nom,des blancs
pattern_oper = re.compile(r"^\s*(.*?=\s*)?([a-zA-Z_]\w*)(\s*)(\()(.*)", re.DOTALL)
pattern_proc = re.compile(r"^\s*([a-zA-Z_]\w*)(\s*)(\()(.*)", re.DOTALL)

implicitContinuationChars = (("(", ")"), ("[", "]"), ("{", "}"))
linecontinueRE = re.compile(r"\\\s*(#.*)?$")
emptyHangingBraces = [0, 0, 0, 0, 0]


# --------------------------------------
class UnbalancedBracesException:
    pass


# --------------------------------------


# -----------
class Node:
    # -----------
    def __init__(self):
        self.childNodes = []

    def addChild(self, node):
        self.childNodes.append(node)


# -------------------
class FactNode(Node):
    # -------------------
    pass


# -------------------
class JDCNode(Node):
    # -------------------
    def __init__(self, src):
        Node.__init__(self)
        self.src = src


# -------------------
class Command(Node):
    # -------------------
    def __init__(self, name, lineno, colno, firstparen):
        Node.__init__(self)
        self.name = name
        self.lineno = lineno
        self.colno = colno
        self.firstparen = firstparen


# -------------------
class Keyword(Node):
    # -------------------
    def __init__(self, name, lineno, colno, endline, endcol):
        Node.__init__(self)
        self.name = name
        self.lineno = lineno
        self.colno = colno
        self.endline = endline
        self.endcol = endcol

    def getText(self, jdc):
        if self.endline > self.lineno:
            debut = jdc.getLines()[self.lineno - 1][self.colno :]
            fin = jdc.getLines()[self.endline - 1][: self.endcol]
            texte = debut
            lignecourante = self.lineno
            while lignecourante < self.endline - 1:
                texte = texte + jdc.getLines()[lignecourante]
                lignecourante = lignecourante + 1
            if chaineBlanche(fin) == 0:
                texte = texte + fin
            if texte[-1] == "\n":
                texte = texte[0:-1]
        else:
            texte = jdc.getLines()[self.lineno - 1][self.colno : self.endcol]
        return texte


# -------------------------
def chaineBlanche(texte):
    # -------------------------
    # retourne 1 si la chaine est composee de " "
    # retourne 0 sinon
    bool = 1
    for i in range(len(texte)):
        if texte[i] != " ":
            bool = 0
    return bool


# -------------------
def printNode(node):
    # -------------------
    if hasattr(node, "name"):
        print(node.name)
    else:
        print("pas de nom pour:", node)
    for c in node.childNodes:
        printNode(c)


# ------------------------
def parser(src, atraiter):
    # ------------------------
    """Parse le texte src et retourne un arbre syntaxique (root).

    Cet arbre syntaxique a comme noeuds (childNodes) les commandes a traiter (liste atraiter)
    """
    lines = src.splitlines(1)
    maskedSrc = maskStringsAndComments(src)
    maskedLines = maskedSrc.splitlines(1)

    root = JDCNode(src)

    # (a) dans un premier temps on extrait les commandes et on les insere
    #     dans un arbre (root)  les noeuds fils sont stockes dans
    #     root.childNodes (liste)
    lineno = 0
    for line in maskedLines:
        lineno = lineno + 1
        if debug:
            print("line", lineno, ":", line)
        m = pattern_proc.match(line)
        if m and (m.group(1) in atraiter):
            if debug:
                print(m.start(3), m.end(3), m.start(4))
            root.addChild(Command(m.group(1), lineno, m.start(1), m.end(3)))
        else:
            m = pattern_oper.match(line)
            if m and (m.group(2) in atraiter):
                root.addChild(Command(m.group(2), lineno, m.start(2), m.end(4)))

    # (b) dans un deuxieme temps , on recupere le texte complet de la commande
    #    jusqu'a la  derniere parenthese fermante

    # iterateur sur les lignes physiques masquees
    iterlines = iter(maskedLines)

    linenum = 0
    for c in root.childNodes:
        lineno = c.lineno
        colno = c.colno  # debut de la commande
        while linenum < lineno:
            line = iterlines.__next__()
            linenum = linenum + 1
            if linenum != lineno:
                if debug:
                    print("line %s:" % linenum, line)
        tmp = []
        hangingBraces = list(emptyHangingBraces)
        hangingComments = 0
        while 1:
            # update hanging braces
            for i in range(len(implicitContinuationChars)):
                contchar = implicitContinuationChars[i]
                numHanging = hangingBraces[i]

                hangingBraces[i] = (
                    numHanging + line.count(contchar[0]) - line.count(contchar[1])
                )

            hangingComments ^= line.count('"""') % 2
            hangingComments ^= line.count("'''") % 2

            if hangingBraces[0] < 0 or hangingBraces[1] < 0 or hangingBraces[2] < 0:
                raise UnbalancedBracesException()

            if linecontinueRE.search(line):
                tmp.append(lines[linenum - 1])
            elif hangingBraces != emptyHangingBraces:
                tmp.append(lines[linenum - 1])
            elif hangingComments:
                tmp.append(lines[linenum - 1])
            else:
                tmp.append(lines[linenum - 1])
                src = "".join(tmp)
                c.src = src
                c.endline = linenum
                decal = len(line) - line.rindex(")")
                c.lastParen = len(src) - decal
                if debug:
                    print("logical line %s %s:" % (c.lineno, c.endline), src)
                break
            line = iterlines.__next__()
            linenum = linenum + 1

    return root


# -----------------
def lastParen(src):
    # -----------------
    """Retourne la position de la derniere parenthese fermante dans src a partir du debut de la string

    La string doit contenir la premiere parenthese ouvrante
    """

    src = maskStringsAndComments(src)
    level = 0
    i, n = 0, len(src)
    while i < n:
        ch = src[i]
        i = i + 1
        if ch in ("(", "["):
            level = level + 1
        if ch in (")", "]"):
            if level == 0:
                raise UnbalancedBracesException()
            level = level - 1
            if level == 0:
                # derniere parenthese fermante
                return i


# -------------------
def lastParen2(src):
    # -------------------
    """Retourne la position de la derniere parenthese fermante dans src a partir du debut de la string

    La string ne contient pas la premiere parenthese ouvrante
    """
    src = maskStringsAndComments(src)
    level = 1
    i, n = 0, len(src)
    while i < n:
        ch = src[i]
        i = i + 1
        if ch in ("(", "["):
            level = level + 1
        if ch in (")", "]"):
            if level == 0:
                raise UnbalancedBracesException()
            level = level - 1
            if level == 0:
                # derniere parenthese fermante
                return i
