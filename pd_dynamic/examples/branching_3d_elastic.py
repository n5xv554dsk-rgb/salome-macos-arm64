#!/usr/bin/env python3
"""
SALOME + dynamic peridynamics: 3D dynamic crack branching, elastic (Duran 50 glass)
====================================================================================
Run:  ./salome python pd_dynamic/examples/branching_3d_elastic.py [dx_mm] [thickness_mm] [t_end_us] [m]

Stage 1 GEOM   : plate 100 x 40 x h mm, pre-crack plane y = 0 from the left edge to x = 50 mm
Stage 2 SMESH  : structured hexahedral mesh, cell size dx (one PD node per cell, centred,
                 so the plate is mirror-symmetric about the crack plane)
Stage 3 libpdcore : explicit dynamic ordinary state-based PD (LPS), horizon 3 dx,
                 12 MPa step traction on top and bottom faces, bonds break at stretch s0
Stage 4 MED + PARAVIS : time series of damage / displacement / velocity on cells,
                 PNG renders (3D view and mid-plane view)
"""

import os
import sys
import time

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, ".."))
sys.path.insert(0, ROOT)
from pdsalome import PDSolver, critical_dt, s0_from_G0  # noqa: E402
from pdsalome.mesh import box_hex_mesh, read_med_cells  # noqa: E402
from pdsalome.output import MEDSeries  # noqa: E402

# ---------------------------------------------------------------- parameters
dx = float(sys.argv[1]) * 1e-3 if len(sys.argv) > 1 else 0.5e-3   # cell size
h = float(sys.argv[2]) * 1e-3 if len(sys.argv) > 2 else 2.5e-3    # thickness (5 layers at 0.5 mm)
t_end = float(sys.argv[3]) * 1e-6 if len(sys.argv) > 3 else 50e-6

Lx, Ly = 0.1, 0.04
x0, y0, z0 = 0.0, -Ly / 2, -h / 2
nx, ny, nz = round(Lx / dx), round(Ly / dx), max(1, round(h / dx))
m = int(sys.argv[4]) if len(sys.argv) > 4 else 4   # horizon = m dx (m = 4 -> ~250 neighbours; m = 3 does not branch)
R = m * dx

E, nu, rho, G0 = 65e9, 0.25, 2235.0, 204.0
s0 = s0_from_G0(G0, E, R)
sigma = 12e6               # traction on top and bottom faces (Pa)
dt = 1e-8
nsteps = round(t_end / dt)
out_every = 250

OUT = os.path.join(ROOT, "results", f"branching_3d_elastic_dx{dx * 1e3:g}mm_h{h * 1e3:g}mm_m{m}")
os.makedirs(OUT, exist_ok=True)
MESH_MED = os.path.join(OUT, "plate_mesh.med")
SOL_MED = os.path.join(OUT, "solution.med")

bar = "=" * 78
print(bar)
print("STAGE 1: GEOM — plate geometry")
print(bar)
from salome.kernel import salome  # noqa: E402
salome.standalone()
salome.salome_init(embedded=True)
from salome.geom import geomBuilder  # noqa: E402
geompy = geomBuilder.New()

box = geompy.MakeBoxTwoPnt(geompy.MakeVertex(x0, y0, z0), geompy.MakeVertex(x0 + Lx, y0 + Ly, z0 + h))
geompy.addToStudy(box, "Plate")
print(f"  plate {Lx * 1e3:g} x {Ly * 1e3:g} x {h * 1e3:g} mm, volume {geompy.BasicProperties(box)[2]:.4e} m^3")

print(bar)
print("STAGE 2: SMESH — structured hexahedral mesh")
print(bar)
from salome.smesh import smeshBuilder  # noqa: E402
smesh = smeshBuilder.New()
t = time.perf_counter()
mesh = box_hex_mesh(smesh, geompy, box, nx, ny, nz, "PlateHex")
if os.path.exists(MESH_MED):
    os.remove(MESH_MED)
mesh.ExportMED(MESH_MED)
print(f"  {mesh.NbHexas()} hexahedra ({nx} x {ny} x {nz}), {mesh.NbNodes()} mesh nodes, {time.perf_counter() - t:.1f} s")

umesh, X, vol = read_med_cells(MESH_MED, "PlateHex")
n = len(vol)
print(f"  PD nodes = cell centres: {n}, total volume {vol.sum():.4e} m^3 (cell {vol.mean():.3e})")

print(bar)
print("STAGE 3: dynamic OSB peridynamics (libpdcore)")
print(bar)
pd = PDSolver(X, vol, R, dx, influence=1)
pd.set_material(E, nu, rho, s0)
eps = 1e-3 * dx
# Crack tip at 50 mm + 0.27 dx: bonds cross y = 0 at multiples of dx/8 from cell faces; a tip exactly
# on one of those points makes the cut decide on round-off and breaks the mirror symmetry.
tip = 0.05 + 0.27 * dx
pd.add_precrack([x0 - dx, 0.0, z0 - eps], [tip, 0.0, z0 - eps], [x0 - dx, 0.0, z0 + h + eps])
pd.build()
print(f"  E = {E:.3g} Pa, nu = {nu}, rho = {rho}, G0 = {G0} J/m^2 -> s0 = {s0:.4e}")
print(f"  horizon R = {m} dx = {R * 1e3:g} mm, {pd.nbonds} bonds (max {pd.max_horizon}/node), "
      f"precrack cut {pd.broken_bonds} bonds, build {pd.build_time:.2f} s")

top = X[:, 1] > y0 + Ly - dx
bot = X[:, 1] < y0 + dx
pd.traction(top, [0, +sigma, 0], dx)
pd.traction(bot, [0, -sigma, 0], dx)
pd.apply()
print(f"  traction {sigma / 1e6:g} MPa on {top.sum()} top + {bot.sum()} bottom nodes")
print(f"  dt = {dt:g} s (local CFL dx/c_p = {critical_dt(E, nu, rho, dx):.2e} s), {nsteps} steps, "
      f"{PDSolver.threads()} threads")

series = MEDSeries(SOL_MED, umesh)
series.append(0, 0.0, {"Damage": pd.phi, "Displacement": pd.u, "Velocity": pd.v})
t_run = 0.0
done = 0
while done < nsteps:
    k = min(out_every, nsteps - done)
    t = time.perf_counter()
    pd.run(k, dt)
    t_run += time.perf_counter() - t
    done += k
    series.append(done, pd.time, {"Damage": pd.phi, "Displacement": pd.u, "Velocity": pd.v})
    if done % 1000 == 0 or done == nsteps:
        phi = pd.phi
        cracked = X[phi > 0.35]
        tip = cracked[:, 0].max() if len(cracked) else 0.0
        print(f"  t = {pd.time * 1e6:5.1f} us  broken bonds {pd.broken_bonds:8d}  crack tip x = {tip * 1e3:5.1f} mm  "
              f"max|u| = {np.linalg.norm(pd.u, axis=1).max():.3e}")
print(f"  time marching {t_run:.1f} s ({t_run / nsteps * 1e3:.2f} ms/step)")

phi = pd.phi
u = pd.u
mid = np.abs(X[:, 2] - X[:, 2].mean()) < dx / 2 + 1e-12
for name, side in (("upper", X[:, 1] > 3 * dx), ("lower", X[:, 1] < -3 * dx)):
    b = X[(phi > 0.35) & side & mid]
    if len(b):
        print(f"  {name} branch: from x = {b[:, 0].min() * 1e3:.1f} mm, reaches |y| = {np.abs(b[:, 1]).max() * 1e3:.1f} mm")
    else:
        print(f"  {name} branch: none (crack stays within 3 dx of y = 0)")
sym = np.abs(np.sort(phi[X[:, 1] > 0]) - np.sort(phi[X[:, 1] < 0])).max()
print(f"  symmetry check (sorted phi, y>0 vs y<0): max diff {sym:.2e}")
np.savez_compressed(os.path.join(OUT, "final_state.npz"), X=X, vol=vol, phi=phi, u=u, v=pd.v)

print(bar)
print("STAGE 4: PARAVIS — renders")
print(bar)
from pdsalome.viz import render  # noqa: E402
render(SOL_MED, OUT, warp_scale=20.0)

print(bar)
print(f"DONE. Open {SOL_MED} in SALOME (PARAVIS / ParaView) to animate.")
print(bar)
