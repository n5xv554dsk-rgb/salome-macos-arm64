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
# @package BLSURFPluginBuilder
# Python API for the MG-CADSurf meshing plug-in module.

from salome.smesh.smesh_algorithm import Mesh_Algorithm
from salome.kernel import GEOM

LIBRARY = "libBLSURFEngine.so"

# ElementType enum
Triangles, QuadrangleDominant, Quadrangles = 0, 1, 2

# Topology treatment way of MG-CADSurf
FromCAD, PreProcess, PreProcessPlus, PreCAD = 0,1,2,3

# Element size flag of MG-CADSurf
DefaultSize, DefaultGeom, MG_CADSURF_GlobalSize, MG_CADSURF_LocalSize = 0,0,1,2
# Retrocompatibility
MG_CADSURF_Custom, SizeMap = MG_CADSURF_GlobalSize, MG_CADSURF_LocalSize
BLSURF_Custom, BLSURF_GlobalSize, BLSURF_LocalSize = MG_CADSURF_Custom, MG_CADSURF_GlobalSize, MG_CADSURF_LocalSize

# import BLSURFPlugin module if possible
noBLSURFPlugin = 0
try:
  from salome.kernel import BLSURFPlugin
  from salome.kernel import BLSURFPlugin__POA
  from salome.kernel.BLSURFPlugin import MG_EnforcedMesh1D

except ImportError:
  noBLSURFPlugin = 1
  pass

#----------------------------
# Mesh algo type identifiers
#----------------------------

## Algorithm type: MG-CADSurf triangle algorithm, see BLSURF_Algorithm
MG_CADSurf = "MG-CADSurf"
BLSURF = MG_CADSurf

#----------------------
# Algorithms
#----------------------

## MG-CADSurf 2D algorithm.
#
#  It can be created by calling smeshBuilder.Mesh.Triangle(smeshBuilder.MG-CADSurf,geom=0)
#
class BLSURF_Algorithm(Mesh_Algorithm):

  ## name of the dynamic method in smeshBuilder.Mesh class
  #  @internal
  meshMethod = "Triangle"
  ## type of algorithm used with helper function in smeshBuilder.Mesh class
  #  @internal
  algoType   = MG_CADSurf
  ## doc string of the method
  #  @internal
  docHelper  = "Creates triangle algorithm for faces"

  _anisotropic_ratio = 0
  _bad_surface_element_aspect_ratio = 1000
  _geometric_approximation = 22
  _gradation  = 1.3
  _volume_gradation  = 2
  _metric = "isotropic"
  _remove_tiny_edges = 0

  ## Private constructor.
  #  @param mesh parent mesh object algorithm is assigned to
  #  @param geom geometry (shape/sub-shape) algorithm is assigned to;
  #              if it is @c 0 (default), the algorithm is assigned to the main shape
  def __init__(self, mesh, geom=0):
    Mesh_Algorithm.__init__(self)
    if noBLSURFPlugin:
      print("Warning: BLSURFPlugin module unavailable")
    if mesh.GetMesh().HasShapeToMesh():
      self.Create(mesh, geom, self.algoType, LIBRARY)
    else:
      self.Create(mesh, geom, self.algoType+"_NOGEOM", LIBRARY)
      mesh.smeshpyD.SetName( self.algo, self.algoType )
    self.params=None
    self.geompyD = mesh.geompyD
    #self.SetPhysicalMesh() - PAL19680
    pass

  ## Sets a way to define size of mesh elements to generate.
  #  @param thePhysicalMesh is: DefaultSize, MG_CADSURF_Custom or SizeMap.
  def SetPhysicalMesh(self, thePhysicalMesh=DefaultSize):
    physical_size_mode = thePhysicalMesh
    if self.Parameters().GetGeometricMesh() == DefaultGeom:
      if physical_size_mode == DefaultSize:
        physical_size_mode = MG_CADSURF_GlobalSize
    self.Parameters().SetPhysicalMesh(physical_size_mode)
    pass

  ## Sets a way to define maximum angular deflection of mesh from CAD model.
  #  @param theGeometricMesh is: DefaultGeom (0)) or MG_CADSURF_GlobalSize (1))
  def SetGeometricMesh(self, theGeometricMesh=DefaultGeom):
    geometric_size_mode = theGeometricMesh
    if self.Parameters().GetPhysicalMesh() == DefaultSize:
      if geometric_size_mode == DefaultGeom:
        geometric_size_mode = MG_CADSURF_GlobalSize
    self.Parameters().SetGeometricMesh(geometric_size_mode)
    pass

  ## Sets size of mesh elements to generate.
  #  @param theVal : constant global size when using a global physical size.
  #  @param isRelative : if True, the value is relative to the length of the diagonal of the bounding box
  def SetPhySize(self, theVal, isRelative = False):
    if self.Parameters().GetPhysicalMesh() == DefaultSize:
      self.SetPhysicalMesh(MG_CADSURF_GlobalSize)
    if isRelative:
      self.Parameters().SetPhySizeRel(theVal)
    else:
      self.Parameters().SetPhySize(theVal)
    pass

  ## Sets lower boundary of mesh element size.
  #  @param theVal : global minimal cell size desired.
  #  @param isRelative : if True, the value is relative to the length of the diagonal of the bounding box
  def SetMinSize(self, theVal=-1, isRelative = False):
    if isRelative:
      self.Parameters().SetMinSizeRel(theVal)
    else:
      self.Parameters().SetMinSize(theVal)
    pass

  ## Sets upper boundary of mesh element size.
  #  @param theVal : global maximal cell size desired.
  #  @param isRelative : if True, the value is relative to the length of the diagonal of the bounding box
  def SetMaxSize(self, theVal=-1, isRelative = False):
    if isRelative:
      self.Parameters().SetMaxSizeRel(theVal)
    else:
      self.Parameters().SetMaxSize(theVal)
    pass

  ## Sets angular deflection (in degrees) from CAD surface.
  #  @param theVal value of angular deflection
  def SetAngleMesh(self, theVal=_geometric_approximation):
    if self.Parameters().GetGeometricMesh() == DefaultGeom:
      self.SetGeometricMesh(MG_CADSURF_GlobalSize)
    self.Parameters().SetAngleMesh(theVal)
    pass

  ## Sets the maximum desired distance between a triangle and its supporting CAD surface
  #  @param distance the distance between a triangle and a surface
  def SetChordalError(self, distance):
    self.Parameters().SetChordalError(distance)
    pass

  ## Sets maximal allowed ratio between the lengths of two adjacent edges.
  #  @param toUseGradation to use gradation
  #  @param theVal value of maximal length ratio
  def SetGradation(self, toUseGradation=True, theVal=_gradation):
    if isinstance( toUseGradation, float ): ## backward compatibility
      toUseGradation, theVal = True, toUseGradation
    if self.Parameters().GetGeometricMesh() == 0: theVal = self._gradation
    self.Parameters().SetUseGradation(toUseGradation)
    self.Parameters().SetGradation(theVal)
    pass

  ## Sets maximal allowed ratio between the lengths of two adjacent edges in 3D mesh.
  #  @param toUseGradation to use gradation
  #  @param theVal value of maximal length ratio
  def SetVolumeGradation(self, toUseGradation=True, theVal=_gradation):
    if self.Parameters().GetGeometricMesh() == 0: theVal = self._volume_gradation
    self.Parameters().SetUseVolumeGradation(toUseGradation)
    self.Parameters().SetVolumeGradation(theVal)
    pass

  ## Sets topology usage way.
  # @param way defines how mesh conformity is assured <ul>
  # <li>FromCAD - mesh conformity is assured by conformity of a shape</li>
  # <li>PreProcess or PreProcessPlus - by pre-processing a CAD model (OBSOLETE: FromCAD will be used)</li>
  # <li>PreCAD - by pre-processing with PreCAD a CAD model</li></ul>
  def SetTopology(self, way):
    if way != PreCAD and way != FromCAD:
      print("Warning: topology mode %d is no longer supported. Mode FromCAD is used."%way)
      way = FromCAD
    self.Parameters().SetTopology(way)
    pass

  ## Activate/deactivate surface proximity computation
  # @param toUse boolean flag
  #
  def SetSurfaceProximity(self, toUse ):
    self.Parameters().SetSurfaceProximity(toUse)
    return

  ## Set number of surface element layers to be generated due to surface proximity
  # @param nbLayers number of layers
  #
  def SetNbSurfaceProximityLayers(self, nbLayers ):
    self.Parameters().SetNbSurfaceProximityLayers( nbLayers )
    return

  ## Set coefficient by which size of element refined due to surface proximity is increased
  # @param ratio proximity coefficient
  #
  def SetSurfaceProximityRatio(self, ratio ):
    self.Parameters().SetSurfaceProximityRatio(ratio)
    return
  
  ## Activate/deactivate volume proximity computation
  # @param toUse boolean flag
  #
  def SetVolumeProximity(self, toUse ):
    self.Parameters().SetVolumeProximity(toUse)
    return
  
  ## Set number of surface element layers to be generated due to volume proximity
  # @param nbLayers number of layers
  #
  def SetNbVolumeProximityLayers(self, nbLayers ):
    self.Parameters().SetNbVolumeProximityLayers(nbLayers)
    return

  ## Set coefficient by which size of element refined due to volume proximity is increased
  # @param ratio proximity coefficient
  #
  def SetVolumeProximityRatio(self, ratio ):
    self.Parameters().SetVolumeProximityRatio(ratio)
    return


  ## Sets verbosity level in the range 0 to 10.
  #  @param level verbosity level
  def SetVerbosity(self, level):
    self.Parameters().SetVerbosity(level)
    pass

  ## Set enforce_cad_edge_sizes parameter
  #  
  #  Relaxes the given sizemap constraint around CAD edges to allow a better
  #  element quality and a better geometric approximation. It is only useful in 
  #  combination with the gradation option.
  #  
  def SetEnforceCadEdgesSize( self, toEnforce ):
    if not version_less(self.Parameters().GetMeshGemsVersion(), '2.10'):
      print("Warning: method SetEnforceCadEdgesSize() is deprecated")
    self.Parameters().SetEnforceCadEdgesSize( toEnforce )

  ## Set jacobian_rectification_respect_geometry parameter
  #  
  #  While making the mesh quadratic, allows to lose the CAD-mesh associativity in order
  #  to correct elements with nagative Jacobian
  #  
  def SetJacobianRectificationRespectGeometry( self, allowRectification ):
    self.Parameters().SetJacobianRectificationRespectGeometry( allowRectification )
    
  ## Set rectify_jacobian parameter
  #  
  #  While making the mesh quadratic, allow to fix nagative Jacobian surface elements
  #  
  def SetJacobianRectification( self, allowRectification ):
    self.Parameters().SetJacobianRectification( allowRectification )

  ## Set use_deprecated_patch_mesher parameter (compatibility with older versions of Meshgems)
  #  
  # the use_deprecated_patch_mesher parameter allows to keep the same behaviour than
  # in salome < 8.3 (meshgems 2.1.11 instead of meshgems >= 2.4.5)
  #  
  def SetUseDeprecatedPatchMesher( self, useDeprecatedPatchMesher ):
    self.Parameters().SetUseDeprecatedPatchMesher( useDeprecatedPatchMesher )

  ## Set respect_geometry parameter
  #  
  #  This patch independent option can be deactivated to allow MeshGems-CADSurf
  #  to lower the geometry accuracy in its patch independent process.
  #  
  def SetRespectGeometry( self, toRespect ):
    self.Parameters().SetRespectGeometry( toRespect )

  ## Set max_number_of_points_per_patch parameter
  #  
  #  This parameter controls the maximum amount of points MeshGems-CADSurf is allowed
  #  to generate on a single CAD patch. For an automatic gestion of the memory, one
  #  can set this parameter to 0
  #  
  def SetMaxNumberOfPointsPerPatch( self, nb ):
    if not version_less(self.Parameters().GetMeshGemsVersion(), '2.10'):
      print("Warning: method SetMaxNumberOfPointsPerPatch() is deprecated")
    self.Parameters().SetMaxNumberOfPointsPerPatch( nb )

  ## Set max_number_of_threads parameter
  #
  #  Set the maximum of threads to use for multithreading mesh computation
  #
  def SetMaxNumberOfThreads( self, nb ):
    self.Parameters().SetMaxNumberOfThreads( nb )

  ## Set respect_geometry parameter
  #  
  #  This patch independent option can be deactivated to allow MeshGems-CADSurf
  #  to lower the geometry accuracy in its patch independent process.
  #  
  def SetRespectGeometry( self, toRespect ):
    self.Parameters().SetRespectGeometry( toRespect )

  ## Set tiny_edges_avoid_surface_intersections parameter
  #  
  #  This option defines the priority between the tiny feature
  #  suppression and the surface intersection prevention. 
  #  
  def SetTinyEdgesAvoidSurfaceIntersections( self, toAvoidIntersection ):
    self.Parameters().SetTinyEdgesAvoidSurfaceIntersections( toAvoidIntersection )

  ## Set closed_geometry parameter parameter
  #  
  #  Describes whether the geometry is expected to be closed or not. 
  #  When activated, this option helps MeshGems-PreCAD to treat the dirtiest geometries.
  #  
  def SetClosedGeometry( self, isClosed ):
    self.Parameters().SetClosedGeometry( isClosed )

  ## Set debug parameter
  #  
  #  Make MeshGems-CADSurf will be very verbose and will output some intermediate
  #  files in the working directory. This option is mainly meant for Distene support issues.
  #  
  def SetDebug( self, isDebug ):
    self.Parameters().SetDebug( isDebug )

  ## Set periodic_tolerance parameter
  #  
  #  This parameter defines the maximum size difference between two periodic edges
  #  and also the maximum distance error between two periodic entities.
  #  
  def SetPeriodicTolerance( self, tol ):
    self.Parameters().SetPeriodicTolerance( tol )

  ## Set required_entities parameter
  #  
  #  The required entities control the correction operations. 
  #  Accepted values for this parameter are :
  #  - "respect" : MeshGems-CADSurf is not allowed to alter any required entity, 
  #                even for correction purposes,
  #  - "ignore" : MeshGems-CADSurf will ignore the required entities in its processing,
  #  - "clear" : MeshGems-CADSurf will clear any required status for the entities. 
  #              There will not be any entity marked as required in the generated mesh.
  #  
  def SetRequiredEntities( self, howToTreat ):
    self.Parameters().SetRequiredEntities( howToTreat )

  ## Set sewing_tolerance parameter
  #  
  #  This parameter is the tolerance of the assembly.
  #  
  def SetSewingTolerance( self, tol ):
    self.Parameters().SetSewingTolerance( tol )

  ## Set tags parameter
  #  
  #  The tag (attribute) system controls the optimisation process. 
  #  Accepted values for this parameter are :
  #  - "respect"  : the CAD tags will be preserved and unaltered by the optimisation operations,
  #  - "ignore" : the CAD tags will be ignored by the optimisation operations 
  #               but they will still be present in the output mesh,
  #  - "clear" : MeshGems-CADSurf will clear any tag on any entity and optimise accordingly. 
  #              There will not be any tag in the generated mesh.
  #  
  def SetTags( self, howToTreat ):
    self.Parameters().SetTags( howToTreat )

  ## Activate/deactivate fully patch independent meshing
  #   @param isIndependent boolean flag
  #
  # This feature can only be used if the @a tags parameter is set to "respect".
  # By default this option deactivated.
  #
  def SetPatchIndependent( self, isIndependent ):
    self.SetOptionValue( "allow_patch_independent", "yes" if isIndependent else "no" )

  ## Set to preserve lines defined by a sharp angle in the input discrete geometry
  #   @param toCompute boolean flag
  #
  # If this option is deactivated, MeshGems-CADSurf will not try to preserve lines
  # defined by a sharp angle in the input discrete geometry. Only input ridges, free
  # edges, non manifold edges and separation betwen zones with different attributes
  # will be respected (if tags is set to respect).
  # By default this option activated.
  #
  def SetComputeRidges( self, toCompute ):
    self.SetOptionValue( "compute_ridges", "yes" if toCompute else "no" )


  ## Activate removal of the tiny edges from the generated
  # mesh when it improves the local mesh quality, without taking into account the
  # tags (attributes) specifications.
  #  @param toOptimise "to optimize" flag value
  #  @param length minimal length under which an edge is considered to be a tiny
  def SetOptimiseTinyEdges(self, toOptimise, length=-1):
    self.Parameters().SetOptimiseTinyEdges( toOptimise )
    if toOptimise:
      self.Parameters().SetTinyEdgeOptimisationLength( length )

  ## Activate correction of all surface intersections
  #  @param toCorrect "to correct" flag value
  #  @param maxCost  the time the user is ready to spend in the intersection prevention process
  #         For example, maxCost = 3 means that MeshGems-CADSurf will not spend more time
  #         in the intersection removal process than 3 times the time required to mesh
  #         without processing the intersections.
  def SetCorrectSurfaceIntersection(self, toCorrect, maxCost ):
    self.Parameters().SetCorrectSurfaceIntersection( toCorrect )
    if toCorrect:
      self.Parameters().SetCorrectSurfaceIntersectionMaxCost( maxCost )

  ## To optimize merges edges.
  #  @param toMergeEdges "merge edges" flag value
  def SetPreCADMergeEdges(self, toMergeEdges=False):
    self.Parameters().SetPreCADMergeEdges(toMergeEdges)
    pass

  ## To remove duplicate CAD Faces
  #  @param toRemoveDuplicateCADFaces "remove_duplicate_cad_faces" flag value
  def SetPreCADRemoveDuplicateCADFaces(self, toRemoveDuplicateCADFaces=False):
    self.Parameters().SetPreCADRemoveDuplicateCADFaces(toRemoveDuplicateCADFaces)
    pass

  ## To process 3D topology.
  #  @param toProcess "PreCAD process 3D" flag value
  def SetPreCADProcess3DTopology(self, toProcess=False):
    self.Parameters().SetPreCADProcess3DTopology(toProcess)
    pass

  ## To remove nano edges.
  #  @param toRemoveNanoEdges "remove nano edges" flag value
  def SetPreCADRemoveNanoEdges(self, toRemoveNanoEdges=False):
    if toRemoveNanoEdges:
      self.SetPreCADOptionValue("remove_tiny_edges","1")
    else:
      self.SetPreCADOptionValue("remove_tiny_edges","0")
    pass

  ## To compute topology from scratch
  #  @param toDiscardInput "discard input" flag value
  def SetPreCADDiscardInput(self, toDiscardInput=False):
    self.Parameters().SetPreCADDiscardInput(toDiscardInput)
    pass

  ## Sets the length below which an edge is considered as nano
  #  for the topology processing.
  #  @param epsNano nano edge length threshold value
  def SetPreCADEpsNano(self, epsNano):
    self.SetPreCADOptionValue("tiny_edge_length","%f"%epsNano)
    pass

  ## Sets advanced option value.
  #  @param optionName advanced option name
  #  @param level advanced option value
  def SetOptionValue(self, optionName, level):
    self.Parameters().SetOptionValue(optionName,level)
    pass

  ## Sets advanced PreCAD option value.
  #  @param optionName name of the option
  #  @param optionValue value of the option
  def SetPreCADOptionValue(self, optionName, optionValue):
    self.Parameters().SetPreCADOptionValue(optionName,optionValue)
    pass
  
  ## Adds custom advanced option values
  #  @param optionsAndValues options and values in a form "option_1 v1 option_2 v2'"
  def SetAdvancedOption(self, optionsAndValues):
    self.Parameters().SetAdvancedOption(optionsAndValues)
    pass

  ## Adds custom advanced option value.
  #  @param optionName custom advanced option name
  #  @param level custom advanced option value
  def AddOption(self, optionName, level):
    self.Parameters().AddOption(optionName,level)
    pass

  ## Adds custom advanced PreCAD option value.
  #  @param optionName custom name of the option
  #  @param optionValue value of the option
  def AddPreCADOption(self, optionName, optionValue):
    self.Parameters().AddPreCADOption(optionName,optionValue)
    pass

  ## Sets GMF file for export at computation
  #  @param fileName GMF file name
  def SetGMFFile(self, fileName):
    self.Parameters().SetGMFFile(fileName)
    pass

  #-----------------------------------------
  # Enforced vertices (BLSURF)
  #-----------------------------------------

  ## To get all the enforced vertices
  def GetAllEnforcedVertices(self):
    return self.Parameters().GetAllEnforcedVertices()

  ## To get all the enforced vertices sorted by face (or group, compound)
  def GetAllEnforcedVerticesByFace(self):
    return self.Parameters().GetAllEnforcedVerticesByFace()

  ## To get all the enforced vertices sorted by coords of input vertices
  def GetAllEnforcedVerticesByCoords(self):
    return self.Parameters().GetAllEnforcedVerticesByCoords()

  ## To get all the coords of input vertices sorted by face (or group, compound)
  def GetAllCoordsByFace(self):
    return self.Parameters().GetAllCoordsByFace()

  ## To get all the enforced vertices on a face (or group, compound)
  #  @param theFace : GEOM face (or group, compound) on which to define an enforced vertex
  def GetEnforcedVertices(self, theFace):
    from salome.smesh.smeshBuilder import AssureGeomPublished
    AssureGeomPublished( self.mesh, theFace )
    return self.Parameters().GetEnforcedVertices(theFace)

  ## To clear all the enforced vertices
  def ClearAllEnforcedVertices(self):
    return self.Parameters().ClearAllEnforcedVertices()

  ## To set an enforced vertex on a face (or group, compound) given the coordinates of a point. If the point is not on the face, it will projected on it. If there is no projection, no enforced vertex is created.
  #  @param theFace      : GEOM face (or group, compound) on which to define an enforced vertex
  #  @param x            : x coordinate
  #  @param y            : y coordinate
  #  @param z            : z coordinate
  #  @param vertexName   : name of the enforced vertex
  #  @param groupName    : name of the group
  def SetEnforcedVertex(self, theFace, x, y, z, vertexName = "", groupName = ""):
    from salome.smesh.smeshBuilder import AssureGeomPublished
    AssureGeomPublished( self.mesh, theFace )
    if vertexName == "":
      if groupName == "":
        return self.Parameters().SetEnforcedVertex(theFace, x, y, z)
      else:
        return self.Parameters().SetEnforcedVertexWithGroup(theFace, x, y, z, groupName)
      pass
    else:
      if groupName == "":
        return self.Parameters().SetEnforcedVertexNamed(theFace, x, y, z, vertexName)
      else:
        return self.Parameters().SetEnforcedVertexNamedWithGroup(theFace, x, y, z, vertexName, groupName)
      pass
    pass

  ## To set an enforced vertex on a face (or group, compound) given a GEOM vertex, group or compound.
  #  @param theFace      : GEOM face (or group, compound) on which to define an enforced vertex
  #  @param theVertex    : GEOM vertex (or group, compound) to be projected on theFace.
  #  @param groupName    : name of the group
  def SetEnforcedVertexGeom(self, theFace, theVertex, groupName = ""):
    from salome.smesh.smeshBuilder import AssureGeomPublished
    AssureGeomPublished( self.mesh, theFace )
    AssureGeomPublished( self.mesh, theVertex )
    if groupName == "":
      return self.Parameters().SetEnforcedVertexGeom(theFace, theVertex)
    else:
      return self.Parameters().SetEnforcedVertexGeomWithGroup(theFace, theVertex,groupName)
    pass

  ## Set an enforced vertex on a face given the coordinates of a point.
  #  The face if found by the application.
  #  @param x            : x coordinate
  #  @param y            : y coordinate
  #  @param z            : z coordinate
  #  @param vertexName   : name of the enforced vertex
  #  @param groupName    : name of the group
  def AddEnforcedVertex(self, x, y, z, vertexName = "", groupName = ""):
    from salome.smesh.smeshBuilder import AssureGeomPublished
    if vertexName == "":
      if groupName == "":
        return self.Parameters().AddEnforcedVertex(x, y, z)
      else:
        return self.Parameters().AddEnforcedVertexWithGroup(x, y, z, groupName)
      pass
    else:
      if groupName == "":
        return self.Parameters().AddEnforcedVertexNamed(x, y, z, vertexName)
      else:
        return self.Parameters().AddEnforcedVertexNamedWithGroup( x, y, z, vertexName, groupName)
      pass
    pass

  ## To set an enforced vertex on a face given a GEOM vertex, group or compound.
  #  The face if found by the application.
  #  @param theVertex    : GEOM vertex (or group, compound).
  #  @param groupName    : name of the group
  def AddEnforcedVertexGeom(self, theVertex, groupName = ""):
    from salome.smesh.smeshBuilder import AssureGeomPublished
    AssureGeomPublished( self.mesh, theVertex )
    if groupName == "":
      return self.Parameters().AddEnforcedVertexGeom(theVertex)
    else:
      return self.Parameters().AddEnforcedVertexGeomWithGroup(theVertex,groupName)
    pass

  ## To remove an enforced vertex on a given GEOM face (or group, compound) given the coordinates.
  #  @param theFace      : GEOM face (or group, compound) on which to remove the enforced vertex
  #  @param x            : x coordinate
  #  @param y            : y coordinate
  #  @param z            : z coordinate
  def UnsetEnforcedVertex(self, theFace, x, y, z):
    from salome.smesh.smeshBuilder import AssureGeomPublished
    AssureGeomPublished( self.mesh, theFace )
    return self.Parameters().UnsetEnforcedVertex(theFace, x, y, z)

  ## To remove an enforced vertex on a given GEOM face (or group, compound) given a GEOM vertex, group or compound.
  #  @param theFace      : GEOM face (or group, compound) on which to remove the enforced vertex
  #  @param theVertex    : GEOM vertex (or group, compound) to remove.
  def UnsetEnforcedVertexGeom(self, theFace, theVertex):
    from salome.smesh.smeshBuilder import AssureGeomPublished
    AssureGeomPublished( self.mesh, theFace )
    AssureGeomPublished( self.mesh, theVertex )
    return self.Parameters().UnsetEnforcedVertexGeom(theFace, theVertex)

  ## To remove all enforced vertices on a given face.
  #  @param theFace      : face (or group/compound of faces) on which to remove all enforced vertices
  def UnsetEnforcedVertices(self, theFace):
    from salome.smesh.smeshBuilder import AssureGeomPublished
    AssureGeomPublished( self.mesh, theFace )
    return self.Parameters().UnsetEnforcedVertices(theFace)

  ## To tell BLSURF to add a node on internal vertices
  #  @param toEnforceInternalVertices : boolean; if True the internal vertices are added as enforced vertices
  def SetInternalEnforcedVertexAllFaces(self, toEnforceInternalVertices):
    return self.Parameters().SetInternalEnforcedVertexAllFaces(toEnforceInternalVertices)

  ## To know if BLSURF will add a node on internal vertices
  def GetInternalEnforcedVertexAllFaces(self):
    return self.Parameters().GetInternalEnforcedVertexAllFaces()

  ## To define a group for the nodes of internal vertices
  #  @param groupName : string; name of the group
  def SetInternalEnforcedVertexAllFacesGroup(self, groupName):
    return self.Parameters().SetInternalEnforcedVertexAllFacesGroup(groupName)

  ## To get the group name of the nodes of internal vertices
  def GetInternalEnforcedVertexAllFacesGroup(self):
    return self.Parameters().GetInternalEnforcedVertexAllFacesGroup()

  #-----------------------------------------
  #  Enforced mesh
  #-----------------------------------------

  ## Set enforced 1D meshes
  #  @param enfMeshes : list of smeshBuilder.MG_EnforcedMesh1D structures
  #
  #  Example: cadsurf.SetEnforcedMeshes([ smeshBuilder.MG_EnforcedMesh1D( mesh1D, "Group 1D")]
  def SetEnforcedMeshes( self, enfMeshes ):
    from salome.smesh.smeshBuilder import Mesh
    for em in enfMeshes:
      if isinstance( em.mesh, Mesh ):
        em.mesh = em.mesh.GetMesh()
    return self.Parameters().SetEnforcedMeshes( enfMeshes )

  #-----------------------------------------
  #  Attractors
  #-----------------------------------------

  ## Sets an attractor on the chosen face. The mesh size will decrease exponentially with the distance from theAttractor, following the rule h(d) = theEndSize - (theEndSize - theStartSize) * exp [ - ( d / theInfluenceDistance ) ^ 2 ]
  #  @param theFace      : face on which the attractor will be defined
  #  @param theAttractor : geometrical object from which the mesh size "h" decreases exponentially
  #  @param theStartSize : mesh size on theAttractor
  #  @param theEndSize   : maximum size that will be reached on theFace
  #  @param theInfluenceDistance : influence of the attractor ( the size grow slower on theFace if it's high)
  #  @param theConstantSizeDistance : distance until which the mesh size will be kept constant on theFace
  def SetAttractorGeom(self, theFace, theAttractor, theStartSize, theEndSize, theInfluenceDistance, theConstantSizeDistance):
    from salome.smesh.smeshBuilder import AssureGeomPublished
    AssureGeomPublished( self.mesh, theFace )
    AssureGeomPublished( self.mesh, theAttractor )
    self.Parameters().SetAttractorGeom(theFace, theAttractor, theStartSize, theEndSize, theInfluenceDistance, theConstantSizeDistance)
    pass

  ## Unsets an attractor on the chosen face.
  #  @param theFace      : face on which the attractor has to be removed
  def UnsetAttractorGeom(self, theFace):
    from salome.smesh.smeshBuilder import AssureGeomPublished
    AssureGeomPublished( self.mesh, theFace )
    self.Parameters().SetAttractorGeom(theFace)
    pass

  #-----------------------------------------
  # Size maps (BLSURF)
  #-----------------------------------------

  ## To set a size map on a face, edge or vertex (or group, compound) given Python function.
  #  If theObject is a face, the function can be: def f(u,v): return u+v
  #  If theObject is an edge, the function can be: def f(t): return t/2
  #  If theObject is a vertex, the function can be: def f(): return 10
  #  @param theObject   : GEOM face, edge or vertex (or group, compound) on which to define a size map
  #  @param theSizeMap  : Size map defined as a string
  def SetSizeMap(self, theObject, theSizeMap):
    from salome.smesh.smeshBuilder import AssureGeomPublished
    AssureGeomPublished( self.mesh, theObject )
    self.Parameters().SetSizeMap(theObject, theSizeMap)
    pass

  ## To set a constant size map on a face, edge or vertex (or group, compound).
  #  @param theObject   : GEOM face, edge or vertex (or group, compound) on which to define a size map
  #  @param theSizeMap  : Size map defined as a double
  def SetConstantSizeMap(self, theObject, theSizeMap):
    from salome.smesh.smeshBuilder import AssureGeomPublished
    AssureGeomPublished( self.mesh, theObject )
    self.Parameters().SetConstantSizeMap(theObject, theSizeMap)

  ## To remove a size map defined on a face, edge or vertex (or group, compound)
  #  @param theObject   : GEOM face, edge or vertex (or group, compound) on which to define a size map
  def UnsetSizeMap(self, theObject):
    from salome.smesh.smeshBuilder import AssureGeomPublished
    AssureGeomPublished( self.mesh, theObject )
    self.Parameters().UnsetSizeMap(theObject)
    pass

  ## To remove all the size maps
  def ClearSizeMaps(self):
    self.Parameters().ClearSizeMaps()
    pass

  ## Sets QuadAllowed flag (DEPRECATED: use SetElementType)
  #  @param toAllow "allow quadrangles" flag value
  # TODO: to remove in Salome 9
  def SetQuadAllowed(self, toAllow=True):
    self.Parameters().SetQuadAllowed(toAllow)
    pass

  ## Sets elements type
  #  @param theElementType: 0 (Triangles), 1 (QuadrangleDominant), 2 (Quadrangles)
  def SetElementType(self, theElementType=Triangles):
    self.Parameters().SetElementType(theElementType)
    pass

  ## Defines hypothesis having several parameters
  #  @return hypothesis object
  def Parameters(self):
    if not self.params:
      hypType = "MG-CADSurf Parameters"
      hasGeom = self.mesh.GetMesh().HasShapeToMesh()
      if hasGeom:
        self.params = self.Hypothesis(hypType, [], LIBRARY, UseExisting=0)
      else:
        self.params = self.Hypothesis(hypType + "_NOGEOM", [], LIBRARY, UseExisting=0)
        self.mesh.smeshpyD.SetName( self.params, hypType )
      pass
    return self.params

  #-----------------------------------------
  # Periodicity (BLSURF with PreCAD)
  #-----------------------------------------
  
  ## Defines periodicity between two groups of faces, using PreCAD
  #  @param theFace1 : GEOM face (or group, compound) to associate with theFace2
  #  @param theFace2 : GEOM face (or group, compound) associated with theFace1
  #  @param theSourceVertices (optionnal): list of GEOM vertices on theFace1 defining the transformation from theFace1 to theFace2.
  #    If None, PreCAD tries to find a simple translation. Else, need at least 3 not aligned vertices.
  #  @param theTargetVertices (optionnal): list of GEOM vertices on theFace2 defining the transformation from theFace1 to theFace2.
  #    If None, PreCAD tries to find a simple translation. Else, need at least 3 not aligned vertices.
  def AddPreCadFacesPeriodicity(self, theFace1, theFace2, theSourceVertices=[], theTargetVertices=[]):
    """calls preCad function:
    status_t cad_add_face_multiple_periodicity_with_transformation_function(cad t *cad,
          integer *fid1, integer size1, integer *fid2, integer size2,
          periodicity_transformation_t transf, void *user data);
    """
    if theSourceVertices and theTargetVertices:
      self.Parameters().AddPreCadFacesPeriodicityWithVertices(theFace1, theFace2, theSourceVertices, theTargetVertices)
    else:
      self.Parameters().AddPreCadFacesPeriodicity(theFace1, theFace2)
    pass

  ## Defines periodicity between two groups of edges, using PreCAD
  #  @param theEdge1 : GEOM edge (or group, compound) to associate with theEdge2
  #  @param theEdge2 : GEOM edge (or group, compound) associated with theEdge1
  #  @param theSourceVertices (optionnal): list of GEOM vertices on theEdge1 defining the transformation from theEdge1 to theEdge2.
  #    If None, PreCAD tries to find a simple translation. Else, need at least 3 not aligned vertices.
  #  @param  theTargetVertices (optionnal): list of GEOM vertices on theEdge2 defining the transformation from theEdge1 to theEdge2.
  #    If None, PreCAD tries to find a simple translation. Else, need at least 3 not aligned vertices.
  def AddPreCadEdgesPeriodicity(self, theEdge1, theEdge2, theSourceVertices=[], theTargetVertices=[]):
    """calls preCad function:
    status_t cad_add_edge_multiple_periodicity_with_transformation_function(cad t *cad,
          integer *eid1, integer size1, integer *eid2, integer size2,
          periodicity_transformation_t transf, void *user data);
    """
    if theSourceVertices and theTargetVertices:
        self.Parameters().AddPreCadEdgesPeriodicityWithVertices(theEdge1, theEdge2, theSourceVertices, theTargetVertices)
    else:
        self.Parameters().AddPreCadEdgesPeriodicity(theEdge1, theEdge2)
    pass

  #-----------------------------------------
  # Hyper-Patches
  #-----------------------------------------
  
  ## Defines hyper-patches. A hyper-patch is a set of adjacent faces meshed as a whole,
  #  ignoring edges between them
  #  @param hyperPatchList : list of hyper-patches. A hyper-patch is defined as a list of
  #         faces or groups of faces. A face can be identified either as a GEOM object or
  #         a face ID (returned e.g. by geompy.GetSubShapeID( mainShape, subShape )).
  #         
  #  Example: cadsurf.SetHyperPatches([[ Face_1, Group_2 ],[ 13, 23 ]])
  def SetHyperPatches(self, hyperPatchList):
    hpl = []
    for patch in hyperPatchList:
      ids = []
      for face in patch:
        if isinstance( face, int ):
          ids.append( face )
        elif isinstance( face, GEOM._objref_GEOM_Object):
          faces = self.mesh.geompyD.SubShapeAll( face, self.mesh.geompyD.ShapeType["FACE"] )
          for f in faces:
            ids.append( self.mesh.geompyD.GetSubShapeID( self.mesh.geom, f ))
        else:
          raise TypeError("Face of hyper-patch should be either ID or GEOM_Object, not %s" % type(face))
        pass
      hpl.append( ids )
      pass
    self.Parameters().SetHyperPatches( hpl )
    return

  pass # end of BLSURF_Algorithm class

def version_less(version: str, ref_version: str):
  from re import split
  return [int(i) for i in split('[.-]', version)] < [int(i) for i in re.split('[.-]', ref_version)]
