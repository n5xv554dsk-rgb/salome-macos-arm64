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
   Ce module contient la classe 3Dpilote qui va creer les ordres
   de pilotage de l idl PAL pour un element de structure
"""
from __future__ import absolute_import
from __future__ import print_function
try :
    from builtins import object
except :
    pass
import generator
from Accas.extensions.eficas_translation import tr

class TroisDPilote(object):

    def __init__(self,node,appliEficas):
        self.node=node
        self.appliEficas=appliEficas

    def envoievisu(self):
        """
        """
        format="vers3DSalome"
        if format in generator.plugins :
            # Le generateur existe on l'utilise
            g=generator.plugins[format]()
            g.initJdc(self.node.getJdc())
            texte=g.gener(self.node)
        else:
            print ("Le generateur n'a pas ete trouve")
            print ("Erreur ! Erreur!")
            return ""
        from Accas.extensions.param2 import originalMath
        originalMath.toOriginal()
        self.appliEficas.envoievisu(texte)
        originalMath.toSurcharge()
