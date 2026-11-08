#!/usr/bin/env python3
"""
SALOME 3D Benchmark: Coupled Thermo-Mechanical Shock — FEM vs. Peridynamics (PD2)
=================================================================================
- Loads the solved 3D temperature field T(x) [290 K .. 385 K] from cooling_block_solution.med
- Solves 3D Coupled Thermo-Elastic FEM: div(D : (eps - alpha * dT * I)) = 0
- Solves 3D Coupled Thermo-Mechanical Peridynamics (PD2): s_mech = s_total - alpha * dT_avg
- Computes thermal-shock bond fracture around the chilled coolant channels & renders in PARAVIS
"""

import os
import math
import numpy as np
from scipy.sparse import lil_matrix
from scipy.sparse.linalg import spsolve
from scipy.spatial import cKDTree
import medcoupling as mc

OUT_DIR = os.path.dirname(os.path.abspath(__file__))
THERM_MED = os.path.join(OUT_DIR, "cooling_block_solution.med")
SOL_MED   = os.path.join(OUT_DIR, "thermo_mech_solution.med")

print("=" * 78)
print("COUPLED 3D THERMO-MECHANICAL SHOCK: FEM vs. PERIDYNAMICS (PD2)")
print("=" * 78)

umesh = mc.ReadUMeshFromFile(THERM_MED, "CoolingBlockMesh", 0)
t_field = mc.ReadFieldNode(THERM_MED, "CoolingBlockMesh", 0, "Temperature_Nodes", -1, -1)
T_nodes = np.array(t_field.getArray().getValues(), dtype=np.float64)

n_nodes = umesh.getNumberOfNodes()
n_cells = umesh.getNumberOfCells()
coords = np.array(umesh.getCoords().getValues(), dtype=np.float64).reshape(n_nodes, 3)
conn = np.array(umesh.getNodalConnectivity().getValues(), dtype=np.int64)
conn_idx = np.array(umesh.getNodalConnectivityIndex().getValues(), dtype=np.int64)

# Aluminum 6061-T6 thermo-mechanical properties: E = 68.9 GPa, nu = 0.25, alpha = 23.1e-6 K^-1, T_ref = 290 K
E_mod = 68.9e9
nu = 0.25
alpha = 23.1e-6
T_ref = 290.0
dT_nodes = T_nodes - T_ref

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
f_fem = np.zeros(n_dofs, dtype=np.float64)

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
    dT_cell = dT_nodes[nodes].mean()
    eps_th = np.array([alpha * dT_cell, alpha * dT_cell, alpha * dT_cell, 0.0, 0.0, 0.0])
    fe = vol * (B.T @ (D_mat @ eps_th))

    dofs = np.empty(12, dtype=np.int64)
    for a in range(4):
        dofs[3 * a : 3 * a + 3] = [3 * nodes[a], 3 * nodes[a] + 1, 3 * nodes[a] + 2]
    f_fem[dofs] += fe
    for i_loc in range(12):
        gi = dofs[i_loc]
        K_fem.rows[gi].extend(dofs.tolist())
        K_fem.data[gi].extend(Ke[i_loc].tolist())

K_fem_csr = K_fem.tocsr()

# Bolted base constraint (z = 0 restrained in z, lateral ends x = 0 and x = 0.10 restrained in x)
tol = 1e-4
bc_dofs = {}
for nid in range(n_nodes):
    x, y, z = coords[nid]
    if abs(z - 0.0) < tol:
        bc_dofs[3 * nid + 2] = 0.0
    if abs(x - 0.0) < tol or abs(x - 0.10) < tol:
        bc_dofs[3 * nid] = 0.0
    if abs(y - 0.0) < tol or abs(y - 0.06) < tol:
        bc_dofs[3 * nid + 1] = 0.0

def solve_system(K_csr, rhs_vec, prescribed):
    free_mask = np.ones(n_dofs, dtype=bool)
    u_full = np.zeros(n_dofs, dtype=np.float64)
    for dof_id, val in prescribed.items():
        free_mask[dof_id] = False
        u_full[dof_id] = val
    free_idx = np.where(free_mask)[0]
    fixed_idx = np.where(~free_mask)[0]
    rhs_free = rhs_vec[free_idx] - K_csr[free_idx][:, fixed_idx] @ u_full[fixed_idx]
    u_full[free_idx] = spsolve(K_csr[free_idx][:, free_idx], rhs_free)
    return u_full.reshape(n_nodes, 3)

u_fem = solve_system(K_fem_csr, f_fem, bc_dofs)

sigma_vm_fem = np.zeros(n_nodes, dtype=np.float64)
node_vol_acc = np.zeros(n_nodes, dtype=np.float64)
for c in range(n_cells):
    nodes = tet_nodes[c]
    grads = tet_grads[c]
    grad_u = u_fem[nodes].T @ grads.T
    dT_c = dT_nodes[nodes].mean()
    eps_mech = np.array([
        grad_u[0, 0] - alpha * dT_c,
        grad_u[1, 1] - alpha * dT_c,
        grad_u[2, 2] - alpha * dT_c,
        grad_u[0, 1] + grad_u[1, 0],
        grad_u[1, 2] + grad_u[2, 1],
        grad_u[0, 2] + grad_u[2, 0],
    ])
    sxx, syy, szz, sxy, syz, sxz = D_mat @ eps_mech
    vm = math.sqrt(0.5 * ((sxx - syy)**2 + (syy - szz)**2 + (szz - sxx)**2 + 6.0 * (sxy**2 + syz**2 + sxz**2)))
    vol = cell_volumes[c]
    for nid in nodes:
        sigma_vm_fem[nid] += vm * vol
        node_vol_acc[nid] += vol
sigma_vm_fem /= node_vol_acc

# 3D Coupled Thermo-Mechanical Peridynamics (PD2)
total_vol = cell_volumes.sum()
h_avg = (total_vol / n_nodes) ** (1.0 / 3.0)
delta = 3.0 * h_avg
tree = cKDTree(coords)
neighbors_list = tree.query_ball_point(coords, r=delta)

node_scale = np.zeros((n_nodes, 3), dtype=np.float64)
for i in range(n_nodes):
    xi_i = coords[i]
    m_dir = np.zeros(3, dtype=np.float64)
    for j in neighbors_list[i]:
        if j == i:
            continue
        diff = coords[j] - xi_i
        dist = np.linalg.norm(diff)
        if dist <= delta:
            m_dir += (diff ** 2 / dist) * nodal_volumes[j]
    node_scale[i] = 3.0 * C11 / np.maximum(m_dir, 1e-30)

K_pd = lil_matrix((n_dofs, n_dofs), dtype=np.float64)
f_pd = np.zeros(n_dofs, dtype=np.float64)

for i in range(n_nodes):
    xi_i = coords[i]
    Vi = nodal_volumes[i]
    diag_block = np.zeros((3, 3), dtype=np.float64)
    row_dofs = [3 * i, 3 * i + 1, 3 * i + 2]
    for j in neighbors_list[i]:
        if j == i:
            continue
        diff = coords[j] - xi_i
        dist = np.linalg.norm(diff)
        if dist <= delta:
            Vj = nodal_volumes[j]
            unit = diff / dist
            c_ij = 0.5 * (np.dot(unit ** 2, node_scale[i]) + np.dot(unit ** 2, node_scale[j]))
            k_bond = (c_ij * Vi * Vj / (dist ** 3)) * np.outer(diff, diff)
            diag_block += k_bond
            col_dofs = [3 * j, 3 * j + 1, 3 * j + 2]
            for r_idx in range(3):
                K_pd.rows[row_dofs[r_idx]].extend(col_dofs)
                K_pd.data[row_dofs[r_idx]].extend((-k_bond[r_idx]).tolist())
            # Thermal bond force contribution: -k_bond @ (alpha * dT_ij * diff) = -c_ij * alpha * dT_ij * (diff / dist) * Vi * Vj
            dT_ij = 0.5 * (dT_nodes[i] + dT_nodes[j])
            f_pd[row_dofs] -= (c_ij * alpha * dT_ij * Vi * Vj / dist) * diff

    for r_idx in range(3):
        K_pd.rows[row_dofs[r_idx]].extend(row_dofs)
        K_pd.data[row_dofs[r_idx]].extend(diag_block[r_idx].tolist())

u_pd = solve_system(K_pd.tocsr(), f_pd, bc_dofs)

sigma_vm_pd = np.zeros(n_nodes, dtype=np.float64)
damage_index = np.zeros(n_nodes, dtype=np.float64)
max_th_stretch = np.zeros(n_nodes, dtype=np.float64)

for i in range(n_nodes):
    xi_i = coords[i]
    ui = u_pd[i]
    K_shape = np.zeros((3, 3), dtype=np.float64)
    P_du = np.zeros((3, 3), dtype=np.float64)
    s_max_i = 0.0
    for j in neighbors_list[i]:
        if j == i:
            continue
        xi = coords[j] - xi_i
        dist = np.linalg.norm(xi)
        du = u_pd[j] - ui
        dT_ij = 0.5 * (dT_nodes[i] + dT_nodes[j])
        s_mech = abs(np.dot(xi, du) / (dist ** 2) - alpha * dT_ij)
        if s_mech > s_max_i:
            s_max_i = s_mech
        w = (1.0 / dist) * nodal_volumes[j]
        K_shape += w * np.outer(xi, xi)
        P_du += w * np.outer(du, xi)
    max_th_stretch[i] = s_max_i
    grad_u = P_du @ np.linalg.pinv(K_shape, rcond=1e-3)
    dT_i = dT_nodes[i]
    eps_m = np.array([
        grad_u[0, 0] - alpha * dT_i,
        grad_u[1, 1] - alpha * dT_i,
        grad_u[2, 2] - alpha * dT_i,
        grad_u[0, 1] + grad_u[1, 0],
        grad_u[1, 2] + grad_u[2, 1],
        grad_u[0, 2] + grad_u[2, 0],
    ])
    sxx, syy, szz, sxy, syz, sxz = D_mat @ eps_m
    sigma_vm_pd[i] = math.sqrt(0.5 * ((sxx - syy)**2 + (syy - szz)**2 + (szz - sxx)**2 + 6.0 * (sxy**2 + syz**2 + sxz**2)))

# Compute thermal-shock bond damage around chilled channels where |s_mech| > s_crit_th
s_crit_th = 0.42 * np.percentile(max_th_stretch, 96.0)
broken_count = 0
for i in range(n_nodes):
    xi_i = coords[i]
    ui = u_pd[i]
    vol_tot = 0.0
    vol_int = 0.0
    for j in neighbors_list[i]:
        if j == i:
            continue
        xi = coords[j] - xi_i
        dist = np.linalg.norm(xi)
        du = u_pd[j] - ui
        dT_ij = 0.5 * (dT_nodes[i] + dT_nodes[j])
        s_mech = abs(np.dot(xi, du) / (dist ** 2) - alpha * dT_ij)
        Vj = nodal_volumes[j]
        vol_tot += Vj
        if s_mech <= s_crit_th:
            vol_int += Vj
        elif j > i:
            broken_count += 1
    damage_index[i] = 1.0 - (vol_int / max(vol_tot, 1e-30))

u_diff = np.linalg.norm(u_fem - u_pd) / np.linalg.norm(u_fem)
print(f"  [THERMO-MECH] FEM Max Thermal Displacement : {np.linalg.norm(u_fem, axis=1).max()*1e3:.4f} mm")
print(f"  [THERMO-MECH] PD2 Max Thermal Displacement : {np.linalg.norm(u_pd, axis=1).max()*1e3:.4f} mm (L2 diff: {u_diff*100:.2f}%)")
print(f"  [THERMO-MECH] FEM Mean Thermal Von Mises   : {sigma_vm_fem.mean()/1e6:.2f} MPa (Max: {sigma_vm_fem.max()/1e6:.2f} MPa)")
print(f"  [THERMO-MECH] PD2 Mean Thermal Von Mises   : {sigma_vm_pd.mean()/1e6:.2f} MPa (Max: {sigma_vm_pd.max()/1e6:.2f} MPa)")
print(f"  [THERMO-MECH] PD2 Thermal-Shock Damage phi : {damage_index.max():.3f} ({broken_count} broken thermal bonds)")

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

write_field("FEM_Thermal_Displacement_m", u_fem, ["ux", "uy", "uz"])
write_field("FEM_Thermal_VonMises_MPa", sigma_vm_fem / 1e6, ["MPa"])
write_field("PD2_Thermal_VonMises_MPa", sigma_vm_pd / 1e6, ["MPa"])
write_field("PD2_Thermal_Damage_Index", damage_index, ["phi"])

import paraview.simple as pvs
pvs.LoadPlugin("/Users/ahorasaze/Desktop/salome/install/PARAVIS/lib/paraview/MEDReader.so", remote=False)
reader = pvs.MEDReader(FileNames=[SOL_MED])
all_fields = list(reader.GetProperty("FieldsTreeInfo")[::2])
if all_fields:
    reader.FieldsStatus = all_fields
reader.UpdatePipeline()

clip = pvs.Clip(Input=reader)
clip.ClipType = "Plane"
clip.ClipType.Origin = [0.05, 0.03, 0.02]
clip.ClipType.Normal = [0.0, -1.0, 0.0]
clip.UpdatePipeline()

view = pvs.CreateRenderView()
view.ViewSize = [1400, 850]
view.Background = [0.14, 0.16, 0.20]
disp = pvs.Show(clip, view)
disp.Representation = "Surface With Edges"
disp.EdgeColor = [0.22, 0.25, 0.30]

cam = view.GetActiveCamera()
cam.SetPosition(0.15, -0.15, 0.10)
cam.SetFocalPoint(0.05, 0.03, 0.02)
cam.SetViewUp(0.0, 0.0, 1.0)

pvs.ColorBy(disp, ("POINTS", "FEM_Thermal_VonMises_MPa"))
lut1 = pvs.GetColorTransferFunction("FEM_Thermal_VonMises_MPa")
lut1.ApplyPreset("Cool to Warm (Extended)", True)
lut1.RescaleTransferFunction(20.0, 220.0)
sb1 = pvs.GetScalarBar(lut1, view)
sb1.Title = "Thermo-Elastic FEM Von Mises Stress (MPa)"
sb1.ComponentTitle = ""
sb1.Visibility = 1
pvs.Render(view)
img1 = os.path.join(OUT_DIR, "thermo_mech_fem_stress_3d.png")
pvs.SaveScreenshot(img1, view, ImageResolution=[1400, 850])
sb1.Visibility = 0

pvs.ColorBy(disp, ("POINTS", "PD2_Thermal_Damage_Index"))
lut2 = pvs.GetColorTransferFunction("PD2_Thermal_Damage_Index")
lut2.ApplyPreset("Inferno (matplotlib)", True)
lut2.RescaleTransferFunction(0.0, max(float(damage_index.max()), 0.05))
sb2 = pvs.GetScalarBar(lut2, view)
sb2.Title = "PD2 Thermal-Shock Damage (phi)"
sb2.ComponentTitle = ""
sb2.Visibility = 1
pvs.Render(view)
img2 = os.path.join(OUT_DIR, "thermo_mech_pd_damage_3d.png")
pvs.SaveScreenshot(img2, view, ImageResolution=[1400, 850])
print(f"  [PARAVIS] Saved {img1} & {img2}")
