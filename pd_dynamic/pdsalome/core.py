"""ctypes wrapper around libpdcore (dynamic ordinary state-based peridynamics, 3D)."""

import ctypes as C
import os
import time

import numpy as np

_HERE = os.path.dirname(os.path.abspath(__file__))
_LIB = os.path.join(_HERE, "..", "build", "libpdcore.dylib")

# Boundary-condition codes (per DOF)
FIXED = 0      # u = value (constant)
FORCE = 1      # body force density value * f(t)  [N/m^3]  (free DOF when value = 0)
VELOCITY = 2   # u = value * t  (prescribed velocity, m/s)

_d = np.ctypeslib.ndpointer(dtype=np.float64, flags="C_CONTIGUOUS")
_i = np.ctypeslib.ndpointer(dtype=np.int32, flags="C_CONTIGUOUS")


def _load():
    if not os.path.exists(_LIB):
        raise RuntimeError(f"{_LIB} not found: run pd_dynamic/build.sh first")
    lib = C.CDLL(_LIB)
    vp = C.c_void_p
    sig = {
        "pd_create": (vp, [C.c_int, _d, _d, C.c_double, C.c_double, C.c_int]),
        "pd_destroy": (None, [vp]),
        "pd_num_threads": (C.c_int, []),
        "pd_set_material": (None, [vp, C.c_double, C.c_double, C.c_double, C.c_double]),
        "pd_add_precrack": (None, [vp, _d, _d, _d]),
        "pd_build": (C.c_int64, [vp]),
        "pd_set_bc": (None, [vp, _i, _d]),
        "pd_set_ic": (None, [vp, _i, _d]),
        "pd_set_load_ramp": (None, [vp, C.c_double]),
        "pd_run": (C.c_int, [vp, C.c_int, C.c_double]),
        "pd_get_u": (None, [vp, _d]),
        "pd_get_v": (None, [vp, _d]),
        "pd_get_a": (None, [vp, _d]),
        "pd_get_phi": (None, [vp, _d]),
        "pd_get_theta": (None, [vp, _d]),
        "pd_time": (C.c_double, [vp]),
        "pd_step": (C.c_int64, [vp]),
        "pd_max_horizon": (C.c_int, [vp]),
        "pd_broken_bonds": (C.c_int64, [vp]),
    }
    for name, (res, args) in sig.items():
        f = getattr(lib, name)
        f.restype = res
        f.argtypes = args
    return lib


_lib = None


def lib():
    global _lib
    if _lib is None:
        _lib = _load()
    return _lib


def s0_from_G0(G0, E, R, nu=0.25):
    """Critical stretch from fracture energy, 3D (bond-based formula, as in make_case3d.py)."""
    return float(np.sqrt(5.0 * G0 / (6.0 * E * R)))


def critical_dt(E, nu, rho, dx):
    """Local P-wave CFL estimate dx / c_p (PD is usually less strict; use ~0.3-0.5 of this)."""
    cp = np.sqrt(E * (1 - nu) / (rho * (1 + nu) * (1 - 2 * nu)))
    return dx / cp


class PDSolver:
    """Explicit dynamic OSB peridynamics on a cloud of nodes (one node per mesh cell).

    X: (n,3) coordinates, vol: (n,) volumes, R: horizon, dx: grid spacing (partial-volume beta)
    """

    def __init__(self, X, vol, R, dx, influence=1):
        self.X = np.ascontiguousarray(X, dtype=np.float64).reshape(-1, 3)
        self.vol = np.ascontiguousarray(vol, dtype=np.float64)
        self.n = len(self.vol)
        self.R, self.dx = float(R), float(dx)
        self._h = lib().pd_create(self.n, self.X.ravel(), self.vol, self.R, self.dx, int(influence))
        self.bc_type = np.full((self.n, 3), FORCE, dtype=np.int32)
        self.bc_value = np.zeros((self.n, 3))
        self.ic_type = np.ones((self.n, 3), dtype=np.int32)
        self.ic_value = np.zeros((self.n, 3))
        self.nbonds = None

    def __del__(self):
        if getattr(self, "_h", None):
            lib().pd_destroy(self._h)
            self._h = None

    # --- setup ---------------------------------------------------------------
    def set_material(self, E, nu, rho, s0):
        self.E, self.nu, self.rho, self.s0 = E, nu, rho, s0
        lib().pd_set_material(self._h, E, nu, rho, s0)

    def add_precrack(self, p0, p1, p2):
        """Rectangle p0 + u(p1-p0) + v(p2-p0), 0<=u,v<=1. Bonds crossing it are cut."""
        a = [np.ascontiguousarray(p, dtype=np.float64) for p in (p0, p1, p2)]
        lib().pd_add_precrack(self._h, *a)

    def build(self):
        t = time.perf_counter()
        self.nbonds = lib().pd_build(self._h)
        self.build_time = time.perf_counter() - t
        return self.nbonds

    def traction(self, mask, sigma, thickness):
        """Apply a surface traction sigma (Pa, vector) as body force sigma/thickness on the layer `mask`."""
        self.bc_type[mask] = FORCE
        self.bc_value[mask] = np.asarray(sigma, dtype=np.float64) / thickness

    def fix(self, mask, dofs=(0, 1, 2), value=0.0):
        for k in dofs:
            self.bc_type[mask, k] = FIXED
            self.bc_value[mask, k] = value

    def velocity(self, mask, dof, v):
        self.bc_type[mask, dof] = VELOCITY
        self.bc_value[mask, dof] = v

    def load_ramp(self, t_ramp):
        lib().pd_set_load_ramp(self._h, float(t_ramp))

    def apply(self):
        """Send BC/IC arrays to the solver (call after build and after changing them)."""
        lib().pd_set_bc(self._h, np.ascontiguousarray(self.bc_type.ravel()), np.ascontiguousarray(self.bc_value.ravel()))
        lib().pd_set_ic(self._h, np.ascontiguousarray(self.ic_type.ravel()), np.ascontiguousarray(self.ic_value.ravel()))

    # --- run -----------------------------------------------------------------
    def run(self, nsteps, dt):
        if lib().pd_run(self._h, int(nsteps), float(dt)) != 0:
            raise RuntimeError("pd_run failed: call build() first")

    def _get(self, fn, shape):
        out = np.empty(shape)
        fn(self._h, out.ravel())
        return out

    @property
    def u(self): return self._get(lib().pd_get_u, (self.n, 3))
    @property
    def v(self): return self._get(lib().pd_get_v, (self.n, 3))
    @property
    def a(self): return self._get(lib().pd_get_a, (self.n, 3))
    @property
    def phi(self): return self._get(lib().pd_get_phi, (self.n,))
    @property
    def theta(self): return self._get(lib().pd_get_theta, (self.n,))
    @property
    def time(self): return lib().pd_time(self._h)
    @property
    def step(self): return lib().pd_step(self._h)
    @property
    def max_horizon(self): return lib().pd_max_horizon(self._h)
    @property
    def broken_bonds(self): return lib().pd_broken_bonds(self._h)

    @staticmethod
    def threads():
        return lib().pd_num_threads()
