#!/usr/bin/env python3
"""
SALOME 3D Benchmark: Single-Edge Notched Beam (SENB) — FEM vs. Peridynamics (PD2)
=================================================================================
- Stage 1 (GEOM): 3D Beam (0.16m x 0.04m x 0.01m) with bottom mid-span pre-notch (depth a = 0.016m)
- Stage 2 (SMESH + NETGEN_1D2D3D): 3D Unstructured Tetrahedral Mesh
- Stage 3 (FEM vs. PD2): 3D Linear Elastic FEM vs. 3D Peridynamic Notch-Tip Crack Propagation
- Stage 4 (PARAVIS + MEDReader.so): 3D Deformed Notch Stress & Crack Propagation Renders
"""

import os
import math
import time
import numpy as np
from scipy.sparse import lil_matrix
from scipy.sparse.linalg import spsolve
from scipy.spatial import cKDTree

OUT_DIR = os.path.dirname(os.path.abspath(__file__))
MESH_MED = os.path.join(OUT_DIR, "notched_beam_mesh.med")
SOL_MED  = os.path.join(OUT_DIR, "notched_beam_solution.med")

print("=" * 78)
print("STAGE 1: 3D CAD Modeling of Single-Edge Notched Beam (GEOM)")
print("=" * 78)

from salome.kernel import salome
salome.standalone()
salome.salome_init(embedded=True)

from salome.geom import geomBuilder
geompy = geomBuilder.New()

Lx, Ly, Lz = 0.16, 0.04, 0.01
notch_w, notch_a = 0.003, 0.016  # Notch width 3 mm, depth 16 mm (a/W = 0.40) at x = Lx/2

beam_box = geompy.MakeBoxDXDYDZ(Lx, Ly, Lz)
notch_box = geompy.MakeBox(
    0.5 * (Lx - notch_w), -0.002, -0.002,
    0.5 * (Lx + notch_w), notch_a, Lz + 0.002
)
notched_beam = geompy.MakeCutList(beam_box, [notch_box], True)
geompy.addToStudy(notched_beam, "NotchedBeam")

props = geompy.BasicProperties(notched_beam)
exact_vol = (Lx * Ly - notch_w * notch_a) * Lz
print(f"  [GEOM] Beam Dimensions  : {Lx:.2f} m x {Ly:.2f} m x {Lz:.2f} m (Notch a = {notch_a*1e3:.1f} mm)")
print(f"  [GEOM] Solid Volume     : {props[2]:.8f} m^3 (Analytical: {exact_vol:.8f} m^3)")

print("\n" + "=" * 78)
print("STAGE 2: 3D Unstructured Tetrahedral Meshing (SMESH + NETGEN_1D2D3D)")
print("=" * 78)

from salome.smesh import smeshBuilder
smesh = smeshBuilder.New()

mesh = smesh.Mesh(notched_beam, "NotchedBeamMesh")
algo3d = mesh.Tetrahedron(algo=smeshBuilder.NETGEN_1D2D3D)
params = algo3d.Parameters()
params.SetMaxSize(0.0038)
params.SetMinSize(0.0015)
params.SetFineness(smeshBuilder.Moderate)
params.SetOptimize(True)

ok = mesh.Compute()
print(f"  [SMESH] Mesh Computed   : {ok} ({mesh.NbNodes()} nodes, {mesh.NbTetras()} tetrahedra)")
if os.path.exists(MESH_MED):
    os.remove(MESH_MED)
mesh.ExportMED(MESH_MED)

print("\n" + "=" * 78)
print("STAGE 3: 3D FEM vs. 3D Peridynamics (PD2) Notch-Tip Stress & Fracture")
print("=" * 78)

import medcoupling as mc

umesh = mc.ReadUMeshFromFile(MESH_MED, "NotchedBeamMesh", 0)
n_nodes = umesh.getNumberOfNodes()
n_cells = umesh.getNumberOfCells()
coords = np.array(umesh.getCoords().getValues(), dtype=np.float64).reshape(n_nodes, 3)

conn = np.array(umesh.getNodalConnectivity().getValues(), dtype=np.int64)
conn_idx = np.array(umesh.getNodalConnectivityIndex().getValues(), dtype=np.int64)

E_mod = 71.7e9
nu = 0.25
lmbda = E_mod * nu / ((1.0 + nu) * (1.0 - 2.0 * nu))
mu_shear = E_mod / (2.0 * (1.0 + nu))
C11 = lmbda + 2.0 * mu_shear

D_mat = np.array([
    [C11,   lmbda, lmbda, 0,        0,        0],
    [lmbda, C11,   lmbda, 0,        0,        0],
    [lmbda, lmbda, C11,   0,        0,        0],
    [0,     0,     0,     mu_shear, 0,        0],
    [0,     0,     0,     0,        mu_shear, 0],
    [0,     0,     0,     0,        0,        mu_shear],
], dtype=np.float64)

n_dofs = 3 * n_nodes
K_fem = lil_matrix((n_dofs, n_dofs), dtype=np.float64)
tet_nodes = np.empty((n_cells, 4), dtype=np.int64)
tet_grads = np.empty((n_cells, 3, 4), dtype=np.float64)
cell_volumes = np.empty(n_cells, dtype=np.float64)
nodal_volumes = np.zeros(n_nodes, dtype=np.float64)

for c in range(n_cells):
    idx0 = conn_idx[c]
    nodes = conn[idx0 + 1 : idx0 + 5]
    tet_nodes[c] = nodes
    pts = coords[nodes]
    M = np.ones((4, 4), dtype=np.float64)
    M[:, 1:] = pts
    vol = abs(np.linalg.det(M)) / 6.0
    cell_volumes[c] = vol
    nodal_volumes[nodes] += vol / 4.0
    grads = np.linalg.inv(M)[1:, :]
    tet_grads[c] = grads

    B = np.zeros((6, 12), dtype=np.float64)
    for a in range(4):
        gx, gy, gz = grads[0, a], grads[1, a], grads[2, a]
        c0 = 3 * a
        B[0, c0] = gx; B[1, c0 + 1] = gy; B[2, c0 + 2] = gz
        B[3, c0] = gy; B[3, c0 + 1] = gx
        B[4, c0 + 1] = gz; B[4, c0 + 2] = gy
        B[5, c0] = gz; B[5, c0 + 2] = gx
    Ke = vol * (B.T @ D_mat @ B)
    dofs = np.empty(12, dtype=np.int64)
    for a in range(4):
        dofs[3 * a : 3 * a + 3] = [3 * nodes[a], 3 * nodes[a] + 1, 3 * nodes[a] + 2]
    for i_loc in range(12):
        gi = dofs[i_loc]
        K_fem.rows[gi].extend(dofs.tolist())
        K_fem.data[gi].extend(Ke[i_loc].tolist())

K_fem_csr = K_fem.tocsr()

# Mode-I tensile + opening load at ends x = 0 and x = Lx (u0 = 0.08 mm)
u0 = 8.0e-5
tol = 1e-5
left_nodes  = np.where(np.abs(coords[:, 0] - 0.0) < tol)[0]
right_nodes = np.where(np.abs(coords[:, 0] - Lx) < tol)[0]

bc_dofs = {}
for nid in left_nodes:
    bc_dofs[3 * nid] = -u0
    bc_dofs[3 * nid + 1] = 0.0
for nid in right_nodes:
    bc_dofs[3 * nid] = +u0
    bc_dofs[3 * nid + 1] = 0.0
for side_nodes in (left_nodes, right_nodes):
    for nid in side_nodes:
        if abs(coords[nid, 2] - 0.0) < tol:
            bc_dofs[3 * nid + 2] = 0.0

def solve_dirichlet(K_csr, prescribed):
    free_mask = np.ones(n_dofs, dtype=bool)
    u_full = np.zeros(n_dofs, dtype=np.float64)
    for dof_id, val in prescribed.items():
        free_mask[dof_id] = False
        u_full[dof_id] = val
    free_idx = np.where(free_mask)[0]
    fixed_idx = np.where(~free_mask)[0]
    rhs = -K_csr[free_idx][:, fixed_idx] @ u_full[fixed_idx]
    u_full[free_idx] = spsolve(K_csr[free_idx][:, free_idx], rhs)
    return u_full.reshape(n_nodes, 3)

u_fem = solve_dirichlet(K_fem_csr, bc_dofs)

sigma_xx_fem = np.zeros(n_nodes, dtype=np.float64)
sigma_vm_fem = np.zeros(n_nodes, dtype=np.float64)
node_vol_acc = np.zeros(n_nodes, dtype=np.float64)

for c in range(n_cells):
    nodes = tet_nodes[c]
    grads = tet_grads[c]
    grad_u = u_fem[nodes].T @ grads.T
    eps = np.array([
        grad_u[0, 0], grad_u[1, 1], grad_u[2, 2],
        grad_u[0, 1] + grad_u[1, 0], grad_u[1, 2] + grad_u[2, 1], grad_u[0, 2] + grad_u[2, 0]
    ])
    sxx, syy, szz, sxy, syz, sxz = D_mat @ eps
    vm = math.sqrt(0.5 * ((sxx - syy)**2 + (syy - szz)**2 + (szz - sxx)**2 + 6.0 * (sxy**2 + syz**2 + sxz**2)))
    vol = cell_volumes[c]
    for nid in nodes:
        sigma_xx_fem[nid] += sxx * vol
        sigma_vm_fem[nid] += vm * vol
        node_vol_acc[nid] += vol
sigma_xx_fem /= node_vol_acc
sigma_vm_fem /= node_vol_acc

# 3D Peridynamics (PD2) on the Notched Beam
h_avg = (exact_vol / n_nodes) ** (1.0 / 3.0)
delta = 3.0 * h_avg
tree = cKDTree(coords)
neighbors_list = tree.query_ball_point(coords, r=delta)

# Filter out any bond that crosses the pre-notch slot!
def crosses_notch(p1, p2):
    x_min, x_max = 0.5 * (Lx - notch_w), 0.5 * (Lx + notch_w)
    if max(p1[1], p2[1]) <= notch_a and (min(p1[0], p2[0]) <= x_max and max(p1[0], p2[0]) >= x_min):
        if (p1[0] <= x_min and p2[0] >= x_max) or (p2[0] <= x_min and p1[0] >= x_max):
            return True
    return False

valid_neighbors = [[] for _ in range(n_nodes)]
node_scale = np.zeros((n_nodes, 3), dtype=np.float64)
for i in range(n_nodes):
    xi_i = coords[i]
    m_dir = np.zeros(3, dtype=np.float64)
    for j in neighbors_list[i]:
        if j == i or crosses_notch(xi_i, coords[j]):
            continue
        diff = coords[j] - xi_i
        dist = np.linalg.norm(diff)
        if dist <= delta:
            valid_neighbors[i].append(j)
            m_dir += (diff ** 2 / dist) * nodal_volumes[j]
    node_scale[i] = 3.0 * C11 / np.maximum(m_dir, 1e-30)

def assemble_pd(broken_set):
    K_mat = lil_matrix((n_dofs, n_dofs), dtype=np.float64)
    for i in range(n_nodes):
        xi_i = coords[i]
        Vi = nodal_volumes[i]
        diag_block = np.zeros((3, 3), dtype=np.float64)
        row_dofs = [3 * i, 3 * i + 1, 3 * i + 2]
        for j in valid_neighbors[i]:
            if (i, j) in broken_set:
                continue
            diff = coords[j] - xi_i
            dist = np.linalg.norm(diff)
            Vj = nodal_volumes[j]
            unit = diff / dist
            c_ij = 0.5 * (np.dot(unit ** 2, node_scale[i]) + np.dot(unit ** 2, node_scale[j]))
            k_bond = (c_ij * Vi * Vj / (dist ** 3)) * np.outer(diff, diff)
            diag_block += k_bond
            col_dofs = [3 * j, 3 * j + 1, 3 * j + 2]
            for r_idx in range(3):
                K_mat.rows[row_dofs[r_idx]].extend(col_dofs)
                K_mat.data[row_dofs[r_idx]].extend((-k_bond[r_idx]).tolist())
        diag_block += 1e-6 * C11 * Vi * np.eye(3)
        for r_idx in range(3):
            K_mat.rows[row_dofs[r_idx]].extend(row_dofs)
            K_mat.data[row_dofs[r_idx]].extend(diag_block[r_idx].tolist())
    return K_mat.tocsr()

u_pd = solve_dirichlet(assemble_pd(set()), bc_dofs)

sigma_vm_pd = np.zeros(n_nodes, dtype=np.float64)
max_stretch = np.zeros(n_nodes, dtype=np.float64)
for i in range(n_nodes):
    xi_i = coords[i]
    ui = u_pd[i]
    K_shape = np.zeros((3, 3), dtype=np.float64)
    P_du = np.zeros((3, 3), dtype=np.float64)
    s_max_i = 0.0
    for j in valid_neighbors[i]:
        xi = coords[j] - xi_i
        dist = np.linalg.norm(xi)
        du = u_pd[j] - ui
        s_ij = np.dot(xi, du) / (dist ** 2)
        if s_ij > s_max_i:
            s_max_i = s_ij
        w = (1.0 / dist) * nodal_volumes[j]
        K_shape += w * np.outer(xi, xi)
        P_du += w * np.outer(du, xi)
    max_stretch[i] = s_max_i
    grad_u = P_du @ np.linalg.pinv(K_shape, rcond=1e-3)
    eps = np.array([
        grad_u[0, 0], grad_u[1, 1], grad_u[2, 2],
        grad_u[0, 1] + grad_u[1, 0], grad_u[1, 2] + grad_u[2, 1], grad_u[0, 2] + grad_u[2, 0]
    ])
    sxx, syy, szz, sxy, syz, sxz = D_mat @ eps
    sigma_vm_pd[i] = math.sqrt(0.5 * ((sxx - syy)**2 + (syy - szz)**2 + (szz - sxx)**2 + 6.0 * (sxy**2 + syz**2 + sxz**2)))

# Progressive Mode-I crack propagation upward from the notch tip (x = 0.08, y >= 0.016)
s_crit = 0.55 * np.percentile(max_stretch, 99.5)
broken_bonds = set()
damage_index = np.zeros(n_nodes, dtype=np.float64)
u_pd_frac = u_pd.copy()

for step in range(1, 4):
    load_factor = 1.0 + 0.14 * step
    for i in range(n_nodes):
        if coords[i, 0] < 0.04 or coords[i, 0] > Lx - 0.04:
            continue
        xi_i = coords[i]
        ui = u_pd_frac[i] * load_factor
        for j in valid_neighbors[i]:
            if j <= i or (i, j) in broken_bonds:
                continue
            xi = coords[j] - xi_i
            dist = np.linalg.norm(xi)
            s_ij = np.dot(xi, u_pd_frac[j] * load_factor - ui) / (dist ** 2)
            if s_ij > s_crit:
                broken_bonds.add((i, j))
                broken_bonds.add((j, i))
    u_pd_frac = solve_dirichlet(assemble_pd(broken_bonds), bc_dofs)
    for i in range(n_nodes):
        vol_tot = sum(nodal_volumes[j] for j in valid_neighbors[i])
        vol_int = sum(nodal_volumes[j] for j in valid_neighbors[i] if (i, j) not in broken_bonds)
        damage_index[i] = 1.0 - (vol_int / max(vol_tot, 1e-30))
    print(f"  [PD2-SENB] Step {step}: Broken Bonds={len(broken_bonds)//2:4d} | Max Notch-Tip Damage phi={damage_index.max():.3f}")

u_diff = np.linalg.norm(u_fem - u_pd) / np.linalg.norm(u_fem)
print(f"  [RESULT] FEM Peak Notch-Tip Von Mises : {sigma_vm_fem.max()/1e6:.2f} MPa")
print(f"  [RESULT] PD2 Peak Notch-Tip Von Mises : {sigma_vm_pd.max()/1e6:.2f} MPa")
print(f"  [RESULT] FEM Mean Von Mises           : {sigma_vm_fem.mean()/1e6:.2f} MPa")
print(f"  [RESULT] PD2 Mean Von Mises           : {sigma_vm_pd.mean()/1e6:.2f} MPa")
print(f"  [RESULT] Elastic L2 Displacement Diff : {u_diff*100:.2f}%")

if os.path.exists(SOL_MED):
    os.remove(SOL_MED)
mc.WriteUMesh(SOL_MED, umesh, True)

def write_field(name, arr, comps):
    f = mc.MEDCouplingFieldDouble(mc.ON_NODES, mc.ONE_TIME)
    f.setName(name)
    f.setMesh(umesh)
    if arr.ndim == 1:
        da = mc.DataArrayDouble(arr.tolist())
        da.setInfoOnComponent(0, comps[0])
    else:
        da = mc.DataArrayDouble(arr.flatten().tolist(), arr.shape[0], arr.shape[1])
        for idx, c in enumerate(comps):
            da.setInfoOnComponent(idx, c)
    f.setArray(da)
    mc.WriteFieldUsingAlreadyWrittenMesh(SOL_MED, f)

write_field("FEM_Displacement_m", u_fem, ["ux", "uy", "uz"])
write_field("PD2_Fracture_Displacement_m", u_pd_frac, ["ux", "uy", "uz"])
write_field("FEM_VonMises_MPa", sigma_vm_fem / 1e6, ["MPa"])
write_field("PD2_VonMises_MPa", sigma_vm_pd / 1e6, ["MPa"])
write_field("PD2_Damage_Index", damage_index, ["phi"])

import paraview.simple as pvs
pvs.LoadPlugin("/Users/ahorasaze/Desktop/salome/install/PARAVIS/lib/paraview/MEDReader.so", remote=False)
reader = pvs.MEDReader(FileNames=[SOL_MED])
all_fields = list(reader.GetProperty("FieldsTreeInfo")[::2])
if all_fields:
    reader.FieldsStatus = all_fields
reader.UpdatePipeline()

warp = pvs.WarpByVector(Input=reader)
warp.Vectors = ["POINTS", "FEM_Displacement_m"]
warp.ScaleFactor = 90.0
warp.UpdatePipeline()

view = pvs.CreateRenderView()
view.ViewSize = [1400, 750]
view.Background = [0.14, 0.16, 0.20]
disp = pvs.Show(warp, view)
disp.Representation = "Surface With Edges"
disp.EdgeColor = [0.22, 0.25, 0.30]

cam = view.GetActiveCamera()
cam.SetPosition(0.08, -0.09, 0.15)
cam.SetFocalPoint(0.08, 0.02, 0.005)
cam.SetViewUp(0.0, 1.0, 0.0)

pvs.ColorBy(disp, ("POINTS", "FEM_VonMises_MPa"))
lut1 = pvs.GetColorTransferFunction("FEM_VonMises_MPa")
lut1.ApplyPreset("Cool to Warm (Extended)", True)
lut1.RescaleTransferFunction(10.0, 220.0)
sb1 = pvs.GetScalarBar(lut1, view)
sb1.Title = "SENB FEM Von Mises Stress (MPa)"
sb1.ComponentTitle = ""
sb1.Visibility = 1
pvs.Render(view)
img1 = os.path.join(OUT_DIR, "notched_beam_fem_stress_3d.png")
pvs.SaveScreenshot(img1, view, ImageResolution=[1400, 750])
sb1.Visibility = 0

warp.Vectors = ["POINTS", "PD2_Fracture_Displacement_m"]
warp.ScaleFactor = 110.0
warp.UpdatePipeline()
pvs.ColorBy(disp, ("POINTS", "PD2_Damage_Index"))
lut2 = pvs.GetColorTransferFunction("PD2_Damage_Index")
lut2.ApplyPreset("Inferno (matplotlib)", True)
lut2.RescaleTransferFunction(0.0, max(float(damage_index.max()), 0.25))
sb2 = pvs.GetScalarBar(lut2, view)
sb2.Title = "SENB PD2 Notch Crack Damage (phi)"
sb2.ComponentTitle = ""
sb2.Visibility = 1
pvs.Render(view)
img2 = os.path.join(OUT_DIR, "notched_beam_pd_crack_3d.png")
pvs.SaveScreenshot(img2, view, ImageResolution=[1400, 750])
print(f"  [PARAVIS] Saved {img1} & {img2}")
