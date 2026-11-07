FILE1= topIIvol_ParMesher.cpp 

all-local:
	@echo " *============================================================*"
	@echo ""
	@echo " Compilation list in"; pwd
	@echo "  # $(FILE1)"
	@echo ""
	@echo " Finished compiling topIIvol tools:"
	@echo ""
	@echo "  # topIIvol_ParMesher"
	@echo "           A point-cloud volume mesher (parallel)"
	@echo ""
	@echo " *============================================================*"

CXX = $(MPICXX)
bin_PROGRAMS               = topIIvol_ParMesher
topIIvol_ParMesher_SOURCES = topIIvol_ParMesher.cpp

topIIvol_ParMesher.o: topIIvol_ParMesher.cpp ./../lib/TopiiVolPartitionPointCloudAlgo.h ./../lib/LogoTopiiVolC.h
	$(MPICXX) -c topIIvol_ParMesher.cpp -std=c++11

#topIIvol_ParMesher: topIIvol_Mesher.o
#	$(MPICXX) -o topIIvol_ParMesher topIIvol_Mesher.o
#	@echo ""

NP=3
SX=24
SY=24
PZ=15
SX1=105
SY1=94

check-local:
	mpirun --oversubscribe -n $(NP) ./topIIvol_ParMesher --xpoints 32 --ypoints 29 --zpoints $(PZ) --depth -3000  --in ./../../data/DEM_160m.xyz --out Parallel-out-mesh.mesh
##	mpirun -n $(NP) ./top-ii-vol-ParMesher --xpoints $(SX1) --ypoints $(SY1) --zpoints $(PZ) --depth -2000  --in out-coarse-striped.xyz --out Parallel-out-mesh.mesh
	@echo ""

test-freefem: check-local
	ff-mpirun -np $(NP) ../../test/NoreconstructPar.edp -v 0
	paraview

clean-local:
	@echo ""
	@echo "*============================================================*"
	@echo " Cleaning files in :"; pwd
	@echo "*============================================================*"
	@echo ""
	rm  -f topIIvol_ParMesher 
	rm  -f *~ *.o *.vtu *.pvd *.xyz *.info *.mesh *.txt  *.meshb *.msh
	@echo ""
