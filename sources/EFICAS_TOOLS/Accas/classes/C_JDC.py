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
from Accas.processing import P_JDC
from Accas.validation import V_JDC
from Accas.extensions import jdc
from Accas.accessor import A_JDC
from Efi2Xsd.MCAccasXML import X_JDC


class JDC(jdc.JDC, A_JDC.JDC, X_JDC, V_JDC.JDC, P_JDC.JDC):
    """
    parent class for dataset object (JDC)
    """


    def __init__(self, *pos, **args):
        P_JDC.JDC.__init__(self, *pos, **args)
        X_JDC.__init__(self)
        V_JDC.JDC.__init__(self)
        A_JDC.JDC.__init__(self)
        jdc.JDC.__init__(self)
        self.icmd = 0
