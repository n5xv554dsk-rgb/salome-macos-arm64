# Copyright (C) 2019-2026  CEA, EDF
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

# ======================================================================================
# Module adding some methods to CORBA API of GEM_Gen, analogously to geomBuilder.py.
#   WARNING: do not try to use it in the same way as geomBuilder because
# it provides limited functionality, it implements only methods used by smeshBuilder
#
# Typical use is:
#     import shaperBuilder
#     shaper = shaperBuilder.New()
#     from salome.smesh import smeshBuilder
#     smesh = smeshBuilder.New( instanceGeom = shaper )
#
# ======================================================================================

import SHAPERSTUDY
from salome.kernel import GEOM
from salome.kernel import SALOME_DriverPy

# Warning: geom is a singleton
geom = None
engine = None
doLcc = False
created = False

class shaperBuilder(SHAPERSTUDY.SHAPERSTUDY):

    ## Enumeration ShapeType as a dictionary
    ShapeType = SHAPERSTUDY.SHAPERSTUDY.ShapeType

    def __new__(cls, *args):
        global engine
        global geom
        global doLcc
        global created
        if geom is None:
            # geom engine is either retrieved from engine, or created
            geom = engine
            # Following test avoids a recursive loop
            if doLcc:
                if geom is not None:
                    # geom engine not created: existing engine found
                    doLcc = False
                if doLcc and not created:
                    doLcc = False
                    # FindOrLoadComponent called:
                    # 1. CORBA resolution of server
                    # 2. the __new__ method is called again
                    from SHAPERSTUDY_utils import getLCC
                    geom = getLCC().FindOrLoadComponent( "FactoryServer", "SHAPERSTUDY" )
            else:
                # FindOrLoadComponent not called
                if geom is None:
                    # geomBuilder instance is created from lcc.FindOrLoadComponent
                    geom = super(shaperBuilder,cls).__new__(cls)
                else:
                    # geom engine not created: existing engine found
                    pass
            return geom

        return geom

    def __init__(self, *args):
        global created
        if not created:
            created = True
            GEOM._objref_GEOM_Gen.__init__(self, *args)
            from SHAPERSTUDY_utils import moduleName
            SALOME_DriverPy.SALOME_DriverPy_i.__init__(self, moduleName())
            self.BasicOp  = None
            self.CurvesOp = None
            self.PrimOp   = None
            self.ShapesOp = self.GetIShapesOperations()
            self.HealOp   = None
            self.InsertOp = None
            self.BoolOp   = None
            self.TrsfOp   = None
            self.LocalOp  = None
            self.MeasuOp  = self.GetIMeasureOperations()
            self.BlocksOp = None
            self.GroupOp  = self.GetIGroupOperations()
            self.FieldOp  = None
            pass

    def init_geom(self):
        return

    def CreateGroup(self, theMainShape, theShapeType, theName=None):
        """
        Creates a new group which will store sub-shapes of theMainShape
        """
        # used in Mesh.GetFailedShapes()
        anObj = self.GroupOp.CreateGroup(theMainShape, theShapeType)
        RaiseIfFailed("CreateGroup", self.GroupOp)
        return anObj

    def ExtractShapes(self, aShape, aType, isSorted = False, theName=None):
        """
        Extract shapes (excluding the main shape) of given type.
        """
        ListObj = self.ShapesOp.ExtractSubShapes(aShape, EnumToLong( aType ), isSorted)
        RaiseIfFailed("ExtractSubShapes", self.ShapesOp)
        return ListObj

    def GetSubShape(self, aShape, ListOfID, theName=None):
        """
        Obtain a composite sub-shape of aShape, composed from sub-shapes
        of aShape, selected by their unique IDs inside aShape
        """
        # used in Mesh.GetFailedShapes() and Mesh.GetSubShapeName() to get a sub-shape by index
        anObj = self.ShapesOp.GetSubShape(aShape,ListOfID[0])
        return anObj

    def GetSubShapeID(self, aShape, aSubShape):
        """
        Obtain unique ID of sub-shape aSubShape inside aShape
        of aShape, selected by their unique IDs inside aShape
        """
        anID = self.ShapesOp.GetSubShapeIndex(aShape, aSubShape)
        RaiseIfFailed("GetSubShapeIndex", self.ShapesOp)
        return anID

    def MinDistance(self, theVertex1, theVertex2):
        """
        Get minimal distance between the given vertices.
        """
        # used in Mesh_Algorithm.ReversedEdgeIndices() to get distance between two vertices
        aTuple = self.MeasuOp.GetMinDistance(theVertex1, theVertex2)
        RaiseIfFailed("GetMinDistance", self.MeasuOp)
        return aTuple[0]

    def NumberOfEdges(self, theShape):
        """
        Gives quantity of edges in the given shape.
        """
        # used in Mesh.MeshDimension() to find out presence of edges in theShape
        nb_edges = self.ShapesOp.NumberOfEdges(theShape)
        RaiseIfFailed("NumberOfEdges", self.ShapesOp)
        return nb_edges

    def NumberOfFaces(self, theShape):
        """
        Gives quantity of faces in the given shape.
        """
        # used in Mesh.MeshDimension() to find out presence of faces in theShape
        nb_faces = self.ShapesOp.NumberOfFaces(theShape)
        RaiseIfFailed("NumberOfFaces", self.ShapesOp)
        return nb_faces

    def PointCoordinates(self,Point):
        """
        Get point coordinates
        """
        aTuple = self.MeasuOp.PointCoordinates(Point)
        RaiseIfFailed("PointCoordinates", self.MeasuOp)
        return aTuple

    def SubShapeAllIDs(self, aShape, aType):
        """
        Explode a shape on sub-shapes of a given type.
        """
        ListObj = self.ShapesOp.GetAllSubShapesIDs(aShape, EnumToLong( aType ), False)
        RaiseIfFailed("SubShapeAllIDs", self.ShapesOp)
        return ListObj

    def SubShapeAll(self, aShape, aType, theName=None):
        """
        Explode a shape on sub-shapes of a given type.
        If the shape itself matches the type, it is also returned.
        """
        ListObj = self.ShapesOp.ExtractSubShapes(aShape, EnumToLong( aType ), False)
        RaiseIfFailed("SubShapeAll", self.ShapesOp)
        return ListObj

    def SubShapeName(self,aSubObj, aMainObj):
        """
        Get name for sub-shape aSubObj of shape aMainObj
        """
        index = self.ShapesOp.GetTopologyIndex(aMainObj, aSubObj)
        name = self.ShapesOp.GetShapeTypeString(aSubObj) + "_%d"%(index)
        return name

    def Tolerance(self,theShape):
        """
        Get min and max tolerances of sub-shapes of theShape
        """
        # used in Mesh_Algorithm.ReversedEdgeIndices() to get tolerance of a vertex
        aTuple = self.MeasuOp.GetTolerance(theShape)
        RaiseIfFailed("GetTolerance", self.MeasuOp)
        return aTuple

    def GetVertexByIndex(self, theShape, theIndex, theUseOri=True, theName=None):
        """
        Get a vertex sub-shape by index.
        """
        # used in Mesh_Algorithm.ReversedEdgeIndices()
        anObj = self.MeasuOp.GetVertexByIndex(theShape, theIndex, theUseOri)
        RaiseIfFailed("GetVertexByIndex", self.MeasuOp)
        return anObj

    def UnionList (self,theGroup, theSubShapes):
        """
        Adds to the group all the given shapes. No errors, if some shapes are already included.
        """
        # used in Mesh.GetFailedShapes()
        self.GroupOp.UnionList(theGroup, theSubShapes)
        RaiseIfFailed("UnionList", self.GroupOp)
        pass

    def addToStudy(self, aShape, aName, doRestoreSubShapes=False,
                   theArgs=[], theFindMethod=None, theInheritFirstArg=False):
        """
        Publish in study aShape with name aName
        """
        # used to publish Mesh.geom and shapes that are filter criteria
        #return ""
        try:
            from SHAPERSTUDY_utils import getEngine
            aSObject = getEngine().AddInStudy(aShape, aName, None)
            if aSObject and aName: aSObject.SetAttrString("AttributeName", aName)
        except:
            print("addToStudy() failed")
            return ""
        return aShape.GetStudyEntry()

    def addToStudyInFather(self, aFather, aShape, aName):
        """
        Publish in study aShape with name aName as sub-object of previously published aFather
        """
        #return ""
        try:
            from SHAPERSTUDY_utils import getEngine
            aSObject = getEngine().AddInStudy(aShape, aName, aFather)
            if aSObject and aName: aSObject.SetAttrString("AttributeName", aName)
        except:
            print("addToStudy() failed")
            return ""
        return aShape.GetStudyEntry()

import omniORB
omniORB.registerObjref(SHAPERSTUDY.SHAPERSTUDY._NP_RepositoryId, shaperBuilder)
omniORB.registerObjref(GEOM._objref_GEOM_Gen._NP_RepositoryId, shaperBuilder)

def New( instance=None ):
    """
    Create a new shaperBuilder instance
    """
    global engine
    global geom
    global doLcc
    engine = instance
    if engine is None:
      doLcc = True
    geom = shaperBuilder()
    assert isinstance(geom,shaperBuilder), "Geom engine class is %s but should be shaperBuilder.shaperBuilder. Import geomBuilder before creating the instance."%geom.__class__
    #geom.init_geom()
    return geom


## Raise an Error, containing the Method_name, if Operation failed
## @ingroup l1_geomBuilder_auxiliary
def RaiseIfFailed (Method_name, Operation):
    if not Operation.IsDone() and Operation.GetErrorCode() != "NOT_FOUND_ANY":
        raise RuntimeError(Method_name + " : " + Operation.GetErrorCode())

def EnumToLong(theItem):
    """
    Returns a long value from enumeration type
    Can be used for CORBA enumerator types like geomBuilder.ShapeType

    Parameters:
        theItem enumeration type
    """
    ret = theItem
    if hasattr(theItem, "_v"): ret = theItem._v
    return ret

