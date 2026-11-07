#!/usr/bin/env python
# -*- coding: iso-8859-1 -*-
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
import os, sys

from Editeur.eficas_appli import EficasAppli
from InterfaceGUI.Web.web_editor_manager import WebEditorManager
from Accas.extensions.eficas_exception import EficasException

activeLogging=0
if activeLogging :
   from Editeur.loggingEnvironnement import loggingEnvironnement, fonctionLoguee
else :
   fonctionLoguee = lambda func: func

#--------------------------------#
class WebEficasAppli(EficasAppli):
#--------------------------------#
    """
    Class implementing the main QT user interface.
    """

    #---------------------------------------------------------------------------------------------------------------------------------------------------------
    def __init__(self, code=None, versionCode=None, salome=0, multi=False, langue="fr", ssCode=None, cataFile=None, GUIPath="InterfaceGUI.QT5", appWeb=None):
    #---------------------------------------------------------------------------------------------------------------------------------------------------------
        """
        Constructor
        """
        EficasAppli.__init__( self, code, versionCode, salome, multi, langue,  ssCode, cataFile, GUIPath, appWeb)
        self.editorManager = WebEditorManager(self)
        if self.appWeb == None : 
           super().afficheMessage ('lancement Eficas WEB' , 'le parametre appWeb est obligatoire')
           return 


    #------------------------------------------
    def toWebApp(self,fction, *args, **kwargs):
    #------------------------------------------
        #if fction =='propageValide' :
        debug=0
        if debug  : print ('PNPNPN : WebEficasAppli.toWebApp',  fction, sid, eid, *args, **kwargs)
        if self.appWeb == None  : return
        #if fction =='propageValide' : print ('self.appWeb.toWebApp propageValide', self.monEditeur.getNodeById(args[0]).nom)
        self.appWeb.fromConnecteur(fction, *args, **kwargs)


    @fonctionLoguee
    #------------------------------------------------
    def openDataset(self, sid, cataFile, datasetFile):
    #--------------------------------------------------
        try:
            (monEditor, codeErreur, message)  = self.editorManager.openDataset(sid, cataFile, datasetFile)
        except EficasException as exc:
            self.afficheMessage('erreur ouverture fichier', str(exc),critical=True)
            monEditor = None
        return (monEditor, codeErreur, message)

    @fonctionLoguee
    #-----------------------------------------------------
    def afficheMessage (self, titre, texte,critical=True):
    #-----------------------------------------------------
#TODO : le afficheMessage doit tenir compte de qui
        if critical : 
           self.toWebApp('afficheMessage', titre+texte, 'rouge')
        else :
           self.toWebApp('afficheMessage', titre+texte)


if __name__ == "__main__":
    print ('todo')
