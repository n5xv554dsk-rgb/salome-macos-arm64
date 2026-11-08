"""
Multiscale Variable-Horizon Bond-Based Peridynamics (BB-PD) & Dual-Horizon PD (DH-PD)
=====================================================================================
Implements variable-horizon bond-based peridynamics for graded SALOME meshes (MED / UNV):
  - Local characteristic spacing:
      * 3D: dx_i = V_i^(1/3)
      * 2D: dx_i = A_i^(1/2)
      * 1D: dx_i = L_i
  - Multiscale horizon: delta_i = m * dx_i (with default m = 3)
  - Neighbor list built with a KD-tree (scipy.spatial.cKDTree), storing each undirected
    bond (i, j) with i < j once:
      * Symmetric mode ("symmetric"): keeps a bond iff |xi| <= min(delta_i, delta_j),
        strictly excluding one-sided bonds so that families are symmetric (j in H_i <=> i in H_j).
      * Dual-Horizon mode ("dual_horizon", Ren et al. 2016/2017): keeps bonds with
        |xi| <= max(delta_i, delta_j), combining half-bond forces from active horizons H_i and H_j.
  - Symmetric micromodulus c_ij = c(delta_ij) and single-loop pairwise force assembly
    applying +f to i and -f to j in the same loop so Newton's third law holds identically.
  - Stiffness correction g_ij = 0.5 * (lambda_i + lambda_j) computed from a uniform-strain
    energy comparison, plus optional minimum-norm transition-zone ghost-force correction
    so that the uniform-strain patch test achieves zero ghost force everywhere, including
    across fine/coarse transition zones.
"""

from __future__ import annotations

import math
import os
from dataclasses import dataclass
from typing import Dict, List, Optional, Tuple, Union

import numpy as np
from scipy.sparse import csr_matrix, lil_matrix
from scipy.sparse.linalg import lsqr, spsolve
from scipy.spatial import cKDTree


@dataclass
class DeltaDistributionReport:
    """Summary statistics of nodal volumes, node spacings dx_i, and horizons delta_i."""

    mesh_path: str
    mesh_name: str
    dim: int
    n_nodes: int
    n_elements: int
    m_ratio: float
    total_measure: float
    dx_min: float
    dx_max: float
    dx_mean: float
    dx_std: float
    delta_min: float
    delta_max: float
    delta_mean: float
    delta_median: float
    delta_std: float
    delta_percentiles: Dict[int, float]
    grading_ratio: float
    hist_counts: np.ndarray
    hist_edges: np.ndarray

    def format_report(self, unit_scale: float = 1e3, unit_name: str = "mm") -> str:
        s = unit_scale
        u = unit_name
        lines = [
            "=" * 78,
            f"SALOME MESH HORIZON (delta_i = m * dx_i) DISTRIBUTION REPORT: {os.path.basename(self.mesh_path)}",
            "=" * 78,
            f"  Mesh File / Name     : {self.mesh_path} ({self.mesh_name})",
            f"  Spatial Dimension    : {self.dim}D ({self.n_nodes} nodes, {self.n_elements} elements)",
            f"  Total Domain Measure : {self.total_measure:.6e} m^{self.dim}",
            f"  Horizon Multiplier m : {self.m_ratio:g}",
            f"  Node Size dx_i       : min = {self.dx_min * s:.4f} {u}, max = {self.dx_max * s:.4f} {u}, "
            f"mean = {self.dx_mean * s:.4f} {u}, std = {self.dx_std * s:.4f} {u}",
            f"  Horizon delta_i      : min = {self.delta_min * s:.4f} {u}, max = {self.delta_max * s:.4f} {u}, "
            f"mean = {self.delta_mean * s:.4f} {u}, median = {self.delta_median * s:.4f} {u}, std = {self.delta_std * s:.4f} {u}",
            f"  Grading Ratio        : delta_max / delta_min = {self.grading_ratio:.3f}x",
            "  Percentiles (delta)  : "
            + ", ".join(f"P{p}={val * s:.4f} {u}" for p, val in self.delta_percentiles.items()),
            "  Histogram (delta_i)  :",
        ]
        max_c = max(int(self.hist_counts.max()), 1)
        for idx, count in enumerate(self.hist_counts):
            lo = self.hist_edges[idx] * s
            hi = self.hist_edges[idx + 1] * s
            bar = "#" * int(round(32 * count / max_c))
            pct = 100.0 * count / max(self.n_nodes, 1)
            lines.append(f"    [{lo:8.4f}, {hi:8.4f}] {u} : {int(count):6d} ({pct:5.1f}%) {bar}")
        lines.append("=" * 78)
        return "\n".join(lines)


# ---------------------------------------------------------------------------
# Mesh Readers for SALOME MED and UNV Exports
# ---------------------------------------------------------------------------

def _infer_dimension(coords: np.ndarray) -> int:
    """Infer spatial dimension (1, 2, or 3) from coordinate spread."""
    if coords.ndim == 1:
        return 1
    ptp = np.ptp(coords, axis=0)
    active = np.sum(ptp > 1e-12 * max(float(ptp.max()), 1e-30))
    return max(int(active), 1)


def _simplex_or_cell_measure(pts: np.ndarray, dim: int) -> float:
    """Compute element length (1D), area (2D), or volume (3D) from element vertex coordinates."""
    nv = len(pts)
    if dim == 1 or nv == 2:
        return float(np.linalg.norm(pts[-1] - pts[0]))
    if dim == 2 or nv == 3:
        if nv == 3:
            v1 = pts[1] - pts[0]
            v2 = pts[2] - pts[0]
            if pts.shape[1] == 2:
                return 0.5 * abs(float(v1[0] * v2[1] - v1[1] * v2[0]))
            return 0.5 * float(np.linalg.norm(np.cross(v1, v2)))
        if nv == 4:
            # Quad split into two triangles (0,1,2) and (0,2,3)
            return _simplex_or_cell_measure(pts[[0, 1, 2]], 2) + _simplex_or_cell_measure(pts[[0, 2, 3]], 2)
    if dim == 3:
        if nv == 4:
            M = np.ones((4, 4), dtype=np.float64)
            M[:, 1:] = pts[:, :3]
            return abs(float(np.linalg.det(M))) / 6.0
        if nv == 8:
            # Hexahedron decomposed into 5 or 6 tetrahedra via centroid
            c = pts.mean(axis=0)
            faces = [
                [0, 1, 2, 3], [4, 5, 6, 7],
                [0, 1, 5, 4], [1, 2, 6, 5],
                [2, 3, 7, 6], [3, 0, 4, 7],
            ]
            vol = 0.0
            for f in faces:
                p0, p1, p2, p3 = pts[f[0]], pts[f[1]], pts[f[2]], pts[f[3]]
                vol += _simplex_or_cell_measure(np.array([p0, p1, p2, c]), 3)
                vol += _simplex_or_cell_measure(np.array([p0, p2, p3, c]), 3)
            return vol
        if nv == 6:
            # Wedge / prism decomposed via centroid
            c = pts.mean(axis=0)
            vol = _simplex_or_cell_measure(np.array([pts[0], pts[1], pts[2], c]), 3)
            vol += _simplex_or_cell_measure(np.array([pts[3], pts[4], pts[5], c]), 3)
            quads = [[0, 1, 4, 3], [1, 2, 5, 4], [2, 0, 3, 5]]
            for q in quads:
                vol += _simplex_or_cell_measure(np.array([pts[q[0]], pts[q[1]], pts[q[2]], c]), 3)
                vol += _simplex_or_cell_measure(np.array([pts[q[0]], pts[q[2]], pts[q[3]], c]), 3)
            return vol
    # Fallback
    c = pts.mean(axis=0)
    return float(np.linalg.norm(pts - c, axis=1).mean() ** dim)


def read_med_mesh(
    med_path: str,
    mesh_name: Optional[str] = None,
    discretization: str = "nodes",
    m: float = 3.0,
    dim: Optional[int] = None,
) -> Tuple[np.ndarray, np.ndarray, np.ndarray, np.ndarray, DeltaDistributionReport]:
    """
    Read a SALOME .med mesh file and compute nodal volumes V_i, node spacings dx_i, and horizons delta_i = m * dx_i.

    Parameters
    ----------
    med_path : str
        Path to the SALOME .med file.
    mesh_name : str, optional
        Mesh name inside the MED file (defaults to the first mesh in the file).
    discretization : {"nodes", "cells"}
        "nodes": PD nodes are mesh vertices with volume lumped equally from incident elements (V_e / n_v).
        "cells": PD nodes are element centroids with volume equal to element measure V_e.
    m : float
        Horizon ratio delta_i / dx_i (default 3.0).
    dim : int, optional
        Spatial dimension (1, 2, or 3). Auto-detected from mesh if omitted.

    Returns
    -------
    coords : (N, dim) ndarray
    volumes : (N,) ndarray
    dx : (N,) ndarray
    delta : (N,) ndarray
    report : DeltaDistributionReport
    """
    if not os.path.exists(med_path):
        raise FileNotFoundError(f"MED file not found: {med_path}")

    try:
        import medcoupling as mc
    except ImportError:
        # Fallback to companion .unv file if running outside SALOME without medcoupling
        unv_fallback = os.path.splitext(med_path)[0] + ".unv"
        if os.path.exists(unv_fallback):
            coords, volumes, dx, delta, rep = read_unv_mesh(
                unv_fallback, discretization=discretization, m=m, dim=dim
            )
            rep.mesh_path = med_path
            if mesh_name is not None:
                rep.mesh_name = mesh_name
            return coords, volumes, dx, delta, rep
        raise ImportError(
            "medcoupling is not installed in this Python environment and no companion .unv file was found. "
            "Run with './salome python ...' or provide the .unv mesh export."
        )

    if mesh_name is None:
        names = mc.GetMeshNames(med_path)
        if not names:
            raise ValueError(f"No meshes found in MED file: {med_path}")
        mesh_name = names[0]

    umesh = mc.ReadUMeshFromFile(med_path, mesh_name, 0)
    mesh_dim = int(umesh.getMeshDimension())
    if dim is None:
        dim = mesh_dim

    n_cells = int(umesh.getNumberOfCells())
    cell_measures = umesh.getMeasureField(True).getArray().toNumPyArray().astype(np.float64).copy()
    cell_measures = np.abs(cell_measures)

    if discretization == "cells":
        raw_coords = umesh.computeCellCenterOfMass().toNumPyArray().reshape(n_cells, -1).astype(np.float64).copy()
        coords = raw_coords[:, :dim].copy()
        volumes = cell_measures
        n_nodes = n_cells
    elif discretization == "nodes":
        n_nodes = int(umesh.getNumberOfNodes())
        raw_coords = umesh.getCoords().toNumPyArray().reshape(n_nodes, -1).astype(np.float64).copy()
        coords = raw_coords[:, :dim].copy()
        conn = umesh.getNodalConnectivity().toNumPyArray()
        conn_idx = umesh.getNodalConnectivityIndex().toNumPyArray()
        volumes = np.zeros(n_nodes, dtype=np.float64)
        for c in range(n_cells):
            i0, i1 = int(conn_idx[c]), int(conn_idx[c + 1])
            el_nodes = conn[i0 + 1 : i1]
            volumes[el_nodes] += cell_measures[c] / len(el_nodes)
        # Handle any orphan vertices if present
        zero_mask = volumes <= 0.0
        if np.any(zero_mask) and np.any(~zero_mask):
            volumes[zero_mask] = np.median(volumes[~zero_mask])
    else:
        raise ValueError(f"Unknown discretization={discretization!r}; expected 'nodes' or 'cells'")

    dx = volumes ** (1.0 / float(dim))
    delta = float(m) * dx
    report = build_delta_report(med_path, mesh_name, dim, n_nodes, n_cells, m, volumes, dx, delta)
    return coords, volumes, dx, delta, report


def read_unv_mesh(
    unv_path: str,
    discretization: str = "nodes",
    m: float = 3.0,
    dim: Optional[int] = None,
) -> Tuple[np.ndarray, np.ndarray, np.ndarray, np.ndarray, DeltaDistributionReport]:
    """
    Read a SALOME .unv (I-DEAS Universal) mesh file (datasets 2411 and 2412) and compute
    nodal volumes V_i, node spacings dx_i, and horizons delta_i = m * dx_i.
    """
    if not os.path.exists(unv_path):
        raise FileNotFoundError(f"UNV file not found: {unv_path}")

    with open(unv_path, "r", encoding="utf-8", errors="replace") as f:
        lines = [line.strip() for line in f]

    n_lines = len(lines)
    idx = 0
    node_ids: List[int] = []
    node_xyz: List[List[float]] = []

    # Elements grouped by dimension: 1D (rod/beam), 2D (tria/quad), 3D (tet/wedge/hex/pyr)
    elems_by_dim: Dict[int, List[List[int]]] = {1: [], 2: [], 3: []}

    # FE descriptor classification (I-DEAS / SALOME UNV standard):
    fe_1d = {11, 21, 22, 23, 24, 25, 29, 31, 32}
    fe_2d = {41, 42, 43, 44, 45, 46, 51, 52, 53, 54, 55, 56, 61, 62, 63, 64, 65, 66, 71, 72, 73, 74, 75, 76, 81, 82, 91, 92, 93, 94, 95, 96}
    fe_3d = {111, 112, 113, 114, 115, 116, 117, 118, 121, 122}
    beam_fe = {11, 21, 22, 23, 24}

    while idx < n_lines:
        if lines[idx] == "-1" and idx + 1 < n_lines:
            block_id = lines[idx + 1]
            idx += 2
            if block_id == "2411":
                while idx < n_lines and lines[idx] != "-1":
                    header = lines[idx].split()
                    nid = int(header[0])
                    coords_line = lines[idx + 1].replace("D", "E").replace("d", "e").split()
                    xyz = [float(c) for c in coords_line[:3]]
                    node_ids.append(nid)
                    node_xyz.append(xyz)
                    idx += 2
                idx += 1  # skip closing -1
            elif block_id == "2412":
                while idx < n_lines and lines[idx] != "-1":
                    parts = [int(x) for x in lines[idx].split()]
                    _el_id, fe_id, _phys, _mat, _col, n_nodes_el = parts[:6]
                    idx += 1
                    if fe_id in beam_fe:
                        idx += 1  # skip beam orientation record
                    el_conn: List[int] = []
                    while len(el_conn) < n_nodes_el and idx < n_lines:
                        el_conn.extend(int(x) for x in lines[idx].split())
                        idx += 1
                    if fe_id in fe_3d:
                        elems_by_dim[3].append(el_conn)
                    elif fe_id in fe_2d:
                        elems_by_dim[2].append(el_conn)
                    elif fe_id in fe_1d:
                        elems_by_dim[1].append(el_conn)
                    else:
                        if n_nodes_el >= 4:
                            elems_by_dim[3].append(el_conn)
                        elif n_nodes_el == 3:
                            elems_by_dim[2].append(el_conn)
                        else:
                            elems_by_dim[1].append(el_conn)
                idx += 1  # skip closing -1
            else:
                while idx < n_lines and lines[idx] != "-1":
                    idx += 1
                idx += 1
        else:
            idx += 1

    if not node_ids:
        raise ValueError(f"No nodes (dataset 2411) found in UNV file: {unv_path}")

    raw_coords = np.array(node_xyz, dtype=np.float64)
    nid_to_idx = {nid: i for i, nid in enumerate(node_ids)}

    # Highest-dimensional elements present define the domain measure
    if elems_by_dim[3]:
        mesh_dim = 3
        active_elems = elems_by_dim[3]
    elif elems_by_dim[2]:
        mesh_dim = 2
        active_elems = elems_by_dim[2]
    elif elems_by_dim[1]:
        mesh_dim = 1
        active_elems = elems_by_dim[1]
    else:
        raise ValueError(f"No elements (dataset 2412) found in UNV file: {unv_path}")

    if dim is None:
        dim = mesh_dim

    n_cells = len(active_elems)
    cell_measures = np.empty(n_cells, dtype=np.float64)
    cell_centers = np.empty((n_cells, dim), dtype=np.float64)
    mapped_elems: List[np.ndarray] = []

    for c, el_nids in enumerate(active_elems):
        el_idx = np.array([nid_to_idx[nid] for nid in el_nids], dtype=np.int64)
        mapped_elems.append(el_idx)
        pts = raw_coords[el_idx]
        cell_measures[c] = _simplex_or_cell_measure(pts, mesh_dim)
        cell_centers[c] = pts[:, :dim].mean(axis=0)

    if discretization == "cells":
        coords = cell_centers
        volumes = cell_measures
        n_nodes = n_cells
    elif discretization == "nodes":
        n_nodes = len(node_ids)
        coords = raw_coords[:, :dim].copy()
        volumes = np.zeros(n_nodes, dtype=np.float64)
        for c, el_idx in enumerate(mapped_elems):
            volumes[el_idx] += cell_measures[c] / len(el_idx)
        zero_mask = volumes <= 0.0
        if np.any(zero_mask) and np.any(~zero_mask):
            volumes[zero_mask] = np.median(volumes[~zero_mask])
    else:
        raise ValueError(f"Unknown discretization={discretization!r}; expected 'nodes' or 'cells'")

    dx = volumes ** (1.0 / float(dim))
    delta = float(m) * dx
    mesh_name = os.path.splitext(os.path.basename(unv_path))[0]
    report = build_delta_report(unv_path, mesh_name, dim, n_nodes, n_cells, m, volumes, dx, delta)
    return coords, volumes, dx, delta, report


def read_salome_mesh(
    mesh_path: str,
    mesh_name: Optional[str] = None,
    discretization: str = "nodes",
    m: float = 3.0,
    dim: Optional[int] = None,
) -> Tuple[np.ndarray, np.ndarray, np.ndarray, np.ndarray, DeltaDistributionReport]:
    """Dispatch reader for SALOME .med or .unv mesh files."""
    ext = os.path.splitext(mesh_path)[1].lower()
    if ext == ".med":
        return read_med_mesh(mesh_path, mesh_name=mesh_name, discretization=discretization, m=m, dim=dim)
    if ext == ".unv":
        return read_unv_mesh(mesh_path, discretization=discretization, m=m, dim=dim)
    raise ValueError(f"Unsupported mesh extension {ext!r} for {mesh_path}; expected '.med' or '.unv'")


def build_delta_report(
    mesh_path: str,
    mesh_name: str,
    dim: int,
    n_nodes: int,
    n_elements: int,
    m: float,
    volumes: np.ndarray,
    dx: np.ndarray,
    delta: np.ndarray,
    bins: int = 8,
) -> DeltaDistributionReport:
    """Compute distribution statistics and histogram for dx_i and delta_i = m * dx_i."""
    pct_keys = [5, 25, 50, 75, 95]
    pct_vals = np.percentile(delta, pct_keys)
    percentiles = {k: float(v) for k, v in zip(pct_keys, pct_vals)}
    hist_counts, hist_edges = np.histogram(delta, bins=bins)
    return DeltaDistributionReport(
        mesh_path=mesh_path,
        mesh_name=mesh_name,
        dim=int(dim),
        n_nodes=int(n_nodes),
        n_elements=int(n_elements),
        m_ratio=float(m),
        total_measure=float(volumes.sum()),
        dx_min=float(dx.min()),
        dx_max=float(dx.max()),
        dx_mean=float(dx.mean()),
        dx_std=float(dx.std()),
        delta_min=float(delta.min()),
        delta_max=float(delta.max()),
        delta_mean=float(delta.mean()),
        delta_median=float(np.median(delta)),
        delta_std=float(delta.std()),
        delta_percentiles=percentiles,
        grading_ratio=float(delta.max() / max(float(delta.min()), 1e-30)),
        hist_counts=hist_counts,
        hist_edges=hist_edges,
    )


# ---------------------------------------------------------------------------
# Multiscale Variable-Horizon Bond-Based Peridynamics & Dual-Horizon PD
# ---------------------------------------------------------------------------

def canonical_micromodulus(delta: Union[float, np.ndarray], E: float, dim: int, plane_stress: bool = True) -> Union[float, np.ndarray]:
    """
    Canonical Bond-Based Peridynamics micromodulus c(delta):
      - 1D: c(delta) = 2 * E / delta^2
      - 2D: c(delta) = 9 * E / (pi * delta^3)          [plane stress, nu = 1/3]
            c(delta) = 48 * E / (5 * pi * delta^3)     [plane strain, nu = 1/4]
      - 3D: c(delta) = 12 * E / (pi * delta^4)         [3D, nu = 1/4]
    """
    if dim == 1:
        return 2.0 * E / (delta ** 2)
    if dim == 2:
        if plane_stress:
            return 9.0 * E / (math.pi * (delta ** 3))
        return 48.0 * E / (5.0 * math.pi * (delta ** 3))
    if dim == 3:
        return 12.0 * E / (math.pi * (delta ** 4))
    raise ValueError(f"Unsupported spatial dimension dim={dim}")


def continuum_isotropic_energy_density(E: float, dim: int, eps0: float = 1.0, plane_stress: bool = True) -> float:
    """
    Continuum elastic strain energy density W^cont under uniform isotropic strain eps_ab = eps0 * delta_ab:
      - 1D: W = (1/2) * E * eps0^2
      - 2D: W = (3/2) * E * eps0^2  [plane stress, nu = 1/3]
            W = (8/5) * E * eps0^2  [plane strain, nu = 1/4]
      - 3D: W = (3/2) * E * eps0^2  [3D, nu = 1/4, K = 2E/3, W = (9/2) K eps0^2]
    """
    if dim == 1:
        return 0.5 * E * (eps0 ** 2)
    if dim == 2:
        return (1.5 if plane_stress else 1.6) * E * (eps0 ** 2)
    if dim == 3:
        return 1.5 * E * (eps0 ** 2)
    raise ValueError(f"Unsupported spatial dimension dim={dim}")


class MultiscaleBondPD:
    """
    Multiscale Variable-Horizon Bond-Based Peridynamics Solver.

    Features:
      1. Variable horizon delta_i = m * dx_i with dx_i = V_i^(1/dim) (m = 3 by default).
      2. KD-tree neighbor search storing each undirected bond (i, j) with i < j once.
      3. Symmetric family condition |xi| <= min(delta_i, delta_j) in "symmetric" mode,
         excluding all one-sided bonds so that j in H_i <=> i in H_j.
      4. Symmetric micromodulus c_ij = c(delta_ij) and single-loop force accumulation
         applying +f_ij to node i and -f_ij to node j in the same loop (exact Newton's 3rd law).
      5. Stiffness correction g_ij = 0.5 * (lambda_i + lambda_j) computed from uniform-strain
         energy comparison, plus optional transition-zone ghost-force elimination.
      6. Optional Dual-Horizon PD mode ("dual_horizon") for comparison.
    """

    def __init__(
        self,
        coords: np.ndarray,
        volumes: np.ndarray,
        E: float,
        rho: float = 1.0,
        m: float = 3.0,
        dim: Optional[int] = None,
        mode: str = "symmetric",
        horizon_rule: str = "min",
        stiffness_correction: bool = True,
        ghost_force_correction: bool = True,
        plane_stress: bool = True,
        interior_mask: Optional[np.ndarray] = None,
        domain_bounds: Optional[Tuple[np.ndarray, np.ndarray]] = None,
    ):
        raw_coords = np.asarray(coords, dtype=np.float64)
        if raw_coords.ndim == 1:
            raw_coords = raw_coords[:, None]
        self.volumes = np.asarray(volumes, dtype=np.float64).ravel()
        self.n_nodes = len(self.volumes)
        if dim is None:
            dim = raw_coords.shape[1] if raw_coords.shape[1] <= 3 else _infer_dimension(raw_coords)
        self.dim = int(dim)
        self.coords = np.ascontiguousarray(raw_coords[:, : self.dim], dtype=np.float64)

        self.E = float(E)
        self.rho = float(rho)
        self.m = float(m)
        self.mode = mode
        self.horizon_rule = horizon_rule
        self.stiffness_correction = bool(stiffness_correction)
        self.ghost_force_correction = bool(ghost_force_correction)
        self.plane_stress = bool(plane_stress)

        # Node size dx_i = V_i^(1/dim) and multiscale horizon delta_i = m * dx_i
        self.dx = self.volumes ** (1.0 / float(self.dim))
        self.delta = self.m * self.dx

        # Domain bounding box for automatic interior-node detection in patch tests / ghost-force projection
        if domain_bounds is not None:
            self.bbox_min = np.asarray(domain_bounds[0], dtype=np.float64)
            self.bbox_max = np.asarray(domain_bounds[1], dtype=np.float64)
        else:
            # Estimate domain bounds incorporating half-cell padding at boundary nodes
            min_idx = np.argmin(self.coords, axis=0)
            max_idx = np.argmax(self.coords, axis=0)
            self.bbox_min = np.array([self.coords[min_idx[d], d] - 0.5 * self.dx[min_idx[d]] for d in range(self.dim)])
            self.bbox_max = np.array([self.coords[max_idx[d], d] + 0.5 * self.dx[max_idx[d]] for d in range(self.dim)])

        if interior_mask is not None:
            self.interior_mask = np.asarray(interior_mask, dtype=bool)
        else:
            tol = 1e-10 * np.maximum(self.bbox_max - self.bbox_min, 1.0)
            in_lo = np.all(self.coords - self.delta[:, None] >= self.bbox_min[None, :] - tol[None, :], axis=1)
            in_hi = np.all(self.coords + self.delta[:, None] <= self.bbox_max[None, :] + tol[None, :], axis=1)
            self.interior_mask = in_lo & in_hi

        # Build neighbor list and bond properties
        self._build_bonds_kdtree()
        self._compute_micromodulus_and_correction()

    def _build_bonds_kdtree(self) -> None:
        """
        Build the neighbor list using a KD-tree, storing each bond once (i < j).
        In 'symmetric' mode: keep a bond iff |xi| <= min(delta_i, delta_j).
        Bonds visible from only one side (min(delta_i, delta_j) < |xi| <= max(delta_i, delta_j))
        are strictly excluded.
        """
        self.kdtree = cKDTree(self.coords)
        rtol = 1.0 + 1e-12

        # Query KD-tree per node with radius delta_i
        candidates = self.kdtree.query_ball_point(self.coords, r=self.delta * rtol)

        sym_i: List[int] = []
        sym_j: List[int] = []
        one_sided_pairs: Dict[Tuple[int, int], int] = {}

        for i, nbrs in enumerate(candidates):
            di = self.delta[i]
            xi_i = self.coords[i]
            for j in nbrs:
                if j == i:
                    continue
                dj = self.delta[j]
                dist = float(np.linalg.norm(self.coords[j] - xi_i))
                d_min = di if di < dj else dj
                if dist <= d_min * rtol:
                    if i < j:
                        sym_i.append(i)
                        sym_j.append(j)
                elif dist <= di * rtol:
                    # Visible from i (|xi| <= delta_i) but NOT from j (|xi| > delta_j)
                    pair = (i, j) if i < j else (j, i)
                    one_sided_pairs[pair] = i  # i is the node with the larger horizon

        self.excluded_one_sided_count = len(one_sided_pairs)

        if self.mode == "symmetric":
            self.bond_i = np.array(sym_i, dtype=np.int64)
            self.bond_j = np.array(sym_j, dtype=np.int64)
            self.bond_is_mutual = np.ones(len(self.bond_i), dtype=bool)
        elif self.mode == "dual_horizon":
            # In Dual-Horizon PD, mutual bonds have both horizons active, and one-sided bonds
            # have only the larger horizon active (acting on the smaller-horizon node via its dual horizon H'_j).
            all_i = list(sym_i)
            all_j = list(sym_j)
            is_mut = [True] * len(sym_i)
            for (u, v) in sorted(one_sided_pairs.keys()):
                all_i.append(u)
                all_j.append(v)
                is_mut.append(False)
            self.bond_i = np.array(all_i, dtype=np.int64)
            self.bond_j = np.array(all_j, dtype=np.int64)
            self.bond_is_mutual = np.array(is_mut, dtype=bool)
        else:
            raise ValueError(f"Unknown mode={self.mode!r}; expected 'symmetric' or 'dual_horizon'")

        self.n_bonds = len(self.bond_i)
        self.xi_vec = self.coords[self.bond_j] - self.coords[self.bond_i]
        self.xi_len = np.linalg.norm(self.xi_vec, axis=1)
        self.unit_xi = self.xi_vec / self.xi_len[:, None]
        self.broken = np.zeros(self.n_bonds, dtype=bool)

        # Degree / family size per node
        self.family_size = np.zeros(self.n_nodes, dtype=np.int64)
        np.add.at(self.family_size, self.bond_i, 1)
        np.add.at(self.family_size, self.bond_j, 1)

    def _compute_micromodulus_and_correction(self) -> None:
        """
        Compute symmetric micromodulus c_ij = c(delta_ij) and stiffness correction
        g_ij = 0.5 * (lambda_i + lambda_j) from a uniform-strain energy comparison.
        """
        di = self.delta[self.bond_i]
        dj = self.delta[self.bond_j]

        if self.mode == "dual_horizon":
            # Dual-Horizon PD (Ren et al. 2016/2017):
            # Each active horizon H_i (|xi| <= delta_i) contributes 0.5 * c(delta_i),
            # and H_j (|xi| <= delta_j) contributes 0.5 * c(delta_j).
            rtol = 1.0 + 1e-12
            ci = canonical_micromodulus(di, self.E, self.dim, self.plane_stress)
            cj = canonical_micromodulus(dj, self.E, self.dim, self.plane_stress)
            in_i = (self.xi_len <= di * rtol).astype(np.float64)
            in_j = (self.xi_len <= dj * rtol).astype(np.float64)
            self.delta_ij = 0.5 * (di + dj)
            self.c_ij = 0.5 * (ci * in_i + cj * in_j)
        else:
            if self.horizon_rule == "min":
                self.delta_ij = np.minimum(di, dj)
            elif self.horizon_rule in ("mean", "avg"):
                self.delta_ij = 0.5 * (di + dj)
            else:
                raise ValueError(f"Unknown horizon_rule={self.horizon_rule!r}; expected 'min' or 'mean'")
            self.c_ij = canonical_micromodulus(self.delta_ij, self.E, self.dim, self.plane_stress)

        # Uniform-strain energy comparison under isotropic strain eps_ab = eps0 * delta_ab (eps0 = 1 -> s_ij = 1):
        # Discrete strain energy density at node i (before correction):
        #   W_i^(0) = (1/4) * sum_{j in H_i} c_ij * |xi_ij| * V_j
        Vi = self.volumes[self.bond_i]
        Vj = self.volumes[self.bond_j]
        W_i_discrete = np.zeros(self.n_nodes, dtype=np.float64)
        np.add.at(W_i_discrete, self.bond_i, 0.25 * self.c_ij * self.xi_len * Vj)
        np.add.at(self.W_i_discrete if hasattr(self, "W_i_discrete") else W_i_discrete, self.bond_j, 0.25 * self.c_ij * self.xi_len * Vi)
        self.W_i_uncorrected = W_i_discrete

        W_cont = continuum_isotropic_energy_density(self.E, self.dim, eps0=1.0, plane_stress=self.plane_stress)
        self.W_continuum = W_cont

        if self.stiffness_correction:
            self.lambda_node = np.where(W_i_discrete > 1e-30, W_cont / W_i_discrete, 1.0)
            self.g_ij_baseline = 0.5 * (self.lambda_node[self.bond_i] + self.lambda_node[self.bond_j])
        else:
            self.lambda_node = np.ones(self.n_nodes, dtype=np.float64)
            self.g_ij_baseline = np.ones(self.n_bonds, dtype=np.float64)

        self.g_ij = self.g_ij_baseline.copy()

        if self.stiffness_correction and self.ghost_force_correction and np.any(self.interior_mask):
            self._apply_ghost_force_correction()

    def _cubic_direction_moments(self) -> np.ndarray:
        """
        Compute the independent degree-3 monomials of bond unit vectors n = xi / |xi|.
        Vanishing of sum_{j in H_i} g_ij * c_ij * (n_a * n_b * n_c) * V_j = 0 at interior node i
        guarantees identically zero ghost force under ANY uniform strain tensor eps!
        """
        if self.dim == 1:
            return self.unit_xi[:, 0:1] ** 3
        if self.dim == 2:
            nx, ny = self.unit_xi[:, 0], self.unit_xi[:, 1]
            return np.column_stack([nx ** 3, (nx ** 2) * ny, nx * (ny ** 2), ny ** 3])
        if self.dim == 3:
            nx, ny, nz = self.unit_xi[:, 0], self.unit_xi[:, 1], self.unit_xi[:, 2]
            return np.column_stack([
                nx ** 3, ny ** 3, nz ** 3,
                (nx ** 2) * ny, (nx ** 2) * nz,
                (ny ** 2) * nx, (ny ** 2) * nz,
                (nz ** 2) * nx, (nz ** 2) * ny,
                nx * ny * nz,
            ])
        raise ValueError(f"Unsupported dim={self.dim}")

    def _apply_ghost_force_correction(self) -> None:
        """
        Project g_ij = g_ij_baseline + dg_ij (minimum L2-norm adjustment) so that all interior
        nodes (including nodes in the fine/coarse transition zone) have identically zero ghost
        force under any uniform strain tensor.
        """
        interior_nodes = np.where(self.interior_mask)[0]
        n_int = len(interior_nodes)
        if n_int == 0 or self.n_bonds == 0:
            return

        moments = self._cubic_direction_moments()
        n_mom = moments.shape[1]
        row_map = np.full(self.n_nodes, -1, dtype=np.int64)
        row_map[interior_nodes] = np.arange(n_int, dtype=np.int64)

        ri = row_map[self.bond_i]
        rj = row_map[self.bond_j]
        Vi = self.volumes[self.bond_i]
        Vj = self.volumes[self.bond_j]

        # Build sparse constraint matrix A of shape (n_int * n_mom, n_bonds)
        rows_list: List[np.ndarray] = []
        cols_list: List[np.ndarray] = []
        vals_list: List[np.ndarray] = []

        mask_i = ri >= 0
        if np.any(mask_i):
            b_idx_i = np.where(mask_i)[0]
            base_r_i = ri[mask_i] * n_mom
            for k in range(n_mom):
                rows_list.append(base_r_i + k)
                cols_list.append(b_idx_i)
                vals_list.append(+self.c_ij[b_idx_i] * moments[b_idx_i, k] * Vj[b_idx_i])

        mask_j = rj >= 0
        if np.any(mask_j):
            b_idx_j = np.where(mask_j)[0]
            base_r_j = rj[mask_j] * n_mom
            for k in range(n_mom):
                rows_list.append(base_r_j + k)
                cols_list.append(b_idx_j)
                vals_list.append(-self.c_ij[b_idx_j] * moments[b_idx_j, k] * Vi[b_idx_j])

        if not rows_list:
            return

        rows = np.concatenate(rows_list)
        cols = np.concatenate(cols_list)
        vals = np.concatenate(vals_list)
        A_csr = csr_matrix((vals, (rows, cols)), shape=(n_int * n_mom, self.n_bonds))

        residual = -(A_csr @ self.g_ij_baseline)
        if np.linalg.norm(residual) <= 1e-14 * max(float(np.linalg.norm(A_csr.data)), 1.0):
            return

        dg = lsqr(A_csr, residual, atol=1e-15, btol=1e-15, iter_lim=4000)[0]
        self.g_ij = self.g_ij_baseline + dg

    # -----------------------------------------------------------------------
    # Force Evaluation (Single Loop over Bonds -> Exact Newton's Third Law)
    # -----------------------------------------------------------------------

    def compute_forces(
        self,
        u: np.ndarray,
        linearized: bool = True,
    ) -> Tuple[np.ndarray, np.ndarray]:
        """
        Compute internal nodal forces F_i [N] and force densities f_i = F_i / V_i [N/m^dim]
        in a SINGLE loop over stored undirected bonds b = (i, j), applying +F_ij to i
        and -F_ij to j so Newton's third law holds identically (sum_i F_i = 0).

        Parameters
        ----------
        u : (N, dim) or (N,) ndarray
            Nodal displacement field.
        linearized : bool
            If True, use small-strain linearized bond stretch s_ij = (xi . du) / |xi|^2
            along unit_xi. If False, use exact nonlinear kinematics
            s_ij = (|xi + du| - |xi|) / |xi| along (xi + du) / |xi + du|.

        Returns
        -------
        F_total : (N, dim) ndarray
            Volume-integrated internal nodal force vector F_i = f_i * V_i.
        f_density : (N, dim) ndarray
            Internal force density f_i = F_i / V_i.
        """
        u_arr = np.asarray(u, dtype=np.float64).reshape(self.n_nodes, self.dim)
        F_total = np.zeros((self.n_nodes, self.dim), dtype=np.float64)

        active = ~self.broken
        bi = self.bond_i[active]
        bj = self.bond_j[active]
        xi_v = self.xi_vec[active]
        xi_l = self.xi_len[active]
        u_xi = self.unit_xi[active]
        g_c = self.g_ij[active] * self.c_ij[active]
        Vi = self.volumes[bi]
        Vj = self.volumes[bj]

        du = u_arr[bj] - u_arr[bi]
        if linearized:
            s_ij = np.sum(u_xi * du, axis=1) / xi_l
            dir_vec = u_xi
        else:
            deformed = xi_v + du
            def_len = np.linalg.norm(deformed, axis=1)
            s_ij = (def_len - xi_l) / xi_l
            dir_vec = deformed / np.maximum(def_len[:, None], 1e-30)

        # Pairwise force F_ij = g_ij * c_ij * s_ij * V_i * V_j * dir_vec
        F_bond = (g_c * s_ij * Vi * Vj)[:, None] * dir_vec

        # Single loop over bonds: +F_bond to i, -F_bond to j (deterministic sequential loop
        # or np.add.at so that +F_ij and -F_ij cancel to exact floating-point precision)
        for b_idx in range(len(bi)):
            i = bi[b_idx]
            j = bj[b_idx]
            fb = F_bond[b_idx]
            F_total[i] += fb
            F_total[j] -= fb

        f_density = F_total / self.volumes[:, None]
        return F_total, f_density

    # -----------------------------------------------------------------------
    # Global Tangent Stiffness Assembly & Static Patch-Test / BVP Solver
    # -----------------------------------------------------------------------

    def assemble_stiffness(self) -> csr_matrix:
        """
        Assemble the global symmetric tangent stiffness matrix K (n_dofs x n_dofs)
        in a single loop over undirected bonds b = (i, j):
            k_bond = (g_ij * c_ij * V_i * V_j / |xi_ij|) * (n_ij (x) n_ij)
        """
        d = self.dim
        n_dofs = self.n_nodes * d
        K = lil_matrix((n_dofs, n_dofs), dtype=np.float64)

        for b_idx in range(self.n_bonds):
            if self.broken[b_idx]:
                continue
            i = int(self.bond_i[b_idx])
            j = int(self.bond_j[b_idx])
            n_v = self.unit_xi[b_idx]
            coeff = float(self.g_ij[b_idx] * self.c_ij[b_idx] * self.volumes[i] * self.volumes[j] / self.xi_len[b_idx])
            k_loc = coeff * np.outer(n_v, n_v)

            dofs_i = [d * i + a for a in range(d)]
            dofs_j = [d * j + a for a in range(d)]
            for r in range(d):
                di_r = dofs_i[r]
                dj_r = dofs_j[r]
                row_vals = k_loc[r].tolist()
                neg_vals = (-k_loc[r]).tolist()
                # +k_loc on (i, i) and (j, j); -k_loc on (i, j) and (j, i)
                K.rows[di_r].extend(dofs_i + dofs_j)
                K.data[di_r].extend(row_vals + neg_vals)
                K.rows[dj_r].extend(dofs_j + dofs_i)
                K.data[dj_r].extend(row_vals + neg_vals)

        return K.tocsr()

    def solve_static(
        self,
        prescribed_dofs: Dict[int, float],
        ext_force: Optional[np.ndarray] = None,
    ) -> Tuple[np.ndarray, float]:
        """
        Solve K * u = F_ext with Dirichlet boundary conditions prescribed_dofs (dof_index -> value).
        Returns (u_field of shape (N, dim), relative_residual).
        """
        K_csr = self.assemble_stiffness()
        n_dofs = self.n_nodes * self.dim
        free_mask = np.ones(n_dofs, dtype=bool)
        u_full = np.zeros(n_dofs, dtype=np.float64)
        for dof_id, val in prescribed_dofs.items():
            free_mask[int(dof_id)] = False
            u_full[int(dof_id)] = float(val)

        free_idx = np.where(free_mask)[0]
        fixed_idx = np.where(~free_mask)[0]
        rhs = np.zeros(len(free_idx), dtype=np.float64)
        if ext_force is not None:
            rhs += np.asarray(ext_force, dtype=np.float64).ravel()[free_idx]
        if len(fixed_idx) > 0:
            rhs -= K_csr[free_idx][:, fixed_idx] @ u_full[fixed_idx]

        K_free = K_csr[free_idx][:, free_idx]
        u_free = spsolve(K_free, rhs)
        u_full[free_idx] = u_free
        res_norm = float(np.linalg.norm(K_free @ u_free - rhs))
        rhs_norm = max(float(np.linalg.norm(rhs)), 1e-30)
        return u_full.reshape(self.n_nodes, self.dim), res_norm / rhs_norm

    # -----------------------------------------------------------------------
    # Explicit Velocity-Verlet Dynamic Time Integrator
    # -----------------------------------------------------------------------

    def run_dynamic(
        self,
        u0: np.ndarray,
        v0: np.ndarray,
        dt: float,
        n_steps: int,
        fixed_dofs: Optional[np.ndarray] = None,
        ext_force_fn=None,
        linearized: bool = True,
        record_every: int = 0,
    ) -> Dict[str, np.ndarray]:
        """
        Explicit Velocity-Verlet time integration using the fast vectorized single-pass bond loop.
        """
        u = np.asarray(u0, dtype=np.float64).reshape(self.n_nodes, self.dim).copy()
        v = np.asarray(v0, dtype=np.float64).reshape(self.n_nodes, self.dim).copy()
        mass = self.rho * self.volumes[:, None]

        active = ~self.broken
        bi = self.bond_i[active]
        bj = self.bond_j[active]
        xi_l = self.xi_len[active]
        u_xi = self.unit_xi[active]
        stiff_b = self.g_ij[active] * self.c_ij[active] * self.volumes[bi] * self.volumes[bj]

        def compute_accel(u_cur: np.ndarray, t_cur: float) -> np.ndarray:
            du = u_cur[bj] - u_cur[bi]
            s_ij = np.sum(u_xi * du, axis=1) / xi_l
            f_b = (stiff_b * s_ij)[:, None] * u_xi
            F = np.zeros_like(u_cur)
            np.add.at(F, bi, f_b)
            np.add.at(F, bj, -f_b)
            if ext_force_fn is not None:
                F += ext_force_fn(t_cur, u_cur)
            acc = F / mass
            if fixed_dofs is not None:
                acc.ravel()[fixed_dofs] = 0.0
            return acc

        a = compute_accel(u, 0.0)
        history_t = [0.0]
        history_u = [u.copy()]
        history_v = [v.copy()]

        for step in range(1, int(n_steps) + 1):
            t = step * dt
            u_next = u + dt * v + 0.5 * (dt * dt) * a
            if fixed_dofs is not None:
                u_next.ravel()[fixed_dofs] = u.ravel()[fixed_dofs]
            a_next = compute_accel(u_next, t)
            v_next = v + 0.5 * dt * (a + a_next)
            if fixed_dofs is not None:
                v_next.ravel()[fixed_dofs] = 0.0
            u, v, a = u_next, v_next, a_next
            if record_every > 0 and (step % record_every == 0 or step == n_steps):
                history_t.append(t)
                history_u.append(u.copy())
                history_v.append(v.copy())

        # Compute final kinetic and elastic potential energy
        du = u[bj] - u[bi]
        s_ij = np.sum(u_xi * du, axis=1) / xi_l
        U_pot = float(np.sum(0.5 * stiff_b * xi_l * (s_ij ** 2)))
        K_kin = float(np.sum(0.5 * mass * (v ** 2)))

        return {
            "u": u,
            "v": v,
            "a": a,
            "U_pot": U_pot,
            "K_kin": K_kin,
            "E_tot": U_pot + K_kin,
            "history_t": np.array(history_t),
            "history_u": np.array(history_u),
            "history_v": np.array(history_v),
        }
