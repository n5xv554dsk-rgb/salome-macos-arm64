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


import os
import re
import sys
import traceback

from PyQt5.QtWidgets import QApplication
from PyQt5.QtWidgets import QMessageBox


from salome.kernel.salome.kernel.logger import Logger
logger = Logger("EFICAS_SRC.EFICASGUI.eficasSalome.py")

import eficasConfig
# eficasConfig definit le EFICAS_ROOT
# lignes de path ajoutees pour acceder aux packages python du
# logiciel Eficas. Le package Aster est ajoute explicitement pour
# acceder au module prefs.py. A
# ajout de InterfaceQT4 pour permettre l acces a la fenetre Option
sys.path[:0] = [eficasConfig.eficasPath, ]

GUIPath='QT5'
if "EFICAS_TOOLS_ROOT"  in  os.environ:
   eficasToolPath = os.environ["EFICAS_TOOLS_ROOT"]
   interfacePath=os.path.join(eficasToolPath,'InterfaceGUI',GUIPath)
   sys.path[:0] = [interfacePath]
else :
   print ('______________________________')
   print ('definir EFICAS_TOOLS_ROOT')
   print ('______________________________')

#import Editeur
from InterfaceGUI.QT5 import qt_eficas

from salome.kernel import salome
import SalomePyQt
sgPyQt = SalomePyQt.SalomePyQt()
langue = str(sgPyQt.stringSetting("language", "language"))

from salome.kernel.salome.kernel.studyedit import getStudyEditor

# couleur pour visualisation des geometries
import colors
COLORS = colors.ListeColors
LEN_COLORS = len(COLORS)

#from Extensions import localisation
#localisation.localise(None, langue)


class MyEficas(qt_eficas.QtEficasAppli):
    """
    Classe de lancement du logiciel EFICAS dans SALOME
    Cette classe specialise le logiciel Eficas par l'ajout de:
    a)la creation de groupes de mailles dans le composant SMESH de SALOME
    b)la visualisation d'elements geometrique dans le coposant GEOM de SALOME par selection dans EFICAS
    """
    def __init__(self, parent, code=None, fichier=None, module="EFICAS",
                 version=None, componentName="Eficas", multi=False ):
        """
        Constructeur.
        @type   parent:
        @param  parent: widget Qt parent
        @type   code: string
        @param  code: catalogue a lancer
        @type   fichier: string
        @param  fichier: chemin absolu du fichier eficas a ouvrir a das le lancement. optionnel
        """

        dictPathCode = {'ADAO': 'Adao', 'MT': 'MT', 'CARMEL3D': 'Carmel3D', 'CF': 'CF',
                        'SPECA': 'SPECA', 'MAP': 'MAP', 'SEP': 'SEP', 'TELEMAC': 'Telemac'}

        if code in dictPathCode:
            pathCode = dictPathCode[code]
            sys.path[:0] = [os.path.join(eficasConfig.eficasPath, 'Codes', pathCode)]

        from Editeur import session
        options = session.parse(['eficasFromSalome'])

        self.editor = getStudyEditor()  # Editeur de l'arbre d'etude

        lang = str(sgPyQt.stringSetting("language", "language"))
        # les deux methodes conviennent pour trouver la langue
        # cela permet de se souvenir comment utiliser le launchConfigureParser
        from EFICASGUI import salomeLanguage
        langue = salomeLanguage
        if lang != langue : print ("WARNING : pb sur le langage")

        #qt_eficas.Appli.__init__(self, code=code, salome=1, parent=parent, multi=multi, langue=langue)
        qt_eficas.QtEficasAppli.__init__(self, code=code, salome=1,  multi=multi, langue=langue, parent=parent)

        # --------------- specialisation EFICAS dans SALOME  -------------------
        self.parent = parent
        self.salome = True  # active les parties de code specifique dans Salome( pour le logiciel Eficas )
        self.module = module  # indique sous quel module dans l'arbre d'etude ajouter le JDC.
        self.componentName = componentName

        # donnee pour la creation de groupe de maille
        # dictionnaire pour gerer les multiples fichiers possibles ouverts par
        # eficas ( cle = identifiant du JDC ), une mainshape par fichier ouvert.
        # dictionnaire des sous-geometrie de la geometrie principale ( cle = entry, valeur = name )
        self.mainShapeNames = {}
        # ----------------------------------------------------------------------

        self.icolor = 0  # compteur pour memoriser la couleur courante
        self.show()

    def closeEvent(self, event):
        res = self.fileExit()
        if res == 2:
            event.ignore()
            return
        if hasattr(self, 'readercata'):
            del self.readercata

        from Accas.extensions.param2 import originalMath
        originalMath.toOriginal()

        global appli
        appli = None
        event.accept()

# ___________________________ Methodes de l ex Pal __________________________________

    def getCORBAObjectInComponent(self, entry, composant):
        sobject = None
        mySO = self.editor.study.FindObjectID(entry)
        if mySO:
            sobject = mySO.GetObject()
            if not object:
                myComponent = salome.lcc.FindOrLoadComponent("FactoryServer", composant)
                SCom = self.editor.study.FindComponent(composant)
                print(myComponent, SCom)
                self.editor.builder.LoadWith(SCom, myComponent)
                sobject = mySO.GetObject()
        if not sobject:
            logger.debug("selectedEntry: An error occurs")
        return sobject

    def giveMeshGroups(self, entry, label1, typeMesh):
        msg = None
        names = []
        from salome.kernel import SMESH
        try:
            monMaillage = self.getCORBAObjectInComponent(entry, "SMESH")
            if monMaillage is not None:  # selection d'un groupe de SMESH
                if monMaillage._narrow(SMESH.SMESH_Mesh):
                    mailSO = self.editor.study.FindObjectID(entry)
                    if mailSO is None:
                        return names, msg

                    subIt = self.editor.study.NewChildIterator(mailSO)
                    while subIt.More():
                        subSO = subIt.Value()
                        subIt.Next()

                        if (subSO.GetName()[0:9] != label1):
                            continue
                        subSSMeshit = self.editor.study.NewChildIterator(subSO)
                        while subSSMeshit.More():
                            subSSMeshSO = subSSMeshit.Value()
                            subSSMeshit.Next()
                            if subSSMeshSO.GetObject()._narrow(typeMesh):
                                names.append(subSSMeshSO.GetName())
                else:
                    msg = entry + self.tr(" n est pas un maillage")
        except:
            logger.debug(' giveMeshGroups pb avec ( entry = %s ) ' % entry)
            msg = ' giveMeshGroup pb avec ( entry = %s ) ' + entry
        return names, msg

    def isMeshGroup(self, entry):
        result = False
        from salome.kernel import SMESH
        try:
            monObjet = self.getCORBAObjectInComponent(entry, "SMESH")
            if monObjet is not None:  # selection d'un groupe de SMESH
                if monObjet._narrow(SMESH.SMESH_GroupBase):
                    result = True
        except:
            logger.debug(' isMeshGroup pb avec ( entry = %s ) ' % entry)
        return result

    def isMesh(self, entry):
        result = False
        from salome.kernel import SMESH
        try:
            monObjet = self.getCORBAObjectInComponent(entry, "SMESH")
            if monObjet is not None:  # selection d'un groupe de SMESH
                if monObjet._narrow(SMESH.SMESH_Mesh):
                    result = True
        except:
            logger.debug(' isMesh pb avec ( entry = %s ) ' % entry)
        return result

    def getMesh(self, entry):
        meshObject = None
        from salome.kernel import SMESH
        try:
            monObjet = self.getCORBAObjectInComponent(entry, "SMESH")
            if monObjet is not None:  # selection d'un groupe de SMESH
                meshObject = monObjet._narrow(SMESH.SMESH_Mesh)
        except:
            logger.debug('  pb avec ( entry = %s ) ' % entry)
        return meshObject

    def isShape(self, entry):
        result = False
        from salome.kernel import GEOM
        try:
            monObjet = self.getCORBAObjectInComponent(entry, "GEOM")
            if monObjet is not None:  # selection d'un objet GEOM
                if monObjet._narrow(GEOM.GEOM_Object):
                    result = True
        except:
            logger.debug(' isShape pb avec ( entry = %s ) ' % entry)
        return result

    def getMainShapeEntry(self, entry):
        result = None
        try:
            mainShapeEntry = entry.split(':')[:4]
            if len(mainShapeEntry) == 4:
                strMainShapeEntry = '%s:%s:%s:%s' % tuple(mainShapeEntry)
                if self.isMainShape(strMainShapeEntry):
                    result = strMainShapeEntry
        except:
            logger.debug('Erreur pour SalomeStudy.getMainShapeEntry( entry = %s ) ' % entry)
            result = None
        return result

    def isMainShape(self, entry):
        result = False
        try:
            monObjet = self.getCORBAObjectInComponent(entry, "GEOM")
            from salome.kernel import GEOM
            shape = monObjet._narrow(GEOM.GEOM_Object)
            if shape.IsMainShape():
                result = True
        except:
            logger.debug('Errreur pour SalomeStudy.isMainShape( entry = %s ) ' % entry)
            result = False
        return result

    def ChercheType(self, shape):
        tgeo = shape.GetShapeType()
        geomEngine = salome.lcc.FindOrLoadComponent("FactoryServer", "GEOM")
        groupIMeasureOp = geomEngine.GetIMeasureOperations(self.editor.study._get_StudyId())
        if tgeo != "COMPOUND":
            return tgeo

        strInfo = groupIMeasureOp.WhatIs(shape)
        dictInfo = {}
        l = strInfo.split('\n')

        for couple in l:
            nom, valeur = couple.split(':')
            dictInfo[nom.strip()] = valeur.strip()

        ordre = ["COMPSOLID", "SOLID", "SHELL", "FACE", "WIRE", "EDGE", "VERTEX"]
        for t in ordre:
            if dictInfo[t] != '0':
                tgeo = t
                return tgeo
        return None

    def selectShape(self, editor, entry, kwType=None):
        """
        selection sous-geometrie dans Salome:
        -test1) si c'est un element sous-geometrique .
        -test2) si appartient a la geometrie principale.
        """
        name, msgError = '', ''
        mySO = self.editor.study.FindObjectID(entry)
        if mySO is None:
            return name, msgError
        sobject = mySO.GetObject()
        if sobject is None:
            return name, msgError

        from salome.kernel import GEOM
        shape = sobject._narrow(GEOM.GEOM_Object)
        if not shape:
            return name, msgError

        tGeo = self.ChercheType(shape)
        if not tGeo:
            return name, msgError
        if kwType == "GROUP_MA" and str(tGeo) == "VERTEX":
            name, msgError = '', "la selection n est pas un groupe de maille"
            return name, msgError

        mainShapeEntry = self.getMainShapeEntry(entry)
        if editor in self.mainShapeNames:
            if self.mainShapeNames[editor] == mainShapeEntry:
                name = mySO.GetName()
            else:
                msgError = "Le groupe reference la geometrie " + mainShapeEntry + " et non " + self.mainShapeNames[editor]
        else:
            self.mainShapeNames[editor] = mainShapeEntry
            name = mySO.GetName()

        return name, msgError

    def selectMeshGroup(self, editor, selectedEntry, kwType=None):
        """
        selection groupe de maille dans Salome:
        -test 1) si c'est un groupe de maille
        -test 2) si le maillage fait reference a la geometrie principale
        """
        name, msgError = '', ''

        mySO = self.editor.study.FindObjectID(selectedEntry)
        from salome.smesh.smeshstudytools import SMeshStudyTools
        monSMeshStudyTools = SMeshStudyTools(self.editor)
        meshSO = monSMeshStudyTools.getMeshFromGroup(mySO)
        if meshSO is None:
            return name, msgError

        # on verifie que l entree selectionnee a le bon type (NODE ou EDGE...)
        tGroup = ""
        groupObject = self.getCORBAObjectInComponent(selectedEntry, "SMESH")
        if not groupObject:
            logger.debug("selectedMeshEntry: An error occurs")

        from salome.kernel import SMESH
        aGroup = groupObject._narrow(SMESH.SMESH_GroupBase)
        if aGroup:
            tGroup = aGroup.GetType()

        if kwType == "GROUP_NO" and tGroup != SMESH.NODE:
            msgError = self.tr("GROUP_NO attend un groupe de noeud")
            return name, msgError
        elif kwType == "GROUP_MA" and tGroup == SMESH.NODE:
            msgError = self.tr("GROUP_MA attend un point goupe de maille")
            return name, msgError

        # on cherche la shape associee
        # PN PN mesh_Object est un SOject
        meshObject = meshSO.GetObject()
        mesh = meshObject._narrow(SMESH.SMESH_Mesh)
        if mesh:  # c'est bien un objet maillage
            shape = mesh.GetShapeToMesh()
            if shape:
                ior = salome.orb.object_to_string(shape)
                if ior:
                    sObject = self.editor.study.FindObjectIOR(ior)
                    mainShapeID = sObject.GetID()
            else:
                mainShapeID = 0
        else:
            return name, self.tr("Type d objet non permis")

        # on cherche si la shape associee est la bonne
        if editor in self.mainShapeNames:
            if self.mainShapeNames[editor] == mainShapeID:
                name = mySO.GetName()
            else:
                msgError = self.tr("Le groupe reference la geometrie ") + mainShapeID + self.tr(" et non ") + self.mainShapeNames[editor]
        else:
            self.mainShapeNames[editor] = mainShapeID
            name = mySO.GetName()

        return name, msgError

    def displayMeshGroups(self, meshGroupName):
        """
        visualisation group de maille de nom meshGroupName dans salome
        """
        ok, msgError = False, ''
        try:
            sg = salome.ImportComponentGUI('SMESH')
#             meshGroupEntries = []
#             selMeshEntry = None
#             selMeshGroupEntry = None

            # liste des groupes de maille de nom meshGroupName
            listSO = self.editor.study.FindObjectByName(meshGroupName, "SMESH")

            if len(listSO) > 1:
                return 0, self.tr('Plusieurs objets  portent ce nom')
            if len(listSO) == 0:
                return 0, self.tr('Aucun objet ne porte ce nom')
            SObjet = listSO[0]
            groupEntry = SObjet.GetID()
            myComponent = salome.lcc.FindOrLoadComponent("FactoryServer", "SMESH")
            SCom = self.editor.study.FindComponent("SMESH")
            myBuilder = self.editor.study.NewBuilder()
            myBuilder.LoadWith(SCom, myComponent)
            sg.CreateAndDisplayActor(groupEntry)
            # color = COLORS[ self.icolor % LEN_COLORS ]
            # self.icolor = self.icolor + 1
            # sg.SetColor(groupEntry, color[0], color[1], color[2])
            salome.sg.Display(groupEntry)
            salome.sg.FitAll()
            ok = True

        except:
            msgError = self.tr("Impossible d afficher ") + meshGroupName
            logger.debug(50 * '=')
        return ok, msgError

# ___________________________ Methodes appelees par EFICAS  __________________________________
    def selectGroupFromSalome(self, kwType=None, editor=None):
        """
        Selection d'element(s) d'une geometrie ( sub-shape ) ou d'element(s) de maillage ( groupe de maille)  partir de l'arbre salome
        retourne ( la liste des noms des groupes, message d'erreur )

        Note: Appele par EFICAS lorsqu'on clique sur le bouton ajouter la liste du panel GROUPMA
        """
        names, msg = [], ''
        try:
            atLeastOneStudy = self.editor.study
            if not atLeastOneStudy:
                return names, msg

            # recupere toutes les selections de l'utilsateur dans l'arbre Salome
            entries = salome.sg.getAllSelected()
            nbEntries = len(entries)
            if nbEntries >= 1:
                for entry in entries:
                    if self.isMeshGroup(entry):  # selection d 'un sous maillage
                        name, msg = self.selectMeshGroup(editor, entry, kwType)
                    elif self.isShape(entry):  # selection d'une sous-geometrie
                        name, msg = self.selectShape(editor, entry, kwType)
                    else:
                        name, msg = None, self.tr("Selection SALOME non autorisee.")
                    if name:
                        names.append(name)

        except:
            logger.debug("selectGroupFromSalome: An error occurs")
        return names, msg

    def selectMeshFile(self, editor=None):
        """
        """
        try:
            atLeastOneStudy = self.editor.study
            if not atLeastOneStudy:
                return "", 'Pas d etude'

            # recupere toutes les selections de l'utilsateur dans l'arbre Salome
            entries = salome.sg.getAllSelected()
            nbEntries = len(entries)
            if nbEntries != 1:
                return "", 'select a Mesh'
            entry = entries[0]
            if not self.isMesh(entry):
                return "", 'select a Mesh'
            mySO = self.editor.study.FindObjectID(entry)
            print(mySO)
            ok, anAttr = mySO.FindAttribute("AttributeName")
            if not ok:
                return "", 'Pb de nommage'
            meshFile = "/tmp/" + str(anAttr.Value()) + '.med'
            myMesh = self.getMesh(entry)
            if myMesh is None:
                return "", 'Pb dans la selection '
            myMesh.ExportMED(meshFile, 0)
            return meshFile, ""
        except:
            return "", "Pb dans la selection "

    def importMedFile(self, fileName, editor=None):
        try:
            theStudy = self.editor.study
            if not theStudy:
                return (0, 'Pas d etude')
            from salome.smesh import smeshBuilder
            smesh = smeshBuilder.New(theStudy)
            smesh.CreateMeshesFromMED(fileName)
            salome.sg.updateObjBrowser()
            return 1, ""
        except:
            return (0, "Pb a l import")

    def selectEntryFromSalome(self, kwType=None, editor=None):
        """
        Selection d'element a partir de l'arbre salome
        Ne verifie que l unicite de la selection
        retourne ( la liste avec le  nom du groupe, message d'erreur )

        retourne une liste pour etre coherent avec selectGroupFromSalome
        Note: Appele par EFICAS lorsqu'on clique sur le bouton ajouter la liste du panel SalomeEntry
        """
        try:
            if self.editor.study._non_existent():
                raise Exception(self.tr("L'etude Salome n'existe plus"))
            entries = salome.sg.getAllSelected()
            nbEntries = len(entries)
            if nbEntries < 1:
                raise Exception(self.tr("Veuillez selectionner une entree de l'arbre d'etude de Salome"))
            elif nbEntries > 1:
                raise Exception(self.tr("Une seule entree doit être selectionnee dans l'arbre d'etude de Salome"))

            value = kwType.get_selected_value(entries[0], self.editor)
            msg = self.tr("L'entree de l'arbre d'etude de Salome a ete selectionnee")
            return [value], msg
        except Exception as e:
            QMessageBox.information(self, self.tr("Selection depuis Salome"), str(e))
            return [], str(e)

    def addJdcInSalome(self, jdcPath):
        """
        Ajoute le Jeu De Commande dans l'arbre d'etude Salome dans la rubrique EFICAS
        Revu pour QT4
        """
        msgError = "Erreur dans l'export du fichier de commande dans l'arbre d'etude Salome"
        if jdcPath == "" or jdcPath is None:
            return
        ok = False
        try:
            atLeastOneStudy = self.editor.study
            if not atLeastOneStudy:
                return ok, msgError

            fileType = {'TELEMAC'   : "FICHIER_EFICAS_TELEMAC",
                        'ADAO'      : "FICHIER_EFICAS_ADAO",
                        'SEP'       : "FICHIER_EFICAS_SEP",
                        'SPECA'     : "FICHIER_EFICAS_SPECA",
                        'MT'        : "FICHIER_EFICAS_MT",
                        'CF'        : "FICHIER_EFICAS_CF",
                        'MAP'       : "FICHIER_EFICAS_MAP",
                        'CARMEL3D'  : "FICHIER_EFICAS_CARMEL3D",
                        }


            folderName = {'TELEMAC' : "TelemacFiles",
                          'ADAO'    : "AdaoFiles",
                          'SEP'     : "SepFiles",
                          'SPECA'   : "SpecaFiles",
                          'MT'      : "MTFiles",
                          'CF'      : "CFFiles",
                          'CARMEL3D': 'CARMEL3DFiles' ,
                          'MAP'     : 'MapFiles' ,
                          }


            folderType = {'TELEMAC'  : "TELEMAC_FILE_FOLDER",
                          'ADAO'     : "ADAO_FILE_FOLDER",
                          'SEP'      : "SEP_FILE_FOLDER",
                          'SPECA'    : "SPECA_FILE_FOLDER",
                          'MT'       : "MT_FILE_FOLDER",
                          'CF'       : "CF_FILE_FOLDER",
                          'SEP'      : "SEP_FILE_FOLDER",
                          'MAP'      : "MAP_FILE_FOLDER",
                          'CARMEL3D' : "CARMEL3D_FILE_FOLDER",
                          }

            moduleEntry = self.editor.findOrCreateComponent(self.module, self.componentName)
            itemName = re.split("/", jdcPath)[-1]

            if self.code in folderName:
                monFolderName = folderName[self.code]
            else:
                monFolderName = str(self.code) + "Files"

            if self.code in folderType:
                monFolderType = fileType[self.code]
            else:
                monFolderType = str(self.code) + "_FILE_FOLDER"

            if self.code in fileType:
                monFileType = fileType[self.code]
            else:
                monFileType = "FICHIER_EFICAS_" + str(self.code)

            fatherEntry = self.editor.findOrCreateItem(
                                    moduleEntry,
                                    name=monFolderName,
                                    # icon = "ICON_COMM_FOLDER",
                                    fileType=monFolderType)

            commEntry = self.editor.findOrCreateItem(fatherEntry,
                                                     name=itemName,
                                                     fileType=monFileType,
                                                     fileName=jdcPath,
                                                     # icon    = "ICON_COMM_FILE",
                                                     comment=str(jdcPath))

            salome.sg.updateObjBrowser()

            if commEntry:
                ok, msgError = True, ''
        except Exception as exc:
            msgError = "Can't add Eficas file to Salome study tree"
            logger.debug(msgError, exc_info=True)
            QMessageBox.warning(self, self.tr("Warning"),
                                self.tr("%s. Raison:\n%s\n\n Voir la log pour plus de details " % (msgError, exc)))
        return ok, msgError

    def displayShape(self, shapeName):
        """
        visualisation de nom shapeName dans salome
        """
        ok, msgError = False, ''
        try:
            import SalomePyQt
            sgPyQt = SalomePyQt.SalomePyQt()
            myActiveView = sgPyQt.getActiveView()
            if myActiveView < 0:
                return ok, 'pas de vue courante'

            currentViewType = sgPyQt.getViewType(myActiveView)
            if str(currentViewType) != "OCCViewer":  # maillage
                ok, msgError = self.displayMeshGroups(shapeName)
            else:  # geometrie
                current_color = COLORS[self.icolor % LEN_COLORS]
                from salome.geom.geomtools import GeomStudyTools
                myGeomTools = GeomStudyTools(self.editor)
                ok = myGeomTools.displayShapeByName(shapeName, current_color)
                salome.sg.FitAll()
                self.icolor = self.icolor + 1
                if not ok:
                    msgError = self.tr("Impossible d afficher ") + shapeName
        except:
            logger.debug(50 * '=')
        return ok, msgError

    def ChercheGrpMeshInSalome(self):
        print("je passe par la")
        from salome.kernel import SMESH
        names, msg = [], ''
        try:
            entries = salome.sg.getAllSelected()
            nbEntries = len(entries)
            names, msg = None, self.tr("Selection SALOME non autorisee.")
            if nbEntries == 1:
                for entry in entries:
                    names, msg = self.giveMeshGroups(entry, "SubMeshes", SMESH.SMESH_subMesh)
        except:
            print("bim bam boum")
        return(msg, names)

    def ChercheGrpMailleInSalome(self):
        from salome.kernel import SMESH
        names, msg = [], ''
        try:
            entries = salome.sg.getAllSelected()
            nbEntries = len(entries)
            names, msg = None, self.tr("Selection SALOME non autorisee.")
            if nbEntries == 1:
                for entry in entries:
                    print(entry)
                    names, msg = self.giveMeshGroups(entry, "Groups of", SMESH.SMESH_GroupBase)
                    print(names)
        except:
            print("bim bam boum")
        return(msg, names)

# -------------------------------------------------------------------------------------------------------
#    Pilotage de la Visu des elements de structures
#
    def envoievisu(self, liste_commandes):
        try:
            from salome.geom.structelem import StructuralElementManager, InvalidParameterError
        except ImportError:
            QMessageBox.critical(self, self.tr("Error"),
                                 self.tr("Impossible d'afficher les elements de structure: "
                                         "module GEOM n est pas  installe."))
            return
        try:
            atLeastOneStudy = self.editor.study
            if not atLeastOneStudy:
                return
            logger.debug(10 * '#' + ":envoievisu: creating a StructuralElementManager instance")
            structElemManager = StructuralElementManager()
            elem = structElemManager.createElement(liste_commandes)
            elem.display()
            salome.sg.updateObjBrowser()
        except InvalidParameterError as err:
            trStr = self.tr("Invalid parameter for group %(group)s: %(expr)s must be "
                            "greater than %(minval)g (actual value is %(value)g)")
            msg = str(trStr) % {"group": err.groupName, "expr": err.expression,
                                "minval": err.minValue, "value": err.value}
            QMessageBox.warning(self, self.tr("Error"), msg)
        except:
            traceback.print_exc()
            logger.debug(10 * '#' + ":pb dans envoievisu")


class SalomeEntry:
    """
    This class replaces the class Accas.SalomeEntry (defined in EFICAS tool)
    when Eficas is launched in Salome context. It handles the objects that can
    be selected from Salome object browser.
    By default, the selected value is the entry of the selected item in the
    object browser. This class can be subclassed to provide more advanced
    functions.
    """

    help_message = "Une entree de l'arbre d'etude de Salome est attendue"

    def __init__(self, entryStr):
        self._entry = entryStr

    @staticmethod
    def __convert__(entryStr):
        return SalomeEntry(entryStr)

    @staticmethod
    def get_selected_value(selected_entry, study_editor):
        return selected_entry


# -------------------------------------------------------------------------------------------------------
#           Point d'entree lancement EFICAS
#
def runEficas(code=None, fichier=None, module="EFICAS", version=None, componentName="Eficas", multi=False):
    logger.debug(10 * '#' + ":runEficas: START")
    # global appli
    logger.debug(10 * '#' + ":runEficas: code=" + str(code))
    logger.debug(10 * '#' + ":runEficas: fichier=" + str(fichier))
    logger.debug(10 * '#' + ":runEficas: module=" + str(module))
    logger.debug(10 * '#' + ":runEficas: version=" + str(version))

    # if not appli: #une seul instance possible!
    appli = MyEficas(SalomePyQt.SalomePyQt().getDesktop(), code=code, fichier=fichier,
                     module=module, version=version, componentName=componentName, multi=multi)
    # if not appli: #une seul instance possible!
    #    appli = MyEficas( SalomePyQt.SalomePyQt().getDesktop(), code = code, fichier = fichier,
    #                      module = module, componentName = componentName, version=version )
    logger.debug(10 * '#' + ":runEficas: END")

