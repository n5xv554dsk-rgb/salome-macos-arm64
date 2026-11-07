# -*- coding: utf-8 -*-
# Copyright (C) 2007-2026  CEA, EDF
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

##
# @package HYBRIDPluginBuilder
# Python API for the HYBRID meshing plug-in module.

from salome.smesh.smesh_algorithm import Mesh_Algorithm
from salome.smesh.smeshBuilder import AssureGeomPublished

# import HYBRIDPlugin module if possible
noHYBRIDPlugin = 0
try:
    from salome.kernel import HYBRIDPlugin
    from salome.kernel import HYBRIDPlugin__POA
except ImportError:
    noHYBRIDPlugin = 1
    pass

# Optimization level of HYBRID
# V3.1
None_Optimization, Light_Optimization, Medium_Optimization, Strong_Optimization = 0,1,2,3
# V4.1 (partialy redefines V3.1). Issue 0020574
None_Optimization, Light_Optimization, Standard_Optimization, StandardPlus_Optimization, Strong_Optimization = 0,1,2,3,4

# Collision Mode
Decrease_Collision_Mode, Stop_Collision_Mode = 0,1

# Boundary Layers growing inward or outward.
Layer_Growth_Inward, Layer_Growth_Outward = 0,1

# Mesh with element type Tetra Dominant or hexa Dominant in the remaining volume (outside layers).
Generation_Tetra_Dominant, Generation_Hexa_Dominant, Generation_Cartesian_Core = 0,1,2

#----------------------------
# Mesh algo type identifiers
#----------------------------

## Algorithm type: HYBRID tetra-hexahedron 3D algorithm, see HYBRID_Algorithm
MG_Hybrid = "HYBRID_3D"
HYBRID = MG_Hybrid

## MG-Hybrid 3D algorithm
#  
#  It can be created by calling smeshBuilder.Mesh.Tetrahedron( smeshBuilder.HYBRID, geom=0 )
class HYBRID_Algorithm(Mesh_Algorithm):

    ## name of the dynamic method in smeshBuilder.Mesh class
    #  @internal
    meshMethod = "Tetrahedron"
    ## type of algorithm used with helper function in smeshBuilder.Mesh class
    #  @internal
    algoType   = MG_Hybrid
    ## doc string of the method in smeshBuilder.Mesh class
    #  @internal
    docHelper  = "Creates tetrahedron 3D algorithm for volumes"

    ## Private constructor.
    #  @param mesh parent mesh object algorithm is assigned to
    #  @param geom geometry (shape/sub-shape) algorithm is assigned to;
    #              if it is @c 0 (default), the algorithm is assigned to the main shape
    def __init__(self, mesh, geom=0):
        Mesh_Algorithm.__init__(self)
        if noHYBRIDPlugin: print("Warning: HYBRIDPlugin module unavailable")
        self.Create(mesh, geom, self.algoType, "libHYBRIDEngine.so")
        self.params = None
        pass

    ## Defines hypothesis having several parameters
    #  @return hypothesis object
    def Parameters(self):
        if not self.params:
            self.params = self.Hypothesis("HYBRID_Parameters", [],
                                          "libHYBRIDEngine.so", UseExisting=0)
            pass
        return self.params

    ## To call MG-Hybrid by library. Default is no (i.e. by executable)
    #  @param toUseLib "mesh layers on all wrap" flag value
    def SetToUseLibrary(self, toUseLib):
        self.Parameters().SetToUseLibrary(toUseLib)
        pass

    ## To mesh layers on all wrap. Default is to mesh.
    #  @param toMesh "mesh layers on all wrap" flag value
    def SetLayersOnAllWrap(self, toMesh):
        self.Parameters().SetLayersOnAllWrap(toMesh)
        pass

    ## To mesh layers on given faces.
    #  @param faceIDs faces or face IDs to construct boundary layers on
    def SetFacesWithLayers(self, faceIDs):
        from salome.kernel import GEOM
        ids = []
        if not isinstance( faceIDs, list ) and not isinstance( faceIDs, tuple ):
            faceIDs = [ faceIDs ]
        for fid in faceIDs:
            if isinstance( fid, int ):
                ids.append( fid )
            elif isinstance( fid, GEOM._objref_GEOM_Object):
                faces = self.mesh.geompyD.SubShapeAll( fid, self.mesh.geompyD.ShapeType["FACE"])
                for f in faces:
                    ids.append( self.mesh.geompyD.GetSubShapeID( self.mesh.geom, f ))
            else:
                raise TypeError("Face should be either ID or GEOM_Object, not %s" % type(fid))
            pass
        self.Parameters().SetFacesWithLayers(ids)
        if ids:
            self.SetLayersOnAllWrap( False )
        pass

    ## To imprint the layers on given faces.
    #  @param faceIDs faces or face IDs to imprint the boundary layers on
    def SetFacesWithImprinting(self, faceIDs):
        from salome.kernel import GEOM
        ids = []
        if not isinstance( faceIDs, list ) and not isinstance( faceIDs, tuple ):
            faceIDs = [ faceIDs ]
        for fid in faceIDs:
            if isinstance( fid, int ):
                ids.append( fid )
            elif isinstance( fid, GEOM._objref_GEOM_Object):
                faces = self.mesh.geompyD.SubShapeAll( fid, self.mesh.geompyD.ShapeType["FACE"])
                for f in faces:
                    ids.append( self.mesh.geompyD.GetSubShapeID( self.mesh.geom, f ))
            else:
                raise TypeError("Face should be either ID or GEOM_Object, not %s" % type(fid))
            pass
        self.Parameters().SetFacesWithImprinting(ids)
        if ids:
            self.SetLayersOnAllWrap( False )
        pass

    ## To snap the layers on given surface (use existing surface layers as base for volume layers).
    #  @param faceIDs faces or face IDs that already have surface layers
    def SetFacesWithSnapping(self, faceIDs):
        from salome.kernel import GEOM
        ids = []
        if not isinstance( faceIDs, list ) and not isinstance( faceIDs, tuple ):
            faceIDs = [ faceIDs ]
        for fid in faceIDs:
            if isinstance( fid, int ):
                ids.append( fid )
            elif isinstance( fid, GEOM._objref_GEOM_Object):
                faces = self.mesh.geompyD.SubShapeAll( fid, self.mesh.geompyD.ShapeType["FACE"])
                for f in faces:
                    ids.append( self.mesh.geompyD.GetSubShapeID( self.mesh.geom, f ))
            else:
                raise TypeError("Face should be either ID or GEOM_Object, not %s" % type(fid))
            pass
        self.Parameters().SetFacesWithSnapping(ids)
        if ids:
            self.SetLayersOnAllWrap( False )
        pass

    ## Set Collision Mode:
    #  @param mode Collision Mode, one of the following values
    #  - Decrease_Collision_Mode
    #  - Stop_Collision_Mode
    #  .
    #  Default is Decrease_Collision_Mode
    def SetCollisionMode(self, mode):
        self.Parameters().SetCollisionMode(mode)
        pass

    ## To mesh Boundary Layers growing inward or outward.
    #  @param mode, one of the following values
    #  - Layer_Growth_Inward
    #  - Layer_Growth_Outward
    #  .
    #  Default is Layer_Growth_Inward
    def SetBoundaryLayersGrowth(self, mode):
        self.Parameters().SetBoundaryLayersGrowth(mode)
        pass

    ## To mesh with element type Tetra Dominant or hexa Dominant in the remaining volume (outside layers).
    #  @param mode, one of the following values
    #  - Generation_Tetra_Dominant
    #  - Generation_Hexa_Dominant
    #  - Generation_Cartesian_Core
    #  .
    # Default is Generation_Tetra_Dominant
    def SetElementGeneration(self, mode):
        self.Parameters().SetElementGeneration(mode)
        pass

    ## To mesh adding extra normals at opening ridges and corners.
    # Default is no.
    # @param addMultinormals boolean value
    def SetAddMultinormals(self, addMultinormals):
        self.Parameters().SetAddMultinormals(addMultinormals)
        pass

    ## To mesh smoothing normals at closed ridges and corners.
    # Default is no.
    # @param smoothNormals boolean value
    def SetSmoothNormals(self, smoothNormals):
        self.Parameters().SetSmoothNormals(smoothNormals)
        pass

    ## To set height of the first layer.
    # Default is 0.0
    # @param heightFirstLayer double value
    def SetHeightFirstLayer(self, heightFirstLayer):
        self.Parameters().SetHeightFirstLayer(heightFirstLayer)
        pass

    ## Sizes of boundary layers are relative to the surface size. Default no
    #  @param isRelative boolean flag
    def SetHeightIsRelative(self, isRelative):
        self.Parameters().SetHeightIsRelative( isRelative )
        pass

    ## To set boundary layers coefficient of geometric progression.
    # Default is 1.0
    # @param boundaryLayersProgression double value
    def SetBoundaryLayersProgression(self, boundaryLayersProgression):
        self.Parameters().SetBoundaryLayersProgression(boundaryLayersProgression)
        pass

    ## Set core elements size.
    # Default is 0.0
    # @param CoreSize double value
    def SetCoreSize(self, CoreSize):
        self.Parameters().SetCoreSize(CoreSize)
        pass

    ## To set multinormals angle threshold at opening ridges.
    # Default is 30.0
    # @param multinormalsAngle double value
    def SetMultinormalsAngle(self, multinormalsAngle):
        self.Parameters().SetMultinormalsAngle(multinormalsAngle)
        pass

    ## To set number of boundary layers.
    # Default is 1
    # @param nbOfBoundaryLayers int value
    def SetNbOfBoundaryLayers(self, nbOfBoundaryLayers):
        self.Parameters().SetNbOfBoundaryLayers(nbOfBoundaryLayers)
        pass

    ## Set maximum internal angles of boundary elements (in degree)
    #  @param angle angle in degree
    def SetBoundaryLayersMaxElemAngle(self, angle):
        self.Parameters().SetBoundaryLayersMaxElemAngle( angle )
        pass

    ## Set path to working directory.
    #  @param path working directory
    def SetWorkingDirectory(self, path):
        self.Parameters().SetWorkingDirectory(path)
        pass

    ## To keep working files or remove them.
    #  @param toKeep "keep working files" flag value
    def SetKeepFiles(self, toKeep):
        self.Parameters().SetKeepFiles(toKeep)
        pass
    
    ## Remove or not the log file (if any) in case of successful computation.
    #  The log file remains in case of errors anyway. If 
    #  the "keep working files" flag is set to true, this option
    #  has no effect.
    #  @param toRemove "remove log on success" flag value
    def SetRemoveLogOnSuccess(self, toRemove):
        self.Parameters().SetRemoveLogOnSuccess(toRemove)
        pass
    
    ## Print the the log in a file. If set to false, the
    # log is printed on the standard output
    #  @param toPrintLogInFile "print log in a file" flag value
    def SetPrintLogInFile(self, toPrintLogInFile):
        self.Parameters().SetStandardOutputLog(not toPrintLogInFile)
        pass

    ## Set verbosity level [0-10].
    #  @param level verbosity level
    #  - 0 - no standard output,
    #  - 2 - prints the data, quality statistics of the skin and final meshes and
    #    indicates when the final mesh is being saved. In addition the software
    #    gives indication regarding the CPU time.
    #  - 10 - same as 2 plus the main steps in the computation, quality statistics
    #    histogram of the skin mesh, quality statistics histogram together with
    #    the characteristics of the final mesh.
    def SetVerboseLevel(self, level):
        self.Parameters().SetVerboseLevel(level)
        pass

    ## To create new nodes.
    #  @param toCreate "create new nodes" flag value
    def SetToCreateNewNodes(self, toCreate):
        self.Parameters().SetToCreateNewNodes(toCreate)
        pass

    ## To use boundary recovery version which tries to create mesh on a very poor
    #  quality surface mesh.
    #  @param toUse "use boundary recovery version" flag value
    def SetToUseBoundaryRecoveryVersion(self, toUse):
        self.Parameters().SetToUseBoundaryRecoveryVersion(toUse)
        pass

    ## Applies finite-element correction by replacing overconstrained elements where
    #  it is possible. The process is cutting first the overconstrained edges and
    #  second the overconstrained facets. This insure that no edges have two boundary
    #  vertices and that no facets have three boundary vertices.
    #  @param toUseFem "apply finite-element correction" flag value
    def SetFEMCorrection(self, toUseFem):
        self.Parameters().SetFEMCorrection(toUseFem)
        pass

    ## To remove initial central point.
    #  @param toRemove "remove initial central point" flag value
    def SetToRemoveCentralPoint(self, toRemove):
        self.Parameters().SetToRemoveCentralPoint(toRemove)
        pass

    ## To set an enforced vertex.
    #  @param x            : x coordinate
    #  @param y            : y coordinate
    #  @param z            : z coordinate
    #  @param size         : size of 1D element around enforced vertex
    #  @param vertexName   : name of the enforced vertex
    #  @param groupName    : name of the group
    def SetEnforcedVertex(self, x, y, z, size, vertexName = "", groupName = ""):
        if vertexName == "":
            if groupName == "":
                return self.Parameters().SetEnforcedVertex(x, y, z, size)
            else:
                return self.Parameters().SetEnforcedVertexWithGroup(x, y, z, size, groupName)
            pass
        else:
            if groupName == "":
                return self.Parameters().SetEnforcedVertexNamed(x, y, z, size, vertexName)
            else:
                return self.Parameters().SetEnforcedVertexNamedWithGroup(x, y, z, size, vertexName, groupName)
            pass
        pass

    ## To set an enforced vertex given a GEOM vertex, group or compound.
    #  @param theVertex    : GEOM vertex (or group, compound) to be projected on theFace.
    #  @param size         : size of 1D element around enforced vertex
    #  @param groupName    : name of the group
    def SetEnforcedVertexGeom(self, theVertex, size, groupName = ""):
        AssureGeomPublished( self.mesh, theVertex )
        if groupName == "":
            return self.Parameters().SetEnforcedVertexGeom(theVertex, size)
        else:
            return self.Parameters().SetEnforcedVertexGeomWithGroup(theVertex, size, groupName)
        pass

    ## To remove an enforced vertex.
    #  @param x            : x coordinate
    #  @param y            : y coordinate
    #  @param z            : z coordinate
    def RemoveEnforcedVertex(self, x, y, z):
        return self.Parameters().RemoveEnforcedVertex(x, y, z)

    ## To remove an enforced vertex given a GEOM vertex, group or compound.
    #  @param theVertex    : GEOM vertex (or group, compound) to be projected on theFace.
    def RemoveEnforcedVertexGeom(self, theVertex):
        AssureGeomPublished( self.mesh, theVertex )
        return self.Parameters().RemoveEnforcedVertexGeom(theVertex)

    ## To set an enforced mesh with given size and add the enforced elements in the group "groupName".
    #  @param theSource    : source mesh which provides constraint elements/nodes
    #  @param elementType  : SMESH.ElementType (NODE, EDGE or FACE)
    #  @param size         : size of elements around enforced elements. Unused if -1.
    #  @param groupName    : group in which enforced elements will be added. Unused if "".
    def SetEnforcedMesh(self, theSource, elementType, size = -1, groupName = ""):
        if size < 0:
            if groupName == "":
                return self.Parameters().SetEnforcedMesh(theSource, elementType)
            else:
                return self.Parameters().SetEnforcedMeshWithGroup(theSource, elementType, groupName)
            pass
        else:
            if groupName == "":
                return self.Parameters().SetEnforcedMeshSize(theSource, elementType, size)
            else:
                return self.Parameters().SetEnforcedMeshSizeWithGroup(theSource, elementType, size, groupName)
            pass
        pass

    ## Set advanced option value
    #  @param optionName option name
    #  @param optionValue option value
    def SetOptionValue(self, optionName, optionValue):
        self.Parameters().SetOptionValue( optionName, optionValue )
        pass

    ## Sets command line option as text.
    #  @param optionAndValue command line option in a form "option value"
    def SetAdvancedOption(self, optionAndValue):
        self.Parameters().SetAdvancedOption(optionAndValue)
        pass
    
    ## Sets command line option as text.
    #
    # OBSOLETE. Use SetAdvancedOption()
    #  @param option command line option
    def SetTextOption(self, option):
        self.Parameters().SetAdvancedOption(option)
        pass
   
    pass # end of HYBRID_Algorithm class
