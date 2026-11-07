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

from builtins import str

import traceback
import types, re, os
from Accas.extensions.eficas_translation import tr
from Accas.IO.writer.writer_python import PythonGenerator


def entryPoint():
    """
    Retourne les informations necessaires pour le chargeur de plugins
    Ces informations sont retournees dans un dictionnaire
    """
    return {
        # Le nom du plugin
        "name": "dicoImbrique",
        # La factory pour creer une instance du plugin
        "factory": DicoImbriqueGenerator,
    }


class DicoImbriqueGenerator(PythonGenerator):
    """
    Ce generateur parcourt un objet de type JDC et produit
    un texte au format eficas et
    un texte au format dictionnaire

    """

    # Les extensions de fichier permis?
    extensions = (".comm",)

    # ----------------------------------------------------------------------------------------
    def gener(self, obj, format="brut", config=None, appliEficas=None):
        self.initDico()

        # Cette instruction genere le contenu du fichier de commandes (persistance)
        self.text = PythonGenerator.gener(self, obj, format)
        # print (self.text)
        print(self.Dico)
        return self.text

    # ----------------------------------------------------------------------------------------
    # initialisations
    # ----------------------------------------------------------------------------------------

    def initDico(self):
        self.Dico = {}
        self.DicoDejaLa = {}
        self.Entete = ""

    # ----------------------------------------------------------------------------------------
    # ecriture
    # ----------------------------------------------------------------------------------------

    def writeDefault(self, fn):
        fileDico = fn[: fn.rfind(".")] + ".py"
        f = open(str(fileDico), "w")

        f.write("Dico =" + str(self.Dico))
        # f.write( self.Entete + "Dico =" + str(self.Dico) )
        f.close()

    # ----------------------------------------------------------------------------------------
    #  analyse de chaque noeud de l'arbre
    # ----------------------------------------------------------------------------------------

    def generMCSIMP(self, obj):
        """recuperation de l objet MCSIMP"""

        s = PythonGenerator.generMCSIMP(self, obj)
        if obj.isInformation():
            return s
        if not obj.isValid():
            return s

        liste = obj.getGenealogiePrecise()

        if obj.etape.nom == "MODIFICATION_CATALOGUE":
            return s
        nom = obj.etape.nom

        if (
            hasattr(obj.etape, "sdnom")
            and obj.etape.sdnom != None
            and obj.etape.sdnom != ""
        ):
            nom = nom + obj.etape.sdnom

        if not (nom in self.Dico):
            dicoCourant = {}
        else:
            dicoCourant = self.Dico[nom]

        nomFeuille = liste[-1]
        if nomFeuille in dicoCourant or nomFeuille in self.DicoDejaLa:
            if nomFeuille in self.DicoDejaLa:
                nomTravail = nomFeuille + "_" + str(self.DicoDejaLa[nomFeuille])
                self.DicoDejaLa[nomFeuille] = self.DicoDejaLa[nomFeuille] + 1
                nomFeuille = nomTravail
            else:
                self.DicoDejaLa[nomFeuille] = 3
                nom1 = nomFeuille + "_1"
                dicoCourant[nom1] = dicoCourant[nomFeuille]
                del dicoCourant[nomFeuille]
                nomFeuille = nomFeuille + "_2"

        if hasattr(obj.valeur, "nom"):
            dicoCourant[nomFeuille] = obj.valeur.nom
        else:
            if type(obj.valeur) in (list, tuple):
                try:
                    # PNPNPN a remplacer par plus propre
                    if obj.definition.validators.typeDesTuples[0] != "R":
                        val = []
                        elt = []
                        for tupleElt in obj.valeur:
                            elt = (str(tupleElt[0]), tupleElt[1])
                            val.append(elt)
                        dicoCourant[nomFeuille] = val
                    else:
                        dicoCourant[nomFeuille] = obj.valeur
                except:
                    dicoCourant[nomFeuille] = obj.valeurFormatee
            # else :dicoCourant[nomFeuille]=obj.valeurFormatee
            else:
                dicoCourant[nomFeuille] = obj.valeurFormatee
                # print nomFeuille, obj.valeurFormatee
        self.Dico[nom] = dicoCourant

        return s
