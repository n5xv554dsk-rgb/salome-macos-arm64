# SALOME Platform — Native macOS Apple Silicon (`arm64`) Port

Native macOS (`arm64`) port, build environment, and 3D engineering examples for all **44 open-source SALOME modules** (SALOME 9.15 / master) + custom prerequisites (`OpenCASCADE 7.8.1`, `ParaView 6.0`, `MEDfile 6.0.1`, `SOLVERLAB` with `PETSc 3.26` & `SLEPc 3.26`, `Netgen 6.2`, `Gmsh 4.15`, `PyQt5` + `SIP`, `Qwt`, `omniORB`).

## Prebuilt Binaries (macOS `arm64`)

Download `salome-macos-arm64-binaries.tar.gz` from the [**Releases**](../../releases) tab and extract it in the repository root:

```bash
tar -xzf salome-macos-arm64-binaries.tar.gz
```

## Quick Start

### 1. Run the 4-Stage 3D Thermal Cooling Block Simulation
```bash
./salome python examples/thermal_cooling_block.py
```
This runs:
1. **Stage 1 (`SHAPER` + `GEOM`)**: 3D parametric CAD modeling of a 3-channel aluminum cooling block.
2. **Stage 2 (`SMESH` + `NETGEN_1D2D3D`)**: 3D unstructured tetrahedral meshing (`2,215` nodes, `8,716` tetrahedra).
3. **Stage 3 (`MEDCoupling` + `SOLVERLAB`/`CDMATH` + `SciPy`)**: 3D finite-element steady-state heat conduction solver.
4. **Stage 4 (`PARAVIS` / `ParaView` + `MEDReader.so`)**: 3D offscreen visualization and cutaway rendering (`examples/cooling_block_3d_exterior.png` & `examples/cooling_block_3d_cutaway.png`).

### 2. Launch Interactive SALOME Shell or Desktop GUI
```bash
# Interactive shell with all 44 SALOME modules on PATH / PYTHONPATH / DYLD_LIBRARY_PATH:
./salome shell

# Launch the SALOME desktop GUI:
./salome
```
