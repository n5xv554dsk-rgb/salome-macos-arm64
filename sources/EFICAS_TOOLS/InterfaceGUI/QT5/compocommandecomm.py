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

import traceback

from InterfaceGUI.Common import objecttreeitem
from Accas.extensions.eficas_exception import EficasException
from InterfaceGUI.QT5 import compocomm


class COMMANDE_COMMTreeItem(objecttreeitem.ObjectTreeItem):
    itemNode = compocomm.Node

    def init(self):
        self.setFunction = self.setValeur

    def getIconName(self):
        """
        Retourne le nom de l'icone associee au noeud qui porte self,
        dependant de la validite de l'objet
        NB : une commande commentarisee est toujours valide ...
        """
        if self.isValid():
            return "ast-green-percent"
        else:
            return "ast-red-percent"

    def getLabelText(self):
        """Retourne 3 valeurs :
        - le texte a afficher dans le noeud representant l'item
        - la fonte dans laquelle afficher ce texte
        - la couleur du texte
        """
        return "commentaire"

    def getValeur(self):
        """
        Retourne la valeur de la commande commentarisee cad son texte
        """
        return self.object.getValeur() or ""

    def getText(self):
        texte = self.object.valeur
        texte = texte.split("\n")[0]
        if len(texte) < 25:
            return texte
        else:
            return texte[0:24]

    def setValeur(self, valeur):
        """
        Afefcte valeur a l'objet commande commentarisee
        """
        self.object.setValeur(valeur)

    def getSubList(self):
        """
        Retourne la liste des fils de self
        """
        return []

    def unComment(self):
        """
        Demande a l'objet commande commentarisee de se decommentariser.
        Si l'operation s'effectue correctement, retourne l'objet commande
        et eventuellement le nom de la sd produite, sinon leve une exception
        """
        try:
            commande, nom = self.object.unComment()
            # self.parent.children[pos].select()
        except Exception as e:
            traceback.print_exc()
            raise EficasException(e)
        return commande, nom


import Accas

treeitem = COMMANDE_COMMTreeItem
objet = Accas.COMMANDE_COMM
