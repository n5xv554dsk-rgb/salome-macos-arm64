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
import sys
import re

from PyQt5.QtWidgets import QMessageBox 


from salome.kernel import salome
import SalomePyQt
sgPyQt = SalomePyQt.SalomePyQt()

from salome.kernel.salome.kernel.logger import Logger
from salome.kernel.salome.kernel import termcolor
logger = Logger("salome.hydro.mascaret.eficas.appli",
                color = termcolor.GREEN_FG)

import eficasSalome

from salome.hydro.study import HydroStudyEditor

class EficasForMascaretAppli(eficasSalome.MyEficas):
    """
    This class launches Eficas and adds entries for the created files in
    MASCARET component in the study tree. The messages in this class are in
    french because they are displayed in Eficas interface.

    :type  fichier: string
    :param fichier: path of an Eficas file to open

    """
    def __init__(self, fichier = None, version = None):
        self.ed = HydroStudyEditor()
        self.codedir = os.path.dirname(__file__)
        sys.path[:0] = [self.codedir]
        eficasSalome.MyEficas.__init__(self, sgPyQt.getDesktop(),
                                       "mascaret",
                                       fichier, version = version)
        sgPyQt.createView("Eficas Mascaret", self)

    def addJdcInSalome(self, jdcPath):
        """
        Add the newly created file in Salome study
        """
        try:
            self.ed.find_or_create_mascaret_case(jdcPath)
        except Exception, exc:
            msgError = "Can't add file to Salome study tree"
            logger.exception(msgError)
            QMessageBox.warning(self, self.tr("Warning"),
                                self.tr("%s. Reason:\n%s\n\nSee logs for "
                                        "more details." % (msgError, exc)))
        salome.sg.updateObjBrowser(0)

    def closeEvent(self, event):
        while self.codedir in sys.path:
            sys.path.remove(self.codedir)
        eficasSalome.MyEficas.closeEvent(self, event)
