# coding=utf-8
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


"""
    Ce module contient la classe MACRO_ETAPE qui sert a verifier et a executer
    une commande
"""

# Modules Python
import types
import sys
import traceback
from warnings import warn

# Modules EFICAS
from Accas.processing import P_MCCOMPO
from Accas.processing import P_ETAPE
from Accas.processing.P_Exception import AsException
from Accas.processing import P_utils
from Accas.processing.P_utils import AsType
from Accas.processing.P_CO import CO
from Accas.processing.P_ASSD import ASSD


class MACRO_ETAPE(P_ETAPE.ETAPE):

    """ """

    nature = "COMMANDE"
    typeCO = CO

    def __init__(self, oper=None, reuse=None, args={}):
        """
        Attributs :
           - definition : objet portant les attributs de definition d'une etape
             de type macro-commande. Il est initialise par
             l'argument oper.
           - reuse : indique le concept d'entree reutilise. Il se trouvera donc
             en sortie si les conditions d'execution de l'operateur
             l'autorise
           - valeur : arguments d'entree de type mot-cle=valeur. Initialise
             avec l'argument args.
        """
        P_ETAPE.ETAPE.__init__(self, oper, reuse, args, niveau=5)
        self.g_context = {}
        # Contexte courant
        self.currentContext = {}
        self.macro_const_context = {}
        self.index_etape_courante = 0
        self.etapes = []
        self.index_etapes = {}
        #  Dans le cas d'une macro ecrite en Python, l'attribut Outputs est un
        #  dictionnaire qui contient les concepts produits de sortie
        #  (nom : ASSD) declares dans la fonction sd_prod
        self.Outputs = {}
        self.sdprods = []
        self.UserError = "UserError"
        # permet de stocker le nom du dernier concept nomme dans la macro
        self.last = None

    def makeRegister(self):
        """
        Initialise les attributs jdc, id, niveau et realise les enregistrements
        necessaires
        """
        P_ETAPE.ETAPE.makeRegister(self)
        if self.parent:
            self.UserError = self.jdc.UserError
        else:
            self.UserError = "UserError"

    def buildSd(self, nom):
        """
        Construit le concept produit de l'operateur. Deux cas
        peuvent se presenter :

          - le parent n'est pas defini. Dans ce cas, l'etape prend en charge
            la creation et le nommage du concept.

          - le parent est defini. Dans ce cas, l'etape demande au parent la
            creation et le nommage du concept.

        """
        self.sdnom = nom
        try:
            # On positionne la macro self en tant que current_step pour que les
            # etapes creees lors de l'appel a sd_prod et a op_init aient la macro
            #  comme parent
            self.setCurrentStep()
            if self.parent:
                sd = self.parent.createSdprod(self, nom)
                if type(self.definition.op_init) == types.FunctionType:
                    self.definition.op_init(*(self, self.parent.g_context))
            else:
                sd = self.getSdProd()
                if sd != None and self.reuse == None:
                    # On ne nomme le concept que dans le cas de non reutilisation
                    # d un concept
                    sd.setName(nom)
            self.resetCurrentStep()
        except AsException as e:
            self.resetCurrentStep()
            raise AsException(
                "Etape ",
                self.nom,
                "ligne : ",
                self.appel[0],
                "fichier : ",
                self.appel[1],
                e,
            )
        # except (EOFError, self.UserError):
        except EOFError:
            # Le retablissement du step courant n'est pas strictement
            # necessaire. On le fait pour des raisons de coherence
            self.resetCurrentStep()
            raise
        except:
            self.resetCurrentStep()
            l = traceback.format_exception(
                sys.exc_info()[0], sys.exc_info()[1], sys.exc_info()[2]
            )
            raise AsException(
                "Etape ",
                self.nom,
                "ligne : ",
                self.appel[0],
                "fichier : ",
                self.appel[1] + "\n",
                "".join(l),
            )

        self.Execute()
        return sd

    def getSdProd(self):
        """
        Retourne le concept resultat d'une macro etape
        La difference avec une etape ou une proc-etape tient a ce que
        le concept produit peut exister ou pas

        Si sd_prod == None le concept produit n existe pas on retourne None

        Deux cas :
         - cas 1 : sd_prod  n'est pas une fonction
                 il s'agit d'une sous classe de ASSD
                 on construit le sd a partir de cette classe
                 et on le retourne
         - cas 2 : sd_prod est une fonction
                 on l'evalue avec les mots-cles de l'etape (mcListe)
                 on construit le sd a partir de la classe obtenue
                 et on le retourne
        """
        sd_prod = self.definition.sd_prod
        self.typret = None

        if type(self.definition.sd_prod) == types.FunctionType:
            d = self.creeDictValeurs(self.mcListe)
            try:
                # la sd_prod d'une macro a l'objet macro_etape lui meme en premier argument
                # Comme sd_prod peut invoquer la methode typeSDProd qui ajoute
                # les concepts produits dans self.sdprods, il faut le mettre a
                # zero avant de l'appeler
                self.sdprods = []
                sd_prod = sd_prod(*(self,), **d)
            # except (EOFError, self.UserError):
            except EOFError:
                raise
            except Exception as exc:
                if CONTEXT.debug:
                    traceback.print_exc()
                raise AsException(
                    "impossible d affecter un type au resultat:", str(exc)
                )

        # on teste maintenant si la SD est reutilisee ou s'il faut la creer
        if self.definition.reentrant != "n" and self.reuse:
            # Le concept produit est specifie reutilise (reuse=xxx). C'est une erreur mais non fatale.
            # Elle sera traitee ulterieurement.
            self.sd = self.reuse
        else:
            if sd_prod == None:
                self.sd = None
            else:
                self.sd = sd_prod(etape=self)
                self.typret = sd_prod
                # Si la commande est obligatoirement reentrante et reuse n'a pas ete specifie, c'est une erreur.
                # On ne fait rien ici. L'erreur sera traitee par la suite.
        # precaution
        if self.sd is not None and not isinstance(self.sd, ASSD):
            raise AsException(
                """
Impossible de typer le resultat !
Causes possibles :
   Utilisateur : Soit la valeur fournie derrière "reuse" est incorrecte,
                 soit il y a une "," a la fin d'une commande precedente.
   Developpeur : La fonction "sd_prod" retourne un type invalide."""
            )
        return self.sd

    def getType_produit(self, force=0):
        try:
            return self.getType_produit_brut(force)
        except:
            # traceback.print_exc()
            return None

    def getType_produit_brut(self, force=0):
        """
        Retourne le type du concept resultat de l'etape et eventuellement type
        les concepts produits "a droite" du signe egal (en entree)

        Deux cas :
          - cas 1 : sd_prod de oper n'est pas une fonction
                 il s'agit d'une sous classe de ASSD
                 on retourne le nom de la classe
          - cas 2 : il s'agit d'une fonction
                 on l'evalue avec les mots-cles de l'etape (mcListe)
                 et on retourne son resultat
        """
        if not force and hasattr(self, "typret"):
            return self.typret

        if type(self.definition.sd_prod) == types.FunctionType:
            d = self.creeDictValeurs(self.mcListe)
            # Comme sd_prod peut invoquer la methode typeSDProd qui ajoute
            # les concepts produits dans self.sdprods, il faut le mettre a zero
            self.sdprods = []
            sd_prod = self.definition.sd_prod(*(self,), **d)
        else:
            sd_prod = self.definition.sd_prod
        return sd_prod

    def getContexteAvant(self, etape):
        """
        Retourne le dictionnaire des concepts connus avant etape
        pour les commandes internes a la macro
        On tient compte des commandes qui modifient le contexte
        comme DETRUIRE ou les macros
        """
        # L'etape courante pour laquelle le contexte a ete calcule est
        # memorisee dans self.index_etape_courante
        # self.currentContext.items() if isinstance(v, ASSD)])
        d = self.currentContext = self.g_context.copy()
        if etape is None:
            return d
        # retirer les sd produites par 'etape'
        sd_names = [sd.nom for sd in etape.getCreated_sd()]
        for nom in sd_names:
            try:
                del d[nom]
            except KeyError:
                pass
                # Exemple avec INCLUDE_MATERIAU appele dans une macro.
                # Les fonctions restent uniquement dans le contexte de INCLUDE_MATERIAU,
                # elles ne sont donc pas dans le contexte de la macro appelante.
                # from warnings import warn
                # warn("concept '%s' absent du contexte de %s" % (nom, self.nom),
                # RuntimeWarning, stacklevel=2)
        return d

    def supprime(self):
        """
        Methode qui supprime toutes les references arrières afin que
        l'objet puisse etre correctement detruit par le garbage collector
        """
        P_MCCOMPO.MCCOMPO.supprime(self)
        self.jdc = None
        self.appel = None
        if self.sd:
            self.sd.supprime()
        for concept in self.sdprods:
            concept.supprime()
        for etape in self.etapes:
            etape.supprime()

    def clean(self, netapes):
        """Nettoie les `netapes` dernières etapes de la liste des etapes."""
        if self.jdc.hist_etape:
            return
        for i in range(netapes):
            e = self.etapes.pop()
            jdc = e.jdc
            parent = e.parent
            e.supprime()
            e.parent = parent
            e.jdc = jdc
            del self.index_etapes[e]

    def typeSDProd(self, co, t):
        """
        Cette methode a pour fonction de typer le concept co avec le type t
        dans les conditions suivantes :
         1. co est un concept produit de self
         2. co est un concept libre : on le type et on l attribue a self

        Elle enregistre egalement les concepts produits (on fait l hypothese
        que la liste sdprods a ete correctement initialisee, vide probablement)
        """
        if not hasattr(co, "etape"):
            # Le concept vaut None probablement. On ignore l'appel
            return
        #
        # On cherche a discriminer les differents cas de typage d'un concept
        # produit par une macro qui est specifie dans un mot cle simple.
        # On peut passer plusieurs fois par typeSDProd ce qui explique
        # le nombre important de cas.
        #
        # Cas 1 : Le concept est libre. Il vient d'etre cree par CO(nom)
        # Cas 2 : Le concept est produit par la macro. On est deja passe par typeSDProd.
        #         Cas semblable a Cas 1.
        # Cas 3 : Le concept est produit par la macro englobante (parent). On transfere
        #         la propriete du concept de la macro parent a la macro courante (self)
        #         en verifiant que le type est valide
        # Cas 4 : La concept est la propriete d'une etape fille. Ceci veut dire qu'on est
        #         deja passe par typeSDProd et que la propriete a ete transfere a une
        #         etape fille. Cas semblable a Cas 3.
        # Cas 5 : Le concept est produit par une etape externe a la macro.
        #
        if co.etape == None:
            # Cas 1 : le concept est libre
            # On l'attache a la macro et on change son type dans le type demande
            # Recherche du mot cle simple associe au concept
            mcs = self.getMcsWithCo(co)
            if len(mcs) != 1:
                raise AsException(
                    """Erreur interne.
Il ne devrait y avoir qu'un seul mot cle porteur du concept CO (%s)"""
                    % co
                )
            mcs = mcs[0]
            if not self.typeCO in mcs.definition.type:
                raise AsException(
                    """Erreur interne.
Impossible de changer le type du concept (%s). Le mot cle associe ne supporte pas CO mais seulement (%s)"""
                    % (co, mcs.definition.type)
                )
            co.etape = self
            # affectation du bon type du concept
            co.changeType(t)
            self.sdprods.append(co)

        elif co.etape == self:
            # Cas 2 : le concept est produit par la macro (self)
            # On est deja passe par typeSDProd (Cas 1 ou 3).
            # XXX Peut-il etre creer par une autre macro ?
            #    On verifie juste que c'est un vrai CO non deja type
            # if co.etape == co._etape:
            if co.isTypCO() == 1:
                # Le concept a ete cree par la macro (self)
                # On peut changer son type
                co.changeType(t)
            else:
                # Le concept a ete cree par une macro parente
                # Le type du concept doit etre coherent avec le type demande
                # (seulement derive)
                if not isinstance(co, t):
                    raise AsException(
                        """Erreur interne.
Le type demande (%s) et le type du concept (%s) devraient etre derives"""
                        % (t, co.__class__)
                    )

            self.sdprods.append(co)

        elif co.etape == self.parent:
            # Cas 3 : le concept est produit par la macro parente (self.parent)
            # on transfere la propriete du concept a la macro fille
            # et on change le type du concept comme demande
            # Au prealable, on verifie que le concept existant (co) est une instance
            # possible du type demande (t)
            # Cette règle est normalement coherente avec les règles de
            # verification des mots-cles
            if not isinstance(co, t):
                raise AsException(
                    """
Impossible de changer le type du concept produit (%s) en (%s).
Le type actuel (%s) devrait etre une classe derivee du nouveau type (%s)"""
                    % (co, t, co.__class__, t)
                )
            mcs = self.getMcsWithCo(co)
            if len(mcs) != 1:
                raise AsException(
                    """Erreur interne.
Il ne devrait y avoir qu'un seul mot cle porteur du concept CO (%s)"""
                    % co
                )
            mcs = mcs[0]
            if not self.typeCO in mcs.definition.type:
                raise AsException(
                    """Erreur interne.
Impossible de changer le type du concept (%s). Le mot cle associe ne supporte pas CO mais seulement (%s)"""
                    % (co, mcs.definition.type)
                )
            co.etape = self
            # On ne change pas le type car il respecte la condition isinstance(co,t)
            # co.__class__ = t
            self.sdprods.append(co)

        elif self.issubstep(co.etape):
            # Cas 4 : Le concept est propriete d'une sous etape de la macro (self).
            # On est deja passe par typeSDProd (Cas 3 ou 1).
            # Il suffit de le mettre dans la liste des concepts produits (self.sdprods)
            # Le type du concept et t doivent etre derives.
            # Il n'y a aucune raison pour que la condition ne soit pas
            # verifiee.
            if not isinstance(co, t):
                raise AsException(
                    """Erreur interne.
Le type demande (%s) et le type du concept (%s) devraient etre derives"""
                    % (t, co.__class__)
                )
            self.sdprods.append(co)

        else:
            # Cas 5 : le concept est produit par une autre etape
            # On ne fait rien
            return

    def issubstep(self, etape):
        """
        Cette methode retourne un entier indiquant si etape est une
        sous etape de la macro self ou non
        1 = oui
        0 = non
        """
        if etape in self.etapes:
            return 1
        for etap in self.etapes:
            if etap.issubstep(etape):
                return 1
        return 0

    def register(self, etape):
        """
        Enregistrement de etape dans le contexte de la macro : liste etapes
        et demande d enregistrement global aupres du JDC
        """
        self.etapes.append(etape)
        self.index_etapes[etape] = len(self.etapes) - 1
        idetape = self.jdc.gRegister(etape)
        return idetape

    def regSD(self, sd):
        """
        Methode appelee dans l __init__ d un ASSD a sa creation pour
        s enregistrer (reserve aux ASSD crees au sein d'une MACRO)
        """
        return self.jdc.o_register(sd)

    def createSdprod(self, etape, nomsd):
        """
        Cette methode doit fabriquer le concept produit retourne
        par l'etape etape et le nommer.

        Elle est appelee a l'initiative de l'etape
        pendant le processus de construction de cette etape : methode __call__
        de la classe CMD (OPER ou MACRO)
        Ce travail est realise par le contexte superieur (etape.parent)
        car dans certains cas, le concept ne doit pas etre fabrique mais
        l'etape doit simplement utiliser un concept preexistant.
                - Cas 1 : etape.reuse != None : le concept est reutilise
                - Cas 2 : l'etape appartient a une macro qui a declare un concept
                  de sortie qui doit etre produit par cette etape.
        """
        if nomsd in self.Outputs:
            # Il s'agit d'un concept de sortie de la macro. Il ne faut pas le creer
            # Il faut quand meme appeler la fonction sd_prod si elle existe.
            # getType_produit le fait et donne le type attendu par la commande
            # pour verification ulterieure.
            sdprod = etape.getType_produit_brut()
            sd = self.Outputs[nomsd]
            # On verifie que le type du concept existant sd.__class__ est un sur type de celui attendu
            # Cette règle est normalement coherente avec les règles de
            # verification des mots-cles
            if not issubclass(sdprod, sd.__class__):
                raise AsException(
                    "Le type du concept produit %s devrait etre une sur classe de %s"
                    % (sd.__class__, sdprod)
                )
            # La propriete du concept est transferee a l'etape avec le type
            # attendu par l'etape
            etape.sd = sd
            sd.etape = etape
            if (
                self.reuse == sd
                and etape.reuse != sd
                and getattr(sd, "executed", 0) == 1
            ):  # n'a pas ete pas detruit
                raise AsException(
                    "Le concept '%s' est reentrant dans la macro-commande %s. "
                    "Il devrait donc l'etre dans %s (produit sous le nom '%s')."
                    % (sd.nom, self.nom, etape.nom, nomsd)
                )
            # On donne au concept le type produit par la sous commande.
            # Le principe est le suivant : apres avoir verifie que le type deduit par la sous commande
            # est bien coherent avec celui initialement affecte par la macro (voir ci dessus)
            # on affecte au concept ce type car il peut etre plus precis
            # (derive, en general)
            sd.__class__ = sdprod
            # On force egalement le nom stocke dans l'attribut sdnom : on lui donne le nom
            # du concept associe a nomsd
            etape.sdnom = sd.nom
            # pour l'ajouter au contexte de la macro
            self.g_context[sd.nom] = sd
        elif etape.definition.reentrant != "n" and etape.reuse != None:
            # On est dans le cas d'une commande avec reutilisation d'un concept existant
            # getSdProd fait le necessaire : verifications, associations, etc. mais ne cree
            # pas un nouveau concept. Il retourne le concept reutilise
            sd = etape.getSdProd()
            # Dans le cas d'un concept nomme automatiquement : _xxx, __xxx,
            # On force le nom stocke dans l'attribut sdnom  de l'objet etape : on lui donne le nom
            # du concept  reutilise (sd ou etape.reuse c'est pareil)
            # Ceci est indispensable pour eviter des erreurs lors des verifications des macros
            # En effet une commande avec reutilisation d'un concept verifie que le nom de
            # la variable a gauche du signe = est le meme que celui du concept reutilise.
            # Lorsqu'une telle commande apparait dans une macro, on supprime
            # cette verification.
            if etape.sdnom == "" or etape.sdnom[0] == "_":
                etape.sdnom = sd.nom
        else:
            # On est dans le cas de la creation d'un nouveau concept
            sd = etape.getSdProd()
            if sd != None:
                self.nommerSDProd(sd, nomsd)
        return sd

    def nommerSDProd(self, sd, sdnom, restrict="non"):
        """
        Cette methode est appelee par les etapes internes de la macro.
        La macro appelle le JDC pour valider le nommage.
        On considère que l'espace de nom est unique et gere par le JDC.
        Si le nom est deja utilise, l'appel lève une exception.
        Si restrict=='non', on insère le concept dans le contexte du parent de la macro.
        Si restrict=='oui', on insère le concept uniquement dans le contexte de la macro.
        """
        # Normalement, lorsqu'on appelle cette methode, on ne veut nommer que des concepts nouvellement crees.
        # Le filtrage sur les concepts a creer ou a ne pas creer est fait dans la methode
        # createSdprod. La seule chose a verifier apres conversion eventuelle du nom
        # est de verifier que le nom n'est pas deja attribue. Ceci est fait en delegant
        # au JDC par l'intermediaire du parent.
        if sdnom in self.Outputs:
            # Il s'agit d'un concept de sortie de la macro produit par une
            # sous commande
            sdnom = self.Outputs[sdnom].nom
        elif len(sdnom) > 0:
            if sdnom[0] in ("_", ".") and sdnom[1:].isdigit():
                # il est deja de la forme _9000012 ou .9000017
                pass
            elif sdnom[0] == "_":
                # Si le nom du concept commence par le caractère '_', on lui attribue
                # un identificateur JEVEUX construit par gcncon.
                # nom commençant par __ : il s'agit de concepts qui seront detruits
                # nom commençant par _ : il s'agit de concepts intermediaires
                # qui seront gardes
                if len(sdnom) > 1 and sdnom[1] == "_":
                    sdnom = self.gcncon(".")
                else:
                    sdnom = self.gcncon("_")
            elif self.nom in ("INCLUDE", "MACR_RECAL"):
                # dans le cas d'INCLUDE, on passe
                # MACR_RECAL fonctionne comme INCLUDE
                pass
            else:
                # On est dans le cas d'un nom de concept global
                # XXX a voir, creation de CO() dans CALC_ESSAI (sdls139a)
                if not sd.isTypCO():
                    raise AsException(
                        "Resultat non declare par la macro %s : %s" % (self.nom, sdnom)
                    )
        self.last = sdnom
        if restrict == "non":
            # On demande le nommage au parent mais sans ajout du concept dans le contexte du parent
            # car on va l'ajouter dans le contexte de la macro
            self.parent.nommerSDProd(sd, sdnom, restrict="oui")
            # On ajoute dans le contexte de la macro les concepts nommes
            # Ceci est indispensable pour les CO (macro) dans un INCLUDE
            self.g_context[sdnom] = sd
        else:
            # La demande de nommage vient probablement d'une macro qui a mis
            # le concept dans son contexte. On ne traite plus que le nommage (restrict="oui")
            self.parent.nommerSDProd(sd, sdnom, restrict="oui")

    def deleteConceptAfterEtape(self, etape, sd):
        """
        Met a jour les etapes de la MACRO  qui sont après etape suite a
        la disparition du concept sd
        """
        # Cette methode est definie dans le processing mais ne sert que pendant la phase de creation
        # des etapes et des concepts. Il n'y a aucun traitement particulier a realiser
        # Dans d'autres conditions, il faudrait surcharger cette methode.
        return

    def getCreated_sd(self):
        """Retourne la liste des sd reellement produites par l'etape.
        Si reuse est present, `self.sd` a ete creee avant, donc n'est pas dans
        cette liste."""
        sdprods = self.sdprods[:]
        if not self.reuse and self.sd:
            sdprods.append(self.sd)
        return sdprods

    def getLastConcept(self):
        """Retourne le dernier concept produit dans la macro.
        Peut-etre utile pour acceder au contenu 'fortran' dans une
        clause 'except'."""
        return self.g_context.get(self.last, None)

    def accept(self, visitor):
        """
        Cette methode permet de parcourir l'arborescence des objets
        en utilisant le pattern VISITEUR
        """
        visitor.visitMACRO_ETAPE(self)

    def updateContext(self, d):
        """
        Met a jour le contexte contenu dans le dictionnaire d
        Une MACRO_ETAPE peut ajouter plusieurs concepts dans le contexte
        Une fonction enregistree dans op_init peut egalement modifier le contexte
        """
        if type(self.definition.op_init) == types.FunctionType:
            self.definition.op_init(*(self, d))
        if self.sd != None:
            d[self.sd.nom] = self.sd
        for co in self.sdprods:
            d[co.nom] = co

    def makeInclude(self, unite=None, fname=None):
        """Inclut un fichier dont l'unite logique est `unite` ou de nom `fname`"""
        if unite is not None:
            warn(
                "'unite' is deprecated, please use 'fname' instead",
                DeprecationWarning,
                stacklevel=2,
            )
            fname = "fort.%s" % unite
        if not fname:
            return
        f, text = self.getFile(fic_origine=self.parent.nom, fname=fname)
        self.fichier_init = f
        if f == None:
            return
        self.makeContexte(f, text)

    def makePoursuite(self):
        """Inclut un fichier poursuite"""
        raise NotImplementedError("this method must be derivated (in Eficas)")

    def makeContexte(self, f, text):
        """
        Interprete le texte fourni (text) issu du fichier f
        dans le contexte du parent.
        Cette methode est utile pour le fonctionnement des
        INCLUDE
        """
        # on execute le texte fourni dans le contexte forme par
        # le contexte de l etape pere (global au sens Python)
        # et le contexte de l etape (local au sens Python)
        code = compile(text, f, "exec")
        d = self.g_context = self.macro_const_context
        globs = self.getGlobalContexte()
        d.update(globs)
        exec(code, globs, d)
        # pour ne pas conserver des references sur tout
        self.macro_const_context = {}

    def getGlobalContexte(self):
        """
        Cette methode retourne le contexte global fourni
        par le parent(self) a une etape fille (l'appelant) pour
        realiser des evaluations de texte Python (INCLUDE,...)
        """
        # Le contexte global est forme par concatenation du contexte
        # du parent de self et de celui de l'etape elle meme (self)
        # Pour les concepts, cela ne doit rien changer. Mais pour les constantes,
        # les valeurs de getContexteAvant sont moins recentes que dans
        # getGlobalContexte. On prend donc la precaution de ne pas ecraser
        # ce qui y est deja.
        d = self.parent.getGlobalContexte()
        d.update(self.g_context)
        d.update(
            [
                (k, v)
                for k, v in list(self.parent.getContexteAvant(self).items())
                if d.get(k) is None
            ]
        )
        return d

    def getContexteCourant(self, etape_fille_du_jdc=None):
        """
        Retourne le contexte tel qu'il est au moment de l'execution de
        l'etape courante.
        """
        ctx = {}
        # update car par ricochet on modifierait jdc.currentContext
        ctx.update(self.parent.getContexteCourant(self))
        # on peut mettre None car toujours en PAR_LOT='NON', donc la dernière
        ctx.update(self.getContexteAvant(None))
        return ctx

    def getConcept(self, nomsd):
        """
        Methode pour recuperer un concept a partir de son nom
        dans le contexte du jdc connu avant l'execution de la macro courante.
        """
        # chercher dans self.getContexteAvant, puis si non trouve
        # self.parent.getConcept est peut-etre plus performant
        co = self.getContexteCourant().get(nomsd.strip(), None)
        if not isinstance(co, ASSD):
            co = None
        return co

    def getConceptByType(self, nomsd, typesd, etape=None):
        """
        Methode pour recuperer un concept a partir de son nom et de son type.
        Il aura comme père 'etape' (ou la macro courante si etape est absente).
        """
        return self.parent.getConceptByType(nomsd, typesd, etape=etape or self)

    def copy(self):
        """Methode qui retourne une copie de self non enregistree auprès du JDC
        et sans sd
        On surcharge la methode de ETAPE pour exprimer que les concepts crees
        par la MACRO d'origine ne sont pas crees par la copie mais eventuellement
        seulement utilises
        """
        etape = P_ETAPE.ETAPE.copy(self)
        etape.sdprods = []
        return etape

    def copyIntern(self, etape):
        """Cette methode effectue la recopie des etapes internes d'une macro
        passee en argument (etape)
        """
        self.etapes = []
        self.index_etapes = {}
        for etp in etape.etapes:
            new_etp = etp.copy()
            new_etp.copyReuse(etp)
            new_etp.copySdnom(etp)
            new_etp.reparent(self)
            if etp.sd:
                new_sd = etp.sd.__class__(etape=new_etp)
                new_etp.sd = new_sd
                if etp.reuse:
                    new_sd.setName(etp.sd.nom)
                else:
                    self.nommerSDProd(new_sd, etp.sd.nom)
            new_etp.copyIntern(etp)
            self.etapes.append(new_etp)
            self.index_etapes[new_etp] = len(self.etapes) - 1

    def resetJdc(self, new_jdc):
        """
        Reinitialise l'etape avec un nouveau jdc parent new_jdc
        """
        if self.sd and self.reuse == None:
            self.parent.nommerSDProd(self.sd, self.sd.nom)
        for concept in self.sdprods:
            self.parent.nommerSDProd(concept, concept.nom)

    def reparent(self, parent):
        """
        Cette methode sert a reinitialiser la parente de l'objet
        """
        P_ETAPE.ETAPE.reparent(self, parent)
        # on ne change pas la parente des concepts. On s'assure uniquement que
        # le jdc en reference est le bon
        for concept in self.sdprods:
            concept.jdc = self.jdc
        for e in self.etapes:
            e.reparent(self)

    def updateConstContext(self, d):
        """
        Met a jour le contexte des constantes pour l'evaluation de
        formules dans la macro.
        """
        # Dans le jdc, const_context est mis a jour par execCompile
        # Dans la macro, on n'a pas le code a compiler pour recupèrer les
        # constantes locales a la macro. On demande donc explicitement de
        # definir les constantes "locales".
        self.macro_const_context.update(d)

    def sdAccessible(self):
        """On peut acceder aux "valeurs" (jeveux) des ASSD dans
        les macro-commandes qui sont localement en PAR_LOT="NON"
        sauf pour INCLUDE.
        """
        if CONTEXT.debug:
            print((" `- MACRO sdAccessible :", self.nom))
        return self.parent.sdAccessible() or not self.isInclude()
