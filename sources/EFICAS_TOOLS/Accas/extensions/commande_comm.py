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

from builtins import str
import os, traceback
import re

from Accas.processing.P_CR import CR
from Accas.processing.P_Exception import AsException
from Accas.processing import P_OBJECT
from Accas.accessor import A_OBJECT
from Accas.extensions.eficas_translation import tr


class COMMANDE_COMM(P_OBJECT.OBJECT, A_OBJECT.OBJECT):
    """
    Cette classe sert a definir les objets de type Commande commentarisee
    """

    nature = "COMMANDE_COMMENTARISEE"
    idracine = "_comm"

    def __init__(self, texte="", parent=None, reg="oui"):
        self.valeur = texte
        if not parent:
            self.jdc = self.parent = CONTEXT.getCurrentStep()
        else:
            self.jdc = self.parent = parent
        if hasattr(self.parent, "etape"):
            self.etape = self.parent.etape
        else:
            self.etape = None
        self.definition = self
        self.nom = ""
        self.niveau = self.parent.niveau
        self.actif = 1
        self.state = "unchanged"
        # self.appel = P_utils.calleeWhere(niveau=2)
        if reg == "oui":
            self.register()

    def isValid(self):
        return 1

    def report(self):
        """
        Genere l'objet rapport (classe CR)
        """
        self.cr = CR()
        if not self.isValid():
            self.cr.warn(tr("Objet commande commentarise invalide"))
        return self.cr

    def copy(self):
        """
        Retourne une copie de self cad un objet COMMANDE_COMM
        """
        # XXX self.texte ne semble pas exister ???
        return COMMANDE_COMM(self.texte, parent=self.parent, reg="non")

    def initModif(self):
        self.state = "modified"
        self.parent.initModif()

    def setValeur(self, new_valeur):
        """
        Remplace la valeur de self(si elle existe) par new_valeur)
        """
        self.valeur = new_valeur
        self.initModif()

    def getValeur(self):
        """
        Retourne la valeur de self, cad le texte de la commande commentarisee
        """
        return self.valeur

    def register(self):
        """
        Enregistre la commande commenatrisee dans la liste des etapes de son parent lorsque celui-ci
        est un JDC
        """
        self.parent.register(self)

    def isOblig(self):
        """
        Indique si self est obligatoire ou non : retourne toujours 0
        """
        return 0

    def ident(self):
        """
        Retourne le nom interne associe a self
        Ce nom n'est jamais vu par l'utilisateur dans EFICAS
        """
        return self.nom

    def isRepetable(self):
        """
        Indique si self est repetable ou non : retourne toujours 1
        """
        return 1

    def getAttribut(self, nom_attribut):
        """
        Retourne l'attribut de nom nom_attribut de self (ou herite)
        """
        if hasattr(self, nom_attribut):
            return getattr(self, nom_attribut)
        else:
            return None

    def getFr(self):
        """
        Retourne l'attribut fr de self.definition
        """
        if self.jdc.code == "ASTER":
            return self.definition.fr
        try:
            return getattr(self.definition, self.jdc.lang)
        except:
            return ""

    def listeMcPresents(self):
        return []

    def supprime(self):
        """
        Methode qui supprime toutes les boucles de references afin que l'objet puisse
        etre correctement detruit par le garbage collector
        """
        self.parent = None
        self.etape = None
        self.jdc = None
        self.niveau = None
        self.definition = None
        self.valeur = None
        self.val = None
        self.appel = None

    def supprimeSdProds(self):
        pass

    def updateContext(self, d):
        """
        Update le dictionnaire d avec les concepts ou objets produits par self
        --> ne fait rien pour une commande en  commentaire
        """
        pass

    def deleteConcept(self, sd):
        pass

    def replaceConcept(self, old_sd, sd):
        pass

    def getSdprods(self, nom_sd):
        return None

    def unComment(self):
        """
        Cette methode a pour but de decommentariser l'objet courant,
        cad de retourner un tuple contenant :
          - l'objet CMD associe
          - le nom de la sdprod eventuellement produite (sinon None)
        """
        # on recupere le contexte avant la commande commentarisee
        context_ini = self.jdc.getContexteAvant(self)
        try:
            # on essaie de creer un objet JDC...
            CONTEXT.unsetCurrentStep()
            if re.search("Fin Commentaire", self.valeur):
                self.valeur = self.valeur.replace("Fin Commentaire", "")
            J = self.jdc.__class__(
                procedure=self.valeur,
                definition=self.jdc.definition,
                cata=self.jdc.cata,
                dicoCataOrdonne=self.jdc.dicoCataOrdonne,
                context_ini=context_ini,
            )
            J.analyse()
        except Exception as e:
            traceback.print_exc()
            # self.jdc.set_context()
            raise AsException(tr("Erreur"), e.__str__())
        if len(J.cr.crfatal) > 0:
            # des erreurs fatales ont ete rencontrees
            # self.jdc.set_context()
            print("erreurs fatales !!!")
            raise AsException(tr("Erreurs fatales"), "".join(J.cr.crfatal))
        if not J.etapes:
            # des erreurs ont ete rencontrees
            raise AsException(tr("Impossible reconstruire commande\n"), str(J.cr))
        # self.jdc.set_context()

        new_etape = J.etapes[0]
        if new_etape.sd:
            nom_sd = new_etape.sd.nom
        else:
            nom_sd = None
        # new_etape=new_etape.copy()
        # print "unComment",new_etape.sd

        pos = self.parent.etapes.index(self)
        # L'ordre d'appel est important : suppEntite fait le menage des concepts dans les etapes suivantes
        self.parent.addEntite(new_etape, pos)
        self.parent.suppEntite(self)
        return new_etape, nom_sd

    def active(self):
        """
        Rend l'etape courante active
        """
        self.actif = 1

    def inactive(self):
        """
        Rend l'etape courante inactive
        """
        self.actif = 0

    def isActif(self):
        """
        Booleenne qui retourne 1 si self est valide, 0 sinon
        """
        return self.actif

    def verifConditionBloc(self):
        """
        Evalue les conditions de tous les blocs fils possibles
        (en fonction du catalogue donc de la definition) de self et
        retourne deux listes :
          - la premiere contient les noms des blocs a rajouter
          - la seconde contient les noms des blocs a supprimer
        """
        return [], []

    def verifConditionRegles(self, liste_presents):
        """
        Retourne la liste des mots-cles a rajouter pour satisfaire les regles
        en fonction de la liste des mots-cles presents
        """
        return []

    def reparent(self, parent):
        """
        Cette methode sert a reinitialiser la parente de l'objet
        """
        self.parent = parent
        self.jdc = parent.getJdcRoot()
        self.etape = self

    def verifExistenceSd(self):
        """
        Verifie que les structures de donnees utilisees dans self existent bien dans le contexte
        avant etape, sinon enleve la reference a ces concepts
        --> sans objet pour les commandes commentarisees
        """
        pass

    def controlSdprods(self, d):
        """sans objet pour les commandes commentarisees"""
        pass

    def close(self):
        pass

    def resetContext(self):
        pass
