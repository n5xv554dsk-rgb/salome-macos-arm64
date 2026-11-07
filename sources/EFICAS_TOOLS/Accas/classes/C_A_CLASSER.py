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
from Accas.processing import P_REGLE
from Accas.validation import V_A_CLASSER
from Accas.accessor import A_A_CLASSER


class A_CLASSER(V_A_CLASSER.A_CLASSER, P_REGLE.REGLE, A_A_CLASSER.A_CLASSER):
    """
    Accas.classes class for catalog rule C_CLASSER
    It is absolutely necessary that V_A_CLASSER be first in the inheritance
    """

    # to do --> prevoir un X_A_CLASSER pour la projection XSD
    # Est-ce possible en 1ere passe ou faut-il modifier pendant une 2nd passe ?
    # ajouter une methode dump a tous les objets ?
    pass
