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
    Ce module contient le plugin convertisseur de fichier
    au format python pour EFICAS.

    Un plugin convertisseur doit fournir deux attributs de classe :
    extensions et formats et deux methodes : readfile,convert.

    L'attribut de classe extensions est une liste d'extensions
    de fichiers preconisees pour ce type de format. Cette information
    est seulement indicative.

    L'attribut de classe formats est une liste de formats de sortie
    supportes par le convertisseur. Les formats possibles sont :
    eval, dict ou exec.
    Le format eval est un texte source Python qui peut etre evalue. Le
    resultat de l'evaluation est un objet Python quelconque.
    Le format dict est un dictionnaire Python.
    Le format exec est un texte source Python qui peut etre execute.

    La methode readfile a pour fonction de lire un fichier dont le
    nom est passe en argument de la fonction.
       - convertisseur.readfile(nom_fichier)

    La methode convert a pour fonction de convertir le fichier
    prealablement lu dans un objet du format passe en argument.
       - objet=convertisseur.convert(outformat)

    Ce convertisseur supporte le format de sortie dict

"""
from __future__ import absolute_import

try:
    from builtins import str
    from builtins import object
except:
    pass

import sys, traceback

from Accas.processing import P_CR
from Accas.extensions.eficas_translation import tr
from Accas.extensions.eficas_exception import EficasException


def entryPoint():
    """
    Retourne les informations necessaires pour le chargeur de plugins
    Ces informations sont retournees dans un dictionnaire
    """
    return {
        # Le nom du plugin
        "name": "pyth",
        # La factory pour creer une instance du plugin
        "factory": Pythparser,
    }


class Pythparser(object):
    """
    Ce convertisseur lit un fichier au format pyth avec la
    methode readfile : convertisseur.readfile(nom_fichier)
    et retourne le texte au format outformat avec la
    methode convertisseur.convert(outformat)

    Ses caracteristiques principales sont exposees dans 2 attributs
    de classe :
      - extensions : qui donne une liste d'extensions de fichier preconisees
      - formats : qui donne une liste de formats de sortie supportes
    """

    # Les extensions de fichier preconisees
    extensions = (".pyth",)
    # Les formats de sortie supportes (eval dict ou exec)
    formats = ("dict",)

    def __init__(self, cr=None):
        # Si l'objet compte-rendu n'est pas fourni, on utilise le compte-rendu standard
        if cr:
            self.cr = cr
        else:
            self.cr = P_CR.CR(
                debut="CR convertisseur format pyth", fin="fin CR format pyth"
            )
        self.g = {}

    def readfile(self, filename):
        self.filename = filename
        try:
            with open(filename) as fd:
                self.text = fd.read()
        except:
            self.cr.fatal(tr("Impossible d'ouvrir le fichier : %s", str(filename)))
            return
        self.g = {}
        try:
            exec(self.text, self.g)
        except EficasException as e:
            l = traceback.format_exception(
                sys.exc_info()[0], sys.exc_info()[1], sys.exc_info()[2]
            )
            s = "".join(l[2:])
            s = s.replace('"<string>"', '"<%s>"' % self.filename)
            self.cr.fatal(tr("Erreur a l'evaluation :\n %s", s))

    def convert(self, outformat, appliEficas=None):
        if outformat == "dict":
            return self.getdict()
        else:
            raise EficasException(tr("Format de sortie : %s, non supporte", outformat))

    def getdict(self):
        d = {}
        for k, v in list(self.g.items()):
            if k[0] != "_":
                d[k] = v
        return d
