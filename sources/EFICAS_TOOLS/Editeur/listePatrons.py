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
from builtins import object
import os
import re

# To DO, ajuster les sous-menu

sous_menus = {}


class listePatrons(object):
    def __init__(self, code="ASTER"):
        rep = os.path.dirname(os.path.abspath(__file__))
        self.repPatrons = rep + "/Patrons/" + code
        self.sous_menu = {}
        if code in sous_menus:
            self.sous_menu = sous_menus[code]
        self.code = code
        self.liste = {}
        self.traiteListe()

    def traiteListe(self):
        if not (self.code in sous_menus):
            return
        if not (os.path.exists(self.repPatrons)):
            return
        for file in os.listdir(self.repPatrons):
            for i in range(len(self.sous_menu)):
                clef = list(self.sous_menu[i].keys())[0]
                chaine = self.sous_menu[i][clef]
                if re.search(chaine, file):
                    if clef in self.liste:
                        self.liste[clef].append(file)
                    else:
                        self.liste[clef] = [file]
                    break
