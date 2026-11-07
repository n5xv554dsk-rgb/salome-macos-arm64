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
   Ce module contient la classe mixin MCBLOC qui porte les methodes
   necessaires pour realiser la Accas.validation d'un objet de type MCBLOC
   derive de OBJECT.

   Une classe mixin porte principalement des traitements et est
   utilisee par heritage multiple pour composer les traitements.
"""

# Modules EFICAS
from . import V_MCCOMPO


class MCBLOC(V_MCCOMPO.MCCOMPO):

    """
    Cette classe a un attribut de classe :

    - txt_nat qui sert pour les comptes-rendus lies a cette classe
    """

    txt_nat = "Bloc :"

    def isValid(self, sd="oui", cr="non"):
        """
        Methode pour verifier la validite du MCBLOC. Cette methode
        peut etre appelee selon plusieurs modes en fonction de la valeur
        de sd et de cr.

        Si cr vaut oui elle cree en plus un compte-rendu
        sd est present pour compatibilite de l'interface mais ne sert pas
        """
        if self.state == "unchanged":
            return self.valid
        else:
            valid = 1
            if hasattr(self, "valid"):
                old_valid = self.valid
            else:
                old_valid = None
            for child in self.mcListe:
                if not child.isValid():
                    valid = 0
                    break
            # Apres avoir verifie la validite de tous les sous-objets, on verifie
            # la validite des regles
            text_erreurs, test_regles = self.verifRegles()
            if not test_regles:
                if cr == "oui":
                    self.cr.fatal("Regle(s) non respectee(s) : %s" % text_erreurs)
                valid = 0
            self.valid = valid
            self.state = "unchanged"
            if not old_valid or old_valid != self.valid:
                self.initModifUp()
            return self.valid
