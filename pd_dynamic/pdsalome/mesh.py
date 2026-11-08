"""SALOME mesh -> peridynamic nodes (one PD node per 3D cell: centroid + cell volume)."""

import numpy as np


def read_med_cells(med_file, mesh_name):
    """Return (umesh, centers (n,3), volumes (n,)) of the 3D cells in a MED file."""
    import medcoupling as mc

    umesh = mc.ReadUMeshFromFile(med_file, mesh_name, 0)
    n = umesh.getNumberOfCells()
    centers = umesh.computeCellCenterOfMass().toNumPyArray().reshape(n, 3).copy()
    vol = umesh.getMeasureField(True).getArray().toNumPyArray().copy()
    return umesh, centers, vol


def box_hex_mesh(smesh, geompy, box, nx, ny, nz, name="PDMesh"):
    """Structured hexahedral mesh of a GEOM box: nx x ny x nz cells (Regular_1D + Quadrangle + Hexa)."""
    from salome.smesh import smeshBuilder

    mesh = smesh.Mesh(box, name)
    edges = geompy.SubShapeAllSortedCentres(box, geompy.ShapeType["EDGE"])
    reg = mesh.Segment()
    reg.NumberOfSegments(nx)  # default; overridden per direction below
    for e in edges:
        p = geompy.PointCoordinates(geompy.MakeVertexOnCurve(e, 0.0))
        q = geompy.PointCoordinates(geompy.MakeVertexOnCurve(e, 1.0))
        d = np.abs(np.subtract(q, p))
        k = int(np.argmax(d))
        sub = mesh.Segment(geom=e)
        sub.NumberOfSegments((nx, ny, nz)[k])
    mesh.Quadrangle()
    mesh.Hexahedron()
    if not mesh.Compute():
        raise RuntimeError("SMESH compute failed")
    return mesh
