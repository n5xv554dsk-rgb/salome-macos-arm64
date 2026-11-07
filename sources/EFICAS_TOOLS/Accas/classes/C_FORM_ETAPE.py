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

from Accas.processing import P_FORM_ETAPE
from Accas.validation import V_MACRO_ETAPE
from Accas.accessor import A_FORM_ETAPE


class FORM_ETAPE(
    A_FORM_ETAPE.FORM_ETAPE, V_MACRO_ETAPE.MACRO_ETAPE, P_FORM_ETAPE.FORM_ETAPE
):
    """
    specific class for Aster FORM_ETAPE
    most likely as MACRO
    """

    def __init__(self, oper=None, reuse=None, args={}):
        P_FORM_ETAPE.FORM_ETAPE.__init__(self, oper, reuse, args)
        V_MACRO_ETAPE.MACRO_ETAPE.__init__(self)
        A_FORM_ETAPE.FORM_ETAPE.__init__(self)
