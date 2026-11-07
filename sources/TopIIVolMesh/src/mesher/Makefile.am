FILE1 = topIIvol_PreProc.cpp 
FILE2 = topIIvol_Mesher.cpp

all-local:topIIvol_PreProc topIIvol_Mesher
	@echo " *============================================================*"
	@echo ""
	@echo " Compilation list in"; pwd
	@echo "  # $(FILE1)"
	@echo "  # $(FILE2)"
	@echo ""
	@echo " Finished compiling topIIvol tools:"
	@echo ""
	@echo "  # topIIvol_PreProc"
	@echo "           A point-cloud preprocessor  (sequential)"
	@echo "  # topIIvol_Mesher"
	@echo "           A point-cloud volume mesher (sequential)"
	@echo ""
	@echo " *============================================================*"

bin_PROGRAMS                = topIIvol_PreProc  topIIvol_Mesher
topIIvol_PreProc_SOURCES    = topIIvol_PreProc.cpp
topIIvol_Mesher_SOURCES     = topIIvol_Mesher.cpp

if HAVEMED
topIIvol_Mesher_LDFLAGS=$(LDFLAGS_MED)
topIIvol_Mesher_LDADD=$(LIBS_MED)
endif


topIIvol_PreProc.o: topIIvol_PreProc.cpp ./../lib/LogoTopiiVolCpp.hpp
	$(CXX) -c topIIvol_PreProc.cpp -std=c++11

#g++ -L/home/catA/mb258512/Install/TarPackages/SALOME-9.9.0-native-UB22.04-SRC/BINARIES-UB22.04/MEDCOUPLING/lib -L/home/catA/mb258512/Install/TarPackages/SALOME-9.9.0-native-UB22.04-SRC/BINARIES-UB22.04/medfile/lib -L/home/catA/mb258512/Install/TarPackages/SALOME-9.9.0-native-UB22.04-SRC/BINARIES-UB22.04/hdf5/lib -o topIIvol_Mesher topIIvol_Mesher.o -lmedloader -lmedcoupling -linterpkernel -lmedcouplingremapper -lmedC -lhdf5


topIIvol_Mesher.o: topIIvol_Mesher.cpp
if HAVEMED
	$(CXX) $(CXXFLAGS_MED) -c topIIvol_Mesher.cpp -std=c++11  -DMEDCOUPLING
else !HAVEMED
	$(CXX) -c topIIvol_Mesher.cpp -std=c++11
	@echo ""
endif

check-local:
	./topIIvol_PreProc --xpoints 500 --ypoints 451 --zpoints 7 --xskip 10 --yskip 10 --in ../../data/DEM_10m.xyz --out out-coarse.xyz
	./topIIvol_Mesher --xpoints 50 --ypoints 46 --zpoints 3 --in out-coarse.xyz --out out-mesh.mesh --depth -1000 --mesh mesh
	./topIIvol_Mesher --xpoints 50 --ypoints 46 --zpoints 3 --in out-coarse.xyz --out out-mesh.msh --depth -1000 --mesh msh
	@echo ""

NP = 2

test-freefem: check-local
	ff-mpirun -np $(NP) ../../test/NoreconstructSeq.edp -v 0
	paraview

clean-local:
	@echo ""
	@echo "*============================================================*"
	@echo " Cleaning files in :"; pwd
	@echo "*============================================================*"
	@echo ""
	rm  -f topIIvol_Mesher topIIvol_PreProc
	rm  -f *~ *.o *.vtu *.pvd *.xyz *.info *.mesh *.txt  *.meshb *.msh
	@echo ""
