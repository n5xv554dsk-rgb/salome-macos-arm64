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
from Accas.accessor import A_FICHIER


class Fichier(A_FICHIER.Fichier):
    """
    This empty class is replaced by the class eficas.SalomeEntry
    (defined in Salome EFICAS module) when Eficas is launched in Salome context.
    It handles the objects that can be selected from Salome object browser.
    """

    def __init__(self, *tup, **args):
        A_FICHIER.FICHIER.__init__(self, *tup, **args)

    # To do --> a travailler pour ajouter tous les types de fichier (existant ou non, avec un chemin relatif pour etre vraiment utilise hors salome
