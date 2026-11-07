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

import types, os
import traceback

from Accas.extensions.eficas_translation import tr

from PyQt5.QtWidgets import QDialog, QMessageBox, QFileDialog
from PyQt5.QtCore import QSize
from UiQT5.desViewTexte import Ui_dView


# ------------------------------- #
class ViewText(Ui_dView, QDialog):
    # ------------------------------- #
    """
    Classe permettant la visualisation de texte
    """

    def __init__(
        self, parent, editor=None, entete=None, texte=None, largeur=600, hauteur=600
    ):
        QDialog.__init__(self, parent)
        self.editor = editor
        self.setupUi(self)

        self.resize(QSize(largeur, hauteur).expandedTo(self.minimumSizeHint()))
        self.bclose.clicked.connect(self.close)
        self.bsave.clicked.connect(self.saveFile)

        if entete != None:
            self.setWindowTitle(entete)
        if entete != None:
            self.setText(texte)

    def setText(self, txt):
        self.view.setText(txt)

    def saveFile(self):
        # recuperation du nom du fichier
        if self.editor != None:
            dir = self.editor.appliEficas.maConfiguration.saveDir
        else:
            dir = "/tmp"
        fn = QFileDialog.getSaveFileName(None, tr("Sauvegarder le fichier"), dir)
        fn = fn[0]
        if fn == "":
            return
        if fn == None:
            return (0, None)

        ulfile = os.path.abspath(fn)
        if self.editor != None:
            self.editor.appliEficas.maConfiguration.saveDir = os.path.split(ulfile)[0]
        try:
            f = open(fn, "w")
            f.write(str(self.view.toPlainText()))
            f.close()
            return 1
        except IOError as why:
            QMessageBox.critical(
                self,
                tr("Sauvegarder le fichier"),
                tr("Le fichier")
                + str(fn)
                + tr("n a pas pu etre sauvegarde : ")
                + str(why),
            )
            return
