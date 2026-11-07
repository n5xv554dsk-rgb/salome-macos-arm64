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
   Ce module contient la classe mixin MACRO_ETAPE qui porte les methodes
   necessaires pour realiser la Accas.validation d'un objet de type MACRO_ETAPE
   derive de OBJECT.

   Une classe mixin porte principalement des traitements et est
   utilisee par heritage multiple pour composer les traitements.
"""

# Modules Python
import types
import sys
import traceback

# Modules EFICAS
from . import V_MCCOMPO
from . import V_ETAPE
from Accas.processing.P_Exception import AsException
from Accas.processing.P_utils import AsType


class MACRO_ETAPE(V_ETAPE.ETAPE):

    """ """

    def isValid(self, sd="oui", cr="non"):
        """
        Methode pour verifier la validite de l'objet ETAPE. Cette methode
        peut etre appelee selon plusieurs modes en fonction de la valeur
        de sd et de cr.

        Si cr vaut oui elle cree en plus un compte-rendu.

        Cette methode a plusieurs fonctions :

         - mettre a jour l'etat de self (update)

         - retourner un indicateur de validite 0=non, 1=oui

         - produire un compte-rendu : self.cr

        """
        if CONTEXT.debug:
            print(("ETAPE.isValid ", self.nom))
        if self.state == "unchanged":
            return self.valid
        else:
            valid = 1
            # On marque les concepts CO pour verification ulterieure de leur
            # bonne utilisation
            l = self.getAllCo()
            # On verifie que les concepts CO sont bien passes par typeSDProd
            for c in l:
                # if c.etape is self.parent:
                if c.isTypCO() != 2:
                    # le concept est propriete de l'etape parent
                    # Il n'a pas ete transforme par typeSDProd
                    # Cette situation est interdite
                    # Pb: La macro-commande a passe le concept a une commande
                    # (macro ?) mal definie
                    if cr == "oui":
                        self.cr.fatal(
                            "Macro-commande mal definie : le concept n'a pas ete type par un appel a typeSDProd pour %s"
                            % c.nom
                        )
                    valid = 0

            valid = valid * self.validChild()
            valid = valid * self.validRegles(cr)

            if self.reste_val != {}:
                if cr == "oui":
                    self.cr.fatal(
                        "unknown keyword : %s" % ",".join(list(self.reste_val.keys()))
                    )
                valid = 0

            if sd == "non":
                # Dans ce cas, on ne calcule qu'une validite partielle, on ne modifie pas l'etat de self
                # on retourne simplement l'indicateur valid
                return valid

            if self.sd != None:
                valid = valid * self.validSdnom(cr)

            if self.definition.reentrant == "n" and self.reuse:
                # Il ne peut y avoir de concept reutilise avec une MACRO  non
                # reentrante
                if cr == "oui":
                    self.cr.fatal(
                        "Macro-commande non reentrante : ne pas utiliser reuse"
                    )
                valid = 0

            if valid:
                valid = self.updateSdprod(cr)

            # Si la macro comprend des etapes internes, on teste leur validite
            for e in self.etapes:
                if not e.isValid():
                    valid = 0
                    break

            self.setValid(valid)

            return self.valid

    def updateSdprod(self, cr="non"):
        """
        Cette methode met a jour le concept produit en fonction des conditions initiales :

         1. Il n'y a pas de concept retourne (self.definition.sd_prod == None)

         2. Le concept retourne n existait pas (self.sd == None)

         3. Le concept retourne existait. On change alors son type ou on le supprime

        En cas d'erreur (exception) on retourne un indicateur de validite de 0 sinon de 1
        """
        sd_prod = self.definition.sd_prod
        # On memorise le type retourne dans l attribut typret
        self.typret = None
        if type(sd_prod) == types.FunctionType:
            # Type de concept retourne calcule
            d = self.creeDictValeurs(self.mcListe)
            try:
                # la sd_prod d'une macro a l'objet lui meme en premier argument
                # contrairement a une ETAPE ou PROC_ETAPE
                # Comme sd_prod peut invoquer la methode typeSDProd qui ajoute
                # les concepts produits dans self.sdprods, il faut le mettre a
                # zero
                self.sdprods = []
                sd_prod = sd_prod(*(self,), **d)
            except:
                # Erreur pendant le calcul du type retourne
                if CONTEXT.debug:
                    traceback.print_exc()
                self.sd = None
                if cr == "oui":
                    l = traceback.format_exception(
                        sys.exc_info()[0], sys.exc_info()[1], sys.exc_info()[2]
                    )
                    self.cr.fatal(
                        "Impossible d affecter un type au resultat\n%s"
                        % " ".join(l[2:])
                    )
                return 0
        # on teste maintenant si la SD est reutilisee ou s'il faut la
        # creer
        valid = 1
        if self.reuse:
            # Un concept reutilise a ete specifie
            if AsType(self.reuse) != sd_prod:
                if cr == "oui":
                    self.cr.fatal(
                        "Type de concept reutilise incompatible avec type produit"
                    )
                valid = 0
            if self.sdnom != "":
                if self.sdnom[0] != "_" and self.reuse.nom != self.sdnom:
                    # Le nom de la variable de retour (self.sdnom) doit etre le
                    # meme que celui du concept reutilise (self.reuse.nom)
                    if cr == "oui":
                        self.cr.fatal(
                            "Concept reutilise : le nom de la variable de retour devrait etre %s et non %s"
                            % (self.reuse.nom, self.sdnom)
                        )
                    valid = 0
            if valid:
                self.sd = self.reuse
        else:
            # Cas d'un concept non reutilise
            if sd_prod == None:  # Pas de concept retourne
                # Que faut il faire de l eventuel ancien sd ?
                self.sd = None
            else:
                if self.sd:
                    # Un sd existe deja, on change son type
                    if CONTEXT.debug:
                        print(("changement de type:", self.sd, sd_prod))
                    if self.sd.__class__ != sd_prod:
                        self.sd.changeType(sd_prod)
                    self.typret = sd_prod
                else:
                    # Le sd n existait pas , on ne le cree pas
                    self.typret = sd_prod
                    if cr == "oui":
                        self.cr.fatal("Concept retourne non defini")
                    valid = 0
            if self.definition.reentrant == "o":
                if cr == "oui":
                    self.cr.fatal(
                        "Commande obligatoirement reentrante : specifier reuse=concept"
                    )
                valid = 0
        return valid

    def report(self):
        """
        Methode pour la generation d un rapport de Accas.validation
        """
        V_ETAPE.ETAPE.report(self)
        for e in self.etapes:
            self.cr.add(e.report())
        return self.cr
