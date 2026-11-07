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
# Modules Python
# Modules Eficas


import os, sys, re
from  UiQT5.desChoixLangue import Ui_ChoixLangue

from PyQt5.QtWidgets import QDialog, QRadioButton, QGroupBox, QButtonGroup
from PyQt5.QtGui import QPalette
from PyQt5.QtCore import QProcess, QFileInfo, Qt, QSize


# Import des panels


class MonChoixLangue(Ui_ChoixLangue, QDialog):
    """
    Classe definissant le panel associe aux mots-cles qui demandent
    a l'utilisateur de choisir une seule valeur parmi une liste de valeurs
    discretes
    """

    def __init__(self, appliEficas=None):
        QDialog.__init__(self, appliEficas)
        self.setModal(True)
        self.setupUi(self)
        self.appliEficas = appliEficas
        self.installLangue()
        self.code = None
        self.pB_OK.clicked.connect(self.choisitLangue)

    def installLangue(self):
        if self.appliEficas.langue == "fr":
            self.rbFrancais.setChecked(True)
        else:
            self.rbEnglish.setChecked(True)

    def choisitLangue(self):
        if self.rbFrancais.isChecked():
            self.appliEficas.langue = "fr"
        else:
            self.appliEficas.langue = "ang"
        self.close()
