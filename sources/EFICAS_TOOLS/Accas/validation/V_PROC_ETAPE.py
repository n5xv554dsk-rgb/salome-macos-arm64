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
# ======================================================================
"""
   Ce module contient la classe mixin PROC_ETAPE qui porte les methodes
   necessaires pour realiser la Accas.validation d'un objet de type PROC_ETAPE
   derive de OBJECT.

   Une classe mixin porte principalement des traitements et est
   utilisee par heritage multiple pour composer les traitements.
"""
# Modules EFICAS
from . import V_ETAPE
from Accas.processing.P_Exception import AsException
from Accas.processing.P_utils import AsType
from Accas.extensions.eficas_translation import tr


class PROC_ETAPE(V_ETAPE.ETAPE):

    """
    On reutilise les methodes report,verifRegles
    de ETAPE par heritage.
    """

    def isValid(self, sd="oui", cr="non"):
        """
        Methode pour verifier la validite de l'objet PROC_ETAPE. Cette methode
        peut etre appelee selon plusieurs modes en fonction de la valeur
        de sd et de cr (sd n'est pas utilise).

        Si cr vaut oui elle cree en plus un compte-rendu.

        Cette methode a plusieurs fonctions :

         - retourner un indicateur de validite 0=non, 1=oui

         - produire un compte-rendu : self.cr

         - propager l'eventuel changement d'etat au parent
        """
        if CONTEXT.debug:
            print(("ETAPE.isValid ", self.nom))
        if self.state == "unchanged":
            return self.valid
        else:
            valid = self.validChild()
            valid = valid * self.validRegles(cr)
            if self.reste_val != {}:
                if not hasattr(self, "cr"):
                    from Accas.processing.P_CR import CR

                    self.cr = CR()
                if cr == "oui":
                    self.cr.fatal(
                        tr("unknown keywords : %s")
                        % ",".join(list(self.reste_val.keys()))
                    )
                valid = 0
            self.setValid(valid)
            return self.valid
