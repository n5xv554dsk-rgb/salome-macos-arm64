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
    Ce module contient le plugin generateur d une liste des GroupNo et GroupMA
"""
import traceback
import types, re

from Accas.IO.writer.writer_python import PythonGenerator


def entryPoint():
    """
    Retourne les informations necessaires pour le chargeur de plugins

    Ces informations sont retournees dans un dictionnaire
    """
    return {
        # Le nom du plugin
        "name": "GroupMA",
        # La factory pour creer une instance du plugin
        "factory": GroupMAGenerator,
    }


class GroupMAGenerator(PythonGenerator):
    """
    Ce generateur parcourt un objet de type JDC et produit
    un texte au format eficas et
    un texte au format homard

    """

    # Les extensions de fichier preconisees
    extensions = (".comm",)

    def __init__(self):
        PythonGenerator.__init__(self)
        self.listeMA = []
        self.listeNO = []

    def gener(self, obj, format="brut", config=None):
        self.liste = []
        self.text = PythonGenerator.gener(self, obj, "brut", config=None)
        return self.listeMA, self.listeNO

    def generMCSIMP(self, obj):
        if "grma" in repr(obj.definition.type):
            if not type(obj.valeur) in (list, tuple):
                aTraiter = (obj.valeur,)
            else:
                aTraiter = obj.valeur
            for group in aTraiter:
                if group not in self.listeMA:
                    self.listeMA.append(group)
        if "grno" in repr(obj.definition.type):
            if not type(obj.valeur) in (list, tuple):
                aTraiter = (obj.valeur,)
            else:
                aTraiter = obj.valeur
            for group in aTraiter:
                if group not in self.listeNO:
                    self.listeNO.append(group)
        s = PythonGenerator.generMCSIMP(self, obj)
        return s
