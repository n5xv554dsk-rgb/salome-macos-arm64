# -*- coding: iso-8859-1 -*-
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
import sys
import os.path as osp
import traceback, types

# Modules Eficas
from Accas.extensions.eficas_translation import tr
from Accas.extensions.eficas_exception import EficasException
from Accas.accessor import A_ETAPE
from Accas.accessor import A_ENTITE
from Accas.accessor import A_OBJECT
from Accas.processing.P_ASSD import ASSD
from Accas.processing import P__F
from Accas.processing import P_MACRO_ETAPE
from Accas.processing import P_Exception
from Accas.processing.P_Exception import AsException
from Accas.extensions import param2

# fin import a resorber


class MACRO_ETAPE(A_ETAPE.ETAPE):
    def __init__(self):
        self.typret = None
        # indique si le jeu de commande inclus a pu etre analyse par convert
        # pour etre editable (0=NON, 1=OUI)
        self.text_converted = 1
        self.text_error = ""
        self.recorded_units = {}

    def getSdprods(self, nom_sd):
        """
        Fonction : retourne le concept produit par l etape de nom nom_sd
        s il existe sinon None
        """
        if self.sd and self.sd.nom == nom_sd:
            return self.sd
        for co in self.sdprods:
            if co.nom == nom_sd:
                return co
        if type(self.definition.op_init) == types.FunctionType:
            d = {}
            self.definition.op_init(*(self, d))
            return d.get(nom_sd, None)
        return None

    def getContexteJdc(self, fichier, text, doitEtreValide=1):
        """
        Interprete text comme un texte de jdc et retourne le contexte final.

        Le contexte final est le dictionnaire des sd disponibles a la derniere etape.
        Si text n'est pas un texte de jdc valide, retourne None
        ou leve une exception
        --> utilisee par ops.POURSUITE et INCLUDE
        """
        # print ("getContexteJdc",self,self.nom, text)
        # On recupere l'etape courante
        step = CONTEXT.getCurrentStep()
        self.text_included_converted = 0
        try:
            # if 1 :
            # on essaie de creer un objet JDC auxiliaire avec un contexte initial
            # Attention getContexteAvant retourne un dictionnaire qui contient
            # le contexte courant. Ce dictionnaire est reactualise regulierement.
            # Si on veut garder l'etat du contexte fige, il faut en faire une copie.
            context_ini = self.parent.getContexteAvant(self).copy()

            # Indispensable avant de creer un nouveau JDC
            CONTEXT.unsetCurrentStep()
            args = self.jdc.args
            prefix_include = None
            if hasattr(self, "prefix"):
                prefix_include = self.prefix
            # ATTENTION : le dictionnaire recorded_units sert a memoriser les unites des
            # fichiers inclus. Il est preferable de garder le meme dictionnaire pendant
            # tout le traitement et de ne pas le reinitialiser brutalement (utiliser
            # clear plutot) si on ne veut pas perdre la memoire des unites.
            # En principe si la memorisation est faite au bon moment il n'est pas necessaire
            # de prendre cette precaution mais ce n'est pas vrai partout.
            old_recorded_units = self.recorded_units.copy()

            # on supprime l'ancien jdc_aux s'il existe
            if hasattr(self, "jdc_aux") and self.jdc_aux:
                self.jdc_aux.supprime_aux()

            if fichier is None:
                fichier = "SansNom"

            # Il faut convertir le texte inclus en fonction du format
            self.text_converted = 0
            self.text_error = ""
            format = self.jdc.appliEficas.format_fichier
            import Accas.IO.reader as convert
            if format in convert.plugins:
                # Le convertisseur existe on l'utilise
                p = convert.plugins[format]()
                p.text = text
                text = p.convert("exec", self.jdc.appliEficas)
                # Si le fichier ne peut pas etre converti, le cr n'est pas vide
                # et le texte est retourne tel que
                if not p.cr.estvide():
                    self.text_converted = 0
                    self.text_error = str(p.cr)
                else:
                    self.text_converted = 1

            if hasattr(self, "sd") and self.sd != None:
                context_ini[self.sd.nom] = self.sd
            j = self.JdC_aux(
                procedure=text,
                nom=fichier,
                appliEficas=self.jdc.appliEficas,
                cata=self.jdc.cata,
                dicoCataOrdonne=self.jdc.dicoCataOrdonne,
                context_ini=context_ini,
                jdc_pere=self.jdc,
                etape_include=self,
                prefix_include=prefix_include,
                recorded_units=self.recorded_units,
                old_recorded_units=old_recorded_units,
                **args
            )

            j.analyse()
            if not j.cr.estvide():
                self.text_included_converted = 0
            else:
                self.text_included_converted = 1
            self.text_included_error = str(j.cr)
            # On recupere les etapes internes (pour Accas.validation)
            self.etapes = j.etapes
            self.jdc_aux = j
            self.jdc.jdcDict = self.jdc_aux

        except:
            # else :
            traceback.print_exc()
            # On retablit l'etape courante step
            CONTEXT.unsetCurrentStep()
            CONTEXT.setCurrentStep(step)
            return None

        if not j.cr.estvide() and doitEtreValide:
            # Erreurs dans l'INCLUDE. On garde la memoire du fichier
            # mais on n'insere pas les concepts
            # On retablit l'etape courante step
            # print (j.cr)
            # print ("valid ",j.isValid())
            CONTEXT.unsetCurrentStep()
            CONTEXT.setCurrentStep(step)
            raise EficasException(
                tr("Impossible de relire le fichier %s \n ") + str(j.cr)
            )

        if not j.isValid() and doitEtreValide:
            # L'INCLUDE n'est pas valide.
            # on produit un rapport d'erreurs
            cr = j.report()
            # print ('cr', cr)
            # On retablit l'etape courante step
            CONTEXT.unsetCurrentStep()
            CONTEXT.setCurrentStep(step)
            self.jdc.cr.fatal("Le fichier include contient des erreurs ")
            raise EficasException(tr("Le fichier include contient des erreurs "))

        # Si aucune erreur rencontree
        # ou qu on accepte un jdc incomplet
        # On recupere le contexte de l'include verifie
        try:
            j_context = j.getVerifContexte()
            # print j_context.keys()
            # print j.g_context.keys()
        except:
            # On retablit l'etape courante step
            CONTEXT.unsetCurrentStep()
            CONTEXT.setCurrentStep(step)
            raise EficasException(" ")

        # Si on est arrive ici, le texte du fichier inclus (INCLUDE, POURSUITE, ...)
        # est valide et inserable dans le JDC

        # On remplit le dictionnaire des concepts produits inclus
        # en retirant les concepts presents dans le  contexte initial
        # On ajoute egalement le concept produit dans le sdsDict du parent
        # sans verification car on est sur (verification integree) que
        # le nommage est possible
        self.g_context.clear()
        for k, v in j_context.items():
            if (not k in context_ini) or (context_ini[k] != v):
                self.g_context[k] = v
                self.parent.sdsDict[k] = v

        # Ce traitement n'est realise que dans les cas suivants:
        #     - si convert n'a pas pu convertir le jeu de commandes
        #     - et ce n'est pas un INCLUDE_MATERIAU
        # On collecte les variables Python qui ne sont pas dans le contexte initial
        # et dans le contexte valide et on en fait un pseudo-parametre (Variable)
        if self.text_converted == 0 and self.nom != "INCLUDE_MATERIAU":
            for k, v in j.g_context.items():
                if k in context_ini:
                    continue
                if k in j_context:
                    continue
                if isinstance(v, ASSD):
                    continue
                if isinstance(v, A_ENTITE.ENTITE):
                    continue
                if isinstance(v, A_OBJECT.OBJECT):
                    continue
                if callable(v):
                    continue
                self.g_context[k] = param2.Variable(k, v)

        # On recupere le contexte courant
        self.currentContext = j.currentContext
        self.index_etape_courante = j.index_etape_courante
        self.jdc_aux = j

        # On retablit l'etape courante step
        CONTEXT.unsetCurrentStep()
        CONTEXT.setCurrentStep(step)

        return j_context

    def reevalueSdJdc(self):
        """
        Avec la liste des SD qui ont ete supprimees, propage la
        disparition de ces SD dans toutes les etapes et descendants
        """
        # print "reevalueSdJdc"
        l_sd_supp, l_sd_repl = self.diffContextes()
        for sd in l_sd_supp:
            self.parent.deleteConceptAfterEtape(self, sd)
        for old_sd, sd in l_sd_repl:
            self.parent.replaceConceptAfterEtape(self, old_sd, sd)

    def diffContextes(self):
        """
        Realise la difference entre les 2 contextes
        old_contexte_fichier_init et contexte_fichier_init
        cad retourne la liste des sd qui ont disparu ou ne derivent pas
        de la meme classe et des sd qui ont ete remplacees
        """
        if not hasattr(self, "old_contexte_fichier_init"):
            return [], []
        l_sd_suppressed = []
        l_sd_replaced = []
        for old_key in self.old_contexte_fichier_init:
            if not old_key in self.contexte_fichier_init:
                if isinstance(self.old_contexte_fichier_init[old_key], ASSD):
                    l_sd_suppressed.append(self.old_contexte_fichier_init[old_key])
            else:
                if isinstance(self.old_contexte_fichier_init[old_key], ASSD):
                    # Un concept de meme nom existe
                    old_class = self.old_contexte_fichier_init[old_key].__class__
                    if not isinstance(self.contexte_fichier_init[old_key], old_class):
                        # S'il n'est pas d'une classe derivee, on le supprime
                        l_sd_suppressed.append(self.old_contexte_fichier_init[old_key])
                    else:
                        l_sd_replaced.append(
                            (
                                self.old_contexte_fichier_init[old_key],
                                self.contexte_fichier_init[old_key],
                            )
                        )
        return l_sd_suppressed, l_sd_replaced

    def controlSdprods(self, d):
        """
        Cette methode doit verifier que les concepts produits par la
        commande ne sont pas incompatibles avec le contexte fourni (d).
        Si c'est le cas, le concept produit doit etre supprime
        Si la macro a elle meme des etapes, elle doit propager
        le traitement (voir methode controlJdcContextApres de A_JDC)
        """
        # print ("A_MACRO_ETAPE.controlSdprods",d.keys(),self,self.nom,self.sd and self.sd.nom)
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
                    self.parent.deleteConceptAfterEtape(self, sd)
                    self.finModif()

        # On verifie les concepts a droite du signe =
        self.initModif()
        sdprods = self.sdprods[:]
        self.sdprods = []
        for co in sdprods:
            if co.nom in d and co is not d[co.nom]:
                # nettoie les mots cles de l'etape qui ont comme valeur co
                self.deleteConcept(co)
                # supprime les references a co dans les etapes suivantes
                self.parent.deleteConceptAfterEtape(self, co)
            else:
                self.sdprods.append(co)
        self.finModif()

        for e in self.etapes:
            e.controlSdprods(d)
            e.updateContext(d)

    def supprimeSdprod(self, sd):
        """
        Supprime le concept produit sd s'il est produit par l'etape
        """
        # print ('supprimeSdprod de MACRO_ETAPE')
        if sd in self.sdprods:
            self.initModif()
            self.parent.delSdprod(sd)
            self.sdprods.remove(sd)
            self.finModif()
            self.parent.deleteConcept(sd)
            return

        if sd is not self.sd:
            return
        if self.sd is not None:
            self.initModif()
            self.parent.delSdprod(sd)
            self.sd = None
            self.finModif()
            self.parent.deleteConcept(sd)

    def supprimeSdProds(self):
        """
        Fonction: Lors de la destruction de la macro-etape, detruit tous les concepts produits
        Un operateur n a qu un concept produit
        Une procedure n'en a aucun
        Une macro en a en general plus d'un
        """
        # print "supprimeSdProds"
        if self.reuse is not self.sd:
            # l'etape n'est pas reentrante
            # le concept retourne par l'etape est a supprimer car il etait
            # cree par l'etape
            if self.sd != None:
                self.parent.delSdprod(self.sd)
                self.parent.deleteConcept(self.sd)
        # On detruit les concepts a droite du signe =
        for co in self.sdprods:
            self.parent.delSdprod(co)
            self.parent.deleteConcept(co)
        # Si la macro a des etapes et des concepts inclus, on les detruit
        for nom_sd, co in self.g_context.items():
            if not isinstance(co, ASSD):
                continue
            self.parent.delSdprod(co)
            self.parent.deleteConcept(co)
        # On met g_context a blanc
        self.g_context = {}

    def close(self):
        # print "close",self
        if hasattr(self, "jdc_aux") and self.jdc_aux:
            # La macro a un jdc auxiliaire inclus. On demande sa fermeture
            self.jdc_aux.close()

    def resetContext(self):
        if hasattr(self, "jdc_aux") and self.jdc_aux:
            # La macro a un jdc auxiliaire inclus. On demande la reinitialisation du contexte
            self.jdc_aux.resetContext()

    def updateConcept(self, sd):
        A_ETAPE.ETAPE.updateConcept(self, sd)
        for etape in self.etapes:
            etape.updateConcept(sd)

    def deleteConcept(self, sd):
        """
        Fonction : Mettre a jour les mots cles de l etape et eventuellement
        le concept produit si reuse suite a la disparition du concept sd
        Seuls les mots cles simples MCSIMP font un traitement autre
        que de transmettre aux fils
        """
        # print "deleteConcept",sd
        A_ETAPE.ETAPE.deleteConcept(self, sd)
        for etape in self.etapes:
            etape.deleteConcept(sd)

    def replaceConcept(self, old_sd, sd):
        """
        Fonction : Mettre a jour les mots cles de l etape et le concept produit si reuse
        suite au remplacement  du concept old_sd par sd
        """
        # print "replaceConcept",old_sd,sd
        A_ETAPE.ETAPE.replaceConcept(self, old_sd, sd)
        for etape in self.etapes:
            etape.replaceConcept(old_sd, sd)

    def changeFichierInit(self, new_fic, text):
        """
        Tente de changer le fichier include. Le precedent include est conserve
        dans old_xxx
        """
        if not hasattr(self, "fichier_ini"):
            self.fichier_ini = None
            self.fichier_text = None
            self.fichier_err = "Le fichier n'est pas defini"
            self.contexte_fichier_init = {}
            self.recorded_units = {}
            self.jdc_aux = None
            self.fichier_unite = "PasDefini"
            import Accas.extensions.jdc_include

            self.JdC_aux = extensions.jdc_include.JdC_include

        self.old_fic = self.fichier_ini
        self.old_text = self.fichier_text
        self.old_err = self.fichier_err
        self.old_context = self.contexte_fichier_init
        self.old_units = self.recorded_units
        self.old_etapes = self.etapes
        self.old_jdc_aux = self.jdc_aux

        self.fichier_ini = new_fic
        self.fichier_text = text

        try:
            self.makeContexteInclude(new_fic, text)
        except:
            l = traceback.format_exception_only(
                tr("Fichier invalide %s", sys.exc_info()[1])
            )
            self.fichier_err = "".join(l)
            raise EficasException(self.fichier_err)

        # L'evaluation de text dans un JDC auxiliaire s'est bien passe
        # on peut poursuivre le traitement
        self.initModif()
        self.state = "undetermined"
        self.fichier_err = None
        # On enregistre la modification de fichier
        self.recordUnite()
        # Le contexte du parent doit etre reinitialise car les concepts produits ont change
        self.parent.resetContext()

        # Si des concepts ont disparu lors du changement de fichier, on demande leur suppression
        self.old_contexte_fichier_init = self.old_context
        self.reevalueSdJdc()

        self.finModif()
        if self.old_jdc_aux:
            self.old_jdc_aux.close()

    def restoreFichierInit(self):
        """
        Restaure le fichier init enregistre dans old_xxx
        """
        self.fichier_ini = self.old_fic
        self.fichier_text = self.old_text
        self.fichier_err = self.old_err
        self.contexte_fichier_init = self.old_context
        self.recorded_units = self.old_units
        self.etapes = self.old_etapes
        self.jdc_aux = self.old_jdc_aux

    def forceFichierInit(self):
        """
        Force le remplacement du fichier init meme si le remplacant est en erreur
        """
        # Reinitialisation complete du compte-rendu d'erreurs
        self.jdc_aux.cr = self.jdc_aux.CR()
        # On remplit le dictionnaire des concepts produits inclus
        # en retirant les concepts presents dans le  contexte initial
        # On ajoute egalement le concept produit dans le sdsDict du parent
        # sans verification car on est sur (verification integree) que
        # le nommage est possible
        j_context = self.jdc_aux.getContexteAvant(None)
        self.g_context.clear()
        context_ini = self.jdc_aux.context_ini
        for k, v in j_context.items():
            if not k in context_ini or context_ini[k] != v:
                self.g_context[k] = v
                self.parent.sdsDict[k] = v
        # On recupere le contexte courant
        self.currentContext = self.jdc_aux.currentContext
        self.index_etape_courante = self.jdc_aux.index_etape_courante
        self.contexte_fichier_init = j_context
        self.fichier_err = None

        # On enregistre la modification de fichier
        self.initModif()
        self.state = "undetermined"
        self.recordUnite()
        # Le contexte du parent doit etre reinitialise car les concepts produits ont change
        self.parent.resetContext()

        # On remplace les anciens concepts par les nouveaux (y compris ajouts
        # et suppression) et on propage les modifications aux etapes precedentes et suivantes
        # reevalueSdJdc construit la liste des differences entre les contextes contexte_fichier_init
        # et old_contexte_fichier_init et effectue les destructions et remplacements de concept
        # necessaires
        self.old_contexte_fichier_init = self.old_context
        self.reevalueSdJdc()
        self.finModif()
        if self.old_jdc_aux:
            self.old_jdc_aux.close()

        self.jdc_aux.forceContexte(self.g_context)

    def buildInclude(self, fichier, text):
        import Accas.extensions.jdc_include

        self.JdC_aux = extensions.jdc_include.JdC_include
        # un include partage la table des unites avec son parent (jdc)
        self.recorded_units = self.parent.recorded_units
        self.buildJdcaux(fichier, text)

    def buildPoursuite(self, fichier, text):
        import Accas.extensions.jdc_include

        self.JdC_aux = extensions.jdc_include.JdC_poursuite
        # une poursuite a sa propre table d'unites
        self.recorded_units = {}
        self.buildJdcaux(fichier, text)

    def buildIncludeInclude(self, text):
        import Accas.extensions.jdc_include

        self.JdC_aux = extensions.jdc_include.JdC_include
        # un include partage la table des unites avec son parent (jdc)

    def buildIncludeEtape(self, text, doitEtreValide=0):
        import Accas.extensions.jdc_include

        self.JdC_aux = extensions.jdc_include.JdC_include
        # un include partage la table des unites avec son parent (jdc)
        # self.buildJdcauxInclude(text)
        # Attention fonctionne pour import_Zone de MT
        # a adapter eventuellement
        try:
            # if 1 :
            contexte = self.getContexteJdc(None, text, doitEtreValide)
        except EficasException:
            return 0

        for e in self.etapes:
            e.niveau = self.niveau
            e.parent = self.parent
            e.state = "change"

        index = self.jdc.etapes.index(self)
        self.jdc.etapes = (
            self.jdc.etapes[: index + 1] + self.etapes + self.jdc.etapes[index + 1 :]
        )

        self.g_context = {}
        self.etapes = []
        self.jdc.resetContext()
        self.jdc_aux = None
        CONTEXT.unsetCurrentStep()
        return 1

    def buildJdcauxInclude(self, text):
        try:
            contexte = self.getContexteJdc(None, text)
        except EficasException:
            pass
        index = self.jdc.etapes.index(self)
        for e in self.etapes:
            e.niveau = self.niveau
        self.jdc.etapes = (
            self.jdc.etapes[: index + 1] + self.etapes + self.jdc.etapes[index + 1 :]
        )
        self.g_context = {}
        self.etapes = []
        self.jdc_aux = None
        CONTEXT.unsetCurrentStep()

    def buildJdcaux(self, fichier, text):
        """
        Cree un jdc auxiliaire initialise avec text.
        Initialise le nom du fichier associe avec fichier
        N'enregistre pas d'association unite <-> fichier
        """
        self.fichier_ini = fichier
        self.fichier_text = text
        self.fichier_unite = None
        self.fichier_err = None
        try:
            contexte = self.getContexteJdc(fichier, text)
            if contexte is None:
                # Impossible de construire le jdc auxiliaire (sortie par None)
                # On simule une sortie par exception
                raise EficasException(
                    tr(
                        "Impossible de construire le jeu de commandes correspondant au fichier"
                    )
                )
            else:
                # La construction du jdc auxiliaire est allee au bout
                self.contexte_fichier_init = contexte
            self.initModif()
            self.finModif()
        except:
            # Impossible de construire le jdc auxiliaire (sortie par exception)
            l = traceback.format_exception_only("Fichier invalide", sys.exc_info()[1])
            if self.jdc.editor is not None:
                self.jdc.editor.afficheMessage(
                    tr("Erreur lors de l'evaluation du fichier inclus"),
                    message=tr(
                        "Ce fichier ne sera pas pris en compte\n %s", "".join(l)
                    ),
                   couleur = 'red'
                )

            self.g_context = {}
            self.etapes = []
            self.jdc_aux = None
            self.fichier_err = "".join(l)
            self.contexte_fichier_init = {}
            self.initModif()
            self.finModif()
            raise EficasException(" ")

    def makeContexteInclude(self, fichier, text):
        """
        Cette methode sert a craer un contexte en interpratant un texte source Python.
        """
        # print ("makeContexteInclude",fichier)
        # on recupere le contexte d'un nouveau jdc dans lequel on interprete text
        contexte = self.getContexteJdc(fichier, text)
        # print (contexte)
        if contexte == None:
            raise EficasException(
                "Impossible de construire le jeu de commandes correspondant au fichier"
            )
        else:
            # Pour les macros de type include : INCLUDE, INCLUDE_MATERIAU et POURSUITE
            # l'attribut g_context est un dictionnaire qui contient les concepts produits par inclusion
            # l'attribut contexte_fichier_init est un dictionnaire qui contient les concepts produits
            # en sortie de macro. g_context est obtenu en retirant de contexte_fichier_init les concepts
            # existants en debut de macro contenus dans context_ini (dans getContexteJdc)
            # g_context est utilise pour avoir les concepts produits par la macro
            # contexte_fichier_init est utilise pour avoir les concepts supprimes par la macro
            self.contexte_fichier_init = contexte
        # print ("fin makeContexteInclude",fichier)

    def reevalueFichierInitObsolete(self):
        """Recalcule les concepts produits par le fichier enregistre"""
        # print "reevalue_fichier_init"
        old_context = self.contexte_fichier_init
        try:
            self.makeContexteInclude(self.fichier_ini, self.fichier_text)
        except:
            l = traceback.format_exception_only("Fichier invalide", sys.exc_info()[1])
            self.fichier_err = "".join(l)
            self.g_context = {}
            self.etapes = []
            self.jdc_aux = None
            self.old_contexte_fichier_init = old_context
            self.contexte_fichier_init = {}
            self.reevalueSdJdc()
            return

        # L'evaluation s'est bien passee
        self.fichier_err = None
        self.old_contexte_fichier_init = old_context
        self.reevalueSdJdc()

    def updateFichierInit(self, unite):
        """Reevalue le fichier init sans demander (dans la mesure du possible) a l'utilisateur
        les noms des fichiers
        Ceci suppose que les relations entre unites et noms ont ete memorisees prealablement
        L'include a ete initialise precedemment. Le jdc auxiliaire existe.
        """
        # print "updateFichierInit",unite,self.fichier_unite
        self.old_contexte_fichier_init = self.contexte_fichier_init
        old_fichier_ini = self.fichier_ini
        if not hasattr(self, "jdc_aux"):
            self.jdc_aux = None
        old_jdc_aux = self.jdc_aux

        # print "updateFichierInit",self,self.parent,self.parent.recorded_units

        if self.fichier_unite is None:
            # L'unite n'etait pas definie precedemment. On ne change que l'unite
            # print "updateFichierInit","pas de changement dans include"
            self.fichier_unite = unite
            return
        elif unite == self.fichier_unite:
            # L'unite n'a pas change
            # print "updateFichierInit","pas de changement dans include 3"
            return
        elif unite != self.fichier_unite:
            # L'unite etait definie precedemment. On remplace l'include
            #
            f, text = self.getFileMemo(unite=unite, fic_origine=self.parent.nom)
            if f is None:
                # Le fichier associe n'a pas pu etre defini
                # on change l'unite associee mais pas l'include
                # print "updateFichierInit","pas de changement dans include 2"
                self.fichier_unite = unite
                return
            else:
                self.fichier_ini = f
                self.fichier_text = text
                self.fichier_unite = unite
            # print "updateFichierInit",self.recorded_units

        # print "updateFichierInit",self.fichier_ini,self.fichier_text,self.fichier_unite

        if old_fichier_ini == self.fichier_ini:
            # Le fichier inclus n'a pas change. On ne recree pas le contexte
            # mais on enregistre le changement d'association unite <-> fichier
            # print "updateFichierInit.fichier inchange",self.jdc_aux.context_ini
            self.parent.recordUnit(unite, self)
            return

        try:
            self.fichier_err = None
            self.makeContexteInclude(self.fichier_ini, self.fichier_text)
            # Les 3 attributs fichier_ini fichier_text recorded_units doivent etre corrects
            # avant d'appeler changeUnit
        except:
            # Erreurs lors de l'evaluation de text dans un JDC auxiliaire
            l = traceback.format_exception_only("Fichier invalide", sys.exc_info()[1])
            # On conserve la memoire du nouveau fichier
            # mais on n'utilise pas les concepts crees par ce fichier
            # on met l'etape en erreur : fichier_err=''.join(l)
            self.fichier_err = "".join(l)
            self.g_context = {}
            self.etapes = []
            self.jdc_aux = None
            self.contexte_fichier_init = {}

        if old_jdc_aux:
            old_jdc_aux.close()
        self.parent.recordUnit(unite, self)
        # Le contexte du parent doit etre reinitialise car les concepts
        # produits ont change
        self.parent.resetContext()
        # Si des concepts ont disparu lors du changement de fichier, on
        # demande leur suppression
        self.reevalueSdJdc()
        # print "updateFichierInit",self.jdc_aux.context_ini.keys()

    def recordUnite(self):
        # print "recordUnite",self.nom
        if self.nom == "POURSUITE":
            self.parent.recordUnit(None, self)
        else:
            if hasattr(self, "fichier_unite"):
                self.parent.recordUnit(self.fichier_unite, self)

    def getFileMemo(self, unite=None, fname=None, fic_origine=""):
        """Retourne le nom du fichier et le source correspondant a l'unite unite
        Initialise en plus recorded_units
        """
        # print "getFileMemo",unite,fic_origine,self,self.parent
        # print self.parent.recorded_units
        if unite is None:
            # On est dans le cas d'une poursuite. On ne reutilise aucune unite de parent
            units = {}
        else:
            # On est dans le cas d'un include. On reutilise toutes les unites de parent
            units = self.parent.recorded_units

        if unite in self.parent.recorded_units:
            f, text, units = self.parent.recorded_units[unite]
        elif self.jdc:
            if fname:
                if not osp.exists(fname):
                    raise AsException(fname + tr(" n'est pas un fichier existant"))
                f = fname
                text = open(fname, "r").read()
            else:
                f, text = self.jdc.getFile(unite=unite, fic_origine=fic_origine)
        else:
            f, text = None, None

        self.recorded_units = units
        if f is None and self.jdc.editor:
            self.jdc.editor.afficheMessage(
                tr("Erreur lors de l'evaluation du fichier inclus"),
                message=tr(
                    "Ce fichier ne sera pas pris en compte\nLe fichier associe n'est pas defini"
                ),
               couleur = 'red'
            )
        return f, text

    def updateContext(self, d):
        """
        Met a jour le contexte contenu dans le dictionnaire d
        Une MACRO_ETAPE peut ajouter plusieurs concepts dans le contexte
        Une fonction enregistree dans op_init peut egalement modifier le contexte
        """
        # print ("updateContext",self,self.nom,d.keys())
        if hasattr(self, "jdc_aux") and self.jdc_aux:
            # ATTENTION: updateContext NE DOIT PAS appeler resetContext
            # car il appelle directement ou indirectement updateContext
            # equivalent a resetContext. Evite les recursions
            self.jdc_aux.context_ini = d.copy()
            self.jdc_aux.currentContext = {}
            self.jdc_aux.index_etape_courante = 0
            # ATTENTION: il ne faut pas utiliser self.jdc_aux.getContexteAvant
            # car cet appel conduit a des remontees multiples incoherentes dans le
            # ou les parents.
            # get_context_avant appelle updateContext qui NE DOIT PAS appeler getContexteAvant
            # On n'a besoin que d'un update local connaissant
            # le contexte amont : d qui sert a reinitialiser self.context_ini
            for e in self.etapes:
                e.updateContext(d)
            return

        if type(self.definition.op_init) == types.FunctionType:
            self.definition.op_init(*(self, d))
        if self.sd != None:
            d[self.sd.nom] = self.sd
        for co in self.sdprods:
            d[co.nom] = co
        # print "updateContext.fin",d.keys()

    # ATTENTION SURCHARGE : cette methode surcharge celle de processing (a garder en synchro)
    def copy(self):
        etape = Accas.processing.P_MACRO_ETAPE.MACRO_ETAPE.copy(self)
        if hasattr(etape, "etapes"):
            etape.etapes = []
        if hasattr(etape, "jdc_aux"):
            etape.jdc_aux = None
            del etape.fichier_ini
        return etape

    def supprime(self):
        # print "supprime",self
        if hasattr(self, "jdc_aux") and self.jdc_aux:
            self.jdc_aux.supprime_aux()
            self.jdc_aux = None
        Accas.processing.P_MACRO_ETAPE.MACRO_ETAPE.supprime(self)

    # ATTENTION SURCHARGE : cette methode surcharge celle de processing (a garder en synchro)
    def getFile(self, unite=None, fic_origine=""):
        """Retourne le nom du fichier et le source correspondant a l'unite unite"""
        if self.jdc:
            f, text = self.jdc.getFile(unite=unite, fic_origine=fic_origine)
        else:
            f, text = None, None
        return f, text

    def makeInclude3(self, fichier=None):
        self.makeIncludeCarmel(fichier)

    def makeIncludeCND(self, fichier=None):
        unite = 999
        if fichier == None:
            return
        if hasattr(self, "fichier_ini"):
            print((self.fichier_ini))
        if hasattr(self, "fichier_ini"):
            return
        self.fichier_ini = fichier
        from Accas.extensions.acquiert_groupes import getGroupes

        erreur, listeGroupes = getGroupes(fichier)
        if erreur != "":
            print("a traiter")
        texteSources = ""
        texteCond = ""
        texteNoCond = ""
        texteVcut = ""
        for groupe in listeGroupes:
            if groupe[0:8] == "CURRENT_":
                texteSources += groupe[8:] + "=SOURCE();\n"
            if groupe[0:5] == "COND_":
                texteCond += groupe[5:] + "=CONDUCTEUR();\n"
            if groupe[0:7] == "NOCOND_":
                texteNoCond += groupe[7:] + "=NOCOND();\n"
            # if groupe[0:5]=='VCUT_':    texteVcut    +=groupe[5:]+"=VCUT();\n"
            if groupe[0:5] == "VCUT_":
                texteVcut += "V_" + groupe[5:] + "=VCUT();\n"
        texte = texteSources + texteCond + texteNoCond + texteVcut
        # print (texte)
        self.buildIncludeInclude(texte)
        if CONTEXT.getCurrentStep() == None:
            CONTEXT.setCurrentStep(self)
        reevalue = 0

    def makeIncludeCarmel(self, fichier=None):
        # Pour Carmel
        # print "je suis dans makeIncludeCarmel"
        unite = 999
        if hasattr(self, "fichier_ini"):
            return
        reevalue = 0
        if hasattr(self, "old_context_fichier_init"):
            reevalue = 1
            for concept in self.old_context_fichier_init.values():
                self.jdc.deleteConcept(concept)
        if fichier == None:
            fichier = str(self.jdc.appliEficas.getFile_dictDonnees())
            if fichier == str(""):
                self.fichier_ini = "badfile"
                self.fichier_text = ""
                self.fichier_err = tr("Le fichier n est pas defini")
                self.parent.recordUnit(999, self)
                try:
                    MCFils = self.getChild("FileName")
                    MCFils.setValeur(None)
                except:
                    pass
                raise EficasException(self.fichier_err)
        self.fichier_ini = fichier
        f = open(self.fichier_ini, "r")
        self.fichier_text = f.read()
        f.close()

        self.contexte_fichier_init = {}
        self.fichier_unite = 999
        self.fichier_err = None

        try:
            # if 1 :
            import Accas.extensions.jdc_include

            self.JdC_aux = extensions.jdc_include.JdC_include
        except:
            # else:
            traceback.print_exc()
            self.makeIncl2Except()
            raise EficasException(" ")

        try:
            # if 1 :
            self.makeContexteInclude(self.fichier_ini, self.fichier_text)
            self.old_context_fichier_init = self.contexte_fichier_init
            self.parent.recordUnit(unite, self)
            try:
                MCFils = self.getChild("FileName")
                # MCFils.setValeur(fichier)
                # on appelle pas setValeur qui modifie le contexte ce qui fout le bazar
                # pas de modification de bloc
                MCFils.valeur = fichier
                MCFils.val = fichier
            except:
                pass
        except:
            # else:
            self.makeIncl2Except()
        # Cette P*** de ligne suivante ne fonctionne que pour Aster
        # si quelqu un a une idee merci de m en parler
        # CONTEXT.setCurrentStep(self)

    def makeInclude2(self, fichier=None):
        # Pour OT
        # gestion de l unicite SVP
        unite = 999

        if hasattr(self, "fichier_ini"):
            return
        reevalue = 0
        if hasattr(self, "old_context_fichier_init"):
            reevalue = 1
            for concept in self.old_context_fichier_init.values():
                self.jdc.deleteConcept(concept)

        if fichier == None:
            fichier = str(self.jdc.appliEficas.getFileVariable())
            if fichier == str(""):
                self.fichier_ini = "badfile"
                self.fichier_text = ""
                self.fichier_err = tr("Le fichier n est pas defini")
                self.parent.recordUnit(999, self)
                try:
                    MCFils = self.getChild("FileName")
                    MCFils.setValeur(None)
                except:
                    pass
                raise EficasException(self.fichier_err)

        self.fichier_ini = fichier
        self.fichier_text = ""
        self.contexte_fichier_init = {}
        self.fichier_unite = 999
        self.fichier_err = None
        nbVariableOut = 0
        try:
            from openturns import WrapperFile

            monWrapper = WrapperFile(fichier)
            data = monWrapper.getWrapperData()
            maVariableListe = data.getVariableList()
            nbVariables = maVariableListe.getSize()
            for i in range(nbVariables):
                nom = maVariableListe[i].id_
                type = maVariableListe[i].type_
                if type:
                    # ligneTexte="%s=DETERMINISTICVARIABLE(N='%s',T='out',R=%d);\n" % (nom, nom, i)
                    ligneTexte = ""
                    nbVariableOut = nbVariableOut + 1
                else:
                    ligneTexte = "%s=DETERMINISTICVARIABLE(N='%s',T='in',R=%d);\n" % (
                        nom,
                        nom,
                        i,
                    )
                self.fichier_text = self.fichier_text + ligneTexte
        except:
            self.makeIncl2Except()
            raise EficasException(" ")

        if nbVariableOut != 1:
            self.makeIncl2Except(
                mess=tr("le fichier doit contenir une unique variable de sortie")
            )
            raise EficasException(" ")

        try:
            import Accas.extensions.jdc_include

            self.JdC_aux = extensions.jdc_include.JdC_include
        except:
            traceback.print_exc()
            self.makeIncl2Except()
            raise EficasException(" ")

        try:
            self.makeContexteInclude(self.fichier_ini, self.fichier_text)
            self.old_context_fichier_init = self.contexte_fichier_init
            self.parent.recordUnit(unite, self)
            try:
                MCFils = self.getChild("FileName")
                MCFils.setValeur(fichier)
            except:
                pass
        except:
            self.makeIncl2Except()

        # recalcul validite pour la matrice eventuelle
        if reevalue:
            for e in self.jdc.etapes:
                if e.nom == "VARIABLE":
                    e.state = "modified"
                    try:
                        mc = e.getChild("ModelVariable")
                        mc.state = "modified"
                    except:
                        pass
                if e.nom == "CORRELATION":
                    e.state = "modified"
                    try:
                        mc = e.getChild("Matrix")
                        mc.state = "modified"
                        mcFeuille = mc.getChild("CorrelationMatrix")
                        mcFeuille.state = "modified"
                    except:
                        pass
                    e.isValid()

    def makeIncl2Except(self, mess=None):
        l = traceback.format_exception_only(tr("Fichier invalide"), sys.exc_info()[1])
        if self.jdc.editor is not None:
            if mess == None:
                self.jdc.editor.afficheMessage(
                    tr("Erreur lors de l'evaluation du fichier inclus"),
                    message=tr(
                        "Le contenu de ce fichier ne sera pas pris en compte\n %s",
                        "".join(l),
                    ),
                   couleur = 'red'
                )

            else:
                self.jdc.editor.afficheMessage(
                    tr("Erreur lors de l'evaluation du fichier inclus"),
                    message=tr(mess),
                   couleur = 'red'
                )
        # self.parent.recordUnit(unite,self)
        self.g_context = {}
        self.etapes = []
        self.jdc_aux = None
        self.fichier_err = "".join(l)
        self.contexte_fichier_init = {}
        try:
            MCFils = self.getChild("FileName")
            MCFils.setValeur(None)
        except:
            pass

    # ATTENTION SURCHARGE : cette methode surcharge celle de processing (a garder en synchro)
    # def makeInclude(self, unite=None, fname=None):
    def makeInclude(self, unite=None, fname=None):
        """
        Inclut un fichier dont l'unite logique est unite
        Cette methode est appelee par la fonction sd_prod de la macro INCLUDE
        Si l'INCLUDE est invalide, la methode doit produire une exception
        Sinon on retourne None. Les concepts produits par l'INCLUDE sont
        pris en compte par le JDC parent lors du calcul du contexte (appel de ???)
        """
        # On supprime l'attribut unite qui bloque l'evaluation du source de l'INCLUDE
        # car on ne s'appuie pas sur lui dans EFICAS mais sur l'attribut fichier_ini
        # Si unite n'a pas de valeur, l'etape est forcement invalide. On peut retourner None
        # if not unite and not fname:
        #    return
        # 2020 on supprime unite
        #      attention cependant c est utilise pour poursuite
        #      PNPN a revoir
        if not fname:
            return

        if not hasattr(self, "fichier_ini"):
            # Si le fichier n'est pas defini on le demande
            f, text = self.getFileMemo(
                unite=unite, fname=fname, fic_origine=self.parent.nom
            )
            # On memorise le fichier retourne
            self.fichier_ini = f
            self.fichier_text = text
            self.contexte_fichier_init = {}
            self.fichier_unite = unite
            self.fichier_err = None
            try:
                import Accas.extensions.jdc_include
            except:
                traceback.print_exc()
                raise EficasException("pb import Accas.extensions")
            self.JdC_aux = extensions.jdc_include.JdC_include

            # print "makeInclude",self.fichier_ini,self.fichier_text
            if f is None and not text:
                self.fichier_err = tr("Le fichier INCLUDE n est pas defini")
                self.parent.recordUnit(unite, self)
                raise EficasException(self.fichier_err)

            try:
                self.makeContexteInclude(self.fichier_ini, self.fichier_text)
                self.parent.recordUnit(unite, self)
            except:
                l = traceback.format_exception_only(
                    tr("Fichier invalide %s", sys.exc_info()[1])
                )
                if self.jdc.editor:
                    self.jdc.editor.afficheMessage(
                        tr("Erreur lors de l'evaluation du fichier inclus"),
                        message=tr(
                            "Le contenu de ce fichier ne sera pas pris en compte\n"
                            + "".join(l)
                        ),
                   couleur = 'red'
                    )
                self.parent.recordUnit(unite, self)
                self.g_context = {}
                self.etapes = []
                self.jdc_aux = None
                self.fichier_err = "".join(l)
                self.contexte_fichier_init = {}
                raise EficasException(" ")

        else:
            # Si le fichier est deja defini on ne reevalue pas le fichier
            # et on leve une exception si une erreur a ete enregistree
            self.updateFichierInit(unite)
            self.fichier_unite = unite
            if self.fichier_err is not None:
                raise EficasException(self.fichier_err)
        # print ('self.g_context', self.g_context)

    # ATTENTION SURCHARGE : cette methode surcharge celle de processing (a garder en synchro)
    def makeContexte(self, fichier, text):
        """
        Cette methode sert a creer un contexte pour INCLUDE_MATERIAU
        en interpretant un texte source Python
        Elle est appelee par la fonction sd_prod d'INCLUDE_MATERIAU
        """
        # print "makeContexte",fichier
        # On supprime l'attribut mat qui bloque l'evaluation du source de l'INCLUDE_MATERIAU
        # car on ne s'appuie pas sur lui dans EFICAS mais sur l'attribut fichier_ini
        if hasattr(self, "mat"):
            del self.mat
        if (
            not hasattr(self, "fichier_ini")
            or self.fichier_ini != fichier
            or self.fichier_mater != self.nom_mater
        ):
            # le fichier est nouveau ou change
            self.fichier_ini = fichier
            self.fichier_unite = fichier
            self.fichier_mater = self.nom_mater
            self.fichier_text = text
            self.fichier_err = None
            self.contexte_fichier_init = {}
            # On specifie la classe a utiliser pour le JDC auxiliaire
            try:
                import Accas.extensions.jdc_include

                self.JdC_aux = extensions.jdc_include.JdC_include
            except:
                raise EficasException(" ")
            try:
                self.makeContexteInclude(self.fichier_ini, self.fichier_text)
                if not self.nom_mater in self.g_context:
                    # Pour permettre de lire un jeu de commandes avec des INCLUDE_MATERIAU errones
                    self.g_context[self.nom_mater] = None
                    if self.parent:
                        self.parent.g_context[self.nom_mater] = None
            except:
                l = traceback.format_exception_only(
                    tr("Fichier invalide %s", sys.exc_info()[1])
                )
                self.fichier_err = "".join(l)
                self.g_context = {}
                # Pour permettre de lire un jeu de commandes avec des INCLUDE_MATERIAU errones
                if self.parent:
                    self.parent.g_context[self.nom_mater] = None
                self.g_context[self.nom_mater] = None
            # -------------
                self.etapes = []
                self.jdc_aux = None
                self.contexte_fichier_init = {}
                raise EficasException(" ")
        else:
            # le fichier est le meme on ne le reevalue pas
            # et on leve une exception si une erreur a ete enregistree
            if self.fichier_err is not None:
                raise EficasException(self.fichier_err)

    # ATTENTION SURCHARGE : cette methode surcharge celle de processing (a garder en synchro)
    def updateSdprod(self, cr="non"):
        # Cette methode peut etre appelee dans EFICAS avec des mots cles de
        # la commande modifies. Ceci peut conduire a la construction ou
        # a la reconstruction d'etapes dans le cas d'INCLUDE ou d'INCLUDE_MATERIAU
        # Il faut donc positionner le current_step avant l'appel
        CONTEXT.unsetCurrentStep()
        CONTEXT.setCurrentStep(self)
        valid = Accas.validation.V_MACRO_ETAPE.MACRO_ETAPE.updateSdprod(self, cr=cr)
        CONTEXT.unsetCurrentStep()
        return valid

    # ATTENTION SURCHARGE: cette methode surcharge celle de processing a garder en synchro
    def buildSd(self, nom):
        """
        Mmethode de processing surchargee pour poursuivre malgre tout
        si une erreur se produit pendant la creation du concept produit
        """
        try:
            sd = P_MACRO_ETAPE.MACRO_ETAPE.buildSd(self, nom)
        except:
            #   return None
            # except AsException,e:
            # Une erreur s'est produite lors de la construction du concept
            # Comme on est dans EFICAS, on essaie de poursuivre quand meme
            # Si on poursuit, on a le choix entre deux possibilites :
            # 1. on annule la sd associee a self
            # 2. on la conserve mais il faut la retourner
            # On choisit de l'annuler
            # En plus il faut rendre coherents sdnom et sd.nom
            self.sd = None
            self.sdnom = None
            self.state = "unchanged"
            self.valid = 0

        return self.sd

    # ATTENTION SURCHARGE: cette methode surcharge celle de processing a garder en synchro
    def makePoursuite(self):
        """Cette methode est appelee par la fonction sd_prod de la macro POURSUITE"""
        # print "makePoursuite"
        if not hasattr(self, "fichier_ini"):
            # Si le fichier n'est pas defini on le demande
            f, text = self.getFileMemo(fic_origine=self.parent.nom)
            # On memorise le fichier retourne
            self.fichier_ini = f
            self.fichier_unite = None
            self.fichier_text = text
            self.fichier_err = None
            try:
                import Accas.extensions.jdc_include
            except:
                traceback.print_exc()
                raise EficasException(" ")
            self.JdC_aux = extensions.jdc_include.JdC_poursuite
            self.contexte_fichier_init = {}
            # print "makePoursuite",self.fichier_ini,self.fichier_text

            if f is None:
                self.fichier_err = "Le fichier POURSUITE n'est pas defini"
                self.jdc_aux = None
                self.parent.recordUnit(None, self)
                raise EficasException(self.fichier_err)

            try:
                self.makeContexteInclude(self.fichier_ini, self.fichier_text)
                self.parent.recordUnit(None, self)
            except:
                l = traceback.format_exception_only(
                    "Fichier invalide", sys.exc_info()[1]
                )
                if self.jdc.editor:
                    self.jdc.editor.afficheMessage(
                        tr("Erreur lors de l'evaluation du fichier poursuite"),
                        message=tr(
                            "Ce fichier ne sera pas pris en compte\n %s", "".join(l)
                        ),
                   couleur = 'red'
                    )
                self.parent.recordUnit(None, self)
                self.g_context = {}
                self.etapes = []
                self.jdc_aux = None
                self.fichier_err = "".join(l)
                self.contexte_fichier_init = {}
                raise EficasException(" ")

        else:
            # Si le fichier est deja defini on ne reevalue pas le fichier
            # et on leve une exception si une erreur a ete enregistree
            self.updateFichierInit(None)
            if self.fichier_err is not None:
                raise EficasException(self.fichier_err)
