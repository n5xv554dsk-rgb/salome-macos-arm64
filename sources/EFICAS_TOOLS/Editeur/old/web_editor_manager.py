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

import os
from Accas.extensions.eficas_translation import tr
from Editeur.editor_manager import EditorManager
from multiprocessing import Lock


#-----------------------------------#
class WebEditorManager(EditorManager):
#-----------------------------------#
    """
    classe qui gere quel est l editor web actif
    """

    #--------------------------------
    def __init__(self, appliEficas):
    #--------------------------------
        super().__init__(appliEficas)
        self.dictEditors={}
        self.dictSessions = {}
        lock = Lock()


    #---------------------------------------
    def afficheInfos(self,txt,couleur=None):
    #---------------------------------------
        """
          Est-ce que le web_manager a des infos a afficher ?
          sans session ?
        """
        self.appliEficas.toWebApp('afficheInfos', txt, couleur) 


    #-------------------------------------------------
    def openDataset (self,sid, cataFile, datasetFile):
    #------------------------------------------------
        print ('aaaaaaaaaaaaaaa pppppppppppppppppppppppppppppppppppp')
        if cataFile == None : 
           return (None, 1, 'fichier Catalogue indispensable pour ouvrir un dataSet) 
        else:
            double = None
            from web_editor import WebEditor
            editor = WebEditor(self.appliEficas, fichier)
            if editor.jdc:  # le fichier est bien un jdc
                self.editors.append(editor)
                self.dictEditors[editor.idUnique]=editor
            else:
                editor=None
        # if double :
        #    il faut mettre les sessions à jours
        return editor

    # --------------------------------------------------------------------------
    def getEditor(self,sId=None, cataFile = None, dataSetFile=None, jdc=None, include=0):
    # --------------------------------------------------------------------------
        """
          Retourne un nouvel editeur ou None si doublon
        """
        if cataFile == None :
            self.appliEficas.afficheMessage('Eficas',
                 'nom de catalogue obligatoire pour obtenir un editor')
            return (None, 1, 'nom de catalogue obligatoire pour obtenir un editor')
        with lock :
            for indexEditor in self.appliEficas.dictEditorSession:
                editor = self.appliEficas.dictEditorSession[indexEditor]
                if self.samePath(dataSetFile, editor.getFileName()) and self.samePath(cataFile, editor.getFileName()):
                    break
            else:
                from web_editor import WebEditor 
                editor = WebEditor(self.appliEficas, cataFile, dataSetFile)

            if editor.jdc:  # le fichier est bien un jdc
                self.editors.append(editor)
                self.appliEficas.dictEditorSession[editor.idUnique]=editor
                if  editor.idUnique in self.appliEficas.dictEditorSession :
                   self.appliEficas.dictEditorSession[editor.idUnique].append(sId)
                else :
                   self.appliEficas.dictEditorSession[editor.idUnique]=(sId,)
            else:
                return (None, 1, 'impossible d allouer l editor')  
            return (editor, 0, '')



    # --------------------------
    def getEditorById(self, id):
    # ---------------------------
        if id in self.appliEficas.dictEditorSession:
           return self.appliEficas.dictEditorSession[id]
        return None
        
 

