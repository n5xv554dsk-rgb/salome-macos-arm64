# coding=utf-8
# ======================================================================
# COPYRIGHT (C) 1991 - 2026  EDF R&D                  WWW.CODE-ASTER.ORG
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

from builtins import object

class ENSEMBLE(object):

    """
    La regle verifie que si un mot-cle de self.mcs est present
        parmi les elements de args tous les autres doivent etre presents.

    Ces arguments sont transmis a la regle pour Accas.validation sous la forme
    d'une liste de noms de mots-cles ou d'un dictionnaire dont
    les cles sont des noms de mots-cles.
    """

    def verif(self, args):
        """
        La methode verif effectue la verification specifique a la regle.
        args peut etre un dictionnaire ou une liste. Les elements de args
        sont soit les elements de la liste soit les cles du dictionnaire.
        """
        #  on compte le nombre de mots cles presents, il doit etre egal a la liste
        #  figurant dans la regle
        text = ""
        test = 1
        args = self.listeToDico(args)
        pivot = None
        for mc in self.mcs:
            if mc in args:
                pivot = mc
                break
        if pivot:
            for mc in self.mcs:
                if mc != pivot:
                    if not mc in args:
                        text = (
                            text
                            + "- "
                            + pivot
                            + " etant present, "
                            + mc
                            + " doit etre present"
                            + "\n"
                        )
                        test = 0
        return text, test
