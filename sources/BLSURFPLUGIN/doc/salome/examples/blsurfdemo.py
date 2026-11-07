# -------------------------------------------------
# blsurf_construct_mesh_basic_hypo Basic hypothesis
# -------------------------------------------------

from salome.kernel import salome
salome.salome_init()
from salome.kernel import GEOM
from salome.geom import geomBuilder
geompy = geomBuilder.New()

from salome.kernel import SMESH, SALOMEDS
from salome.smesh import smeshBuilder
smesh =  smeshBuilder.New()

# create a box
box = geompy.MakeBoxDXDYDZ(200., 200., 200.)
geompy.addToStudy(box, "box")

# get sub-shapes
Face_1   = geompy.SubShapeAllSorted(box, geompy.ShapeType["FACE"])[0]
Edge_1   = geompy.SubShapeAllSorted(box, geompy.ShapeType["EDGE"])[0]
Vertex_1 = geompy.SubShapeAllSorted(box, geompy.ShapeType["VERTEX"])[0]

Face_2   = geompy.SubShapeAllSorted(box,    geompy.ShapeType["FACE"])[5]
Wire_1   = geompy.SubShapeAllSorted(Face_2, geompy.ShapeType["WIRE"])[0]

# Geom object with sizemaps can be unpublished in study.
# They will then be automatically published.
geompy.addToStudyInFather(box,Face_1, "Face_1")
geompy.addToStudyInFather(box,Edge_1, "Edge_1")
geompy.addToStudyInFather(box,Vertex_1, "Vertex_1")

geompy.addToStudyInFather(box   ,Face_2, "Face_2")
geompy.addToStudyInFather(Face_2,Wire_1, "Wire_1")

# create a mesh on the box
cadsurfMesh = smesh.Mesh(box,"box: MG-CADSurf mesh")

# create a BLSurf algorithm for faces
algo2d = cadsurfMesh.Triangle(algo=smeshBuilder.MG_CADSurf)

# ----------------------------------------------
# blsurf_construct_mesh_sizemaps Adding sizemaps
# ----------------------------------------------

# optional - set physical mesh to 2 = Size Map
algo2d.SetPhysicalMesh( 2 )

# optional - set global mesh size
algo2d.SetPhySize( 34.641 )

# set size on Face_1
algo2d.SetSizeMap(Face_1, 'def f(u,v): return 10' )
# set size on Edge_1
algo2d.SetSizeMap(Edge_1, 'def f(t): return 5' )
# set size on Vertex_1
algo2d.SetSizeMap(Vertex_1, 'def f(): return 2' )

# compute the mesh
cadsurfMesh.Compute()

# ----------------------------------------------------------------
# blsurf_construct_mesh_enforced_vertices Adding enforced vertices
# ----------------------------------------------------------------

# Add enforced vertex for Face_1 on (50, 50, 50)
# The projection coordinates will be (50, 50, 0)
algo2d.SetEnforcedVertex(Face_1, 50, 50, 50)

# Add another enforced vertex on (150, 150, 150)
algo2d.SetEnforcedVertex(Face_1, 150, 150, 150)

# Retrieve and print the list of enforced vertices defines on Face_1
enfList = algo2d.GetEnforcedVertices(Face_1)
print("List of enforced vertices for Face_1: ")
print(enfList)

# compute the mesh
cadsurfMesh.Compute()

# Remove an enforced vertex and print the list
algo2d.UnsetEnforcedVertex(Face_1, 50, 50, 50)
enfList = algo2d.GetEnforcedVertices(Face_1)
print("List of enforced vertices for Face_1: ")
print(enfList)

# compute the mesh
cadsurfMesh.Compute()

# Remove all enforced vertices defined on Face_1
algo2d.UnsetEnforcedVertices(Face_1)

# compute the mesh
cadsurfMesh.Compute()

# ---------------------------------------------------
# blsurf_construct_mesh_attractor Adding an attractor
# ---------------------------------------------------

# Add an attractor on Face_2, which shape is Wire_1

# The size on Wire_1 is 1 and will grow until a maximum of 36.641 (physical size set above) 
# The influence distance of the attractor is 20
# The size is kept constant until a distance of 10
algo2d.SetAttractorGeom(Face_2, Wire_1, 1, 36.641, 20, 10)

# In order to let the attractor control the growing of the mesh let set
# the gradation to its maximum
algo2d.SetGradation( 2.5 )

# -----------------------
# Adding enforced meshes
# -----------------------

# create 1D mesh
OZ       = geompy.MakeVectorDXDYDZ(0, 0, 1)
circle_1 = geompy.MakeCircle( geompy.MakeVertex( 100, 75,  200 ), OZ, 50 )
circle_2 = geompy.MakeCircle( geompy.MakeVertex( 100, 150, 200 ), OZ, 70 )
circles  = geompy.MakeCompound([ circle_1, circle_2 ], theName="circles")
mesh_1D  = smesh.Mesh( circles, "enforced circles" )
mesh_1D.Segment().LocalLength( 7 )
mesh_1D.Compute()

# Add enforced mesh
algo2d.SetEnforcedMeshes([
    smeshBuilder.MG_EnforcedMesh1D( mesh_1D, "Enforced edges")])

# -----------------
# compute the mesh
# -----------------

cadsurfMesh.Compute()


# ================================================================
# blsurf_construct_mesh_internal_vertices Using internal vertices
# ================================================================

# Creating a geometry containing internal vertices
Face_3 = geompy.MakeFaceHW(1, 1, 1)
Vertex_2 = geompy.MakeVertex(0.2, 0.2, 0)
Partition_1 = geompy.MakePartition([Face_3, Vertex_2], [], [], [], geompy.ShapeType["FACE"], 0, [], 0)
OX = geompy.MakeVectorDXDYDZ(1, 0, 0)
OY = geompy.MakeVectorDXDYDZ(0, 1, 0)
Multi_Translation_1 = geompy.MakeMultiTranslation2D(Partition_1, OX, 1, 10, OY, 1, 10)
Multi_Translation_glued = geompy.MakeGlueEdges(Multi_Translation_1, 1e-7)
geompy.addToStudy( Face_3, 'Face_3' )
geompy.addToStudy( Vertex_2, 'Vertex_2' )
geompy.addToStudy( Partition_1, 'Partition_1' )
geompy.addToStudy( OX, 'OX' )
geompy.addToStudy( OY, 'OY' )
geompy.addToStudy( Multi_Translation_1, 'Multi_Translation_1' )
geompy.addToStudy( Multi_Translation_glued, 'Multi_Translation_glued' )

# The mesh on the geometry with internal vertices
cadsurfMesh_internal = smesh.Mesh(Multi_Translation_glued, "cadsurfMesh_internal")
algo2d = cadsurfMesh_internal.Triangle(algo=smeshBuilder.MG_CADSurf)
algo2d.SetPhySize( 0.1 )

# Allow MG-CADSURF to take into account internal vertices
algo2d.SetInternalEnforcedVertexAllFaces( True )

# Add the created nodes into a group
algo2d.SetInternalEnforcedVertexAllFacesGroup( "my group" )

# compute the mesh
cadsurfMesh_internal.Compute()

# End of script
