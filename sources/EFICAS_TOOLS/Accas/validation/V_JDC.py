# coding=utf-8
# ======================================================================
# COPYRIGHT (C) 2007-2026  EDF R&D
# THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY
# IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
# THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR
# (AT YOUR OPTION) ANY LATER VERSION.
#
# THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
# WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
# MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
# GENERAL PUBLIC LICENSE FOR MORE DETAILS.
#
# YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE
# ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,
#    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
#
#
# ======================================================================
"""
   Ce module contient la classe mixin JDC qui porte les methodes
   necessaires pour realiser la Accas.validation d'un objet de type JDC
   derive de OBJECT.

   Une classe mixin porte principalement des traitements et est
   utilisee par heritage multiple pour composer les traitements.
"""

# Modules EFICAS
from . import V_MCCOMPO
from Accas.processing.P_Exception import AsException
from Accas.processing.P_utils import AsType


class JDC(V_MCCOMPO.MCCOMPO):

    """ """

    def report(self):
        """
        Methode pour generation d un rapport de validite
        """
        self.cr.purge()
        # self.cr.debut = "DEBUT CR Accas.validation : " + self.nom
        # self.cr.fin = "FIN CR Accas.validation :" + self.nom
        self.cr.debut = "BEGIN Accas.validation report : " + self.nom
        self.cr.fin = "END Accas.validation report :" + self.nom
        for e in self.etapes:
            if e.isActif():
                self.cr.add(e.report())
        self.state = "modified"
        self.isValid(cr="oui")
        return self.cr

    def isValid(self, cr="non"):
        """
        Methode booleenne qui retourne 0 si le JDC est invalide, 1 sinon
        """
        # FR : on prend en compte l'etat du JDC ('unchanged','modified','undetermined')
        # afin d'accelerer le test de validite du JDC
        if self.state == "unchanged":
            return self.valid
        else:
            valid = 1
            texte, test = self.verifRegles()
            if test == 0:
                if cr == "oui":
                    if texte != "" and (" ".strip(texte) == ""):
                        self.cr.fatal(texte)
                    else:
                        self.cr.fatal(" ".strip(texte))
                valid = 0
            if valid:
                for e in self.etapes:
                    if not e.isActif():
                        continue
                    if not e.isValid():
                        valid = 0
                        break
            self.state = "unchanged"
            self.valid = valid
            return self.valid

    def getValid(self, cr="non"):
        if self.state == "unchanged":
            return self.valid
        else:
            return self.isValid()

    def verifRegles(self):
        """
        Effectue la verification de validite des regles du jeu de commandes
        """
        noms_etapes = [etape.nom for etape in self.etapes]
        texte_global = ""
        test_global = 1
        for regle in self.regles:
            texte, test = regle.verif(noms_etapes)
            texte_global = texte_global + texte
            test_global = test_global * test
        return texte_global, test_global
