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
import types


class Fichier:
    def __init__(
        self, filtre="All Files (*)", existence="NonExistant", repertoire=None
    ):
        self.filtre = filtre
        self.existence = existence
        self.repertoire = repertoire

    def __convert__(self, valeur):
        # Attention ne verifie pas grand chose
        if type(valeur) != bytes and type(valeur) != str:
            return None
        return valeur

    def info(self):
        return "Fichier de Type %s et %s" % (self.filtre, self.existence)

        __repr__ = info
        __str__ = info
