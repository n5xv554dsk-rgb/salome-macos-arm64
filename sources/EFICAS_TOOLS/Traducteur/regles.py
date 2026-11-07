# -*- coding: utf-8 -*-
# Copyright (C) 2007-2026    EDF R&D
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
Définition des règles
"""

debug = 0


# --------------------
class ensembleRegles:
    # --------------------
    """
    Ensemble des règles
    """

    def __init__(self, liste_regles):
        self.liste = []
        for item in liste_regles:
            args, clefRegle = item
            r = regle(clefRegle, args)
            self.liste.append(r)

    def verif(self, commande):
        """
        Vérification
        """
        bool = 1
        for regle in self.liste:
            result = regle.verif(commande)
            bool = bool * result
        return bool


# --------------------------------
class pasDeRegle(ensembleRegles):
    # --------------------------------
    """
    Pas de règle
    """

    def __init__(self):
        pass

    def verif(self, commande):
        """
        Vérification
        """
        return 1


# ------------
class regle:
    # ------------
    """
    Règle
    """

    def __init__(self, clef_regle, args):
        self.fonction = dictionnaire_regle[clef_regle]
        self.list_args = args
        self.bool = 0

    def verif(self, commande):
        """
        Vérification
        """
        f = self.fonction(self.list_args)
        return f.verif(commande)


# ---------------------
class existeMCFParmi:
    # ---------------------
    """
    Existence du mot-clé facteur parmi la liste
    """

    def __init__(self, list_arg):
        self.listeMCF = list_arg

    def verif(self, commande):
        """
        Vérification
        """
        bool = 0
        for c in commande.childNodes:
            if c.name in self.listeMCF:
                bool = 1
                break
        return bool


# ---------------------
class nexistepasMCFParmi(existeMCFParmi):
    # ---------------------
    """
    Existence du mot-clé facteur parmi la liste
    """

    def __init__(self, list_arg):
        self.listeMCF = list_arg

    def verif(self, commande):
        """
        Vérification
        """
        bool = existeMCFParmi.verif(self, commande)
        if bool:
            return 0
        return 1


# ----------------------
class existeMCsousMCF:
    # ----------------------
    """
    Existence du mot-clé simple sous le mot-clé facteur
    """

    def __init__(self, list_arg):
        self.liste = list_arg
        self.MCF = self.liste[0]
        self.MC = self.liste[1]

    def verif(self, commande):
        """
        Vérification
        """
        bool = 0
        for mcf in commande.childNodes:
            if mcf.name != self.MCF:
                continue
            l = mcf.childNodes[:]
            l.reverse()
            for ll in l:
                for mc in ll.childNodes:
                    if mc.name != self.MC:
                        continue
                    bool = 1
        return bool


# ----------------------
class existeMCsousMCFcourant:
    # ----------------------
    """
    Existence du mot-clé simple sous le mot-clé facteur courant
    """

    def __init__(self, list_arg):
        self.liste = list_arg
        self.MC = self.liste[0]

    def verif(self, mcf):
        """
        Vérification
        """
        bool = 0
        l = mcf.childNodes[:]
        l.reverse()
        for mc in l:
            if mc.name != self.MC:
                continue
            bool = 1
        return bool


# -----------------------------------------
class nexistepasMCsousMCF(existeMCsousMCF):
    # -----------------------------------------
    """
    Absence du mot-clé simple sous le mot-clé facteur
    """

    def __init__(self, list_arg):
        existeMCsousMCF.__init__(self, list_arg)

    def verif(self, commande):
        """
        Vérification
        """
        bool = existeMCsousMCF.verif(self, commande)
        if bool:
            return 0
        return 1


# -----------------------------------------
class nexistepasMCsousMCFcourant(existeMCsousMCFcourant):
    # -----------------------------------------
    """
    Absence du mot-clé simple sous le mot-clé facteur courant
    """

    def __init__(self, list_arg):
        existeMCsousMCFcourant.__init__(self, list_arg)

    def verif(self, commande):
        """
        Vérification
        """
        bool = existeMCsousMCFcourant.verif(self, commande)
        if bool:
            return 0
        return 1


# -------------
class existe:
    # --------------
    """
    Existence du mot-clé simple
    """

    def __init__(self, list_arg):
        self.genea = list_arg

    def chercheMot(self, niveau, commande):
        """
        Recherche du mot
        """
        if commande == None:
            return 0
        if niveau == len(self.genea):
            return 1
        texte = self.genea[niveau]
        for c in commande.childNodes:
            if c.name == texte:
                niveau = niveau + 1
                return self.chercheMot(niveau, c)
        return None

    def verif(self, commande):
        """
        Vérification
        """
        bool = self.chercheMot(0, commande)
        if bool == None:
            bool = 0
        return bool


# -------------
class nexistepas:
    # --------------
    """
    Absence du mot-clé simple
    """

    def __init__(self, list_arg):
        self.genea = list_arg

    def chercheMot(self, niveau, commande):
        """
        Recherche du mot
        """
        if commande == None:
            return 0
        if niveau == len(self.genea):
            return 1
        texte = self.genea[niveau]
        for c in commande.childNodes:
            if c.name == texte:
                niveau = niveau + 1
                return self.chercheMot(niveau, c)
        return None

    def verif(self, commande):
        """
        Vérification
        """
        bool = self.chercheMot(0, commande)
        if bool:
            return 0
        return 1


# -------------------------------
class MCsousMCFaPourValeur:
    # ------------------------------
    """
    Égalité du mot-clé simple à une valeur sous le mot-clé facteur
    """

    def __init__(self, list_arg):
        assert len(list_arg) == 4
        self.genea = list_arg[0:-2]
        self.MCF = list_arg[0]
        self.MC = list_arg[1]
        self.Val = list_arg[2]
        self.Jdc = list_arg[3]

    def verif(self, commande):
        """
        Vérification
        """
        bool = 0
        for mcf in commande.childNodes:
            if mcf.name != self.MCF:
                continue
            l = mcf.childNodes[:]
            l.reverse()
            for ll in l:
                for mc in ll.childNodes:
                    if mc.name != self.MC:
                        continue
                    TexteMC = mc.getText(self.Jdc)
                    if TexteMC.find(self.Val) < 0:
                        continue
                    bool = 1
        return bool


# -------------------------------
class MCsousMCFcourantaPourValeur:
    # ------------------------------
    """
    Égalité du mot-clé simple à une valeur sous le mot-clé facteur courant
    """

    def __init__(self, list_arg):
        assert len(list_arg) == 3
        self.genea = list_arg[0:-1]
        self.MC = list_arg[0]
        self.Val = list_arg[1]
        self.Jdc = list_arg[2]

    def verif(self, mcf):
        """
        Vérification
        """
        bool = 0
        l = mcf.childNodes[:]
        l.reverse()
        for mc in l:
            if mc.name != self.MC:
                continue
            TexteMC = mc.getText(self.Jdc)
            if TexteMC.find(self.Val) < 0:
                continue
            bool = 1
        return bool


# -----------------------------
class MCsousMCFaPourValeurDansListe:
    # ----------------------------
    """
    Égalité du mot-clé simple à une valeur dans une liste
    sous le mot-clé facteur
    """

    def __init__(self, list_arg):
        assert len(list_arg) == 4
        self.genea = list_arg[0:-2]
        self.MCF = list_arg[0]
        self.MC = list_arg[1]
        self.LVal = list_arg[2]
        self.Jdc = list_arg[3]

    def verif(self, commande):
        """
        Vérification
        """
        bool = 0
        for mcf in commande.childNodes:
            if mcf.name != self.MCF:
                continue
            l = mcf.childNodes[:]
            l.reverse()
            for ll in l:
                for mc in ll.childNodes:
                    if mc.name != self.MC:
                        continue
                    TexteMC = mc.getText(self.Jdc)
                    for Val in self.LVal:
                        if TexteMC.find(Val) < 0:
                            continue
                        bool = 1
        return bool


# -----------------------------
class MCsousMCFcourantaPourValeurDansListe:
    # ----------------------------
    """
    Égalité du mot-clé simple à une valeur dans une liste
    sous le mot-clé facteur
    """

    def __init__(self, list_arg):
        assert len(list_arg) == 3
        self.genea = list_arg[0:-1]
        self.MC = list_arg[0]
        self.LVal = list_arg[1]
        self.Jdc = list_arg[2]

    def verif(self, mcf):
        """
        Vérification
        """
        bool = 0
        l = mcf.childNodes[:]
        l.reverse()
        for mc in l:
            if mc.name != self.MC:
                continue
            TexteMC = mc.getText(self.Jdc)
            for Val in self.LVal:
                if TexteMC.find(Val) < 0:
                    continue
                bool = 1
        return bool


# -----------------------------------------
class MCsousMCFcourantnaPasPourValeurDansListe(MCsousMCFcourantaPourValeurDansListe):
    # -----------------------------------------
    """
    Non égalité du mot-clé simple à une valeur dans une liste
    sous le mot-clé facteur
    """

    def __init__(self, list_arg):
        MCsousMCFcourantaPourValeurDansListe.__init__(self, list_arg)

    def verif(self, commande):
        bool = MCsousMCFcourantaPourValeurDansListe.verif(self, commande)
        if bool:
            return 0
        return 1


# -----------------------------------------
class MCsousMCFnaPasPourValeurDansListe(MCsousMCFaPourValeurDansListe):
    # -----------------------------------------
    """
    Non égalité du mot-clé simple à une valeur dans une liste
    sous le mot-clé facteur
    """

    def __init__(self, list_arg):
        MCsousMCFaPourValeurDansListe.__init__(self, list_arg)

    def verif(self, commande):
        bool = MCsousMCFaPourValeurDansListe.verif(self, commande)
        if bool:
            return 0
        return 1


# ------------------------------
class MCaPourValeur:
    # ------------------------------
    """
    Égalité du mot-clé à une valeur
    """

    def __init__(self, list_arg):
        assert len(list_arg) == 3
        self.MC = list_arg[0]
        self.Val = list_arg[1]
        self.Jdc = list_arg[2]

    def verif(self, commande):
        """
        Vérification
        """
        bool = 0
        for mc in commande.childNodes:
            if mc.name != self.MC:
                continue
            TexteMC = mc.getText(self.Jdc)
            if TexteMC.find(self.Val) < 0:
                continue
            bool = 1
        return bool


# -----------------------------------------
class MCnaPasPourValeur(MCaPourValeur):
    # -----------------------------------------
    """
    Non égalité du mot-clé à une valeur
    """

    def __init__(self, list_arg):
        MCaPourValeur.__init__(self, list_arg)

    def verif(self, commande):
        """
        Vérification
        """
        bool = MCaPourValeur.verif(self, commande)
        if bool:
            return 0
        return 1


# ------------------------------
class MCaPourValeurDansListe:
    # ------------------------------
    """
    Égalité du mot-clé à une valeur dans une liste
    """

    def __init__(self, list_arg):
        assert len(list_arg) == 3
        self.MC = list_arg[0]
        self.LVal = list_arg[1]
        self.Jdc = list_arg[2]

    def verif(self, commande):
        """
        Vérification
        """
        bool = 0
        for mc in commande.childNodes:
            if mc.name != self.MC:
                continue
            TexteMC = mc.getText(self.Jdc)
            # print "TexteMC=",type(TexteMC),TexteMC
            # print "LVal=",type(self.LVal),self.LVal
            for Val in self.LVal:
                # print "Val=",type(Val),Val
                # print "Find",TexteMC.find(Val)
                if TexteMC.find(Val) < 0:
                    continue
                bool = 1
        return bool


# -----------------------------------------
class MCnaPasPourValeurDansListe(MCaPourValeurDansListe):
    # -----------------------------------------
    """
    Non égalité du mot-clé à une valeur dans une liste
    """

    def __init__(self, list_arg):
        MCaPourValeurDansListe.__init__(self, list_arg)

    def verif(self, commande):
        """
        Vérification
        """
        bool = MCaPourValeurDansListe.verif(self, commande)
        if bool:
            return 0
        return 1


dictionnaire_regle = {
    "existe": existe,
    "nexistepas": nexistepas,
    "existeMCFParmi": existeMCFParmi,
    "nexistepasMCFParmi": nexistepasMCFParmi,
    "existeMCsousMCF": existeMCsousMCF,
    "nexistepasMCsousMCF": nexistepasMCsousMCF,
    "MCsousMCFaPourValeur": MCsousMCFaPourValeur,
    "MCsousMCFaPourValeurDansListe": MCsousMCFaPourValeurDansListe,
    "MCaPourValeur": MCaPourValeur,
    "MCnaPasPourValeur": MCnaPasPourValeur,
    "existeMCsousMCFcourant": existeMCsousMCFcourant,
    "nexistepasMCsousMCFcourant": nexistepasMCsousMCFcourant,
    "MCsousMCFcourantaPourValeur": MCsousMCFcourantaPourValeur,
    "MCsousMCFcourantaPourValeurDansListe": MCsousMCFcourantaPourValeurDansListe,
    "MCsousMCFcourantnaPasPourValeurDansListe": MCsousMCFcourantnaPasPourValeurDansListe,
    "MCsousMCFnaPasPourValeurDansListe": MCsousMCFnaPasPourValeurDansListe,
    "MCaPourValeurDansListe": MCaPourValeurDansListe,
    "MCnaPasPourValeurDansListe": MCnaPasPourValeurDansListe,
}


SansRegle = pasDeRegle()
