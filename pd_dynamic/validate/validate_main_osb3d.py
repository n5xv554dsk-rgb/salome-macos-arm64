"""Check libpdcore against main_osb3d.cpp on its plate case (same nodes, BCs, precrack, 5000 steps).

usage: ./salome python pd_dynamic/validate/validate_main_osb3d.py <case jobname> <dir with main_osb3d *.phi.csv> <prefix>
e.g.   ... ~/Desktop/pd/Ordinery-SB-3d/cases/plate/plate  /tmp/ref/plate  _r
"""

import os
import sys
import time

import numpy as np

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
from pdsalome import FORCE, FIXED, PDSolver  # noqa: E402

job, refjob, prefix = sys.argv[1], sys.argv[2], sys.argv[3]


def rd(ext, dtype=float):
    return np.array(open(job + ext).read().split(), dtype=dtype)


n, nsteps, npre = rd(".data1", int)
E, Nu, Rho, wf, t0, t1, dt, R, dx, dy, dz, s0 = rd(".data2")
X = rd(".nodes").reshape(n, 3)
bct, bcv = rd(".bctypes", int).reshape(n, 3), rd(".bcvalues").reshape(n, 3)
ict, icv = rd(".ictypes", int).reshape(n, 3), rd(".icvalues").reshape(n, 3)
pre = rd(".prenotch").reshape(npre, 9)

pd = PDSolver(X, np.full(n, dx * dy * dz), R, dx, influence=1)
pd.set_material(E, Nu, Rho, s0)
for p in pre:
    pd.add_precrack(p[0:3], p[3:6], p[6:9])
pd.build()
print(f"{n} nodes, {pd.nbonds} bonds, max horizon {pd.max_horizon}, build {pd.build_time:.2f} s, {PDSolver.threads()} threads")

pd.bc_type[:] = np.where(bct == 0, FIXED, FORCE)  # main_osb3d: any type != 0 is a body force
pd.bc_value[:] = bcv
pd.ic_type[:] = ict
pd.ic_value[:] = icv
pd.apply()

worst = 0.0
t_run = 0.0
for s in range(100, nsteps + 1, 100):
    t = time.perf_counter()
    pd.run(100, dt)
    t_run += time.perf_counter() - t
    ref = np.loadtxt(f"{refjob}{prefix}-{s}.phi.csv", delimiter=",", skiprows=1)
    assert np.allclose(ref[:, :3], X, atol=1e-12)
    d = np.abs(pd.phi - ref[:, 3])
    worst = max(worst, d.max())
    if s % 1000 == 0:
        print(f"step {s}: max|dphi| = {d.max():.3e}, nodes differing > 1e-12: {(d > 1e-12).sum()}, "
              f"max phi = {pd.phi.max():.3f}, broken bonds = {pd.broken_bonds}")
print(f"time marching {t_run:.2f} s; worst max|dphi| over all {nsteps // 100} outputs = {worst:.3e}")
u = pd.u
print(f"max |u| = {np.linalg.norm(u, axis=1).max():.6e}")
