"""pdsalome — dynamic peridynamics inside SALOME (GEOM/SMESH -> libpdcore -> MED -> PARAVIS)."""

from .core import FIXED, FORCE, VELOCITY, PDSolver, critical_dt, s0_from_G0  # noqa: F401
