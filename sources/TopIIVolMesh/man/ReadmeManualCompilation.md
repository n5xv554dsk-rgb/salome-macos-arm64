# Manual compilation of top-ii-vol tools

Plan is to build Automake compilation for multiplatform builds but for now the manual setup should be followed:

#### top-ii-vol-PreProc

It has two main functions 

- Provides way to coarsen the point cloud by skipping points.
- Provides point cloud scattering (necessary for parallel for now).

To compile and build the executable 

```
g++ -c Top2Vol-preproc.cpp -std=c++11 ; g++ -o top-ii-vol-PreProc Top2Vol-preproc.o
```

#### top-ii-vol-Mesher

This is a sequential mesher that can output `.msh` and `.mesh` format tetrahedral meshes.

To compile and build the executable 

```
g++ -c Top2Vol-Mesher.cpp -std=c++11 ; g++ -o top-ii-vol-Mesher Top2Vol-Mesher.o
```

#### top-ii-vol-ParMesher

This is a parallel mesher that can output `.msh` and `.mesh` format tetrahedral meshes.

To compile and build the executable 

```
mpicc -c ParTop2Vol-Mesher.c -std=c99 ; mpicc -o top-ii-vol-ParMesher ParTop2Vol-Mesher.o
```

#### top-ii-vol-Part

This is point-cloud mesh partitioner that breaks the point cloud into strips.

To compile and build the executable 

```
g++ -c top-ii-vol-partitioner.cpp -std=c++11 ; g++ -o top-ii-vol-Part top-ii-vol-partitioner.o
```


#### top-ii-vol-DistMesher

This is MPI based distributed mesher that can output `.mesh` format tetrahedral meshes.

To compile and build the executable 

```
mpic++ -c top-ii-vol-MPImesher.cpp -std=c++11 ; mpic++ -o top-ii-vol-DistMesher top-ii-vol-MPImesher.o
```


