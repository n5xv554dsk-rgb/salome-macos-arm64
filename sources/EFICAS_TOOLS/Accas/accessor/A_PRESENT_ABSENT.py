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


class PRESENT_ABSENT(A_REGLE.REGLE):
    def purgeListe(self, liste_a_purger, listeMcPresents):
        regle_active = 0
        if self.mcs[0] in listeMcPresents:
            regle_active = 1
        if not regle_active:
            return liste_a_purger

        # Il ne faut pas purger le mot cle present
        for mc in self.mcs[1:]:
            if mc in liste_a_purger:
                liste_a_purger.remove(mc)
        return liste_a_purger
