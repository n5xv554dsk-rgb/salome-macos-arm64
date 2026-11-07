# -*- coding: utf8 -*-
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

import salomedsgui
from salome.kernel import salome

from salome.kernel import SALOMEDS
try:
    from salome.kernel import SMESH
except ImportError:
    pass

from salome.kernel.salome.kernel.logger import Logger
logger = Logger("EficasStudy")


# Nom des composants SALOME dans l'arbre d'étude
SMesh = "Mesh"
SGeom = "Geometry"
SVisu = "Post-Pro"
SAster = "Aster"


class SalomeStudy(salomedsgui.guiDS):
    """
    Classe de manipulation de l'arbre d'étude Salome. Cette classe permet à
    l'utilisateur de manipuler les objets de 'arbre d'étude via leurs
    identifiants( entry ).

    Attention : Par défaut les opérations réalisée par cette classe portent sur
    une étude courante ( positionnée dans le constructeur ou par la méthode
    setCurrentStudyID() )
    """
    def __init__(self, studyID=salome.myStudyId):
        salomedsgui.guiDS.__init__(self)
        self.setCurrentStudy(studyID)

        # spécifique méthode __getMeshType() :
        self.groupOp = None
        self.geomEngine = None

        # spécifique méthode createMesh() :
        self.smeshEngine = None

    # --------------------------------------------------------------------------
    #   fonctions de manipulation générale ( porte sur toute l'arbre d'étude )
    def __getCORBAObject(self, entry):
        """
        Retourne l'objet CORBA correspondant son identifiant ( entry ) dans
        l'arbre d'étude.

        @type   entry : string
        @param  entry : objet Corba

        @rtype  :  objet CORBA
        @return :  l'objet CORBA,   None si erreur.
        """
        sobject = None
        try:
            mySO = self._myStudy.FindObjectID(entry)
            if mySO:
                sobject = mySO.GetObject()

                if not sobject:  # l'objet n'a pas encore chargé
                    path = self._myStudy.GetObjectPath(mySO)  # recherche du nom du composant
                    componentName = (path.split('/')[1]).strip()

                    if componentName == SMesh:
                        strContainer, strComponentName = "FactoryServer", "SMESH"
                    elif componentName == SGeom:
                        strContainer, strComponentName = "FactoryServer", "GEOM"
                    elif componentName == SVisu:
                        strContainer, strComponentName = "FactoryServer", "VISU"
                    elif componentName == SAster:
                        strContainer, strComponentName = "FactoryServerPy", "ASTER"
                    else:
                        logger.debug('>>>>CS_Pbruno StudyTree.__getCORBAObject chargement du composant  %s non implémenté ' % componentName)
                        raise Exception('Erreur')

                    myComponent = salome.lcc.FindOrLoadComponent(strContainer, strComponentName)
                    SCom = self._myStudy.FindComponent(strComponentName)
                    self._myBuilder.LoadWith(SCom, myComponent)
                    sobject = mySO.GetObject()
        except:
            import sys
            ex_type = sys.exc_info()[0]
            ex_value = sys.exc_info()[1]
            logger.debug('>>>>CS_Pbruno StudyTree.__getCORBAObject erreur recupération  objet corba ( entry = %s ) ' % entry)
            logger.debug('type        = %s ,             value       = %s ' % (ex_type, ex_value))
            sobject = None

        return sobject

    def __getEntry(self, corbaObject):
        """
        Retourne l'identifiant ( entry ) ds l'arbre d'étude de l'objet CORBA
        passé en paramètre.

        @type     corbaObject : objet Corba
        @param  corbaObject   : objet Corba

        @rtype  :  string
        @return :  identifiant ( entry ),    None si erreur.
        """
        entry = None
        currentStudy = self._myStudy

        if corbaObject:
            ior = salome.orb.object_to_string(corbaObject)
            if ior:
                sObject = currentStudy.FindObjectIOR(ior)
                entry = sObject.GetID()
        return entry

    def setCurrentStudyID(self, studyID):
        """
        Fixe l'étude courante sur laquel vont opérer toutes les fonctions
        de la classe.
        """
        self._father = None
        self._component = None
        self._myStudy = self._myStudyManager.GetStudyByID(studyID)
        self._myBuilder = self._myStudy.NewBuilder()

        salome.myStudy = self._myStudy
        salome.myStudyId = studyID
        salome.myStudyName = self._myStudy._get_Name()

    def refresh(self):
        """
        Rafraichissement de l'arbre d'étude
        """
        salome.sg.updateObjBrowser(0)

    def setName(self, entry, name):
        """
        Fixe le nom( la valeur de l'attribut 'AttributeName' ) d'un objet de l'arbre d'étude
        désigné par son identifiant( entry )

        @type   entry: string
        @param  entry: identifiant de l'objet dans l'arbre d'étude

        @type   name: string
        @param  name: nom à attribuer

        @rtype  :  boolean
        @return :  True si Ok, False sinon, None si erreur
        """
        result = False
        try:
            SObject = self._myStudy.FindObjectID(entry)
            A1 = self._myBuilder.FindOrCreateAttribute(SObject, "AttributeName")
            AName = A1._narrow(SALOMEDS.AttributeName)
            AName.SetValue(name)
            result = True
        except:
            import sys
            ex_type = sys.exc_info()[0]
            ex_value = sys.exc_info()[1]
            logger.debug('>>>>CS_Pbruno StudyTree.setName ( entry = %s, name = %s )' % (entry, name))
            logger.debug('type        = %s ,             value       = %s ' % (ex_type, ex_value))
            result = None

        return result

    def hasName(self, componentName, objectName):
        """
        Vérifie si dans l'arbre d'étude le commposant de nom componentName
        possède un objet de nom objectName.

        @type   componentName: string
        @param  componentName: nom du composant Salome

        @type   objectName: string
        @param  objectName: nom de l'objet

        @rtype  :  boolean
        @return :  True si Ok, False sinon,  None si erreur
        """
        result = False
        try:
            nom = {
                SMesh:  "SMESH",
                SGeom:  "GEOM",
                SVisu:  "VISU",
                SAster: "ASTER"
            }
            componentName = nom[componentName]
            SObjects = self._myStudy.FindObjectByName(objectName, componentName)
            if len(SObjects) > 0:
                result = True
        except:
            import sys
            ex_type = sys.exc_info()[0]
            ex_value = sys.exc_info()[1]
            logger.debug('>>>>CS_Pbruno StudyTree.hasName ( componentName = %s, objectName = %s )' % (componentName, objectName))
            logger.debug('type        = %s ,             value       = %s ' % (ex_type, ex_value))
            result = None

        return result

    # --------------------------------------------------------------------------
    #   fonctions de manipulation des objets géométriques dans l'arbre d'étude
    #   ( éléments contenu dans la sous-rubrique "Geometry' )
    def isMainShape(self, entry):
        """
        Teste si l'objet désigné par l'identifiant ( entry ) passé en argument
        est bien un objet géométrique principal.

        @type   entry: string
        @param  entry: identifiant de l'objet

        @rtype:   boolean
        @return:  True si Ok, False sinon
        """
        result = False
        try:
            anObject = self.__getCORBAObject(entry)
            shape = anObject._narrow(GEOM.GEOM_Object)
            if shape.IsMainShape():
                result = True
        except:
            import sys
            ex_type = sys.exc_info()[0]
            ex_value = sys.exc_info()[1]
            logger.debug('>>>>CS_Pbruno StudyTree.isMainShape( entry = %s ) ' % entry)
            logger.debug('type        = %s ,             value       = %s ' % (ex_type, ex_value))
            result = False
        return result

    def getMainShapeEntry(self, entry):
        """
        Retourne l'identifiant de l'objet géométrique principal du sous-objet géométrique désigné par
        l'identifiant ( entry ) passé en paramètre.

        @type   entry: string
        @param  entry: identifiant du sous-objet géométrique

        @rtype  :  string
        @return :  identifiant de  l'objet géométrique principal, None si erreur.
        """
        result = None
        try:
            if self.isMainShape(entry):
                result = entry
            else:
                anObject = self.__getCORBAObject(entry)
                shape = anObject._narrow(GEOM.GEOM_Object)
                objMain = shape.GetMainShape()
                result = self.__getEntry(objMain)
        except:
            # import sys
            # ex_type = sys.exc_info()[0]
            # ex_value = sys.exc_info()[1]
            # print('>>>>CS_Pbruno StudyTree.getMainShapeEntry( entry = %s ) ' %entry)
            # print('type        = %s ,             value       = %s '%( ex_type, ex_value ))
            result = None

        return result

    def sameMainShape(self, shapeEntry1, shapeEntry2):
        """
        Détermine si les objets géometriques fournis en argument sont les
        sous-objets d'une même géométrie principale

        @type   shapeEntry1: string
        @param  shapeEntry1: identifiant dans l'arbre d'étude d'un objet géométrique

        @type   shapeEntry2: string
        @param  shapeEntry2: identifiant dans l'arbre d'étude d'un objet géométrique

        @rtype  :  boolean
        @return :  True si même objet principal, False sinon, None si erreur.
        """
        result = None
        try:
            mainShape1 = self.getMainShapeEntry(shapeEntry1)
            if mainShape1:
                mainShape2 = self.getMainShapeEntry(shapeEntry2)
                if mainShape2:
                    result = mainShape1 == mainShape2
        except:
            # import sys
            # ex_type = sys.exc_info()[0]
            # ex_value = sys.exc_info()[1]
            # print('>>>>CS_Pbruno StudyTree.sameMainShape(  shapeEntry1 = %s , shapeEntry2 = %s )'%( shapeEntry1, shapeEntry2 ))
            # print('type        = %s ,             value       = %s '%( ex_type, ex_value ))
            result = None

        return result

    # --------------------------------------------------------------------------
    #   fonctions de manipulation des objets maillages  dans l'arbre d'étude
    #   ( éléments contenu dans la sous-rubrique 'Mesh' )
    def __getMeshType(self, shapeEntry):
        """
        Determination du type de maille en fonction de la géométrie pour les conditions aux limites.

        @type     shapeEntry : string
        @param  shapeEntry : identifiant de l'objet géométrique

        @rtype:   SMESH::ElementType ( voir SMESH_Mesh.idl )
        @return:  type de maillage, None si erreur.
        """
        result = None

        try:
            anObject = self.__getCORBAObject(shapeEntry)
            shape = anObject._narrow(GEOM.GEOM_Object)

            if shape:  # Ok, c'est bien un objet géométrique
                tgeo = str(shape.GetShapeType())

                meshTypeStr = {
                    "VERTEX": SMESH.NODE,
                    "EDGE": SMESH.EDGE,
                    "FACE": SMESH.FACE,
                    "SOLID": SMESH.VOLUME,
                    "COMPOUND":  None
                }
                result = meshTypeStr[tgeo]
                if result is None:
                    if not self.geomEngine:
                        self.geomEngine = salome.lcc.FindOrLoadComponent("FactoryServer", "GEOM")
                    if not self.GroupOp:
                        self.GroupOp = self.geomEngine.GetIGroupOperations(salome.myStudyId)

                    tgeo = self.GroupOp.GetType(shape)
                    meshTypeInt = {  # Voir le dictionnnaire ShapeType dans geompy.py pour les correspondances type - numero.
                        7:      SMESH.NODE,
                        6:      SMESH.EDGE,
                        4:      SMESH.FACE,
                        2:      SMESH.VOLUME
                    }
                    if int(tgeo) in meshTypeInt:
                        result = meshTypeInt[tgeo]
        except:
            import sys
            ex_type = sys.exc_info()[0]
            ex_value = sys.exc_info()[1]
            logger.debug('>>>>CS_Pbruno StudyTree.__getMeshType( shapeEntry  = %s ) ' % shapeEntry)
            logger.debug('type        = %s ,             value       = %s ' % (ex_type, ex_value))
            result = None

        return result

    def getAllMeshReferencingMainShape(self, mainShapeEntry):
        """
        Retourne une liste de tous les maillages construits à partir de l'objet
        principal géométrique passé en argument

        @type     mainShapeEntry : string
        @param    mainShapeEntry : identifiant( entry ) de l'objet  principal géométrique

        @rtype:   list
        @return:  liste des identifiants( entry ) des maillages, liste vide si aucun , None si erreur.
        """
        result = []

        try:
            if self.isMainShape(mainShapeEntry):
                mainShapeSO = salome.IDToSObject(mainShapeEntry)
                SObjectList = self._myStudy.FindDependances(mainShapeSO)
                # print('####  mainShapeSO=%s , SObjectList  = %s'%( mainShapeSO, SObjectList ))
                if SObjectList:  # Ok, il y a des objet référençant la mainShape
                    for SObject in SObjectList:  # Recherche du type de chacun des objets
                        SFatherComponent = SObject.GetFatherComponent()
                        # print('####  SFatherComponent = %s'%SFatherComponent)
                        if SFatherComponent.GetName() == SMesh:  # Ok, l'objet est un objet du composant 'Mesh'
                            SFather = SObject.GetFather()
                            # print('####  SFather= %s'%SFather)
                            # #CorbaObject = SFather.GetObject()
                            FatherEntry = SFather.GetID()
                            CorbaObject = self.__getCORBAObject(FatherEntry)
                            # print('####  CorbaObject = %s'%CorbaObject)
                            MeshObject = CorbaObject ._narrow(SMESH.SMESH_Mesh)
                            # print('####  MeshObject = %s'%MeshObject)
                            if MeshObject:  # Ok, l'objet est un objet 'maillage'
                                MeshObjectEntry = self.__getEntry(MeshObject)
                                # print('####  MeshObjectEntry = %s'%MeshObjectEntry)
                                if MeshObjectEntry:
                                    result.append(MeshObjectEntry)  # On l'ajoute ds la liste résultat!
            else:  # c'est pas une mainShape !
                result = None
        except:
            import sys
            ex_type = sys.exc_info()[0]
            ex_value = sys.exc_info()[1]
            logger.debug('>>>>CS_Pbruno StudyTree.getAllMeshReferencingMainShape( mainShapeEntry  = %s ) ' % mainShapeEntry)
            logger.debug('type        = %s ,             value       = %s ' % (ex_type, ex_value))
            result = None

        return result

    def updateMesh(self, meshEntry, groupeMaEntries, groupeNoEntries):
        """
        Met à jours d'un objet maillage à partir d'une liste de sous-objet géométrique.
        L'opération consiste à créer des groupes dans le maillage correspondant
        aux sous-objets géométrique de la liste.

        CS_pbruno Attention: ajoute des groupes sans vérifier si auparavant ils ont déjà été crées

        @type   meshEntry : string
        @param  meshEntry : identifiant du maillage

        @type   groupeMaEntries : liste de string
        @param  groupeMaEntries : liste contenant les identifiants ( entry ) des sous-objets géométriques
                                  sur lesquel on veut construire des groupes de face.

        @type   groupeNoEntries : liste de string
        @param  groupeNoEntries : liste contenant les identifiants ( entry ) des sous-objets géométriques
                                  sur lesquel on veut construire des groupes de noeuds.

        @rtype:   bool
        @return:  True si update OK, False en cas d'erreur
        """
        result = False
        try:
            # print('CS_pbruno updateMesh( self,  meshEntry=%s,   groupeMaEntries=%s )'%( meshEntry,   groupeMaEntries ))
            corbaObject = self.__getCORBAObject(meshEntry)
            mesh = corbaObject._narrow(SMESH.SMESH_Mesh)

            if mesh:  # Ok, c'est bien un maillage
                shapeName = ""
                meshType = None

                # création groupes de noeud
                for shapeEntry in groupeNoEntries:
                    anObject = self.__getCORBAObject(shapeEntry)
                    shape = anObject._narrow(GEOM.GEOM_Object)
                    if shape:  # Ok, c'est bien un objet géométrique
                        shapeName = self.getNameAttribute(shapeEntry)
                        mesh.CreateGroupFromGEOM(SMESH.NODE, shapeName, shape)
                    else:
                        pass  # CS_pbruno au choix: 1)une seule erreur arrète l'intégralité de l'opération
                        # return False   #                    2)ou on continue et essaye les suivants ( choix actuel

                # création groupes de face
                for shapeEntry in groupeMaEntries:
                    meshType = self.__getMeshType(shapeEntry)
                    if meshType:
                        anObject = self.__getCORBAObject(shapeEntry)
                        shape = anObject._narrow(GEOM.GEOM_Object)
                        if shape:  # Ok, c'est bien un objet géométrique
                            shapeName = self.getNameAttribute(shapeEntry)
                            mesh.CreateGroupFromGEOM(meshType, shapeName, shape)
                        else:
                            pass  # CS_pbruno au choix: 1)une seule erreur arrète l'intégralité de l'opération
                            # return False   #                    2)ou on continue et essaye les suivants ( choix actuel )
                    else:
                        pass  # CS_pbruno au choix: 1)une seule erreur arrète l'intégralité de l'opération
                        # return False   #                    2)ou on continue et essaye les suivants ( choix actuel )

                result = True

        except:
            import sys
            ex_type = sys.exc_info()[0]
            ex_value = sys.exc_info()[1]
            logger.debug('>>>>CS_Pbruno StudyTree.updateMesh( meshEntry= %s,   groupeMaEntries = %s )' % (meshEntry, groupeMaEntries))
            logger.debug('type        = %s ,             value       = %s ' % (ex_type, ex_value))
            result = None
        return result

    def createMesh(self, newMeshName, mainShapeEntry, groupeMaEntries, groupeNoEntries):
        """
        Création d'un objet maillage à partir d'un objet géométrique principal
        Les groupes dans le maillage sont crée à partir des sous-objets géométriques
        contenu dans la liste fourni en paramètre d'entré.

        @type   newMeshName : string
        @param  newMeshName : nom du nouveau maillage

        @type   mainShapeEntry : string
        @param  mainShapeEntry : identifiant de l'objet géométrique principal

        @type   groupeMaEntries : liste de string
        @param  groupeMaEntries : liste contenant les identifiants ( entry ) des sous-objets géométriques
                                  sur lesquel on veut construire des groupes de face.

        @type   groupeNoEntries : liste de string
        @param  groupeNoEntries : liste contenant les identifiants ( entry ) des sous-objets géométriques
                                  sur lesquel on veut construire des groupes de noeuds.

        @rtype:   string
        @return:  identifiant( entry ) dans l'arbre d'étude du nouveau maillage, None en cas d'erreur.
        """
        result = False
        try:
            # print('CS_pbruno createMesh( self, newMeshName=%s, mainShapeEntry=%s, groupeMaEntries=%s )'
            #      % (newMeshName, mainShapeEntry, groupeMaEntries))
            newMesh = None
            anObject = self.__getCORBAObject(mainShapeEntry)
            shape = anObject._narrow(GEOM.GEOM_Object)
            if shape:
                # Création du nouveau maillage
                if not self.smeshEngine:
                    self.smeshEngine = salome.lcc.FindOrLoadComponent("FactoryServer", "SMESH")
                    self.smeshEngine.SetCurrentStudy(salome.myStudy)
                newMesh = self.smeshEngine.CreateMesh(shape)
                newMeshEntry = self.__getEntry(newMesh)
                if newMeshEntry:
                    ok = self.setName(newMeshEntry, newMeshName)
                    if ok:
                        result = self.updateMesh(newMeshEntry, groupeMaEntries, groupeNoEntries)
        except:
            import sys
            ex_type = sys.exc_info()[0]
            ex_value = sys.exc_info()[1]
            logger.debug('>>>>CS_Pbruno StudyTree.createMesh( self, newMeshName=%s, mainShapeEntry=%s, groupeMaEntries=%s )'
                         % (newMeshName, mainShapeEntry, groupeMaEntries))
            logger.debug('type        = %s ,             value       = %s ' % (ex_type, ex_value))
            result = None
        return result


# --------------------------------------------------------------------------
#   INIT
study = SalomeStudy()

