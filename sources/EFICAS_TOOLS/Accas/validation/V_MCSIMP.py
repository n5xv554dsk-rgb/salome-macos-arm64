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
   Ce module contient la classe mixin MCSIMP qui porte les methodes
   necessaires pour realiser la Accas.validation d'un objet de type MCSIMP
   derive de OBJECT.

   Une classe mixin porte principalement des traitements et est
   utilisee par heritage multiple pour composer les traitements.
"""
# Modules Python
from builtins import str
from builtins import object

# Modules EFICAS
from Accas.processing import P_CR
from Accas.processing.P_Exception import AsException
from Accas.processing.P_VALIDATOR import ValError, TypeProtocol, CardProtocol, IntoProtocol
from Accas.processing.P_VALIDATOR import listProto
from Accas.extensions.eficas_translation import tr


class MCSIMP(object):

    """
    COMMENTAIRE CCAR:
    Cette classe est quasiment identique a la classe originale d'EFICAS
    a part quelques changements cosmetiques et des chagements pour la
    faire fonctionner de facon plus autonome par rapport a l'environnement
    EFICAS

    A mon avis, il faudrait aller plus loin et reduire les dependances
    amont au strict necessaire.

        - Est il indispensable de faire l'evaluation de la valeur dans le contexte
          du jdc dans cette classe.
          oui surtout pour les filtres et les validateurs

        - Ne pourrait on pas doter les objets en presence des methodes suffisantes
          pour eviter les tests un peu particuliers sur GEOM, PARAMETRE et autres. J'ai
          d'ailleurs modifie la classe pour eviter l'import de GEOM
    """

    CR = P_CR.CR

    def __init__(self):
        self.state = "undetermined"
        self.typeProto = TypeProtocol("type", typ=self.definition.type)
        self.intoProto = IntoProtocol(
            "into",
            into=self.definition.into,
            val_min=self.definition.val_min,
            val_max=self.definition.val_max,
        )
        self.cardProto = CardProtocol(
            "card", min=self.definition.min, max=self.definition.max
        )

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

    def isValid(self, cr="non"):
        """
        Cette methode retourne un indicateur de validite de l'objet de type MCSIMP

          - 0 si l'objet est invalide
          - 1 si l'objet est valide

        Le parametre cr permet de parametrer le traitement. Si cr == 'oui'
        la methode construit egalement un comte-rendu de Accas.validation
        dans self.cr qui doit avoir ete cree prealablement.
        """
        if self.state == "unchanged":
            return self.valid
        else:
            valid = 1
            v = self.valeur
            #  verification presence
            if self.isOblig() and (v == None or v == ""):
                if cr == "oui":
                    self.cr.fatal("Mandatory keyword : %s has no value" % tr(self.nom))
                valid = 0

            lval = listProto.adapt(v)
            # Ajout PN
            # Pour tenir compte des Tuples
            if hasattr(self.definition.type[0], "ntuple"):
                try:
                    if (not (type(lval[0]) is tuple)) and (not (type(lval[0]) is list)):
                        lval = (lval,)
                except:
                    pass
            if lval is None:
                valid = 0
                if cr == "oui":
                    self.cr.fatal("None is not a valid value")
            else:
                # type,into ...
                # typeProto=TypeProtocol("type",typ=self.definition.type)
                # intoProto=IntoProtocol("into",into=self.definition.into,val_min=self.definition.val_min,val_max=self.definition.val_max)
                # cardProto=CardProtocol("card",min=self.definition.min,max=self.definition.max)
                # typeProto=self.definition.typeProto
                # intoProto=self.definition.intoProto
                # cardProto=self.definition.cardProto
                typeProto = self.typeProto
                intoProto = self.intoProto
                cardProto = self.cardProto
                if self.definition.filtre != None:
                    listePossibles = self.getUserAssdPossible()
                    self.intoProto = IntoProtocol(
                        "into",
                        into=listePossibles,
                        val_min=self.definition.val_min,
                        val_max=self.definition.val_max,
                    )
                    intoProto = self.intoProto
                if cr == "oui":
                    # un cr est demande : on collecte tous les types d'erreur
                    try:
                        for val in lval:
                            typeProto.adapt(val)
                    except ValError as e:
                        valid = 0
                        self.cr.fatal(str(e))
                    try:
                        for val in lval:
                            intoProto.adapt(val)
                    except ValError as e:
                        valid = 0
                        self.cr.fatal(str(e))
                    try:
                        cardProto.adapt(lval)
                    except ValError as e:
                        valid = 0
                        self.cr.fatal(str(e))
                    #
                    # On verifie les validateurs s'il y en a et si necessaire (valid == 1)
                    #
                    if valid and self.definition.validators:
                        try:
                            self.definition.validators.convert(lval)
                        except ValError as e:
                            self.cr.fatal(
                                "invalid keyword %s  : %s\nCriteria : %s"
                                % (
                                    tr(self.nom),
                                    str(e),
                                    self.definition.validators.info(),
                                )
                            )
                            valid = 0
                else:
                    # si pas de cr demande, on sort a la toute premiere erreur
                    try:
                        for val in lval:
                            typeProto.adapt(val)
                            intoProto.adapt(val)
                        cardProto.adapt(lval)
                        if self.definition.validators:
                            if hasattr(self.definition.validators, "set_MCSimp"):
                                self.definition.validators.set_MCSimp(self)
                            self.definition.validators.convert(lval)
                    except ValError as e:
                        valid = 0

            self.setValid(valid)
            return self.valid

    def isOblig(self):
        """indique si le mot-cle est obligatoire"""
        return self.definition.statut == "o"

    def initModifUp(self):
        """
        Propage l'etat modifie au parent s'il existe et n'est l'objet
        lui-meme
        """
        if self.parent and self.parent != self:
            self.parent.state = "modified"

    def report(self):
        """genere le rapport de Accas.validation de self"""
        self.cr = self.CR()
        self.cr.debut = "Simple Keyword : " + tr(self.nom)
        self.cr.fin = "End Simple Keyword: " + tr(self.nom)
        self.state = "modified"
        try:
            self.isValid(cr="oui")
        except AsException as e:
            if CONTEXT.debug:
                traceback.print_exc()
            self.cr.fatal("Simple Keyword  : %s %s" % (tr(self.nom), e))
        return self.cr
 
    def revalide(self):
        self.state = "undetermined"
        self.typeProto = TypeProtocol("type", typ=self.definition.type)
        self.intoProto = IntoProtocol( "into", into=self.definition.into, val_min=self.definition.val_min, val_max=self.definition.val_max,)
        self.cardProto = CardProtocol( "card", min=self.definition.min, max=self.definition.max)
        self.isValid()

