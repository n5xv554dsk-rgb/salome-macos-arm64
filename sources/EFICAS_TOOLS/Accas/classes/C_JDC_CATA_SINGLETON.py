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

from Accas.processing.P_utils import Singleton
from Accas import JDC_CATA


class JDC_CATA_SINGLETON(Singleton, JDC_CATA):
    """
    class used for defining catalogs which can be either standalone
    either imported by another catalog
    the steps are recorded in the correct JDC_CATA
    """

    def __init__(self, *pos, **kw):
        # on ne rappelle pas les init pour ne pas changer le nom du code
        if hasattr(self, "initialised"): return
        self.initialised = True
        JDC_CATA.__init__(self, *pos, **kw)

    # to do : reflechir pour les imports des drivers a utiliser le nom du code
    # de maniere a pour pourvoir utiliser n importe lequel des driver pour lire
    # le XML
