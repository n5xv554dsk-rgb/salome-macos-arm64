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


from Accas.processing.P_ASSD import ASSD
from Accas.processing.P_Exception import AsException
from Accas.processing import P_utils


class CO(ASSD):
    def __init__(self, nom):
        ASSD.__init__(self, etape=None, sd=None, reg="oui")
        self._as_co = 1
        #
        #  On demande le nommage du concept
        #
        if self.parent:
            try:
                self.parent.nommerSDProd(self, nom)
            except AsException as e:
                appel = P_utils.calleeWhere(niveau=2)
                raise AsException(
                    "Concept CO, fichier: ", appel[1], " ligne : ", appel[0], "\n", e
                )
        else:
            self.nom = nom

    def __convert__(cls, valeur):
        if valeur.isTypCO():
            return valeur
        raise ValError("Pas un concept CO")

    __convert__ = classmethod(__convert__)
