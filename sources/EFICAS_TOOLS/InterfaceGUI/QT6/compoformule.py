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
representant un objet de type FORMULE, cad le panneau et l'item de l'arbre
d'EFICAS
"""

from InterfaceGUI.QT6 import compooper
from InterfaceGUI.QT6 import browser
from InterfaceGUI.QT6 import typeNode


class FormuleNode(browser.JDCNode, typeNode.PopUpMenuNode):
    def getPanel(self):
        from InterfaceGUI.QT6.monWidgetFormule import MonWidgetFormule

        return MonWidgetFormule(self, self.editor, self.item.object)

    def createPopUpMenu(self):
        typeNode.PopUpMenuNode.createPopUpMenu(self)


class FORMULETreeItem(compooper.EtapeTreeItem):
    """
    Classe servant a definir l'item porte par le noeud de l'arbre d'EFICAS
    qui represente la FORMULE
    """

    itemNode = FormuleNode

    def init(self):
        self.setFunction = self.setValeur

    # ---------------------------------------------------------------------------
    #                   API de FORMULE pour l'arbre
    # ---------------------------------------------------------------------------
    def getSubList(self):
        """
        Retourne la liste des fils de self
        On considere que FORMULE n'a pas de fils
        --> modification par rapport a MACRO classique
        """
        # dans EFICAS on ne souhaite pas afficher les mots-cles fils de FORMULE
        # de facon traditionnelle
        return []

    def getIconName(self):
        """
        Retourne le nom de l'icone a afficher dans l'arbre
        Ce nom depend de la validite de l'objet
        """
        if self.object.isActif():
            if self.object.isValid():
                return "ast-green-square"
            else:
                return "ast-red-square"
        else:
            return "ast-white-text"

    def getLabelText(self):
        """Retourne 3 valeurs :
        - le texte a afficher dans le noeud representant l'item
        - la fonte dans laquelle afficher ce texte
        - la couleur du texte
        """
        return self.labeltext, None, None
        # if self.object.isActif():
        # None --> fonte et couleur par defaut
        #  return tr(self.labeltext),None,None
        # else:
        #   return tr(self.labeltext),None,None
        # return self.labeltext,fontes.standard_italique,None

    # ---------------------------------------------------------------------------
    #       Methodes permettant la modification et la lecture des attributs
    #       du parametre = API graphique de la FORMULE pour Panel et EFICAS
    # ---------------------------------------------------------------------------

    def getNom(self):
        """
        Retourne le nom de la FORMULE
        """
        return self.object.getNom()

    def getType(self):
        """
        Retourne le type de la valeur retournee par la FORMULE
        """
        return self.object.type_retourne

    def getArgs(self):
        """
        Retourne les arguments de la FORMULE
        """
        args = ""
        for mot in self.object.mcListe:
            if mot.nom == "NOM_PARA":
                args = mot.valeur
                break
        if args:
            if args[0] == "(" and args[-1] == ")":
                args = args[1:-1]
            # transforme en tuple si ce n est pas deja le casa
            try:
                args = args.split(",")
            except:
                pass
        return args

    def getCorps(self):
        """
        Retourne le corps de la FORMULE
        """
        corps = ""
        for mot in self.object.mcListe:
            if mot.nom == "VALE":
                corps = mot.valeur
                break
        return corps

    def getListeTypesAutorises(self):
        """
        Retourne la liste des types autorises pour les valeurs de sortie
        d'une FORMULE
        """
        return self.object.l_types_autorises

    def saveFormule(self, new_nom, new_typ, new_arg, new_exp):
        """
        Verifie si (new_nom,new_typ,new_arg,new_exp) definit bien une FORMULE
        licite :
            - si oui, stocke ces parametres comme nouveaux parametres de la
              FORMULE courante et retourne 1
            - si non, laisse les parametres anciens de la FORMULE inchanges et
              retourne 0
        """
        test, erreur = self.object.verifFormule_python(
            formule=(new_nom, new_typ, new_arg, new_exp)
        )
        if test:
            # la formule est bien correcte : on sauve les nouveaux parametres
            test = self.object.updateFormulePython(
                formule=(new_nom, new_typ, new_exp, new_arg)
            )
        return test, erreur

    # ---------------------------------------------------------------------------
    #          Acces aux methodes de verification de l'objet FORM_ETAPE
    # ---------------------------------------------------------------------------

    def verifNom(self, nom):
        """
        Lance la verification du nom passe en argument
        """
        return self.object.verifNom(nom)

    def verifArguments(self, arguments):
        """
        Lance la verification des arguments passes en argument
        """
        return self.object.verifArguments("(" + arguments + ")")

    def verifFormule(self, formule):
        """
        Lance la verification de FORMULE passee en argument
        """
        return self.object.verifFormule(formule=formule)

    def verifFormule_python(self, formule):
        """
        Lance la verification de FORMULE passee en argument
        """
        return self.object.verifFormule_python(formule=formule)


import Accas

treeitem = FORMULETreeItem
objet = Accas.FORM_ETAPE
