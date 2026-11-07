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
import types, traceback, sys, os
import linecache
from Accas.extensions.eficas_translation import tr
from Accas.extensions.eficas_exception import EficasException


# Modules Eficas
from Accas.accessor import A_OBJECT
from Accas.processing.P_ASSD import ASSD

# from Accas.processing.P_LASSD import LASSD
from Accas.processing.P_ETAPE import ETAPE
from Accas.processing.P_Exception import AsException
from Accas.extensions import commentaire, parametre, parametre_eval
from Accas.accessor import CONNECTOR
from Accas.validation  import V_JDC

try:
    basestring
except NameError:
    basestring = str


class LASSD:
    pass


class JDC(A_OBJECT.OBJECT):
    """ """

    def __init__(self):
        self.editmode = 0
        self.etapes_niveaux = []
        self.niveau = self
        self.params = []
        self.fonctions = []
        self._etape_context = None
        self.recorded_units = {}
        self.old_recorded_units = {}

    def isOblig(self):
        return 1

    def getIndex(self, objet):
        """
        Retourne la position d'objet dans la liste self
        """
        return self.etapes.index(objet)

    def getSdAvantDuBonType(self, etape, types_permis):
        """
        Retourne la liste des concepts avant etape d'un type acceptable
        """
        # print ('getSdAvantDuBonType   ', types_permis)
        d = self.getContexteAvant(etape)

        l = []
        for k, v in d.items():
            # if type(v) != types.InstanceType and not isinstance(v,object): continue
            if not isinstance(v, object):
                continue
            # On considere que seul assd indique un type quelconque pas CO
            elif self.assd in types_permis:
                if v.etape.sdnom != "sansnom":
                    l.append(k)
            elif self.estPermis(v, types_permis):
                if v.etape.sdnom != "sansnom":
                    l.append(k)
        l.sort()
        return l

    def getSdCreeParObjet(self, classeAChercher):
        l = []
        for v in list(self.sdsDict.keys()):
            if isinstance(self.sdsDict[v], classeAChercher):
                l.append(self.sdsDict[v])
        return l

    def getVariables(self, etape):
        etapeStop = etape
        l = []
        for etapeTraitee in self.etapes:
            if etapeTraitee == etapeStop:
                break
            if etapeTraitee.nom == "VARIABLE":
                variable = etapeTraitee.getMocle("ModelVariable")
                if variable != None:
                    l.append(variable.nom)
        return l

    def getDistributions(self, etape):
        etapeStop = etape
        l = []
        for etapeTraitee in self.etapes:
            if etapeTraitee == etapeStop:
                break
            if etapeTraitee.nom == "DISTRIBUTION" and etapeTraitee.sd != None:
                l.append(etapeTraitee.sd.nom)
        return l

    # def set_Copules_recalcule_etat(self):
    #   for etapeTraitee in self.etapes :
    #       if etapeTraitee.nom == 'CORRELATION' :
    # Matrix=etapeTraitee.getChild('Matrix')
    # if Matrix !=None :
    #             Correlation=etapeTraitee.getChild('CorrelationMatrix')
    #             if Correlation !=None : Correlation.state='arecalculer'
    #   Matrix.state='arecalculer'

    # def recalculeEtatCorrelation(self):
    #   for etapeTraitee in self.etapes :
    #       if etapeTraitee.nom == 'CORRELATION' :
    # Matrix=etapeTraitee.getChild('Matrix')
    # if Matrix !=None :
    #             Matrix.state='arecalculer'
    #             Correlation=Matrix.getChild('CorrelationMatrix')
    #             if Correlation !=None : Correlation.state='arecalculer'
    #                Correlation.isValid()
    #             Matrix.isValid()
    #             etapeTraitee.state='arecalculer'
    #          if etapeTraitee.state=='arecalculer': etapeTraitee.isValid()

    def recalculeEtatCorrelation(self):
        for etapeTraitee in self.etapes:
            if etapeTraitee.nom == "CORRELATION":
                Correlation = etapeTraitee.getChild("CorrelationMatrix")
                if Correlation != None:
                    Correlation.state = "arecalculer"
                    Correlation.isValid()
                etapeTraitee.isValid()

    def recalculeValiditeApresChangementGlobalJdc(self, motClef):
        # print ("je passe dans recalculeValiditeApresChangementGlobalJdc")
        try:
            liste = self.getJdcRoot().cata.dict_condition[motClef.nom]
        except:
            liste = ()
        for etapeTraitee in self.etapes:
            if etapeTraitee.nom not in liste:
                continue
            # self.forceRecalculBloc(etapeTraitee)
            etapeTraitee.state = "arecalculer"
            etapeTraitee.deepUpdateConditionBloc()
            etapeTraitee.isValid()
            # print (etapeTraitee.nom ,etapeTraitee.isValid())

    def activeBlocsGlobaux(self):
        for nomMotClef in self.mc_globaux:
            motClef = self.mc_globaux[nomMotClef]
            if nomMotClef in list(self.cata.dict_condition.keys()):
                liste = self.cata.dict_condition[nomMotClef]
            else:
                liste = ()
            for etapeTraitee in self.etapes:
                if etapeTraitee.nom not in liste:
                    continue
                etapeTraitee.state = "arecalculer"
                etapeTraitee.deepUpdateConditionBlocApresCreation()
                etapeTraitee.isValid()

    # def forceRecalculBloc(self,objet):
    # Attention : certains objets deviennent None quand on recalcule
    # les conditions d existence des blocs
    #    if objet != None:  objet.state='arecalculer'
    #    if hasattr(objet,'listeMcPresents'):
    #       for childNom in objet.listeMcPresents():
    #           child=objet.getChild(childNom)
    #           if hasattr(objet,'_updateConditionBloc'):objet._updateConditionBloc()
    #           self.forceRecalculBloc(child)

    def getSdAvantDuBonTypePourTypeDeBase(self, etape, type):
        """
        Retourne la liste des concepts avant etape d'1 type de base acceptable
        Attention different de la routine precedente : 1 seul type passe en parametre
        Teste sur issubclass et par sur le type permis
        """
        d = self.getContexteAvant(etape)
        l = []
        try:
            typeverif = self.cata.__dict__[type]
        except:
            return l
        for k, v in d.items():
            if issubclass(v.__class__, typeverif):
                l.append(k)
        l.sort()
        return l

    def chercheListAvant(self, etape, valeur):
        d = self.getContexteAvant(etape)
        for k, v in d.items():
            if issubclass(v.__class__, LASSD):
                if k == valeur:
                    return k
                # Attention pour enlever les . a la fin des pretendus reels
                if k == valeur[0:-1]:
                    return v
        return None

    def estPermis(self, v, types_permis):
        for type_ok in types_permis:
            if type_ok in ("R", "I", "C", "TXM") and v in self.params:
                return 1
            elif type_ok == "R" and v.__class__.__name__ == "reel":
                return 1
            elif type_ok == "I" and v.__class__.__name__ == "entier":
                return 1
            elif type_ok == "C" and v.__class__.__name__ == "complexe":
                return 1
            elif type_ok == "TXM" and v.__class__.__name__ == "chaine":
                return 1
            elif type(type_ok) != type and not isinstance(type_ok, type):
                continue
            elif v.__class__ == type_ok or issubclass(v.__class__, type_ok):
                return 1
        return 0

    def addEntite(self, name, pos):
        """
        Ajoute une entite :
        Si name est le nom d une commande ou un commentaire ajoute
        une etape au JDC
        Sinon remonte une erreur
        """
        self.initModif()
        self.editmode = 1
        if name == "COMMENTAIRE":
            from Accas.extensions import commentaire

            # ajout d'un commentaire
            self.setCurrentStep()
            ind = 1
            for child in self.etapes:
                if isinstance(child, commentaire.COMMENTAIRE):
                    ind = ind + 1
            objet = commentaire.COMMENTAIRE("", parent=self)
            objet.nom = "_comm_" + repr(ind)
            if pos == None:
                pos = 0
            self.etapes.insert(pos, objet)
            self.resetContext()
            self.editmode = 0
            self.activeEtapes()
            CONNECTOR.Emit(self, "add", objet)
            self.finModif()
            return objet
        elif name == "PARAMETRE":
            # ajout d'un parametre
            self.setCurrentStep()
            nom_param = "_param_" + str(len(self.params) + 1)
            objet = parametre.PARAMETRE(nom=nom_param)
            if pos == None:
                pos = 0
            self.etapes.insert(pos, objet)
            self.resetContext()
            self.editmode = 0
            self.activeEtapes()
            CONNECTOR.Emit(self, "add", objet)
            self.finModif()
            return objet
        elif name == "PARAMETRE_EVAL":
            # ajout d'un parametre EVAL
            self.setCurrentStep()
            nom_param = "_param_" + str(len(self.params) + 1)
            objet = parametre_eval.PARAMETRE_EVAL(nom=nom_param)
            if pos == None:
                pos = 0
            self.etapes.insert(pos, objet)
            self.resetContext()
            self.editmode = 0
            self.activeEtapes()
            CONNECTOR.Emit(self, "add", objet)
            self.finModif()
            return objet
        elif not (isinstance(name, basestring)):
            # elif type(name)==types.InstanceType:
            # elif isinstance(name,object):
            # on est dans le cas ou on veut ajouter une commande deja
            # existante (par copie donc)
            # on est donc necessairement en mode editeur ...
            objet = name
            # Il ne faut pas oublier de reaffecter le parent d'obj (si copie)
            from Accas.extensions import commentaire

            if not (isinstance(objet, commentaire.COMMENTAIRE)):
                objet.reparent(self)
            self.setCurrentStep()
            if isinstance(objet, ETAPE):
                if objet.nom_niveau_definition == "JDC":
                    # l'objet depend directement du JDC
                    objet.niveau = self
                else:
                    # l'etape depend d'un niveau et non directement du JDC :
                    # il faut l'enregistrer dans le niveau de parent
                    objet.parent.dict_niveaux[objet.nom_niveau_definition].register(
                        objet
                    )
                    objet.niveau = objet.parent.dict_niveaux[
                        objet.nom_niveau_definition
                    ]
            self.etapes.insert(pos, objet)
            self.resetContext()
            # il faut verifier que les concepts utilises par objet existent bien
            # a ce niveau d'arborescence
            objet.verifExistenceSd()
            objet.updateMcGlobal()
            self.editmode = 0
            self.activeEtapes()
            CONNECTOR.Emit(self, "add", objet)
            self.finModif()
            return objet
        else:
            # On veut ajouter une nouvelle commande
            try:
                self.setCurrentStep()
                cmd = self.getCmd(name)
                # L'appel a make_objet n'a pas pour effet d'enregistrer l'etape
                # aupres du step courant car editmode vaut 1
                # Par contre elle a le bon parent grace a setCurrentStep
                e = cmd.make_objet()
                if pos == None:
                    pos = 0
                self.etapes.insert(pos, e)
                self.resetCurrentStep()
                self.resetContext()
                self.editmode = 0
                self.activeEtapes()
                self.enregistreEtapePyxb(e, pos)
                # PN fait ds self.activeEtapes
                CONNECTOR.Emit(self, "add", e)
                self.finModif()
                return e
            except AsException as e:
                traceback.print_exc()
                self.resetCurrentStep()
                self.editmode = 0
                raise AsException(tr("Impossible d'ajouter la commande") + name + "\n")
            except:
                # else :
                traceback.print_exc()
                self.resetCurrentStep()
                self.editmode = 0
                raise AsException(tr("Impossible d ajouter la commande") + name)

    def close(self):
        # print "JDC.close",self
        for etape in self.etapes:
            if hasattr(etape, "close"):
                etape.close()
        CONNECTOR.Emit(self, "close")

    def setCurrentStep(self):
        CONTEXT.unsetCurrentStep()
        CONTEXT.setCurrentStep(self)

    def resetCurrentStep(self):
        CONTEXT.unsetCurrentStep()

    def listeMcPresents(self):
        return []

    def getSdAvantEtape(self, nom_sd, etape):
        return self.getContexteAvant(etape).get(nom_sd, None)

    def getSdApresEtapeAvecDetruire(self, nom_sd, sd, etape, avec="non"):
        """
        Cette methode retourne la SD sd de nom nom_sd qui est eventuellement
        definie apres etape en tenant compte des concepts detruits
        Si avec vaut 'non' exclut etape de la recherche
        """
        # print "JDC.getSdApresEtapeAvecDetruire",nom_sd,sd
        ietap = self.etapes.index(etape)
        if avec == "non":
            ietap = ietap + 1
        d = {nom_sd: sd}
        for e in self.etapes[ietap:]:
            if e.isActif():
                e.updateContext(d)
                autre_sd = d.get(nom_sd, None)
                if autre_sd is None:
                    # Le concept a ete detruit. On interrompt la recherche car il n'y a
                    # pas eu de redefinition du concept (il n'y a pas de conflit potentiel).
                    return None
                if autre_sd is not sd:
                    # L'etape produit un concept different de meme nom. La situation n'est
                    # pas saine (sauf peut etre si reuse ???)
                    if hasattr(e, "reuse") and e.reuse == autre_sd:
                        # Le concept etant reutilise, on interrompt la recherche.
                        # On considere qu'il n'y a pas de nouveau concept defini
                        # meme si dans les etapes suivantes le concept est detruit
                        # et un concept de meme nom cree.
                        # AVERIFIER : avec reuse le concept devrait etre le meme
                        # le passage par ici est tres improbable
                        return None
                    else:
                        # Le concept est produit par l'etape (Il y a conflit potentiel).
                        # Le concept est redefini par une etape posterieure.
                        return autre_sd
        # Pas de destruction du concept ni de redefinition. On retourne le
        # concept initial
        return sd

    def getSdApresEtape(self, nom_sd, etape, avec="non"):
        """
        Cette methode retourne la SD de nom nom_sd qui est eventuellement
        definie apres etape
        Si avec vaut 'non' exclut etape de la recherche
        """
        ietap = self.etapes.index(etape)
        if avec == "non":
            ietap = ietap + 1
        for e in self.etapes[ietap:]:
            sd = e.getSdprods(nom_sd)
            if sd:
                if hasattr(e, "reuse"):
                    if e.reuse != sd:
                        return sd
        return None

    def getSdAutourEtape(self, nom_sd, etape, avec="non"):
        """
        Fonction: retourne la SD de nom nom_sd qui est eventuellement
        definie avant ou apres etape
        Permet de verifier si un concept de meme nom existe dans le perimetre
        d'une etape
        Si avec vaut 'non' exclut etape de la recherche
        """
        sd = self.getSdAvantEtape(nom_sd, etape)
        if sd:
            return sd
        sd = self.getSdApresEtape(nom_sd, etape, avec)
        if sd:
            return sd
        # Pour tenir compte des UserASSD # et des UserASSDMultiple a affiner
        if nom_sd in self.sdsDict.keys():
            sd = self.sdsDict[nom_sd]
            return sd

    def getContexte_apres(self, etape):
        """
        Retourne le dictionnaire des concepts connus apres etape
        On tient compte des commandes qui modifient le contexte
        comme DETRUIRE ou les macros
        Si etape == None, on retourne le contexte en fin de JDC
        """
        if not etape:
            return self.getContexteAvant(etape)

        d = self.getContexteAvant(etape)
        if etape.isActif():
            etape.updateContext(d)
        self.index_etape_courante = self.index_etape_courante + 1
        return d

    def activeEtapes(self):
        """ """
        for etape in self.etapes:
            etape.active()

    def deplaceEntite(self, indexNoeudACopier, indexNoeudOuColler, pos):
        """
        Pour le cut
        """
        if indexNoeudACopier == indexNoeudOuColler:
            return
        etapeACopier = self.etapes[indexNoeudACopier]
        try:
            sd = self.etapes[indexNoeudACopier].sd
        except:
            sd = None
        if pos == "before" and indexNoeudOuColler == 0:
            self.etapes2 = (
                [
                    etapeACopier,
                ]
                + self.etapes[0:indexNoeudACopier]
                + self.etapes[indexNoeudACopier + 1 :]
            )
        elif indexNoeudACopier < indexNoeudOuColler:
            self.etapes2 = (
                self.etapes[0:indexNoeudACopier]
                + self.etapes[indexNoeudACopier + 1 : indexNoeudOuColler + 1]
                + [
                    etapeACopier,
                ]
                + self.etapes[indexNoeudOuColler + 1 :]
            )
        else:
            self.etapes2 = (
                self.etapes[0 : indexNoeudOuColler + 1]
                + [
                    etapeACopier,
                ]
                + self.etapes[indexNoeudOuColler + 1 : indexNoeudACopier]
                + self.etapes[indexNoeudACopier + 1 :]
            )
        self.etapes = self.etapes2
        if indexNoeudACopier < indexNoeudOuColler:
            self.deleteConceptEntreEtapes(indexNoeudACopier, indexNoeudOuColler, sd)
        self.resetContext()
        for e in self.etapes:
            e.state = "modified"
        self.controlContextApres(None)
        return 1

    def suppEntite(self, etape):
        """
        Cette methode a pour fonction de supprimer une etape dans
        un jeu de commandes
        Retourne 1 si la suppression a pu etre effectuee,
        Retourne 0 dans le cas contraire
        """
        # PN correction de bugs
        # print ('suppEntite', etape.nom)
        if etape not in self.etapes:
            return 0
        # print ('suppEntite', etape.nom)
        if etape.nom == "ExpressionIncertitude":
            etape.delieIncertitude()

        self.initModif()
        index_etape = self.etapes.index(etape)

        # etape.delObjPyxb()
        self.etapes.remove(etape)

        if etape.niveau is not self:
            # Dans ce cas l'etape est enregistree dans un niveau
            # Il faut la desenregistrer
            etape.niveau.unregister(etape)

        etape.supprimeSdProds()
        etape.supprimeUserAssd()
        etape.close()
        etape.supprime()
        self.activeEtapes()

        # Apres suppression de l'etape il faut controler que les etapes
        # suivantes ne produisent pas des concepts DETRUITS dans op_init de etape
        etapeSup = etape
        if index_etape > 0:
            index_etape = index_etape - 1
            etape = self.etapes[index_etape]
        else:
            etape = None
        self.controlContextApres(etape)

        self.resetContext()
        CONNECTOR.Emit(self, "supp", etapeSup)
        print ('iiiiiiiiiiiiiiiii CONNECTOR.Emit JDC')
        self.finModif()
        return 1

    def controlContextApres(self, etape):
        """
        Cette methode verifie que les etapes apres l'etape etape
        ont bien des concepts produits acceptables (pas de conflit de
        nom principalement)
        Si des concepts produits ne sont pas acceptables ils sont supprimes.
        Effectue les verifications sur les etapes du jdc mais aussi sur les
        jdc parents s'ils existent.
        """
        # print ("controlContextApres",self,etape)
        # Regularise les etapes du jdc apres l'etape etape
        self.controlJdcContextApres(etape)

    def controlJdcContextApres(self, etape):
        """
        Methode semblable a controlContextApres mais ne travaille
        que sur les etapes et sous etapes du jdc
        """
        # print ("controlJdcContextApres",self,etape)
        if etape is None:
            # on demarre de la premiere etape
            index_etape = 0
        else:
            index_etape = self.etapes.index(etape) + 1

        try:
            etape = self.etapes[index_etape]
        except:
            # derniere etape du jdc : rien a faire
            return

        context = self.getContexteAvant(etape)
        for e in self.etapes[index_etape:]:
            e.controlSdprods(context)
            e.updateContext(context)

    def analyse(self):
        self.compile()
        self.execCompile()
        if not self.cr.estvide():
            return
        self.activeEtapes()
        if self.mc_globaux != {}:
            self.activeBlocsGlobaux()

    def analyseXML(self):
        # print ('analyseXML')
        # print (self.procedure)
        self.setCurrentContext()
        try:
        #print ('PNPN : chgt try en if')
        #if 1 :
            self.analyseFromXML()
        except Exception as e:
            print("Erreur dans analyseXML a la generation du JDC a partir du xml")
            # import traceback
            # traceback.print_stack()
            # Erreur lors de la conversion
            l = traceback.format_exception(
                sys.exc_info()[0], sys.exc_info()[1], sys.exc_info()[2]
            )
            self.cr.exception(
                tr("Impossible de convertir le fichier XML\n %s", "".join(l))
            )
            print(e)
            return

    def registerParametre(self, param):
        """
        Cette methode sert a ajouter un parametre dans la liste des parametres
        """
        self.params.append(param)

    def registerFonction(self, fonction):
        """
        Cette methode sert a ajouter une fonction dans la liste des fonctions
        """
        self.fonctions.append(fonction)

    def deleteParam(self, param):
        """
        Supprime le parametre param de la liste des parametres
        et du contexte gobal
        """
        if param in self.params:
            self.params.remove(param)
        if param.nom in self.g_context:
            del self.g_context[param.nom]

    def getParametresFonctionsAvantEtape(self, etape):
        """
        Retourne deux elements :
        - une liste contenant les noms des parametres (constantes ou EVAL)
          definis avant etape
        - une liste contenant les formules definies avant etape
        """
        l_constantes = []
        l_fonctions = []
        # on recupere le contexte avant etape
        # on ne peut mettre dans les deux listes que des elements de ce contexte
        d = self.getContexteAvant(etape)
        # construction de l_constantes
        for param in self.params:
            nom = param.nom
            if not nom:
                continue
            if nom in d:
                l_constantes.append(nom)
        # construction de l_fonctions
        for form in self.fonctions:
            nom = form.nom
            if not nom:
                continue
            if nom in d:
                l_fonctions.append(form.getFormule())

        # on ajoute les concepts produits par DEFA_VALEUR
        # XXX On pourrait peut etre faire plutot le test sur le type
        # de concept : entier, reel, complexe, etc.
        for k, v in d.items():
            if hasattr(v, "etape") and v.etape.nom in ("DEFA_VALEUR",):
                l_constantes.append(k)

        # on retourne les deux listes
        return l_constantes, l_fonctions

    def getNbEtapesAvant(self, niveau):
        """
        Retourne le nombre d etapes avant le debut de niveau
        """
        nb = 0
        for niv in self.etapes_niveaux:
            if niv == niveau:
                break
            nb = nb + len(niv.etapes)
        return nb

    def initModif(self):
        """
        Methode appelee au moment ou une modification va etre faite afin de
        declencher d'eventuels traitements pre-modification
        """
        # print "initModif",self
        self.state = "modified"

    def finModif(self):
        # print "finModif",self
        # ??? pourquoi le isValid est apres le Emit ??
        CONNECTOR.Emit(self, "valid")
        self.isValid()

    def deepUpdateConditionBloc(self, motClef=None):
        # pour le moment, on ne fait rien
        self.getJdcRoot().recalculeValiditeApresChangementGlobalJdc(motClef)
        # raise EficasException(tr("Pas implemente"))

    def updateConditionBloc(self):
        # pour le moment, on ne fait rien
        raise EficasException(tr("Pas implemente"))

    def getListeMcInconnus(self):
        """
        Retourne une liste contenant les mots-cles inconnus a la relecture du JDC
        """
        # cette liste a le format suivant : [etape,(bloc,mcfact,...),nom_mc,valeur_mc]
        l_mc = []
        for etape in self.etapes:
            if etape.isActif():
                if not etape.isValid():
                    l = etape.getListeMcInconnus()
                    if l:
                        l_mc.extend(l)
        return l_mc

    def getMCPath(self):
        return []

    def getGenealogiePrecise(self):
        return []

    def getObjetByMCPath(self, MCPath):
        # Attention; le MCPath n est valide qu a la lecture du fichier
        etape = None
        nomEtape = MCPath[0]
        nomSuivant = MCPath[1]
        if nomSuivant.startswith("@sdname "):
            nomEtape = nomSuivant.split(" ")[1]
            etape = self.getEtapeByConceptName(nomEtape)
        elif nomSuivant.startswith("@index "):
            indexEtape = nomSuivant.split(" ")[1]
            etape = self.getEtapesByName(nomEtape)[indexEtape]
        if not etape:
            return None
        return etape.getObjetByMCPath(MCPath[2:])

    def selectXYWhereCondition(self, MCPath1, MCPath2, MCARetourner, MCCondition, valeur):
   #---------------------------------------------------------------------------------------
   # est-ce que cette signature va bien  ?
   # elle permet de selection MCARetourner sous MCPath2 si MCCondition sous MCPath2 == valeur
   # il y aura surement d  autres cas
   # est-ce qu il ne faut pas deja prevoir les etapes nommees
   # retourne la valeur de MCPath1 et de MCARetourner 
   # si dans le fact decrit par MCPath2, le MCCOndition == Valeur
   # fact
  
        debug=0
        from Accas import MCList
        if MCPath1[0] != MCPath2[0] :
           print (' les MCPaths n indiquent pas la meme etape' )
           return []
        listeDonnees=[]
        if debug : print ('McPath1 ', MCPath1)
        if debug : print ('McPath2 ', MCPath2)
        if debug : print ('McARetourner ', MCARetourner)
        if debug : print ('MCCondition ', MCCondition)
        if debug : print ('valeur ', valeur)
        for e in self.etapes:
            if e.nom != MCPath1[0] : continue
            obj2=e.getObjetByMCPath(MCPath2[1:])
            if not obj2 : continue 
            if not (isinstance(obj2,MCList) and len(obj2) > 1) : obj2=(obj2,)
            if debug : print ('obj2', obj2)
            for o in obj2 :
                objCondition = o.getChild(MCCondition)
                if debug : print ('objCondition', objCondition)
                if objCondition.valeur != valeur : continue
                if debug : print ('la condition est vraie')

                objX=e.getObjetByMCPath(MCPath1[1:])
                objY=o.getChild(MCARetourner)
                if not objX or not objY : continue
                listeDonnees.append((objX.valeur,objY.valeur))
        return listeDonnees


    def selectXY(self, MCPath1, MCPath2):
    #------------------------------------
        debug=0
        from Accas import MCList
        if MCPath1[0] != MCPath2[0] :
           print (' les MCPaths n indiquent pas la meme etape' )
           return []
        listeDonnees=[]
        if debug : print ('McPath1 ', MCPath1)
        if debug : print ('McPath2 ', MCPath2)
        for e in self.etapes:
            if debug : print (e, e.nom)
            if e.nom != MCPath1[0] : continue
            objX=e.getObjetByMCPath(MCPath1[1:])
            if debug : print ('objX', objX)
            objY=e.getObjetByMCPath(MCPath2[1:])
            if debug : print ('objY', objY)
            if not objX or not objY : continue
            listeDonnees.append((objX.valeur,objY.valeur))
        return listeDonnees
    def getGenealogie(self):
        """
        Retourne la liste des noms des ascendants de l'objet self
        jusqu'a la premiere ETAPE parent.
        """
        return []

    def getListeCmd(self):
        """
        Retourne la liste des commandes du catalogue
        """
        return self.niveau.definition.getListeCmd()

    def getGroups(self):
        """
        Retourne la liste des groupes
        """
        return self.niveau.definition.liste_groupes, self.niveau.definition.dict_groupes

    def setEtapeContext(self, etape):
        """
        Positionne l'etape qui sera utilisee dans NommerSdProd pour
        decider si le concept passe pourra etre  nomme
        """
        self._etape_context = etape

    def resetContext(self):
        """
        Cette methode reinitialise le contexte glissant pour pouvoir
        tenir compte des modifications de l'utilisateur : craation
        de commandes, nommage de concepts, etc.
        """
        # print "resetContext",self,self.nom
        self.currentContext = {}
        self.index_etape_courante = 0
        ind = {}
        for i, etape in enumerate(self.etapes):
            ind[etape] = i
        self.index_etapes = ind

    #   for etape in self.etapes:
    #       etape.resetContext()

    def delSdprod(self, sd):
        """
        Supprime la SD sd de la liste des sd et des dictionnaires de contexte
        """
        # print "delSdprod",self,sd
        # print "delSdprod",self.sds
        # print "delSdprod",self.g_context
        # print "delSdprod",self.sdsDict
        # if sd in self.sds : self.sds.remove(sd)
        if sd.nom in self.g_context:
            del self.g_context[sd.nom]
        if sd.nom in self.sdsDict:
            del self.sdsDict[sd.nom]

    def delParam(self, param):
        """
        Supprime le parametre param de la liste des paramatres
        et du contexte gobal
        """
        if param in self.params:
            self.params.remove(param)
        if param.nom in self.g_context:
            del self.g_context[param.nom]

    def delFonction(self, fonction):
        """
        Supprime la fonction fonction de la liste des fonctions
        et du contexte gobal
        """
        if fonction in self.fonctions:
            self.fonctions.remove(fonction)
        if fonction.nom in self.g_context:
            del self.g_context[fonction.nom]

    def appendSdProd(self, sd):
        """
        Ajoute la SD sd a la liste des sd en verifiant au prealable qu'une SD de
        meme nom n'existe pas deja
        """
        if sd == None or sd.nom == None:
            return
        o = self.sdsDict.get(sd.nom, None)
        if isinstance(o, ASSD):
            raise AsException(tr("Nom de concept deja defini " + sd.nom))
        self.sdsDict[sd.nom] = sd
        self.g_context[sd.nom] = sd
        # if sd not in self.sds : self.sds.append(sd)

    def appendParam(self, param):
        """
        Ajoute le parametre param a la liste des params
        et au contexte global
        """
        # il faudrait verifier qu'un parametre de meme nom n'existe pas deja !!!
        if param not in self.params:
            self.params.append(param)
        self.g_context[param.nom] = param

    def appendFonction(self, fonction):
        """
        Ajoute la fonction fonction a la liste des fonctions
        et au contexte global
        """
        # il faudrait verifier qu'une fonction de meme nom n'existe pas deja !!!
        if fonction not in self.fonctions:
            self.fonctions.append(fonction)
        self.g_context[fonction.nom] = fonction

    def deleteConcept(self, sd):
        """
        Inputs :
           - sd=concept detruit
        Fonction :
        Mettre a jour les etapes du JDC suite a la disparition du
        concept sd
        Seuls les mots cles simples MCSIMP font un traitement autre
        que de transmettre aux fils
        """
        for etape in self.etapes:
            etape.deleteConcept(sd)
            # PN PN PN pour les matrices ????
            # self.getVariables_avant(etape)

    def replaceConceptAfterEtape(self, etape, old_sd, sd):
        """
        Met a jour les etapes du JDC qui sont apres etape en fonction
        du remplacement du concept sd
        """
        index = self.etapes.index(etape) + 1
        if index == len(self.etapes):
            return  # etape est la derniere etape du jdc ...on ne fait rien !
        for child in self.etapes[index:]:
            child.replaceConcept(old_sd, sd)

    def updateConceptAfterEtape(self, etape, sd):
        """
        Met a jour les etapes du JDC qui sont apres etape en fonction
        de la modification (principalement nommage) du concept sd
        """
        if etape is None:
            # On traite toutes les etapes
            index = 0
        else:
            index = self.etapes.index(etape) + 1
        if index == len(self.etapes):
            return  # etape est la derniere etape du jdc ...on ne fait rien !
        for child in self.etapes[index:]:
            child.updateConcept(sd)

    def dumpState(self):
        # print(("JDC.state: ",self.state))
        for etape in self.etapes:
            print((etape.nom + ".state: ", etape.state))

    def changeUnit(self, unit, etape, old_unit):
        # print "changeUnit",unit,etape,old_unit
        # print id(self.recorded_units),self.recorded_units
        # if self.recorded_units.has_key(old_unit):del self.recorded_units[old_unit]
        self.recordUnit(unit, etape)

    def recordUnit(self, unit, etape):
        """Enregistre les unites logiques incluses et les infos relatives a l'etape"""
        # print "recordUnit",unit,etape
        if unit is None:
            # Cas de POURSUITE
            self.recorded_units[None] = (
                etape.fichier_ini,
                etape.fichier_text,
                etape.recorded_units,
            )
        else:
            self.recorded_units[unit] = (
                etape.fichier_ini,
                etape.fichier_text,
                etape.recorded_units,
            )
        # print id(self.recorded_units),self.recorded_units
        # print self.recorded_units.get(None,(None,"",{}))[2]
        # print self.recorded_units.get(None,(None,"",{}))[2].get(None,(None,"",{}))

    def changeFichier(self, fichier):
        self.finModif()

    def evalInContext(self, valeur, etape):
        """Tente d'evaluer valeur dans le contexte courant de etape
        Retourne le parametre valeur inchange si l'evaluation est impossible
        """
        # contexte initial du jdc
        context = self.condition_context.copy()
        # contexte courant des concepts. Il contient les parametres
        context.update(self.getContexteAvant(etape))
        try:
            objet = eval(valeur, context)
            return objet
        except:
            # traceback.print_exc()
            pass
        return valeur

    # ATTENTION SURCHARGE : cette methode doit etre gardee en synchronisation avec celle de processing
    def supprime(self):
        Accas.processing.P_JDC.JDC.supprime(self)
        for etape in self.etapes:
            etape.supprime()
        self.appliEficas = None
        self.g_context = {}
        self.const_context = {}
        self.sdsDict = {}
        self.mc_globaux = {}
        self.currentContext = {}
        self.condition_context = {}
        self.etapes_niveaux = []
        self.niveau = None
        self.params = []
        self.fonctions = []
        self._etape_context = None
        self.etapes = []

    # ATTENTION SURCHARGE : cette methode doit etre gardee en synchronisation avec celle de processing
    def register(self, etape):
        """
        Cette methode ajoute  etape dans la liste
        des etapes self.etapes et retourne l identificateur d'etape
        fourni par l appel a gRegister

        A quoi sert editmode ?
           - Si editmode vaut 1, on est en mode edition de JDC. On cherche
             a enregistrer une etape que l'on a creee avec eficas (en passant
             par addEntite) auquel cas on ne veut recuperer que son numero
             d'enregistrement et c'est addEntite qui l'enregistre dans
             self.etapes a la bonne place...
           - Si editmode vaut 0, on est en mode relecture d'un fichier de
             commandes et on doit enregistrer l'etape a la fin de self.etapes
             (dans ce cas l'ordre des etapes est bien l'ordre chronologique
             de leur creation   )
        """
        # import traceback
        # traceback.print_stack()
        if not self.editmode:
            self.etapes.append(etape)
            self.index_etapes[etape] = len(self.etapes) - 1
        else:
            pass
        return self.gRegister(etape)

    # ATTENTION SURCHARGE : cette methode doit etre gardee en synchronisation avec celle de processing
    def nommerSDProd(self, sd, sdnom, restrict="non"):
        """
        Nomme la SD apres avoir verifie que le nommage est possible :
        nom non utilise
        Si le nom est deja utilise, leve une exception
        Met le concept cree dans le concept global g_context
        """
        # XXX En mode editeur dans EFICAS, le nommage doit etre gere differemment
        # Le dictionnaire g_context ne represente pas le contexte
        # effectif avant une etape.
        # Il faut utiliser getContexteAvant avec indication de l'etape
        # traitee.
        # Cette etape est indiquee par l'attribut _etape_context qui a ete
        # positionne prealablement par un appel a setEtapeContext

        if CONTEXT.debug:
            print(("JDC.nommerSDProd ", sd, sdnom))

        if self._etape_context:
            o = self.getContexteAvant(self._etape_context).get(sdnom, None)
        else:
            o = self.sdsDict.get(sdnom, None)

        if isinstance(o, ASSD):
            raise AsException(tr(" Nom de concept deja defini : " + sdnom))

        # ATTENTION : Il ne faut pas ajouter sd dans sds car il s y trouve deja.
        # Ajoute a la creation (appel de regSD).
        # print (' je pass ici, pour ', sdnom, self.sdsDict)
        self.sdsDict[sdnom] = sd
        sd.nom = sdnom

        # En plus si restrict vaut 'non', on insere le concept dans le contexte du JDC
        if restrict == "non":
            self.g_context[sdnom] = sd

    def deleteConceptEntreEtapes(self, index1, index2, sd):
        if index2 <= index1:
            return
        for child in self.etapes[index1:index2]:
            child.deleteConcept(sd)

    def deleteConceptAfterEtape(self, etape, sd):
        """
        Met a jour les etapes du JDC qui sont apres etape en fonction
        de la disparition du concept sd
        """
        index = self.etapes.index(etape) + 1
        if index == len(self.etapes):
            return  # etape est la derniere etape du jdc ...on ne fait rien !
        for child in self.etapes[index:]:
            child.deleteConcept(sd)

    def updateMCPath(self):
        # Cette methode sert a recaluler les MCPaths qui peuvent avoir changer
        # si il y a eu des suprressions dans des MCList freres ou oncles des motclefs incertains
        etapeIncertitude = self.getEtapesByName("ExpressionIncertitude")
        if etapeIncertitude == []:
            return
        mcVP = self.getChild("Input").getChild("VariableProbabiliste")
        if mcVP == None:
            return
        for mc in mcVP:
            itemMCPath = mc.getChild("MCPath")
            itemMCPath.setValeur(mc.variableDeterministe.getMCPath())

    def getDicoForFancy(self):
        monDico = {}
        monDico["title"] = self.code
        monDico["key"] = self.idUnique
        monDico["classeAccas"] = "JDC"
        monDico["validite"] = self.getValid()
        if not (monDico["validite"]):
            monDico["validite"] = 0
        # self.editor.fichier ?
        listNodes = []
        for e in self.etapes:
            listNodes.append(e.getDicoForFancy())
        monDico["children"] = listNodes
        return monDico

  

    # ATTENTION SURCHARGE : les methodes ci-dessus surchargent des methodes de Noyau et Validation : a reintegrer

    def getFile(self, unite=None, fic_origine=""):
        """
        Retourne le nom du fichier correspondant a un numero d'unite
        logique (entier) ainsi que le source contenu dans le fichier
        """
        if self.appliEficas is not None:
            # Si le JDC est relie a une appliEficascation maitre, on delegue la recherche
            file, text = self.appliEficas.getFile(unite, fic_origine)
        else:
            file = None
            if unite != None:
                if os.path.exists("fort." + str(unite)):
                    file = "fort." + str(unite)
            if file == None:
                raise AsException(
                    tr(
                        "Impossible de trouver le fichier correspondant a l'unite "
                        + str(unite)
                    )
                )
            if not os.path.exists(file):
                raise AsException(str(unite) + tr(" n'est pas un fichier existant"))
            fproc = open(file, "r")
            text = fproc.read()
            fproc.close()
        # if file == None : return None,None
        text = text.replace("\r\n", "\n")
        if file:
            linecache.cache[file] = 0, 0, text.split("\n"), file
        return file, text

    def isValid(self, cr="non"):
        if hasattr(self, "valid"):
            old_valid = self.valid
        else:
            old_valid = 0
        valid = V_JDC.JDC.isValid(self, cr)
        if valid != old_valid:
            CONNECTOR.Emit(self, "valid")
        return valid

    def getLNomsEtapes(self):
        """
        Retourne la liste des noms des etapes de self
        """
        l = []
        for etape in self.etapes:
            l.append(etape.nom)
        return l

    def getValuesOfAllMC(self,McPath):
        from Accas.A_MCLIST import MCList
        debug=0
        l=set()
        listeObj=[]
        for etape in self.etapes :
            if etape.nom == McPath[0] : listeObj.append(etape)
        if debug : print (listeObj)
        if debug : print (len(listeObj))
        for nom in McPath [1:] :
            if debug : print ('traitement de ', nom)
            newList=[]
            for obj in listeObj:
                newObj=obj.getChildOrChildInBloc(nom)
                if debug : print (newObj)
                if newObj : 
                    if isinstance(newObj,MCList):
                        for o in newObj : newList.append(o)
                    else :
                        newList.append(newObj)
            if debug : print (newList)
            listeObj=newList
        for obj in listeObj :
            if debug : print (obj)
            l.add(obj.valeur)
        if debug : print (l)
        return l

