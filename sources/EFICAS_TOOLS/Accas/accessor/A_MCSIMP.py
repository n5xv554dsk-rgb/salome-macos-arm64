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
import types
import traceback
from copy import copy
from Accas.extensions.eficas_translation import tr
from Accas.extensions.eficas_exception import EficasException

from Accas.processing.P_utils import repr_float
from Accas.accessor import CONNECTOR

# Attention : les classes ASSD,.... peuvent etre surchargees
# dans le package Accas. Il faut donc prendre des precautions si
# on utilise les classes  de processing pour faire des tests (isxxxx, ...)
# Si on veut creer des objets comme des CO avec les classes du processing
# ils n'auront pas les conportements des autres packages (pb!!!)
# Il vaut mieux les importer d'Accas mais probleme d'import circulaire,
# on ne peut pas les importer au debut.
# On fait donc un import local quand c'est necessaire (peut occasionner
# des pbs de prformance).
from Accas.processing.P_ASSD import ASSD, assd
from Accas.processing.P_GEOM import GEOM, geom
from Accas.processing.P_CO import CO

# fin attention

from Accas.extensions import parametre
from Accas.extensions import param2
from Accas.accessor import A_OBJECT
from Accas.accessor import CONNECTOR
from Accas.accessor.A_VALIDATOR import ValError, listProto
from Accas.validation import V_MCSIMP


class MCSIMP(A_OBJECT.OBJECT):
    def isValid(self, cr="non"):
        if self.state == "unchanged":
            return self.valid
        for type_permis in self.definition.type:
            # if hasattr(type_permis, "__class__") and type_permis.__class__.__name__ == 'Matrice':
            if hasattr(type_permis, "typElt"):
                self.monType = type_permis
                return self.valideMatrice(cr=cr)
        validite = V_MCSIMP.MCSIMP.isValid(self, cr=cr)

        if self.definition.siValide != None and validite:
            self.definition.siValide(self)
        return validite


    def getDicoForFancy(self):
        # print ('MCSIMP getDicoForFancy ', self)
        monDico = {}
        monDico["title"] = self.nom
        monDico["key"] = self.idUnique
        if self.valeur != None:
            if self.waitUserAssd() or self.waitAssd() or self.waitUserAssdMultiple():
                if isinstance(self.valeur, list) or isinstance(self.valeur,tuple) :
                   monDico["wValue"] = []
                   for v in self.valeur : monDico["wValue"].append(v.getName())
                else : monDico["wValue"] = self.valeur.getName()
            else : monDico["wValue"] = str(self.valeur)
        else:
            monDico["wValue"] = ""
        monDico["classeAccas"] = self.nature
        monDico["validite"] = self.getValid()
        if monDico["validite"] == None:
            monDico["validite"] = self.isValid()
        #PN TODO:  Corriger pour gérer correctement le inf ds javascript
        monDico["max"] = self.definition.max
        if self.definition.max == float('inf'): 
            monDico["max"] = 10000
        monDico["min"] = self.definition.min
        monDico["into"] = self.definition.into
        if self.definition.into != None and self.waitReel() :
           monDico["into"] = []
           for r in self.definition.into :
               chaineR=str(r)
               if not chaineR.find('.') : chaineR = chaineR + '.'
               monDico["into"].append(chaineR)
           if not monDico["wValue"].find('.') : monDico["wValue"]+'.'
        if self.waitAssd():
           if self.waitUserAssdOrAssdMultipleEnCreation() : 
               monDico["into"] = None 
           else :
               if self.waitUserAssdMultiple(): dict = self.getUserAssdPossible()
               else : dict = self.etape.parent.getSdAvantDuBonType(self.etape,self.definition.type)
               if self.waitUserAssd() : dict +=self.jdc.getSdCreeParObjet(self.definition.type)
               monDico["into"] =[]
               for r in dict :  monDico["into"]. append(r.getName())
        monDico["statut"] = self.definition.statut
        # a priori jamais vrai sauf si on a change un nom de userassd
        if monDico["validite"] == 0 and monDico["statut"] == "f":
            monDico["validite"] == 2

        return monDico
    def getNomConcept(self):
        p = self
        while p.parent:
            try:
                nomconcept = p.getSdname()
                return nomconcept
            except:
                try:
                    nomconcept = p.object.getSdname()
                    return nomconcept
                except:
                    pass
            p = p.parent
        return ""

    def getText(self):
        """
        Retourne le texte a afficher dans l'arbre representant la valeur de l'objet
        pointe par self
        """

        if self.valeur == None:
            return None
        elif type(self.valeur) == float:
            # traitement d'un flottant isole
            txt = str(self.valeur)
            clefobj = self.getNomConcept()
            if clefobj in self.jdc.appliEficas.dict_reels:
                if self.valeur in self.jdc.appliEficas.dict_reels[clefobj]:
                    txt = self.jdc.appliEficas.dict_reels[clefobj][self.valeur]
        elif type(self.valeur) in (list, tuple):
            if self.valeur == [] or self.valeur == ():
                return str(self.valeur)
            # traitement des listes
            txt = "("
            sep = ""
            for val in self.valeur:
                if type(val) == float:
                    clefobj = self.getNomConcept()
                    if clefobj in self.jdc.appliEficas.dict_reels:
                        if val in self.jdc.appliEficas.dict_reels[clefobj]:
                            txt = (
                                txt
                                + sep
                                + self.jdc.appliEficas.dict_reels[clefobj][val]
                            )
                        else:
                            txt = txt + sep + str(val)
                    else:
                        txt = txt + sep + str(val)
                else:
                    if isinstance(val, tuple):
                        texteVal = "("
                        for i in val:
                            if isinstance(i, bytes) or isinstance(i, str):
                                texteVal = texteVal + "'" + str(i) + "',"
                            else:
                                texteVal = texteVal + str(i) + ","
                        texteVal = texteVal[:-1] + ")"
                    else:
                        if isinstance(val, bytes) or isinstance(val, str):
                            texteVal = "'" + str(val) + "'"
                        else:
                            texteVal = str(val)
                    txt = txt + sep + texteVal

                ##        if len(txt) > 200:
                ##            #ligne trop longue, on tronque
                ##            txt=txt+" ..."
                ##            break
                sep = ","
            # cas des listes de tuples de longueur 1
            if isinstance(val, tuple) and len(self.valeur) == 1:
                txt = txt + ","
            txt = txt + ")"
        else:
            # traitement des autres cas
            txt = str(self.valeur)

        # txt peut etre une longue chaine sur plusieurs lignes.
        # Il est possible de tronquer cette chaine au premier \n et
        # de limiter la longueur de la chaine a 30 caracteres. Cependant
        # ceci provoque une perte d'information pour l'utilisateur
        # Pour le moment on retourne la chaine telle que
        return txt

    def getVal(self):
        """
        Retourne une chaine de caractere representant la valeur de self
        """
        val = self.valeur
        if type(val) == float:
            clefobj = self.getNomConcept()
            if clefobj in self.jdc.appliEficas.dict_reels:
                if val in self.jdc.appliEficas.appliEficas.dict_reels[clefobj]:
                    return self.jdc.appliEficas.dict_reels[clefobj][val]
        if type(val) != tuple:
            try:
                return val.getName()
            except:
                return val
        else:
            if val == () or val == []:
                return val
            s = "( "
            for item in val:
                try:
                    s = s + item.getName() + ","
                except:
                    s = s + repr(item) + ","
            s = s + " )"
            return s

    def waitBool(self):
        for typ in self.definition.type:
            try:
                if typ == bool:
                    return True
            except:
                pass
        return False

    def waitCo(self):
        """
        Methode booleenne qui retourne 1 si l'objet attend un objet ASSD
        qui n'existe pas encore (type CO()), 0 sinon
        """
        for typ in self.definition.type:
            if type(typ) == type or isinstance(typ, type):
                if issubclass(typ, CO):
                    return 1
        return 0

    def waitAssd(self):
        """
        Methode booleenne qui retourne 1 si le MCS attend un objet de type ASSD ou UserASSD
        ou derive, 0 sinon
        """
        for typ in self.definition.type:
            if type(typ) == type or isinstance(typ, type):
                if issubclass(typ, ASSD) and not issubclass(typ, GEOM):
                    return 1
        return 0

    def waitUserAssd(self):
        """
        Methode booleenne qui retourne 1 si le MCS attend un objet de type ASSD
        ou derive, 0 sinon
        """
        from Accas import UserASSD
        for typ in self.definition.type:
            if type(typ) == type or isinstance(typ, type):
                if issubclass(typ, UserASSD):
                    return 1
        return 0

    def waitUserAssdMultiple(self):
        from Accas import UserASSDMultiple
        for typ in self.definition.type:
            if type(typ) == type or isinstance(typ, type):
                if issubclass(typ, UserASSDMultiple):
                    return 1
        return 0

    def waitUserAssdOrAssdMultipleEnCreation(self):
        for typ in self.definition.type:
            if typ == "createObject":
                return 1
        return 0

    def waitAssdOrGeom(self):
        """
        Retourne 1 si le mot-cle simple attend un objet de type
        assd, ASSD, geom ou GEOM
        Retourne 0 dans le cas contraire
        """
        for typ in self.definition.type:
            if type(typ) == type or isinstance(typ, type):
                if typ.__name__ in ("GEOM", "ASSD", "geom", "assd") or issubclass(
                    typ, GEOM
                ):
                    return 1
        return 0

    def waitGeom(self):
        """
        Retourne 1 si le mot-cle simple attend un objet de type GEOM
        Retourne 0 dans le cas contraire
        """
        for typ in self.definition.type:
            if type(typ) == type or isinstance(typ, type):
                if issubclass(typ, GEOM):
                    return 1
        return 0

    def waitTxm(self):
        """
        Retourne 1 si le mot-cle simple attend un objet de type TXM
        Retourne 0 dans le cas contraire
        """
        for typ in self.definition.type:
            if typ == "TXM":
                return 1
        return 0

    def waitReel(self):
        for typ in self.definition.type:
            if typ == "R":
                return 1
        return 0

    def waitTuple(self):
        for ss_type in self.definition.type:
            if repr(ss_type).find("Tuple") != -1:
                return 1
        return 0

    def waitChaineAvecBlancs(self):
        if self.definition.avecBlancs:
            return 1
        return 0

    def combienEltDsTuple(self):
        for ss_type in self.definition.type:
            if hasattr(ss_type, "ntuple"):
                return ss_type.ntuple
        return O

    def waitMatrice(self):
        if hasattr(self, "isAMatrice"):
            return self.isAMatrice
        for typ in self.definition.type:
            try:
                if hasattr(typ, "typElt"):
                    self.isAMatrice = 1
                    return 1
            except:
                pass
        self.isAMatrice = 0
        return 0

    def getListeValeurs(self):
        """ """
        if self.valeur == None:
            return []
        elif type(self.valeur) == tuple:
            return list(self.valeur)
        elif type(self.valeur) == list:
            return self.valeur
        else:
            return [self.valeur]

    def isOblig(self):
        return self.definition.statut == "o"

    def isImmuable(self):
        return self.definition.homo == "constant"

    def isInformation(self):
        return self.definition.homo == "information"

    def validVal(self, valeur):
        """
        Verifie que la valeur passee en argument (valeur) est valide
        sans modifier la valeur courante
        """
        lval = listProto.adapt(valeur)
        if lval is None:
            valid = 0
            mess = tr("None n'est pas une valeur autorisee")
        else:
            try:
                for val in lval:
                    self.typeProto.adapt(val)
                    self.intoProto.adapt(val)
                self.cardProto.adapt(lval)
                if self.definition.validators:
                    self.definition.validators.convert(lval)
                valid, mess = 1, ""
            except ValError as e:
                mess = str(e)
                valid = 0
        return valid, mess

    def validValeur(self, new_valeur):
        """
        Verifie que la valeur passee en argument (new_valeur) est valide
        sans modifier la valeur courante (evite d'utiliser setValeur et est plus performant)
        """
        validite, mess = self.validVal(new_valeur)
        return validite

    def validValeurPartielle(self, new_valeur):
        """
        Verifie que la valeur passee en argument (new_valeur) est une liste partiellement valide
        sans modifier la valeur courante du mot cle
        """
        validite = 1
        try:
            for val in new_valeur:
                self.typeProto.adapt(val)
                self.intoProto.adapt(val)
                # on ne verifie pas la cardinalite
                if self.definition.validators:
                    validite = self.definition.validators.valideListePartielle(
                        new_valeur
                    )
        except ValError as e:
            validite = 0

        return validite

    def updateConditionBloc(self):
        """Met a jour les blocs conditionnels dependant du mot cle simple self"""
        if self.definition.position == "global":
            self.etape.deepUpdateConditionBloc()
            self.etape.demandeUpdateOptionnels()
        elif self.definition.position == "reCalculeEtape":
            # print ('je passe par updateConditionBloc pour ', self.nom)
            self.etape.deepUpdateConditionBloc()
            self.etape.demandeRedessine()
        elif self.definition.position == "global_jdc":
            self.jdc.deepUpdateConditionBloc(self)
            self.etape.demandeRedessine()
        elif self.definition.position == "inGetAttribut":
            self.jdc.deepUpdateConditionBloc(self)
        else:
            self.parent.updateConditionBloc()

    def demandeUpdateOptionnels(self):
        pass

    def setValeur(self, new_valeur):
        self.initModif()
        self.valeur = new_valeur
        self.val = new_valeur
        if ( self.valeur and self.waitUserAssd() and not (self.waitUserAssdOrAssdMultipleEnCreation())):
            if type(self.valeur) in (list, tuple):
                for v in self.valeur:
                    v.ajoutUtilisePar(self)
            else:
                self.valeur.ajoutUtilisePar(self)
        if self.isValid() and hasattr(self, "objPyxb") and self.objPyxb:
            self.setValeurObjPyxb(new_valeur)
        self.updateConditionBloc()
        if self.definition.metAJour != None:
            self.updateAutresMotsClefs()
        self.etape.modified()
        self.finModif()
        return 1

    def evalValeur(self, new_valeur):
        """
        Essaie d'evaluer new_valeur comme une SD, une declaration Python
        ou un EVAL: Retourne la valeur evaluee (ou None) et le test de reussite (1 ou 0)
        """
        sd = self.jdc.getSdAvantEtape(new_valeur, self.etape)
        # sd = self.jdc.getContexteAvant(self.etape).get(new_valeur,None)
        if sd is not None:
            return sd, 1
        lsd = self.jdc.chercheListAvant(self.etape, new_valeur)
        if lsd:
            return lsd, 1
        else:
            d = {}
            # On veut EVAL avec tous ses comportements. On utilise Accas. Perfs ??
            d["EVAL"] = Accas.EVAL
            try:
                objet = eval(new_valeur, d)
                return objet, 1
            except Exception:
                itparam = self.chercheItemParametre(new_valeur)
                if itparam:
                    return itparam, 1
                try:
                    object = eval(new_valeur.valeur, d)
                except:
                    pass
                if CONTEXT.debug:
                    traceback.print_exc()
                return None, 0

    def evalVal(self, new_valeur):
        """
        Tente d'evaluer new_valeur comme un objet du jdc (par appel a evalValItem)
        ou comme une liste de ces memes objets
        Si new_valeur contient au moins un separateur (,), tente l'evaluation sur
        la chaine splittee
        """
        if new_valeur in ("True", "False") and "TXM" in self.definition.type:
            valeur = self.evalValItem(str(new_valeur))
            return new_valeur
        if type(new_valeur) in (list, tuple):
            valeurretour = []
            for item in new_valeur:
                valeurretour.append(self.evalValItem(item))
            return valeurretour
        else:
            valeur = self.evalValItem(new_valeur)
            return valeur

    def evalValItem(self, new_valeur):
        """
        Tente d'evaluer new_valeur comme un concept, un parametre, un objet Python ou un UserASSD
        Si c'est impossible retourne new_valeur inchange
        argument new_valeur : string (nom de concept, de parametre, expression ou simple chaine)
        """
        if new_valeur in list(self.jdc.sdsDict.keys()) and self.waitUserAssd():
            valeur = self.jdc.sdsDict[new_valeur]
            return valeur
        elif self.etape and self.etape.parent:
            valeur = self.etape.parent.evalInContext(new_valeur, self.etape)
            return valeur
        else:
            try:
                valeur = eval(new_valeur)
                return valeur
            except:
                # traceback.print_exc()
                return new_valeur
                pass

    def chercheItemParametre(self, new_valeur):
        try:
            nomparam = new_valeur[0 : new_valeur.find("[")]
            indice = new_valeur[new_valeur.find("[") + 1 : new_valeur.find("]")]
            for p in self.jdc.params:
                if p.nom == nomparam:
                    if int(indice) < len(p.getValeurs()):
                        itparam = parametre.ITEM_PARAMETRE(p, int(indice))
                        return itparam
            return None
        except:
            return None

    def updateConcept(self, sd):
        if not self.waitAssd():
            return
        if type(self.valeur) in (list, tuple):
            if sd in self.valeur:
                newVal = []
                for v in self.valeur:
                    newVal.append(v.nom)
                self.initModif()
                if hasattr(self, "objPyxb") and self.objPyxb:
                    self.setValeurObjPyxb(newVal)
                self.finModif()
        else:
            if sd == self.valeur:
                self.initModif()
                if hasattr(self, "objPyxb") and self.objPyxb:
                    self.setValeurObjPyxb(sd.nom)
                self.finModif()

    def deleteConcept(self, sd):
        """
        Inputs :
           - sd=concept detruit
        Fonction :
        Met a jour la valeur du mot cle simple suite a la disparition
        du concept sd
        Attention aux matrices
        """
        ##PNPNPN a tester
        if type(self.valeur) == tuple:
            if sd in self.valeur:
                self.initModif()
                self.valeur = list(self.valeur)
                while sd in self.valeur:
                    self.valeur.remove(sd)
                if hasattr(self, "objPyxb") and self.objPyxb:
                    newVal = []
                    for v in self.valeur:
                        newVal.append(v.nom)
                    if newVal == []:
                        self.delObjPyxb()
                    else:
                        self.setValeurObjPyxb(sd.nom)
                self.finModif()
        elif type(self.valeur) == list:
            if sd in self.valeur:
                self.initModif()
                while sd in self.valeur:
                    self.valeur.remove(sd)
                self.finModif()
        else:
            if self.valeur == sd:
                self.initModif()
                self.valeur = None
                self.val = None
                if hasattr(self, "objPyxb") and self.objPyxb:
                    self.setValeurObjPyxb()
                self.finModif()
        # Glut Horrible pour les matrices OT ???
        # if sd.__class__.__name__== "variable":
        #   for type_permis in self.definition.type:
        # if type(type_permis) == types.InstanceType:
        # a voir en python 3
        #           if type_permis.__class__.__name__ == 'Matrice' :
        #               self.state="changed"
        #               self.isValid()

    def replaceConcept(self, old_sd, sd):
        """
        Inputs :
           - old_sd=concept remplace
           - sd=nouveau concept
        Fonction :
        Met a jour la valeur du mot cle simple suite au remplacement
        du concept old_sd
        """
        # print ("replaceConcept",old_sd,sd)
        if type(self.valeur) == tuple:
            if old_sd in self.valeur:
                self.initModif()
                self.valeur = list(self.valeur)
                i = self.valeur.index(old_sd)
                self.valeur[i] = sd
                self.finModif()
        elif type(self.valeur) == list:
            if old_sd in self.valeur:
                self.initModif()
                i = self.valeur.index(old_sd)
                self.valeur[i] = sd
                self.finModif()
        else:
            if self.valeur == old_sd:
                self.initModif()
                self.valeur = sd
                self.val = sd
                self.finModif()

    def setValeurCo(self, nomCO):
        """
        Affecte a self l'objet de type CO et de nom nomCO
        """
        step = self.etape.parent
        if nomCO == None or nomCO == "":
            new_objet = None
        else:
            # Avant de creer un concept il faut s'assurer du contexte : step
            # courant
            sd = step.getSdAutourEtape(nomCO, self.etape, avec="oui")
            if sd:
                # Si un concept du meme nom existe deja dans la portee de l'etape
                # on ne cree pas le concept
                return 0, tr("un concept de meme nom existe deja")
            # Il n'existe pas de concept de meme nom. On peut donc le creer
            # Il faut neanmoins que la methode NommerSdProd de step gere les
            # contextes en mode editeur
            # Normalement la methode   de processing doit etre surchargee
            # On declare l'etape du mot cle comme etape courante pour nommerSDProd
            cs = CONTEXT.getCurrentStep()
            CONTEXT.unsetCurrentStep()
            CONTEXT.setCurrentStep(step)
            step.setEtapeContext(self.etape)
            new_objet = Accas.CO(nomCO)
            CONTEXT.unsetCurrentStep()
            CONTEXT.setCurrentStep(cs)
        self.initModif()
        self.valeur = new_objet
        self.val = new_objet
        # On force l'enregistrement de new_objet en tant que concept produit
        # de la macro en appelant getType_produit avec force=1
        self.etape.getType_produit(force=1)
        self.finModif()
        step.resetContext()
        # print "setValeurCo",new_objet
        return 1, tr("Concept cree")

    def verifExistenceSd(self):
        """
        Verifie que les structures de donnees utilisees dans self existent bien dans le contexte
        avant etape, sinon enleve la referea ces concepts
        """
        # print "verifExistenceSd"
        # Attention : possible probleme avec include
        # A priori il n'y a pas de raison de retirer les concepts non existants
        # avant etape. En fait il s'agit uniquement eventuellement de ceux crees par une macro
        l_sd_avant_etape = list(self.jdc.getContexteAvant(self.etape).values())
        if type(self.valeur) in (tuple, list):
            l = []
            for sd in self.valeur:
                if isinstance(sd, ASSD):
                    if sd in l_sd_avant_etape or self.etape.getSdprods(sd.nom) is sd:
                        l.append(sd)
                else:
                    l.append(sd)
            if len(l) < len(self.valeur):
                self.initModif()
                self.valeur = tuple(l)
                self.finModif()
        else:
            if isinstance(self.valeur, ASSD):
                if (
                    self.valeur not in l_sd_avant_etape
                    and self.etape.getSdprods(self.valeur.nom) is None
                ):
                    self.initModif()
                    self.valeur = None
                    self.finModif()

    def renommeSdCree(self, nouveauNom):
        # print ( 'dans renommeSdCree', self.jdc.sdsDict, self.valeur)
        if nouveauNom in self.jdc.sdsDict:
            return (0, "concept deja existant")
        if self.valeur == None:
            return (0, "pb sur la valeur")
        else:
            self.valeur.renomme(nouveauNom)
        return (1, "concept renomme")

    def renommeSdCreeDsListe(self, objASSD, nouveauNom):
        # print ( 'dans renommeSdCree', self.jdc.sdsDict, self.valeur, nouveauNom)
        if nouveauNom in self.jdc.sdsDict:
            return (0, "concept deja existant")
        objASSD.renomme(nouveauNom)
        return (1, "concept renomme")

    def getMinMax(self):
        """
        Retourne les valeurs min et max admissibles pour la valeur de self
        """
        return self.definition.min, self.definition.max

    def getType(self):
        """
        Retourne le type attendu par le mot-cle simple
        """
        return self.definition.type

    def deleteMcGlobal(self):
        """Retire self des declarations globales"""
        # on est oblige de verifier si le nom est dans etape
        # car parfois l ordre des creations/destruction n est pas clair
        # quand on a des blocs freres qui contiennent le meme mc global
        # cas de NumericalMethod dans VIMMP
        if self.definition.position == "global":
            etape = self.getEtape()
            if etape and self.nom in etape.mc_globaux:
                if etape.mc_globaux[self.nom] == self:
                    del etape.mc_globaux[self.nom]
        elif self.definition.position == "reCalculeEtape":
            etape = self.getEtape()
            if etape:
                if self.nom in etape.mc_globaux:
                    if etape.mc_globaux[self.nom] == self:
                        del etape.mc_globaux[self.nom]
                        self.etape.doitEtreRecalculee = True
                    # print ('deleteMcGlobal je mets doitEtreRecalculee = True avec', self.nom ,' pour ', etape.nom)
        elif self.definition.position == "global_jdc":
            if self.nom in self.jdc.mc_globaux:
                try:
                    del self.jdc.mc_globaux[self.nom]
                except:
                    print("!!!!!!!! Souci delete mc_globaux")

    def updateMcGlobal(self):
        """
        Met a jour les mots cles globaux enregistres dans l'etape parente
        et dans le jdc parent.
        Un mot cle simple peut etre global.
        """
        if self.definition.position == "global":
            etape = self.getEtape()
            if etape:
                etape.mc_globaux[self.nom] = self
        elif self.definition.position == "reCalculeEtape":
            etape = self.getEtape()
            if etape:
                etape.mc_globaux[self.nom] = self
                etape.doitEtreRecalculee = True
                print(
                    "je mets doitEtreRecalculee = True avec",
                    self.nom,
                    " pour ",
                    etape.nom,
                )
                print("j ajoute au mc_globaux")
        elif self.definition.position == "global_jdc":
            if self.jdc:
                self.jdc.mc_globaux[self.nom] = self

    def nbrColonnes(self):
        genea = self.getGenealogie()
        if "VALE_C" in genea and "DEFA_FONCTION" in genea:
            return 3
        if "VALE" in genea and "DEFA_FONCTION" in genea:
            return 2
        return 0

    def valideItem(self, item):
        """Valide un item isole. Cet item est candidata l'ajout a la liste existante"""
        valid = 1
        try:
            # on verifie le type
            self.typeProto.adapt(item)
            # on verifie les choix possibles
            self.intoProto.adapt(item)
            # on ne verifie pas la cardinalite
            if self.definition.validators:
                valid = self.definition.validators.verifItem(item)
        except ValError as e:
            # traceback.print_exc()
            valid = 0
        return valid

    def verifType(self, item):
        """Verifie le type d'un item de liste"""
        try:
            # on verifie le type
            self.typeProto.adapt(item)
            # on verifie les choix possibles
            self.intoProto.adapt(item)
            # on ne verifie pas la cardinalite mais on verifie les validateurs
            if self.definition.validators:
                if hasattr(self.definition.validators, "set_MCSimp"):
                    self.definition.validators.set_MCSimp(self)
                valid = self.definition.validators.verifItem(item)
            comment = ""
            valid = 1
        except ValError as e:
            # traceback.print_exc()
            comment = tr(e.__str__())
            valid = 0
        except Exception as e:
            comment = tr(e.__str__())
            valid = 0
        return valid, comment

    def valideMatrice(self, cr):
        ok = 1
        commentaire = ""
        if self.valeur == None:
            self.setValid(0)
            return 0

        if self.monType.methodeCalculTaille != None:
            MCSIMP.__dict__[self.monType.methodeCalculTaille](*(self,))

        if len(self.valeur) == self.monType.nbLigs:
            for i in range(len(self.valeur)):
                if len(self.valeur[i]) != self.monType.nbCols:
                    ok = 0
        else:
            ok = 0

        if not ok:
            self.setValid(0)
            if cr == "oui":
                self.cr.fatal(
                    tr(
                        "La matrice n'est pas une matrice %(n_lign)d sur %(n_col)d",
                        {"n_lign": self.monType.nbLigs, "n_col": self.monType.nbCols},
                    )
                )
            return 0

        for i in range(self.monType.nbLigs):
            for j in range(self.monType.nbCols):
                val = self.valeur[i][j]
                ok, commentaire = self.monType.verifItem(str(val), self.parent)
                if (
                    self.monType.typElt not in ("TXM", "I", "R")
                    and type(val) != self.monType.typElt
                ):
                    ok = 0
                    commentaire = "mauvais type"
                    self.valeur = None
                if not ok:
                    self.setValid(0)
                    if cr == "oui":
                        self.cr.fatal(tr(commentaire))
                    return 0
        self.setValid(1)
        return 1

    def valideMatriceOT(self, cr):
        # Attention, la matrice contient comme dernier tuple l ordre des variables
        if self.valideEnteteMatrice() == False:
            self.setValid(0)
            if cr == "oui":
                self.cr.fatal(tr("La matrice n'a pas le bon entete"))
            return 0
        if self.monType.methodeCalculTaille != None:
            MCSIMP.__dict__[self.monType.methodeCalculTaille](*(self,))
        try:
            # if 1 :
            ok = 0
            if len(self.valeur) == self.monType.nbLigs + 1:
                ok = 1
                for i in range(len(self.valeur) - 1):
                    if len(self.valeur[i]) != self.monType.nbCols:
                        ok = 0
            if ok:
                self.setValid(1)
                return 1
        except:
            # else :
            pass
        if cr == "oui":
            self.cr.fatal(
                tr(
                    "La matrice n'est pas une matrice %(n_lign)d sur %(n_col)d",
                    {"n_lign": self.monType.nbLigs, "n_col": self.monType.nbCols},
                )
            )
        self.setValid(0)
        return 0

    def nbDeVariables(self):
        listeVariables = self.jdc.getVariables(self.etape)
        self.monType.nbLigs = len(listeVariables)
        self.monType.nbCols = len(listeVariables)

    def valideEnteteMatrice(self):
        if self.jdc.getDistributions(self.etape) == () or self.valeur == None:
            return 0
        if self.jdc.getDistributions(self.etape) != self.valeur[0]:
            return 0
        return 1

    def changeEnteteMatrice(self):
        a = [
            self.jdc.getDistributions(self.etape),
        ]
        for t in self.valeur[1:]:
            a.append(t)
        self.valeur = a

    def nbDeDistributions(self):
        listeVariables = self.jdc.getDistributions(self.etape)
        self.monType.nbLigs = len(listeVariables)
        self.monType.nbCols = len(listeVariables)

    def getNomDsXML(self):
        nomDsXML = self.parent.getNomDsXML() + "." + self.nom
        return nomDsXML

    def verifTypeIhm(self, val, cr="non"):
        try:
            val.eval()
            return 1
        except:
            traceback.print_exc()
            pass
        return self.verifType(val, cr)

    def verifTypeliste(self, val, cr="non"):
        verif = 0
        for v in val:
            verif = verif + self.verifTypeIhm(v, cr)
        return verif

    def initModifUp(self):
        V_MCSIMP.MCSIMP.initModifUp(self)
        CONNECTOR.Emit(self, "valid")

    def initRedessine(self):
        CONNECTOR.Emit(self, "redessine")

    def deleteRef(self):
        if self.valeur == None or self.valeur == []:
            return
        if not type(self.valeur) in (list, tuple):
            lesValeurs = (self.valeur,)
        else:
            lesValeurs = self.valeur
        for val in lesValeurs:
            if self.definition.creeDesObjets:
                val.deleteReference(self)
            else:
                if hasattr(val, "enleveUtilisePar"):
                    val.enleveUtilisePar(self)

    def updateAutresMotsClefs(self):
        # print ('updateAutresMotsClefs')
        for nomMC, Xpath in self.definition.metAJour:
            exp = Xpath + '.getChild("' + nomMC + '")'
            try:
                lesMotsClefs = eval(exp)
            except:
                lesMotsClefs = []
            if not type(lesMotsClefs) in (list, tuple):
                lesMotsClefs = (lesMotsClefs,)
            if isinstance(lesMotsClefs, MCSIMP):
                lesMotsClefs = (lesMotsClefs,)
            listeEtapesDejaRedessinees = []
            listeMotsClefsAppel = []
            for leMotCle in lesMotsClefs:
                leMotCle.state = "changed"
                if not leMotCle.isValid():
                    leMotCle.val = None
                if leMotCle.etape not in listeEtapesDejaRedessinees:
                    listeEtapesDejaRedessinees.append(leMotCle.etape)
                    listeMotsClefsAppel.append(leMotCle)
            for leMotCle in listeMotsClefsAppel:
                leMotCle.demandeRedessine()

        # print ('fin updateAutresMotsClefs')

    def UQPossible(self):
        # Plus facile de mettre cette methode dans le SIMP, car on connait son nom
        # reflechir au TUI
        if not hasattr(self.cata, "dictUQ"):
            return False
        if not (self.nom in self.cata.dictUQ.keys()):
            return False
        if not hasattr(self.cata, "dictUQConditions"):
            return True
        if not (self.nom in self.cata.dictUQConditions.keys()):
            return True
        maFonction = self.cata.dictUQConditions[self.nom][0]
        argsLoi = self.cata.dictUQConditions[self.nom][1]
        argsLoi["obj"] = self
        return maFonction(**argsLoi)

    def isUQActivate(self):
        # valide uniquement pour les MCSIMP
        # a reflechir a la relecture du .comm
        return self.associeVariableUQ

    def lieVariableUQ(self):
        # print ('je passe dans lieVariableUQ')
        self.associeVariableUQ = True
        etapeIncertitude = self.jdc.getEtapesByName("ExpressionIncertitude")
        if etapeIncertitude == []:
            self.jdc.editor.tree.racine.appendChild("ExpressionIncertitude", "last")
            etapeIncertitude = self.jdc.getEtapesByName("ExpressionIncertitude")
            # Ou la la, que c est generique
            # ajouter un op_construction
            etapeIncertitude[0].buildSd()
        etapeIncertitude = etapeIncertitude[0]
        incertitudeInput = etapeIncertitude.getChildOrChildInBloc("Input")
        nodeVariableProbabiliste = incertitudeInput.node.appendChild(
            "VariableProbabiliste", "first"
        )
        # le buildChildren a une mcliste --> on est oblige de mettre first mais en fait c est last
        # PN a cooriger
        if nodeVariableProbabiliste.item.object.nature == "MCFACT":
            newVariable = nodeVariableProbabiliste.item.object
        else:
            newVariable = nodeVariableProbabiliste.item.object[-1]
        newVariable.variableDeterministe = self
        self.variableProbabiliste = newVariable

        if self.etape.nature == "OPERATEUR":
            itemObjet = newVariable.addEntite("ObjectName", 0)
            itemObjet.definition.addInto(self.etape.sd.nom)
            itemObjet.setValeur(self.etape.sd.nom)
        itemModelVariable = newVariable.getChild("ModelVariable")
        itemModelVariable.setValeur(self.nom)

        itemConsigne = newVariable.getChild("Consigne")
        itemConsigne.setValeur(
            "la valeur entrée pour {} est {}".format(self.nom, self.valeur)
        )

        itemXPath = newVariable.getChild("MCPath")
        itemXPath.setValeur(self.getMCPath())
        # print (itemXPath)

        self.definition.siValide = self.changeValeursRefUQ

    def changeValeursRefUQ(self, motClef):
        debug = 0
        if debug:
            print("changeValeursRefUQ", motClef)
        if debug:
            print(self.nom)
        # la premiere fois, si on a des MCFACT, la variable probabiliste n est pas encore a jour
        if not hasattr(motClef, "variableProbabiliste"):
            if debug:
                print("pb ds changeValeursRefUQ")
            return
        itemConsigne = motClef.variableProbabiliste.getChild("Consigne")
        itemConsigne.setValeur(
            "la valeur entrée pour {} est {}".format(motClef.nom, motClef.valeur)
        )

    def delieVariableUQ(self):
        debug = 0
        if debug:
            print("delieVariableUQ pour", self)
        self.associeVariableUQ = False
        # Attention, on n a pas le MCLIST mais le MCLIST(0) dans la variableProbabiliste
        # si self est le seul alors on enleve la MCLIST du MCCOMPO
        mcVP = self.variableProbabiliste.parent.getChild("VariableProbabiliste")
        if len(mcVP) == 1:
            ret = self.variableProbabiliste.parent.suppEntite(mcVP)
        else:
            ret = mcVP.suppEntite(self.variableProbabiliste)
        return ret
