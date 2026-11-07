from salome.kernel import salome
salome.salome_init()

from salome.geom import geomBuilder
geompy = geomBuilder.New()

from salome.kernel import SMESH, SALOMEDS
from salome.smesh import smeshBuilder
smesh =  smeshBuilder.New()


# Create geometry: a box cut by a holed sphere
Box_1 = geompy.MakeBoxDXDYDZ(200, 200, 200)
Sphere_1 = geompy.MakeSphereR(75)
Sphere_2 = geompy.MakeSphereR(25)
geompy.TranslateDXDYDZ(Box_1, -100, -100, -100)
Cut_1 = geompy.MakeCut(Sphere_1, Sphere_2)
Cut_2 = geompy.MakeCut(Box_1, Cut_1)
geompy.addToStudy( Box_1, 'Box_1' )
geompy.addToStudy( Sphere_1, 'Sphere_1' )
geompy.addToStudy( Sphere_2, 'Sphere_2' )
geompy.addToStudy( Cut_1, 'Cut_1' )
geompy.addToStudy( Cut_2, 'Cut_2' )

# Create filters
# aFilter1: elements inside small sphere
aFilter1 = smesh.GetFilter(SMESH.VOLUME,SMESH.FT_BelongToGeom,'=',Sphere_2)
# aFilter2: elements inside big sphere and not inside small sphere
aFilter2 = smesh.GetFilterFromCriteria([smesh.GetCriterion(SMESH.VOLUME,SMESH.FT_BelongToGeom,'=',Sphere_1, SMESH.FT_LogicalAND),
                                        smesh.GetCriterion(SMESH.VOLUME,SMESH.FT_BelongToGeom,'=',Sphere_2, SMESH.FT_LogicalNOT)])
# aFilter3: elements not inside big sphere
aFilter3 = smesh.GetFilter(SMESH.VOLUME,SMESH.FT_BelongToGeom,'=',Sphere_1, SMESH.FT_LogicalNOT)

# Create mesh of Cut_2 with sd mode 1
print("Create mesh of Cut_2 with sd mode 1")
Mesh_mghexa_sd1 = smesh.Mesh(Cut_2, "Mesh_mghexa_sd1")

# Create the 2D algo: MG-CADSurf with geometrical mesh
Mesh_mghexa_sd1.Triangle(algo=smeshBuilder.MG_CADSurf).SetGeometricMesh( 1 )

# Create the 3D algo: MG-Hexa with:
# - minl = 4
# - maxl = 8
# - sd = 1
Mesh_mghexa_sd1.Hexahedron(algo=smeshBuilder.MG_Hexa).SetMinMaxHexes(4, 8).SetHexoticSdMode( 1 )

# Create the groups on filters
g1 = Mesh_mghexa_sd1.GroupOnFilter(SMESH.VOLUME, 'small sphere', aFilter1 )
g1.SetColor( SALOMEDS.Color( 1, 0, 0 ))
g2 = Mesh_mghexa_sd1.GroupOnFilter(SMESH.VOLUME, 'big sphere - small sphere', aFilter2 )
g2.SetColor( SALOMEDS.Color( 0, 1, 0 ))
g3 = Mesh_mghexa_sd1.GroupOnFilter(SMESH.VOLUME, 'box - big sphere', aFilter3 )
g3.SetColor( SALOMEDS.Color( 0, 0, 1 ))

# Compute
assert Mesh_mghexa_sd1.Compute(), "Meshing fails"

# End of script
