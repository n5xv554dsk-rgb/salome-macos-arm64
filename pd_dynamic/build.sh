#!/bin/zsh
# Build libpdcore.dylib (OpenMP). Usage: ./build.sh
cd "${0:A:h}"
mkdir -p build
OMP=/opt/homebrew/opt/libomp
clang++ -O3 -march=native -std=c++17 -shared -fPIC \
  -Xpreprocessor -fopenmp -I$OMP/include -L$OMP/lib -lomp -Wl,-rpath,$OMP/lib \
  src/pdcore.cpp -o build/libpdcore.dylib && echo "built build/libpdcore.dylib"
