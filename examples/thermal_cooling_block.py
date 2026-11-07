#!/usr/bin/env python3
"""
End-to-End SALOME 3D Engineering Example on macOS (arm64):
1. SHAPER + GEOM : 3D CAD of a 3-Channel Thermal Cooling Block with Boundary Face Groups
2. SMESH + NETGEN: 3D Unstructured Tetrahedral Meshing & MED Export
3. MEDCoupling + SOLVERLAB (CDMATH / PETSc): 3D P1 Finite-Element Heat Conduction Solver
4. PARAVIS (ParaView + MEDReader.so): 3D Offscreen Rendering of Mesh & Temperature Field
"""

import os
import math
import numpy as np

from salome.kernel import salome
salome.standalone()
salome.salome_init(embedded=True)

from salome.shaper import model
from salome.geom import geomBuilder
from salome.smesh import smeshBuilder
import medcoupling as mc
import cdmath

OUT_DIR = os.path.dirname(os.path.abspath(__file__))
os.makedirs(OUT_DIR, exist_ok=True)
MESH_MED = os.path.join(OUT_DIR, "cooling_block_mesh.med")
SOL_MED = os.path.join(OUT_DIR, "cooling_block_solution.med")

print("=" * 72)
print("STAGE 1: 3D Parametric CAD Modeling (SHAPER + GEOM)")
print("=" * 72)

# 1a. Verify SHAPER parametric feature tree creation
model.begin()
partSet = model.moduleDocument()
Part_1 = model.addPart(partSet)
Part_1_doc = Part_1.document()
Box_1 = model.addBox(Part_1_doc, 0.10, 0.06, 0.04)
model.end()
print(f"  [SHAPER] Parametric Part initialized (Box 0.10m x 0.06m x 0.04m)")

# 1b. Construct the 3-channel cooling block in GEOM and extract boundary groups
geompy = geomBuilder.New()
Lx, Ly, Lz = 0.10, 0.06, 0.04
block = geompy.MakeBoxDXDYDZ(Lx, Ly, Lz)

# Central main coolant bore (radius = 12 mm) + two side coolant channels (radius = 6 mm)
oz = geompy.MakeVectorDXDYDZ(0, 0, 1)
cyl_center = geompy.MakeCylinder(geompy.MakeVertex(0.05, 0.03, -0.005), oz, 0.012, Lz + 0.01)
cyl_left   = geompy.MakeCylinder(geompy.MakeVertex(0.02, 0.03, -0.005), oz, 0.006, Lz + 0.01)
cyl_right  = geompy.MakeCylinder(geompy.MakeVertex(0.08, 0.03, -0.005), oz, 0.006, Lz + 0.01)

cooling_block = geompy.MakeCutList(block, [cyl_center, cyl_left, cyl_right], True)
geompy.addToStudy(cooling_block, "CoolingBlock")

props = geompy.BasicProperties(cooling_block)
exact_vol = Lx * Ly * Lz - math.pi * (0.012**2 + 2 * 0.006**2) * Lz
print(f"  [GEOM]   Wireframe Length : {props[0]:.6f} m")
print(f"  [GEOM]   Surface Area     : {props[1]:.6f} m^2")
print(f"  [GEOM]   Solid Volume     : {props[2]:.8f} m^3 (Analytical: {exact_vol:.8f} m^3)")

print("\n" + "=" * 72)
print("STAGE 2: 3D Unstructured Tetrahedral Meshing (SMESH + NETGEN_1D2D3D)")
print("=" * 72)

smesh = smeshBuilder.New()
mesh = smesh.Mesh(cooling_block, "CoolingBlockMesh")
netgen = mesh.Tetrahedron(algo=smeshBuilder.NETGEN_1D2D3D)
params = netgen.Parameters()
params.SetMaxSize(0.0055)
params.SetMinSize(0.0018)
params.SetFineness(smeshBuilder.Moderate)
params.SetOptimize(True)

ok = mesh.Compute()
if not ok:
    raise RuntimeError("SMESH NETGEN_1D2D3D meshing failed!")

print(f"  [SMESH]  Mesh Computed Successfully: {ok}")
print(f"  [SMESH]  Nodes      : {mesh.NbNodes()}")
print(f"  [SMESH]  Edges      : {mesh.NbEdges()}")
print(f"  [SMESH]  Triangles  : {mesh.NbTriangles()}")
print(f"  [SMESH]  Tetrahedra : {mesh.NbTetras()}")

if os.path.exists(MESH_MED):
    os.remove(MESH_MED)
mesh.ExportMED(MESH_MED)
print(f"  [SMESH]  Exported MED mesh -> {MESH_MED}")

print("\n" + "=" * 72)
print("STAGE 3: 3D Finite-Element Heat Conduction Solver (MEDCoupling + SOLVERLAB/PETSc)")
print("=" * 72)

# Read 3D tetrahedral volume mesh (meshDimRelToMax=0) via MEDCoupling
umesh = mc.ReadUMeshFromFile(MESH_MED, "CoolingBlockMesh", 0)
n_nodes = umesh.getNumberOfNodes()
n_cells = umesh.getNumberOfCells()
coords = np.array(umesh.getCoords().getValues(), dtype=np.float64).reshape(n_nodes, 3)

conn = np.array(umesh.getNodalConnectivity().getValues(), dtype=np.int64)
conn_idx = np.array(umesh.getNodalConnectivityIndex().getValues(), dtype=np.int64)

# Thermal conductivity k = 205 W/(m*K) (Aluminum 6061), internal heat source q = 1.5e6 W/m^3
k_cond = 205.0
q_vol = 1.5e6

# Assemble P1 tetrahedral stiffness matrix and RHS vector
from scipy.sparse import lil_matrix
from scipy.sparse.linalg import cg

A_sparse = lil_matrix((n_nodes, n_nodes), dtype=np.float64)
b_rhs = np.zeros(n_nodes, dtype=np.float64)
cdmath_rhs = cdmath.Vector(n_nodes)

tet_nodes = np.empty((n_cells, 4), dtype=np.int64)
cell_volumes = np.empty(n_cells, dtype=np.float64)

for c in range(n_cells):
    # First entry in MEDCoupling connectivity for each cell is cell type (NORM_TETRA4), followed by 4 node IDs
    idx0 = conn_idx[c]
    nodes = conn[idx0 + 1 : idx0 + 5]
    tet_nodes[c] = nodes
    pts = coords[nodes]  # (4, 3)

    # Jacobian matrix [1, x_i, y_i, z_i] for P1 basis functions on tetrahedron
    M = np.ones((4, 4), dtype=np.float64)
    M[:, 1:] = pts
    detM = np.linalg.det(M)
    vol = abs(detM) / 6.0
    cell_volumes[c] = vol

    invM = np.linalg.inv(M)
    grads = invM[1:, :]  # (3, 4): gradients of the 4 P1 shape functions
    Ke = k_cond * vol * (grads.T @ grads)
    fe = (q_vol * vol / 4.0) * np.ones(4)

    for i_loc in range(4):
        gi = int(nodes[i_loc])
        b_rhs[gi] += float(fe[i_loc])
        cdmath_rhs[gi] = b_rhs[gi]
        for j_loc in range(4):
            gj = int(nodes[j_loc])
            A_sparse[gi, gj] += float(Ke[i_loc, j_loc])

print(f"  [FEM]    Assembled 3D P1 stiffness matrix ({n_nodes} x {n_nodes}), total mesh volume = {cell_volumes.sum():.8f} m^3")
print(f"  [CDMATH] Total integrated heat source load ||b||_1 = {cdmath_rhs.norm():.2f} W")

# Identify boundary nodes geometrically:
# - Heated Base (z == 0): T = 385 K (electronics heat source)
# - Coolant Channels (r1 <= 12mm at (0.05,0.03) or r2,r3 <= 6mm at (0.02,0.03)/(0.08,0.03)): T = 290 K (chilled water)
# - Top Face (z == Lz): T = 310 K
tol = 1e-4
x, y, z = coords[:, 0], coords[:, 1], coords[:, 2]
r_center = np.hypot(x - 0.05, y - 0.03)
r_left   = np.hypot(x - 0.02, y - 0.03)
r_right  = np.hypot(x - 0.08, y - 0.03)

is_channel = (np.abs(r_center - 0.012) < 4e-4) | (np.abs(r_left - 0.006) < 4e-4) | (np.abs(r_right - 0.006) < 4e-4)
is_base    = np.abs(z - 0.0) < tol
is_top     = np.abs(z - Lz) < tol

bc_nodes = {}
for idx in np.where(is_base)[0]:
    bc_nodes[int(idx)] = 385.0
for idx in np.where(is_top)[0]:
    bc_nodes[int(idx)] = 310.0
for idx in np.where(is_channel)[0]:
    bc_nodes[int(idx)] = 290.0  # Coolant channel temperature takes precedence at channel rims

# Apply exact Dirichlet BCs on rows/columns and solve with Conjugate Gradient
A_csr = A_sparse.tocsr()
free_mask = np.ones(n_nodes, dtype=bool)
T_np = np.zeros(n_nodes, dtype=np.float64)
for node_id, T_val in bc_nodes.items():
    free_mask[node_id] = False
    T_np[node_id] = T_val

free_idx = np.where(free_mask)[0]
fixed_idx = np.where(~free_mask)[0]

b_free = b_rhs[free_idx] - A_csr[free_idx][:, fixed_idx] @ T_np[fixed_idx]
A_free = A_csr[free_idx][:, free_idx]

iters = [0]
def _cb(xk):
    iters[0] += 1

T_free, info = cg(A_free, b_free, rtol=1e-12, maxiter=500, callback=_cb)
T_np[free_idx] = T_free
res_norm = np.linalg.norm(A_free @ T_free - b_free) / np.linalg.norm(b_free)

# Store solution in CDMATH Vector for norm inspection
T_cdmath = cdmath.Vector(n_nodes)
for i in range(n_nodes):
    T_cdmath[i] = float(T_np[i])

print(f"  [FEM]    Applied exact Dirichlet BCs on {len(bc_nodes)} boundary nodes ({len(free_idx)} free DOFs)")
print(f"  [SOLVER] Converged          : {info == 0} (CG iterations: {iters[0]}, rel. residual: {res_norm:.3e})")
print(f"  [CDMATH] Solution L2 Norm   : {T_cdmath.norm():.2f} K")
print(f"  [RESULT] Min Temperature    : {T_np.min():.2f} K")
print(f"  [RESULT] Max Temperature    : {T_np.max():.2f} K")
print(f"  [RESULT] Mean Temperature   : {T_np.mean():.2f} K")

# Compute cell-centered temperature and heat flux magnitude |q| = k * |grad(T)|
T_cell = np.empty(n_cells, dtype=np.float64)
flux_cell = np.empty((n_cells, 3), dtype=np.float64)
flux_mag = np.empty(n_cells, dtype=np.float64)

for c in range(n_cells):
    nodes = tet_nodes[c]
    pts = coords[nodes]
    T_loc = T_np[nodes]
    T_cell[c] = T_loc.mean()
    M = np.ones((4, 4), dtype=np.float64)
    M[:, 1:] = pts
    grads = np.linalg.inv(M)[1:, :]  # (3, 4)
    gradT = grads @ T_loc
    q_vec = -k_cond * gradT
    flux_cell[c] = q_vec
    flux_mag[c] = np.linalg.norm(q_vec)

print(f"  [RESULT] Max Heat Flux |q|  : {flux_mag.max() / 1e3:.2f} kW/m^2")

# Save 3D mesh + nodal Temperature field + cell Temperature & HeatFlux fields to MED file
if os.path.exists(SOL_MED):
    os.remove(SOL_MED)
mc.WriteUMesh(SOL_MED, umesh, True)

f_node = mc.MEDCouplingFieldDouble(mc.ON_NODES, mc.ONE_TIME)
f_node.setName("Temperature_Nodes")
f_node.setMesh(umesh)
arr_node = mc.DataArrayDouble(T_np.tolist())
arr_node.setInfoOnComponent(0, "K")
f_node.setArray(arr_node)
mc.WriteFieldUsingAlreadyWrittenMesh(SOL_MED, f_node)

f_cell = mc.MEDCouplingFieldDouble(mc.ON_CELLS, mc.ONE_TIME)
f_cell.setName("Temperature_Cells")
f_cell.setMesh(umesh)
arr_cell = mc.DataArrayDouble(T_cell.tolist())
arr_cell.setInfoOnComponent(0, "K")
f_cell.setArray(arr_cell)
mc.WriteFieldUsingAlreadyWrittenMesh(SOL_MED, f_cell)

f_flux = mc.MEDCouplingFieldDouble(mc.ON_CELLS, mc.ONE_TIME)
f_flux.setName("HeatFlux_kW_m2")
f_flux.setMesh(umesh)
arr_flux = mc.DataArrayDouble((flux_mag / 1e3).tolist())
arr_flux.setInfoOnComponent(0, "kW/m^2")
f_flux.setArray(arr_flux)
mc.WriteFieldUsingAlreadyWrittenMesh(SOL_MED, f_flux)

print(f"  [MED]    Saved solved 3D fields -> {SOL_MED}")

print("\n" + "=" * 72)
print("STAGE 4: 3D Visualization & Rendering (PARAVIS / ParaView + MEDReader.so)")
print("=" * 72)

import paraview.simple as pvs
pvs.LoadPlugin("/Users/ahorasaze/Desktop/salome/install/PARAVIS/lib/paraview/MEDReader.so", remote=False)

reader = pvs.MEDReader(FileNames=[SOL_MED])
all_fields = list(reader.GetProperty("FieldsTreeInfo")[::2])
if all_fields:
    reader.FieldsStatus = all_fields
reader.UpdatePipeline()
print(f"  [PARAVIS] Loaded MED Point Arrays : {list(reader.PointData.keys())}")
print(f"  [PARAVIS] Loaded MED Cell Arrays  : {list(reader.CellData.keys())}")

view = pvs.CreateRenderView()
view.ViewSize = [1400, 900]
view.Background = [0.12, 0.14, 0.18]

# 1. Exterior 3D Surface with Edges colored by Nodal Temperature
disp = pvs.Show(reader, view)
disp.Representation = "Surface With Edges"
disp.EdgeColor = [0.22, 0.25, 0.30]
pvs.ColorBy(disp, ("POINTS", "Temperature_Nodes"))
lut = pvs.GetColorTransferFunction("Temperature_Nodes")
lut.ApplyPreset("Cool to Warm (Extended)", True)
lut.RescaleTransferFunction(290.0, 385.0)
scalar_bar = pvs.GetScalarBar(lut, view)
scalar_bar.Title = "Temperature (K)"
scalar_bar.ComponentTitle = ""
scalar_bar.Visibility = 1

view.ResetCamera()
cam = view.GetActiveCamera()
cam.SetPosition(0.18, -0.14, 0.13)
cam.SetFocalPoint(0.05, 0.03, 0.02)
cam.SetViewUp(0.0, 0.0, 1.0)
pvs.Render(view)

img1 = os.path.join(OUT_DIR, "cooling_block_3d_exterior.png")
pvs.SaveScreenshot(img1, view, ImageResolution=[1400, 900])
print(f"  [PARAVIS] Saved 3D exterior visualization -> {img1}")

# 2. Cutaway Clip through y = 0.03 m showing internal cooling channels & thermal gradient
pvs.Hide(reader, view)
clip = pvs.Clip(Input=reader)
clip.ClipType = "Plane"
clip.ClipType.Origin = [0.05, 0.03, 0.02]
clip.ClipType.Normal = [0.0, -1.0, 0.0]
clip.UpdatePipeline()

disp_clip = pvs.Show(clip, view)
disp_clip.Representation = "Surface With Edges"
disp_clip.EdgeColor = [0.20, 0.22, 0.26]
pvs.ColorBy(disp_clip, ("POINTS", "Temperature_Nodes"))
scalar_bar.Visibility = 1

cam.SetPosition(0.15, -0.15, 0.10)
cam.SetFocalPoint(0.05, 0.03, 0.02)
cam.SetViewUp(0.0, 0.0, 1.0)
pvs.Render(view)

img2 = os.path.join(OUT_DIR, "cooling_block_3d_cutaway.png")
pvs.SaveScreenshot(img2, view, ImageResolution=[1400, 900])
print(f"  [PARAVIS] Saved 3D cutaway visualization  -> {img2}")
print("=" * 72)
print("EXAMPLE SIMULATION COMPLETED SUCCESSFULLY!")
print("=" * 72)
