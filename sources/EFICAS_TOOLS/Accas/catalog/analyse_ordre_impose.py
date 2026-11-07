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
import re, os

from Accas.extensions.eficas_translation import tr


class catalogueInitial(object):
    def __init__(self, fichier):
        self.listeCommandes = []
        self.lignes = []
        self.fichier = fichier
        self.ouvrirFichier()
        self.constrListTxtCmd()

    def ouvrirFichier(self):
        try:
            with open(self.fichier) as fd:
                self.lignes = fd.readlines()
        except:
            print(tr("Impossible d'ouvrir le fichier : %s", str(self.fichier)))

    def constrListTxtCmd(self):
        pattern = "^# Ordre Catalogue "
        for i in self.lignes:
            if re.search(pattern, i):
                i = i.replace("# Ordre Catalogue ", "")
                i = i.replace("\n", "")
                self.listeCommandes.append(i)


def analyseCatalogue(nomCata):
    cata = catalogueInitial(nomCata)
    return cata.listeCommandes


if __name__ == "__main__":
    print ('a faire')
    exit()
    monCata = "/local/noyret/Install_Eficas/EficasQT4/Openturns_StudyOpenTURNS_Cata_Study_V4.py"
    analyseCatalogue(monCata)
