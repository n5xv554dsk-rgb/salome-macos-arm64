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
    Ce module sert pour charger les parametres de configuration d'EFICAS
"""
# Modules Python

import os, sys, types, re
from Accas.extensions.eficas_translation import tr


class ModificationGenerator(object):
    def generTexteModif(self, obj):
        texteModification = ""
        for t in list(obj.editor.dicoNouveauxMC.keys()):
            # 'ajoutDefinitionMC',etape,listeAvant,nomDuMC,typ,args
            (
                fonction,
                Etape,
                Genea,
                nomSIMP,
                typeSIMP,
                arguments,
            ) = obj.editor.dicoNouveauxMC[t]
            texteModification += (
                "MODIFICATION_CATALOGUE(Fonction  = '" + str(fonction) + "',\n"
            )
            texteModification += (
                "                       Etape     = '" + str(Etape) + "',\n"
            )
            texteModification += (
                "                       Genea     = " + str(Genea) + ",\n"
            )
            texteModification += (
                "                       NomSIMP   = '" + str(nomSIMP) + "',\n"
            )
            texteModification += (
                "                       TypeSIMP  = '" + str(typeSIMP) + "',\n"
            )
            texteModification += (
                "                       PhraseArguments = "
                + '"'
                + str(arguments)
                + '"'
                + ",);\n"
            )

        return texteModification
