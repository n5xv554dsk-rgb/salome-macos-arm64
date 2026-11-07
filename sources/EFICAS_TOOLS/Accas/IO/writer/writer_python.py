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
    python pour EFICAS.

"""

from Accas.processing import P_CR
from Accas.processing.P_utils import repr_float
from Accas.extensions.parametre import ITEM_PARAMETRE
from Accas.extensions.param2 import Formula
from Accas.extensions.eficas_exception import EficasException
from Accas.extensions.eficas_translation import tr
import Accas


def entryPoint():
    """
    Retourne les informations necessaires pour le chargeur de plugins

    Ces informations sont retournees dans un dictionnaire
    """
    return {
        # Le nom du plugin
        "name": "python",
        # La factory pour creer une instance du plugin
        "factory": PythonGenerator,
    }


class PythonGenerator(object):
    """
    Ce generateur parcourt un objet de type JDC et produit
    un fichier au format python

    L'acquisition et le parcours sont realises par la methode
    generator.gener(objet_jdc,format)

    L'ecriture du fichier au format ini par appel de la methode
    generator.writeFile(nom_fichier)

    Ses caracteristiques principales sont exposees dans des attributs
    de classe :
      - extensions : qui donne une liste d'extensions de fichier preconisees

    """

    # Les extensions de fichier preconisees
    extensions = (".comm",)

    def __init__(self, cr=None):
        # Si l'objet compte-rendu n'est pas fourni, on utilise le compte-rendu standard
        if cr:
            self.cr = cr
        else:
            self.cr = P_CR.CR(
                debut="CR generateur format python pour python",
                fin="fin CR format python pour python",
            )
        # Le texte au format python est stocke dans l'attribut text
        self.text = ""
        self.appliEficas = None

    def writeFile(self, filename):
        try:
            with open(filename, "w") as fp:
                fp.write(self.text)
                return 1
        except:
            return 0

    def gener(self, obj, format="brut", config=None, appliEficas=None):
        """
        Retourne une representation du JDC obj sous une
        forme qui est parametree par format.
        Si format vaut 'brut', retourne une liste de listes de ...
        Si format vaut 'standard', retourne un texte obtenu par concatenation de la liste
        Si format vaut 'beautifie', retourne le meme texte beautifie
        """
        if obj == None:
            return
        self.appliEficas = appliEficas
        liste = self.generator(obj)
        if format == "brut":
            self.text = liste
        elif format == "standard":
            self.text = "".join(liste)
        elif format == "beautifie":
            from Accas.IO.writer.formatage import formatage
            jdc_formate = formatage(liste, mode=".py")
            # import cProfile, pstats, StringIO
            # pr = cProfile.Profile()
            # pr.enable()
            self.text = jdc_formate.formateJdc()
            # pr.disable()
            # s = StringIO.StringIO()
            # sortby = 'cumulative'
            # ps = pstats.Stats(pr, stream=s).sort_stats(sortby)
            # ps.print_stats()
            # print (s.getValue())

        elif format == "Ligne":
            from Accas.IO.writer.formatage import formatageLigne
            jdc_formate = formatageLigne(liste, mode=".py")
            self.text = jdc_formate.formateJdc()
        else:
            raise EficasException(tr("Format non implemente ") + format)
        return self.text

    def generator(self, obj):
        """
        Cette methode joue un role d'aiguillage en fonction du type de obj
        On pourrait utiliser les methodes accept et visitxxx a la
        place (depend des gouts !!!)
        """
        # ATTENTION a l'ordre des tests : il peut avoir de l'importance (heritage)
        if isinstance(obj, Accas.PROC_ETAPE):
            return self.generPROC_ETAPE(obj)
        # Attention doit etre place avant MACRO (raison : heritage)
        elif isinstance(obj, Accas.FORM_ETAPE):
            return self.generFORM_ETAPE(obj)
        elif isinstance(obj, Accas.MACRO_ETAPE):
            return self.generMACRO_ETAPE(obj)
        elif isinstance(obj, Accas.ETAPE):
            return self.generETAPE(obj)
        elif isinstance(obj, Accas.MCFACT):
            return self.generMCFACT(obj)
        elif isinstance(obj, Accas.MCList):
            return self.generMCList(obj)
        elif isinstance(obj, Accas.MCBLOC):
            return self.generMCBLOC(obj)
        elif isinstance(obj, Accas.MCSIMP):
            return self.generMCSIMP(obj)
        elif isinstance(obj, Accas.ASSD):
            return self.generASSD(obj)
        elif isinstance(obj, Accas.ETAPE_NIVEAU):
            return self.generETAPE_NIVEAU(obj)
        elif isinstance(obj, Accas.COMMENTAIRE):
            return self.generCOMMENTAIRE(obj)
        # Attention doit etre place avant PARAMETRE (raison : heritage)
        elif isinstance(obj, Accas.PARAMETRE_EVAL):
            return self.generPARAMETRE_EVAL(obj)
        elif isinstance(obj, Accas.PARAMETRE):
            return self.generPARAMETRE(obj)
        elif isinstance(obj, Accas.EVAL):
            return self.generEVAL(obj)
        elif isinstance(obj, Accas.COMMANDE_COMM):
            return self.generCOMMANDE_COMM(obj)
        elif isinstance(obj, Accas.JDC):
            return self.generJDC(obj)
        elif isinstance(obj, Accas.MCNUPLET):
            return self.generMCNUPLET(obj)
        elif isinstance(obj, ITEM_PARAMETRE):
            return self.generITEM_PARAMETRE(obj)
        elif isinstance(obj, Formula):
            return self.generFormula(obj)
        else:
            raise EficasException(tr("Type d'objet non prevu") + obj)

    def generJDC(self, obj):
        """
        Cette methode convertit un objet JDC en une liste de chaines de
        caracteres a la syntaxe python
        """
        l = []

        # print ('generJDC', obj.sdsDict)
        for objRef in obj.sdsDict:
            if isinstance(obj.sdsDict[objRef], Accas.UserASSD):
                l.append(self.generUserASSD(obj.sdsDict[objRef]))
        if obj.definition.lNiveaux == ():
            # Il n'y a pas de niveaux
            for etape in obj.etapes:
                l.append(self.generator(etape))
        else:
            # Il y a des niveaux
            for etape_niveau in obj.etapes_niveaux:
                l.extend(self.generator(etape_niveau))
        if l != []:
            # Si au moins une etape, on ajoute le retour chariot sur la derniere etape
            if type(l[-1]) == list:
                l[-1][-1] = l[-1][-1] + "\n"
            elif type(l[-1]) == bytes or type(l[-1]) == str:
                l[-1] = l[-1] + "\n"
        return l

    def generUserASSD(self, obj):
        classeName = obj.__class__.__name__
        if obj.valeur == None:
            texte = obj.nom + "=" + classeName + "()"
            return texte

    def generMCNUPLET(self, obj):
        """
        Methode generant une representation de self permettant son ecriture
        dans le format python
        """
        l = []
        l.append("(")
        for v in obj.mcListe:
            text = re.sub(".*=", "", self.generator(v))
            l.append(text)
        l.append("),")
        return l

    def generCOMMANDE_COMM(self, obj):
        """
        Cette methode convertit un COMMANDE_COMM
        en une liste de chaines de caracteres a la syntaxe python
        """
        l_lignes = obj.valeur.split("\n")
        txt = ""
        for ligne in l_lignes:
            txt = txt + "##" + ligne + "\n"
        return txt

    def generEVAL(self, obj):
        """
        Cette methode convertit un EVAL
        en une liste de chaines de caracteres a la syntaxe python
        """
        return 'EVAL("""' + obj.valeur + '""")'

    def generCOMMENTAIRE(self, obj):
        """
        Cette methode convertit un COMMENTAIRE
        en une liste de chaines de caracteres a la syntaxe python
        """
        # modification pour repondre a la demande de C. Durand, d'eviter
        # l'ajout systematique d'un diese, a la suite du commentaire
        # Dans la chaine de caracteres obj.valeur, on supprime le dernier
        # saut de ligne
        sans_saut = re.sub("\n$", "", obj.valeur)
        l_lignes = sans_saut.split("\n")
        txt = ""
        i = 1
        for ligne in l_lignes:
            txt = txt + "#" + ligne + "\n"

        # suppression du dernier saut de ligne
        # txt = re.sub("\n$","",txt)
        # on ajoute un saut de ligne avant
        pattern = re.compile(" ?\#")
        m = pattern.match(txt)
        if m:
            txt = "\n" + txt
        return txt

    def generPARAMETRE_EVAL(self, obj):
        """
        Cette methode convertit un PARAMETRE_EVAL
        en une liste de chaines de caracteres a la syntaxe python
        """
        if obj.valeur == None:
            return obj.nom + " = None ;\n"
        else:
            return obj.nom + " = " + self.generator(obj.valeur) + ";\n"

    def generITEM_PARAMETRE(self, obj):
        return repr(obj)

    def generFormula(self, obj):
        # return repr(obj)
        return str(obj)

    def generPARAMETRE(self, obj):
        """
        Cette methode convertit un PARAMETRE
        en une liste de chaines de caracteres a la syntaxe python
        """
        return repr(obj) + ";\n"

    def generETAPE_NIVEAU(self, obj):
        """
        Cette methode convertit une etape niveau
        en une liste de chaines de caracteres a la syntaxe python
        """
        l = []
        if obj.etapes_niveaux == []:
            for etape in obj.etapes:
                l.append(self.generator(etape))
        else:
            for etape_niveau in obj.etapes_niveaux:
                l.extend(self.generator(etape_niveau))
        return l

    def generETAPE(self, obj):
        """
        Cette methode convertit une etape
        en une liste de chaines de caracteres a la syntaxe python
        """
        try:
            sdname = self.generator(obj.sd)
            if sdname.find("SD_") != -1:
                sdname = "sansnom"
        except:
            sdname = "sansnom"
        l = []
        label = sdname + "=" + obj.definition.nom + "("
        l.append(label)
        if obj.reuse != None:
            str = "reuse =" + self.generator(obj.reuse) + ","
            l.append(str)
        for v in obj.mcListe:
            if isinstance(v, Accas.MCBLOC):
                liste = self.generator(v)
                for mocle in liste:
                    l.append(mocle)
            elif isinstance(v, Accas.MCSIMP):
                text = self.generator(v)
                l.append(v.nom + "=" + text)
            else:
                # MCFACT ou MCList
                liste = self.generator(v)
                liste[0] = v.nom + "=" + liste[0]
                l.append(liste)
        if len(l) == 1:
            l[0] = label + ");"
        else:
            l.append(");")
        return l

    def generFORM_ETAPE(self, obj):
        """
        Methode particuliere pour les objets de type FORMULE
        """
        l = []
        nom = obj.getNom()
        if nom == "":
            nom = "sansnom"
        l.append(nom + " = FORMULE(")
        for v in obj.mcListe:
            text = self.generator(v)
            l.append(v.nom + "=" + text)
        l.append(");")
        return l

    def generMACRO_ETAPE(self, obj):
        """
        Cette methode convertit une macro-etape
        en une liste de chaines de caracteres a la syntaxe python
        """
        try:
            if obj.sd == None:
                sdname = ""
            else:
                sdname = self.generator(obj.sd) + "="
            if sdname.find("SD_") != -1:
                sdname = ""
        except:
            sdname = "sansnom="
        l = []
        label = sdname + obj.definition.nom + "("
        l.append(label)
        if obj.reuse != None:
            # XXX faut il la virgule ou pas ????
            str = "reuse =" + self.generator(obj.reuse) + ","
            l.append(str)
        for v in obj.mcListe:
            if isinstance(v, Accas.MCBLOC):
                liste = self.generator(v)
                for mocle in liste:
                    l.append(mocle)
            elif isinstance(v, Accas.MCSIMP):
                text = self.generator(v)
                l.append(v.nom + "=" + text)
            else:
                # MCFACT ou MCList
                liste = self.generator(v)
                liste[0] = v.nom + "=" + liste[0]
                l.append(liste)

        if len(l) == 1:
            l[0] = label + ");"
        else:
            l.append(");")
        return l

    def generPROC_ETAPE(self, obj):
        """
        Cette methode convertit une PROC etape
        en une liste de chaines de caracteres a la syntaxe python
        """
        if (
            obj.nom == "ExpressionIncertitude"
            and hasattr(self, "generDeterministe")
            and self.generDeterministe == True
        ):
            return ""
        l = []
        label = obj.definition.nom + "("
        l.append(label)
        for v in obj.mcListe:
            if isinstance(v, Accas.MCBLOC):
                liste = self.generator(v)
                for mocle in liste:
                    l.append(mocle)
            elif isinstance(v, Accas.MCSIMP):
                text = self.generator(v)
                if text == None:
                    text = ""
                l.append(v.nom + "=" + text)
            else:
                # MCFACT ou MCList
                liste = self.generator(v)
                liste[0] = v.nom + "=" + liste[0]
                l.append(liste)

        if len(l) == 1:
            l[0] = label + ");"
        else:
            l.append(");")
        return l

    def generASSD(self, obj):
        """
        Convertit un objet derive d'ASSD en une chaine de caracteres a la
        syntaxe python
        """
        return obj.getName()

    def generMCFACT(self, obj):
        """
        Convertit un objet MCFACT en une liste de chaines de caracteres a la
        syntaxe python
        """
        l = []
        l.append("_F(")
        for v in obj.mcListe:
            if not isinstance(v, Accas.MCSIMP) and not isinstance(v, Accas.MCBLOC):
                # on est en presence d'une entite composee : on recupere une liste
                liste = self.generator(v)
                liste[0] = v.nom + "=" + liste[0]
                l.append(liste)
            elif isinstance(v, Accas.MCBLOC):
                liste = self.generator(v)
                for arg in liste:
                    l.append(arg)
            else:
                # on est en presence d'un MCSIMP : on recupere une string
                text = self.generator(v)
                if text == None:
                    text = ""
                if v.nom != "Consigne":
                    l.append(v.nom + "=" + text)
        # il faut etre plus subtil dans l'ajout de la virgule en differenciant
        # le cas ou elle est obligatoire (si self a des freres cadets
        # dans self.parent) ou non
        # (cas ou self est seul ou le benjamin de self.parent)
        l.append("),")
        return l

    def generMCList(self, obj):
        """
        Convertit un objet MCList en une liste de chaines de caracteres a la
        syntaxe python
        """
        if len(obj.data) > 1:
            l = ["("]
            for mcfact in obj.data:
                l.append(self.generator(mcfact))
            l.append("),")
        else:
            l = self.generator(obj.data[0])
        return l

    def generMCBLOC(self, obj):
        """
        Convertit un objet MCBLOC en une liste de chaines de caracteres a la
        syntaxe python
        """
        l = []
        for v in obj.mcListe:
            if isinstance(v, Accas.MCBLOC):
                liste = self.generator(v)
                for mocle in liste:
                    l.append(mocle)
            elif isinstance(v, Accas.MCFACT):
                liste = self.generator(v)
            elif isinstance(v, Accas.MCList):
                liste = self.generator(v)
                liste[0] = v.nom + "=" + liste[0]
                # PN  essai de correction bug identation
                if hasattr(v, "data"):
                    if isinstance(v.data[0], Accas.MCFACT) and (len(v.data) == 1):
                        l.append(liste)
                    else:
                        for mocle in liste:
                            l.append(mocle)
                else:
                    for mocle in liste:
                        l.append(mocle)
            else:
                data = self.generator(v)
                if data == None:
                    data = ""
                if type(data) == list:
                    data[0] = v.nom + "=" + data[0]
                else:
                    data = v.nom + "=" + data
                if v.nom != "Consigne":
                    l.append(data)
        return l

    def formatItem(self, valeur, etape, obj, vientDeListe=0, matriceDAssd=0):
        if (type(valeur) == float or "R" in obj.definition.type) and not (
            isinstance(valeur, Accas.PARAMETRE)
        ):
            # Pour un flottant on utilise str ou repr si on vient d une liste
            # ou la notation scientifique
            # On ajoute un . si il n y en a pas dans la valeur
            s = str(valeur)
            if vientDeListe and repr(valeur) != str(valeur):
                s = repr(valeur)
            if s.find(".") == -1 and s.find("e") == -1 and s.find("E") == -1:
                s = s + ".0"
            clefobj = etape.getSdname()
            if self.appliEficas and clefobj in self.appliEficas.dict_reels:
                if valeur in self.appliEficas.dict_reels[clefobj]:
                    s = self.appliEficas.dict_reels[clefobj][valeur]

        elif type(valeur) == bytes or type(valeur) == str:
            if valeur.find("\n") == -1:
                # pas de retour chariot, on utilise repr
                s = repr(valeur)
            elif valeur.find('"""') == -1:
                # retour chariot mais pas de triple ", on formatte
                s = '"""' + valeur + '"""'
            else:
                s = repr(valeur)
        elif (
            isinstance(valeur, Accas.CO)
            or hasattr(etape, "sdprods")
            and valeur in etape.sdprods
        ):
            s = "CO('" + self.generator(valeur) + "')"
        elif isinstance(valeur, Accas.UserASSD):
            # ici on ne prend que la reference
            s = valeur.nom
        elif isinstance(valeur, Accas.ASSD):
            s = self.generator(valeur)
        elif isinstance(valeur, Accas.PARAMETRE):
            # il ne faut pas prendre la string que retourne gener
            # mais seulement le nom dans le cas d'un parametre
            s = valeur.nom

        # elif type(valeur) == types.InstanceType or isinstance(valeur,object):
        #   if valeur.__class__.__name__ == 'CO' or hasattr(etape,'sdprods') and valeur in etape.sdprods :
        #      s = "CO('"+ self.generator(valeur) +"')"
        #   elif isinstance(valeur,Accas.PARAMETRE):
        # il ne faut pas prendre la string que retourne gener
        # mais seulement le nom dans le cas d'un parametre
        #      s = valeur.nom
        #   else:
        #      s = self.generator(valeur)

        elif matriceDAssd:
            s = "["
            for v in valeur:
                s = s + str(self.generator(v)) + ", "

            s = s + "]"
        else:
            # Pour les autres types on utilise repr
            s = repr(valeur)
        return s

    def generMCSIMP(self, obj):
        """
        Convertit un objet MCSIMP en une liste de chaines de caracteres a la
        syntaxe python
        """
        waitTuple = 0
        matriceDAssd = 0
        for ssType in obj.definition.type:
            if hasattr(ssType, "typElt"):
                if ssType.typElt not in ("R", "I", "C", "TXM"):
                    matriceDAssd = 1
                    break
        if type(obj.valeur) in (tuple, list):
            s = ""
            for ss_type in obj.definition.type:
                if repr(ss_type).find("Tuple") != -1:
                    waitTuple = 1
                    break
            if waitTuple:
                # s = str(obj.valeur) +','
                # obj.valeurFormatee=obj.valeur
                s = obj.getText() + ","
                obj.valeurFormatee = obj.getText()
            else:
                obj.valeurFormatee = []
                for val in obj.valeur:
                    s = s + self.formatItem(val, obj.etape, obj, 1, matriceDAssd) + ","
                    if obj.waitTxm():
                        obj.valeurFormatee.append(val)
                    else:
                        obj.valeurFormatee.append(self.formatItem(val, obj.etape, obj))
                if len(obj.valeur) >= 1:
                    s = "(" + s + "),"
                if obj.valeur == [] or obj.valeur == ():
                    s = "(),"
            if obj.nbrColonnes():
                s = self.formatColonnes(obj.nbrColonnes(), obj.valeur, obj)
        else:
            obj.valeurFormatee = obj.valeur
            s = self.formatItem(obj.valeur, obj.etape, obj) + ","
        return s

    def formatColonnes(self, nbrColonnes, listeValeurs, obj):
        try:
            # if 1 == 1 :
            indice = 0
            textformat = "("
            while indice < len(listeValeurs):
                try:
                    # if 1 :
                    for l in range(nbrColonnes):
                        texteVariable = self.formatItem(
                            listeValeurs[indice], obj.etape, obj
                        )
                        textformat = textformat + texteVariable + " ,"
                        indice = indice + 1
                    textformat = textformat + "\n"
                except:
                    # else :
                    while indice < len(listeValeurs):
                        texteVariable = self.formatItem(
                            listeValeurs[indice], obj.etape, obj
                        )
                        textformat = textformat + texteVariable + ", "
                        indice = indice + 1
                    textformat = textformat + "\n"
            textformat = textformat[0:-1] + "),\n"
        except:
            # else :
            textformat = str(obj.valeur)
        return textformat
