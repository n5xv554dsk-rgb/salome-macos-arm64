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
    Ce package fournit les classes de base d'EFICAS.
    Ces classes permettent d'effectuer les operations basiques :

      - la creation
      - la verification des definitions
      - la gestion d'objets de type OBJECT a partir d'une definition de type ENTITE
"""
# Avant toutes choses, on met le module context dans le global de l'interpreteur (__builtin__)
# sous le nom CONTEXT afin d'avoir acces aux fonctions
# getCurrentStep, setCurrentStep et unsetCurrentStep de n'importe ou


from Accas.processing import context

import builtins
builtins.CONTEXT = context

# Only the first MAXSIZE objects will be checked
# This is used for the number of MCFACT, the number of MCSIMP and the number of
# values in a MCSIMP.

MAXSIZE = 500
MAXSIZE_MSGCHK = " <I> Only the first {0} occurrences (total: {1}) have been checked."
MAXSIZE_MSGKEEP = " <I> Only the first {0} occurrences (total: {1}) have been printed."
