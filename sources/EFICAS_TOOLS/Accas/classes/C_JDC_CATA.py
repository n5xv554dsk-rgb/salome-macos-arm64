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
from Accas.classes import C_JDC
from Accas.processing import P_JDC_CATA
from Accas.accessor import A_JDC_CATA
from Efi2Xsd.AccasXsd import X_JDC_CATA


class JDC_CATA(A_JDC_CATA.JDC_CATA, P_JDC_CATA.JDC_CATA, X_JDC_CATA):
    """
    Accas.classes class that defines a catalog object that is object which will be used
    to control conformity of the dataset with its definition
    """

    class_instance = C_JDC.JDC

    def __init__(self, *pos, **kw):
        # print (pos)
        # print (kw)
        P_JDC_CATA.JDC_CATA.__init__(self, *pos, **kw)
        A_JDC_CATA.JDC_CATA.__init__(self)
