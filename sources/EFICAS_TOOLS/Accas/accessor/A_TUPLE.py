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


class A_Matrice:
    def activeCouleur(self):
        self.dictCouleurs = {}
        self.indiceCouleur = 1
        self.listeCouleurs = (
            (10, 186, 181),
            (204, 204, 255),
            (121, 248, 248),
            (254, 231, 240),
            (250, 234, 115),
            (254, 191, 210),
            (248, 142, 85),
            (133, 193, 126),
            (210, 202, 236),
            (225, 206, 154),
            (187, 174, 152),
            (240, 195, 0),
            (242, 255, 255),
            (239, 239, 239),
            (149, 165, 149),
            (150, 131, 236),
            (201, 160, 220),
            (103, 159, 90),
            (176, 242, 182),
            (233, 201, 177),
        )
