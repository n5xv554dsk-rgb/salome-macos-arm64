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
from Accas import PARAMETRE
from Accas.extensions.eficas_translation import tr


# ----------------------------
class ValidationSaisie(object):
# ----------------------------
    """
    classe mere des classes de politique de validation des CHAMPS SAISIS 
    les valeurs saisies sont toutes des CHAINES DE CARACTERE
    il faut transformer '5' en 5 ou en 5. selon le type de l objet attendu
    et 'MonNomDObjet' en MonNomDObjet
    mais garder 'voici ma chaine de caractere '...
    """
    def __init__(self, node, parent):
    # -------------------------------
        self.node = node
        self.parent = parent

    def testeUneValeur(self, valeurentree):
    # -------------------------------------
        commentaire = None
        # import traceback
        # traceback.print_stack()
        valeur, validite = self.node.item.evalValeur(valeurentree)
        if not validite:
            commentaire = "impossible d'evaluer : %s " % repr(valeurentree)
            return valeur, validite, commentaire
        if self.node.item.waitTxm() and not (type(valeur) == str):
            valeur = str(valeur)

        testtype, commentaire = self.node.item.object.verifType(valeur)
        if not testtype:
            return valeur, 0, commentaire

        #print (testtype, commentaire)
        valide = self.node.item.valideItem(valeur)
        if type(valide) == tuple:
            validite, commentaire = valide
        else:
            validite = valide
            commentaire = " "

        #print (validite, commentaire)
        if not validite and commentaire is None:
            commentaire = "impossible d'evaluer : %s " % repr(valeurentree)
        #print ('ds testeUneValeur', valeur, validite, commentaire)
        return valeur, validite, commentaire

    # ----------------------------------------------------------------------------------------
    #   Methodes utilisees pour la manipulation des items en notation scientifique
    #   a mettre au point
    # ----------------------------------------------------------------------------------------
    def setValeurTexte(self, texteValeur):
    # ------------------------------------
        try:
            if "R" in self.node.item.object.definition.type:
                if texteValeur[0] != "'":
                    clef = eval(texteValeur)
                    if str(clef) != str(texteValeur):
                        self.node.item.object.initModif()
                        clefobj = self.node.item.object.getNomConcept()
                        if not clefobj in self.parent.appliEficas.dict_reels:
                            self.parent.appliEficas.dict_reels[clefobj] = {}
                        self.parent.appliEficas.dict_reels[clefobj][clef] = texteValeur
                        self.parent.appliEficas.dict_reels[clefobj]
                        if clefobj == "":
                            if ( not self.node.item.object.etape in self.parent.appliEficas.dict_reels):
                                self.parent.appliEficas.dict_reels[ self.node.item.object.etape ] = {}
                            self.parent.appliEficas.dict_reels[ self.node.item.object.etape ][clef] = texteValeur
                        self.node.item.object.finModif()
        except:
            pass

    # --------------------------------
    def getValeurTexte(self, valeur):
    # --------------------------------
        valeurTexte = valeur
        if valeur == None:
            return valeur
        from decimal import Decimal

        if isinstance(valeur, Decimal):
            if self.node.waitTxm() and not self.isParam(valeur):
                return "'" + str(valeur) + "'"
            else:
                return valeur
        if "R" in self.node.item.object.definition.type:
            clefobj = self.node.item.object.getNomConcept()
            if clefobj in self.parent.appliEficas.dict_reels:
                if valeur in self.parent.appliEficas.dict_reels[clefobj]:
                    valeurTexte = self.parent.appliEficas.dict_reels[clefobj][valeur]
            else:
                if ( str(valeur).find(".") == -1 and str(valeur).find("e") == -1 and str(valeur).find("E")):
                # aucun '.' n'a ete trouve dans valeur --> on en rajoute un a la fin
                    if self.isParam(valeur): return valeur
                    
                    #else:
                    #    try:
                    #        val2 = eval(str(valeur) + ".")
                    #    except: pass
        return valeurTexte

    # --------------------------------
    def isParam(self, valeur):
    # --------------------------------
        for param in self.node.item.jdc.params:
            if (repr(param) == repr(valeur)) or (str(param) == str(valeur)):
                return 1
        return 0

    # -------------------------------------
    def ajoutDsDictReel(self, texteValeur):
    # -----------------------------------
        # le try except est necessaire pour saisir les parametres
        # on enleve l erreur de saisie 00 pour 0
        if str(texteValeur) == "00": return
        try:
            if "R" in self.node.item.object.definition.type:
                if str(texteValeur)[0] != "'":
                    clef = eval(texteValeur)
                    if str(clef) != str(texteValeur):
                        clefobj = self.node.item.object.getNomConcept()
                        if not clefobj in self.parent.appliEficas:
                            self.parent.appliEficas.dict_reels[clefobj] = {}
                        self.parent.appliEficas.dict_reels[clefobj][clef] = texteValeur
                        if clefobj == "":
                            if ( not self.node.item.object.etape in self.parent.appliEficas.dict_reels):
                                self.parent.appliEficas.dict_reels[ self.node.item.object.etape ] = {}
                            self.parent.appliEficas.dict_reels[ self.node.item.object.etape ][clef] = texteValeur
        except:
            pass

    # -----------------------------
    def ajoutDsDictReelEtape(self):
    # -----------------------------
        # janvier 24. Utile pour les formules ?
        # a reconsiderer
        # ajout du return
        # a tester correctement
        return
        try:
            if self.node.item.object in self.parent.appliEficas.dict_reels:
                self.parent.appliEficas.dict_reels[ self.node.item.sdnom ] = self.parent.appliEficas.dict_reels[self.node.item.object]
                del self.parent.appliEficas.dict_reels[self.node.item.object]
        except:
            pass


# --------------------------------------
class PolitiqueUnique(ValidationSaisie):
# ---------------------_----------------
    """
    classe servant pour les entrees ne demandant qu un mot clef
    """
    def __init__(self, node, parent):
    #--------------------------------
        super().__init__(node,parent)


    def recordValeur(self, valeurentree):
    #------------------------------------
       # Plus aucun sens avec le mode d acces concurrent
       # if self.parent.modified == "n": self.parent.initModif()
        ancienneVal = self.node.item.getValeur()
        valeur, validite, commentaire = self.testeUneValeur(valeurentree)
        if ( validite and ("R" in self.node.item.object.definition.type) and not (isinstance(valeur, PARAMETRE))):
            s = valeurentree
            if s.find(".") == -1 and s.find("e") == -1 and s.find("E") == -1: s = s + "."
            valeur, validite, commentaire = self.testeUneValeur(s)
        if validite:
            validite = self.node.item.setValeur(valeur)
            if self.node.item.isValid():
                commentaire = tr("Valeur du mot-cle enregistree")
                self.setValeurTexte(str(valeurentree))
            else:
                cr = self.node.item.getCr()
                commentaire = tr("Valeur du mot-cle non autorisee ") + cr.getMessFatal()
                self.node.item.setValeur(ancienneVal)
        #print (validite, commentaire)
        return validite, commentaire


# --------------------------------------
class PolitiquePlusieurs(ValidationSaisie):
# --------------------------------------
    """
    classe servant pour les entrees ne demandant qu un mot clef
    """

    def ajoutValeurs(self, listevaleur, index, listecourante):
    #--------------------------------------------------------
        listeRetour = []
        commentaire = "Nouvelle valeur acceptee"
        commentaire2 = ""
        valide = 1
        if listevaleur == None:
            return
        if listevaleur == "":
            return
        if not (type(listevaleur) in (list, tuple)):
            listevaleur = tuple(listevaleur)
        # on verifie que la cardinalite max n a pas ete atteinte
        min, max = self.node.item.getMinMax()
        if len(listecourante) + len(listevaleur) > max:
            commentaire = (
                "La liste atteint le nombre maximum d'elements : "
                + str(max)
                + " ,ajout refuse"
            )
            return False, commentaire, commentaire2, listeRetour

        for valeur in listevaleur:
            # On teste le type de la valeur
            valeurScientifique = valeur
            valide = self.node.item.valideItem(valeur)
            if not valide:
                try:
                    valeur, valide = self.node.item.evalValeur(valeur)
                    valide, commentaire2 = self.node.item.object.verifType(valeur)
                except:
                    # return testtype,commentaire,"",listeRetour
                    pass
            if not valide:
                if commentaire.find("On attend un chaine") > 1:
                    commentaire = (
                        "Valeur "
                        + str(valeur)
                        + " incorrecte : ajout a la liste refuse: On attend une chaine de caracteres < 8"
                    )
                else:
                    commentaire = (
                        "Valeur "
                        + str(valeur)
                        + " incorrecte : ajout a la liste refuse"
                    )
                if commentaire2 == "":
                    commentaire2 = self.node.item.infoErreurItem()
                return valide, commentaire, commentaire2, listeRetour

            # On valide la liste obtenue
            encorevalide = self.node.item.valideListePartielle(valeur, listecourante)
            if not encorevalide:
                commentaire2 = self.node.item.infoErreurListe()
                # On traite le cas ou la liste n est pas valide pour un pb de cardinalite
                min, max = self.node.item.getMinMax()
                if len(listecourante) + 1 >= max:
                    commentaire = (
                        "La liste atteint le nombre maximum d'elements : "
                        + str(max)
                        + " ,ajout refuse"
                    )
                    return valide, commentaire, commentaire2, listeRetour
                if len(listecourante) + 1 > min:
                    commentaire = ""
                    return valide, commentaire, commentaire2, listeRetour
            # On ajoute la valeur testee a la liste courante et a la liste acceptee
            self.ajoutDsDictReel(valeurScientifique)
            listecourante.insert(index, valeur)
            index = index + 1
            listeRetour.append(valeur)

        return valide, commentaire, commentaire2, listeRetour

    def ajoutTuple(self, valeurTuple, listecourante):
        listeRetour = []
        commentaire = "Nouvelle valeur acceptee"
        commentaire2 = ""
        valide = 1
        if valeurTuple == None:
            return
        if valeurTuple == [""]:
            return
        # On teste le type de la valeur
        valide = self.node.item.valideItem(valeurTuple)
        if not valide:
            try:
                valeur, valide = self.node.item.evalValeur(valeurTuple)
                valide = self.node.item.valideItem(valeur)
            except:
                pass
        if not valide:
            commentaire = (
                "Valeur " + str(valeurTuple) + " incorrecte : ajout a la liste refuse"
            )
            commentaire2 = self.node.item.infoErreurItem()
            return valide, commentaire, commentaire2, listeRetour

        # On valide la liste obtenue
        encorevalide = self.node.item.valideListePartielle(valeurTuple, listecourante)
        if not encorevalide:
            commentaire2 = self.node.item.infoErreurListe()
            return valide, commentaire, commentaire2, listeRetour
        listeRetour.append(valeurTuple)
        return valide, commentaire, commentaire2, listeRetour

    def ajoutNTuple(self, liste):
        commentaire = "Nouvelles valeurs acceptee"
        commentaire2 = ""
        valide = self.node.item.valideListePartielle(None, liste)
        print("uuuuuuuuuuu", valide)
        if not valide:
            commentaire2 = self.node.item.infoErreurListe()
        return valide, commentaire, commentaire2

    def recordValeur(self, liste, dejaValide=True):
        ancienneVal = self.node.item.getValeur()
        validite = self.node.item.setValeur(liste)
        if validite:
            self.node.item.initModif()
        if self.node.item.isValid():
            commentaire = tr("Valeur du mot-cle enregistree")
        else:
            cr = self.node.item.getCr()
            commentaire = tr("Valeur du mot-cle non autorisee ") + cr.getMessFatal()
            self.node.item.setValeur(ancienneVal)
        return validite, commentaire
