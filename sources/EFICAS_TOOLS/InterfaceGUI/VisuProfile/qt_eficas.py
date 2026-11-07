#!/usr/bin/env python3
# -*- coding: UTF-8 -*-
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

from UiQT5.myMainVP import Ui_EficasVP
from InterfaceGUI.QT5.qt_eficas import QtEficasAppli
from PyQt5.QtWidgets import  QAction, QMessageBox
from Accas.extensions.eficas_translation import tr
import os



class QtEficasAppli(Ui_EficasVP, QtEficasAppli):
    """
    Class implementing the ProfileVisualisation user interface.
    """

    def __init__(self,code='VP', salome=0, multi = 0, versionCode=None,  langue='en', GUIPath="InterfaceGUI.VisuProfile",appWeb=None):
        super().__init__(code=code, salome=salome, multi=multi, langue=langue, versionCode=versionCode, GUIPath=GUIPath)
        self.gitDir= os.environ.get('COCAGNE_GIT_DIR')
        if not self.gitDir :
            print ('Il est necessaire de positionner COCAGNE_GIT_DIR dans l environnement') 
            exit()
        self.withXSD = True
        self.GUIPath = GUIPath
        self.editorManager.getEditor()
        

    def connecterSignaux(self) :
        # Pour Aide
        self.actionCode = QAction(self)
        self.actionCode.setText(tr("Aide Visualisation"))
        self.actionCode.triggered.connect(self.aideCode)
        self.actionOuvrir.triggered.connect(self.openFile) 


    def openFile(self) :
        print ('aChanger')
        print ( self.editorManager)


    def closeEvent(self,event):
        print ('fermer la database ?? ')
        #res=self.fileExit()
        #if res==2 : event.ignore()


