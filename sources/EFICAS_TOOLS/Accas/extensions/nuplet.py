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
    Ce module contient la classe de definition pour les nuplets NUPL
"""
# Modules Python
from builtins import str
import types

# Modules Eficas
from Accas.processing import P_ENTITE, P_MCLIST, P_CR
from Accas.accessor import A_ENTITE
from Accas.extensions.eficas_translation import tr
from . import mcnuplet


class NUPL(P_ENTITE.ENTITE, A_ENTITE.ENTITE):
    """ """

    class_instance = mcnuplet.MCNUPLET
    list_instance = P_MCLIST.MCList
    label = "NUPLET"
    CR = P_CR.CR

    def __init__( self, fr="", ang="", docu="", statut="f", defaut=None, min=0, max=1, elements=None,):
        P_ENTITE.ENTITE.__init__(self)
        A_ENTITE.ENTITE.__init__(self)
        self.fr = fr
        self.ang = ang
        self.docu = docu
        self.statut = statut
        self.defaut = defaut
        self.min = min
        self.max = max
        if self.max == "**":
            self.max = float("inf")
        if self.min == "**":
            self.min = float("-inf")
        self.entites = elements
        self.regles = ()
        # on force le statut des sous entites a obligatoire
        for e in elements:
            e.statut = "o"
        self.idracine = "NUPLET"
        self.affecter_parente()

    def verifCata(self):
        """
        Cette methode sert a valider les attributs de l'objet de definition
        de la classe NUPL
        """
        if type(self.min) != int:
            if self.min != "**" and self.min != float("-inf"):
                self.cr.fatal(
                    tr("L'attribut 'min' doit etre un entier : ") + str(self.min)
                )
        if type(self.max) != int:
            if self.max != "**" and self.max != float("inf"):
                self.cr.fatal(
                    tr("L'attribut 'max' doit etre un entier : ") + str(self.max)
                )
        if self.min > self.max:
            self.cr.fatal(
                tr("Nombres d'occurrence min et max invalides :")
                + str(self.min)
                + ","
                + str(self.max)
            )
        if type(self.fr) != bytes and type(self.fr) != str:
            self.cr.fatal(tr("L'attribut 'fr' doit etre une chaine de caracteres"))
        if self.statut not in ["o", "f", "c", "d"]:
            self.cr.fatal(tr("L'attribut 'statut' doit valoir 'o','f','c' ou 'd'"))
        if type(self.docu) != bytes and type(self.docu) != str:
            self.cr.fatal(tr("L'attribut 'docu' doit etre une chaine de caracteres"))
        self.verifCataRegles()

    def __call__(self, val, nom, parent):
        """
        Construit la structure de donnees pour un NUPLET a partir de sa definition (self)
        de sa valeur (val), de son nom (nom) et de son parent dans l arboresence (parent)
        """
        if (type(val) == tuple or type(val) == list) and type(val[0]) == tuple:
            # On est en presence d une liste de nuplets
            l = self.list_instance()
            l.init(nom=nom, parent=parent)
            for v in val:
                objet = self.class_instance(
                    nom=nom, definition=self, val=v, parent=parent
                )
                l.append(objet)
            return l
        else:
            # on est en presence d un seul nuplet
            return self.class_instance(nom=nom, definition=self, val=val, parent=parent)

    def report(self):
        """
        Methode qui cree le rapport de verification du catalogue du nuplet
        """
        self.cr = self.CR()
        self.verifCata()
        for v in self.entites:
            cr = v.report()
            cr.debut = tr("Debut ") + v.__class__.__name__ + " : "
            cr.fin = tr("Fin ") + v.__class__.__name__ + " : "
            self.cr.add(cr)
        return self.cr

    def affecter_parente(self):
        """
        Cette methode a pour fonction de donner un nom et un pere aux
        sous entites qui n'ont aucun moyen pour atteindre leur parent
        directement
        Il s'agit principalement des mots cles
        """
        k = 0
        for v in self.entites:
            v.pere = self
            v.nom = str(k)
            k = k + 1
