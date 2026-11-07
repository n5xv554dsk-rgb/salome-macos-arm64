from salome.kernel import salome
salome.salome_init()

from salome.geom import geomBuilder
geompy = geomBuilder.New()

from salome.smesh import smeshBuilder
smesh =  smeshBuilder.New()

# Create geometry: a box cut by a plane
Box_1 = geompy.MakeBoxDXDYDZ(200, 200, 200)
Translation_1 = geompy.MakeTranslation(Box_1, 0, 200, 0)
Partition_1 = geompy.MakePartition([Box_1, Translation_1])
geompy.addToStudy( Box_1, 'Box_1' )
geompy.addToStudy( Translation_1, 'Translation_1' )
geompy.addToStudy( Partition_1, 'Partition_1' )

# Create mesh of Partition_1 with sd mode 4 (default sd mode in SALOME)
Mesh_mghexa_sd4 = smesh.Mesh(Partition_1, "Mesh_mghexa_sd4")
Mesh_mghexa_sd4.Triangle(smeshBuilder.MG_CADSurf)
Mesh_mghexa_sd4.Hexahedron(smeshBuilder.MG_Hexa).SetMinMaxHexes(4, 8).SetHexoticSdMode( 4 )

# Compute
assert Mesh_mghexa_sd4.Compute(), "Meshing fails"

# End of script
