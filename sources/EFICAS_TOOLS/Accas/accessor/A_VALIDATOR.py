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

from Accas.processing.P_VALIDATOR import *


class Compulsory(Compulsory):
    def hasInto(self):
        return 0

    def valideListePartielle(self, liste_courante=None):
        return 1


class OrdList(OrdList):
    def valideListePartielle(self, liste_courante=None):
        """
        Methode de Accas.validation de liste partielle pour le validateur OrdList
        """
        try:
            self.convert(liste_courante)
            valid = 1
        except:
            valid = 0
        return valid


class compareAutreMC(Valid):
# ----------------------------
    def __init__(self, frere=None):
        Valid.__init__(self, frere=frere)
        self.nomFrere = frere

    def set_MCSimp(self, MCSimp):
        debug = 0
        if debug:
            print("je passe la pour ", self, MCSimp.nom)
        self.MCSimp = MCSimp


class infFrereMC(compareAutreMC):
# -------------------------------
    def convert(self, valeur):
        # on sort de cardProto on a une liste
        valeur = valeur[0]
        try:
            MCFrere = self.MCSimp.parent.getChildOrChildInBloc(self.nomFrere)
        except:
            return valeur
        if not MCFrere: return valeur
        if MCFrere == None: return valeur
        if MCFrere.valeur == None: return valeur
        if MCFrere.valeur < valeur:
            raise ValError( "la valeur doit etre inferieure à la valeur de " + self.nomFrere)
        return valeur

    def verifItem(self, valeur):
        try:
            MCFrere = self.MCSimp.parent.getChildOrChildInBloc(self.nomFrere)
        except: return valeur
        if not MCFrere: return valeur
        if MCFrere == None: return valeur
        if MCFrere.valeur == None: return valeur
        if MCFrere.valeur < valeur:
            raise ValError( "la valeur doit etre inferieure à la valeur de " + self.nomFrere)
            return 0
        return 1

    def infoErreurItem(self, valeur):
        return  ("la valeur doit etre inferieure à la valeur de " + self.nomFrere)

    def info(self):
        return  ("la valeur doit etre inferieure à la valeur de " + self.nomFrere)


class supFrereMC(compareAutreMC):
# --------------------------------
    def convert(self, valeur):
        # on sort de cardProto on a une liste
        valeur = valeur[0]
        MCFrere = self.MCSimp.parent.getChildOrChildInBloc(self.nomFrere)
        if not MCFrere: return valeur
        if MCFrere == None: return valeur
        if MCFrere.valeur == None : return valeur
        if MCFrere.valeur > valeur:
            raise ValError( "la valeur doit etre superieure à la valeur de " + self.nomFrere)
        return valeur

    def verifItem(self, valeur):
        MCFrere = self.MCSimp.parent.getChildOrChildInBloc(self.nomFrere)
        if not MCFrere: return 1
        if MCFrere == None: return 1
        if MCFrere.valeur == None : return 1
        if MCFrere.valeur > valeur:
            raise ValError( "la valeur doit etre superieure à la valeur de " + self.nomFrere)
            return 0
        return 1

    def infoErreurItem(self, valeur):
        return ( "la valeur doit etre superieure à la valeur de " + self.nomFrere)

    def info(self):
        return ( "la valeur doit etre superieure à la valeur de " + self.nomFrere)
