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
from builtins import str
from builtins import object

import re, sys, types

from Accas.processing.P_CR import CR
from Accas.extensions.eficas_translation import tr


# def group(*choices): return '(' + ''.join(choices, '|') + ')'
# def any(*choices): return apply(group, choices) + '*'
# def maybe(*choices): return apply(group, choices) + '?'

Intnumber = r"[1-9]\d*"
Exponent = r"[eEdD][-+]?\d+"
Expfloat = r"[1-9]\d*" + Exponent
# Pointfloat = group(r'\d+\.\d*', r'\.\d+') + maybe(Exponent)
# Floatnumber = group(Pointfloat, Expfloat)
Pointfloat = r"(\d+\.\d*|\.\d+)([eEdD][-+]?\d+)?"
Floatnumber = r"((\d+\.\d*|\.\d+)([eEdD][-+]?\d+)?|[1-9]\d*[eEdD][-+]?\d+)"


pat_number = re.compile(r"^([+-]?)([0-9]+)(\.\d*)?(.*)")
pat_number_complet = re.compile(r"^([+-]?)([0-9]+)(\.\d*)?([eEdD][+-]?\d+)(.*)")
pat_constante = re.compile(r"^([+-]?)([a-zA-Z][a-zA-Z_0-9]*\s*)(.*)")


def cmp_function(arg1, arg2):
    """
    Fonction de comparaison permettant de classer les listes de
    fonctions unaires et binaires selon la longueur de leurs arguments
    On classe les arguments les plus longs en premier
    """
    if len(arg1) > len(arg2):
        return -1
    elif len(arg1) == len(arg2):
        return 0
    else:
        return 1


class InterpreteurException(Exception):
    """
    Classe servant a definir les exceptions levees par l'interpreteur de formule
    """

    def __init__(self, args=None):
        self.args = args

    def __str__(self):
        return str(self.args)


class Interpreteur_Formule(object):
    """
    Cette classe sert a construire un interpreteur de formules Aster
    """

    l_fonctions_binaires = ["+", "-", "*", "/", "**", "=", "MOD", "MIN", "MAX", "ATAN2"]
    l_fonctions_unaires = [
        "+",
        "-",
        "INT",
        "REAL",
        "AIMAG",
        "ABS",
        "SQRT",
        "EXP",
        "LOG",
        "LOG10",
        "SIN",
        "COS",
        "TAN",
        "ASIN",
        "ACOS",
        "ATAN",
        "SINH",
        "COSH",
        "TANH",
        "HEAVYSID",
    ]
    l_constantes = ["PI", "RD_RG", "DG_RD"]

    def __init__(self, formule=None, constantes=[], fonctions=[], parent=None):
        """
        Constructeur d'interpreteurs de formule Aster
        - formule = tuple (nom,type,arguments,corps)
        - constantes = liste des noms de constantes externes
        - fonctions_unaires = dictionnaire {nom_fonction externe : nb arguments de cette fonction}
        """
        self.new_constantes = constantes
        self.new_fonctions_unaires = fonctions
        self.cr = CR()
        self.l_operateurs = []
        self.parent = parent
        self.l_children = []
        if formule:
            self.setFormule(formule)
        if self.parent:
            self.parent.enregistre(self)

    def setFormule(self, formule):
        """
        Stocke formule (tuple) dans l'attribut t_formule
        Methode externe
        """
        # if type(formule) != types.TupleType:
        if type(formule) != types.tuple:
            raise InterpreteurException(
                tr("La formule passee a l'interpreteur doit etre sous forme de tuple")
            )
        self.t_formule = formule
        # self.initCr()
        self.modifyListes()
        self.ordonneListes()

    def initCr(self):
        """
        Initialise le cr,cad valorise les chaines debut et fin
        """
        nom = self.t_formule[0]
        if nom:
            if nom[0] in ("+", "-"):
                nom = nom[1:]
        self.cr.debut = tr("Debut Fonction %s", nom)
        self.cr.fin = tr("Fin Fonction %s", nom)

    def str(self):
        """
        Retourne une liste de chaines de caracteres representant la formule
        """
        l_txt = []
        l_txt.append(self.t_formule[0])
        for oper in self.l_operateurs:
            # oper est ici une liste decrivant oper
            txt = []
            for elem in oper:
                txt.append(str(elem))
            l_txt.append(txt)
        return l_txt

    def report(self, decalage=1):
        """
        Retourne le rapport de FORMULE
        """
        txt = self.cr.report()
        return txt

    def enregistre(self, fils):
        """
        Enregistre un operateur fils dans la liste des children
        """
        self.l_children.append(fils)
        self.cr.add(fils.cr)

    def isValid(self):
        """
        Booleenne qui retourne 1 si la formule est valide, 0 sinon
        Methode externe
        """
        self.l_operateurs = []
        self.cr.purge()  # on vide le cr
        self.initCr()  # on initialise le cr
        self.interpreteFormule()
        return self.cr.estvide()

    def interpreteFormule(self):
        """
        Realise l'interpretation du corps de la formule
        """
        texte = self.t_formule[3]
        if not texte:
            return
        if type(texte) != list:
            texte = [
                texte,
            ]
        for text_arg in texte:
            text_arg = text_arg.replace("\n", "")
            # Enleve les espaces
            text_arg = text_arg.replace(" ", "")
            try:
                self.l_operateurs.append(self.splitOperateurs(text_arg))
            except InterpreteurException as e:
                self.cr.fatal(e.__str__())

    def modifyListes(self):
        """
        Modifie la liste des constantes en lui ajoutant le nom des parametres
        de la fonction a interpreter
        """
        args = self.t_formule[2]
        # l'interpreteur de formule sert aussi a evaluer les EVAL
        # dans ce cas il n'y a pas d'arguments puisque pas de fonction ...
        if args:
            args = args[1:-1]  # on enleve les parentheses ouvrante et fermante
            l_args = args.split(",")
            for arg in l_args:
                typ, nom = arg.split(":")
                nom = nom.strip()
                self.l_constantes.append(nom)
        # on considere que les fonctions unaires de base sont toutes a un seul argument :
        l_f = []
        self.d_fonctions_unaires = {}
        for fct in self.l_fonctions_unaires:
            self.d_fonctions_unaires[fct] = 1
        # on ajoute les constantes externes
        for cte in self.new_constantes:
            self.l_constantes.append(cte)
        # on ajoute les fonctions unaires externes au dictionnaire des fonctions unaires
        for new_fonc in self.new_fonctions_unaires:
            self.d_fonctions_unaires[new_fonc[0]] = self.getNbArgs(new_fonc)
        # self.d_fonctions_unaires.update(self.new_fonctions_unaires)
        self.l_fonctions_unaires = list(self.d_fonctions_unaires.keys())

    def ordonneListes(self):
        """
        Ordonne les listes de fonctions unaires et binaires
        """
        self.l_fonctions_binaires.sort(cmp_function)
        self.l_fonctions_unaires.sort(cmp_function)
        self.l_constantes.sort(cmp_function)

    def splitOperateurs(self, texte):
        """
        Splite le texte passe en argument en operateurs plus elementaires.
        N'analyse pas l'interieur des operateurs (ne fait qu'une passe)
        """
        l_operateurs = []
        texte = texte.strip()
        # on recherche un nombre en debut de texte
        try:
            oper, reste = self.chercheNombre(texte)
        except InterpreteurException as e:
            raise InterpreteurException(e.__str__())
        if not oper:
            # on recherche une constante en debut de texte
            try:
                oper, reste = self.chercheConstante(texte)
            except InterpreteurException as e:
                raise InterpreteurException(e.__str__())
            if not oper:
                # on recherche une expression entre parentheses...
                try:
                    oper, reste = self.chercheExpressionEntreParentheses(texte)
                except InterpreteurException as e:
                    raise InterpreteurException(e.__str__())
                if not oper:
                    # on recherche le debut d'un operateur unaire en debut de texte
                    try:
                        oper, reste = self.chercheOperateurUnaire(texte)
                    except InterpreteurException as e:
                        raise InterpreteurException(e.__str__())
                    if not oper:
                        type_objet, nom_objet = self.getType(texte)
                        if type_objet == "constante":
                            raise InterpreteurException(
                                "Constante %s inconnue" % nom_objet
                            )
                        elif type_objet == "fonction":
                            raise InterpreteurException(
                                "Fonction %s inconnue dans %s" % (nom_objet, texte)
                            )
                        else:
                            raise InterpreteurException(
                                "Impossible d'interpreter : %s" % texte
                            )
        # on a trouve un operateur (nombre, constante ou unaire)
        # il faut encore verifier que l'on est en fin de texte ou qu'il est bien suivi
        # d'un operateur binaire
        l_operateurs.append(oper)
        if reste:
            texte = reste.strip()
            oper, reste = self.chercheOperateurBinaire(texte)
            if not oper:
                # on a un reste et pas d'operateur binaire --> erreur
                raise InterpreteurException(
                    "L'operateur %s doit etre suivi d'un operateur binaire"
                    % l_operateurs[-1]
                )
            else:
                # on a bien trouve un operateur binaire:
                l_operateurs.append(oper)
                # il faut recommencer l'analyse du reste par splitOperateurs ...
                try:
                    l_op = self.splitOperateurs(reste)
                except InterpreteurException as e:
                    raise InterpreteurException(e.__str__())
                l_operateurs.extend(l_op)
                return l_operateurs
        else:
            # on a fini d'analyser texte
            return l_operateurs

    def chercheNombre(self, texte):
        """
        Cherche un nombre en debut de texte
        Retourne ce nombre et le reste ou None et le texte initial
        Peut lever une InterpreteurException dans le cas ou le nombre n'est pas valide
        """
        texte = texte.strip()
        m = pat_number_complet.match(texte)
        if m:
            # on a trouve un nombre avec exposant
            l_groups = m.groups()
            sgn = l_groups[0]
            nb = l_groups[1]
            if l_groups[2]:
                nb = nb + l_groups[2]
            if l_groups[3]:
                nb = nb + l_groups[3]
            nombre = sgn + nb
            return nombre, l_groups[4]
        else:
            m = pat_number.match(texte)
            if m:
                # on a trouve un nombre sans exposant
                l_groups = m.groups()
                sgn = l_groups[0]
                nb = l_groups[1]
                if l_groups[2]:
                    nb = nb + l_groups[2]
                nombre = sgn + nb
                # il faut verifier si ce nombre n'est pas suivi d'un exposant incomplet ...
                reste = l_groups[3].strip()
                if reste == "":
                    return nombre, l_groups[3]
                if reste[0] in ("e", "E", "d", "D"):
                    raise InterpreteurException(
                        "La syntaxe de l'exposant de %s est erronee " % nb
                    )
                else:
                    return nombre, l_groups[3]
            else:
                # on n'a pas trouve de nombre
                return None, texte

    def chercheConstanteOld(self, texte):
        """
        Recherche une constante en debut de texte parmi la liste des constantes.
        Retourne le texte representant la constante et le reste du texte ou
        Retourne None,texte si aucune constante trouvee
        """
        txt = None
        texte = texte.strip()
        for cte in self.l_constantes:
            index = texte.find(cte)
            # if index == 0 : print 'on a trouve %s dans %s en %d' %(cte,texte,index)
            if index == 0:
                txt = cte
                zz, reste = texte.split(cte, 1)
                break
        if txt:
            return txt, reste
        else:
            # aucune constante trouvee
            return None, texte

    def chercheConstante(self, texte):
        """
        Recherche une constante en debut de texte parmi la liste des constantes.
        Retourne le texte representant la constante et le reste du texte ou
        Retourne None,texte si aucune constante trouvee
        """
        txt = None
        texte = texte.strip()
        m = pat_constante.match(texte)
        if m:
            # on a trouve un identificateur en debut de texte
            l_groups = m.groups()
            sgn = l_groups[0]
            identificateur = l_groups[1].strip()
            reste = l_groups[2]
            # il faut verifier qu'il ne s'agit pas d'un appel a une fonction
            if reste:
                if reste[0] == "(":
                    # --> appel de fonction
                    return None, texte
            # il faut encore verifier qu'elle est bien dans la liste des constantes...
            if identificateur not in self.l_constantes:
                raise InterpreteurException(
                    "La constante %s est inconnue dans %s" % (identificateur, texte)
                )
            else:
                return sgn + identificateur, reste
        else:
            # aucune constante trouvee
            return None, texte

    def chercheArgs(self, texte):
        """
        Cherche au debut de texte une liste d'arguments entre parentheses
        """
        if texte[0] != "(":
            return None, texte
        else:
            n = 0
            cpt = 1
            while cpt != 0:
                n = n + 1
                if n >= len(texte):
                    # on a atteint la fin de texte sans avoir trouve la parenthese fermante --> erreur
                    raise InterpreteurException(
                        "Manque parenthese fermante dans %s" % texte
                    )
                if texte[n] == "(":
                    cpt = cpt + 1
                elif texte[n] == ")":
                    cpt = cpt - 1
            if n + 1 < len(texte):
                return texte[0 : n + 1], texte[n + 1 :]
            else:
                # on a fini d'analyser le texte : reste = None
                return texte, None

    def chercheOperateurUnaireOld(self, texte):
        """
        Cherche dans texte un operateur unaire
        """
        txt = None
        texte = texte.strip()
        for oper in self.l_fonctions_unaires:
            index = texte.find(oper)
            if index == 0:
                txt = oper
                zz, reste = texte.split(oper, 1)
                break
        if txt:
            # print 'on a trouve :',txt
            operateur = txt
            texte = reste
            try:
                args, reste = self.chercheArgs(texte)
            except InterpreteurException as e:
                raise InterpreteurException(e.__str__())
            if not args:
                # operateur unaire sans arguments
                raise InterpreteurException(
                    "operateur unaire  %s sans arguments" % operateur
                )
            else:
                # operateur = operateur+args
                args = self.splitArgs(txt, args, self.d_fonctions_unaires[operateur])
                formule_operateur = (txt, "", self.t_formule[2], args)
                operateur = Interpreteur_Formule(
                    formule=formule_operateur,
                    constantes=self.new_constantes,
                    fonctions_unaires=self.new_fonctions_unaires,
                    parent=self,
                )
                operateur.interpreteFormule()
                texte = reste
                return operateur, reste
        else:
            # aucun operateur unaire trouve
            return None, texte

    def chercheOperateurUnaire(self, texte):
        """
        Cherche dans texte un operateur unaire
        """
        txt = None
        texte = texte.strip()
        m = pat_constante.match(texte)
        if m:
            # on a trouve un identificateur en debut de texte
            # il faut encore verifier que l'on a bien a faire a un appel de fonction ...
            l_groups = m.groups()
            sgn = l_groups[0]
            identificateur = l_groups[1].strip()
            reste = l_groups[2]
            try:
                args, reste = self.chercheArgs(reste)
            except InterpreteurException as e:
                raise InterpreteurException(e.__str__())
            if not args:
                # operateur unaire sans arguments
                # en principe on ne doit jamais etre dans ce cas car il est deja trappe par chercheConstante ...
                raise InterpreteurException(
                    "Fonction %s sans arguments !" % identificateur
                )
            else:
                # il faut encore verifier que l'on a bien a faire a une fonction connue
                if identificateur not in self.l_fonctions_unaires:
                    raise InterpreteurException(
                        "Fonction %s inconnue dans %s !" % (identificateur, texte)
                    )
                args = self.splitArgs(
                    identificateur, args, self.d_fonctions_unaires[identificateur]
                )
                formule_operateur = (sgn + identificateur, "", self.t_formule[2], args)
                operateur = Interpreteur_Formule(
                    formule=formule_operateur,
                    constantes=self.new_constantes,
                    fonctions=self.new_fonctions_unaires,
                    parent=self,
                )
                operateur.interpreteFormule()
                texte = reste
                return operateur, reste
        elif texte[0] == "-":
            # Il faut pouvoir trapper les expressions du type exp(-(x+1)) ...
            try:
                args, reste = self.chercheArgs(texte[1:])
            except InterpreteurException as e:
                raise InterpreteurException(e.__str__())
            if not args:
                # Il ne s'agit pas de '-' comme operateur unaire --> on retourne None
                return None, texte
            else:
                identificateur = "-"
                args = self.splitArgs(
                    identificateur, args, self.d_fonctions_unaires[identificateur]
                )
                formule_operateur = (identificateur, "", self.t_formule[2], args)
                operateur = Interpreteur_Formule(
                    formule=formule_operateur,
                    constantes=self.new_constantes,
                    fonctions=self.new_fonctions_unaires,
                    parent=self,
                )
                operateur.interpreteFormule()
                texte = reste
                return operateur, reste
        else:
            return None, texte

    def chercheOperateurBinaire(self, texte):
        """
        Cherche dans texte un operateur unaire
        """
        txt = None
        texte = texte.strip()
        for oper in self.l_fonctions_binaires:
            index = texte.find(oper)
            # if index != -1 : print 'on a trouve %s dans %s en %d' %(oper,texte,index)
            if index == 0:
                txt = oper
                zz, reste = texte.split(oper, 1)
                break
        if txt:
            return txt, reste
        else:
            # aucun operateur unaire trouve
            return None, texte

    def chercheExpressionEntreParentheses(self, texte):
        """
        Cherche en debut de texte une expression entre parentheses
        """
        args, reste = self.chercheArgs(texte.strip())
        if not args:
            return None, texte
        else:
            # on a trouve une expression entre parentheses en debut de texte
            # --> on retourne un objet Interpreteur_Formule
            formule_operateur = ("", "", self.t_formule[2], args[1:-1])
            operateur = Interpreteur_Formule(
                formule=formule_operateur,
                constantes=self.new_constantes,
                fonctions=self.new_fonctions_unaires,
                parent=self,
            )
            operateur.interpreteFormule()
            texte = reste
            return operateur, reste

    def splitArgs(self, nom_fonction, args, nb_args):
        """
        Tente de partager args en nb_args elements
        Retourne une liste de chaines de caracteres (liste de longueur nb_args)
        """
        args = args[1:-1]  # on enleve les parentheses ouvrante et fermante
        if nb_args == 1:
            return args
        l_args = args.split(",")
        if len(l_args) != nb_args:
            raise InterpreteurException(
                "La fonction %s requiert %d arguments : %d fourni(s)"
                % (nom_fonction, nb_args, len(l_args))
            )
        else:
            return l_args

    def getType(self, texte):
        """
        Retourne le type de l'objet defini dans texte, a savoir:
        - constante
        - fonction
        - unknown
        et son nom
        """
        texte = texte.strip()
        if "(" not in texte:
            return "constante", texte
        if texte[-1] != ")":
            return "unknown", ""
        nom_oper, args = texte.split("(", 1)
        return "fonction", nom_oper

    def getNbArgs(self, formule):
        """
        Retourne le nombre d'arguments dans la definition de formule (sous forme de tuple)
        """
        args = formule[2][1:-1]  # on enleve les parentheses ouvrante et fermante
        l_args = args.split(",")
        return len(l_args)


if __name__ == "__main__":
    constantes = ["FREQ3", "AMOR1"]
    fonctions_unaires = [
        ("ACC", "REEL", "(REEL:x)", """bidon"""),
    ]
    f1 = ("f1", "REEL", "(REEL:x)", """SIN(x)+3*x""")
    f2 = ("f2", "REEL", "(REEL:x)", """ATAN(x+3)+3*x""")
    f3 = ("f3", "REEL", "(REEL:INST)", """ACC(INST,FREQ3,AMOR1)""")
    f4 = ("f4", "REEL", "(REEL:INST)", """ACC(INST,FREQ2,AMOR1)""")
    f5 = ("f5", "REEL", "(REEL:INST,REEL:Y)", """ACC(INST,FREQ3,AMOR1)+Y*INST""")
    f6 = ("f6", "REEL", "(REEL:x)", """(x+ 3)/ 35.698""")
    f7 = ("f7", "REEL", "(REEL:x)", """(x+ 3)/ 35.698E-10""")
    f8 = ("f8", "REEL", "(REEL:x)", """(x+ 3)/ 35.698E""")
    f9 = (
        "f9",
        "REEL",
        "(REEL:INSTA,REEl:INSTB)",
        """2.*SIN((PI/4)+((INSTA-INSTB)/2.))* COS((PI/4)-((INSTA+INSTB)/2.))""",
    )
    f10 = ("f10", "REEL", "(REEL:X)", """EXP(-(X+1))""")
    for formule in (f1, f2, f3, f4, f5, f6, f7, f8, f9, f10):
        i = Interpreteur_Formule(
            formule=formule, constantes=constantes, fonctions=fonctions_unaires
        )
        txt = i.str()
        print(("\nformule %s = %s" % (str(formule), txt)))
        # if i.isValid() :
        #    print "\n\tPas d'erreur !"
        # else:
        #    print i.report()
