from salome.kernel import salome
salome.salome_init()

from salome.geom import geomBuilder
geompy = geomBuilder.New()

from salome.smesh import smeshBuilder
smesh =  smeshBuilder.New()


# create a sphere
sphere = geompy.MakeSphereR(100.)
geompy.addToStudy(sphere, "sphere")

# create a mesh on the sphere
mghexaMesh = smesh.Mesh(sphere,"sphere: MG-CADSurf and MG-Hexa mesh")

# create a MG-CADSurf algorithm for faces
MG_CADSurf = mghexaMesh.Triangle(algo=smeshBuilder.MG_CADSurf)
MG_CADSurf.SetGeometricMesh( 1 )

# create a MG-Hexa algorithm for volumes
MG_Hexa = mghexaMesh.Hexahedron(algo=smeshBuilder.MG_Hexa)

## compute the mesh
#mghexaMesh.Compute()

# Change the level of subdivision
MG_Hexa.SetMinMaxHexes(4, 8)

## compute the mesh
#mghexaMesh.Compute()

# Local size

# Get the sphere skin
faces = geompy.SubShapeAll(sphere, geompy.ShapeType["FACE"])

# Set a local size on the face
MG_Hexa.SetMinMaxSize(10, 20)
MG_Hexa.SetSizeMap(faces[0], 10)

# compute the mesh
assert mghexaMesh.Compute(), "Meshing fails"

# End of script
