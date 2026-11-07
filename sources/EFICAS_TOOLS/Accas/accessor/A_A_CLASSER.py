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
"""
from Accas.accessor import A_REGLE


class A_CLASSER(A_REGLE.REGLE):
    def getText(self):
        text = "Regle " + self.__class__.__name__ + " :\n"
        t = "  D'abord :\n" + " " * 8
        for arg in self.args0:
            t = t + arg.strip() + " ou "
        text = text + t[0:-4] + "\n"
        t = "  Ensuite :\n" + " " * 8
        for arg in self.args1:
            t = t + arg.strip() + " ou "
        text = text + t[0:-4] + "\n"
        return text
