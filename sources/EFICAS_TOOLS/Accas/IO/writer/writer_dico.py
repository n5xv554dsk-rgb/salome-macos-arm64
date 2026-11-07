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
        "name": "dico",
        # La factory pour creer une instance du plugin
        "factory": DicoGenerator,
    }


class DicoGenerator(PythonGenerator):
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
        return self.text

    def generDico(self, obj, format="brut", config=None, appliEficas=None):
        self.initDico()
        # Cette instruction genere le contenu du fichier de commandes (persistance)
        self.text = PythonGenerator.gener(self, obj, format)
        return self.dicoComm

    # ----------------------------------------------------------------------------------------
    # initialisations
    # ----------------------------------------------------------------------------------------

    def initDico(self):
        self.dicoComm = {}
        self.rang = 0

    # ----------------------------------------------------------------------------------------
    # ecriture
    # ----------------------------------------------------------------------------------------

    def writeDefault(self, fn):
        fileDico = fn[: fn.rfind(".")] + ".py"
        f = open(str(fileDico), "w")
        f.write("dicoComm = " + str(self.dicoComm))
        f.close()

    # ----------------------------------------------------------------------------------------
    #  analyse de chaque noeud de l'arbre
    # ----------------------------------------------------------------------------------------

    def generMCSIMP(self, obj):
        """recuperation de l objet MCSIMP"""
        s = PythonGenerator.generMCSIMP(self, obj)
        listeParents = []
        objTraite = obj
        while hasattr(objTraite, "parent") and objTraite.parent != None:
            objTraite = objTraite.parent
            if objTraite.nature == "JDC":
                break
            if objTraite.nature == "BLOC":
                continue
            if objTraite.nature == "OPERATEUR" or objTraite.nature == "PROCEDURE":
                listeParents.insert(0, objTraite)
            elif objTraite.nature == "MCList":
                if len(objTraite.data > 1):
                    monRang = objTraite.data.index(objTraite)
                    listeParents.insert(0, objTraite.nom + "_" + str(monRang))
                else:
                    listeParents.insert(0, objTraite.nom)
            else:
                listeParents.insert(0, objTraite.nom)
        courant = self.dicoComm
        # On traite l etape pour ajouter le rang et la classe
        etape = listeParents[0]
        ordreId = etape.parent.etapes.index(etape)
        if etape.nature == "OPERATEUR":
            if not etape.sd.nom in courant.keys():
                courant[etape.sd.nom] = {}
                courant[etape.sd.nom]["@classeAccas"] = etape.nom
                courant[etape.sd.nom]["@ordreAccas"] = ordreId
            courant = courant[etape.sd.nom]
        else:
            if not etape.nom in courant.keys():
                courant[etape.nom] = {}
                courant[etape.nom]["@classeAccas"] = etape.nom
                courant[etape.nom]["@ordreAccas"] = ordreId
                courant = courant[etape.nom]
            else:
                if not (isinstance(courant[etape.nom], list)):
                    laListe = [
                        courant[etape.nom],
                    ]
                    courant[etape.nom] = laListe
                newDict = {}
                newDict["@classeAccas"] = etape.nom
                newDict["@ordreAccas"] = ordreId
                courant[etape.nom].append(newDict)
                courant = newDict
        for p in listeParents[1:]:
            if not (p in courant.keys()):
                courant[p] = {}
            courant = courant[p]
        # on transforme les concepts en nom
        laValeur = self.transformeObjInRef(obj)
        courant[obj.nom] = laValeur
        return s

    def transformeObjInRef(self, obj):
        # cas d une matrice d ASSD
        for ssType in obj.definition.type:
            if hasattr(ssType, "typElt"):
                if ssType.typElt not in ("R", "I", "C", "TXM"):
                    # on a une matrice d ASSD
                    listeLigne = []
                    for ligne in obj.val:
                        col = []
                        for elt in ligne:
                            col.append(elt.nom)
                        listeLigne.append(col)
                    return listeLigne
        waitASSDTuple = 0
        if type(obj.valeur) in (tuple, list):
            for ss_type in obj.definition.type:
                if repr(ss_type).find("Tuple") != -1:
                    if hasattr(ssType, "typeDesTuples"):
                        for t in ssType.typeDesTuples:
                            if t not in ("R", "I", "C", "TXM"):
                                waitASSDTuple = 1
                                break
                elif ss_type not in ("R", "I", "C", "TXM"):
                    waitASSDTuple = 1
        if waitASSDTuple:
            listeRetour = []
            for elt in obj.val:
                if hasattr(elt, "nom"):
                    listeRetour.append(elt.nom)
                else:
                    listeRetour.append(elt)
            return listeRetour

        if hasattr(obj.val, "nom"):
            listeRetour.append(obj.val.nom)
        return obj.val
