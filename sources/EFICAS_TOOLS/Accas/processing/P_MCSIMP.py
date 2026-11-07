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
    Ce module contient la classe MCSIMP qui sert à controler la valeur
    d'un mot-clé simple par rapport à sa définition portée par un objet
    de type ENTITE
"""

from copy import copy
from Accas.processing.P_ASSD import ASSD
from Accas.processing.P_UserASSDMultiple import UserASSDMultiple
from Accas.processing.P_CO import CO
from Accas.processing import P_OBJECT
from Accas.processing.P_CONVERT import ConversionFactory
from Accas.processing.P_types import forceList, isSequence


class MCSIMP(P_OBJECT.OBJECT):

    """ """

    nature = "MCSIMP"

    def __init__(self, val, definition, nom, parent, objPyxbDeConstruction):
        """
         Attributs :
          - val : valeur du mot clé simple
          - definition
          - nom
          - parent

        Autres attributs :

          - valeur : valeur du mot-clé simple en tenant compte de la valeur par défaut

        """
        # print (self, val, definition, nom, parent)
        self.definition = definition
        self.nom = nom
        self.val = val
        self.parent = parent
        self.associeVariableUQ = False
        self.objPyxbDeConstruction = objPyxbDeConstruction
        if parent:
            self.jdc = self.parent.jdc
            if self.jdc:
                self.cata = self.jdc.cata
            else:
                self.cata = None
            self.niveau = self.parent.niveau
            self.etape = self.parent.etape
        else:
            # Le mot cle simple a été créé sans parent
            # est-ce possible ?
            print("P_MCSIMP dans le else sans parent du build")
            self.jdc = None
            self.cata = None
            self.niveau = None
            self.etape = None
        if self.definition.creeDesObjets:
            if issubclass(self.definition.creeDesObjetsDeType, UserASSDMultiple):
                self.convProto = ConversionFactory(
                    "UserASSDMultiple", self.definition.creeDesObjetsDeType
                )
            else:
                self.convProto = ConversionFactory(
                    "UserASSD", self.definition.creeDesObjetsDeType
                )
        else:
            self.convProto = ConversionFactory("type", typ=self.definition.type)
        self.valeur = self.getValeurEffective(self.val)
        if self.definition.utiliseUneReference:
            if self.valeur != None:
                if not type(self.valeur) in (list, tuple):
                    self.valeur.ajoutUtilisePar(self)
                else:
                    # PNPN --> chgt pour Vimmp
                    for v in self.valeur:
                        # print (v, type(v))
                        v.ajoutUtilisePar(self)
                        # try : v.ajoutUtilisePar(self)
                        # except : print ('il y a un souci ici', self.nom, self.valeur)
        self.buildObjPyxb()
        self.listeNomsObjsCrees = []

    def getValeurEffective(self, val):
        """
        Retourne la valeur effective du mot-clé en fonction
        de la valeur donnée. Defaut si val == None
        Attention aux UserASSD et aux into (exple Wall gp de maille et 'Wall')
        """
        # print ('getValeurEffective ________________', val)
        if val is None and hasattr(self.definition, "defaut"):
            val = self.definition.defaut
        if self.definition.type[0] == "TXM" and isinstance(val, str):
            return val
        if self.definition.creeDesObjets:
            # isinstance(val, self.definition.creeDesObjetsDeType) ne fonctionne pas car il y a un avec cata devant et l autre non
            if val == None:
                return val
            if not isinstance(val, (list, tuple)):
                valATraiter = [
                    val,
                ]
            else:
                valATraiter = val
            listeRetour = []
            for v in valATraiter:
                # print (v.__class__.__name__, self.definition.creeDesObjetsDeType.__name__)
                if not (
                    v.__class__.__name__ == self.definition.creeDesObjetsDeType.__name__
                ):
                    if self.jdc != None and v in list(self.jdc.sdsDict.keys()):
                        v = self.jdc.sdsDict[v]
                    else:
                        v = self.convProto.convert(v)
                    if v.parent == None:
                        v.initialiseParent(self)
                    if issubclass(
                        self.definition.creeDesObjetsDeType, UserASSDMultiple
                    ):
                        v.ajouteUnPere(self)
                else:
                    if v.nom == "sansNom":
                        for leNom, laVariable in self.jdc.g_context.items():
                            # print (leNom,laVariable)
                            if id(laVariable) == id(v) and (leNom != "sansNom"):
                                v.initialiseNom(leNom)
                    if v.parent == None:
                        v.initialiseParent(self)
                    if issubclass(
                        self.definition.creeDesObjetsDeType, UserASSDMultiple
                    ):
                        v.ajouteUnPere(self)
                listeRetour.append(v)
            if isinstance(val, (list, tuple)):
                newVal = listeRetour
            else:
                newVal = listeRetour[0]
            return newVal
        if self.convProto:
            val = self.convProto.convert(val)
        return val

    def creeUserASSDetSetValeur(self, val):
        self.state = "changed"
        nomVal = val
        if nomVal in self.jdc.sdsDict.keys():
            if isinstance(
                self.jdc.sdsDict[nomVal], self.definition.creeDesObjetsDeType
            ):
                if issubclass(self.definition.creeDesObjetsDeType, UserASSDMultiple):
                    p = self.parent
                    while p in self.parent:
                        if hasattr(p, "listeDesReferencesCrees"):
                            p.listeDesReferencesCrees.append(self.jdc.sdsDict[nomVal])
                        else:
                            p.listeDesReferencesCrees = [
                                self.jdc.sdsDict[nomVal],
                            ]
                        p = p.parent
                        self.jdc.sdsDict[nomVal].ajouteUnPere(self)
                        # return (1, 'reference ajoutee')
                else:
                    return (0, "concept non multiple deja reference")
            else:
                return (0, "concept d un autre type existe deja")
        if self.convProto:
            objVal = self.convProto.convert(nomVal)
            objVal.initialiseNom(nomVal)
            if objVal.parent == None:
                objVal.initialiseParent(self)
            objVal.ajouteUnPere(self)
            p = self.parent
            while p in self.parent:
                # print ('mise a jour de ',p)
                if hasattr(p, "listeDesReferencesCrees"):
                    p.listeDesReferencesCrees.append(objVal)
                else:
                    p.listeDesReferencesCrees = [
                        objVal,
                    ]
                p = p.parent
        return (self.setValeur(objVal), "reference creee")

    def creeUserASSD(self, val):
        self.state = "changed"
        nomVal = val
        if nomVal in self.jdc.sdsDict.keys():
            if isinstance(
                self.jdc.sdsDict[nomVal], self.definition.creeDesObjetsDeType
            ):
                if issubclass(self.definition.creeDesObjetsDeType, UserASSDMultiple):
                    p = self.parent
                    while p in self.parent:
                        if hasattr(p, "listeDesReferencesCrees"):
                            p.listeDesReferencesCrees.append(self.jdc.sdsDict[nomVal])
                        else:
                            p.listeDesReferencesCrees = [
                                self.jdc.sdsDict[nomVal],
                            ]
                        p = p.parent
                        self.jdc.sdsDict[nomVal].ajouteUnPere(self)
                        return (1, self.jdc.sdsDict[nomVal], "reference ajoutee")
                else:
                    return (0, None, "concept d un autre type existe deja")
            else:
                return (0, None, "concept d un autre type existe deja")
        if self.convProto:
            objVal = self.convProto.convert(nomVal)
            objVal.initialiseNom(nomVal)
            objVal.ajouteUnPere(self)
        return (1, objVal, "reference creee")

    def rattacheUserASSD(self, objASSD):
        if objASSD.parent == None:
            objASSD.initialiseParent(self)
        p = self.parent
        while p in self.parent:
            if hasattr(p, "listeDesReferencesCrees"):
                p.listeDesReferencesCrees.append(objASSD)
            else:
                p.listeDesReferencesCrees = [
                    objASSD,
                ]
            p = p.parent

    def getValeur(self):
        """
        Retourne la "valeur" d'un mot-clé simple.
        Cette valeur est utilisée lors de la création d'un contexte
        d'évaluation d'expressions à l'aide d'un interpréteur Python
        """
        v = self.valeur
        # Si singleton et max=1, on retourne la valeur.
        # Si une valeur simple et max='**', on retourne un singleton.
        # (si liste de longueur > 1 et max=1, on sera arrêté plus tard)
        # Pour accepter les numpy.array, on remplace : "type(v) not in (list, tuple)"
        # par "not has_attr(v, '__iter__')".
        if v is None:
            pass
        elif isSequence(v) and len(v) == 1 and self.definition.max == 1:
            v = v[0]
        elif not isSequence(v) and self.definition.max != 1:
            v = (v,)
        # traitement particulier pour les complexes ('RI', r, i)
        if (
            "C" in self.definition.type
            and self.definition.max != 1
            and v != None
            and v[0] in ("RI", "MP")
        ):
            v = (v,)
        return v

    def getVal(self):
        """
        Une autre méthode qui retourne une "autre" valeur du mot clé simple.
        Elle est utilisée par la méthode getMocle
        """
        return self.valeur

    def accept(self, visitor):
        """
        Cette methode permet de parcourir l'arborescence des objets
        en utilisant le pattern VISITEUR
        """
        visitor.visitMCSIMP(self)

    def copy(self):
        """Retourne une copie de self"""
        objet = self.makeobjet()
        # il faut copier les listes et les tuples mais pas les autres valeurs
        # possibles (réel,SD,...)
        if type(self.valeur) in (list, tuple):
            objet.valeur = copy(self.valeur)
        else:
            objet.valeur = self.valeur
        objet.val = objet.valeur
        return objet

    def makeobjet(self):
        return self.definition(val=None, nom=self.nom, parent=self.parent)

    def reparent(self, parent):
        """
        Cette methode sert a reinitialiser la parente de l'objet
        """
        self.parent = parent
        self.jdc = parent.jdc
        self.etape = parent.etape

    def getSd_utilisees(self):
        """
        Retourne une liste qui contient la ou les SD utilisée par self si c'est le cas
        ou alors une liste vide
        """
        l = []
        if isinstance(self.valeur, ASSD):
            l.append(self.valeur)
        elif type(self.valeur) in (list, tuple):
            for val in self.valeur:
                if isinstance(val, ASSD):
                    l.append(val)
        return l

    def getSdMCSUtilisees(self):
        """
        Retourne la ou les SD utilisée par self sous forme d'un dictionnaire :
          - Si aucune sd n'est utilisée, le dictionnaire est vide.
          - Sinon, la clé du dictionnaire est le mot-clé simple ; la valeur est
            la liste des sd attenante.

            Exemple ::
                    { 'VALE_F': [ <Cata.cata.fonction_sdaster instance at 0x9419854>,
                                  <Cata.cata.fonction_sdaster instance at 0x941a204> ] }
        """
        l = self.getSd_utilisees()
        dico = {}
        if len(l) > 0:
            dico[self.nom] = l
        return dico

    def getMcsWithCo(self, co):
        """
        Cette methode retourne l'objet MCSIMP self s'il a le concept co
        comme valeur.
        """
        if co in forceList(self.valeur):
            return [
                self,
            ]
        return []

    def getAllCo(self):
        """
        Cette methode retourne la liste de tous les concepts co
        associés au mot cle simple
        """
        return [
            co for co in forceList(self.valeur) if isinstance(co, CO) and co.isTypCO()
        ]

    def supprime(self):
        if not type(self.valeur) in (list, tuple):
            lesValeurs = (self.valeur,)
        else:
            lesValeurs = self.valeur
        if self.valeur == None or self.valeur == []:
            lesValeurs = []
        for val in lesValeurs:
            if self.definition.creeDesObjets:
                val.deleteReference(self)
            else:
                if hasattr(val, "enleveUtilisePar"):
                    val.enleveUtilisePar(self)
        P_OBJECT.OBJECT.supprime(self)

    def getUserAssdPossible(self):
        debug = False
        if self.nom == "ApplyOn":
            debug = True
        if debug:
            print("____________", self, self.nom)
        classeAChercher = self.definition.type
        if debug:
            print("____________", classeAChercher)
        l = []
        dicoValeurs = {}
        d = {}
        if debug:
            print("____________", self.definition.filtreVariables)
        if self.definition.filtreVariables != None:
            for nomMC, Xpath in self.definition.filtreVariables:
                if debug:
                    print(nomMC, Xpath)
                if Xpath == None:
                    dicoValeurs[nomMC] = getattr(self, nomMC)
                else:
                    try:  # if 1 :
                        pereMC = eval(Xpath)
                        if debug:
                            print("pereMC :", pereMC)
                        if pereMC:
                            exp = Xpath + '.getChild("' + nomMC + '")'
                            leMotCle = eval(exp)
                        else:
                            leMotCle = None
                        if debug:
                            print("leMotCle", leMotCle)
                        if leMotCle:
                            if leMotCle.val:
                                dicoValeurs[nomMC] = leMotCle.val
                            elif leMotCle.definition.max != 1:
                                dicoValeurs[nomMC] = []
                            else:
                                dicoValeurs[nomMC] = None
                            if debug:
                                print("dicoValeurs", dicoValeurs)
                        else:
                            # PN PN est-ce sur ? sinon quoi None ou []
                            # je pense que les 2 valeurs doivent être renseignees si le filtre depend de 2 valeurs
                            return l
                    except:
                        return l

        for k, v in self.parent.jdc.sdsDict.items():
            if isinstance(v, classeAChercher):
                if debug:
                    print("je traite", v)
                if self.definition.filtreExpression:
                    if debug:
                        print("expression", self.definition.filtreExpression)
                    if debug:
                        print(
                            v.executeExpression(
                                self.definition.filtreExpression, dicoValeurs
                            )
                        )
                    try:
                        if v.executeExpression(
                            self.definition.filtreExpression, dicoValeurs
                        ):
                            l.append(v)
                    except:
                        print("il faut comprendre except pour", self.nom)
                        # print (self.nom)
                        # print (self.parent.nom)
                        # print (k,v)
                else:
                    l.append(v)
        return l
