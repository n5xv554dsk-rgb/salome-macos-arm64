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
# Modules Python
import types, os

from copy import copy, deepcopy
import traceback
try :    from InterfaceGUI.QT5 import typeNode
except : from InterfaceGUI.QT6 import typeNode

# Modules Eficas
from InterfaceGUI.Common import objecttreeitem
from Accas import SalomeEntry

class SIMPTreeItemCommun(objecttreeitem.AtomicObjectTreeItem):
    def init(self):
        self.expandable = 0

    # -----------------------------------------------
    #
    # Methodes liees aux informations sur le Panel
    # ou au mot-clef simple
    #
    # -----------------------------------------------
    # isList
    # hasInto
    # getMinMax
    # getMultiplicite
    # getIntervalle
    # getListeValeurs
    # getListePossible

    def isList(self):
        """
        Cette methode indique si le mot cle simple attend une liste (valeur de retour 1)
        ou s'il n'en attend pas (valeur de retour 0)

        Deux cas principaux peuvent se presenter : avec validateurs ou bien sans.
        Dans le cas sans validateur, l'information est donnee par l'attribut max
        de la definition du mot cle.
        Dans le cas avec validateur, il faut combiner l'information precedente avec
        celle issue de l'appel de la methode isList sur le validateur.On utilisera
        l'operateur ET pour effectuer cette combinaison (AndVal).
        """
        is_a_list = 0
        min, max = self.getMinMax()
        assert min <= max
        if max > 1:
            is_a_list = 1
        # Dans le cas avec validateurs, pour que le mot cle soit considere
        # comme acceptant une liste, il faut que max soit superieur a 1
        # ET que la methode isList du validateur retourne 1. Dans les autres cas
        # on retournera 0 (n'attend pas de liste)
        if self.definition.validators:
            is_a_list = self.definition.validators.isList() * is_a_list
        return is_a_list

    def isListSansOrdreNiDoublon(self):
        if self.definition.homo=="SansOrdreNiDoublon" : return 1
        return 0

    def hasInto(self):
        """
        Cette methode indique si le mot cle simple propose un choix (valeur de retour 1)
        ou s'il n'en propose pas (valeur de retour 0)

        Deux cas principaux peuvent se presenter : avec validateurs ou bien sans.
        Dans le cas sans validateur, l'information est donnee par l'attribut into
        de la definition du mot cle.
        Dans le cas avec validateurs, pour que le mot cle soit considere
        comme proposant un choix, il faut que into soit present OU
        que la methode hasInto du validateur retourne 1. Dans les autres cas
        on retournera 0 (ne propose pas de choix)
        """
        has_an_into = 0
        if self.definition.into:
            has_an_into = 1
        elif self.definition.validators:
            has_an_into = self.definition.validators.hasInto()
        return has_an_into

    def hasIntoSug(self):
        if self.definition.intoSug: return 1
        return 0

    def getMinMax(self):
        """Retourne les valeurs min et max de la definition de object"""
        return self.object.getMinMax()

    def getMultiplicite(self):
        """A preciser.
        Retourne la multiplicite des valeurs affectees a l'objet
        represente par l'item. Pour le moment retourne invariablement 1.
        """
        return 1

    def getIntervalle(self):
        """
        Retourne le domaine de valeur attendu par l'objet represente
        par l'item.
        """
        return self.object.getintervalle()

    def getListeValeurs(self):
        """Retourne la liste des valeurs de object"""
        valeurs = self.object.getListeValeurs()
        try:
            if "R" in self.object.definition.type:
                clef = self.object.getNomConcept()
                if clef in self.appliEficas.dict_reels:
                    if type(valeurs) == tuple:
                        valeurs_reelles = []
                        for val in valeurs:
                            if val in self.appliEficas.dict_reels[clef]:
                                valeurs_reelles.append(self.appliEficas.dict_reels[clef][val])
                            else:
                                valeurs_reelles.append(val)
                    else:
                        if valeurs in self.appliEficas.dict_reels[clef]:
                            valeurs_reelles = self.appliEficas.dict_reels[clef][valeurs]
                    valeurs = valeurs_reelles
        except:
            pass
        return valeurs

    def getListePossible(self, listeActuelle=[]):
        if hasattr(self.definition.validators, "into"):
            valeurspossibles = self.definition.validators.into
        else:
            valeurspossibles = self.get_definition().into

        if listeActuelle==[] : return valeurspossibles

        # On ne garde que les items valides
        listevalideitem = []
        if type(valeurspossibles) in (list, tuple):
            pass
        else:
            valeurspossibles = (valeurspossibles,)
        for item in valeurspossibles:
            encorevalide = self.valideItem(item)
            if encorevalide:
                listevalideitem.append(item)

        # on ne garde que les choix possibles qui passent le test de valideListePartielle
        listevalideliste = []
        for item in listevalideitem:
            encorevalide = self.valideListePartielle(item, listeActuelle)
            if encorevalide:
                listevalideliste.append(item)
        # print listevalideliste
        return listevalideliste

    def getListePossibleAvecSug(self, listeActuelle=[]):
        if hasattr(self.definition,'intoSug'):
            valeurspossibles = self.definition.intoSug
        else:
            return listeActuelle

        if listeActuelle==[] :  return valeurspossibles
        valeurspossibles = valeurspossibles + listeActuelle

        # On ne garde que les items valides
        listevalideitem = []
        if type(valeurspossibles) in (list, tuple):
            pass
        else:
            valeurspossibles = (valeurspossibles,)
        for item in valeurspossibles:
            encorevalide = self.valideItem(item)
            if encorevalide:
                listevalideitem.append(item)

        # on ne garde que les choix possibles qui passent le test de valideListePartielle
        listevalideliste = []
        for item in listevalideitem:
            encorevalide = self.valideListePartielle(item, listeActuelle)
            if encorevalide:
                listevalideliste.append(item)
        return listevalideliste

    def getListeParamPossible(self):
        liste_param = []
        l1, l2 = self.jdc.getParametresFonctionsAvantEtape(self.getEtape())
        for param in self.object.jdc.params:
            if param.nom not in l1:
                continue
            encorevalide = self.valideItem(param.valeur)
            if encorevalide:
                type_param = param.valeur.__class__.__name__
                for typ in self.definition.type:
                    if typ == "R":
                        liste_param.append(param)
                    if typ == "I" and type_param == "int":
                        liste_param.append(param)
                    if typ == "TXM" and type_param == "str":
                        liste_param.append(repr(param))
                    if ("grma" in repr(typ)) and type_param == "str":
                        liste_param.append(param.nom)
        return liste_param

    # --------------------------------------------------
    #
    # Methodes liees a la validite des valeurs saisies
    #
    # ---------------------------------------------------
    # valideItem
    # valideListePartielle
    # valideListeComplete
    # infoErreurItem
    # infoErreurListe
    # isInIntervalle
    # isValid

    def valideItem(self, item):
        """
        La validation est realisee directement par l'objet
        """
        return self.object.valideItem(item)

    def valideListePartielle(self, item, listecourante):
        # On protege la liste en entree en la copiant
        valeur = list(listecourante)
        if item : valeur.append(item)
        return self.object.validValeurPartielle(valeur)

    def valideListeComplete(self, valeur):
        return self.object.validValeur(valeur)

    def infoErreurItem(self):
        commentaire = ""
        if self.definition.validators:
            commentaire = self.definition.validators.infoErreurItem()
        return commentaire

    def aide(self):
        commentaire = ""
        if self.definition.validators:
            commentaire = self.definition.validators.aide()
        return commentaire

    def infoErreurListe(self):
        commentaire = ""
        if self.definition.validators:
            commentaire = self.definition.validators.infoErreurListe()
        return commentaire

    def isInIntervalle(self, valeur):
        """
        Retourne 1 si la valeur est dans l'intervalle permis par
        l'objet represente par l'item.
        """
        return self.valideItem(valeur)

    def isValid(self):
        valide = self.object.isValid()
        return valide

    # --------------------------------------------------
    #
    # Autres ...
    #
    # ---------------------------------------------------
    # getIconName
    # getText
    # setValeurCo
    # getSdAvantDuBonType

    def getIconName(self):
        if self.appliEficas.maConfiguration.differencieSiDefaut and self.isValid():
            if self.object.definition.defaut != None:
                if self.object.valeur == self.object.definition.defaut : return "ast-green-dark-ball"
                if self.object.definition.max > 1 and list(self.object.valeur) == list(self.object.definition.defaut) : return "ast-green-dark-ball"
            return "ast-green-ball"
        elif self.isValid():
            return "ast-green-ball"
        elif self.object.isOblig():
            return "ast-red-ball"
        else:
            return "ast-yel-ball"

    def getText(self):
        """
        Classe SIMPTreeItem
        Retourne le texte a afficher dans l'arbre representant la valeur de l'objet
        pointe par self
        """
        if (
            self.waitUserAssdMultiple()
            or self.object.waitUserAssd()
            or self.object.waitAssd()
        ):
            return self.object.valeur
            # if self.object.valeur != None : return self.object.valeur.nom
            # else : return ""
        text = self.object.getText()
        if text == None : text=""
        return text

    def setValeurCo(self, nomCo):
        """
        Affecte au MCS pointe par self l'objet de type CO et de nom nom_co
        """
        ret = self.object.setValeurCo(nomCo)
        # print "setValeurCo",ret
        return ret

    def getSdAvantDuBonType(self):
        """
        Retourne la liste des noms des SD presentes avant l'etape qui contient
        le MCS pointe par self et du type requis par ce MCS
        """
        # A changer pour tenir compte des UserASSDMultiple
        # ici on passe par parent pour avoir le bon type
        # if  self.waitUserAssdMultiple() :
        #    l=self.object.parent.getSdCreeParObjetAvecFiltre(self.object)
        #    return l
        if self.waitUserAssdMultiple():
            l = self.object.getUserAssdPossible()
            return l
        a=self.object.etape.parent.getSdAvantDuBonType(self.object.etape,self.object.definition.type)
        if self.waitUserAssd() : l=self.jdc.getSdCreeParObjet(self.object.definition.type)
        else :l=[]
        return a + l

    def getSdAvantDuBonTypePourTypeDeBase(self):
        a=self.object.jdc.getSdAvantDuBonTypePourTypeDe_Base(self.object.etape,"LASSD")
        return a

    def deleteValeurCo(self, valeur=None):
        """
        Supprime la valeur du mot cle (de type CO)
        il faut propager la destruction aux autres etapes
        """
        if not valeur : valeur=self.object.valeur
        # XXX faut il vraiment appeler delSdprod ???
        # self.object.etape.parent.delSdprod(valeur)
        self.object.etape.parent.deleteConcept(valeur)

    # -----------------------------------------------
    #
    # Methodes liees au type de l objet attendu
    #
    # -----------------------------------------------
    # waitCo
    # waitGeom
    # waitComplex
    # waitReel
    # waitAssd
    # getType

    def waitCo(self):
        """
        Methode booleenne qui retourne 1 si l'objet pointe par self
        attend un objet de type ASSD qui n'existe pas encore (type CO()),
        0 sinon
        """
        return self.object.waitCo()

    def waitFichier(self):
        maDefinition = self.object.definition
        try:
            if ("Repertoire" in maDefinition.type[0]) or (
                "Fichier" in maDefinition.type[0]
            ):
                return 1
        except:
            return 0

    def waitGeom(self):
        """
        Methode booleenne qui retourne 1 si l'objet pointe par self
        attend un objet GEOM, 0 sinon
        """
        return self.object.waitGeom()

    def waitTxm(self):
        return self.object.waitTxm()

    def waitComplex(self):
        """Methode booleenne qui retourne 1 si l'objet pointe par self
        attend un complexe, 0 sinon"""
        if "C" in self.object.definition.type:
            return 1
        else:
            return 0

    def waitReel(self):
        """Methode booleenne qui retourne 1 si l'objet pointe par self
        attend un reel, 0 sinon"""
        if "R" in self.object.definition.type:
            return 1
        else:
            return 0

    def waitTuple(self):
        return self.object.waitTuple()

    def waitDate(self):
        """Methode booleenne qui retourne 1 si l'objet pointe par self
        attend un reel, 0 sinon"""
        if "DateHHMMAAAA" in self.object.definition.type:
            return 1
        else:
            return 0

    def waitHeure(self):
        """Methode booleenne qui retourne 1 si l'objet pointe par self
        attend un reel, 0 sinon"""
        if "HeureHHMMSS" in self.object.definition.type:
            return 1
        else:
            return 0

    def waitTuple(self):
        """Methode booleenne qui retourne 1 si l'objet pointe par self
        attend un Tuple, 0 sinon"""
        for ss_type in self.object.definition.type:
            if repr(ss_type).find("Tuple") != -1:
                return 1
        return 0

    def waitMatrice(self):
        """Methode booleenne qui retourne 1 si l'objet pointe par self
        attend un Tuple, 0 sinon"""
        # il faut trouver autre chose que ce find!!!
        for ss_type in self.object.definition.type:
            # if repr(ss_type).find('Matrice') != -1 :
            if hasattr(ss_type, "typElt"):
                return 1
        return 0

    def waitAssd(self):
        """Methode booleenne qui retourne 1 si l'objet pointe par self
        attend un objet de type ASSD ou derive, 0 sinon"""
        return self.object.waitAssd()

    def waitAssdOrTypeBase(self):
        boo = 0
        if len(self.object.definition.type) > 1:
            if self.waitReel():
                boo = 1
            if "I" in self.object.definition.type:
                boo = 1
        return boo

    def waitSalome(self):
        monType = self.object.definition.type[0]
        if 'grma' in repr(monType) : return True
        if 'grno' in repr(monType) : return True
        try:
            if issubclass(monType, SalomeEntry) : return True
        except:
            pass
        return False

    def getType(self):
        """
        Retourne le type de valeur attendu par l'objet represente par l'item.
        """
        return self.object.getType()

    # -----------------------------------------------------
    #
    # Methodes liees  a l evaluation de la valeur saisie
    #
    # -----------------------------------------------------
    # evalValeur
    # evalValeurItem
    # isCO
    # traiteReel

    def evalValeur(self, valeur):
        """Lance l'interpretation de 'valeur' (chaine de caracteres) comme valeur de self :
        - retourne l'objet associe si on a pu interpreter (entier, reel, ASSD,...)
        - retourne 'valeur' (chaine de caracteres) sinon
        """
        newvaleur = self.evalVal(valeur)
        return newvaleur, 1

    def evalValeurItem(self, valeur):
        """Lance l'interpretation de 'valeur' qui doit ne pas etre un tuple
        - va retourner la valeur de retour et la validite
          selon le type de l objet attendu
        - traite les reels et les parametres
        """
        # print "evalValeurItem",valeur
        if valeur == None or valeur == "":
            return None, 0
        validite = 1
        if self.waitReel():
            valeurinter = self.traiteReel(valeur)
            if valeurinter != None:
                valeurretour, validite = self.object.evalValeur(valeurinter)
            else:
                valeurretour, validite = self.object.evalValeur(valeur)
        elif self.waitGeom():
            valeurretour, validite = valeur, 1
        else:
            valeurretour, validite = self.object.evalValeur(valeur)

        if validite == 0:
            if (type(valeur) == bytes or type(valeur) == str) and self.object.waitTxm():
                essai_valeur = "'" + valeur + "'"
                valeurretour, validite = self.object.evalValeur(essai_valeur)

        if hasattr(valeurretour, "__class__"):
            # if valeurretour.__class__.__name__ in ('PARAMETRE','PARAMETRE_EVAL'):
            if valeurretour.__class__.__name__ in ("PARAMETRE",):
                validite = 1

        # if self.waitCo():
        # CCAR : il ne faut pas essayer de creer un concept
        # il faut simplement en chercher un existant ce qui a du etre fait par self.object.evalValeur(valeur)
        # try:
        # valeurretour=Accas.CO(valeur)
        # except:
        # valeurretour=None
        # validite=0
        # on est dans le cas ou on a evalue et ou on n'aurait pas du
        if self.object.waitTxm():
            if type(valeurretour) != bytes:
                valeurretour = str(valeur)
                validite = 1
        return valeurretour, validite

    def isCO(self, valeur=None):
        """
        Indique si valeur est un concept produit de la macro
        Cette methode n'a de sens que pour un MCSIMP d'une MACRO
        Si valeur vaut None on teste la valeur du mot cle
        """
        # Pour savoir si un concept est un nouveau concept de macro
        # on regarde s'il est present dans l'attribut sdprods de l'etape
        # ou si son nom de classe est CO.
        # Il faut faire les 2 tests car une macro non valide peut etre
        # dans un etat pas tres catholique avec des CO pas encore types
        # et donc pas dans sdprods (resultat d'une exception dans typeSDProd)
        if not valeur:
            valeur = self.object.valeur
        if valeur in self.object.etape.sdprods:
            return 1
        # if type(valeur) is not types.InstanceType:return 0
        if type(valeur) is not object:
            return 0
        if valeur.__class__.__name__ == "CO":
            return 1
        return 0

    def isParam(self, valeur):
        for param in self.jdc.params:
            if repr(param) == valeur:
                return 1
        return 0

    def traiteReel(self, valeur):
        """
        Cette fonction a pour but de rajouter le '.' en fin de chaine pour un reel
        ou de detecter si on fait reference a un concept produit
        ou un EVAL ...
        """
        valeur = valeur.strip()
        liste_reels = self.getSdAvantDuBonType()
        if valeur in liste_reels:
            return valeur
        if len(valeur) >= 3:
            if valeur[0:4] == "EVAL":
                # on a trouve un EVAL --> on retourne directement la valeur
                return valeur
        if valeur.find(".") == -1:
            # aucun '.' n'a ete trouve dans valeur --> on en rajoute un a la fin
            if self.isParam(valeur):
                return valeur
            else:
                if valeur.find("e") != -1:
                    # Notation scientifique ?
                    try:
                        r = eval(valeur)
                        return valeur
                    except:
                        return None
                else:
                    return valeur + "."
        else:
            return valeur

