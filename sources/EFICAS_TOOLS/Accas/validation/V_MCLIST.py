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
   Ce module contient la classe mixin MCList qui porte les methodes
   necessaires pour realiser la Accas.validation d'un objet de type MCList
   derive de OBJECT.

   Une classe mixin porte principalement des traitements et est
   utilisee par heritage multiple pour composer les traitements.
"""
# Modules Python
from builtins import object
import traceback

# Modules EFICAS
from Accas.extensions.eficas_translation import tr
from Accas.processing import MAXSIZE, MAXSIZE_MSGCHK
from Accas.processing import P_CR
from Accas.processing.P_Exception import AsException


class MCList(object):

    """
    Cette classe a deux attributs de classe :

    - CR qui sert a construire l'objet compte-rendu

    - txt_nat qui sert pour les comptes-rendus lies a cette classe
    """

    CR = P_CR.CR
    txt_nat = "Mot cle Facteur Multiple :"

    def isValid(self, cr="non"):
        """
        Methode pour verifier la validite du MCList. Cette methode
        peut etre appelee selon plusieurs modes en fonction de la valeur
        de cr.

        Si cr vaut oui elle cree en plus un compte-rendu.

        On n'utilise pas d'attribut pour stocker l'etat et on ne remonte pas
        le changement d'etat au parent (pourquoi ??)
        MCLIST est une liste de MCFACT. Les MCFACT ont le meme parent
        que le MCLIST qui les contient. Il n'est donc pas necessaire de
        remonter le changement d'etat au parent. C'est deja fait
        par les MCFACT.
        """
        if len(self.data) == 0:
            return 0

        valid = 1
        definition = self.data[0].definition
        # Verification du nombre des mots cles facteurs
        if definition.min is not None and len(self.data) < definition.min:
            valid = 0
            if cr == "oui":
                self.cr.fatal(
                    "Nombre de mots cles facteurs insuffisant minimum : %s"
                    % definition.min
                )

        if definition.max is not None and len(self.data) > definition.max:
            valid = 0
            if cr == "oui":
                self.cr.fatal(
                    "Nombre de mots cles facteurs trop grand maximum : %s"
                    % definition.max
                )
        num = 0
        for i in self.data:
            num = num + 1
            if not i.isValid():
                valid = 0
                if cr == "oui" and len(self) > 1:
                    self.cr.fatal(
                        "L'occurrence numero %d du mot-cle facteur : %s n'est pas valide"
                        % (num, self.nom)
                    )
        return valid

    def report(self):
        """
        Genere le rapport de Accas.validation de self
        """
        if len(self) > 1:
            # Mot cle facteur multiple
            self.cr = self.CR(
                debut="Mot-cle facteur multiple : " + tr(self.nom),
                fin="Fin Mot-cle facteur multiple : " + tr(self.nom),
            )
            j = 0
            for i in self.data:
                j += 1
                if j > MAXSIZE:
                    print(MAXSIZE_MSGCHK.format(MAXSIZE, len(self.data)))
                    break
                self.cr.add(i.report())
        elif len(self) == 1:
            # Mot cle facteur non multiple
            self.cr = self.data[0].report()
        else:
            self.cr = self.CR(
                debut="Mot-cle facteur : " + tr(self.nom),
                fin="Fin Mot-cle facteur : " + tr(self.nom),
            )

        try:
            self.isValid(cr="oui")
        except AsException as e:
            if CONTEXT.debug:
                traceback.print_exc()
            self.cr.fatal(" %s Mot-cle facteur multiple : %s" % (self.nom, e))
        return self.cr
