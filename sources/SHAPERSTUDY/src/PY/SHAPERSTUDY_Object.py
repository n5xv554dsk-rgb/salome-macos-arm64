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

from salome.kernel import SHAPERSTUDY_ORB
from salome.kernel import SHAPERSTUDY_ORB__POA
from salome.kernel import GEOM
from SHAPERSTUDY_utils import getEngine, getStudy
from salome.kernel import salome

import StudyData_Swig

# converter from the integer values to idl shape_type enumerations
__shape_types__ = {
  0:GEOM.COMPOUND, 1:GEOM.COMPSOLID, 2:GEOM.SOLID,
  3:GEOM.SHELL, 4:GEOM.FACE, 5:GEOM.WIRE,
  6:GEOM.EDGE, 7:GEOM.VERTEX, 8:GEOM.SHAPE, 9:GEOM.FLAT}

class SHAPERSTUDY_GenericObject:
    """
    Implement methods of SALOME::GenericObj
    """
    def __init__(self):
        self.cnt=1

    def Register(self):
        """
        Increase the reference count (mark as used by another object).
        """
        #print(self.GetEntry())
        self.cnt+=1
        #print("Register() --------- ", id(self), self.cnt)
        return

    def UnRegister(self):
        """
        Decrease the reference count (release by another object)
        """
        self.cnt-=1
        #print("UnRegister() --------- ", id(self), self.cnt)
        if self.cnt <= 0:
            from SHAPERSTUDY_utils import getPOA
            poa = getPOA()
            oid=poa.servant_to_id(self)
            poa.deactivate_object(oid)
            if hasattr(self,"SetSO"):
                self.SetSO(None) # release a GenericObject SO
            #print("UnRegister() --------- OK")
        return

    def Destroy(self):
        """
        Obsolete, left for compatibility reasons only. Use UnRegister() instead
        """
        self.UnRegister()
        return

    pass


class SHAPERSTUDY_Object(SHAPERSTUDY_ORB__POA.SHAPER_Object,
                         SHAPERSTUDY_GenericObject):
    """
    Constructs an instance of SHAPERSTUDY Object.
    """
    def __init__ ( self, *args):
        SHAPERSTUDY_GenericObject.__init__(self)
        self.SO = None
        self.data = None
        self.entry = ""
        self.type = 1 # by default it is a shape (Import feature in GEOMImpl_Types.hxx)
        pass

    def GetShapeType( self ):
        """
        Get a GEOM.shape_type of the object value.
        """
        if self.data is None:
            return GEOM.SHAPE
        global __shape_types__
        return __shape_types__[self.data.type()];

    def IsMainShape( self ):
        """
        Returns True if this object is not a sub-shape of another object.
        """
        return True

    def GetSubShapeIndices( self ):
        """
        Get a list of ID's of sub-shapes in the main shape.
        """
        return []

    def GetMainShape( self ):
        """
        Get a main shape object to which this object is a sub-shape.
        """
        return getShape()

    def getShape( self ):
        """
        Get the TopoDS_Shape, for collocated case only.
        Called by GEOM_Client to get TopoDS_Shape pointer
        """
        if self.data is None:
            return 0
        return self.data.shape()

    def GetShapeStream( self ):
        """
        Get geometric shape of the object as a byte stream in BRep format
        """
        if self.data is None:
            return b''
        return self.data.shapeStream().encode()

    def GetOldShapeStream( self ):
        """
        Get geometric shape of the object as a byte stream in BRep format
        """
        if self.data is None:
            return b''
        return self.data.oldShapeStream().encode()

    def SetShapeByStream(self, theStream):
        """
        Sets geometric shape content of the object as a byte stream in BRep format
        """
        if self.data:
          self.data.updateShape(theStream)
        else:
          self.data = StudyData_Swig.StudyData_Object(theStream)

    """
    Methods from BaseObject
    """
    def GetName( self ):
        """
        Get name of the object associated with this object.
        """
        return self.SO.GetName()

    def SetEntry( self, theInternalEntry ):
        """
        Sets internal (unique) entry of the object in the component's data tree.
        """
        self.entry = theInternalEntry

    def GetEntry( self ):
        """
        Get internal (unique) entry of the object in the component's data tree.
        """
        return self.entry

    def GetType( self ):
        """
        Get internal type of operation created this object.
        In SMESH is used to find out if an object is GROUP (type == 37)
        """
        return self.type

    def SetType( self, theType ):
        """
        Sets internal type of operation created this object.
        In SMESH is used to find out if an object is GROUP (type == 37, for shape it is default=1)
        """
        self.type = theType

    def GetTick( self ):
        """
        Get value of a modification counter of the object
        """
        if self.data:
          return self.data.getTick()
        return 0

    def SetTick( self, theValue ):
        """
        Sets value of a modification counter of the object
        """
        if self.data:
          return self.data.setTick(theValue)
        return 0

    def GetStudyEntry( self ):
        """
        Get a Study entry where this object was published.
        """
        if self.SO:
            return self.SO.GetID()
        return ""

    def IsShape( self ):
        """
        Return true if geom object represents a shape.
        For example, method return false for GEOM_MARKER
        """
        return True

    def IsSame( self, other ):
        """
        Return true if passed object is identical to this object
        """
        return self.GetType() == other.GetType() and self.GetEntry() == other.GetEntry()

    def GetGen( self ):
        """
        Return the engine creating this object
        """
        e = getEngine()
        return e._duplicate( e )

    def SetSO( self, theSO ):
        """
        Sets SObject of this object (when it is published)
        """
        if theSO:
            theSO.Register() # I hold a GenericObject!
        if self.SO:
            if theSO:
                # Protect this object from deletion in self.SO.UnRegister()
                # Do not protect, if new theSO is None
                self.Register()
            self.SO.UnRegister()
        self.SO = theSO

    def GetSO( self ):
        """
        Returns SObject of this object
        """
        return self.SO

    def IsParametrical(self):
        """
        Returns true if the current object has connection to a parametrical model
        which can be modified by parameters change.
        """
        return not self.IsDead() and self.type == 1 # only break link for shapes are accessible now

    def IsDead(self):
        """
        Returns true if the shape is dead - no parametrical link to the SHAPER exists
        """
        return self.GetEntry().startswith("dead")

    def MakeDead(self):
        """
        Makes the dead-copy of the shape and returns it.
        """
        aStudy = getStudy()
        aBuilder = aStudy.NewBuilder()
        aRes, aHistSO = self.SO.FindSubObject(10000)
        if not aRes: # create a "history" folder if it does not exist
          aHistSO = aBuilder.NewObjectToTag(self.SO, 10000)
          aHistSO.SetAttrString("AttributeName", "History")

        aDeadSO = aBuilder.NewObject(aHistSO)
        anIndex = aDeadSO.Tag()
        aDeadSO.SetAttrString("AttributeName", self.SO.GetName() + " (" + str(anIndex) + ")")
        aRes, aPixMap = aBuilder.FindAttribute(self.SO, "AttributePixMap")
        if aRes:
          aDeadPixMap = aBuilder.FindOrCreateAttribute(aDeadSO, "AttributePixMap")
          aDeadPixMap.SetPixMap(aPixMap.GetPixMap())
        aDead = SHAPERSTUDY_Object()
        aDeadEntry = "dead" + str(anIndex) + "_" + self.GetEntry()
        aDead.SetEntry(aDeadEntry)
        aDead.SetShapeByStream(self.data.oldShapeStream())
        aDeadObj = aDead._this()
        anIOR = salome.orb.object_to_string(aDeadObj)
        aDeadSO.SetAttrString("AttributeIOR", anIOR)
        aDead.SetSO(aDeadSO)
        if self.GetTick() > 2:
          aDead.data.setTick(self.GetTick() - 1) # set the tick of an old shape
        # make dead-copy also sub-groups
        aSOIter = aStudy.NewChildIterator(self.SO)
        while aSOIter.More():
          aGroupSO = aSOIter.Value()
          anIOR = aGroupSO.GetIOR()
          if len(anIOR):
            aGroup = salome.orb.string_to_object(anIOR)
            if isinstance(aGroup, SHAPERSTUDY_ORB._objref_SHAPER_Group) or \
               isinstance(aGroup, SHAPERSTUDY_ORB._objref_SHAPER_Field):
              if isinstance(aGroup, SHAPERSTUDY_ORB._objref_SHAPER_Group):
                aDeadGroup = SHAPERSTUDY_Group()
              else:
                aDeadGroup = SHAPERSTUDY_Field()
              aDeadGroupEntry = "dead" + str(anIndex) + "_" + aGroup.GetEntry()
              aDeadGroup.SetEntry(aDeadGroupEntry)
              aDeadGroup.SetSelectionType(aGroup.GetSelectionType())
              anOldSelection = aGroup.GetSelectionOld()
              if len(anOldSelection) == 0: # in case there is no old modification, get the current, same as in shape
                anOldSelection = aGroup.GetSelection()
              aDeadGroup.SetSelection(anOldSelection)
              if isinstance(aGroup, SHAPERSTUDY_ORB._objref_SHAPER_Field): # additional field data
                aDeadGroup.SetValuesType(aGroup.GetValuesType())
                aDeadGroup.SetSteps(aGroup.GetSteps())
                aDeadGroup.SetComponents(aGroup.GetComponents())
                for aStep in aGroup.GetSteps():
                  aStepObj = aGroup.GetStep(aStep)
                  aDeadGroup.AddFieldStep(aStepObj.GetStamp(), aStep, aStepObj.GetValues())
              aDeadGroupSO = aBuilder.NewObject(aDeadSO)
              aDeadGroup.SetSO(aDeadGroupSO)
              # 15.01.20 groups and fields names stays the same
              #aDeadGroupSO.SetAttrString("AttributeName", aGroupSO.GetName() + " (" + str(anIndex) + ")")
              aDeadGroupSO.SetAttrString("AttributeName", aGroupSO.GetName())
              aRes, aPixMap = aBuilder.FindAttribute(aGroupSO, "AttributePixMap")
              if aRes:
                aDeadPixMap = aBuilder.FindOrCreateAttribute(aDeadGroupSO, "AttributePixMap")
                aDeadPixMap.SetPixMap(aPixMap.GetPixMap())
              aDeadGroupObj = aDeadGroup._this()
              anIOR = salome.orb.object_to_string(aDeadGroupObj)
              aDeadGroupSO.SetAttrString("AttributeIOR", anIOR)
          aSOIter.Next()

        return aDeadObj
    
    def SetShapeByPointer(self, theShape):
        """
        Sets the shape by the pointer to the TopoDS_Shape
        """
        if not self.data:
          self.data = StudyData_Swig.StudyData_Object()
        self.data.SetShapeByPointer(theShape)
        return

    ### unnecessary methods that can be accidentally called from any module
    def GetTopologyType(self, *args): return GEOM.SHAPE
    def GetMinShapeType(self, *args): return GEOM.SHAPE
    def GetMaxShapeType(self, *args): return GEOM.SHAPE
    def GetSubShapeName(self, *args): return ""
    def SetColor(self, *args): return
    #def GetColor(self, *args): import SALOMEDS; return SALOMEDS.Color( 0,0,0 )
    def GetColor(self, *args): import salome.kernel.SALOMEDS; return salome.kernel.SALOMEDS.Color( -1,-1,-1 )
    def SetAutoColor(self, *args): return 
    def GetAutoColor(self, *args): return False
    def SetMarkerStd(self, *args): return 
    def SetMarkerTexture(self, *args): return 
    def GetMarkerType(self, *args): return GEOM.MT_NONE
    def GetMarkerSize(self, *args): return GEOM.MS_NONE
    def GetMarkerTexture(self, *args): return 0

    pass

class SHAPERSTUDY_Group(SHAPERSTUDY_ORB__POA.SHAPER_Group, SHAPERSTUDY_Object):
    """
    Constructs an instance of SHAPERSTUDY Group
    """
    def __init__ ( self, *args):
        SHAPERSTUDY_GenericObject.__init__(self)
        self.seltype = None
        self.selection = []
        self.selectionTick = -2 # tick of the main shape when the current selection is set
        self.selectionOld = [] # keep selection for breaking link
        self.SO = None
        self.data = None
        self.entry = ""
        self.type = 37 # a group type
        pass

    def SetSelectionType(self, theType):
        """
        Sets what is returned in the GEOM_IGroupOperations::GetType
        """
        self.seltype = theType

    def GetSelectionType(self):
        """
        Returns the type of the selected sub-shapes
        """
        return self.seltype

    def SetSelection(self, theSelection):
        """
        Sets what is returned in the GEOM_IGroupOperations::GetObjects
        """
        aTick = -2
        if self.SO:
          aMainShape = self.GetMainShape()
          if aMainShape:
            aTick = aMainShape.GetTick()
        if aTick > self.selectionTick or aTick == -2:
          self.selectionOld = self.selection
          self.selection = theSelection
          self.selectionTick = aTick
          #print("Set selection " + self.entry + " old = " + str(self.selectionOld) + " new = " + str(self.selection) + " tick = " + str(aTick))
        elif self.selection != theSelection:
          self.selectionOld = self.selection
          self.selection = theSelection
          if self.selectionTick < 0:
            self.selectionTick = aTick + 1
          else:
            self.selectionTick = self.selectionTick + 1 # when the group is changed, but the main shape stays the same, make tick + 1
          #print("Set selection " + self.entry + " old = " + str(self.selectionOld) + " new = " + str(self.selection) + " tick = " + str(self.selectionTick))
        pass

    def GetSelection(self):
        """
        Returns the selected sub-shapes indices
        """
        return self.selection

    def GetSelectionOld(self):
        """
        Returns the previously selected sub-shapes indices
        """
        #print("get selection OLD " + self.entry + " old = " + str(self.selectionOld) + " new = " + str(self.selection))
        return self.selectionOld

    def IsMainShape( self ):
        """
        Returns True if this object is not a sub-shape of another object.
        """
        return False

    def GetMainShape( self ):
        """
        Main shape is groups owner
        """
        return self.SO.GetFather().GetObject()

    def GetSubShapeIndices( self ):
        """
        Get a list of ID's of sub-shapes in the main shape.
        """
        return self.selection

    def getShape( self ):
        """
        Redefinition of the getShape method: here it creates a shape by the
        main shape and the group index.
        """
        if not self.data:
          self.data = StudyData_Swig.StudyData_Object()
        # convert selection to long list
        anArg = StudyData_Swig.LongList()
        for l in self.selection:
          anArg.append(l)
        return self.data.groupShape(self.GetMainShape().getShape(), anArg)

    def GetShapeType( self ):
        """
        Group shape type is always compound.
        """
        return GEOM.COMPOUND;

    pass

    def GetTick( self ):
        """
        Get value of a modification counter of the group
        """
        return self.selectionTick

    def SetTick( self, theValue ):
        """
        Sets value of a modification counter of the group
        """
        #print("Set tick " + self.entry + " tick = " + str(theValue))
        self.selectionTick = theValue

class SHAPERSTUDY_Field(SHAPERSTUDY_ORB__POA.SHAPER_Field, SHAPERSTUDY_Group):
    """
    Constructs an instance of SHAPERSTUDY Field (inherits selection from a Group object)
    """
    def __init__ ( self, *args):
        SHAPERSTUDY_GenericObject.__init__(self)
        self.seltype = None
        self.selection = []
        self.selectionTick = -2 # tick of the main shape when the current selection is set
        self.selectionOld = [] # keep selection for breaking link
        self.SO = None
        self.data = None
        self.entry = None
        self.type = 52 # a field type
        self.valtype = None # type of the values
        self.steps = [] # list of long
        self.components = [] # string array, names of the components
        self.name = None # name, string
        self.fieldsteps = {} # FieldSteps objects identified by step ID
        pass

    def SetValuesType( self, theType ):
      """
      Sets the type of values in the field
      """
      self.valtype = theType

    def GetValuesType( self ):
      """
      Returns the type of values in the field
      """
      return self.valtype


    def GetDataType( self ):
      """
      Returns the type of values in the field in terms of GEOM enumeration
      """
      if self.valtype == 0:
        return GEOM.FDT_Bool
      elif self.valtype == 1:
        return GEOM.FDT_Int
      elif self.valtype == 2:
        return GEOM.FDT_Double
      elif self.valtype == 3:
        return GEOM.FDT_String
      return None # unknown case

    def GetShape ( self ):
      """
      Returns the shape the field lies on
      """
      return super().GetMainShape()

    def SetSteps( self, theSteps ):
      self.steps = theSteps

    def GetSteps( self ):
      return self.steps

    def SetComponents( self, theComponents ):
      self.components = theComponents
    
    def GetComponents( self ):
      return self.components

    def GetDimension( self ):
      aShapeType = super().GetSelectionType()
      if aShapeType == 8:
        return -1 # whole part
      elif aShapeType == 7:
        return 0 # vertex
      elif aShapeType == 6:
        return 1 # edge
      elif aShapeType == 4:
        return 2 # face
      elif aShapeType == 2:
        return 3 # solid
      return None # unknown case

    def ClearFieldSteps( self ):
       self.fieldsteps = {}

    def AddFieldStep( self, theStampID, theStepID, theValues):
      aFieldStep = None
      if self.valtype == 0:
        aFieldStep = SHAPER_BoolFieldStep()
      elif self.valtype == 1:
        aFieldStep = SHAPER_IntFieldStep()
      elif self.valtype == 2:
        aFieldStep = SHAPER_DoubleFieldStep()
      
      aFieldStep.SetStep(theStampID, theStepID, theValues)
      self.fieldsteps[theStepID] = aFieldStep._this()

    def GetStep( self, theStepID ):
       return self.fieldsteps[theStepID]

    pass

class SHAPER_FieldStep:
    """
    Base class for all step-classes
    """
    def __init__ ( self, *args):
        self.stamp = None  # long, ID of stamp
        self.step = None   # long, ID of step
        self.values = None # array of values of the needed type

    """
    Defines all parameters of the step
    """
    def SetStep( self, theStamp, theStep, theValues ):
        self.stamp = theStamp
        self.step = theStep
        self.values = theValues
     
    """
    Returns stamp ID
    """
    def GetStamp( self ):
        return self.stamp
    """
    Returns step ID
    """
    def GetID( self ):
        return self.step
    """
    Returns a name of a sub-shape if the sub-shape is published in the study
    """
    def GetSubShape(self, theSubID):
        # the SHAPER study does not support sub-shapes for now
        return ""
        

class SHAPER_DoubleFieldStep(SHAPERSTUDY_ORB__POA.SHAPER_DoubleFieldStep, SHAPER_FieldStep):
    """
    Constructs an instance of SHAPERSTUDY Field step of type Double
    """
    def __init__ ( self, *args):
        pass

    """
    Returns values as an array of the needed type
    """
    def GetValues( self ):
        aResult = [] # to make any type of result, create a corba-type
        for i in self.values:
          aResult.append(float(i))
        return aResult

    pass

class SHAPER_IntFieldStep(SHAPERSTUDY_ORB__POA.SHAPER_IntFieldStep, SHAPER_FieldStep):
    """
    Constructs an instance of SHAPERSTUDY Field step of type Double
    """
    def __init__ ( self, *args):
        pass

    """
    Returns values as an array of the needed type
    """
    def GetValues( self ):
        aResult = [] # to make any type of result, create a corba-type
        for i in self.values:
          aResult.append(int(i))
        return aResult

    pass

class SHAPER_BoolFieldStep(SHAPERSTUDY_ORB__POA.SHAPER_BoolFieldStep, SHAPER_FieldStep):
    """
    Constructs an instance of SHAPERSTUDY Field step of type Double
    """
    def __init__ ( self, *args):
        pass

    """
    Returns values as an array of the needed type
    """
    def GetValues( self ):
        aResult = [] # to make any type of result, create a corba-type
        for i in self.values:
          aResult.append(int(i))
        return aResult

    pass

