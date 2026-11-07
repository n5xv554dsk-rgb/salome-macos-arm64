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
   Ce module contient la classe  de base MCCOMPO qui sert a factoriser
   les traitements des objets composites de type OBJECT
"""

# Modules Python

import os
import traceback

# Modules EFICAS
from Accas.processing import MAXSIZE, MAXSIZE_MSGCHK
from Accas.processing import P_CR
from Accas.processing.P_Exception import AsException


class MCCOMPO(object):

    """
    L'attribut mcListe a ete cree par une classe derivee de la
    classe MCCOMPO de processing
    """

    CR = P_CR.CR

    def __init__(self):
        self.state = "undetermined"
        # defini dans les classes derivees
        self.txt_nat = ""

    def initModifUp(self):
        """
        Propage l'etat modifie au parent s'il existe et n'est pas l'objet
        lui-meme
        """
        if self.parent and self.parent != self:
            self.parent.state = "modified"

    def report(self):
        """
        Genere le rapport de Accas.validation de self
        """
        self.cr = self.CR()
        self.cr.debut = self.txt_nat + self.nom
        self.cr.fin = "END " + self.txt_nat + self.nom
        i = 0
        for child in self.mcListe:
            i += 1
            if i > MAXSIZE:
                print(MAXSIZE_MSGCHK.format(MAXSIZE, len(self.mcListe)))
                break
            self.cr.add(child.report())
        self.state = "modified"
        try:
            self.isValid(cr="oui")
        except AsException as e:
            if CONTEXT.debug:
                traceback.print_exc()
            self.cr.fatal(" ".join((self.txt_nat, self.nom, str(e))))
        return self.cr

    def verifRegles(self):
        """
        A partir du dictionnaire des mots-cles presents, verifie si les regles
        de self sont valides ou non.

        Retourne une chaine et un booleen :

          - texte = la chaine contient le message d'erreur de la (les) regle(s) violee(s) ('' si aucune)

          - testglob = booleen 1 si toutes les regles OK, 0 sinon
        """
        # On verifie les regles avec les defauts affectes
        dictionnaire = self.dictMcPresents(restreint="non")
        texte = [""]
        testglob = 1
        for r in self.definition.regles:
            erreurs, test = r.verif(dictionnaire)
            testglob = testglob * test
            if erreurs != "":
                texte.append(str(erreurs))
        texte = os.linesep.join(texte)
        return texte, testglob

    def dictMcPresents(self, restreint="non"):
        """
        Retourne le dictionnaire {mocle : objet} construit a partir de self.mcListe
        Si restreint == 'non' : on ajoute tous les mots-cles simples du catalogue qui ont
        une valeur par defaut
        Si restreint == 'oui' : on ne prend que les mots-cles effectivement entres par
        l'utilisateur (cas de la verification des regles)
        """
        dico = {}
        # on ajoute les couples {nom mot-cle:objet mot-cle} effectivement
        # presents
        for v in self.mcListe:
            if v == None:
                continue
            k = v.nom
            dico[k] = v
        if restreint == "oui":
            return dico
        # Si restreint != 'oui',
        # on ajoute les couples {nom mot-cle:objet mot-cle} des mots-cles simples
        # possibles pour peu qu'ils aient une valeur par defaut
        for k, v in list(self.definition.entites.items()):
            if v.label != "SIMP":
                continue
            if not v.defaut:
                continue
            if not k in dico:
                dico[k] = v(nom=k, val=None, parent=self)
        # on ajoute l'objet detenteur de regles pour des Accas.validations plus
        # sophistiquees (a manipuler avec precaution)
        dico["self"] = self
        return dico
