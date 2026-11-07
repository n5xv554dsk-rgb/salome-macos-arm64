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
from Accas.accessor import A_MCCOMPO


class MCBLOC(A_MCCOMPO.MCCOMPO):
    def getNomDsXML(self):
        return self.parent.getNomDsXML()

    def getDicoForFancy(self):
        listeNodes = []
        for obj in self.mcListe:
            lesNodes = obj.getDicoForFancy()
            if not (isinstance(lesNodes, list)):
                listeNodes.append(lesNodes)
            else:
                for leNode in lesNodes:
                    listeNodes.append(leNode)
        return listeNodes

    def getParentsJusqua(self, jusqua):
        listeDesParents = []
        aTraiter = self
        while aTraiter != jusqua.getObject():
            listeDesParents.append(aTraiter.parent)
            aTraiter = aTraiter.parent
        return listeDesParents
