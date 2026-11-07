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
from salome.kernel import SALOME_ComponentPy
from salome.kernel import SALOME_DriverPy
from salome.kernel import SALOMEDS
from SHAPERSTUDY_utils import findOrCreateComponent, moduleName, getStudy, getORB
from salome.kernel import salome
import SHAPERSTUDY_Object
import SHAPERSTUDY_IOperations
from salome.kernel import GEOM
from salome.kernel import SMESH

import StudyData_Swig

# for unit tests correct execution
salome.salome_init(embedded=True)

__entry2IOR__ = {}
__entry2DumpName__ = {}

class SHAPERSTUDY_Gen(SHAPERSTUDY_ORB__POA.Gen, SALOME_ComponentPy.SALOME_ComponentPy_i, SALOME_DriverPy.SALOME_DriverPy_i):

    ShapeType = {"AUTO":-1, "COMPOUND":0, "COMPSOLID":1, "SOLID":2, "SHELL":3, "FACE":4, "WIRE":5, "EDGE":6, "VERTEX":7, "SHAPE":8, "FLAT":9}
    
    ShaperIcons = {GEOM.COMPOUND:"compsolid.png",
        GEOM.COMPSOLID:"compsolid.png",
        GEOM.SOLID:"solid.png",
        GEOM.SHELL:"shell.png",
        GEOM.FACE:"face.png",
        GEOM.WIRE:"wire.png",
        GEOM.EDGE:"edge.png",
        GEOM.VERTEX:"vertex.png",
        GEOM.SHAPE:"solid.png",
        GEOM.FLAT:"face.png"
        }
    
    ShaperFieldIcons = {GEOM.COMPOUND:"compsolid_field.png",
        GEOM.COMPSOLID:"compsolid_field.png",
        GEOM.SOLID:"solid_field.png",
        GEOM.SHELL:"shell_field.png",
        GEOM.FACE:"face_field.png",
        GEOM.WIRE:"wire_field.png",
        GEOM.EDGE:"edge_field.png",
        GEOM.VERTEX:"vertex_field.png",
        GEOM.SHAPE:"solid_field.png",
        GEOM.FLAT:"face_field.png"
        }
    
    ShaperDeadObjectIcons = {GEOM.COMPOUND:"compsolid_dead.png",
        GEOM.COMPSOLID:"compsolid_dead.png",
        GEOM.SOLID:"solid_dead.png",
        GEOM.SHELL:"shell_dead.png",
        GEOM.FACE:"face_dead.png",
        GEOM.WIRE:"wire_dead.png",
        GEOM.EDGE:"edge_dead.png",
        GEOM.VERTEX:"vertex_dead.png",
        GEOM.SHAPE:"solid_dead.png",
        GEOM.FLAT:"face_dead.png"
        }

    def FindOrCreateShape( self, theInternalEntry ):
        """
        Searches existing or creates a new SHAPERSTUDY_Object to interact with SHAPER
        """
        # Searching in the study tree
        aComponent = findOrCreateComponent()
        aSOIter = getStudy().NewChildIterator(aComponent)
        while aSOIter.More():
          aSO = aSOIter.Value()
          anIOR = aSO.GetIOR()
          if len(anIOR):
            anObj = salome.orb.string_to_object(anIOR)
            if anObj and isinstance(anObj, SHAPERSTUDY_ORB._objref_SHAPER_Object):
              if anObj.GetEntry() == theInternalEntry:
                return anObj
          aSOIter.Next()
        aShapeObj = SHAPERSTUDY_Object.SHAPERSTUDY_Object()
        aShapeObj.SetEntry(theInternalEntry)
        return aShapeObj._this()

    def AddInStudy( self, theObject, theName, theFather ):
        """
        Adds in theStudy a object theObject under theFather with a name theName,
        if theFather is not NULL the object is placed under theFather's SObject.
        Returns a SObject where theObject is placed
        """
        if not theObject.GetEntry():
            return None # object not existing in shaper
        aStudy = getStudy()
        aBuilder = aStudy.NewBuilder()
        isGroupOrField = theObject.GetType() == 37 or theObject.GetType() == 52
        isField = theObject.GetType() == 52

        if not theFather:
          if isGroupOrField:
            return None # Group may be added only under the shape-father
          theFatherSO = findOrCreateComponent()
        else:
          theFatherSO = theFather.GetSO()
        aResultSO = None
        if isGroupOrField:
          aTag = 2
          anIter = aStudy.NewChildIterator(theFatherSO)
          while anIter.More():
            if anIter.Value().Tag() == 10000: # skip the history folder
              anIter.Next()
              continue
            aCurrentTag = anIter.Value().Tag() + 1
            anIter.Next()
            if aTag < aCurrentTag:
              aTag = aCurrentTag
          if aTag == 10000: # to avoid putting the object to the history folder
            aTag += 1
          aResultSO = aBuilder.NewObjectToTag(theFatherSO, aTag)
        else:
          aResultSO = aBuilder.NewObject(theFatherSO)
        aResultSO.SetAttrString("AttributeName", theName)
        if theObject is not None:
            anIOR = salome.orb.object_to_string(theObject)
            aResultSO.SetAttrString("AttributeIOR", anIOR)
            theObject.SetSO(aResultSO)
            aAttr = aBuilder.FindOrCreateAttribute(aResultSO, "AttributePixMap")
            aPixmap = aAttr._narrow(salome.SALOMEDS.AttributePixMap)
            aType = 0
            if isGroupOrField:
              aType = SHAPERSTUDY_Object.__shape_types__[theObject.GetSelectionType()]
            else:
              aType = theObject.GetShapeType()

            if isField:
              aPixmap.SetPixMap(self.ShaperFieldIcons[aType])
            else:
              aPixmap.SetPixMap(self.ShaperIcons[aType])
            
        # add a red-reference that means that this is an active reference to SHAPER result
        if not isGroupOrField:
          aSub = aBuilder.NewObjectToTag(aResultSO, 1)
          aBuilder.Addreference(aSub, aResultSO)

        return aResultSO

    def SetDeadPixmapToDeadObject( self, theObject):
      if not theObject.GetEntry():
        return None # object not existing in shaper
      
      aStudy = getStudy()
      aBuilder = aStudy.NewBuilder()

      aAttr = aBuilder.FindOrCreateAttribute(theObject.GetSO(), "AttributeTextColor")
      aTextColor = aAttr._narrow(salome.SALOMEDS.AttributeTextColor)
      aTextColor.SetTextColor(salome.SALOMEDS.Color(155, 155, 155))

      aAttr = aBuilder.FindOrCreateAttribute(theObject.GetSO(), "AttributePixMap")
      aPixmap = aAttr._narrow(salome.SALOMEDS.AttributePixMap)
      aType = 0
      isGroupOrField = theObject.GetType() == 37 or theObject.GetType() == 52
      if isGroupOrField:
        aType = SHAPERSTUDY_Object.__shape_types__[theObject.GetSelectionType()]
      else:
        aType = theObject.GetShapeType()

      aPixmap.SetPixMap(self.ShaperDeadObjectIcons[aType])
      return

    def StoreVariableName(self, theEntry, theVarName):
        """
        Stores the variable names of the SHAPER dump to python
        """
        __entry2DumpName__["s" + theEntry] = theVarName


    def AddSubShape( theMainShape, theIndices ):
        """
        Add a sub-shape defined by indices in theIndices
        (contains unique IDs of sub-shapes inside theMainShape)
        """
        # no sub-shapes for the moment
        go = SHAPERSTUDY_Object()._this()
        return go

    # For now it is impossible to remove anything from the SHAPER-STUDY
    def RemoveObject( self, theObject ):
        """
        Removes the object from the component
        """
        # can not be removed for the moment
        return

    def GetIFieldOperations( self ):
        """
        """
        return SHAPERSTUDY_IOperations.SHAPERSTUDY_IFieldOperations()._this()

    def GetIGroupOperations( self ):
        """
        """
        return SHAPERSTUDY_IOperations.SHAPERSTUDY_IGroupOperations()._this()

    def GetIShapesOperations( self ):
        """
        """
        return SHAPERSTUDY_IOperations.SHAPERSTUDY_IShapesOperations()._this()

    def GetIMeasureOperations( self ):
        """
        """
        return SHAPERSTUDY_IOperations.SHAPERSTUDY_IMeasureOperations()._this()

    def GetStringFromIOR( self, theObject ):
        """
        Returns a string which contains an IOR of the SHAPERSTUDY_Object
        """
        IOR = ""
        if theObject and getORB():
            IOR = getORB().object_to_string( theObject )
            pass
        return IOR

    def Save( self, component, URL, isMultiFile ):
        """
        Saves data: all objects into one file
        """
        aResult = "" # string-pairs of internal entries and shape streams
        aStudy = getStudy()
        # get all sub-SObjects with IOR defined
        anIters = [aStudy.NewChildIterator(findOrCreateComponent())]
        aSOList = []
        while len(anIters):
          aLast = anIters[len(anIters) - 1]
          if aLast.More():
            aSO = aLast.Value()
            anIOR = aSO.GetIOR()
            if len(anIOR):
              aSOList.append(aSO)
            anIters.append(aStudy.NewChildIterator(aSO))
            aLast.Next()
          else:
            anIters.remove(aLast)

        for aSO in aSOList: # for each sobject export shapes stream if exists
          anIOR = aSO.GetIOR()
          if not len(anIOR):
            continue
          anObj = salome.orb.string_to_object(anIOR)
          if type(anObj) == SHAPERSTUDY_ORB._objref_SHAPER_Group:
            if len(aResult):
              aResult += '|'
            # store internal entry, type and list of indices of the group selection (separated by spaces)
            aResult += anObj.GetEntry() + "|" + str(anObj.GetSelectionType())
            aSelList = anObj.GetSelection()
            aResult += "|" + str(' '.join(str(anI) for anI in aSelList))
            aSelListOld = anObj.GetSelectionOld()
            aResult += ";" + str(' '.join(str(anI) for anI in aSelListOld))
          elif type(anObj) == SHAPERSTUDY_ORB._objref_SHAPER_Field:
            if len(aResult):
              aResult += '|'
            # same as for group, but in addition to the second string part - field specifics
            aResult += anObj.GetEntry() + "|" + str(anObj.GetSelectionType())
            aResult += " " + str(anObj.GetDataType()) # values type
            aSteps = anObj.GetSteps()
            aResult += " " + str(len(aSteps)) # number of steps
            aComps = anObj.GetComponents()
            aResult += " " + str(len(aComps)) # number of components
            for aComp in aComps: # components strings: but before remove spaces and '|'
              aCoded = aComp.replace(" ", "__space__").replace("|", "__vertical_bar__")
              aResult += " " + aCoded
            for aStepNum in range(len(aSteps)):
              aVals = anObj.GetStep(aStepNum + 1).GetValues()
              if aStepNum == 0:
                aResult += " " + str(len(aVals)) # first the number of values in the step
              aResult += " " + str(anObj.GetStep(aStepNum + 1).GetStamp()) # ID of stamp in step
              for aVal in aVals:
                aResult += " " + str(aVal) # all values of step
            aSelList = anObj.GetSelection()
            aResult += "|" + str(' '.join(str(anI) for anI in aSelList))
            aSelListOld = anObj.GetSelectionOld()
            aResult += ";" + str(' '.join(str(anI) for anI in aSelListOld))
          elif isinstance(anObj, SHAPERSTUDY_ORB._objref_SHAPER_Object):
            if len(aResult):
              aResult += '|'
            # store internal entry + tick, current and old shapes in BRep format
            aResult += anObj.GetEntry() + " " + str(anObj.GetTick())
            aResult += "|" + anObj.GetShapeStream().decode()
            aResult += "|" + anObj.GetOldShapeStream().decode()

        return aResult.encode()

    def Load( self, component, stream, URL, isMultiFile ):
        """
        Loads data
        """
        global __entry2IOR__
        __entry2IOR__.clear()
        aList=stream.decode().split('|')
        aSubNum = 1
        anId = ""
        aNewShapeStream = ""
        for aSub in aList:
          if aSubNum == 1:
            anId = aSub
            aSubNum = 2
          elif aSubNum == 2:
            aNewShapeStream = aSub
            aSubNum = 3
          else: # create objects by 3 arguments
            anObj = None
            if anId.startswith('group') or (anId.startswith('dead') and anId.count("group") > 0): # group object
              anObj = SHAPERSTUDY_Object.SHAPERSTUDY_Group()
              if len(aSub):
                aSel = aSub.split(";")
                if len(aSel) > 1 and len(aSel[1]):
                  anObj.SetSelection([int(anI) for anI in aSel[1].split(' ')]) # old selection
                anObj.SetSelection([int(anI) for anI in aSel[0].split(' ')])
              anObj.SetSelectionType(int(aNewShapeStream))
            elif anId.startswith('field') or (anId.startswith('dead') and anId.count("field") > 0): # field object
              anObj = SHAPERSTUDY_Object.SHAPERSTUDY_Field()
              if len(aSub):
                aSel = aSub.split(";")
                if len(aSel) > 1:
                  anObj.SetSelection([int(anI) for anI in aSel[1].split(' ')]) # old selection
                anObj.SetSelection([int(anI) for anI in aSel[0].split(' ')])
              aParams = aNewShapeStream.split(" ")
              anObj.SetSelectionType(int(aParams[0]))
              aTypeStr = aParams[1]
              if (aTypeStr == "FDT_Bool"):
                anObj.SetValuesType(0)
              elif (aTypeStr == "FDT_Int"):
                anObj.SetValuesType(1)
              elif (aTypeStr == "FDT_Double"):
                anObj.SetValuesType(2)
              elif (aTypeStr == "FDT_String"):
                anObj.SetValuesType(3)
              aSteps = []
              aNumSteps = int(aParams[2])
              for aVal in range(aNumSteps):
                aSteps.append(aVal + 1)
              anObj.SetSteps(aSteps)
              aCompNum = int(aParams[3])
              aCompNames = []
              for aCompNameIndex in range(aCompNum):
                aCompName = aParams[4 + aCompNameIndex].replace("__space__", " ").replace("__vertical_bar__", "|")
                aCompNames.append(aCompName)
              anObj.SetComponents(aCompNames)
              aNumValsInStep = int(aParams[4 + aCompNum])
              for aStepNum in range(aNumSteps):
                aStepStartIndex = 4 + aCompNum + aStepNum * (aNumValsInStep + 1) + 1
                aStampId = int(aParams[aStepStartIndex])
                aVals = []
                for aValIndex in range(aNumValsInStep):
                  aVals.append(float(aParams[aStepStartIndex + aValIndex + 1]))
                anObj.AddFieldStep(aStampId, aStepNum + 1, aVals)
              anObj.SetTick(-3)
            else: # shape object by BRep in the stream: set old first then new
              anObj = SHAPERSTUDY_Object.SHAPERSTUDY_Object()
              if len(aSub):
                anObj.SetShapeByStream(aSub)
              anObj.SetShapeByStream(aNewShapeStream)
            if anObj:
              anEntryAndTick = anId.split(" ")
              anObj.SetEntry(anEntryAndTick[0])
              if len(anEntryAndTick) > 1:
                anObj.SetTick(int(anEntryAndTick[1]))
              anIOR = salome.orb.object_to_string(anObj._this())
              __entry2IOR__[anEntryAndTick[0]] = anIOR
            aSubNum = 1
        return 1
        
    def IORToLocalPersistentID(self, sobject, IOR, isMultiFile, isASCII):
        """
        Gets persistent ID for the CORBA object.
        The internal entry of the Object is returned.
        """
        anObj = salome.orb.string_to_object(IOR)
        if anObj and (isinstance(anObj, SHAPERSTUDY_ORB._objref_SHAPER_Object) or \
                      isinstance(anObj, SHAPERSTUDY_ORB._objref_SHAPER_Field)):
          return anObj.GetEntry()
        return ""

    def LocalPersistentIDToIOR(self, sobject, persistentID, isMultiFile, isASCII):
        "Converts persistent ID of the object to its IOR."
        global __entry2IOR__
        if persistentID in __entry2IOR__:
          aRes = __entry2IOR__[persistentID]
          if len(aRes): # set SO from the study, the sobject param is temporary, don't store it
             aSO = getStudy().FindObjectID(sobject.GetID())
             anObj = salome.orb.string_to_object(aRes)
             anObj.SetSO(aSO)
             # restore tick of the sub-object
             anIOR = aSO.GetFather().GetIOR()
             if len(anIOR):
               anFatherObj = salome.orb.string_to_object(anIOR)
               if anFatherObj and isinstance(anFatherObj, SHAPERSTUDY_ORB._objref_SHAPER_Object):
                 anObj.SetTick(anFatherObj.GetTick())
          return aRes
        return ""
    
    def UniqueDumpName( self, theBaseName, theID ):
        """
        Returns a unique name from the theBaseName. Keeps theBaseName if it was not used yet.
        Stores the newly generated name into the global map __entry2DumpName__.
        """
        global __entry2DumpName__
        aPrefix = 1
        # to avoid spaces and parenthesis in the variable name
        aBaseName = theBaseName.replace(" ", "_").replace("(", "").replace(")", "")
        aName = aBaseName
        while aName in __entry2DumpName__.values():
          aName = aBaseName + "_" + str(aPrefix)
          aPrefix = aPrefix + 1
        __entry2DumpName__[theID] = aName
        return aName

    def GetShaperEntry(self, theShapeObj):
        """
        Returns string in the python dump that generates the SHAPER entry:
        it may be just entry string, or call for the SHAPER dump variable.
        """
        global __entry2DumpName__
        anEntry = "s" + theShapeObj.GetEntry()
        if anEntry in __entry2DumpName__:
          anArg = ""
          if anEntry.count(":") == 2: # not first result of the feature, set argument as a number
            anArg = ", " + anEntry[anEntry.rfind(":") + 1:]
          return "model.featureStringId(" + __entry2DumpName__[anEntry] + anArg + ")"
        return "\"" + theShapeObj.GetEntry() + "\""

    def OrderGroups(self, theStudy, theStartSO, theIsGroup):
        """
        An internal method for returning sub-groups or sub-fields in a correct order basing on their IDs
        """
        aResult = []
        anIter = theStudy.NewChildIterator(theStartSO)
        anOrder = {} # entry to object
        while anIter.More():
          anSO = anIter.Value()
          anIter.Next()
          anIOR = anSO.GetIOR()
          if len(anIOR):
            anObj = salome.orb.string_to_object(anIOR)
            if (theIsGroup and isinstance(anObj, SHAPERSTUDY_ORB._objref_SHAPER_Group)) or \
               (not theIsGroup and isinstance(anObj, SHAPERSTUDY_ORB._objref_SHAPER_Field)):
              anEntry = anObj.GetEntry()
              aSplit = anEntry.split(":")
              if len(aSplit) > 1 and aSplit[1].isdecimal():
                anID = int(aSplit[1])
                anOrder[anID] = anObj

        for aKey in sorted(anOrder.keys()):
          aResult.append(anOrder[aKey])

        return aResult


    def DumpPython( self, isPublished, isMultiFile ):
        """
        Dump module data to the Python script.
        """
        global __entry2DumpName__
        # remove all non-SHAPER entries
        aCopyMap = {}
        for anEntry in __entry2DumpName__:
          if anEntry.startswith("s"):
            aCopyMap[anEntry] = __entry2DumpName__[anEntry]
        __entry2DumpName__ = aCopyMap

        anArchiveNum = 1
        # collect all shape-objects in the SHAPERSTUDY tree
        aShapeObjects = []
        aStudy = getStudy()
        aRoots = aStudy.NewChildIterator(findOrCreateComponent())
        while aRoots.More():
          aSO = aRoots.Value()
          anIOR = aSO.GetIOR()
          if len(anIOR):
            anObj = salome.orb.string_to_object(anIOR)
            if anObj and type(anObj) == SHAPERSTUDY_ORB._objref_SHAPER_Object:
              aShapeObjects.append(anObj)
          aRoots.Next()
        script = []
        if len(aShapeObjects):
          if isMultiFile:
            script.append("import string, os, sys, re, inspect")
            script.append("thisFile   = inspect.getfile( inspect.currentframe() )")
            script.append("thisModule = os.path.splitext( os.path.basename( thisFile ))[0]")
            script.append("sys.path.insert( 0, os.path.dirname( thisFile ))")
            script.append("exec(\"from \"+re.sub(\"SHAPERSTUDY$\",\"SHAPER\",thisModule)+\" import *\")")
            script.append("")
            script.append("def RebuildData():")
            script.append("  from salome.shaper import model")
            script.append("  model.publishToShaperStudy()")
            script.append("  import SHAPERSTUDY")
          else:
            script.append("model.publishToShaperStudy()")
            script.append("import SHAPERSTUDY")

          for aShapeObj in aShapeObjects:
            # check this shape also has sub-groups and fields
            anOrderedGroups = self.OrderGroups(aStudy, aShapeObj.GetSO(), True)
            anOrderedFields = self.OrderGroups(aStudy, aShapeObj.GetSO(), False)
            anObjects = anOrderedGroups + anOrderedFields

            aGroupVarNames = []
            for anObj in anObjects:
              aGroupVarName = self.UniqueDumpName(anObj.GetName(), anObj.GetSO().GetID())
              aGroupVarNames.append(aGroupVarName)

            aShapeVar = self.UniqueDumpName(aShapeObj.GetName(), aShapeObj.GetSO().GetID())
            aShapeStr = aShapeVar + ", "
            for aGName in aGroupVarNames:
              aShapeStr += aGName + ", "
            if isMultiFile:
              aShapeStr = aShapeStr[:-2]
              script.append("  global " + aShapeStr)
              aShapeStr +=", "
            aShaperEntry = self.GetShaperEntry(aShapeObj)
            aShapeStr += "= SHAPERSTUDY.shape(" + aShaperEntry +")"
            # 18884 : comment the line with dead shapes for now
            if aShaperEntry.startswith("\"dead"):
              script.append("# This shape does not exist among the SHAPER results; if it is referenced by SMESH, this may cause an error")
              aShapeStr = "# " + aShapeStr
            script.append("  " + aShapeStr)if isMultiFile else script.append(aShapeStr)
            # dump also dead-shapes with groups and fields in the XAO format
            aRes, aHistSO = aShapeObj.GetSO().FindSubObject(10000) # the History folder
            if aRes:
              aDeads = aStudy.NewChildIterator(aHistSO)
              while aDeads.More():
                aDSO = aDeads.Value()
                aDIOR = aDSO.GetIOR()
                if len(aDIOR):
                  aDeadShape = salome.orb.string_to_object(aDIOR)
                  if aDeadShape and type(aDeadShape) == SHAPERSTUDY_ORB._objref_SHAPER_Object:
                    aDeadString = ""
                    aXAO = StudyData_Swig.StudyData_XAO()
                    aXAO.SetShape(aDeadShape.getShape())
                    anArchiveName = "archive_" + str(anArchiveNum) + ".xao"
                    if len(aStudy.GetDumpPath()):
                      anArchiveName = aStudy.GetDumpPath() + "/" + anArchiveName
                    anArchiveNum += 1
                    aDeadVarName = self.UniqueDumpName(aDeadShape.GetName(), aDSO.GetID())
                    aDeadString += aDeadVarName + ", "

                    aGroups = self.OrderGroups(aStudy, aDSO, True)
                    for aDeadGroup in aGroups:
                      aDGroupVarName = self.UniqueDumpName(aDeadGroup.GetName(), aDeadGroup.GetSO().GetID())
                      aDeadString += aDGroupVarName + ", "
                      aGroupID = aXAO.AddGroup(aDeadGroup.GetSelectionType(), aDGroupVarName)
                      for aSel in aDeadGroup.GetSelection():
                        aXAO.AddGroupSelection(aGroupID, aSel)

                    aFields = self.OrderGroups(aStudy, aDSO, False)
                    for aDeadField in aFields:
                      aDFieldVarName = self.UniqueDumpName(aDeadField.GetName(), aDeadField.GetSO().GetID())
                      aDeadString += aDFieldVarName + ", "
                      aComponents = aDeadField.GetComponents()
                      aFieldID = aXAO.AddField(aDeadField.GetValuesType(), aDeadField.GetSelectionType(), \
                        len(aComponents), aDFieldVarName)
                      for aCompIndex in range(len(aComponents)):
                        aXAO.SetFieldComponent(aFieldID, aCompIndex, aComponents[aCompIndex])
                      aSteps = aDeadField.GetSteps()
                      for aStep in aSteps:
                        aFieldStep = aDeadField.GetStep(aStep)
                        aXAO.AddStep(aFieldID, aStep, aFieldStep.GetStamp())
                        aStepVals = aFieldStep.GetValues()
                        for aValue in aStepVals:
                          aXAO.AddStepValue(aFieldID, aStep, str(aValue))

                    aXAO.Export(anArchiveName)
                    aDeadString += " = SHAPERSTUDY.archive(" + aShapeVar + ", \"" + anArchiveName + "\")"
                    script.append("  " + aDeadString) if isMultiFile else script.append("aDeadString")
                aDeads.Next()
          pass
        
        script.append("") # to have an end-line in the end
        result_str = "\n".join(script)
        encoded_str = result_str.encode() + b'\0' # to avoid garbage symbols in the end
        return (encoded_str, 1)

    def GetAllDumpNames( self ):
        """
        Returns all names with which Object's was dumped
        into python script to avoid the same names in SMESH script
        """
        global __entry2DumpName__
        aResultList = []
        for anEntry in __entry2DumpName__:
          aResultList.append(__entry2DumpName__[anEntry])
        return aResultList

    def GetDumpName( self, theStudyEntry ):
        """
        Returns a name with which a GEOM_Object was dumped into python script

        Parameters:
            theStudyEntry is an entry of the Object in the study
        """
        global __entry2DumpName__
        if theStudyEntry in __entry2DumpName__:
          return __entry2DumpName__[theStudyEntry]
        return ""

    def BreakLink(self, theEntry):
        """
        Breaks links to not-dead shape, make the shape as dead
        """
        aStudy = getStudy()
        aSO = aStudy.FindObjectID(theEntry)
        if not aSO:
          return
        aRes, aSSO = aSO.ReferencedObject()
        if not aRes:
          return # only SObjects referenced to the SHAPER STUDY objects are allowed
        anIOR = aSSO.GetIOR()
        if not anIOR:
          return # must be referenced to the SHAPER STUDY shape
        anObj = salome.orb.string_to_object(anIOR)
        if not anObj or not isinstance(anObj, SHAPERSTUDY_ORB._objref_SHAPER_Object):
          return
        if anObj.IsDead():
          return # do nothing for reference to already dead shape
        aDeadShape = anObj.MakeDead()
        
        aMeshSObject = aSO.GetFather()
        aMeshObject = aMeshSObject.GetObject()

        aBuilder = aStudy.NewBuilder()
        aBuilder.RemoveReference(aSO) # reset reference to the dead shape
        aBuilder.Addreference(aSO, aDeadShape.GetSO())

        # check also sub-structure of the mesh to find references to sub-objects that become dead
        breakLinkForSubElements(aSO, aDeadShape)

        # Replace shape object in the parent mesh
        aMeshObject.ReplaceShape(aDeadShape)

def shape(theEntry):
  """
  Searches a shape object by the SHAPER entry. Used in the python dump script
  """
  aStudy = getStudy()
  aRoots = aStudy.NewChildIterator(findOrCreateComponent())
  while aRoots.More():
    aSO = aRoots.Value()
    anIOR = aSO.GetIOR()
    if len(anIOR):
      anObj = salome.orb.string_to_object(anIOR)
      if anObj and type(anObj) == SHAPERSTUDY_ORB._objref_SHAPER_Object and anObj.GetEntry() == theEntry:
        aRes = (anObj,)
        # add groups and fields to the result
        aSOIter = aStudy.NewChildIterator(aSO)
        while aSOIter.More():
          aGroupSO = aSOIter.Value()
          anIOR = aGroupSO.GetIOR()
          if len(anIOR):
            aGroup = salome.orb.string_to_object(anIOR)
            if isinstance(aGroup, SHAPERSTUDY_ORB._objref_SHAPER_Group) or \
               isinstance(aGroup, SHAPERSTUDY_ORB._objref_SHAPER_Field):
              aRes = aRes + (aGroup,)
          aSOIter.Next()
        return aRes
    aRoots.Next()
  return None # not found

def archive(theShape, theXAOFile):
  """
  Creates a dead shapes under the theShape and restores these dead objects state basing on theXAOFile
  """
  theShape.MakeDead()
  aStudy = getStudy()
  # searching for the last dead
  aDeads = aStudy.NewChildIterator(theShape.GetSO().FindSubObject(10000)[1])
  aLastDeadSO = aDeads.Value()
  while aDeads.More():
    aLastDeadSO = aDeads.Value()
    aDeads.Next()

  aDShape = aLastDeadSO.GetObject()
  if aDShape:
    aXAO = StudyData_Swig.StudyData_XAO()
    anError = aXAO.Import(theXAOFile)
    if (len(anError)):
      print("Error of XAO file import: " + anError)
      return None
    aDShape.SetShapeByPointer(aXAO.GetShape())
    aRes = (aDShape,)
    # add groups and fields to the result
    aGroupIndex = 0
    aFieldIndex = 0
    aSOIter = aStudy.NewChildIterator(aLastDeadSO)
    while aSOIter.More():
      aGroupSO = aSOIter.Value()
      anIOR = aGroupSO.GetIOR()
      if len(anIOR):
        aGroup = salome.orb.string_to_object(anIOR)
        if isinstance(aGroup, SHAPERSTUDY_ORB._objref_SHAPER_Group):
          aRes += (aGroup,)
          aGroup.SetSelectionType(aXAO.GetGroupDimension(aGroupIndex))
          aSelection = []
          for aSel in aXAO.GetGroupSelection(aGroupIndex):
            aSelection.append(aSel)
          aGroup.SetSelection(aSelection)
          aGroupIndex += 1
        elif isinstance(aGroup, SHAPERSTUDY_ORB._objref_SHAPER_Field):
          aField = aGroup
          aRes += (aField,)
          aValType = aXAO.GetValuesType(aFieldIndex)
          aField.SetValuesType(aValType)
          aField.SetSelectionType(aXAO.GetSelectionType(aFieldIndex))
          aCompNames = []
          for aCompName in aXAO.GetComponents(aFieldIndex):
            aCompNames.append(aCompName)
          aField.SetComponents(aCompNames)
          aField.ClearFieldSteps()
          aXAO.BeginSteps(aFieldIndex)
          while aXAO.More(aFieldIndex):
            aValsList = []
            for aVal in aXAO.GetValues():
              if aValType == 0: # boolean
                aValsList.append(int(aVal))
              elif aValType == 1: # int
                aValsList.append(int(aVal))
              elif aValType == 2: # double
                aValsList.append(float(aVal))
            aField.AddFieldStep(aXAO.GetStamp(), aXAO.GetStepIndex(), aValsList)
            aXAO.Next()
          aFieldIndex += 1
      aSOIter.Next()
    return aRes
  return None # not found

def isFather(theFather, theChild):
    """
    Returns true if theChild SObject is a child of theFather SObject
    """
    aChild = theChild.GetFather()
    while aChild.Depth() > theFather.Depth():
      aChild = aChild.GetFather()
    return aChild.GetID() == theFather.GetID()

def breakLinkForSubElements(theMainShapeSO, theDeadShape):
  """
  Checks sub-structure of the SMESH-mesh to find references to sub-objects that become dead.
  theMainShapeSO is SObject with reference to real SHAPERSTUDY shape, located under the Mesh node.
  theDeadShape is a newly created dead shape instance
  """
  aStudy = getStudy()
  aBuilder = aStudy.NewBuilder()
  aRoot = theMainShapeSO.GetFather()
  anIters = [aStudy.NewChildIterator(aRoot)]
  aSubList = []
  anOriginShapeSO = theDeadShape.GetSO().GetFather().GetFather()
  while len(anIters):
    aLast = anIters[len(anIters) - 1]
    if aLast.More():
      aSub = aLast.Value()
      aRes, aSubRef = aSub.ReferencedObject()
      if aRes and isFather(anOriginShapeSO, aSubRef):
        aReferenced = aSubRef.GetObject()
        if aReferenced and not aReferenced.IsDead():
          aSubList.append(aSub)
      anIters.append(aStudy.NewChildIterator(aSub))
      aLast.Next()
    else:
      anIters.remove(aLast)
  if len(aSubList):
    # associate the number of sub-objects of the referenced objects
    aMapSubEntryToIndex = {}
    aSSOIter = aStudy.NewChildIterator(anOriginShapeSO)
    anIndex = 1
    while aSSOIter.More():
      aSub = aSSOIter.Value()
      if aSub.GetIOR():
        aMapSubEntryToIndex[aSub.GetID()] = anIndex
        anIndex = anIndex + 1
      aSSOIter.Next()
    for aSubSO in aSubList:
      aRes, aSubRef = aSubSO.ReferencedObject()
      if aRes and aSubRef.GetID() in aMapSubEntryToIndex:
        anIndex = aMapSubEntryToIndex[aSubRef.GetID()]
        aDeadIter = aStudy.NewChildIterator(theDeadShape.GetSO())
        while aDeadIter.More(): # iterate dead subs to find object with the same index
          aDeadSubSO = aDeadIter.Value()
          if aDeadSubSO.GetIOR():
            anIndex = anIndex - 1
            if anIndex == 0:
              aBuilder.RemoveReference(aSubSO) # reset reference to the dead shape
              aBuilder.Addreference(aSubSO, aDeadSubSO)
          aDeadIter.Next()
  pass

class SHAPERSTUDY(SHAPERSTUDY_Gen, SHAPERSTUDY_ORB__POA.Gen, SALOME_ComponentPy.SALOME_ComponentPy_i, SALOME_DriverPy.SALOME_DriverPy_i):
    """
    Implementation with naming_service server.
    """
    def __init__ ( self, orb, poa, contID, containerName, instanceName, interfaceName ):
        """
        Construct an instance of SHAPERSTUDY module engine.
        The class SHAPERSTUDY implements CORBA interface Gen (see SHAPERSTUDY_Gen.idl).
        It is inherited (via GEOM_Gen) from the classes SALOME_ComponentPy_i (implementation of
        Engines::EngineComponent CORBA interface - SALOME component) and SALOME_DriverPy_i
        (implementation of SALOMEDS::Driver CORBA interface - SALOME module's engine).
        """
        global __entry2IOR__, __entry2DumpName__
        __entry2IOR__.clear()
        __entry2DumpName__.clear()
        SALOME_ComponentPy.SALOME_ComponentPy_i.__init__(self, orb, poa, contID, containerName, instanceName, interfaceName, False)
        SALOME_DriverPy.SALOME_DriverPy_i.__init__(self, interfaceName)
        pass

class SHAPERSTUDY_No_Session(SHAPERSTUDY_Gen, SHAPERSTUDY_ORB__POA.Gen, SALOME_ComponentPy.SALOME_ComponentPy_Gen_i, SALOME_DriverPy.SALOME_DriverPy_i):
    """
    Implementation without naming_service server.
    """
    def __init__ ( self, orb, poa, contID, containerName, instanceName, interfaceName ):
        global __entry2IOR__, __entry2DumpName__
        __entry2IOR__.clear()
        __entry2DumpName__.clear()
        SALOME_ComponentPy.SALOME_ComponentPy_Gen_i.__init__(self, orb, poa, contID, containerName, instanceName, interfaceName, False)
        SALOME_DriverPy.SALOME_DriverPy_i.__init__(self, interfaceName)
        pass
