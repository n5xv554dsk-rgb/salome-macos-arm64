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
    Ce module contient la classe ETAPE_NIVEAU qui sert a
    concretiser les niveaux au sein d'un JDC
"""
import traceback
from Accas.processing import P_OBJECT


class ETAPE_NIVEAU(P_OBJECT.OBJECT):
    def __init__(self, niveau, parent):
        self.parent = parent
        self.jdc = self.parent.getJdcRoot()
        self.niveau = self
        self.definition = niveau
        self.etapes = []
        self.etapes_niveaux = []
        self.dict_niveaux = {}
        self.editmode = 0
        self.state = "undetermined"
        self.buildNiveaux()

    def buildNiveaux(self):
        for niveau in self.definition.lNiveaux:
            etape_niveau = ETAPE_NIVEAU(niveau, self)
            self.etapes_niveaux.append(etape_niveau)
            self.dict_niveaux[niveau.nom] = etape_niveau

    def register(self, etape):
        """
        Enregistre la commande etape :
        - si editmode = 0 : on est en mode relecture d'un fichier de commandes
        auquel cas on ajoute etape a la fin de la liste self.etapes
        - si editmode = 1 : on est en mode ajout d'etape depuis eficas auquel cas
        cette methode ne fait rien, c'est addEntite qui enregistre etape
        a la bonne place dans self.etapes
        """
        if self.editmode:
            return
        self.etapes.append(etape)

    def unregister(self, etape):
        """
        Desenregistre l'etape du niveau
        """
        self.etapes.remove(etape)

    def ident(self):
        return self.definition.label

    def isActif(self):
        # print 'Niveau : ',self.definition.nom
        # print '\tactif =',self.definition.actif
        if self.definition.actif == 1:
            return 1
        else:
            # self.actif est une condition a evaluer dans un certain contexte ...
            d = self.creeDictValeurs()
            try:
                t = eval(self.definition.actif, d)
                return t
            except:
                traceback.print_exc()
                return 0

    def creeDictValeurs(self):
        """
        Retourne le dictionnaire des freres aines de self compose des couples :
        {nom_frere isValid()}
        """
        d = {}
        for niveau in self.parent.etapes_niveaux:
            if niveau is self:
                break
            d[niveau.definition.nom] = niveau.isValid()
        return d

    def isValid(self):
        """Methode booleenne qui retourne 0 si le niveau est invalide, 1 sinon"""
        if self.etapes_niveaux == []:
            if len(self.etapes) == 0:
                return self.definition.valide_vide
            else:
                for etape in self.etapes:
                    if not etape.isValid():
                        return 0
                return 1
        else:
            for etape_niveau in self.etapes_niveaux:
                if not etape_niveau.isValid():
                    return 0
            return 1

    def accept(self, visitor):
        visitor.visitETAPE_NIVEAU(self)

    def addEntite(self, name, pos_rel):
        self.editmode = 1
        try:
            pos_abs = self.jdc.getNbEtapesAvant(self) + pos_rel
            cmd = self.jdc.addEntite(name, pos_abs)
            self.etapes.insert(pos_rel, cmd)
            self.editmode = 0
            return cmd
        except:
            traceback.print_exc()
            self.editmode = 0
            return None

    def suppEntite(self, etape):
        """Classe ETAPE_NIVEAU
        Supprime une etape
        """
        self.jdc.suppEntite(etape)

    def getFr(self):
        """
        Retourne le texte d'aide dans la langue choisie
        """
        try:
            return getattr(self.definition, self.jdc.lang)
        except:
            return ""
