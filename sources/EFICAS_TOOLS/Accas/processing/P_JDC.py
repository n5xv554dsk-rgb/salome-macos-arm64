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
   Ce module contient la classe JDC qui sert a interpreter un jeu de commandes
"""
from builtins import str
from builtins import range
import os
import types
import sys
import linecache

# Modules EFICAS
from Accas.processing import P_OBJECT
from Accas.processing import P_CR
from Accas.processing.P_Exception import AsException, InterruptParsingError
from Accas.processing.P_ASSD import ASSD
from Accas.processing.strfunc import getEncoding


class JDC(P_OBJECT.OBJECT):

    """
    Cette classe interprete un jeu de commandes fourni sous
    la forme d'une chaine de caractères

    Attributs de classe :

    Attributs d'instance :

    """

    nature = "JDC"
    CR = P_CR.CR
    exec_init = """import Accas
from Accas import _F
from Accas import *
NONE = None
"""

    from Accas.processing.P_utils import SEP

    def __init__( self, definition=None, procedure=None, cata=None, dicoCataOrdonne=None,
        parent=None, nom="SansNom", appliEficas=None, editeur = None, context_ini=None, **args):
        self.procedure = procedure
        self.definition = definition
        self.cata = cata
        self._build_reserved_kw_list()
        self.dicoCataOrdonne = dicoCataOrdonne
        self.nom = nom
        self.appliEficas = appliEficas
        self.parent = parent
        self.context_ini = context_ini

        # On conserve les arguments supplementaires. Il est possible de passer
        # des informations globales au JDC par ce moyen. Il pourrait etre plus
        # sur de mettre en place le mecanisme des mots-cles pour verifier la
        # validite des valeurs passees.
        # Ceci reste a faire
        # On initialise avec les parametres de la definition puis on
        # update avec ceux du JDC
        self.args = self.definition.args
        self.args.update(args)
        self.nstep = 0
        self.nsd = 0
        self.parLot = "OUI"
        self.parLot_user = None
        if definition:
            self.regles = definition.regles
            self.code = definition.code
        else:
            self.regles = ()
            self.code = "CODE"
        #
        #  Creation de l objet compte rendu pour collecte des erreurs
        #
        self.cr = self.CR(
            debut="CR phase d'initialisation", fin="fin CR phase d'initialisation"
        )
        # on met le jdc lui-meme dans le context global pour l'avoir sous
        # l'etiquette "jdc" dans le fichier de commandes
        self.g_context = {"jdc": self}
        CONTEXT.unsetCurrentJdC()
        CONTEXT.setCurrentJdC(self)
        # Dictionnaire pour stocker tous les concepts du JDC (acces rapide par
        # le nom)
        self.sdsDict = {}
        self.etapes = []
        self.index_etapes = {}
        self.mc_globaux = {}
        self.currentContext = {}
        self.condition_context = {}
        self.index_etape_courante = 0
        self.UserError = "UserError"
        self.alea = None
        # permet transitoirement de conserver la liste des etapes
        self.hist_etape = False

    def compile(self):
        """
        Cette methode compile la chaine procedure
        Si des erreurs se produisent, elles sont consignees dans le
        compte-rendu self.cr
        """
        try:
            encoded_filename = self.nom.encode(getEncoding())
            self.proc_compile = compile(self.procedure, encoded_filename, "exec")
        except SyntaxError as e:
            import traceback
            if CONTEXT.debug:
                traceback.print_exc()
            l = traceback.format_exception_only(SyntaxError, e)
            self.cr.exception("Compilation impossible : " + "".join(l))
        except SystemError as e:
            erreurs_connues = """
Causes possibles :
 - offset too large : liste trop longue derrière un mot-cle.
   Solution : liste = (valeurs, ..., )
              MOT_CLE = *liste,
"""
            import traceback
            l = traceback.format_exception_only(SystemError, e)
            l.append(erreurs_connues)
            self.cr.exception("Compilation impossible : " + "".join(l))
        return

    def setCurrentContext(self):
        # beaucoup trop simple Ne tient pas compte des imports
        # et des include
        # ne sert que pour le POC
        CONTEXT.setCurrentStep(self)

    def execCompile(self):
        """
        Cette methode execute le jeu de commandes compile dans le contexte
        self.g_context de l'objet JDC
        """

        CONTEXT.setCurrentStep(self)
        # Le module nommage utilise le module linecache pour acceder
        # au source des commandes du jeu de commandes.
        # Dans le cas d'un fichier, on accède au contenu de ce fichier
        # Dans le cas d'une chaine de caractères il faut acceder
        # aux commandes qui sont dans la chaine
        import linecache
        import traceback

        linecache.cache[self.nom] = 0, 0, self.procedure.split("\n"), self.nom
        try:
            exec(self.exec_init, self.g_context)
            for obj_cata in (self.cata,):
                if type(obj_cata) == types.ModuleType:
                    init2 = "from " + obj_cata.__name__ + " import *"
                    exec(init2, self.g_context)
                else:
                    # ici on a un catalogue en grammaire Eficas XML
                    # il faut ajouter ce qu on a construit au contexte
                    for k, v in obj_cata.contexteXML.items():
                        self.g_context[k] = v
            # Initialisation du contexte global pour l'evaluation des conditions de BLOC
            # On utilise une copie de l'initialisation du contexte du jdc
            self.condition_context = self.g_context.copy()

            # Si l'attribut context_ini n'est pas vide, on ajoute au contexte global
            # le contexte initial (--> permet d'evaluer un JDC en recuperant un contexte
            # d'un autre par exemple)
            if self.context_ini:
                self.g_context.update(self.context_ini)
                # Update du dictionnaire des concepts
                for sdnom, sd in list(self.context_ini.items()):
                    if isinstance(sd, ASSD):
                        self.sdsDict[sdnom] = sd


            # On sauve le contexte pour garder la memoire des constantes
            # En mode edition (EFICAS) ou lors des verifications le contexte
            # est recalcule
            # mais les constantes sont perdues
            self.const_context = self.g_context
            exec(self.proc_compile, self.g_context)

            CONTEXT.unsetCurrentStep()

        except InterruptParsingError:
            # interrupt the command file parsing used by FIN to ignore the end
            # of the file
            pass

        except EOFError:
            # Exception utilise pour interrompre un jeu
            # de commandes avant la fin
            # Fonctionnement normal, ne doit pas etre considere comme une
            # erreur
            CONTEXT.unsetCurrentStep()
            self.afficheFinExec()
            self.traiterFinExec("commande")

        except AsException as e:
            # une erreur a ete identifiee
            if CONTEXT.debug:
                traceback.print_exc()
            # l'exception a ete recuperee avant (ou, comment ?),
            # donc on cherche dans le texte
            txt = str(e)
            self.cr.exception(txt)
            CONTEXT.unsetCurrentStep()

        except NameError as e:
            etype, value, tb = sys.exc_info()
            l = traceback.extract_tb(tb)
            s = traceback.format_exception_only(NameError, e)
            msg = "erreur de syntaxe,  %s ligne %d" % (s, l[-1][1])
            if CONTEXT.debug:
                traceback.print_exc()
            self.cr.exception(msg)
            CONTEXT.unsetCurrentStep()

        # except self.UserError as exc_val:
        #     self.traiterUserException(exc_val)
        #     CONTEXT.unsetCurrentStep()
        #     self.afficheFinExec()
        #     self.traiterFinExec('commande')

        except:
            # erreur inattendue
            # sys_exc_typ,sys_exc_value,sys_exc_frame = sys_exc.info()
            # (tuple de 3 elements)
            if CONTEXT.debug:
                traceback.print_exc()

            exc_typ, exc_val, exc_fr = sys.exc_info()
            l = traceback.format_exception(exc_typ, exc_val, exc_fr)
            self.cr.exception(
                "erreur non prevue et non traitee prevenir la maintenance "
                + "\n"
                + "".join(l)
            )
            del exc_typ, exc_val, exc_fr
            CONTEXT.unsetCurrentStep()
        idx = 0
        for e in self.etapes:
            self.enregistreEtapePyxb(e, idx)
            idx = idx + 1

    def afficheFinExec(self):
        """
        utilisee par le superviseur : obsolete
        Cette methode realise l'affichage final des statistiques de temps
        apres l'execution de toutes
        les commandes en mode commande par commande ou par lot
        Elle doit etre surchargee pour en introduire un
        """
        return

    def traiterFinExec(self, mode, etape=None):
        """
        utilisee par le superviseur : obsolete
        Cette methode realise un traitement final apres l'execution de toutes
        les commandes en mode commande par commande ou par lot
        Par defaut il n'y a pas de traitement. Elle doit etre surchargee
        pour en introduire un
        """
        print("FIN D'EXECUTION %s %s" % s(mode, etape))

    def traiterUserException(self, exc_val):
        """Cette methode realise un traitement sur les exceptions utilisateur
        Par defaut il n'y a pas de traitement. La methode doit etre
        surchargee pour en introduire un.
        """
        return

    def register(self, etape):
        """
        Cette methode ajoute etape dans la liste des etapes : self.etapes
        et retourne un numero d'enregistrement
        """
        self.etapes.append(etape)
        self.index_etapes[etape] = len(self.etapes) - 1
        return self.gRegister(etape)

    def o_register(self, sd):
        """
        Retourne un identificateur pour concept
        """
        self.nsd = self.nsd + 1
        nom = sd.idracine + self.SEP + repr(self.nsd)
        return nom

    def gRegister(self, etape):
        """
        Retourne un identificateur pour etape
        """
        self.nstep = self.nstep + 1
        idetape = etape.idracine + self.SEP + repr(self.nstep)
        return idetape

    def createSdprod(self, etape, nomsd):
        """
        Cette methode doit fabriquer le concept produit retourne
        par l'etape etape et le nommer.

        Elle est appelee a l'initiative de l'etape
        pendant le processus de construction de cette etape :
        methode __call__ de la classe CMD (OPER ou MACRO)

        Ce travail est realise par le contexte superieur
        (etape.parent) car dans certains cas, le concept ne doit
        pas etre fabrique mais l'etape doit simplement utiliser
        un concept preexistant.

        """
        sd = etape.getSdProd()
        if sd != None and (etape.definition.reentrant == "n" or etape.reuse is None):
            # ATTENTION : On ne nomme la SD que dans le cas de non reutilisation
            # d un concept. Commande non reentrante ou reuse absent.
            self.nommerSDProd(sd, nomsd)
        return sd

    def nommerSDProd(self, sd, sdnom, restrict="non"):
        """
        Nomme la SD apres avoir verifie que le nommage est possible : nom
        non utilise
        Si le nom est deja utilise, leve une exception
        Met le concept cree dans le concept global g_context
        """
        o = self.sdsDict.get(sdnom, None)
        if isinstance(o, ASSD):
            raise AsException("Nom de concept deja defini : %s" % sdnom)
        if sdnom in self._reserved_kw:
            raise AsException(
                "Nom de concept invalide. '%s' est un mot-cle reserve." % sdnom
            )

        # Ajoute a la creation (appel de regSD).
        self.sdsDict[sdnom] = sd
        sd.setName(sdnom)

        # En plus si restrict vaut 'non', on insere le concept dans le contexte
        # du JDC
        if restrict == "non":
            self.g_context[sdnom] = sd

    def regUserSD(self, sd):
        # utilisee pour creer les references
        # se contente d appeler la methode equivalente sur le jdc
        id = self.regSD(sd)
        self.nommerSDProd(sd, sd.nom)
        return id

    def regSD(self, sd):
        """
        Methode appelee dans l __init__ d un ASSD lors de sa creation
        pour s enregistrer
        """
        return self.o_register(sd)

    def deleteConceptAfterEtape(self, etape, sd):
        """
        Met a jour les etapes du JDC qui sont après etape suite a
        la disparition du concept sd
        """
        # Cette methode est definie dans le processing mais ne sert que pendant
        # la phase de creation des etapes et des concepts. Il n'y a aucun
        # traitement particulier a realiser.
        # Dans d'autres conditions, il faut surcharger cette methode
        return

    def supprime(self):
        P_OBJECT.OBJECT.supprime(self)
        for etape in self.etapes:
            etape.supprime()

    def clean(self, netapes):
        """Nettoie les `netapes` dernières etapes de la liste des etapes."""
        if self.hist_etape:
            return
        for i in range(netapes):
            e = self.etapes.pop()
            jdc = e.jdc
            parent = e.parent
            e.supprime()
            e.parent = parent
            e.jdc = jdc
            del self.index_etapes[e]

    def getFile(self, unite=None, fic_origine="", fname=None):
        """
        Retourne le nom du fichier correspondant a un numero d'unite
        logique (entier) ainsi que le source contenu dans le fichier
        """
        # if self.appliEficas:
        # Si le JDC est relie a une appliEficascation maitre, on delègue la
        # recherche
        #    return self.appliEficas.getFile(unite, fic_origine)
        # else:
        #    if unite != None:
        #        if os.path.exists("fort." + str(unite)):
        #            fname = "fort." + str(unite)
        if fname == None:
            raise AsException("Impossible de trouver le fichier correspondant")
        if not os.path.exists(fname):
            raise AsException(fname + " n'est pas un fichier existant")
        fproc = open(fname, "r")
        text = fproc.read()
        fproc.close()
        text = text.replace("\r\n", "\n")
        linecache.cache[fname] = 0, 0, text.split("\n"), fname
        return fname, text

    def set_parLot(self, parLot, user_value=False):
        """
        utilisee par le superviseur : obsolete
        Met le mode de traitement a PAR LOT
        ou a COMMANDE par COMMANDE
        en fonction de la valeur du mot cle PAR_LOT et
        du contexte : appliEficascation maitre ou pas

        En PAR_LOT='NON', il n'y a pas d'ambiguite.
        d'analyse et juste avant la phase d'execution.
        `user_value` : permet de stocker la valeur choisie par l'utilisateur
        pour l'interroger plus tard (par exemple dans `getContexteAvant`).
        """
        if user_value:
            self.parLot_user = parLot
        if self.appliEficas == None:
            # Pas d appliEficascation maitre
            self.parLot = parLot
        else:
            # Avec appliEficascation maitre
            self.parLot = "OUI"

    def accept(self, visitor):
        """
        Cette methode permet de parcourir l'arborescence des objets
        en utilisant le pattern VISITEUR
        """
        visitor.visitJDC(self)

    def interact(self):
        """
        essai jamais mene au bout
        Cette methode a pour fonction d'ouvrir un interpreteur
        pour que l'utilisateur entre des commandes interactivement
        """
        CONTEXT.setCurrentStep(self)
        try:
            # Le module nommage utilise le module linecache pour acceder
            # au source des commandes du jeu de commandes.
            # Dans le cas d'un fichier, on accède au contenu de ce fichier
            # Dans le cas de la console interactive, il faut pouvoir acceder
            # aux commandes qui sont dans le buffer de la console
            import linecache
            import code

            console = code.InteractiveConsole(self.g_context, filename="<console>")
            linecache.cache["<console>"] = 0, 0, console.buffer, "<console>"
            banner = (
                """***********************************************
*          Interpreteur interactif %s
***********************************************"""
                % self.code
            )
            console.interact(banner)
        finally:
            console = None
            CONTEXT.unsetCurrentStep()

    def getContexteAvant(self, etape):
        """
        Retourne le dictionnaire des concepts connus avant etape
        On tient compte des commandes qui modifient le contexte
        comme les macros, les includes
        Si etape == None, on retourne le contexte en fin de JDC
        """
        # L'etape courante pour laquelle le contexte a ete calcule est
        # memorisee dans self.index_etape_courante
        # memorisant l'etape # courante pendant le processus 
        # de construction des etapes.
        # Si on insère des commandes  il faut prealablement
        # remettre ce pointeur a 0
        if etape:
            index_etape = self.index_etapes[etape]
        else:
            index_etape = len(self.etapes)
        if index_etape >= self.index_etape_courante:
            # On calcule le contexte en partant du contexte existant
            d = self.currentContext
            if self.index_etape_courante == 0 and self.context_ini:
                d.update(self.context_ini)
            liste_etapes = self.etapes[self.index_etape_courante : index_etape]
        else:
            d = self.currentContext = {}
            if self.context_ini:
                d.update(self.context_ini)
            liste_etapes = self.etapes

        for e in liste_etapes:
            if e is etape:
                break
            if e.isActif():
                e.updateContext(d)
        self.index_etape_courante = index_etape
        return d

    def getGlobalContexte(self):
        """Retourne "un" contexte global ;-)"""
        # N'est utilise que par INCLUDE (sauf erreur).
        # g_context est remis a {} en PAR_LOT='OUI'. const_context permet
        # de retrouver ce qui y a ete mis par execCompile.
        # Les concepts n'y sont pas en PAR_LOT='OUI'. Ils sont ajoutes
        # par getGlobalContexte de la MACRO.
        d = self.const_context.copy()
        d.update(self.g_context)
        return d

    def getContexteCourant(self, etape_courante=None):
        """
        Retourne le contexte tel qu'il est (ou 'sera' si on est en phase
        de construction) au moment de l'execution de l'etape courante.
        """
        if etape_courante is None:
            etape_courante = CONTEXT.getCurrentStep()
        return self.getContexteAvant(etape_courante)

    def getConcept(self, nomsd):
        """
        Methode pour recuperer un concept a partir de son nom
        """
        co = self.getContexteCourant().get(nomsd.strip(), None)
        if not isinstance(co, ASSD):
            co = None
        return co

    def getConceptByType(self, nomsd, typesd, etape):
        """
        Methode pour recuperer un concept a partir de son nom et de son type.
        Il aura comme père 'etape'.
        """
        assert issubclass(typesd, ASSD), typesd
        co = typesd(etape=etape)
        co.setName(nomsd)
        co.executed = 1
        return co

    def delConcept(self, nomsd):
        """
        Methode pour supprimer la reference d'un concept dans le sdsDict.
        Ne detruire pas le concept (different de supprime).
        """
        try:
            del self.sdsDict[nomsd.strip()]
        except:
            pass

    def getCmd(self, nomcmd):
        """
        Methode pour recuperer la definition d'une commande
        donnee par son nom dans les catalogues declares
        au niveau du jdc
        """
        for cata in (self.cata,):
            if hasattr(cata, nomcmd):
                return getattr(cata, nomcmd)

    def append_reset(self, etape):
        """
        Ajoute une etape provenant d'un autre jdc a la liste des etapes
        et remet a jour la parente de l'etape et des concepts
        """
        self.etapes.append(etape)
        self.index_etapes[etape] = len(self.etapes) - 1
        etape.reparent(self)
        etape.resetJdc(self)

    def sdAccessible(self):
        """On peut acceder aux "valeurs" (jeveux) des ASSD si le JDC est en PAR_LOT="NON"."""
        if CONTEXT.debug:
            print((" `- JDC sdAccessible : PAR_LOT =", self.parLot))
        return self.parLot == "NON"

    def getEtapesByName(self, name):
        listeDEtapes = []
        for e in self.etapes:
            if e.nom == name:
                listeDEtapes.append(e)
        return listeDEtapes

    def getEtapeByConceptName(self, conceptName):
        for e in self.etapes:
            if hasattr(e, "sdnom") and e.sdnom == conceptName:
                return e

    def revalide(self, definition) :
        debug = 0
        if debug : print ('revalide ', definition)
        for e in self.etapes:
            e.revalide(definition)


    def _build_reserved_kw_list(self):
        """Construit la liste des mots-cles reserves (interdits pour le
        nommage des concepts)."""
        # A completer avec les UserASSD ?
        self._reserved_kw = set()
        # for cat in self.cata:
        cat = self.cata
        self._reserved_kw.update(
            # PN 14  2020 [kw for kw in dir(cat) if len(kw) <= 8 and kw == kw.upper()])
            [kw for kw in dir(cat)]
        )
        self._reserved_kw.difference_update(
            [
                "OPER",
                "MACRO",
                "BLOC",
                "SIMP",
                "FACT",
                "FORM",
                "GEOM",
                "MCSIMP",
                "MCFACT",
            ]
        )

    def prepareInsertInDB(self):
        debug = 0
        if debug: print("prepareInsertInDB traitement de ", self.nom)
        if hasattr(self, "dPrimaryKey"):
            dPrimaryKey = self.dPrimaryKey
        else:
            dPrimaryKey = {}
        if hasattr(self, "dElementsRecursifs"):
            dElementsRecursifs = self.dElementsRecursifs
        else:
            dElementsRecursifs = {}
        dictKey = {}
        if debug: print("dElementsRecursifs", dElementsRecursifs)
        if debug: print( "dPrimaryKey", dPrimaryKey,)
        for mc in dPrimaryKey.values():
            dictKey[mc] = None
        texte = ""
        for e in self.etapes:
            tc, tv, ta = e.prepareInsertInDB(dictKey, dElementsRecursifs, dPrimaryKey)
            texte += tc + tv + ta
        return texte
