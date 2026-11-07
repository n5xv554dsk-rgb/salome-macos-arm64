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
from Accas.processing import P_OPER
from Accas.accessor import A_ENTITE
from Accas.classes import C_ETAPE
from Efi2Xsd.AccasXsd import X_OPER


class OPER(P_OPER.OPER, X_OPER, A_ENTITE.ENTITE):
    """
    Accas.classes class for catalog definition keyword OPER
    """

    class_instance = C_ETAPE.ETAPE

    def __init__(self, *tup, **args):
        A_ENTITE.ENTITE.__init__(self)
        P_OPER.OPER.__init__(self, *tup, **args)
