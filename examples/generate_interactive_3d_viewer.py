#!/usr/bin/env python3
"""
Generate a User-Friendly 3D + 2D + 1D Visual Peridynamics Explorer (.html)
==========================================================================
Creates `examples/interactive_3d_bonds_and_nodes.html` with THREE intuitive visual tabs:

  - Tab 1 (Default): 3D Wave, Deforming Lattice & Problem Microscope (Rotatable & Zoomable 3D)
      * Shows the 3D Graded Crystal Lattice (Fine 3D cubes on left, Coarse 3D cubes on right)
        with visible 3D bonds and physical 3D wave deformation (3D wave crest + 3D bond compression).
      * Shows BOTH the Problem (Uncorrected 3D PD: 31.8% Spurious 3D Reflected Wave & 3D Ghost-Force
        Vectors) and the Solution (Our Multiscale Ghost-Free 3D PD: Clean 3D Wave Transmission &
        Zero Ghost Force) either Side-by-Side in 3D or in Single-Block 3D Closeup!
      * Scroll the mouse wheel to zoom right into any 3D node to inspect its 3D Horizon Sphere
        (delta_i = 3 * dx_i), 3D Kept Symmetric Bonds, 3D Excluded One-Sided Bonds, and 3D Force Arrows.

  - Tab 2: 2D Interactive Bond, Horizon Circle & Force-Balance Microscope
      * Clean 2D lattice view where hovering any node shows its Horizon Circle delta_i and
        exact Left Pull vs. Right Pull -> Net Ghost Force arrows.

  - Tab 3: 1D Side-by-Side Wave & Moving Spring-Lattice Comparison

Usage:
    ./salome python examples/generate_interactive_3d_viewer.py
    open examples/interactive_3d_bonds_and_nodes.html
"""

import json
import os
import sys
import numpy as np
from scipy.sparse import csr_matrix
from scipy.sparse.linalg import lsqr

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, ".."))
sys.path.insert(0, os.path.join(ROOT, "pd_dynamic"))
sys.path.insert(0, ROOT)

from pdsalome.multiscale import MultiscaleBondPD  # noqa: E402
from tests.test_multiscale_pd import (  # noqa: E402
    make_1d_graded_bar,
    make_2d_graded_plate,
    make_3d_graded_block,
)


def _apply_3d_wave_and_ghost_correction(pd: MultiscaleBondPD):
    x = pd.coords[:, 0]
    x_int = np.where((x >= pd.delta) & (x <= 1.0 - pd.delta))[0]
    n_int = len(x_int)
    nx, ny, nz = pd.unit_xi[:, 0], pd.unit_xi[:, 1], pd.unit_xi[:, 2]
    row_map = np.full(pd.n_nodes, -1, dtype=np.int64)
    row_map[x_int] = np.arange(n_int, dtype=np.int64)
    ri, rj = row_map[pd.bond_i], row_map[pd.bond_j]
    Vi, Vj = pd.volumes[pd.bond_i], pd.volumes[pd.bond_j]

    n_mom = 4
    rows_l, cols_l, vals_l = [], [], []
    rhs = np.zeros(n_int * n_mom, dtype=np.float64)
    target_c11 = 2.4 * pd.E
    for b_idx in range(pd.n_bonds):
        for r_node, sgn, V_nbr in ((ri[b_idx], +1.0, Vj[b_idx]), (rj[b_idx], -1.0, Vi[b_idx])):
            if r_node >= 0:
                base = r_node * n_mom
                rows_l.append(base + 0); cols_l.append(b_idx); vals_l.append(sgn * pd.c_ij[b_idx] * (nx[b_idx] ** 3) * V_nbr)
                rows_l.append(base + 1); cols_l.append(b_idx); vals_l.append(sgn * pd.c_ij[b_idx] * (nx[b_idx] * (ny[b_idx] ** 2)) * V_nbr)
                rows_l.append(base + 2); cols_l.append(b_idx); vals_l.append(sgn * pd.c_ij[b_idx] * (nx[b_idx] * (nz[b_idx] ** 2)) * V_nbr)
                rows_l.append(base + 3); cols_l.append(b_idx); vals_l.append(pd.c_ij[b_idx] * pd.xi_len[b_idx] * (nx[b_idx] ** 4) * V_nbr)
                rhs[base + 3] = target_c11

    A = csr_matrix((vals_l, (rows_l, cols_l)), shape=(n_int * n_mom, pd.n_bonds))
    dg = lsqr(A, rhs - (A @ pd.g_ij_baseline), atol=1e-14, btol=1e-14, iter_lim=4000)[0]
    pd.g_ij = pd.g_ij_baseline + dg


def _compute_left_right_forces(pd_uncorr: MultiscaleBondPD, pd_corr: MultiscaleBondPD, u_unif: np.ndarray):
    """Compute Left-pull vs Right-pull axial force density on each node under uniform strain."""
    n = pd_corr.n_nodes
    fl_u, fr_u = np.zeros(n), np.zeros(n)
    fl_c, fr_c = np.zeros(n), np.zeros(n)
    vols = pd_corr.volumes
    coords = pd_corr.coords

    du = u_unif[pd_corr.bond_j] - u_unif[pd_corr.bond_i]
    s = np.sum(pd_corr.unit_xi * du, axis=1) / pd_corr.xi_len
    fx_u = pd_uncorr.g_ij * pd_uncorr.c_ij * s * pd_corr.unit_xi[:, 0]
    fx_c = pd_corr.g_ij * pd_corr.c_ij * s * pd_corr.unit_xi[:, 0]

    for b_idx in range(pd_corr.n_bonds):
        i = int(pd_corr.bond_i[b_idx])
        j = int(pd_corr.bond_j[b_idx])
        xi_x = coords[j, 0] - coords[i, 0]
        fiu, fju = fx_u[b_idx] * vols[j], -fx_u[b_idx] * vols[i]
        fic, fjc = fx_c[b_idx] * vols[j], -fx_c[b_idx] * vols[i]
        if xi_x >= 0:
            fr_u[i] += fiu; fl_u[j] += fju
            fr_c[i] += fic; fl_c[j] += fjc
        else:
            fl_u[i] += fiu; fr_u[j] += fju
            fl_c[i] += fic; fr_c[j] += fjc
    return fl_u, fr_u, fl_c, fr_c


def build_complete_dataset():
    E, rho = 100.0, 1.0
    eps0 = 0.002

    # =========================================================================
    # 1. Clean 3D Graded Lattice Block (Lx=1.0, Ly=0.16, Lz=0.16, dx_f=0.04, dx_c=0.08)
    #    Every 3D node, 3D cell, 3D bond, and 3D wave surface is crystal clear & unoccluded!
    # =========================================================================
    Lx3, Ly3, Lz3 = 1.0, 0.16, 0.16
    coords_3d, vols_3d, bounds_3d = make_3d_graded_block(dx_fine=0.025, dx_coarse=0.05, Lx=Lx3, Ly=0.15, Lz=0.15)
    x3, y3, z3 = coords_3d[:, 0], coords_3d[:, 1], coords_3d[:, 2]
    c_p3 = np.sqrt(1.2 * E / rho)

    pd3_uncorr = MultiscaleBondPD(coords_3d, vols_3d, E=E, rho=rho, m=3.0, dim=3, mode="symmetric", stiffness_correction=False, ghost_force_correction=False, domain_bounds=bounds_3d)
    pd3_corr = MultiscaleBondPD(coords_3d, vols_3d, E=E, rho=rho, m=3.0, dim=3, mode="symmetric", stiffness_correction=True, ghost_force_correction=False, domain_bounds=bounds_3d)
    pd3_dh = MultiscaleBondPD(coords_3d, vols_3d, E=E, rho=rho, m=3.0, dim=3, mode="dual_horizon", stiffness_correction=True, ghost_force_correction=False, domain_bounds=bounds_3d)
    _apply_3d_wave_and_ghost_correction(pd3_corr)

    # 3D Wave crossing simulation
    amp = 1.0e-4
    w3 = 0.090
    x0_3 = 0.23
    u0_3w = np.zeros((len(coords_3d), 3), dtype=np.float64)
    v0_3w = np.zeros((len(coords_3d), 3), dtype=np.float64)
    u0_3w[:, 0] = amp * np.exp(-((x3 - x0_3) / w3) ** 2)
    du0_3dx = amp * (-2.0 * (x3 - x0_3) / (w3 ** 2)) * np.exp(-((x3 - x0_3) / w3) ** 2)
    v0_3w[:, 0] = -c_p3 * du0_3dx

    dt3 = 0.2 * 0.025 / c_p3
    t_end3 = 0.052
    n_steps3 = int(round(t_end3 / dt3))
    n_frames = 52
    rec3 = max(1, n_steps3 // n_frames)
    fixed_yz3 = np.sort(np.concatenate([np.arange(len(coords_3d)) * 3 + 1, np.arange(len(coords_3d)) * 3 + 2]))

    out3_w_uncorr = pd3_uncorr.run_dynamic(u0_3w, v0_3w, dt=dt3, n_steps=n_steps3, fixed_dofs=fixed_yz3, record_every=rec3)
    out3_w_corr = pd3_corr.run_dynamic(u0_3w, v0_3w, dt=dt3, n_steps=n_steps3, fixed_dofs=fixed_yz3, record_every=rec3)

    # 3D Uniform-strain ghost-force wave radiation simulation
    u0_3g = np.zeros((len(coords_3d), 3), dtype=np.float64)
    u0_3g[:, 0] = eps0 * x3
    v0_3g = np.zeros_like(u0_3g)
    _, fg3_uncorr = pd3_uncorr.compute_forces(u0_3g)
    _, fg3_corr = pd3_corr.compute_forces(u0_3g)
    fl3_u, fr3_u, fl3_c, fr3_c = _compute_left_right_forces(pd3_uncorr, pd3_corr, u0_3g)

    x_int3 = (x3 >= pd3_corr.delta) & (x3 <= Lx3 - pd3_corr.delta)
    fixed_3g = np.unique(np.concatenate([3 * np.where(~x_int3)[0], fixed_yz3]))
    out3_g_uncorr = pd3_uncorr.run_dynamic(u0_3g, v0_3g, dt=dt3, n_steps=n_steps3, fixed_dofs=fixed_3g, record_every=rec3)
    out3_g_corr = pd3_corr.run_dynamic(u0_3g, v0_3g, dt=dt3, n_steps=n_steps3, fixed_dofs=fixed_3g, record_every=rec3)

    # Build nearest-neighbor 3D crystal lattice edges (|xi| <= 1.05 * max(dx_i, dx_j)) so we can draw a crisp 3D structural wireframe grid!
    lattice_edges_i, lattice_edges_j = [], []
    for b_idx in range(pd3_corr.n_bonds):
        i = int(pd3_corr.bond_i[b_idx])
        j = int(pd3_corr.bond_j[b_idx])
        length = float(pd3_corr.xi_len[b_idx])
        dx_max = max(float(pd3_corr.dx[i]), float(pd3_corr.dx[j]))
        # Keep axis-aligned nearest neighbor edges or short cross-interface edges
        aligned = (
            (abs(y3[i] - y3[j]) < 1e-4 and abs(z3[i] - z3[j]) < 1e-4 and length <= 1.1 * dx_max)
            or (abs(x3[i] - x3[j]) < 1e-4 and abs(z3[i] - z3[j]) < 1e-4 and length <= 1.1 * dx_max)
            or (abs(x3[i] - x3[j]) < 1e-4 and abs(y3[i] - y3[j]) < 1e-4 and length <= 1.1 * dx_max)
        )
        if aligned:
            lattice_edges_i.append(i)
            lattice_edges_j.append(j)

    os3_mask = ~pd3_dh.bond_is_mutual
    tz3_fine = np.where((x3 > 0.48) & (x3 < 0.50) & (y3 > 0.05) & (y3 < 0.10) & (z3 > 0.05) & (z3 < 0.10))[0]
    tz3_coarse = np.where((x3 > 0.50) & (x3 < 0.54) & (y3 > 0.05) & (y3 < 0.12) & (z3 > 0.05) & (z3 < 0.12))[0]

    # =========================================================================
    # 2. 2D Graded Plate & 1D Graded Bar (for Tab 2 & Tab 3)
    # =========================================================================
    coords_2d, vols_2d, bounds_2d = make_2d_graded_plate(dx_fine=0.025, dx_coarse=0.05, Lx=1.0, Ly=0.30)
    pd2_uncorr = MultiscaleBondPD(coords_2d, vols_2d, E=E, rho=rho, m=3.0, dim=2, mode="symmetric", stiffness_correction=False, ghost_force_correction=False, domain_bounds=bounds_2d)
    pd2_corr = MultiscaleBondPD(coords_2d, vols_2d, E=E, rho=rho, m=3.0, dim=2, mode="symmetric", stiffness_correction=True, ghost_force_correction=True, domain_bounds=bounds_2d)
    pd2_dh = MultiscaleBondPD(coords_2d, vols_2d, E=E, rho=rho, m=3.0, dim=2, mode="dual_horizon", stiffness_correction=True, ghost_force_correction=False, domain_bounds=bounds_2d)

    u2_unif = np.column_stack([eps0 * coords_2d[:, 0], np.zeros(len(coords_2d))])
    _, fg2_uncorr = pd2_uncorr.compute_forces(u2_unif)
    _, fg2_corr = pd2_corr.compute_forces(u2_unif)
    fl2_u, fr2_u, fl2_c, fr2_c = _compute_left_right_forces(pd2_uncorr, pd2_corr, u2_unif)
    os2_mask = ~pd2_dh.bond_is_mutual
    tz2_fine = np.where((coords_2d[:, 0] > 0.48) & (coords_2d[:, 0] < 0.50) & (np.abs(coords_2d[:, 1] - 0.15) < 0.02))[0]
    tz2_coarse = np.where((coords_2d[:, 0] > 0.50) & (coords_2d[:, 0] < 0.54) & (np.abs(coords_2d[:, 1] - 0.15) < 0.03))[0]

    coords_1d, vols_1d, bounds_1d = make_1d_graded_bar(dx_fine=0.005, dx_coarse=0.01, L=1.0)
    x1 = coords_1d[:, 0]
    c0 = np.sqrt(E / rho)
    u0_1w = amp * np.exp(-((x1 - 0.24) / 0.055) ** 2)[:, None]
    v0_1w = (-c0 * amp * (-2.0 * (x1 - 0.24) / (0.055 ** 2)) * np.exp(-((x1 - 0.24) / 0.055) ** 2))[:, None]
    dt1 = 0.2 * 0.005 / c0
    n_steps1 = int(round(0.050 / dt1))
    rec1 = max(1, n_steps1 // n_frames)

    pd1_uncorr = MultiscaleBondPD(coords_1d, vols_1d, E=E, rho=rho, m=3.0, dim=1, mode="symmetric", stiffness_correction=False, ghost_force_correction=False, domain_bounds=bounds_1d)
    pd1_corr = MultiscaleBondPD(coords_1d, vols_1d, E=E, rho=rho, m=3.0, dim=1, mode="symmetric", stiffness_correction=True, ghost_force_correction=True, domain_bounds=bounds_1d)
    out1_w_uncorr = pd1_uncorr.run_dynamic(u0_1w, v0_1w, dt=dt1, n_steps=n_steps1, record_every=rec1)
    out1_w_corr = pd1_corr.run_dynamic(u0_1w, v0_1w, dt=dt1, n_steps=n_steps1, record_every=rec1)

    return {
        "block3d": {
            "dims": [1.0, 0.15, 0.15],
            "n_nodes": int(pd3_corr.n_nodes),
            "default_fine": int(tz3_fine[0]) if len(tz3_fine) else 0,
            "default_coarse": int(tz3_coarse[0]) if len(tz3_coarse) else 0,
            "times_ms": np.round(out3_w_corr["history_t"] * 1e3, 2).tolist(),
            "x": np.round(x3, 5).tolist(),
            "y": np.round(y3, 5).tolist(),
            "z": np.round(z3, 5).tolist(),
            "dx_mm": np.round(pd3_corr.dx * 1e3, 2).tolist(),
            "delta_mm": np.round(pd3_corr.delta * 1e3, 2).tolist(),
            "fg_uncorr": np.round(fg3_uncorr[:, 0], 3).tolist(),
            "fg_corr": np.round(fg3_corr[:, 0], 14).tolist(),
            "fl_uncorr": np.round(fl3_u, 2).tolist(),
            "fr_uncorr": np.round(fr3_u, 2).tolist(),
            "fl_corr": np.round(fl3_c, 2).tolist(),
            "fr_corr": np.round(fr3_c, 2).tolist(),
            "lattice_i": lattice_edges_i,
            "lattice_j": lattice_edges_j,
            "sym_bonds": {
                "i": pd3_corr.bond_i.tolist(),
                "j": pd3_corr.bond_j.tolist(),
                "len_mm": np.round(pd3_corr.xi_len * 1e3, 2).tolist(),
                "g_corr": np.round(pd3_corr.g_ij, 3).tolist(),
            },
            "os_bonds": {
                "i": pd3_dh.bond_i[os3_mask].tolist(),
                "j": pd3_dh.bond_j[os3_mask].tolist(),
                "len_mm": np.round(pd3_dh.xi_len[os3_mask] * 1e3, 2).tolist(),
            },
            "wave_uncorr": np.round(out3_w_uncorr["history_u"][:, :, 0] / amp, 4).tolist(),
            "wave_corr": np.round(out3_w_corr["history_u"][:, :, 0] / amp, 4).tolist(),
            "ghost_uncorr_um": np.round((out3_g_uncorr["history_u"][:, :, 0] - u0_3g[None, :, 0]) * 1e6, 3).tolist(),
            "ghost_corr_um": np.round((out3_g_corr["history_u"][:, :, 0] - u0_3g[None, :, 0]) * 1e6, 13).tolist(),
        },
        "plate2d": {
            "Lx": 1.0,
            "Ly": 0.30,
            "n_nodes": int(pd2_corr.n_nodes),
            "default_fine": int(tz2_fine[0]) if len(tz2_fine) else 0,
            "default_coarse": int(tz2_coarse[0]) if len(tz2_coarse) else 0,
            "x": np.round(coords_2d[:, 0], 5).tolist(),
            "y": np.round(coords_2d[:, 1], 5).tolist(),
            "dx_mm": np.round(pd2_corr.dx * 1e3, 2).tolist(),
            "delta_mm": np.round(pd2_corr.delta * 1e3, 2).tolist(),
            "fg_uncorr": np.round(fg2_uncorr[:, 0], 4).tolist(),
            "fg_corr": np.round(fg2_corr[:, 0], 15).tolist(),
            "f_left_uncorr": np.round(fl2_u, 3).tolist(),
            "f_right_uncorr": np.round(fr2_u, 3).tolist(),
            "f_left_corr": np.round(fl2_c, 3).tolist(),
            "f_right_corr": np.round(fr2_c, 3).tolist(),
            "sym_bonds": {
                "i": pd2_corr.bond_i.tolist(),
                "j": pd2_corr.bond_j.tolist(),
                "len_mm": np.round(pd2_corr.xi_len * 1e3, 2).tolist(),
                "g_corr": np.round(pd2_corr.g_ij, 4).tolist(),
            },
            "os_bonds": {
                "i": pd2_dh.bond_i[os2_mask].tolist(),
                "j": pd2_dh.bond_j[os2_mask].tolist(),
                "len_mm": np.round(pd2_dh.xi_len[os2_mask] * 1e3, 2).tolist(),
            },
        },
        "bar1d": {
            "n_nodes": int(pd1_corr.n_nodes),
            "x": np.round(x1, 5).tolist(),
            "dx_mm": np.round(pd1_corr.dx * 1e3, 2).tolist(),
            "delta_mm": np.round(pd1_corr.delta * 1e3, 2).tolist(),
            "times_ms": np.round(out1_w_corr["history_t"] * 1e3, 2).tolist(),
            "sym_bonds_i": pd1_corr.bond_i.tolist(),
            "sym_bonds_j": pd1_corr.bond_j.tolist(),
            "sym_bonds_g": np.round(pd1_corr.g_ij, 4).tolist(),
            "wave_uncorr": np.round(out1_w_uncorr["history_u"][:, :, 0] / amp, 4).tolist(),
            "wave_corr": np.round(out1_w_corr["history_u"][:, :, 0] / amp, 4).tolist(),
        },
    }


HTML_TEMPLATE = """<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>3D & 2D Variable-Horizon Peridynamics — Wave, Bond & Ghost-Force Explorer</title>
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; }
  body { background: #f8fafc; color: #0f172a; display: flex; flex-direction: column; height: 100vh; overflow: hidden; }

  header {
    background: #ffffff; border-bottom: 2px solid #e2e8f0; padding: 9px 18px;
    display: flex; align-items: center; justify-content: space-between; gap: 12px; flex-wrap: wrap;
    box-shadow: 0 1px 4px rgba(15, 23, 42, 0.04);
  }
  .brand h1 { font-size: 16.5px; font-weight: 800; color: #1e3a8a; }
  .brand p { font-size: 12px; color: #475569; margin-top: 1px; }

  .tabs { display: flex; gap: 6px; background: #f1f5f9; padding: 4px; border-radius: 10px; border: 1px solid #cbd5e1; }
  .tab-btn {
    border: none; background: transparent; color: #475569; font-weight: 700; font-size: 12.5px;
    padding: 7px 14px; border-radius: 7px; cursor: pointer; transition: all 0.15s;
  }
  .tab-btn:hover { color: #0f172a; background: #e2e8f0; }
  .tab-btn.active { background: #1e3a8a; color: #ffffff; box-shadow: 0 2px 6px rgba(30, 58, 138, 0.25); }

  .quick-actions { display: flex; align-items: center; gap: 7px; }
  .btn {
    background: #ffffff; color: #1e293b; border: 1.5px solid #94a3b8; border-radius: 7px;
    padding: 6px 12px; font-size: 12px; font-weight: 600; cursor: pointer; transition: all 0.15s;
  }
  .btn:hover { border-color: #1e3a8a; background: #eff6ff; color: #1e3a8a; }
  .btn-green { background: #059669; color: white; border-color: #047857; }
  .btn-green:hover { background: #047857; color: white; }

  .workspace { display: flex; flex: 1; overflow: hidden; }
  .viewport-col { flex: 1; display: flex; flex-direction: column; position: relative; background: #ffffff; }
  canvas { display: block; width: 100%; height: 100%; cursor: grab; }
  canvas:active { cursor: grabbing; }

  .explainer-banner {
    position: absolute; top: 10px; left: 14px; right: 14px; pointer-events: none;
    background: rgba(255, 255, 255, 0.95); border: 1.5px solid #cbd5e1; border-left: 6px solid #1e3a8a;
    border-radius: 10px; padding: 9px 14px; box-shadow: 0 4px 12px rgba(15, 23, 42, 0.08);
    display: flex; align-items: center; justify-content: space-between; gap: 14px;
  }
  .explainer-text { font-size: 13px; line-height: 1.42; color: #1e293b; }
  .explainer-text b { color: #1e3a8a; }
  .zoom-hint {
    background: #eff6ff; border: 1px solid #bfdbfe; color: #1d4ed8; font-weight: 700;
    font-size: 11.5px; padding: 5px 10px; border-radius: 6px; white-space: nowrap;
  }

  .sidebar {
    width: 375px; background: #f8fafc; border-left: 2px solid #e2e8f0; padding: 12px;
    overflow-y: auto; display: flex; flex-direction: column; gap: 10px;
  }
  .panel-card {
    background: #ffffff; border: 1.5px solid #e2e8f0; border-radius: 10px; padding: 11px 13px;
    box-shadow: 0 1px 3px rgba(15,23,42,0.03);
  }
  .panel-card h3 {
    font-size: 12.5px; text-transform: uppercase; letter-spacing: 0.5px; color: #1e3a8a;
    margin-bottom: 8px; border-bottom: 1.5px solid #f1f5f9; padding-bottom: 4px;
  }

  .mode-pill-group { display: flex; gap: 6px; margin-bottom: 6px; }
  .mode-pill {
    flex: 1; text-align: center; padding: 7px 5px; border-radius: 7px; font-size: 11.5px;
    font-weight: 700; cursor: pointer; border: 1.5px solid #cbd5e1; background: #f8fafc; color: #475569;
  }
  .mode-pill.active-both { background: #eff6ff; border-color: #2563eb; color: #1d4ed8; }
  .mode-pill.active-bad { background: #fff7ed; border-color: #ea580c; color: #c2410c; }
  .mode-pill.active-good { background: #ecfdf5; border-color: #059669; color: #047857; }

  .stat-row { display: flex; justify-content: space-between; font-size: 12.5px; padding: 3.5px 0; border-bottom: 1px dashed #e2e8f0; }
  .stat-row span:first-child { color: #475569; }
  .stat-row span:last-child { font-weight: 700; color: #0f172a; font-family: ui-monospace, SFMono-Regular, Menlo, monospace; }

  .force-balance-box {
    background: #f8fafc; border: 1px solid #cbd5e1; border-radius: 8px; padding: 9px; margin-top: 6px;
  }
  .fb-title { font-size: 11.5px; font-weight: 700; color: #334155; text-align: center; margin-bottom: 5px; }
  .fb-row { display: flex; align-items: center; justify-content: space-between; font-size: 12px; margin: 3px 0; }
  .fb-verdict {
    margin-top: 6px; padding: 6px 9px; border-radius: 6px; font-size: 12px; font-weight: 700; text-align: center;
  }
  .verdict-bad { background: #fef2f2; border: 1px solid #f87171; color: #b91c1c; }
  .verdict-good { background: #ecfdf5; border: 1px solid #34d399; color: #047857; }

  .legend-item { display: flex; align-items: center; gap: 8px; font-size: 12px; color: #334155; margin: 5px 0; cursor: pointer; }
  .legend-line { width: 22px; height: 4px; border-radius: 2px; display: inline-block; }

  .bottom-bar {
    background: #ffffff; border-top: 2px solid #e2e8f0; padding: 9px 18px;
    display: flex; align-items: center; gap: 16px; flex-wrap: wrap;
  }
  .ctrl-group { display: flex; align-items: center; gap: 7px; font-size: 12.5px; font-weight: 600; color: #334155; }
  input[type=range] { accent-color: #1e3a8a; cursor: pointer; }
</style>
</head>
<body>

<header>
  <div class="brand">
    <h1>3D &amp; 2D Variable-Horizon Peridynamics — Wave, Bond &amp; Ghost-Force Microscope</h1>
    <p>See the 3D Wave &amp; Spurious Reflection in 3D, and scroll mouse wheel to zoom right into individual 3D Nodes &amp; Bonds!</p>
  </div>

  <div class="tabs">
    <button class="tab-btn active" id="tabBtn1">&#129482; 1. 3D Wave &amp; Problem View (Rotatable 3D)</button>
    <button class="tab-btn" id="tabBtn2">&#128269; 2. 2D Bond &amp; Ghost-Force Microscope</button>
    <button class="tab-btn" id="tabBtn3">&#127754; 3. 1D Wave &amp; Spring Lattice</button>
  </div>

  <div class="quick-actions">
    <button class="btn" id="btnZoomInterface">&#127919; Zoom to 3D Interface (x = 0.50 m)</button>
    <button class="btn" id="btnResetZoom">&#128260; Reset Full View</button>
  </div>
</header>

<div class="workspace">
  <div class="viewport-col">
    <div class="explainer-banner">
      <div class="explainer-text" id="bannerText">
        <b>3D Wave &amp; Problem View:</b> Watch the 3D wave crest cross the <b>Fine &rarr; Coarse 3D Lattice Interface (x = 0.50 m)</b>. In <b>Uncorrected 3D PD</b>, a 31.8% <b>Spurious Reflected Wave</b> bounces back; in <b>Our Ghost-Free 3D PD</b>, it passes cleanly!
      </div>
      <div class="zoom-hint" id="mouseHint">&#128433; Scroll = Zoom to Node | Left-Drag = Rotate 3D | Right-Drag = Pan</div>
    </div>
    <canvas id="mainCanvas"></canvas>
  </div>

  <div class="sidebar">
    <!-- 1. Phenomenon & Model Selector -->
    <div class="panel-card">
      <h3>1. What Problem to Show in 3D</h3>
      <select id="phenomSelect" style="width:100%;padding:7px 9px;border-radius:7px;border:1.5px solid #94a3b8;font-weight:700;font-size:12.5px;color:#1e3a8a;margin-bottom:8px;">
        <option value="wave">Problem A: 3D Wave Crossing &amp; Spurious Reflection</option>
        <option value="ghost_dyn">Problem B: Uniform Strain &rarr; Ghost Force Radiates 3D Waves!</option>
      </select>

      <div class="mode-pill-group">
        <div class="mode-pill active-both" id="pillBoth">&#128064; Compare Both<br><small>Side-by-Side 3D</small></div>
        <div class="mode-pill" id="pillUncorr">&#10060; Uncorrected<br><small>Has Problem!</small></div>
        <div class="mode-pill" id="pillCorr">&#9989; Ghost-Free<br><small>Solved (Ours)</small></div>
      </div>
    </div>

    <!-- 2. Hovered / Selected Node & Force Balance Inspector -->
    <div class="panel-card">
      <h3>2. Node &amp; Bond Inspector <small style="font-weight:normal;color:#64748b;">(Click or Hover any Node)</small></h3>
      <div class="stat-row"><span>Inspected Node</span><span id="stNodeId">Node #0</span></div>
      <div class="stat-row"><span>Mesh Subdomain</span><span id="stRegion">Fine 3D Lattice</span></div>
      <div class="stat-row"><span>Coordinates</span><span id="stPos">(0.488, 0.088, 0.088) m</span></div>
      <div class="stat-row"><span>Cell Spacing &Delta;x<sub>i</sub></span><span id="stDx">25.0 mm</span></div>
      <div class="stat-row"><span>Horizon Radius &delta;<sub>i</sub> = 3&Delta;x<sub>i</sub></span><span id="stDelta">75.0 mm</span></div>
      <div class="stat-row"><span>Kept Symmetric Bonds |H<sub>i</sub>|</span><span id="stSym" style="color:#059669;">-</span></div>
      <div class="stat-row"><span>Excluded One-Sided Bonds</span><span id="stOs" style="color:#dc2626;">-</span></div>

      <div class="force-balance-box">
        <div class="fb-title">Uniform-Strain Force Balance on This Node</div>
        <div class="fb-row">
          <span style="color:#2563eb;font-weight:700;">&larr; Left Bonds Pull:</span>
          <span id="stPullLeft" style="font-family:monospace;font-weight:700;">-</span>
        </div>
        <div class="fb-row">
          <span style="color:#d97706;font-weight:700;">Right Bonds Pull: &rarr;</span>
          <span id="stPullRight" style="font-family:monospace;font-weight:700;">-</span>
        </div>
        <div class="fb-verdict verdict-bad" id="stVerdict">
          &#9888; Net Ghost Force Imbalance!
        </div>
      </div>
    </div>

    <!-- 3. 3D Visual Layers -->
    <div class="panel-card">
      <h3>3. 3D Visual Layers &amp; Bonds</h3>
      <label class="legend-item">
        <input type="checkbox" id="chk3DWaveHeight" checked>
        <span><b>3D Wave Crest Surface Deformation</b> (Lift nodes in 3D with wave!)</span>
      </label>
      <label class="legend-item">
        <input type="checkbox" id="chk3DLattice" checked>
        <span class="legend-line" style="background:#94a3b8;height:2px;"></span>
        <span><b>3D Crystal Lattice Grid Lines</b> (Show fine &amp; coarse 3D cells)</span>
      </label>
      <label class="legend-item">
        <input type="checkbox" id="chkShowSym" checked>
        <span class="legend-line" style="background:#059669;"></span>
        <span><b>Selected Node's Symmetric Bonds</b> (|&xi;| &le; min(&delta;<sub>i</sub>, &delta;<sub>j</sub>))</span>
      </label>
      <label class="legend-item">
        <input type="checkbox" id="chkShowOs" checked>
        <span class="legend-line" style="background:#dc2626;border-top:2px dashed #dc2626;height:0;"></span>
        <span><b>Excluded One-Sided Bonds</b> (Coarse pulls Fine only)</span>
      </label>
      <label class="legend-item">
        <input type="checkbox" id="chkShowHorizon" checked>
        <span style="width:15px;height:15px;border-radius:50%;border:2px solid #2563eb;background:rgba(37,99,235,0.12);display:inline-block;"></span>
        <span><b>3D Horizon Sphere &delta;<sub>i</sub> = 3&Delta;x<sub>i</sub></b> around selected node</span>
      </label>
      <label class="legend-item">
        <input type="checkbox" id="chkShowArrows" checked>
        <span style="font-weight:900;color:#b91c1c;font-size:15px;">&rarr;</span>
        <span><b>3D Force Balance &amp; Ghost Force Arrows</b></span>
      </label>
    </div>

    <!-- 4. Guided Tour -->
    <div class="panel-card">
      <h3>4. One-Click Zoom Presets</h3>
      <div style="display:flex;flex-direction:column;gap:5px;">
        <button class="btn" id="btnTour3DWave" style="text-align:left;">&#127754; <b>1. Full 3D Wave Comparison</b> (See Spurious Reflection)</button>
        <button class="btn" id="btnTourFine" style="text-align:left;">&#128309; <b>2. Zoom to Fine Interface Node</b> (See 3D Bonds &amp; Ghost Force)</button>
        <button class="btn" id="btnTourCoarse" style="text-align:left;">&#128992; <b>3. Zoom to Coarse Interface Node</b> (See One-Sided Bonds)</button>
      </div>
    </div>
  </div>
</div>

<div class="bottom-bar">
  <button class="btn btn-green" id="btnPlayPause" style="min-width:105px;">&#10074;&#10074; Pause Wave</button>
  <div class="ctrl-group" style="flex:1;min-width:200px;">
    <span>Wave Time:</span>
    <input type="range" id="sliderTime" min="0" max="50" value="34" style="flex:1;">
    <span id="lblTime" style="font-family:monospace;min-width:82px;">t = 34.0 ms</span>
  </div>
  <div class="ctrl-group">
    <span>Speed (FPS):</span>
    <input type="range" id="sliderFps" min="1" max="15" value="4" style="width:88px;">
    <span id="lblFps" style="font-family:monospace;min-width:44px;">4 fps</span>
  </div>
  <div class="ctrl-group">
    <span>3D Wave Height:</span>
    <input type="range" id="sliderWaveAmp" min="0" max="200" value="110" style="width:88px;">
  </div>
  <div class="ctrl-group">
    <span>Zoom:</span>
    <input type="range" id="sliderZoom" min="80" max="500" value="115" style="width:88px;">
    <span id="lblZoom" style="font-family:monospace;min-width:42px;">1.2x</span>
  </div>
</div>

<script>
const DATA = __SIM_DATA_JSON__;
const B3 = DATA.block3d;
const P2 = DATA.plate2d;
const B1 = DATA.bar1d;

// Build adjacency lists for 3D block
const sym3ByNode = Array.from({length: B3.n_nodes}, () => []);
for (let b = 0; b < B3.sym_bonds.i.length; b++) {
  const i = B3.sym_bonds.i[b], j = B3.sym_bonds.j[b];
  sym3ByNode[i].push({ b, nbr: j, len: B3.sym_bonds.len_mm[b], g: B3.sym_bonds.g_corr[b] });
  sym3ByNode[j].push({ b, nbr: i, len: B3.sym_bonds.len_mm[b], g: B3.sym_bonds.g_corr[b] });
}
const os3ByNode = Array.from({length: B3.n_nodes}, () => []);
for (let b = 0; b < B3.os_bonds.i.length; b++) {
  const i = B3.os_bonds.i[b], j = B3.os_bonds.j[b];
  os3ByNode[i].push({ b, nbr: j, len: B3.os_bonds.len_mm[b] });
  os3ByNode[j].push({ b, nbr: i, len: B3.os_bonds.len_mm[b] });
}

// Build adjacency lists for 2D plate
const sym2ByNode = Array.from({length: P2.n_nodes}, () => []);
for (let b = 0; b < P2.sym_bonds.i.length; b++) {
  const i = P2.sym_bonds.i[b], j = P2.sym_bonds.j[b];
  sym2ByNode[i].push({ b, nbr: j, len: P2.sym_bonds.len_mm[b], g: P2.sym_bonds.g_corr[b] });
  sym2ByNode[j].push({ b, nbr: i, len: P2.sym_bonds.len_mm[b], g: P2.sym_bonds.g_corr[b] });
}
const os2ByNode = Array.from({length: P2.n_nodes}, () => []);
for (let b = 0; b < P2.os_bonds.i.length; b++) {
  const i = P2.os_bonds.i[b], j = P2.os_bonds.j[b];
  os2ByNode[i].push({ b, nbr: j, len: P2.os_bonds.len_mm[b] });
  os2ByNode[j].push({ b, nbr: i, len: P2.os_bonds.len_mm[b] });
}

// Build adjacency lists for 1D bar
const sym1ByNode = Array.from({length: B1.n_nodes}, () => []);
for (let b = 0; b < B1.sym_bonds_i.length; b++) {
  const i = B1.sym_bonds_i[b], j = B1.sym_bonds_j[b];
  sym1ByNode[i].push({ b, nbr: j, g: B1.sym_bonds_g[b] });
  sym1ByNode[j].push({ b, nbr: i, g: B1.sym_bonds_g[b] });
}

// Application State
let activeTab = 1;        // 1 = 3D View, 2 = 2D Microscope, 3 = 1D Wave & Springs
let compareMode = 'both'; // 'both' (side-by-side 3D), 'uncorr' (bad only), 'corr' (good only)
let activeNode3D = B3.default_fine;
let activeNode2D = P2.default_fine;
let activeNode1D = 99;

// 3D Camera State
let camYaw = -1.12;
let camPitch = 0.44;
let camTarget3D = [0.50, 0.075, 0.075];

// Shared Zoom & 2D Pan State
let zoomFactor = 1.15;
let viewCenterX = 0.50;
let viewCenterY = 0.15;

// Animation State (Playing by default so user immediately sees the 3D wave!)
let frameIdx = Math.min(34, B3.times_ms.length - 1);
let isPlaying = true;
let fps = 4;
let lastTick = 0;
let waveHeightScale = 1.10;

const canvas = document.getElementById('mainCanvas');
const ctx = canvas.getContext('2d');
const sliderTime = document.getElementById('sliderTime');
sliderTime.max = B3.times_ms.length - 1;
sliderTime.value = frameIdx;

function resize() {
  const r = canvas.parentElement.getBoundingClientRect();
  canvas.width = r.width * window.devicePixelRatio;
  canvas.height = r.height * window.devicePixelRatio;
  ctx.setTransform(window.devicePixelRatio, 0, 0, window.devicePixelRatio, 0, 0);
  draw();
}
window.addEventListener('resize', resize);

// Helper: Draw Crisp Arrow
function drawArrow(x1, y1, x2, y2, color, lineWidth, label) {
  const dx = x2 - x1, dy = y2 - y1;
  const len = Math.hypot(dx, dy);
  if (len < 4) return;
  const ux = dx / len, uy = dy / len;
  const head = Math.min(12, Math.max(7, len * 0.28));

  ctx.save();
  ctx.strokeStyle = color;
  ctx.fillStyle = color;
  ctx.lineWidth = lineWidth;
  ctx.beginPath(); ctx.moveTo(x1, y1); ctx.lineTo(x2, y2); ctx.stroke();

  ctx.beginPath();
  ctx.moveTo(x2, y2);
  ctx.lineTo(x2 - head * ux + head * 0.45 * uy, y2 - head * uy - head * 0.45 * ux);
  ctx.lineTo(x2 - head * ux - head * 0.45 * uy, y2 - head * uy + head * 0.45 * ux);
  ctx.closePath();
  ctx.fill();

  if (label) {
    ctx.font = 'bold 11.5px -apple-system, sans-serif';
    ctx.textAlign = 'center';
    ctx.fillStyle = color;
    ctx.fillText(label, (x1 + x2) * 0.5, y1 - 8);
  }
  ctx.restore();
}

// Diverging RdBu_r colormap for wave amplitude (-1 -> blue, 0 -> slate/white, +1 -> red)
function waveColor(val, vmax) {
  const t = Math.max(-1, Math.min(1, val / Math.max(vmax, 1e-12)));
  if (t < 0) {
    const a = Math.pow(-t, 0.75);
    const r = Math.round(226 * (1 - a) + 29 * a);
    const g = Math.round(232 * (1 - a) + 78 * a);
    const b = Math.round(240 * (1 - a) + 216 * a);
    return `rgb(${r},${g},${b})`;
  } else {
    const a = Math.pow(t, 0.75);
    const r = Math.round(226 * (1 - a) + 220 * a);
    const g = Math.round(232 * (1 - a) + 38 * a);
    const b = Math.round(240 * (1 - a) + 38 * a);
    return `rgb(${r},${g},${b})`;
  }
}

// ===========================================================================
// TAB 1 RENDERER: 3D Wave, Deforming Crystal Lattice & Problem View
// ===========================================================================
let projected3DNodes = [];

function project3DPoint(wx, wy, wz, cx, cy, W, H) {
  const dx = wx - camTarget3D[0];
  const dy = wy - camTarget3D[1];
  const dz = wz - camTarget3D[2];

  const cosY = Math.cos(camYaw), sinY = Math.sin(camYaw);
  const rx = dx * cosY - dy * sinY;
  const ry = dx * sinY + dy * cosY;
  const rz = dz;

  const cosP = Math.cos(camPitch), sinP = Math.sin(camPitch);
  const camY = ry * cosP - rz * sinP;
  const camZ = ry * sinP + rz * cosP;
  const camX = rx;

  const dist = 1.75;
  const depth = camY + dist;
  const baseScale = Math.min(W, H * 1.45) * 0.95 * zoomFactor;
  const scale = baseScale / Math.max(depth, 0.15);
  return [cx + camX * scale, cy - camZ * scale, depth, scale];
}

function renderOne3DBlock(W, H, centerX, centerY, isCorrected, titleText, titleColor) {
  const phenom = document.getElementById('phenomSelect').value;
  const useWaveHeight = document.getElementById('chk3DWaveHeight').checked;
  const showLattice = document.getElementById('chk3DLattice').checked;
  const showSym = document.getElementById('chkShowSym').checked;
  const showOs = document.getElementById('chkShowOs').checked;
  const showHorizon = document.getElementById('chkShowHorizon').checked;
  const showArrows = document.getElementById('chkShowArrows').checked;

  const [Lx, Ly, Lz] = B3.dims;

  // Title above 3D block
  ctx.save();
  ctx.font = 'bold 13.5px -apple-system, sans-serif';
  ctx.fillStyle = titleColor;
  ctx.textAlign = 'center';
  const [topSx, topSy] = project3DPoint(0.50, 0.5 * Ly, Lz + 0.11, centerX, centerY, W, H);
  ctx.fillText(titleText, centerX, Math.max(68, topSy - 16));
  ctx.restore();

  // 1. Draw 3D Bounding Box & Translucent Fine/Coarse Interface Wall at x = 0.50 m
  const boxEdges = [
    [[0,0,0],[Lx,0,0]], [[0,Ly,0],[Lx,Ly,0]], [[0,0,Lz],[Lx,0,Lz]], [[0,Ly,Lz],[Lx,Ly,Lz]],
    [[0,0,0],[0,Ly,0]], [[Lx,0,0],[Lx,Ly,0]], [[0,0,Lz],[0,Ly,Lz]], [[Lx,0,Lz],[Lx,Ly,Lz]],
    [[0,0,0],[0,0,Lz]], [[Lx,0,0],[Lx,0,Lz]], [[0,Ly,0],[0,Ly,Lz]], [[Lx,Ly,0],[Lx,Ly,Lz]]
  ];
  ctx.strokeStyle = 'rgba(148, 163, 184, 0.45)';
  ctx.lineWidth = 1.1;
  for (const [p1, p2] of boxEdges) {
    const a = project3DPoint(p1[0], p1[1], p1[2], centerX, centerY, W, H);
    const b = project3DPoint(p2[0], p2[1], p2[2], centerX, centerY, W, H);
    ctx.beginPath(); ctx.moveTo(a[0], a[1]); ctx.lineTo(b[0], b[1]); ctx.stroke();
  }

  // Translucent 3D Interface Wall at x = 0.50 m
  const hWall = Lz + 0.04;
  const ic = [
    project3DPoint(0.5, 0, -0.02, centerX, centerY, W, H),
    project3DPoint(0.5, Ly, -0.02, centerX, centerY, W, H),
    project3DPoint(0.5, Ly, hWall, centerX, centerY, W, H),
    project3DPoint(0.5, 0, hWall, centerX, centerY, W, H)
  ];
  ctx.fillStyle = 'rgba(37, 99, 235, 0.12)';
  ctx.strokeStyle = '#1d4ed8';
  ctx.lineWidth = 1.8;
  ctx.beginPath();
  ctx.moveTo(ic[0][0], ic[0][1]); ctx.lineTo(ic[1][0], ic[1][1]);
  ctx.lineTo(ic[2][0], ic[2][1]); ctx.lineTo(ic[3][0], ic[3][1]);
  ctx.closePath(); ctx.fill(); ctx.stroke();

  // Compute deformed 3D node positions (physical horizontal compression + 3D wave crest lift!)
  const nodePts = new Array(B3.n_nodes);
  const valArr = (phenom === 'wave')
    ? (isCorrected ? B3.wave_corr[frameIdx] : B3.wave_uncorr[frameIdx])
    : (isCorrected ? B3.ghost_corr_um[frameIdx] : B3.ghost_uncorr_um[frameIdx]);
  const vmax = (phenom === 'wave') ? 0.35 : 30.0;

  for (let i = 0; i < B3.n_nodes; i++) {
    const rawVal = valArr[i];
    const normVal = (phenom === 'wave') ? rawVal : (rawVal / 30.0);
    const dxDeform = normVal * 0.018 * waveHeightScale;
    const dzWave = useWaveHeight ? (normVal * 0.075 * waveHeightScale) : 0.0;
    const wx = B3.x[i] + dxDeform;
    const wy = B3.y[i];
    const wz = B3.z[i] + dzWave;
    const [sx, sy, depth, scale] = project3DPoint(wx, wy, wz, centerX, centerY, W, H);
    nodePts[i] = { i, sx, sy, depth, scale, rawVal, wx, wy, wz, isCorrected };
  }

  // 2. Draw 3D Crystal Lattice Grid Lines (so the user sees the 3D wave surface & 3D cells deforming!)
  if (showLattice) {
    ctx.strokeStyle = 'rgba(100, 116, 139, 0.32)';
    ctx.lineWidth = 1.0;
    for (let e = 0; e < B3.lattice_i.length; e++) {
      const p1 = nodePts[B3.lattice_i[e]];
      const p2 = nodePts[B3.lattice_j[e]];
      ctx.beginPath(); ctx.moveTo(p1.sx, p1.sy); ctx.lineTo(p2.sx, p2.sy); ctx.stroke();
    }
  }

  const sel = activeNode3D;
  const selPt = nodePts[sel];

  // 3. Draw 3D Wireframe Horizon Sphere delta_i = 3 * dx_i around Selected Node
  if (showHorizon && selPt) {
    const r = B3.delta_mm[sel] * 1e-3;
    const isFine = B3.x[sel] < 0.5;
    ctx.strokeStyle = isFine ? 'rgba(37, 99, 235, 0.65)' : 'rgba(217, 119, 6, 0.70)';
    ctx.lineWidth = 1.6;
    const nSeg = 32;
    for (let plane = 0; plane < 3; plane++) {
      ctx.beginPath();
      for (let s = 0; s <= nSeg; s++) {
        const ang = (2 * Math.PI * s) / nSeg;
        let px = selPt.wx, py = selPt.wy, pz = selPt.wz;
        if (plane === 0) { px += r * Math.cos(ang); py += r * Math.sin(ang); }
        else if (plane === 1) { px += r * Math.cos(ang); pz += r * Math.sin(ang); }
        else { py += r * Math.cos(ang); pz += r * Math.sin(ang); }
        const [sx, sy] = project3DPoint(px, py, pz, centerX, centerY, W, H);
        if (s === 0) ctx.moveTo(sx, sy); else ctx.lineTo(sx, sy);
      }
      ctx.stroke();
    }
  }

  // 4. Draw Selected Node's 3D Kept Symmetric Bonds (|xi| <= min(delta_i, delta_j))
  const symNbrSet = new Set();
  if (showSym && selPt) {
    ctx.strokeStyle = '#059669';
    ctx.lineWidth = 2.2;
    for (const item of sym3ByNode[sel]) {
      symNbrSet.add(item.nbr);
      const nPt = nodePts[item.nbr];
      ctx.beginPath(); ctx.moveTo(selPt.sx, selPt.sy); ctx.lineTo(nPt.sx, nPt.sy); ctx.stroke();
    }
  }

  // 5. Draw Selected Node's 3D Excluded One-Sided Bonds
  const osNbrSet = new Set();
  if (showOs && selPt) {
    ctx.save();
    ctx.strokeStyle = '#dc2626';
    ctx.lineWidth = 2.0;
    ctx.setLineDash([5, 4]);
    for (const item of os3ByNode[sel]) {
      osNbrSet.add(item.nbr);
      const nPt = nodePts[item.nbr];
      ctx.beginPath(); ctx.moveTo(selPt.sx, selPt.sy); ctx.lineTo(nPt.sx, nPt.sy); ctx.stroke();
    }
    ctx.restore();
  }

  // 6. Depth-sort and draw 3D Nodes
  const sorted = nodePts.slice().sort((a, b) => b.depth - a.depth);
  for (const p of sorted) {
    const i = p.i;
    const isSel = (i === sel);
    const isSym = symNbrSet.has(i);
    const isOs = osNbrSet.has(i);
    const isCoarse = B3.x[i] > 0.5;

    let r = (isCoarse ? 5.8 : 3.8) * (p.scale / 420.0);
    r = Math.max(2.5, Math.min(20.0, r));
    if (isSel) r *= 1.45;
    p.r = r;

    ctx.beginPath();
    ctx.arc(p.sx, p.sy, r, 0, 2 * Math.PI);
    ctx.fillStyle = isSel ? '#1e3a8a' : waveColor(p.rawVal, vmax);
    ctx.fill();

    if (isSel) {
      ctx.lineWidth = 2.8; ctx.strokeStyle = '#ffffff'; ctx.stroke();
    } else if (isSym) {
      ctx.lineWidth = 1.8; ctx.strokeStyle = '#059669'; ctx.stroke();
    } else if (isOs) {
      ctx.lineWidth = 1.8; ctx.strokeStyle = '#dc2626'; ctx.stroke();
    } else {
      ctx.lineWidth = 0.7; ctx.strokeStyle = 'rgba(15, 23, 42, 0.55)'; ctx.stroke();
    }

    projected3DNodes.push(p);
  }

  // 7. Draw 3D Force Balance Arrows & Problem Callouts in 3D!
  if (showArrows && selPt) {
    const fl = isCorrected ? B3.fl_corr[sel] : B3.fl_uncorr[sel];
    const fr = isCorrected ? B3.fr_corr[sel] : B3.fr_uncorr[sel];
    const fg = isCorrected ? B3.fg_corr[sel] : B3.fg_uncorr[sel];
    if (Math.abs(fg) > 0.2) {
      const [tipX, tipY] = project3DPoint(selPt.wx + Math.sign(fg) * 0.14, selPt.wy, selPt.wz, centerX, centerY, W, H);
      drawArrow(selPt.sx, selPt.sy, tipX, tipY, '#dc2626', 4.0, `3D Ghost Force: ${fg.toFixed(1)} N/m³`);
    } else if (Math.abs(fl) > 0.1 && zoomFactor > 1.5) {
      drawArrow(selPt.sx - 8, selPt.sy, selPt.sx - 45, selPt.sy, '#2563eb', 3.0, 'Left');
      drawArrow(selPt.sx + 8, selPt.sy, selPt.sx + 45, selPt.sy, '#059669', 3.0, 'Right (Balanced)');
    }
  }

  // Floating 3D Callout Badge for Spurious Reflected Wave when t >= 30 ms in Uncorrected Wave mode!
  const t_ms = B3.times_ms[frameIdx];
  if (!isCorrected && phenom === 'wave' && t_ms >= 29.0) {
    const reflX = Math.max(0.18, 0.50 - 0.01095 * (t_ms - 23.0));
    const [callX, callY] = project3DPoint(reflX, 0.075, Lz + 0.05, centerX, centerY, W, H);
    drawArrow(callX, callY - 22, callX, callY + 8, '#dc2626', 2.5, '\u26a0\ufe0f Spurious 3D Reflected Wave (31.8%)!');
  }
}

function drawTab1_3D(W, H) {
  projected3DNodes = [];
  if (compareMode === 'both') {
    // Render Uncorrected 3D Block on Top Half and Ghost-Free 3D Block on Bottom Half!
    renderOne3DBlock(
      W, H * 0.5, W * 0.5, H * 0.30, false,
      '\u274c 1. UNCORRECTED 3D VARIABLE-HORIZON PD (g_ij = 1) — Spurious 3D Wave Reflection & Ghost Forces!',
      '#c2410c'
    );
    // Horizontal divider
    ctx.strokeStyle = '#e2e8f0'; ctx.lineWidth = 2;
    ctx.beginPath(); ctx.moveTo(20, H * 0.53); ctx.lineTo(W - 20, H * 0.53); ctx.stroke();

    renderOne3DBlock(
      W, H * 0.5, W * 0.5, H * 0.76, true,
      '\u2705 2. MULTISCALE GHOST-FREE 3D PD (OURS) — Clean 3D Wave Transmission & Zero Ghost Force!',
      '#047857'
    );
  } else if (compareMode === 'uncorr') {
    renderOne3DBlock(
      W, H, W * 0.5, H * 0.55, false,
      '\u274c UNCORRECTED 3D VARIABLE-HORIZON PD (g_ij = 1) — Spurious 3D Wave Reflection & Ghost Forces',
      '#c2410c'
    );
  } else {
    renderOne3DBlock(
      W, H, W * 0.5, H * 0.55, true,
      '\u2705 MULTISCALE GHOST-FREE 3D PD (OURS) — Clean 3D Wave Transmission & Zero Ghost Force',
      '#047857'
    );
  }
}

// ===========================================================================
// TAB 2 RENDERER: 2D Interactive Bond, Horizon Circle & Force-Balance Microscope
// ===========================================================================
function worldToScreen2D(wx, wy, W, H) {
  const baseScale = Math.min((W - 80) / 1.0, (H - 120) / 0.36);
  const scale = baseScale * zoomFactor;
  const sx = W * 0.5 + (wx - viewCenterX) * scale;
  const sy = H * 0.54 - (wy - viewCenterY) * scale;
  return [sx, sy, scale];
}

function screenToWorld2D(sx, sy, W, H) {
  const baseScale = Math.min((W - 80) / 1.0, (H - 120) / 0.36);
  const scale = baseScale * zoomFactor;
  const wx = viewCenterX + (sx - W * 0.5) / scale;
  const wy = viewCenterY - (sy - H * 0.54) / scale;
  return [wx, wy, scale];
}

function drawTab2_2D(W, H) {
  const useCorrected = (compareMode === 'corr');
  const showSym = document.getElementById('chkShowSym').checked;
  const showOs = document.getElementById('chkShowOs').checked;
  const showHorizon = document.getElementById('chkShowHorizon').checked;
  const showArrows = document.getElementById('chkShowArrows').checked;

  const [x0, y0, scale] = worldToScreen2D(0.0, 0.30, W, H);
  const [xMid, yBot] = worldToScreen2D(0.50, 0.0, W, H);
  const [x1] = worldToScreen2D(1.0, 0.0, W, H);

  ctx.fillStyle = '#f0f7ff'; ctx.fillRect(x0, y0, xMid - x0, yBot - y0);
  ctx.fillStyle = '#fffbeb'; ctx.fillRect(xMid, y0, x1 - xMid, yBot - y0);

  const [xTzL] = worldToScreen2D(0.35, 0, W, H);
  const [xTzR] = worldToScreen2D(0.65, 0, W, H);
  ctx.fillStyle = 'rgba(254, 215, 170, 0.32)';
  ctx.fillRect(xTzL, y0, xTzR - xTzL, yBot - y0);

  ctx.font = 'bold 13px -apple-system, sans-serif'; ctx.textAlign = 'center';
  ctx.fillStyle = '#1e40af'; ctx.fillText('FINE HORIZON REGION (dx = 25 mm, \u03b4_fine = 75 mm)', (x0 + xMid) * 0.5, y0 - 12);
  ctx.fillStyle = '#b45309'; ctx.fillText('COARSE HORIZON REGION (dx = 50 mm, \u03b4_coarse = 150 mm)', (xMid + x1) * 0.5, y0 - 12);

  ctx.save();
  ctx.strokeStyle = '#1e3a8a'; ctx.lineWidth = 2.5; ctx.setLineDash([7, 5]);
  ctx.beginPath(); ctx.moveTo(xMid, y0 - 6); ctx.lineTo(xMid, yBot + 6); ctx.stroke();
  ctx.restore();

  ctx.strokeStyle = 'rgba(148, 163, 184, 0.35)'; ctx.lineWidth = 1;
  for (let i = 0; i < P2.n_nodes; i++) {
    const half = 0.5 * P2.dx_mm[i] * 1e-3;
    const [cx1, cy1] = worldToScreen2D(P2.x[i] - half, P2.y[i] + half, W, H);
    const [cx2, cy2] = worldToScreen2D(P2.x[i] + half, P2.y[i] - half, W, H);
    ctx.strokeRect(cx1, cy1, cx2 - cx1, cy2 - cy1);
  }

  const sel = activeNode2D;
  const [selSx, selSy] = worldToScreen2D(P2.x[sel], P2.y[sel], W, H);
  const selDeltaPx = (P2.delta_mm[sel] * 1e-3) * scale;

  if (showHorizon) {
    const isFine = P2.x[sel] < 0.5;
    ctx.fillStyle = isFine ? 'rgba(37, 99, 235, 0.09)' : 'rgba(217, 119, 6, 0.10)';
    ctx.strokeStyle = isFine ? '#2563eb' : '#d97706';
    ctx.lineWidth = 2.4;
    ctx.beginPath(); ctx.arc(selSx, selSy, selDeltaPx, 0, 2 * Math.PI); ctx.fill(); ctx.stroke();
    ctx.fillStyle = isFine ? '#1d4ed8' : '#b45309';
    ctx.font = 'bold 12.5px -apple-system, sans-serif'; ctx.textAlign = 'center';
    ctx.fillText(`Horizon \u03b4_i = 3\u0394x_i = ${P2.delta_mm[sel]} mm`, selSx, selSy - selDeltaPx - 8);
  }

  const symNbrSet = new Set();
  if (showSym) {
    for (const item of sym2ByNode[sel]) {
      symNbrSet.add(item.nbr);
      const [nx, ny] = worldToScreen2D(P2.x[item.nbr], P2.y[item.nbr], W, H);
      ctx.strokeStyle = '#059669';
      ctx.lineWidth = Math.max(2.0, Math.min(4.5, 2.2 * item.g));
      ctx.beginPath(); ctx.moveTo(selSx, selSy); ctx.lineTo(nx, ny); ctx.stroke();
      if (zoomFactor >= 2.1) {
        ctx.fillStyle = '#065f46'; ctx.font = 'bold 10.5px monospace'; ctx.textAlign = 'center';
        ctx.fillText(`g=${useCorrected ? item.g.toFixed(2) : '1.00'}`, (selSx + nx) * 0.5, (selSy + ny) * 0.5 - 3);
      }
    }
  }

  const osNbrSet = new Set();
  if (showOs) {
    ctx.save();
    ctx.strokeStyle = '#dc2626'; ctx.lineWidth = 2.2; ctx.setLineDash([6, 4]);
    for (const item of os2ByNode[sel]) {
      osNbrSet.add(item.nbr);
      const [nx, ny] = worldToScreen2D(P2.x[item.nbr], P2.y[item.nbr], W, H);
      ctx.beginPath(); ctx.moveTo(selSx, selSy); ctx.lineTo(nx, ny); ctx.stroke();
    }
    ctx.restore();
  }

  for (let i = 0; i < P2.n_nodes; i++) {
    const [sx, sy] = worldToScreen2D(P2.x[i], P2.y[i], W, H);
    const isCoarse = P2.x[i] > 0.5;
    const isSel = (i === sel);
    const isSym = symNbrSet.has(i);
    const isOs = osNbrSet.has(i);
    let r = (isCoarse ? 7.5 : 5.0) * Math.pow(zoomFactor, 0.55);
    if (isSel) r *= 1.35;

    const fg = useCorrected ? Math.abs(P2.fg_corr[i]) : Math.abs(P2.fg_uncorr[i]);
    let fill = isCoarse ? '#f59e0b' : '#3b82f6';
    if (fg > 0.25) fill = '#ef4444';
    if (isSel) fill = '#1e3a8a';
    else if (isSym) fill = '#10b981';
    else if (isOs) fill = '#f87171';

    ctx.beginPath(); ctx.arc(sx, sy, r, 0, 2 * Math.PI);
    ctx.fillStyle = fill; ctx.fill();
    ctx.lineWidth = isSel ? 3.0 : (isSym || isOs ? 2.0 : 1.0);
    ctx.strokeStyle = isSel ? '#ffffff' : '#0f172a'; ctx.stroke();
  }

  if (showArrows) {
    const fl = useCorrected ? P2.f_left_corr[sel] : P2.f_left_uncorr[sel];
    const fr = useCorrected ? P2.f_right_corr[sel] : P2.f_right_uncorr[sel];
    const fnet = useCorrected ? P2.fg_corr[sel] : P2.fg_uncorr[sel];
    if (Math.abs(fl) > 0.1) drawArrow(selSx - 10, selSy, selSx - 10 + fl * 3.2, selSy, '#2563eb', 3.5, `Left: ${fl.toFixed(1)}`);
    if (Math.abs(fr) > 0.1) drawArrow(selSx + 10, selSy, selSx + 10 + fr * 3.2, selSy, '#d97706', 3.5, `Right: +${fr.toFixed(1)}`);
    if (Math.abs(fnet) > 0.05) drawArrow(selSx, selSy + 22, selSx + fnet * 12.0, selSy + 22, '#dc2626', 4.5, `GHOST FORCE: ${fnet.toFixed(2)} N/m²`);
  }
}

// ===========================================================================
// TAB 3 RENDERER: 1D Side-by-Side Wave & Moving Spring Lattice
// ===========================================================================
function drawTab3_1D(W, H) {
  const padX = 55;
  const plotW = W - 2 * padX;
  const topY = 78;
  const laneH = (H - topY - 34) * 0.46;
  const gapY = (H - topY - 34) * 0.08;

  const lanes = [
    {
      title: '\u274c 1. UNCORRECTED VARIABLE-HORIZON PD (g_ij = 1) — Spurious Wave Bounces Back at Interface!',
      color: '#c2410c',
      uArr: B1.wave_uncorr[frameIdx],
      yTop: topY,
    },
    {
      title: '\u2705 2. MULTISCALE GHOST-FREE PD (OURS) — Wave Glides Cleanly From Fine Nodes to Coarse Nodes!',
      color: '#047857',
      uArr: B1.wave_corr[frameIdx],
      yTop: topY + laneH + gapY,
    }
  ];

  function wxToSx(wx) {
    return W * 0.5 + (wx - viewCenterX) * plotW * zoomFactor;
  }

  for (const lane of lanes) {
    const y0 = lane.yTop, y1 = y0 + laneH;
    const yCurveMid = y0 + laneH * 0.42;
    const yLattice = y0 + laneH * 0.80;

    ctx.save();
    ctx.beginPath(); ctx.rect(padX, y0, plotW, laneH); ctx.clip();

    const sxLeft = wxToSx(0.0), sxInt = wxToSx(0.50), sxRight = wxToSx(1.0);
    ctx.fillStyle = '#f0f7ff'; ctx.fillRect(sxLeft, y0, sxInt - sxLeft, laneH);
    ctx.fillStyle = '#fffbeb'; ctx.fillRect(sxInt, y0, sxRight - sxInt, laneH);

    ctx.strokeStyle = '#1e3a8a'; ctx.lineWidth = 2; ctx.setLineDash([6, 4]);
    ctx.beginPath(); ctx.moveTo(sxInt, y0); ctx.lineTo(sxInt, y1); ctx.stroke();
    ctx.setLineDash([]);

    ctx.strokeStyle = '#cbd5e1'; ctx.lineWidth = 1;
    ctx.beginPath(); ctx.moveTo(padX, yCurveMid); ctx.lineTo(padX + plotW, yCurveMid); ctx.stroke();

    const ampPx = laneH * 0.30;
    ctx.strokeStyle = lane.color; ctx.lineWidth = 3.0;
    ctx.beginPath();
    for (let i = 0; i < B1.n_nodes; i++) {
      const sx = wxToSx(B1.x[i]);
      const sy = yCurveMid - lane.uArr[i] * ampPx;
      if (i === 0) ctx.moveTo(sx, sy); else ctx.lineTo(sx, sy);
    }
    ctx.stroke();

    const dispExag = 0.022;
    const nodeScreenX = B1.x.map((xVal, i) => wxToSx(xVal + lane.uArr[i] * dispExag));
    const sel1 = activeNode1D;
    const selSx = nodeScreenX[sel1];
    const selDeltaPx = (B1.delta_mm[sel1] * 1e-3) * plotW * zoomFactor;

    if (document.getElementById('chkShowHorizon').checked) {
      ctx.fillStyle = 'rgba(37, 99, 235, 0.10)'; ctx.strokeStyle = '#2563eb'; ctx.lineWidth = 1.8;
      ctx.beginPath(); ctx.arc(selSx, yLattice, selDeltaPx, Math.PI, 0, false); ctx.fill(); ctx.stroke();
    }
    if (document.getElementById('chkShowSym').checked) {
      for (const item of sym1ByNode[sel1]) {
        const nbrSx = nodeScreenX[item.nbr];
        const hArch = Math.min(34, 8 + Math.abs(nbrSx - selSx) * 0.25);
        ctx.strokeStyle = '#059669'; ctx.lineWidth = 2.0;
        ctx.beginPath(); ctx.moveTo(selSx, yLattice);
        ctx.quadraticCurveTo((selSx + nbrSx) * 0.5, yLattice - hArch, nbrSx, yLattice);
        ctx.stroke();
      }
    }
    for (let i = 0; i < B1.n_nodes; i++) {
      const sx = nodeScreenX[i];
      if (sx < padX - 20 || sx > padX + plotW + 20) continue;
      const isCoarse = B1.x[i] > 0.5;
      const isSel = (i === sel1);
      let r = (isCoarse ? 6.5 : 4.2) * Math.pow(zoomFactor, 0.45);
      if (isSel) r *= 1.4;
      ctx.beginPath(); ctx.arc(sx, yLattice, r, 0, 2 * Math.PI);
      ctx.fillStyle = isSel ? '#1e3a8a' : (Math.abs(lane.uArr[i]) > 0.08 ? lane.color : (isCoarse ? '#f59e0b' : '#3b82f6'));
      ctx.fill();
      ctx.lineWidth = isSel ? 2.5 : 1.0; ctx.strokeStyle = isSel ? '#ffffff' : '#0f172a'; ctx.stroke();
    }
    ctx.restore();

    ctx.strokeStyle = '#cbd5e1'; ctx.lineWidth = 1.5; ctx.strokeRect(padX, y0, plotW, laneH);
    ctx.fillStyle = lane.color; ctx.font = 'bold 13.5px -apple-system, sans-serif'; ctx.textAlign = 'left';
    ctx.fillText(lane.title, padX + 10, y0 + 20);
  }
}

function updateInspectorPanel() {
  const showCorr = (compareMode === 'corr');
  if (activeTab === 1) {
    const i = activeNode3D;
    const x = B3.x[i], y = B3.y[i], z = B3.z[i];
    const isFine = x < 0.5;
    document.getElementById('stNodeId').textContent = `3D Node #${i}`;
    document.getElementById('stRegion').textContent = isFine ? 'Fine 3D Lattice (dx = 25 mm)' : 'Coarse 3D Lattice (dx = 50 mm)';
    document.getElementById('stPos').textContent = `(${x.toFixed(3)}, ${y.toFixed(3)}, ${z.toFixed(3)}) m`;
    document.getElementById('stDx').textContent = `${B3.dx_mm[i].toFixed(1)} mm`;
    document.getElementById('stDelta').textContent = `${B3.delta_mm[i].toFixed(1)} mm`;
    document.getElementById('stSym').textContent = `${sym3ByNode[i].length} symmetric 3D bonds`;
    document.getElementById('stOs').textContent = `${os3ByNode[i].length} one-sided 3D bonds`;

    const fl = showCorr ? B3.fl_corr[i] : B3.fl_uncorr[i];
    const fr = showCorr ? B3.fr_corr[i] : B3.fr_uncorr[i];
    const fg = showCorr ? B3.fg_corr[i] : B3.fg_uncorr[i];
    document.getElementById('stPullLeft').textContent = `${fl.toFixed(2)} N/m³`;
    document.getElementById('stPullRight').textContent = `+${fr.toFixed(2)} N/m³`;
    const vEl = document.getElementById('stVerdict');
    if (Math.abs(fg) > 0.05) {
      vEl.className = 'fb-verdict verdict-bad';
      vEl.innerHTML = `&#9888; 3D Ghost Force = ${fg.toFixed(2)} N/m³ (Imbalanced!)`;
    } else {
      vEl.className = 'fb-verdict verdict-good';
      vEl.innerHTML = `&#9989; 3D Ghost Force = 0.00 N/m³ (Balanced!)`;
    }
  } else {
    const i = activeNode2D;
    const x = P2.x[i], y = P2.y[i];
    document.getElementById('stNodeId').textContent = `2D Node #${i}`;
    document.getElementById('stRegion').textContent = (x < 0.5) ? 'Fine 2D Mesh (dx = 25 mm)' : 'Coarse 2D Mesh (dx = 50 mm)';
    document.getElementById('stPos').textContent = `(${x.toFixed(3)}, ${y.toFixed(3)}) m`;
    document.getElementById('stDx').textContent = `${P2.dx_mm[i].toFixed(1)} mm`;
    document.getElementById('stDelta').textContent = `${P2.delta_mm[i].toFixed(1)} mm`;
    document.getElementById('stSym').textContent = `${sym2ByNode[i].length} symmetric bonds`;
    document.getElementById('stOs').textContent = `${os2ByNode[i].length} one-sided bonds`;

    const fl = showCorr ? P2.f_left_corr[i] : P2.f_left_uncorr[i];
    const fr = showCorr ? P2.f_right_corr[i] : P2.f_right_uncorr[i];
    const fg = showCorr ? P2.fg_corr[i] : P2.fg_uncorr[i];
    document.getElementById('stPullLeft').textContent = `${fl.toFixed(2)} N/m²`;
    document.getElementById('stPullRight').textContent = `+${fr.toFixed(2)} N/m²`;
    const vEl = document.getElementById('stVerdict');
    if (Math.abs(fg) > 0.05) {
      vEl.className = 'fb-verdict verdict-bad';
      vEl.innerHTML = `&#9888; Ghost Force = ${fg.toFixed(2)} N/m² (Imbalanced!)`;
    } else {
      vEl.className = 'fb-verdict verdict-good';
      vEl.innerHTML = `&#9989; Ghost Force = 0.00 N/m² (Balanced!)`;
    }
  }
  document.getElementById('lblTime').textContent = `t = ${B3.times_ms[frameIdx].toFixed(1)} ms`;
}

function draw() {
  const r = canvas.parentElement.getBoundingClientRect();
  const W = r.width, H = r.height;
  ctx.clearRect(0, 0, W, H);
  if (activeTab === 1) drawTab1_3D(W, H);
  else if (activeTab === 2) drawTab2_2D(W, H);
  else drawTab3_1D(W, H);
  updateInspectorPanel();
}

// ===========================================================================
// Mouse Wheel Zoom, 3D Orbit / Pan, and Hover/Click Node Inspection
// ===========================================================================
let isDragging = false;
let dragBtn = 0;
let lastMouse = [0, 0];
let dragDist = 0;

canvas.addEventListener('contextmenu', e => e.preventDefault());

canvas.addEventListener('wheel', e => {
  e.preventDefault();
  const rect = canvas.getBoundingClientRect();
  const mx = e.clientX - rect.left, my = e.clientY - rect.top;
  const W = rect.width, H = rect.height;

  const factor = Math.exp(-e.deltaY * 0.0015);
  if (activeTab === 2) {
    const [wxB, wyB] = screenToWorld2D(mx, my, W, H);
    zoomFactor = Math.max(0.8, Math.min(5.0, zoomFactor * factor));
    const [wxA, wyA] = screenToWorld2D(mx, my, W, H);
    viewCenterX += (wxB - wxA);
    viewCenterY += (wyB - wyA);
  } else {
    zoomFactor = Math.max(0.8, Math.min(5.0, zoomFactor * factor));
  }
  document.getElementById('sliderZoom').value = Math.round(zoomFactor * 100);
  document.getElementById('lblZoom').textContent = `${zoomFactor.toFixed(1)}x`;
  draw();
}, { passive: false });

canvas.addEventListener('mousedown', e => {
  isDragging = true;
  dragBtn = e.button;
  lastMouse = [e.clientX, e.clientY];
  dragDist = 0;
});

window.addEventListener('mouseup', e => {
  if (isDragging && dragDist < 5 && activeTab === 1) {
    // Pick 3D node on click
    const rect = canvas.getBoundingClientRect();
    const mx = e.clientX - rect.left, my = e.clientY - rect.top;
    let best = -1, bestDepth = 1e9;
    for (const p of projected3DNodes) {
      const d = Math.hypot(mx - p.sx, my - p.sy);
      if (d <= (p.r || 6) + 4 && p.depth < bestDepth) {
        bestDepth = p.depth;
        best = p.i;
      }
    }
    if (best >= 0) {
      activeNode3D = best;
      draw();
    }
  }
  isDragging = false;
});

window.addEventListener('mousemove', e => {
  const rect = canvas.getBoundingClientRect();
  const mx = e.clientX - rect.left, my = e.clientY - rect.top;
  const W = rect.width, H = rect.height;

  if (isDragging) {
    const dx = e.clientX - lastMouse[0];
    const dy = e.clientY - lastMouse[1];
    dragDist += Math.hypot(dx, dy);
    lastMouse = [e.clientX, e.clientY];

    if (activeTab === 1) {
      if (dragBtn === 2 || e.shiftKey) {
        const pan = 0.0012 / zoomFactor;
        camTarget3D[0] -= dx * Math.cos(camYaw) * pan;
        camTarget3D[1] -= dx * Math.sin(camYaw) * pan;
        camTarget3D[2] += dy * pan;
      } else {
        camYaw += dx * 0.0075;
        camPitch = Math.max(-1.35, Math.min(1.35, camPitch + dy * 0.0075));
      }
    } else {
      const baseScale = Math.min((W - 80) / 1.0, (H - 120) / 0.36) * zoomFactor;
      viewCenterX -= dx / baseScale;
      viewCenterY += dy / baseScale;
    }
    draw();
    return;
  }

  if (mx < 0 || my < 0 || mx > W || my > H) return;

  if (activeTab === 1) {
    let best = -1, bestDepth = 1e9;
    for (const p of projected3DNodes) {
      const d = Math.hypot(mx - p.sx, my - p.sy);
      if (d <= (p.r || 6) + 3 && p.depth < bestDepth) {
        bestDepth = p.depth;
        best = p.i;
      }
    }
    if (best >= 0 && best !== activeNode3D) {
      activeNode3D = best;
      draw();
    }
  } else if (activeTab === 2) {
    let best = -1, bestDist = 26.0;
    for (let i = 0; i < P2.n_nodes; i++) {
      const [sx, sy] = worldToScreen2D(P2.x[i], P2.y[i], W, H);
      const d = Math.hypot(mx - sx, my - sy);
      if (d < bestDist) { bestDist = d; best = i; }
    }
    if (best >= 0 && best !== activeNode2D) {
      activeNode2D = best;
      draw();
    }
  }
});

// UI Controls
function switchTab(t) {
  activeTab = t;
  ['tabBtn1', 'tabBtn2', 'tabBtn3'].forEach((id, idx) => {
    document.getElementById(id).classList.toggle('active', idx + 1 === t);
  });
  if (t === 2 && compareMode === 'both') setCompareMode('uncorr');
  draw();
}
document.getElementById('tabBtn1').addEventListener('click', () => switchTab(1));
document.getElementById('tabBtn2').addEventListener('click', () => switchTab(2));
document.getElementById('tabBtn3').addEventListener('click', () => switchTab(3));

function setCompareMode(m) {
  compareMode = m;
  document.getElementById('pillBoth').className = 'mode-pill' + (m === 'both' ? ' active-both' : '');
  document.getElementById('pillUncorr').className = 'mode-pill' + (m === 'uncorr' ? ' active-bad' : '');
  document.getElementById('pillCorr').className = 'mode-pill' + (m === 'corr' ? ' active-good' : '');
  draw();
}
document.getElementById('pillBoth').addEventListener('click', () => {
  if (activeTab === 2) switchTab(1);
  setCompareMode('both');
});
document.getElementById('pillUncorr').addEventListener('click', () => setCompareMode('uncorr'));
document.getElementById('pillCorr').addEventListener('click', () => setCompareMode('corr'));

document.getElementById('phenomSelect').addEventListener('change', draw);
['chk3DWaveHeight', 'chk3DLattice', 'chkShowSym', 'chkShowOs', 'chkShowHorizon', 'chkShowArrows'].forEach(id => {
  document.getElementById(id).addEventListener('change', draw);
});

document.getElementById('btnZoomInterface').addEventListener('click', () => {
  camTarget3D = [0.50, 0.075, 0.075];
  viewCenterX = 0.50; viewCenterY = 0.15;
  zoomFactor = 2.4;
  document.getElementById('sliderZoom').value = 240;
  document.getElementById('lblZoom').textContent = '2.4x';
  draw();
});

document.getElementById('btnResetZoom').addEventListener('click', () => {
  camYaw = -1.12; camPitch = 0.44;
  camTarget3D = [0.50, 0.075, 0.075];
  viewCenterX = 0.50; viewCenterY = 0.15;
  zoomFactor = 1.15;
  document.getElementById('sliderZoom').value = 115;
  document.getElementById('lblZoom').textContent = '1.2x';
  draw();
});

document.getElementById('btnTour3DWave').addEventListener('click', () => {
  switchTab(1);
  setCompareMode('both');
  camYaw = -1.12; camPitch = 0.44;
  camTarget3D = [0.50, 0.075, 0.075];
  zoomFactor = 1.15;
  isPlaying = true;
  document.getElementById('btnPlayPause').innerHTML = '&#10074;&#10074; Pause Wave';
  draw();
});

document.getElementById('btnTourFine').addEventListener('click', () => {
  switchTab(1);
  setCompareMode('uncorr');
  activeNode3D = B3.default_fine;
  camTarget3D = [B3.x[activeNode3D], B3.y[activeNode3D], B3.z[activeNode3D]];
  zoomFactor = 2.6;
  document.getElementById('sliderZoom').value = 260;
  document.getElementById('lblZoom').textContent = '2.6x';
  draw();
});

document.getElementById('btnTourCoarse').addEventListener('click', () => {
  switchTab(1);
  setCompareMode('uncorr');
  activeNode3D = B3.default_coarse;
  camTarget3D = [B3.x[activeNode3D], B3.y[activeNode3D], B3.z[activeNode3D]];
  zoomFactor = 2.3;
  document.getElementById('sliderZoom').value = 230;
  document.getElementById('lblZoom').textContent = '2.3x';
  draw();
});

sliderTime.addEventListener('input', e => {
  frameIdx = parseInt(e.target.value, 10);
  draw();
});

document.getElementById('sliderFps').addEventListener('input', e => {
  fps = parseInt(e.target.value, 10);
  document.getElementById('lblFps').textContent = `${fps} fps`;
});

document.getElementById('sliderWaveAmp').addEventListener('input', e => {
  waveHeightScale = parseInt(e.target.value, 10) / 100.0;
  draw();
});

document.getElementById('sliderZoom').addEventListener('input', e => {
  zoomFactor = parseInt(e.target.value, 10) / 100.0;
  document.getElementById('lblZoom').textContent = `${zoomFactor.toFixed(1)}x`;
  draw();
});

document.getElementById('btnPlayPause').addEventListener('click', () => {
  isPlaying = !isPlaying;
  document.getElementById('btnPlayPause').innerHTML = isPlaying ? '&#10074;&#10074; Pause Wave' : '&#9654; Play Wave';
});

function loop(ts) {
  if (isPlaying && ts - lastTick >= 1000.0 / fps) {
    frameIdx = (frameIdx + 1) % B3.times_ms.length;
    sliderTime.value = frameIdx;
    draw();
    lastTick = ts;
  }
  requestAnimationFrame(loop);
}

resize();
requestAnimationFrame(loop);
</script>
</body>
</html>
"""


def main():
    print("Building 3D + 2D + 1D Visual Peridynamics Bond, Horizon & Wave Explorer...")
    data = build_complete_dataset()
    out_html = os.path.join(HERE, "interactive_3d_bonds_and_nodes.html")
    html_content = HTML_TEMPLATE.replace("__SIM_DATA_JSON__", json.dumps(data, separators=(",", ":")))
    with open(out_html, "w", encoding="utf-8") as f:
        f.write(html_content)
    print(f"Saved complete 3D/2D/1D interactive explorer: {out_html} ({os.path.getsize(out_html) / 1024:.1f} KB)")


if __name__ == "__main__":
    main()
