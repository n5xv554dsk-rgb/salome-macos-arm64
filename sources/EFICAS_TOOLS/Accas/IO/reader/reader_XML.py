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
from Accas.extensions.eficas_translation import tr

# import traceback
# traceback.print_stack()

from Accas.processing import P_CR
from Accas.IO.reader.reader_UQPython import pythonUQParser


def entryPoint():
    """
    Return a dictionary containing the description needed to load the plugin
    """
    return {"name": "xml", "factory": XMLparser}


class XMLparser:
    """
    This converter works like Pythonparser, except that it reads XML file
    """

    def __init__(self, cr=None):
        # print("dans XML convert")
        self.text = ""
        if cr:
            self.cr = cr
        else:
            self.cr = P_CR.CR(
                debut="CR convertisseur format XML", fin="fin CR format XML"
            )

    def readfile(self, filename):
        self.filename = filename
        try:
            with open(filename) as fd:
                self.text = fd.read()
        except:
            self.cr.exception(tr("Impossible d'ouvrir le fichier %s", str(filename)))
            self.cr.fatal(tr("Impossible d'ouvrir le fichier %s", str(filename)))
            return

    def convert(self, outformat, appliEficas=None):
        # ici on ne fait rien
        # on le fera a la creation du JDC
        try:
            return self.text
        except Exception as e:
            # Erreur lors de la conversion
            l = traceback.format_exception(
                sys.exc_info()[0], sys.exc_info()[1], sys.exc_info()[2]
            )
            self.cr.exception(
                tr("Impossible de convertir le fichier XML\n %s", "".join(l))
            )
            return ""
