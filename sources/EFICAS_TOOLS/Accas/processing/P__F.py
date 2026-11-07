# coding=utf-8
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

from collections import UserDict


class _F(UserDict):

    """
    Cette classe a un comportement semblable à un
    dictionnaire Python et permet de donner
    la valeur d'un mot-clé facteur avec pour les sous
    mots-clés la syntaxe motcle=valeur
    """

    def __init__(self, *pos, **args):
        if len(pos) != 0:
            raise SyntaxError(
                "Valeur invalide pour '_F('. "
                "On attend cette syntaxe : _F(MOTCLE=valeur, ...)"
            )
        self.data = args

    def supprime(self):
        self.data = {}

    def __cmp__(self, dict):
        print("processing _F.py   ________________________ Attention cmp deprecated")
        from past.builtins import cmp

        if type(dict) == type(self.data):
            return cmp(self.data, dict)
        elif hasattr(dict, "data"):
            return cmp(self.data, dict.data)
        else:
            return cmp(self.data, dict)

    def __iter__(self):
        return iter(self.data)

    def copy(self):
        import copy

        c = copy.copy(self)
        c.data = self.data.copy()
        return c
