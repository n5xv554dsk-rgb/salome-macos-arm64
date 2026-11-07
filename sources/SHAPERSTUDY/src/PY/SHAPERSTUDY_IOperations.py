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

from salome.kernel import SHAPERSTUDY_ORB__POA
from salome.kernel import SHAPERSTUDY_ORB
import SHAPERSTUDY_Object
from salome.kernel import GEOM
from salome.kernel import salome
from SHAPERSTUDY_utils import getStudy

import StudyData_Swig

class SHAPERSTUDY_IShapesOperations(SHAPERSTUDY_ORB__POA.IShapesOperations,
                                    SHAPERSTUDY_Object.SHAPERSTUDY_GenericObject):
    """
    Construct an instance of SHAPERSTUDY IShapesOperations.
    """
    def __init__ ( self, *args):
        SHAPERSTUDY_Object.SHAPERSTUDY_GenericObject.__init__(self)
        self.done = False
        self.myop = StudyData_Swig.StudyData_Operation()
        self.errorcode = ""
        pass

    def GetAllSubShapesIDs( self, theShape, theShapeType, isSorted ):
        """
        Explode a shape on sub-shapes of a given type.

        Parameters:
            theShape Shape to be exploded.
            theShapeType Type of sub-shapes to be retrieved.
            isSorted If this parameter is TRUE, sub-shapes will be
            sorted by coordinates of their gravity centers.
        """
        aList = self.myop.GetAllSubShapesIDs(theShape.getShape(), theShapeType, isSorted)
        self.done = True
        aResult = []
        for i in aList:
          aResult.append(i)
        return aResult

    def GetSharedShapes( self, theShape1, theShape2, theShapeType ):
        """
        Get sub-shapes, shared by input shapes.

        Parameters:
            theShape1 Shape to find sub-shapes in.
            theShape2 Shape to find shared sub-shapes with.
            theShapeType Type of sub-shapes to be retrieved.
        """
        aList = self.myop.GetSharedShapes(theShape1.getShape(), theShape2.getShape(), theShapeType)
        self.done = True
        aResult = []
        for i in aList:
          aResult.append(i)
        return aResult

    def GetSubShapeIndex( self, theMainShape, theSubShape ):
        """
        Get global index of theSubShape in theMainShape.
        """
        anIndex = self.myop.GetSubShapeIndex(theMainShape.getShape(), theSubShape.getShape())
        self.done = True
        return anIndex

    def GetSubShape( self, theMainShape, theID ):
        """
        Get a sub-shape defined by its unique ID within theMainShape
        """
        aShape = self.myop.GetSubShape(theMainShape.getShape(), theID)
        self.done = aShape != 0
        if not self.done:
          return None

        # create a shape-object that contain the internal shape only
        aShapeObj = SHAPERSTUDY_Object.SHAPERSTUDY_Object()
        aShapeObj.SetShapeByPointer(aShape)
        return aShapeObj._this()

    def ExtractSubShapes(self, aShape, aType, isSorted):
        """
        Extract shapes (excluding the main shape) of given type.

        Parameters:
            aShape The shape.
            aType  The shape type (see geompy.ShapeType)
            isSorted Boolean flag to switch sorting on/off.

        Returns:
            List of sub-shapes of type aType, contained in aShape.
        """
        shapes = self.myop.ExtractSubShapes( aShape.getShape(), aType, isSorted )
        resultList = []
        for s in shapes:
            aShapeObj = SHAPERSTUDY_Object.SHAPERSTUDY_Object()
            aShapeObj.SetShapeByPointer( s )
            resultList.append( aShapeObj._this() )
        self.done = True
        return resultList


    def NumberOfEdges(self, theShape):
        """
        Gives quantity of edges in the given shape.

        Parameters:
            theShape Shape to count edges of.

        Returns:
            Quantity of edges.
        """
        nb = self.myop.NumberOfEdges( theShape.getShape() )
        self.done = ( nb >= 0 )
        return nb

    def NumberOfFaces(self, theShape):
        """
        Gives quantity of faces in the given shape.

        Parameters:
            theShape Shape to count faces of.

        Returns:
            Quantity of faces.
        """
        nb = self.myop.NumberOfFaces( theShape.getShape() )
        self.done = ( nb >= 0 )
        return nb

    def MakeAllSubShapes(self, aShape, aType):
        """
        Explode a shape on sub-shapes of a given type.
        If the shape itself matches the type, it is also returned.

        Parameters:
            aShape Shape to be exploded.
            aType Type of sub-shapes to be retrieved (see geompy.ShapeType)

        Returns:
            List of sub-shapes of type theShapeType, contained in theShape.
        """
        self.done = True
        return self.myop.MakeAllSubShapes(aShape.getShape(), aType)

    def MakeSubShapes(self, aShape, anIDs):
        """
        Get a set of sub-shapes defined by their unique IDs inside theMainShape

        Parameters:
            aShape Main shape.
            anIDs List of unique IDs of sub-shapes inside theMainShape.

        Returns:
            List of GEOM.GEOM_Object, corresponding to found sub-shapes.
        """
        self.done = True
        return self.myop.MakeSubShapes(aShape.getShape(), anIDs)

    def GetExistingSubObjects(self, theShape, theGroupsOnly = False):
        """
        Get all sub-shapes and groups of theShape,
        that were created already by any other methods.

        Parameters:
            theShape Any shape.
            theGroupsOnly If this parameter is TRUE, only groups will be
                             returned, else all found sub-shapes and groups.

        Returns:
            List of existing sub-objects of theShape.
        """
        ListObj = []
        self.done = False
        SObj = salome.ObjectToSObject( theShape )
        if not SObj: return ListObj
        soIter = salome.myStudy.NewChildIterator( SObj )
        while soIter.More():
            soChild = soIter.Value()
            soIter.Next()
            obj = soChild.GetObject()
            if theGroupsOnly:
                if isinstance( obj, SHAPERSTUDY_ORB._objref_SHAPER_Group):
                    ListObj.append( obj )
            elif isinstance( obj, SHAPERSTUDY_ORB._objref_SHAPER_Object ):
                ListObj.append( obj )
        self.done = True
        return ListObj

    def GetTopologyIndex(self, aMainObj, aSubObj):
        """
        Return index of a sub-shape
        """
        i = self.myop.GetTopologyIndex(aMainObj.getShape(), aSubObj.getShape())
        self.done = ( i > 0 )
        return i

    def GetShapeTypeString(self,aSubObj):
        """
        Return a shape type as a string
        """
        s = "%s" % aSubObj.GetShapeType()
        t = s[5:]
        return t
        

    def GetInPlace( self, theShapeWhere, theShapeWhat ):
        """
        Get sub-shape(s) of \a theShapeWhere, which are
        coincident with \a theShapeWhat or could be a part of it.
        """
        self.done = False
        self.errorcode = "Not implemented"
        return SHAPERSTUDY_Object()._this()
        
    def GetInPlaceMap( self, theShapeWhere, theShapeWhat ):
        """
        A sort of GetInPlace functionality, returning for each sub-shape ID of
        \a theShapeWhat a list of corresponding sub-shape IDs of \a theShapeWhere.
        """
        self.done = False
        self.errorcode = "Not implemented"
        return [[]]

    def IsDone( self ):
        """
        To know, if the operation was successfully performed
        """
        return self.done

    pass

    def GetErrorCode( self ):
        """
        To know a failure reason
        """
        return self.errorcode

    pass

class SHAPERSTUDY_IGroupOperations(SHAPERSTUDY_ORB__POA.IGroupOperations,
                                   SHAPERSTUDY_IShapesOperations):
    """
    Construct an instance of SHAPERSTUDY IShapesOperations.
    """
    def __init__ ( self, *args):
        SHAPERSTUDY_IShapesOperations.__init__(self)
        self.done = False
        pass

    def CreateGroup( self, theMainShape, theShapeType ):
        """
        Creates a new group which will store sub-shapes of theMainShape
        """
        if theShapeType != 7 and theShapeType != 6 and theShapeType != 4 and theShapeType != 2: 
          print("Error: You could create group of only next type: vertex, edge, face or solid")
          return None

        aGroup = SHAPERSTUDY_Object.SHAPERSTUDY_Group()
        aGroupPtr = aGroup._this()
        aGroup.SetSelectionType(theShapeType) # create a new field specific for the group python object
        self.done = True
        return aGroupPtr

    def FindGroup(self, theOwner, theEntry):
        """
        Searches existing group of theOwner shape by the entry. Returns NULL if can not find.
        """       
        if not hasattr(theOwner, "GetSO"): # only SHAPERSTUDY objects are allowed
          return None
        aStudy = getStudy()
        anIter = aStudy.NewChildIterator(theOwner.GetSO())
        while anIter.More():
          aGroupObj = anIter.Value().GetObject()
          if aGroupObj:
            if aGroupObj.GetEntry() == theEntry:
              self.done = True
              return aGroupObj
          anIter.Next()
        self.done = False
        return None # not found

    def UnionList( self, theGroup, theSubShapes ):
        """
        Adds to the group all the given shapes. No errors, if some shapes are already included.
        """
        self.done = False
        indices = theGroup.GetSelection()
        mainShape = self.GetMainShape( theGroup )
        if not mainShape:
            self.errorcode = "No main shape"
            return
        groupType = self.GetType( theGroup )
        from shaperBuilder import EnumToLong
        for shape in theSubShapes:
            shapeType = EnumToLong( shape.GetShapeType() )
            if not groupType == shapeType:
                self.errorcode = "Group type and shape type mismatch"
                return
            i = self.myop.GetSubShapeIndex( mainShape.getShape(), shape.getShape() )
            if not i in indices:
                indices.append( i )
        theGroup.SetSelection( indices )
        self.done = True
        return

    def GetMainShape( self, theGroup ):
        """
        Returns a main shape associated with the group
        """
        if not hasattr(theGroup, "GetSO"): # only SHAPERSTUDY objects are allowed
          return None
        aSO = theGroup.GetSO()
        if not aSO:
            return None
        aFatherSO = aSO.GetFather()
        if not aFatherSO:
            return None
        anObj = aFatherSO.GetObject()
        if isinstance( anObj, SHAPERSTUDY_ORB._objref_SHAPER_Object ):
            return anObj
        else:
            return None

    def GetType( self, theGroup ):
        """
        Returns a type (int) of sub-objects stored in the group
        """
        return theGroup.GetSelectionType()

    def GetObjects( self, theGroup ):
        """
        Returns a list of sub-objects ID stored in the group
        """
        return theGroup.GetSelection()

    pass

class SHAPERSTUDY_IFieldOperations(SHAPERSTUDY_ORB__POA.IFieldOperations,
                                   SHAPERSTUDY_IShapesOperations):
    """
    Construct an instance of SHAPERSTUDY IFieldOperations.
    """
    def __init__ ( self, *args):
        SHAPERSTUDY_IShapesOperations.__init__(self)
        pass

    def CreateFieldByType( self, theMainShape, theShapeType):
        """
        Creates a new group which will store sub-shapes of theMainShape
        """
        if theShapeType != 8 and theShapeType != 7 and theShapeType != 6 and theShapeType != 4 and theShapeType != 2: 
          print("Error: You could create field of only next type: vertex, edge, face or solid, whole part")
          return None

        aField = SHAPERSTUDY_Object.SHAPERSTUDY_Field()
        aFieldPtr = aField._this()
        aField.SetSelectionType(theShapeType) # create a new field specific for the group python object
        return aFieldPtr

    def FindField(self, theOwner, theEntry):
        """
        Searches existing field of theOwner shape by the entry. Returns NULL if can not find.
        """
        if not hasattr(theOwner, "GetSO"): # only SHAPERSTUDY objects are allowed
          return None
        aStudy = getStudy()
        anIter = aStudy.NewChildIterator(theOwner.GetSO())
        while anIter.More():
          if len(anIter.Value().GetIOR()):
            aFieldObj = anIter.Value().GetObject()
            if aFieldObj:
              if aFieldObj.GetEntry() == theEntry:
                return aFieldObj
          anIter.Next()
        return None # not found


    def GetFields( self, shape ):
        """
        Returns all fields on a shape
        """
        if not hasattr(shape, "GetSO"): # only SHAPERSTUDY objects are allowed
          return []
        aResList = []
        aStudy = getStudy()
        anIter = aStudy.NewChildIterator(shape.GetSO())
        while anIter.More():
          aFieldObj = anIter.Value().GetObject()
          if aFieldObj and isinstance(aFieldObj, SHAPERSTUDY_ORB._objref_SHAPER_Field):
            aResList.append(aFieldObj)
          anIter.Next()
        return aResList

    pass


class SHAPERSTUDY_IMeasureOperations(SHAPERSTUDY_ORB__POA.IMeasureOperations,
                                     SHAPERSTUDY_IShapesOperations):
    """
    Construct an instance of SHAPERSTUDY IMeasureOperations.
    """
    def __init__ ( self, *args):
        SHAPERSTUDY_IShapesOperations.__init__(self)
        self.myop = StudyData_Swig.StudyData_Operation()
        pass

    def GetVertexByIndex( self, theShape, theIndex, theUseOri ):
        """
        Get a vertex sub-shape by index.

        Parameters:
        theShape Shape to find sub-shape.
        theIndex Index to find vertex by this index (starting from zero)
        theUseOri To consider edge/wire orientation or not
        """
        v = self.myop.GetVertexByIndex( theShape.getShape(), theIndex, theUseOri )
        self.done = ( v > 0 )
        if self.done:
            aShapeObj = SHAPERSTUDY_Object.SHAPERSTUDY_Object()
            aShapeObj.SetShapeByPointer( v )
            return aShapeObj._this()
        return None

    def GetMinDistance(self, theShape1, theShape2):
        """
        Get minimal distance between the given shapes.

        Parameters:
            theShape1,theShape2 Shapes to find minimal distance between.

        Returns:
            Value of the minimal distance between the given shapes.
        """
        d = self.myop.MinDistance(theShape1.getShape(), theShape2.getShape())
        self.done = ( d >= 0 )
        return d, 0,0,0, 0,0,0

    def PointCoordinates(self,Point):
        """
        Get point coordinates

        Returns:
            [x, y, z]
        """
        d = self.myop.PointCoordinates(Point.getShape())
        self.done = len( d )
        if self.done == 3:
            return d[0],d[1],d[2]
        return [0,0,0]

    def GetTolerance(self,theShape):
        """
        Get min and max tolerances of sub-shapes of theShape

        Parameters:
            theShape Shape, to get tolerances of.

        Returns:
            [FaceMin,FaceMax, EdgeMin,EdgeMax, VertMin,VertMax]
             FaceMin,FaceMax: Min and max tolerances of the faces.
             EdgeMin,EdgeMax: Min and max tolerances of the edges.
             VertMin,VertMax: Min and max tolerances of the vertices.
        """
        tol = self.myop.GetTolerance(theShape.getShape())
        self.done = tol > 0;
        return tol,tol, tol,tol, tol,tol

    pass
