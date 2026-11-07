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


""" Ce module contient la classe de definition FACT
    qui permet de spécifier les caractéristiques des mots clés facteurs
"""
import types

from Accas.processing import P_ENTITE
from Accas.processing import P_MCFACT
from Accas.processing import P_MCLIST
from Accas.processing.P__F import _F
from Accas.processing.P_types import isSequence

from Accas.processing import P_OBJECT


class FACT(P_ENTITE.ENTITE):

    """
    Classe pour definir un mot cle facteur

    Cette classe a trois attributs de classe

      - class_instance qui indique la classe qui devra etre utilisée
        pour créer l'objet qui servira à controler la conformité d'un
        mot-clé facteur avec sa définition

      - list_instance

      - label qui indique la nature de l'objet de définition (ici, FACT)
    """

    class_instance = P_MCFACT.MCFACT
    list_instance = P_MCLIST.MCList
    label = "FACT"

    def __init__( self, fr="", docu="", regles=(), statut="f", defaut=None, ang="",
        fenetreIhm=None, min=0, max=1, validators=None,  nomXSD = None,  **args):
        """
        Un mot-clé facteur est caractérisé par les attributs suivants :

          - statut :
          - regles : regles de coherence a l interieur du fact (au_moins 1...)
          - validators : regles de coherence developpees specifiquement
          - min : nb max d occurence
          - max : nb min d occurence
          - docu : lien sur une documentation extene
          - fr   : documentation en francais
          - ang  : documentation en anglais
          - fenetreIhm : fenetre particuliere de présentation
        """
        P_ENTITE.ENTITE.__init__(self, validators)
        # Initialisation des attributs
        self.fr = fr
        self.ang = ang
        self.docu = docu
        if type(regles) == tuple:
            self.regles = regles
        else:
            self.regles = (regles,)
        self.statut = statut
        self.defaut = defaut
        self.min = min
        self.max = max
        if self.max == "**":
            self.max = float("inf")
        if self.min == "**":
            self.min = float("-inf")
        self.entites = args
        self.position = None
        self.affecter_parente()
        self.fenetreIhm = fenetreIhm
        self.nomXSD = nomXSD

    def __call__(self, val, nom, parent, dicoPyxbDeConstruction=None):
        """
        Construit la structure de donnee pour un mot cle facteur a partir
        de sa definition (self) de sa valeur (val), de son nom (nom) et de
        son parent dans l arboresence (parent)

        Suivant le type de la valeur on retournera soit un objet de type
        MCFACT soit une liste de type MCLIST.

        La creation d un mot cle facteur depend de son statut
          - Si statut ='o'   il est obligatoire
          - Si statut == 'd' il est facultatif mais ses sous mots cles avec
            defaut sont visibles
          - Si statut == 'f' il est facultatif et ses sous mots avec defaut ne
            sont pas visibles
          - Si statut == 'c' il est cache ???
          - Si defaut != None, on utilise cette valeur pour calculer la valeur
            par defaut du mot cle facteur
        """
        if val is None:
            if self.defaut == None:
                val = {}
            elif type(self.defaut) == tuple:
                val = self.defaut
                # Est ce utile ? Le défaut pourrait etre uniquement un dict
            elif type(self.defaut) == dict or isinstance(self.defaut, _F):
                val = self.defaut
            else:
                # On ne devrait jamais passer par la
                print("On ne devrait jamais passer par la")
                return None
        elif isSequence(val) and len(val) == 0 and self.statut == "o":
            # On est dans le cas où le mcfact est présent mais est une liste/tuple
            # vide. Il est obligatoire donc on l'initialise. Les règles, mots-clés
            # obligatoires diront si un mcfact vide est accepté.
            val = {}

        # On cree toujours une liste de mcfact
        l = self.list_instance()
        l.init(nom=nom, parent=parent)
        if type(val) in (tuple, list, self.list_instance):
            indice = 0
            for v in val:
                if type(v) == dict or isinstance(v, _F):
                    if dicoPyxbDeConstruction:
                        objet = self.class_instance(
                            nom=nom,
                            definition=self,
                            val=v,
                            parent=parent,
                            dicoPyxbDeConstruction=dicoPyxbDeConstruction[indice],
                        )
                    else:
                        objet = self.class_instance(
                            nom=nom,
                            definition=self,
                            val=v,
                            parent=parent,
                            dicoPyxbDeConstruction=None,
                        )
                    indice = indice + 1
                    l.append(objet)
                elif isinstance(v, self.class_instance):
                    # if faut gerer ici --> on passe la avec une liste de concept ?
                    # PNPN --> si pyxb
                    l.append(v)
                else:
                    l.append(P_OBJECT.ErrorObj(self, v, parent, nom))
        elif type(val) == dict or isinstance(val, _F):
            if dicoPyxbDeConstruction:
                objet = self.class_instance(
                    nom=nom,
                    definition=self,
                    val=val,
                    parent=parent,
                    dicoPyxbDeConstruction=dicoPyxbDeConstruction,
                )
            else:
                objet = self.class_instance(
                    nom=nom,
                    definition=self,
                    val=val,
                    parent=parent,
                    dicoPyxbDeConstruction=None,
                )
            l.append(objet)
        elif isinstance(val, self.class_instance):
            # idem --> quand passe t on la
            l.append(val)
        else:
            l.append(P_OBJECT.ErrorObj(self, val, parent, nom))
        # pour tenir compte du validateFonction
        if l.jdc:
            l.cata = l.jdc.cata
            l.buildObjPyxb(l)
        return l

    def verifCata(self):
        self.checkMinMax()
        self.checkFr()
        self.checkRegles()
        self.checkStatut()
        self.checkDocu()
        self.checkValidators()
        self.verifCataRegles()

    def dumpDBSchema(self, dPrimaryKey, dForeignKey, dElementsRecursifs, dUnique, dKeys, inBloc):
        # on admet que si un FACT a une primaryKey, elle existe dans celui-ci
        # ou que il s agit d un motclef frere/oncle place avant. Elle est dans dictKeys
        debug = False
        #if self.nom == 'time_profile' : debug = True
        if debug: print("****** traitement de FACT ", self.nom)
        if debug: print( "dElementsRecursifs", dElementsRecursifs,)
        if debug: print( "dPrimaryKey", dPrimaryKey,)
        if debug: print( "dElementsRecursifs,", dElementsRecursifs)
        if debug: print( "dUnique,", dUnique)
        if debug: print( "dKeys,", dKeys)
        texteForeignKey = ""
        textePrimaryKey = ""
        texteTable = ""
        texteColonnes = ""
        texteConstraintUnique = ""
        suisUneTable = False
        texteDesFactTables = ""
        if self.nom in dElementsRecursifs: return "\t{} XML ,\n".format(self.nom)
        if self.nom in dPrimaryKey or self.nom in dForeignKey:
            suisUneTable = True
            texteTable = "CREATE TABLE IF NOT EXISTS {} (\n".format(self.nom)
            if debug: print("FACT ", self.nom, " est une table")
            if self.nom in dPrimaryKey:
               if dPrimaryKey[self.nom]  in self.entites.values() :
                  texteTable += "\t{} SERIAL PRIMARY KEY,\n".format(dPrimaryKey[self.nom])
               elif dPrimaryKey[self.nom] in dKeys :
                  texteTable += "\t{} {},\n".format(dPrimaryKey[self.nom], dKeys[dPrimaryKey[self.nom]])
               else :
                  # on estime qu on a alors une SERIAL PRIMARY KEY,
                  texteTable += "\t{} SERIAL PRIMARY KEY,\n".format(dPrimaryKey[self.nom])
                  dKeys[dPrimaryKey[self.nom]] = 'INT NOT NULL'
               if dPrimaryKey[self.nom]  in self.entites.values() :
                  textePrimaryKey += "\tPRIMARY KEY ({}), \n".format( dPrimaryKey[self.nom])
            if self.nom in dForeignKey:
               texteForeignKey = "\tCONSTRAINT fk_{}_{} FOREIGN KEY ({}) REFERENCES {}({}) ON DELETE CASCADE ,\n".format( 
                        self.nom, dForeignKey[self.nom][0],
                        dForeignKey[self.nom][0],
                        dForeignKey[self.nom][2],
                        dForeignKey[self.nom][1],
               )
        for mc in self.entites.values():
            if mc.label == "SIMP":
                texteMC = mc.dumpDBSchema(inBloc)
                if suisUneTable : texteTable += texteMC
                else : texteColonnes += texteMC
                if debug : print ('ds le for du Fact : ', texteMC)
            elif mc.label == "FACT" and mc.nom in dElementsRecursifs:
                texteMC = mc.dumpDBSchema(dPrimaryKey, dForeignKey, dElementsRecursifs, dUnique, dKeys, inBloc)
                if suisUneTable : texteTable += texteMC
                else : texteColonnes += texteMC
            else:
                t1, t2 = mc.dumpDBSchema( dPrimaryKey, dForeignKey, dElementsRecursifs, dUnique, dKeys, inBloc)
                if suisUneTable : texteTable += t1
                else : texteColonnes += t1
                texteDesFactTables += t2
        texteTable += textePrimaryKey
        texteTable += texteForeignKey
        if self.nom in dUnique: texteTable += "\tCONSTRAINT UC_{} UNIQUE {},\n".format(self.nom,str(dUnique[self.nom]).replace ("'",""))
        if self.nom in dPrimaryKey or self.nom in dForeignKey: 
           texteTable = texteTable[0:-2]
           texteTable += "\n);\n"
        if debug : print ('retour du Fact : texteTable', texteTable)
        if debug : print ('retour du Fact : texteDesFactTables ', texteDesFactTables)
        if debug : print ('retour du Fact : texteDesFactTables ', texteColonnes)
        return texteColonnes, texteDesFactTables + texteTable
