# -*- coding: utf-8 -*-
# Copyright (C) 2007-2026   EDF R&D
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
#
# See http://www.salome-platform.org/ or email : webmaster.salome@opencascade.com
#

"""
   Ce module contient la classe JDC_INCLUDE qui sert a inclure
   dans un jeu de commandes une partie de jeu de commandes
   au moyen de la fonctionnalite INCLUDE ou INCLUDE_MATERIAU
   Quand l'utilisateur veut inclure un fichier il faut versifier
   que le jeu de commandes inclus est valide et compatible
   avec le contexte avant et apres l'insertion
"""
import string
from Accas import JDC, ASSD, AsException, JDC_CATA
from Accas.accessor import CONNECTOR


class JDC_POURSUITE(JDC):
    def __init__(
        self,
        definition=None,
        procedure=None,
        cata=None,
        dicoCataOrdonne=None,
        parent=None,
        nom="SansNom",
        appliEficas=None,
        context_ini=None,
        jdc_pere=None,
        etape_include=None,
        prefix_include=None,
        recorded_units=None,
        old_recorded_units=None,
        **args
    ):
        JDC.__init__(
            self,
            definition=definition,
            procedure=procedure,
            cata=cata,
            dicoCataOrdonne=dicoCataOrdonne,
            parent=parent,
            nom=nom,
            appli=appliEficas,
            context_ini=context_ini,
            **args
        )
        self.jdc_pere = jdc_pere
        self.etape_include = etape_include
        self.prefix_include = prefix_include
        if recorded_units is not None:
            self.recorded_units = recorded_units
        if old_recorded_units is not None:
            self.old_recorded_units = old_recorded_units

    def o_register(self, sd):
        return self.jdc_pere.o_register(sd)

    def nommerSDProd(self, sd, sdnom, restrict="non"):
        """
        Nomme la SD apres avoir verifie que le nommage est possible : nom
        non utilise
        Ajoute un prefixe s'il est specifie (INCLUDE_MATERIAU)
        Si le nom est deja utilise, leve une exception
        Met le concept cree dans le contexe global g_context
        """
        # print "nommerSDProd",sd,sdnom,restrict
        if self.prefix_include:
            if sdnom != self.prefix_include:
                sdnom = self.prefix_include + sdnom

        if sdnom != "" and sdnom[0] == "_":
            # Si le nom du concept commence par le caractere _ on lui attribue
            # un identificateur automatique comme dans JEVEUX (voir gcncon)
            #
            # nom commencant par __ : il s'agit de concepts qui seront detruits
            # nom commencant par _ : il s'agit de concepts intermediaires qui seront gardes
            # ATTENTION : il faut traiter differemment les concepts dont le nom
            # commence par _ mais qui sont des concepts nommes automatiquement par
            # une eventuelle sous macro.
            if sdnom[1] in string.digits:
                # Ce concept provient probablement d'une sous macro (cas improbable)
                # pas de renommage
                pass
            elif sdnom[1] == "_":
                # cas d'un concept a ne pas conserver apres execution de la commande
                sdnom = sd.id[2:]
                pass
            else:
                sdnom = sd.id[2:]
                pass

        o = self.sdsDict.get(sdnom, None)
        if isinstance(o, ASSD):
            raise AsException(tr("Nom de concept deja defini : %s", sdnom))

        # On pourrait verifier que le jdc_pere apres l'etape etape_include
        # ne contient pas deja un concept de ce nom
        # if self.jdc_pere.getSdApresEtapeAvecDetruire(sdnom,etape=self.etape_include):
        # Il existe un concept apres self => impossible d'inserer
        #   raise AsException("Nom de concept deja defini : %s" % sdnom)
        # On a choisi de ne pas faire ce test ici mais de le faire en bloc
        # si necessaire apres en appelant la methode verifContexte

        # ATTENTION : Il ne faut pas ajouter sd dans sds car il s y trouve deja.
        # Ajoute a la creation (appel de regSD).
        self.sdsDict[sdnom] = sd
        sd.nom = sdnom

        # En plus si restrict vaut 'non', on insere le concept dans le contexte du JDC
        if restrict == "non":
            self.g_context[sdnom] = sd

    def getVerifContexte(self):
        # print "getVerifContexte"
        j_context = self.getContexteAvant(None)
        self.verifContexte(j_context)
        return j_context

    def forceContexte(self, contexte):
        for nom_sd, sd in list(contexte.items()):
            if not isinstance(sd, ASSD):
                continue
            autre_sd = self.jdc_pere.getSdApresEtapeAvecDetruire(
                nom_sd, sd, etape=self.etape_include
            )
            if autre_sd is None:
                continue
            if sd is not autre_sd:
                # Il existe un autre concept de meme nom produit par une etape apres self
                # on detruit ce concept pour pouvoir inserer les etapes du jdc_include
                if sd.etape:
                    sd.etape.supprimeSdprod(sd)

        return contexte

    def verifContexte(self, context):
        """
        Cette methode verifie si le contexte passe en argument (context)
        peut etre insere dans le jdc pere de l'include.
        Elle verifie que les concepts contenus dans ce contexte n'entrent
        pas en conflit avec les concepts produits dans le jdc pere
        apres l'include.
        Si le contexte ne peut pas etre insere, la methode leve une
        exception sinon elle retourne le contexte inchange
        """
        # print "verifContexte"
        for nom_sd, sd in list(context.items()):
            if not isinstance(sd, ASSD):
                continue
            autre_sd = self.jdc_pere.getSdApresEtapeAvecDetruire(
                nom_sd, sd, etape=self.etape_include
            )
            if autre_sd is None:
                continue
            if sd is not autre_sd:
                # Il existe un concept produit par une etape apres self
                # => impossible d'inserer
                raise Exception(
                    "Impossible d'inclure le fichier. Un concept de nom "
                    + "%s existe deja dans le jeu de commandes." % nom_sd
                )

        return context

    def getListeCmd(self):
        """
        Retourne la liste des commandes du catalogue
        """
        if self.jdc_pere is None:
            return JDC.getListeCmd(self)
        return self.jdc_pere.getListeCmd()

    def getGroups(self):
        """
        Retourne la liste des commandes du catalogue par groupes
        """
        if self.jdc_pere is None:
            return JDC.getGroups(self)
        return self.jdc_pere.getGroups()

    def initModif(self):
        """
        Met l'etat de l'etape a : modifie
        Propage la modification au parent

        Attention : initModif doit etre appele avant de realiser une modification
        La validite devra etre recalculee apres cette modification
        mais par un appel a finModif pour preserver l'etat modified
        de tous les objets entre temps
        """
        # print "jdc_include.initModif",self,self.etape_include
        self.state = "modified"
        if self.etape_include:
            self.etape_include.initModif()

    def finModif(self):
        """
        Methode appelee une fois qu'une modification a ete faite afin de
        declencher d'eventuels traitements post-modification
        ex : INCLUDE et POURSUITE
        """
        # print "jdc_include.finModif",self,self.etape_include
        CONNECTOR.Emit(self, "valid")
        if self.etape_include:
            self.etape_include.finModif()

    def supprime(self):
        """
        On ne supprime rien directement pour un jdc auxiliaire d'include ou de poursuite
        Utiliser supprime_aux
        """
        pass

    def supprime_aux(self):
        # print "supprime_aux",self
        JDC.supprime(self)
        self.jdc_pere = None
        self.etape_include = None
        #   self.dicoCataOrdonne={}
        self.appliEficas = None

    #   self.context_ini={}
    #   self.procedure=None

    def getContexteAvant(self, etape):
        """
        Retourne le dictionnaire des concepts connus avant etape
        On tient compte des concepts produits par le jdc pere
        en reactualisant le contexte initial context_ini
        On tient compte des commandes qui modifient le contexte
        comme DETRUIRE ou les macros
        Si etape == None, on retourne le contexte en fin de JDC
        """
        # print "jdc_include.getContexteAvant",etape,etape and etape.nom
        if self.etape_include:
            new_context = self.etape_include.parent.getContexteAvant(
                self.etape_include
            ).copy()
            self.context_ini = new_context
        d = JDC.getContexteAvant(self, etape)
        return d

    def resetContext(self):
        # print "jdc_include.resetContext",self,self.nom
        if self.etape_include:
            self.etape_include.parent.resetContext()
            new_context = self.etape_include.parent.getContexteAvant(
                self.etape_include
            ).copy()
            self.context_ini = new_context
        JDC.resetContext(self)

    def getSdApresEtape(self, nom_sd, etape, avec="non"):
        """
        Cette methode retourne la SD de nom nom_sd qui est eventuellement
        definie apres etape
        Si avec vaut 'non' exclut etape de la recherche
        """
        if self.etape_include:
            sd = self.etape_include.parent.getSdApresEtape(
                nom_sd, self.etape_include, "non"
            )
            if sd:
                return sd
        return JDC.getSdApresEtape(self, nom_sd, etape, avec)

    def getSdApresEtapeAvecDetruire(self, nom_sd, sd, etape, avec="non"):
        """
        On veut savoir ce que devient le concept sd de nom nom_sd apres etape.
        Il peut etre detruit, remplace ou conserve
        Cette methode retourne la SD sd de nom nom_sd qui est eventuellement
        definie apres etape en tenant compte des concepts detruits
        Si avec vaut 'non' exclut etape de la recherche
        """
        # print "jdc_include.getSdApresEtapeAvecDetruire",nom_sd,sd,id(sd)
        autre_sd = JDC.getSdApresEtapeAvecDetruire(self, nom_sd, sd, etape, avec)
        # si autre_sd vaut None le concept sd a ete detruit. On peut terminer
        # la recherche en retournant None
        # Si autre_sd ne vaut pas sd, le concept a ete redefini. On peut terminer
        # la recherche en retournant le concept nouvellement defini
        # Sinon, on poursuit la recherche dans les etapes du niveau superieur.
        if autre_sd is None or autre_sd is not sd:
            return autre_sd
        return self.etape_include.parent.getSdApresEtapeAvecDetruire(
            nom_sd, sd, self.etape_include, "non"
        )

    def deleteConcept(self, sd):
        """
        Fonction : Mettre a jour les etapes du JDC suite a la disparition du
        concept sd
        Seuls les mots cles simples MCSIMP font un traitement autre
        que de transmettre aux fils
        """
        # Nettoyage des etapes de l'include
        JDC.deleteConcept(self, sd)
        # Nettoyage des etapes du parent
        if self.etape_include:
            self.etape_include.parent.deleteConceptAfterEtape(self.etape_include, sd)

    def deleteConceptAfterEtape(self, etape, sd):
        """
        Fonction : Mettre a jour les etapes du JDC qui sont apres etape suite a
        la disparition du concept sd
        """
        # Nettoyage des etapes de l'include
        JDC.deleteConceptAfterEtape(self, etape, sd)
        # Nettoyage des etapes du parent
        if self.etape_include:
            self.etape_include.parent.deleteConceptAfterEtape(self.etape_include, sd)

    def updateConceptAfterEtape(self, etape, sd):
        """
        Fonction : mettre a jour les etapes du JDC suite a une modification
        du concept sd (principalement renommage)
        """
        JDC.updateConceptAfterEtape(self, etape, sd)
        if self.etape_include:
            self.etape_include.parent.updateConceptAfterEtape(self.etape_include, sd)

    def replaceConceptAfterEtape(self, etape, old_sd, sd):
        """
        Fonction : Mettre a jour les etapes du JDC qui sont apres etape suite au
        remplacement du concept old_sd par sd
        """
        # Nettoyage des etapes de l'include
        JDC.replaceConceptAfterEtape(self, etape, old_sd, sd)
        # Nettoyage des etapes du parent
        if self.etape_include:
            self.etape_include.parent.replaceConceptAfterEtape(
                self.etape_include, old_sd, sd
            )

    def changeFichier(self, fichier):
        if self.etape_include:
            self.etape_include.fichier_ini = fichier
        self.finModif()

    def controlContextApres(self, etape):
        """
        Cette methode verifie que les etapes apres l'etape etape
        ont bien des concepts produits acceptables (pas de conflit de
        nom principalement)
        Si des concepts produits ne sont pas acceptables ils sont supprimes.
        Effectue les verifications sur les etapes du jdc mais aussi sur les
        jdc parents s'ils existent.
        """
        # print "jdc_include.controlContextApres",self,etape
        # Regularise les etapes du jdc apres l'etape etape
        self.controlJdcContextApres(etape)
        if self.etape_include:
            # print "CONTROL_INCLUDE:",self.etape_include,self.etape_include.nom
            # il existe un jdc pere. On propage la regularisation
            self.etape_include.parent.controlContextApres(self.etape_include)


class JDC_INCLUDE(JDC_POURSUITE):
    def getListeCmd(self):
        """
        Retourne la liste des commandes du catalogue
        """
        if self.jdc_pere is None:
            return JDC.getListeCmd(self)
        return [
            e
            for e in self.jdc_pere.getListeCmd()
            if e not in ("DEBUT", "POURSUITE", "FIN")
        ]

    def activeEtapes(self):
        for e in self.etapes:
            e.active()


class JDC_CATA_INCLUDE(JDC_CATA):
    class_instance = JDC_INCLUDE


class JDC_CATA_POURSUITE(JDC_CATA):
    class_instance = JDC_POURSUITE


from Accas import AU_MOINS_UN, A_CLASSER

import prefs

c = prefs.code
JdC_include = JDC_CATA_INCLUDE(code=c, execmodul=None)

JdC_poursuite = JDC_CATA_POURSUITE(
    code="ASTER",
    execmodul=None,
    regles=(
        AU_MOINS_UN("DEBUT", "POURSUITE"),
        AU_MOINS_UN("FIN"),
        A_CLASSER(("DEBUT", "POURSUITE"), "FIN"),
    ),
)
