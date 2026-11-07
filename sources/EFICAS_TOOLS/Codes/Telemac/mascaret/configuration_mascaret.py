# -*- coding: utf-8 -*-
#
#  Copyright (C) 2012 - 2026 EDF
#
#  This file is part of SALOME HYDRO module.
#
#  SALOME HYDRO module is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  SALOME HYDRO module is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with SALOME HYDRO module.  If not, see <http://www.gnu.org/licenses/>.

import os

from Editeur.catadesc import CatalogDescription
from InterfaceQT4.configuration import CONFIG_BASE

class CONFIG(CONFIG_BASE):

    def __init__(self, appli, repIni):
        """
        This class stores the configuration parameters for Eficas
        """
        CONFIG_BASE.__init__(self, appli, repIni)

        # Configuration parameters
        self.savedir    = os.getenv("HOME")
        self.catalogues = (CatalogDescription("mascaret_V7",
                                              os.path.join(repIni, "mascaret_V7_cata.py")),)
        self.lang = 'fr'

    def save_params(self):
        pass

def make_config(appli, rep):
    return CONFIG(appli, rep)

def make_config_style(appli, rep):
    return None
