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


""" Ce module contient la classe de definition SIMP
    qui permet de spécifier les caractéristiques des mots clés simples
"""


import types

import Accas
from Accas.processing import P_ENTITE
from Accas.processing import P_MCSIMP

dictPourSql = {
    "I": "BIGINT",
    "R": "FLOAT8",
    "BOOL": "BOOL",
    "TXM": "TEXT",
    "date": "DATE",
}


class SIMP(P_ENTITE.ENTITE):

    """
    Classe pour definir un mot cle simple

    Cette classe a deux attributs de classe

    - class_instance qui indique la classe qui devra etre utilisée
            pour créer l'objet qui servira à controler la conformité d'un
            mot-clé simple avec sa définition

    - label qui indique la nature de l'objet de définition (ici, SIMP)

    """

    class_instance = P_MCSIMP.MCSIMP
    label = "SIMP"

    def __init__( self, typ, ang="", fr="", statut="f", into=None, intoSug=None, siValide=None,
        defaut=None, min=1, max=1, homo=1, position="local", filtre=None, val_min=float("-inf"),
        val_max=float("inf"), docu="", validators=None,  sug=None, fenetreIhm=None,
        attribut=False, sortie="n", intoXSD=None, metAJour=None, avecBlancs=False, unite=None,
        typeXSD=None, nomXSD = None, formatGit=None, affichage=None, defautXSD = None ):
        """
        Un mot-clé simple est caractérisé par les attributs suivants :
        - type : cet attribut est obligatoire et indique le type de valeur attendue
        - fr : chaîne documentaire en français
        - ang : chaîne documentaire en anglais
        - statut : obligatoire ou facultatif ou caché ou cache avec defaut (d)
        - into : valeurs autorisées
        - unite : unite de la valeur si valeur physique
        - intoSug : valeurs possibles mais des valeurs autres du bon type peuvent etre entrees par l utilsateur : sug pour suggeree
        - defaut : valeur par défaut
        - min : nombre minimal de valeurs
        - max : nombre maximal de valeurs
        - homo : un certain nb de choses qui il faut redispacher ailleurs (information, constant)
        - position : si global, le mot-clé peut-être lu n'importe où dans la commande, si global_jdc n'importe où dans le jdc
        - val_min : valeur minimale autorisée
        - val_max : valeur maximale autorisée
        - docu : clef sur de la documentation utilisateur
        - sug : valeur suggeree (idem intoSug)
        - fenetreIhm : si widget particulier
        - attribut : si projection XSD sur attribut --> a revoir
        - creeDesObjetsDeType : type des UserASSD si siValide en cree
        - typeXSD  : se projette en XSD avec ce type 
        - nomXSD  : se projette en XSD avec ce nom
        - sortie : force l ecriture dans le fichier de sortie (utile pour Telemac)
        - affichage : Tuple contenant un nom de gridLayout, puis ligne et colonne pour l affichage
        - metAJour : en cas de changement de valeur met à jour 
          exemple dans le catalogue VIMMP       
                   MeshIdentifiers = SIMP(statut ='o', max ='**', typ = meshIdentifier,
                   metAJour=(('ApplyOnGroups', 'self.etape.getChild("BoundaryConditions").getChild("BoundaryCondition")'),),
                   signifie que si on change la valeur des MeshIdentifiers, il faut changer le into des BoundaryConditions.BoundaryCondition
        - filtre : permet de restreindre les
          exemple dans le catalogue VIMMP
                   ApplyOnStateVariable =  SIMP (statut ='o', typ=stateVariable, max='**', homo='SansOrdreNiDoublon',
                   filtre=( 'etape in set(self.getEtapes()) ', (('etape', None),), ), # ne faut  propose pas les variables d'état des autres composants
        - sortie : pour Telemac, rend la sortie obligatoire meme si la valeur du mot-clef est la valeur par defaut
        - avecBlancs : accepte les chaines de caracteres contenant un blanc : utile pour la projection XSD
        """
        # print (self)
        # import traceback
        # traceback.print_stack()
        # print (self)
        P_ENTITE.ENTITE.__init__(self, validators)
        # Initialisation des attributs
        self.creeDesObjets = False
        self.utiliseUneReference = False
        self.creeDesObjetsDeType = None
        self.utiliseDesObjetsDeType = None
        if type(typ) == tuple:
            self.type = typ
        else:
            self.type = (typ,)
        for t in self.type:
            try:
                if issubclass(t, Accas.UserASSDMultiple):
                    creeDesObjetsDeType = t
                    self.utiliseUneReference = True
                elif issubclass(t, Accas.UserASSD):
                    creeDesObjetsDeType = t
                    self.utiliseUneReference = True
            except:
                pass
            if t == "createObject":
                self.creeDesObjets = True
        if self.utiliseUneReference:
            if self.creeDesObjets:
                self.utiliseUneReference = False
                self.creeDesObjetsDeType = creeDesObjetsDeType
            else:
                self.utiliseDesObjetsDeType = creeDesObjetsDeType
        self.fr = fr
        self.statut = statut
        self.into = into
        self.intoSug = intoSug
        self.siValide = siValide
        self.defaut = defaut
        self.min = min
        self.max = max
        self.homo = homo
        self.position = position
        self.val_min = val_min
        self.val_max = val_max
        self.docu = docu
        self.sug = sug
        self.ang = ang
        if self.max == "**":
            self.max = float("inf")
        if self.val_max == "**":
            self.val_max = float("inf")
        if self.min == "**":
            self.min = float("-inf")
        if self.val_min == "**":
            self.val_min = float("-inf")
        self.fenetreIhm = fenetreIhm
        self.attribut = attribut
        self.typeXSD = typeXSD
        self.defautXSD = defautXSD
        self.intoXSD = intoXSD
        self.sortie = sortie
        self.filtre = filtre
        self.avecBlancs = avecBlancs
        self.unite = unite
        self.formatGit = formatGit
        self.affichage = affichage
        if typeXSD:
            self.typeXSD = typeXSD
        if (
            not (self.avecBlancs)
            and self.max > 1
            and "TXM" in self.type
            and self.into != None
        ):
            for val in self.into:
                if val.find(" ") > -1:
                    self.avecBlancs = True
                    break
        if (
            not (self.avecBlancs)
            and self.max > 1
            and "TXM" in self.type
            and self.intoXSD != None
        ):
            for val in self.intoXSD:
                if val.find(" ") > -1:
                    self.avecBlancs = True
                    break
        if self.avecBlancs and not ("TXM" in self.type):
            print("definition incoherente avecBlanc et non texte pour ", self)
            exit()
        if self.filtre:
            self.filtreExpression = self.filtre[0]
            self.filtreVariables = self.filtre[1]
        else:
            self.filtreExpression = []
            self.filtreVariables = []
        self.metAJour = metAJour

    def changeInto(self, listeDesIntos, jdc):
        self.into = listeDesIntos
        jdc.revalide(self)

    def addInto(self, nvlInto):
    # fonctionne car cette fonction est appelee dans le catalaogue
    # et non pas depuis un appel declenché par le chgt
    # dans un jdc
        if self.into == None:
            self.into = []
        if nvlInto in self.into:
            return
        self.into.append(nvlInto)

    def changeStatut(self, nvlStatut):
        self.statut = nvlStatut

    def changeSiValide(self, nvlFonction):
        self.siValide = nvlFonction

    def verifCata(self):
        """
        Cette methode sert à valider les attributs de l'objet de définition
        de la classe SIMP
        """
        self.checkMinMax()
        self.checkFr()
        self.checkStatut()
        self.checkHomo()
        self.checkInto()
        self.checkPosition()
        self.checkValidators()

    def dumpDBSchema(self, inBloc):
        if self.type[0] in dictPourSql:
            leTypeSql = dictPourSql[self.type[0]]
        else:
            leTypeSql = "texte"
        # est-ce toujours vrai ? est ce que cela ne depend pas un peu des tables
        if self.statut == "o" and not inBloc:
            contraintes = "NOT NULL"
        else:
            contraintes = ""
        if self.val_min != float("-inf"):
            contraintes += " CHECK ({} >= {}) ".format(self.nom, self.val_min)
        if self.val_max != float("inf"):
            contraintes += " CHECK ({} >= {}) ".format(self.nom, self.val_max)
        texte = "\t{}  {} {} ,\n".format(self.nom, leTypeSql, contraintes)
        return texte

    def __call__(self, val, nom, parent=None, objPyxbDeConstruction=None):
        """
        Construit un objet mot cle simple (MCSIMP) a partir de sa definition (self)
        de sa valeur (val), de son nom (nom) et de son parent dans l arboresence (parent)
        """
        return self.class_instance(
            nom=nom,
            definition=self,
            val=val,
            parent=parent,
            objPyxbDeConstruction=objPyxbDeConstruction,
        )
