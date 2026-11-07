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
"""
   Ce module contient la classe mixin qui porte les methodes
   pour traiter les niveaux au sein d'un JDC
"""

from builtins import object
from . import etape_niveau


class JDC(object):
    def __init__(self):
        self.dict_niveaux = {}
        self.buildNiveaux()

    def buildNiveaux(self):
        for niveau in self.definition.lNiveaux:
            etape_niv = etape_niveau.ETAPE_NIVEAU(niveau, self)
            self.etapes_niveaux.append(etape_niv)
            self.dict_niveaux[niveau.nom] = etape_niv
            self.dict_niveaux.update(etape_niv.dict_niveaux)
