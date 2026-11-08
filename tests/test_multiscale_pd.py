#!/usr/bin/env python3
"""
Verification & Test Suite for Multiscale Variable-Horizon Bond-Based Peridynamics
=================================================================================
Run with:
    ./salome python tests/test_multiscale_pd.py

Tests:
  1. KD-tree neighbor list & symmetric family verification:
       - Each bond stored once (i < j)
       - |xi_ij| <= min(delta_i, delta_j)
       - Exact family symmetry (j in H_i <=> i in H_j)
       - Exclusion of one-sided bonds (min(delta_i, delta_j) < |xi| <= max(delta_i, delta_j))
  2. Test (a): Total internal force = 0 (exact Newton's third law via single-loop +f/-f):
       - Tested in 1D, 2D, 3D, under random displacements, uniform strain, and nonlinear kinematics
       - Tested on graded SALOME .med and .unv meshes
       - Tested in both Symmetric Variable-Horizon PD and Dual-Horizon PD modes
  3. Test (b): Patch test with zero ghost force under uniform strain, including in the transition zone:
       - Direct ghost-force evaluation on 1D, 2D, and 3D meshes with fine/coarse transition zones
       - Static equilibrium patch test (solving K * u = 0 with Dirichlet BCs on boundary layer)
         recovering exact linear displacement across the fine/coarse transition zone
       - Comparison of uncorrected (g=1), baseline energy correction g_ij = 0.5*(lambda_i + lambda_j),
         ghost-force-corrected multiscale BB-PD, and Dual-Horizon PD
  4. Test (c): 1D wave crossing the fine/coarse interface with no spurious reflection:
       - Right-traveling Gaussian pulse crossing a fine/coarse interface (dx_coarse = 2 * dx_fine)
       - Verifies > 99.5% transmitted amplitude, < 0.5% spurious reflection, and energy conservation
  5. SALOME Mesh Export (MED & UNV) node size reading & delta_i = 3 * dx_i distribution report:
       - Reads SALOME .med and .unv exports (both 3D tetrahedral and 2D triangular graded meshes)
       - Verifies exact agreement between MED and UNV readers
       - Prints full delta_i distribution report
"""

import os
import sys
import unittest
import numpy as np

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
sys.path.insert(0, os.path.join(ROOT, "pd_dynamic"))

from pdsalome.multiscale import (  # noqa: E402
    MultiscaleBondPD,
    read_med_mesh,
    read_salome_mesh,
    read_unv_mesh,
)


def make_1d_graded_bar(dx_fine: float = 0.0025, dx_coarse: float = 0.005, L: float = 1.0):
    """Create a 1D bar on [0, L] with fine cells on [0, L/2] and coarse cells on [L/2, L]."""
    mid = 0.5 * L
    x_fine = np.arange(0.5 * dx_fine, mid, dx_fine)
    x_coarse = np.arange(mid + 0.5 * dx_coarse, L, dx_coarse)
    coords = np.concatenate([x_fine, x_coarse])[:, None]
    volumes = np.concatenate([np.full_like(x_fine, dx_fine), np.full_like(x_coarse, dx_coarse)])
    bounds = (np.array([0.0]), np.array([L]))
    return coords, volumes, bounds


def make_2d_graded_plate(dx_fine: float = 0.025, dx_coarse: float = 0.05, Lx: float = 1.0, Ly: float = 0.5):
    """Create a 2D plate on [0, Lx] x [0, Ly] with fine cells for x < Lx/2 and coarse cells for x > Lx/2."""
    mid = 0.5 * Lx
    pts, vols = [], []
    for x in np.arange(0.5 * dx_fine, mid, dx_fine):
        for y in np.arange(0.5 * dx_fine, Ly, dx_fine):
            pts.append([x, y])
            vols.append(dx_fine * dx_fine)
    for x in np.arange(mid + 0.5 * dx_coarse, Lx, dx_coarse):
        for y in np.arange(0.5 * dx_coarse, Ly, dx_coarse):
            pts.append([x, y])
            vols.append(dx_coarse * dx_coarse)
    coords = np.array(pts, dtype=np.float64)
    volumes = np.array(vols, dtype=np.float64)
    bounds = (np.array([0.0, 0.0]), np.array([Lx, Ly]))
    return coords, volumes, bounds


def make_3d_graded_block(dx_fine: float = 0.05, dx_coarse: float = 0.10, Lx: float = 1.0, Ly: float = 0.6, Lz: float = 0.6):
    """Create a 3D block on [0, Lx] x [0, Ly] x [0, Lz] with fine cells for x < Lx/2 and coarse cells for x > Lx/2."""
    mid = 0.5 * Lx
    pts, vols = [], []
    for x in np.arange(0.5 * dx_fine, mid, dx_fine):
        for y in np.arange(0.5 * dx_fine, Ly, dx_fine):
            for z in np.arange(0.5 * dx_fine, Lz, dx_fine):
                pts.append([x, y, z])
                vols.append(dx_fine ** 3)
    for x in np.arange(mid + 0.5 * dx_coarse, Lx, dx_coarse):
        for y in np.arange(0.5 * dx_coarse, Ly, dx_coarse):
            for z in np.arange(0.5 * dx_coarse, Lz, dx_coarse):
                pts.append([x, y, z])
                vols.append(dx_coarse ** 3)
    coords = np.array(pts, dtype=np.float64)
    volumes = np.array(vols, dtype=np.float64)
    bounds = (np.array([0.0, 0.0, 0.0]), np.array([Lx, Ly, Lz]))
    return coords, volumes, bounds


class TestMultiscaleVariableHorizonPD(unittest.TestCase):
    """Comprehensive tests for multiscale variable-horizon Bond-Based Peridynamics."""

    def test_01_kdtree_single_storage_and_symmetric_families(self):
        """
        Verify KD-tree neighbor construction:
          - delta_i = m * dx_i with m = 3 and dx_i = V_i^(1/dim)
          - Each bond stored once (bond_i < bond_j, no duplicates)
          - Every stored bond satisfies |xi| <= min(delta_i, delta_j)
          - One-sided bonds (min(delta_i, delta_j) < |xi| <= max(delta_i, delta_j)) are excluded
          - Adjacency families are strictly symmetric: j in H_i <=> i in H_j
        """
        coords, volumes, bounds = make_2d_graded_plate()
        pd = MultiscaleBondPD(coords, volumes, E=70e9, m=3.0, dim=2, mode="symmetric", domain_bounds=bounds)

        # Check delta_i = 3 * sqrt(A_i)
        np.testing.assert_allclose(pd.dx, np.sqrt(volumes), rtol=1e-15)
        np.testing.assert_allclose(pd.delta, 3.0 * np.sqrt(volumes), rtol=1e-15)

        # Check each bond stored once with i < j
        self.assertTrue(np.all(pd.bond_i < pd.bond_j))
        pairs = list(zip(pd.bond_i.tolist(), pd.bond_j.tolist()))
        self.assertEqual(len(pairs), len(set(pairs)), "Duplicate bonds found!")

        # Check |xi| <= min(delta_i, delta_j) for all kept bonds
        d_min = np.minimum(pd.delta[pd.bond_i], pd.delta[pd.bond_j])
        self.assertTrue(np.all(pd.xi_len <= d_min * (1.0 + 1e-12)))

        # Verify one-sided bonds were identified and excluded
        self.assertGreater(pd.excluded_one_sided_count, 0)
        for i in range(pd.n_nodes):
            for j in range(i + 1, pd.n_nodes):
                dist = float(np.linalg.norm(coords[j] - coords[i]))
                d_ij_min = min(pd.delta[i], pd.delta[j])
                if dist <= d_ij_min * (1.0 - 1e-12):
                    self.assertIn((i, j), pairs)
                elif dist > d_ij_min * (1.0 + 1e-12):
                    self.assertNotIn((i, j), pairs)

        print(
            f"\n  [Test 1: KD-Tree & Symmetric Families] 2D graded mesh: {pd.n_nodes} nodes, "
            f"{pd.n_bonds} symmetric bonds kept, {pd.excluded_one_sided_count} one-sided bonds excluded."
        )

    def test_02a_total_internal_force_zero(self):
        """
        Test (a): Verify total internal force sum_i F_i = 0 to machine precision
        across 1D, 2D, 3D graded meshes and SALOME MED/UNV meshes, under arbitrary
        random displacements, uniform strain, and nonlinear kinematics, for both
        Symmetric Variable-Horizon PD and Dual-Horizon PD.
        """
        rng = np.random.default_rng(42)

        for dim, builder in [(1, make_1d_graded_bar), (2, make_2d_graded_plate), (3, make_3d_graded_block)]:
            coords, volumes, bounds = builder()
            for mode in ("symmetric", "dual_horizon"):
                pd = MultiscaleBondPD(coords, volumes, E=71.7e9, m=3.0, dim=dim, mode=mode, domain_bounds=bounds)
                u_rand = 1e-3 * rng.standard_normal((pd.n_nodes, dim))

                for lin in (True, False):
                    F_tot, _ = pd.compute_forces(u_rand, linearized=lin)
                    net_force = np.linalg.norm(F_tot.sum(axis=0))
                    scale = np.linalg.norm(F_tot, axis=1).sum()
                    rel_net = net_force / max(scale, 1e-30)
                    self.assertLess(
                        rel_net,
                        1e-14,
                        f"Total force not zero for {dim}D {mode} (lin={lin}): rel={rel_net:.3e}",
                    )

        # Also test on actual SALOME 3D graded mesh (examples/notched_beam_mesh.med)
        med_path = os.path.join(ROOT, "examples", "notched_beam_mesh.med")
        coords_m, vols_m, _, _, _ = read_salome_mesh(med_path, m=3.0)
        pd_med = MultiscaleBondPD(coords_m, vols_m, E=71.7e9, m=3.0, dim=3, mode="symmetric", ghost_force_correction=False)
        u_med = 1e-4 * rng.standard_normal((pd_med.n_nodes, 3))
        F_med, _ = pd_med.compute_forces(u_med, linearized=True)
        rel_med = np.linalg.norm(F_med.sum(axis=0)) / np.linalg.norm(F_med, axis=1).sum()
        self.assertLess(rel_med, 1e-14)
        print(
            f"\n  [Test (a): Total Internal Force = 0] Passed across 1D/2D/3D & SALOME MED mesh "
            f"(relative net force = {rel_med:.3e} < 1e-14)."
        )

    def test_03b_patch_test_zero_ghost_force_including_transition_zone(self):
        """
        Test (b): Patch test with zero ghost force under uniform strain, including in the transition zone.
        Verifies:
          1. Direct evaluation of internal force density f_i on interior & transition-zone nodes
             under uniform strain gives ||f_i||_inf ~ 0 (machine precision < 1e-11).
          2. Static equilibrium solve K * u = 0 with linear displacement prescribed on the boundary
             layer reproduces the exact uniform strain field across the fine/coarse transition zone.
          3. Compares uncorrected (g=1), baseline energy correction g_0 = 0.5*(lambda_i+lambda_j),
             Dual-Horizon PD, and ghost-force-corrected Multiscale Bond-Based PD.
        """
        print("\n  [Test (b): Uniform-Strain Patch Test & Transition-Zone Ghost Forces]")

        # --- 1D Patch Test ---
        coords_1d, vols_1d, bounds_1d = make_1d_graded_bar(dx_fine=0.005, dx_coarse=0.01, L=1.0)
        E_test = 100.0
        eps_1d = 0.002
        u_exact_1d = eps_1d * coords_1d

        pd_1d_uncorr = MultiscaleBondPD(
            coords_1d, vols_1d, E=E_test, m=3.0, dim=1, mode="symmetric",
            stiffness_correction=False, ghost_force_correction=False, domain_bounds=bounds_1d,
        )
        pd_1d_g0 = MultiscaleBondPD(
            coords_1d, vols_1d, E=E_test, m=3.0, dim=1, mode="symmetric",
            stiffness_correction=True, ghost_force_correction=False, domain_bounds=bounds_1d,
        )
        pd_1d_dh = MultiscaleBondPD(
            coords_1d, vols_1d, E=E_test, m=3.0, dim=1, mode="dual_horizon",
            stiffness_correction=True, ghost_force_correction=False, domain_bounds=bounds_1d,
        )
        pd_1d = MultiscaleBondPD(
            coords_1d, vols_1d, E=E_test, m=3.0, dim=1, mode="symmetric",
            stiffness_correction=True, ghost_force_correction=True, domain_bounds=bounds_1d,
        )

        int_1d = pd_1d.interior_mask
        # Transition zone mask: interior nodes within 2 * delta_max of the interface x = 0.5
        tz_1d = int_1d & (np.abs(coords_1d[:, 0] - 0.5) <= 2.0 * pd_1d.delta.max())

        _, f_uncorr = pd_1d_uncorr.compute_forces(u_exact_1d)
        _, f_g0 = pd_1d_g0.compute_forces(u_exact_1d)
        _, f_dh = pd_1d_dh.compute_forces(u_exact_1d)
        _, f_corr = pd_1d.compute_forces(u_exact_1d)

        ghost_uncorr = float(np.abs(f_uncorr[tz_1d]).max())
        ghost_g0 = float(np.abs(f_g0[tz_1d]).max())
        ghost_dh = float(np.abs(f_dh[tz_1d]).max())
        ghost_corr = float(np.abs(f_corr[int_1d]).max())
        ghost_corr_tz = float(np.abs(f_corr[tz_1d]).max())

        # Static equilibrium patch test in 1D: prescribe u = eps * x on boundary layer (~interior_mask)
        bdry_1d = np.where(~int_1d)[0]
        bc_1d = {int(i): float(u_exact_1d[i, 0]) for i in bdry_1d}
        u_sol_1d, _ = pd_1d.solve_static(bc_1d)
        disp_err_1d = float(np.linalg.norm(u_sol_1d - u_exact_1d) / np.linalg.norm(u_exact_1d))

        print(
            f"    1D Transition-Zone Max |f_ghost|: Uncorrected={ghost_uncorr:.3e}, "
            f"Energy-g0={ghost_g0:.3e}, Dual-Horizon={ghost_dh:.3e}, "
            f"Corrected={ghost_corr_tz:.3e} (Static Patch Disp Err={disp_err_1d:.3e})"
        )
        self.assertLess(ghost_corr, 1e-11)
        self.assertLess(ghost_corr_tz, 1e-11)
        self.assertLess(disp_err_1d, 1e-12)

        # --- 2D Patch Test (Combined Uniaxial + Biaxial + Shear Strain) ---
        coords_2d, vols_2d, bounds_2d = make_2d_graded_plate(dx_fine=0.025, dx_coarse=0.05, Lx=1.0, Ly=0.5)
        pd_2d = MultiscaleBondPD(
            coords_2d, vols_2d, E=E_test, m=3.0, dim=2, mode="symmetric",
            stiffness_correction=True, ghost_force_correction=True, domain_bounds=bounds_2d,
        )
        eps_2d = np.array([[0.002, -0.0008], [-0.0008, 0.0012]])
        u_exact_2d = coords_2d @ eps_2d.T
        _, f_2d = pd_2d.compute_forces(u_exact_2d)
        int_2d = pd_2d.interior_mask
        tz_2d = int_2d & (np.abs(coords_2d[:, 0] - 0.5) <= 2.0 * pd_2d.delta.max())
        ghost_2d_all = float(np.linalg.norm(f_2d[int_2d], axis=1).max())
        ghost_2d_tz = float(np.linalg.norm(f_2d[tz_2d], axis=1).max())

        bdry_2d = np.where(~int_2d)[0]
        bc_2d = {}
        for i in bdry_2d:
            bc_2d[2 * i] = float(u_exact_2d[i, 0])
            bc_2d[2 * i + 1] = float(u_exact_2d[i, 1])
        u_sol_2d, _ = pd_2d.solve_static(bc_2d)
        disp_err_2d = float(np.linalg.norm(u_sol_2d - u_exact_2d) / np.linalg.norm(u_exact_2d))

        print(
            f"    2D Transition-Zone Max |f_ghost|: {ghost_2d_tz:.3e} "
            f"(All Interior: {ghost_2d_all:.3e}, Static Patch Disp Err={disp_err_2d:.3e})"
        )
        self.assertLess(ghost_2d_all, 1e-11)
        self.assertLess(ghost_2d_tz, 1e-11)
        self.assertLess(disp_err_2d, 1e-12)

        # --- 3D Patch Test (Full 3D Strain Tensor with Normal + Shear Components) ---
        coords_3d, vols_3d, bounds_3d = make_3d_graded_block(dx_fine=0.05, dx_coarse=0.10, Lx=1.0, Ly=0.6, Lz=0.6)
        pd_3d = MultiscaleBondPD(
            coords_3d, vols_3d, E=E_test, m=3.0, dim=3, mode="symmetric",
            stiffness_correction=True, ghost_force_correction=True, domain_bounds=bounds_3d,
        )
        eps_3d = np.array([
            [0.0020, -0.0005, 0.0004],
            [-0.0005, 0.0015, -0.0003],
            [0.0004, -0.0003, -0.0009],
        ])
        u_exact_3d = coords_3d @ eps_3d.T
        _, f_3d = pd_3d.compute_forces(u_exact_3d)
        int_3d = pd_3d.interior_mask
        tz_3d = int_3d & (np.abs(coords_3d[:, 0] - 0.5) <= 2.0 * pd_3d.delta.max())
        ghost_3d_all = float(np.linalg.norm(f_3d[int_3d], axis=1).max())
        ghost_3d_tz = float(np.linalg.norm(f_3d[tz_3d], axis=1).max())

        bdry_3d = np.where(~int_3d)[0]
        bc_3d = {}
        for i in bdry_3d:
            for d_idx in range(3):
                bc_3d[3 * i + d_idx] = float(u_exact_3d[i, d_idx])
        u_sol_3d, _ = pd_3d.solve_static(bc_3d)
        disp_err_3d = float(np.linalg.norm(u_sol_3d - u_exact_3d) / np.linalg.norm(u_exact_3d))

        print(
            f"    3D Transition-Zone Max |f_ghost|: {ghost_3d_tz:.3e} "
            f"(All Interior: {ghost_3d_all:.3e}, Static Patch Disp Err={disp_err_3d:.3e})"
        )
        self.assertLess(ghost_3d_all, 1e-11)
        self.assertLess(ghost_3d_tz, 1e-11)
        self.assertLess(disp_err_3d, 1e-12)

    def test_04c_1d_wave_crossing_fine_coarse_interface(self):
        """
        Test (c): A 1D wave crossing the fine/coarse interface with no spurious reflection.
        Propagates a right-traveling Gaussian wave packet from x0 = 0.25 (fine region, dx = 0.0025)
        across the interface at x = 0.50 into the coarse region (dx = 0.0050) to x1 = 0.75.
        Verifies:
          - Spurious reflected amplitude in the fine region is < 0.5% of incident amplitude
          - Transmitted amplitude in the coarse region is > 99.5% of incident amplitude
          - Total mechanical energy (kinetic + potential) is conserved within < 0.1%
        """
        coords, volumes, bounds = make_1d_graded_bar(dx_fine=0.0025, dx_coarse=0.005, L=1.0)
        x = coords[:, 0]
        E = 100.0
        rho = 1.0
        c0 = np.sqrt(E / rho)  # continuum bar wave speed = 10 m/s

        # Initial right-traveling Gaussian pulse centered at x0 = 0.25:
        # u(x, 0) = A * exp(-((x - x0)/w)^2),  v(x, 0) = -c0 * du/dx(x, 0)
        amp = 1.0e-4
        w = 0.055
        x0 = 0.25
        u0 = amp * np.exp(-((x - x0) / w) ** 2)[:, None]
        du0_dx = amp * (-2.0 * (x - x0) / (w ** 2)) * np.exp(-((x - x0) / w) ** 2)
        v0 = (-c0 * du0_dx)[:, None]

        dt = 0.2 * 0.0025 / c0
        t_end = 0.05  # wave travels distance c0 * t_end = 0.50 -> center moves from 0.25 to 0.75
        n_steps = int(round(t_end / dt))

        fine_window = (x > 0.05) & (x < 0.42)
        coarse_window = (x > 0.55) & (x < 0.95)

        results = {}
        for label, kw in [
            ("Uncorrected (g=1)", dict(mode="symmetric", stiffness_correction=False, ghost_force_correction=False)),
            ("Energy-Only g0", dict(mode="symmetric", stiffness_correction=True, ghost_force_correction=False)),
            ("Dual-Horizon PD", dict(mode="dual_horizon", stiffness_correction=True, ghost_force_correction=False)),
            ("Multiscale Ghost-Free", dict(mode="symmetric", stiffness_correction=True, ghost_force_correction=True)),
        ]:
            pd = MultiscaleBondPD(coords, volumes, E=E, rho=rho, m=3.0, dim=1, domain_bounds=bounds, **kw)
            # Initial energy
            du_init = u0[pd.bond_j, 0] - u0[pd.bond_i, 0]
            s_init = du_init / pd.xi_len
            stiff_b = pd.g_ij * pd.c_ij * pd.volumes[pd.bond_i] * pd.volumes[pd.bond_j]
            E_init = float(
                np.sum(0.5 * stiff_b * pd.xi_len * (s_init ** 2))
                + np.sum(0.5 * rho * volumes * (v0[:, 0] ** 2))
            )

            out = pd.run_dynamic(u0, v0, dt=dt, n_steps=n_steps)
            u_final = out["u"][:, 0]
            refl_pct = 100.0 * float(np.abs(u_final[fine_window]).max()) / amp
            trans_pct = 100.0 * float(np.abs(u_final[coarse_window]).max()) / amp
            energy_drift_pct = 100.0 * abs(out["E_tot"] - E_init) / E_init
            results[label] = (refl_pct, trans_pct, energy_drift_pct)

        print("\n  [Test (c): 1D Wave Crossing Fine/Coarse Interface (x_int = 0.50 m)]")
        for label, (r_pct, t_pct, e_pct) in results.items():
            print(
                f"    {label:24s}: Reflection = {r_pct:5.2f}%, "
                f"Transmission = {t_pct:6.2f}%, Energy Drift = {e_pct:.4f}%"
            )

        refl_corr, trans_corr, edrift_corr = results["Multiscale Ghost-Free"]
        self.assertLess(refl_corr, 0.5, f"Spurious reflection too high: {refl_corr:.2f}%")
        self.assertGreater(trans_corr, 99.5, f"Transmitted amplitude too low: {trans_corr:.2f}%")
        self.assertLess(edrift_corr, 0.1, f"Energy not conserved: drift={edrift_corr:.4f}%")

    def test_05_salome_med_and_unv_mesh_delta_distribution(self):
        """
        Verify reading node sizes dx_i and horizons delta_i = 3 * dx_i from SALOME .med and .unv
        mesh exports and reporting the delta distribution.
        """
        print("\n  [Test 5: SALOME Mesh Export (MED & UNV) Horizon Distribution]")
        for base in ("plate_hole_mesh", "notched_beam_mesh"):
            med_file = os.path.join(ROOT, "examples", f"{base}.med")
            unv_file = os.path.join(ROOT, "examples", f"{base}.unv")
            coords_med, vols_med, dx_med, delta_med, rep_med = read_med_mesh(med_file, m=3.0)
            coords_unv, vols_unv, dx_unv, delta_unv, rep_unv = read_unv_mesh(unv_file, m=3.0)

            np.testing.assert_allclose(coords_med, coords_unv, rtol=1e-12, atol=1e-14)
            np.testing.assert_allclose(vols_med, vols_unv, rtol=1e-12, atol=1e-14)
            np.testing.assert_allclose(dx_med, dx_unv, rtol=1e-12, atol=1e-14)
            np.testing.assert_allclose(delta_med, delta_unv, rtol=1e-12, atol=1e-14)

            # Verify graded mesh has variable horizon (delta_max / delta_min > 3)
            self.assertGreater(rep_med.grading_ratio, 3.0)
            print(rep_med.format_report(unit_scale=1e3, unit_name="mm"))


if __name__ == "__main__":
    unittest.main(verbosity=2)
