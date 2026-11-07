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


class A_AVANT:
    """
    La regle A_AVANT verifie que l'on trouve l ordre  des mots-cles
    de la regle parmi les arguments d'un JDC.

    Ces arguments sont transmis a la regle pour Accas.validation sous la forme
    d'une liste de noms de mots-cles ou d'un dictionnaire dont
    les cles sont des noms de mots-cles.
    """

    def __init__(self, *args):
        if len(args) > 2:
            print(("Erreur a la creation de la regle A_CLASSER(", args, ")"))
            return
        if type(args[0]) == tuple:
            self.listeAvant = args[0]
        else:
            self.listeAvant = (args[0],)
        if type(args[1]) == tuple:
            self.listeApres = args[1]
        else:
            self.listeApres = (args[1],)

    def verif(self, args):
        """
        args peut etre un dictionnaire ou une liste. Les elements de args
        sont soit les elements de la liste soit les cles du dictionnaire.
        """
        #  on compte le nombre de mots cles presents
        text = ""
        boolListeAvant = 0
        boolListeApres = 0
        boolOK = 1
        for nom in args:
            if nom in self.listeAvant:
                boolListeAvant = 1
                if boolListeApres == 1:
                    boolOK = 0
            if nom in self.listeApres:
                boolListeApres = 1
        if boolListeAvant == 0 and boolListeApres == 1:
            boolOK = 0
        return text, boolOK

    def getText(self):
        text = "Regle de classement " " :\n"
        for mc in self.listeAvant:
            text = text + mc + ", "
        text = text + " \nAvant : \n"
        for mc in self.listeApres:
            text = text + mc + ","
        return text
