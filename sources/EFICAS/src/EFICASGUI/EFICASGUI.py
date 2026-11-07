# -*- coding: utf-8 -*-
# Copyright (C) 2001-2026  EDF R&D
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
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

# -*- coding: utf-8 -*-

import os

from PyQt5.QtWidgets import QMessageBox
from salome.kernel.salome.kernel.studyedit import getStudyEditor
import SalomePyQt
from salome.kernel import salome
from launchConfigureParser import userFile, salomecfgname, salomeappname, xml_parser


sgPyQt = SalomePyQt.SalomePyQt()

def findSalomeLanguage():
    debug = 0
    language = None
    configFile=userFile(salomeappname, salomecfgname)
    if debug : print ('configFile',configFile)
    try:
       parser = xml_parser(configFile,{},[])
       language=parser.opts['language_language']
    except:
       language ='en_US'
    if debug : print ('salome language',language)
    return language

salomeLanguage = findSalomeLanguage()

# Test Eficas directory
eficasRoot = os.getenv("EFICAS_ROOT")
if eficasRoot is None:
    QMessageBox.critical(sgPyQt.getDesktop(), "Error",
                         "Cannot initialize EFICAS module. Environment "
                         "variable EFICAS_ROOT is not set.")
elif not os.path.isdir(eficasRoot):
    QMessageBox.critical(sgPyQt.getDesktop(), "Error",
                         "Cannot initialize EFICAS module. Directory %s does "
                         "not exist (check EFICAS_ROOT environment "
                         "variable)." % eficasRoot)


################################################
# GUI context class
# Used to store actions, menus, toolbars, etc...
################################################

class GUIcontext:
    # menus/toolbars/actions IDs
    EFICAS_MENU_ID = 90
    TELEMAC_ID = 941
    ADAO_ID = 942
    MAP_ID = 943
    CF_ID = 944
    MT_ID = 945
    SPECA_ID = 946
    SEP_ID = 947
    CARMEL3D_ID = 948
    MULTICATALOG_ID = 949

    # constructor
    def __init__(self):
        # create top-level menu
        self.mid = sgPyQt.createMenu("Eficas", -1, GUIcontext.EFICAS_MENU_ID,
                                     sgPyQt.defaultMenuGroup())
        # create toolbar
        self.tid = sgPyQt.createTool("Eficas")

        a = sgPyQt.createAction(GUIcontext.MULTICATALOG_ID, "Eficas MultiCatalogue", "Lancer Eficas", "Lancer Eficas", "eficas.png")
        sgPyQt.createMenu(a, self.mid)
        sgPyQt.createTool(a, self.tid)

        # create actions conditionally and fill menu and toolbar with actions
        self.addActionConditionally("Telemac3/prefs.py", GUIcontext.TELEMAC_ID,
                                    "Eficas pour Telemac",
                                    "Editer un .cas avec Eficas",
                                    "eficasTelemac.png")
        self.addActionConditionally("SEP/prefs.py", GUIcontext.SEP_ID,
                                    "Eficas pour SEP",
                                    "Editer un jeu de commande SEP avec Eficas",
                                    "eficasSEP.png")
        self.addActionConditionally("SPECA/prefs.py", GUIcontext.SPECA_ID,
                                    "Eficas pour SPECA",
                                    "Editer un jeu de commande SPECA avec Eficas",
                                    "eficasSPECA.png")
        self.addActionConditionally("CF/prefs.py", GUIcontext.CF_ID,
                                    "Eficas pour CF",
                                    "Editer un jeu de commande CF avec Eficas",
                                    "eficasCF.png")
        self.addActionConditionally("MT/prefs.py", GUIcontext.MT_ID,
                                    "Eficas pour MT",
                                    "Editer un jeu de commande MT avec Eficas",
                                    "eficasMT.png")
        self.addActionConditionally("Adao/prefs.py", GUIcontext.ADAO_ID,
                                    "Eficas pour Adao",
                                    "Editer un jeu de commande Adao avec Eficas",
                                    "eficasAdao.png")
        self.addActionConditionally("MAP/prefs.py", GUIcontext.MAP_ID,
                                    "Eficas pour Map",
                                    "Editer un jeu de commande Map avec Eficas",
                                    "eficasMAP.png")
        self.addActionConditionally("Carmel3D/prefs.py", GUIcontext.CARMEL3D_ID,
                                    "Eficas pour Carmel3D",
                                    "Editer un jeu de commande Carmel3D avec Eficas",
                                    "eficasCarmel3D.png")

    def addActionConditionally(self, fileToTest, commandId, menuLabel, tipLabel, icon):
        global eficasRoot
        if os.path.isfile(os.path.join(eficasRoot, fileToTest)):
            a = sgPyQt.createAction(commandId, menuLabel, tipLabel, tipLabel, icon)
            sgPyQt.createMenu(a, self.mid)
            sgPyQt.createTool(a, self.tid)

################################################
# Global variables
################################################

# study-to-context map
#__study2context__ = {}
# current context
#__current_context__ = None



# ##
# set and return current GUI context
# study ID is passed as parameter
# ##
#def _setContext(studyID):
#    global eficasRoot
#    if eficasRoot is None:
#        return
#    global __study2context__, __current_context__
#    if studyID not in __study2context__:
#        __study2context__[studyID] = GUIcontext()
#        pass
#    __current_context__ = __study2context__[studyID]
#    return __current_context__


# -----------------------------------------------------------------------------

def OnGUIEvent(commandID):
    if commandID in dict_command:
        print("OnGUIEvent ::::::::::  commande associée  : ", commandID)
        dict_command[commandID]()
    else:
        print("Pas de commande associée a : ", commandID)


# -----------------------------------------------------------------------------

#def setSettings():
#    """
#    Cette méthode permet les initialisations.
#    """
    #_setContext(sgPyQt.getStudyId())


def activate():
    """
    Cette méthode permet l'activation du module, s'il a été chargé mais pas encore
    activé dans une étude précédente.

    Portage V3.
    """
#    setSettings()
    GUIcontext()


# -----------------------------------------------------------------------------

#def activeStudyChanged(ID):
#    _setContext(ID)


# -----------------------------------------------------------------------------

def runEficas():
    print("-------------------------EFICASGUI::runEficas-------------------------")
    import eficasSalome
    eficasSalome.runEficas(multi=True)


def runEficaspourTelemac():
    import eficasSalome
    eficasSalome.runEficas("TELEMAC")


def runEficaspourAdao():
    print("runEficas Pour Ada")
    import eficasSalome
    eficasSalome.runEficas("ADAO")


def runEficaspourMT():
    print("runEficas Pour MT")
    import eficasSalome
    eficasSalome.runEficas("MT")


def runEficaspourSPECA():
    print("runEficas Pour SPECA")
    import eficasSalome
    eficasSalome.runEficas("SPECA")


def runEficaspourSEP():
    print("runEficas Pour SEP")
    import eficasSalome
    eficasSalome.runEficas("SEP")


def runEficaspourMap():
    print("runEficas Pour Map ")
    import eficasSalome
    eficasSalome.runEficas("MAP")


def runEficaspourCarmel3D():
    print("runEficas Pour Carmel3D ")
    import eficasSalome
    eficasSalome.runEficas("CARMEL3D")


def runEficaspourCF():
    print("runEficas Pour CF ")
    import eficasSalome
    eficasSalome.runEficas("CF")


def runEficasFichier(version=None):
    """
    Lancement d'eficas pour ASTER
    si un fichier est sélectionné, il est ouvert dans eficas
    """
    fileName = None
    code = None
    a = salome.sg.getAllSelected()
    if len(a) == 1:
        selectedEntry = a[0]

        editor = getStudyEditor()
        mySO = editor.study.FindObjectID(selectedEntry)
        aType = editor.getFileType(mySO)
        aValue = editor.getFileName(mySO)
        if aType is not None:
            fileName = aValue
            code = aType[15:]
    else:
        QMessageBox.critical(None, "Selection Invalide",
                             "Selectionner un seul fichier SVP")
        return

    import eficasSalome
    if code:
        if version:
            eficasSalome.runEficas(code, fileName, version=version)
        else:
            eficasSalome.runEficas(code, fileName)


# Partie applicative

dict_command = {
                GUIcontext.TELEMAC_ID: runEficaspourTelemac,
                GUIcontext.ADAO_ID: runEficaspourAdao,
                GUIcontext.MT_ID: runEficaspourMT,
                GUIcontext.SPECA_ID: runEficaspourSPECA,
                GUIcontext.SEP_ID: runEficaspourSEP,
                GUIcontext.CF_ID: runEficaspourCF,
                GUIcontext.MAP_ID: runEficaspourMap,
                GUIcontext.CARMEL3D_ID: runEficaspourCarmel3D,
                GUIcontext.MULTICATALOG_ID: runEficas,

                9041: runEficasFichier,
             }

