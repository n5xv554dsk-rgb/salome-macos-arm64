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
    Ce module contient le plugin generateur de fichier au format
    aplat pour EFICAS.

"""

import traceback
import types, re
from Accas.extensions.eficas_translation import tr
from Accas.extensions.eficas_exception import EficasException

from Accas.processing import P_CR
from Accas.processing.P_utils import repr_float
from Accas import ETAPE, PROC_ETAPE, MACRO_ETAPE, ETAPE_NIVEAU, JDC, FORM_ETAPE
from Accas import MCSIMP, MCFACT, MCBLOC, MCList, EVAL
from Accas import GEOM, ASSD, MCNUPLET
from Accas import COMMENTAIRE, PARAMETRE, PARAMETRE_EVAL, COMMANDE_COMM


def entryPoint():
    """
    Retourne les informations necessaires pour le chargeur de plugins

    Ces informations sont retournees dans un dictionnaire
    """
    return {
        # Le nom du plugin
        "name": "aplat",
        # La factory pour creer une instance du plugin
        "factory": AplatGenerator,
    }


class AplatGenerator(object):
    """
    Ce generateur parcourt un objet de type JDC et produit
    un fichier au format aplat

    L'acquisition et le parcours sont realises par la methode
    generator.gener(objet_jdc,format)

    L'ecriture du fichier au format ini par appel de la methode
    generator.writeFile(nom_fichier)

    Ses caracteristiques principales sont exposees dans des attributs
    de classe :
      - extensions : qui donne une liste d'extensions de fichier preconisees

    """

    # Les extensions de fichier preconisees
    extensions = (".*",)

    def __init__(self, cr=None):
        # Si l'objet compte-rendu n'est pas fourni, on utilise le compte-rendu standard
        if cr:
            self.cr = cr
        else:
            self.cr = P_CR.CR(
                debut="CR generateur format aplat pour eficas",
                fin="fin CR format aplat pour eficas",
            )
        self.init = ""
        # Le separateur utiise
        self.sep = "//"
        # Le texte au format aplat est stocke dans l'attribut text
        self.text = ""

    def writefile(self, filename):
        fp = open(filename, "w")
        fp.write(self.text)
        fp.close()

    def gener(self, obj, format="brut", config=None, appliEficas=None):
        """
        Retourne une representation du JDC obj sous une forme qui est parametree par format.
        Si format vaut 'brut', 'standard' ou 'beautifie', retourne le texte issu de generator
        """
        liste = self.generator(obj)
        if format == "brut":
            self.text = liste
        elif format == "standard":
            self.text = liste
        elif format == "beautifie":
            self.text = liste
        else:
            raise EficasException(tr("Format pas implemente : %s", format))
        return self.text

    def generator(self, obj):
        """
        Cette methode joue un role d'aiguillage en fonction du type de obj
        On pourrait utiliser les methodes accept et visitxxx a la
        place (depend des gouts !!!)
        """
        # ATTENTION a l'ordre des tests : il peut avoir de l'importance (heritage)
        if isinstance(obj, PROC_ETAPE):
            return self.generPROC_ETAPE(obj)
        elif isinstance(obj, MACRO_ETAPE):
            return self.generMACRO_ETAPE(obj)
        elif isinstance(obj, FORM_ETAPE):
            return self.generFORM_ETAPE(obj)
        elif isinstance(obj, ETAPE):
            return self.generETAPE(obj)
        elif isinstance(obj, MCFACT):
            return self.generMCFACT(obj)
        elif isinstance(obj, MCList):
            return self.generMCList(obj)
        elif isinstance(obj, MCBLOC):
            return self.generMCBLOC(obj)
        elif isinstance(obj, MCSIMP):
            return self.generMCSIMP(obj)
        elif isinstance(obj, ASSD):
            return self.generASSD(obj)
        elif isinstance(obj, ETAPE_NIVEAU):
            return self.generETAPE_NIVEAU(obj)
        elif isinstance(obj, COMMENTAIRE):
            return self.generCOMMENTAIRE(obj)
        # Attention doit etre place avant PARAMETRE (raison : heritage)
        elif isinstance(obj, PARAMETRE_EVAL):
            return self.generPARAMETRE_EVAL(obj)
        elif isinstance(obj, PARAMETRE):
            return self.generPARAMETRE(obj)
        elif isinstance(obj, EVAL):
            return self.generEVAL(obj)
        elif isinstance(obj, COMMANDE_COMM):
            return self.generCOMMANDE_COMM(obj)
        elif isinstance(obj, JDC):
            return self.generJDC(obj)
        elif isinstance(obj, MCNUPLET):
            return self.generMCNUPLET(obj)
        else:
            raise EficasException(tr("Format non implemente : %s", format))

    def generJDC(self, obj):
        """
        Cette methode convertit un objet JDC en une chaine de
        caracteres a la syntaxe aplat
        """
        text = ""
        if obj.definition.lNiveaux == ():
            # Il n'y a pas de niveaux
            for etape in obj.etapes:
                text = text + self.generator(etape) + "\n"
        else:
            # Il y a des niveaux
            for etape_niveau in obj.etapes_niveaux:
                text = text + self.generator(etape_niveau) + "\n"
        return text

    def generCOMMANDE_COMM(self, obj):
        """
        Cette methode convertit un COMMANDE_COMM
        en une chaine de caracteres a la syntaxe aplat
        """
        l_lignes = obj.valeur.split("\n")
        txt = ""
        for ligne in l_lignes:
            txt = txt + "##" + ligne + "\n"
        return txt

    def generEVAL(self, obj):
        """
        Cette methode convertit un EVAL
        en une chaine de caracteres a la syntaxe aplat
        """
        return 'EVAL("""' + obj.valeur + '""")'

    def generCOMMENTAIRE(self, obj):
        """
        Cette methode convertit un COMMENTAIRE
        en une chaine de caracteres a la syntaxe aplat
        """
        l_lignes = obj.valeur.split("\n")
        txt = ""
        for ligne in l_lignes:
            txt = txt + "#" + ligne + "\n"
        return txt

    def generPARAMETRE_EVAL(self, obj):
        """
        Cette methode convertit un PARAMETRE_EVAL
        en une chaine de caracteres a la syntaxe aplat
        """
        if obj.valeur == None:
            return obj.nom + " = None ;\n"
        else:
            return obj.nom + " = " + self.generator(obj.valeur) + ";\n"

    def generPARAMETRE(self, obj):
        """
        Cette methode convertit un PARAMETRE
        en une chaine de caracteres a la syntaxe aplat
        """
        if type(obj.valeur) == bytes or type(obj.valeur) == str:
            # PN pour corriger le bug a='3+4' au lieu de a= 3+4
            # return obj.nom + " = '" + obj.valeur + "';\n"
            return obj.nom + " = " + obj.valeur + ";\n"
        else:
            return obj.nom + " = " + str(obj.valeur) + ";\n"

    def generETAPE_NIVEAU(self, obj):
        """
        Cette methode convertit une etape niveau
        en une chaine de caracteres a la syntaxe aplat
        """
        text = ""
        if obj.etapes_niveaux == []:
            for etape in obj.etapes:
                text = text + self.generator(etape) + "\n"
        else:
            for etape_niveau in obj.etapes_niveaux:
                text = text + self.generator(etape_niveau) + "\n"
        return text

    def gener_etape(self, obj):
        """
        Cette methode est utilise pour convertir les objets etape
        en une chaine de caracteres a la syntaxe aplat
        """
        text = ""
        for v in obj.mcListe:
            text = text + self.generator(v)
        if text == "":
            return self.init + "\n"
        else:
            return text

    def generETAPE(self, obj):
        """
        Cette methode convertit une etape
        en une chaine de caracteres a la syntaxe aplat
        """
        try:
            sdname = self.generator(obj.sd)
        except:
            sdname = "sansnom"
        self.init = sdname + self.sep + obj.nom
        return self.gener_etape(obj)

    def generMACRO_ETAPE(self, obj):
        """
        Cette methode convertit une macro-etape
        en une chaine de caracteres a la syntaxe aplat
        """
        try:
            if obj.sd == None:
                self.init = obj.nom
            else:
                sdname = self.generator(obj.sd)
                self.init = sdname + self.sep + obj.nom
        except:
            self.init = "sansnom" + self.sep + obj.nom

        return self.gener_etape(obj)

    generPROC_ETAPE = generMACRO_ETAPE

    generFORM_ETAPE = generMACRO_ETAPE

    def generASSD(self, obj):
        """
        Convertit un objet derive d'ASSD en une chaine de caracteres a la
        syntaxe aplat
        """
        return obj.getName()

    def generMCList(self, obj):
        """
        Convertit un objet MCList en une chaine de caracteres a la
        syntaxe aplat
        """
        i = 0
        text = ""
        init = self.init + self.sep + obj.nom
        old_init = self.init
        for data in obj.data:
            i = i + 1
            self.init = init + self.sep + "occurrence n" + repr(i)
            text = text + self.generator(data)
        self.init = old_init
        return text

    def generMCSIMP(self, obj):
        """
        Convertit un objet MCSIMP en une chaine de caracteres a la
        syntaxe aplat
        """
        if type(obj.valeur) in (tuple, list):
            # On est en presence d'une liste de valeur
            rep = "("
            for val in obj.valeur:
                # if type(val) == types.InstanceType :
                if isinstance(val, object):
                    rep = rep + self.generator(val) + ","
                else:
                    rep = rep + repr(val) + ","
            rep = rep + ")"
        # elif type(obj.valeur) == types.InstanceType :
        elif type(obj.valeur) == object:
            # On est en presence d'une valeur unique de type instance
            rep = self.generator(obj.valeur)
        else:
            # On est en presence d'une valeur unique
            rep = repr(obj.valeur)
        return self.init + self.sep + obj.nom + " :" + rep + "\n"

    def generMCCOMPO(self, obj):
        """
        Convertit un objet MCCOMPO en une chaine de caracteres a la
        syntaxe aplat
        """
        text = ""
        old_init = self.init
        self.init = self.init + self.sep + obj.nom
        for mocle in obj.mcListe:
            text = text + self.generator(mocle)
        self.init = old_init
        return text

    generMCFACT = generMCCOMPO

    generMCBLOC = generMCCOMPO

    generMCNUPLET = generMCCOMPO
