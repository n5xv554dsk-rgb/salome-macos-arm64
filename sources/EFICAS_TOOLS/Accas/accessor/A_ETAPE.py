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
"""
# Modules Python
import sys, re
import types
from copy import copy

from Accas.extensions.eficas_translation import tr
from Accas.extensions.eficas_exception import EficasException

# Objet re pour controler les identificateurs Python
conceptRE = re.compile(r"[a-zA-Z_]\w*$")

import traceback
from Accas.processing import P_ETAPE
from Accas.processing import P_Exception
from Accas.processing.P_Exception import AsException
from Accas.validation import V_ETAPE

# fin import a resorber

# Modules EFICAS
from Accas.accessor import A_MCCOMPO
from Accas.accessor import CONNECTOR
from Accas.extensions import commande_comm


class ETAPE(A_MCCOMPO.MCCOMPO):
    def ident(self):
        return self.nom

    def getSdname(self):
        # print "SDNAME ",self.reuse,self.sd,self.sd.getName()
        if CONTEXT.debug:
            print(("SDNAME ", self.reuse, self.sd, self.sd.getName()))
        sdname = ""
        if self.reuse != None:
            sdname = self.reuse.getName()
        else:
            if self.sd:
                sdname = self.sd.getName()
        if sdname.find("sansnom") != -1 or sdname.find("SD_") != -1:
            # dans le cas ou la SD est 'sansnom' ou 'SD_' on retourne la chaine vide
            return ""
        return sdname

    def isReentrant(self):
        """
        Indique si la commande est reentrante
        """
        return self.definition.reentrant == "o"

    def initModif(self):
        """
        Met l'etat de l'etape a : modifie
        Propage la modification au parent
        """
        # initModif doit etre appele avant de realiser une modification
        # La validite devra etre recalculee apres cette modification
        # mais dans l'appel a finModif pour preserver l'etat modified
        # de tous les objets entre temps
        # print "initModif",self,self.parent
        self.state = "modified"
        if self.parent:
            self.parent.initModif()

    def finModif(self):
        """
        Methode appelee une fois qu'une modification a ete faite afin de
        declencher d'eventuels traitements post-modification
        ex : INCLUDE et POURSUITE
        Ne pas mettre de traitement qui risque d'induire des recursions (soit a peu pres rien)
        """
        CONNECTOR.Emit(self, "valid")
        if self.parent:
            self.parent.finModif()

    def nommeSd(self, nom):
        """
        Cette methode a pour fonction de donner un nom (nom) au concept
        produit par l'etape (self).
          - si le concept n'existe pas, on essaye de le creer a condition que l'etape soit valide ET non reentrante)
          - si il existe dea, on le renomme et on repercute les changements dans les autres etapes
        Les valeurs de retour sont :
          - 0 si le nommage n'a pas pu etre menea son terme,
          - 1 dans le cas contraire
        """
        # Le nom d'un concept doit etre un identificateur Python (toujours vrai ou insuffisant?)
        if not conceptRE.match(nom):
            return 0, tr("Un nom de concept doit etre un identificateur Python")

        # pour eviter que le nom du concept soit le nom de la classe --> souci pour utiliser le concept
        if nom == self.definition.nom:
            return ( 0, tr("un concept de type ") + nom + tr(" ne peut pas se nommer ") + nom)
        if nom in dir(self.jdc.cata):
            return (0, nom + tr("est un not reserve"))
        # if (not isinstance(nom,str)) : return (0, tr("Le nom ") + nom + tr(" est un mot reserve"))
        # if len(nom) > 8 and self.jdc.definition.code == 'ASTER':
        #  return 0, tr("Nom de concept trop long (maxi 8 caracteres)")

        self.initModif()
        #
        # On verifie d'abord si les mots cles sont valides
        #
        if not self.isValid(sd="non"):
            return 0, "Nommage du concept refuse : l'operateur n'est pas valide"
        #
        # Cas particulier des operateurs obligatoirement reentrants
        # plus de concept reentrant (pour Aster)
        #
        if self.definition.reentrant == "o":
            self.sd = self.reuse = self.jdc.getSdAvantEtape(nom, self)
            if self.sd != None:
                self.sdnom = self.sd.nom
                self.finModif()
                return 1, tr("Concept existant")
            else:
                return 0, tr("Operateur reentrant mais concept non existant")
        #
        # Cas particulier des operateurs facultativement reentrants
        #
        old_reuse = None
        if self.definition.reentrant == "f":
            sd = self.jdc.getSdAvantEtape(nom, self)
            if sd != None:
                if isinstance(sd, self.getType_produit()):
                    self.sd = self.reuse = sd
                    self.sdnom = sd.nom
                    self.finModif()
                    return 1, tr("Operateur reentrant et concept existant trouve")
                else:
                    return 0, tr("Concept deja existant et de mauvais type")
            else:
                # il faut enlever le lien vers une SD existante car si on passe ici
                # cela signifie que l'operateur n'est pas utilise en mode reentrant.
                # Si on ne fait pas cela, on risque de modifier une SD produite par un autre operateur
                if self.reuse:
                    old_reuse = self.reuse
                    self.sd = self.reuse = self.sdnom = None
        #
        # On est dans le cas ou l'operateur n'est pas reentrant ou est facultativement reentrant
        # mais est utilise en mode non reentrant
        #
        if self.sd == None:
            # Pas de concept produit preexistant
            if self.parent.getSdAutourEtape(nom, self):
                # Un concept de ce nom existe dans le voisinage de l'etape courante
                # On retablit l'ancien concept reentrant s'il existait
                if old_reuse:
                    self.sd = self.reuse = old_reuse
                    self.sdnom = old_reuse.nom
                return 0, tr( "Nommage du concept refuse : un concept de meme nom existe deja")
            else:
                # Il n'existe pas de concept de ce nom dans le voisinage de l'etape courante
                # On peut donc creer le concept retourne
                # Il est cree sans nom mais enregistre dans la liste des concepts existants
                try:
                    self.getSdProd()
                    # Renommage du concept : Il suffit de changer son attribut nom pour le nommer
                    self.sd.nom = nom
                    self.sdnom = nom
                    self.parent.sdsDict[nom] = self.sd
                    self.parent.updateConceptAfterEtape(self, self.sd)
                    self.finModif()
                    return 1, tr("Nommage du concept effectue")
                except:
                    return 0, tr("Nommage impossible %s", str(sys.exc_info()[1]))
        else:
            # Un concept produit preexiste
            old_nom = self.sd.nom
            if old_nom.find("sansnom"):
                # Dans le cas ou old_nom == sansnom, isValid retourne 0 alors que ...
                # par contre si le concept existe et qu'il s'appelle sansnom c'est que l'etape est valide
                # on peut donc le nommer sans test prealable
                if self.parent.getSdAutourEtape(nom, self):
                    return 0, tr( "Nommage du concept refuse : un concept de meme nom existe deja")
                else:
                    # Renommage du concept : Il suffit de changer son attribut nom pour le nommer
                    self.sd.nom = nom
                    self.sdnom = nom
                    self.parent.updateConceptAfterEtape(self, self.sd)
                    self.finModif()
                    return 1, tr("Nommage du concept effectue")
            if self.isValid():
                # Normalement l appel de isValid a mis a jour le concept produit (son type)
                # Il suffit de specifier l attribut nom de sd pour le nommer si le nom n est pas
                # deja attribue
                if self.parent.getSdAutourEtape(nom, self):
                    return 0, tr( "Nommage du concept refuse : un concept de meme nom existe deja")
                else:
                    # Renommage du concept : Il suffit de changer son attribut nom pour le nommer
                    self.sd.nom = nom
                    self.sdnom = nom
                    self.parent.updateConceptAfterEtape(self, self.sd)
                    self.finModif()
                    return 1, tr("Nommage du concept effectue")
            else:
                # Normalement on ne devrait pas passer ici
                return 0, "nommeSd de Etape : Normalement on ne devrait pas passer ici"

    def getIndexDsParent(self):
        return self.parent.getIndex(self)

    def getSdprods(self, nom_sd):
        """
        Fonction : retourne le concept produit par l etape de nom nom_sd
        s il existe sinon None
        """
        if self.sd:
            if self.sd.nom == nom_sd:
                return self.sd

    def active(self):
        """
        Rend l'etape courante active.
        Il faut ajouter la sd si elle existe au contexte global du JDC
        et a la liste des sd
        """
        if self.actif:
            return
        self.actif = 1
        self.initModif()
        if self.sd:
            try:
                self.jdc.appendSdProd(self.sd)
            except:
                pass
        CONNECTOR.Emit(self, "add", None)
        CONNECTOR.Emit(self, "valid")

    def inactive(self):
        """
        Rend l'etape courante inactive
        Il faut supprimer la sd du contexte global du JDC
        et de la liste des sd
        """
        self.actif = 0
        self.initModif()
        if self.sd:
            self.jdc.delSdprod(self.sd)
            self.jdc.deleteConceptAfterEtape(self, self.sd)
        #print ('jjjjjjjjjj CONNECTOR.Emit ETAPE')
        CONNECTOR.Emit(self, "supp", None)
        CONNECTOR.Emit(self, "valid")

    def controlSdprods(self, d):
        """
        Cette methode doit verifier que ses concepts produits ne sont pas
        deja definis dans le contexte
        Si c'est le cas, les concepts produits doivent etre supprimes
        """
        # print ("controlSdprods etape",d.keys(),self.sd and self.sd.nom,self.nom)
        if self.sd:
            if self.sd.nom in d:
                # Le concept est deja defini
                if self.reuse and self.reuse is d[self.sd.nom]:
                    # Le concept est reutilise : situation normale
                    pass
                else:
                    # Redefinition du concept, on l'annule
                    # XXX on pourrait simplement annuler son nom pour conserver les objets
                    # l'utilisateur n'aurait alors qu'a renommer le concept (faisable??)
                    self.initModif()
                    sd = self.sd
                    self.sd = self.reuse = self.sdnom = None
                    # supprime les references a sd dans les etapes suivantes
                    self.parent.deleteConceptAfterEtape(self, sd)
                    self.finModif()

    def supprimeSdprod(self, sd):
        """
        Supprime le concept produit sd s'il est produit par l'etape
        """
        if sd is not self.sd:
            return
        if self.sd != None:
            self.initModif()
            self.parent.delSdprod(sd)
            self.sd = None
            self.finModif()
            self.parent.deleteConcept(sd)

    def supprimeSdProds(self):
        """
        Fonction:
        Lors d'une destruction d'etape, detruit tous les concepts produits
        Un operateur n a qu un concept produit
        Une procedure n'en a aucun
        Une macro en a en general plus d'un
        """
        self.deleteRef()
        # print "supprimeSdProds",self
        if self.reuse is self.sd:
            return
        # l'etape n'est pas reentrante
        # le concept retourne par l'etape est a supprimer car il etait
        # cree par l'etape
        if self.sd != None:
            self.parent.delSdprod(self.sd)
            self.parent.deleteConcept(self.sd)

    def close(self):
        return

    def updateConcept(self, sd):
        for child in self.mcListe:
            child.updateConcept(sd)

    def deleteConcept(self, sd):
        """
        Inputs :
           - sd=concept detruit
        Fonction :
        Mettre a jour les mots cles de l etape et eventuellement
        le concept produit si reuse
        suite a la disparition du concept sd
        Seuls les mots cles simples MCSIMP font un traitement autre
        que de transmettre aux fils
        """
        if self.reuse and self.reuse == sd:
            self.sd = self.reuse = None
            self.initModif()
        for child in self.mcListe:
            child.deleteConcept(sd)

    def replaceConcept(self, old_sd, sd):
        """
        Inputs :
           - old_sd=concept remplace
           - sd = nouveau concept
        Fonction :
        Mettre a jour les mots cles de l etape et eventuellement
        le concept produit si reuse
        suite au remplacement  du concept old_sd
        """
        if self.reuse and self.reuse == old_sd:
            self.sd = self.reuse = sd
            self.initModif()
        for child in self.mcListe:
            child.replaceConcept(old_sd, sd)

    def resetContext(self):
        pass

    def getNomsSdOperReentrant(self):
        """
        Retourne la liste des noms de concepts utilisesa l'interieur de la commande
        qui sont du type que peut retourner cette commande
        """
        liste_sd = self.getSd_utilisees()
        l_noms = []
        if type(self.definition.sd_prod) == types.FunctionType:
            d = self.creeDictValeurs(self.mcListe)
            try:
                classe_sd_prod = self.definition.sd_prod(*(), **d)
            except:
                return []
        else:
            classe_sd_prod = self.definition.sd_prod
        for sd in liste_sd:
            if sd.__class__ is classe_sd_prod:
                l_noms.append(sd.nom)
        l_noms.sort()
        return l_noms

    def getGenealogiePrecise(self):
        return [self.nom]

    def getMCPath(self):
        return [self.nom, "@sdname " + self.sd.nom + " @"]

    def getNomDsXML(self):
        # en xml on a un choice
        index = 0
        for e in self.parent.etapes:
            if e == self:
                break
            if e.nom == self.nom:
                index += 1
        nomDsXML = self.nom + "[" + str(index) + "]"
        return nomDsXML

    def getGenealogie(self):
        """
        Retourne la liste des noms des ascendants de l'objet self
        en s'arretant a la premiere ETAPE rencontree
        """
        return [self.nom]

    def verifExistenceSd(self):
        """
        Verifie que les structures de donnees utilisees dans self existent bien dans le contexte
        avant etape, sinon enleve la referea ces concepts
        """
        # print "verifExistenceSd",self.sd
        for motcle in self.mcListe:
            motcle.verifExistenceSd()

    def updateMcGlobal(self):
        """
        Met a jour les mots cles globaux enregistres dans l'etape
        et dans le jdc parent.
        Une etape ne peut pas etre globale. Elle se contente de passer
        la requete a ses fils apres avoir reinitialise le dictionnaire
        des mots cles globaux.
        """
        self.mc_globaux = {}
        A_MCCOMPO.MCCOMPO.updateMcGlobal(self)

    def updateConditionBloc(self):
        """
        Realise l'update des blocs conditionnels fils de self
        """
        self._updateConditionBloc()

    def getObjetCommentarise(self, format):
        """
        Cette methode retourne un objet commande commentarisee
        representant la commande self
        """
        import Accas.IO.writer as generator

        g = generator.plugins[format]()
        texte_commande = g.gener(self, format="beautifie")
        # Il faut enlever la premiere ligne vide de texte_commande que
        # rajoute le generator
        # on construit l'objet COMMANDE_COMM repesentatif de self mais non
        # enregistre dans le jdc (pas ajoute dans jdc.etapes)
        parent = self.parent
        pos = self.parent.etapes.index(self)
        # on ajoute une fin à la commande pour pouvoir en commenter 2
        texte_commande += "\nFin Commentaire"
        commande_comment = commande_comm.COMMANDE_COMM(
            texte=texte_commande, reg="non", parent=parent
        )
        self.parent.suppEntite(self)
        parent.addEntite(commande_comment, pos)

        return commande_comment

    def modified(self):
        """Le contenu de l'etape (mots cles, ...) a ete modifie"""
        if self.nom == "DETRUIRE":
            self.parent.controlContextApres(self)

    # ATTENTION SURCHARGE: a garder en synchro ou a reintegrer dans processing 
    def buildSd(self, nom):
        """
        Mmethode de processing surchargee pour poursuivre malgre tout
        si une erreur se produit pendant la creation du concept produit
        """
        try:
            # sd = Accas.processing.P_ETAPE.ETAPE.buildSd(self, nom)
            sd = P_ETAPE.ETAPE.buildSd(self, nom)
        except AsException as e:
            # Une erreur s'est produite lors de la construction du concept
            # Comme on est dans EFICAS, on essaie de poursuivre quand meme
            # Si on poursuit, on a le choix entre deux possibilites :
            # 1. on annule la sd associee a self
            # 2. on la conserve mais il faut la retourner
            # En plus il faut rendre coherents sdnom et sd.nom
            self.sd = None
            self.sdnom = None
            self.state = "unchanged"
            self.valid = 0

        return self.sd

    # ATTENTION SURCHARGE: cette methode doit etre gardee en synchronisation avec processing
    def makeRegister(self):
        """
        Initialise les attributs jdc, id, niveau et realise les
        enregistrements necessaires
        Pour EFICAS, on tient compte des niveaux
        Surcharge la methode makeRegister du package processing
        """
        if self.parent:
            self.jdc = self.parent.getJdcRoot()
            self.id = self.parent.register(self)
            self.UserError = self.jdc.UserError
            if self.definition.niveau:
                # La definition est dans un niveau. En plus on
                # l'enregistre dans le niveau
                self.nom_niveau_definition = self.definition.niveau.nom
                self.niveau = self.parent.dict_niveaux[self.nom_niveau_definition]
                self.niveau.register(self)
            else:
                # La definition est au niveau global
                self.nom_niveau_definition = "JDC"
                self.niveau = self.parent
        else:
            self.jdc = self.parent = None
            self.id = None
            self.niveau = None
            self.UserError = "UserError"

    def report(self):
        cr = V_ETAPE.ETAPE.report(self)
        # rafraichisst de la validite de l'etape (probleme avec l'ordre dans les macros : etape puis mots cles)
        self.isValid()
        if not self.isValid() and self.nom == "INCLUDE":
            self.cr.fatal(
                "Etape : {} ligne : {}  {}".format(
                    self.nom,
                    self.appel[0],
                    tr("\n   Include Invalide. \n  ne sera pas pris en compte"),
                )
            )
        return cr
