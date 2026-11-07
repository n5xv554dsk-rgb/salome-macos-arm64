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


def indexToCoordinates(src, index):
    """return le numero de la colonne (x) et le numero de la ligne (y) dans src"""
    y = src[:index].count("\n")
    startOfLineIdx = src.rfind("\n", 0, index) + 1
    x = index - startOfLineIdx
    return x, y


def lineToDict(line):
    """Transforme une ligne (string) en un dictionnaire de mots
    reperes par le numero de la colonne"""

    words = re.split("(\w+)", line)
    h = {}
    i = 0
    for word in words:
        h[i] = word
        i += len(word)
    return h


def dictToLine(d):
    """Transformation inverse: a partir d'un dictionnaire retourne une ligne"""
    cols = d
    cols.sort()
    return "".join([d[colno] for colno in cols])
