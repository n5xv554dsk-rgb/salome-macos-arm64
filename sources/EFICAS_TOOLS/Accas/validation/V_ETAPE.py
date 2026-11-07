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
   Ce module contient la classe mixin ETAPE qui porte les methodes
   necessaires pour realiser la Accas.validation d'un objet de type ETAPE
   derive de OBJECT.

   Une classe mixin porte principalement des traitements et est
   utilisee par heritage multiple pour composer les traitements.
"""

# Modules Python
import types
import sys
import traceback
import re

# Modules EFICAS
from . import V_MCCOMPO
from Accas.processing import MAXSIZE, MAXSIZE_MSGCHK
from Accas.processing.P_Exception import AsException
from Accas.processing.P_utils import AsType
from Accas.extensions.eficas_translation import tr


class ETAPE(V_MCCOMPO.MCCOMPO):

    """ """

    def validChild(self):
        """Cette methode teste la validite des mots cles de l'etape"""
        for child in self.mcListe:
            if not child.isValid():
                return 0
        return 1

    def validRegles(self, cr):
        """Cette methode teste la validite des regles de l'etape"""
        text_erreurs, test_regles = self.verifRegles()
        if not test_regles:
            if cr == "oui":
                self.cr.fatal("Regle(s) non respectee(s) : %s" % text_erreurs)
            return 0
        return 1

    def validSdnom(self, cr):
        """Cette methode teste la validite du nom du concept produit par l'etape"""
        valid = 1
        if self.sd.nom != None:
            if self.sd.nom.find("sansnom") != -1:
                # la SD est 'sansnom' : --> erreur
                if cr == "oui":
                    self.cr.fatal(("object must have a name"))
                valid = 0
            elif re.search("^SD_[0-9]*$", self.sd.nom):
                # la SD est 'SD_' cad son nom = son id donc pas de nom donne
                # par utilisateur : --> erreur
                if cr == "oui":
                    self.cr.fatal(("invalid name ('SD_' is a reserved keyword)"))
                valid = 0
        return valid

    def getValid(self):
        if hasattr(self, "valid"):
            return self.valid
        else:
            self.valid = None
            return None

    def setValid(self, valid):
        old_valid = self.getValid()
        self.valid = valid
        self.state = "unchanged"
        if not old_valid or old_valid != self.valid:
            self.initModifUp()

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
        # if CONTEXT.debug:
        # if 1 :
        #   print(("ETAPE.isValid ", self.nom, self.state))
        #   import traceback
        #   traceback.print_stack()
        if self.state == "unchanged":
            return self.valid
        else:
            valid = self.validChild()
            valid = valid * self.validRegles(cr)
            if cr == "oui":
                if not hasattr(self, "cr"):
                    from Accas.processing.P_CR import CR

                    self.cr = CR()
                else:
                    self.cr.purge()
            if self.reste_val != {}:
                if cr == "oui":
                    self.cr.fatal(
                        "unknown keywords : %s" % ",".join(list(self.reste_val.keys()))
                    )
                valid = 0

            if sd == "non":
                # Dans ce cas, on ne teste qu'une validite partielle (sans tests sur le concept produit)
                # Consequence : on ne change pas l'etat ni l'attribut valid, on retourne simplement
                # l'indicateur de validite valid
                return valid

            if self.definition.reentrant == "n" and self.reuse:
                # Il ne peut y avoir de concept reutilise avec un OPER non
                # reentrant
                if cr == "oui":
                    self.cr.fatal("Operateur non reentrant : ne pas utiliser reuse")
                valid = 0

            if self.sd == None:
                # Le concept produit n'existe pas => erreur
                if cr == "oui":
                    self.cr.fatal(("Concept is not defined"))
                valid = 0
            else:
                valid = valid * self.validSdnom(cr)

            if valid:
                valid = self.updateSdprod(cr)

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
        if type(sd_prod) == types.FunctionType:  # Type de concept retourne calcule
            d = self.creeDictValeurs(self.mcListe)
            try:
                sd_prod = sd_prod(*(), **d)
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
                        "unable to affect type to concept\n %s" % " ".join(l[2:])
                    )
                return 0
        # on teste maintenant si la SD est reutilisee ou s'il faut la
        # creer
        valid = 1
        if self.reuse:
            if AsType(self.reuse) != sd_prod:
                if cr == "oui":
                    self.cr.fatal(
                        ("Type de concept reutilise incompatible avec type produit")
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
                else:
                    # Le sd n existait pas , on ne le cree pas
                    if cr == "oui":
                        self.cr.fatal("Concept retourne non defini")
                    valid = 0
            if self.definition.reentrant == "o":
                if cr == "oui":
                    self.cr.fatal(
                        (
                            "Commande obligatoirement reentrante : specifier reuse=concept"
                        )
                    )
                valid = 0
        return valid

    def report(self):
        """
        Methode pour generation d un rapport de validite
        """
        self.cr = self.CR(
            debut="Command : "
            + tr(self.nom)
            + "    line : "
            + repr(self.appel[0])
            + "    file : "
            + repr(self.appel[1]),
            fin="End Command : " + tr(self.nom),
        )
        self.state = "modified"
        try:
            self.isValid(cr="oui")
        except AsException as e:
            if CONTEXT.debug:
                traceback.print_exc()
            self.cr.fatal(
                "Command : %s line : %r file : %r %s"
                % (tr(self.nom), self.appel[0], self.appel[1], e)
            )
        i = 0
        for child in self.mcListe:
            i += 1
            if i > MAXSIZE:
                print(MAXSIZE_MSGCHK.format(MAXSIZE, len(self.mcListe)))
                break
            self.cr.add(child.report())
        return self.cr
