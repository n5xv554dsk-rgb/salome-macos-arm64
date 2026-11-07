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
"""
"""
# Modules Python

from builtins import str

# Modules Eficas
from Accas.processing import P_MCCOMPO
from Accas.validation import V_MCCOMPO
from Accas.extensions.eficas_translation import tr


class MCNUPLET(V_MCCOMPO.MCCOMPO, P_MCCOMPO.MCCOMPO):
    """ """

    nature = "MCNUPLET"
    txt_nat = "Nuplet : "

    def __init__(self, val, definition, nom, parent):
        # val contient la valeur initial du nuplet
        self.val = val
        if val == None:
            self.val = ()
        self.definition = definition
        self.nom = nom
        self.parent = parent
        # getValeurEffective affecte la valeur par defaut si necessaire
        self.valeur = self.getValeurEffective(self.val)
        if parent:
            self.jdc = self.parent.jdc
            self.niveau = self.parent.niveau
            self.etape = self.parent.etape
        else:
            # Le mot cle a ete cree sans parent
            self.jdc = None
            self.niveau = None
            self.etape = None
        self.state = "undetermined"
        self.actif = 1
        self.mcListe = self.buildMc()

    def buildMc(self):
        """
        Construit la liste des sous-entites de MCNUPLET
        a partir de la liste des arguments (valeur)
        """
        args = self.valeur
        if args == None:
            args = ()
        mcListe = []

        # on cree les sous entites du NUPLET a partir des valeurs initiales
        k = 0
        for v in self.definition.entites:
            if k < len(args):
                val = args[k]
            else:
                val = None
            objet = v(val=val, nom=repr(k), parent=self)
            if hasattr(objet.definition, "position"):
                if objet.definition.position == "global":
                    self.append_mc_global(objet)
                # XXX et global_jdc ??
            mcListe.append(objet)
            k = k + 1
        # Un nuplet n'a pas de mots inconnus
        self.reste_val = {}
        return mcListe

    def isValid(self, cr="non"):
        """
        Indique si self (MCNUPLET) est un objet valide ou non : retourne 1 si oui, 0 sinon
        """
        if self.state == "unchanged":
            return self.valid
        else:
            valid = 1
            if hasattr(self, "valid"):
                old_valid = self.valid
            else:
                old_valid = None
            for child in self.mcListe:
                if not child.isValid():
                    valid = 0
                    break
            if len(self.mcListe) != len(self.definition.entites):
                valid = 0
                if cr == "oui":
                    self.cr.fatal(
                        "".join(("Nuplet : ", self.nom, tr("Longueur incorrecte")))
                    )
            self.valid = valid
            self.state = "unchanged"
            if old_valid:
                if old_valid != self.valid:
                    self.initModifUp()
            return self.valid

    def __getitem__(self, key):
        """
        Retourne le key eme element du nuplet
        """
        # Un nuplet est toujours une liste de mots cles simples
        # On retourne donc la valeur
        return self.mcListe[key].valeur

    def __str__(self):
        """
        Retourne une representation du nuplet sous forme de chaine
        de caracteres
        """
        s = "("
        for e in self.mcListe:
            s = s + str(e.valeur) + ","
        return s + ")"

    def __repr__(self):
        """
        Retourne une representation du nuplet sous forme de chaine
        de caracteres
        """
        s = "("
        for e in self.mcListe:
            s = s + str(e.valeur) + ","
        return s + ")"

    def getRegles(self):
        """
        Retourne la liste des regles attachees au nuplet
        """
        return []

    def verifConditionBloc(self):
        """
        Verifie s'il y a des blocs sous le nuplet et retourne
        les blocs en question
        """
        # Il n y a pas de BLOCs sous un NUPLET
        return [], []

    def isRepetable(self):
        """
        Indique si le NUPLET peut etre repete.
        Retourne 1 si c'est le cas.
        Retourne 0 dans le cas contraire.
        L'information est donnee par le catalogue, cad la definition de self
        """
        if self.definition.min != self.definition.max:
            return 1
        else:
            return 0

    def makeobjet(self):
        return self.definition(val=None, nom=self.nom, parent=self.parent)

    def getValeur(self):
        """
        Cette methode doit retourner la valeur de l'objet. Elle est utilisee par
        creeDictValeurs pour construire un dictionnaire contenant les mots cles
        d'une etape.
        Dans le cas d'un nuplet, on retournera comme valeur une liste des valeurs
        des mots cle simples contenus.
        """
        l = []
        for v in self.mcListe:
            l.append(v.valeur)
        return l

    def getVal(self):
        """
        Une autre methode qui retourne une "autre" valeur du mot cle facteur.
        Elle est utilisee par la methode getMocle
        """
        l = []
        for v in self.mcListe:
            l.append(v.valeur)
        return l

    def isOblig(self):
        return self.definition.statut == "o"

    def getFr(self):
        """
        Retourne le texte d'aide dans la langue choisie
        """
        try:
            return getattr(self.definition, self.jdc.lang)
        except:
            return ""

    def creeDictValeurs(self, liste=[], condition=0):
        dico = {}
        return dico

    def updateConditionBloc(self):
        """
        Realise l'update des blocs conditionnels fils de self
        et propage au parent (rien a faire pour nuplet)
        """
