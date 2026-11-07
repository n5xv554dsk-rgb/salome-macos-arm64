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

from PyQt6.QtWidgets import QButtonGroup, QToolButton
from PyQt6.QtGui import QIcon, QPixmap
from Accas.extensions.eficas_translation import tr


# ----------------------
class MonLayoutBouton:
    # ----------------------

    #  -------------------------------
    def __init__(self, appliEficas):
        #  -------------------------------

        self.appliEficas = appliEficas
        self.buttonGroup = QButtonGroup()

        for etape in self.appliEficas.readercata.cata.JdC.commandes:
            nomEtape = etape.nom
            toolButton = QToolButton(self.appliEficas.toolBarCommande)
            icon = QIcon()
            if nomEtape in self.appliEficas.maConfiguration.dicoIcones:
                fichier = self.appliEficas.maConfiguration.dicoIcones[nomEtape]
                icon.addPixmap(QPixmap(fichier), QIcon.Normal, QIcon.Off)
                toolButton.setIcon(icon)
            else:
                try:
                    label = nomEtape[0:3]
                except:
                    label = nomEtape
                toolButton.setText(label)

            action = self.appliEficas.toolBarCommande.addWidget(toolButton)
            action.setVisible(True)
            toolButton.setObjectName(nomEtape)
            toolButton.setToolTip(tr(nomEtape))
            self.buttonGroup.addButton(toolButton)

        self.buttonGroup.buttonClicked.connect(self.rbCliqueEtInsere)

    def rbCliqueEtInsere(self, id):
        self.appliEficas.handleAjoutEtape(id.objectName())
