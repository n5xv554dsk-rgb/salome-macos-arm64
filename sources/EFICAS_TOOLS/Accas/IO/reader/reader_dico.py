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

from Accas.IO.reader.reader_python import Pythonparser
from Accas.processing import P_CR


def entryPoint():
    """
    Return a dictionary containing the description needed to load the plugin
    """
    return {"name": "dico", "factory": Dicoparser}


class Dicoparser(Pythonparser):
    """
    This converter initializes model variable from a python dictionnary
    """

    def __init__(self, cr=None):
        # Si l'objet compte-rendu n'est pas fourni, on utilise le
        # compte-rendu standard
        self.text = ""
        self.textePy = ""
        if cr:
            self.cr = cr
        else:
            self.cr = P_CR.CR(
                debut="CR convertisseur format dico", fin="fin CR format dico"
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

    def convert(self, outformat, appli=None):
        monTexteDico = {}
        exec(self.text, globals(), monTexteDico)
        if len(monTexteDico.keys()) != 1:
            self.cr.exception(tr("Impossible de traiter le fichier %s", str(filename)))
            self.cr.fatal(tr("Impossible de traiter le fichier %s", str(filename)))
            return
        self.textePy = ""
        monDico = monTexteDico[monTexteDico.keys()[0]]
        for commande in monDico:
            valeurs = monDico[commande]
            if valeurs.has_key("NomDeLaSdCommande"):
                # cas d un oper
                self.textePy += valeurs["NomDeLaSdCommande"] + " = " + commande + "("
                del valeurs["NomDeLaSdCommande"]
            else:
                self.textePy += commande + "("
            for mot in valeurs:
                if isinstance(valeurs[mot], dict):
                    self.traiteMCFact(mot, valeurs[mot])
                else:
                    self.textePy += mot + " = " + str(valeurs[mot]) + ","
            self.textePy += ");\n"  # fin de la commande
        return self.textePy

    def traiteMCFact(self, mot, valeurs):
        self.textePy += mot + "=_F("
        for mot in valeurs:
            if isinstance(valeurs[mot], dict):
                self.traiteMCFact(mot, valeurs[mot])
            else:
                self.textePy += mot + " = " + str(valeurs[mot]) + ","
        self.textePy += "),"
