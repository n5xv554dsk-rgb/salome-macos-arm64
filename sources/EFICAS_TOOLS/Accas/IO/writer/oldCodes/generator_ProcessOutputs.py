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
"""Ce module contient le plugin generateur de fichier au format  Code_Carmel3D pour EFICAS.
"""

from __future__ import absolute_import
import types,re,os
from Accas.extensions.eficas_translation import tr
from .generator_python import PythonGenerator
from .generator_modification import ModificationGenerator

def entryPoint():
    """
       Retourne les informations necessaires pour le chargeur de plugins
       Ces informations sont retournees dans un dictionnaire
    """
    return {
         # Le nom du plugin
           'name' : 'ProcessOutputs',
         # La factory pour creer une instance du plugin
           'factory' : ProcessOutputsGenerator,
           }


class ProcessOutputsGenerator(PythonGenerator,ModificationGenerator):
    """
       Ce generateur parcourt un objet de type JDC et produit
       un texte au format eficas et
       un texte au format dictionnaire

    """
    # Les extensions de fichier permis?
    extensions=('.comm',)

#----------------------------------------------------------------------------------------
    def gener(self,obj,format='brut',config=None, appliEficas=None):

        # Cette instruction genere le contenu du fichier de commandes (persistance)
        texteModification=self.generTexteModif(obj)
        text=PythonGenerator.gener(self,obj,format)
        self.text=texteModification+text

        return self.text



# si repertoire on change tous les noms de fichier
