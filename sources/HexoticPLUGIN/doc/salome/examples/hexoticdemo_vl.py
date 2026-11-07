from salome.kernel import salome
salome.salome_init()

from salome.geom import geomBuilder
geompy = geomBuilder.New()

from salome.smesh import smeshBuilder
smesh =  smeshBuilder.New()

# Create geometry
Box_1 = geompy.MakeBoxDXDYDZ(50, 50, 50)
geompy.addToStudy( Box_1, 'Box_1' )

# Create mesh
Mesh_mghexa_vl = smesh.Mesh(Box_1, "Mesh_mghexa_vl")

Regular_1D = Mesh_mghexa_vl.Segment()
Local_Length_1 = Regular_1D.LocalLength(8.66025)

MEFISTO_2D = Mesh_mghexa_vl.Triangle(algo=smeshBuilder.MEFISTO)

MG_Hexa = Mesh_mghexa_vl.Hexahedron(algo=smeshBuilder.MG_Hexa)
MG_Hexa_Parameters = MG_Hexa.Parameters()
MG_Hexa.SetViscousLayers(5,5,3,[13,23])
MG_Hexa_Parameters.SetMinSize( 2 )
MG_Hexa_Parameters.SetMaxSize( 4 )
MG_Hexa_Parameters.SetHexesMinLevel( 2 )
MG_Hexa_Parameters.SetHexesMaxLevel( 4 )

# Compute
assert Mesh_mghexa_vl.Compute(), "Meshing fails"

# End of script
