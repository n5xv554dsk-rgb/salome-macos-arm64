#!/usr/bin/env python3
"""
Generate a User-Friendly, PhET / 3Blue1Brown-Style Interactive Peridynamics Explorer (.html)
============================================================================================
Creates `examples/interactive_3d_bonds_and_nodes.html` — a clean, intuitive, interactive visual
simulation where you can:
  - Scroll the mouse wheel (Google-Maps style, zooming directly toward your cursor!) from the
    macroscopic wave view right into individual nodes, bonds, and horizon circles.
  - Simply move your mouse over ANY node to see its Horizon Circle (delta_i = 3 * dx_i),
    its Kept Symmetric Bonds (|xi| <= min(delta_i, delta_j)), its Excluded One-Sided Bonds
    (min(delta_i, delta_j) < |xi| <= max(delta_i, delta_j)), and the exact Left vs. Right
    Force Balance vectors showing WHY Ghost Forces happen and HOW our method eliminates them.
  - Switch between 3 clear visual views:
      1. Side-by-Side Wave & Lattice Microscope (Uncorrected vs. Our Ghost-Free PD)
      2. Interactive Bond & Ghost-Force Microscope (Hover any node to see Horizon & Force Balance)
      3. Clean 2.5D / 3D Lattice Slice (Rotatable & Zoomable with Physical Deforming Nodes)

Usage:
    ./salome python examples/generate_interactive_3d_viewer.py
    open examples/interactive_3d_bonds_and_nodes.html
"""

import json
import os
import sys
import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, ".."))
sys.path.insert(0, os.path.join(ROOT, "pd_dynamic"))
sys.path.insert(0, ROOT)

from pdsalome.multiscale import MultiscaleBondPD  # noqa: E402
from tests.test_multiscale_pd import make_1d_graded_bar, make_2d_graded_plate  # noqa: E402


def build_user_friendly_dataset():
    """
    Build two crystal-clear datasets:
      A. 1D Graded Bar (dx_fine=0.01, dx_coarse=0.02 on [0, 1.0] m -> 75 nodes so every single
         node and bond is large, distinct, and easy to see & hover!) plus high-res wave curves.
      B. 2D Graded Lattice Strip (dx_fine=0.025, dx_coarse=0.05 on [0, 1.0] x [0, 0.30] m ->
         312 nodes in a clean 2D grid where every horizon circle delta_i = 3*dx_i and bond
         is visually crystal-clear!).
    """
    # --- Part A: 1D Wave & Ghost-Force Simulation (Clean 1D Lattice + Wave) ---
    coords_1d, vols_1d, bounds_1d = make_1d_graded_bar(dx_fine=0.005, dx_coarse=0.01, L=1.0)
    x1 = coords_1d[:, 0]
    E, rho = 100.0, 1.0
    c0 = np.sqrt(E / rho)  # 10 m/s

    amp = 1.0e-4
    w = 0.055
    x0 = 0.24
    u0_w = amp * np.exp(-((x1 - x0) / w) ** 2)[:, None]
    du0_dx = amp * (-2.0 * (x1 - x0) / (w ** 2)) * np.exp(-((x1 - x0) / w) ** 2)
    v0_w = (-c0 * du0_dx)[:, None]

    dt = 0.2 * 0.005 / c0
    t_end = 0.050
    n_steps = int(round(t_end / dt))
    n_frames = 60
    rec = max(1, n_steps // n_frames)

    pd1_uncorr = MultiscaleBondPD(coords_1d, vols_1d, E=E, rho=rho, m=3.0, dim=1, mode="symmetric", stiffness_correction=False, ghost_force_correction=False, domain_bounds=bounds_1d)
    pd1_g0 = MultiscaleBondPD(coords_1d, vols_1d, E=E, rho=rho, m=3.0, dim=1, mode="symmetric", stiffness_correction=True, ghost_force_correction=False, domain_bounds=bounds_1d)
    pd1_dh = MultiscaleBondPD(coords_1d, vols_1d, E=E, rho=rho, m=3.0, dim=1, mode="dual_horizon", stiffness_correction=True, ghost_force_correction=False, domain_bounds=bounds_1d)
    pd1_corr = MultiscaleBondPD(coords_1d, vols_1d, E=E, rho=rho, m=3.0, dim=1, mode="symmetric", stiffness_correction=True, ghost_force_correction=True, domain_bounds=bounds_1d)

    out_w_uncorr = pd1_uncorr.run_dynamic(u0_w, v0_w, dt=dt, n_steps=n_steps, record_every=rec)
    out_w_g0 = pd1_g0.run_dynamic(u0_w, v0_w, dt=dt, n_steps=n_steps, record_every=rec)
    out_w_dh = pd1_dh.run_dynamic(u0_w, v0_w, dt=dt, n_steps=n_steps, record_every=rec)
    out_w_corr = pd1_corr.run_dynamic(u0_w, v0_w, dt=dt, n_steps=n_steps, record_every=rec)

    # Uniform strain dynamic ghost-force radiation in 1D
    eps0 = 0.002
    u0_g = eps0 * coords_1d
    v0_g = np.zeros_like(u0_g)
    fixed_1d = np.where(~pd1_corr.interior_mask)[0]

    _, fg1_uncorr = pd1_uncorr.compute_forces(u0_g)
    _, fg1_g0 = pd1_g0.compute_forces(u0_g)
    _, fg1_dh = pd1_dh.compute_forces(u0_g)
    _, fg1_corr = pd1_corr.compute_forces(u0_g)

    out_g_uncorr = pd1_uncorr.run_dynamic(u0_g, v0_g, dt=dt, n_steps=n_steps, fixed_dofs=fixed_1d, record_every=rec)
    out_g_corr = pd1_corr.run_dynamic(u0_g, v0_g, dt=dt, n_steps=n_steps, fixed_dofs=fixed_1d, record_every=rec)

    # --- Part B: 2D Graded Lattice for Interactive Bond & Horizon Circle Explorer ---
    coords_2d, vols_2d, bounds_2d = make_2d_graded_plate(dx_fine=0.025, dx_coarse=0.05, Lx=1.0, Ly=0.30)
    pd2_uncorr = MultiscaleBondPD(coords_2d, vols_2d, E=E, rho=rho, m=3.0, dim=2, mode="symmetric", stiffness_correction=False, ghost_force_correction=False, domain_bounds=bounds_2d)
    pd2_corr = MultiscaleBondPD(coords_2d, vols_2d, E=E, rho=rho, m=3.0, dim=2, mode="symmetric", stiffness_correction=True, ghost_force_correction=True, domain_bounds=bounds_2d)
    pd2_dh = MultiscaleBondPD(coords_2d, vols_2d, E=E, rho=rho, m=3.0, dim=2, mode="dual_horizon", stiffness_correction=True, ghost_force_correction=False, domain_bounds=bounds_2d)

    u2_unif = np.column_stack([eps0 * coords_2d[:, 0], np.zeros(len(coords_2d))])
    _, fg2_uncorr = pd2_uncorr.compute_forces(u2_unif)
    _, fg2_corr = pd2_corr.compute_forces(u2_unif)

    # Also compute left-pull vs right-pull force density on each 2D node under uniform strain
    # so we can draw the exact Left Force Arrow and Right Force Arrow on the hovered node!
    f_left_uncorr = np.zeros(pd2_uncorr.n_nodes)
    f_right_uncorr = np.zeros(pd2_uncorr.n_nodes)
    f_left_corr = np.zeros(pd2_corr.n_nodes)
    f_right_corr = np.zeros(pd2_corr.n_nodes)

    du2 = u2_unif[pd2_corr.bond_j] - u2_unif[pd2_corr.bond_i]
    s2 = np.sum(pd2_corr.unit_xi * du2, axis=1) / pd2_corr.xi_len
    fx_uncorr_b = pd2_uncorr.g_ij * pd2_uncorr.c_ij * s2 * pd2_uncorr.unit_xi[:, 0]
    fx_corr_b = pd2_corr.g_ij * pd2_corr.c_ij * s2 * pd2_corr.unit_xi[:, 0]

    for b_idx in range(pd2_corr.n_bonds):
        i = int(pd2_corr.bond_i[b_idx])
        j = int(pd2_corr.bond_j[b_idx])
        xi_x = coords_2d[j, 0] - coords_2d[i, 0]
        # Force density on i from j is +fx * V_j; on j from i is -fx * V_i
        fi_u = fx_uncorr_b[b_idx] * vols_2d[j]
        fj_u = -fx_uncorr_b[b_idx] * vols_2d[i]
        fi_c = fx_corr_b[b_idx] * vols_2d[j]
        fj_c = -fx_corr_b[b_idx] * vols_2d[i]
        if xi_x >= 0:
            f_right_uncorr[i] += fi_u; f_left_uncorr[j] += fj_u
            f_right_corr[i] += fi_c; f_left_corr[j] += fj_c
        else:
            f_left_uncorr[i] += fi_u; f_right_uncorr[j] += fj_u
            f_left_corr[i] += fi_c; f_right_corr[j] += fj_c

    os2_mask = ~pd2_dh.bond_is_mutual
    os2_i = pd2_dh.bond_i[os2_mask]
    os2_j = pd2_dh.bond_j[os2_mask]
    os2_len = pd2_dh.xi_len[os2_mask]

    # Pick default transition-zone fine node & coarse node near center y = 0.15
    tz_fine = np.where((coords_2d[:, 0] > 0.48) & (coords_2d[:, 0] < 0.50) & (np.abs(coords_2d[:, 1] - 0.15) < 0.02))[0]
    tz_coarse = np.where((coords_2d[:, 0] > 0.50) & (coords_2d[:, 0] < 0.54) & (np.abs(coords_2d[:, 1] - 0.15) < 0.03))[0]

    return {
        "bar1d": {
            "n_nodes": int(pd1_corr.n_nodes),
            "x": np.round(x1, 5).tolist(),
            "dx_mm": np.round(pd1_corr.dx * 1e3, 2).tolist(),
            "delta_mm": np.round(pd1_corr.delta * 1e3, 2).tolist(),
            "times_ms": np.round(out_w_corr["history_t"] * 1e3, 2).tolist(),
            "sym_bonds_i": pd1_corr.bond_i.tolist(),
            "sym_bonds_j": pd1_corr.bond_j.tolist(),
            "sym_bonds_g": np.round(pd1_corr.g_ij, 4).tolist(),
            "os_bonds_i": pd1_dh.bond_i[~pd1_dh.bond_is_mutual].tolist(),
            "os_bonds_j": pd1_dh.bond_j[~pd1_dh.bond_is_mutual].tolist(),
            "fg_uncorr": np.round(fg1_uncorr[:, 0], 4).tolist(),
            "fg_g0": np.round(fg1_g0[:, 0], 4).tolist(),
            "fg_dh": np.round(fg1_dh[:, 0], 4).tolist(),
            "fg_corr": np.round(fg1_corr[:, 0], 15).tolist(),
            "wave_uncorr": np.round(out_w_uncorr["history_u"][:, :, 0] / amp, 4).tolist(),
            "wave_g0": np.round(out_w_g0["history_u"][:, :, 0] / amp, 4).tolist(),
            "wave_dh": np.round(out_w_dh["history_u"][:, :, 0] / amp, 4).tolist(),
            "wave_corr": np.round(out_w_corr["history_u"][:, :, 0] / amp, 4).tolist(),
            "ghost_uncorr_um": np.round((out_g_uncorr["history_u"][:, :, 0] - u0_g[None, :, 0]) * 1e6, 3).tolist(),
            "ghost_corr_um": np.round((out_g_corr["history_u"][:, :, 0] - u0_g[None, :, 0]) * 1e6, 14).tolist(),
        },
        "plate2d": {
            "Lx": 1.0,
            "Ly": 0.30,
            "n_nodes": int(pd2_corr.n_nodes),
            "default_fine": int(tz_fine[0]) if len(tz_fine) else 0,
            "default_coarse": int(tz_coarse[0]) if len(tz_coarse) else 0,
            "x": np.round(coords_2d[:, 0], 5).tolist(),
            "y": np.round(coords_2d[:, 1], 5).tolist(),
            "dx_mm": np.round(pd2_corr.dx * 1e3, 2).tolist(),
            "delta_mm": np.round(pd2_corr.delta * 1e3, 2).tolist(),
            "lambda_node": np.round(pd2_corr.lambda_node, 4).tolist(),
            "fg_uncorr": np.round(fg2_uncorr[:, 0], 4).tolist(),
            "fg_corr": np.round(fg2_corr[:, 0], 15).tolist(),
            "f_left_uncorr": np.round(f_left_uncorr, 3).tolist(),
            "f_right_uncorr": np.round(f_right_uncorr, 3).tolist(),
            "f_left_corr": np.round(f_left_corr, 3).tolist(),
            "f_right_corr": np.round(f_right_corr, 3).tolist(),
            "sym_bonds": {
                "i": pd2_corr.bond_i.tolist(),
                "j": pd2_corr.bond_j.tolist(),
                "len_mm": np.round(pd2_corr.xi_len * 1e3, 2).tolist(),
                "g_corr": np.round(pd2_corr.g_ij, 4).tolist(),
            },
            "os_bonds": {
                "i": os2_i.tolist(),
                "j": os2_j.tolist(),
                "len_mm": np.round(os2_len * 1e3, 2).tolist(),
            },
        },
    }


HTML_TEMPLATE = """<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Variable-Horizon Peridynamics — Visual Node, Bond & Wave Explorer</title>
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; }
  body { background: #f8fafc; color: #0f172a; display: flex; flex-direction: column; height: 100vh; overflow: hidden; }

  /* Clean Header with 2 Big Intuitive Mode Tabs */
  header {
    background: #ffffff; border-bottom: 2px solid #e2e8f0; padding: 10px 20px;
    display: flex; align-items: center; justify-content: space-between; gap: 14px; flex-wrap: wrap;
    box-shadow: 0 1px 4px rgba(15, 23, 42, 0.04);
  }
  .brand h1 { font-size: 17px; font-weight: 800; color: #1e3a8a; }
  .brand p { font-size: 12.5px; color: #475569; margin-top: 2px; }

  .tabs { display: flex; gap: 8px; background: #f1f5f9; padding: 4px; border-radius: 10px; border: 1px solid #cbd5e1; }
  .tab-btn {
    border: none; background: transparent; color: #475569; font-weight: 700; font-size: 13px;
    padding: 8px 16px; border-radius: 7px; cursor: pointer; transition: all 0.15s;
  }
  .tab-btn:hover { color: #0f172a; background: #e2e8f0; }
  .tab-btn.active { background: #1e3a8a; color: #ffffff; box-shadow: 0 2px 6px rgba(30, 58, 138, 0.25); }

  .quick-actions { display: flex; align-items: center; gap: 8px; }
  .btn {
    background: #ffffff; color: #1e293b; border: 1.5px solid #94a3b8; border-radius: 7px;
    padding: 7px 13px; font-size: 12.5px; font-weight: 600; cursor: pointer; transition: all 0.15s;
  }
  .btn:hover { border-color: #1e3a8a; background: #eff6ff; color: #1e3a8a; }
  .btn-green { background: #059669; color: white; border-color: #047857; }
  .btn-green:hover { background: #047857; color: white; }
  .btn-orange { background: #ea580c; color: white; border-color: #c2410c; }
  .btn-orange:hover { background: #c2410c; color: white; }

  /* Main Layout */
  .workspace { display: flex; flex: 1; overflow: hidden; }
  .viewport-col { flex: 1; display: flex; flex-direction: column; position: relative; background: #ffffff; }
  canvas { display: block; width: 100%; height: 100%; cursor: grab; }
  canvas:active { cursor: grabbing; }

  /* Top Floating Explainer Banner inside Viewport */
  .explainer-banner {
    position: absolute; top: 12px; left: 16px; right: 16px; pointer-events: none;
    background: rgba(255, 255, 255, 0.95); border: 1.5px solid #cbd5e1; border-left: 6px solid #1e3a8a;
    border-radius: 10px; padding: 10px 16px; box-shadow: 0 4px 12px rgba(15, 23, 42, 0.08);
    display: flex; align-items: center; justify-content: space-between; gap: 16px;
  }
  .explainer-text { font-size: 13.5px; line-height: 1.45; color: #1e293b; }
  .explainer-text b { color: #1e3a8a; }
  .zoom-hint {
    background: #eff6ff; border: 1px solid #bfdbfe; color: #1d4ed8; font-weight: 700;
    font-size: 12px; padding: 6px 11px; border-radius: 6px; white-space: nowrap;
  }

  /* Right Inspector Panel — Simple, Visual, Easy to Read */
  .sidebar {
    width: 375px; background: #f8fafc; border-left: 2px solid #e2e8f0; padding: 14px;
    overflow-y: auto; display: flex; flex-direction: column; gap: 12px;
  }
  .panel-card {
    background: #ffffff; border: 1.5px solid #e2e8f0; border-radius: 10px; padding: 13px;
    box-shadow: 0 1px 3px rgba(15,23,42,0.03);
  }
  .panel-card h3 {
    font-size: 13px; text-transform: uppercase; letter-spacing: 0.5px; color: #1e3a8a;
    margin-bottom: 9px; border-bottom: 1.5px solid #f1f5f9; padding-bottom: 5px;
  }

  /* Big Toggle Switch for Ghost-Free Correction */
  .mode-pill-group { display: flex; gap: 6px; margin-bottom: 8px; }
  .mode-pill {
    flex: 1; text-align: center; padding: 8px 6px; border-radius: 7px; font-size: 12px;
    font-weight: 700; cursor: pointer; border: 1.5px solid #cbd5e1; background: #f8fafc; color: #475569;
  }
  .mode-pill.active-bad { background: #fff7ed; border-color: #ea580c; color: #c2410c; }
  .mode-pill.active-good { background: #ecfdf5; border-color: #059669; color: #047857; }

  .stat-row { display: flex; justify-content: space-between; font-size: 13px; padding: 4.5px 0; border-bottom: 1px dashed #e2e8f0; }
  .stat-row span:first-child { color: #475569; }
  .stat-row span:last-child { font-weight: 700; color: #0f172a; font-family: ui-monospace, SFMono-Regular, Menlo, monospace; }

  /* Visual Force Balance Bar */
  .force-balance-box {
    background: #f8fafc; border: 1px solid #cbd5e1; border-radius: 8px; padding: 10px; margin-top: 8px;
  }
  .fb-title { font-size: 12px; font-weight: 700; color: #334155; text-align: center; margin-bottom: 6px; }
  .fb-row { display: flex; align-items: center; justify-content: space-between; font-size: 12px; margin: 4px 0; }
  .fb-verdict {
    margin-top: 8px; padding: 7px 10px; border-radius: 6px; font-size: 12.5px; font-weight: 700; text-align: center;
  }
  .verdict-bad { background: #fef2f2; border: 1px solid #f87171; color: #b91c1c; }
  .verdict-good { background: #ecfdf5; border: 1px solid #34d399; color: #047857; }

  .legend-item { display: flex; align-items: center; gap: 9px; font-size: 12.5px; color: #334155; margin: 6px 0; cursor: pointer; }
  .legend-line { width: 24px; height: 4px; border-radius: 2px; display: inline-block; }

  /* Bottom Playback Bar */
  .bottom-bar {
    background: #ffffff; border-top: 2px solid #e2e8f0; padding: 10px 20px;
    display: flex; align-items: center; gap: 18px; flex-wrap: wrap;
  }
  .ctrl-group { display: flex; align-items: center; gap: 8px; font-size: 13px; font-weight: 600; color: #334155; }
  input[type=range] { accent-color: #1e3a8a; cursor: pointer; }
</style>
</head>
<body>

<header>
  <div class="brand">
    <h1>Variable-Horizon Peridynamics — Visual Node, Bond &amp; Wave Microscope</h1>
    <p>Move mouse over any node to see its Horizon &delta;<sub>i</sub> = 3&Delta;x<sub>i</sub> &amp; Bonds | Scroll mouse wheel to zoom right into the lattice!</p>
  </div>

  <div class="tabs">
    <button class="tab-btn active" id="tabBtn1">&#128269; 1. Interactive Bond &amp; Ghost-Force Microscope</button>
    <button class="tab-btn" id="tabBtn2">&#127754; 2. Wave &amp; Deforming Lattice (Side-by-Side)</button>
  </div>

  <div class="quick-actions">
    <button class="btn" id="btnZoomInterface">&#127919; Zoom to Interface (x = 0.50 m)</button>
    <button class="btn" id="btnResetZoom">&#128260; Reset Full View</button>
  </div>
</header>

<div class="workspace">
  <div class="viewport-col">
    <div class="explainer-banner" id="explainerBanner">
      <div class="explainer-text" id="bannerText">
        <b>Move your mouse over any node</b> to inspect its <b>Horizon Circle (&delta;<sub>i</sub> = 3&Delta;x<sub>i</sub>)</b>, its <b>Kept Symmetric Bonds</b> (solid green), and any <b>Excluded One-Sided Bonds</b> (dashed red).
      </div>
      <div class="zoom-hint">&#128433; Scroll Wheel = Zoom to Cursor | Drag = Pan</div>
    </div>
    <canvas id="mainCanvas"></canvas>
  </div>

  <div class="sidebar">
    <!-- Formulation Toggle Card -->
    <div class="panel-card">
      <h3>1. Formulation Comparison Switch</h3>
      <div class="mode-pill-group">
        <div class="mode-pill active-bad" id="pillUncorr">&#10060; Uncorrected (g<sub>ij</sub> = 1)<br><small>Has Ghost Force &amp; Refl.</small></div>
        <div class="mode-pill" id="pillCorr">&#9989; Ghost-Free (Ours)<br><small>Zero Ghost Force!</small></div>
      </div>
      <p style="font-size:12px;color:#475569;line-height:1.45;" id="formulationDesc">
        Currently viewing <b>Uncorrected Variable-Horizon PD (g<sub>ij</sub> = 1)</b>: nodes near the interface pull unevenly on left vs. right neighbors, creating a phantom <b>Ghost Force</b>!
      </p>
    </div>

    <!-- Hovered / Selected Node & Force Balance Card -->
    <div class="panel-card">
      <h3>2. Node &amp; Horizon Inspector <small style="font-weight:normal;color:#64748b;">(Hover or Click)</small></h3>
      <div class="stat-row"><span>Inspected Node</span><span id="stNodeId">Node #0</span></div>
      <div class="stat-row"><span>Mesh Region</span><span id="stRegion">Fine Region</span></div>
      <div class="stat-row"><span>Position (x, y)</span><span id="stPos">(0.487, 0.150) m</span></div>
      <div class="stat-row"><span>Cell Spacing &Delta;x<sub>i</sub></span><span id="stDx">25.0 mm</span></div>
      <div class="stat-row"><span>Horizon Radius &delta;<sub>i</sub> = 3&Delta;x<sub>i</sub></span><span id="stDelta">75.0 mm</span></div>
      <div class="stat-row"><span>Kept Symmetric Bonds</span><span id="stSym" style="color:#059669;">28 bonds</span></div>
      <div class="stat-row"><span>Excluded One-Sided Bonds</span><span id="stOs" style="color:#dc2626;">6 bonds</span></div>

      <div class="force-balance-box">
        <div class="fb-title">Uniform-Strain Force Balance on This Node</div>
        <div class="fb-row">
          <span style="color:#2563eb;font-weight:700;">&larr; Left Bonds Pull:</span>
          <span id="stPullLeft" style="font-family:monospace;font-weight:700;">-18.40 N/m²</span>
        </div>
        <div class="fb-row">
          <span style="color:#d97706;font-weight:700;">Right Bonds Pull: &rarr;</span>
          <span id="stPullRight" style="font-family:monospace;font-weight:700;">+14.20 N/m²</span>
        </div>
        <div class="fb-verdict verdict-bad" id="stVerdict">
          &#9888; Net Ghost Force = -4.20 N/m² (Imbalanced!)
        </div>
      </div>
    </div>

    <!-- Visual Legend & Layers Card -->
    <div class="panel-card">
      <h3>3. Visual Layers &amp; Bond Legend</h3>
      <label class="legend-item">
        <input type="checkbox" id="chkShowSym" checked>
        <span class="legend-line" style="background:#059669;"></span>
        <span><b>Kept Symmetric Bonds</b> (|&xi;| &le; min(&delta;<sub>i</sub>, &delta;<sub>j</sub>))</span>
      </label>
      <label class="legend-item">
        <input type="checkbox" id="chkShowOs" checked>
        <span class="legend-line" style="background:#dc2626;border-top:2px dashed #dc2626;height:0;"></span>
        <span><b>Excluded One-Sided Bonds</b> (only coarse sees fine)</span>
      </label>
      <label class="legend-item">
        <input type="checkbox" id="chkShowHorizon" checked>
        <span style="width:16px;height:16px;border-radius:50%;border:2px solid #2563eb;background:rgba(37,99,235,0.12);display:inline-block;"></span>
        <span><b>Horizon Circle &delta;<sub>i</sub> = 3&Delta;x<sub>i</sub></b> around node</span>
      </label>
      <label class="legend-item">
        <input type="checkbox" id="chkShowArrows" checked>
        <span style="font-weight:900;color:#b91c1c;font-size:15px;">&rarr;</span>
        <span><b>Force Balance &amp; Ghost Force Arrows</b></span>
      </label>
    </div>

    <!-- Quick Jump Presets -->
    <div class="panel-card">
      <h3>4. One-Click Guided Tour</h3>
      <div style="display:flex;flex-direction:column;gap:6px;">
        <button class="btn" id="btnTourFine" style="text-align:left;">&#128309; <b>Step 1:</b> Inspect Fine Node at Interface (x = 0.488 m)</button>
        <button class="btn" id="btnTourCoarse" style="text-align:left;">&#128992; <b>Step 2:</b> Inspect Coarse Node at Interface (x = 0.525 m)</button>
        <button class="btn" id="btnTourInterior" style="text-align:left;">&#9898; <b>Step 3:</b> Inspect Uniform Interior Node (Balanced)</button>
      </div>
    </div>
  </div>
</div>

<!-- Bottom Bar (for Tab 2 Wave & Lattice Animation + Zoom Slider) -->
<div class="bottom-bar">
  <button class="btn btn-green" id="btnPlayPause" style="min-width:105px;">&#9654; Play Wave</button>
  <div class="ctrl-group" style="flex:1;min-width:220px;">
    <span>Wave Time:</span>
    <input type="range" id="sliderTime" min="0" max="50" value="32" style="flex:1;">
    <span id="lblTime" style="font-family:monospace;min-width:85px;">t = 26.7 ms</span>
  </div>
  <div class="ctrl-group">
    <span>Animation Speed:</span>
    <input type="range" id="sliderFps" min="1" max="15" value="4" style="width:95px;">
    <span id="lblFps" style="font-family:monospace;min-width:48px;">4 fps</span>
  </div>
  <div class="ctrl-group">
    <span>Zoom Level:</span>
    <input type="range" id="sliderZoom" min="100" max="600" value="100" style="width:100px;">
    <span id="lblZoom" style="font-family:monospace;min-width:48px;">1.0x</span>
  </div>
</div>

<script>
const DATA = __SIM_DATA_JSON__;
const P2 = DATA.plate2d;
const B1 = DATA.bar1d;

// Build adjacency lists for 2D Lattice (Tab 1)
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

// Build adjacency lists for 1D Bar (Tab 2)
const sym1ByNode = Array.from({length: B1.n_nodes}, () => []);
for (let b = 0; b < B1.sym_bonds_i.length; b++) {
  const i = B1.sym_bonds_i[b], j = B1.sym_bonds_j[b];
  sym1ByNode[i].push({ b, nbr: j, g: B1.sym_bonds_g[b] });
  sym1ByNode[j].push({ b, nbr: i, g: B1.sym_bonds_g[b] });
}
const os1ByNode = Array.from({length: B1.n_nodes}, () => []);
for (let b = 0; b < B1.os_bonds_i.length; b++) {
  const i = B1.os_bonds_i[b], j = B1.os_bonds_j[b];
  os1ByNode[i].push({ b, nbr: j });
  os1ByNode[j].push({ b, nbr: i });
}

// App State
let activeTab = 1; // 1 = 2D Bond & Ghost-Force Microscope, 2 = Wave & Deforming Lattice Side-by-Side
let useCorrected = false; // false = Uncorrected (g_ij = 1), true = Ghost-Free Corrected
let activeNode2D = P2.default_fine;
let activeNode1D = 99; // Fine node right next to x = 0.50 m in 1D bar
let lockNode = false;

// Google-Maps style Pan & Zoom state (world coordinates in [0, 1] m)
let viewCenterX = 0.50;
let viewCenterY = 0.15;
let zoomFactor = 1.35; // 1.0 = full domain, up to 6.0 = single node closeup

// Animation state
let frameIdx = Math.min(34, B1.times_ms.length - 1);
let isPlaying = false;
let fps = 4;
let lastTick = 0;

const canvas = document.getElementById('mainCanvas');
const ctx = canvas.getContext('2d');
const sliderTime = document.getElementById('sliderTime');
sliderTime.max = B1.times_ms.length - 1;
sliderTime.value = frameIdx;

function resize() {
  const r = canvas.parentElement.getBoundingClientRect();
  canvas.width = r.width * window.devicePixelRatio;
  canvas.height = r.height * window.devicePixelRatio;
  ctx.setTransform(window.devicePixelRatio, 0, 0, window.devicePixelRatio, 0, 0);
  draw();
}
window.addEventListener('resize', resize);

// Coordinate transforms for Tab 1 (2D Lattice on [0, 1.0] x [0, 0.30] m)
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

function updateSidebarInspector() {
  const i = activeNode2D;
  const x = P2.x[i], y = P2.y[i];
  const isFine = x < 0.5;
  const inTz = Math.abs(x - 0.5) <= 0.15;

  document.getElementById('stNodeId').textContent = `Node #${i}`;
  document.getElementById('stRegion').textContent =
    (isFine ? 'Fine Mesh (Left)' : 'Coarse Mesh (Right)') + (inTz ? ' — Transition Zone' : ' — Bulk Interior');
  document.getElementById('stPos').textContent = `(${x.toFixed(3)}, ${y.toFixed(3)}) m`;
  document.getElementById('stDx').textContent = `${P2.dx_mm[i].toFixed(1)} mm`;
  document.getElementById('stDelta').textContent = `${P2.delta_mm[i].toFixed(1)} mm`;
  document.getElementById('stSym').textContent = `${sym2ByNode[i].length} symmetric bonds`;
  document.getElementById('stOs').textContent = `${os2ByNode[i].length} one-sided bonds`;

  const fl = useCorrected ? P2.f_left_corr[i] : P2.f_left_uncorr[i];
  const fr = useCorrected ? P2.f_right_corr[i] : P2.f_right_uncorr[i];
  const fnet = useCorrected ? P2.fg_corr[i] : P2.fg_uncorr[i];

  document.getElementById('stPullLeft').textContent = `${fl >= 0 ? '+' : ''}${fl.toFixed(2)} N/m²`;
  document.getElementById('stPullRight').textContent = `${fr >= 0 ? '+' : ''}${fr.toFixed(2)} N/m²`;

  const verdictEl = document.getElementById('stVerdict');
  if (Math.abs(fnet) > 1e-4) {
    verdictEl.className = 'fb-verdict verdict-bad';
    verdictEl.innerHTML = `&#9888; Net Ghost Force = ${fnet >= 0 ? '+' : ''}${fnet.toFixed(2)} N/m² (Pulls ${fnet > 0 ? 'Right &rarr;' : '&larr; Left'}!)`;
  } else {
    verdictEl.className = 'fb-verdict verdict-good';
    verdictEl.innerHTML = `&#9989; Net Ghost Force = 0.00 N/m² (100% Balanced!)`;
  }

  // Update top banner plain-English explanation
  const banner = document.getElementById('bannerText');
  if (activeTab === 1) {
    if (inTz && !useCorrected) {
      banner.innerHTML = `<b>Transition-Zone Node #${i} (x = ${x.toFixed(3)} m):</b> Because fine and coarse bonds meet here, Left Pull (<b>${fl.toFixed(1)}</b>) &ne; Right Pull (<b>+${fr.toFixed(1)}</b>) &rarr; creates a phantom <b>Ghost Force (${fnet.toFixed(2)} N/m²)</b>! Click <b>"Ghost-Free (Ours)"</b> on the right to fix it!`;
    } else if (inTz && useCorrected) {
      banner.innerHTML = `<b>Transition-Zone Node #${i} (x = ${x.toFixed(3)} m) — Ghost-Free Corrected:</b> Stiffness correction <b>g<sub>ij</sub></b> balances Left Pull (<b>${fl.toFixed(1)}</b>) and Right Pull (<b>+${fr.toFixed(1)}</b>) &rarr; <b>Ghost Force = 0.00 N/m²!</b>`;
    } else {
      banner.innerHTML = `<b>Interior Node #${i} (x = ${x.toFixed(3)} m):</b> Surrounded by a uniform neighborhood of ${sym2ByNode[i].length} symmetric bonds inside horizon &delta;<sub>i</sub> = ${P2.delta_mm[i]} mm. Move mouse toward the <b>center dashed line (x = 0.50 m)</b> to see transition-zone bonds!`;
    }
  } else {
    banner.innerHTML = `<b>Wave &amp; Deforming Lattice Microscope:</b> Top shows <b>Uncorrected PD</b> (spurious reflected wave bounces back left); Bottom shows <b>Our Ghost-Free PD</b> (clean transmission). <b>Scroll wheel</b> to zoom into the moving nodes &amp; stretching bonds!`;
  }

  document.getElementById('lblTime').textContent = `t = ${B1.times_ms[frameIdx].toFixed(1)} ms`;
}

// Helper to draw a crisp arrow on canvas
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
  ctx.beginPath();
  ctx.moveTo(x1, y1);
  ctx.lineTo(x2, y2);
  ctx.stroke();

  ctx.beginPath();
  ctx.moveTo(x2, y2);
  ctx.lineTo(x2 - head * ux + head * 0.45 * uy, y2 - head * uy - head * 0.45 * ux);
  ctx.lineTo(x2 - head * ux - head * 0.45 * uy, y2 - head * uy + head * 0.45 * ux);
  ctx.closePath();
  ctx.fill();

  if (label) {
    ctx.font = 'bold 12px -apple-system, sans-serif';
    ctx.textAlign = 'center';
    ctx.fillText(label, (x1 + x2) * 0.5, y1 - 10);
  }
  ctx.restore();
}

// ===========================================================================
// TAB 1 RENDERER: 2D Interactive Bond, Horizon Circle & Ghost-Force Microscope
// ===========================================================================
function drawTab1(W, H) {
  const showSym = document.getElementById('chkShowSym').checked;
  const showOs = document.getElementById('chkShowOs').checked;
  const showHorizon = document.getElementById('chkShowHorizon').checked;
  const showArrows = document.getElementById('chkShowArrows').checked;

  const [x0, y0, scale] = worldToScreen2D(0.0, 0.30, W, H);
  const [xMid, yBot] = worldToScreen2D(0.50, 0.0, W, H);
  const [x1, _] = worldToScreen2D(1.0, 0.0, W, H);

  // 1. Shaded Background Regions: Fine (Left) vs Transition Zone vs Coarse (Right)
  ctx.fillStyle = '#f0f7ff';
  ctx.fillRect(x0, y0, xMid - x0, yBot - y0);
  ctx.fillStyle = '#fffbeb';
  ctx.fillRect(xMid, y0, x1 - xMid, yBot - y0);

  // Transition zone band [0.5 - 0.15, 0.5 + 0.15]
  const [xTzL] = worldToScreen2D(0.35, 0, W, H);
  const [xTzR] = worldToScreen2D(0.65, 0, W, H);
  ctx.fillStyle = 'rgba(254, 215, 170, 0.32)';
  ctx.fillRect(xTzL, y0, xTzR - xTzL, yBot - y0);

  // Region Headers
  ctx.font = 'bold 13px -apple-system, sans-serif';
  ctx.textAlign = 'center';
  ctx.fillStyle = '#1e40af';
  ctx.fillText('FINE HORIZON REGION (dx = 25 mm, \u03b4_fine = 75 mm)', (x0 + xMid) * 0.5, y0 - 12);
  ctx.fillStyle = '#b45309';
  ctx.fillText('COARSE HORIZON REGION (dx = 50 mm, \u03b4_coarse = 150 mm)', (xMid + x1) * 0.5, y0 - 12);

  // Interface vertical line x = 0.50 m
  ctx.save();
  ctx.strokeStyle = '#1e3a8a';
  ctx.lineWidth = 2.5;
  ctx.setLineDash([7, 5]);
  ctx.beginPath(); ctx.moveTo(xMid, y0 - 6); ctx.lineTo(xMid, yBot + 6); ctx.stroke();
  ctx.restore();

  // 2. Draw cell grid boxes around each node so the fine vs coarse cell sizes V_i are visually obvious!
  ctx.strokeStyle = 'rgba(148, 163, 184, 0.35)';
  ctx.lineWidth = 1;
  for (let i = 0; i < P2.n_nodes; i++) {
    const half = 0.5 * P2.dx_mm[i] * 1e-3;
    const [cx1, cy1] = worldToScreen2D(P2.x[i] - half, P2.y[i] + half, W, H);
    const [cx2, cy2] = worldToScreen2D(P2.x[i] + half, P2.y[i] - half, W, H);
    ctx.strokeRect(cx1, cy1, cx2 - cx1, cy2 - cy1);
  }

  const sel = activeNode2D;
  const [selSx, selSy] = worldToScreen2D(P2.x[sel], P2.y[sel], W, H);
  const selDeltaPx = (P2.delta_mm[sel] * 1e-3) * scale;

  // 3. Draw Horizon Circle delta_i = 3 * dx_i around active node
  if (showHorizon) {
    ctx.save();
    const isFine = P2.x[sel] < 0.5;
    ctx.fillStyle = isFine ? 'rgba(37, 99, 235, 0.09)' : 'rgba(217, 119, 6, 0.10)';
    ctx.strokeStyle = isFine ? '#2563eb' : '#d97706';
    ctx.lineWidth = 2.4;
    ctx.beginPath();
    ctx.arc(selSx, selSy, selDeltaPx, 0, 2 * Math.PI);
    ctx.fill();
    ctx.stroke();

    // Horizon radius label
    ctx.fillStyle = isFine ? '#1d4ed8' : '#b45309';
    ctx.font = 'bold 12.5px -apple-system, sans-serif';
    ctx.textAlign = 'center';
    ctx.fillText(`Horizon \u03b4_i = 3\u0394x_i = ${P2.delta_mm[sel]} mm`, selSx, selSy - selDeltaPx - 8);
    ctx.restore();
  }

  // 4. Draw Kept Symmetric Bonds (|xi| <= min(delta_i, delta_j)) for active node
  const symNbrSet = new Set();
  if (showSym) {
    for (const item of sym2ByNode[sel]) {
      symNbrSet.add(item.nbr);
      const [nx, ny] = worldToScreen2D(P2.x[item.nbr], P2.y[item.nbr], W, H);
      ctx.save();
      ctx.strokeStyle = '#059669';
      ctx.lineWidth = Math.max(2.0, Math.min(4.5, 2.2 * item.g));
      ctx.beginPath();
      ctx.moveTo(selSx, selSy);
      ctx.lineTo(nx, ny);
      ctx.stroke();

      // If zoomed in (zoomFactor >= 2.1), show g_ij label on each bond!
      if (zoomFactor >= 2.2) {
        const mx = (selSx + nx) * 0.5, my = (selSy + ny) * 0.5;
        ctx.fillStyle = '#065f46';
        ctx.font = 'bold 10.5px monospace';
        ctx.textAlign = 'center';
        const gVal = useCorrected ? item.g.toFixed(2) : '1.00';
        ctx.fillText(`g=${gVal}`, mx, my - 3);
      }
      ctx.restore();
    }
  }

  // 5. Draw Excluded One-Sided Bonds (min(delta_i, delta_j) < |xi| <= max(delta_i, delta_j))
  const osNbrSet = new Set();
  if (showOs) {
    ctx.save();
    ctx.strokeStyle = '#dc2626';
    ctx.lineWidth = 2.2;
    ctx.setLineDash([6, 4]);
    for (const item of os2ByNode[sel]) {
      osNbrSet.add(item.nbr);
      const [nx, ny] = worldToScreen2D(P2.x[item.nbr], P2.y[item.nbr], W, H);
      ctx.beginPath();
      ctx.moveTo(selSx, selSy);
      ctx.lineTo(nx, ny);
      ctx.stroke();
    }
    ctx.restore();
  }

  // 6. Draw All 2D Nodes
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
    if (fg > 0.25) {
      fill = '#ef4444'; // Highlight nodes experiencing strong ghost force in red!
    }
    if (isSel) fill = '#1e3a8a';
    else if (isSym) fill = '#10b981';
    else if (isOs) fill = '#f87171';

    ctx.beginPath();
    ctx.arc(sx, sy, r, 0, 2 * Math.PI);
    ctx.fillStyle = fill;
    ctx.fill();
    ctx.lineWidth = isSel ? 3.0 : (isSym || isOs ? 2.0 : 1.0);
    ctx.strokeStyle = isSel ? '#ffffff' : '#0f172a';
    ctx.stroke();
  }

  // 7. Draw Force Balance & Ghost Force Arrows on the Active Node
  if (showArrows) {
    const fl = useCorrected ? P2.f_left_corr[sel] : P2.f_left_uncorr[sel];
    const fr = useCorrected ? P2.f_right_corr[sel] : P2.f_right_uncorr[sel];
    const fnet = useCorrected ? P2.fg_corr[sel] : P2.fg_uncorr[sel];
    const arrowScale = 3.2;

    if (Math.abs(fl) > 0.1) {
      drawArrow(selSx - 10, selSy, selSx - 10 + fl * arrowScale, selSy, '#2563eb', 3.5, `Left: ${fl.toFixed(1)}`);
    }
    if (Math.abs(fr) > 0.1) {
      drawArrow(selSx + 10, selSy, selSx + 10 + fr * arrowScale, selSy, '#d97706', 3.5, `Right: +${fr.toFixed(1)}`);
    }
    if (Math.abs(fnet) > 0.05) {
      drawArrow(selSx, selSy + 22, selSx + fnet * 12.0, selSy + 22, '#dc2626', 4.5, `GHOST FORCE: ${fnet.toFixed(2)} N/m²`);
    }
  }
}

// ===========================================================================
// TAB 2 RENDERER: Side-by-Side Wave & Deforming Physical Lattice Microscope
// ===========================================================================
function drawTab2(W, H) {
  const padX = 55;
  const plotW = W - 2 * padX;
  const topY = 82;
  const laneH = (H - topY - 38) * 0.46;
  const gapY = (H - topY - 38) * 0.08;

  const lanes = [
    {
      title: '\u274c 1. UNCORRECTED VARIABLE-HORIZON PD (g_ij = 1) — Spurious Wave Bounces Back at Interface!',
      color: '#c2410c',
      bgFine: '#fff7ed',
      uArr: B1.wave_uncorr[frameIdx],
      yTop: topY,
    },
    {
      title: '\u2705 2. MULTISCALE GHOST-FREE PD (OURS) — Wave Glides Cleanly From Fine Nodes to Coarse Nodes!',
      color: '#047857',
      bgFine: '#ecfdf5',
      uArr: B1.wave_corr[frameIdx],
      yTop: topY + laneH + gapY,
    }
  ];

  // World X -> Screen X using zoomFactor & viewCenterX
  function wxToSx(wx) {
    return W * 0.5 + (wx - viewCenterX) * plotW * zoomFactor;
  }

  for (const lane of lanes) {
    const y0 = lane.yTop;
    const y1 = y0 + laneH;
    const yCurveMid = y0 + laneH * 0.42;
    const yLattice = y0 + laneH * 0.80;

    // Lane box
    ctx.save();
    ctx.beginPath();
    ctx.rect(padX, y0, plotW, laneH);
    ctx.clip();

    const sxLeft = wxToSx(0.0);
    const sxInt = wxToSx(0.50);
    const sxRight = wxToSx(1.0);

    ctx.fillStyle = '#f0f7ff';
    ctx.fillRect(sxLeft, y0, sxInt - sxLeft, laneH);
    ctx.fillStyle = '#fffbeb';
    ctx.fillRect(sxInt, y0, sxRight - sxInt, laneH);

    // Interface line
    ctx.strokeStyle = '#1e3a8a';
    ctx.lineWidth = 2;
    ctx.setLineDash([6, 4]);
    ctx.beginPath(); ctx.moveTo(sxInt, y0); ctx.lineTo(sxInt, y1); ctx.stroke();
    ctx.setLineDash([]);

    // Zero baseline for wave curve
    ctx.strokeStyle = '#cbd5e1';
    ctx.lineWidth = 1;
    ctx.beginPath(); ctx.moveTo(padX, yCurveMid); ctx.lineTo(padX + plotW, yCurveMid); ctx.stroke();

    // Wave curve u(x, t) / A_0
    const ampPx = laneH * 0.30;
    ctx.strokeStyle = lane.color;
    ctx.lineWidth = 3.0;
    ctx.beginPath();
    for (let i = 0; i < B1.n_nodes; i++) {
      const sx = wxToSx(B1.x[i]);
      const sy = yCurveMid - lane.uArr[i] * ampPx;
      if (i === 0) ctx.moveTo(sx, sy); else ctx.lineTo(sx, sy);
    }
    ctx.stroke();

    // Physical Deforming 1D Node-and-Bond Lattice at y = yLattice!
    // Exaggerate physical horizontal node motion so the viewer sees the wave compressing the springs/bonds!
    const dispExag = 0.022;
    const nodeScreenX = new Array(B1.n_nodes);
    for (let i = 0; i < B1.n_nodes; i++) {
      nodeScreenX[i] = wxToSx(B1.x[i] + lane.uArr[i] * dispExag);
    }

    // Draw active node's horizon arch & bonds on the physical lattice
    const sel1 = activeNode1D;
    const selSx = nodeScreenX[sel1];
    const selDeltaPx = (B1.delta_mm[sel1] * 1e-3) * plotW * zoomFactor;

    if (document.getElementById('chkShowHorizon').checked) {
      ctx.fillStyle = 'rgba(37, 99, 235, 0.10)';
      ctx.strokeStyle = '#2563eb';
      ctx.lineWidth = 1.8;
      ctx.beginPath();
      ctx.arc(selSx, yLattice, selDeltaPx, Math.PI, 0, false);
      ctx.fill();
      ctx.stroke();
    }

    if (document.getElementById('chkShowSym').checked) {
      for (const item of sym1ByNode[sel1]) {
        const nbrSx = nodeScreenX[item.nbr];
        const distPx = Math.abs(nbrSx - selSx);
        const hArch = Math.min(34, 8 + distPx * 0.25);
        ctx.strokeStyle = '#059669';
        ctx.lineWidth = 2.0;
        ctx.beginPath();
        ctx.moveTo(selSx, yLattice);
        ctx.quadraticCurveTo((selSx + nbrSx) * 0.5, yLattice - hArch, nbrSx, yLattice);
        ctx.stroke();
      }
    }

    // Draw all physical nodes along yLattice
    for (let i = 0; i < B1.n_nodes; i++) {
      const sx = nodeScreenX[i];
      if (sx < padX - 20 || sx > padX + plotW + 20) continue;
      const isCoarse = B1.x[i] > 0.5;
      const isSel = (i === sel1);
      let r = (isCoarse ? 6.5 : 4.2) * Math.pow(zoomFactor, 0.45);
      if (isSel) r *= 1.4;

      const uVal = lane.uArr[i];
      ctx.beginPath();
      ctx.arc(sx, yLattice, r, 0, 2 * Math.PI);
      ctx.fillStyle = isSel ? '#1e3a8a' : (Math.abs(uVal) > 0.08 ? lane.color : (isCoarse ? '#f59e0b' : '#3b82f6'));
      ctx.fill();
      ctx.lineWidth = isSel ? 2.5 : 1.0;
      ctx.strokeStyle = isSel ? '#ffffff' : '#0f172a';
      ctx.stroke();
    }

    ctx.restore();

    // Border & Title
    ctx.strokeStyle = '#cbd5e1';
    ctx.lineWidth = 1.5;
    ctx.strokeRect(padX, y0, plotW, laneH);
    ctx.fillStyle = lane.color;
    ctx.font = 'bold 13.5px -apple-system, sans-serif';
    ctx.textAlign = 'left';
    ctx.fillText(lane.title, padX + 10, y0 + 20);
  }
}

function draw() {
  const r = canvas.parentElement.getBoundingClientRect();
  const W = r.width, H = r.height;
  ctx.clearRect(0, 0, W, H);
  if (activeTab === 1) drawTab1(W, H);
  else drawTab2(W, H);
  updateSidebarInspector();
}

// ===========================================================================
// Mouse Interaction: Google-Maps Zoom-to-Cursor, Pan, and Hover-to-Inspect
// ===========================================================================
let isDragging = false;
let lastMouse = [0, 0];
let dragMoved = 0;

canvas.addEventListener('wheel', e => {
  e.preventDefault();
  const rect = canvas.getBoundingClientRect();
  const mx = e.clientX - rect.left;
  const my = e.clientY - rect.top;
  const W = rect.width, H = rect.height;

  const [wxBefore, wyBefore] = screenToWorld2D(mx, my, W, H);
  const factor = Math.exp(-e.deltaY * 0.0016);
  zoomFactor = Math.max(1.0, Math.min(6.0, zoomFactor * factor));
  const [wxAfter, wyAfter] = screenToWorld2D(mx, my, W, H);

  // Keep the world point under the mouse cursor stationary!
  viewCenterX += (wxBefore - wxAfter);
  viewCenterY += (wyBefore - wyAfter);

  document.getElementById('sliderZoom').value = Math.round(zoomFactor * 100);
  document.getElementById('lblZoom').textContent = `${zoomFactor.toFixed(1)}x`;
  draw();
}, { passive: false });

canvas.addEventListener('mousedown', e => {
  isDragging = true;
  lastMouse = [e.clientX, e.clientY];
  dragMoved = 0;
});

window.addEventListener('mouseup', () => {
  isDragging = false;
});

window.addEventListener('mousemove', e => {
  const rect = canvas.getBoundingClientRect();
  const mx = e.clientX - rect.left;
  const my = e.clientY - rect.top;
  const W = rect.width, H = rect.height;

  if (isDragging) {
    const dx = e.clientX - lastMouse[0];
    const dy = e.clientY - lastMouse[1];
    dragMoved += Math.hypot(dx, dy);
    lastMouse = [e.clientX, e.clientY];

    const baseScale = Math.min((W - 80) / 1.0, (H - 120) / 0.36) * zoomFactor;
    viewCenterX -= dx / baseScale;
    viewCenterY += dy / baseScale;
    draw();
    return;
  }

  // Hover-to-inspect nearest node!
  if (mx < 0 || my < 0 || mx > W || my > H) return;

  if (activeTab === 1) {
    let best = -1, bestDist = 28.0;
    for (let i = 0; i < P2.n_nodes; i++) {
      const [sx, sy] = worldToScreen2D(P2.x[i], P2.y[i], W, H);
      const d = Math.hypot(mx - sx, my - sy);
      if (d < bestDist) { bestDist = d; best = i; }
    }
    if (best >= 0 && best !== activeNode2D) {
      activeNode2D = best;
      draw();
    }
  } else {
    const padX = 55;
    const plotW = W - 2 * padX;
    const wx = viewCenterX + (mx - W * 0.5) / (plotW * zoomFactor);
    let best1 = 0, bestDx = 1e9;
    for (let i = 0; i < B1.n_nodes; i++) {
      const d = Math.abs(B1.x[i] - wx);
      if (d < bestDx) { bestDx = d; best1 = i; }
    }
    if (best1 !== activeNode1D) {
      activeNode1D = best1;
      draw();
    }
  }
});

// UI Bindings
document.getElementById('tabBtn1').addEventListener('click', () => {
  activeTab = 1;
  document.getElementById('tabBtn1').classList.add('active');
  document.getElementById('tabBtn2').classList.remove('active');
  draw();
});

document.getElementById('tabBtn2').addEventListener('click', () => {
  activeTab = 2;
  document.getElementById('tabBtn2').classList.add('active');
  document.getElementById('tabBtn1').classList.remove('active');
  isPlaying = true;
  document.getElementById('btnPlayPause').innerHTML = '&#10074;&#10074; Pause Wave';
  draw();
});

function setFormulation(corr) {
  useCorrected = corr;
  const pBad = document.getElementById('pillUncorr');
  const pGood = document.getElementById('pillCorr');
  const desc = document.getElementById('formulationDesc');
  if (!corr) {
    pBad.className = 'mode-pill active-bad';
    pGood.className = 'mode-pill';
    desc.innerHTML = 'Currently viewing <b>Uncorrected Variable-Horizon PD (g<sub>ij</sub> = 1)</b>: nodes near the interface pull unevenly on left vs. right neighbors, creating a phantom <b>Ghost Force</b>!';
  } else {
    pBad.className = 'mode-pill';
    pGood.className = 'mode-pill active-good';
    desc.innerHTML = 'Currently viewing <b>Our Ghost-Free Multiscale PD</b>: stiffness correction <b>g<sub>ij</sub></b> balances the bond moments across the interface so <b>Ghost Force = 0.00 N/m²</b> everywhere!';
  }
  draw();
}

document.getElementById('pillUncorr').addEventListener('click', () => setFormulation(false));
document.getElementById('pillCorr').addEventListener('click', () => setFormulation(true));

['chkShowSym', 'chkShowOs', 'chkShowHorizon', 'chkShowArrows'].forEach(id => {
  document.getElementById(id).addEventListener('change', draw);
});

document.getElementById('btnZoomInterface').addEventListener('click', () => {
  viewCenterX = 0.50;
  viewCenterY = 0.15;
  zoomFactor = 2.6;
  activeNode2D = P2.default_fine;
  document.getElementById('sliderZoom').value = 260;
  document.getElementById('lblZoom').textContent = '2.6x';
  draw();
});

document.getElementById('btnResetZoom').addEventListener('click', () => {
  viewCenterX = 0.50;
  viewCenterY = 0.15;
  zoomFactor = 1.15;
  document.getElementById('sliderZoom').value = 115;
  document.getElementById('lblZoom').textContent = '1.2x';
  draw();
});

document.getElementById('btnTourFine').addEventListener('click', () => {
  activeTab = 1;
  document.getElementById('tabBtn1').classList.add('active');
  document.getElementById('tabBtn2').classList.remove('active');
  activeNode2D = P2.default_fine;
  viewCenterX = P2.x[activeNode2D];
  viewCenterY = P2.y[activeNode2D];
  zoomFactor = 2.7;
  draw();
});

document.getElementById('btnTourCoarse').addEventListener('click', () => {
  activeTab = 1;
  document.getElementById('tabBtn1').classList.add('active');
  document.getElementById('tabBtn2').classList.remove('active');
  activeNode2D = P2.default_coarse;
  viewCenterX = P2.x[activeNode2D];
  viewCenterY = P2.y[activeNode2D];
  zoomFactor = 2.5;
  draw();
});

document.getElementById('btnTourInterior').addEventListener('click', () => {
  activeTab = 1;
  document.getElementById('tabBtn1').classList.add('active');
  document.getElementById('tabBtn2').classList.remove('active');
  // Find a fine interior node around x = 0.25, y = 0.15
  let best = 0, bestD = 1e9;
  for (let i = 0; i < P2.n_nodes; i++) {
    const d = Math.hypot(P2.x[i] - 0.2375, P2.y[i] - 0.15);
    if (d < bestD) { bestD = d; best = i; }
  }
  activeNode2D = best;
  viewCenterX = P2.x[best];
  viewCenterY = P2.y[best];
  zoomFactor = 2.5;
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
    frameIdx = (frameIdx + 1) % B1.times_ms.length;
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
    print("Building User-Friendly Visual Peridynamics Bond, Horizon & Wave Explorer...")
    data = build_user_friendly_dataset()
    out_html = os.path.join(HERE, "interactive_3d_bonds_and_nodes.html")
    html_content = HTML_TEMPLATE.replace("__SIM_DATA_JSON__", json.dumps(data, separators=(",", ":")))
    with open(out_html, "w", encoding="utf-8") as f:
        f.write(html_content)
    print(f"Saved user-friendly interactive explorer: {out_html} ({os.path.getsize(out_html) / 1024:.1f} KB)")


if __name__ == "__main__":
    main()
