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

import traceback
from Accas.extensions.eficas_translation import tr
from Accas.IO.writer.writer_python import PythonGenerator


def entryPoint():
    """
    Retourne les informations necessaires pour le chargeur de plugins
    Ces informations sont retournees dans un dictionnaire
    # name: Le nom du plugin
    # factory: La factory pour creer une instance du plugin
    """
    return {
        "name": "VPRequeteSelection",
        "factory": RequeteSelectionGenerator,
    }


class RequeteSelectionGenerator(PythonGenerator):
    """
    Ce generateur parcourt un etapeSelectionet de type JDC et produit
    un texte pour requeter la base
    """

    # Les extensions de fichier permis?
    pass
    extensions = (".comm",)

    # ----------------------------------------------------------------------------------------
    def genereConditionSelection(self, jdc ):
        #debug = 1
        debug = 0

        texteCondition = ""
        etapeSelection = jdc.etapes[0]
        if debug: print("appelle genereRequeteSelection avec jdc", jdc)
        if debug: print("etapeSelection", etapeSelection)

        # L etapeSelection n est pas valide : Tout est obligatoire or tout n est pas rempli
        # On se contente de verifier les regles d afficher les regles non valides
        # en enlevant les motclefs invalides
        listeRegles = etapeSelection.getRegles()
        dictObjPresents = etapeSelection.dictMcPresents(restreint="oui")
        if debug: print("dictObjPresents", dictObjPresents)
        dictObjPresentsValides = {}

        for nomObj, obj in dictObjPresents.items():
            if obj.valeur == 'tout' or obj.valeur == 'all' or obj.valeur == 'All' : continue
            if obj.nom == 'performance' : continue
            if obj.nom == 'sha1_debut' : continue
            if obj.nom == 'sha1_fin' : continue
            if obj.isValid(): dictObjPresentsValides[nomObj] = obj
        if debug: print("dictObjPresentsValides", dictObjPresentsValides)

        if len(dictObjPresentsValides) == 0:
            texteErreurs = "Les données sont insuffisantes pour générer les requetes : \n"
            return texteErreurs, {}
        else : 
            texteErreurs = ""

        separateur = ""
        for nomObj, obj in dictObjPresentsValides.items():
            if nomObj.endswith("_debut") or nomObj.endswith("_fin"): continue;
            texteCondition += separateur
            texteCondition += nomObj + ' = '
            lesTypes = obj.getType()
            if "TXM" in lesTypes: texteCondition += "'"
            texteCondition += str(obj.valeur)
            if "TXM" in lesTypes: texteCondition += "'"
            separateur = " and "
        dictObj={}
        for nomObj, obj in dictObjPresentsValides.items():
            if nomObj.endswith("_debut") : 
               nomGener = nomObj[0:-6]
               if nomGener in dictObj : dictObj[nomGener] = 'lesDeux'
               else : dictObj[nomGener] = 'debut'
            if nomObj.endswith("_fin") : 
               nomGener = nomObj[0:-4]
               if nomGener in dictObj : dictObj[nomGener] = 'lesDeux'
               else : dictObj[nomGener] = 'fin'
        for nomGener, typCond in dictObj.items():
            texteCondition += separateur
            valeurFin=None 
            ajoutQuote = False 
            if typCond == 'fin' or typCond == 'lesDeux' : 
               nomObj=nomGener+'_fin' 
               obj=dictObjPresentsValides[nomObj]
               lesTypes = obj.getType()
               if "TXM" in lesTypes: ajoutQuote = True 
               if typCond == 'fin' :
                  if ajoutQuote:
                     texteCondition += " {} < '{}' ".format(nomGener, str(obj.valeur))
                  else : 
                     texteCondition += " {} < {} ".format(nomGener, str(obj.valeur))
               else : valeurFin = obj.valeur
            if typCond == 'debut' or typCond == 'lesDeux' : 
               nomObj=nomGener+'_debut' 
               obj=dictObjPresentsValides[nomObj]
               lesTypes = obj.getType()
               if "TXM" in lesTypes: ajoutQuote = True 
               if typCond == 'debut' :
                  if ajoutQuote:
                     texteCondition += " {} > '{}' ".format(nomGener, str(obj.valeur))
                  else : 
                     texteCondition += " {} < {} ".format(nomGener, str(obj.valeur))
               else :
                  if ajoutQuote:
                     texteCondition += " {} between '{}' and '{}' ".format(nomGener, str(obj.valeur), valeurFin)
                  else : 
                     texteCondition += " {} between {} and {} ".format(nomGener, str(obj.valeur), valeurFin)
    
        return  texteCondition
