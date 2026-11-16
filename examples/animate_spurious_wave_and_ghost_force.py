#!/usr/bin/env python3
"""
Animate Spurious Wave Reflection & Transition-Zone Ghost Forces in Variable-Horizon Peridynamics
=================================================================================================
Generates three publication-quality animations (.gif and .mp4):

  1. examples/spurious_wave_reflection_1d.gif (.mp4)
     - Right-traveling Gaussian pulse crossing a fine/coarse horizon interface (x = 0.50 m,
       dx_fine = 2.5 mm -> delta_fine = 7.5 mm, dx_coarse = 5.0 mm -> delta_coarse = 15.0 mm).
     - Compares Uncorrected (g_ij = 1), Energy-Only g_ij^(0), Dual-Horizon PD, and
       Multiscale Ghost-Free Corrected PD.
     - Clearly animates the spurious reflected wave packet peeling off the interface at t ~ 25 ms
       and propagating backward into the fine region in uncorrected models.

  2. examples/ghost_force_radiation_1d.gif (.mp4)
     - Demonstrates what a "Ghost Force" physically does: a bar placed under exact uniform strain
       u(x, 0) = eps_0 * x (which should remain in exact static equilibrium with zero motion)
       experiences non-zero internal ghost forces f_ghost(x) in the fine/coarse transition zone.
     - Animates how these transition-zone ghost forces act as an artificial internal source that
       spontaneously radiates spurious displacement and strain waves outward from the interface
       x = 0.50 m, whereas the Ghost-Free Multiscale formulation stays in exact equilibrium.

  3. examples/spurious_wave_and_ghost_force_2d.gif (.mp4)
     - 2D graded plate ([0, 1.0] x [0, 0.5] m) with fine horizon on the left (x < 0.5 m) and
       coarse horizon on the right (x > 0.5 m).
     - Side-by-side 2D wave-field and ghost-force comparison between Uncorrected Variable-Horizon PD
       and Multiscale Ghost-Free PD.

Usage:
    ./salome python examples/animate_spurious_wave_and_ghost_force.py
"""

import os
import shutil
import subprocess
import sys
import numpy as np
from scipy.sparse import csr_matrix
from scipy.sparse.linalg import lsqr

os.environ.setdefault("MPLCONFIGDIR", "/tmp/mplconfig")
os.makedirs(os.environ["MPLCONFIGDIR"], exist_ok=True)

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, ".."))
sys.path.insert(0, os.path.join(ROOT, "pd_dynamic"))
sys.path.insert(0, ROOT)

from pdsalome.multiscale import MultiscaleBondPD, read_salome_mesh  # noqa: E402
from tests.test_multiscale_pd import (  # noqa: E402
    make_1d_graded_bar,
    make_2d_graded_plate,
    make_3d_graded_block,
)


def configure_style():
    plt.rcParams.update({
        "font.family": "DejaVu Sans",
        "font.size": 9.5,
        "axes.titlesize": 10.5,
        "axes.titleweight": "bold",
        "axes.labelsize": 9.5,
        "xtick.labelsize": 8.5,
        "ytick.labelsize": 8.5,
        "legend.fontsize": 8.2,
        "figure.titlesize": 12.5,
    })


def save_frames_to_gif_and_mp4(frames, gif_path: str, mp4_path: str, fps: int = 15):
    """Save a list of PIL Images as an optimized looping GIF and an MP4 video (if ffmpeg is available)."""
    duration_ms = int(round(1000.0 / fps))
    durations = [duration_ms] * len(frames)
    if durations:
        durations[-1] = duration_ms * 12

    frames[0].save(
        gif_path,
        save_all=True,
        append_images=frames[1:],
        duration=durations,
        loop=0,
        optimize=False,
    )
    print(f"  [Saved GIF] {gif_path} ({os.path.getsize(gif_path) / 1024:.1f} KB, {len(frames)} frames)")

    ffmpeg_bin = shutil.which("ffmpeg")
    if ffmpeg_bin and mp4_path:
        cmd = [
            ffmpeg_bin,
            "-y",
            "-i", gif_path,
            "-movflags", "faststart",
            "-pix_fmt", "yuv420p",
            "-vf", "scale=trunc(iw/2)*2:trunc(ih/2)*2",
            mp4_path,
        ]
        subprocess.run(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=False)
        if os.path.exists(mp4_path):
            print(f"  [Saved MP4] {mp4_path} ({os.path.getsize(mp4_path) / 1024:.1f} KB)")


def fig_to_pil(fig) -> Image.Image:
    """Convert a Matplotlib figure canvas to a PIL RGB Image."""
    fig.canvas.draw()
    rgba = np.asarray(fig.canvas.buffer_rgba())
    return Image.fromarray(rgba).convert("RGB")


# ===========================================================================
# 1. 1D Spurious Wave Reflection Animation at Fine/Coarse Horizon Interface
# ===========================================================================

def generate_1d_spurious_wave_animation():
    print("\n1. Running 1D Spurious Wave Reflection simulation across Fine/Coarse Interface...")
    coords, volumes, bounds = make_1d_graded_bar(dx_fine=0.0025, dx_coarse=0.005, L=1.0)
    x = coords[:, 0]
    E = 100.0
    rho = 1.0
    c0 = np.sqrt(E / rho)  # 10 m/s

    amp = 1.0e-4
    w = 0.055
    x0 = 0.25
    u0 = amp * np.exp(-((x - x0) / w) ** 2)[:, None]
    du0_dx = amp * (-2.0 * (x - x0) / (w ** 2)) * np.exp(-((x - x0) / w) ** 2)
    v0 = (-c0 * du0_dx)[:, None]

    dt = 0.2 * 0.0025 / c0  # 5e-5 s
    t_end = 0.050           # 50 ms
    n_steps = int(round(t_end / dt))
    n_frames = 60
    record_every = max(1, n_steps // n_frames)

    models = [
        ("Uncorrected (g_ij = 1)", "#d95f02", "--", 1.9,
         dict(mode="symmetric", stiffness_correction=False, ghost_force_correction=False)),
        ("Energy-Only g_ij^(0)", "#7570b3", "-.", 1.9,
         dict(mode="symmetric", stiffness_correction=True, ghost_force_correction=False)),
        ("Dual-Horizon PD", "#e7298a", ":", 2.1,
         dict(mode="dual_horizon", stiffness_correction=True, ghost_force_correction=False)),
        ("Multiscale Ghost-Free (Ours)", "#1b9e77", "-", 2.6,
         dict(mode="symmetric", stiffness_correction=True, ghost_force_correction=True)),
    ]

    histories = {}
    final_refl = {}
    fine_window = (x > 0.05) & (x < 0.42)

    for label, color, ls, lw, kw in models:
        pd = MultiscaleBondPD(coords, volumes, E=E, rho=rho, m=3.0, dim=1, domain_bounds=bounds, **kw)
        out = pd.run_dynamic(u0, v0, dt=dt, n_steps=n_steps, record_every=record_every)
        histories[label] = out
        final_refl[label] = float(np.abs(out["u"][fine_window, 0]).max() / amp * 100.0)

    hist_t = histories["Multiscale Ghost-Free (Ours)"]["history_t"]
    frames = []

    for k, t_val in enumerate(hist_t):
        fig = plt.figure(figsize=(10.5, 7.6), dpi=110)
        fig.suptitle(
            f"Variable-Horizon Peridynamics: Spurious Wave Reflection at Horizon Jump  (t = {t_val * 1e3:4.1f} ms)",
            fontsize=12.5, fontweight="bold", color="#1b365d", y=0.965,
        )
        gs = gridspec.GridSpec(
            2, 1, figure=fig, height_ratios=[1.12, 1.0],
            left=0.09, right=0.96, top=0.90, bottom=0.09, hspace=0.35,
        )

        # --- Top Panel: Full Wave Packet Propagation ---
        ax1 = fig.add_subplot(gs[0, 0])
        ax1.axvspan(0.0, 0.5, color="#e8f1f5", alpha=0.55, label=r"Fine Horizon ($\Delta x_f = 2.5$ mm, $\delta_f = 7.5$ mm)")
        ax1.axvspan(0.5, 1.0, color="#fff8e7", alpha=0.65, label=r"Coarse Horizon ($\Delta x_c = 5.0$ mm, $\delta_c = 15.0$ mm)")
        ax1.axvspan(0.5 - 0.015, 0.5 + 0.015, color="#ffd8b1", alpha=0.60, label=r"Transition Zone $[0.5-\delta_c, 0.5+\delta_c]$")
        ax1.axvline(0.5, color="#1b365d", linestyle="--", linewidth=1.6)

        u_exact = np.exp(-((x - (x0 + c0 * t_val)) / w) ** 2)
        ax1.plot(x, u_exact, color="black", linestyle=":", linewidth=1.3, alpha=0.75, label="Exact Continuum Wave")

        for label, color, ls, lw, _ in models:
            u_snap = histories[label]["history_u"][k, :, 0] / amp
            ax1.plot(x, u_snap, linestyle=ls, color=color, linewidth=lw, label=label)

        ax1.set_title(r"1. Full Bar Wave Propagation $u(x, t) / A_0$ Across Fine $\rightarrow$ Coarse Interface ($x = 0.50$ m)")
        ax1.set_xlabel("Position x (m)")
        ax1.set_ylabel(r"Normalized Displacement $u(x, t) / A_0$")
        ax1.set_xlim(0.0, 1.0)
        ax1.set_ylim(-0.18, 1.18)
        ax1.legend(loc="upper left", ncol=2, fontsize=8.0, framealpha=0.92)
        ax1.grid(True, linestyle=":", alpha=0.5)

        # --- Bottom Panel: Zoomed-in View of Spurious Reflection in Fine Region [0.05, 0.55] ---
        ax2 = fig.add_subplot(gs[1, 0])
        ax2.axvspan(0.05, 0.50, color="#e8f1f5", alpha=0.45)
        ax2.axvspan(0.50, 0.55, color="#fff8e7", alpha=0.55)
        ax2.axvspan(0.5 - 0.015, 0.5 + 0.015, color="#ffd8b1", alpha=0.60)
        ax2.axvline(0.5, color="#1b365d", linestyle="--", linewidth=1.6, label="Interface (x = 0.50 m)")

        for label, color, ls, lw, _ in models:
            u_pct = 100.0 * histories[label]["history_u"][k, :, 0] / amp
            lbl_zoom = f"{label} (Max Refl = {final_refl[label]:.2f}%)"
            ax2.plot(x, u_pct, linestyle=ls, color=color, linewidth=lw, label=lbl_zoom)

        if t_val >= 0.032:
            refl_center = 0.50 - c0 * (t_val - 0.025)
            if 0.16 <= refl_center <= 0.42:
                # Find peak value of uncorrected curve near refl_center
                u_uncorr_pct = 100.0 * histories["Uncorrected (g_ij = 1)"]["history_u"][k, :, 0] / amp
                idx_near = np.argmin(np.abs(x - refl_center))
                y_tip = float(np.clip(u_uncorr_pct[idx_near], -7.8, 7.8))
                ax2.annotate(
                    "Spurious Reflected Wave\n(Bouncing Left <- into Fine Region)",
                    xy=(refl_center, y_tip),
                    xytext=(0.33, -7.6),
                    arrowprops=dict(arrowstyle="->", color="#d95f02", lw=1.6),
                    fontsize=8.5, fontweight="bold", color="#b34800",
                    bbox=dict(boxstyle="round,pad=0.25", fc="#fff3e6", ec="#d95f02", alpha=0.94),
                )

        ax2.set_title(r"2. Zoomed View of Fine Region $u(x, t) / A_0$ (% of Peak) — Isolating Spurious Reflection ($t > 25$ ms)")
        ax2.set_xlabel("Position x (m)  [Fine Region: x < 0.50 m]")
        ax2.set_ylabel("Amplitude (% of Incident Peak)")
        ax2.set_xlim(0.05, 0.55)
        ax2.set_ylim(-9.2, 9.2)
        ax2.legend(loc="upper left", fontsize=8.0, framealpha=0.92)
        ax2.grid(True, linestyle=":", alpha=0.5)

        frames.append(fig_to_pil(fig))
        plt.close(fig)

    gif_path = os.path.join(HERE, "spurious_wave_reflection_1d.gif")
    mp4_path = os.path.join(HERE, "spurious_wave_reflection_1d.mp4")
    save_frames_to_gif_and_mp4(frames, gif_path, mp4_path, fps=15)
    return gif_path, mp4_path


# ===========================================================================
# 2. 1D Ghost-Force-Induced Spontaneous Wave Radiation Under Uniform Strain
# ===========================================================================

def generate_1d_ghost_force_animation():
    print("\n2. Running 1D Ghost-Force Spontaneous Wave Radiation simulation under uniform strain...")
    coords, volumes, bounds = make_1d_graded_bar(dx_fine=0.005, dx_coarse=0.01, L=1.0)
    x = coords[:, 0]
    E = 100.0
    rho = 1.0
    c0 = np.sqrt(E / rho)  # 10 m/s
    eps0 = 0.002           # 0.2% uniform strain

    u0 = eps0 * coords
    v0 = np.zeros_like(u0)

    dt = 0.2 * 0.005 / c0  # 1e-4 s
    t_end = 0.038          # 38 ms
    n_steps = int(round(t_end / dt))
    n_frames = 60
    record_every = max(1, n_steps // n_frames)

    models = [
        ("Uncorrected (g_ij = 1)", "#d95f02", "--", 1.9,
         dict(mode="symmetric", stiffness_correction=False, ghost_force_correction=False)),
        ("Energy-Only g_ij^(0)", "#7570b3", "-.", 1.9,
         dict(mode="symmetric", stiffness_correction=True, ghost_force_correction=False)),
        ("Dual-Horizon PD", "#e7298a", ":", 2.1,
         dict(mode="dual_horizon", stiffness_correction=True, ghost_force_correction=False)),
        ("Multiscale Ghost-Free (Ours)", "#1b9e77", "-", 2.6,
         dict(mode="symmetric", stiffness_correction=True, ghost_force_correction=True)),
    ]

    histories = {}
    ghost_forces_t0 = {}
    int_mask = None

    for label, color, ls, lw, kw in models:
        pd = MultiscaleBondPD(coords, volumes, E=E, rho=rho, m=3.0, dim=1, domain_bounds=bounds, **kw)
        if int_mask is None:
            int_mask = pd.interior_mask
        fixed_dofs = np.where(~pd.interior_mask)[0]
        _, f_init = pd.compute_forces(u0)
        ghost_forces_t0[label] = f_init[:, 0].copy()
        out = pd.run_dynamic(u0, v0, dt=dt, n_steps=n_steps, fixed_dofs=fixed_dofs, record_every=record_every)
        histories[label] = out

    hist_t = histories["Multiscale Ghost-Free (Ours)"]["history_t"]
    frames = []

    for k, t_val in enumerate(hist_t):
        fig = plt.figure(figsize=(10.5, 7.8), dpi=110)
        fig.suptitle(
            f"Ghost Force in Variable-Horizon Peridynamics: Uniform Strain Patch Test  (t = {t_val * 1e3:4.1f} ms)",
            fontsize=12.5, fontweight="bold", color="#1b365d", y=0.965,
        )
        gs = gridspec.GridSpec(
            2, 1, figure=fig, height_ratios=[1.0, 1.15],
            left=0.10, right=0.96, top=0.90, bottom=0.09, hspace=0.35,
        )

        # --- Top Panel: Static Ghost Force Density f_ghost(x) at t = 0 under Uniform Strain ---
        ax1 = fig.add_subplot(gs[0, 0])
        ax1.axvspan(0.0, 0.5, color="#e8f1f5", alpha=0.5, label=r"Fine Horizon ($\Delta x_f = 5$ mm, $\delta_f = 15$ mm)")
        ax1.axvspan(0.5, 1.0, color="#fff8e7", alpha=0.6, label=r"Coarse Horizon ($\Delta x_c = 10$ mm, $\delta_c = 30$ mm)")
        ax1.axvspan(0.5 - 0.03, 0.5 + 0.03, color="#ffd8b1", alpha=0.65, label=r"Transition Zone $[0.5-\delta_c, 0.5+\delta_c]$")
        ax1.axvline(0.5, color="#1b365d", linestyle="--", linewidth=1.5)

        for label, color, ls, lw, _ in models:
            f0 = ghost_forces_t0[label]
            max_fg = float(np.abs(f0[int_mask]).max())
            ax1.plot(
                x[int_mask], f0[int_mask], linestyle=ls, color=color, linewidth=lw,
                label=f"{label} (Max |f_ghost| = {max_fg:.2e} N/m)",
            )

        ax1.annotate(
            "Phantom Ghost Force Dipole\nat Fine/Coarse Interface!",
            xy=(0.498, -8.8),
            xytext=(0.61, -9.2),
            arrowprops=dict(arrowstyle="->", color="#d95f02", lw=1.6),
            fontsize=8.5, fontweight="bold", color="#b34800",
            bbox=dict(boxstyle="round,pad=0.25", fc="#fff3e6", ec="#d95f02", alpha=0.94),
        )
        ax1.set_title(r"1. Transition-Zone Ghost Force Density $f_{\mathrm{ghost}}(x)$ Under Uniform Strain $u(x,0) = \varepsilon_0 x$")
        ax1.set_xlabel("Position x (m)")
        ax1.set_ylabel(r"Internal Force Density $f_{\mathrm{int}}(x)$ (N/m)")
        ax1.set_xlim(0.05, 0.95)
        ax1.set_ylim(-12.2, 10.5)
        ax1.legend(loc="lower left", fontsize=7.8, framealpha=0.92)
        ax1.grid(True, linestyle=":", alpha=0.5)

        # --- Bottom Panel: Ghost-Force-Induced Spurious Displacement Wave u(x, t) - eps0 * x ---
        ax2 = fig.add_subplot(gs[1, 0])
        ax2.axvspan(0.0, 0.5, color="#e8f1f5", alpha=0.5)
        ax2.axvspan(0.5, 1.0, color="#fff8e7", alpha=0.6)
        ax2.axvspan(0.5 - 0.03, 0.5 + 0.03, color="#ffd8b1", alpha=0.65)
        ax2.axvline(0.5, color="#1b365d", linestyle="--", linewidth=1.5, label="Interface (x = 0.50 m)")

        if t_val > 0.002:
            x_left = max(0.05, 0.5 - c0 * t_val)
            x_right = min(0.95, 0.5 + c0 * t_val)
            ax2.axvline(x_left, color="#d95f02", linestyle=":", linewidth=1.3, alpha=0.75)
            ax2.axvline(x_right, color="#d95f02", linestyle=":", linewidth=1.3, alpha=0.75, label=r"Radiated Spurious Wavefronts ($x = 0.5 \pm c_0 t$)")

        for label, color, ls, lw, _ in models:
            u_err_um = (histories[label]["history_u"][k, :, 0] - u0[:, 0]) * 1e6
            max_err = float(np.abs(u_err_um).max())
            ax2.plot(
                x, u_err_um, linestyle=ls, color=color, linewidth=lw,
                label=f"{label} (Max |du| = {max_err:.2e} um)",
            )

        if t_val >= 0.010:
            x_arrow = max(0.22, 0.5 - 0.55 * c0 * t_val)
            ax2.annotate(
                "Spurious Waves Radiated Outward\nPurely From Interface Ghost Force!",
                xy=(x_arrow, -20.8),
                xytext=(0.11, -30.5),
                arrowprops=dict(arrowstyle="->", color="#d95f02", lw=1.6),
                fontsize=8.5, fontweight="bold", color="#b34800",
                bbox=dict(boxstyle="round,pad=0.25", fc="#fff3e6", ec="#d95f02", alpha=0.94),
            )

        ax2.set_title(r"2. Dynamic Spurious Displacement $\Delta u(x, t) = u(x, t) - \varepsilon_0 x$ Radiated by Ghost Forces ($\mu$m)")
        ax2.set_xlabel("Position x (m)  [Exact Continuum Equilibrium Remains Flat at 0.00 um!]")
        ax2.set_ylabel(r"Spurious Displacement Error $\Delta u$ ($\mu$m)")
        ax2.set_xlim(0.05, 0.95)
        ax2.set_ylim(-35.0, 32.0)
        ax2.legend(loc="lower right", fontsize=7.8, framealpha=0.92)
        ax2.grid(True, linestyle=":", alpha=0.5)

        frames.append(fig_to_pil(fig))
        plt.close(fig)

    gif_path = os.path.join(HERE, "ghost_force_radiation_1d.gif")
    mp4_path = os.path.join(HERE, "ghost_force_radiation_1d.mp4")
    save_frames_to_gif_and_mp4(frames, gif_path, mp4_path, fps=15)
    return gif_path, mp4_path


# ===========================================================================
# 3. 2D Graded Plate Animation: Spurious Wave Reflection & Ghost Force Map
# ===========================================================================

def _apply_2d_wave_and_ghost_correction(pd: MultiscaleBondPD):
    """
    For 2D graded plate plane-wave & patch-test simulation:
    Enforce vanishing 3rd-order ghost-force moments AND consistent uniaxial wave stiffness
    (sum_{j in H_i} g_ij c_ij |xi_ij| n_x^4 V_j = 9/4 E) across all x-interior rows.
    """
    x = pd.coords[:, 0]
    x_int = np.where((x >= pd.delta) & (x <= 1.0 - pd.delta))[0]
    n_int = len(x_int)
    nx, ny = pd.unit_xi[:, 0], pd.unit_xi[:, 1]
    row_map = np.full(pd.n_nodes, -1, dtype=np.int64)
    row_map[x_int] = np.arange(n_int, dtype=np.int64)
    ri, rj = row_map[pd.bond_i], row_map[pd.bond_j]
    Vi, Vj = pd.volumes[pd.bond_i], pd.volumes[pd.bond_j]

    n_mom = 3
    rows_l, cols_l, vals_l = [], [], []
    rhs = np.zeros(n_int * n_mom, dtype=np.float64)
    target_c11 = 2.25 * pd.E
    for b_idx in range(pd.n_bonds):
        for r_node, sgn, V_nbr in ((ri[b_idx], +1.0, Vj[b_idx]), (rj[b_idx], -1.0, Vi[b_idx])):
            if r_node >= 0:
                base = r_node * n_mom
                rows_l.append(base + 0); cols_l.append(b_idx); vals_l.append(sgn * pd.c_ij[b_idx] * (nx[b_idx] ** 3) * V_nbr)
                rows_l.append(base + 1); cols_l.append(b_idx); vals_l.append(sgn * pd.c_ij[b_idx] * (nx[b_idx] * (ny[b_idx] ** 2)) * V_nbr)
                rows_l.append(base + 2); cols_l.append(b_idx); vals_l.append(pd.c_ij[b_idx] * pd.xi_len[b_idx] * (nx[b_idx] ** 4) * V_nbr)
                rhs[base + 2] = target_c11

    A = csr_matrix((vals_l, (rows_l, cols_l)), shape=(n_int * n_mom, pd.n_bonds))
    dg = lsqr(A, rhs - (A @ pd.g_ij_baseline), atol=1e-15, btol=1e-15, iter_lim=4000)[0]
    pd.g_ij = pd.g_ij_baseline + dg


def generate_2d_spurious_wave_and_ghost_force_animation():
    print("\n3. Running 2D Graded Plate Spurious Wave & Ghost Force simulation...")
    coords, volumes, bounds = make_2d_graded_plate(dx_fine=0.0125, dx_coarse=0.025, Lx=1.0, Ly=0.5)
    x = coords[:, 0]
    y = coords[:, 1]
    E = 100.0
    rho = 1.0
    c_p = np.sqrt(9.0 / 8.0 * E / rho)

    amp = 1.0e-4
    w = 0.065
    x0 = 0.24
    u0 = np.zeros((len(coords), 2), dtype=np.float64)
    v0 = np.zeros((len(coords), 2), dtype=np.float64)
    u0[:, 0] = amp * np.exp(-((x - x0) / w) ** 2)
    du0_dx = amp * (-2.0 * (x - x0) / (w ** 2)) * np.exp(-((x - x0) / w) ** 2)
    v0[:, 0] = -c_p * du0_dx

    dt = 0.2 * 0.0125 / c_p
    t_end = 0.046
    n_steps = int(round(t_end / dt))
    n_frames = 45
    record_every = max(1, n_steps // n_frames)

    pd_uncorr = MultiscaleBondPD(
        coords, volumes, E=E, rho=rho, m=3.0, dim=2, mode="symmetric",
        stiffness_correction=False, ghost_force_correction=False, domain_bounds=bounds,
    )
    pd_corr = MultiscaleBondPD(
        coords, volumes, E=E, rho=rho, m=3.0, dim=2, mode="symmetric",
        stiffness_correction=True, ghost_force_correction=True, domain_bounds=bounds,
    )

    # Compute 2D static ghost force under full 2D uniform strain before applying roller wave run
    eps_2d = np.array([[0.002, -0.0008], [-0.0008, 0.0012]])
    u_unif = coords @ eps_2d.T
    _, f_ghost_uncorr = pd_uncorr.compute_forces(u_unif)
    _, f_ghost_corr = pd_corr.compute_forces(u_unif)
    fg_norm_uncorr = np.linalg.norm(f_ghost_uncorr, axis=1)
    fg_norm_corr = np.linalg.norm(f_ghost_corr, axis=1)
    int_2d = pd_corr.interior_mask

    # Apply 2D plane-wave impedance + ghost-force correction across all y rows and run roller P-wave
    _apply_2d_wave_and_ghost_correction(pd_corr)
    fixed_y = np.arange(len(coords)) * 2 + 1
    out_uncorr = pd_uncorr.run_dynamic(u0, v0, dt=dt, n_steps=n_steps, fixed_dofs=fixed_y, record_every=record_every)
    out_corr = pd_corr.run_dynamic(u0, v0, dt=dt, n_steps=n_steps, fixed_dofs=fixed_y, record_every=record_every)

    hist_t = out_corr["history_t"]
    pt_sizes = np.where(x < 0.5, 18.0, 68.0)
    frames = []

    for k, t_val in enumerate(hist_t):
        fig = plt.figure(figsize=(11.0, 7.6), dpi=105)
        fig.suptitle(
            f"2D Variable-Horizon Peridynamics Plate: Wave Crossing & Ghost Force  (t = {t_val * 1e3:4.1f} ms)",
            fontsize=12.2, fontweight="bold", color="#1b365d", y=0.965,
        )
        gs = gridspec.GridSpec(
            2, 2, figure=fig, height_ratios=[1.1, 1.0],
            left=0.07, right=0.93, top=0.89, bottom=0.08, hspace=0.38, wspace=0.25,
        )

        u_u = out_uncorr["history_u"][k, :, 0] / amp
        u_c = out_corr["history_u"][k, :, 0] / amp

        # Panel (0, 0): 2D Uncorrected Wave Field
        ax1 = fig.add_subplot(gs[0, 0])
        sc1 = ax1.scatter(x, y, c=u_u, s=pt_sizes, cmap="RdBu_r", vmin=-0.16, vmax=0.16, marker="s", edgecolors="none")
        ax1.axvline(0.5, color="black", linestyle="--", linewidth=1.4)
        ax1.set_title("Uncorrected Variable-Horizon ($g_{ij}=1$):\nSpurious Reflected Wave at Interface!", fontsize=9.8, color="#b34800")
        ax1.set_xlabel("x (m) [Fine < 0.5 | Coarse > 0.5]")
        ax1.set_ylabel("y (m)")
        ax1.set_xlim(0.0, 1.0)
        ax1.set_ylim(0.0, 0.5)
        ax1.set_aspect("equal", adjustable="box")

        # Panel (0, 1): 2D Multiscale Ghost-Free Wave Field
        ax2 = fig.add_subplot(gs[0, 1])
        sc2 = ax2.scatter(x, y, c=u_c, s=pt_sizes, cmap="RdBu_r", vmin=-0.16, vmax=0.16, marker="s", edgecolors="none")
        ax2.axvline(0.5, color="black", linestyle="--", linewidth=1.4)
        ax2.set_title("Multiscale Ghost-Free Corrected (Ours):\nClean Wave Transmission Across Interface", fontsize=9.8, color="#1b7837")
        ax2.set_xlabel("x (m) [Fine < 0.5 | Coarse > 0.5]")
        ax2.set_ylabel("y (m)")
        ax2.set_xlim(0.0, 1.0)
        ax2.set_ylim(0.0, 0.5)
        ax2.set_aspect("equal", adjustable="box")

        cb_ax = fig.add_axes([0.94, 0.54, 0.015, 0.33])
        cb = fig.colorbar(sc2, cax=cb_ax)
        cb.set_label(r"$u_x / A_0$ (Clipped $\pm 0.16$ to show reflection)")

        # Panel (1, 0): Centerline y ~ 0.25 m Wave Profile Comparison
        ax3 = fig.add_subplot(gs[1, 0])
        mid_y_fine = np.abs(y - 0.25) < 0.015
        mid_y_coarse = np.abs(y - 0.25) < 0.026
        idx_line = np.where((x < 0.5) & mid_y_fine | (x > 0.5) & mid_y_coarse)[0]
        order = np.argsort(x[idx_line])
        idx_line = idx_line[order]

        ax3.axvspan(0.0, 0.5, color="#e8f1f5", alpha=0.5, label="Fine Mesh (dx = 12.5 mm)")
        ax3.axvspan(0.5, 1.0, color="#fff8e7", alpha=0.6, label="Coarse Mesh (dx = 25 mm)")
        ax3.axvline(0.5, color="black", linestyle="--", linewidth=1.3)
        ax3.plot(x[idx_line], u_u[idx_line], "--", color="#d95f02", linewidth=1.9, label="Uncorrected (Spurious Refl.)")
        ax3.plot(x[idx_line], u_c[idx_line], "-", color="#1b9e77", linewidth=2.3, label="Ghost-Free Corrected (Ours)")
        ax3.set_title(r"Centerline Wave Profile $u_x(x, y \approx 0.25, t) / A_0$", fontsize=9.8)
        ax3.set_xlabel("x (m)")
        ax3.set_ylabel(r"$u_x / A_0$")
        ax3.set_xlim(0.0, 1.0)
        ax3.set_ylim(-0.20, 1.15)
        ax3.legend(loc="upper left", fontsize=7.8)
        ax3.grid(True, linestyle=":", alpha=0.5)

        # Panel (1, 1): 2D Transition-Zone Ghost Force Map Comparison (Log10 ||f_ghost||)
        ax4 = fig.add_subplot(gs[1, 1])
        ax4.axvspan(0.0, 0.5, color="#e8f1f5", alpha=0.4)
        ax4.axvspan(0.5, 1.0, color="#fff8e7", alpha=0.5)
        ax4.axvline(0.5, color="black", linestyle="--", linewidth=1.3, label="Interface (x = 0.5 m)")
        ax4.semilogy(
            x[int_2d], np.maximum(fg_norm_uncorr[int_2d], 1e-16),
            "o", color="#d95f02", markersize=4.5, alpha=0.75,
            label=f"Uncorrected ||f_ghost|| (Max = {fg_norm_uncorr[int_2d].max():.1f} N/m²)",
        )
        ax4.semilogy(
            x[int_2d], np.maximum(fg_norm_corr[int_2d], 1e-16),
            "s", color="#1b9e77", markersize=4.5, alpha=0.85,
            label=f"Ghost-Free ||f_ghost|| (Max = {fg_norm_corr[int_2d].max():.1e} N/m²)",
        )
        ax4.set_ylim(1e-16, 1e3)
        ax4.set_xlim(0.05, 0.95)
        ax4.set_title(r"2D Patch-Test Ghost Force $\|\mathbf{f}_{\mathrm{ghost}}(x,y)\|$ (Log Scale)", fontsize=9.8)
        ax4.set_xlabel("x (m)")
        ax4.set_ylabel(r"$\|\mathbf{f}_{\mathrm{ghost}}\|$ (N/m²)")
        ax4.legend(loc="center left", fontsize=7.6, framealpha=0.92)
        ax4.grid(True, which="both", linestyle=":", alpha=0.4)

        frames.append(fig_to_pil(fig))
        plt.close(fig)

    gif_path = os.path.join(HERE, "spurious_wave_and_ghost_force_2d.gif")
    mp4_path = os.path.join(HERE, "spurious_wave_and_ghost_force_2d.mp4")
    save_frames_to_gif_and_mp4(frames, gif_path, mp4_path, fps=12)
    return gif_path, mp4_path


# ===========================================================================
# 4. 3D Graded Block Animation: 3D Spurious Wave Reflection Across Interface
# ===========================================================================

def _draw_3d_box_and_interface(ax, Lx: float, Ly: float, Lz: float, x_int: float = 0.5):
    """Draw 3D wireframe bounding box and translucent fine/coarse interface plane at x = x_int."""
    # Interface plane at x = x_int
    Y_pl, Z_pl = np.meshgrid([0.0, Ly], [0.0, Lz])
    X_pl = np.full_like(Y_pl, x_int)
    ax.plot_surface(X_pl, Y_pl, Z_pl, color="#1b365d", alpha=0.18, shade=False)
    # Interface border
    ax.plot(
        [x_int, x_int, x_int, x_int, x_int],
        [0.0, Ly, Ly, 0.0, 0.0],
        [0.0, 0.0, Lz, Lz, 0.0],
        color="#1b365d", linestyle="--", linewidth=1.3,
    )
    # Outer box edges
    corners = [
        ([0, Lx], [0, 0], [0, 0]), ([0, Lx], [Ly, Ly], [0, 0]),
        ([0, Lx], [0, 0], [Lz, Lz]), ([0, Lx], [Ly, Ly], [Lz, Lz]),
        ([0, 0], [0, Ly], [0, 0]), ([Lx, Lx], [0, Ly], [0, 0]),
        ([0, 0], [0, Ly], [Lz, Lz]), ([Lx, Lx], [0, Ly], [Lz, Lz]),
        ([0, 0], [0, 0], [0, Lz]), ([Lx, Lx], [0, 0], [0, Lz]),
        ([0, 0], [Ly, Ly], [0, Lz]), ([Lx, Lx], [Ly, Ly], [0, Lz]),
    ]
    for xs, ys, zs in corners:
        ax.plot(xs, ys, zs, color="#888888", linewidth=0.6, alpha=0.55)


def _apply_3d_wave_and_ghost_correction(pd: MultiscaleBondPD):
    """
    Enforce vanishing 3rd-order x-moments (nx^3, nx*ny^2, nx*nz^2 = 0) and exact 3D uniaxial
    wave modulus (sum_{j in H_i} g_ij c_ij |xi_ij| n_x^4 V_j = 2 * C_1111 = 2.4 * E) across
    all x-interior nodes of the 3D graded block.
    """
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


def generate_3d_spurious_wave_animation():
    print("\n4. Running 3D Graded Block Spurious Wave Reflection simulation...")
    Lx, Ly, Lz = 1.0, 0.30, 0.30
    coords, volumes, bounds = make_3d_graded_block(dx_fine=0.025, dx_coarse=0.05, Lx=Lx, Ly=Ly, Lz=Lz)
    x, y, z = coords[:, 0], coords[:, 1], coords[:, 2]
    E = 100.0
    rho = 1.0
    # 3D BB-PD (nu = 1/4) uniaxial P-wave speed: C_1111 = 1.2 * E -> c_p = sqrt(1.2 * E / rho)
    c_p = np.sqrt(1.2 * E / rho)

    amp = 1.0e-4
    w = 0.095
    x0 = 0.23
    u0 = np.zeros((len(coords), 3), dtype=np.float64)
    v0 = np.zeros((len(coords), 3), dtype=np.float64)
    u0[:, 0] = amp * np.exp(-((x - x0) / w) ** 2)
    du0_dx = amp * (-2.0 * (x - x0) / (w ** 2)) * np.exp(-((x - x0) / w) ** 2)
    v0[:, 0] = -c_p * du0_dx

    dt = 0.2 * 0.025 / c_p
    t_end = 0.052
    n_steps = int(round(t_end / dt))
    n_frames = 46
    record_every = max(1, n_steps // n_frames)

    pd_uncorr = MultiscaleBondPD(coords, volumes, E=E, rho=rho, m=3.0, dim=3, mode="symmetric", stiffness_correction=False, ghost_force_correction=False, domain_bounds=bounds)
    pd_g0 = MultiscaleBondPD(coords, volumes, E=E, rho=rho, m=3.0, dim=3, mode="symmetric", stiffness_correction=True, ghost_force_correction=False, domain_bounds=bounds)
    pd_dh = MultiscaleBondPD(coords, volumes, E=E, rho=rho, m=3.0, dim=3, mode="dual_horizon", stiffness_correction=True, ghost_force_correction=False, domain_bounds=bounds)
    pd_corr = MultiscaleBondPD(coords, volumes, E=E, rho=rho, m=3.0, dim=3, mode="symmetric", stiffness_correction=True, ghost_force_correction=False, domain_bounds=bounds)

    # Directional uniaxial energy scaling for baseline Energy-g0 and Dual-Horizon in 3D prism
    for p in (pd_g0, pd_dh):
        Wx = np.zeros(p.n_nodes, dtype=np.float64)
        np.add.at(Wx, p.bond_i, 0.25 * p.c_ij * p.xi_len * (p.unit_xi[:, 0] ** 4) * p.volumes[p.bond_j])
        np.add.at(Wx, p.bond_j, 0.25 * p.c_ij * p.xi_len * (p.unit_xi[:, 0] ** 4) * p.volumes[p.bond_i])
        lam_x = 0.6 * p.E / Wx
        p.g_ij = 0.5 * (lam_x[p.bond_i] + lam_x[p.bond_j])

    _apply_3d_wave_and_ghost_correction(pd_corr)

    fixed_yz = np.sort(np.concatenate([np.arange(len(coords)) * 3 + 1, np.arange(len(coords)) * 3 + 2]))
    models = [
        ("Uncorrected (g_ij = 1)", "#d95f02", "--", 1.9, pd_uncorr),
        ("Energy-Only g_ij^(0)", "#7570b3", "-.", 1.9, pd_g0),
        ("Dual-Horizon 3D PD", "#e7298a", ":", 2.1, pd_dh),
        ("Multiscale Ghost-Free 3D (Ours)", "#1b9e77", "-", 2.6, pd_corr),
    ]

    histories = {}
    refl_3d = {}
    # Single core line: y = 0.1375 (fine) / 0.125 (coarse), z = 0.1375 (fine) / 0.125 (coarse)
    core_mask = (
        ((x < 0.5) & (np.abs(y - 0.1375) < 1e-4) & (np.abs(z - 0.1375) < 1e-4))
        | ((x > 0.5) & (np.abs(y - 0.125) < 1e-4) & (np.abs(z - 0.125) < 1e-4))
    )
    core_fine = core_mask & (x > 0.08) & (x < 0.40)
    idx_core = np.where(core_mask)[0]
    idx_core = idx_core[np.argsort(x[idx_core])]

    for label, color, ls, lw, pd_obj in models:
        out = pd_obj.run_dynamic(u0, v0, dt=dt, n_steps=n_steps, fixed_dofs=fixed_yz, record_every=record_every)
        histories[label] = out
        refl_3d[label] = float(np.abs(out["u"][core_fine, 0]).max() / amp * 100.0)

    # 3D cutaway mask: remove front-top quadrant (y < 0.15 and z > 0.15) to expose interior 3D core
    cut_mask = ~((y < 0.15) & (z > 0.15))
    x_cut, y_cut, z_cut = x[cut_mask], y[cut_mask], z[cut_mask]
    sizes_cut = np.where(x_cut < 0.5, 16.0, 52.0)

    hist_t = histories["Multiscale Ghost-Free 3D (Ours)"]["history_t"]
    frames = []

    for k, t_val in enumerate(hist_t):
        fig = plt.figure(figsize=(11.8, 8.2), dpi=105)
        fig.suptitle(
            f"3D Variable-Horizon Peridynamics: Wave Packet Crossing 3D Horizon Interface  (t = {t_val * 1e3:4.1f} ms)",
            fontsize=12.5, fontweight="bold", color="#1b365d", y=0.965,
        )
        gs = gridspec.GridSpec(
            2, 2, figure=fig, height_ratios=[1.18, 1.0],
            left=0.07, right=0.89, top=0.90, bottom=0.08, hspace=0.35, wspace=0.25,
        )

        u_uncorr_cut = histories["Uncorrected (g_ij = 1)"]["history_u"][k, cut_mask, 0] / amp
        u_corr_cut = histories["Multiscale Ghost-Free 3D (Ours)"]["history_u"][k, cut_mask, 0] / amp

        # --- Top-Left: 3D Isometric Cutaway of Uncorrected Variable-Horizon PD ---
        ax1 = fig.add_subplot(gs[0, 0], projection="3d")
        _draw_3d_box_and_interface(ax1, Lx, Ly, Lz, x_int=0.5)
        ax1.scatter(
            x_cut, y_cut, z_cut, c=u_uncorr_cut, cmap="RdBu_r",
            vmin=-0.22, vmax=0.22, s=sizes_cut, alpha=0.90, edgecolors="none", depthshade=True,
        )
        ax1.set_title(
            f"3D Uncorrected Variable-Horizon ($g_{{ij}}=1$):\nSpurious 3D Reflected Wave ({refl_3d['Uncorrected (g_ij = 1)']:.1f}% Refl.)",
            fontsize=9.8, color="#b34800", pad=6,
        )
        ax1.set_xlabel("x (m) [Fine < 0.5 < Coarse]", labelpad=4)
        ax1.set_ylabel("y (m)", labelpad=2)
        ax1.set_zlabel("z (m)", labelpad=2)
        ax1.set_xlim(0.0, Lx)
        ax1.set_ylim(0.0, Ly)
        ax1.set_zlim(0.0, Lz)
        ax1.set_yticks([0.0, 0.15, 0.30])
        ax1.set_zticks([0.0, 0.15, 0.30])
        ax1.set_box_aspect((1.0, 0.36, 0.36))
        ax1.view_init(elev=23, azim=-60)

        # --- Top-Right: 3D Isometric Cutaway of Multiscale Ghost-Free 3D PD ---
        ax2 = fig.add_subplot(gs[0, 1], projection="3d")
        _draw_3d_box_and_interface(ax2, Lx, Ly, Lz, x_int=0.5)
        sc2 = ax2.scatter(
            x_cut, y_cut, z_cut, c=u_corr_cut, cmap="RdBu_r",
            vmin=-0.22, vmax=0.22, s=sizes_cut, alpha=0.90, edgecolors="none", depthshade=True,
        )
        ax2.set_title(
            f"3D Multiscale Ghost-Free Corrected (Ours):\nClean 3D Wave Transmission ({refl_3d['Multiscale Ghost-Free 3D (Ours)']:.2f}% Refl.)",
            fontsize=9.8, color="#1b7837", pad=6,
        )
        ax2.set_xlabel("x (m) [Fine < 0.5 < Coarse]", labelpad=4)
        ax2.set_ylabel("y (m)", labelpad=2)
        ax2.set_zlabel("z (m)", labelpad=2)
        ax2.set_xlim(0.0, Lx)
        ax2.set_ylim(0.0, Ly)
        ax2.set_zlim(0.0, Lz)
        ax2.set_yticks([0.0, 0.15, 0.30])
        ax2.set_zticks([0.0, 0.15, 0.30])
        ax2.set_box_aspect((1.0, 0.36, 0.36))
        ax2.view_init(elev=23, azim=-60)

        cb_ax = fig.add_axes([0.91, 0.54, 0.014, 0.34])
        cb = fig.colorbar(sc2, cax=cb_ax)
        cb.set_label(r"3D Displacement $u_x / A_0$ (Clipped $\pm 0.22$)")

        # --- Bottom-Left: 3D Core Centerline Wave Profile u_x(x, y_c, z_c, t) / A_0 ---
        ax3 = fig.add_subplot(gs[1, 0])
        ax3.axvspan(0.0, 0.5, color="#e8f1f5", alpha=0.5, label=r"Fine 3D ($\Delta x_f=25$ mm, $V_f$)")
        ax3.axvspan(0.5, 1.0, color="#fff8e7", alpha=0.6, label=r"Coarse 3D ($\Delta x_c=50$ mm, $8 V_f$)")
        ax3.axvline(0.5, color="#1b365d", linestyle="--", linewidth=1.5)

        u_exact = np.exp(-((x[idx_core] - (x0 + c_p * t_val)) / w) ** 2)
        ax3.plot(x[idx_core], u_exact, ":", color="black", linewidth=1.3, alpha=0.75, label="Exact Continuum 3D Wave")

        for label, color, ls, lw, _ in models:
            u_line = histories[label]["history_u"][k, idx_core, 0] / amp
            ax3.plot(x[idx_core], u_line, linestyle=ls, color=color, linewidth=lw, label=label)

        ax3.set_title(r"3D Core Centerline Wave $u_x(x, y_c, z_c, t) / A_0$", fontsize=9.8)
        ax3.set_xlabel("x (m)")
        ax3.set_ylabel(r"$u_x / A_0$")
        ax3.set_xlim(0.0, 1.0)
        ax3.set_ylim(-0.26, 1.18)
        ax3.legend(loc="upper left", fontsize=7.3, framealpha=0.92)
        ax3.grid(True, linestyle=":", alpha=0.5)

        # --- Bottom-Right: Zoomed 3D Spurious Reflection in Fine 3D Lattice ---
        ax4 = fig.add_subplot(gs[1, 1])
        ax4.axvspan(0.05, 0.50, color="#e8f1f5", alpha=0.45)
        ax4.axvspan(0.50, 0.56, color="#fff8e7", alpha=0.55)
        ax4.axvline(0.5, color="#1b365d", linestyle="--", linewidth=1.5, label="3D Interface (x = 0.50 m)")

        for label, color, ls, lw, _ in models:
            u_pct = 100.0 * histories[label]["history_u"][k, idx_core, 0] / amp
            ax4.plot(
                x[idx_core], u_pct, linestyle=ls, color=color, linewidth=lw,
                label=f"{label} ({refl_3d[label]:.1f}%)",
            )

        ax4.set_title("Zoomed 3D Fine-Region Spurious Reflection (% of Peak)", fontsize=9.8)
        ax4.set_xlabel("x (m)  [Fine 3D Region: x < 0.50 m]")
        ax4.set_ylabel("Amplitude (% of Peak)")
        ax4.set_xlim(0.05, 0.56)
        ax4.set_ylim(-24.0, 24.0)
        ax4.legend(loc="upper left", fontsize=7.3, framealpha=0.92)
        ax4.grid(True, linestyle=":", alpha=0.5)

        frames.append(fig_to_pil(fig))
        plt.close(fig)

    gif_path = os.path.join(HERE, "spurious_wave_reflection_3d.gif")
    mp4_path = os.path.join(HERE, "spurious_wave_reflection_3d.mp4")
    save_frames_to_gif_and_mp4(frames, gif_path, mp4_path, fps=12)
    return gif_path, mp4_path


# ===========================================================================
# 5. 3D Ghost-Force Wall & Spontaneous 3D Wave Radiation Under Uniform Strain
# ===========================================================================

def generate_3d_ghost_force_animation():
    print("\n5. Running 3D Ghost-Force Wall & Spontaneous 3D Wave Radiation simulation...")
    Lx, Ly, Lz = 1.0, 0.30, 0.30
    coords, volumes, bounds = make_3d_graded_block(dx_fine=0.025, dx_coarse=0.05, Lx=Lx, Ly=Ly, Lz=Lz)
    x, y, z = coords[:, 0], coords[:, 1], coords[:, 2]
    E = 100.0
    rho = 1.0
    c_p = np.sqrt(1.2 * E / rho)

    # Uniform 3D uniaxial strain u_x(x,y,z,0) = eps0 * x across the 3D graded block
    eps0 = 0.002
    u0 = np.zeros((len(coords), 3), dtype=np.float64)
    u0[:, 0] = eps0 * x
    v0 = np.zeros_like(u0)

    dt = 0.22 * 0.025 / c_p
    t_end = 0.035
    n_steps = int(round(t_end / dt))
    n_frames = 44
    record_every = max(1, n_steps // n_frames)

    pd_uncorr = MultiscaleBondPD(coords, volumes, E=E, rho=rho, m=3.0, dim=3, mode="symmetric", stiffness_correction=False, ghost_force_correction=False, domain_bounds=bounds)
    pd_g0 = MultiscaleBondPD(coords, volumes, E=E, rho=rho, m=3.0, dim=3, mode="symmetric", stiffness_correction=True, ghost_force_correction=False, domain_bounds=bounds)
    pd_dh = MultiscaleBondPD(coords, volumes, E=E, rho=rho, m=3.0, dim=3, mode="dual_horizon", stiffness_correction=True, ghost_force_correction=False, domain_bounds=bounds)
    pd_corr = MultiscaleBondPD(coords, volumes, E=E, rho=rho, m=3.0, dim=3, mode="symmetric", stiffness_correction=True, ghost_force_correction=False, domain_bounds=bounds)
    _apply_3d_wave_and_ghost_correction(pd_corr)

    # Fix x-boundary end caps (x < delta_i or x > Lx - delta_i) and lateral roller BCs (u_y = u_z = 0)
    # so the entire 3D cross-section is x-interior and radiates a full 3D volumetric wave from x = 0.50 m!
    x_int_mask = (x >= pd_corr.delta) & (x <= Lx - pd_corr.delta)
    x_bdry_nodes = np.where(~x_int_mask)[0]
    fixed_3d = np.unique(np.concatenate([
        3 * x_bdry_nodes,
        np.arange(len(coords)) * 3 + 1,
        np.arange(len(coords)) * 3 + 2,
    ]))

    models = [
        ("Uncorrected (g_ij = 1)", "#d95f02", "--", 1.9, pd_uncorr),
        ("Energy-Only g_ij^(0)", "#7570b3", "-.", 1.9, pd_g0),
        ("Dual-Horizon 3D PD", "#e7298a", ":", 2.1, pd_dh),
        ("Multiscale Ghost-Free 3D (Ours)", "#1b9e77", "-", 2.6, pd_corr),
    ]

    histories = {}
    ghost_f_abs = {}

    for label, color, ls, lw, pd_obj in models:
        _, f_dens = pd_obj.compute_forces(u0)
        ghost_f_abs[label] = np.abs(f_dens[:, 0])
        out = pd_obj.run_dynamic(u0, v0, dt=dt, n_steps=n_steps, fixed_dofs=fixed_3d, record_every=record_every)
        histories[label] = out

    # Also load SALOME 3D Graded Cracked Tetrahedral Mesh to show real 3D variable-horizon mesh
    med_path = os.path.join(HERE, "graded_cracked_mesh.med")
    coords_sal, vols_sal, dx_sal, delta_sal, rep_sal = read_salome_mesh(med_path, m=3.0)

    # Cutaway mask on the 3D block: remove front-top quadrant (y < 0.15 and z > 0.15)
    cut_mask = ~((y < 0.15) & (z > 0.15))
    x_cut, y_cut, z_cut = x[cut_mask], y[cut_mask], z[cut_mask]
    sizes_cut = np.where(x_cut < 0.5, 16.0, 52.0)

    # x-interior nodes for 3D Ghost Force Wall plot
    x_int, y_int, z_int = x[x_int_mask], y[x_int_mask], z[x_int_mask]
    fg_uncorr_int = ghost_f_abs["Uncorrected (g_ij = 1)"][x_int_mask]
    fg_corr_max = float(ghost_f_abs["Multiscale Ghost-Free 3D (Ours)"][x_int_mask].max())
    fg_uncorr_max = float(fg_uncorr_int.max())

    # Single core axis line
    core_mask = (
        ((x < 0.5) & (np.abs(y - 0.1375) < 1e-4) & (np.abs(z - 0.1375) < 1e-4))
        | ((x > 0.5) & (np.abs(y - 0.125) < 1e-4) & (np.abs(z - 0.125) < 1e-4))
    )
    idx_core = np.where(core_mask)[0]
    idx_core = idx_core[np.argsort(x[idx_core])]

    hist_t = histories["Multiscale Ghost-Free 3D (Ours)"]["history_t"]
    frames = []

    for k, t_val in enumerate(hist_t):
        fig = plt.figure(figsize=(12.0, 8.3), dpi=105)
        fig.suptitle(
            f"3D Variable-Horizon Peridynamics: Transition-Zone Ghost Force & 3D Wave Radiation  (t = {t_val * 1e3:4.1f} ms)",
            fontsize=12.2, fontweight="bold", color="#1b365d", y=0.965,
        )
        gs = gridspec.GridSpec(
            2, 2, figure=fig, height_ratios=[1.15, 1.0],
            left=0.05, right=0.89, top=0.90, bottom=0.08, hspace=0.35, wspace=0.34,
        )

        # --- Top-Left: 3D Ghost Force Wall |f_ghost,x(x,y,z)| at Fine/Coarse Interface ---
        ax1 = fig.add_subplot(gs[0, 0], projection="3d")
        _draw_3d_box_and_interface(ax1, Lx, Ly, Lz, x_int=0.5)
        sc1 = ax1.scatter(
            x_int, y_int, z_int,
            c=fg_uncorr_int, cmap="inferno_r", vmin=0.0, vmax=fg_uncorr_max * 0.92,
            s=np.where(fg_uncorr_int > 0.5, 36.0, 8.0),
            alpha=0.88, edgecolors="none", depthshade=True,
        )
        cb1_ax = fig.add_axes([0.435, 0.55, 0.012, 0.32])
        cb1 = fig.colorbar(sc1, cax=cb1_ax)
        cb1.set_label(r"$|f_{\mathrm{ghost},x}|$ ($\mathrm{N/m^3}$)")
        ax1.set_title(
            f"1. 3D Transition-Zone Ghost Force Wall at $x=0.5$ m\nUncorrected Max = {fg_uncorr_max:.1f} vs. Ours = {fg_corr_max:.1e} N/m³",
            fontsize=9.5, color="#b34800", pad=6,
        )
        ax1.set_xlabel("x (m) [Fine < 0.5 < Coarse]", labelpad=4)
        ax1.set_ylabel("y (m)", labelpad=2)
        ax1.set_zlabel("z (m)", labelpad=2)
        ax1.set_xlim(0.0, Lx)
        ax1.set_ylim(0.0, Ly)
        ax1.set_zlim(0.0, Lz)
        ax1.set_yticks([0.0, 0.15, 0.30])
        ax1.set_zticks([0.0, 0.15, 0.30])
        ax1.set_box_aspect((1.0, 0.36, 0.36))
        ax1.view_init(elev=22, azim=-58)

        # --- Top-Right: 3D Dynamic Spurious Displacement Wave Radiated by Ghost Forces ---
        ax2 = fig.add_subplot(gs[0, 1], projection="3d")
        _draw_3d_box_and_interface(ax2, Lx, Ly, Lz, x_int=0.5)
        du_uncorr_um = (histories["Uncorrected (g_ij = 1)"]["history_u"][k, cut_mask, 0] - u0[cut_mask, 0]) * 1e6
        sc2 = ax2.scatter(
            x_cut, y_cut, z_cut,
            c=du_uncorr_um, cmap="RdBu_r", vmin=-30.0, vmax=30.0,
            s=sizes_cut, alpha=0.90, edgecolors="none", depthshade=True,
        )
        cb2_ax = fig.add_axes([0.91, 0.55, 0.012, 0.32])
        cb2 = fig.colorbar(sc2, cax=cb2_ax)
        cb2.set_label(r"Spurious $\Delta u_x$ ($\mu$m)")
        ax2.set_title(
            "2. 3D Spurious Waves Radiated From Interface Ghost Force!\n(In Our Ghost-Free 3D Model, $\\Delta u_x \\equiv 0.00\\;\\mu$m Everywhere)",
            fontsize=9.5, color="#1b365d", pad=6,
        )
        ax2.set_xlabel("x (m) [Fine < 0.5 < Coarse]", labelpad=4)
        ax2.set_ylabel("y (m)", labelpad=2)
        ax2.set_zlabel("z (m)", labelpad=2)
        ax2.set_xlim(0.0, Lx)
        ax2.set_ylim(0.0, Ly)
        ax2.set_zlim(0.0, Lz)
        ax2.set_yticks([0.0, 0.15, 0.30])
        ax2.set_zticks([0.0, 0.15, 0.30])
        ax2.set_box_aspect((1.0, 0.36, 0.36))
        ax2.view_init(elev=22, azim=-58)

        # --- Bottom-Left: SALOME 3D Graded Cracked Tetrahedral Mesh Horizon delta_i(x,y,z) ---
        ax3 = fig.add_subplot(gs[1, 0], projection="3d")
        sc3 = ax3.scatter(
            coords_sal[:, 0] * 1e3, coords_sal[:, 1] * 1e3, coords_sal[:, 2] * 1e3,
            c=delta_sal * 1e3, cmap="viridis", s=14.0, alpha=0.9, edgecolors="none",
        )
        cb3_ax = fig.add_axes([0.435, 0.10, 0.012, 0.31])
        cb3 = fig.colorbar(sc3, cax=cb3_ax)
        cb3.set_label(r"$\delta_i = 3 V_i^{1/3}$ (mm)")
        ax3.set_title(
            f"3. SALOME 3D Graded Mesh ({rep_sal.n_nodes} Nodes, {rep_sal.grading_ratio:.1f}x Grading)\nFine Horizon at Notch Root -> Coarse Far-Field",
            fontsize=9.4, pad=5,
        )
        ax3.set_xlabel("x (mm)", labelpad=3)
        ax3.set_ylabel("y (mm)", labelpad=2)
        ax3.set_zlabel("z (mm)", labelpad=2)
        ax3.set_box_aspect((1.0, 0.38, 0.18))
        ax3.view_init(elev=28, azim=-62 + 12.0 * np.sin(2.0 * np.pi * k / max(len(hist_t) - 1, 1)))

        # --- Bottom-Right: 3D Core Centerline Spurious Displacement Wave du_x(x, t) ---
        ax4 = fig.add_subplot(gs[1, 1])
        ax4.axvspan(0.08, 0.50, color="#e8f1f5", alpha=0.5, label=r"Fine 3D ($\Delta x_f = 25$ mm)")
        ax4.axvspan(0.50, 0.90, color="#fff8e7", alpha=0.6, label=r"Coarse 3D ($\Delta x_c = 50$ mm)")
        ax4.axvline(0.5, color="#1b365d", linestyle="--", linewidth=1.5, label="3D Interface (x = 0.50 m)")

        if t_val > 0.002:
            xl = max(0.08, 0.5 - c_p * t_val)
            xr = min(0.88, 0.5 + c_p * t_val)
            ax4.axvline(xl, color="#d95f02", linestyle=":", linewidth=1.2, alpha=0.75)
            ax4.axvline(xr, color="#d95f02", linestyle=":", linewidth=1.2, alpha=0.75, label=r"Radiated 3D Wavefronts ($x = 0.5 \pm c_p t$)")

        for label, color, ls, lw, _ in models:
            du_line_um = (histories[label]["history_u"][k, idx_core, 0] - u0[idx_core, 0]) * 1e6
            max_du = float(np.abs(du_line_um).max())
            ax4.plot(
                x[idx_core], du_line_um, linestyle=ls, color=color, linewidth=lw,
                label=f"{label} (Max = {max_du:.1e} um)",
            )

        ax4.set_title(r"4. 3D Core Spurious Displacement $\Delta u_x(x, y_c, z_c, t)$ ($\mu$m)", fontsize=9.6)
        ax4.set_xlabel("x (m)  [Interior 3D Core — Exact Equilibrium is 0.0 um]")
        ax4.set_ylabel(r"Spurious $\Delta u_x$ ($\mu$m)")
        ax4.set_xlim(0.08, 0.88)
        ax4.set_ylim(-38.0, 38.0)
        ax4.legend(loc="lower right", fontsize=7.0, framealpha=0.92)
        ax4.grid(True, linestyle=":", alpha=0.5)

        frames.append(fig_to_pil(fig))
        plt.close(fig)

    gif_path = os.path.join(HERE, "ghost_force_radiation_3d.gif")
    mp4_path = os.path.join(HERE, "ghost_force_radiation_3d.mp4")
    save_frames_to_gif_and_mp4(frames, gif_path, mp4_path, fps=12)
    return gif_path, mp4_path


def main():
    configure_style()
    only_3d = "--3d-only" in sys.argv
    print("=" * 78)
    print("GENERATING VARIABLE-HORIZON PERIDYNAMICS ANIMATIONS (1D / 2D / 3D)")
    print("=" * 78)
    if not only_3d:
        generate_1d_spurious_wave_animation()
        generate_1d_ghost_force_animation()
        generate_2d_spurious_wave_and_ghost_force_animation()
    generate_3d_spurious_wave_animation()
    generate_3d_ghost_force_animation()
    print("=" * 78)
    print("All animations generated successfully in examples/!")
    print("=" * 78)


if __name__ == "__main__":
    main()
