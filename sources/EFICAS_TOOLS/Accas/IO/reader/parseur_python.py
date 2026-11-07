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
import sys, string, re
import traceback
from Accas.extensions.eficas_translation import tr

escapedQuotesRE = re.compile(r"(\\\\|\\\"|\\\')")
stringsAndCommentsRE = re.compile(
    "(\"\"\".*?\"\"\"|'''.*?'''|\"[^\"]*\"|'[^']*'|#.*?\n)", re.DOTALL
)
# stringsAndCommentsRE =  \
#      re.compile(u"(\"\"\".*\"\"\"|'''.*'''|\"[^\"]*\"|\'[^\']*\'|#.*\n)", re.DOTALL)
allchars = bytes.maketrans(b"", b"")
allcharsExceptNewline = (
    allchars[: allchars.index(b"\n")] + allchars[allchars.index(b"\n") + 1 :]
)
allcharsExceptNewlineTranstable = bytes.maketrans(
    allcharsExceptNewline, b"*" * len(allcharsExceptNewline)
)


def maskStringsAndComments(src):
    """Masque tous les caracteres de src contenus dans des commentaires ou des strings multilignes (triples
    quotes et guillemets.
    Le masquage est realise en remplacant les caracteres par des *
    Attention : cette fonction doit etre utilisee sur un texte complet et pas ligne par ligne
    """
    # remplace les \\, les \" les \'  par **
    # supprime toutes les chaines ou commentaires ,y compris multiligne i
    # entre 3 ou 1 simples ou doubles quotes (ouvrantes fermantes) ou #
    # laisse les non fermantes ou non ouvrantes
    # on prend 1 sur 2 en raison du split qui donne python, commentaire, python, commentaire...

    src = escapedQuotesRE.sub("**", src)
    allstrings = stringsAndCommentsRE.split(src)

    # on a une liste d elements constituee successivement de  (string, comment)
    for i in range(1, len(allstrings), 2):
        if allstrings[i].startswith("'''") or allstrings[i].startswith('"""'):
            allstrings[i] = (
                allstrings[i][:3]
                + allstrings[i][3:-3].translate(allcharsExceptNewlineTranstable)
                + allstrings[i][-3:]
            )
        else:
            allstrings[i] = (
                allstrings[i][0]
                + allstrings[i][1:-1].translate(allcharsExceptNewlineTranstable)
                + allstrings[i][-1]
            )

    return "".join(allstrings)


implicitContinuationChars = (("(", ")"), ("[", "]"), ("{", "}"))
linecontinueRE = re.compile(r"\\\s*(#.*)?$")
emptyHangingBraces = [0, 0, 0, 0, 0]


class parserException(Exception):
    pass


class FatalError(Exception):
    pass


# commentaire double precede d'un nombre quelconque de blancs (pas multiligne)
pattern_2comments = re.compile(r"^\s*##.*")
pattern_finComments = re.compile("^\s*##Fin Commentaire")
# commentaire standard precede d'un nombre quelconque de blancs (pas multiligne)
pattern_comment = re.compile(r"^\s*#.*")
# fin de ligne ; suivi d'un nombre quelconque de blancs (pas multiligne)
pattern_fin = re.compile(r"; *$")
# pattern pour supprimer les blancs, tabulations et fins de ligne
pattern_blancs = re.compile(r"[ \t\r\f\v]")
# pattern_blancs = re.compile(r"[\s\n]")
number_kw_pattern = re.compile(
    r"""
(
    #groupe nombre decimal
    (?:
        #signe : on ignore le signe +
        [-]?
        #groupe (avec ?: n'apparait pas en tant que groupe dans le resultat)
        (?:
            #mantisse forme entiere.fractionnaire
            \d+(?:\.\d*)?
            |
            #ou forme .fractionnaire
            \.\d+
        )
        (?:[eE][+-]?\d+)?
    )
    |
    #argument keyword
    [a-zA-Z_]\w*=
)
""",
    re.VERBOSE | re.MULTILINE,
)


def construitGenea(texte, listeMc):
    """
    Retourne un dictionnaire dont les cles sont des reels et les valeurs sont leurs representations textuelles.

    Realise un filtrage sur les reels :

      - Ne garde que les reels pour lesquels str ne donne pas une bonne representation.
      - Ne garde que les reels derriere un argument keyword dont le nom est dans listeMc

    >>> s = '''a=+21.3e-5*85,b=-.1234,c=81.6   , d= -8 , e=_F(x=342.67,y=-1), f=+1.1, g=(1.3,-5,1.54E-3),
    ... #POMPE_PRIMA._BOUCLE_N._2_ELEMENT_NUMERO:0239
    ... h=_F(x=34.6,y=-1)'''
    >>> construitGenea(s,['a','x'])
    {0.000213: '21.3e-5'}
    """
    d = {}
    mot = ""
    # on masque les strings et commentaires pour ne pas identifier de faux reels
    for m in number_kw_pattern.findall(maskStringsAndComments(texte)):
        if m[-1] == "=":
            # argument keyword
            mot = m[:-1]
        else:
            if mot not in listeMc:
                continue
            # valeur
            key = eval(m)
            if str(key) != m:
                d[key] = m
    return d


class ENTITE_JDC(object):
    """Classe de base pour tous les objets crees lors de la conversion
    Tout objet derive est enregistre aupres de son pere a sa creation
    """

    def __init__(self, pere):
        self.texte = ""
        pere.l_objets.append(self)

    def setText(self, texte):
        self.texte = texte

    def appendText(self, texte):
        """
        Ajoute texte a self.texte en mettant un retour chariot a la fin de texte
        """
        texte = texte + "\n"
        self.texte = self.texte + texte

    def __str__(self):
        return self.texte


class COMMENTAIRE(ENTITE_JDC):
    def __str__(self):
        """
        Retourne une chaine de caracteres representants self
        sous une forme interpretable par EFICAS
        """
        t = repr(self.texte)
        return "COMMENTAIRE(u" + t + ")\n"

        # s='COMMENTAIRE(u"""'+self.texte+'""")\n\n'
        # return s

    def appendText(self, texte):
        """
        Ajoute texte a self.texte en enlevant le # initial
        """
        texte = texte + "\n"
        if texte[0] == "#":
            self.texte = self.texte + texte[1:]
        else:
            # le diese n'est pas sur le premier caractere
            amont, aval = texte.split(
                "#", 1
            )  # on decoupe suivant la premiere occurrence de #
            self.texte = self.texte + amont + aval


class COMMANDE(ENTITE_JDC):
    def __str__(self):
        """
        Retourne self.texte
        """
        return self.texte + "\n"

    def getNbPar(self):
        """
        Retourne la difference entre le nombre de parentheses ouvrantes
        et le nombre de parentheses fermantes presentes dans self.texte
        Peut donc retourner un entier negatif
        """
        # faire attention aux commentaires contenus dans self.texte
        # qui peuvent eux-memes contenir des parentheses !!!!
        l_lignes = self.texte.split("\n")
        nb = 0
        for ligne in l_lignes:
            ligne = ligne.split("#")[0]
            # nb = nb + (string.count(ligne,'(')-string.count(ligne,')'))

            nb = nb + (ligne.count("(") - ligne.count(")"))
        return nb


class AFFECTATION(ENTITE_JDC):
    def appendText(self, texte):
        """
        Ajoute texte a self.texte en enlevant tout retour chariot et tout point virgule
        PN et tout commentaire
        """
        if texte[-1] == "\n":
            texte = texte[0:-1].rstrip()
        if texte[-1] == ";":
            texte = texte[0:-1].rstrip()
        self.texte = self.texte + texte + "\n"

    def __str__(self):
        """
        Retourne une expression de l'affectation comprehensible par ACCAS
        et exploitable par EFICAS
        """
        nom, valeur = self.texte.split("=", 1)
        n = nom.rstrip()
        nom = n.lstrip()
        if valeur[-1] == "\n":
            valeur = valeur[:-1]
        return n + " = PARAMETRE(nom='" + nom + "',valeur=" + valeur + ")\n"


class COMMANDE_COMMENTARISEE(ENTITE_JDC):
    def appendText(self, texte):
        """
        Ajoute texte a self.texte en enlevant les doubles commentaires
        """
        texte = texte.strip()
        texte = texte[2:].strip()
        self.texte = self.texte + (len(self.texte) > 0) * "\n" + texte

    def __str__(self):
        """
        Retourne une expression de la commande commentarisee comprehensible par ACCAS
        et exploitable par EFICAS
        """
        return "COMMANDE_COMM(texte=" + repr(self.texte) + ")\n"
        # return "COMMANDE_COMM(texte='''"+self.texte+"''')\n"


class AFFECTATION_EVAL(ENTITE_JDC):
    def appendText(self, texte):
        """
        Ajoute texte a self.texte en enlevant tout retour chariot
        """
        if texte[-1] == "\n":
            texte = texte[1:-1]
        self.texte = self.texte + texte

    def __str__(self):
        """
        Retourne une expression du parametre EVAL comprehensible par ACCAS
        et exploitable par EFICAS
        """
        nom, valeur = self.texte.split("=", 1)
        nom = nom.strip()
        if valeur[-1] == "\n":
            valeur = valeur[:-1]
        valeur = valeur.strip()
        return nom + " = PARAMETRE_EVAL(nom='" + nom + "',valeur='" + valeur + "')\n\n"


class PARSEUR_PYTHON(object):
    """
    Cette classe sert a generer un objet PARSEUR_PYTHON qui realise l'analyse d'un texte
    representant un JDC Python en distinguant :
      - les commentaires inter commandes
      - les affectations
      - les commandes
    """

    pattern_commande = re.compile(r"^([A-Z][a-zA-Z0-9_]+)([ \t\r\f\v]*)\(([\w\W]*)")
    pattern_eval = re.compile(r"^(EVAL)([ \t\r\f\v]*)\(([\w\W]*)")
    pattern_ligne_vide = re.compile(r"^[\t\r\f\v\n]+")
    pattern_name = re.compile(r"[a-zA-Z_]\w*")

    def __init__(self, texte):
        self.texte = texte
        self.l_objets = None
        self.appliEficas = None

    def isAffectation(self, texte):
        """
        Methode booleenne qui retourne :
           1 si le texte est celui d'une affectation dans un jeu de commandes
           0 sinon
        """
        if "=" not in texte:
            return 0
        if self.pattern_commande.match(texte):
            # cas d'une procedure ...
            return 0
        amont, aval = texte.split("=", 1)
        aval = aval.strip()

        if self.pattern_commande.match(aval):
            return 0
        else:
            s = amont.strip()
            m = self.pattern_name.match(s)
            if m is None:
                return 0
            if m.start() != 0:
                return 0
            if m.end() != len(s):
                return 0
            return 1

    def isEval(self, texte):
        """
        Methode booleenne qui retourne 1 si le texte est celui d'une affectation de type EVAL
        dans un jeu de commandes Aster, 0 sinon
        """
        if "=" not in texte:
            return 0
        if self.pattern_commande.match(texte):
            # cas d'une procedure ...
            return 0
        amont, aval = texte.split("=", 1)
        aval = aval.strip()
        if not self.pattern_commande.match(aval):
            return 0
        if self.pattern_eval.match(aval):
            return 1
        else:
            return 0

    def isCommande(self, texte):
        """
        Methode booleenne qui retourne 1 si le texte est celui d'une commande dans un jeu de commandes
        Aster, 0 sinon
        """
        if self.pattern_commande.match(texte):
            # cas d'une procedure ...
            return 1
        # A ce stade il faut avoir un OPER ou une MACRO, bref un '=' !
        if "=" not in texte:
            return 0
        # on a un texte de la forme xxxx = yyyyy
        # --> reste a analyser yyyy
        amont, aval = texte.split("=", 1)
        aval = aval.strip()
        if self.pattern_commande.match(aval):
            return 1
        else:
            return 0

    def isModificationCatalogue(self, texte):
        if self.pattern_commande.match(texte):
            return 1

    def analyse(self):
        """
        Eclate la chaine self.texte en self.l_objets une liste lignes d'instructions
        et de commentaires (parmi lesquels des instructions "commentarisees").
        """
        l_lignes = self.texte.split("\n")
        commentaire_courant = None
        commande_courante = None
        affectation_courante = None
        commande_commentarisee_courante = None
        self.l_objets = []

        # initialisation du nombre de parentheses non fermees et de commentaires non termines
        # Attention a reinitialiser en fin de ligne logique
        # Une ligne logique peut s'etendre sur plusieurs lignes physiques avec des caracteres de continuation
        # explicites ou implicites
        hangingBraces = list(emptyHangingBraces)
        hangingComments = 0

        # Masquage des commentaires et strings multilignes
        srcMasked = maskStringsAndComments("\n".join(l_lignes))
        masked_lines = srcMasked.split("\n")
        lineno = 0

        for ligne in l_lignes:
            line = masked_lines[lineno]
            lineno = lineno + 1
            # print ("ligne:",line)
            # mise a jour du nombre total de parentheses ouvertes (non fermees)
            # et du nombre de commentaires non termines
            for i in range(len(implicitContinuationChars)):
                contchar = implicitContinuationChars[i]
                numHanging = hangingBraces[i]
                hangingBraces[i] = (
                    numHanging + line.count(contchar[0]) - line.count(contchar[1])
                )

            hangingComments ^= line.count('"""') % 2
            hangingComments ^= line.count("'''") % 2
            # print (hangingComments,hangingBraces)
            if hangingBraces[0] < 0 or hangingBraces[1] < 0 or hangingBraces[2] < 0:
                raise parserException()

            if ligne.strip() == "":
                # il s'agit d'un saut de ligne
                # --> on l'ignore
                continue

            if pattern_2comments.match(ligne):
                # on a trouve une commande commentarisee : double commentaire sans rien devant a part des blancs
                if commentaire_courant:
                    # Si un commentaire ordinaire est en cours on le termine
                    commentaire_courant = None

                if commande_courante:
                    # on a un objet commentarise a l'interieur d'une commande
                    # --> non traite pour l'instant : on l'ajoute simplement a la commande courante comme
                    # un commentaire ordinaire
                    commande_courante.appendText(ligne)
                elif commande_commentarisee_courante:
                    # commande_commentarisee en cours : on ajoute la ligne
                    commande_commentarisee_courante.appendText(ligne)
                    # on a 2 commandes commentarisees de suite
                    if pattern_finComments.match(ligne):
                        commande_commentarisee_courante = None
                else:
                    # debut de commande commentarisee : on cree un objet commande_commentarisee_courante
                    commande_commentarisee_courante = COMMANDE_COMMENTARISEE(self)
                    commande_commentarisee_courante.appendText(ligne)

                # on passe a la ligne suivante
                continue

            if pattern_comment.match(ligne):
                # commentaire ordinaire avec seulement des blancs devant
                if commande_commentarisee_courante:
                    # commande_commentarisee en cours : on la clot
                    commande_commentarisee_courante = None

                if commande_courante:
                    # il s'agit d'un commentaire a l'interieur d'une commande --> on ne fait rien de special
                    # on l'ajoute au texte de la commande
                    commande_courante.appendText(ligne)
                elif commentaire_courant:
                    # il s'agit de la nieme ligne d'un commentaire entre deux commandes
                    # --> on ajoute cette ligne au commentaire courant
                    commentaire_courant.appendText(ligne)
                else:
                    # il s'agit d'un nouveau commentaire entre deux commandes
                    # --> on le cree et il devient le commentaire courant
                    commentaire_courant = COMMENTAIRE(self)
                    commentaire_courant.appendText(ligne)

                # on passe a la ligne suivante
                continue

            # la ligne contient des donnees autre qu'un eventuel commentaire
            if commentaire_courant:
                # on clot un eventuel commentaire courant
                commentaire_courant = None

            if commande_commentarisee_courante:
                # on clot une eventuelle commande commentarisee courante
                commande_commentarisee_courante = None

            if commande_courante:
                # on a une commande en cours. On l'enrichit ou on la termine
                commande_courante.appendText(ligne)
                if (
                    not linecontinueRE.search(line)
                    and (hangingBraces == emptyHangingBraces)
                    and not hangingComments
                ):
                    # la commande est terminee
                    self.analyseReel(commande_courante.texte)
                    commande_courante = None

                # on passe a la ligne suivante
                continue

            if affectation_courante != None:
                # poursuite d'une affectation
                affectation_courante.appendText(ligne)
                if (
                    not linecontinueRE.search(line)
                    and (hangingBraces == emptyHangingBraces)
                    and not hangingComments
                ):
                    # L'affectation est terminee
                    affectation_courante = None
                # on passe a la ligne suivante
                continue

            # il peut s'agir d'une commande ou d'une affectation ...
            # ou d'un EVAL !!!
            if self.isEval(ligne):
                # --> affectation de type EVAL
                if affectation_courante:
                    affectation_courante = None
                affectation = AFFECTATION_EVAL(self)
                affectation.appendText(ligne)
                # on passe a la ligne suivante
                continue

            if self.isAffectation(ligne):
                # print( '--> affectation')
                text = ligne
                # traitement des commentaires en fin de ligne
                compos = line.find("#")
                if compos > 2:
                    # commentaire en fin de ligne
                    # on cree un nouveau commentaire avant le parametre
                    COMMENTAIRE(self).appendText(ligne[compos:])
                    text = ligne[:compos]
                # si plusieurs instructions separees par des ; sur la meme ligne
                inspos = line.find(";")
                if inspos > 2:
                    # on garde seulement la premiere partie de la ligne
                    # si on a que des blancs apres le point virgule
                    if text[inspos:].strip() == ";":
                        text = text[:inspos]
                    else:
                        raise FatalError(
                            tr(
                                "Eficas ne peut pas traiter plusieurs instructions \
                                                 sur la meme ligne : %s",
                                ligne,
                            )
                        )

                affectation_courante = AFFECTATION(self)
                affectation_courante.appendText(text)
                if (
                    not linecontinueRE.search(line)
                    and (hangingBraces == emptyHangingBraces)
                    and not hangingComments
                ):
                    # L'affectation est terminee
                    affectation_courante = None
                # on passe a la ligne suivante
                continue

            if self.isCommande(ligne):
                # --> nouvelle commande
                affectation_courante = None
                commande_courante = COMMANDE(self)
                commande_courante.appendText(ligne)
                # si la commande est complete, on la termine
                if (
                    not linecontinueRE.search(line)
                    and (hangingBraces == emptyHangingBraces)
                    and not hangingComments
                ):
                    # la commande est terminee
                    self.analyseReel(commande_courante.texte)
                    commande_courante = None
                # on passe a la ligne suivante
                continue

    def enleve(self, texte):
        """Supprime de texte tous les caracteres blancs, fins de ligne, tabulations
        Le nouveau texte est retourne
        """
        i = 0
        chaine = ""
        while i < len(texte):
            if texte[i] == " " or texte[i] == "\n" or texte[i] == "\t":
                i = i + 1
            else:
                chaine = chaine + texte[i]
                i = i + 1
        return chaine

    def construitGenea(self, texte):
        indiceC = 0
        mot = ""
        dict_reel_concept = {}

        # traitement pour chaque caractere
        while indiceC < len(texte):
            c = texte[indiceC]
            if c == "," or c == "(u" or c == ")":
                mot = ""
            elif c == "=":
                # on doit trouver derriere soit une valeur soit une parenthese
                valeur = ""
                nouvelindice = indiceC + 1
                if texte[nouvelindice] != "(u":
                    # pas de parenthese ouvrante derriere un signe =, on a une valeur.
                    while texte[nouvelindice] != "," and texte[nouvelindice] != ")":
                        valeur = valeur + texte[nouvelindice]
                        nouvelindice = nouvelindice + 1
                        if nouvelindice == len(texte):
                            nouvelindice = nouvelindice - 1
                            break
                    if mot in self.appliEficas.liste_simp_reel:
                        if valeur[0] != "'":
                            try:
                                clef = eval(valeur)
                                if str(clef) != str(valeur):
                                    dict_reel_concept[clef] = valeur
                            except:
                                pass
                    mot = ""
                    indiceC = nouvelindice
                else:
                    # parenthese ouvrante derriere un signe =, on a un tuple de valeur ou de mots cles facteurs.
                    # s agit -il d un tuple
                    if texte[nouvelindice + 1] != "(u":
                        # le suivant n'est pas une parenthese ouvrante : on a un tuple de valeurs ou un mot cle facteur
                        tuple = False
                        # on avance jusqu'a la fin du tuple de valeurs ou jusqu'a la fin du premier mot cle simple
                        # contenu dans le mot cle facteur
                        while texte[nouvelindice] != "=":
                            if texte[nouvelindice] == ")":
                                tuple = True
                                break
                            else:
                                nouvelindice = nouvelindice + 1
                                if nouvelindice == len(texte):
                                    nouvelindice = nouvelindice - 1
                                    break
                        if tuple:
                            # cas du tuple de valeurs
                            valeur = texte[indiceC + 1 : nouvelindice + 1]
                            indiceC = nouvelindice + 1
                            if mot in self.appliEficas.liste_simp_reel:
                                valeur = valeur[1:-1]
                                for val in valeur.split(","):
                                    # Attention la derniere valeur est""
                                    try:
                                        if val[0] != "'":
                                            clef = eval(val)
                                            if str(clef) != str(val):
                                                dict_reel_concept[clef] = val
                                    except:
                                        pass
                            mot = ""
                    # ou de ( imbriquees
                    else:
                        # cas du mocle facteur simple ou
                        mot = ""
            else:
                mot = mot + texte[indiceC]
            indiceC = indiceC + 1
        # traitement du dernier inutile
        # c est un ;
        return dict_reel_concept

    def analyseReel(self, commande):
        nomConcept = None
        # On verifie qu on a bien un OPER
        # et pas une MACRO
        if commande.find("=") > commande.find("(u"):
            return
        if commande.find("=") > 0:
            # epure1=self.enleve(commande)
            epure1 = pattern_blancs.sub("", commande)
            nomConcept, corps = epure1.split("=", 1)
            epure2 = corps.replace("_F(u", "(u")
            # nomConcept=epure1.split(u"=")[0]
            # index=epure1.find(u"=")
            # epure2=epure1[index+1:len(epure1)].replace(u"_F(u","(u")
            # dict_reel_concept=self.construitGenea(epure2)
            if self.appliEficas:
                dict_reel_concept = construitGenea(
                    epure2, self.appliEficas.liste_simp_reel
                )
            else:
                dict_reel_concept = {}
        if nomConcept == "sansnom":
            nomConcept = ""
        if nomConcept != None:
            if len(dict_reel_concept) != 0:
                self.appliEficas.dict_reels[nomConcept] = dict_reel_concept

    def getTexte(self, appliEficas=None):
        """
        Retourne le texte issu de l'analyse
        """
        self.appliEficas = appliEficas
        try:
            # if 1:
            if not self.l_objets:
                self.analyse()
            txt = ""
            for obj in self.l_objets:
                txt = txt + str(obj)
        # else :
        except parserException:
            # Impossible de convertir le texte, on le retourne tel que
            txt = self.texte
        return txt


def test():
    # import parseur_python
    import doctest

    doctest.testmod(parseur_python)


if __name__ == "__main__":
    import time

    # fichier = 'D:/Eficas_dev/Tests/zzzz100a.comm'
    # fichier = 'U:/Eficas_dev/Tests/test_eval.comm'
    with open(fichier) as fd:
        texte = fd.read()

    class appliEficas(object):
        dict_reels = {}
        liste_simp_reel = ["VALE", "VALE_C", "GROUP_MA", "RAYON"]

    a = appliEficas()

    compile(txt, "<string>", "exec")
    print((a.dict_reels))
