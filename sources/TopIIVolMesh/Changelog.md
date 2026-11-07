# Changelog
All notable changes to top-ii-vol mesher will be documented in this file.

## [Rolling Release]

### Added

- Added `.med` extension for `topIIvol_Mesher`
- New configuration flags `--with-medfile`, `--with-medcoupling`  and `--with-hdf5` for providing med support.

### Changed

- `topIIvol_DistMesher` input DEM is given with `.xyz` suffix e.g. `--in filename.xyz `.

## [1.3] 11-01-2021

### Added
- Smarter way to perform 1D partitioning, algorithm decides based on points in each direction.
- New flags `--partition_x`, `--partition_y`  and `--partition_z` to decide # of partitions in each direction. 
- Installation now performed at `/usr/local/bin` or `/usr/bin`.
- More tutorials and examples.
- Different labeling for different surfaces for `.msh` mesher.
- Faster file writing for sequential mesher and preprocessor.
- Faster and more robust parallel partitonoing of point cloud for distributed mesher.

### Changed

- Tools renamed from `top-ii-vol_*`  to `topIIvol_*`.

### Bug

- one layer was missing in x-direction, causing load imbalance (see c2aecf0).


## [1.2] 2020‑10‑15
### Added
- PSD interface for exascale computing
- New header for all files
- Better algorithm for parallel mesher
  - Dimension with Highest number of points gets partitioned
  - Unbalanced partitioning improved
- Parallel partitioner for point cloud (sequential before)
- Parallel mesher migration to C++

### Removed
- Merged the partitioner and distributed mesher, no more `top-ii-vol-Part`
- No more `--scatter`, now a part of parallel mesher
- Parallel mehser in C (migrated to C++)

### Bug

- proper labeling for `.msh` was missing : now fixed



## [1.1] 2020‑03‑31
### Added
- New MPI based distributed mesher
- New partitioner for distributed mesher
- Fully parallel MPI I/O, now partitioning can be even or unbalaced 
- Moved to automake for cross platform installation 

### Changed
- Name changes from Top2Vol to top-ii-vol
- Larger buffer size written at once to improve performance 5X

## [1.0] 2019‑12‑19
### Added
- Meshes can now be exported in `.msh` and `.mesh` format
- New Parallel mesher based on MPI I/O
- New tool for preprocessing point cloud

## [0.0] 2019‑10‑09
### Added
- Moved to git 
- Sequential mesher for `.msh` format : `full-mesh.cpp`
