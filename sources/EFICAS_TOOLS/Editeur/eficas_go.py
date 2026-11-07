#!/usr/bin/env python3
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
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
#
# See http://www.salome-platform.org/ or email : webmaster.salome@opencascade.com
#

# Modules Python

import sys, os
repIni = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))

if sys.version_info[0] < 3:
    print("Must be using Python 3")
    sys.exit()


def lanceQtEficas(code=None, versionCode = None, multi=False, langue=None,  GUIPath='QT5', salome=0, prefsFile = None):
# ---------------------------------------------------------------------------------------------------------------------
    """
      Lance l'appli EFICAS avec Ihm QT
    """
    try:
        from PyQt5.QtWidgets import QApplication
    except:
        try:
            from PyQt6.QtWidgets import QApplication
        except:
            print("Please, set qt environment")
            return

    if not GUIPath in ('QT5','VisuProfile', 'QT6') :
       print ('Attention, lancement de Eficas pour QT avec GUIPath = {}'.format(GUIPath))

    from Editeur import session
    options = session.parse(sys.argv)
    if options.code != None:
        code = options.code
    if options.versionCode != None:
        versionCode = options.versionCode

    pathAbso=os.path.abspath(os.path.join(os.path.dirname(__file__),'..','InterfaceGUI',GUIPath))
    if pathAbso not in sys.path : sys.path.insert(0,pathAbso)
    from qt_eficas import QtEficasAppli
    app = QApplication(sys.argv)
    Eficas = QtEficasAppli(code=code, versionCode = versionCode, salome=salome, multi=multi, langue=langue, GUIPath=GUIPath, prefsFile = prefsFile)

    Eficas.show()

    #res = app.exec_()
    res = app.exec()
    sys.exit(res)


def getEficas( code=None, ssCode = None, versionCode = None , multi=False, langue=None, appWeb = None, cataFile = None, info = True):
# ---------------------------------------------------------------------------------------------------------------------------------
    """
    instancie l'appli EFICAS sans lancer QT
    """

    from Editeur import session
    options = session.parse(sys.argv)
    if options.code != None:
        code = options.code

    if info : print ('lancement de Eficas sans QT ')
    from Editeur.eficas_appli import EficasAppli
    Eficas = EficasAppli(code=code, multi=multi, langue=langue, ssCode=ssCode, salome = 0 , versionCode=versionCode,  cataFile=cataFile,  appWeb=appWeb, info=info)
    return Eficas


def genereXSD(code=None):
# -----------------------
    from Editeur import session
    options = session.parse(sys.argv)
    if code != None:
        options.code = code
    if options.cataFile == None:
        print("Use -c cata_name.py")
        return

    monEficas = getEficas(code=options.code, info = False)
    monEficas.genereXSD = True
    monEditor = monEficas.getEditorForXSDGeneration(cataFile= options.cataFile)
    texteXSD = monEditor.dumpXsd(withAbstractElt=options.withAbstractElt, withUnitAsAttribute = options.withUnitAsAttribute )

    cataFileTrunc = os.path.splitext(os.path.basename(options.cataFile))[0]
    fileXSD = cataFileTrunc + ".xsd"

    f = open(str(fileXSD), "w")
    f.write(str(texteXSD))


def genereXML(code=None):
# -----------------------
    from Editeur import session

    options = session.parse(sys.argv)
    if code != None:
        options.code = code
    if options.cataFile == None:
        print("Use -c cata_name.py")
        return
    try:
        fichier = options.comm[0]
    except:
        fichier = None
    if fichier == None:
        print("comm file is needed")
        return

    monEficas = getEficas(code=options.code, info = False)
    monEficas.genereXSD=False
    monEficas.withXSD=True
    monEditor = monEficas.getEditorForXSDGeneration(cataFile= options.cataFile,datasetFile=fichier,formatOut = 'xml')
    if options.fichierOut == None:
        fichierOut = fichier[: fichier.rfind(".")] + ".xml"
    else:
        fichierOut = options.fichierOut
    if not (monEditor.jdc.isValid()):
        print("Fichier comm is not valid")
        return
    # print ('Fichier comm is not valid')
    monEditor.XMLWriter.gener(monEditor.jdc)
    monEditor.XMLWriter.writeDefault(fichierOut)


def genereStructure(code=None):
# ------------------------------
    from Editeur import session

    options = session.parse(sys.argv)
    if code != None:
        options.code = code
    if options.cataFile == None:
        print("Use -c cata_name.py")
        return

    monEficas = getEficas(code=options.code, info = False)
    monEditor = monEficas.getEditorForGeneration(cataFile = options.cataFile)
    texteStructure = monEditor.dumpStructure()

    cataFileTrunc = os.path.splitext(os.path.basename(options.cataFile))[0]
    fileStructure = cataFileTrunc + ".txt"
    f = open(str(fileStructure), "w")
    f.write(str(texteStructure))
    f.close()

def genereGitStringFormat (code=None):
#---------------------------------------
    from Editeur  import session
    options=session.parse(sys.argv)
    if code != None : options.code = code
    if options.cataFile == None :
        print ('Use -c cata_name.py')
        return
    monEficas = getEficas(code=options.code, info = False)
    monEditor = monEficas.getEditorForGeneration(cataFile = options.cataFile)
    texteGitStringFormat = monEditor.dumpGitStringFormat()
    return texteGitStringFormat
 

def genereDBSchema (code=None):
#------------------------------------
    from Editeur  import session
    options=session.parse(sys.argv)
    if code != None : options.code = code
    if options.cataFile == None :
        print ('Use -c cata_name.py')
        return

    if options.databaseName == None :
        print ('Use -n nameOfDatabase')
        return
    monEficas = getEficas(code=options.code, info = False )
    monEditor = monEficas.getEditorForGeneration(cataFile = options.cataFile)
    texteDBSchema=monEditor.dumpDBSchema(options.databaseName)
    return texteDBSchema

def insertInDB (code=None):
#------------------------------
    from Editeur  import session
    options=session.parse(sys.argv)
    if code != None : options.code = code
    if options.cataFile == None :
        print ('Use -c cata_name.py')
        return 0
    try    : fichier=options.comm[0]
    except : fichier=None
    if fichier==None :
        print ('xml file is needed')
        return 0

    monEficasSsIhm = getEficasSsIhm(code=options.code, forceXML=True, info = False)
    from .editorSsIhm import JDCEditorSsIhm
    monEditeur=JDCEditorSsIhm(monEficasSsIhm,fichier)
    if not(monEditeur.readercata.cata) : return 0
    if not(monEditeur.jdc) : return 0
    return monEditeur.insertInDB()
   


def validateDataSet(code=None):
# ------------------------------
    from Editeur import session

    options = session.parse(sys.argv)
    if code != None:
        options.code = code
    if options.cataFile == None:
        print("Use -c cata_name.py")
        return
    fichier = options.comm[0]
    if fichier == None:
        print("comm file is needed")
        return

    monEficas = getEficas(code=options.code)
    monEficas.genereXSD=True
    monEditor = monEficas.getEditorForXSDGeneration(cataFile= options.cataFile,datasetFile=fichier,formatOut = 'xml')
    if not (monEditor.jdc.isValid()):
        print(monEditor.getJdcRapport())
    else:
        print("Jdc is valid")
    return monEditor.jdc.isValid()

def genereComm(code=None):
#-----------------------
    from Editeur  import session
    options=session.parse(sys.argv)
    if code != None : options.code = code
    if options.cataFile == None :
        print ('Use -c cata_name.py')
        return 0
    try    : fichier=options.comm[0]
    except : fichier=None
    if fichier==None :
        print ('xml file is needed')
        return 0

    monEficas = getEficas(code=options.code)
    monEditor = monEficas.getEditorForXSDGeneration(cataFile= options.cataFile,datasetFile=fichier, formatIn ='xml',formatOut = 'python')
    if options.fichierOut == None : fichierCommOut=fichier[:fichier.rfind(".")]+'.comm'
    else : fichierCommOut = options.fichierOut

    if not(monEditor.readercata.cata) : return 0
    if not(monEditor.jdc) : return 0
    # on ne sait lire que des xml valides
    #PNPN
    monEditor.myWriter.gener(monEditor.jdc,format = 'beautifie')
    monEditor.myWriter.writeFile(fichierCommOut)
    return 1

def genereUQ(code=None):
#-----------------------
    from Editeur  import session
    options=session.parse(sys.argv)
    if code != None : options.code = code
    if options.cataFile == None :
        print ('Use -c cata_name.py')
        return 0
    try    : fichier=options.comm[0]
    except : fichier=None
    if fichier==None :
        print ('comm file is needed')
        return 0

    monEficas = getEficas(code=options.code)
    monEditor = monEficas.getEditorForXSDGeneration(cataFile= options.cataFile,datasetFile=fichier, formatIn ='xml',formatOut = 'python')
    if not(monEditor.readercata.cata) : return 0
    if monEditor.jdc and not(monEditor.jdc.isValid()):
        print ('Fichier comm is not valid')
        return 0
    return monEditeur.saveUQFile(fichier)

def genereUQComm(code=None):
#-----------------------------
    from Editeur  import session
    options=session.parse(sys.argv)
    if code != None : options.code = code
    if options.cataFile == None :
        print ('Use -c cata_name.py')
        return 0
    try    : fichier=options.comm[0]
    except : fichier=None
    if fichier==None :
        print ('xml file is needed')
        return 0
    if options.fichierOut == None : fichierCommOut=fichier[:fichier.rfind(".")]+'.comm'
    else : fichierCommOut = options.fichierOut

    monEficas = getEficas(code=options.code)
    monEditor = monEficas.getEditorForXSDGeneration(cataFile= options.cataFile,datasetFile=fichier, formatIn ='xml',formatOut = 'python')
    if not(monEditor.readercata.cata) : return 0
    if not(monEditor.jdc) : return 0
    # on ne sait lire que des xml valides
    #PNPN
    return monEditor.saveUQFile(fichierCommOut)

def genereGitStringFormat (code=None):
#------------------------------
    from Editeur  import session
    options=session.parse(sys.argv)
    if code != None : options.code = code
    if options.cataFile == None :
        print ('Use -c cata_name.py')
        return

    monEficas = getEficas(code=options.code)
    monEditor = monEficas.getEditorForGeneration(cataFile = options.cataFile)
    texteGitStringFormat=monEditor.dumpGitStringFormat()
    print (texteGitStringFormat)



# Les deux fonctions ci-après ne sont pas utilisees mais 
# restent des idees interessantes

def validateFonction(laFonction, debug=False):
# ---------------------------------------------
# permet de verifier les arguments d une fonction python
# exposee dans un catalogue
# ceci etait juste une essai mais garde au cas ou  
    monEficas = getEficas(code="Essai")
    monEditor = monEficas.getEditor()
    print("_______ validateFonction", laFonction, laFonction.__name__)
    from functools import wraps
    from collections import OrderedDict
    from inspect import getargspec

    @wraps(laFonction)
    def fonctionValidee(*args, **kwargs):
        laFonctionName = laFonction.__name__
        if debug:
            print(
                "Appel {} avec args={} et kwargs={}".format(
                    laFonction.__name__, args, kwargs
                )
            )
        laDefDeLaFonctionDansAccas = getattr(monEditor.readercata.cata, laFonctionName)
        objConstruit = laDefDeLaFonctionDansAccas.makeObjetPourVerifSignature(
            *args, **kwargs
        )
        if objConstruit.isValid():
            ret = laFonction(*args, **kwargs)
            return ret
        else:
            print("mauvais arguments")
            print(objConstruit.CR())
            return None
    return fonctionValidee



def createObjetPythonFromDocumentAccas(cataFile=None, fichier=None, code=None):
# --------------------------------------------------------------------------------
# activeSurcharge permet de surcharger [ pour
# acceder aux objets Accas comme en python
# Attention peu testé et uniquement en lecture
# obsolete
    if fichier == None:
        print("file is needed")
        return None
    if cataFile == None:
        print("cata file is needed")
        return None

    from Accas.processing.P_OBJECT import activeSurcharge
    activeSurcharge()
    from .editorSsIhm import JDCEditorSsIhm

    monEficas = getEficas(code="Essai", cataFile=cataFile)
    monEditeur = JDCEditorSsIhm(monEficas, fichier)
    return monEditeur.jdc


if __name__ == "__main__":
    if repIni not in sys.path : sys.path.insert(0,repIni)
    lanceQtEficas(multi=True)
