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
    Ce module contient la classe formatage qui permet le formatage d'une
    liste de chaines de caractères dans une syntaxe représentative d'un
    jeu de commandes en un texte présentable
"""
import types, re
from Accas.extensions.eficas_translation import tr

filePattern = "'[^\(\)]([^\(\)]*\([^\(\)]*\))*[^\(\)]*'"
filePattern2 = '"[^\(\)]([^\(\)]*\([^\(\)]*\))*[^\(\)]*"'


class formatage(object):
    """
    Cette classe contient toutes les méthodes nécessaires au formatage
    de la chaine de caracteres issue d'un generator en un fichier
    'lisible' ie avec indentations

    L'objet attend en parametre du constructeur (argument l_jdc) une representation
    du jeu de commandes sous la forme d'une liste.

    Chaque element de la liste est la representation d'une etape.

    La representation d'une etape est une liste dont le premier element est une chaine de
    caracteres donnant le debut de la commande ("xxx=lire_maillage(", par exemple).
    Les elements suivants sont les representations des mots cles simples et facteurs.
    Elle se termine avec un element de fin : ");"

    La representation d'un mot cle simple est une chaine de caracteres (info=2, par exemple).

    La representation d'un mot cle facteur est semblable à celle de l'étape : premier element
    caracteristique du mot cle facteur suivi d'elements representatifs des mots cles simples.
    Elle se termine avec un element de fin : ")" ou "),".
    """

    def __init__(self, l_jdc, code=None, mode=None, sep="=", l_max=72):
        # l_jdc représente le jeu de commandes brut sous forme de liste
        self.l_jdc = l_jdc
        self.jdc_fini = ""
        self.count = 0
        self.sep = sep
        self.l_max = l_max
        if mode == ".py":
            self.sep = "="
            self.l_max = 132
        elif code == "ASTER":
            self.sep = ":"
            self.l_max = 72

    def formateJdc(self):
        comment = re.compile("\n#")
        commentaireavant = 0
        for etape in self.l_jdc:
            self.count = self.count + 1
            self.texte_etape = ""
            if type(etape) == list:
                # L'etape est sous la forme d'une liste dont le premier element est une chaine
                self.indent = []
                self.indent.append(len(etape[0]))
                self.indent_courant = self.indent[0]
                self.texte_etape = "\n" + etape[0]
                if len(etape) > 1:
                    self.formateEtape(etape[1:])
            else:
                # L'etape est deja sous forme de chaine de caracteres
                self.indent = []
                self.texte_etape = etape

            m = comment.match(self.texte_etape)
            # si ce n est pas la premiere ligne
            if self.jdc_fini != "":
                # si il n y avait pas de commentaire avant on met un saut de ligne
                if commentaireavant == 0:
                    self.jdc_fini = self.jdc_fini + "\n" + self.texte_etape
                else:
                    self.jdc_fini = self.jdc_fini + self.texte_etape
            # si c est la premiere ligne
            else:
                # on ne met pas de saut de ligne avant la premiere ligne
                # si c est un commentaire on enleve le saut de ligne precedent
                if m:
                    self.texte_etape = self.texte_etape[1:]
                self.jdc_fini = self.texte_etape
            if m:
                commentaireavant = 1
            else:
                commentaireavant = 0

        return self.jdc_fini

    def formateEtape(self, liste):
        """
        Enrichissement de la chaine de caracteres representant l'etape (attribut
        texte_etape de l'objet formatage).
        Les elements a ajouter sont dans l'argument liste de la methode.
        L'objet "liste" à traiter a été produit par le module generator. En particulier
        les parenthèses et les virgules ont été produites par ce module
        """
        l_patterns_fin_etape = (");", ");\n")
        l_patterns_fin_mcf = (")", "),")

        ind = 0
        for element in liste:
            if type(element) == list:
                # il s'agit d'un mot-clé facteur
                # on écrit son nom (element[0])
                longueur = self.longueur(self.texte_etape)
                try:
                    increment = len(
                        ("\n" + self.indent_courant * " ") * ind + element[0]
                    )
                except:
                    print(tr("ERREUR"))
                    print(liste)
                    print(element)
                self.texte_etape = (
                    self.texte_etape
                    + ("\n" + self.indent_courant * " ") * ind
                    + element[0]
                )
                length = len(self.indent)
                self.indent.insert(length, self.indent[length - 1] + len(element[0]))
                self.indent_courant = self.indent[length]
                # on écrit ses fils
                self.formateEtape(element[1:])
            # elif type(element) == types.StringType:
            # elif type(element) == bytes:
            # PNPNPN -> marre du python 2 et 3
            # on remplace par else dans if
            else:
                # il s'agit d'un mot-clé simple ou de ')' ou ');' ou '),' ou ');\n'

                if element in l_patterns_fin_mcf:
                    self.traiteMcfact(s_mcfact=element, ind=ind)
                elif element in l_patterns_fin_etape:
                    self.traiteEtape(s_etape=element, ind=ind)
                else:
                    self.traiteMcsimp(s_mcsimp=element, ind=ind)

            ind = 1

    def traiteEtape(self, s_etape, ind):
        """
        Traite une partie du jdc formaté : s_etape, une chaîne de caractères
        contenant une étape
        L'attribut self.texte_etape est modifié (complété) par le traitement
        L'attribut self.indent est modifié par le traitement
        L'attribut self.indent_courant est modifié par le traitement
        """
        length = len(self.indent)
        if length > 1:
            last = self.indent[length - 1]
            self.indent.remove(last)
            self.indent_courant = self.indent[length - 2]
        else:
            self.indent_courant = self.indent[0]
        self.texte_etape = self.texte_etape + s_etape.strip()

    def traiteMcfact(self, s_mcfact, ind):
        """
        Traite une partie du jdc formaté : s_mcfact, une chaîne de caractères
        contenant un mot-clef facteur.
        L'attribut self.texte_etape est modifié (complété) par le traitement
        L'attribut self.indent est modifié par le traitement
        L'attribut self.indent_courant est modifié par le traitement
        """
        self.texte_etape = self.texte_etape + s_mcfact.strip()
        length = len(self.indent)
        if length > 1:
            last = self.indent[length - 1]
            self.indent.remove(last)
            self.indent_courant = self.indent[length - 2]
        else:
            self.indent_courant = self.indent[0]

    def traiteMcsimp(self, s_mcsimp, ind):
        """
        Traite une partie du jdc formaté : s_mcsimp, une chaîne de caractères
        contenant un mot-clef simple.
        L'attribut self.texte_etape est modifié (complété) par le traitement
        """
        #
        # Ajout pour defi fonction
        if self.texte_etape.find("DEFI_FONCTION") > 1:
            self.mcSimpDEFI_FONCTION( s_mcsimp, ind)

        longueur = self.longueur(self.texte_etape)
        increment = len(("\n" + self.indent_courant * " ") * ind + s_mcsimp.strip())
        if ((1 - ind) * longueur + increment) <= self.l_max:
            self.texte_etape = ( self.texte_etape + ("\n" + self.indent_courant * " ") * ind + s_mcsimp.strip()
            )
        else:
            # il faut couper ...
            nom, valeur = str.split(s_mcsimp, self.sep, 1)
            chaine = self.creerChaine( nom, valeur, "\n" + self.indent_courant * " ", ind)
            self.texte_etape = self.texte_etape + chaine

    def mcSimpDEFI_FONCTION(self, s_mcsimp, ind):
        if s_mcsimp.find("\n") > 1:
            txt = ""
            bool = 0
            numident = 1
            for l in s_mcsimp.splitlines():
                if bool == 0:
                    bool = 1
                    numident = s_mcsimp.find("=") + 2
                    txt = l
                else:
                    txt = ( txt + ("\n" + self.indent_courant * " " + numident * " ") * ind + l)
            s_mcsimp = txt
        longueur = self.longueur(self.texte_etape)
        increment = len(("\n" + self.indent_courant * " ") * ind + s_mcsimp.strip())
        self.texte_etape = ( self.texte_etape + "\n" + self.indent_courant * " " + s_mcsimp)

    def longueur(self, texte):
        """
        texte est une string qui peut contenir des retours chariots
        Cette méthode retourne la longueur de la dernière ligne de texte
        """
        # liste = texte.split('\n')
        # return len(liste[-1])
        if texte[-1] == "\n":
            return 0
        return len(texte[texte.rfind("\n") : -1])

    def creerChaine(self, nom, valeur, increment, ind):
        """
        La methode creerChaine reconstitue un objet Eficas à partir de
             - son nom,
             - sa valeur.
        """
        s = ""
        if len(increment + nom + self.sep) <= self.l_max:
            texte = increment * ind
            label = nom + self.sep
            s = texte + label
            longueur = len(increment + label)

            if ("(" not in valeur) or (valeur[0:3] == '"""'):
                # il s'agit d'une vraie chaîne de caractères
                val = len(valeur)
                texte = (self.l_max - 2 - val) * " " + valeur
                s = s + "\\\n" + texte
            elif re.match(filePattern, valeur) or re.match(filePattern2, valeur):
                val = len(valeur)
                texte = (self.l_max - 2 - val) * " " + valeur
                s = s + "\\\n" + texte
            elif "," in valeur:
                # il s'agit d'une liste de tuple
                # c est trop complique on ne splitte pas
                if valeur[0:2] == "((" or valeur[0:2] == "[(":
                    s = s + valeur
                    return s
                # il s'agit d'une liste
                liste = valeur.split(",")
                i = 0
                for arg in liste:
                    ajout = arg.strip()
                    if len(ajout) == 0:
                        continue
                    longueur = (
                        self.longueur(texte=(texte + label))
                        + len(ajout + ",")
                        + (1 - i) * len(increment)
                    )
                    if longueur <= self.l_max:
                        if ajout[-1] != ")":
                            texte = texte + ajout + ","
                        else:
                            texte = texte + ajout
                    else:
                        i = 1
                        if ajout[-1] != ")":
                            texte = (
                                texte + increment + (len(label) + 2) * " " + ajout + ","
                            )
                        else:
                            texte = texte + increment + (len(label) + 2) * " " + ajout

                s = s + texte
                s = s + ","

            else:
                # On a une ( mais pas de , . On passe la chaine sans modification
                val = len(valeur) + len(label)
                texte = (self.l_max - 2 - val) * " " + valeur
                s = "\n" + s + texte
        else:
            label = nom + self.sep
            val = len(valeur) + len(label)
            s = "\n" + (self.l_max - 2 - val) * " " + label + valeur
        return s


class formatageLigne(formatage):
    def __init__(self, l_jdc, code=None, mode=None, sep="=", l_max="**"):
        formatage.__init__(self, l_jdc, code=None, mode=None, sep="=", l_max="**")

    def formateJdc(self):
        texte1 = formatage.formateJdc(self)
        newText = ""
        lignes = texte1.split("\n")
        texte = ""
        pattern_debut_blanc = re.compile(r"^ \s*.*")
        pattern_commentaire = re.compile(r"^\s*#.*")
        pattern_vide = re.compile(r"\s*^$")
        for l in lignes:
            if pattern_commentaire.match(l) or pattern_vide.match(l):
                newText += l + "\n"
                continue
            if not pattern_debut_blanc.match(l):
                texte = l
            else:
                texte += re.sub(r"^ \s*", " ", l)
            if texte[-1] == ";":
                newText += texte + "\n"
                texte = ""
        return newText
