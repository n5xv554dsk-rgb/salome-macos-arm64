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
   Ce module contient les classes permettant de definir les objets graphiques
   representant un objet de type PARAMETRE, cad le panneau et l'item de l'arbre
   d'EFICAS
"""
# import modules Python
import types
from Accas.extensions.eficas_translation import tr
from InterfaceGUI.Common import objecttreeitem

class PARAMTreeItemCommun(objecttreeitem.ObjectTreeItem):
    """
    Classe servant a definir l'item porte par le noeud de l'arbre d'EFICAS
    qui represente le PARAMETRE
    """

    def init(self):
        self.setFunction = self.setValeur

    # ---------------------------------------------------------------------------
    #                   API du PARAMETRE pour l'arbre
    # ---------------------------------------------------------------------------

    def getIconName(self):
        """
        Retourne le nom de l'icone associee au noeud qui porte self,
        dependant de la validite de l'objet
        NB : un PARAMETRE est toujours valide ...
        """
        if self.isActif():
            if self.isValid():
                return "ast-green-square"
            else:
                return "ast-red-square"
        else:
            return "ast-white-square"

    def getLabelText(self):
        """Retourne 3 valeurs :
        - le texte a afficher dans le noeud representant l'item
        - la fonte dans laquelle afficher ce texte
        - la couleur du texte
        """
        return tr("PARAMETRE"), None, None

    def getText(self):
        """
        Retourne le texte a afficher apres le nom de la commande (ici apres 'parametre')
        Ce texte est tronque a 25 caracteres
        """
        texte = self.object.nom + "=" + str(self.object.valeur)
        if type(self.object.valeur) == list:
            texte = self.nom + " = ["
            for l in self.object.valeur:
                texte = texte + str(l) + ","
            texte = texte[0:-1] + "]"
        texte = texte.split("\n")[0]
        if len(texte) < 25:
            return texte
        else:
            return texte[0:24] + "..."

    def getSubList(self):
        """
        Retourne la liste des fils de self
        """
        return []

    # ---------------------------------------------------------------------------
    #       Methodes permettant la modification et la lecture des attributs
    #       du parametre = API graphique du PARAMETRE pour Panel et EFICAS
    # ---------------------------------------------------------------------------

    def getValeur(self):
        """
        Retourne la valeur de l'objet PARAMETRE cad son texte
        """
        if self.object.valeur is None:
            return ""
        else:
            return self.object.valeur

    def getNom(self):
        """
        Retourne le nom du parametre
        """
        return self.object.nom

    def setValeur(self, new_valeur):
        """
        Affecte valeur a l'objet PARAMETRE
        """
        self.object.setValeur(new_valeur)

    def setNom(self, new_nom):
        """
        Renomme le parametre
        """
        self.object.setNom(new_nom)
        # self.object.setAttribut('nom',new_nom)

    def getFr(self):
        """
        Retourne le fr associe au parametre, cad la bulle d'aide pour EFICAS
        """
        return tr("Definition d'un parametre")

