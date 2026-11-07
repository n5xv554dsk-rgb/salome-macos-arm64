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
    Ce module contient la classe de definition BLOC
    qui permet de spécifier les caractéristiques des blocs de mots clés
"""


import types
import sys
import traceback

from Accas.processing import P_ENTITE
from Accas.processing import P_MCBLOC
from Accas.processing.P_Exception import AsException
from Accas.processing.P_types import forceList


class BLOC(P_ENTITE.ENTITE):

    """
    Classe pour definir un bloc de mots-cles

    Cette classe a deux attributs de classe :

      - class_instance qui indique la classe qui devra etre utilisée
        pour créer l'objet qui servira à controler la conformité d'un
        bloc de mots-clés avec sa définition
      - label qui indique la nature de l'objet de définition (ici, BLOC)

    """

    class_instance = P_MCBLOC.MCBLOC
    label = "BLOC"

    def __init__( self, fr="", docu="", regles=(), statut="f", condition=None, ang="",  exclusif=False, typeXSD = None, nomXSD= None,  **args):
        """
        Un bloc est caractérisé par les attributs suivants :

          - fr   : chaine de caractere commentaire pour aide en ligne (en francais)
          - regles : liste d'objets de type REGLE pour vérifier la cohérence des sous-objets
          - statut : obligatoire ('o') ou facultatif ('f')
          - condition : chaine de caractère evaluable par l'interpreteur Python
          - exclusif : ne s active pas en meme temps que ses blocs freres
          - entites : dictionnaire contenant les sous-objets de self (mots-clés).
            La clé du dictionnaire est le nom du mot-clé et la valeur l'objet de
            définition correspondant. Cet attribut est initialisé avec l'argument
            args de la méthode __init__
          - typeXSD peut valoir Fusion pour un bloc ou peut etre le meme qu un autre bloc
          - nomXSD 

        """
        # Initialisation des attributs
        self.fr = fr
        self.ang = ang
        self.docu = docu
        self.fenetreIhm = None
        self.exclusif = exclusif
        if type(regles) == tuple:
            self.regles = regles
        else:
            self.regles = (regles,)
        self.statut = statut
        self.condition = condition
        self.typeXSD = typeXSD
        self.nomXSD = nomXSD
        self.entites = args
        self.affecter_parente()
        self.txtNomComplet = ""
        self.possedeDejaUnMCFactorise = False

    def __call__(self, val, nom, parent=None, dicoPyxbDeConstruction=None):
        """
        Construit un objet MCBLOC a partir de sa definition (self)
        de sa valeur (val), de son nom (nom) et de son parent dans l arboresence (parent)
        """
        return self.class_instance(
            nom=nom,
            definition=self,
            val=val,
            parent=parent,
            dicoPyxbDeConstruction=dicoPyxbDeConstruction,
        )

    def verifCata(self):
        """
        Cette méthode vérifie si les attributs de définition sont valides.
        Les éventuels messages d'erreur sont écrits dans l'objet compte-rendu (self.cr).
        """
        self.checkFr()
        self.checkDocu()
        self.checkRegles()
        self.checkStatut(into=("f", "o"))
        self.checkCondition()
        self.verifCataRegles()

    def verifPresence(self, dict, globs):
        """
        Cette méthode vérifie si le dictionnaire passé en argument (dict)
        est susceptible de contenir un bloc de mots-clés conforme à la
        définition qu'il porte.
        Si la réponse est oui, la méthode retourne 1
        Si la réponse est non, la méthode retourne 0

        Le dictionnaire dict a pour clés les noms des mots-clés et pour valeurs
        les valeurs des mots-clés
        """
        # On recopie le dictionnaire pour protéger l'original
        dico = blocUtils()
        dico.update(dict)
        if self.condition != None:
            try:
                # if 1 :
                test = eval(self.condition, globs, dico)
                return test
            # try:
            #   1
            except NameError:
                # erreur 'normale' : un mot-clé n'est pas présent et on veut
                # l'évaluer dans la condition
                if CONTEXT.debug:
                    l = traceback.format_exception(
                        sys.exc_info()[0], sys.exc_info()[1], sys.exc_info()[2]
                    )
                    print(
                        (
                            "WARNING : Erreur a l'evaluation de la condition "
                            + "".join(l)
                        )
                    )
                return 0
            except SyntaxError:
                # le texte de la condition n'est pas du Python correct -->
                # faute de catalogue
                l = traceback.format_exception(
                    sys.exc_info()[0], sys.exc_info()[1], sys.exc_info()[2]
                )
                raise AsException(
                    "Catalogue entite : ",
                    self.nom,
                    ", de pere : ",
                    self.pere.nom,
                    "\n",
                    "Erreur dans la condition : ",
                    self.condition,
                    "".join(l),
                )
            except:
                l = traceback.format_exception(
                    sys.exc_info()[0], sys.exc_info()[1], sys.exc_info()[2]
                )
                raise AsException(
                    "Catalogue entite : ",
                    self.nom,
                    ", de pere : ",
                    self.pere.nom,
                    "\n",
                    "Erreur dans la condition : ",
                    self.condition,
                    "".join(l),
                )
        else:
            return 0

    def longueurDsArbre(self):
        longueur = 0
        for mc in self.mcListe:
            longueur = longueur + mc.longueurDsArbre()
        return longueur

    def dumpDBSchema(self, dPrimaryKey, dForeignKey, dElementsRecursifs, dUnique, dKeys, inBloc):
        debug = False
        if debug: print("****** traitement de BLOC ", self.nom)
        if debug: print( "dElementsRecursifs", dElementsRecursifs,)
        if debug: print( "dPrimaryKey", dPrimaryKey,)
        if debug: print( "dElementsRecursifs,", dElementsRecursifs)
        if debug: print( "dUnique,", dUnique)
        if debug: print( "dKeys,", dKeys)
        texteTable = ""
        texteColonnes = ""
        inBloc = 1
        for mc in self.entites.values():
            if mc.label == "SIMP":
                texteMC = mc.dumpDBSchema(inBloc)
                texteColonnes += texteMC
                if debug : print ('ds le for du Fact : ', texteMC)
            elif mc.label == "FACT" and mc.nom in dElementsRecursifs:
                texteMC += mc.dumpDBSchema(dPrimaryKey, dForeignKey, dElementsRecursifs, dUnique, dKeys, inBloc)
                texteColonnes += texteMC
            else:
                t1, t2 = mc.dumpDBSchema( dPrimaryKey, dForeignKey, dElementsRecursifs, dUnique, dKeys, inBloc)
                texteColonnes += t1
                texteDesFactTables += t2
        if debug : print ('retour du BLOC : ', texteDesFactTables)
        if debug : print ('retour du BLOC : ', texteColonnes)
        if debug : print ('retour du Fact : ', texteDesFactTables)
        return texteColonnes, texteDesFactTables

def blocUtils():
    """Définit un ensemble de fonctions utilisables pour écrire les
    conditions de BLOC."""

    def au_moins_un(mcsimp, valeurs):
        """Valide si la (ou une) valeur de 'mcsimp' est au moins une fois dans
        la ou les 'valeurs'. Similaire à la règle AU_MOINS_UN, 'mcsimp' peut
        contenir plusieurs valeurs."""
        test = set(forceList(mcsimp))
        valeurs = set(forceList(valeurs))
        return not test.isdisjoint(valeurs)

    def aucun(mcsimp, valeurs):
        """Valide si aucune des valeurs de 'mcsimp' n'est dans 'valeurs'."""
        return not au_moins_un(mcsimp, valeurs)

    def getEficasAttribut(nomUserASSD, nomAttr):
        if nomUserASSD == None:
            return None
        return nomUserASSD.getEficasAttribut(nomAttr)

    def getEficasListOfAttributs(nomASSD, listeAttributs):
        if nomASSD == None:
            return ()
        return nomASSD.getEficasListOfAttributs(listeAttributs)

    return locals()
