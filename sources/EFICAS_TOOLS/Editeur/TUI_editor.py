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

import types, sys, os, re
import subprocess
import traceback

# Modules Eficas

import Accas.IO.reader as reader
import Accas.IO.writer as writer
from uuid import uuid1
from Accas.extensions.eficas_exception import EficasException
from Accas.extensions.eficas_translation import tr

Dictextensions = {"MAP": ".map", "TELEMAC": ".cas"}
debug = False


# ---------------- #
class TUI_Editor():
# ---------------- #
    """
    Editeur de jdc
    """

    # ------------------------#
    def ajoutCommentaire(self):
    # ------------------------#
        print("pas programme sans Ihm")
        print("prevenir la maintenance du besoin")

    # --------------------------------------------------#
    def afficheMessage(self, titre, txt, couleur= 'red'):
    # --------------------------------------------------#
        # methode differenre avec et sans ihm
        if couleur == 'red': print("!!!!!!!!!!!!!!!!!!!!!!!!!!!")
        print(titre)
        print(txt)
        if couleur == 'red': print("!!!!!!!!!!!!!!!!!!!!!!!!!!!")

    # ------------------------------------------------------------------------#
    def _viewText(self, txt, caption="FILE_VIEWER", largeur=1200, hauteur=600):
    # ------------------------------------------------------------------------#
        print("_____________________________")
        print(txt)
        print("_____________________________")


if __name__ == "__main__":
    print("a faire")
