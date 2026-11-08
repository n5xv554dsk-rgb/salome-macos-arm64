"""MED time-series output (fields on cells = PD nodes) for PARAVIS / ParaView."""

import os

import numpy as np


class MEDSeries:
    """Writes the mesh once, then append(step, time, fields) adds one time step of cell fields.

    fields: dict name -> array (n,) or (n,k). Component names: Damage -> phi, vectors -> x,y,z.
    """

    def __init__(self, path, umesh):
        import medcoupling as mc

        self.mc = mc
        self.path = path
        self.umesh = umesh
        if os.path.exists(path):
            os.remove(path)
        mm = mc.MEDFileUMesh()
        mm.setMeshAtLevel(0, umesh)
        mm.write(path, 2)
        self.n = umesh.getNumberOfCells()

    def append(self, step, t, fields):
        mc = self.mc
        for name, arr in fields.items():
            arr = np.ascontiguousarray(arr, dtype=np.float64)
            ncomp = 1 if arr.ndim == 1 else arr.shape[1]
            da = mc.DataArrayDouble(arr.reshape(self.n, ncomp))
            comps = ["x", "y", "z"] if ncomp == 3 else [name] if ncomp == 1 else [f"c{k}" for k in range(ncomp)]
            for k, c in enumerate(comps):
                da.setInfoOnComponent(k, c)
            f = mc.MEDCouplingFieldDouble(mc.ON_CELLS, mc.ONE_TIME)
            f.setName(name)
            f.setMesh(self.umesh)
            f.setArray(da)
            f.setTime(float(t), int(step), -1)
            ff = mc.MEDFileField1TS()
            ff.setFieldNoProfileSBT(f)
            ff.write(self.path, 0)
