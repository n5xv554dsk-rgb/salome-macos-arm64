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

# import compiler
import ast
import types
from Traducteur.parseur import (
    Keyword,
    FactNode,
    lastParen,
    lastParen2,
    maskStringsAndComments,
)
from Traducteur.visiteur import KeywordFinder, NodeVisitor
from Traducteur.utils import indexToCoordinates, lineToDict, dictToLine

debug = 0


# ------------------------
def parseFact(match, c, kw):
    # ------------------------
    submatch = match[2]
    lastpar = match[0] + lastParen(c.src[match[0] :])
    # if type(submatch[0][0]) ==types.IntType:
    if isinstance(submatch[0][0], int):
        # mot cle facteur isole
        no = FactNode()
        kw.addChild(no)
        for ii in range(len(submatch) - 1):
            e = submatch[ii]
            x, y = indexToCoordinates(c.src, e[0])
            lineno = y + c.lineno
            colno = x
            x, y = indexToCoordinates(c.src, submatch[ii + 1][0])
            endline = y + c.lineno
            endcol = x
            no.addChild(Keyword(e[1], lineno, colno, endline, endcol))
        # last one
        e = submatch[-1]
        x, y = indexToCoordinates(c.src, e[0])
        lineno = y + c.lineno
        colno = x
        x, y = indexToCoordinates(c.src, lastpar - 1)
        endline = y + c.lineno
        endcol = x
        no.addChild(Keyword(e[1], lineno, colno, endline, endcol))
    else:
        # mot cle facteur multiple
        ii = 0
        for l in submatch:
            lastpar = l[0][0] + lastParen2(c.src[l[0][0] :])
            ii = ii + 1
            no = FactNode()
            kw.addChild(no)
            for j in range(len(l) - 1):
                e = l[j]
                x, y = indexToCoordinates(c.src, e[0])
                lineno = y + c.lineno
                colno = x
                x, y = indexToCoordinates(c.src, l[j + 1][0])
                endline = y + c.lineno
                endcol = x
                no.addChild(Keyword(e[1], lineno, colno, endline, endcol))
            # last one
            e = l[-1]
            x, y = indexToCoordinates(c.src, e[0])
            lineno = y + c.lineno
            colno = x
            x, y = indexToCoordinates(c.src, lastpar - 1)
            endline = y + c.lineno
            endcol = x
            no.addChild(Keyword(e[1], lineno, colno, endline, endcol))


# -----------------------
def parseKeywords(root):
    # -----------------------
    """A partir d'un arbre contenant des commandes, ajoute les noeuds
    fils correspondant aux mocles de la commande
    """
    # traceback.print_stack(limit=5)

    matchFinder = KeywordFinder()

    for c in root.childNodes:
        if debug:
            print("parse -------------- ", c.name)
        maskedsrc = maskStringsAndComments(c.src)
        # on supprime seulement les blancs du debut pour pouvoir compiler
        # meme si la commande est sur plusieurs lignes seul le debut compte
        # ast=compiler.parse(c.src.lstrip())
        # print ast
        monAst = ast.parse(c.src.lstrip())
        if debug:
            print(ast.dump(monAst))
        # Ne pas supprimer les blancs du debut pour avoir les bons numeros de colonne
        matchFinder.reset(maskedsrc)
        matchFinder.visit(monAst)
        if debug:
            print("matchFinder.matches", matchFinder.matches)
        if len(matchFinder.matches) > 1:
            # plusieurs mocles trouves :
            # un mocle commence au debut du keyword (matchFinder.matches[i][0])
            # et finit juste avant le keyword suivant
            # (matchFinder.matches[i+1][0]])
            for i in range(len(matchFinder.matches) - 1):
                if debug:
                    print(
                        "texte:",
                        c.src[
                            matchFinder.matches[i][0] : matchFinder.matches[i + 1][0]
                        ],
                    )
                x, y = indexToCoordinates(c.src, matchFinder.matches[i][0])
                lineno = y + c.lineno
                colno = x
                x, y = indexToCoordinates(c.src, matchFinder.matches[i + 1][0])
                endline = y + c.lineno
                endcol = x
                if debug:
                    print(
                        matchFinder.matches[i][0],
                        matchFinder.matches[i][1],
                        lineno,
                        colno,
                        endline,
                        endcol,
                    )
                kw = Keyword(matchFinder.matches[i][1], lineno, colno, endline, endcol)
                c.addChild(kw)
                submatch = matchFinder.matches[i][2]
                if submatch:
                    parseFact(matchFinder.matches[i], c, kw)

            # dernier mocle :
            #   il commence au debut du dernier keyword
            #   (matchFinder.matches[i+1][0]) et
            #   finit avant la parenthese fermante de la commande (c.lastParen)

            if debug:
                print("texte:", c.src[matchFinder.matches[i + 1][0] : c.lastParen])
            x, y = indexToCoordinates(c.src, matchFinder.matches[i + 1][0])
            lineno = y + c.lineno
            colno = x
            x, y = indexToCoordinates(c.src, c.lastParen)
            endline = y + c.lineno
            endcol = x
            if debug:
                print(
                    matchFinder.matches[i + 1][0],
                    matchFinder.matches[i + 1][1],
                    lineno,
                    colno,
                    endline,
                    endcol,
                )
            kw = Keyword(matchFinder.matches[i + 1][1], lineno, colno, endline, endcol)
            c.addChild(kw)
            submatch = matchFinder.matches[i + 1][2]
            if submatch:
                parseFact(matchFinder.matches[i + 1], c, kw)

        elif len(matchFinder.matches) == 1:
            # un seul mocle trouve :
            # il commence au debut du keyword (matchFinder.matches[0][0]) et
            # finit juste avant la parenthese fermante de la
            # commande (c.lastParen)
            if debug:
                print("texte:", c.src[matchFinder.matches[0][0] : c.lastParen])
            x, y = indexToCoordinates(c.src, matchFinder.matches[0][0])
            lineno = y + c.lineno
            colno = x
            x, y = indexToCoordinates(c.src, c.lastParen)
            endline = y + c.lineno
            endcol = x
            if debug:
                print(
                    matchFinder.matches[0][0],
                    matchFinder.matches[0][1],
                    lineno,
                    colno,
                    endline,
                    endcol,
                )
            kw = Keyword(matchFinder.matches[0][1], lineno, colno, endline, endcol)
            c.addChild(kw)
            submatch = matchFinder.matches[0][2]
            if submatch:
                parseFact(matchFinder.matches[0], c, kw)
        else:
            pass
