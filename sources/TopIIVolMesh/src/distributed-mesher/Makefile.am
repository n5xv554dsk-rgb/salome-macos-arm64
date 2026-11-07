FILE1= topIIvol_MPImesher.cpp 

TEST_FILE=./../../data/DEM_160m.xyz
NP=4

all-local: topIIvol_DistMesher
	@echo " *============================================================*"
	@echo ""
	@echo " Compilation list in:" ; pwd
	@echo "  # $(FILE1)"
	@echo ""
	@echo " Finished compiling topIIvol tools"
	@echo ""
	@echo "  # topIIvol_DistMesher-> Point-cloud distributed volume mesher (parallel)"
	@echo ""
	@echo " *============================================================*"

CXX = $(MPICXX)
bin_PROGRAMS               = topIIvol_DistMesher
topIIvol_DistMesher_SOURCES = topIIvol_DistMesher.cpp


topIIvol_DistMesher.o: topIIvol_DistMesher.cpp ./../lib/TopiiVolPartAlgo1D2D3D.hpp ./../lib/TopiiVolMeshAlgo1D2D3D.hpp ./../lib/LogoTopiiVolCpp.hpp
	$(MPICXX) -c topIIvol_DistMesher.cpp -std=c++11

#top-ii-vol-DistMesher: top-ii-vol-MPImesher.o
#	$(MPICXX) -o top-ii-vol-DistMesher top-ii-vol-MPImesher.o 
#	@echo "" 

check-local: topIIvol_DistMesher.o
	mpirun --oversubscribe -np $(NP) ./topIIvol_DistMesher --zpoints 50 --xpoints 32 --ypoints 29 --depth -1000 --out top-ii-vol-mesh  --in $(TEST_FILE)
	mpirun --oversubscribe -np $(NP) ./topIIvol_DistMesher --zpoints 50 --xpoints 32 --ypoints 29 --depth -1000 --out top-ii-vol-mesh  --in $(TEST_FILE) --partition_x 1 --partition_y 4
	mpirun --oversubscribe -np $(NP) ./topIIvol_DistMesher --zpoints 50 --xpoints 32 --ypoints 29 --depth -1000 --out top-ii-vol-mesh  --in $(TEST_FILE) --partition_x 4 --partition_y 1
	mpirun --oversubscribe -np $(NP) ./topIIvol_DistMesher --zpoints 50 --xpoints 32 --ypoints 29 --depth -1000 --out top-ii-vol-mesh  --in $(TEST_FILE) --partition_x 2 --partition_y 2
	mpirun --oversubscribe -np $(NP) ./topIIvol_DistMesher --zpoints 50 --xpoints 32 --ypoints 29 --depth -1000 --out top-ii-vol-mesh  --in $(TEST_FILE) --partition_x 2 --partition_z 2
	mpirun --oversubscribe -np $(NP) ./topIIvol_DistMesher --zpoints 50 --xpoints 32 --ypoints 29 --depth -1000 --out top-ii-vol-mesh  --in $(TEST_FILE) --partition_y 2 --partition_z 2
	mpirun --oversubscribe -np $(NP) ./topIIvol_DistMesher --zpoints 50 --xpoints 32 --ypoints 29 --depth -1000 --out top-ii-vol-mesh  --in $(TEST_FILE) --partition_x 1 --partition_z 4
	mpirun --oversubscribe -np $(NP) ./topIIvol_DistMesher --zpoints 50 --xpoints 32 --ypoints 29 --depth -1000 --out top-ii-vol-mesh  --in $(TEST_FILE) --partition_x 1 --partition_z 2 --partition_y 2
	mpirun --oversubscribe -np $(NP) ./topIIvol_DistMesher --zpoints 50 --xpoints 32 --ypoints 29 --depth -1000 --out top-ii-vol-mesh  --in $(TEST_FILE) --partition_x 2 --partition_y 2 --partition_z 1
	@echo ""

test-freefem: ./../../test/reconstruct.edp
	ff-mpirun -np $(NP) ../../test/reconstruct.edp -v 0
	paraview vtk_$(NP).pvd
	@echo ""  

clean-local:
	@echo ""
	@echo "*============================================================*"
	@echo " Cleaning files in :"; pwd
	@echo "*============================================================*"
	@echo ""
	rm  -f *~  topIIvol_DistMesher *.o *.vtu *.pvd *.xyz
	rm  -f *.xyz *.info *.mesh *.txt  *.meshb *.msh *.khi
	@echo ""
